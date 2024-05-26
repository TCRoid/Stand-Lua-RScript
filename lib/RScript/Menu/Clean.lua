------------------------------------------
--          Clean Options
------------------------------------------


local Clean_Options <const> = menu.list(Menu_Root, "清理选项", {}, "移除，清理等")

local MenuClean = {}


--#region Clear Area

local Clear_Area <const> = menu.list(Clean_Options, "清理区域", {}, "无法清理任务实体")

MenuClean.Area = {
    radius = 100,
    broadcast = 1,
}

menu.toggle_loop(Clear_Area, "清理区域", { "clsArea" }, "清理区域内所有东西", function()
    local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    MISC.CLEAR_AREA(coords.x, coords.y, coords.z, MenuClean.Area.radius, true, false, false, cls_broadcast)
end)
menu.toggle_loop(Clear_Area, "清理载具", { "clsVehicles" }, "清理区域内所有载具", function()
    local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    MISC.CLEAR_AREA_OF_VEHICLES(coords.x, coords.y, coords.z, MenuClean.Area.radius, false, false, false, false,
        cls_broadcast, false, 0)
end)
menu.toggle_loop(Clear_Area, "清理行人", { "clsPeds" }, "清理区域内所有行人", function()
    local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    MISC.CLEAR_AREA_OF_PEDS(coords.x, coords.y, coords.z, MenuClean.Area.radius, cls_broadcast)
end)
menu.toggle_loop(Clear_Area, "清理警察", { "clsCops" }, "清理区域内所有警察", function()
    local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    MISC.CLEAR_AREA_OF_COPS(coords.x, coords.y, coords.z, MenuClean.Area.radius, cls_broadcast)
end)
menu.toggle_loop(Clear_Area, "清理物体", { "clsObjects" }, "清理区域内所有物体", function()
    local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    MISC.CLEAR_AREA_OF_OBJECTS(coords.x, coords.y, coords.z, MenuClean.Area.radius, cls_broadcast)
end)
menu.toggle_loop(Clear_Area, "清理投掷物", { "clsProjectiles" }, "清理区域内所有子弹、炮弹、投掷物等",
    function()
        local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        MISC.CLEAR_AREA_OF_PROJECTILES(coords.x, coords.y, coords.z, MenuClean.Area.radius, cls_broadcast)
    end)

menu.divider(Clear_Area, "设置")
menu.slider_float(Clear_Area, "范围半径", { "clsRadius" }, "",
    0, 100000, MenuClean.Area.radius * 100, 1000, function(value)
        MenuClean.Area.radius = value * 0.01
    end)
menu.toggle(Clear_Area, "同步到其它玩家", { "clsBroadcast" }, "", function(toggle)
    MenuClean.Area.broadcast = toggle and 1 or 0
    util.toast("清理区域 网络同步: " .. tostring(toggle and "开" or "关"))
end, true)


--#endregion Clear Area



menu.toggle_loop(Clean_Options, "移除爆炸和火焰", { "clsFire" }, "范围: 30", function()
    local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    FIRE.STOP_FIRE_IN_RANGE(pos.x, pos.y, pos.z, 30.0)
    FIRE.STOP_ENTITY_FIRE(players.user_ped())
end)
menu.toggle_loop(Clean_Options, "移除粒子效果", { "clsPtfx" }, "范围: 30", function()
    local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    GRAPHICS.REMOVE_PARTICLE_FX_IN_RANGE(pos.x, pos.y, pos.z, 30.0)
    GRAPHICS.REMOVE_PARTICLE_FX_FROM_ENTITY(players.user_ped())
end)
menu.toggle_loop(Clean_Options, "移除视觉效果", { "clsGraphics" }, "", function()
    GRAPHICS.ANIMPOSTFX_STOP_ALL()
    GRAPHICS.CLEAR_TIMECYCLE_MODIFIER()
    --GRAPHICS.SET_TIMECYCLE_MODIFIER("DEFAULT")
end)
menu.toggle_loop(Clean_Options, "移除载具上的黏弹", {}, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        NETWORK.REMOVE_ALL_STICKY_BOMBS_FROM_ENTITY(vehicle, 0)
    end
end)
menu.toggle_loop(Clean_Options, "停止所有声音", {}, "", function()
    for i = 0, 99 do
        AUDIO.STOP_SOUND(i)
        AUDIO.RELEASE_SOUND_ID(i)
    end
end)

menu.divider(Clean_Options, "")
menu.action(Clean_Options, "清理已死亡的任务载具", {}, "", function()
    local num = 0
    for _, ent in pairs(entities.get_all_vehicles_as_handles()) do
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) and ENTITY.IS_ENTITY_DEAD(ent) then
            entities.delete(ent)

            if not ENTITY.DOES_ENTITY_EXIST(num) then
                num = num + 1
            end
        end
    end

    if num > 0 then
        util.toast("清理任务载具数量: " .. num)
    end
end)
menu.action(Clean_Options, "清理已死亡的任务NPC", {}, "", function()
    local num = 0
    for _, ent in pairs(entities.get_all_peds_as_handles()) do
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) and ENTITY.IS_ENTITY_DEAD(ent) then
            entities.delete(ent)

            if not ENTITY.DOES_ENTITY_EXIST(num) then
                num = num + 1
            end
        end
    end

    if num > 0 then
        util.toast("清理任务NPC数量: " .. num)
    end
end)
menu.action(Clean_Options, "中断当前动作", { "clsTask" }, "", function()
    TASK.CLEAR_PED_TASKS_IMMEDIATELY(players.user_ped())
end)
