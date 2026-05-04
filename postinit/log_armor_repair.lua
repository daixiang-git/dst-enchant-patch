local REPAIR_AMOUNT = (TUNING.ARMORWOOD or 450) / 10

local function CanRepairWoodArmorAction(item, target)
    return item ~= nil
        and target ~= nil
        and item.prefab == "log"
        and target.prefab == "armorwood"
end

local function CanRepairWoodArmor(item, target)
    return CanRepairWoodArmorAction(item, target)
        and target.components ~= nil
        and target.components.armor ~= nil
        and target.components.armor:GetPercent() < 1
end

local function GetArmorMaxCondition(target)
    return target ~= nil
        and target.components ~= nil
        and target.components.armor ~= nil
        and target.components.armor.maxcondition
        or TUNING.ARMORWOOD
        or 450
end

local function GetConsumeCountForFullRepair(repair_item, target)
    if not CanRepairWoodArmor(repair_item, target) then
        return 0
    end

    local armor = target.components.armor
    local max_condition = GetArmorMaxCondition(target)
    local current_condition = math.max((armor.GetPercent and armor:GetPercent() or 0) * max_condition, 0)
    local missing_condition = math.max(max_condition - current_condition, 0)

    if missing_condition <= 0 then
        return 0
    end

    local need_count = math.ceil(missing_condition / REPAIR_AMOUNT)
    local stackable = repair_item.components ~= nil and repair_item.components.stackable or nil
    local stack_count = stackable ~= nil and stackable:StackSize() or 1
    return math.max(math.min(need_count, stack_count), 0)
end

local function ConsumeRepairItems(repair_item, consume_count)
    if repair_item == nil or consume_count <= 0 then
        return
    end

    local stackable = repair_item.components ~= nil and repair_item.components.stackable or nil
    if stackable == nil then
        repair_item:Remove()
        return
    end

    local stack_count = stackable:StackSize()
    if consume_count >= stack_count then
        repair_item:Remove()
        return
    end

    local taken_stack = stackable:Get(consume_count)
    if taken_stack ~= nil then
        taken_stack:Remove()
    end
end

local repair_action = Action({ mount_valid = true, encumbered_valid = true, priority = 3 })
repair_action.id = "PATCH_REPAIR_WOODARMOR"
repair_action.str = STRINGS.ACTIONS.REPAIR and STRINGS.ACTIONS.REPAIR.GENERIC or "修理"
repair_action.fn = function(act)
    local target = act.target
    local repair_item = act.invobject
    local doer = act.doer

    if not CanRepairWoodArmor(repair_item, target) then
        return false
    end

    local consume_count = GetConsumeCountForFullRepair(repair_item, target)
    if consume_count <= 0 then
        return false
    end

    target.components.armor:Repair(REPAIR_AMOUNT * consume_count)

    if doer ~= nil and doer.SoundEmitter ~= nil then
        doer.SoundEmitter:PlaySound("turnoftides/common/together/boat/repair_with_wood")
    end

    ConsumeRepairItems(repair_item, consume_count)

    return true
end

AddAction(repair_action)

local function CollectRepairActions(inst, doer, target, actions)
    if CanRepairWoodArmorAction(inst, target) then
        table.insert(actions, ACTIONS.PATCH_REPAIR_WOODARMOR)
    end
end

AddComponentAction("USEITEM", "inventoryitem", CollectRepairActions)
AddComponentAction("EQUIPPED", "inventoryitem", CollectRepairActions)

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.PATCH_REPAIR_WOODARMOR, "dolongaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.PATCH_REPAIR_WOODARMOR, "dolongaction"))

print("[附魔补丁] 木头修复木甲已启用")
