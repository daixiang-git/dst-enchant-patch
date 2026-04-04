if not AddSpecialEquipEffect then
    return
end

local ACTIONS = GLOBAL.ACTIONS
local EQUIPSLOTS = GLOBAL.EQUIPSLOTS
local CONTROL_FORCE_STACK = GLOBAL.CONTROL_FORCE_STACK
local GetTime = GLOBAL.GetTime
local net_bool = GLOBAL.net_bool
local State = GLOBAL.State
local FRAMES = GLOBAL.FRAMES
local Vector3 = GLOBAL.Vector3

local SLIDE_EFFECT = "rare_slide_dodge"
local SLIDE_TAG = "patch_rare_slide_dodge"
local SLIDE_COOLDOWN = 2
local SLIDE_SPEED = 20
local SLIDE_ACTION_NAME = "PATCH_SLIDE_DODGE"

local function HasComponents(inst, name)
    return inst ~= nil and inst.components ~= nil and inst.components[name] ~= nil
end

-- ============================================================
-- 第一步：定义滑铲动作（如果 Legion 已定义 DODGE_WALTER 则复用，否则自行定义）
-- ============================================================
local SLIDE_ACTION = ACTIONS.DODGE_WALTER  -- 尝试复用 Legion 的

if SLIDE_ACTION == nil then
    -- Legion 未安装，自行定义动作
    AddAction(SLIDE_ACTION_NAME, "Slide Dodge", function(act, data)
        if act.pos or act.target then
            local doer = act.doer
            doer.sg:GoToState("patch_slide_dodge", { pos = act.pos or act.target })
            return true
        end
    end)
    SLIDE_ACTION = ACTIONS[SLIDE_ACTION_NAME]
    SLIDE_ACTION.distance = math.huge
    SLIDE_ACTION.instant = true
    SLIDE_ACTION.mount_valid = true
    GLOBAL.STRINGS.ACTIONS[SLIDE_ACTION_NAME] = { GENERIC = "冲刺" }
end

-- 实际使用的动作引用（可能是 DODGE_WALTER 或 PATCH_SLIDE_DODGE）
local RESOLVED_ACTION = SLIDE_ACTION

-- ============================================================
-- 第二步：定义滑铲状态机（仿制自 Legion 的 dodge2hm）
-- 如果 Legion 已定义 dodge2hm，补丁使用自己的状态名避免冲突
-- ============================================================
local STATE_NAME = ACTIONS.DODGE_WALTER ~= nil and "dodge2hm" or "patch_slide_dodge"

-- 只在 Legion 未安装时定义状态机
if ACTIONS.DODGE_WALTER == nil then
    local function cancelmiss(inst)
        inst.cancelmisstask2hm = nil
        if inst.allmiss2hm then inst.allmiss2hm = nil end
    end

    -- 服务端状态
    AddStategraphState("wilson", State {
        name = STATE_NAME,
        tags = { "busy", "evade", "no_stun", "canrotate", "pausepredict", "nopredict", "drowning" },
        onenter = function(inst, data)
            inst.components.locomotor:Stop()
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end
            if data and data.pos then
                local pos = data.pos:GetPosition()
                inst:ForceFacePoint(pos.x, 0, pos.z)
            end
            inst.components.locomotor:EnableGroundSpeedMultiplier(false)
            inst.allmiss2hm = true

            local riding = inst.components.rider and inst.components.rider:IsRiding()
            if riding then
                inst.AnimState:PlayAnimation("slingshot_pre")
                inst.AnimState:PushAnimation("slingshot", false)
            else
                inst.AnimState:PlayAnimation("wortox_portal_jumpin_pre")
                inst.AnimState:PushAnimation("wortox_portal_jumpin_lag", false)
            end
            inst.SoundEmitter:PlaySound("dontstarve/characters/wortox/soul/hop_out")

            local speed = SLIDE_SPEED
            if riding then speed = speed * 1.2 end
            inst.Physics:SetMotorVelOverride(speed, 0, 0)

            local dodgetime = riding and 0.3 or 0.25
            inst.last_rightaction2hm_time = GetTime() + dodgetime
            if inst.rightaction2hm ~= nil then
                inst.rightaction2hm:set(inst.rightaction2hm:value() == false and true or false)
            end
            inst.sg:SetTimeout(dodgetime)
        end,
        ontimeout = function(inst)
            if not inst.cancelmisstask2hm then
                inst.cancelmisstask2hm = inst:DoTaskInTime(0.1, cancelmiss)
            end
            inst.sg:GoToState("idle")
        end,
        onexit = function(inst)
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)
            inst.Physics:ClearMotorVelOverride()
            inst.components.locomotor:Stop()
            inst.components.locomotor:SetBufferedAction(nil)
            if not inst.cancelmisstask2hm then
                inst.cancelmisstask2hm = inst:DoTaskInTime(0.1, cancelmiss)
            end
        end,
    })

    -- 客户端状态
    local function ClearCachedServerState(inst)
        if inst.player_classified ~= nil then
            inst.player_classified.currentstate:set_local(0)
        end
    end

    AddStategraphState("wilson_client", State {
        name = STATE_NAME,
        tags = { "busy", "evade", "no_stun", "canrotate", "pausepredict", "nopredict", "drowning" },
        onenter = function(inst, data)
            inst.components.locomotor:Stop()
            inst.components.locomotor:Clear()
            inst:ClearBufferedAction()
            inst.entity:FlattenMovementPrediction()
            inst.entity:SetIsPredictingMovement(false)
            ClearCachedServerState(inst)
            if data and data.pos then
                local pos = data.pos:GetPosition()
                inst:ForceFacePoint(pos.x, 0, pos.z)
            end
            local riding = inst.replica and inst.replica.rider and inst.replica.rider:IsRiding()
            if riding then
                inst.AnimState:PlayAnimation("slingshot_pre")
                inst.AnimState:PushAnimation("slingshot", false)
            else
                inst.AnimState:PlayAnimation("wortox_portal_jumpin_pre")
                inst.AnimState:PushAnimation("wortox_portal_jumpin_lag", false)
            end
            local dodgetime = riding and 0.3 or 0.25
            inst.last_rightaction2hm_time = GetTime() + dodgetime
            inst.sg:SetTimeout(2)
        end,
        onupdate = function(inst)
            if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,
        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
        onexit = function(inst)
        end,
    })
end

-- ============================================================
-- 第三步：右键动作选择器
-- ============================================================
local function IsAoeTargeting(inst)
    local inventory = inst.replica ~= nil and inst.replica.inventory or nil
    local item = inventory ~= nil and inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
    if item == nil then
        return false
    end
    return item.components.aoetargeting ~= nil
end

local function HasRareSlide(inst)
    return inst ~= nil and inst:HasTag(SLIDE_TAG)
end

local function ShouldShowSlideAction(inst, right)
    if not right then return false end
    if not HasRareSlide(inst) then return false end
    if RESOLVED_ACTION == nil then return false end
    if IsAoeTargeting(inst) then return false end

    local cooldown = inst.rightaction2hm_cooldown or SLIDE_COOLDOWN
    local last_time = inst.last_rightaction2hm_time or 0
    if GetTime() - last_time <= cooldown then
        return false
    end
    return true
end

-- Hook playeractionpicker 组件
AddComponentPostInit("playeractionpicker", function(self, inst)
    local _base_GetPointSpecialActions = self.GetPointSpecialActions
    self.GetPointSpecialActions = function(self, pos, useitem, right, usereticulepos)
        if ShouldShowSlideAction(self.inst, right) then
            return self:SortActionList({ RESOLVED_ACTION }, usereticulepos or pos, useitem)
        end
        return _base_GetPointSpecialActions(self, pos, useitem, right, usereticulepos)
    end

    local _base_GetRightClickActions = self.GetRightClickActions
    self.GetRightClickActions = function(self, position, target, spellbook)
        local actions = _base_GetRightClickActions(self, position, target, spellbook)
        if (actions == nil or #actions <= 0) and ShouldShowSlideAction(self.inst, true) then
            local slide_actions = self:SortActionList({ RESOLVED_ACTION }, position)
            if #slide_actions > 0 then
                return slide_actions
            end
        end
        return actions
    end
end)

-- ============================================================
-- 第四步：玩家基础变量初始化
-- ============================================================
AddPlayerPostInit(function(inst)
    -- net_bool：服务端状态机需要（toggle 通知客户端冷却）
    if inst.rightaction2hm == nil then
        inst.rightaction2hm = net_bool(inst.GUID, "player.rightaction2hm", "rightaction2hmdirty")
        inst:ListenForEvent("rightaction2hmdirty", function()
            inst.last_rightaction2hm_time = GetTime() + 0.25
        end)
    end

    if inst.pettiredPG == nil then
        inst.pettiredPG = 0
    end

    if not TheWorld.ismastersim then
        return
    end

    inst.last_rightaction2hm_time = inst.last_rightaction2hm_time or (GetTime() - SLIDE_COOLDOWN)
    inst.rightaction2hm_cooldown = inst.rightaction2hm_cooldown or SLIDE_COOLDOWN
end)

-- ============================================================
-- 第五步：注册附魔石词条
-- ============================================================
AddSpecialEquipEffect(SLIDE_EFFECT, {
    id = 10097,
    name = "滑铲-稀",
    client_text = "稀\n滑铲",
    desc = "获得为爽而虐滑铲能力(右键冲刺)",
    check_desc = "无",
    can_add = false,
    only_one = true,
    star_rating = 8,
    on_equip_fn = function(inst, owner, value)
        if owner == nil then return end
        owner.patch_rare_slide_count = (owner.patch_rare_slide_count or 0) + 1
        owner:AddTag(SLIDE_TAG)
    end,
    un_equip_fn = function(inst, owner, value)
        if owner == nil then return end
        owner.patch_rare_slide_count = math.max((owner.patch_rare_slide_count or 1) - 1, 0)
        if owner.patch_rare_slide_count <= 0 then
            owner.patch_rare_slide_count = nil
            owner:RemoveTag(SLIDE_TAG)
        end
    end,
})
