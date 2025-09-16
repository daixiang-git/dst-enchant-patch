-- 检查模组是否启用
if not GLOBAL.KnownModIndex:IsModEnabled("workshop-1909182187") then return end

local HHCompatAPI = GLOBAL.HHCompatAPI

-- 同步到主模组的 hh_prefab_list
local function SyncToHHPrefabList(prefab, tag)
    local hh_prefab_list = GLOBAL.require("enums/hh_prefab_list")
    if hh_prefab_list then
        hh_prefab_list[tag] = hh_prefab_list[tag] or {}
        hh_prefab_list[tag][prefab] = true
    end
end

AddSimPostInit(function()
    -- 定义主模组的混淆标签
    local boss_tag = string.char(0x62, 0x6f, 0x73, 0x73, 0x5f, 0x6d, 0x6f, 0x6e,
                                 0x73, 0x74, 0x65, 0x72) -- "boss_monster"
    local elite_tag = string.char(0x65, 0x6c, 0x69, 0x74, 0x65, 0x5f, 0x6d,
                                  0x6f, 0x6e, 0x73, 0x74, 0x65, 0x72) -- "elite_monster"
    local common_tag = string.char(0x63, 0x6f, 0x6d, 0x6d, 0x6f, 0x6e, 0x5f,
                                   0x6d, 0x6f, 0x6e, 0x73, 0x74, 0x65, 0x72) -- "common_monster"

    -- 批量注册模组的生物，保留所有标签
    local prism_mobs = {
        ["medal_spike_med"] = {
            [common_tag] = "普通" -- 时空之刃
        },
        ["medal_spike_short"] = {
            [common_tag] = "普通" -- 时空之刃
        },
        ["medal_spike_tall"] = {
            [common_tag] = "普通" -- 时空之刃
        },
        ["medal_naughty_krampus"] = {
            [common_tag] = "普通" -- 复仇坎普斯
        },
        ["medal_rage_krampus"] = {
            ["shadow"] = "暗影", -- 暗夜坎普斯
            [elite_tag] = "精英"
        },
        ["medal_beequeen"] = {
            ["insect"] = "昆虫", -- 凋零之蜂（保留原模组昆虫标签不知道有什么效果）
            [elite_tag] = "精英"
        },
        ["medal_beeguard"] = {
            ["insect"] = "昆虫", -- 堕落之蜂
            [common_tag] = "普通"
        },
        ["medal_shadowthrall_screamer"] = {
            ["shadowthrall"] = "混沌", -- 驱光遗骸（自定义标签）
            [elite_tag] = "精英"
        }
    }

    -- 注册到 HHCompatAPI
    HHCompatAPI:RegisterMobs(prism_mobs)

    -- 同步到 hh_prefab_list 并为怪物添加组件
    for prefab, tags in pairs(prism_mobs) do
        -- 同步所有标签到 hh_prefab_list（包括自定义标签如 insect）
        for tag in pairs(tags) do SyncToHHPrefabList(prefab, tag) end
        AddPrefabPostInit(prefab, function(inst)
            if not GLOBAL.TheWorld.ismastersim then return end
            if not inst.components.hh_monster then
                inst:AddComponent("hh_monster")
            end
            HHCompatAPI:ApplyTags(inst)
        end)
    end

    print("[HH兼容] 能力勋章模组兼容已激活")
end)
