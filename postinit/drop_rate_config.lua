--[[
    极品附魔石/装备包裹掉率配置修改
    作者：老斑鸠
    功能：自定义精英怪和Boss的极品附魔石、装备包裹掉落概率
    
    配置项：
    - player_gem_drop_rate: 宝石/特殊道具掉率（默认0.01）
    - elite_stone_drop_rate: 精英极品附魔石掉率（默认0.05）
    - elite_gif_drop_rate: 精英装备包裹掉率（默认0.01）
    - boss_stone_drop_rate: Boss极品附魔石掉率（默认0.2）
    - boss_gif_drop_rate: Boss装备包裹掉率（默认0.03）
]]--

-- 获取配置
local player_gem_rate = GetModConfigData("player_gem_drop_rate") or 0.05
local elite_stone_rate = GetModConfigData("elite_stone_drop_rate") or 0.05
local elite_gif_rate = GetModConfigData("elite_gif_drop_rate") or 0.01
local boss_stone_rate = GetModConfigData("boss_stone_drop_rate") or 0.2
local boss_gif_rate = GetModConfigData("boss_gif_drop_rate") or 0.03

-- 配置键名（与本体mod保持一致，无混淆）
local HH_CHANCE_CONFIG = "HH_CHANCE_CONFIG"
local GIF_CHANCE = "GIF_CHANCE"

-- 更新概率表显示文本（与本体mod的getChanceDesc函数一致）
local function updateChanceText()
    local config = TUNING[HH_CHANCE_CONFIG] or {}
    local drop_equip = config["DROP_EQUIP_CHANCE"] or {}
    local gif_chance = config[GIF_CHANCE] or {}
    
    local hh_table = {
        string.format("装备-普通生物:%s%%\n", (drop_equip["common_monster"] or 0) * 100),
        string.format("装备-精英生物:%s%%\n", (drop_equip["elite_monster"] or 0) * 100),
        string.format("装备-boss生物:%s%%\n", (drop_equip["boss_monster"] or 0) * 100),
        string.format("宝石/特殊道具:%s%%\n", (gif_chance["player_gem_chance"] or 0) * 100),
        string.format("附魔卷轴/洗蕴石:%s%%\n", (gif_chance["player_stone_chance"] or 0) * 50),
        string.format("极品附魔石-精英:%s%%\n", (gif_chance["elite_monster_stone"] or 0) * 100),
        string.format("极品附魔石-boss:%s%%\n", (gif_chance["boss_monster_stone"] or 0) * 100),
        string.format("装备包裹-精英:%s%%\n", (gif_chance["elite_monster_gif"] or 0) * 100),
        string.format("装备包裹-boss:%s%%\n", (gif_chance["boss_monster_gif"] or 0) * 100),
    }
    
    local result = table.concat(hh_table)
    
    -- 本体帮助页实际读取的是 HH_UI_TEXT.CHANCE_TEXT。
    if TUNING["HH_UI_TEXT"] then
        TUNING["HH_UI_TEXT"]["CHANCE_TEXT"] = result
    end
    if TUNING["HH_FORMAT_CONFIG"] then
        TUNING["HH_FORMAT_CONFIG"]["CHANCE_TEXT"] = result
    end
    print("[附魔补丁] 概率表UI文本已更新")
end

-- 修改TUNING配置
local function updateDropRateConfig()
    if not TUNING[HH_CHANCE_CONFIG] then
        TUNING[HH_CHANCE_CONFIG] = {}
    end
    
    if not TUNING[HH_CHANCE_CONFIG][GIF_CHANCE] then
        TUNING[HH_CHANCE_CONFIG][GIF_CHANCE] = {}
    end

    -- 修改宝石/特殊道具掉率
    TUNING[HH_CHANCE_CONFIG][GIF_CHANCE].player_gem_chance = player_gem_rate
    
    -- 修改极品附魔石掉率
    TUNING[HH_CHANCE_CONFIG][GIF_CHANCE].elite_monster_stone = elite_stone_rate
    TUNING[HH_CHANCE_CONFIG][GIF_CHANCE].boss_monster_stone = boss_stone_rate
    
    -- 修改装备包裹掉率
    TUNING[HH_CHANCE_CONFIG][GIF_CHANCE].elite_monster_gif = elite_gif_rate
    TUNING[HH_CHANCE_CONFIG][GIF_CHANCE].boss_monster_gif = boss_gif_rate
    
    -- 更新概率表UI显示（必须在CHANCE_TEXT被计算之前执行）
    updateChanceText()
    
    print(string.format("[附魔补丁] 宝石/特殊道具掉率:%.1f%%",
        player_gem_rate * 100))
    print(string.format("[附魔补丁] 极品附魔石掉率 - 精英:%.1f%% Boss:%.1f%%", 
        elite_stone_rate * 100, boss_stone_rate * 100))
    print(string.format("[附魔补丁] 装备包裹掉率 - 精英:%.1f%% Boss:%.1f%%", 
        elite_gif_rate * 100, boss_gif_rate * 100))
end

-- 立即执行，不使用AddSimPostInit
-- 因为CHANCE_TEXT在mod加载时就计算好了，必须在那时之前修改配置
updateDropRateConfig()

-- 补丁mod晚于本体加载时，再次刷新帮助页显示文本。
AddSimPostInit(function()
    updateChanceText()
end)
