GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })

-- 读取配置
GLOBAL.UnknownTagEnabled = GetModConfigData("ENABLE_UNKNOWN_TAG") or false
GLOBAL.EnableMonsterEffectLimit = GetModConfigData("enable_monster_effect_limit") or false
GLOBAL.EnableDropRateConfig = GetModConfigData("enable_drop_rate_config") or false
GLOBAL.EnableStoneConvertConfig = GetModConfigData("enable_stone_convert_config") or false
GLOBAL.EnableLuckyCounter = GetModConfigData("enable_lucky_counter") or false

-- 怪物词条数量上限修改（需要在附魔mod加载后执行）
if GLOBAL.UnknownTagEnabled and GLOBAL.EnableMonsterEffectLimit then
    modimport("postinit/monster_effect_limit.lua")
end

-- 精英/Boss装备掉率修改
if GLOBAL.UnknownTagEnabled and GLOBAL.EnableDropRateConfig then
    modimport("postinit/drop_rate_config.lua")
end

-- 水晶小人转换概率修改
if GLOBAL.UnknownTagEnabled and GLOBAL.EnableStoneConvertConfig then
    modimport("postinit/stone_convert_config.lua")
end

-- 累计保底系统
if GLOBAL.UnknownTagEnabled and GLOBAL.EnableLuckyCounter then
    modimport("postinit/lucky_counter.lua")
end
GLOBAL.RangedWeaponsEnabled = GetModConfigData("ENABLE_RANGED_WEAPONS") or false
GLOBAL.BenyuanXZEnabled = GetModConfigData("ENABLE_BENYUAN_XZ") or false
GLOBAL.DropReelEnabled = GetModConfigData("ENABLE_DROP_SYSTEM") or false
GLOBAL.GemEnabled = GetModConfigData("ENABLE_GEM") or false
GLOBAL.GemWORMWOOD = GetModConfigData("ENABLE_WORMWOOD") or false
GLOBAL.enable_new_effect = GetModConfigData("enable_new_effect") or false
GLOBAL.EnableTrueMeleeEnchantStone = GetModConfigData("enable_true_melee_enchant_stone") ~= false
GLOBAL.EnableCompoundCommonImmunityStones = GetModConfigData("enable_compound_common_immunity_stones") ~= false
GLOBAL.EnableMediumHasteEnchantStone = GetModConfigData("enable_medium_haste_enchant_stone") ~= false
GLOBAL.EnableRareSlideEnchantStone = GetModConfigData("enable_rare_slide_enchant_stone") ~= false
GLOBAL.EnableAttackRangeGem = GetModConfigData("enable_attack_range_gem") ~= false
GLOBAL.EnableGemConvert = GetModConfigData("enable_gem_convert") ~= false
GLOBAL.EnableMonsterSpitSkill = GetModConfigData("enable_monster_spit_skill") ~= false
GLOBAL.EnableMonsterShockwaveSkill = GetModConfigData("enable_monster_shockwave_skill") ~= false
GLOBAL.EnableMonsterChargeSkill = GetModConfigData("enable_monster_charge_skill") ~= false
GLOBAL.EnableMonsterPounceSkill = GetModConfigData("enable_monster_pounce_skill") ~= false
GLOBAL.EnableMonsterBarrageSkill = GetModConfigData("enable_monster_barrage_skill") ~= false
GLOBAL.EnableMonsterTrapSkill = GetModConfigData("enable_monster_trap_skill") ~= false
GLOBAL.EnableMonsterBoltSkill = GetModConfigData("enable_monster_bolt_skill") ~= false
GLOBAL.EnableMonsterFreezeRingSkill = GetModConfigData("enable_monster_freeze_ring_skill") ~= false
GLOBAL.EnableMonsterFireRingSkill = GetModConfigData("enable_monster_fire_ring_skill") ~= false
GLOBAL.EnableMonsterFlameConeSkill = GetModConfigData("enable_monster_flame_cone_skill") ~= false
GLOBAL.EnableMonsterTwinLaserSkill = GetModConfigData("enable_monster_twin_laser_skill") ~= false
GLOBAL.EnableMonsterTwinDashSkill = GetModConfigData("enable_monster_twin_dash_skill") ~= false
GLOBAL.EnableMonsterTwinHellfireSkill = GetModConfigData("enable_monster_twin_hellfire_skill") ~= false
GLOBAL.EnableMonsterSkillStatusDisplay = GetModConfigData("enable_monster_skill_status_display") ~= false
GLOBAL.EnableLogArmorRepair = GetModConfigData("enable_log_armor_repair") ~= false


if GLOBAL.UnknownTagEnabled then
    print("附魔补丁已激活")
    modimport("postinit/fumo.lua")     --配方
    if GLOBAL.EnableLogArmorRepair then
        modimport("postinit/log_armor_repair.lua")
    end
end


if GLOBAL.RangedWeaponsEnabled then
    print("远程武器禁用模式已激活")
    modimport("postinit/peifang.lua")     --配方
end

if GLOBAL.GemEnabled then
    print("宝石制作模式已激活")
    modimport("postinit/gem.lua")     --配方
end

if GLOBAL.DropReelEnabled then
    print("部分掉落卷轴已激活")
    modimport("postinit/drop.lua")     --配方
end

if GLOBAL.GemWORMWOOD then
    print("部分掉落卷轴已激活")
    modimport("postinit/renwu.lua")     --配方
end

if GLOBAL.enable_new_effect then
    print("添加新附魔石已激活")
    modimport("postinit/addNewEffect.lua")     --配方
end

if GLOBAL.EnableTrueMeleeEnchantStone then
    print("真近战附魔石已激活")
    modimport("postinit/true_melee_enchant.lua")
end

if GLOBAL.EnableCompoundCommonImmunityStones then
    print("复合普通附魔石已激活")
    modimport("postinit/compound_common_immunity_stones.lua")
end

if GLOBAL.UnknownTagEnabled then
    modimport("postinit/stride_bead_patch.lua")
    if GLOBAL.EnableMediumHasteEnchantStone then
        modimport("postinit/medium_haste_enchant.lua")
    end
    if GLOBAL.EnableRareSlideEnchantStone then
        modimport("postinit/rare_slide_enchant.lua")
    end
    if GLOBAL.EnableAttackRangeGem then
        modimport("postinit/attack_range_gem.lua")
    end
end

if GLOBAL.UnknownTagEnabled then
    modimport("postinit/gem_level_system.lua")
    if GLOBAL.EnableGemConvert then
        modimport("postinit/gem_convert_ui.lua")
    end
end

if GLOBAL.EnableMonsterSpitSkill or GLOBAL.EnableMonsterShockwaveSkill or GLOBAL.EnableMonsterChargeSkill or GLOBAL.EnableMonsterPounceSkill or GLOBAL.EnableMonsterBarrageSkill or GLOBAL.EnableMonsterTrapSkill or GLOBAL.EnableMonsterBoltSkill or GLOBAL.EnableMonsterFreezeRingSkill or GLOBAL.EnableMonsterFireRingSkill or GLOBAL.EnableMonsterFlameConeSkill or GLOBAL.EnableMonsterTwinLaserSkill or GLOBAL.EnableMonsterTwinDashSkill or GLOBAL.EnableMonsterTwinHellfireSkill then
    print("怪物技能词条已激活")
    modimport("postinit/monster_skill_effects.lua")
end

GLOBAL.MonsterPlayerEffectsEnabled = GetModConfigData("enable_monster_player_effects") or false
if GLOBAL.MonsterPlayerEffectsEnabled then
    print("怪物玩家词条扩展已激活")
    modimport("postinit/monster_player_effects.lua")
end

GLOBAL.EnableLifeEnchantStone = GetModConfigData("enable_life_enchant_stone") or false
if GLOBAL.EnableLifeEnchantStone then
    print("生命附魔石随机池已开启")
    modimport("postinit/life_enchant_stone.lua")
end

GLOBAL.RemovePlayerEffectsEnabled = GetModConfigData("remove_player_effects") or false
if GLOBAL.RemovePlayerEffectsEnabled then
    print("移除部分玩家词条已激活")
    modimport("postinit/remove_player_effects.lua")
end

GLOBAL.RemoveTreasureMonstersEnabled = GetModConfigData("remove_treasure_monsters") ~= false
if GLOBAL.RemoveTreasureMonstersEnabled then
    print("移除宝藏怪已激活")
    modimport("postinit/remove_treasure_monsters.lua")
end

GLOBAL.EnableLongRangeEnchantRestriction = GetModConfigData("enable_long_range_enchant_restriction") ~= false

if GLOBAL.UnknownTagEnabled then
    modimport("postinit/suppress_effect.lua")
    modimport("postinit/effect_caps.lua")
    modimport("postinit/drop_eligibility.lua")
    if GLOBAL.EnableLongRangeEnchantRestriction then
        modimport("postinit/enchant_restrictions.lua")
    end
    modimport("postinit/treasure_boss_shared_reward.lua")
end

modimport("postinit/other.lua")     --其他杂项

-- 更新日志注入到本体mod界面
if GLOBAL.UnknownTagEnabled then
    modimport("postinit/update_log.lua")
end
