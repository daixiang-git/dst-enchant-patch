-- 补丁mod更新日志注入
-- 在本体mod的更新日志界面显示补丁mod的更新记录

local function AddPatchUpdateLog()
    if not TUNING or not TUNING.HH_UI_TEXT or not TUNING.HH_UI_TEXT.UPDATE_VISION then
        return
    end

    local patchLogs = {
        {
            ["title"] = "补丁mod - 2026-04-03(技能系统概要)",
            ["desc"] = [[
            --------概要--------
            【怪物技能词条】
              新增连发弹幕、地刺陷阱、落雷
              冰环、火阵、扇形喷火
              以及双子魔眼系技能
              激光炮、五连快速冲撞、高速魔焰喷火

            【系统与表现】
              完善多人目标、扇形/直线预警
              原版冰阵/火阵、统一技能CD倍率配置

            【修正】
              完成双子魔眼技能报错
              prefab依赖、喷火串线
              激光炮破坏建筑等问题修正
            ]]
        },
        {
            ["title"] = "补丁mod - 2026-04-02(首批技能与附魔扩展概要)",
            ["desc"] = [[
            --------概要--------
            【怪物技能词条】
              新增喷吐、震击、冲撞、飞扑

            【怪物玩家词条与附魔】
              新增攻击距离、攻击速度、刺猬词条
              下放5个Boss独有词条给精英怪
              新增真近战附魔石与复合普通附魔石
              开放生命附魔石随机获取
              调整黄昏增伤为可重复附魔
            ]]
        },
    }

    for i = #patchLogs, 1, -1 do
        table.insert(TUNING.HH_UI_TEXT.UPDATE_VISION, 1, patchLogs[i])
    end
end

AddPatchUpdateLog()
