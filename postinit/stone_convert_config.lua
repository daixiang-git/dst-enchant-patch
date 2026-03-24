--[[
    水晶小人转换附魔石概率修改
    作者：老斑鸠
    功能：修改水晶小人转换附魔石获得稀有/超级稀有词条的概率
    
    本体默认概率：
    - 超级稀有词条：1%
    - 稀有词条：4%（实际代码中是5%-1%=4%）
    - 普通词条：95%
    
    注意：稀有概率包含超级稀有概率的扣除
]]--

-- 获取配置
local rare_rate = GetModConfigData("stone_convert_rare_rate") or 0.05
local super_rare_rate = GetModConfigData("stone_convert_super_rare_rate") or 0.01

-- 将概率转换为1-100的整数
local super_rare_threshold = math.floor(super_rare_rate * 100)
local rare_threshold = math.floor(rare_rate * 100)

-- 确保超级稀有不超过稀有
if super_rare_threshold > rare_threshold then
    super_rare_threshold = rare_threshold
end

-- 存储到TUNING供Hook使用
if not TUNING.HH_PATCH_CONFIG then
    TUNING.HH_PATCH_CONFIG = {}
end
TUNING.HH_PATCH_CONFIG.STONE_CONVERT = {
    super_rare_threshold = super_rare_threshold,
    rare_threshold = rare_threshold
}

print(string.format("[附魔补丁] 水晶小人转换概率 - 稀有:%d%% 超稀有:%d%%", 
    rare_threshold, super_rare_threshold))

-- Hook hh_player组件的AddReplaceStone方法
AddComponentPostInit("hh_player", function(self, inst)
    -- 保存原始方法引用
    local old_AddReplaceStone = self.AddReplaceStone
    
    -- 替换方法
    self.AddReplaceStone = function(self)
        -- 检查容器
        if not self.forge_container or not self.forge_container.components or not self.forge_container.components.container then
            return false, "未查到容器"
        end
        
        local player = self.inst
        local container = self.forge_container.components.container
        local effect_stone = container:GetItemInSlot(2)
        local pos = player:GetPosition()
        local player_name = player.name or player.prefab
        
        -- 检查附魔石
        if not effect_stone or effect_stone.prefab ~= "hh_effect_stone" then
            return false, "第一格放附魔石"
        end
        
        -- 检查水晶小人数量
        if not container:Has("hh_essence", 5) then
            return false, string.format("水晶小人数量不足-数量>=%s", 5)
        end
        
        -- 获取HH_EQUIP_BUFF_LIST（延迟获取，确保已定义）
        local HH_EQUIP_BUFF_LIST = rawget(_G, "HH_EQUIP_BUFF_LIST") or {}
        
        local old_effect = effect_stone.hh_effect
        
        -- 检查是否是普通附魔石（can_add标记）
        if HH_EQUIP_BUFF_LIST[old_effect] and not HH_EQUIP_BUFF_LIST[old_effect].can_add then
            return false, "只能转换普通附魔石"
        end
        
        -- 使用配置的概率
        local rand = math.random(1, 100)
        local new_stone = nil
        local is_super_rare = false
        
        -- 获取生成函数（延迟获取，确保已定义）
        local HHSpawnRareEffectStone = rawget(_G, "HHSpawnRareEffectStone")
        local HHSpawnGoodEffectStone = rawget(_G, "HHSpawnGoodEffectStone")
        local HHSpawnComEffectStone = rawget(_G, "HHSpawnComEffectStone")
        
        if rand <= super_rare_threshold then
            -- 超级稀有词条
            new_stone = HHSpawnRareEffectStone and HHSpawnRareEffectStone()
            if new_stone and new_stone.hh_effect then
                local effect_name = HH_EQUIP_BUFF_LIST[new_stone.hh_effect] and HH_EQUIP_BUFF_LIST[new_stone.hh_effect].name or "???"
                if TheNet then
                    TheNet:Announce(string.format("%s好运当头，合成出:超超超稀有的%s", tostring(player_name), tostring(effect_name)))
                end
                is_super_rare = true
            end
        elseif rand <= rare_threshold then
            -- 稀有词条
            new_stone = HHSpawnGoodEffectStone and HHSpawnGoodEffectStone()
            if new_stone and new_stone.hh_effect then
                local effect_name = HH_EQUIP_BUFF_LIST[new_stone.hh_effect] and HH_EQUIP_BUFF_LIST[new_stone.hh_effect].name or "???"
                if TheNet then
                    TheNet:Announce(string.format("%s运气爆棚，合成出-%s", tostring(player_name), tostring(effect_name)))
                end
            end
        else
            -- 普通词条
            new_stone = HHSpawnComEffectStone and HHSpawnComEffectStone()
        end
        
        if not new_stone then
            return false, "生成附魔石异常"
        end
        
        -- 更新皮肤
        local HHUtils = rawget(_G, "HHUtils")
        if HHUtils and HHUtils.UpdateSkinItem then
            HHUtils.UpdateSkinItem(player, new_stone)
        end
        
        -- 处理原附魔石的hh_data数据
        if effect_stone.components and effect_stone.components.hh_data then
            if is_super_rare then
                effect_stone.components.hh_data:SetParamsValue("draw_lots_num_rare", 0)
            else
                effect_stone.components.hh_data:DoDeltaParamValue("draw_lots_num_rare", 1)
            end
        end
        
        -- 移除原附魔石
        effect_stone:Remove()
        
        -- 消耗水晶小人
        container:ConsumeByName("hh_essence", 5)
        
        -- 给予新附魔石
        container:GiveItem(new_stone, 2, pos)
        
        return true, "合成成功"
    end
end)
