----
--- 移除部分玩家词条
--- 通过 Hook hh_player 组件，使指定词条效果值永远返回 0
--- 通过修改装备附魔枚举，从词条池中移除这些词条
----

-- 要移除的词条配置
-- player_key: hh_player组件中使用的键名（驼峰格式）
-- buff_id: HH_EQUIP_BUFF_LIST中的词条ID（下划线格式），套装效果设为nil
-- 注意：套装效果没有buff_id，只有player_key
local REMOVED_EFFECTS = {
    { player_key = "immuneSuppressNum", buff_id = nil, desc = "免疫制裁(套装)" },
    { player_key = "shadowCamp", buff_id = "shadow_camp", desc = "暗影伪装" },
    { player_key = "moonCamp", buff_id = "moon_camp", desc = "月灵伪装" },
}

-- 构建玩家效果键名快速查找表
local REMOVED_PLAYER_SET = {}
local REMOVED_BUFF_SET = {}
for _, effect in ipairs(REMOVED_EFFECTS) do
    REMOVED_PLAYER_SET[effect.player_key] = true
    if effect.buff_id then
        REMOVED_BUFF_SET[effect.buff_id] = true
    end
end

-- ============================================================
-- 1. Hook hh_player：使被移除的词条效果值永远返回 0
-- ============================================================
AddComponentPostInit("hh_player", function(self)
    local _orig_GetEffectValueByKey = self.GetEffectValueByKey
    self.GetEffectValueByKey = function(self, key)
        if REMOVED_PLAYER_SET[key] then
            return 0
        end
        return _orig_GetEffectValueByKey(self, key)
    end

    local _orig_HasSpecialEffect = self.HasSpecialEffect
    self.HasSpecialEffect = function(self, key)
        if REMOVED_PLAYER_SET[key] then
            return false
        end
        return _orig_HasSpecialEffect(self, key)
    end
end)

-- ============================================================
-- 1.1 Hook hh_equip：从卷轴随机附魔池中移除指定词条
-- ============================================================
AddComponentPostInit("hh_equip", function(self)
    local _orig_GetAllBuffByEquip = self.GetAllBuffByEquip
    self.GetAllBuffByEquip = function(self)
        local result = _orig_GetAllBuffByEquip(self) or {}
        local filtered = {}

        for _, buff_id in ipairs(result) do
            if not REMOVED_BUFF_SET[buff_id] then
                table.insert(filtered, buff_id)
            end
        end

        return filtered
    end
end)

-- ============================================================
-- 2. 从装备附魔词条池中移除，使新附魔不会再抽到这些词条
-- ============================================================
local function RemoveFromBuffPool()
    -- HH_EQUIP_BUFF_LIST 是全局变量，不是 TUNING 中的
    -- 方案：将 can_add 设为 false，而不是删除词条
    -- 这样词条仍存在但不会被随机抽到，避免遍历出错
    local HH_EQUIP_BUFF_LIST = rawget(_G, "HH_EQUIP_BUFF_LIST")
    if HH_EQUIP_BUFF_LIST then
        for _, effect in ipairs(REMOVED_EFFECTS) do
            if effect.buff_id and HH_EQUIP_BUFF_LIST[effect.buff_id] then
                -- 设置 can_add = false，禁止通过附魔石获取
                HH_EQUIP_BUFF_LIST[effect.buff_id].can_add = false
                print(string.format("[附魔补丁] 已禁止词条获取: %s", effect.desc))
            end
        end
    end

    local HH_GEM_BUFF_LIST = rawget(_G, "HH_GEM_BUFF_LIST")
    if HH_GEM_BUFF_LIST then
        for _, effect in ipairs(REMOVED_EFFECTS) do
            if effect.buff_id and HH_GEM_BUFF_LIST[effect.buff_id] then
                -- 设置 can_add = false，禁止通过宝石获取
                HH_GEM_BUFF_LIST[effect.buff_id].can_add = false
                print(string.format("[附魔补丁] 已禁止宝石词条获取: %s", effect.desc))
            end
        end
    end
end

-- ============================================================
-- 3. Hook 附魔石生成函数：阻止水晶转换/掉落直接生成被移除词条
-- ============================================================
local function WrapStoneSpawner(fn_name)
    local old_fn = rawget(_G, fn_name)
    if type(old_fn) ~= "function" then
        return
    end
    if rawget(_G, fn_name .. "_HH_PATCH_WRAPPED") then
        return
    end

    rawset(_G, fn_name, function(...)
        local stone = nil

        for _ = 1, 20 do
            stone = old_fn(...)
            local buff_id = stone and stone.hh_effect
            if not buff_id or not REMOVED_BUFF_SET[buff_id] then
                return stone
            end

            if stone.Remove then
                stone:Remove()
            end
        end

        return stone
    end)

    rawset(_G, fn_name .. "_HH_PATCH_WRAPPED", true)
end

local function WrapStoneSpawners()
    WrapStoneSpawner("HHSpawnComEffectStone")
    WrapStoneSpawner("HHSpawnGoodEffectStone")
    WrapStoneSpawner("HHSpawnRareEffectStone")
end

-- 立即执行一次
RemoveFromBuffPool()
WrapStoneSpawners()

-- 延迟执行确保本体mod已加载
AddSimPostInit(function()
    RemoveFromBuffPool()
    WrapStoneSpawners()
end)

local desc_list = {}
for _, effect in ipairs(REMOVED_EFFECTS) do
    table.insert(desc_list, effect.desc)
end
print("[附魔补丁] 已移除词条: " .. table.concat(desc_list, ", "))
