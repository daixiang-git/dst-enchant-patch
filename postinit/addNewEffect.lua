-- 提供了一个可以新增词条的接口-仅限于新增词条 未开放人物属性部分 具体逻辑需要自己补充
-- 案例-自己随便找个mod模板加就行 优先级改为负数或写在GLOBALModManagerRegisterPrefabs中
if not AddSpecialEquipEffect then return end

local var_2 = TUNING["HH_FORMAT_CONFIG"]["EQUIP_EFFECT"]
local var_3 = (string["format"]("(攻击目标攻击力不低于%s时生效)", 0x0))

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
