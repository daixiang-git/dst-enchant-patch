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


if GLOBAL.UnknownTagEnabled then
    print("附魔补丁已激活")
    modimport("postinit/fumo.lua")     --配方
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

GLOBAL.MonsterPlayerEffectsEnabled = GetModConfigData("enable_monster_player_effects") or false
if GLOBAL.MonsterPlayerEffectsEnabled then
    print("怪物玩家词条扩展已激活")
    modimport("postinit/monster_player_effects.lua")
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

if GLOBAL.UnknownTagEnabled then
    modimport("postinit/suppress_effect.lua")
    modimport("postinit/effect_caps.lua")
    modimport("postinit/enchant_restrictions.lua")
    modimport("postinit/treasure_boss_shared_reward.lua")
end

modimport("postinit/other.lua")     --其他杂项

-- 更新日志注入到本体mod界面
if GLOBAL.UnknownTagEnabled then
    modimport("postinit/update_log.lua")
end
