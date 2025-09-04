-- 检查模组是否启用
if not GLOBAL.KnownModIndex:IsModEnabled("workshop-3235319974") then return end

if not GLOBAL.WormEnabled then
    return
end

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
    local boss_tag = string.char(0x62,0x6f,0x73,0x73,0x5f,0x6d,0x6f,0x6e,0x73,0x74,0x65,0x72) -- "boss_monster"
    local elite_tag = string.char(0x65,0x6c,0x69,0x74,0x65,0x5f,0x6d,0x6f,0x6e,0x73,0x74,0x65,0x72) -- "elite_monster"
    local common_tag = string.char(0x63,0x6f,0x6d,0x6d,0x6f,0x6e,0x5f,0x6d,0x6f,0x6e,0x73,0x74,0x65,0x72) -- "common_monster"

    -- 批量注册模组的生物，保留所有标签
    local prism_mobs = {
        ["xd_baihu"] = {
            ["wxj"] = "五行-金", 
            [boss_tag] = "BOSS"
        },
        ["xd_qlch"] = {
            ["wxt"] = "五行-土",           -- 保留自定义标签
            [boss_tag] = "BOSS"
        },
		["xd_qlch_fs"] = {
            ["wxt"] = "五行-土",           -- 保留自定义标签
            [boss_tag] = "BOSS"
        },
        ["xd_jfsn"] = {
            ["wxh"] = "五行-火",           -- 保留自定义标签
            [boss_tag] = "BOSS"
        },
        ["xd_spiderqueen"] = {
            ["spider"] = "蜘蛛",           --不知道原模组的分类标签有没有特殊效果
            [elite_tag] = "精英"
        },
        ["xd_spider"] = {
            ["spider"] = "蜘蛛",
            [common_tag] = "普通"
        },
		["xd_ziyunboss"] = {
            [boss_tag] = "BOSS"
        },
		["xd_deerclops_ziyun"] = {
            ["xd_hp"] = "魂魄",
            [boss_tag] = "BOSS"
        },
		["xd_futu"] = {
            [boss_tag] = "BOSS"
        },
		["xd_pog"] = {
            [common_tag] = "普通"
        },
    }

    -- 注册到 HHCompatAPI
    HHCompatAPI:RegisterMobs(prism_mobs)

    -- 同步到 hh_prefab_list 并为怪物添加组件
    for prefab, tags in pairs(prism_mobs) do
        -- 同步所有标签到 hh_prefab_list（包括自定义标签如 insect）
        for tag in pairs(tags) do
            SyncToHHPrefabList(prefab, tag)
        end
        AddPrefabPostInit(prefab, function(inst)
            if not GLOBAL.TheWorld.ismastersim then return end
            if not inst.components.hh_monster then
                inst:AddComponent("hh_monster")
            end
            HHCompatAPI:ApplyTags(inst)
        end)
    end

    print("[HH兼容] 登仙模组兼容已激活")
end)