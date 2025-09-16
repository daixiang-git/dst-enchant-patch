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

    local hat_on_opentop =
        function(owner, buildname, foldername) -- 完全开放式的帽子样式
            if buildname == nil then
                owner.AnimState:ClearOverrideSymbol("swap_hat")
            else
                owner.AnimState:OverrideSymbol("swap_hat", buildname, foldername)
            end
            owner.AnimState:Show("HAT")
            owner.AnimState:Hide("HAIR_HAT")
            owner.AnimState:Show("HAIR_NOHAT")
            owner.AnimState:Show("HAIR")

            owner.AnimState:Show("HEAD")
            owner.AnimState:Hide("HEAD_HAT")
            owner.AnimState:Hide("HEAD_HAT_NOHELM")
            owner.AnimState:Hide("HEAD_HAT_HELM")
        end

    local hat_off =
        function(inst, owner) -- inst参数虽然没用，但是可以摆阵型，对齐参数
            owner.AnimState:ClearOverrideSymbol("headbase_hat") -- it might have been overriden by _onequip
            if owner.components.skinner ~= nil then
                owner.components.skinner.base_change_cb =
                    owner.old_base_change_cb
            end

            owner.AnimState:ClearOverrideSymbol("swap_hat")
            owner.AnimState:Hide("HAT")
            owner.AnimState:Hide("HAIR_HAT")
            owner.AnimState:Show("HAIR_NOHAT")
            owner.AnimState:Show("HAIR")

            if owner:HasTag("player") then
                owner.AnimState:Show("HEAD")
                owner.AnimState:Hide("HEAD_HAT")
                owner.AnimState:Hide("HEAD_HAT_NOHELM")
                owner.AnimState:Hide("HEAD_HAT_HELM")
            end
        end
    local DarkSet_whisperose = function(inst, phase)
        local state
        if phase == nil then
            if TheWorld.state.isnight then
                state = 2
            elseif TheWorld.state.isdusk then
                state = 1
            end
        elseif phase == "night" then
            state = 2
        elseif phase == "dusk" then
            state = 1
        end
        local owner = inst._owner_l
        if owner == nil then
            return
        elseif owner.components.combat == nil then
            owner.legion_whisperose = nil
            return
        end
        owner.legion_whisperose = state
        if state == 2 then
            owner.components.combat.externaldamagemultipliers:SetModifier(inst,
                                                                          1.5)
        elseif state == 1 then
            owner.components.combat.externaldamagemultipliers:SetModifier(inst,
                                                                          1.3)
        else
            owner.components.combat.externaldamagemultipliers:RemoveModifier(
                inst)
        end
    end
    local OnHitOther_whisperose = function(owner, data) -- 攻击时会扣血
        local value = data.damageresolved or data.damage
        if value ~= nil and value > 0 and owner.legiontask_cost_whisperose ==
            nil then -- 造成了伤害才行
            owner.legiontask_cost_whisperose =
                owner:DoTaskInTime(0, function()
                    owner.legiontask_cost_whisperose = nil
                    if owner.components.health ~= nil and
                        not owner.components.health:IsDead() then
                        if owner:HasTag("genesis_nyx") then
                            if owner.components.health:IsHurt() then
                                owner.components.health:DoDelta(1, nil,
                                                                "hat_whisperose")
                            end
                        else
                            owner.components.health:DoDelta(-1, true,
                                                            "hat_whisperose")
                        end
                    end
                end)
        end
    end
    AddPrefabPostInit("hat_whisperose", function(inst)
        local equippable = inst.components.equippable
        if equippable == nil then return end
        equippable:SetOnEquip(function(inst, owner)
            hat_on_opentop(owner, "hat_whisperose", "swap_hat")
            owner.AnimState:SetSymbolLightOverride("swap_hat", 0.2)
            if owner:HasTag("equipmentmodel") then return end -- 假人
            inst._owner_l = owner
            inst:WatchWorldState("phase", DarkSet_whisperose)
            owner:ListenForEvent("onhitother", OnHitOther_whisperose)
            DarkSet_whisperose(inst, nil)
        end)
        equippable:SetOnUnequip(function(inst, owner)
            hat_off(inst, owner)
            owner.AnimState:SetSymbolLightOverride("swap_hat", 0)
            if owner:HasTag("equipmentmodel") then return end -- 假人
            inst:StopWatchingWorldState("phase", DarkSet_whisperose)
            owner:RemoveEventCallback("onhitother", OnHitOther_whisperose)
            DarkSet_whisperose(inst, "day")
            inst._owner_l = nil
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
