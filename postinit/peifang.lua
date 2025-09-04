Ingredient = GLOBAL.Ingredient
TECH = GLOBAL.TECH


-- 检查模组是否启用
-- if not GLOBAL.KnownModIndex:IsModEnabled("workshop-3096210166") then return end

--星星法杖
AddRecipePostInit("hh_staff_star", function(recipe)
  -- 替换材料
  recipe.ingredients = {
    Ingredient("opalpreciousgem", 100000)
  }
end)

--冰刃
AddRecipePostInit("hh_ice_knife", function(recipe)
  -- 替换材料
  recipe.ingredients = {
    Ingredient("opalpreciousgem", 100000)
  }
end)
