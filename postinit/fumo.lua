-- 检查模组是否启用
-- if not GLOBAL.KnownModIndex:IsModEnabled("workshop-3096210166") then return end

-- 初始化核心API
local HHCompatAPIClass = GLOBAL.require("compat/hh_compat_api")
GLOBAL.HHCompatAPI = HHCompatAPIClass()

-- 读取配置
GLOBAL.HHCompatAPI.UnknownTagEnabled = GetModConfigData("ENABLE_UNKNOWN_TAG") or false
GLOBAL.WormEnabled = GetModConfigData("ENABLE_WORM") or false
GLOBAL.LeifEnabled = GetModConfigData("ENABLE_LEIF") or false
GLOBAL.DamageEnabled = GetModConfigData("ENABLE_DAMAGE") or false

-- 定义已知的生物分类标签集合（使用主模组的混淆形式）
local KNOWN_CATEGORY_TAGS = {
    "pig", "rabbit", "fish", "gear", "spider", "dog", "frog", "insect", "monkey", "shadow", "plant",
    string.char(0x63, 0x6f, 0x6d, 0x6d, 0x6f, 0x6e, 0x5f, 0x6d, 0x6f, 0x6e, 0x73, 0x74, 0x65, 0x72), -- "common_monster"
    string.char(0x65, 0x6c, 0x69, 0x74, 0x65, 0x5f, 0x6d, 0x6f, 0x6e, 0x73, 0x74, 0x65, 0x72),       -- "elite_monster"
    string.char(0x62, 0x6f, 0x73, 0x73, 0x5f, 0x6d, 0x6f, 0x6e, 0x73, 0x74, 0x65, 0x72)              -- "boss_monster"
}

local boss_tag = string.char(0x62, 0x6f, 0x73, 0x73, 0x5f, 0x6d, 0x6f, 0x6e, 0x73, 0x74, 0x65, 0x72)
local elite_tag = string.char(0x65, 0x6c, 0x69, 0x74, 0x65, 0x5f, 0x6d, 0x6f, 0x6e, 0x73, 0x74, 0x65, 0x72)
local common_tag = string.char(0x63, 0x6f, 0x6d, 0x6d, 0x6f, 0x6e, 0x5f, 0x6d, 0x6f, 0x6e, 0x73, 0x74, 0x65, 0x72) -- "common_monster"

-- 加载兼容配置文件
local compat_config = GLOBAL.require("compat/compat_config")
local compat_modules = compat_config.modules

-- 动态加载兼容模块
for _, mod in ipairs(compat_modules) do
    local status, err = pcall(function()
        modimport("scripts/compat/" .. mod.file)
    end)
    if not status then
        print("[HH兼容] 加载错误:", mod.name, "->", err)
    end
end

-- 判断是否为生物的函数
local function IsCreature(inst)
    if inst and inst.prefab == "abigail" then
        return true
    end
    return inst.components.health ~= nil and inst.components.combat ~= nil and inst.components.lootdropper ~= nil
end

-- 判断是否为玩家的函数
local function IsPlayer(inst)
    return inst:HasTag("player") or inst.components.playercontroller ~= nil
end

-- 同步到主模组的 hh_prefab_list
local function SyncToHHPrefabList(prefab, tag)
    local hh_prefab_list = GLOBAL.require("enums/hh_prefab_list")
    if hh_prefab_list then
        hh_prefab_list[tag] = hh_prefab_list[tag] or {}
        hh_prefab_list[tag][prefab] = true
        if tag == boss_tag then
            hh_prefab_list[elite_tag][prefab] = false
            hh_prefab_list[common_tag][prefab] = false
        end
        if tag == elite_tag then
            hh_prefab_list[boss_tag][prefab] = false
            hh_prefab_list[common_tag][prefab] = false
        end
        if tag == common_tag then
            hh_prefab_list[boss_tag][prefab] = false
            hh_prefab_list[elite_tag][prefab] = false
        end
    end
end


-- 可选：手动注册特定怪物
local function RegisterCustomMonsters()
    if not GLOBAL.TheWorld.ismastersim then return end

    local custom_mobs = {}
    -- 示例：手动注册 "my_boss" 和 "my_elite"
    -- 仅当开启未知标签功能时添加树精相关项
    if GLOBAL.LeifEnabled then
        custom_mobs["leif"] = {
            [common_tag] = "普通"
        }
        custom_mobs["leif_sparse"] = {
            [common_tag] = "普通"
        }
    end

    if GLOBAL.WormEnabled then
        custom_mobs["worm"] = {
            [common_tag] = "普通"
        }
        custom_mobs["yots_worm"] = {
            [common_tag] = "普通"
        }
    end

    if next(custom_mobs) == nil then
        return
    end

    GLOBAL.HHCompatAPI:RegisterMobs(custom_mobs)

    -- 同步到 hh_prefab_list 并为怪物添加组件
    for prefab, tags in pairs(custom_mobs) do
        -- 同步所有标签到 hh_prefab_list（包括自定义标签如 insect）
        for tag in pairs(tags) do
            SyncToHHPrefabList(prefab, tag)
        end
        AddPrefabPostInit(prefab, function(inst)
            if not GLOBAL.TheWorld.ismastersim then return end
            if not inst.components.hh_monster then
                inst:AddComponent("hh_monster")
            end
            GLOBAL.HHCompatAPI:ApplyTags(inst)
        end)
    end
end

AddSimPostInit(RegisterCustomMonsters)


-- 全局拦截生物创建并根据攻击力注册标签
AddPrefabPostInitAny(function(inst)
    if not inst or not inst.prefab or not GLOBAL.HHCompatAPI.UnknownTagEnabled or not IsCreature(inst) or IsPlayer(inst) then
        return
    end

    GLOBAL.HHCompatAPI:ApplyTags(inst)

    -- 初始化 hh_tags
    inst.hh_tags = inst.hh_tags or {}

    -- 检查是否已有分类标签
    for tag in pairs(inst.hh_tags) do
        for _, known_tag in ipairs(KNOWN_CATEGORY_TAGS) do
            if tag == known_tag then
                return -- 已存在分类标签，直接退出
            end
        end
    end

    -- 根据攻击力添加标签
    local combat = inst.components.combat
    local damage = combat and combat.defaultdamage or 0
    local mob_data, tag_to_add, tag_desc

    if damage >= 90 then
        mob_data = { [inst.prefab] = { [boss_tag] = "BOSS" } }
        tag_to_add = boss_tag
        tag_desc = "BOSS"
    elseif damage >= 51 then
        mob_data = { [inst.prefab] = { [elite_tag] = "精英" } }
        tag_to_add = elite_tag
        tag_desc = "精英"
    elseif damage >= 10 then
        mob_data = { [inst.prefab] = { [common_tag] = "普通" } }
        tag_to_add = common_tag
        tag_desc = "普通"
    end

    if mob_data then
        -- 添加 hh_monster 组件（如果不存在）
        if not inst.components.hh_monster then
            inst:AddComponent("hh_monster")
        end
        -- 注册并添加标签
        GLOBAL.HHCompatAPI:RegisterMobs(mob_data)
        inst.hh_tags[tag_to_add] = tag_desc
        -- 同步到主模组的 hh_prefab_list
        SyncToHHPrefabList(inst.prefab, tag_to_add)
    end
end)


-- 定义已知的生物分类标签集合（使用混淆形式避免直接识别）
local SOME_CATEGORY_TAGS = {
    string.char(0x65, 0x6c, 0x69, 0x74, 0x65, 0x5f, 0x6d, 0x6f, 0x6e, 0x73, 0x74, 0x65, 0x72), -- "elite_monster"
    string.char(0x62, 0x6f, 0x73, 0x73, 0x5f, 0x6d, 0x6f, 0x6e, 0x73, 0x74, 0x65, 0x72)        -- "boss_monster"
}

local UpvalueHacker = {}
local function GetUpvalueHelper(fn, name)
    local i = 1
    while debug.getupvalue(fn, i) and debug.getupvalue(fn, i) ~= name do
        i = i + 1
    end
    local name, value = debug.getupvalue(fn, i)
    return value, i
end

function UpvalueHacker.GetUpvalue(fn, ...)
    local prv, i, prv_var = nil, nil, "(the starting point)"
    for j, var in ipairs({ ... }) do
        assert(type(fn) == "function", "We were looking for " .. var .. ", but the value before it, "
            .. prv_var .. ", wasn't a function (it was a " .. type(fn)
            .. "). Here's the full chain: " .. table.concat({ "(the starting point)", ... }, ", "))
        prv = fn
        prv_var = var
        fn, i = GetUpvalueHelper(fn, var)
    end
    return fn, i, prv
end

function UpvalueHacker.SetUpvalue(start_fn, new_fn, ...)
    local _fn, _fn_i, scope_fn = UpvalueHacker.GetUpvalue(start_fn, ...)
    debug.setupvalue(scope_fn, _fn_i, new_fn)
end

-- 增强关系检测：骑乘+跟随
local function CheckAttackRelationship(inst, target)
    -- 2. 检测跟随关系（新增）
    local instLeader = inst.components and inst.components.follower and inst.components.follower.leader
    if instLeader ~= nil then
        return true
    end

    local targetLeader = target.components and target.components.follower and target.components.follower.leader
    if targetLeader ~= nil then
        return true
    end

    return false
end

-- 检查两个实体是否都有分类标签
local function BothHaveCategoryTags(inst, target)
    if not inst.hh_tags or not target.hh_tags then
        return false
    end
    -- 增强关系检测优先
    if CheckAttackRelationship(inst, target) then
        return false -- 允许攻击有特殊关系的实体
    end
    local hasInstTags = false
    for tag, _ in pairs(inst.hh_tags) do
        for _, known_tag in ipairs(SOME_CATEGORY_TAGS) do
            if tag == known_tag then
                hasInstTags = true
                break
            end
        end
        if hasInstTags then
            break
        end
    end

    local hasTargetTags = false
    for tag, _ in pairs(target.hh_tags) do
        for _, known_tag in ipairs(SOME_CATEGORY_TAGS) do
            if tag == known_tag then
                hasTargetTags = true
                break
            end
        end
        if hasTargetTags then
            break
        end
    end

    return hasInstTags and hasTargetTags
end

-- 实体碰撞时特效
local function SpawnFx(inst)
    if inst:IsValid() then
        SpawnPrefab("stalker_shield").Transform:SetPosition(inst.Transform:GetWorldPosition())
    end
end

-- 修改战斗组件逻辑
local function CombatPostInit(self)
    local old_CanTarget = self.CanTarget
    self.CanTarget = function(self, target, ...)
        if target and BothHaveCategoryTags(self.inst, target) then
            return false
        end
        return old_CanTarget(self, target, ...)
    end

    local old_CanAttack = self.CanAttack
    self.CanAttack = function(self, target, ...)
        if target and BothHaveCategoryTags(self.inst, target) then
            return false
        end
        return old_CanAttack(self, target, ...)
    end

    local old_DoAttack = self.DoAttack
    self.DoAttack = function(self, targ, ...)
        if targ and BothHaveCategoryTags(self.inst, targ) then
            SpawnFx(targ)
            return false
        end
        return old_DoAttack(self, targ, ...)
    end

    local oldGetAttacked = self.GetAttacked
    self.GetAttacked = function(self, attacker, ...)
        if attacker and BothHaveCategoryTags(self.inst, attacker) then
            SpawnFx(self.inst)
            return false
        end
        return oldGetAttacked(self, attacker, ...)
    end
end

-- 确保战斗组件初始化前实体已收集标签
if GLOBAL.DamageEnabled then
    print("boss精英相互没有仇恨和伤害已开启")
    AddComponentPostInit("combat", CombatPostInit)
end
