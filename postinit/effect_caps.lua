----
--- 玩家词条上限调整
--- 1. 暗影护盾上限 30%
--- 2. 伤害减免上限 50%
--- 3. 秋季战神仅按 1 条词条生效
--- 4. 白天/黄昏/夜晚增伤分别上限 100
----

local PLAYER_EFFECT_CAPS = {
    sanReplaceDamageChance = 30, -- 暗影护盾
    absorbDamage = 50,           -- 伤害减免-小/中/大 共用
    autumnGod = 1,               -- 秋季战神只按 1 层计算
    sunlightStrike = 100,        -- 白天增伤
    afterglowStrike = 100,       -- 黄昏增伤
    nightMenace = 100,           -- 夜晚增伤
}

AddComponentPostInit("hh_player", function(self)
    if self._hh_patch_effect_caps_hooked then
        return
    end
    self._hh_patch_effect_caps_hooked = true

    local old_GetEffectValueByKey = self.GetEffectValueByKey
    self.GetEffectValueByKey = function(self, key)
        local value = old_GetEffectValueByKey(self, key)
        local cap = PLAYER_EFFECT_CAPS[key]

        if cap ~= nil and type(value) == "number" and value > cap then
            return cap
        end

        return value
    end
end)

print("[附魔补丁] 玩家词条上限已调整: 暗影护盾30%, 伤害减免50%, 秋季战神单条生效, 昼/昏/夜增伤100封顶")
