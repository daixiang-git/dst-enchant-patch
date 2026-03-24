local REMOVED_TREASURE_MONSTERS = {
    treasure_kps = true,
    treasure_cat_you = true,
}

local function RemoveFromTreasureConfig(config)
    if type(config) ~= "table" then
        return
    end

    for prefab in pairs(REMOVED_TREASURE_MONSTERS) do
        config[prefab] = nil
    end
end

local function PatchTreasureConfig()
    if TUNING then
        RemoveFromTreasureConfig(TUNING.HH_TREASURE_MONSTER_CONFIG)
    end

    local module_names = {
        "scripts/enums/hh_treasure_monster",
        "enums/hh_treasure_monster",
        "hh_treasure_monster",
    }

    for _, module_name in ipairs(module_names) do
        local ok, treasure_module = pcall(require, module_name)
        if ok and type(treasure_module) == "table" then
            RemoveFromTreasureConfig(treasure_module.TREASURE_MONSTER_CONFIG)
        end
    end
end

for prefab in pairs(REMOVED_TREASURE_MONSTERS) do
    AddPrefabPostInit(prefab, function(inst)
        if not TheWorld.ismastersim then
            return
        end

        inst:DoTaskInTime(0, function()
            if inst:IsValid() then
                inst:Remove()
            end
        end)
    end)
end

PatchTreasureConfig()

AddSimPostInit(function()
    PatchTreasureConfig()
end)
