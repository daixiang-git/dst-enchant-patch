if not AddSpecialEquipEffect then
    return
end

local function HasComponents(inst, name)
    return inst ~= nil and inst.components ~= nil and inst.components[name] ~= nil
end

local function RegisterCompoundCommonStone(effect_name, data)
    AddSpecialEquipEffect(effect_name, {
        id = data.id,
        name = data.name,
        client_text = data.client_text,
        desc = data.desc,
        check_desc = "无",
        can_add = true,
        only_one = true,
        only_compound = false,
        star_rating = 5,
        on_equip_fn = function(inst, owner, value)
            if not HasComponents(owner, "hh_player") then
                return
            end
            for _, effect_key in ipairs(data.effect_keys) do
                owner.components.hh_player:AddEffectValueByKey(effect_key, 1)
            end
        end,
        un_equip_fn = function(inst, owner, value)
            if not HasComponents(owner, "hh_player") then
                return
            end
            for _, effect_key in ipairs(data.effect_keys) do
                owner.components.hh_player:ReduceEffectValueByKey(effect_key, 1)
            end
        end,
    })
end

RegisterCompoundCommonStone("compound_common_hot_cold", {
    id = 10092,
    name = "免疫冷热",
    client_text = "普\n冷热",
    desc = "免疫过冷和过热",
    effect_keys = { "immuneCold", "immuneHot" },
})

RegisterCompoundCommonStone("compound_common_moist_hot", {
    id = 10093,
    name = "免疫潮冻",
    client_text = "普\n潮冻",
    desc = "免疫潮湿和冰冻",
    effect_keys = { "immunityMoisture", "immuneFreeze" },
})

RegisterCompoundCommonStone("compound_common_sleep_stick", {
    id = 10094,
    name = "免疫眠粘",
    client_text = "普\n眠粘",
    desc = "免疫催眠和粘液",
    effect_keys = { "immunitySleep", "immunityStick" },
})
