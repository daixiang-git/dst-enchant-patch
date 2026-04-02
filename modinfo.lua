name = "老斑鸠自用兼容补丁"
description = [[自用，侵权联系删除

【更新日志】
v0.43 (2026-04-02)
- 调整原版黄昏增伤附魔石：取消唯一性，改为可重复附魔
v0.42 (2026-04-02)
- 调整复合普通附魔石来源：现在可通过普通附魔获取
v0.41 (2026-04-02)
- 新增3颗复合普通附魔石：免疫冷热、免疫潮冻、免疫眠粘
- 新增独立配置开关：可控制复合普通附魔石是否启用，默认开启
v0.40 (2026-04-02)
- 新增“真近战”附魔石：普通版提供50%伤害加成和25点固定增伤，稀有版提供100%伤害加成和50点固定增伤
- 仅允许攻击距离1~2的手部武器附魔，且词条唯一
- 新增独立配置开关：可控制真近战附魔石是否启用，默认开启
v0.39 (2026-04-02)
- 提升补丁版本号
v0.38 (2026-04-02)
- 将5个Boss独有词条同步开放给精英怪：冰炮台、火炮台、毒炮台、冰激光、概率免伤
v0.37 (2026-04-02)
- 怪物玩家词条扩展新增“刺猬”词条：怪物受击后可对攻击者造成真实反伤
- 新增独立配置开关：可控制“刺猬”词条是否进入怪物随机词条池
v0.36 (2026-04-02)
- 怪物玩家词条扩展新增两种词条：攻击距离、攻击速度
- 新增两个独立配置开关：可分别控制这两种词条是否进入怪物随机词条池
- 两个开关默认均为开启
v0.35 (2026-03-27)
- 新增配置开关：可控制生命附魔石是否进入正常随机池
- 默认开启生命附魔石随机获取
v0.34 (2026-03-25)
- 修复开启掉率系统后，额外掉落会直接掉地上的问题；现在优先放入玩家背包，背包放不下时才掉地
- 修复树精、大象等新生成怪物的初始词条没有立即吃到天数成长的问题
v0.33 (2026-03-24)
- 修复“怪物词条数量配置”启用后，新生成怪物有时不获得初始词条的问题
v0.32 (2026-03-24)
- 新增配置开关：可控制“攻击距离大于2的武器禁止附魔”是否生效，默认开启
- 同步更新帮助页补丁变更日志
v0.31 (2026-03-24)
- 新增精英/Boss词条：命中有概率分解玩家头部或身体装备
- 分解装备时复用附魔分解规则，修复分解后不掉附魔石的问题
- 新增配置开关：可单独启用/禁用该词条
- 新增概率范围配置：支持1%~3%或1%~5%
- 调整宝藏Boss尾刀奖励：死亡点附近16范围内的玩家都可获得稀有宝石奖励
v0.30 (2026-03-24)
- 调整破界：兼容能力勋章的混沌抵抗
- 调整破界：目标处于破界状态时，受到的伤害减半
- 同步更新帮助页补丁变更日志
v0.29 (2026-03-24)
- 新增稀有附魔石“破界”：附魔时概率范围1%~10%，可使拥有位面抵抗的怪物失去位面抵抗10秒，怪物内置冷却10秒
- 修复破界词条显示、附魔石描述和触发提示异常的问题
v0.28 (2026-03-24)
- 新增配置开关：默认移除 treasure_kps、treasure_cat_you
- 同步更新帮助页补丁变更日志
v0.27 (2026-03-24)
- 修复暗影伪装、月灵伪装移除后仍可能通过附魔卷轴/水晶转换出现的问题
- 新增附魔限制：攻击距离大于2的武器禁止附魔
- 新增配置开关：默认移除 treasure_kps、treasure_cat_you
- 修复帮助页概率表不按配置显示的问题
- 调整制裁效果：治疗压制改为-100%，持续时间翻倍
- 调整部分玩家词条上限：暗影护盾30%，伤害减免50%，秋季战神仅生效1条，白天/黄昏/夜晚增伤上限100
v0.26 (2026-03-23)
- 新增水晶小人转换概率配置（稀有/超稀有词条概率可自定义）
- 新增累计保底系统：转换水晶小人、击杀精英怪、击杀Boss独立计数
- 新增保底阈值配置：三种行为可设置不同的保底次数
- 优化击杀判定：仅玩家或玩家召唤物（随从）击杀才计入保底计数
]]
author = "老斑鸠"
version = "0.43"

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
        label = "开启棱镜蔷薇剑、夜雨玫瑰真实伤害",
        hover = "开启棱镜蔷薇剑、夜雨玫瑰真实伤害",
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
    }, {
        name = "enable_new_effect",
        label = "开启新附魔石头（极品穿刺、暴击效果、伤害加成）",
        hover = "开启新附魔石头（极品穿刺、暴击效果、伤害加成）",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    }, {
        name = "enable_true_melee_enchant_stone",
        label = "开启真近战附魔石",
        hover = "开启后，可获得普通/稀有两种真近战附魔石，仅限攻击距离1~2的手部武器附魔",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    }, {
        name = "enable_compound_common_immunity_stones",
        label = "开启复合普通附魔石",
        hover = "开启后，可使用免疫冷热、免疫潮冻、免疫眠粘三种复合普通附魔石",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    }, {
        name = "enable_monster_player_effects",
        label = "怪物玩家词条（真伤/暴击/反伤/末世/血涌）",
        hover = "让怪物随机获得玩家专属词条，使怪物更加强大",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    }, {
        name = "enable_monster_attack_range_effect",
        label = "怪物攻击距离词条",
        hover = "开启后，怪物玩家词条扩展可随机加入攻击距离提升词条",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    }, {
        name = "enable_monster_attack_speed_effect",
        label = "怪物攻击速度词条",
        hover = "开启后，怪物玩家词条扩展可随机加入攻击速度提升词条",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    }, {
        name = "enable_monster_hedgehog_effect",
        label = "怪物刺猬词条",
        hover = "开启后，怪物玩家词条扩展可随机加入受击真实反伤词条",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    }, {
        name = "enable_life_enchant_stone",
        label = "开启生命附魔石随机获取",
        hover = "开启后，初/中/高/极生命附魔石会进入正常随机池",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    }, {
        name = "enable_monster_break_equip_effect",
        label = "怪物分解装备词条",
        hover = "开启后，精英/Boss可随机获得命中分解玩家头部/身体装备的词条",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    }, {
        name = "monster_break_equip_effect_range",
        label = "分解装备词条概率范围",
        hover = "设置精英/Boss该词条的随机概率范围",
        options = {
            {description = "1%~3%", data = "1_3"},
            {description = "1%~5%", data = "1_5"}
        },
        default = "1_3"
    }, {
        name = "remove_player_effects",
        label = "移除部分玩家词条（免疫制裁、暗影伪装）",
        hover = "开启后，玩家将无法获得免疫制裁和暗影伪装词条",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = false
    }, {
        name = "remove_treasure_monsters",
        label = "移除部分宝藏怪",
        hover = "开启后，默认移除 treasure_kps 和 treasure_cat_you",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    }, {
        name = "enable_long_range_enchant_restriction",
        label = "远程武器禁止附魔",
        hover = "开启后，攻击距离大于2的武器将无法附魔",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    }, {
        name = "enable_monster_effect_limit",
        label = "修改怪物词条数量上限",
        hover = "开启后，可自定义不同级别怪物的词条数量上限",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = false
    }, {
        name = "common_monster_effect_limit",
        label = "普通怪物词条上限",
        hover = "普通怪物最多拥有的词条数量",
        options = {
            {description = "3", data = 3}, {description = "4", data = 4},
            {description = "5", data = 5}, {description = "6", data = 6},
            {description = "7", data = 7}, {description = "8", data = 8},
            {description = "9", data = 9}, {description = "10", data = 10},
            {description = "12", data = 12}, {description = "15", data = 15},
            {description = "20", data = 20}
        },
        default = 5
    }, {
        name = "elite_monster_effect_limit",
        label = "精英怪物词条上限",
        hover = "精英怪物最多拥有的词条数量",
        options = {
            {description = "5", data = 5}, {description = "6", data = 6},
            {description = "7", data = 7}, {description = "8", data = 8},
            {description = "9", data = 9}, {description = "10", data = 10},
            {description = "12", data = 12}, {description = "15", data = 15},
            {description = "18", data = 18}, {description = "20", data = 20},
            {description = "25", data = 25}
        },
        default = 7
    }, {
        name = "boss_monster_effect_limit",
        label = "Boss怪物词条上限",
        hover = "Boss怪物最多拥有的词条数量",
        options = {
            {description = "8", data = 8}, {description = "10", data = 10},
            {description = "12", data = 12}, {description = "15", data = 15},
            {description = "18", data = 18}, {description = "20", data = 20},
            {description = "25", data = 25}, {description = "30", data = 30},
            {description = "35", data = 35}, {description = "40", data = 40}
        },
        default = 10
    }, {
        name = "common_base_effect_num",
        label = "普通怪物基础词条数量",
        hover = "普通怪物的初始词条数量（随天数增加会更多）",
        options = {
            {description = "1", data = 1}, {description = "2", data = 2},
            {description = "3(默认)", data = 3}, {description = "4", data = 4},
            {description = "5", data = 5}, {description = "6", data = 6},
            {description = "7", data = 7}, {description = "8", data = 8},
            {description = "9", data = 9}, {description = "10", data = 10},
            {description = "11", data = 11}, {description = "12", data = 12},
            {description = "13", data = 13}, {description = "14", data = 14},
            {description = "15", data = 15}
        },
        default = 3
    }, {
        name = "elite_base_effect_num",
        label = "精英怪物基础词条数量",
        hover = "精英怪物的初始词条数量（随天数增加会更多）",
        options = {
            {description = "1", data = 1}, {description = "2", data = 2},
            {description = "3", data = 3}, {description = "4", data = 4},
            {description = "5(默认)", data = 5}, {description = "6", data = 6},
            {description = "7", data = 7}, {description = "8", data = 8},
            {description = "9", data = 9}, {description = "10", data = 10},
            {description = "11", data = 11}, {description = "12", data = 12},
            {description = "13", data = 13}, {description = "14", data = 14},
            {description = "15", data = 15}
        },
        default = 5
    }, {
        name = "boss_base_effect_num",
        label = "Boss怪物基础词条数量",
        hover = "Boss怪物的初始词条数量（随天数增加会更多）",
        options = {
            {description = "1", data = 1}, {description = "2", data = 2},
            {description = "3", data = 3}, {description = "4", data = 4},
            {description = "5", data = 5}, {description = "6", data = 6},
            {description = "7", data = 7}, {description = "8", data = 8},
            {description = "9", data = 9}, {description = "10(默认)", data = 10},
            {description = "11", data = 11}, {description = "12", data = 12},
            {description = "13", data = 13}, {description = "14", data = 14},
            {description = "15", data = 15}
        },
        default = 10
    }, {
        name = "effect_add_days",
        label = "词条增加天数间隔",
        hover = "每隔多少天怪物额外获得1个词条",
        options = {
            {description = "3天", data = 3},
            {description = "4天", data = 4},
            {description = "5天", data = 5},
            {description = "6天", data = 6},
            {description = "8天", data = 8},
            {description = "10天", data = 10},
            {description = "12天(默认)", data = 12},
            {description = "15天", data = 15},
            {description = "18天", data = 18},
            {description = "20天", data = 20},
            {description = "24天", data = 24},
            {description = "30天", data = 30},
            {description = "40天", data = 40},
            {description = "50天", data = 50},
            {description = "60天", data = 60}
        },
        default = 12
    }, {
        name = "enable_drop_rate_config",
        label = "修改极品附魔石/包裹掉率",
        hover = "开启后，可自定义精英怪和Boss的极品附魔石、装备包裹掉落概率",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = false
    }, {
        name = "elite_stone_drop_rate",
        label = "精英极品附魔石掉率",
        hover = "精英怪死亡时掉落极品附魔石的概率",
        options = {
            {description = "0.1%", data = 0.001},
            {description = "0.2%", data = 0.002},
            {description = "0.3%", data = 0.003},
            {description = "0.5%", data = 0.005},
            {description = "1%", data = 0.01},
            {description = "2%", data = 0.02},
            {description = "3%", data = 0.03},
            {description = "4%", data = 0.04},
            {description = "5%(默认)", data = 0.05}
        },
        default = 0.05
    }, {
        name = "elite_gif_drop_rate",
        label = "精英装备包裹掉率",
        hover = "精英怪死亡时掉落装备包裹的概率",
        options = {
            {description = "0.1%", data = 0.001},
            {description = "0.2%", data = 0.002},
            {description = "0.3%", data = 0.003},
            {description = "0.5%", data = 0.005},
            {description = "1%(默认)", data = 0.01}
        },
        default = 0.01
    }, {
        name = "boss_stone_drop_rate",
        label = "Boss极品附魔石掉率",
        hover = "Boss死亡时掉落极品附魔石的概率",
        options = {
            {description = "0.1%", data = 0.001},
            {description = "0.2%", data = 0.002},
            {description = "0.3%", data = 0.003},
            {description = "0.5%", data = 0.005},
            {description = "1%", data = 0.01},
            {description = "2%", data = 0.02},
            {description = "3%", data = 0.03},
            {description = "4%", data = 0.04},
            {description = "5%", data = 0.05},
            {description = "10%", data = 0.1},
            {description = "15%", data = 0.15},
            {description = "20%(默认)", data = 0.2}
        },
        default = 0.2
    }, {
        name = "boss_gif_drop_rate",
        label = "Boss装备包裹掉率",
        hover = "Boss死亡时掉落装备包裹的概率",
        options = {
            {description = "0.1%", data = 0.001},
            {description = "0.2%", data = 0.002},
            {description = "0.3%", data = 0.003},
            {description = "0.5%", data = 0.005},
            {description = "1%", data = 0.01},
            {description = "2%", data = 0.02},
            {description = "3%(默认)", data = 0.03}
        },
        default = 0.03
    }, {
        name = "enable_stone_convert_config",
        label = "修改水晶小人转换概率",
        hover = "开启后，可自定义水晶小人转换附魔石的概率",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = false
    }, {
        name = "stone_convert_rare_rate",
        label = "转换稀有词条概率",
        hover = "水晶小人转换附魔石获得稀有词条的概率",
        options = {
            {description = "0.1%", data = 0.001},
            {description = "0.2%", data = 0.002},
            {description = "0.3%", data = 0.003},
            {description = "0.5%", data = 0.005},
            {description = "1%", data = 0.01},
            {description = "2%", data = 0.02},
            {description = "3%", data = 0.03},
            {description = "4%", data = 0.04},
            {description = "5%(默认)", data = 0.05},
            {description = "10%", data = 0.1},
            {description = "15%", data = 0.15},
            {description = "20%", data = 0.2},
            {description = "25%", data = 0.25},
            {description = "30%", data = 0.3},
            {description = "40%", data = 0.4},
            {description = "50%", data = 0.5}
        },
        default = 0.05
    }, {
        name = "stone_convert_super_rare_rate",
        label = "转换超稀有词条概率",
        hover = "水晶小人转换附魔石获得超级稀有词条的概率",
        options = {
            {description = "0.1%", data = 0.001},
            {description = "0.2%", data = 0.002},
            {description = "0.3%", data = 0.003},
            {description = "0.5%", data = 0.005},
            {description = "1%(默认)", data = 0.01},
            {description = "2%", data = 0.02},
            {description = "3%", data = 0.03},
            {description = "4%", data = 0.04},
            {description = "5%", data = 0.05},
            {description = "10%", data = 0.1},
            {description = "15%", data = 0.15},
            {description = "20%", data = 0.2},
            {description = "25%", data = 0.25},
            {description = "30%", data = 0.3}
        },
        default = 0.01
    }, {
        name = "enable_lucky_counter",
        label = "开启累计保底系统",
        hover = "开启后，转换水晶小人、击杀精英怪/Boss会累计计数，达到阈值必定获得稀有词条",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = false
    }, {
        name = "stone_convert_threshold",
        label = "水晶小人转换保底阈值",
        hover = "转换水晶小人累计多少次后必定获得稀有词条",
        options = {
            {description = "5次", data = 5},
            {description = "10次", data = 10},
            {description = "15次", data = 15},
            {description = "20次(默认)", data = 20},
            {description = "25次", data = 25},
            {description = "30次", data = 30},
            {description = "40次", data = 40},
            {description = "50次", data = 50}
        },
        default = 20
    }, {
        name = "elite_kill_threshold",
        label = "精英怪击杀保底阈值",
        hover = "击杀精英怪累计多少次后必定获得稀有词条",
        options = {
            {description = "5次", data = 5},
            {description = "10次", data = 10},
            {description = "15次", data = 15},
            {description = "20次(默认)", data = 20},
            {description = "25次", data = 25},
            {description = "30次", data = 30},
            {description = "40次", data = 40},
            {description = "50次", data = 50}
        },
        default = 20
    }, {
        name = "boss_kill_threshold",
        label = "Boss击杀保底阈值",
        hover = "击杀Boss累计多少次后必定获得稀有词条",
        options = {
            {description = "3次", data = 3},
            {description = "5次", data = 5},
            {description = "7次", data = 7},
            {description = "10次(默认)", data = 10},
            {description = "12次", data = 12},
            {description = "15次", data = 15},
            {description = "20次", data = 20},
            {description = "25次", data = 25}
        },
        default = 10
    }
}
