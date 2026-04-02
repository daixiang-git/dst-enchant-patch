local LIFE_EFFECTS = {
    "add_max_health_01",
    "add_max_health_02",
    "add_max_health_03",
    "add_max_health_04",
}

local function EnableLifeEffects()
    local HH_EQUIP_BUFF_LIST = rawget(_G, "HH_EQUIP_BUFF_LIST")
    if not HH_EQUIP_BUFF_LIST then
        return
    end

    for _, effect_id in ipairs(LIFE_EFFECTS) do
        local effect = HH_EQUIP_BUFF_LIST[effect_id]
        if effect then
            effect.can_add = true
            if effect.ui_from_desc == "获取途径未开放" then
                effect.ui_from_desc = "已加入正常随机池"
            end
        end
    end

    print("[附魔补丁] 已开启生命附魔石进入正常随机池")
end

EnableLifeEffects()

AddSimPostInit(function()
    EnableLifeEffects()
end)
