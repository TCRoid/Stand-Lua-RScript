---------------------------------
------------ 开发者选项 -----------
---------------------------------

menu.action(Dev_options, "Copy Coords & Heading", {}, "", function()
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
menu.click_slider_float(Dev_options, "SET_PICKUP_GENERATION_RANGE_MULTIPLIER", {}, "", 0, 100000, 0, 100,
    function(value)
        OBJECT.SET_PICKUP_GENERATION_RANGE_MULTIPLIER(value * 0.01)
    end)


----- 信息显示 -----
local ent_info = menu.list(Dev_options, "信息显示", {}, "")

local ent_info_target = 0
local ent_info_list = {}

menu.toggle_loop(ent_info, "开启[E键]", {}, "", function()
    draw_point_in_center()

    local result = get_raycast_result(1500, -1)
    if result.didHit then
        local ent = result.hitEntity

        if PAD.IS_CONTROL_PRESSED(0, 51) and ENTITY.IS_ENTITY_A_PED(ent) then
            ent_info_target = ent
            util.toast(ENTITY.GET_ENTITY_MODEL(ent))
        end

    end
end)

ent_info_list[1] = menu.readonly(ent_info, "Hash")
ent_info_list[2] = menu.readonly(ent_info, "IS_PED_IN_MELEE_COMBAT")
ent_info_list[3] = menu.readonly(ent_info, "IS_PED_IN_COMBAT")
ent_info_list[4] = menu.readonly(ent_info, "CAN_PED_SEE_HATED_PED")
ent_info_list[5] = menu.readonly(ent_info, "CAN_PED_HEAR_PLAYER")

menu.on_tick_in_viewport(ent_info_list[1], function()
    if ENTITY.DOES_ENTITY_EXIST(ent_info_target) then
        menu.set_value(ent_info_list[1], ENTITY.GET_ENTITY_MODEL(ent_info_target))
        menu.set_value(ent_info_list[2], bool_to_string(PED.IS_PED_IN_MELEE_COMBAT(ent_info_target)))
        menu.set_value(ent_info_list[3], bool_to_string(PED.IS_PED_IN_COMBAT(ent_info_target, players.user_ped())))
        menu.set_value(ent_info_list[4], bool_to_string(PED.CAN_PED_SEE_HATED_PED(ent_info_target, players.user_ped())))
        menu.set_value(ent_info_list[5], bool_to_string(PLAYER.CAN_PED_HEAR_PLAYER(players.user(), ent_info_target)))

    end
end)
