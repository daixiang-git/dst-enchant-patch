if not AddSpecialEquipEffect then
    return
end

local function HasComponents(inst, name)
    return inst ~= nil and inst.components ~= nil and inst.components[name] ~= nil
end

local desc_table = TUNING["HH_FORMAT_CONFIG"] ~= nil and TUNING["HH_FORMAT_CONFIG"]["EQUIP_EFFECT"] or nil
local speed_desc = desc_table ~= nil and desc_table["addSpeedPercent"] or "移速+%s%%"

AddSpecialEquipEffect("medium_haste_percent", {
    id = 10096,
    name = "中-急速",
    client_text = "中\n急速",
    desc = speed_desc,
    check_desc = "无",
    can_add = true,
    star_rating = 5,
    value_range = { min = 10, max = 40 },
    on_equip_fn = function(inst, owner, value)
        if HasComponents(owner, "hh_player") then
            owner.components.hh_player:AddEffectValueByKey("addSpeedPercent", value)
        end
    end,
    un_equip_fn = function(inst, owner, value)
        if HasComponents(owner, "hh_player") then
            owner.components.hh_player:ReduceEffectValueByKey("addSpeedPercent", value)
        end
    end
})
