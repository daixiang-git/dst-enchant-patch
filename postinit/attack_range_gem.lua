local ENCHANT_OK, ENCHANT_ENUM = pcall(require, "enums/hh_enchant")
local ITEMS_OK, ITEM_ENUM = pcall(require, "enums/hh_items")

if not ENCHANT_OK or ENCHANT_ENUM == nil or not ITEMS_OK or ITEM_ENUM == nil then
    return
end

local HH_GEM_BUFF_LIST = ENCHANT_ENUM.HH_GEM_BUFF_LIST
local HH_ITEMS = ITEM_ENUM
if type(HH_GEM_BUFF_LIST) ~= "table" or type(HH_ITEMS) ~= "table" then
    return
end

local EQUIPSLOTS = GLOBAL.EQUIPSLOTS
local GEM_KEY = "attackRangeBead"
local GEM_NAME = "长击珠"
local GEM_DESC = "攻击距离+1"

local function HasComponents(inst, name)
    return inst ~= nil and inst.components ~= nil and inst.components[name] ~= nil
end

local function GetWeaponRange(inst)
    if not HasComponents(inst, "weapon") then
        return nil, nil
    end

    local weapon = inst.components.weapon
    local attack_range = weapon.attackrange
    local hit_range = weapon.hitrange

    if type(attack_range) ~= "number" and weapon.GetRange ~= nil then
        local ok, range = pcall(function()
            return weapon:GetRange()
        end)
        if ok and type(range) == "number" then
            attack_range = range
        end
    end

    if type(attack_range) ~= "number" then
        attack_range = 1
    end
    if type(hit_range) ~= "number" then
        hit_range = attack_range + 1
    end

    return attack_range, hit_range
end

local function CheckCanAdd(inst)
    if not HasComponents(inst, "weapon")
        or not HasComponents(inst, "equippable")
        or inst.components.equippable.equipslot ~= EQUIPSLOTS.HANDS
    then
        return false, "只能镶嵌在手部武器上"
    end

    local attack_range = GetWeaponRange(inst)
    if type(attack_range) ~= "number" then
        return false, "未找到武器攻击距离"
    end
    if attack_range >= 2 then
        return false, "仅攻击距离小于2的武器可镶嵌"
    end

    return true, "满足条件"
end

local function ApplyAttackRangeBonus(inst, equip_bool)
    if not HasComponents(inst, "weapon") then
        return
    end

    local weapon = inst.components.weapon
    local attack_range, hit_range = GetWeaponRange(inst)
    if type(attack_range) ~= "number" or type(hit_range) ~= "number" then
        return
    end

    if equip_bool then
        inst.patch_attack_range_gem_count = (inst.patch_attack_range_gem_count or 0) + 1
        if inst.patch_attack_range_gem_count == 1 then
            inst.patch_attack_range_gem_base_attack = attack_range
            inst.patch_attack_range_gem_base_hit = hit_range
            weapon:SetRange(attack_range + 1, hit_range + 1)
        end
    else
        inst.patch_attack_range_gem_count = math.max((inst.patch_attack_range_gem_count or 1) - 1, 0)
        if inst.patch_attack_range_gem_count <= 0 then
            local base_attack = inst.patch_attack_range_gem_base_attack or attack_range
            local base_hit = inst.patch_attack_range_gem_base_hit or hit_range
            weapon:SetRange(base_attack, base_hit)
            inst.patch_attack_range_gem_count = nil
            inst.patch_attack_range_gem_base_attack = nil
            inst.patch_attack_range_gem_base_hit = nil
        end
    end
end

HH_ITEMS[GEM_KEY] = {
    name = GEM_NAME,
}

if TUNING ~= nil and TUNING.HH_FORMAT_CONFIG ~= nil and TUNING.HH_FORMAT_CONFIG.GEM_EFFECT ~= nil then
    TUNING.HH_FORMAT_CONFIG.GEM_EFFECT[GEM_KEY] = GEM_DESC
end

HH_GEM_BUFF_LIST[GEM_KEY] = {
    name = GEM_NAME,
    desc = GEM_DESC,
    only_one = true,
    max_level = 1,
    check_gem_can_add = CheckCanAdd,
    on_equip_fn = function(inst, owner)
        ApplyAttackRangeBonus(inst, true)
    end,
    un_equip_fn = function(inst, owner)
        ApplyAttackRangeBonus(inst, false)
    end,
}
