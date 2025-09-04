Ingredient = GLOBAL.Ingredient
TECH = GLOBAL.TECH


if GLOBAL.GemEnabled then
  local MAX_ITEM_TRIGGERS = GetModConfigData("XIAOREN_COUNT")

  -- 只包含联机版实际存在的宝石
  local gems = {
    "redgem",    -- 红宝石
    "orangegem", -- 橙宝石
    "bluegem",   -- 蓝宝石
    -- "purplegem"  -- 紫宝石
  }

  -- 为每种宝石添加配方
  for _, gem in ipairs(gems) do
    AddRecipe2(gem,
      { Ingredient("hh_essence", MAX_ITEM_TRIGGERS) }, -- 材料：小人精华
      TECH.NONE,                                       -- 无科技要求
      {
        name = gem .. "简易合成",
        -- atlas = GetSafeAtlas(gem), -- 使用安全的图标路径
        numtogive = 1,
        no_deconstruction = true -- 禁止分解

      },
      { "NONE" } -- 分类
    )
  end
end
