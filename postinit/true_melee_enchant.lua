if not AddSpecialEquipEffect then
    return
end

local EQUIPSLOTS = GLOBAL.EQUIPSLOTS

local function HasComponents(inst, name)
    return inst ~= nil and inst.components ~= nil and inst.components[name] ~= nil
end

local function IsHandsWeapon(inst)
    return HasComponents(inst, "weapon")
        and HasComponents(inst, "equippable")
        and inst.components.equippable.equipslot == EQUIPSLOTS.HANDS
end

local function GetWeaponRange(inst)
    if not HasComponents(inst, "weapon") then
        return nil
    end

    local weapon = inst.components.weapon
    local range = weapon.attackrange

    if type(range) ~= "number" and weapon.GetRange ~= nil then
        local ok, value = pcall(function()
            return weapon:GetRange()
        end)
        if ok and type(value) == "number" then
            range = value
        end
    end

    -- 近战武器如果没有显式填写攻击距离，按默认近战1处理
    if type(range) ~= "number" then
        range = 1
    end

    return range
end

local function CheckTrueMeleeWeapon(inst)
    if not IsHandsWeapon(inst) then
        return false, "只允许附魔在手部武器上"
    end

    local range = GetWeaponRange(inst)
    if type(range) ~= "number" or range < 1 or range > 2 then
        return false, "仅攻击距离1~2的手部武器可以附加该词条"
    end

    return true, "满足条件"
end

local function RegisterTrueMeleeEnchant(effect_name, data)
    AddSpecialEquipEffect(effect_name, {
        id = data.id,
        name = data.name,
        client_text = data.client_text,
        desc = data.desc,
        check_desc = "攻击距离1~2的手部近战武器",
        can_add = data.can_add,
        only_one = true,
        star_rating = data.star_rating,
        value_range = { min = data.percent, max = data.percent },
        check_equip_can_add = CheckTrueMeleeWeapon,
        on_equip_fn = function(inst, owner, value)
            if not HasComponents(owner, "hh_player") then
                return
            end
            owner.components.hh_player:AddEffectValueByKey("addComDamagePercent", value)
            owner.components.hh_player:AddEffectValueByKey("addComDamage", data.flat_damage)
        end,
        un_equip_fn = function(inst, owner, value)
            if not HasComponents(owner, "hh_player") then
                return
            end
            owner.components.hh_player:ReduceEffectValueByKey("addComDamagePercent", value)
            owner.components.hh_player:ReduceEffectValueByKey("addComDamage", data.flat_damage)
        end,
    })
end

RegisterTrueMeleeEnchant("true_melee_damage_common", {
    id = 10090,
    name = "真近战",
    client_text = "普\n近战",
    desc = "提高%s%%伤害并附加25点固定伤害",
    can_add = true,
    star_rating = 5,
    percent = 50,
    flat_damage = 25,
})

RegisterTrueMeleeEnchant("true_melee_damage_rare", {
    id = 10091,
    name = "真近战-稀",
    client_text = "稀\n近战",
    desc = "提高%s%%伤害并附加50点固定伤害",
    can_add = false,
    star_rating = 8,
    percent = 100,
    flat_damage = 50,
})
