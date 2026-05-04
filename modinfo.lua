name = "老斑鸠-附魔补丁"
description = [[自用，侵权联系删除

【更新日志】
v1.36 (2026-04-12)
- 修正附魔相关掉落过滤：拦截本体玩家击杀掉落入口 DropSpecialGif，不再错误修改怪物死亡装备掉落入口
- 调整附魔卷轴/宝石掉落判断：目标没有 lootdropper 组件时不掉落，有 follower 组件时不掉落
- 调整双子魔眼五连冲撞：在上一版基础上继续加长单段冲刺距离

v1.35 (2026-04-11)
- 调整宝石转换规则：treasure_ 开头的宝藏宝石现已支持互相转换
- 宝藏宝石转换保持原有概率：50% 转换失败直接消失，50% 转换成功
- 宝藏宝石仅会在 treasure_armor、treasure_atk、treasure_bj 三者之间互转
- 宝藏宝石不会转换为普通宝石，也不会混入普通宝石转换池

v1.34 (2026-04-07)
- 调整双子魔眼系技能表现：继续修正五连冲撞、魔焰喷火与普通喷火的手感和表现
- 修正魔焰：持续时间延长，施法期间会跟随怪物当前朝向变化
- 调整喷火：恢复更接近附身座狼的扇形持续喷焰表现，并同步修正预警范围
- 修复火阵异常：恢复为上一版 deer_fire_circle 触发方式
- 优化木头修木甲：一次动作按需消耗整组木头，尽量直接修满

v1.33 (2026-04-07)
- 新增怪物技能头顶状态显示，并增加独立配置开关
- 优化怪物技能头顶提示：改为低开销状态刷新，按体型动态计算高度，并继续整体下调到更贴近头部
- 修复技能头顶状态崩溃：移除新增 prefab 文件依赖，改为直接复用原版附魔的 hh_treasure_text
- 修复骑牛无敌：怪物互相无效规则不再错误拦截“有玩家骑乘的坐骑”
- 新增怪物通用词条：免疫远程伤害，并将判定距离阈值调整为3格
- 调整远程武器禁止附魔判定：由攻击距离大于2改为大于等于3
- 优化喷火与魔焰技能性能：下调魔焰 tick 频率，并减少喷火/魔焰每跳生成的特效数量
- 移除移速-中附魔石
- 迁移“为爽而虐”功能：支持使用木头修复木甲，并增加独立配置开关
- 修复激光炮自伤：排除施法者自身，并上调激光首段生成距离
- 修改火阵：改为自定义安全火圈，不再点燃周围建筑和物品
- 修复木头修复木甲失效：补齐装备栏目标的动作收集，并放宽客户端动作判定

v1.17 (2026-04-06)
- 修复重复宝石继承：原版装备继承后，重复同类宝石会按宝石类型逐个匹配等级，避免部分2级宝石错误掉回1级

v1.16 (2026-04-06)
- 修复装备继承兼容：通过本体原版“装备继承”功能转移宝石时，会同步继承宝石等级，不再全部重置为1级

v1.15 (2026-04-05)
- 修复旧存档兼容：启用宝石等级系统后，进入旧存档时不再让旧档宝石恢复流程误触发升级逻辑
- 修复宝石等级系统：读档恢复阶段不再重复触发额外装备刷新，降低物品/装备异常丢失风险

v1.14 (2026-04-04)
- 新增怪物技能词条：连发弹幕、地刺陷阱、落雷、冰环、火阵、扇形喷火，以及双子魔眼系技能（激光炮、五连快速冲撞、高速魔焰喷火）
- 完善怪物技能系统：补充多人目标、扇形/直线预警、原版冰阵/火阵、统一怪物技能CD倍率配置
- 多轮优化技能表现与平衡：地刺、落雷、喷火、双子魔眼技能的距离、数量、预警、视觉与伤害逻辑已整体打磨
- 修复关键问题：双子魔眼技能作用域报错、运行时报错、prefab依赖崩溃、喷火技能串线、激光炮破坏建筑等问题
- 新增怪物技能词条第一批与第二批：喷吐、震击、冲撞、飞扑
- 新增怪物玩家词条扩展：攻击距离、攻击速度、刺猬，并加入对应配置开关
- 将5个Boss独有词条同步开放给精英怪，并补充独立配置开关
- 新增真近战附魔石、复合普通附魔石，开放生命附魔石随机获取，并调整黄昏增伤附魔石为可重复附魔
- 修复宝石升级：拆除法杖特殊道具升级宝石时恢复按当前等级*2消耗材料
- 修复同类宝石升级：装备上存在多个同类宝石时，会优先升级未满级的那一颗
- 修复怪物技能词条：怪物死亡或移除后，不会继续释放延迟/持续类技能
- 调整宝石转换池：长击珠现已加入可转换宝石范围
- 新增宝石“长击珠”：攻击距离+1，仅限攻击距离小于2的手部武器镶嵌，且宝石等级上限为1
- 新增稀有附魔石“滑铲-稀”：装备后获得为爽而虐滑铲能力（右键冲刺）
- 新增中-急速附魔石：移速范围10%~40%
- 修正中移速附魔石数值：按原版步伐珠3%效果的2倍，调整为6%
- 调整宝石掉率默认值为5%，并新增中移速附魔石（原版移速附魔石2倍效果）
- 新增宝石掉落概率配置：可在mod配置中调整宝石/特殊道具掉率
- 修正宝石等级系统：等级叠加后会立即刷新玩家移速等衍生属性
- 修正宝石等级系统入口：等级升级逻辑改为接管本体主镶嵌路径
- 新增宝石等级系统：同类宝石在无空槽时可升级，升级消耗为当前等级*2
]]
author = "老斑鸠"
version = "1.36"

api_version = 10
dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
all_clients_require_mod = true

icon_atlas = "modicon.xml"
icon = "modicon.tex"

server_filter_tags = {"compatibility", "enhancement", "enchantment"}
priority = -9999

local _section_index = 0
local function MakeSection(label, hover)
    _section_index = _section_index + 1
    return {
        name = "__section_" .. _section_index,
        label = "【" .. label .. "】",
        hover = hover or "仅用于分组显示",
        options = {
            {description = "查看下方配置", data = false}
        },
        default = false
    }
end

configuration_options = {
    MakeSection("基础功能", "补丁总开关与基础世界规则"),
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
        name = "enable_log_armor_repair",
        label = "木头修复木甲",
        hover = "开启后，可使用木头修复木甲（armorwood）",
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
    },

    MakeSection("掉落系统", "卷轴掉落相关配置"),
    {
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
    },

    MakeSection("辅助与开局", "宝石、初始礼物与杂项辅助"),
    {
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
    },

    MakeSection("附魔扩展", "新增附魔石、复合石与基础附魔规则"),
    {
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
        name = "enable_medium_haste_enchant_stone",
        label = "开启中-急速附魔石",
        hover = "开启后，可获得中-急速附魔石，移速范围10%~40%",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    }, {
        name = "enable_rare_slide_enchant_stone",
        label = "开启滑铲-稀附魔石",
        hover = "开启后，可获得稀有附魔石滑铲-稀，装备后获得右键滑铲能力",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    }, {
        name = "enable_attack_range_gem",
        label = "开启长击珠宝石",
        hover = "开启后，可获得长击珠；效果为攻击距离+1，仅限攻击距离小于2的手部武器镶嵌，且等级上限为1",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    }, {
        name = "enable_gem_convert",
        label = "开启宝石转换功能",
        hover = "开启后，可在附魔页点击普通宝石并弹出转换确认；转换结果为50%消失，50%变成其他普通可转换宝石",
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
        name = "enable_long_range_enchant_restriction",
        label = "远程武器禁止附魔",
        hover = "开启后，攻击距离大于等于3的武器将无法附魔",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    },

    MakeSection("怪物技能与词条", "怪物技能词条、玩家词条扩展与特殊下放"),
    {
        name = "enable_monster_skill_status_display",
        label = "显示怪物技能头顶状态",
        hover = "开启后，带技能词条的怪物会在头顶显示技能是否可用；关闭后不创建这套显示",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    }, {
        name = "monster_skill_cd_mult_common",
        label = "怪物技能CD倍率：普通怪",
        hover = "统一调整普通怪所有技能词条的冷却时间倍率；当前默认1.0x，数值越大冷却越久",
        options = {
            {description = "0.5x", data = 0.5},
            {description = "0.75x", data = 0.75},
            {description = "1.0x(默认)", data = 1.0},
            {description = "1.25x", data = 1.25},
            {description = "1.5x", data = 1.5},
            {description = "2.0x", data = 2.0},
            {description = "3.0x", data = 3.0},
            {description = "4.0x", data = 4.0},
            {description = "5.0x", data = 5.0},
            {description = "6.0x", data = 6.0},
            {description = "7.0x", data = 7.0},
            {description = "8.0x", data = 8.0},
            {description = "9.0x", data = 9.0},
            {description = "10.0x", data = 10.0}
        },
        default = 1.0
    }, {
        name = "monster_skill_cd_mult_elite",
        label = "怪物技能CD倍率：精英怪",
        hover = "统一调整精英怪所有技能词条的冷却时间倍率；当前默认1.0x，数值越大冷却越久",
        options = {
            {description = "0.5x", data = 0.5},
            {description = "0.75x", data = 0.75},
            {description = "1.0x(默认)", data = 1.0},
            {description = "1.25x", data = 1.25},
            {description = "1.5x", data = 1.5},
            {description = "2.0x", data = 2.0},
            {description = "3.0x", data = 3.0},
            {description = "4.0x", data = 4.0},
            {description = "5.0x", data = 5.0},
            {description = "6.0x", data = 6.0},
            {description = "7.0x", data = 7.0},
            {description = "8.0x", data = 8.0},
            {description = "9.0x", data = 9.0},
            {description = "10.0x", data = 10.0}
        },
        default = 1.0
    }, {
        name = "monster_skill_cd_mult_boss",
        label = "怪物技能CD倍率：Boss",
        hover = "统一调整Boss所有技能词条的冷却时间倍率；当前默认1.0x，数值越大冷却越久",
        options = {
            {description = "0.5x", data = 0.5},
            {description = "0.75x", data = 0.75},
            {description = "1.0x(默认)", data = 1.0},
            {description = "1.25x", data = 1.25},
            {description = "1.5x", data = 1.5},
            {description = "2.0x", data = 2.0},
            {description = "3.0x", data = 3.0},
            {description = "4.0x", data = 4.0},
            {description = "5.0x", data = 5.0},
            {description = "6.0x", data = 6.0},
            {description = "7.0x", data = 7.0},
            {description = "8.0x", data = 8.0},
            {description = "9.0x", data = 9.0},
            {description = "10.0x", data = 10.0}
        },
        default = 1.0
    }, {
        name = "enable_monster_spit_skill",
        label = "怪物技能词条：喷吐",
        hover = "开启后，符合条件的怪物可随机获得喷吐类技能词条；概率/冷却：普通30%/8秒，精英38%/6秒，Boss45%/4秒",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    }, {
        name = "enable_monster_shockwave_skill",
        label = "怪物技能词条：震击",
        hover = "开启后，符合条件的大型战怪可随机获得范围震击词条；概率/冷却：普通22%/10秒，精英28%/8秒，Boss34%/6秒",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    }, {
        name = "enable_monster_charge_skill",
        label = "怪物技能词条：冲撞",
        hover = "开启后，符合条件的大型战怪可随机获得冲撞技能词条；概率/冷却：普通18%/12秒，精英24%/10秒，Boss30%/8秒",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    }, {
        name = "enable_monster_pounce_skill",
        label = "怪物技能词条：飞扑",
        hover = "开启后，符合条件的战怪可随机获得飞扑技能词条；概率/冷却：普通16%/10秒，精英22%/8秒，Boss28%/6秒",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    }, {
        name = "enable_monster_barrage_skill",
        label = "怪物技能词条：连发弹幕",
        hover = "开启后，符合条件的怪物可随机获得连发弹幕词条；概率/冷却：普通16%/14秒，精英22%/12秒，Boss28%/10秒",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    }, {
        name = "enable_monster_trap_skill",
        label = "怪物技能词条：地刺陷阱",
        hover = "开启后，符合条件的怪物可随机获得地刺陷阱词条；概率/冷却：普通16%/14秒，精英22%/12秒，Boss28%/10秒",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    }, {
        name = "enable_monster_bolt_skill",
        label = "怪物技能词条：落雷",
        hover = "开启后，符合条件的怪物可随机获得落雷定点技能词条；概率/冷却：普通14%/16秒，精英20%/13秒，Boss26%/10秒",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    }, {
        name = "enable_monster_freeze_ring_skill",
        label = "怪物技能词条：冰环",
        hover = "开启后，符合条件的怪物可随机获得冰环冻结技能词条；概率/冷却：普通14%/15秒，精英20%/12秒，Boss26%/9秒",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    }, {
        name = "enable_monster_fire_ring_skill",
        label = "怪物技能词条：火阵",
        hover = "开启后，符合条件的怪物可随机获得火阵燃烧技能词条；概率/冷却：普通14%/15秒，精英20%/12秒，Boss26%/9秒",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    }, {
        name = "enable_monster_flame_cone_skill",
        label = "怪物技能词条：扇形喷火",
        hover = "开启后，符合条件的怪物可随机获得前方扇形喷火技能词条；当前仅精英/Boss可用，概率/冷却：精英20%/11秒，Boss26%/8秒",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    }, {
        name = "enable_monster_twin_laser_skill",
        label = "魔眼技能词条：激光炮",
        hover = "开启后，精英怪与Boss可随机获得双子魔眼风格的激光炮技能词条；概率/冷却：精英16%/16秒，Boss22%/12秒",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    }, {
        name = "enable_monster_twin_dash_skill",
        label = "魔眼技能词条：五连冲撞",
        hover = "开启后，精英怪与Boss可随机获得双子魔眼风格的五连快速冲撞技能词条；概率/冷却：精英18%/17秒，Boss24%/13秒",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    }, {
        name = "enable_monster_twin_hellfire_skill",
        label = "魔眼技能词条：高速魔焰喷火",
        hover = "开启后，精英怪与Boss可随机获得双子魔眼风格的高速魔焰喷火技能词条；概率/冷却：精英18%/15秒，Boss24%/11秒",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    }, {
        name = "enable_boss_skills_for_elite",
        label = "Boss词条下放精英",
        hover = "开启后，5个Boss独有词条会同步开放给精英怪",
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
    },

    MakeSection("怪物成长与掉落", "怪物词条数量、成长曲线与精英/Boss掉率"),
    {
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
        hover = "开启后，可自定义宝石/特殊道具、精英怪和Boss的极品附魔石、装备包裹掉落概率",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = false
    }, {
        name = "player_gem_drop_rate",
        label = "宝石/特殊道具掉率",
        hover = "玩家击杀相关怪物时掉落宝石/特殊道具的概率",
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
            {description = "20%", data = 0.2},
            {description = "30%", data = 0.3},
            {description = "40%", data = 0.4},
            {description = "50%", data = 0.5}
        },
        default = 0.05
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
    },

    MakeSection("转换与保底", "水晶小人转换概率与累计保底系统"),
    {
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
