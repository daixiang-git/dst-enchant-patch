local ENCHANT_OK, ENCHANT_ENUM = pcall(require, "enums/hh_enchant")
local HH_GEM_BUFF_LIST = ENCHANT_OK and ENCHANT_ENUM ~= nil and ENCHANT_ENUM.HH_GEM_BUFF_LIST or {}
local ITEM_OK, HH_ITEMS = pcall(require, "enums/hh_items")
HH_ITEMS = ITEM_OK and HH_ITEMS or {}

local KEY_GEMS_LIST = "gems_list"
local KEY_INST = "inst"
local KEY_GEM_LEVEL_DATA = "gem_level_data"

local function ShallowCopy(list)
    local result = {}
    if type(list) == "table" then
        for i, v in ipairs(list) do
            result[i] = v
        end
    end
    return result
end

local function GetGemsList(self)
    if type(self[KEY_GEMS_LIST]) ~= "table" then
        self[KEY_GEMS_LIST] = {}
    end
    return self[KEY_GEMS_LIST]
end

local function EnsureGemLevelData(self)
    local gems_list = GetGemsList(self)
    local level_data = self[KEY_GEM_LEVEL_DATA]
    if type(level_data) ~= "table" then
        level_data = {}
        self[KEY_GEM_LEVEL_DATA] = level_data
    end

    for i = 1, #gems_list do
        if type(level_data[i]) ~= "number" or level_data[i] < 1 then
            level_data[i] = 1
        end
    end
    for i = #level_data, #gems_list + 1, -1 do
        level_data[i] = nil
    end

    return level_data
end

local function GetEquippedOwner(self)
    local inst = self[KEY_INST]
    if inst == nil or inst.components == nil then
        return nil
    end
    if inst.components.equippable ~= nil
        and inst.components.equippable:IsEquipped()
        and inst.components.inventoryitem ~= nil
    then
        return inst.components.inventoryitem.owner
    end
    return nil
end

local function FindGemOperatePlayer(self)
    local equip_inst = self[KEY_INST]
    if equip_inst == nil or AllPlayers == nil then
        return nil
    end

    for _, player in ipairs(AllPlayers) do
        local hh_player = player ~= nil and player.components ~= nil and player.components.hh_player or nil
        local ui_container = hh_player ~= nil and hh_player.ui_container or nil
        local container = ui_container ~= nil and ui_container.components ~= nil and ui_container.components.container or nil
        if container ~= nil and container:GetItemInSlot(0x1c) == equip_inst then
            return hh_player
        end
    end

    return nil
end

local function RollbackGemUpgrade(equip_cmp, upgrade_info)
    if equip_cmp == nil or upgrade_info == nil then
        return
    end

    local level_data = EnsureGemLevelData(equip_cmp)
    level_data[upgrade_info.index] = upgrade_info.old_level

    local owner = GetEquippedOwner(equip_cmp)
    if owner ~= nil then
        ApplyEquipLevelDelta(equip_cmp, owner, upgrade_info.gem_name, 1, false)
        RefreshOwnerAfterGemChange(owner)
    end
end

local function GetGemData(gem_name)
    return type(HH_GEM_BUFF_LIST) == "table" and HH_GEM_BUFF_LIST[gem_name] or nil
end

local DEFAULT_UPGRADEABLE_GEM_MAX_LEVEL = 10
local GEM_CONVERT_PREFIX = "convert:"
local PENDING_SPECIAL_GEM_UPGRADE = nil
local LAST_GEM_QUERY = nil

local SPECIAL_GEM_MAX_LEVEL = {
    shadowNightBead = 5,
    twilightBead = 5,
    dayShineBead = 5,
}

local NON_CONVERTIBLE_GEMS = {
    baconOmeletteBlessArmor = true,
    baconOmeletteBlessAtk = true,
    baconOmeletteBlessCritical = true,
    baconOmeletteTrueDamage = true,
    elementBead = true,
    eightPigGem = true,
    fxGem = true,
    nkGem = true,
    treasure_armor = true,
    treasure_atk = true,
    treasure_bj = true,
}

local function GetGemMaxLevel(gem_name, gem_data)
    gem_data = gem_data or GetGemData(gem_name)
    if gem_data == nil then
        return nil
    end

    if type(gem_data.max_level) == "number" then
        return gem_data.max_level
    end

    if gem_data.start_fn ~= nil or gem_data.end_fn ~= nil then
        return 1
    end

    return SPECIAL_GEM_MAX_LEVEL[gem_name] or DEFAULT_UPGRADEABLE_GEM_MAX_LEVEL
end

local function IsUpgradeableGem(gem_name)
    local gem_data = GetGemData(gem_name)
    if gem_data == nil then
        return false
    end

    local max_level = GetGemMaxLevel(gem_name, gem_data)
    if type(max_level) == "number" and max_level <= 1 then
        return false
    end

    return true
end

local function IsConvertibleGem(gem_name, gem_data)
    gem_data = gem_data or GetGemData(gem_name)
    if gem_data == nil then
        return false
    end
    if NON_CONVERTIBLE_GEMS[gem_name] then
        return false
    end
    if gem_data.start_fn ~= nil or gem_data.end_fn ~= nil then
        return false
    end
    if gem_name == "attackRangeBead" then
        return true
    end
    if gem_data.only_one then
        return false
    end
    if type(gem_data.max_level) == "number" and gem_data.max_level <= 1 then
        return false
    end
    return true
end

local function GetConvertibleGemPool(exclude_gem_name)
    local pool = {}
    if type(HH_GEM_BUFF_LIST) ~= "table" then
        return pool
    end

    for gem_name, gem_data in pairs(HH_GEM_BUFF_LIST) do
        if gem_name ~= exclude_gem_name and IsConvertibleGem(gem_name, gem_data) then
            table.insert(pool, gem_name)
        end
    end

    return pool
end

local function SetPendingSpecialGemUpgrade(data)
    PENDING_SPECIAL_GEM_UPGRADE = data
end

local function PeekPendingSpecialGemUpgrade()
    return PENDING_SPECIAL_GEM_UPGRADE
end

local function ClearPendingSpecialGemUpgrade()
    PENDING_SPECIAL_GEM_UPGRADE = nil
end

local function SetLastGemQuery(player_cmp, gem_name)
    LAST_GEM_QUERY = {
        player_cmp = player_cmp,
        gem_name = gem_name,
        time = GetTime ~= nil and GetTime() or 0,
    }
end

local function ConsumeLastGemQuery(gem_name)
    local query = LAST_GEM_QUERY
    LAST_GEM_QUERY = nil
    if query == nil or query.gem_name ~= gem_name then
        return nil
    end
    if GetTime ~= nil and type(query.time) == "number" and GetTime() - query.time > 1 then
        return nil
    end
    return query.player_cmp
end

local function ApplyEquipLevelDelta(self, owner, gem_name, times, equip_bool)
    if owner == nil or times == nil or times <= 0 then
        return
    end

    local gem_data = GetGemData(gem_name)
    if gem_data == nil then
        return
    end

    local fn = equip_bool and gem_data.on_equip_fn or gem_data.un_equip_fn
    if fn == nil then
        return
    end

    for _ = 1, times do
        pcall(fn, self[KEY_INST], owner)
    end
end

local function RefreshOwnerAfterGemChange(owner)
    if owner ~= nil and owner:IsValid() then
        owner:PushEvent("handle_equip_to_player")
    end
end

local function FindRemovedIndex(old_list, new_list)
    local old_len = #old_list
    local new_len = #new_list
    if old_len <= new_len then
        return nil
    end

    for i = 1, new_len do
        if old_list[i] ~= new_list[i] then
            return i
        end
    end
    return old_len
end

AddComponentPostInit("hh_equip", function(self, inst)
    local old_AddNewGem = self.AddNewGem
    local old_ReduceGemByIndex = self.ReduceGemByIndex
    local old_OnSave = self.OnSave
    local old_OnLoad = self.OnLoad
    local old_GetGemDebugList = self.GetGemDebugList
    local old_HandleEquipBuffToPlayer = self.HandleEquipBuffToPlayer

    function self:GetGemLevelByIndex(index)
        local level_data = EnsureGemLevelData(self)
        return level_data[index] or 1
    end

    function self:FindUpgradeableGemIndex(gem_name)
        if not IsUpgradeableGem(gem_name) then
            return nil
        end
        local gems_list = GetGemsList(self)
        local level_data = EnsureGemLevelData(self)
        for i, v in ipairs(gems_list) do
            if v == gem_name then
                local gem_data = GetGemData(v)
                local level = level_data[i] or 1
                local max_level = GetGemMaxLevel(v, gem_data)
                if type(max_level) ~= "number" or level < max_level then
                    return i
                end
            end
        end
        return nil
    end

    function self:UpgradeGemByIndex(index)
        local gems_list = GetGemsList(self)
        local gem_name = gems_list[index]
        local gem_data = GetGemData(gem_name)
        if gem_name == nil then
            return false, "要升级的宝石不存在"
        end
        if not IsUpgradeableGem(gem_name) then
            return false, "该宝石当前不支持等级升级"
        end

        local level_data = EnsureGemLevelData(self)
        local old_level = level_data[index] or 1
        local max_level = GetGemMaxLevel(gem_name, gem_data)
        if type(max_level) == "number" and old_level >= max_level then
            return false, string.format("%s 已达到最高等级 Lv.%s", tostring(gem_data and gem_data.name or gem_name), tostring(max_level))
        end
        level_data[index] = old_level + 1

        local owner = GetEquippedOwner(self)
        if owner ~= nil then
            ApplyEquipLevelDelta(self, owner, gem_name, 1, true)
            RefreshOwnerAfterGemChange(owner)
        end

        return true, string.format("%s 升级到 Lv.%s", tostring(gem_data and gem_data.name or gem_name), tostring(level_data[index]))
    end

    self.AddNewGem = function(self, gem_name)
        local old_len = #GetGemsList(self)
        if self:HasEmptyGroove() then
            local success, message = old_AddNewGem(self, gem_name)
            if success then
                local new_len = #GetGemsList(self)
                if new_len > old_len then
                    local level_data = EnsureGemLevelData(self)
                    level_data[new_len] = 1

                    local owner = GetEquippedOwner(self)
                    if owner ~= nil then
                        ApplyEquipLevelDelta(self, owner, gem_name, 1, true)
                        RefreshOwnerAfterGemChange(owner)
                    end
                end
            end
            return success, message
        end

        local upgrade_index = self:FindUpgradeableGemIndex(gem_name)
        if upgrade_index == nil then
            return false, "没有空余凹槽，且当前装备不存在可升级的同类宝石"
        end

        local old_level = self:GetGemLevelByIndex(upgrade_index)
        local need_num = math.max(old_level * 2, 1)
        local operate_player = FindGemOperatePlayer(self) or ConsumeLastGemQuery(gem_name)
        if operate_player ~= nil and operate_player.GetItemsByKey ~= nil then
            local current_num = operate_player:GetItemsByKey(gem_name)
            if current_num < need_num then
                return false, "升级宝石数量不足，需要 " .. tostring(need_num) .. " 颗"
            end
        end
        local success, message = self:UpgradeGemByIndex(upgrade_index)
        if success then
            SetPendingSpecialGemUpgrade({
                equip_cmp = self,
                gem_name = gem_name,
                index = upgrade_index,
                old_level = old_level,
                new_level = old_level + 1,
                need_num = need_num,
            })
        else
            ClearPendingSpecialGemUpgrade()
        end
        return success, message
    end

    self.ReduceGemByIndex = function(self, player, gem_index)
        local old_list = ShallowCopy(GetGemsList(self))
        local old_levels = ShallowCopy(EnsureGemLevelData(self))
        local owner = GetEquippedOwner(self)

        local success, message = old_ReduceGemByIndex(self, player, gem_index)
        if not success then
            return success, message
        end

        local new_list = GetGemsList(self)
        local removed_index = FindRemovedIndex(old_list, new_list)
        if removed_index ~= nil then
            local removed_gem = old_list[removed_index]
            local removed_level = old_levels[removed_index] or 1

            local new_levels = {}
            for i, level in ipairs(old_levels) do
                if i ~= removed_index then
                    table.insert(new_levels, level)
                end
            end
            self[KEY_GEM_LEVEL_DATA] = new_levels

            if owner ~= nil and removed_gem ~= nil then
                ApplyEquipLevelDelta(self, owner, removed_gem, removed_level, false)
                RefreshOwnerAfterGemChange(owner)
            end
        else
            EnsureGemLevelData(self)
        end

        return success, message
    end

    self.OnSave = function(self)
        local data = old_OnSave(self)
        data[KEY_GEM_LEVEL_DATA] = ShallowCopy(EnsureGemLevelData(self))
        return data
    end

    self.OnLoad = function(self, data)
        old_OnLoad(self, data)
        local level_data = type(data) == "table" and data[KEY_GEM_LEVEL_DATA] or nil
        if type(level_data) == "table" then
            self[KEY_GEM_LEVEL_DATA] = ShallowCopy(level_data)
        end
        EnsureGemLevelData(self)
    end

    self.GetGemDebugList = function(self)
        local result = old_GetGemDebugList(self)
        local level_data = EnsureGemLevelData(self)
        for i, info in ipairs(result) do
            local level = level_data[i] or 1
            info.level = level
            if info.desc ~= nil then
                info.desc = tostring(info.desc) .. " Lv." .. tostring(level)
            end
        end
        return result
    end

    self.HandleEquipBuffToPlayer = function(self, player, equip_bool)
        old_HandleEquipBuffToPlayer(self, player, equip_bool)

        local gems_list = GetGemsList(self)
        local level_data = EnsureGemLevelData(self)
        for i, gem_name in ipairs(gems_list) do
            local level = level_data[i] or 1
            if level > 1 then
                ApplyEquipLevelDelta(self, player, gem_name, level - 1, equip_bool)
            end
        end
        RefreshOwnerAfterGemChange(player)
    end
end)

AddComponentPostInit("hh_player", function(self, inst)
    local old_AddEquipGems = self.AddEquipGems
    local old_HasItemsByKey = self.HasItemsByKey
    local old_RemoveItemsByKey = self.RemoveItemsByKey

    function self:ConvertGemByName(gem_name)
        if type(gem_name) ~= "string" or gem_name == "" then
            return false, "要转换的宝石不存在"
        end
        if not self:HasItemsByKey(gem_name) then
            return false, "宝石数量不足"
        end

        local gem_data = GetGemData(gem_name)
        if not IsConvertibleGem(gem_name, gem_data) then
            return false, "该宝石不能转换"
        end

        local convert_pool = GetConvertibleGemPool(gem_name)
        if #convert_pool <= 0 then
            return false, "当前没有可转换的目标宝石"
        end

        self:RemoveItemsByKey(gem_name, 1)

        local source_name = tostring(gem_data.name or gem_name)
        if math.random() <= 0.5 then
            return true, string.format("%s 转换失败，宝石已消失", source_name)
        end

        local target_gem_name = convert_pool[math.random(1, #convert_pool)]
        local target_gem_data = GetGemData(target_gem_name)
        self:AddItemsByKey(target_gem_name, 1, true)

        return true, string.format(
            "%s 转换成功，获得 %s",
            source_name,
            tostring(target_gem_data and target_gem_data.name or target_gem_name)
        )
    end

    self.HasItemsByKey = function(self, item_key)
        local result = old_HasItemsByKey(self, item_key)
        if result and GetGemData(item_key) ~= nil then
            SetLastGemQuery(self, item_key)
        end
        return result
    end

    self.AddEquipGems = function(self, gem_name)
        ClearPendingSpecialGemUpgrade()

        if type(gem_name) == "string" and gem_name:sub(1, #GEM_CONVERT_PREFIX) == GEM_CONVERT_PREFIX then
            if GLOBAL ~= nil and GLOBAL.EnableGemConvert == false then
                return false, "宝石转换功能未开启"
            end
            return self:ConvertGemByName(gem_name:sub(#GEM_CONVERT_PREFIX + 1))
        end

        if not self:HasItemsByKey(gem_name) then
            return false, "宝石数量不足"
        end

        if self.ui_container == nil
            or self.ui_container.components == nil
            or self.ui_container.components.container == nil
        then
            return old_AddEquipGems(self, gem_name)
        end

        local container = self.ui_container.components.container
        local hh_equip = container:GetItemInSlot(0x1c)
        if hh_equip == nil or hh_equip.components == nil or hh_equip.components.hh_equip == nil then
            return old_AddEquipGems(self, gem_name)
        end

        local equip_cmp = hh_equip.components.hh_equip
        if equip_cmp:HasEmptyGroove() then
            return old_AddEquipGems(self, gem_name)
        end

        local upgrade_index = equip_cmp:FindUpgradeableGemIndex(gem_name)
        if upgrade_index == nil then
            return false, "当前装备没有空余凹槽，且该宝石当前无法升级"
        end

        local level = equip_cmp:GetGemLevelByIndex(upgrade_index)
        local need_num = math.max(level * 2, 1)
        if self:GetItemsByKey(gem_name) < need_num then
            return false, "升级宝石数量不足，需要 " .. tostring(need_num) .. " 颗"
        end

        local success, desc = equip_cmp:UpgradeGemByIndex(upgrade_index)
        if success then
            self:RemoveItemsByKey(gem_name, need_num)
        end
        return success, desc
    end

    self.RemoveItemsByKey = function(self, item_key, num)
        local pending = PeekPendingSpecialGemUpgrade()
        if pending ~= nil
            and pending.gem_name == item_key
            and num == 1
        then
            ClearPendingSpecialGemUpgrade()

            local need_num = math.max(tonumber(pending.need_num) or 1, 1)
            local current_num = self:GetItemsByKey(item_key)
            if current_num < need_num then
                RollbackGemUpgrade(pending.equip_cmp, pending)
                return false
            end

            return old_RemoveItemsByKey(self, item_key, need_num)
        end

        return old_RemoveItemsByKey(self, item_key, num)
    end
end)
