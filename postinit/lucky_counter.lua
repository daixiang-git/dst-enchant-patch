--[[
    累计保底计数系统
    作者：老斑鸠
    功能：转换水晶小人、击杀精英怪、击杀Boss分别累计计数，达到阈值必定获得稀有词条
    
    计数来源（独立计数）：
    - 转换水晶小人
    - 击杀精英怪（仅限玩家或玩家召唤物击杀）
    - 击杀Boss（仅限玩家或玩家召唤物击杀）
    
    通告规则：
    - 计数是10的倍数时全服通告进度
    - 达到阈值时100%掉落稀有词条并全服通告，计数重置
]]--

-- 获取配置
local stone_convert_threshold = GetModConfigData("stone_convert_threshold") or 20
local elite_kill_threshold = GetModConfigData("elite_kill_threshold") or 20
local boss_kill_threshold = GetModConfigData("boss_kill_threshold") or 10

print(string.format("[附魔补丁] 累计保底系统 - 水晶小人:%d次 精英怪:%d次 Boss:%d次", 
    stone_convert_threshold, elite_kill_threshold, boss_kill_threshold))

-- 存储到TUNING
if not TUNING.HH_PATCH_CONFIG then
    TUNING.HH_PATCH_CONFIG = {}
end
TUNING.HH_PATCH_CONFIG.LUCKY_COUNTER = {
    stone_convert = stone_convert_threshold,
    elite_kill = elite_kill_threshold,
    boss_kill = boss_kill_threshold
}

-- 存储键名（用于本体mod的hh_world组件）
local LUCKY_COUNTER_KEY = "lucky_counter"

-- 计数类型
local COUNTER_TYPE = {
    STONE_CONVERT = "stone_convert",
    ELITE_KILL = "elite_kill",
    BOSS_KILL = "boss_kill"
}

-- 获取对应类型的阈值
local function getThreshold(counter_type)
    if counter_type == COUNTER_TYPE.STONE_CONVERT then
        return stone_convert_threshold
    elseif counter_type == COUNTER_TYPE.ELITE_KILL then
        return elite_kill_threshold
    elseif counter_type == COUNTER_TYPE.BOSS_KILL then
        return boss_kill_threshold
    end
    return 50
end

-- 获取对应类型的名称
local function getTypeName(counter_type)
    if counter_type == COUNTER_TYPE.STONE_CONVERT then
        return "水晶小人转换"
    elseif counter_type == COUNTER_TYPE.ELITE_KILL then
        return "精英怪击杀"
    elseif counter_type == COUNTER_TYPE.BOSS_KILL then
        return "Boss击杀"
    end
    return "未知"
end

-- 获取玩家计数（使用本体mod的hh_world组件存储）
local function getPlayerCount(player, counter_type)
    if not player or not player.userid then return 0 end
    if not counter_type then return 0 end
    
    if TheWorld and TheWorld.components and TheWorld.components.hh_world then
        local hh_world = TheWorld.components.hh_world
        -- 使用本体mod的API获取数据
        local counter_data = hh_world:GetValueByUid(LUCKY_COUNTER_KEY, player.userid)
        if counter_data and type(counter_data) == "table" then
            return counter_data[counter_type] or 0
        end
    end
    
    return 0
end

-- 设置玩家计数（使用本体mod的hh_world组件存储）
local function setPlayerCount(player, counter_type, count)
    if not player or not player.userid then return end
    if not counter_type then return end
    
    count = count or 0
    
    if TheWorld and TheWorld.components and TheWorld.components.hh_world then
        local hh_world = TheWorld.components.hh_world
        -- 获取当前数据
        local counter_data = hh_world:GetValueByUid(LUCKY_COUNTER_KEY, player.userid)
        if not counter_data or type(counter_data) ~= "table" then
            counter_data = {}
        end
        -- 更新计数
        counter_data[counter_type] = count
        -- 保存数据
        hh_world:SetValueByUid(LUCKY_COUNTER_KEY, player.userid, counter_data)
    end
end

-- 增加玩家计数
local function addPlayerCount(player, counter_type, amount)
    if not player then return 0, false, false end
    
    amount = amount or 1
    local threshold = getThreshold(counter_type)
    local current = getPlayerCount(player, counter_type)
    local new_count = current + amount
    
    local is_milestone = (threshold >= 10) and (new_count % 10 == 0) and (new_count < threshold)
    local is_threshold = new_count >= threshold
    
    if is_threshold then
        new_count = 0
    end
    
    setPlayerCount(player, counter_type, new_count)
    
    return new_count, is_threshold, is_milestone, threshold
end

-- 获取玩家名称
local function getPlayerName(player)
    if not player then return "???" end
    return player.name or player.prefab or "???"
end

-- 通告
local function announce(msg)
    if TheNet then
        TheNet:Announce(msg)
    end
end

-- 给玩家稀有附魔石
local function giveRareStone(player)
    if not player then return nil end
    
    local pos = player:GetPosition()
    local stone = nil
    
    local HHSpawnGoodEffectStone = rawget(_G, "HHSpawnGoodEffectStone")
    if HHSpawnGoodEffectStone then
        stone = HHSpawnGoodEffectStone()
    end
    
    if stone then
        if player.components and player.components.inventory then
            player.components.inventory:GiveItem(stone, nil, pos)
        end
        return stone
    end
    
    return nil
end

-- 获取实际玩家（处理召唤物情况）
local function getRealPlayer(attacker)
    if not attacker then return nil end
    
    -- 检查是否是玩家
    if attacker.components and attacker.components.hh_player then
        return attacker
    end
    
    -- 检查是否是玩家召唤物
    if attacker.components and attacker.components.follower and attacker.components.follower.leader then
        local leader = attacker.components.follower.leader
        if leader and leader.components and leader.components.hh_player then
            return leader
        end
    end
    
    return nil
end

-- 使用本体mod的hh_world组件存储计数数据
-- 本体mod提供 SetValueByUid/GetValueByUid API，数据自动持久化

-- 初始化：确保存储表存在
AddComponentPostInit("hh_world", function(self, inst)
    -- 延迟初始化，确保组件完全加载
    inst:DoTaskInTime(0, function()
        -- 初始化存储表（如果不存在）
        local counter_data = self:GetValueByUid(LUCKY_COUNTER_KEY, "init")
        if not counter_data then
            self:SetValueByUid(LUCKY_COUNTER_KEY, "init", {initialized = true})
            print("[附魔补丁] 累计保底系统已初始化")
        end
    end)
end)

-- Hook水晶小人转换
AddComponentPostInit("hh_player", function(self, inst)
    local old_AddReplaceStone = self.AddReplaceStone
    
    self.AddReplaceStone = function(self)
        local result, msg = old_AddReplaceStone and old_AddReplaceStone(self)
        
        if result then
            local player = self.inst
            local player_name = getPlayerName(player)
            local type_name = getTypeName(COUNTER_TYPE.STONE_CONVERT)
            
            local new_count, is_threshold, is_milestone, threshold = addPlayerCount(player, COUNTER_TYPE.STONE_CONVERT, 1)
            
            if is_milestone then
                announce(string.format("【保底进度】%s%s累计%d次，距离保底还有%d次！", 
                    player_name, type_name, new_count, threshold - new_count))
            end
            
            if is_threshold then
                local stone = giveRareStone(player)
                if stone and stone.hh_effect then
                    local HH_EQUIP_BUFF_LIST = rawget(_G, "HH_EQUIP_BUFF_LIST") or {}
                    local effect_name = HH_EQUIP_BUFF_LIST[stone.hh_effect] and HH_EQUIP_BUFF_LIST[stone.hh_effect].name or "???"
                    announce(string.format("【保底达成】%s%s累计达到%d次，必定获得稀有词条-%s！", 
                        player_name, type_name, threshold, effect_name))
                end
            end
        end
        
        return result, msg
    end
end)

-- 判断怪物类型的辅助函数
-- 本体 mod 在 hh_monster.lua 中定义了怪物列表（使用混淆的变量名）
-- 我们需要在本体 mod 加载后才能访问这些列表
local BOSS_MONSTERS = nil
local ELITE_MONSTERS = nil

local function initMonsterLists()
    if BOSS_MONSTERS and ELITE_MONSTERS then return end
    
    -- 尝试从本体 mod 的全局变量获取
    -- hh_prefab_list.lua 返回的 table 包含 boss_monster 和 elite_monster 列表
    local ok, list = pcall(function()
        return require("enums/hh_prefab_list")
    end)
    
    if ok and list then
        BOSS_MONSTERS = list.boss_monster or {}
        ELITE_MONSTERS = list.elite_monster or {}
        print("[附魔补丁] 成功加载怪物列表")
    else
        print("[附魔补丁] 警告: 无法加载本体mod怪物列表")
        return
    end
end

local function getMonsterTypeByPrefab(prefab)
    if not prefab then return nil end
    initMonsterLists()
    if BOSS_MONSTERS[prefab] then
        return "boss_monster"
    elseif ELITE_MONSTERS[prefab] then
        return "elite_monster"
    end
    return nil
end

-- Hook怪物击杀掉落（通过Hook DropEquipByDead 函数）
AddComponentPostInit("hh_monster", function(self, inst)
    local old_DropEquipByDead = self.DropEquipByDead
    
    self.DropEquipByDead = function(self, attacker)
        -- 先调用原始函数处理掉落
        if old_DropEquipByDead then
            old_DropEquipByDead(self, attacker)
        end
        
        -- 处理保底计数
        if not attacker then return end
        
        local player = getRealPlayer(attacker)
        
        -- 只有玩家或玩家召唤物击杀才计数
        if not player then return end
        
        -- 获取怪物类型：优先从组件获取，否则根据prefab判断
        local monster_type = self:GetMonsterType()
        if not monster_type then
            monster_type = getMonsterTypeByPrefab(inst.prefab)
        end
        if not monster_type then return end
        
        local counter_type = nil
        if monster_type == "elite_monster" then
            counter_type = COUNTER_TYPE.ELITE_KILL
        elseif monster_type == "boss_monster" then
            counter_type = COUNTER_TYPE.BOSS_KILL
        else
            return
        end
        
        local player_name = getPlayerName(player)
        local type_name = getTypeName(counter_type)
        
        local new_count, is_threshold, is_milestone, threshold = addPlayerCount(player, counter_type, 1)
        
        print(string.format("[附魔补丁] %s击杀%s，%s计数: %d/%d", 
            player_name, inst.prefab or "???", type_name, new_count, threshold))
        
        if is_milestone then
            announce(string.format("【保底进度】%s%s累计%d次，距离保底还有%d次！", 
                player_name, type_name, new_count, threshold - new_count))
        end
        
        if is_threshold then
            local stone = giveRareStone(player)
            if stone and stone.hh_effect then
                -- 安全获取全局变量 HH_EQUIP_BUFF_LIST
                local HH_EQUIP_BUFF_LIST = rawget(_G, "HH_EQUIP_BUFF_LIST") or {}
                local effect_name = HH_EQUIP_BUFF_LIST[stone.hh_effect] and HH_EQUIP_BUFF_LIST[stone.hh_effect].name or "???"
                announce(string.format("【保底达成】%s%s累计达到%d次，必定获得稀有词条-%s！", 
                    player_name, type_name, threshold, effect_name))
            end
        end
    end
end)
