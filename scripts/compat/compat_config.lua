local compat_config = {
    modules = {
        {
            name = "棱镜",
            file = "prism",
            mod_id = "workshop-1392778117",
        },
		{
            name = "海洋传说",
            file = "hycs",
            mod_id = "workshop-2979177306",
        },
		{
            name = "登仙",
            file = "dx",
            mod_id = "workshop-3235319974",
       },
		{
            name = "能力勋章",
            file = "nlxz",
            mod_id = "workshop-1909182187",
        },
        {
            name = "永不妥协",
            file = "ybtx",
            mod_id = "workshop-2039181790",
        },
        -- 未来添加其他模组兼容时，只需在此处添加配置
        -- 示例：
        -- {
        --     name = "Another Mod Compat",
        --     file = "another_mod_compat",
        --     mod_id = "workshop-XXXXXXXXX",
        -- }
    }
}

return compat_config