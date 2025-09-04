GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })

-- 读取配置
GLOBAL.UnknownTagEnabled = GetModConfigData("ENABLE_UNKNOWN_TAG") or false
GLOBAL.RangedWeaponsEnabled = GetModConfigData("ENABLE_RANGED_WEAPONS") or false
GLOBAL.BenyuanXZEnabled = GetModConfigData("ENABLE_BENYUAN_XZ") or false
GLOBAL.DropReelEnabled = GetModConfigData("ENABLE_DROP_SYSTEM") or false
GLOBAL.GemEnabled = GetModConfigData("ENABLE_GEM") or false
GLOBAL.GemWORMWOOD = GetModConfigData("ENABLE_WORMWOOD") or false


if GLOBAL.UnknownTagEnabled then
    print("附魔补丁已激活")
    modimport("postinit/fumo.lua")     --配方
end


if GLOBAL.RangedWeaponsEnabled then
    print("远程武器禁用模式已激活")
    modimport("postinit/peifang.lua")     --配方
end

if GLOBAL.GemEnabled then
    print("宝石制作模式已激活")
    modimport("postinit/gem.lua")     --配方
end

if GLOBAL.DropReelEnabled then
    print("部分掉落卷轴已激活")
    modimport("postinit/drop.lua")     --配方
end

if GLOBAL.GemWORMWOOD then
    print("部分掉落卷轴已激活")
    modimport("postinit/renwu.lua")     --配方
end
modimport("postinit/other.lua")     --其他杂项
