GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })

-- 配置常量
local CONFIG = {
    COOKING_DROP_CHANCE = GetModConfigData("COOKING_DROP_RATE"),
    OVERSIZED_DROP_CHANCE = GetModConfigData("OVERSIZED_DROP_RATE"),
    CHOP_DROP_CHANCE = GetModConfigData("CHOP_DROP_RATE"),
    MINE_DROP_CHANCE = GetModConfigData("MINE_DROP_RATE"),
    FISH_DROP_CHANCE = GetModConfigData("FISH_DROP_RATE"),
    MAX_DAILY_TRIGGERS = GetModConfigData("MAX_DAILY_DROP_COUNT"),
    MAX_ITEM_TRIGGERS = GetModConfigData("MAX_ITEM_DROP_COUNT"),
    ENABLE_100_DAY_REWARD = GetModConfigData("ENABLE_100_DAY_REWARD"),
    ENABLE_DROP_SYSTEM = GetModConfigData("ENABLE_DROP_SYSTEM"),
}

-- 玩家记忆表结构: [userid] = { count = 总触发次数, day = 记录天数, items = {[prefab]=触发次数} }
local playerMemory = {}


-- 全局变量初始化
local players_100_day_reward = {}            -- 存储玩家奖励状态的缓存
local HUNDRED_DAY_KEY = "hh_100_day_rewards" -- 存储的键名

-- 持久化存储函数
local function Save100DayRewards()
    if TheWorld.ismastersim then
        local data = { players = players_100_day_reward }
        TheSim:SetPersistentString(HUNDRED_DAY_KEY, json.encode(data), false)
        print("[100天奖励] 奖励数据已保存")
    end
end

-- 加载存储的函数
local function Load100DayRewards()
    TheSim:GetPersistentString(HUNDRED_DAY_KEY, function(load_success, json_data)
        if load_success and json_data ~= "" then
            local success, data = pcall(json.decode, json_data)
            if success and data and data.players then
                players_100_day_reward = data.players
                print("[100天奖励] 已加载奖励数据")
            else
                print("[100天奖励] 错误: 奖励数据损坏")
            end
        else
            print("[100天奖励] 没有找到奖励数据或创建新记录")
        end
    end)
end

-- 玩家登入时检查是否已有记录
AddPlayerPostInit(function(player)
    player:ListenForEvent("ms_playerjoined", function()
        if TheWorld.ismastersim and CONFIG.ENABLE_100_DAY_REWARD then
            local userid = player.userid or "unknown"
            players_100_day_reward[userid] = players_100_day_reward[userid] or false
            print(string.format("[100天奖励] 玩家 %s 已登记 (已发放: %s)",
                player.name, players_100_day_reward[userid] and "是" or "否"))
        end
    end)
end)

-- 监听世界阶段变化
AddPrefabPostInit("world", function(inst)
    if not inst.ismastersim then return end

    -- 加载保存的数据
    Load100DayRewards()

    inst:WatchWorldState("phase", function(inst, phase)
        if phase == "day" then
            playerMemory = {}
            if CONFIG.ENABLE_100_DAY_REWARD then
                local current_day = GLOBAL.TheWorld.state.cycles

                if CONFIG.ENABLE_100_DAY_REWARD and current_day >= 100 then
                    for _, player in pairs(GLOBAL.AllPlayers) do
                        local userid = player.userid or "unknown"

                        if not players_100_day_reward[userid] then
                            if player.components and player.components.hh_player then
                                -- 发放奖励
                                player.components.hh_player:TestSpawnStone("immune_debuff", "元素防御")
                                players_100_day_reward[userid] = true -- 标记为已发放

                                if player.components.talker then
                                    player.components.talker:Say("恭喜生存满100天！获得元素防御附魔石奖励！")
                                end

                                print(string.format("[100天奖励] %s 获得元素防御附魔石（第%d天）",
                                    player.name, current_day))

                                -- 保存发放状态
                                Save100DayRewards()
                            end
                        end
                    end
                end
            end
        end
    end)

    -- 监听存档事件
    inst:ListenForEvent("ms_save", Save100DayRewards)

    -- 世界重置时清空数据
    inst:ListenForEvent("ms_worldreset", function()
        players_100_day_reward = {}
        Save100DayRewards()
        print("[100天奖励] 世界重置 - 奖励记录已清除")
    end)
end)


-- 工具函数
local function isValidPlayer(player)
    return player and player:IsValid() and player:HasTag("player") and player.userid
end

local function getItemName(prefab)
    return prefab == "hh_effect_tally" and "卷轴" or "石头"
end

local function logDrop(itemName, playerName, prefabName, totalCount, itemCount)
    print(string.format("[%s掉落] %s 获得 %s (总%d次，该物品%d次)",
        itemName, playerName, prefabName, totalCount, itemCount))
end

--黑名单物品列表
local BLACKLIST_PREFAB = {
    "wetgoop",     --潮湿黏糊
    "beefalofeed", --蒸树枝
    "snowcone"     --妥协冰沙
}

local BLACKLIST_PREFAB_HASH = {}
for _, v in ipairs(BLACKLIST_PREFAB) do BLACKLIST_PREFAB_HASH[v] = true end
BLACKLIST_PREFAB = nil

-- 核心掉落逻辑
local function CheckAndDropGold(harvester, prefabName, position, dropChance)
    if BLACKLIST_PREFAB_HASH[prefabName] then
        return
    end
    if not GLOBAL.TheWorld.ismastersim then return end
    if not CONFIG.ENABLE_DROP_SYSTEM then return end
    if not isValidPlayer(harvester) then return end

    local userid = harvester.userid
    local currentDay = GLOBAL.TheWorld.state.cycles

    -- 初始化玩家记忆
    if not playerMemory[userid] then
        playerMemory[userid] = {
            count = 0,
            day = currentDay,
            items = {}
        }
    end

    local playerData = playerMemory[userid]

    -- 检查是否是全新的一天
    if playerData.day ~= currentDay then
        playerData.count = 0
        playerData.day = currentDay
        playerData.items = {}
    end

    -- 检查限制
    local itemTriggers = playerData.items[prefabName] or 0
    if itemTriggers >= CONFIG.MAX_ITEM_TRIGGERS or playerData.count >= CONFIG.MAX_DAILY_TRIGGERS then
        return
    end

    -- 概率判定
    if math.random() < dropChance then
        local itemToSpawn = math.random() < 0.5 and "hh_effect_tally" or "hh_remove_stone"
        GLOBAL.SpawnPrefab(itemToSpawn).Transform:SetPosition(position:Get())

        -- 更新记忆
        playerData.count = playerData.count + 1
        itemTriggers = itemTriggers + 1
        playerData.items[prefabName] = itemTriggers

        -- 玩家提示
        local remaining = CONFIG.MAX_DAILY_TRIGGERS - playerData.count
        local itemRemaining = CONFIG.MAX_ITEM_TRIGGERS - itemTriggers
        local itemName = getItemName(itemToSpawn)

        if harvester.components.talker then
            harvester.components.talker:Say(string.format("幸运收获%s！剩余次数:%d，该物品剩余:%d",
                itemName, remaining, itemRemaining))
        end

        logDrop(itemName, harvester.name, prefabName, playerData.count, itemTriggers)
    end
end


-- 烹饪锅收获逻辑
AddComponentPostInit("stewer", function(self)
    local _Harvest = self.Harvest
    self.Harvest = function(self, harvester, ...)
        local product_prefab = self.product
        local result = _Harvest(self, harvester, ...)
        if result and product_prefab and isValidPlayer(harvester) then
            CheckAndDropGold(harvester, product_prefab, self.inst:GetPosition(), CONFIG.COOKING_DROP_CHANCE)
        end
        return result
    end
end)

-- 巨大作物处理（内存优化版本）
local allOversizeds = {
    "asparagus_oversized",
    "garlic_oversized",
    "pumpkin_oversized",
    "corn_oversized",
    "onion_oversized",
    "potato_oversized",
    "dragonfruit_oversized",
    "pomegranate_oversized",
    "eggplant_oversized",
    "tomato_oversized",
    "watermelon_oversized",
    "pepper_oversized",
    "durian_oversized",
    "carrot_oversized",
    "immortal_fruit_oversized",
    "medal_gift_fruit_oversized",
}

for _, v in pairs(allOversizeds) do
    AddPrefabPostInit(v, function(inst)
        local workable = inst.components.workable
        if workable == nil then
            return
        end
        local old_finish = workable.onfinish
        workable:SetOnFinishCallback(function(workable_inst, worker)
            if isValidPlayer(worker) then
                CheckAndDropGold(worker, inst.prefab, inst:GetPosition(), CONFIG.OVERSIZED_DROP_CHANCE)
            end
            if old_finish then
                old_finish(workable_inst, worker)
            end
        end)
    end)
end
allOversizeds = nil


local function Onfinishwork(inst, data)
    local action_now = inst.components.workable and inst.components.workable.action and
        inst.components.workable.action.id
    if not action_now or data.worker == nil then
        return
    end

    if action_now == "CHOP" or action_now == "DIG" then
        CheckAndDropGold(data.worker, inst.prefab, inst:GetPosition(), CONFIG.CHOP_DROP_CHANCE)
        -- elseif action_now == "MINE" then
        --     print(string.format("[调试] 挖矿完成 目标=%s 玩家=%s 概率=%.2f",
        --         tostring(inst.prefab), tostring(data.worker.name), CONFIG.MINE_DROP_CHANCE))
        --     CheckAndDropGold(data.worker, inst.prefab, inst:GetPosition(), CONFIG.MINE_DROP_CHANCE)
    end
end


-- 统一的挖矿掉落逻辑
AddComponentPostInit("workable", function(self)
    local action_id = self.action and self.action.id
    if not action_id then
        return
    end
    local old_onfinish = self.onfinish
    self:SetOnFinishCallback(function(inst, worker)
        if worker and worker:IsValid() and worker:HasTag("player") then
            -- 以实例当前的action为准，避免中途切换造成判断不准
            local w = inst.components and inst.components.workable
            local action_now = (w and (w.workaction or (w.action and w.action.id))) or action_id
            if action_now == "MINE" then
                CheckAndDropGold(worker, inst.prefab, inst:GetPosition(), CONFIG.MINE_DROP_CHANCE)
            end
        end

        if old_onfinish ~= nil then
            old_onfinish(inst, worker)
        end
    end)
end)


--工作列表
local workList = {
    -- 矿石类
    -- "rock",
    -- "rock1",
    -- "rock2",
    -- "rock_flintless",
    -- "rock_flintless_med",
    -- "rock_flintless_low",
    -- "rock_petrified_tree",
    -- "rock_moon",
    -- "rock_ice",
    -- "stalagmite",
    -- "moonglass_rock",
    -- "stalagmite_full",
    -- "stalagmite_med",
    -- "stalagmite_low",
    -- "stalagmite_tall",
    -- "stalagmite_tall_full",
    -- "stalagmite_tall_med",
    -- "stalagmite_tall_low",
    -- "ancient_statue",
    -- "ruins_statue_mage",
    -- "ruins_statue_mage_nogem",
    -- "ruins_statue_head",
    -- "ruins_statue_head_nogem",
    -- "marbletree",
    -- "marbleshrub",

    -- 树木类
    "evergreen",
    "evergreen_short",
    "evergreen_normal",
    "evergreen_tall",
    "evergreen_sparse",
    "evergreen_sparse_normal",
    "evergreen_sparse_tall",
    "evergreen_sparse_short",
    "deciduoustree",
    "twiggytree",
    "mushtree_moon",
    "mushtree_tall",
    "mushtree_medium",
    "mushtree_small",
    "livingtree",
    "livingtree_full",
    "livingtree_half",
    "marsh_tree",
    "cave_banana_tree",
    "palmconetree_tall",
    "palmconetree_normal",
    "palmconetree_short",
    "moon_tree",
    "driftwood_tree",
    "driftwood_tall",
    "driftwood_small1",
    "driftwood_small2"
}

for _, v in pairs(workList) do
    AddPrefabPostInit(v, function(inst)
        --workable.onfinish 容易被官方逻辑替换掉，所以用事件机制更保险
        --"workfinished"事件在 workable.onfinish执行后才触发，inst已经是被remove的状态，没法执行我的逻辑了
        inst:ListenForEvent("workfinished", Onfinishwork)
    end)
end
workList = nil


-- 组件级钩子：钓鱼竿收获时触发
AddComponentPostInit("fishingrod", function(fishingrod)
    --hook收集函数，给玩家推送钓鱼的池塘
    local oldCollect = fishingrod.Collect
    fishingrod.Collect = function(self)
        --必须在收集完之前推，不然数据就被清掉了
        if self.caughtfish and self.fisherman and self.target then
            local pos = self.caughtfish.GetPosition and self.caughtfish:GetPosition() or self.fisherman:GetPosition()
            CheckAndDropGold(self.fisherman, self.caughtfish.prefab, pos, CONFIG.FISH_DROP_CHANCE)
        end
        if oldCollect then
            oldCollect(self)
        end
    end
end)
