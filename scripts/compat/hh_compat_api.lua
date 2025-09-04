local HHCompatAPI = Class(function(self)
    self.registered_mobs = {}
end)

-- 注册单个生物
function HHCompatAPI:RegisterMob(prefab, tags)
    self.registered_mobs[prefab] = tags
end

-- 批量注册多个生物
function HHCompatAPI:RegisterMobs(mob_table)
    for prefab, tags in pairs(mob_table) do
        self:RegisterMob(prefab, tags)
    end
end

-- 应用标签
function HHCompatAPI:ApplyTags(inst)
    if not TheWorld.ismastersim then return end
    
    local prefab_name = inst.prefab
    local tags = self.registered_mobs[prefab_name]
    
    if tags and not inst.hh_tags_applied then
        if not inst.hh_tags then
            inst.hh_tags = {}
        end
        
        if not inst.components.hh_monster then
            inst:AddComponent("hh_monster")
        end
        
        for category, desc in pairs(tags) do
            inst.hh_tags[category] = desc
            inst:AddTag("hh_" .. category)
        end
        
        inst.hh_tags_applied = true
        --print("[HH兼容] 成功为", prefab_name, "添加标签:", table.concat(table.getkeys(tags), ", "))
    end
end

-- 获取所有已注册的生物
function HHCompatAPI:GetRegisteredMobs()
    return self.registered_mobs
end

return HHCompatAPI