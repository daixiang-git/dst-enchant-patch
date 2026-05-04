----
--- 附魔限制
--- 武器攻击距离 >= 3 时，禁止附魔
----

local function IsLongRangeWeapon(inst)
    if not inst or not inst.components or not inst.components.weapon then
        return false
    end

    local weapon = inst.components.weapon
    local range = weapon.attackrange

    if type(range) ~= "number" and weapon.GetRange then
        local ok, value = pcall(function()
            return weapon:GetRange()
        end)
        if ok then
            range = value
        end
    end

    return type(range) == "number" and range >= 3
end

AddComponentPostInit("hh_equip", function(self)
    if self._hh_patch_enchant_restriction_hooked then
        return
    end
    self._hh_patch_enchant_restriction_hooked = true

    local old_AddEquipBuff = self.AddEquipBuff
    self.AddEquipBuff = function(self, ...)
        if IsLongRangeWeapon(self.inst) then
            return false, "攻击距离大于等于3的武器禁止附魔"
        end
        return old_AddEquipBuff(self, ...)
    end
end)

print("[附魔补丁] 附魔限制已启用: 攻击距离>=3的武器禁止附魔")
