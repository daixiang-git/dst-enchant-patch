----
--- 制裁效果修改：
--- 1. 治疗效果从-90%改为-100%
--- 2. 制裁buff持续时间翻倍
--- 3. 同步帮助/词条文案显示
----
local SUPPRESS_BUFFS = {
    player_healthSuppressNum = true,
    monster_healthSuppressNum = true,
}

local function UpdateSuppressUIText()
    if TUNING and TUNING.HH_FORMAT_CONFIG then
        local buff = TUNING.HH_FORMAT_CONFIG.BUFF
        local monster = TUNING.HH_FORMAT_CONFIG.MONSTER_CONFIG

        if buff then
            buff.player_healthSuppressNum = "治疗效果-100%"
            buff.monster_healthSuppressNum = "治疗效果-100%"
        end

        if monster then
            monster.addSuppressAddHealth = "攻击有%s%%使目标获得治疗-100%%效果"
            monster.hitSuppressAddHealth = "使攻击者有%s%%获得治疗-100%%效果"
        end
    end
end

local function HookBuffDuration()
    AddComponentPostInit("hh_buff", function(self)
        if self._hh_patch_suppress_duration_hooked then
            return
        end
        self._hh_patch_suppress_duration_hooked = true

        local old_AddBuff = self.AddBuff
        self.AddBuff = function(self, buff_name, buff_time)
            if SUPPRESS_BUFFS[buff_name] and type(buff_time) == "number" and buff_time > 0 then
                buff_time = buff_time * 2
            end
            return old_AddBuff(self, buff_name, buff_time)
        end
    end)
end

local function HookHealthDoDelta()
    -- 获取原始的 health 组件
    local health = rawget(_G, "Health")
    if not health then return end

    if health._hh_patch_suppress_heal_hooked then
        return
    end
    health._hh_patch_suppress_heal_hooked = true
    
    -- 保存原始方法
    local original_DoDelta = health.DoDelta
    
    -- Hook DoDelta 方法
    health.DoDelta = function(self, amount, overtime, cause, ...)
        -- 检查是否是正向治疗（amount > 0）
        if amount and amount > 0 then
            -- 检查是否有制裁效果
            local hh_player = self.inst and self.inst.components and self.inst.components.hh_player
            if hh_player then
                local suppress_num = hh_player:GetEffectValueByKey("healthSuppressNum")
                if suppress_num and suppress_num > 0 then
                    -- 每层制裁效果减少100%治疗量
                    -- 当 suppress_num >= 1 时，治疗量为 0
                    amount = 0
                end
            end
        end
        
        -- 调用原始方法
        return original_DoDelta(self, amount, overtime, cause, ...)
    end
end

HookBuffDuration()

-- 在游戏初始化后执行
AddSimPostInit(function()
    HookHealthDoDelta()
    UpdateSuppressUIText()
end)

print("[附魔补丁] 制裁效果已修改: 时间翻倍, 治疗-100%")
