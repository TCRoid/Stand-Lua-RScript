---------------------------------
------------ 开发者选项 -----------
---------------------------------

menu.action(Dev_options, "Copy My Coords & Heading", { "copymypos" }, "", function()
    local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    local heading = ENTITY.GET_ENTITY_HEADING(players.user_ped())
    local text = coords.x .. ", " .. coords.y .. ", " .. coords.z .. "\n" .. heading
    util.copy_to_clipboard(text, false)
    util.toast("Copied!\n" .. text)
end)
menu.action(Dev_options, "GET_ENTITY_HEADING", {}, "", function()
    util.toast(ENTITY.GET_ENTITY_HEADING(players.user_ped()))
end)
menu.action(Dev_options, "GET_NETWORK_TIME", {}, "", function()
    util.toast(NETWORK.GET_NETWORK_TIME())
end)
menu.action(Dev_options, "GET_MAX_RANGE_OF_CURRENT_PED_WEAPON", {}, "", function()
    util.toast(WEAPON.GET_MAX_RANGE_OF_CURRENT_PED_WEAPON(players.user_ped()))
end)
menu.action(Dev_options, "Clear Player Ped Tasks", { "clstask" }, "", function()
    local ped = players.user_ped()
    TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
    TASK.CLEAR_PED_TASKS(ped)
    TASK.CLEAR_DEFAULT_PRIMARY_TASK(ped)
    TASK.CLEAR_PED_SECONDARY_TASK(ped)
    TASK.TASK_CLEAR_LOOK_AT(ped)
    TASK.TASK_CLEAR_DEFENSIVE_AREA(ped)
    TASK.CLEAR_DRIVEBY_TASK_UNDERNEATH_DRIVING_TASK(ped)
end)
menu.action(Dev_options, "GET_PICKUP_GENERATION_RANGE_MULTIPLIER", {}, "", function()
    util.toast(OBJECT.GET_PICKUP_GENERATION_RANGE_MULTIPLIER())
end)
menu.click_slider_float(Dev_options, "SET_PICKUP_GENERATION_RANGE_MULTIPLIER", {}, "",
    0, 100000, 0, 100, function(value)
    OBJECT.SET_PICKUP_GENERATION_RANGE_MULTIPLIER(value * 0.01)
end)

menu.action(Dev_options, "FORCE_PED_AI_AND_ANIMATION_UPDATE", {}, "", function()
    PED.FORCE_PED_AI_AND_ANIMATION_UPDATE(players.user_ped())
end)




local radius_draw_sphere = 10.0
local dev_draw_sphere = menu.slider_float(Dev_options, "DRAW_MARKER_SPHERE", { "radius_draw_sphere" }, "",
        0, 100000, 1000, 100, function(value)
        radius_draw_sphere = value * 0.01
    end)
menu.on_tick_in_viewport(dev_draw_sphere, function()
    if menu.is_focused(dev_draw_sphere) then
        local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        DRAW_MARKER_SPHERE(coords, radius_draw_sphere)
    end
end)



----- 信息显示 -----
local ent_info = menu.list(Dev_options, "信息显示", {}, "")

local ent_info_target = 0
local ent_info_list = {}

menu.toggle_loop(ent_info, "开启[E键]", {}, "", function()
    draw_point_in_center()

    if PAD.IS_CONTROL_PRESSED(0, 51) then
        local result = get_raycast_result(1500, -1)
        if result.didHit then
            local ent = result.hitEntity
            if IS_AN_ENTITY(ent) then
                ent_info_target = ent
                util.toast(ENTITY.GET_ENTITY_MODEL(ent) .. "\n" .. GET_ENTITY_TYPE(ent))
            end
        end
    end
end)

ent_info_list.hash = menu.readonly(ent_info, "Hash")
ent_info_list.type = menu.readonly(ent_info, "Type")


menu.divider(ent_info, "VEHICLE")
ent_info_list.max_passengers = menu.readonly(ent_info, "MAX_NUMBER_OF_PASSENGERS")
ent_info_list.number_seats = menu.readonly(ent_info, "NUMBER_OF_SEATS")

menu.on_tick_in_viewport(ent_info_list.hash, function()
    local ent = ent_info_target
    if ENTITY.DOES_ENTITY_EXIST(ent) then
        local hash = ENTITY.GET_ENTITY_MODEL(ent)
        menu.set_value(ent_info_list.hash, hash)
        menu.set_value(ent_info_list.type, GET_ENTITY_TYPE(ent))

        -- if ENTITY.IS_ENTITY_A_PED(ent) then
        -- end

        if ENTITY.IS_ENTITY_A_VEHICLE(ent) then
            menu.set_value(ent_info_list.max_passengers, VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(ent))
            menu.set_value(ent_info_list.number_seats, VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(hash))
        end
    end
end)



----- 实体控制 -----
local ent_ctrl = menu.list(Dev_options, "实体控制", {}, "")

local ent_ctrl_target = 0

menu.toggle_loop(ent_ctrl, "开启[E键]", {}, "", function()
    draw_point_in_center()

    local result = get_raycast_result(1500.0, -1)
    if result.didHit then
        local ent = result.hitEntity

        if PAD.IS_CONTROL_PRESSED(0, 51) and IS_AN_ENTITY(ent) then
            ent_ctrl_target = ent
            util.toast(GET_ENTITY_TYPE(ent) .. ": " .. ENTITY.GET_ENTITY_MODEL(ent))
        end
    end
end)


menu.action(ent_ctrl, "坠落爆炸", {}, "", function()
    local ent = ent_ctrl_target
    if ENTITY.DOES_ENTITY_EXIST(ent) then
        ENTITY.FREEZE_ENTITY_POSITION(ent, false)
        ENTITY.SET_ENTITY_MAX_SPEED(ent, 99999.0)
        if ENTITY.IS_ENTITY_A_PED(ent) then
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(ent)
        end

        for i = 1, 3, 1 do
            if ENTITY.IS_ENTITY_A_PED(ent) then
                PED.SET_PED_TO_RAGDOLL(ent, 500, 500, 0, false, false, false)
            end
            ENTITY.APPLY_FORCE_TO_ENTITY(ent, 1, 0.0, 0.0, 30.0, math.random( -2, 2), math.random( -2, 2), 0.0, 0, false,
                false, true,
                false, false)
            util.yield(1000)
            ENTITY.APPLY_FORCE_TO_ENTITY(ent, 1, 0.0, 0.0, -100.0, 0.0, 0.0, 0.0, 0, false
                , false, true, false, false)
            util.yield(300)
        end

        local coords = ENTITY.GET_ENTITY_COORDS(ent)
        FIRE.ADD_OWNED_EXPLOSION(players.user_ped(), coords.x, coords.y, coords.z, 4, 1.0, true, false, 0.0)
    end
end)






------------

menu.toggle_loop(Dev_options, "GET_IS_TASK_ACTIVE", { "show_active_task" }, "", function()
    for i = 0, 530, 1 do
        if TASK.GET_IS_TASK_ACTIVE(players.user_ped(), i) then
            util.draw_debug_text("Task Active: " .. tostring(i))
        end
    end
end)

menu.toggle_loop(Dev_options, "NOTHING", {}, "", function()
end)
