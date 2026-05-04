local function HasComponents(inst, ...)
    if inst == nil or inst.components == nil then
        return false
    end

    for i = 1, select("#", ...) do
        local name = select(i, ...)
        if inst.components[name] == nil then
            return false
        end
    end

    return true
end

local function ShouldAllowTargetDrop(target)
    if target == nil or not target:IsValid() then
        return false
    end
    if not HasComponents(target, "lootdropper") then
        return false
    end
    if HasComponents(target, "follower") then
        return false
    end
    return true
end

AddComponentPostInit("hh_player", function(self)
    if self == nil or self._hh_patch_drop_eligibility_hooked then
        return
    end
    self._hh_patch_drop_eligibility_hooked = true

    local old_DropSpecialGif = self.DropSpecialGif
    self.DropSpecialGif = function(self, target)
        if not ShouldAllowTargetDrop(target) then
            return
        end
        if old_DropSpecialGif ~= nil then
            return old_DropSpecialGif(self, target)
        end
    end
end)

print("[附魔补丁] 已修正玩家击杀附魔掉落判断：目标无lootdropper不掉，有follower不掉")
