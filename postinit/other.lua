local enable_rosorns = GetModConfigData("enable_rosorns")

if not enable_rosorns then
    local hand_on = function(owner, build, symbol) -- 简单的手持物
        owner.AnimState:OverrideSymbol("swap_object", build, symbol)
        owner.AnimState:Show("ARM_carry") -- 显示持物手
        owner.AnimState:Hide("ARM_normal") -- 隐藏普通的手
    end
    local hand_off =
        function(inst, owner) -- inst参数虽然没用，但是可以摆阵型，对齐参数
            -- owner.AnimState:ClearOverrideSymbol("swap_object") --之所以不需要，因为卸下装备动画还需要贴图显示出来
            owner.AnimState:Hide("ARM_carry") -- 隐藏持物手
            owner.AnimState:Show("ARM_normal") -- 显示普通的手
        end
    AddPrefabPostInit("rosorns", function(inst)
        local equippable = inst.components.equippable
        if equippable == nil then return end
        equippable:SetOnEquip(function(inst, owner)
            if inst._dd ~= nil then
                hand_on(owner, inst._dd.build, inst._dd.file)
            else
                hand_on(owner, "swap_rosorns", "swap_rosorns")
            end
            if owner:HasTag("equipmentmodel") then return end -- 假人
        end)
        equippable:SetOnUnequip(function(inst, owner)
            hand_off(inst, owner)
        end)
    end)
end




local enable_start_give = GetModConfigData("enable_start_give")

if enable_start_give then
    local enable_start_give_count = GetModConfigData("enable_start_give_count")
    local name = "附魔补丁礼物"
    local giveitems = { -- 给什么物品
        {"hh_effect_tally", enable_start_give_count} -- 卷子
    }

    local ex_fns = require "prefabs/player_common_extensions"
    local GivePlayerStartingItems = ex_fns.GivePlayerStartingItems
    ex_fns.GivePlayerStartingItems = function(inst, items, ...)
        if inst and not inst[name] then
            inst[name] = true
            local gift = SpawnPrefab("gift")
            local t = {}
            for k, v in pairs(giveitems) do
                table.insert(t, {
                    prefab = v[1],
                    data = (v[2] ~= 1 and {stackable = {stack = v[2]}} or {})
                })
            end
            gift.components.unwrappable.itemdata = t
            inst.components.inventory:GiveItem(gift)
        end
        GivePlayerStartingItems(inst, items, ...)
    end

end
