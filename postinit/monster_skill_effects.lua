local ENABLE_SPIT_SKILL = GetModConfigData("enable_monster_spit_skill") ~= false
local ENABLE_SHOCKWAVE_SKILL = GetModConfigData("enable_monster_shockwave_skill") ~= false
local ENABLE_CHARGE_SKILL = GetModConfigData("enable_monster_charge_skill") ~= false
local ENABLE_POUNCE_SKILL = GetModConfigData("enable_monster_pounce_skill") ~= false

if not ENABLE_SPIT_SKILL and not ENABLE_SHOCKWAVE_SKILL and not ENABLE_CHARGE_SKILL and not ENABLE_POUNCE_SKILL then
    return
end

local HH_UTILS = require("utils/hh_utils")

local SPIT_EFFECT_KEY = "skillSpitAttack"
local SHOCKWAVE_EFFECT_KEY = "skillShockwaveAttack"
local CHARGE_EFFECT_KEY = "skillChargeAttack"
local POUNCE_EFFECT_KEY = "skillPounceAttack"
local SPIT_CANDIDATE_TAG = "hh_skill_spit_candidate"
local SHOCKWAVE_CANDIDATE_TAG = "hh_skill_shockwave_candidate"
local CHARGE_CANDIDATE_TAG = "hh_skill_charge_candidate"
local POUNCE_CANDIDATE_TAG = "hh_skill_pounce_candidate"

local PREFAB_BLACKLIST = {
    alterguardian_phase1 = true,
    alterguardian_phase2 = true,
    alterguardian_phase3 = true,
    alterguardian_phase4_lunarrift = true,
    antlion = true,
    beequeen = true,
    crabking = true,
    crabking_claw = true,
    daywalker = true,
    daywalker2 = true,
    dragonfly = true,
    malbatross = true,
    stalker = true,
    stalker_atrium = true,
    toadstool = true,
    toadstool_dark = true,
    worm_boss_head = true,
    worm_boss_tail = true,
}

local EXCLUDED_TAGS = {
    INLIMBO = true,
    companion = true,
    flight = true,
    flying = true,
    noattack = true,
    notarget = true,
    player = true,
    playerghost = true,
    structure = true,
    wall = true,
}

local SPITTER_MIN_RANGE = TUNING.SPIDER_SPITTER_MELEE_RANGE or 3
local SPITTER_MAX_RANGE = TUNING.SPIDER_SPITTER_ATTACK_RANGE or 8

local SPIT_PARAMS = {
    common = { cooldown = 8, proc = 0.30, min_range = SPITTER_MIN_RANGE, max_range = SPITTER_MAX_RANGE, windup = 0.2, damage_mult = 0.9 },
    elite = { cooldown = 6, proc = 0.38, min_range = SPITTER_MIN_RANGE, max_range = SPITTER_MAX_RANGE, windup = 0.15, damage_mult = 1.1 },
    boss = { cooldown = 4, proc = 0.45, min_range = SPITTER_MIN_RANGE, max_range = SPITTER_MAX_RANGE, windup = 0.1, damage_mult = 1.25 },
}

local SHOCKWAVE_PARAMS = {
    common = { cooldown = 10, proc = 0.22, trigger_range = 3.5, radius = 3.2, windup = 0.05, damage_mult = 0.95 },
    elite = { cooldown = 8, proc = 0.28, trigger_range = 4.5, radius = 4.2, windup = 0.05, damage_mult = 1.1 },
    boss = { cooldown = 6, proc = 0.34, trigger_range = 5.5, radius = 5.2, windup = 0.05, damage_mult = 1.25 },
}

local CHARGE_PARAMS = {
    common = { cooldown = 12, proc = 0.18, min_range = 4, max_range = 9, windup = 0.12, duration = 0.55, speed = 14, hit_radius = 1.8, damage_mult = 1.0 },
    elite = { cooldown = 10, proc = 0.24, min_range = 4, max_range = 11, windup = 0.1, duration = 0.65, speed = 16, hit_radius = 2.2, damage_mult = 1.15 },
    boss = { cooldown = 8, proc = 0.30, min_range = 4, max_range = 13, windup = 0.08, duration = 0.75, speed = 18, hit_radius = 2.6, damage_mult = 1.3 },
}

local POUNCE_PARAMS = {
    common = { cooldown = 10, proc = 0.16, min_range = 3, max_range = 8, windup = 0.18, duration = 0.28, speed = 18, radius = 2.2, damage_mult = 0.95 },
    elite = { cooldown = 8, proc = 0.22, min_range = 3, max_range = 10, windup = 0.15, duration = 0.34, speed = 20, radius = 2.8, damage_mult = 1.1 },
    boss = { cooldown = 6, proc = 0.28, min_range = 3, max_range = 12, windup = 0.12, duration = 0.4, speed = 22, radius = 3.4, damage_mult = 1.25 },
}

local SKILL_TARGET_MUST_TAGS = { "_combat", "_health" }
local SKILL_TARGET_CANT_TAGS = { "INLIMBO", "flight", "invisible", "notarget", "noattack", "playerghost", "wall" }
local SKILL_TARGET_ONEOF_TAGS = { "character", "monster", "animal", "shadowminion" }

local function HasComponents(inst, ...)
    if inst == nil or inst.components == nil then
        return false
    end

    for i = 1, select("#", ...) do
        local name = select(i, ...)
        if inst.components[name] == nil then
            return false
        end
    end

    return true
end

local function HasExcludedTag(inst)
    if inst == nil or inst.HasTag == nil then
        return true
    end

    for tag in pairs(EXCLUDED_TAGS) do
        if inst:HasTag(tag) then
            return true
        end
    end

    return false
end

local function IsBlacklisted(inst)
    return inst == nil
        or inst.prefab == nil
        or PREFAB_BLACKLIST[inst.prefab] == true
end

local function IsBaseCandidate(inst)
    return inst ~= nil
        and inst.entity ~= nil
        and inst.Transform ~= nil
        and inst.sg ~= nil
        and not IsBlacklisted(inst)
        and not HasExcludedTag(inst)
        and HasComponents(inst, "combat", "health", "locomotor")
end

local function IsSpitCandidate(inst)
    if not IsBaseCandidate(inst) then
        return false
    end

    local radius = inst.GetPhysicsRadius ~= nil and inst:GetPhysicsRadius(0) or 0
    return not inst:HasTag("smallcreature") and radius >= 0.3
end

local function IsShockwaveCandidate(inst)
    if not IsBaseCandidate(inst) then
        return false
    end

    local radius = inst.GetPhysicsRadius ~= nil and inst:GetPhysicsRadius(0) or 0
    return inst:HasTag("largecreature")
        or inst:HasTag("epic")
        or radius >= 1.2
end

local function IsChargeCandidate(inst)
    if not IsBaseCandidate(inst) then
        return false
    end

    local radius = inst.GetPhysicsRadius ~= nil and inst:GetPhysicsRadius(0) or 0
    return inst:HasTag("largecreature")
        or inst:HasTag("epic")
        or radius >= 0.9
end

local function IsPounceCandidate(inst)
    if not IsBaseCandidate(inst) then
        return false
    end

    local radius = inst.GetPhysicsRadius ~= nil and inst:GetPhysicsRadius(0) or 0
    return not inst:HasTag("smallcreature")
        and not inst:HasTag("wall")
        and radius >= 0.35
        and radius <= 1.8
end

local function GetMonsterTier(inst)
    if inst ~= nil and inst:HasTag("boss_monster") then
        return "boss"
    end
    if inst ~= nil and inst:HasTag("elite_monster") then
        return "elite"
    end
    return "common"
end

local function GetSkillDamage(inst, mult)
    if not HasComponents(inst, "combat") then
        return 0
    end

    local base_damage = inst.components.combat.defaultdamage or 0
    if type(base_damage) ~= "number" or base_damage <= 0 then
        base_damage = 20
    end

    return math.max(base_damage * (mult or 1), 1)
end

local function GetOrCreateSpitWeapon(attacker, damage, range)
    if attacker == nil then
        return nil
    end

    local weapon = attacker.hh_skill_spit_weapon
    if weapon == nil or not weapon:IsValid() then
        weapon = CreateEntity()
        weapon.persists = false
        weapon.entity:AddTransform()
        weapon.entity:SetParent(attacker.entity)
        weapon:RemoveFromScene()

        weapon:AddComponent("inventoryitem")
        weapon.components.inventoryitem.owner = attacker

        weapon:AddComponent("weapon")
        weapon.projectilemissremove2hm = true
        weapon.projectileneedstartpos2hm = true
        weapon.projectilespeed2hm = 20
        weapon.projectilehoming2hm = false
        weapon.projectilephysics2hm = false
        weapon.components.weapon:SetProjectile("spider_web_spit")
        weapon.components.weapon:SetProjectileOffset(1.2)

        attacker.hh_skill_spit_weapon = weapon
    end

    weapon.components.weapon:SetDamage(damage)
    weapon.components.weapon:SetRange(range or 10, (range or 10) + 4)
    weapon.projectiledelay = 2.5 * FRAMES
    return weapon
end

local function LaunchSpitProjectile(attacker, target, damage, range)
    if attacker == nil or target == nil then
        return false
    end

    local weapon = GetOrCreateSpitWeapon(attacker, damage, range)
    if weapon == nil or weapon.components == nil or weapon.components.weapon == nil then
        return false
    end

    weapon.components.weapon:LaunchProjectile(attacker, target)
    return true
end

local function IsValidBaseTarget(inst, target)
    return inst ~= nil
        and target ~= nil
        and target:IsValid()
        and target ~= inst
        and HasComponents(target, "health")
        and not target.components.health:IsDead()
        and HasComponents(inst, "combat")
        and inst.components.combat:CanTarget(target)
end

local function IsValidSpitTarget(inst, target)
    return IsValidBaseTarget(inst, target)
        and target:HasTag("player")
end

local function IsValidSkillTarget(inst, target)
    return IsValidBaseTarget(inst, target)
end

local function ApplySkillDamage(inst, target, damage)
    if not IsValidBaseTarget(inst, target) or not HasComponents(target, "combat") then
        return false
    end

    target.components.combat:GetAttacked(inst, damage, nil)
    return true
end

local function IsHardBlockedForSkill(inst)
    return inst == nil
        or inst.sg == nil
        or inst.sg:HasAnyStateTag("dead", "frozen", "jumping", "sleeping")
end

local function SpawnSkillIndicator(pos, scale, color)
    if pos ~= nil and HH_UTILS ~= nil and HH_UTILS.SpawnIndicatorFx ~= nil then
        HH_UTILS:SpawnIndicatorFx(pos, scale or 1, color or { 1, 1, 1, 1 }, 1)
    end
end

local function SpawnSkillText(inst, text)
    if inst ~= nil and HH_UTILS ~= nil and HH_UTILS.SpawnTextFx ~= nil then
        HH_UTILS:SpawnTextFx(inst, text)
    end
end

local function ClearVelocityOverride(inst)
    if inst ~= nil and inst:IsValid() and inst.Physics ~= nil then
        inst.Physics:ClearMotorVelOverride()
        inst.Physics:Stop()
    end
end

local function SpawnGroundTrailFx(inst)
    if inst == nil or not inst:IsValid() then
        return
    end

    local fx = SpawnPrefab("dirt_puff")
    if fx ~= nil and fx.Transform ~= nil then
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    end
end

local function FaceTarget(inst, target)
    if inst ~= nil and target ~= nil and target:IsValid() then
        inst:FacePoint(target.Transform:GetWorldPosition())
    end
end

local function GetVelocityToPoint(inst, x, z, speed)
    if inst == nil or inst.Transform == nil then
        return nil, nil
    end

    local ix, iy, iz = inst.Transform:GetWorldPosition()
    local dx = x - ix
    local dz = z - iz
    local len = math.sqrt(dx * dx + dz * dz)
    if len <= 0.001 then
        return 0, 0
    end

    local mult = (speed or 0) / len
    return dx * mult, dz * mult
end

local function SetVelocityTowardsTarget(inst, target, speed)
    if inst == nil or target == nil or not target:IsValid() or inst.Physics == nil then
        return false
    end

    local tx, ty, tz = target.Transform:GetWorldPosition()
    local vx, vz = GetVelocityToPoint(inst, tx, tz, speed)
    if vx == nil or vz == nil then
        return false
    end

    inst.Physics:SetMotorVel(vx, 0, vz)
    FaceTarget(inst, target)
    return true
end

local function MarkSkillCandidate(inst)
    if inst == nil or inst._hh_skill_candidates_initialized then
        return
    end
    inst._hh_skill_candidates_initialized = true

    if IsSpitCandidate(inst) then
        inst:AddTag(SPIT_CANDIDATE_TAG)
    end
    if IsShockwaveCandidate(inst) then
        inst:AddTag(SHOCKWAVE_CANDIDATE_TAG)
    end
    if IsChargeCandidate(inst) then
        inst:AddTag(CHARGE_CANDIDATE_TAG)
    end
    if IsPounceCandidate(inst) then
        inst:AddTag(POUNCE_CANDIDATE_TAG)
    end
end

AddPrefabPostInitAny(function(inst)
    if TheWorld ~= nil and not TheWorld.ismastersim then
        return
    end
    MarkSkillCandidate(inst)
end)

local function TryUseSpitSkill(self, target)
    local inst = self.inst
    if not ENABLE_SPIT_SKILL
        or inst == nil
        or not inst:HasTag(SPIT_CANDIDATE_TAG)
        or self:GetEffectValueByKey(SPIT_EFFECT_KEY) <= 0
    then
        return false
    end

    local params = SPIT_PARAMS[GetMonsterTier(inst)]
    if params == nil or inst.hh_skill_spit_cd ~= nil and inst.hh_skill_spit_cd > GetTime() then
        return false
    end

    if not IsValidSpitTarget(inst, target) then
        return false
    end

    local dsq = inst:GetDistanceSqToInst(target)
    if dsq < params.min_range * params.min_range or dsq > params.max_range * params.max_range then
        return false
    end

    if math.random() > params.proc then
        return false
    end

    inst.hh_skill_spit_cd = GetTime() + params.cooldown
    SpawnSkillText(inst, "喷吐")
    SpawnSkillIndicator(target:GetPosition(), 1.2, { 0.35, 0.85, 0.35, 1 })

    local captured_target = target
    inst:DoTaskInTime(params.windup, function(attacker)
        if attacker == nil or not attacker:IsValid() or not HasComponents(attacker, "combat") or IsHardBlockedForSkill(attacker) then
            return
        end
        if not IsValidSpitTarget(attacker, captured_target) then
            return
        end
        if attacker:GetDistanceSqToInst(captured_target) > (params.max_range + 1) * (params.max_range + 1) then
            return
        end

        attacker:FacePoint(captured_target.Transform:GetWorldPosition())
        SpawnSkillIndicator(captured_target:GetPosition(), 0.9, { 0.4, 1, 0.4, 1 })
        LaunchSpitProjectile(attacker, captured_target, GetSkillDamage(attacker, params.damage_mult), params.max_range + 2)
    end)

    return true
end

local function TryUseShockwaveSkill(self, target)
    local inst = self.inst
    if not ENABLE_SHOCKWAVE_SKILL
        or inst == nil
        or not inst:HasTag(SHOCKWAVE_CANDIDATE_TAG)
        or self:GetEffectValueByKey(SHOCKWAVE_EFFECT_KEY) <= 0
    then
        return false
    end

    local params = SHOCKWAVE_PARAMS[GetMonsterTier(inst)]
    if params == nil or inst.hh_skill_shockwave_cd ~= nil and inst.hh_skill_shockwave_cd > GetTime() then
        return false
    end

    if not IsValidSkillTarget(inst, target) then
        return false
    end

    if inst:GetDistanceSqToInst(target) > params.trigger_range * params.trigger_range then
        return false
    end

    if math.random() > params.proc then
        return false
    end

    inst.hh_skill_shockwave_cd = GetTime() + params.cooldown
    SpawnSkillText(inst, "震击")
    SpawnSkillIndicator(inst:GetPosition(), math.max(params.radius / 3, 1), { 1, 0.75, 0.35, 1 })

    inst:DoTaskInTime(params.windup, function(attacker)
        if attacker == nil or not attacker:IsValid() or not HasComponents(attacker, "combat") then
            return
        end

        local fx = SpawnPrefab("groundpoundring_fx")
        if fx ~= nil and fx.Transform ~= nil then
            fx.Transform:SetPosition(attacker.Transform:GetWorldPosition())
            fx.Transform:SetScale(math.max(params.radius / 2.8, 1), math.max(params.radius / 2.8, 1), math.max(params.radius / 2.8, 1))
        end

        local center_fx = SpawnPrefab("groundpound_fx")
        if center_fx ~= nil and center_fx.Transform ~= nil then
            center_fx.Transform:SetPosition(attacker.Transform:GetWorldPosition())
        end

        local x, y, z = attacker.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, params.radius, SKILL_TARGET_MUST_TAGS, SKILL_TARGET_CANT_TAGS, SKILL_TARGET_ONEOF_TAGS)
        for _, ent in ipairs(ents) do
            if ent ~= attacker and IsValidSkillTarget(attacker, ent) then
                local hit_fx = SpawnPrefab("groundpound_fx")
                if hit_fx ~= nil and hit_fx.Transform ~= nil then
                    hit_fx.Transform:SetPosition(ent.Transform:GetWorldPosition())
                end
                ApplySkillDamage(attacker, ent, GetSkillDamage(attacker, params.damage_mult))
            end
        end
    end)

    return true
end

local function TryUseChargeSkill(self, target)
    local inst = self.inst
    if not ENABLE_CHARGE_SKILL
        or inst == nil
        or not inst:HasTag(CHARGE_CANDIDATE_TAG)
        or self:GetEffectValueByKey(CHARGE_EFFECT_KEY) <= 0
    then
        return false
    end

    local params = CHARGE_PARAMS[GetMonsterTier(inst)]
    if params == nil or inst.hh_skill_charge_cd ~= nil and inst.hh_skill_charge_cd > GetTime() then
        return false
    end

    if not IsValidSkillTarget(inst, target) or not target:HasTag("player") then
        return false
    end

    local dsq = inst:GetDistanceSqToInst(target)
    if dsq < params.min_range * params.min_range or dsq > params.max_range * params.max_range then
        return false
    end

    if math.random() > params.proc or inst.Physics == nil then
        return false
    end

    inst.hh_skill_charge_cd = GetTime() + params.cooldown
    SpawnSkillText(inst, "冲撞")
    SpawnSkillIndicator(target:GetPosition(), 1.4, { 1, 0.45, 0.2, 1 })

    local captured_target = target
    inst:DoTaskInTime(params.windup, function(attacker)
        if attacker == nil or not attacker:IsValid() or not HasComponents(attacker, "combat") or attacker.Physics == nil then
            return
        end
        if not IsValidSkillTarget(attacker, captured_target) then
            return
        end

        attacker.components.locomotor:Stop()
        attacker.components.locomotor:EnableGroundSpeedMultiplier(false)
        SetVelocityTowardsTarget(attacker, captured_target, params.speed)
        SpawnGroundTrailFx(attacker)

        local hit_targets = {}
        local dash_task = attacker:DoPeriodicTask(0.05, function(runner)
            if not SetVelocityTowardsTarget(runner, captured_target, params.speed) then
                return
            end
            local x, y, z = runner.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x, y, z, params.hit_radius, SKILL_TARGET_MUST_TAGS, SKILL_TARGET_CANT_TAGS, SKILL_TARGET_ONEOF_TAGS)
            for _, ent in ipairs(ents) do
                if ent ~= runner and not hit_targets[ent] and IsValidSkillTarget(runner, ent) then
                    hit_targets[ent] = true
                    ApplySkillDamage(runner, ent, GetSkillDamage(runner, params.damage_mult))
                end
            end
            SpawnGroundTrailFx(runner)
        end)

        attacker:DoTaskInTime(params.duration, function(runner)
            if dash_task ~= nil then
                dash_task:Cancel()
            end
            if runner ~= nil and runner:IsValid() then
                runner.components.locomotor:EnableGroundSpeedMultiplier(true)
                ClearVelocityOverride(runner)
            end
        end)
    end)

    return true
end

local function TryUsePounceSkill(self, target)
    local inst = self.inst
    if not ENABLE_POUNCE_SKILL
        or inst == nil
        or not inst:HasTag(POUNCE_CANDIDATE_TAG)
        or self:GetEffectValueByKey(POUNCE_EFFECT_KEY) <= 0
    then
        return false
    end

    local params = POUNCE_PARAMS[GetMonsterTier(inst)]
    if params == nil or inst.hh_skill_pounce_cd ~= nil and inst.hh_skill_pounce_cd > GetTime() then
        return false
    end

    if not IsValidSkillTarget(inst, target) or not target:HasTag("player") then
        return false
    end

    local dsq = inst:GetDistanceSqToInst(target)
    if dsq < params.min_range * params.min_range or dsq > params.max_range * params.max_range then
        return false
    end

    if math.random() > params.proc or inst.Physics == nil then
        return false
    end

    inst.hh_skill_pounce_cd = GetTime() + params.cooldown
    SpawnSkillText(inst, "飞扑")
    SpawnSkillIndicator(target:GetPosition(), 1.25, { 0.8, 0.95, 1, 1 })

    local captured_target = target
    inst:DoTaskInTime(params.windup, function(attacker)
        if attacker == nil or not attacker:IsValid() or attacker.Physics == nil or not HasComponents(attacker, "locomotor") then
            return
        end
        if not IsValidSkillTarget(attacker, captured_target) then
            return
        end

        attacker.components.locomotor:Stop()
        attacker.components.locomotor:EnableGroundSpeedMultiplier(false)
        SetVelocityTowardsTarget(attacker, captured_target, params.speed)

        local jump_task = attacker:DoPeriodicTask(0.05, function(runner)
            if not SetVelocityTowardsTarget(runner, captured_target, params.speed) then
                return
            end
            SpawnGroundTrailFx(runner)
        end)

        attacker:DoTaskInTime(params.duration, function(runner)
            if jump_task ~= nil then
                jump_task:Cancel()
            end
            if runner == nil or not runner:IsValid() then
                return
            end

            runner.components.locomotor:EnableGroundSpeedMultiplier(true)
            ClearVelocityOverride(runner)

            local land_x, land_y, land_z = runner.Transform:GetWorldPosition()
            local ring_fx = SpawnPrefab("groundpoundring_fx")
            if ring_fx ~= nil and ring_fx.Transform ~= nil then
                ring_fx.Transform:SetPosition(land_x, land_y, land_z)
                ring_fx.Transform:SetScale(math.max(params.radius / 2.8, 1), math.max(params.radius / 2.8, 1), math.max(params.radius / 2.8, 1))
            end

            local center_fx = SpawnPrefab("groundpound_fx")
            if center_fx ~= nil and center_fx.Transform ~= nil then
                center_fx.Transform:SetPosition(land_x, land_y, land_z)
            end

            local ents = TheSim:FindEntities(land_x, land_y, land_z, params.radius, SKILL_TARGET_MUST_TAGS, SKILL_TARGET_CANT_TAGS, SKILL_TARGET_ONEOF_TAGS)
            for _, ent in ipairs(ents) do
                if ent ~= runner and IsValidSkillTarget(runner, ent) then
                    ApplySkillDamage(runner, ent, GetSkillDamage(runner, params.damage_mult))
                end
            end
        end)
    end)

    return true
end

local function TryUseMonsterSkill(self, target)
    local inst = self ~= nil and self.inst or nil
    if inst == nil
        or TheWorld == nil
        or not TheWorld.ismastersim
        or not HasComponents(inst, "combat")
    then
        return false
    end

    target = target or inst.components.combat.target
    if not IsValidSpitTarget(inst, target) then
        return false
    end

    return TryUseSpitSkill(self, target)
end

local function TryUsePursuitSkills(self, target)
    local inst = self ~= nil and self.inst or nil
    if inst == nil
        or TheWorld == nil
        or not TheWorld.ismastersim
        or not HasComponents(inst, "combat", "locomotor")
        or IsHardBlockedForSkill(inst)
    then
        return false
    end

    target = target or inst.components.combat.target
    if not IsValidBaseTarget(inst, target) or not target:HasTag("player") then
        return false
    end

    if not inst.components.locomotor:WantsToMoveForward() then
        return false
    end

    if TryUseChargeSkill(self, target) then
        return true
    end

    if TryUsePounceSkill(self, target) then
        return true
    end

    return false
end

local SKILL_BUFFS = {
    common_monster = {},
    elite_monster = {},
    boss_monster = {},
}

if ENABLE_SPIT_SKILL then
    for monster_type, buffs in pairs(SKILL_BUFFS) do
        buffs.patch_skill_spit = {
            name = "喷吐(远程技能)",
            only_one = true,
            rangeValue = { min = 1, max = 1 },
            check_fn = function(inst)
                return inst ~= nil and inst:HasTag(SPIT_CANDIDATE_TAG)
            end,
            start_fn = function(inst, value)
                if inst ~= nil and inst:IsValid() and inst.components.hh_monster ~= nil then
                    inst.components.hh_monster:AddEffectValueByKey(SPIT_EFFECT_KEY, 1)
                end
            end,
        }
    end
end

if ENABLE_SHOCKWAVE_SKILL then
    for monster_type, buffs in pairs(SKILL_BUFFS) do
        buffs.patch_skill_shockwave = {
            name = "震击(范围技能)",
            only_one = true,
            rangeValue = { min = 1, max = 1 },
            check_fn = function(inst)
                return inst ~= nil and inst:HasTag(SHOCKWAVE_CANDIDATE_TAG)
            end,
            start_fn = function(inst, value)
                if inst ~= nil and inst:IsValid() and inst.components.hh_monster ~= nil then
                    inst.components.hh_monster:AddEffectValueByKey(SHOCKWAVE_EFFECT_KEY, 1)
                end
            end,
        }
    end
end

if ENABLE_CHARGE_SKILL then
    for monster_type, buffs in pairs(SKILL_BUFFS) do
        buffs.patch_skill_charge = {
            name = "冲撞(突进技能)",
            only_one = true,
            rangeValue = { min = 1, max = 1 },
            check_fn = function(inst)
                return inst ~= nil and inst:HasTag(CHARGE_CANDIDATE_TAG)
            end,
            start_fn = function(inst, value)
                if inst ~= nil and inst:IsValid() and inst.components.hh_monster ~= nil then
                    inst.components.hh_monster:AddEffectValueByKey(CHARGE_EFFECT_KEY, 1)
                end
            end,
        }
    end
end

if ENABLE_POUNCE_SKILL then
    for monster_type, buffs in pairs(SKILL_BUFFS) do
        buffs.patch_skill_pounce = {
            name = "飞扑(突袭技能)",
            only_one = true,
            rangeValue = { min = 1, max = 1 },
            check_fn = function(inst)
                return inst ~= nil and inst:HasTag(POUNCE_CANDIDATE_TAG)
            end,
            start_fn = function(inst, value)
                if inst ~= nil and inst:IsValid() and inst.components.hh_monster ~= nil then
                    inst.components.hh_monster:AddEffectValueByKey(POUNCE_EFFECT_KEY, 1)
                end
            end,
        }
    end
end

AddComponentPostInit("hh_monster", function(self, inst)
    if self.hh_effects ~= nil then
        if self.hh_effects[SPIT_EFFECT_KEY] == nil then
            self.hh_effects[SPIT_EFFECT_KEY] = 0
        end
        if self.hh_effects[SHOCKWAVE_EFFECT_KEY] == nil then
            self.hh_effects[SHOCKWAVE_EFFECT_KEY] = 0
        end
        if self.hh_effects[CHARGE_EFFECT_KEY] == nil then
            self.hh_effects[CHARGE_EFFECT_KEY] = 0
        end
        if self.hh_effects[POUNCE_EFFECT_KEY] == nil then
            self.hh_effects[POUNCE_EFFECT_KEY] = 0
        end
    end

    MarkSkillCandidate(inst)

    if ENABLE_SPIT_SKILL and inst._hh_monster_skill_doattack == nil then
        inst._hh_monster_skill_doattack = function(monster, data)
            if monster ~= nil and monster.components ~= nil and monster.components.hh_monster ~= nil then
                local target = data ~= nil and data.target or nil
                TryUseMonsterSkill(monster.components.hh_monster, target)
            end
        end
        inst:ListenForEvent("doattack", inst._hh_monster_skill_doattack)
    end

    if (ENABLE_CHARGE_SKILL or ENABLE_POUNCE_SKILL) and inst._hh_monster_skill_pursuit_task == nil then
        inst._hh_monster_skill_pursuit_task = inst:DoPeriodicTask(0.2, function(inst_)
            if inst_ ~= nil and inst_.components ~= nil and inst_.components.hh_monster ~= nil then
                TryUsePursuitSkills(inst_.components.hh_monster)
            end
        end)
    end

    if ENABLE_SHOCKWAVE_SKILL and inst._hh_monster_skill_onhit == nil then
        inst._hh_monster_skill_onhit = function(monster, data)
            if monster ~= nil and monster.components ~= nil and monster.components.hh_monster ~= nil then
                local target = data ~= nil and data.target or nil
                if IsValidSkillTarget(monster, target) then
                    TryUseShockwaveSkill(monster.components.hh_monster, target)
                end
            end
        end
        inst:ListenForEvent("onhitother", inst._hh_monster_skill_onhit)
    end
end)

local function InjectSkillBuffs()
    local success, hh_monster_enum = pcall(require, "enums/hh_monster")
    if not success or type(hh_monster_enum) ~= "table" then
        print("[附魔补丁] 无法加载 enums/hh_monster，跳过怪物技能词条注入")
        return
    end

    for monster_type, buffs in pairs(SKILL_BUFFS) do
        if type(hh_monster_enum[monster_type]) == "table" then
            for buff_name, buff_data in pairs(buffs) do
                if hh_monster_enum[monster_type][buff_name] == nil then
                    hh_monster_enum[monster_type][buff_name] = buff_data
                end
            end
        end
    end

    print("[附魔补丁] 怪物技能词条注入完成")
end

InjectSkillBuffs()
