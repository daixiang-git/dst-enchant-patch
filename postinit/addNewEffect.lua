-- 提供了一个可以新增词条的接口-仅限于新增词条 未开放人物属性部分 具体逻辑需要自己补充
-- 案例-自己随便找个mod模板加就行 优先级改为负数或写在GLOBALModManagerRegisterPrefabs中
if not AddSpecialEquipEffect then return end

local var_2 = TUNING["HH_FORMAT_CONFIG"]["EQUIP_EFFECT"]
local var_3 = (string["format"]("(攻击目标攻击力不低于%s时生效)", 0x0))
local HH_UTILS = require("utils/hh_utils")
local function U8(...)
    return string.char(...)
end

function HasComponents(inst, str)
    if inst and inst["components"] and inst["components"][str] then
        return true
    else
        return false
    end
end

-- 非必填的都可以置空 但需要注意key之间的关联关系
AddSpecialEquipEffect("true_damage_max", {
    id = 10086, -- id唯一 不要重复
    name = "穿刺-极",
    client_text = "极\n穿刺",
    desc = var_2["true_damage_small"],
    check_desc = "武器" .. var_3,
    can_add = false,
    star_rating = 0x5,
    value_range = {min = 50, max = 100},
    check_equip_can_add = function(inst)
        if HasComponents(inst, "weapon") then
            return true, "满足条件"
        end
        return false, "武器才能附加该词条"
    end,
    on_equip_fn = function(inst, owner, value)
        if HasComponents(owner, "hh_player") then
            owner["components"]["hh_player"]:AddEffectValueByKey(
                "trueDamageNum", value)
        end
    end,
    un_equip_fn = function(inst, owner, value)
        if HasComponents(owner, "hh_player") then
            owner["components"]["hh_player"]:ReduceEffectValueByKey(
                "trueDamageNum", value)
        end
    end
})

AddSpecialEquipEffect("add_critical_hit_effect_max", { -- id唯一 不要重复
    ["id"] = 10087,
    ["name"] = "暴击效果-极",
    ["client_text"] = "极\n暴伤",
    ["desc"] = var_2["add_critical_hit_effect"],
    ["check_desc"] = "无",
    ["can_add"] = false,
    ["value_range"] = {["min"] = 50, ["max"] = 100},
    ["star_rating"] = 0x5,
    ["on_equip_fn"] = function(inst, owner, value)
        if not HasComponents(owner, "hh_player") then return end
        owner["components"]["hh_player"]:AddEffectValueByKey(
            "criticalHitEffect", value)
    end,
    ["un_equip_fn"] = function(inst, owner, value)
        if not HasComponents(owner, "hh_player") then return end
        owner["components"]["hh_player"]:ReduceEffectValueByKey(
            "criticalHitEffect", value)
    end
})


AddSpecialEquipEffect("add_extra_damage_percent_max", { -- id唯一 不要重复
    ["id"] = 10088,
    ["name"] = "伤害加成-极",
    ["client_text"] = "极\n加成",
    ["desc"] = var_2["add_extra_damage_percent"],
    ["check_desc"] = "无",
    ["can_add"] = false,
    ["value_range"] = {["min"] = 30, ["max"] = 50},
    ["star_rating"] = 0x5,
    ["on_equip_fn"] = function(inst, owner, value)
        if not HasComponents(owner, "hh_player") then
            return
        end
        owner["components"]["hh_player"]:AddEffectValueByKey(
            "addComDamagePercent", value)
    end,
    ["un_equip_fn"] = function(inst, owner, value)
        if not HasComponents(owner, "hh_player") then
            return
        end
        owner["components"]["hh_player"]:ReduceEffectValueByKey(
            "addComDamagePercent", value)
    end
})

local PLANAR_BREAK_EFFECT = "break_planar_resist"
local PLANAR_BREAK_DURATION = 10
local PLANAR_BREAK_COOLDOWN = 10
local PLANAR_BREAK_TOTAL_CD = PLANAR_BREAK_DURATION + PLANAR_BREAK_COOLDOWN
local PLANAR_BREAK_NAME = U8(231,160,180,231,149,140)
local PLANAR_BREAK_RARE = U8(231,168,128)
local PLANAR_BREAK_DESC_PREFIX = U8(230,148,187,229,135,187,230,139,165,230,156,137,228,189,141,233,157,162,230,138,181,230,138,151,231,154,132,230,128,170,231,137,169,230,151,182,239,188,140,230,156,137)
local PLANAR_BREAK_DESC_SUFFIX = U8(230,166,130,231,142,135,228,189,191,229,133,182,229,164,177,229,142,187,228,189,141,233,157,162,230,138,181,230,138,151,49,48,231,167,146,40,231,187,147,230,157,159,229,144,142,229,134,183,229,141,180,49,48,231,167,146,41)
local PLANAR_BREAK_DESC_SUFFIX_EXTRA = U8(44,229,140,133,230,139,172,230,183,183,230,178,140,230,138,181,230,138,151)
local PLANAR_BREAK_WEAPON = U8(230,173,166,229,153,168)
local PLANAR_BREAK_OK = U8(230,187,161,232,182,179,230,157,161,228,187,182)
local PLANAR_BREAK_WEAPON_ONLY = U8(230,173,166,229,153,168,230,137,141,232,131,189,233,153,132,229,138,160,232,175,165,232,175,141,230,157,161)

AddSpecialEquipEffect(PLANAR_BREAK_EFFECT, {
    id = 10089,
    name = PLANAR_BREAK_NAME,
    client_text = PLANAR_BREAK_RARE .. "\n" .. PLANAR_BREAK_NAME,
    desc = PLANAR_BREAK_DESC_PREFIX .. "%s%%" .. PLANAR_BREAK_DESC_SUFFIX .. PLANAR_BREAK_DESC_SUFFIX_EXTRA,
    check_desc = PLANAR_BREAK_WEAPON,
    can_add = false,
    star_rating = 0x5,
    value_range = {min = 1, max = 10},
    check_equip_can_add = function(inst)
        if HasComponents(inst, "weapon") then
            return true, PLANAR_BREAK_OK
        end
        return false, PLANAR_BREAK_WEAPON_ONLY
    end,
    on_equip_fn = function(inst, owner, value)
        if HasComponents(owner, "hh_player") then
            owner["components"]["hh_player"]:AddEffectValueByKey(
                PLANAR_BREAK_EFFECT, value)
        end
    end,
    un_equip_fn = function(inst, owner, value)
        if HasComponents(owner, "hh_player") then
            owner["components"]["hh_player"]:ReduceEffectValueByKey(
                PLANAR_BREAK_EFFECT, value)
        end
    end
})

AddComponentPostInit("hh_player", function(self)
    if self and self.hh_effects and self.hh_effects[PLANAR_BREAK_EFFECT] == nil then
        self.hh_effects[PLANAR_BREAK_EFFECT] = 0
    end
end)

local function SetPlanarResistDisabled(target, disabled)
    if not HasComponents(target, "planarentity") then
        return
    end

    if disabled then
        if target.hh_planar_break_absorb_damage == nil then
            target.hh_planar_break_absorb_damage =
                target["components"]["planarentity"].AbsorbDamage
        end
        target["components"]["planarentity"].AbsorbDamage = function(self, damage, attacker, weapon, spdmg)
            return damage, spdmg
        end
    elseif target.hh_planar_break_absorb_damage ~= nil then
        target["components"]["planarentity"].AbsorbDamage =
            target.hh_planar_break_absorb_damage
        target.hh_planar_break_absorb_damage = nil
    end
end

local function HasBreakableResist(target)
    return target ~= nil
        and target:IsValid()
        and HasComponents(target, "planarentity")
        and (target:HasTag("chaos_creature") or true)
end

local function ApplyPlanarBreak(target)
    if not HasBreakableResist(target) then
        return
    end

    if target.hh_planar_break_restore_task ~= nil then
        target.hh_planar_break_restore_task:Cancel()
        target.hh_planar_break_restore_task = nil
    end

    target.hh_planar_break_cd = GetTime() + PLANAR_BREAK_TOTAL_CD
    target.hh_planar_break_active = true
    SetPlanarResistDisabled(target, true)

    target.hh_planar_break_restore_task = target:DoTaskInTime(PLANAR_BREAK_DURATION, function(inst)
        inst.hh_planar_break_restore_task = nil
        inst.hh_planar_break_active = nil
        SetPlanarResistDisabled(inst, false)
    end)
end

local function ScaleSpecialDamage(spdamage, mult)
    if type(spdamage) ~= "table" then
        return spdamage
    end

    local scaled = {}
    for k, v in pairs(spdamage) do
        if type(v) == "number" then
            scaled[k] = v * mult
        else
            scaled[k] = v
        end
    end
    return scaled
end

AddComponentPostInit("combat", function(self)
    local old_GetAttacked = self.GetAttacked

    self.GetAttacked = function(self, attacker, damage, weapon, stimuli, spdamage, ...)
        if self.inst ~= nil and self.inst.hh_planar_break_active then
            if type(damage) == "number" then
                damage = damage * 0.5
            end
            spdamage = ScaleSpecialDamage(spdamage, 0.5)
        end

        if TheWorld ~= nil and TheWorld.ismastersim
                and attacker ~= nil
                and not self.inst:HasTag("player")
                and HasComponents(attacker, "hh_player")
                and attacker["components"]["hh_player"]:HasSpecialEffect(PLANAR_BREAK_EFFECT)
                and HasBreakableResist(self.inst)
                and (self.inst.hh_planar_break_cd == nil or self.inst.hh_planar_break_cd <= GetTime())
                and math.random(1, 100) <= attacker["components"]["hh_player"]:GetEffectValueByKey(PLANAR_BREAK_EFFECT)
        then
            ApplyPlanarBreak(self.inst)
            HH_UTILS:SpawnTextFx(self.inst, PLANAR_BREAK_NAME)
            HH_UTILS:SpawnIndicatorFx(self.inst:GetPosition(), 1.2, { 1, 0.25, 0.25, 1 }, 1.3)
        end

        return old_GetAttacked(self, attacker, damage, weapon, stimuli, spdamage, ...)
    end
end)
