name = "老斑鸠自用兼容补丁"
description = "自用，侵权联系删除"
author = "老斑鸠"
version = "0.23"

api_version = 10
dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
all_clients_require_mod = true

icon_atlas = "modicon.xml"
icon = "modicon.tex"

server_filter_tags = {"compatibility", "enhancement", "enchantment"}
priority = -9999

configuration_options = {
    {
        name = "ENABLE_UNKNOWN_TAG",
        label = "启用附魔补丁",
        hover = "自用",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    }, {
        name = "ENABLE_RANGED_WEAPONS",
        label = "禁用远程武器（星星法杖和冰刃）",
        hover = "自用",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    }, {
        name = "ENABLE_WORM",
        label = "蠕虫变成普通怪",
        hover = "自用",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    }, {
        name = "ENABLE_LEIF",
        label = "树精变成普通怪",
        hover = "自用",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = false
    }, {
        name = "ENABLE_DAMAGE",
        label = "boss精英相互没有仇恨和伤害",
        hover = "自用",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    }, {
        name = "ENABLE_DROP_SYSTEM",
        label = "开启掉落系统",
        hover = "开启做饭、巨大作物、砍树、挖矿、钓鱼概率掉落卷轴",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    }, {
        name = "COOKING_DROP_RATE",
        label = "做饭卷轴掉落概率",
        hover = "自用",
        options = {
            {description = "1%", data = 0.01},
            {description = "2%", data = 0.02},
            {description = "3%", data = 0.03},
            {description = "4%", data = 0.04},
            {description = "5%", data = 0.05},
            {description = "6%", data = 0.06},
            {description = "7%", data = 0.07},
            {description = "8%", data = 0.08},
            {description = "9%", data = 0.09},
            {description = "10%", data = 0.1},
            {description = "20%", data = 0.2},
            {description = "30%", data = 0.3},
            {description = "40%", data = 0.4}, {description = "50%", data = 0.5}
        },
        default = 0.2
    }, {
        name = "OVERSIZED_DROP_RATE",
        label = "巨大作物卷轴掉落概率",
        hover = "自用",
        options = {
            {description = "1%", data = 0.01},
            {description = "2%", data = 0.02},
            {description = "3%", data = 0.03},
            {description = "4%", data = 0.04},
            {description = "5%", data = 0.05},
            {description = "6%", data = 0.06},
            {description = "7%", data = 0.07},
            {description = "8%", data = 0.08},
            {description = "9%", data = 0.09},
            {description = "10%", data = 0.1},
            {description = "20%", data = 0.2},
            {description = "30%", data = 0.3},
            {description = "40%", data = 0.4}, {description = "50%", data = 0.5}
        },
        default = 0.5
    }, {
        name = "CHOP_DROP_RATE",
        label = "砍树卷轴掉落概率",
        hover = "自用",
        options = {
            {description = "1%", data = 0.01},
            {description = "2%", data = 0.02},
            {description = "3%", data = 0.03},
            {description = "4%", data = 0.04},
            {description = "5%", data = 0.05},
            {description = "6%", data = 0.06},
            {description = "7%", data = 0.07},
            {description = "8%", data = 0.08},
            {description = "9%", data = 0.09},
            {description = "10%", data = 0.1},
            {description = "20%", data = 0.2},
            {description = "30%", data = 0.3},
            {description = "40%", data = 0.4}, {description = "50%", data = 0.5}
        },
        default = 0.2
    }, {
        name = "MINE_DROP_RATE",
        label = "挖矿卷轴掉落概率",
        hover = "自用",
        options = {
            {description = "1%", data = 0.01},
            {description = "2%", data = 0.02},
            {description = "3%", data = 0.03},
            {description = "4%", data = 0.04},
            {description = "5%", data = 0.05},
            {description = "6%", data = 0.06},
            {description = "7%", data = 0.07},
            {description = "8%", data = 0.08},
            {description = "9%", data = 0.09},
            {description = "10%", data = 0.1},
            {description = "20%", data = 0.2},
            {description = "30%", data = 0.3},
            {description = "40%", data = 0.4}, {description = "50%", data = 0.5}
        },
        default = 0.2
    }, {
        name = "FISH_DROP_RATE",
        label = "钓鱼卷轴掉落概率",
        hover = "自用",
        options = {
            {description = "1%", data = 0.01},
            {description = "2%", data = 0.02},
            {description = "3%", data = 0.03},
            {description = "4%", data = 0.04},
            {description = "5%", data = 0.05},
            {description = "6%", data = 0.06},
            {description = "7%", data = 0.07},
            {description = "8%", data = 0.08},
            {description = "9%", data = 0.09},
            {description = "10%", data = 0.1},
            {description = "20%", data = 0.2},
            {description = "30%", data = 0.3},
            {description = "40%", data = 0.4}, {description = "50%", data = 0.5}
        },
        default = 0.2
    }, {
        name = "MAX_ITEM_DROP_COUNT",
        label = "相同项目掉落最大次数",
        hover = "自用",
        options = {
            {description = "1", data = 1}, {description = "2", data = 2},
            {description = "3", data = 3}, {description = "4", data = 4},
            {description = "5", data = 5}, {description = "6", data = 6},
            {description = "7", data = 7}, {description = "8", data = 8},
            {description = "9", data = 9}, {description = "10", data = 10},
            {description = "20", data = 20}, {description = "30", data = 30},
            {description = "40", data = 40}, {description = "50", data = 50}
        },
        default = 1
    }, {
        name = "MAX_DAILY_DROP_COUNT",
        label = "卷轴每日掉落最大数量",
        hover = "每日天亮重置",
        options = {
            {description = "1", data = 1}, {description = "2", data = 2},
            {description = "3", data = 3}, {description = "4", data = 4},
            {description = "5", data = 5}, {description = "6", data = 6},
            {description = "7", data = 7}, {description = "8", data = 8},
            {description = "9", data = 9}, {description = "10", data = 10},
            {description = "20", data = 20}, {description = "30", data = 30},
            {description = "40", data = 40}, {description = "50", data = 50}
        },
        default = 5
    }, {
        name = "ENABLE_100_DAY_REWARD",
        label = "开启100天生存奖励",
        hover = "玩家生存满100天后自动获得元素防御附魔石",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    }, {
        name = "ENABLE_GEM",
        label = "开启小人制作宝石",
        hover = "开启小人制作宝石",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = false
    }, {
        name = "XIAOREN_COUNT",
        label = "小人制作宝石需要数量",
        hover = "小人制作宝石需要数量",
        options = {
            {description = "1", data = 1}, {description = "2", data = 2},
            {description = "3", data = 3}, {description = "4", data = 4},
            {description = "5", data = 5}, {description = "6", data = 6},
            {description = "7", data = 7}, {description = "8", data = 8},
            {description = "9", data = 9}, {description = "10", data = 10},
            {description = "20", data = 20}, {description = "30", data = 30},
            {description = "40", data = 40}, {description = "50", data = 50}
        },
        default = 5
    }, {
        name = "ENABLE_WORMWOOD",
        label = "植物人砍树不掉san",
        hover = "植物人砍树不掉san",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    }, {
        name = "enable_rosorns",
        label = "开启棱镜蔷薇剑真实伤害",
        hover = "开启棱镜蔷薇剑真实伤害",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = false
    }, {
        name = "enable_start_give",
        label = "开启附魔开局礼物",
        hover = "开启附魔开局礼物附魔卷轴",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = false
    }, {
        name = "enable_start_give_count",
        label = "附魔卷轴数量",
        hover = "附魔卷轴数量",
        options = {
            {description = "10", data = 10}, {description = "20", data = 20},
            {description = "30", data = 30}, {description = "40", data = 40},
            {description = "50", data = 50}, {description = "60", data = 60},
            {description = "70", data = 70}, {description = "80", data = 80},
            {description = "90", data = 90}, {description = "100", data = 100}
        },
        default = 20
    }
}
