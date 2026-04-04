local ENABLE_SPIT_SKILL = GetModConfigData("enable_monster_spit_skill") ~= false
local ENABLE_SHOCKWAVE_SKILL = GetModConfigData("enable_monster_shockwave_skill") ~= false
local ENABLE_CHARGE_SKILL = GetModConfigData("enable_monster_charge_skill") ~= false
local ENABLE_POUNCE_SKILL = GetModConfigData("enable_monster_pounce_skill") ~= false
local ENABLE_BARRAGE_SKILL = GetModConfigData("enable_monster_barrage_skill") ~= false
local ENABLE_TRAP_SKILL = GetModConfigData("enable_monster_trap_skill") ~= false
local ENABLE_BOLT_SKILL = GetModConfigData("enable_monster_bolt_skill") ~= false
local ENABLE_FREEZE_RING_SKILL = GetModConfigData("enable_monster_freeze_ring_skill") ~= false
local ENABLE_FIRE_RING_SKILL = GetModConfigData("enable_monster_fire_ring_skill") ~= false
local ENABLE_FLAME_CONE_SKILL = GetModConfigData("enable_monster_flame_cone_skill") ~= false
local ENABLE_TWIN_LASER_SKILL = GetModConfigData("enable_monster_twin_laser_skill") ~= false
local ENABLE_TWIN_DASH_SKILL = GetModConfigData("enable_monster_twin_dash_skill") ~= false
local ENABLE_TWIN_HELLFIRE_SKILL = GetModConfigData("enable_monster_twin_hellfire_skill") ~= false
local COMMON_SKILL_CD_MULT = GetModConfigData("monster_skill_cd_mult_common") or 1
local ELITE_SKILL_CD_MULT = GetModConfigData("monster_skill_cd_mult_elite") or 1
local BOSS_SKILL_CD_MULT = GetModConfigData("monster_skill_cd_mult_boss") or 1

if not ENABLE_SPIT_SKILL and not ENABLE_SHOCKWAVE_SKILL and not ENABLE_CHARGE_SKILL and not ENABLE_POUNCE_SKILL and not ENABLE_BARRAGE_SKILL and not ENABLE_TRAP_SKILL and not ENABLE_BOLT_SKILL and not ENABLE_FREEZE_RING_SKILL and not ENABLE_FIRE_RING_SKILL and not ENABLE_FLAME_CONE_SKILL and not ENABLE_TWIN_LASER_SKILL and not ENABLE_TWIN_DASH_SKILL and not ENABLE_TWIN_HELLFIRE_SKILL then
    return
end

local HH_UTILS = require("utils/hh_utils")
local PREFAB_LIST_OK, HH_PREFAB_LIST = pcall(require, "enums/hh_prefab_list")

local SPIT_EFFECT_KEY = "skillSpitAttack"
local SHOCKWAVE_EFFECT_KEY = "skillShockwaveAttack"
local CHARGE_EFFECT_KEY = "skillChargeAttack"
local POUNCE_EFFECT_KEY = "skillPounceAttack"
local BARRAGE_EFFECT_KEY = "skillBarrageAttack"
local TRAP_EFFECT_KEY = "skillTrapAttack"
local BOLT_EFFECT_KEY = "skillBoltAttack"
local FREEZE_RING_EFFECT_KEY = "skillFreezeRingAttack"
local FIRE_RING_EFFECT_KEY = "skillFireRingAttack"
local FLAME_CONE_EFFECT_KEY = "skillFlameConeAttack"
local TWIN_LASER_EFFECT_KEY = "skillTwinLaserAttack"
local TWIN_DASH_EFFECT_KEY = "skillTwinDashAttack"
local TWIN_HELLFIRE_EFFECT_KEY = "skillTwinHellfireAttack"
local SPIT_CANDIDATE_TAG = "hh_skill_spit_candidate"
local SHOCKWAVE_CANDIDATE_TAG = "hh_skill_shockwave_candidate"
local CHARGE_CANDIDATE_TAG = "hh_skill_charge_candidate"
local POUNCE_CANDIDATE_TAG = "hh_skill_pounce_candidate"
local BARRAGE_CANDIDATE_TAG = "hh_skill_barrage_candidate"
local TRAP_CANDIDATE_TAG = "hh_skill_trap_candidate"
local BOLT_CANDIDATE_TAG = "hh_skill_bolt_candidate"
local FREEZE_RING_CANDIDATE_TAG = "hh_skill_freeze_ring_candidate"
local FIRE_RING_CANDIDATE_TAG = "hh_skill_fire_ring_candidate"
local FLAME_CONE_CANDIDATE_TAG = "hh_skill_flame_cone_candidate"
local TWIN_LASER_CANDIDATE_TAG = "hh_skill_twin_laser_candidate"
local TWIN_DASH_CANDIDATE_TAG = "hh_skill_twin_dash_candidate"
local TWIN_HELLFIRE_CANDIDATE_TAG = "hh_skill_twin_hellfire_candidate"

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

local BARRAGE_PARAMS = {
    common = { cooldown = 14, proc = 0.16, min_range = 4, max_range = 24, travel_range = 42, count = 3, interval = 0.18, damage_mult = 0.7, spread_angle = 22, projectile_scale = 1.35 },
    elite = { cooldown = 12, proc = 0.22, min_range = 4, max_range = 28, travel_range = 50, count = 5, interval = 0.16, damage_mult = 0.8, spread_angle = 30, projectile_scale = 1.5 },
    boss = { cooldown = 10, proc = 0.28, min_range = 4, max_range = 32, travel_range = 58, count = 7, interval = 0.14, damage_mult = 0.9, spread_angle = 38, projectile_scale = 1.7 },
}

local TRAP_PARAMS = {
    common = { cooldown = 14, proc = 0.16, min_range = 3, max_range = 10, delay = 1.6, radius = 1.33, count = 2, spread = 3.1, damage_mult = 0.95 },
    elite = { cooldown = 12, proc = 0.22, min_range = 3, max_range = 12, delay = 1.45, radius = 1.6, count = 4, spread = 4.5, damage_mult = 1.1 },
    boss = { cooldown = 10, proc = 0.28, min_range = 3, max_range = 14, delay = 1.25, radius = 1.93, count = 8, spread = 6.2, damage_mult = 1.25 },
}

local BOLT_PARAMS = {
    common = { cooldown = 16, proc = 0.14, min_range = 5, max_range = 16, delay = 1.6, warning_scale = 0.9, hit_radius = 1.8, fire_damage = 4, count = 2, line_spacing = 2.8 },
    elite = { cooldown = 13, proc = 0.20, min_range = 5, max_range = 18, delay = 1.45, warning_scale = 1.05, hit_radius = 2.1, fire_damage = 6, count = 4, line_spacing = 3.2 },
    boss = { cooldown = 10, proc = 0.26, min_range = 5, max_range = 20, delay = 1.25, warning_scale = 1.2, hit_radius = 2.4, fire_damage = 8, count = 8, line_spacing = 3.6 },
}

local FREEZE_RING_PARAMS = {
    common = { cooldown = 15, proc = 0.14, min_range = 5, max_range = 16, delay = 1.2, warning_scale = 1.0, duration = 6 },
    elite = { cooldown = 12, proc = 0.20, min_range = 5, max_range = 18, delay = 1.05, warning_scale = 1.15, duration = 6 },
    boss = { cooldown = 9, proc = 0.26, min_range = 5, max_range = 20, delay = 0.9, warning_scale = 1.3, duration = 6 },
}

local FIRE_RING_PARAMS = {
    common = { cooldown = 15, proc = 0.14, min_range = 5, max_range = 16, delay = 1.2, warning_scale = 1.0, duration = 4 },
    elite = { cooldown = 12, proc = 0.20, min_range = 5, max_range = 18, delay = 1.05, warning_scale = 1.15, duration = 4 },
    boss = { cooldown = 9, proc = 0.26, min_range = 5, max_range = 20, delay = 0.9, warning_scale = 1.3, duration = 4 },
}

local FLAME_CONE_PARAMS = {
    common = nil,
    elite = { cooldown = 11, proc = 0.20, min_range = 3, max_range = 12, windup = 1.5, duration = 1.05, tick = 0.16, reach = 9.5, half_angle = 34, damage_mult = 0.7, fire_damage = 4, ignite_chance = 0.5 },
    boss = { cooldown = 8, proc = 0.26, min_range = 3, max_range = 14, windup = 1.5, duration = 1.2, tick = 0.14, reach = 11, half_angle = 40, damage_mult = 0.85, fire_damage = 5, ignite_chance = 0.65 },
}

local TWIN_LASER_PARAMS = {
    common = nil,
    elite = { cooldown = 16, proc = 0.16, min_range = 7, max_range = 24, windup = 1.5, reach = 24, step = 1.1, damage_mult = 0.95, scale = 1.0 },
    boss = { cooldown = 12, proc = 0.22, min_range = 7, max_range = 30, windup = 1.5, reach = 28, step = 1.0, damage_mult = 1.15, scale = 1.15 },
}

local TWIN_DASH_PARAMS = {
    common = nil,
    elite = { cooldown = 17, proc = 0.18, min_range = 5, max_range = 20, windup = 1.5, count = 5, dash_duration = 0.28, dash_gap = 0.04, speed = 34, hit_radius = 2.4, damage_mult = 0.9 },
    boss = { cooldown = 13, proc = 0.24, min_range = 5, max_range = 24, windup = 1.5, count = 5, dash_duration = 0.32, dash_gap = 0.03, speed = 38, hit_radius = 2.9, damage_mult = 1.05 },
}

local TWIN_HELLFIRE_PARAMS = {
    common = nil,
    elite = { cooldown = 15, proc = 0.18, min_range = 4, max_range = 15, windup = 1.5, duration = 1.35, tick = 0.08, reach = 12.5, half_angle = 44, damage_mult = 0.95, fire_damage = 6, ignite_chance = 0.85 },
    boss = { cooldown = 11, proc = 0.24, min_range = 4, max_range = 17, windup = 1.5, duration = 1.55, tick = 0.06, reach = 14.5, half_angle = 50, damage_mult = 1.1, fire_damage = 8, ignite_chance = 1.0 },
}

local THINK_MIN_INTERVAL = 0.4
local THINK_MAX_INTERVAL = 0.6
local THINK_MAX_GROUPS_PER_ROUND = 3

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

local function IsBarrageCandidate(inst)
    return IsSpitCandidate(inst)
end

local function IsTrapCandidate(inst)
    if not IsBaseCandidate(inst) then
        return false
    end

    local radius = inst.GetPhysicsRadius ~= nil and inst:GetPhysicsRadius(0) or 0
    return not inst:HasTag("smallcreature")
        and radius >= 0.45
end

local function IsBoltCandidate(inst)
    if not IsBaseCandidate(inst) then
        return false
    end

    local radius = inst.GetPhysicsRadius ~= nil and inst:GetPhysicsRadius(0) or 0
    return not inst:HasTag("smallcreature")
        and radius >= 0.3
end

local function IsFreezeRingCandidate(inst)
    if not IsBaseCandidate(inst) then
        return false
    end

    local radius = inst.GetPhysicsRadius ~= nil and inst:GetPhysicsRadius(0) or 0
    return not inst:HasTag("smallcreature")
        and radius >= 0.45
end

local function IsFireRingCandidate(inst)
    return IsFreezeRingCandidate(inst)
end

local function IsFlameConeCandidate(inst)
    return IsSpitCandidate(inst)
end

local function IsTwinLaserCandidate(inst)
    return IsSpitCandidate(inst)
end

local function IsTwinDashCandidate(inst)
    if not IsBaseCandidate(inst) then
        return false
    end

    local radius = inst.GetPhysicsRadius ~= nil and inst:GetPhysicsRadius(0) or 0
    return inst:HasTag("largecreature")
        or inst:HasTag("epic")
        or radius >= 0.9
end

local function IsTwinHellfireCandidate(inst)
    return IsSpitCandidate(inst)
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
    if HasComponents(inst, "hh_monster") and inst.components.hh_monster.GetMonsterType ~= nil then
        local monster_type = inst.components.hh_monster:GetMonsterType()
        if monster_type == "boss_monster" then
            return "boss"
        elseif monster_type == "elite_monster" then
            return "elite"
        elseif monster_type == "common_monster" then
            return "common"
        end
    end

    if PREFAB_LIST_OK and type(HH_PREFAB_LIST) == "table" and inst ~= nil and inst.prefab ~= nil then
        if type(HH_PREFAB_LIST["boss_monster"]) == "table" and HH_PREFAB_LIST["boss_monster"][inst.prefab] then
            return "boss"
        end
        if type(HH_PREFAB_LIST["elite_monster"]) == "table" and HH_PREFAB_LIST["elite_monster"][inst.prefab] then
            return "elite"
        end
        if type(HH_PREFAB_LIST["common_monster"]) == "table" and HH_PREFAB_LIST["common_monster"][inst.prefab] then
            return "common"
        end
    end

    if inst ~= nil and inst:HasTag("boss_monster") then
        return "boss"
    end
    if inst ~= nil and inst:HasTag("elite_monster") then
        return "elite"
    end
    return "common"
end

local function GetSkillCooldown(params, inst)
    if params == nil then
        return 0
    end

    local base = params.cooldown or 0
    local tier = type(inst) == "string" and inst or GetMonsterTier(inst)
    local mult = 1

    if tier == "boss" then
        mult = BOSS_SKILL_CD_MULT
    elseif tier == "elite" then
        mult = ELITE_SKILL_CD_MULT
    else
        mult = COMMON_SKILL_CD_MULT
    end

    if type(mult) ~= "number" or mult <= 0 then
        mult = 1
    end

    return math.max(base * mult, 0.1)
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
    weapon.projectiledelay = nil
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

local function GetAngleOffsets(count, spread_angle)
    local offsets = {}
    if count <= 1 then
        offsets[1] = 0
        return offsets
    end

    local start_angle = -spread_angle * (count - 1) / 2
    for i = 1, count do
        offsets[i] = start_angle + spread_angle * (i - 1)
    end
    return offsets
end

local function LaunchBarrageProjectile(attacker, target, damage, range, angle_offset, projectile_scale)
    if attacker == nil or target == nil or not target:IsValid() then
        return false
    end

    local weapon = GetOrCreateSpitWeapon(attacker, damage, range)
    if weapon == nil then
        return false
    end

    local projectile = SpawnPrefab("spider_web_spit")
    if projectile == nil or projectile.components == nil or projectile.components.projectile == nil then
        if projectile ~= nil and projectile:IsValid() then
            projectile:Remove()
        end
        return false
    end

    if projectile.components.weapon == nil then
        projectile:AddComponent("weapon")
    end
    projectile.components.weapon:SetDamage(damage)
    projectile.components.projectile:SetRange(range or 12)
    projectile.components.projectile:SetSpeed(20)
    projectile.components.projectile:SetHitDist(1.5)
    projectile.components.projectile:SetHoming(false)
    if weapon.projectiledelay ~= nil and projectile.components.projectile.DelayVisibility ~= nil then
        projectile.components.projectile:DelayVisibility(weapon.projectiledelay)
    end

    if projectile.Transform ~= nil and projectile_scale ~= nil then
        projectile.Transform:SetScale(projectile_scale, projectile_scale, projectile_scale)
    end

    local angle = attacker:GetAngleToPoint(target.Transform:GetWorldPosition())
    projectile.components.projectile:SetLaunchAngle(angle + (angle_offset or 0))
    projectile.Transform:SetPosition(attacker.Transform:GetWorldPosition())
    projectile.components.projectile:Throw(weapon, target, attacker)
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

local function IsOutsideNormalAttackRange(inst, target)
    if inst == nil or target == nil or not HasComponents(inst, "combat") then
        return false
    end

    local attack_range = inst.components.combat.attackrange or 0
    if type(attack_range) ~= "number" then
        attack_range = 0
    end

    return inst:GetDistanceSqToInst(target) > attack_range * attack_range
end

local function IsValidSkillTarget(inst, target)
    return IsValidBaseTarget(inst, target)
end

local function IsValidSkillCaster(inst)
    return inst ~= nil
        and inst:IsValid()
        and not inst:IsInLimbo()
        and HasComponents(inst, "health")
        and not inst.components.health:IsDead()
        and (inst.sg == nil or not inst.sg:HasStateTag("dead"))
end

local function CleanupMonsterSkillTasks(inst)
    if inst == nil then
        return
    end

    local task_keys = {
        "_hh_monster_skill_think_start_task",
        "_hh_monster_skill_think_task",
        "_hh_monster_skill_barrage_task",
        "_hh_monster_skill_pursuit_task",
        "_hh_monster_skill_trap_task",
        "_hh_monster_skill_bolt_task",
        "_hh_monster_skill_freeze_ring_task",
        "_hh_monster_skill_fire_ring_task",
        "_hh_monster_skill_flame_cone_task",
        "_hh_monster_skill_twin_laser_task",
        "_hh_monster_skill_twin_dash_task",
        "_hh_monster_skill_twin_hellfire_task",
    }

    for _, key in ipairs(task_keys) do
        local task = inst[key]
        if task ~= nil then
            task:Cancel()
            inst[key] = nil
        end
    end

    if inst._hh_monster_skill_doattack ~= nil then
        inst:RemoveEventCallback("doattack", inst._hh_monster_skill_doattack)
        inst._hh_monster_skill_doattack = nil
    end

    if inst._hh_monster_skill_onhit ~= nil then
        inst:RemoveEventCallback("onhitother", inst._hh_monster_skill_onhit)
        inst._hh_monster_skill_onhit = nil
    end
end

local function GetTrapTargets(inst, primary_target, params)
    local targets = {}
    local seen = {}

    local function TryAddTarget(candidate)
        if candidate == nil
            or seen[candidate] == true
            or not IsValidBaseTarget(inst, candidate)
            or not candidate:HasTag("player")
        then
            return
        end

        local dsq = inst:GetDistanceSqToInst(candidate)
        if dsq < params.min_range * params.min_range or dsq > params.max_range * params.max_range then
            return
        end

        seen[candidate] = true
        table.insert(targets, candidate)
    end

    TryAddTarget(primary_target)

    if AllPlayers ~= nil then
        for _, player in ipairs(AllPlayers) do
            TryAddTarget(player)
        end
    end

    return targets
end

local function AddTrapPointsForTarget(trap_points, target, count, spread)
    if target == nil or target.Transform == nil then
        return
    end

    local tx, ty, tz = target.Transform:GetWorldPosition()
    table.insert(trap_points, { x = tx, y = ty, z = tz })

    local extra_count = math.max((count or 1) - 1, 0)
    if extra_count <= 0 then
        return
    end

    for i = 1, extra_count do
        local angle = (2 * PI / extra_count) * (i - 1)
        table.insert(trap_points, {
            x = tx + math.cos(angle) * spread,
            y = ty,
            z = tz + math.sin(angle) * spread,
        })
    end
end

local function GetBoltStrikePoints(inst, target, count, spacing)
    local points = {}
    if inst == nil or target == nil or inst.Transform == nil or target.Transform == nil then
        return points
    end

    local tx, ty, tz = target.Transform:GetWorldPosition()
    local ix, iy, iz = inst.Transform:GetWorldPosition()
    local dx = tx - ix
    local dz = tz - iz
    local len = math.sqrt(dx * dx + dz * dz)

    local px, pz
    if len <= 0.001 then
        px, pz = 1, 0
    else
        px = -dz / len
        pz = dx / len
    end

    local total = math.max(count or 1, 1)
    local gap = spacing or 3
    local start = -(total - 1) / 2
    for i = 0, total - 1 do
        local offset = (start + i) * gap
        table.insert(points, Vector3(
            tx + px * offset,
            ty,
            tz + pz * offset
        ))
    end

    return points
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

local function SpawnTrapWarningFx(x, y, z, radius)
    if HH_UTILS ~= nil and HH_UTILS.SpawnIndicatorFx ~= nil then
        HH_UTILS:SpawnIndicatorFx(Vector3(x, y, z), 1.2, { 0.85, 0.25, 0.25, 1 }, math.max(radius * 0.42, 0.3))
    end
end

local function SpawnTimedIndicator(pos, remove_time, color, scale)
    if pos ~= nil and HH_UTILS ~= nil and HH_UTILS.SpawnIndicatorFx ~= nil then
        HH_UTILS:SpawnIndicatorFx(pos, remove_time or 1, color or { 1, 1, 1, 1 }, scale or 1)
    end
end

local function SpawnFreezeCircleAtPos(pos, duration)
    local spell = SpawnPrefab("deer_ice_circle")
    if spell == nil or spell.Transform == nil then
        if spell ~= nil and spell:IsValid() then
            spell:Remove()
        end
        return nil
    end

    spell.Transform:SetPosition(pos:Get())
    if spell.TriggerFX ~= nil then
        spell:TriggerFX()
    end
    if spell.KillFX ~= nil then
        spell:DoTaskInTime(duration or 6, spell.KillFX)
    end
    return spell
end

local function SpawnFireCircleAtPos(pos, duration)
    local spell = SpawnPrefab("deer_fire_circle")
    if spell == nil or spell.Transform == nil then
        if spell ~= nil and spell:IsValid() then
            spell:Remove()
        end
        return nil
    end

    spell.Transform:SetPosition(pos:Get())
    if spell.TriggerFX ~= nil then
        spell:TriggerFX()
    end
    if spell.KillFX ~= nil then
        spell:DoTaskInTime(duration or 4, spell.KillFX)
    end
    return spell
end

local function AngleDiffDeg(a, b)
    local diff = a - b
    while diff > 180 do
        diff = diff - 360
    end
    while diff < -180 do
        diff = diff + 360
    end
    return diff
end

local function SpawnFlameConeFx(attacker, offset_angle, dist, scale)
    local fx = SpawnPrefab("warg_mutated_breath_fx")
    if fx == nil or fx.Transform == nil then
        if fx ~= nil and fx:IsValid() then
            fx:Remove()
        end
        return
    end

    if fx.SetFXOwner ~= nil then
        fx:SetFXOwner(attacker)
    end

    local x, y, z = attacker.Transform:GetWorldPosition()
    local angle = (attacker.Transform:GetRotation() + offset_angle) * DEGREES
    x = x + math.cos(angle) * dist
    z = z - math.sin(angle) * dist
    fx.Transform:SetPosition(x, 0, z)

    if fx.RestartFX ~= nil then
        fx:RestartFX(scale or 1.4, "nofade")
    end
    if fx.KillFX ~= nil then
        fx:DoTaskInTime(math.random(18, 22) * FRAMES, fx.KillFX)
    end
end

local function SpawnTwinHellfireFx(attacker, offset_angle, dist, scale)
    local fx = SpawnPrefab("eyeflame")
    if fx == nil or fx.Transform == nil then
        if fx ~= nil and fx:IsValid() then
            fx:Remove()
        end
        return
    end

    local x, y, z = attacker.Transform:GetWorldPosition()
    local angle = (attacker.Transform:GetRotation() + offset_angle) * DEGREES
    x = x + math.cos(angle) * dist
    z = z - math.sin(angle) * dist
    fx.Transform:SetPosition(x, 0, z)
    if fx.Transform ~= nil then
        local s = scale or 1.1
        fx.Transform:SetScale(s, s, s)
    end
    fx:DoTaskInTime(0.42, fx.Remove)
end

local function SpawnFlameConeWarning(attacker, fixed_rotation, params, remove_time)
    if not IsValidSkillCaster(attacker) then
        return
    end

    local x, y, z = attacker.Transform:GetWorldPosition()
    local warning_angles = {
        -(params.half_angle or 30),
        -(params.half_angle or 30) * 0.5,
        0,
        (params.half_angle or 30) * 0.5,
        (params.half_angle or 30),
    }
    local warning_dists = {
        (params.reach or 8) * 0.35,
        (params.reach or 8) * 0.58,
        (params.reach or 8) * 0.82,
    }

    for _, dist in ipairs(warning_dists) do
        for _, offset in ipairs(warning_angles) do
            local angle = (fixed_rotation + offset) * DEGREES
            local pos = Vector3(
                x + math.cos(angle) * dist,
                0,
                z - math.sin(angle) * dist
            )
            SpawnTimedIndicator(pos, remove_time, { 1, 0.32, 0.08, 1 }, math.max((params.reach or 8) / 10, 0.9))
        end
    end
end

local function SpawnLineWarning(attacker, fixed_rotation, reach, remove_time, color, scale, step)
    if not IsValidSkillCaster(attacker) then
        return
    end

    local x, y, z = attacker.Transform:GetWorldPosition()
    local gap = step or 1.25
    local dist = gap
    while dist <= reach do
        local angle = fixed_rotation * DEGREES
        local pos = Vector3(
            x + math.cos(angle) * dist,
            0,
            z - math.sin(angle) * dist
        )
        SpawnTimedIndicator(pos, remove_time, color or { 1, 0.2, 0.2, 1 }, scale or 0.9)
        dist = dist + gap
    end
end

local function SpawnTwinLaserAtPos(attacker, x, z, damage_mult, scale, targets)
    local laser = SpawnPrefab("alterguardian_laser")
    if laser == nil or laser.Transform == nil or laser.Trigger == nil then
        if laser ~= nil and laser:IsValid() then
            laser:Remove()
        end
        return
    end

    laser.Transform:SetPosition(x, 0, z)
    laser.caster = attacker
    laser.overridedmg = GetSkillDamage(attacker, damage_mult)
    laser.overridepdp = 1

    local skip_targets = targets or {}
    for _, ent in ipairs(TheSim:FindEntities(x, 0, z, 4, nil, nil, { "structure", "wall" })) do
        skip_targets[ent] = true
    end

    laser:Trigger(0, skip_targets, {}, true, scale or 1, scale or 1, scale or 1)
end

local function DoTwinLaserShot(attacker, params, fixed_rotation)
    if not IsValidSkillCaster(attacker) then
        return
    end

    local x, y, z = attacker.Transform:GetWorldPosition()
    local theta = fixed_rotation * DEGREES
    local shared_targets = {}
    local dist = 1
    while dist <= (params.reach or 16) do
        local px = x + math.cos(theta) * dist
        local pz = z - math.sin(theta) * dist
        SpawnTwinLaserAtPos(attacker, px, pz, params.damage_mult, params.scale, shared_targets)
        dist = dist + (params.step or 1.25)
    end
end

local function StartTwinDashSequence(attacker, target, params, remaining)
    if not IsValidSkillCaster(attacker) or remaining <= 0 then
        return
    end
    if target == nil or not target:IsValid() then
        return
    end

    local tx, ty, tz = target.Transform:GetWorldPosition()
    local target_point = { x = tx, z = tz }
    attacker:FacePoint(tx, ty, tz)

    attacker.components.locomotor:Stop()
    attacker.components.locomotor:EnableGroundSpeedMultiplier(false)

    local hit_targets = {}
    local dash_task = attacker:DoPeriodicTask(0.05, function(runner)
        local ix, iy, iz = runner.Transform:GetWorldPosition()
        local dx = target_point.x - ix
        local dz = target_point.z - iz
        local len = math.sqrt(dx * dx + dz * dz)
        if len <= 0.001 then
            return
        end

        local move = math.min(params.speed * 0.05, len)
        if move <= 0 then
            return
        end

        local nx = ix + dx / len * move
        local nz = iz + dz / len * move

        if runner.Physics ~= nil then
            runner.Physics:Teleport(nx, 0, nz)
        else
            runner.Transform:SetPosition(nx, 0, nz)
        end
        runner:FacePoint(target_point.x, 0, target_point.z)

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

    attacker:DoTaskInTime(params.dash_duration, function(runner)
        if dash_task ~= nil then
            dash_task:Cancel()
        end
        if IsValidSkillCaster(runner) then
            runner.components.locomotor:EnableGroundSpeedMultiplier(true)
            ClearVelocityOverride(runner)
            if remaining > 1 then
                runner:DoTaskInTime(params.dash_gap, function(next_runner)
                    StartTwinDashSequence(next_runner, target, params, remaining - 1)
                end)
            end
        end
    end)
end

local function DoFlameConeTick(attacker, params, fixed_rotation, hit_targets)
    if not IsValidSkillCaster(attacker) or not HasComponents(attacker, "combat") then
        return
    end

    local x, y, z = attacker.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, (params.reach or 8) + 2, SKILL_TARGET_MUST_TAGS, SKILL_TARGET_CANT_TAGS, SKILL_TARGET_ONEOF_TAGS)
    local now = GetTime()
    for _, ent in ipairs(ents) do
        if ent ~= attacker and IsValidSkillTarget(attacker, ent) then
            local dist_sq = ent:GetDistanceSqToPoint(x, 0, z)
            if dist_sq <= (params.reach or 8) * (params.reach or 8) then
                local angle_to = attacker:GetAngleToPoint(ent.Transform:GetWorldPosition())
                local diff = math.abs(AngleDiffDeg(angle_to, fixed_rotation))
                if diff <= (params.half_angle or 30) then
                    local last_hit = hit_targets[ent]
                    if last_hit == nil or now - last_hit >= math.max((params.tick or 0.15) * 0.9, 0.1) then
                        hit_targets[ent] = now
                        ApplySkillDamage(attacker, ent, GetSkillDamage(attacker, params.damage_mult))
                        if ent.components.health ~= nil then
                            ent.components.health:DoFireDamage(params.fire_damage or 0, attacker, true)
                        end
                        if ent.components.burnable ~= nil and not ent.components.burnable:IsBurning() and math.random() <= (params.ignite_chance or 0.4) then
                            ent.components.burnable:Ignite(true, attacker, attacker)
                        end
                    end
                end
            end
        end
    end

    local fx_angles = { -params.half_angle, -(params.half_angle or 30) * 0.45, 0, (params.half_angle or 30) * 0.45, params.half_angle }
    local fx_dists = { (params.reach or 8) * 0.45, (params.reach or 8) * 0.62, (params.reach or 8) * 0.78 }
    for _, dist in ipairs(fx_dists) do
        for _, offset in ipairs(fx_angles) do
            SpawnFlameConeFx(attacker, offset, dist, 1.15 + dist / math.max(params.reach or 8, 1) * 0.45)
        end
    end
end

local function DoTwinHellfireTick(attacker, params, fixed_rotation, hit_targets)
    if attacker == nil or not attacker:IsValid() or not HasComponents(attacker, "combat") then
        return
    end

    local x, y, z = attacker.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, (params.reach or 8) + 2, SKILL_TARGET_MUST_TAGS, SKILL_TARGET_CANT_TAGS, SKILL_TARGET_ONEOF_TAGS)
    local now = GetTime()
    for _, ent in ipairs(ents) do
        if ent ~= attacker and IsValidSkillTarget(attacker, ent) then
            local dist_sq = ent:GetDistanceSqToPoint(x, 0, z)
            if dist_sq <= (params.reach or 8) * (params.reach or 8) then
                local angle_to = attacker:GetAngleToPoint(ent.Transform:GetWorldPosition())
                local diff = math.abs(AngleDiffDeg(angle_to, fixed_rotation))
                if diff <= (params.half_angle or 30) then
                    local last_hit = hit_targets[ent]
                    if last_hit == nil or now - last_hit >= math.max((params.tick or 0.15) * 0.9, 0.05) then
                        hit_targets[ent] = now
                        ApplySkillDamage(attacker, ent, GetSkillDamage(attacker, params.damage_mult))
                        if ent.components.health ~= nil then
                            ent.components.health:DoFireDamage(params.fire_damage or 0, attacker, true)
                        end
                        if ent.components.burnable ~= nil and not ent.components.burnable:IsBurning() and math.random() <= (params.ignite_chance or 0.4) then
                            ent.components.burnable:Ignite(true, attacker, attacker)
                        end
                    end
                end
            end
        end
    end

    local fx_angles = { -(params.half_angle or 30), -(params.half_angle or 30) * 0.55, -(params.half_angle or 30) * 0.2, 0, (params.half_angle or 30) * 0.2, (params.half_angle or 30) * 0.55, (params.half_angle or 30) }
    local fx_dists = { (params.reach or 8) * 0.3, (params.reach or 8) * 0.5, (params.reach or 8) * 0.7, (params.reach or 8) * 0.88 }
    for _, dist in ipairs(fx_dists) do
        for _, offset in ipairs(fx_angles) do
            SpawnTwinHellfireFx(attacker, offset, dist, 0.85 + dist / math.max(params.reach or 8, 1) * 0.55)
        end
    end
end

local function SpawnTrapRiseFx(x, y, z, radius)
    return nil
end

local function SpawnTrapSpikeVisualFx(x, y, z, radius)
    local spike_fx = SpawnPrefab("deerclops_icespike_fx")
    if spike_fx ~= nil and spike_fx.Transform ~= nil then
        spike_fx.Transform:SetPosition(x, y, z)
        local scale = math.max(radius / 2.1, 0.95)
        spike_fx.Transform:SetScale(scale, scale, scale)
        if spike_fx.RestartFX ~= nil then
            spike_fx:RestartFX(radius >= 2.8, math.random(4))
        end
    end
    return spike_fx
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

local function StepTowardsTarget(inst, target, step_distance)
    if inst == nil or target == nil or not target:IsValid() or inst.Transform == nil then
        return false
    end

    local tx, ty, tz = target.Transform:GetWorldPosition()
    local ix, iy, iz = inst.Transform:GetWorldPosition()
    local dx = tx - ix
    local dz = tz - iz
    local len = math.sqrt(dx * dx + dz * dz)
    if len <= 0.001 then
        return false
    end

    local move = math.min(step_distance or 0, len)
    if move <= 0 then
        return false
    end

    local nx = ix + dx / len * move
    local nz = iz + dz / len * move

    if inst.Physics ~= nil then
        inst.Physics:Teleport(nx, 0, nz)
    else
        inst.Transform:SetPosition(nx, 0, nz)
    end
    FaceTarget(inst, target)
    return true
end

local function StepTowardsPoint(inst, point, step_distance)
    if inst == nil or point == nil or inst.Transform == nil then
        return false
    end

    local ix, iy, iz = inst.Transform:GetWorldPosition()
    local dx = point.x - ix
    local dz = point.z - iz
    local len = math.sqrt(dx * dx + dz * dz)
    if len <= 0.001 then
        return false
    end

    local move = math.min(step_distance or 0, len)
    if move <= 0 then
        return false
    end

    local nx = ix + dx / len * move
    local nz = iz + dz / len * move

    if inst.Physics ~= nil then
        inst.Physics:Teleport(nx, 0, nz)
    else
        inst.Transform:SetPosition(nx, 0, nz)
    end
    inst:FacePoint(point.x, 0, point.z)
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
    if IsBarrageCandidate(inst) then
        inst:AddTag(BARRAGE_CANDIDATE_TAG)
    end
    if IsTrapCandidate(inst) then
        inst:AddTag(TRAP_CANDIDATE_TAG)
    end
    if IsBoltCandidate(inst) then
        inst:AddTag(BOLT_CANDIDATE_TAG)
    end
    if IsFreezeRingCandidate(inst) then
        inst:AddTag(FREEZE_RING_CANDIDATE_TAG)
    end
    if IsFireRingCandidate(inst) then
        inst:AddTag(FIRE_RING_CANDIDATE_TAG)
    end
    if IsFlameConeCandidate(inst) then
        inst:AddTag(FLAME_CONE_CANDIDATE_TAG)
    end
    if IsTwinLaserCandidate(inst) then
        inst:AddTag(TWIN_LASER_CANDIDATE_TAG)
    end
    if IsTwinDashCandidate(inst) then
        inst:AddTag(TWIN_DASH_CANDIDATE_TAG)
    end
    if IsTwinHellfireCandidate(inst) then
        inst:AddTag(TWIN_HELLFIRE_CANDIDATE_TAG)
    end
end

AddPrefabPostInitAny(function(inst)
    if TheWorld ~= nil and not TheWorld.ismastersim then
        return
    end
    MarkSkillCandidate(inst)
    if inst._hh_monster_skill_cleanup_on_death == nil then
        inst._hh_monster_skill_cleanup_on_death = function(monster)
            CleanupMonsterSkillTasks(monster)
        end
        inst:ListenForEvent("death", inst._hh_monster_skill_cleanup_on_death)
        inst:ListenForEvent("onremove", inst._hh_monster_skill_cleanup_on_death)
    end
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

    inst.hh_skill_spit_cd = GetTime() + GetSkillCooldown(params, inst)
    SpawnSkillText(inst, "喷吐")
    SpawnSkillIndicator(target:GetPosition(), 1.2, { 0.35, 0.85, 0.35, 1 })

    local captured_target = target
    inst:DoTaskInTime(params.windup, function(attacker)
        if not IsValidSkillCaster(attacker) or not HasComponents(attacker, "combat") or IsHardBlockedForSkill(attacker) then
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

local function TryUseBarrageSkill(self, target)
    local inst = self.inst
    if not ENABLE_BARRAGE_SKILL
        or inst == nil
        or not inst:HasTag(BARRAGE_CANDIDATE_TAG)
        or self:GetEffectValueByKey(BARRAGE_EFFECT_KEY) <= 0
    then
        return false
    end

    local params = BARRAGE_PARAMS[GetMonsterTier(inst)]
    if params == nil or inst.hh_skill_barrage_cd ~= nil and inst.hh_skill_barrage_cd > GetTime() then
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

    inst.hh_skill_barrage_cd = GetTime() + GetSkillCooldown(params, inst)
    SpawnSkillText(inst, "弹幕")
    SpawnSkillIndicator(target:GetPosition(), 1.35, { 1, 0.6, 0.2, 1 })

    local captured_target = target
    local angle_offsets = GetAngleOffsets(params.count, params.spread_angle or 10)
    for i = 1, params.count do
        inst:DoTaskInTime((i - 1) * params.interval, function(attacker)
            if not IsValidSkillCaster(attacker) or not HasComponents(attacker, "combat") then
                return
            end
            if not IsValidSpitTarget(attacker, captured_target) then
                return
            end
            attacker:FacePoint(captured_target.Transform:GetWorldPosition())
            LaunchBarrageProjectile(
                attacker,
                captured_target,
                GetSkillDamage(attacker, params.damage_mult),
                params.travel_range or (params.max_range + 2),
                angle_offsets[i] or 0,
                params.projectile_scale or 1
            )
        end)
    end

    return true
end

local function TryUseBarrageByAggro(self, target)
    local inst = self ~= nil and self.inst or nil
    if inst == nil
        or TheWorld == nil
        or not TheWorld.ismastersim
        or IsHardBlockedForSkill(inst)
    then
        return false
    end

    target = target or (HasComponents(inst, "combat") and inst.components.combat.target or nil)
    if not IsValidSpitTarget(inst, target) then
        return false
    end

    if not IsOutsideNormalAttackRange(inst, target) then
        return false
    end

    return TryUseBarrageSkill(self, target)
end

local function TryUseTrapSkill(self, target)
    local inst = self.inst
    if not ENABLE_TRAP_SKILL
        or inst == nil
        or not inst:HasTag(TRAP_CANDIDATE_TAG)
        or self:GetEffectValueByKey(TRAP_EFFECT_KEY) <= 0
    then
        return false
    end

    local params = TRAP_PARAMS[GetMonsterTier(inst)]
    if params == nil or inst.hh_skill_trap_cd ~= nil and inst.hh_skill_trap_cd > GetTime() then
        return false
    end

    if not IsValidBaseTarget(inst, target) or not target:HasTag("player") then
        return false
    end

    local dsq = inst:GetDistanceSqToInst(target)
    if dsq < params.min_range * params.min_range or dsq > params.max_range * params.max_range then
        return false
    end

    if math.random() > params.proc then
        return false
    end

    inst.hh_skill_trap_cd = GetTime() + GetSkillCooldown(params, inst)

    local trap_targets = GetTrapTargets(inst, target, params)
    if #trap_targets <= 0 then
        return false
    end

    SpawnSkillText(inst, "地刺")
    local trap_points = {}

    for _, trap_target in ipairs(trap_targets) do
        AddTrapPointsForTarget(trap_points, trap_target, params.count, params.spread)
    end

    for _, trap_point in ipairs(trap_points) do
        SpawnTrapWarningFx(trap_point.x, trap_point.y, trap_point.z, params.radius)
    end

    inst:DoTaskInTime(params.delay, function(attacker)
        if not IsValidSkillCaster(attacker) or not HasComponents(attacker, "combat") then
            return
        end

        for _, trap_point in ipairs(trap_points) do
            SpawnTrapSpikeVisualFx(trap_point.x, trap_point.y, trap_point.z, params.radius)

            local ents = TheSim:FindEntities(trap_point.x, trap_point.y, trap_point.z, params.radius, SKILL_TARGET_MUST_TAGS, SKILL_TARGET_CANT_TAGS, SKILL_TARGET_ONEOF_TAGS)
            for _, ent in ipairs(ents) do
                if ent ~= attacker and IsValidSkillTarget(attacker, ent) then
                    ApplySkillDamage(attacker, ent, GetSkillDamage(attacker, params.damage_mult))
                end
            end
        end
    end)

    return true
end

local function TryUseBoltSkill(self, target)
    local inst = self.inst
    if not ENABLE_BOLT_SKILL
        or inst == nil
        or not inst:HasTag(BOLT_CANDIDATE_TAG)
        or self:GetEffectValueByKey(BOLT_EFFECT_KEY) <= 0
    then
        return false
    end

    local params = BOLT_PARAMS[GetMonsterTier(inst)]
    if params == nil or inst.hh_skill_bolt_cd ~= nil and inst.hh_skill_bolt_cd > GetTime() then
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

    local bolt_targets = GetTrapTargets(inst, target, params)
    if #bolt_targets <= 0 then
        return false
    end

    inst.hh_skill_bolt_cd = GetTime() + GetSkillCooldown(params, inst)
    SpawnSkillText(inst, "落雷")

    for _, bolt_target in ipairs(bolt_targets) do
        local strike_target = bolt_target
        local strike_points = GetBoltStrikePoints(inst, bolt_target, params.count, params.line_spacing)

        for _, strike_pos in ipairs(strike_points) do
            if HH_UTILS ~= nil and HH_UTILS.SpawnIndicatorFx ~= nil then
                HH_UTILS:SpawnIndicatorFx(strike_pos, params.delay, { 0.55, 0.85, 1, 1 }, params.warning_scale or 1)
            end

            inst:DoTaskInTime(params.delay, function(attacker)
                if not IsValidSkillCaster(attacker) or TheWorld == nil then
                    return
                end

                TheWorld:PushEvent("ms_sendlightningstrike", strike_pos)

                if strike_target ~= nil
                    and strike_target:IsValid()
                    and IsValidSkillTarget(attacker, strike_target)
                    and strike_target:GetDistanceSqToPoint(strike_pos:Get()) <= (params.hit_radius or 2) * (params.hit_radius or 2)
                then
                    if strike_target.components.health ~= nil then
                        strike_target.components.health:DoFireDamage(params.fire_damage or 0, attacker, true)
                    end
                    if strike_target.components.burnable ~= nil and not strike_target.components.burnable:IsBurning() then
                        strike_target.components.burnable:Ignite(true, attacker, attacker)
                    end
                end
            end)
        end
    end

    return true
end

local function TryUseBoltByAggro(self, target)
    local inst = self ~= nil and self.inst or nil
    if inst == nil
        or TheWorld == nil
        or not TheWorld.ismastersim
        or IsHardBlockedForSkill(inst)
    then
        return false
    end

    target = target or (HasComponents(inst, "combat") and inst.components.combat.target or nil)
    if not IsValidSpitTarget(inst, target) then
        return false
    end

    if not IsOutsideNormalAttackRange(inst, target) then
        return false
    end

    return TryUseBoltSkill(self, target)
end

local function TryUseFreezeRingSkill(self, target)
    local inst = self.inst
    if not ENABLE_FREEZE_RING_SKILL
        or inst == nil
        or not inst:HasTag(FREEZE_RING_CANDIDATE_TAG)
        or self:GetEffectValueByKey(FREEZE_RING_EFFECT_KEY) <= 0
    then
        return false
    end

    local params = FREEZE_RING_PARAMS[GetMonsterTier(inst)]
    if params == nil or inst.hh_skill_freeze_ring_cd ~= nil and inst.hh_skill_freeze_ring_cd > GetTime() then
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

    inst.hh_skill_freeze_ring_cd = GetTime() + GetSkillCooldown(params, inst)
    SpawnSkillText(inst, "冰环")

    local freeze_targets = GetTrapTargets(inst, target, params)
    if #freeze_targets <= 0 then
        return false
    end

    for _, freeze_target in ipairs(freeze_targets) do
        local strike_pos = freeze_target:GetPosition()
        SpawnTimedIndicator(strike_pos, params.delay, { 0.55, 0.85, 1, 1 }, params.warning_scale or 1)

        inst:DoTaskInTime(params.delay, function(attacker)
            if not IsValidSkillCaster(attacker) then
                return
            end
            SpawnFreezeCircleAtPos(strike_pos, params.duration)
        end)
    end

    return true
end

local function TryUseFreezeRingByAggro(self, target)
    local inst = self ~= nil and self.inst or nil
    if inst == nil
        or TheWorld == nil
        or not TheWorld.ismastersim
        or IsHardBlockedForSkill(inst)
    then
        return false
    end

    target = target or (HasComponents(inst, "combat") and inst.components.combat.target or nil)
    if not IsValidSpitTarget(inst, target) then
        return false
    end

    if not IsOutsideNormalAttackRange(inst, target) then
        return false
    end

    return TryUseFreezeRingSkill(self, target)
end

local function TryUseFireRingSkill(self, target)
    local inst = self.inst
    if not ENABLE_FIRE_RING_SKILL
        or inst == nil
        or not inst:HasTag(FIRE_RING_CANDIDATE_TAG)
        or self:GetEffectValueByKey(FIRE_RING_EFFECT_KEY) <= 0
    then
        return false
    end

    local params = FIRE_RING_PARAMS[GetMonsterTier(inst)]
    if params == nil or inst.hh_skill_fire_ring_cd ~= nil and inst.hh_skill_fire_ring_cd > GetTime() then
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

    inst.hh_skill_fire_ring_cd = GetTime() + GetSkillCooldown(params, inst)
    SpawnSkillText(inst, "火阵")

    local fire_targets = GetTrapTargets(inst, target, params)
    if #fire_targets <= 0 then
        return false
    end

    for _, fire_target in ipairs(fire_targets) do
        local strike_pos = fire_target:GetPosition()
        SpawnTimedIndicator(strike_pos, params.delay, { 1, 0.45, 0.15, 1 }, params.warning_scale or 1)

        inst:DoTaskInTime(params.delay, function(attacker)
            if not IsValidSkillCaster(attacker) then
                return
            end
            SpawnFireCircleAtPos(strike_pos, params.duration)
        end)
    end

    return true
end

local function TryUseFireRingByAggro(self, target)
    local inst = self ~= nil and self.inst or nil
    if inst == nil
        or TheWorld == nil
        or not TheWorld.ismastersim
        or IsHardBlockedForSkill(inst)
    then
        return false
    end

    target = target or (HasComponents(inst, "combat") and inst.components.combat.target or nil)
    if not IsValidSpitTarget(inst, target) then
        return false
    end

    if not IsOutsideNormalAttackRange(inst, target) then
        return false
    end

    return TryUseFireRingSkill(self, target)
end

local function TryUseFlameConeSkill(self, target)
    local inst = self.inst
    if not ENABLE_FLAME_CONE_SKILL
        or inst == nil
        or not inst:HasTag(FLAME_CONE_CANDIDATE_TAG)
        or self:GetEffectValueByKey(FLAME_CONE_EFFECT_KEY) <= 0
    then
        return false
    end

    local params = FLAME_CONE_PARAMS[GetMonsterTier(inst)]
    if params == nil or inst.hh_skill_flame_cone_cd ~= nil and inst.hh_skill_flame_cone_cd > GetTime() then
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

    inst.hh_skill_flame_cone_cd = GetTime() + GetSkillCooldown(params, inst)
    SpawnSkillText(inst, "喷火")

    local tx, ty, tz = target.Transform:GetWorldPosition()
    local fixed_rotation = inst:GetAngleToPoint(tx, ty, tz)
    inst:FacePoint(tx, ty, tz)
    SpawnFlameConeWarning(inst, fixed_rotation, params, params.windup)

    inst:DoTaskInTime(params.windup, function(attacker)
        if not IsValidSkillCaster(attacker) or not HasComponents(attacker, "combat") then
            return
        end

        attacker:FacePoint(tx, ty, tz)
        local hit_targets = {}
        DoFlameConeTick(attacker, params, fixed_rotation, hit_targets)

        local flame_task
        flame_task = attacker:DoPeriodicTask(params.tick, function(flame_attacker)
            if not IsValidSkillCaster(flame_attacker) then
                if flame_task ~= nil then
                    flame_task:Cancel()
                end
                return
            end
            DoFlameConeTick(flame_attacker, params, fixed_rotation, hit_targets)
        end)

        attacker:DoTaskInTime(params.duration, function(flame_attacker)
            if flame_task ~= nil then
                flame_task:Cancel()
            end
        end)
    end)

    return true
end

local function TryUseFlameConeByAggro(self, target)
    local inst = self ~= nil and self.inst or nil
    if inst == nil
        or TheWorld == nil
        or not TheWorld.ismastersim
        or IsHardBlockedForSkill(inst)
    then
        return false
    end

    target = target or (HasComponents(inst, "combat") and inst.components.combat.target or nil)
    if not IsValidSpitTarget(inst, target) then
        return false
    end

    return TryUseFlameConeSkill(self, target)
end

local function TryUseTwinLaserSkill(self, target)
    local inst = self.inst
    if not ENABLE_TWIN_LASER_SKILL
        or inst == nil
        or not inst:HasTag(TWIN_LASER_CANDIDATE_TAG)
        or self:GetEffectValueByKey(TWIN_LASER_EFFECT_KEY) <= 0
    then
        return false
    end

    local params = TWIN_LASER_PARAMS[GetMonsterTier(inst)]
    if params == nil or inst.hh_skill_twin_laser_cd ~= nil and inst.hh_skill_twin_laser_cd > GetTime() then
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

    inst.hh_skill_twin_laser_cd = GetTime() + GetSkillCooldown(params, inst)
    SpawnSkillText(inst, "激光炮")

    local tx, ty, tz = target.Transform:GetWorldPosition()
    local fixed_rotation = inst:GetAngleToPoint(tx, ty, tz)
    SpawnLineWarning(inst, fixed_rotation, params.reach, params.windup, { 1, 0.15, 0.15, 1 }, 0.95, params.step)
    inst:FacePoint(tx, ty, tz)

    inst:DoTaskInTime(params.windup, function(attacker)
        if not IsValidSkillCaster(attacker) then
            return
        end
        attacker:FacePoint(tx, ty, tz)
        DoTwinLaserShot(attacker, params, fixed_rotation)
    end)

    return true
end

local function TryUseTwinLaserByAggro(self, target)
    local inst = self ~= nil and self.inst or nil
    if inst == nil or TheWorld == nil or not TheWorld.ismastersim or IsHardBlockedForSkill(inst) then
        return false
    end

    target = target or (HasComponents(inst, "combat") and inst.components.combat.target or nil)
    if not IsValidSpitTarget(inst, target) then
        return false
    end

    if not IsOutsideNormalAttackRange(inst, target) then
        return false
    end

    return TryUseTwinLaserSkill(self, target)
end

local function TryUseTwinDashSkill(self, target)
    local inst = self.inst
    if not ENABLE_TWIN_DASH_SKILL
        or inst == nil
        or not inst:HasTag(TWIN_DASH_CANDIDATE_TAG)
        or self:GetEffectValueByKey(TWIN_DASH_EFFECT_KEY) <= 0
    then
        return false
    end

    local params = TWIN_DASH_PARAMS[GetMonsterTier(inst)]
    if params == nil or inst.hh_skill_twin_dash_cd ~= nil and inst.hh_skill_twin_dash_cd > GetTime() then
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

    inst.hh_skill_twin_dash_cd = GetTime() + GetSkillCooldown(params, inst)
    SpawnSkillText(inst, "五连冲撞")
    SpawnTimedIndicator(target:GetPosition(), params.windup, { 1, 0.4, 0.2, 1 }, 1.25)

    local captured_target = target
    inst:DoTaskInTime(params.windup, function(attacker)
        if not IsValidSkillCaster(attacker) or not HasComponents(attacker, "combat", "locomotor") then
            return
        end
        StartTwinDashSequence(attacker, captured_target, params, params.count)
    end)

    return true
end

local function TryUseTwinDashByAggro(self, target)
    local inst = self ~= nil and self.inst or nil
    if inst == nil or TheWorld == nil or not TheWorld.ismastersim or IsHardBlockedForSkill(inst) then
        return false
    end

    target = target or (HasComponents(inst, "combat") and inst.components.combat.target or nil)
    if not IsValidSpitTarget(inst, target) then
        return false
    end

    return TryUseTwinDashSkill(self, target)
end

local function TryUseTwinHellfireSkill(self, target)
    local inst = self.inst
    if not ENABLE_TWIN_HELLFIRE_SKILL
        or inst == nil
        or not inst:HasTag(TWIN_HELLFIRE_CANDIDATE_TAG)
        or self:GetEffectValueByKey(TWIN_HELLFIRE_EFFECT_KEY) <= 0
    then
        return false
    end

    local params = TWIN_HELLFIRE_PARAMS[GetMonsterTier(inst)]
    if params == nil or inst.hh_skill_twin_hellfire_cd ~= nil and inst.hh_skill_twin_hellfire_cd > GetTime() then
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

    inst.hh_skill_twin_hellfire_cd = GetTime() + GetSkillCooldown(params, inst)
    SpawnSkillText(inst, "魔焰")

    local tx, ty, tz = target.Transform:GetWorldPosition()
    local fixed_rotation = inst:GetAngleToPoint(tx, ty, tz)
    inst:FacePoint(tx, ty, tz)
    SpawnFlameConeWarning(inst, fixed_rotation, params, params.windup)

    inst:DoTaskInTime(params.windup, function(attacker)
        if not IsValidSkillCaster(attacker) or not HasComponents(attacker, "combat") then
            return
        end

        attacker:FacePoint(tx, ty, tz)
        local hit_targets = {}
        DoTwinHellfireTick(attacker, params, fixed_rotation, hit_targets)

        local flame_task
        flame_task = attacker:DoPeriodicTask(params.tick, function(flame_attacker)
            if not IsValidSkillCaster(flame_attacker) then
                if flame_task ~= nil then
                    flame_task:Cancel()
                end
                return
            end
            DoTwinHellfireTick(flame_attacker, params, fixed_rotation, hit_targets)
        end)

        attacker:DoTaskInTime(params.duration, function(flame_attacker)
            if flame_task ~= nil then
                flame_task:Cancel()
            end
        end)
    end)

    return true
end

local function TryUseTwinHellfireByAggro(self, target)
    local inst = self ~= nil and self.inst or nil
    if inst == nil or TheWorld == nil or not TheWorld.ismastersim or IsHardBlockedForSkill(inst) then
        return false
    end

    target = target or (HasComponents(inst, "combat") and inst.components.combat.target or nil)
    if not IsValidSpitTarget(inst, target) then
        return false
    end

    return TryUseTwinHellfireSkill(self, target)
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

    inst.hh_skill_shockwave_cd = GetTime() + GetSkillCooldown(params, inst)
    SpawnSkillText(inst, "震击")
    SpawnSkillIndicator(inst:GetPosition(), math.max(params.radius / 3, 1), { 1, 0.75, 0.35, 1 })

    inst:DoTaskInTime(params.windup, function(attacker)
        if not IsValidSkillCaster(attacker) or not HasComponents(attacker, "combat") then
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

    inst.hh_skill_charge_cd = GetTime() + GetSkillCooldown(params, inst)
    SpawnSkillText(inst, "冲撞")
    SpawnSkillIndicator(target:GetPosition(), 1.4, { 1, 0.45, 0.2, 1 })

    local captured_target = target
    inst:DoTaskInTime(params.windup, function(attacker)
        if not IsValidSkillCaster(attacker) or not HasComponents(attacker, "combat") or attacker.Physics == nil then
            return
        end
        if not IsValidSkillTarget(attacker, captured_target) then
            return
        end

        local tx, ty, tz = captured_target.Transform:GetWorldPosition()
        local target_point = { x = tx, z = tz }

        attacker.components.locomotor:Stop()
        attacker.components.locomotor:EnableGroundSpeedMultiplier(false)
        SpawnGroundTrailFx(attacker)

        local hit_targets = {}
        local dash_task = attacker:DoPeriodicTask(0.05, function(runner)
            if not StepTowardsPoint(runner, target_point, params.speed * 0.05) then
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
            if IsValidSkillCaster(runner) then
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

    inst.hh_skill_pounce_cd = GetTime() + GetSkillCooldown(params, inst)
    SpawnSkillText(inst, "飞扑")
    SpawnSkillIndicator(target:GetPosition(), 1.25, { 0.8, 0.95, 1, 1 })

    local captured_target = target
    inst:DoTaskInTime(params.windup, function(attacker)
        if not IsValidSkillCaster(attacker) or attacker.Physics == nil or not HasComponents(attacker, "locomotor") then
            return
        end
        if not IsValidSkillTarget(attacker, captured_target) then
            return
        end

        local tx, ty, tz = captured_target.Transform:GetWorldPosition()
        local target_point = { x = tx, z = tz }

        attacker.components.locomotor:Stop()
        attacker.components.locomotor:EnableGroundSpeedMultiplier(false)

        local jump_task = attacker:DoPeriodicTask(0.05, function(runner)
            if not StepTowardsPoint(runner, target_point, params.speed * 0.05) then
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
        or not IsValidSkillCaster(inst)
        or IsHardBlockedForSkill(inst)
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
        or not IsValidSkillCaster(inst)
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

local function HasEnabledThinkSkills()
    return ENABLE_BARRAGE_SKILL
        or ENABLE_CHARGE_SKILL
        or ENABLE_POUNCE_SKILL
        or ENABLE_TRAP_SKILL
        or ENABLE_BOLT_SKILL
        or ENABLE_FREEZE_RING_SKILL
        or ENABLE_FIRE_RING_SKILL
        or ENABLE_FLAME_CONE_SKILL
        or ENABLE_TWIN_LASER_SKILL
        or ENABLE_TWIN_DASH_SKILL
        or ENABLE_TWIN_HELLFIRE_SKILL
end

local function HasAnyThinkSkillEffect(self)
    if self == nil or self.GetEffectValueByKey == nil then
        return false
    end

    return (ENABLE_BARRAGE_SKILL and self:GetEffectValueByKey(BARRAGE_EFFECT_KEY) > 0)
        or ((ENABLE_CHARGE_SKILL or ENABLE_POUNCE_SKILL) and (
            self:GetEffectValueByKey(CHARGE_EFFECT_KEY) > 0
            or self:GetEffectValueByKey(POUNCE_EFFECT_KEY) > 0
        ))
        or (ENABLE_TRAP_SKILL and self:GetEffectValueByKey(TRAP_EFFECT_KEY) > 0)
        or (ENABLE_BOLT_SKILL and self:GetEffectValueByKey(BOLT_EFFECT_KEY) > 0)
        or (ENABLE_FREEZE_RING_SKILL and self:GetEffectValueByKey(FREEZE_RING_EFFECT_KEY) > 0)
        or (ENABLE_FIRE_RING_SKILL and self:GetEffectValueByKey(FIRE_RING_EFFECT_KEY) > 0)
        or (ENABLE_FLAME_CONE_SKILL and self:GetEffectValueByKey(FLAME_CONE_EFFECT_KEY) > 0)
        or (ENABLE_TWIN_LASER_SKILL and self:GetEffectValueByKey(TWIN_LASER_EFFECT_KEY) > 0)
        or (ENABLE_TWIN_DASH_SKILL and self:GetEffectValueByKey(TWIN_DASH_EFFECT_KEY) > 0)
        or (ENABLE_TWIN_HELLFIRE_SKILL and self:GetEffectValueByKey(TWIN_HELLFIRE_EFFECT_KEY) > 0)
end

local function GetMonsterSkillThinkInterval(inst)
    if inst == nil then
        return THINK_MIN_INTERVAL
    end

    if type(inst._hh_monster_skill_think_interval) ~= "number" then
        inst._hh_monster_skill_think_interval = THINK_MIN_INTERVAL
            + math.random() * (THINK_MAX_INTERVAL - THINK_MIN_INTERVAL)
    end

    return inst._hh_monster_skill_think_interval
end

local function TryUseRangedBurstSkills(self, target)
    if TryUseBarrageByAggro(self, target) then
        return true
    end

    if TryUseBoltByAggro(self, target) then
        return true
    end

    if TryUseTwinLaserByAggro(self, target) then
        return true
    end

    return false
end

local function TryUseZoneSkills(self, target)
    if TryUseTrapSkill(self, target) then
        return true
    end

    if TryUseFreezeRingByAggro(self, target) then
        return true
    end

    if TryUseFireRingByAggro(self, target) then
        return true
    end

    if TryUseFlameConeByAggro(self, target) then
        return true
    end

    if TryUseTwinHellfireByAggro(self, target) then
        return true
    end

    return false
end

local function TryUseMobilitySkills(self, target)
    if TryUsePursuitSkills(self, target) then
        return true
    end

    if TryUseTwinDashByAggro(self, target) then
        return true
    end

    return false
end

local function TryUseSkillThink(self)
    local inst = self ~= nil and self.inst or nil
    if inst == nil
        or TheWorld == nil
        or not TheWorld.ismastersim
        or not HasComponents(inst, "combat")
        or not IsValidSkillCaster(inst)
        or IsHardBlockedForSkill(inst)
        or not HasAnyThinkSkillEffect(self)
    then
        return false
    end

    local target = inst.components.combat.target
    if not IsValidBaseTarget(inst, target) or not target:HasTag("player") then
        return false
    end

    local groups
    if IsOutsideNormalAttackRange(inst, target) then
        groups = {
            TryUseMobilitySkills,
            TryUseRangedBurstSkills,
            TryUseZoneSkills,
        }
    else
        groups = {
            TryUseZoneSkills,
            TryUseMobilitySkills,
            TryUseRangedBurstSkills,
        }
    end

    local max_groups = math.min(THINK_MAX_GROUPS_PER_ROUND, #groups)
    for i = 1, max_groups do
        if groups[i](self, target) then
            return true
        end
    end

    return false
end

local function StartMonsterSkillThinkTask(inst)
    if inst == nil
        or inst._hh_monster_skill_think_task ~= nil
        or inst._hh_monster_skill_think_start_task ~= nil
        or not HasEnabledThinkSkills()
    then
        return
    end

    local interval = GetMonsterSkillThinkInterval(inst)
    local initial_delay = math.random() * interval
    inst._hh_monster_skill_think_start_task = inst:DoTaskInTime(initial_delay, function(monster)
        if monster == nil then
            return
        end
        monster._hh_monster_skill_think_start_task = nil
        if not monster:IsValid() or monster._hh_monster_skill_think_task ~= nil then
            return
        end

        monster._hh_monster_skill_think_task = monster:DoPeriodicTask(interval, function(monster_)
            if monster_ ~= nil and monster_.components ~= nil and monster_.components.hh_monster ~= nil then
                TryUseSkillThink(monster_.components.hh_monster)
            end
        end)
    end)
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

if ENABLE_BARRAGE_SKILL then
    for monster_type, buffs in pairs(SKILL_BUFFS) do
        buffs.patch_skill_barrage = {
            name = "连发弹幕(远程技能)",
            only_one = true,
            rangeValue = { min = 1, max = 1 },
            check_fn = function(inst)
                return inst ~= nil and inst:HasTag(BARRAGE_CANDIDATE_TAG)
            end,
            start_fn = function(inst, value)
                if inst ~= nil and inst:IsValid() and inst.components.hh_monster ~= nil then
                    inst.components.hh_monster:AddEffectValueByKey(BARRAGE_EFFECT_KEY, 1)
                end
            end,
        }
    end
end

if ENABLE_TRAP_SKILL then
    for monster_type, buffs in pairs(SKILL_BUFFS) do
        buffs.patch_skill_trap = {
            name = "地刺陷阱(延迟技能)",
            only_one = true,
            rangeValue = { min = 1, max = 1 },
            check_fn = function(inst)
                return inst ~= nil and inst:HasTag(TRAP_CANDIDATE_TAG)
            end,
            start_fn = function(inst, value)
                if inst ~= nil and inst:IsValid() and inst.components.hh_monster ~= nil then
                    inst.components.hh_monster:AddEffectValueByKey(TRAP_EFFECT_KEY, 1)
                end
            end,
        }
    end
end

if ENABLE_BOLT_SKILL then
    for monster_type, buffs in pairs(SKILL_BUFFS) do
        buffs.patch_skill_bolt = {
            name = "落雷(定点技能)",
            only_one = true,
            rangeValue = { min = 1, max = 1 },
            check_fn = function(inst)
                return inst ~= nil and inst:HasTag(BOLT_CANDIDATE_TAG)
            end,
            start_fn = function(inst, value)
                if inst ~= nil and inst:IsValid() and inst.components.hh_monster ~= nil then
                    inst.components.hh_monster:AddEffectValueByKey(BOLT_EFFECT_KEY, 1)
                end
            end,
        }
    end
end

if ENABLE_FREEZE_RING_SKILL then
    for monster_type, buffs in pairs(SKILL_BUFFS) do
        buffs.patch_skill_freeze_ring = {
            name = "冰环(冻结技能)",
            only_one = true,
            rangeValue = { min = 1, max = 1 },
            check_fn = function(inst)
                return inst ~= nil and inst:HasTag(FREEZE_RING_CANDIDATE_TAG)
            end,
            start_fn = function(inst, value)
                if inst ~= nil and inst:IsValid() and inst.components.hh_monster ~= nil then
                    inst.components.hh_monster:AddEffectValueByKey(FREEZE_RING_EFFECT_KEY, 1)
                end
            end,
        }
    end
end

if ENABLE_FIRE_RING_SKILL then
    for monster_type, buffs in pairs(SKILL_BUFFS) do
        buffs.patch_skill_fire_ring = {
            name = "火阵(燃烧技能)",
            only_one = true,
            rangeValue = { min = 1, max = 1 },
            check_fn = function(inst)
                return inst ~= nil and inst:HasTag(FIRE_RING_CANDIDATE_TAG)
            end,
            start_fn = function(inst, value)
                if inst ~= nil and inst:IsValid() and inst.components.hh_monster ~= nil then
                    inst.components.hh_monster:AddEffectValueByKey(FIRE_RING_EFFECT_KEY, 1)
                end
            end,
        }
    end
end

if ENABLE_FLAME_CONE_SKILL then
    for monster_type, buffs in pairs(SKILL_BUFFS) do
        if monster_type ~= "common_monster" then
        buffs.patch_skill_flame_cone = {
            name = "扇形喷火(前方技能)",
            only_one = true,
            rangeValue = { min = 1, max = 1 },
            check_fn = function(inst)
                return inst ~= nil and inst:HasTag(FLAME_CONE_CANDIDATE_TAG)
            end,
            start_fn = function(inst, value)
                if inst ~= nil and inst:IsValid() and inst.components.hh_monster ~= nil then
                    inst.components.hh_monster:AddEffectValueByKey(FLAME_CONE_EFFECT_KEY, 1)
                end
            end,
        }
        end
    end
end

if ENABLE_TWIN_LASER_SKILL then
    for monster_type, buffs in pairs(SKILL_BUFFS) do
        if monster_type ~= "common_monster" then
            buffs.patch_skill_twin_laser = {
                name = "激光炮(魔眼技能)",
                only_one = true,
                rangeValue = { min = 1, max = 1 },
                check_fn = function(inst)
                    return inst ~= nil and inst:HasTag(TWIN_LASER_CANDIDATE_TAG)
                end,
                start_fn = function(inst, value)
                    if inst ~= nil and inst:IsValid() and inst.components.hh_monster ~= nil then
                        inst.components.hh_monster:AddEffectValueByKey(TWIN_LASER_EFFECT_KEY, 1)
                    end
                end,
            }
        end
    end
end

if ENABLE_TWIN_DASH_SKILL then
    for monster_type, buffs in pairs(SKILL_BUFFS) do
        if monster_type ~= "common_monster" then
            buffs.patch_skill_twin_dash = {
                name = "五连快速冲撞(魔眼技能)",
                only_one = true,
                rangeValue = { min = 1, max = 1 },
                check_fn = function(inst)
                    return inst ~= nil and inst:HasTag(TWIN_DASH_CANDIDATE_TAG)
                end,
                start_fn = function(inst, value)
                    if inst ~= nil and inst:IsValid() and inst.components.hh_monster ~= nil then
                        inst.components.hh_monster:AddEffectValueByKey(TWIN_DASH_EFFECT_KEY, 1)
                    end
                end,
            }
        end
    end
end

if ENABLE_TWIN_HELLFIRE_SKILL then
    for monster_type, buffs in pairs(SKILL_BUFFS) do
        if monster_type ~= "common_monster" then
            buffs.patch_skill_twin_hellfire = {
                name = "高速魔焰喷火(魔眼技能)",
                only_one = true,
                rangeValue = { min = 1, max = 1 },
                check_fn = function(inst)
                    return inst ~= nil and inst:HasTag(TWIN_HELLFIRE_CANDIDATE_TAG)
                end,
                start_fn = function(inst, value)
                    if inst ~= nil and inst:IsValid() and inst.components.hh_monster ~= nil then
                        inst.components.hh_monster:AddEffectValueByKey(TWIN_HELLFIRE_EFFECT_KEY, 1)
                    end
                end,
            }
        end
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
        if self.hh_effects[BARRAGE_EFFECT_KEY] == nil then
            self.hh_effects[BARRAGE_EFFECT_KEY] = 0
        end
        if self.hh_effects[TRAP_EFFECT_KEY] == nil then
            self.hh_effects[TRAP_EFFECT_KEY] = 0
        end
        if self.hh_effects[BOLT_EFFECT_KEY] == nil then
            self.hh_effects[BOLT_EFFECT_KEY] = 0
        end
        if self.hh_effects[FREEZE_RING_EFFECT_KEY] == nil then
            self.hh_effects[FREEZE_RING_EFFECT_KEY] = 0
        end
        if self.hh_effects[FIRE_RING_EFFECT_KEY] == nil then
            self.hh_effects[FIRE_RING_EFFECT_KEY] = 0
        end
        if self.hh_effects[FLAME_CONE_EFFECT_KEY] == nil then
            self.hh_effects[FLAME_CONE_EFFECT_KEY] = 0
        end
        if self.hh_effects[TWIN_LASER_EFFECT_KEY] == nil then
            self.hh_effects[TWIN_LASER_EFFECT_KEY] = 0
        end
        if self.hh_effects[TWIN_DASH_EFFECT_KEY] == nil then
            self.hh_effects[TWIN_DASH_EFFECT_KEY] = 0
        end
        if self.hh_effects[TWIN_HELLFIRE_EFFECT_KEY] == nil then
            self.hh_effects[TWIN_HELLFIRE_EFFECT_KEY] = 0
        end
    end

    MarkSkillCandidate(inst)
    StartMonsterSkillThinkTask(inst)

    if ENABLE_SPIT_SKILL and inst._hh_monster_skill_doattack == nil then
        inst._hh_monster_skill_doattack = function(monster, data)
            if monster ~= nil and monster.components ~= nil and monster.components.hh_monster ~= nil then
                local target = data ~= nil and data.target or nil
                TryUseMonsterSkill(monster.components.hh_monster, target)
            end
        end
        inst:ListenForEvent("doattack", inst._hh_monster_skill_doattack)
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
