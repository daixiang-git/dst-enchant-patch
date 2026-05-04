----
--- 怪物玩家词条扩展
--- 让怪物能随机获得部分玩家装备专属的附魔词条
--- 通过 AddComponentPostInit 钩子注入，不修改本体
----

-- ============================================================
-- 新增的 effect key 列表（玩家有但怪物原本没有的，适合怪物的）
-- ============================================================
local BREAK_EQUIP_ENABLED = GetModConfigData("enable_monster_break_equip_effect") ~= false
local BREAK_EQUIP_RANGE_MODE = GetModConfigData("monster_break_equip_effect_range") or "1_3"
local BREAK_EQUIP_MAX = BREAK_EQUIP_RANGE_MODE == "1_5" and 5 or 3
local ATTACK_RANGE_ENABLED = GetModConfigData("enable_monster_attack_range_effect") ~= false
local ATTACK_SPEED_ENABLED = GetModConfigData("enable_monster_attack_speed_effect") ~= false
local HEDGEHOG_ENABLED = GetModConfigData("enable_monster_hedgehog_effect") ~= false
local BOSS_SKILLS_TO_ELITE_ENABLED = GetModConfigData("enable_boss_skills_for_elite") ~= false

local NEW_EFFECT_KEYS = {
    "trueDamageNum",                -- 真实伤害（穿刺）
    "bloodOutburst",                -- 血涌（血量越低伤害越高）
    "moreDamage20To200",            -- 20%概率双倍伤害
    "moreDamage10To300",            -- 10%概率三倍伤害
    "moreDamage8To500",             -- 8%概率五倍伤害
    "reflexiveInjury",              -- 固定反伤
    "reflexiveInjuryByPercent",     -- 百分比反伤
    "targetPercentDamage",          -- 末世（目标当前血量百分比伤害）
    "immunePoison",                 -- 免疫中毒
    "immuneLongRangeDamage",        -- 免疫远程伤害（按距离判定）
    "breakEquipOnHitChance",        -- 命中概率分解头部/身体装备
    "attackRangeBonus",             -- 攻击距离增加
    "attackSpeedPercent",           -- 攻击速度增加（减少攻击间隔）
    "hedgehogTrueReflect",          -- 受击后真实反伤
}

-- ============================================================
-- 新增的怪物词条定义（按等级分类，仿照 enums/hh_monster.lua 格式）
-- 这些词条可以被 AddBuffByName() 随机抽中
-- ============================================================
local NEW_MONSTER_BUFFS = {
    -- ==================== 普通怪 ====================
    common_monster = {
        patch_trueDamage = {
            name = "真实伤害+%s",
            only_one = true,
            rangeValue = { min = 5, max = 15 },
            start_fn = function(inst, value)
                if inst:IsValid() and inst.components.hh_monster then
                    inst.components.hh_monster:AddEffectValueByKey("trueDamageNum", value)
                end
            end,
        },
        patch_bloodOutburst = {
            name = "血涌(血量越低伤害越高)",
            only_one = true,
            rangeValue = { min = 1, max = 1 },
            start_fn = function(inst, value)
                if inst:IsValid() and inst.components.hh_monster then
                    inst.components.hh_monster:AddEffectValueByKey("bloodOutburst", 1)
                end
            end,
        },
        patch_moreDamage20 = {
            name = "20%%概率双倍伤害",
            only_one = true,
            rangeValue = { min = 100, max = 200 },
            start_fn = function(inst, value)
                if inst:IsValid() and inst.components.hh_monster then
                    inst.components.hh_monster:AddEffectValueByKey("moreDamage20To200", value)
                end
            end,
        },
        patch_moreDamage10 = {
            name = "10%%概率三倍伤害",
            only_one = true,
            rangeValue = { min = 150, max = 300 },
            start_fn = function(inst, value)
                if inst:IsValid() and inst.components.hh_monster then
                    inst.components.hh_monster:AddEffectValueByKey("moreDamage10To300", value)
                end
            end,
        },
        patch_moreDamage8 = {
            name = "8%%概率五倍伤害",
            only_one = true,
            rangeValue = { min = 200, max = 400 },
            start_fn = function(inst, value)
                if inst:IsValid() and inst.components.hh_monster then
                    inst.components.hh_monster:AddEffectValueByKey("moreDamage8To500", value)
                end
            end,
        },
        patch_reflexiveInjury = {
            name = "固定反伤+%s",
            only_one = true,
            rangeValue = { min = 5, max = 15 },
            start_fn = function(inst, value)
                if inst:IsValid() and inst.components.hh_monster then
                    inst.components.hh_monster:AddEffectValueByKey("reflexiveInjury", value)
                end
            end,
        },
        patch_reflexivePercent = {
            name = "百分比反伤%s%%",
            only_one = true,
            rangeValue = { min = 3, max = 8 },
            start_fn = function(inst, value)
                if inst:IsValid() and inst.components.hh_monster then
                    inst.components.hh_monster:AddEffectValueByKey("reflexiveInjuryByPercent", value)
                end
            end,
        },
        patch_targetPercent = {
            name = "末世(目标当前血量%s%%真伤)",
            only_one = true,
            rangeValue = { min = 1, max = 2 },
            start_fn = function(inst, value)
                if inst:IsValid() and inst.components.hh_monster then
                    inst.components.hh_monster:AddEffectValueByKey("targetPercentDamage", value)
                end
            end,
        },
        patch_immunePoison = {
            name = "免疫中毒",
            only_one = true,
            rangeValue = { min = 1, max = 1 },
            start_fn = function(inst, value)
                if inst:IsValid() and inst.components.hh_monster then
                    inst.components.hh_monster:AddEffectValueByKey("immunePoison", 1)
                end
            end,
        },
        patch_immuneLongRangeDamage = {
            name = "免疫远程伤害",
            only_one = true,
            rangeValue = { min = 1, max = 1 },
            start_fn = function(inst, value)
                if inst:IsValid() and inst.components.hh_monster then
                    inst.components.hh_monster:AddEffectValueByKey("immuneLongRangeDamage", 1)
                end
            end,
        },
    },
    -- ==================== 精英怪 ====================
    elite_monster = {
        patch_trueDamage = {
            name = "真实伤害+%s",
            only_one = true,
            rangeValue = { min = 15, max = 40 },
            start_fn = function(inst, value)
                if inst:IsValid() and inst.components.hh_monster then
                    inst.components.hh_monster:AddEffectValueByKey("trueDamageNum", value)
                end
            end,
        },
        patch_bloodOutburst = {
            name = "血涌(血量越低伤害越高)",
            only_one = true,
            rangeValue = { min = 1, max = 1 },
            start_fn = function(inst, value)
                if inst:IsValid() and inst.components.hh_monster then
                    inst.components.hh_monster:AddEffectValueByKey("bloodOutburst", 1)
                end
            end,
        },
        patch_moreDamage20 = {
            name = "20%%概率双倍伤害",
            only_one = true,
            rangeValue = { min = 150, max = 300 },
            start_fn = function(inst, value)
                if inst:IsValid() and inst.components.hh_monster then
                    inst.components.hh_monster:AddEffectValueByKey("moreDamage20To200", value)
                end
            end,
        },
        patch_moreDamage10 = {
            name = "10%%概率三倍伤害",
            only_one = true,
            rangeValue = { min = 200, max = 400 },
            start_fn = function(inst, value)
                if inst:IsValid() and inst.components.hh_monster then
                    inst.components.hh_monster:AddEffectValueByKey("moreDamage10To300", value)
                end
            end,
        },
        patch_moreDamage8 = {
            name = "8%%概率五倍伤害",
            only_one = true,
            rangeValue = { min = 300, max = 500 },
            start_fn = function(inst, value)
                if inst:IsValid() and inst.components.hh_monster then
                    inst.components.hh_monster:AddEffectValueByKey("moreDamage8To500", value)
                end
            end,
        },
        patch_reflexiveInjury = {
            name = "固定反伤+%s",
            only_one = true,
            rangeValue = { min = 10, max = 30 },
            start_fn = function(inst, value)
                if inst:IsValid() and inst.components.hh_monster then
                    inst.components.hh_monster:AddEffectValueByKey("reflexiveInjury", value)
                end
            end,
        },
        patch_reflexivePercent = {
            name = "百分比反伤%s%%",
            only_one = true,
            rangeValue = { min = 4, max = 10 },
            start_fn = function(inst, value)
                if inst:IsValid() and inst.components.hh_monster then
                    inst.components.hh_monster:AddEffectValueByKey("reflexiveInjuryByPercent", value)
                end
            end,
        },
        patch_targetPercent = {
            name = "末世(目标当前血量%s%%真伤)",
            only_one = true,
            rangeValue = { min = 1, max = 3 },
            start_fn = function(inst, value)
                if inst:IsValid() and inst.components.hh_monster then
                    inst.components.hh_monster:AddEffectValueByKey("targetPercentDamage", value)
                end
            end,
        },
        patch_immunePoison = {
            name = "免疫中毒",
            only_one = true,
            rangeValue = { min = 1, max = 1 },
            start_fn = function(inst, value)
                if inst:IsValid() and inst.components.hh_monster then
                    inst.components.hh_monster:AddEffectValueByKey("immunePoison", 1)
                end
            end,
        },
        patch_immuneLongRangeDamage = {
            name = "免疫远程伤害",
            only_one = true,
            rangeValue = { min = 1, max = 1 },
            start_fn = function(inst, value)
                if inst:IsValid() and inst.components.hh_monster then
                    inst.components.hh_monster:AddEffectValueByKey("immuneLongRangeDamage", 1)
                end
            end,
        },
    },
    -- ==================== Boss ====================
    boss_monster = {
        patch_trueDamage = {
            name = "真实伤害+%s",
            only_one = true,
            rangeValue = { min = 30, max = 80 },
            start_fn = function(inst, value)
                if inst:IsValid() and inst.components.hh_monster then
                    inst.components.hh_monster:AddEffectValueByKey("trueDamageNum", value)
                end
            end,
        },
        patch_bloodOutburst = {
            name = "血涌(血量越低伤害越高)",
            only_one = true,
            rangeValue = { min = 1, max = 1 },
            start_fn = function(inst, value)
                if inst:IsValid() and inst.components.hh_monster then
                    inst.components.hh_monster:AddEffectValueByKey("bloodOutburst", 1)
                end
            end,
        },
        patch_moreDamage20 = {
            name = "20%%概率双倍伤害",
            only_one = true,
            rangeValue = { min = 200, max = 400 },
            start_fn = function(inst, value)
                if inst:IsValid() and inst.components.hh_monster then
                    inst.components.hh_monster:AddEffectValueByKey("moreDamage20To200", value)
                end
            end,
        },
        patch_moreDamage10 = {
            name = "10%%概率三倍伤害",
            only_one = true,
            rangeValue = { min = 300, max = 500 },
            start_fn = function(inst, value)
                if inst:IsValid() and inst.components.hh_monster then
                    inst.components.hh_monster:AddEffectValueByKey("moreDamage10To300", value)
                end
            end,
        },
        patch_moreDamage8 = {
            name = "8%%概率五倍伤害",
            only_one = true,
            rangeValue = { min = 400, max = 600 },
            start_fn = function(inst, value)
                if inst:IsValid() and inst.components.hh_monster then
                    inst.components.hh_monster:AddEffectValueByKey("moreDamage8To500", value)
                end
            end,
        },
        patch_reflexiveInjury = {
            name = "固定反伤+%s",
            only_one = true,
            rangeValue = { min = 20, max = 60 },
            start_fn = function(inst, value)
                if inst:IsValid() and inst.components.hh_monster then
                    inst.components.hh_monster:AddEffectValueByKey("reflexiveInjury", value)
                end
            end,
        },
        patch_reflexivePercent = {
            name = "百分比反伤%s%%",
            only_one = true,
            rangeValue = { min = 5, max = 15 },
            start_fn = function(inst, value)
                if inst:IsValid() and inst.components.hh_monster then
                    inst.components.hh_monster:AddEffectValueByKey("reflexiveInjuryByPercent", value)
                end
            end,
        },
        patch_targetPercent = {
            name = "末世(目标当前血量%s%%真伤)",
            only_one = true,
            rangeValue = { min = 2, max = 5 },
            start_fn = function(inst, value)
                if inst:IsValid() and inst.components.hh_monster then
                    inst.components.hh_monster:AddEffectValueByKey("targetPercentDamage", value)
                end
            end,
        },
        patch_immunePoison = {
            name = "免疫中毒",
            only_one = true,
            rangeValue = { min = 1, max = 1 },
            start_fn = function(inst, value)
                if inst:IsValid() and inst.components.hh_monster then
                    inst.components.hh_monster:AddEffectValueByKey("immunePoison", 1)
                end
            end,
        },
        patch_immuneLongRangeDamage = {
            name = "免疫远程伤害",
            only_one = true,
            rangeValue = { min = 1, max = 1 },
            start_fn = function(inst, value)
                if inst:IsValid() and inst.components.hh_monster then
                    inst.components.hh_monster:AddEffectValueByKey("immuneLongRangeDamage", 1)
                end
            end,
        },
    },
}

if BREAK_EQUIP_ENABLED then
    local break_equip_buff = {
        name = "%s%%概率分解头/衣",
        only_one = true,
        rangeValue = { min = 1, max = BREAK_EQUIP_MAX },
        start_fn = function(inst, value)
            if inst:IsValid() and inst.components.hh_monster then
                inst.components.hh_monster:AddEffectValueByKey("breakEquipOnHitChance", value)
            end
        end,
    }

    NEW_MONSTER_BUFFS.elite_monster.patch_breakEquip = break_equip_buff
    NEW_MONSTER_BUFFS.boss_monster.patch_breakEquip = break_equip_buff
end

if ATTACK_RANGE_ENABLED then
    NEW_MONSTER_BUFFS.common_monster.patch_attackRange = {
        name = "攻击距离+%s",
        only_one = true,
        rangeValue = { min = 1, max = 1 },
        start_fn = function(inst, value)
            if inst:IsValid() and inst.components.hh_monster then
                inst.components.hh_monster:AddEffectValueByKey("attackRangeBonus", value)
            end
        end,
    }

    NEW_MONSTER_BUFFS.elite_monster.patch_attackRange = {
        name = "攻击距离+%s",
        only_one = true,
        rangeValue = { min = 1, max = 2 },
        start_fn = function(inst, value)
            if inst:IsValid() and inst.components.hh_monster then
                inst.components.hh_monster:AddEffectValueByKey("attackRangeBonus", value)
            end
        end,
    }

    NEW_MONSTER_BUFFS.boss_monster.patch_attackRange = {
        name = "攻击距离+%s",
        only_one = true,
        rangeValue = { min = 1, max = 2 },
        start_fn = function(inst, value)
            if inst:IsValid() and inst.components.hh_monster then
                inst.components.hh_monster:AddEffectValueByKey("attackRangeBonus", value)
            end
        end,
    }
end

if ATTACK_SPEED_ENABLED then
    NEW_MONSTER_BUFFS.common_monster.patch_attackSpeed = {
        name = "攻击速度+%s%%",
        only_one = true,
        rangeValue = { min = 10, max = 100 },
        start_fn = function(inst, value)
            if inst:IsValid() and inst.components.hh_monster then
                inst.components.hh_monster:AddEffectValueByKey("attackSpeedPercent", value)
            end
        end,
    }

    NEW_MONSTER_BUFFS.elite_monster.patch_attackSpeed = {
        name = "攻击速度+%s%%",
        only_one = true,
        rangeValue = { min = 30, max = 100 },
        start_fn = function(inst, value)
            if inst:IsValid() and inst.components.hh_monster then
                inst.components.hh_monster:AddEffectValueByKey("attackSpeedPercent", value)
            end
        end,
    }

    NEW_MONSTER_BUFFS.boss_monster.patch_attackSpeed = {
        name = "攻击速度+%s%%",
        only_one = true,
        rangeValue = { min = 50, max = 200 },
        start_fn = function(inst, value)
            if inst:IsValid() and inst.components.hh_monster then
                inst.components.hh_monster:AddEffectValueByKey("attackSpeedPercent", value)
            end
        end,
    }
end

if HEDGEHOG_ENABLED then
    NEW_MONSTER_BUFFS.common_monster.patch_hedgehog = {
        name = "刺猬(受击真伤反伤+%s)",
        only_one = true,
        rangeValue = { min = 1, max = 3 },
        start_fn = function(inst, value)
            if inst:IsValid() and inst.components.hh_monster then
                inst.components.hh_monster:AddEffectValueByKey("hedgehogTrueReflect", value)
            end
        end,
    }

    NEW_MONSTER_BUFFS.elite_monster.patch_hedgehog = {
        name = "刺猬(受击真伤反伤+%s)",
        only_one = true,
        rangeValue = { min = 3, max = 6 },
        start_fn = function(inst, value)
            if inst:IsValid() and inst.components.hh_monster then
                inst.components.hh_monster:AddEffectValueByKey("hedgehogTrueReflect", value)
            end
        end,
    }

    NEW_MONSTER_BUFFS.boss_monster.patch_hedgehog = {
        name = "刺猬(受击真伤反伤+%s)",
        only_one = true,
        rangeValue = { min = 5, max = 10 },
        start_fn = function(inst, value)
            if inst:IsValid() and inst.components.hh_monster then
                inst.components.hh_monster:AddEffectValueByKey("hedgehogTrueReflect", value)
            end
        end,
    }
end

local EQUIPSLOTS = GLOBAL.EQUIPSLOTS

local function HasComponents(inst, ...)
    if not inst or not inst.components then
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

local function CacheCombatDefaults(inst)
    if not HasComponents(inst, "combat") then
        return nil
    end

    local combat = inst.components.combat

    if combat.hh_patch_base_attack_range == nil then
        combat.hh_patch_base_attack_range = combat.attackrange or 0
    end
    if combat.hh_patch_base_hit_range == nil then
        combat.hh_patch_base_hit_range = combat.hitrange or combat.attackrange or 0
    end
    if combat.hh_patch_base_attack_period == nil then
        combat.hh_patch_base_attack_period = combat.min_attack_period or combat.attackperiod
    end

    return combat
end

local function ApplyCombatEffectModifiers(self)
    local inst = self and self.inst or nil
    if not inst then
        return
    end

    local combat = CacheCombatDefaults(inst)
    if combat == nil then
        return
    end

    local range_bonus = ATTACK_RANGE_ENABLED and self:GetEffectValueByKey("attackRangeBonus") or 0
    local speed_percent = ATTACK_SPEED_ENABLED and self:GetEffectValueByKey("attackSpeedPercent") or 0

    if combat.SetRange and combat.hh_patch_base_attack_range ~= nil then
        local base_attack_range = combat.hh_patch_base_attack_range or 0
        local base_hit_range = combat.hh_patch_base_hit_range or base_attack_range
        local new_attack_range = math.max(base_attack_range + range_bonus, 0)
        local new_hit_range = math.max(base_hit_range + range_bonus, new_attack_range)
        combat:SetRange(new_attack_range, new_hit_range)
    end

    if combat.SetAttackPeriod and combat.hh_patch_base_attack_period ~= nil then
        local base_period = combat.hh_patch_base_attack_period
        local speed_mult = math.max(0.2, 1 - speed_percent / 100)
        combat:SetAttackPeriod(math.max(base_period * speed_mult, 0.2))
    end
end

local function CloneBuffData(buff_data)
    if type(buff_data) ~= "table" then
        return buff_data
    end

    local cloned = {}
    for k, v in pairs(buff_data) do
        if type(v) == "table" then
            local child = {}
            for ck, cv in pairs(v) do
                child[ck] = cv
            end
            cloned[k] = child
        else
            cloned[k] = v
        end
    end
    return cloned
end

local function GetDisplayName(inst)
    if not inst then
        return "未知目标"
    end
    return inst.name or (STRINGS.NAMES and STRINGS.NAMES[string.upper(inst.prefab or "")]) or inst.prefab or "未知目标"
end

local function GetMonsterTitle(inst)
    if inst and inst:HasTag("boss_monster") then
        return "BOSS"
    end
    if inst and inst:HasTag("elite_monster") then
        return "精英"
    end
    return "怪物"
end

local function IsLongRangeHit(attacker, target)
    if attacker == nil or target == nil or not attacker:IsValid() or not target:IsValid() then
        return false
    end
    if attacker.Transform == nil or target.Transform == nil then
        return false
    end

    local ax, ay, az = attacker.Transform:GetWorldPosition()
    local tx, ty, tz = target.Transform:GetWorldPosition()
    local dx = ax - tx
    local dz = az - tz
    return (dx * dx + dz * dz) > 9
end

local function GetSlotLabel(slot)
    if slot == EQUIPSLOTS.HEAD then
        return "头部"
    end
    if slot == EQUIPSLOTS.BODY then
        return "身体"
    end
    return "装备"
end

local function GetBreakableEquip(player)
    if not HasComponents(player, "inventory") then
        return nil, nil
    end

    local candidates = {}
    local head = player.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
    local body = player.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)

    if head and HasComponents(head, "hh_equip") then
        table.insert(candidates, { item = head, slot = EQUIPSLOTS.HEAD })
    end
    if body and HasComponents(body, "hh_equip") then
        table.insert(candidates, { item = body, slot = EQUIPSLOTS.BODY })
    end

    if #candidates <= 0 then
        return nil, nil
    end

    local choice = candidates[math.random(1, #candidates)]
    return choice.item, choice.slot
end

local function DecomposeEquippedItem(player, equip)
    if not player or not equip or not equip:IsValid() or not HasComponents(equip, "hh_equip") then
        return false
    end

    if HasComponents(equip, "inventoryitem") then
        equip.components.inventoryitem:RemoveFromOwner(true)
    end
    if equip:IsValid() then
        equip:Remove()
    end
    return true
end

-- ============================================================
-- Hook hh_monster 组件：注入新 effect keys + 包装战斗方法
-- ============================================================
AddComponentPostInit("hh_monster", function(self, inst)
    -- 1. 注入新 effect key 到 hh_effects 表（初始值 0）
    if self.hh_effects then
        for _, key in ipairs(NEW_EFFECT_KEYS) do
            if self.hh_effects[key] == nil then
                self.hh_effects[key] = 0
            end
        end
    end

    local _orig_RefreshSpecialFn = self.RefreshSpecialFn
    self.RefreshSpecialFn = function(self, ...)
        local result = nil
        if _orig_RefreshSpecialFn then
            result = _orig_RefreshSpecialFn(self, ...)
        end
        ApplyCombatEffectModifiers(self)
        return result
    end

    -- 2. 包装 DoAttackDamage —— 追加新效果的伤害计算
    local _orig_DoAttackDamage = self.DoAttackDamage
    self.DoAttackDamage = function(self, monster, target, amount)
        -- 先执行原始逻辑
        amount = _orig_DoAttackDamage(self, monster, target, amount)

        if not target or not target:IsValid() then
            return amount
        end

        -- 血涌：血量越低伤害越高（最高加成50%）
        local bloodOutburst = self:GetEffectValueByKey("bloodOutburst")
        if bloodOutburst > 0 and monster.components.health and not monster.components.health:IsDead() then
            local hp_percent = monster.components.health:GetPercent()
            if hp_percent >= 0 then
                local bonus_percent = (1 - hp_percent) * 0.5  -- 最高50%加成
                amount = amount * (1 + bonus_percent)
            end
        end

        -- 20%概率双倍伤害
        local moreDmg20 = self:GetEffectValueByKey("moreDamage20To200")
        if moreDmg20 > 0 then
            if math.random() <= 0.2 then
                amount = amount * math.max(moreDmg20 / 100, 1)
            end
        end

        -- 10%概率三倍伤害
        local moreDmg10 = self:GetEffectValueByKey("moreDamage10To300")
        if moreDmg10 > 0 then
            if math.random() <= 0.1 then
                amount = amount * math.max(moreDmg10 / 100, 1)
            end
        end

        -- 8%概率五倍伤害
        local moreDmg8 = self:GetEffectValueByKey("moreDamage8To500")
        if moreDmg8 > 0 then
            if math.random() <= 0.08 then
                amount = amount * math.max(moreDmg8 / 100, 1)
            end
        end

        -- 真实伤害（穿刺）—— 在主伤害之外额外造成真实伤害
        local trueDmg = self:GetEffectValueByKey("trueDamageNum")
        if trueDmg > 0 and target.components.health and target.components.health.DoHHDelta then
            target.components.health:DoHHDelta(-trueDmg, monster, "穿刺")
        end

        -- 末世：按目标当前血量百分比造成真实伤害
        local targetPctDmg = self:GetEffectValueByKey("targetPercentDamage")
        if targetPctDmg > 0 and target.components.health and not target.components.health:IsDead() then
            local target_current_hp = target.components.health.currenthealth or 0
            local pct_damage = target_current_hp * targetPctDmg / 100
            if pct_damage > 0 and target.components.health.DoHHDelta then
                target.components.health:DoHHDelta(-pct_damage, monster, "末世")
            end
        end

        return amount
    end

    -- 3. 包装 GetBlockDamage —— 追加反伤效果
    local _orig_GetBlockDamage = self.GetBlockDamage
    self.GetBlockDamage = function(self, player, attacker, amount)
        -- 先执行原始逻辑
        amount = _orig_GetBlockDamage(self, player, attacker, amount)

        if not attacker or not attacker:IsValid() then
            return amount
        end

        if amount > 0 and self:GetEffectValueByKey("immuneLongRangeDamage") > 0 and IsLongRangeHit(attacker, player) then
            return 0
        end

        -- 固定反伤
        local refInjury = self:GetEffectValueByKey("reflexiveInjury")
        if refInjury > 0 and attacker.components.combat and attacker.components.combat.GetBrambleFx then
            attacker.components.combat:GetBrambleFx(self.inst, refInjury)
        end

        -- 百分比反伤
        local refPercent = self:GetEffectValueByKey("reflexiveInjuryByPercent")
        if refPercent > 0 and amount > 0 and attacker.components.combat and attacker.components.combat.GetBrambleFx then
            local reflect_dmg = amount * refPercent / 100
            if reflect_dmg > 0 then
                attacker.components.combat:GetBrambleFx(self.inst, reflect_dmg)
            end
        end

        local hedgehogReflect = self:GetEffectValueByKey("hedgehogTrueReflect")
        if hedgehogReflect > 0
            and attacker ~= self.inst
            and attacker.components
            and attacker.components.health
            and not attacker.components.health:IsDead()
            and attacker.components.health.DoHHDelta
        then
            attacker.components.health:DoHHDelta(-hedgehogReflect, self.inst, "刺猬")
        end

        return amount
    end

    inst:ListenForEvent("onhitother", function(monster, data)
        if not BREAK_EQUIP_ENABLED then
            return
        end

        local chance = self:GetEffectValueByKey("breakEquipOnHitChance")
        if chance <= 0 then
            return
        end

        local target = data and data.target or nil
        if not target or not target:IsValid() or not target:HasTag("player") or not HasComponents(target, "hh_player", "inventory") then
            return
        end

        if math.random(1, 100) > math.min(chance, 100) then
            return
        end

        local equip, slot = GetBreakableEquip(target)
        if not equip then
            return
        end

        local player_name = GetDisplayName(target)
        local equip_name = GetDisplayName(equip)
        local monster_name = GetDisplayName(monster)
        local monster_title = GetMonsterTitle(monster)
        local slot_label = GetSlotLabel(slot)

        DecomposeEquippedItem(target, equip)

        if TheNet then
            TheNet:Announce(string.format("%s[%s]命中分解了%s的%s装备-%s", monster_title, monster_name, tostring(player_name), tostring(slot_label), tostring(equip_name)))
        end
    end)

    ApplyCombatEffectModifiers(self)
end)

-- ============================================================
-- 注入新词条到怪物词条池
-- 通过 require hh_monster 枚举表，合并新词条
-- ============================================================
local function InjectNewBuffs()
    -- 尝试获取本体的怪物词条配置表
    local success, hh_monster_enum = pcall(require, "enums/hh_monster")
    if not success or type(hh_monster_enum) ~= "table" then
        print("[附魔补丁] 无法加载 enums/hh_monster，跳过怪物词条注入")
        return
    end

    -- hh_monster_enum 的结构是按怪物类型分组的表
    -- 遍历我们的新词条配置，合并到对应的怪物类型中
    for monster_type, buffs in pairs(NEW_MONSTER_BUFFS) do
        if hh_monster_enum[monster_type] and type(hh_monster_enum[monster_type]) == "table" then
            for buff_name, buff_data in pairs(buffs) do
                if not hh_monster_enum[monster_type][buff_name] then
                    hh_monster_enum[monster_type][buff_name] = buff_data
                end
            end
        end
    end

    if BOSS_SKILLS_TO_ELITE_ENABLED then
        local boss_only_to_elite = {
            "iceTurret",
            "fireTurret",
            "poisonTurret",
            "iceLaser",
            "noHitDamage",
        }

        if type(hh_monster_enum.elite_monster) == "table" and type(hh_monster_enum.boss_monster) == "table" then
            for _, buff_name in ipairs(boss_only_to_elite) do
                if hh_monster_enum.elite_monster[buff_name] == nil and type(hh_monster_enum.boss_monster[buff_name]) == "table" then
                    hh_monster_enum.elite_monster[buff_name] = CloneBuffData(hh_monster_enum.boss_monster[buff_name])
                end
            end
        end
    end

    print("[附魔补丁] 怪物玩家词条注入完成")
end

-- 执行注入
InjectNewBuffs()

-- ============================================================
-- Hook 中毒免疫：如果怪物有 immunePoison 效果，阻止中毒 buff
-- ============================================================
AddComponentPostInit("hh_buff", function(self, inst)
    local _orig_AddBuff = self.AddBuff
    if _orig_AddBuff then
        self.AddBuff = function(self, buff_name, ...)
            -- 如果是中毒 buff，检查怪物是否有免疫
            if buff_name == "poison" and inst.components.hh_monster then
                if inst.components.hh_monster:HasSpecialEffect("immunePoison") then
                    return  -- 免疫中毒，不添加
                end
            end
            return _orig_AddBuff(self, buff_name, ...)
        end
    end
end)

print("[附魔补丁] 怪物玩家词条扩展模块已加载")
