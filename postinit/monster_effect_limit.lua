--[[
    怪物词条数量配置修改
    作者：老斑鸠
    功能：修改怪物词条数量上限和天数增长配置
    
    配置项：
    - common/elite/boss_monster_effect_limit: 各类怪物词条上限
    - common/elite/boss_base_effect_num: 各类怪物基础词条数量
    - effect_add_days: 每隔多少天增加1个词条
    
    实现原理：
    1. 修改TUNING中的全局配置（天数间隔、各级别上限）
    2. Hook AddFirstBuffs方法，使用分级别的base_num
    3. Hook UpdateDayEffect相关逻辑，确保天数增长也使用正确的base_num
]]--

-- 获取配置
local common_limit = GetModConfigData("common_monster_effect_limit") or 5
local elite_limit = GetModConfigData("elite_monster_effect_limit") or 7
local boss_limit = GetModConfigData("boss_monster_effect_limit") or 10
local common_base = GetModConfigData("common_base_effect_num") or 3
local elite_base = GetModConfigData("elite_base_effect_num") or 3
local boss_base = GetModConfigData("boss_base_effect_num") or 3
local add_days = GetModConfigData("effect_add_days") or 12

print(string.format("[附魔补丁] 怪物词条配置 - 普通[基础:%d 上限:%d] 精英[基础:%d 上限:%d] Boss[基础:%d 上限:%d] 天数间隔:%d", 
    common_base, common_limit, elite_base, elite_limit, boss_base, boss_limit, add_days))

-- 怪物类型标签（与本体mod保持一致）
local MONSTER_TYPES = {
    COMMON = "common_monster",
    ELITE = "elite_monster",
    BOSS = "boss_monster"
}

local HH_PREFAB_LIST = require("enums/hh_prefab_list")

-- 配置键名（与本体mod保持一致，无混淆）
local HH_CHANCE_CONFIG = "HH_CHANCE_CONFIG"
local MONSTER_EFFECT_NUM = "MONSTER_EFFECT_NUM"
local MONSTER_ADD_EFFECT_DATE = "MONSTER_ADD_EFFECT_DATE"

-- 各级别怪物的基础词条配置键
local BASE_EFFECT_NUM_CONFIG = "BASE_EFFECT_NUM_CONFIG"

-- 根据怪物类型获取基础词条数量
local function getBaseByType(monster_type)
    if monster_type == MONSTER_TYPES.BOSS then
        return boss_base
    elseif monster_type == MONSTER_TYPES.ELITE then
        return elite_base
    else
        return common_base
    end
end

-- 根据怪物类型获取上限值
local function getLimitByType(monster_type)
    if monster_type == MONSTER_TYPES.BOSS then
        return boss_limit
    elseif monster_type == MONSTER_TYPES.ELITE then
        return elite_limit
    else
        return common_limit
    end
end

local function getDayBonus()
    local cycles = TheWorld and TheWorld.state and TheWorld.state.cycles or 0
    local interval = math.max(1, add_days)
    return math.floor(cycles / interval) + 1
end

local function getDesiredEffectCount(monster_type)
    local base_num = getBaseByType(monster_type)
    local limit = getLimitByType(monster_type)
    return math.min(limit, base_num + getDayBonus())
end

local function getMonsterTypeFallback(inst, self)
    local monster_type = self and self.GetMonsterType and self:GetMonsterType() or nil
    if monster_type ~= nil then
        return monster_type
    end

    if inst == nil or inst.prefab == nil then
        return MONSTER_TYPES.COMMON
    end

    if HH_PREFAB_LIST.boss_monster and HH_PREFAB_LIST.boss_monster[inst.prefab] then
        return MONSTER_TYPES.BOSS
    elseif HH_PREFAB_LIST.elite_monster and HH_PREFAB_LIST.elite_monster[inst.prefab] then
        return MONSTER_TYPES.ELITE
    else
        return MONSTER_TYPES.COMMON
    end
end

-- 修改TUNING配置
local function updateTuningConfig()
    if not TUNING[HH_CHANCE_CONFIG] then
        TUNING[HH_CHANCE_CONFIG] = {}
    end
    
    -- 修改词条数量上限
    if not TUNING[HH_CHANCE_CONFIG][MONSTER_EFFECT_NUM] then
        TUNING[HH_CHANCE_CONFIG][MONSTER_EFFECT_NUM] = {}
    end
    
    -- 设置统一的base_num为最大值（实际使用时会按怪物类型覆盖）
    local max_base = math.max(common_base, elite_base, boss_base)
    TUNING[HH_CHANCE_CONFIG][MONSTER_EFFECT_NUM].base_num = max_base
    TUNING[HH_CHANCE_CONFIG][MONSTER_EFFECT_NUM].common_monster = common_limit
    TUNING[HH_CHANCE_CONFIG][MONSTER_EFFECT_NUM].elite_monster = elite_limit
    TUNING[HH_CHANCE_CONFIG][MONSTER_EFFECT_NUM].boss_monster = boss_limit
    
    -- 存储各级别基础词条数量供Hook使用
    TUNING[HH_CHANCE_CONFIG][BASE_EFFECT_NUM_CONFIG] = {
        common_monster = common_base,
        elite_monster = elite_base,
        boss_monster = boss_base
    }
    
    -- 修改天数增长配置
    TUNING[HH_CHANCE_CONFIG][MONSTER_ADD_EFFECT_DATE] = add_days
    
    print("[附魔补丁] TUNING配置已更新")
end

-- 立即尝试更新配置
updateTuningConfig()

-- 使用AddSimPostInit确保配置被正确设置
AddSimPostInit(function()
    updateTuningConfig()
end)

-- Hook hh_monster组件
AddComponentPostInit("hh_monster", function(self, inst)
    -- 保存原始方法
    local old_AddFirstBuffs = self.AddFirstBuffs
    local old_SetMaxEffectLimit = self.SetMaxEffectLimit
    
    -- 设置上限
    inst:DoTaskInTime(0, function()
        if not self or not inst then return end
        
        local monster_type = getMonsterTypeFallback(inst, self)
        
        local limit = getLimitByType(monster_type)
        
        if self.SetMaxEffectLimit then
            self:SetMaxEffectLimit(limit)
        end
    end)
    
    -- Hook AddFirstBuffs方法，使用分级别的base_num
    self.AddFirstBuffs = function(self)
        if not TheWorld or not TheWorld.state or not TheWorld.state.cycles then
            return
        end
        
        -- 获取怪物类型。新生成怪物此时常常还没写入 hh_monster_type，
        -- 需要回退到 prefab 列表判定，否则会直接跳过初始词条。
        local monster_type = getMonsterTypeFallback(self.inst, self)
        
        -- 获取该类型的基础词条数
        local effect_count = getDesiredEffectCount(monster_type)
        
        -- 当前已有词条数
        local current_count = self:GetAllBuffNum()
        
        -- 需要添加的词条数
        local to_add = effect_count - current_count
        
        if to_add > 0 then
            -- 先添加生命词条
            self:AddBuffByName("addMaxHealthNum")
            to_add = to_add - 1
            
            -- 添加剩余词条
            for i = 1, to_add do
                self:AddBuffByName()
            end
        end
    end
end)
