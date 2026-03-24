local TREASURE_BOSS_RADIUS = 16

local TREASURE_BOSS_NAMES = {
    mutateddeerclops_boss = "超级巨鹿",
    mutatedbearger_boss = "超级熊大",
    hh_sharkboi_boss = "超级鲨鱼",
    mutatedwarg_boss = "附身狼王",
    hh_beetle_pig_boss = "大猪知非",
    hh_dual_wield_pig_boss = "笨比林猪",
}

local function HasComponents(inst, component_name)
    return inst ~= nil
        and inst.components ~= nil
        and inst.components[component_name] ~= nil
end

local function RewardTreasureGem(player)
    if not HasComponents(player, "hh_player") then
        return
    end

    local rand = math.random()
    if rand < 0.3 then
        player.components.hh_player:AddItemsByKey("treasure_atk", 1, true)
    elseif rand < 0.6 then
        player.components.hh_player:AddItemsByKey("treasure_bj", 1, true)
    else
        player.components.hh_player:AddItemsByKey("treasure_armor", 1, true)
    end
end

local function RewardNearbyPlayers(inst, boss_name, killer)
    if inst == nil or inst.Transform == nil then
        return
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, TREASURE_BOSS_RADIUS, { "player" }, { "playerghost", "INLIMBO" })
    for _, player in ipairs(ents) do
        if player ~= nil and player:IsValid() and HasComponents(player, "hh_player") then
            if killer == nil or player ~= killer then
                RewardTreasureGem(player)
            end
        end
    end
end

for prefab, boss_name in pairs(TREASURE_BOSS_NAMES) do
    AddPrefabPostInit(prefab, function(inst)
        if not TheWorld.ismastersim then
            return
        end

        inst:ListenForEvent("death", function(hh_inst, data)
            local killer = data ~= nil and data.afflicter or nil
            if killer ~= nil and not HasComponents(killer, "hh_player") then
                killer = nil
            end
            RewardNearbyPlayers(hh_inst, boss_name, killer)
        end)
    end)
end
