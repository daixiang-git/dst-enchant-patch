local STRIDE_BEAD_SPEED = 6
local STRIDE_BEAD_OLD_SPEED = 3
local STRIDE_BEAD_NAME = "strideBead"
local KEY_GEMS_LIST = "gems_list"
local KEY_GEM_LEVEL_DATA = "gem_level_data"

local function HasComponents(inst, name)
    return inst ~= nil and inst.components ~= nil and inst.components[name] ~= nil
end

-- 新的 on_equip_fn：加 6% 移速
local function PatchedOnEquip(inst, owner)
    if HasComponents(owner, "hh_player") then
        owner.components.hh_player:AddEffectValueByKey("addSpeedPercent", STRIDE_BEAD_SPEED)
    end
end

-- 新的 un_equip_fn：减 6% 移速
local function PatchedUnEquip(inst, owner)
    if HasComponents(owner, "hh_player") then
        owner.components.hh_player:ReduceEffectValueByKey("addSpeedPercent", STRIDE_BEAD_SPEED)
    end
end

-- 标记是否已成功替换
local patch_applied = false

-- 核心替换函数：替换 HH_GEM_BUFF_LIST.strideBead 的 on_equip_fn / un_equip_fn
local function ApplyStrideBeadPatch(HH_GEM_BUFF_LIST)
    if patch_applied then
        return true
    end

    if type(HH_GEM_BUFF_LIST) ~= "table" then
        return false
    end

    local gem = HH_GEM_BUFF_LIST[STRIDE_BEAD_NAME]
    if type(gem) ~= "table" then
        return false
    end

    gem.on_equip_fn = PatchedOnEquip
    gem.un_equip_fn = PatchedUnEquip

    -- 同时修改宝石的 name 显示字段（因为 name 是在模块加载时从 TUNING 读取的，后改 TUNING 不会影响已读取的值）
    gem.name = "移速增加6%"

    patch_applied = true
    print("[stride_bead_patch] 步伐珠移速已修改为 " .. tostring(STRIDE_BEAD_SPEED) .. "%")
    return true
end

-- ============================================================
-- 方式1：模块加载时直接尝试 require 替换
-- ============================================================
local ENCHANT_OK, ENCHANT_ENUM = pcall(require, "enums/hh_enchant")
if ENCHANT_OK and type(ENCHANT_ENUM) == "table" then
    ApplyStrideBeadPatch(ENCHANT_ENUM.HH_GEM_BUFF_LIST)
else
    print("[stride_bead_patch] require enums/hh_enchant 失败，将在组件初始化时重试")
end

-- ============================================================
-- 方式2：通过 AddComponentPostInit 在 hh_equip 组件初始化时再次尝试
--        此时 require 一定已经可用，作为保底
-- ============================================================
AddComponentPostInit("hh_equip", function(self, inst)
    if patch_applied then
        return
    end

    local ok, enum = pcall(require, "enums/hh_enchant")
    if ok and type(enum) == "table" then
        ApplyStrideBeadPatch(enum.HH_GEM_BUFF_LIST)
    else
        print("[stride_bead_patch] hh_equip PostInit: require 仍然失败!")
    end
end)

-- ============================================================
-- 修改 TUNING 显示文字（影响附魔UI上的描述）
-- ============================================================
if TUNING ~= nil
    and TUNING.HH_FORMAT_CONFIG ~= nil
    and TUNING.HH_FORMAT_CONFIG.GEM_EFFECT ~= nil
then
    TUNING.HH_FORMAT_CONFIG.GEM_EFFECT[STRIDE_BEAD_NAME] = "移速增加6%"
end

-- ============================================================
-- 旧存档补偿：已装备的步伐珠效果是 3%，需要补差值到 6%
-- ============================================================
local function GetStrideBeadLevelCount(equip_cmp)
    local gems_list = equip_cmp ~= nil and equip_cmp[KEY_GEMS_LIST] or nil
    if type(gems_list) ~= "table" then
        return 0
    end

    local level_data = type(equip_cmp[KEY_GEM_LEVEL_DATA]) == "table" and equip_cmp[KEY_GEM_LEVEL_DATA] or nil
    local total = 0
    for index, gem_name in ipairs(gems_list) do
        if gem_name == STRIDE_BEAD_NAME then
            local level = level_data ~= nil and level_data[index] or 1
            total = total + math.max(tonumber(level) or 1, 1)
        end
    end
    return total
end

local function ApplyStrideBeadLegacyCompensation(player)
    if not HasComponents(player, "inventory") or not HasComponents(player, "hh_player") then
        return
    end
    if player.patch_stride_bead_compensated then
        return
    end

    local total = 0
    for _, item in pairs(player.components.inventory.equipslots or {}) do
        local equip_cmp = item ~= nil and item.components ~= nil and item.components.hh_equip or nil
        if equip_cmp ~= nil then
            total = total + GetStrideBeadLevelCount(equip_cmp)
        end
    end

    if total > 0 then
        local delta = (STRIDE_BEAD_SPEED - STRIDE_BEAD_OLD_SPEED) * total
        player.components.hh_player:AddEffectValueByKey("addSpeedPercent", delta)
        print("[stride_bead_patch] 旧存档补偿: 为 " .. tostring(player) .. " 补加 " .. tostring(delta) .. "% 移速")
    end
    player.patch_stride_bead_compensated = true
end

AddPlayerPostInit(function(inst)
    if TheWorld == nil or not TheWorld.ismastersim then
        return
    end

    inst:DoTaskInTime(0, function()
        if inst ~= nil and inst:IsValid() then
            ApplyStrideBeadLegacyCompensation(inst)
        end
    end)
end)
