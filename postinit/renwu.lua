-- 移除所有破坏植物的San值惩罚
AddPrefabPostInit("wormwood", function(inst)
    if inst.components.sanity then
        inst:RemoveEventCallback("plantkilled", inst._onplantkilled, TheWorld)
    end
end)