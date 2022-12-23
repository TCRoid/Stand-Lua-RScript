-----------------------------------
------------ 世界实体选项 -----------
-----------------------------------

local Entity_options = menu.list(menu.my_root(), "世界实体选项", {}, "")



local Entity_NEAR_PED_CAM = menu.list(Entity_options, "管理附近的NPC、摄像头和门", {}, "")
-----
menu.divider(Entity_NEAR_PED_CAM, "NPC选项")
local NEAR_PED_onlyHostile = false
menu.toggle(Entity_NEAR_PED_CAM, "只作用于敌对NPC", {}, "启用：只对怀有敌意的NPC生效\n禁用：对所有NPC生效"
    , function(toggle)
    NEAR_PED_onlyHostile = toggle
end)
menu.action(Entity_NEAR_PED_CAM, "移除武器", {}, "", function()
    for _, ent in pairs(entities.get_all_peds_as_handles()) do
        if not IS_PED_PLAYER(ent) then
            if NEAR_PED_onlyHostile then
                if PED.IS_PED_IN_COMBAT(ent, PLAYER.PLAYER_PED_ID()) then
                    WEAPON.REMOVE_ALL_PED_WEAPONS(ent, true)
                end
            else
                WEAPON.REMOVE_ALL_PED_WEAPONS(ent, true)
            end
        end
    end
end)
menu.action(Entity_NEAR_PED_CAM, "删除", { "delete_ped" }, "", function()
    for _, ent in pairs(entities.get_all_peds_as_handles()) do
        if not IS_PED_PLAYER(ent) then
            if NEAR_PED_onlyHostile then
                if PED.IS_PED_IN_COMBAT(ent, PLAYER.PLAYER_PED_ID()) then
                    entities.delete_by_handle(ent)
                end
            else
                entities.delete_by_handle(ent)
            end
        end
    end
end)
menu.action(Entity_NEAR_PED_CAM, "死亡", { "dead_ped" }, "", function()
    for _, ent in pairs(entities.get_all_peds_as_handles()) do
        if not IS_PED_PLAYER(ent) and not ENTITY.IS_ENTITY_DEAD(ent) then
            if NEAR_PED_onlyHostile then
                if PED.IS_PED_IN_COMBAT(ent, PLAYER.PLAYER_PED_ID()) then
                    ENTITY.SET_ENTITY_HEALTH(ent, 0)
                end
            else
                ENTITY.SET_ENTITY_HEALTH(ent, 0)
            end
        end
    end
end)
menu.action(Entity_NEAR_PED_CAM, "爆头击杀", { "kill_ped" }, "", function()
    local weaponHash = util.joaat("WEAPON_APPISTOL")
    for _, ent in pairs(entities.get_all_peds_as_handles()) do
        if not IS_PED_PLAYER(ent) and not ENTITY.IS_ENTITY_DEAD(ent) then
            local ped = nil
            if NEAR_PED_onlyHostile then
                if PED.IS_PED_IN_COMBAT(ent, players.user_ped()) then
                    ped = ent
                end
            else
                ped = ent
            end

            if ped ~= nil then
                local head_pos = PED.GET_PED_BONE_COORDS(ped, 0x322c, 0, 0, 0)
                --local start_pos = vect.add(head_pos, { x = 0.0, y = 0.0, z = 0.1 })
                local ped_veh = GET_VEHICLE_PED_IS_IN(ped)
                if ped_veh then
                    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(head_pos.x, head_pos.y, head_pos.z + 0.1,
                        head_pos.x,
                        head_pos.y, head_pos.z, 1000, false, weaponHash, players.user_ped(),
                        false, false, 1000, ped_veh)
                else
                    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(head_pos.x, head_pos.y, head_pos.z + 0.1, head_pos.x,
                        head_pos.y, head_pos.z, 1000, false, weaponHash, players.user_ped(),
                        false, false, 1000)
                end
            end

        end
    end
end)
-----
menu.divider(Entity_NEAR_PED_CAM, "摄像头选项")
local Cams = {
    -1233322078, --ch_prop_ch_cctv_cam_02a
    3061645218, -- same as above
    168901740, --prop_cctv_cam_06a
    -1095296451, --prop_cctv_cam_04a
    -173206916, --prop_cctv_cam_05a
    -1159421424, --prop_cctv_cam_02a
    548760764, --prop_cctv_cam_01a
    -1340405475, --prop_cctv_cam_07a
    1449155105, --prop_cctv_cam_03a
    -354221800, --prop_cctv_cam_01b
    -1884701657, --prop_cctv_cam_04c
    2090203758, --prop_cs_cctv
    -1007354661, --hei_prop_bank_cctv_01
    -1842407088, --hei_prop_bank_cctv_02
    289451089, --p_cctv_s
    -247409812, --xm_prop_x17_server_farm_cctv_01
    2135655372 --prop_cctv_pole_04
}
local Cams2 = {
    1919058329, --prop_cctv_cam_04b
    1849991131 --prop_snow_cam_03a
}

menu.action(Entity_NEAR_PED_CAM, "删除", { "delete_cam" }, "", function()
    for _, ent in pairs(entities.get_all_objects_as_handles()) do
        local EntityModel = ENTITY.GET_ENTITY_MODEL(ent)
        for i = 1, #Cams do
            if EntityModel == Cams[i] then
                entities.delete_by_handle(ent)
            end
        end
    end
end)
menu.click_slider(Entity_NEAR_PED_CAM, "上下移动", { "near_cam_set" }, "易导致bug", -10, 10, 0, 1,
    function(value)
        for _, ent in pairs(entities.get_all_objects_as_handles()) do
            local EntityModel = ENTITY.GET_ENTITY_MODEL(ent)
            for i = 1, #Cams do
                if EntityModel == Cams[i] then
                    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, 0.0, 0.0, value)
                    ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
                end
            end
        end
    end)
-----
menu.divider(Entity_NEAR_PED_CAM, "")
local Entity_NEAR_DOOR = menu.list(Entity_NEAR_PED_CAM, "门选项（本地）", {}, "只对你自己有效")
menu.divider(Entity_NEAR_DOOR, "佩里科岛的门")
local Perico_Doors = {
    --豪宅内 各种铁门
    -1052729812, --h4_prop_h4_gate_l_01a
    1866987242, --h4_prop_h4_gate_r_01a
    -1360938964, --h4_prop_h4_gate_02a
    -2058786200, --h4_prop_h4_gate_03a
    -630812075, --h4_prop_h4_gate_05a
    --豪宅内 电梯门
    -1240156945, --v_ilev_garageliftdoor
    -576022807, ----h4_prop_office_elevator_door_01
    --豪宅大门
    -1574151574, --h4_prop_h4_gate_r_03a
    1215477734, --h4_prop_h4_gate_l_03a
    --豪宅外 铁门
    227019171, --prop_fnclink_02gate6_r
    1526539404, --prop_fnclink_02gate6_l
    141297241, --h4_prop_h4_garage_door_01a
    -1156020871 --prop_fnclink_03gate5
}
local Perico_Doors2 = -607013269 --h4_prop_h4_door_01a 豪宅内的库房门

menu.action(Entity_NEAR_DOOR, "删除门", { "delete_door" }, "", function()
    for _, ent in pairs(entities.get_all_objects_as_handles()) do
        local EntityModel = ENTITY.GET_ENTITY_MODEL(ent)
        for i = 1, #Perico_Doors do
            if EntityModel == Perico_Doors[i] then
                entities.delete_by_handle(ent)
            end
        end
    end
end)
menu.action(Entity_NEAR_DOOR, "开启无碰撞", {}, "可以直接穿过门，包括库房门", function()
    for _, ent in pairs(entities.get_all_objects_as_handles()) do
        local EntityModel = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityModel == Perico_Doors2 then
            ENTITY.SET_ENTITY_COLLISION(ent, false, true)
        else
            for i = 1, #Perico_Doors do
                if EntityModel == Perico_Doors[i] then
                    ENTITY.SET_ENTITY_COLLISION(ent, false, true)
                end
            end
        end
    end
end)
menu.action(Entity_NEAR_DOOR, "关闭无碰撞", {}, "", function()
    for _, ent in pairs(entities.get_all_objects_as_handles()) do
        local EntityModel = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityModel == Perico_Doors2 then
            ENTITY.SET_ENTITY_COLLISION(ent, true, true)
        else
            for i = 1, #Perico_Doors do
                if EntityModel == Perico_Doors[i] then
                    ENTITY.SET_ENTITY_COLLISION(ent, true, true)
                end
            end
        end
    end
end)


-----
-- 会自崩
--menu.divider(Entity_NEAR_DOOR, "赌场的门")
local Casion_Doors = {
    1243560448, --ch_prop_ch_service_door_02c
    -1498975473, --ch_prop_ch_service_door_02a
    1938754783, --ch_prop_ch_service_door_02b
    -2050208642, --ch_prop_ch_vault_d_door_01a 小金库的门
    1226684428, --ch_prop_casino_door_01b
    270965283, --ch_prop_ch_gendoor_01 楼梯门
    1129244853, --ch_prop_ch_secure_door_r
    -1940292931, --ch_prop_ch_secure_door_l
    -1549164937, --ch_prop_ch_tunnel_door_01_r
    -1710290106, --ch_prop_ch_tunnel_door_01_l
    -1241631688, --ch_des_heist3_vault_01 金库大门
    -219532439, --ch_prop_ch_vault_slide_door_lrg
    -754698435 --ch_prop_ch_vault_slide_door_sm
}
-- menu.action(Entity_NEAR_DOOR, "删除门", {}, "", function()
--     for _, ent in pairs(entities.get_all_objects_as_handles()) do
--         local EntityModel = ENTITY.GET_ENTITY_MODEL(ent)
--         for i = 1, #Casion_Doors do
--             if EntityModel == Casion_Doors[i] then
--                 entities.delete_by_handle(ent)
--             end
--         end
--     end
-- end)
-- menu.action(Entity_NEAR_DOOR, "无碰撞", {}, "可以直接穿过门", function()
--     for _, ent in pairs(entities.get_all_objects_as_handles()) do
--         local EntityModel = ENTITY.GET_ENTITY_MODEL(ent)
--         for i = 1, #Casion_Doors do
--             if EntityModel == Casion_Doors[i] then
--                 ENTITY.SET_ENTITY_COLLISION(ent, false, true)
--             end
--         end
--     end
-- end)





-------------------------------------
------ Nearby Entity Functions ------
--------------- START ---------------

-------------
-- Vehicle --
-------------
local control_nearby_vehicles_toggles = {
    --Trolling
    remove_godmode = false,
    explosion = false,
    emp = false,
    broken_door = false,
    open_door = false,
    kill_engine = false,
    burst_tyre = false,
    full_dirt = false,
    remove_window = false,
    leave_vehicle = false,
    forward_speed = false,
    max_speed = false,
    alpha = false,
    --Friendly
    godmode = false,
    fix_vehicle = false,
    fix_engine = false,
    fix_tyre = false,
    clean_dirt = false,
}
local control_nearby_vehicles_data = {
    forward_speed = 30,
    max_speed = 0,
    alpha = 0,
}
local control_nearby_vehicles_setting = {
    radius = 30.0,
    time_delay = 1000,
    exclude_mission = true,
    exclude_dead = true
}

local is_Control_nearby_vehicles = false
local function control_nearby_vehicles()
    util.create_tick_handler(function()
        local is_all_false = true
        for _, i in pairs(control_nearby_vehicles_toggles) do
            if i then
                is_all_false = false
            end
        end
        if is_all_false then
            is_Control_nearby_vehicles = false
            return
        end
        -----
        is_Control_nearby_vehicles = true
        for k, vehicle in ipairs(GET_NEARBY_VEHICLES(players.user(), control_nearby_vehicles_setting.radius)) do
            if IS_PLAYER_VEHICLE(vehicle) then
                --排除玩家载具
            elseif control_nearby_vehicles_setting.exclude_mission and ENTITY.IS_ENTITY_A_MISSION_ENTITY(vehicle) then
                --排除任务载具
            elseif control_nearby_vehicles_setting.exclude_dead and ENTITY.IS_ENTITY_DEAD(vehicle) then
                --排除已死亡实体
            else
                --请求控制
                RequestControl(vehicle)
                --移除无敌
                if control_nearby_vehicles_toggles.remove_godmode then
                    ENTITY.SET_ENTITY_INVINCIBLE(vehicle, false)
                    ENTITY.SET_ENTITY_PROOFS(vehicle, false, false, false, false, false, false, false, false)
                end
                --爆炸
                if control_nearby_vehicles_toggles.explosion then
                    local pos = ENTITY.GET_ENTITY_COORDS(vehicle)
                    FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, 2, 1000.0, true, false, 0, false)
                end
                --电磁脉冲
                if control_nearby_vehicles_toggles.emp then
                    local pos = ENTITY.GET_ENTITY_COORDS(vehicle)
                    FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, 65, 1.0, true, false, 0, false)
                end
                --拆下车门
                if control_nearby_vehicles_toggles.broken_door then
                    for i = 0, 3 do
                        VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, i, false)
                    end
                end
                --打开车门
                if control_nearby_vehicles_toggles.open_door then
                    for i = 0, 3 do
                        VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, i, false, false)
                    end
                end
                --破坏引擎
                if control_nearby_vehicles_toggles.kill_engine then
                    VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, -4000)
                end
                --爆胎
                if control_nearby_vehicles_toggles.burst_tyre then
                    for i = 0, 5 do
                        if not VEHICLE.IS_VEHICLE_TYRE_BURST(vehicle, i, true) then
                            VEHICLE.SET_VEHICLE_TYRE_BURST(vehicle, i, true, 1000.0)
                        end
                    end
                end
                --布满灰尘
                if control_nearby_vehicles_toggles.full_dirt then
                    VEHICLE.SET_VEHICLE_DIRT_LEVEL(vehicle, 15.0)
                end
                --删除车窗
                if control_nearby_vehicles_toggles.remove_window then
                    for i = 0, 7 do
                        VEHICLE.REMOVE_VEHICLE_WINDOW(vehicle, i)
                    end
                end
                --跳出载具
                if control_nearby_vehicles_toggles.leave_vehicle then
                    local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
                    if ped and not TASK.GET_IS_TASK_ACTIVE(ped, 176) then
                        TASK.TASK_LEAVE_VEHICLE(ped, vehicle, 4160)
                    end
                end
                --向前加速
                if control_nearby_vehicles_toggles.forward_speed then
                    VEHICLE.SET_VEHICLE_FORWARD_SPEED(vehicle, control_nearby_vehicles_data.forward_speed)
                end
                --实体最大速度
                if control_nearby_vehicles_toggles.max_speed then
                    ENTITY.SET_ENTITY_MAX_SPEED(vehicle, control_nearby_vehicles_data.max_speed)
                end
                --透明度
                if control_nearby_vehicles_toggles.alpha then
                    ENTITY.SET_ENTITY_ALPHA(vehicle, control_nearby_vehicles_data.alpha, false)
                end
                ------
                --给予无敌
                if control_nearby_vehicles_toggles.godmode then
                    ENTITY.SET_ENTITY_INVINCIBLE(vehicle, true)
                end
                --修复载具
                if control_nearby_vehicles_toggles.fix_vehicle then
                    VEHICLE.SET_VEHICLE_FIXED(vehicle)
                end
                --修复引擎
                if control_nearby_vehicles_toggles.fix_engine then
                    VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, 1000)
                end
                --修复轮胎
                if control_nearby_vehicles_toggles.fix_tyre then
                    for i = 0, 3 do
                        VEHICLE.SET_VEHICLE_TYRE_FIXED(vehicle, i)
                    end
                end
                --清理载具
                if control_nearby_vehicles_toggles.clean_dirt then
                    VEHICLE.SET_VEHICLE_DIRT_LEVEL(vehicle, 0.0)
                end

            end
        end

        util.yield(control_nearby_vehicles_setting.time_delay)
        ----

    end)
end

---------
-- Ped --
---------
local control_nearby_peds_toggles = {
    --Trolling
    force_forward = false,
    drop_weapon = false,
    ignore_events = false,
    explode_head = false,
    --Friendly
    drop_money = false,
    give_weapon = false
}
local control_nearby_peds_data = {
    forward_degree = 30,
    drop_money_amount = 100,
    weapon_hash = 4130548542
}
local control_nearby_peds_setting = {
    radius = 30.0,
    time_delay = 1000,
    exclude_ped_in_vehicle = true,
    exclude_mission = true,
    exclude_dead = true
}

local is_Control_nearby_peds = false
local function control_nearby_peds()
    util.create_tick_handler(function()
        local is_all_false = true
        for _, i in pairs(control_nearby_peds_toggles) do
            if i then
                is_all_false = false
            end
        end
        if is_all_false then
            is_Control_nearby_peds = false
            return
        end
        -----
        is_Control_nearby_peds = true
        for k, ped in ipairs(GET_NEARBY_PEDS(players.user(), control_nearby_peds_setting.radius)) do
            if IS_PED_PLAYER(ped) then
                --排除玩家
            elseif control_nearby_peds_setting.exclude_ped_in_vehicle and PED.IS_PED_IN_ANY_VEHICLE(ped, true) then
                --排除载具内NPC
            elseif control_nearby_peds_setting.exclude_mission and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ped) then
                --排除任务NPC
            elseif control_nearby_peds_setting.exclude_dead and ENTITY.IS_ENTITY_DEAD(ped) then
                --排除已死亡实体
            else
                --请求控制
                RequestControl(ped)
                --向前推进
                if control_nearby_peds_toggles.force_forward then
                    ENTITY.SET_ENTITY_MAX_SPEED(ped, 99999)
                    local vector = ENTITY.GET_ENTITY_FORWARD_VECTOR(ped)
                    local force = vect.mult(vector, control_nearby_peds_data.forward_degree)
                    ENTITY.APPLY_FORCE_TO_ENTITY(ped, 1, force.x, force.y, force.z, 0.0, 0.0, 0.0, 1, false, true,
                        true, true, true)
                end
                --丢弃武器
                if control_nearby_peds_toggles.drop_weapon then
                    WEAPON.SET_PED_DROPS_WEAPONS_WHEN_DEAD(ped)
                    WEAPON.SET_PED_DROPS_WEAPON(ped)
                    WEAPON.SET_PED_AMMO_TO_DROP(ped, 9999)
                end
                --忽略其它临时事件
                if control_nearby_peds_toggles.ignore_events then
                    PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
                    TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
                end
                --爆头
                if control_nearby_peds_toggles.explode_head then
                    local weaponHash = util.joaat("WEAPON_APPISTOL")
                    PED.EXPLODE_PED_HEAD(ped, weaponHash)
                end
                --------
                --修改掉落现金
                if control_nearby_peds_toggles.drop_money then
                    PED.SET_PED_MONEY(ped, control_nearby_peds_data.drop_money_amount)
                    PED.SET_AMBIENT_PEDS_DROP_MONEY(true)
                end
                --给予武器
                if control_nearby_peds_toggles.give_weapon then
                    WEAPON.GIVE_WEAPON_TO_PED(ped, control_nearby_peds_data.weapon_hash, -1, false, true)
                    WEAPON.SET_CURRENT_PED_WEAPON(ped, control_nearby_peds_data.weapon_hash, false)
                end

            end
        end

        util.yield(control_nearby_peds_setting.time_delay)
        ----

    end)
end

------ Nearby Entity Functions ------
---------------- END ----------------


------------------
----- 附近载具 -----
------------------
local Nearby_Vehicle_options = menu.list(Entity_options, "管理附近载具", {}, "")

menu.slider_float(Nearby_Vehicle_options, "范围半径", { "radius_nearby_vehicle" }, "若半径是0，则为全部范围"
    , 0, 100000, 3000, 1000,
    function(value)
        control_nearby_vehicles_setting.radius = value
    end)
menu.toggle_loop(Nearby_Vehicle_options, "绘制范围", {}, "", function()
    local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
    GRAPHICS.DRAW_MARKER_SPHERE(coords.x, coords.y, coords.z, control_nearby_vehicles_setting.radius, 200, 50, 200, 0.5)
end)

local Nearby_Vehicle_Setting = menu.list(Nearby_Vehicle_options, "设置", {}, "")
menu.slider(Nearby_Vehicle_Setting, "时间间隔", { "delay_nearby_vehicle" }, "单位: ms", 0, 5000, 1000, 100,
    function(value)
        control_nearby_vehicles_setting.time_delay = value
    end)
menu.toggle(Nearby_Vehicle_Setting, "排除任务载具", {}, "", function(toggle)
    control_nearby_vehicles_setting.exclude_mission = toggle
end, true)
menu.toggle(Nearby_Vehicle_Setting, "排除已死亡实体", {}, "", function(toggle)
    control_nearby_vehicles_setting.exclude_dead = toggle
end, true)

----------------------
--  附近载具 恶搞选项
----------------------
local Nearby_Vehicle_Trolling_options = menu.list(Nearby_Vehicle_options, "恶搞选项", {}, "")
menu.toggle(Nearby_Vehicle_Trolling_options, "移除无敌", {}, "", function(toggle)
    control_nearby_vehicles_toggles.remove_godmode = toggle
    if not is_Control_nearby_vehicles then
        control_nearby_vehicles()
    end
end)
menu.toggle(Nearby_Vehicle_Trolling_options, "爆炸", {}, "", function(toggle)
    control_nearby_vehicles_toggles.explosion = toggle
    if not is_Control_nearby_vehicles then
        control_nearby_vehicles()
    end
end)
menu.toggle(Nearby_Vehicle_Trolling_options, "电磁脉冲", {}, "", function(toggle)
    control_nearby_vehicles_toggles.emp = toggle
    if not is_Control_nearby_vehicles then
        control_nearby_vehicles()
    end
end)
menu.toggle(Nearby_Vehicle_Trolling_options, "打开车门", {}, "", function(toggle)
    control_nearby_vehicles_toggles.open_door = toggle
    if not is_Control_nearby_vehicles then
        control_nearby_vehicles()
    end
end)
menu.toggle(Nearby_Vehicle_Trolling_options, "拆下车门", {}, "", function(toggle)
    control_nearby_vehicles_toggles.broken_door = toggle
    if not is_Control_nearby_vehicles then
        control_nearby_vehicles()
    end
end)
menu.toggle(Nearby_Vehicle_Trolling_options, "破坏引擎", {}, "", function(toggle)
    control_nearby_vehicles_toggles.kill_engine = toggle
    if not is_Control_nearby_vehicles then
        control_nearby_vehicles()
    end
end)
menu.toggle(Nearby_Vehicle_Trolling_options, "爆胎", {}, "", function(toggle)
    control_nearby_vehicles_toggles.burst_tyre = toggle
    if not is_Control_nearby_vehicles then
        control_nearby_vehicles()
    end
end)
menu.toggle(Nearby_Vehicle_Trolling_options, "布满灰尘", {}, "", function(toggle)
    control_nearby_vehicles_toggles.full_dirt = toggle
    if not is_Control_nearby_vehicles then
        control_nearby_vehicles()
    end
end)
menu.toggle(Nearby_Vehicle_Trolling_options, "删除车窗", {}, "", function(toggle)
    control_nearby_vehicles_toggles.remove_window = toggle
    if not is_Control_nearby_vehicles then
        control_nearby_vehicles()
    end
end)
menu.toggle(Nearby_Vehicle_Trolling_options, "司机跳出载具", {}, "", function(toggle)
    control_nearby_vehicles_toggles.leave_vehicle = toggle
    if not is_Control_nearby_vehicles then
        control_nearby_vehicles()
    end
end)
menu.slider(Nearby_Vehicle_Trolling_options, "设置向前加的速度", { "nearby_veh_forward_speed" }, "", 0, 1000, 30
    , 10,
    function(value)
        control_nearby_vehicles_data.forward_speed = value
    end)
menu.toggle(Nearby_Vehicle_Trolling_options, "向前加速", {}, "", function(toggle)
    control_nearby_vehicles_toggles.forward_speed = toggle
    if not is_Control_nearby_vehicles then
        control_nearby_vehicles()
    end
end)
menu.slider(Nearby_Vehicle_Trolling_options, "实体最大的速度", { "nearby_veh_max_speed" }, "", 0, 1000, 0, 10,
    function(value)
        control_nearby_vehicles_data.max_speed = value
    end)
menu.toggle(Nearby_Vehicle_Trolling_options, "设置实体最大速度", {}, "", function(toggle)
    control_nearby_vehicles_toggles.max_speed = toggle
    if not is_Control_nearby_vehicles then
        control_nearby_vehicles()
    end
end)
menu.slider(Nearby_Vehicle_Trolling_options, "透明度", { "nearby_veh_alpha" },
    "Ranging from 0 to 255 but chnages occur after every 20 percent (after every 51).", 0, 255, 0, 5,
    function(value)
        control_nearby_vehicles_data.alpha = value
    end)
menu.toggle(Nearby_Vehicle_Trolling_options, "设置透明度", {}, "", function(toggle)
    control_nearby_vehicles_toggles.alpha = toggle
    if not is_Control_nearby_vehicles then
        control_nearby_vehicles()
    end
end)

menu.action(Nearby_Vehicle_Trolling_options, "颠倒", {}, "", function()
    for k, vehicle in ipairs(GET_NEARBY_VEHICLES(players.user(), control_nearby_vehicles_setting.radius)) do
        if not IS_PLAYER_VEHICLE(vehicle) then
            ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, 0.0, 0.0, 5.0, 5.0, 0.0, 0.0, 1, false, true, true, true, true)
        end
    end
end)
menu.action(Nearby_Vehicle_Trolling_options, "随机喷漆", {}, "", function()
    for k, vehicle in ipairs(GET_NEARBY_VEHICLES(players.user(), control_nearby_vehicles_setting.radius)) do
        if not IS_PLAYER_VEHICLE(vehicle) then
            local primary, secundary = get_random_colour(), get_random_colour()
            VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(vehicle, primary.r, primary.g, primary.b)
            VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(vehicle, secundary.r, secundary.g, secundary.b)
        end
    end
end)

menu.divider(Nearby_Vehicle_Trolling_options, "载具上天")
local launch_vehicle_height = 20
menu.slider(Nearby_Vehicle_Trolling_options, "上天高度", { "launch_vehicle_height" }, "", 0, 1000, 20, 10,
    function(value)
        launch_vehicle_height = value
    end)
local launch_vehicle_freeze = false
menu.toggle(Nearby_Vehicle_Trolling_options, "冻结载具", {}, "", function(toggle)
    launch_vehicle_freeze = toggle
end)
menu.action(Nearby_Vehicle_Trolling_options, "发射上天", {}, "", function()
    for k, vehicle in ipairs(GET_NEARBY_VEHICLES(players.user(), control_nearby_vehicles_setting.radius)) do
        if not IS_PLAYER_VEHICLE(vehicle) then
            if launch_vehicle_freeze then
                ENTITY.FREEZE_ENTITY_POSITION(vehicle, true)
            end
            local pos = ENTITY.GET_ENTITY_COORDS(vehicle)
            ENTITY.SET_ENTITY_COORDS(vehicle, pos.x, pos.y, pos.z + launch_vehicle_height, false, false, false, false)
        end
    end
end)

----------------------
-- 附近载具 友好选项
----------------------
local Nearby_Vehicle_Friendly_options = menu.list(Nearby_Vehicle_options, "友好选项", {}, "")
menu.toggle(Nearby_Vehicle_Friendly_options, "给予无敌", {}, "", function(toggle)
    control_nearby_vehicles_toggles.godmode = toggle
    if not is_Control_nearby_vehicles then
        control_nearby_vehicles()
    end
end)
menu.toggle(Nearby_Vehicle_Friendly_options, "修复载具", {}, "", function(toggle)
    control_nearby_vehicles_toggles.fix_vehicle = toggle
    if not is_Control_nearby_vehicles then
        control_nearby_vehicles()
    end
end)
menu.toggle(Nearby_Vehicle_Friendly_options, "修复引擎", {}, "", function(toggle)
    control_nearby_vehicles_toggles.fix_engine = toggle
    if not is_Control_nearby_vehicles then
        control_nearby_vehicles()
    end
end)
menu.toggle(Nearby_Vehicle_Friendly_options, "修复轮胎", {}, "", function(toggle)
    control_nearby_vehicles_toggles.fix_tyre = toggle
    if not is_Control_nearby_vehicles then
        control_nearby_vehicles()
    end
end)
menu.toggle(Nearby_Vehicle_Friendly_options, "清理载具", {}, "", function(toggle)
    control_nearby_vehicles_toggles.clean_dirt = toggle
    if not is_Control_nearby_vehicles then
        control_nearby_vehicles()
    end
end)

-----
menu.divider(Nearby_Vehicle_options, "全部范围")
menu.action(Nearby_Vehicle_options, "解锁车门", { "unlock_all_vehicle" }, "", function()
    for k, vehicle in ipairs(entities.get_all_vehicles_as_handles()) do
        VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle, 1)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_PLAYER(vehicle, players.user(), false)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(vehicle, false)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_NON_SCRIPT_PLAYERS(vehicle, false)
        VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, false)
    end
end)
menu.action(Nearby_Vehicle_options, "打开左右车门和引擎", {}, "", function()
    for k, vehicle in ipairs(entities.get_all_vehicles_as_handles()) do
        VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, false)
        VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, 0, false, false)
        VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, 1, false, false)
    end
end)
menu.action(Nearby_Vehicle_options, "拆下左右车门和打开引擎", {}, "", function()
    for k, vehicle in ipairs(entities.get_all_vehicles_as_handles()) do
        VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, false)
        VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, 0, false)
        VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, 1, false)
    end
end)



------------------
----- 附近NPC -----
------------------
local Nearby_Ped_options = menu.list(Entity_options, "管理附近NPC", {}, "")

menu.slider_float(Nearby_Ped_options, "范围半径", { "radius_nearby_ped" }, "若半径是0，则为全部范围", 0,
    100000, 3000, 1000,
    function(value)
        control_nearby_peds_setting.radius = value
    end)
menu.toggle_loop(Nearby_Ped_options, "绘制范围", {}, "", function()
    local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
    GRAPHICS.DRAW_MARKER_SPHERE(coords.x, coords.y, coords.z, control_nearby_peds_setting.radius, 200, 50, 200, 0.5)
end)

local Nearby_Ped_Setting = menu.list(Nearby_Ped_options, "设置", {}, "")
menu.slider(Nearby_Ped_Setting, "时间间隔", { "delay_nearby_ped" }, "单位: ms", 0, 5000, 1000, 100,
    function(value)
        control_nearby_peds_setting.time_delay = value
    end)
menu.toggle(Nearby_Ped_Setting, "排除载具内NPC", {}, "", function(toggle)
    control_nearby_peds_setting.exclude_ped_in_vehicle = toggle
end, true)
menu.toggle(Nearby_Ped_Setting, "排除任务NPC", {}, "", function(toggle)
    control_nearby_peds_setting.exclude_mission = toggle
end, true)
menu.toggle(Nearby_Ped_Setting, "排除已死亡实体", {}, "", function(toggle)
    control_nearby_peds_setting.exclude_dead = toggle
end, true)

----------------------
--  附近NPC 恶搞选项
----------------------
local Nearby_Ped_Trolling_options = menu.list(Nearby_Ped_options, "恶搞选项", {}, "")
menu.slider(Nearby_Ped_Trolling_options, "设置向前推进程度", { "ped_forward_degree" }, "", 0, 1000, 30, 10,
    function(value)
        control_nearby_peds_data.forward_speed = value
    end)
menu.toggle(Nearby_Ped_Trolling_options, "向前推进", {}, "", function(toggle)
    control_nearby_peds_toggles.force_forward = toggle
    if not is_Control_nearby_peds then
        control_nearby_peds()
    end
end)
menu.toggle(Nearby_Ped_Trolling_options, "丢弃武器", {}, "", function(toggle)
    control_nearby_peds_toggles.drop_weapon = toggle
    if not is_Control_nearby_peds then
        control_nearby_peds()
    end
end)
menu.toggle(Nearby_Ped_Trolling_options, "忽略其它临时事件", {}, "", function(toggle)
    control_nearby_peds_toggles.ignore_events = toggle
    if not is_Control_nearby_peds then
        control_nearby_peds()
    end
end)
menu.toggle(Nearby_Ped_Trolling_options, "爆头", {}, "", function(toggle)
    control_nearby_peds_toggles.explode_head = toggle
    if not is_Control_nearby_peds then
        control_nearby_peds()
    end
end)

menu.divider(Nearby_Ped_Trolling_options, "NPC上天")
local launch_ped_height = 20
menu.slider(Nearby_Ped_Trolling_options, "上天高度", { "launch_ped_height" }, "", 0, 1000, 20, 10, function(value)
    launch_ped_height = value
end)
local launch_ped_freeze = false
menu.toggle(Nearby_Ped_Trolling_options, "冻结NPC", {}, "", function(toggle)
    launch_ped_freeze = toggle
end)
menu.action(Nearby_Ped_Trolling_options, "发射上天", {}, "", function()
    for k, ped in ipairs(GET_NEARBY_PEDS(players.user(), control_nearby_peds_setting.radius)) do
        if not IS_PED_PLAYER(ped) then
            if launch_ped_freeze then
                ENTITY.FREEZE_ENTITY_POSITION(ped, true)
            end
            local pos = ENTITY.GET_ENTITY_COORDS(ped)
            ENTITY.SET_ENTITY_COORDS(ped, pos.x, pos.y, pos.z + launch_ped_height, false, false, false, false)
        end
    end
end)

----------------------
--  附近NPC 友好选项
----------------------
local Nearby_Ped_Friendly_options = menu.list(Nearby_Ped_options, "友好选项", {}, "")
menu.slider(Nearby_Ped_Friendly_options, "掉落现金数量", { "ped_drop_money_amonut" }, "", 0, 2000, 100, 100,
    function(value)
        control_nearby_peds_data.drop_money_amount = value
    end)
menu.toggle(Nearby_Ped_Friendly_options, "修改掉落现金", {}, "", function(toggle)
    control_nearby_peds_toggles.drop_money = toggle
    if not is_Control_nearby_peds then
        control_nearby_peds()
    end
end)
menu.list_select(Nearby_Ped_Friendly_options, "设置武器", {}, "", WeaponName_ListItem, 1, function(value)
    control_nearby_peds_data.weapon_hash = util.joaat(WeaponModel_List[value])
end)
menu.toggle(Nearby_Ped_Friendly_options, "给予武器", {}, "", function(toggle)
    control_nearby_peds_toggles.give_weapon = toggle
    if not is_Control_nearby_peds then
        control_nearby_peds()
    end
end)


menu.divider(Nearby_Ped_options, "全部范围")

----------------------
--  附近NPC 作战能力
----------------------
local Nearby_Ped_Combat_options = menu.list(Nearby_Ped_options, "作战能力", {}, "")

--15
local Ped_CombatAttributes_Title = {
    "Can Use Cover",
    "Can Use Vehicles",
    "Can Do Drivebys",
    "Always Fight",
    "Blind Fire When In Cover",
    "Aggressive",
    "Can Chase Target On Foot",
    "Will Drag Injured Peds To Safety",
    "Use Proximity Firing Rate",
    "Perfect Accuracy",
    "Can Commandeer Vehicles",
    "Can Flank",
    "Can Charge",
    "Can Fight Armed Peds When Not Armed",
    "Always Equip Best Weapon"
}
local Ped_CombatAttributes_Enum = {
    0, 1, 2, 5, 12, 13, 21, 22, 24, 27, 41, 42, 46, 50, 54
}

local nearby_ped_combat = {
    health = 100,
    armour = 0,
    see_range = 0.0,
    hear_range = 0.0,
    id_range = 0.0,
    peripheral_range = 0.0,
    peripheral_angle = 0.0,
    highly_perceptive = false,
    accuracy = 0,
    shoot_rate = 0,
    combat_ability = 0,
    combat_range = 0,
    combat_movement = 0,
    target_loss_response = 0,
    remove_defensive_area = true,
    stop_drop_fire = true,
    disable_injured_behaviour = false,
    dies_when_injured = false
}
local nearby_ped_combat_attr = {}
for i = 1, 15 do
    nearby_ped_combat_attr[i] = false
end

local Nearby_Ped_Combat_setting = menu.list(Nearby_Ped_Combat_options, "作战能力设置", {}, "")
menu.slider(Nearby_Ped_Combat_setting, "生命", { "combat_health" }, "生命值低于100就会死", 0, 10000, 100, 50,
    function(value)
        nearby_ped_combat.health = value
    end)
menu.slider(Nearby_Ped_Combat_setting, "护甲", { "combat_armour" }, "", 0, 100, 0, 10, function(value)
    nearby_ped_combat.armour = value
end)
menu.slider(Nearby_Ped_Combat_setting, "视力范围", { "combat_see_range" }, "", 0.0, 500.0, 0.0, 1.0,
    function(value)
        nearby_ped_combat.see_range = value
    end)
menu.slider(Nearby_Ped_Combat_setting, "听力范围", { "combat_hear_range" }, "", 0.0, 500.0, 0.0, 1.0,
    function(value)
        nearby_ped_combat.hear_range = value
    end)
menu.slider(Nearby_Ped_Combat_setting, "识别范围", { "combat_id_range" }, "", 0.0, 500.0, 0.0, 1.0,
    function(value)
        nearby_ped_combat.id_range = value
    end)
menu.slider(Nearby_Ped_Combat_setting, "锥形视野范围", { "combat_peripheral_range" }, "", 0.0, 500.0, 0.0, 1.0,
    function(value)
        nearby_ped_combat.peripheral_range = value
    end)
menu.slider(Nearby_Ped_Combat_setting, "侦查视野角度", { "combat_peripheral_angle" }, "", -90.0, 90.0, 0.0, 1.0,
    function(value)
        nearby_ped_combat.peripheral_angle = value
    end)
menu.toggle(Nearby_Ped_Combat_setting, "高度警觉性", {}, "", function(toggle)
    nearby_ped_combat.highly_perceptive = toggle
end)
menu.slider(Nearby_Ped_Combat_setting, "精准度", { "combat_accuracy" }, "", 0, 100, 0, 5, function(value)
    nearby_ped_combat.accuracy = value
end)
menu.slider(Nearby_Ped_Combat_setting, "射击频率", { "combat_shoot_rate" }, "", 0, 1000, 0, 10, function(value)
    nearby_ped_combat.shoot_rate = value
end)
menu.list_select(Nearby_Ped_Combat_setting, "作战技能", {}, "", {
    { "弱" }, { "普通" }, { "专业" }
}, 1, function(value)
    nearby_ped_combat.combat_ability = value - 1
end)
menu.list_select(Nearby_Ped_Combat_setting, "作战范围", {}, "", {
    { "近" }, { "中等" }, { "远" }, { "非常远" }
}, 1, function(value)
    nearby_ped_combat.combat_range = value - 1
end)
menu.list_select(Nearby_Ped_Combat_setting, "作战走位", {}, "", {
    { "站立" }, { "防卫" }, { "会前进" }, { "会后退" }
}, 1, function(value)
    nearby_ped_combat.combat_movement = value - 1
end)
menu.list_select(Nearby_Ped_Combat_setting, "失去目标时反应", {}, "", {
    { "退出战斗" }, { "从不失去目标" }, { "寻找目标" }
}, 1, function(value)
    nearby_ped_combat.target_loss_response = value - 1
end)
menu.toggle(Nearby_Ped_Combat_setting, "移除防卫区域", {}, "Ped will no longer get angry when you stay near him.",
    function(toggle)
        nearby_ped_combat.remove_defensive_area = toggle
    end, true)
menu.toggle(Nearby_Ped_Combat_setting, "武器掉落时不会走火", {}, "", function(toggle)
    nearby_ped_combat.stop_drop_fire = toggle
end, true)
menu.toggle(Nearby_Ped_Combat_setting, "禁止受伤时在地面打滚", {}, "", function(toggle)
    nearby_ped_combat.disable_injured_behaviour = toggle
end)
menu.toggle(Nearby_Ped_Combat_setting, "一受伤就死亡", {}, "", function(toggle)
    nearby_ped_combat.dies_when_injured = toggle
end)

local Nearby_Ped_Combat_Attributes = menu.list(Nearby_Ped_Combat_options, "战斗属性设置", {}, "")
local Nearby_Ped_Combat_Attributes_menu = {}

menu.toggle(Nearby_Ped_Combat_Attributes, "全部开/关", {}, "", function(toggle)
    for i, the_menu in pairs(Nearby_Ped_Combat_Attributes_menu) do
        menu.set_value(the_menu, toggle)
    end
end)
for i, name in pairs(Ped_CombatAttributes_Title) do
    Nearby_Ped_Combat_Attributes_menu[i] = menu.toggle(Nearby_Ped_Combat_Attributes, name, {}, "", function(toggle)
        nearby_ped_combat_attr[i] = toggle
    end)
end


---------
local Nearby_Ped_Combat_toggles = menu.list(Nearby_Ped_Combat_options, "作战能力设置开关", {}, "取消勾选代表不对这一项进行修改")

local nearby_ped_combat_toggle = {
    health = true,
    armour = 0,
    see_range = true,
    hear_range = 0,
    peripheral_range = true,
    peripheral_angle = true,
    highly_perceptive = 0,
    accuracy = 0,
    shoot_rate = 0,
    combat_ability = 0,
    combat_range = 0,
    combat_movement = true,
    target_loss_response = true,
}
local nearby_ped_combat_attr_toggle = {}
for i = 1, 15 do
    nearby_ped_combat_attr_toggle[i] = true
end

menu.toggle(Nearby_Ped_Combat_toggles, "生命", {}, "", function(toggle)
    nearby_ped_combat_toggle.health = toggle
end, true)
menu.toggle(Nearby_Ped_Combat_toggles, "视力范围", {}, "", function(toggle)
    nearby_ped_combat_toggle.see_range = toggle
end, true)
menu.toggle(Nearby_Ped_Combat_toggles, "锥形视野范围", {}, "", function(toggle)
    nearby_ped_combat_toggle.peripheral_range = toggle
end, true)
menu.toggle(Nearby_Ped_Combat_toggles, "侦查视野角度", {}, "", function(toggle)
    nearby_ped_combat_toggle.peripheral_angle = toggle
end, true)
menu.toggle(Nearby_Ped_Combat_toggles, "作战走位", {}, "", function(toggle)
    nearby_ped_combat_toggle.combat_movement = toggle
end, true)
menu.toggle(Nearby_Ped_Combat_toggles, "失去目标时反应", {}, "", function(toggle)
    nearby_ped_combat_toggle.target_loss_response = toggle
end, true)

menu.divider(Nearby_Ped_Combat_toggles, "战斗属性")
local Nearby_Ped_Combat_toggles_menu = {}

menu.toggle(Nearby_Ped_Combat_toggles, "全部开/关", {}, "", function(toggle)
    for i, the_menu in pairs(Nearby_Ped_Combat_toggles_menu) do
        menu.set_value(the_menu, toggle)
    end
end, true)
for i, name in pairs(Ped_CombatAttributes_Title) do
    Nearby_Ped_Combat_toggles_menu[i] = menu.toggle(Nearby_Ped_Combat_toggles, name, {}, "", function(toggle)
        nearby_ped_combat_attr_toggle[i] = toggle
    end, true)
end


---------
menu.divider(Nearby_Ped_Combat_options, "默认设置为弱化NPC")

local neayby_ped_combat_all_setting = {
    only_combat = true,
    request_control = false
}
menu.toggle(Nearby_Ped_Combat_options, "只作用于敌对NPC", {}, "", function(toggle)
    neayby_ped_combat_all_setting.only_combat = toggle
end, true)
menu.toggle(Nearby_Ped_Combat_options, "请求控制", {}, "如果有其它玩家", function(toggle)
    neayby_ped_combat_all_setting.request_control = toggle
end)

local function NearbyPed_Combat()
    for _, ped in ipairs(entities.get_all_peds_as_handles()) do
        if IS_PED_PLAYER(ped) then
        elseif PED.IS_PED_DEAD_OR_DYING(ped) or ENTITY.IS_ENTITY_DEAD(ped) then
        elseif neayby_ped_combat_all_setting.only_combat and not PED.IS_PED_IN_COMBAT(ped, players.user_ped()) then
        else
            if neayby_ped_combat_all_setting.request_control then
                RequestControl(ped)
            end

            if nearby_ped_combat_toggle.health then
                ENTITY.SET_ENTITY_HEALTH(ped, nearby_ped_combat.health)
            end

            PED.SET_PED_ARMOUR(ped, nearby_ped_combat.armour)

            if nearby_ped_combat_toggle.see_range then
                PED.SET_PED_SEEING_RANGE(ped, nearby_ped_combat.see_range)
            end

            PED.SET_PED_HEARING_RANGE(ped, nearby_ped_combat.hear_range)
            PED.SET_PED_ID_RANGE(ped, nearby_ped_combat.id_range)

            if nearby_ped_combat_toggle.peripheral_range then
                PED.SET_PED_VISUAL_FIELD_PERIPHERAL_RANGE(ped, nearby_ped_combat.peripheral_range)
            end

            PED.SET_PED_HIGHLY_PERCEPTIVE(ped, nearby_ped_combat.highly_perceptive)

            if nearby_ped_combat_toggle.peripheral_angle then
                PED.SET_PED_VISUAL_FIELD_MIN_ANGLE(ped, nearby_ped_combat.peripheral_angle)
                PED.SET_PED_VISUAL_FIELD_MAX_ANGLE(ped, nearby_ped_combat.peripheral_angle)
                PED.SET_PED_VISUAL_FIELD_MIN_ELEVATION_ANGLE(ped, nearby_ped_combat.peripheral_angle)
                PED.SET_PED_VISUAL_FIELD_MAX_ELEVATION_ANGLE(ped, nearby_ped_combat.peripheral_angle)
                PED.SET_PED_VISUAL_FIELD_CENTER_ANGLE(ped, nearby_ped_combat.peripheral_angle)
            end

            PED.SET_PED_ACCURACY(ped, nearby_ped_combat.accuracy)
            PED.SET_PED_SHOOT_RATE(ped, nearby_ped_combat.shoot_rate)
            PED.SET_PED_COMBAT_ABILITY(ped, nearby_ped_combat.combat_ability)
            PED.SET_PED_COMBAT_RANGE(ped, nearby_ped_combat.combat_range)

            if nearby_ped_combat_toggle.combat_movement then
                PED.SET_PED_COMBAT_MOVEMENT(ped, nearby_ped_combat.combat_movement)
            end

            if nearby_ped_combat_toggle.target_loss_response then
                PED.SET_PED_TARGET_LOSS_RESPONSE(ped, nearby_ped_combat.target_loss_response)
            end

            PED.SET_PED_DIES_WHEN_INJURED(ped, nearby_ped_combat.dies_when_injured)
            PED.REMOVE_PED_DEFENSIVE_AREA(ped, nearby_ped_combat.remove_defensive_area)

            if nearby_ped_combat.stop_drop_fire then
                PED.STOP_PED_WEAPON_FIRING_WHEN_DROPPED(ped)
            end

            if nearby_ped_combat.disable_injured_behaviour then
                PED.DISABLE_PED_INJURED_ON_GROUND_BEHAVIOUR(ped)
            end

            for i, toggle in pairs(nearby_ped_combat_attr_toggle) do
                if toggle then
                    local id = Ped_CombatAttributes_Enum[i]
                    local is = nearby_ped_combat_attr[i]
                    PED.SET_PED_COMBAT_ATTRIBUTES(ped, id, is)
                end
            end
            -----
        end
    end
end

menu.action(Nearby_Ped_Combat_options, "设置 (Once)", {}, "", function()
    NearbyPed_Combat()
    util.toast("Done!")
end)
menu.toggle_loop(Nearby_Ped_Combat_options, "设置 (Loop)", {}, "", function()
    NearbyPed_Combat()
end)


----------------------------
-- 附近NPC 取消NPC执行的任务
----------------------------
local Nearby_Ped_ClearTask_options = menu.list(Nearby_Ped_options, "取消NPC执行的任务", {}, "乱用会导致任务无法进行")

local nearby_ped_cleartask = {
    exclude_mission = false,
    only_combat = true,
    clear_task = false,
    ignore_events = true
}

menu.toggle(Nearby_Ped_ClearTask_options, "排除任务实体", {}, "", function(toggle)
    nearby_ped_cleartask.exclude_mission = toggle
end)
menu.toggle(Nearby_Ped_ClearTask_options, "只作用于敌对NPC", {}, "", function(toggle)
    nearby_ped_cleartask.only_combat = toggle
end, true)
menu.toggle(Nearby_Ped_ClearTask_options, "取消正在执行的任务", {}, "", function(toggle)
    nearby_ped_cleartask.clear_task = toggle
end)
menu.toggle(Nearby_Ped_ClearTask_options, "忽略其它临时事件", {}, "开枪射击之类的事件",
    function(toggle)
        nearby_ped_cleartask.ignore_events = toggle
    end, true)

local function NearbyPed_ClearTask()
    for _, ped in pairs(entities.get_all_peds_as_handles()) do
        if IS_PED_PLAYER(ped) then
        elseif PED.IS_PED_DEAD_OR_DYING(ped) or ENTITY.IS_ENTITY_DEAD(ped) then
        elseif nearby_ped_cleartask.exclude_mission and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ped) then
        elseif nearby_ped_cleartask.only_combat and not PED.IS_PED_IN_COMBAT(ped, players.user_ped()) then
        else
            if nearby_ped_cleartask.clear_task then
                Clear_Ped_All_Tasks(ped)
            end
            PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, nearby_ped_cleartask.ignore_events)
            TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, nearby_ped_cleartask.ignore_events)
        end
    end
end

menu.action(Nearby_Ped_ClearTask_options, "Clear Ped Tasks Immediately", {}, "", function()
    for _, ped in ipairs(entities.get_all_peds_as_handles()) do
        if IS_PED_PLAYER(ped) then
        elseif PED.IS_PED_DEAD_OR_DYING(ped) or ENTITY.IS_ENTITY_DEAD(ped) then
        elseif nearby_ped_cleartask.exclude_mission and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ped) then
        elseif nearby_ped_cleartask.only_combat and not PED.IS_PED_IN_COMBAT(ped, players.user_ped()) then
        else
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
        end
    end
    util.toast("Done!")
end)
menu.action(Nearby_Ped_ClearTask_options, "设置 (Once)", {}, "", function()
    NearbyPed_ClearTask()
end)
menu.toggle_loop(Nearby_Ped_ClearTask_options, "设置 (Loop)", {}, "", function()
    NearbyPed_ClearTask()
end)


------------------
----- 附近区域 -----
------------------
local Nearby_Area_options = menu.list(Entity_options, "管理附近区域", {}, "")

local nearby_area = {
    radius = 100.0
}

menu.slider_float(Nearby_Area_options, "范围半径", { "radius_nearby_area" }, "", 0, 100000, 10000, 1000,
    function(value)
        nearby_area.radius = value
    end)
menu.toggle_loop(Nearby_Area_options, "绘制范围", {}, "", function()
    local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
    GRAPHICS.DRAW_MARKER_SPHERE(coords.x, coords.y, coords.z, nearby_area.radius, 200, 50, 200, 0.5)
end)

-------------
-- 清理区域
-------------
local Nearby_Area_Clear = menu.list(Nearby_Area_options, "清理区域", {}, "MISC::CLEAR_AREA")
menu.toggle_loop(Nearby_Area_Clear, "清理区域", { "cls_area" }, "清理区域内所有东西", function()
    local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
    MISC.CLEAR_AREA(coords.x, coords.y, coords.z, nearby_area.radius, true, false, false, false)
end)
menu.toggle_loop(Nearby_Area_Clear, "清理载具", { "cls_veh" }, "清理区域内所有载具", function()
    local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
    MISC.CLEAR_AREA_OF_VEHICLES(coords.x, coords.y, coords.z, nearby_area.radius, false, false, false, false, false,
        false)
end)
menu.toggle_loop(Nearby_Area_Clear, "清理行人", { "cls_ped" }, "清理区域内所有行人", function()
    local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
    MISC.CLEAR_AREA_OF_PEDS(coords.x, coords.y, coords.z, nearby_area.radius, 1)
end)
menu.toggle_loop(Nearby_Area_Clear, "清理警察", { "cls_cop" }, "清理区域内所有警察", function()
    local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
    MISC.CLEAR_AREA_OF_COPS(coords.x, coords.y, coords.z, nearby_area.radius, 0)
end)
menu.toggle_loop(Nearby_Area_Clear, "清理物体", { "cls_obj" }, "清理区域内所有物体", function()
    local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
    MISC.CLEAR_AREA_OF_OBJECTS(coords.x, coords.y, coords.z, nearby_area.radius, 0)
end)
menu.toggle_loop(Nearby_Area_Clear, "清理投掷物", { "cls_proj" }, "清理区域内所有子弹、炮弹、投掷物等"
    ,
    function()
        local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
        MISC.CLEAR_AREA_OF_PROJECTILES(coords.x, coords.y, coords.z, nearby_area.radius, 0)
    end)

-------------
-- 射击区域
-------------
local Nearby_Area_Shoot = menu.list(Nearby_Area_options, "射击区域", {}, "若半径是0，则为全部范围")
local nearby_area_shoot = {
    target_ped = 2,
    target_ped_body = 2,
    target_vehicle = 1,
    target_vehicle_body = 1,
    target_object = 1,
    weapon_hash = "PLAYER_WEAPON",
    owner = 1,
    damage = 1000,
    speed = 1000,
    is_audible = true,
    is_invisible = false,
    start_from_player = false,
    x = 0.0,
    y = 0.0,
    z = 0.1,
    delay = 1000,
}
-----
local Nearby_Area_Shoot_Target = menu.list(Nearby_Area_Shoot, "目标", {}, "")

menu.divider(Nearby_Area_Shoot_Target, "NPC")
local Nearby_Area_Shoot_Target_Ped = {
    { "关闭" },
    { "全部NPC" },
    { "步行NPC" },
    { "载具内NPC" },
    { "敌对NPC" },
}
menu.list_select(Nearby_Area_Shoot_Target, "NPC目标", {}, "", Nearby_Area_Shoot_Target_Ped, 2, function(value)
    nearby_area_shoot.target_ped = value
end)

local Nearby_Area_Shoot_Target_Ped_Body = {
    { "默认", {}, "身体中心" },
    { "头部" },
}
menu.list_select(Nearby_Area_Shoot_Target, "NPC身体位置", {}, "", Nearby_Area_Shoot_Target_Ped_Body, 2,
    function(value)
        nearby_area_shoot.target_ped_body = value
    end)

menu.divider(Nearby_Area_Shoot_Target, "载具")
local Nearby_Area_Shoot_Target_Vehicle = {
    { "关闭" },
    { "NPC载具", {}, "有NPC作为司机驾驶的载具" },
    { "敌对载具", {}, "敌对NPC驾驶或者有敌对地图标识的载具" },
    { "全部载具", {}, "会排除玩家载具" },
}
menu.list_select(Nearby_Area_Shoot_Target, "载具目标", {}, "", Nearby_Area_Shoot_Target_Vehicle, 1,
    function(value)
        nearby_area_shoot.target_vehicle = value
    end)

local Nearby_Area_Shoot_Target_Vehicle_Body = {
    { "默认", {}, "载具中心" },
    { "车轮" },
    { "车窗" },
}
local Nearby_Area_Shoot_Target_Vehicle_Body_List = {
    { "" },
    { "wheel_lf", "wheel_lr", "wheel_rf", "wheel_rr" },
    { "windscreen", "windscreen_r",
        "window_lf", "window_rf",
        "window_lr", "window_rr",
        "window_lm", "window_rm" },
}
menu.list_select(Nearby_Area_Shoot_Target, "载具车身位置", {}, "", Nearby_Area_Shoot_Target_Vehicle_Body, 1,
    function(value)
        nearby_area_shoot.target_vehicle_body = value
    end)

menu.divider(Nearby_Area_Shoot_Target, "物体")
local Nearby_Area_Shoot_Target_Object = {
    { "关闭" },
    { "敌对物体", {}, "有敌对地图标识的物体" },
}
menu.list_select(Nearby_Area_Shoot_Target, "物体目标", {}, "", Nearby_Area_Shoot_Target_Object, 1,
    function(value)
        nearby_area_shoot.target_object = value
    end)

-----
local Nearby_Area_Shoot_Setting = menu.list(Nearby_Area_Shoot, "设置", {}, "")
menu.divider(Nearby_Area_Shoot_Setting, "属性")

menu.list_select(Nearby_Area_Shoot_Setting, "武器", {}, "", AllWeapons_NoMelee_ListItem, 1, function(value)
    nearby_area_shoot.weapon_hash = AllWeapons_NoMelee_ListItem[value][3]
end)

local Nearby_Area_Shoot_Owner = {
    { "玩家", {}, "以你的名义射击" },
    { "匿名", {}, "" },
    { "随机玩家", {}, "没有其他玩家则匿名" },
}
menu.list_select(Nearby_Area_Shoot_Setting, "攻击者", {}, "", Nearby_Area_Shoot_Owner, 1, function(value)
    nearby_area_shoot.owner = value
end)

menu.slider(Nearby_Area_Shoot_Setting, "伤害", { "nearby_area_shoot_damage" }, "", 0, 10000, 1000, 100,
    function(value)
        nearby_area_shoot.damage = value
    end)
menu.slider(Nearby_Area_Shoot_Setting, "速度", { "nearby_area_shoot_speed" }, "", 0, 10000, 1000, 100,
    function(value)
        nearby_area_shoot.speed = value
    end)

menu.divider(Nearby_Area_Shoot_Setting, "起始射击位置偏移")
menu.toggle(Nearby_Area_Shoot_Setting, "从玩家位置起始射击", {},
    "如果关闭，则起始位置为目标位置+偏移\n如果开启，建议偏移Z>1.0", function(toggle)
    nearby_area_shoot.start_from_player = toggle
end)
menu.slider_float(Nearby_Area_Shoot_Setting, "X", { "nearby_area_shoot_x" }, "", -10000, 10000, 0, 10,
    function(value)
        value = value * 0.01
        nearby_area_shoot.x = value
    end)
menu.slider_float(Nearby_Area_Shoot_Setting, "Y", { "nearby_area_shoot_y" }, "", -10000, 10000, 0, 10,
    function(value)
        value = value * 0.01
        nearby_area_shoot.y = value
    end)
menu.slider_float(Nearby_Area_Shoot_Setting, "Z", { "nearby_area_shoot_z" }, "", -10000, 10000, 10, 10,
    function(value)
        value = value * 0.01
        nearby_area_shoot.z = value
    end)
---
---
---
local function Get_Random_Player()
    local player_list = players.list(false, true, true)
    local length = 0
    for k, v in pairs(player_list) do
        length = length + 1
    end
    if length == 0 then
        return 0
    else
        return player_list[math.random(1, length)]
    end
end

local function Shoot_Nearby_Area(state)
    local weaponHash = nearby_area_shoot.weapon_hash
    if weaponHash == "PLAYER_WEAPON" then
        local pWeapon = memory.alloc_int()
        WEAPON.GET_CURRENT_PED_WEAPON(players.user_ped(), pWeapon, true)
        weaponHash = memory.read_int(pWeapon)
    end
    if not WEAPON.HAS_WEAPON_ASSET_LOADED(weaponHash) then
        Request_Weapon_Asset(weaponHash)
    end

    local owner
    if nearby_area_shoot.owner == 1 then
        owner = players.user_ped()
    elseif nearby_area_shoot.owner == 2 then
        owner = 0
    elseif nearby_area_shoot.owner == 3 then
        owner = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(Get_Random_Player())
    end

    --- PED ---
    if nearby_area_shoot.target_ped ~= 1 then
        for _, ent in pairs(GET_NEARBY_PEDS(players.user(), nearby_area.radius)) do
            if not IS_PED_PLAYER(ent) and not ENTITY.IS_ENTITY_DEAD(ent) then
                local ped = nil
                if nearby_area_shoot.target_ped == 2 then
                    ped = ent
                elseif nearby_area_shoot.target_ped == 3 and not PED.IS_PED_IN_ANY_VEHICLE(ent, false) then
                    ped = ent
                elseif nearby_area_shoot.target_ped == 4 and PED.IS_PED_IN_ANY_VEHICLE(ent, false) then
                    ped = ent
                elseif nearby_area_shoot.target_ped == 5 and IS_HOSTILE_ENTITY(ent) then
                    ped = ent
                end

                if ped ~= nil then
                    local pos, start_pos = {}, {}
                    if nearby_area_shoot.target_ped_body == 1 then
                        pos = ENTITY.GET_ENTITY_COORDS(ped)
                    elseif nearby_area_shoot.target_ped_body == 2 then
                        pos = PED.GET_PED_BONE_COORDS(ped, 0x322c, 0, 0, 0)
                    end

                    if nearby_area_shoot.start_from_player then
                        local player_pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
                        start_pos.x = player_pos.x + nearby_area_shoot.x
                        start_pos.y = player_pos.y + nearby_area_shoot.y
                        start_pos.z = player_pos.z + nearby_area_shoot.z
                    else
                        start_pos.x = pos.x + nearby_area_shoot.x
                        start_pos.y = pos.y + nearby_area_shoot.y
                        start_pos.z = pos.z + nearby_area_shoot.z
                    end

                    if state == "shoot" then
                        local ignore_entity = players.user_ped()
                        if PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
                            ignore_entity = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
                        end

                        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(start_pos.x, start_pos.y, start_pos.z,
                            pos.x, pos.y, pos.z,
                            nearby_area_shoot.damage, false, weaponHash, owner,
                            nearby_area_shoot.is_audible, nearby_area_shoot.is_invisible, nearby_area_shoot.speed,
                            ignore_entity)
                    elseif state == "draw" then
                        DRAW_LINE(start_pos, pos)
                    end
                end

            end
        end
    end

    --- VEHICLE ---
    if nearby_area_shoot.target_vehicle ~= 1 then
        for _, ent in pairs(GET_NEARBY_VEHICLES(players.user(), nearby_area.radius)) do
            if not IS_PLAYER_VEHICLE(ent) and not ENTITY.IS_ENTITY_DEAD(ent) then
                local veh = nil
                if nearby_area_shoot.target_vehicle == 2 and not VEHICLE.IS_VEHICLE_SEAT_FREE(ent, -1, false) then
                    veh = ent
                elseif nearby_area_shoot.target_vehicle == 3 and IS_HOSTILE_ENTITY(ent) then
                    veh = ent
                elseif nearby_area_shoot.target_vehicle == 4 then
                    veh = ent
                end

                if veh ~= nil then
                    local pos, start_pos = {}, {}
                    if nearby_area_shoot.target_vehicle_body == 1 then
                        pos = ENTITY.GET_ENTITY_COORDS(veh)

                        if nearby_area_shoot.start_from_player then
                            local player_pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
                            start_pos.x = player_pos.x + nearby_area_shoot.x
                            start_pos.y = player_pos.y + nearby_area_shoot.y
                            start_pos.z = player_pos.z + nearby_area_shoot.z
                        else
                            start_pos.x = pos.x + nearby_area_shoot.x
                            start_pos.y = pos.y + nearby_area_shoot.y
                            start_pos.z = pos.z + nearby_area_shoot.z
                        end

                        if state == "shoot" then
                            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(start_pos.x, start_pos.y, start_pos.z,
                                pos.x, pos.y, pos.z,
                                nearby_area_shoot.damage, false, weaponHash, owner,
                                nearby_area_shoot.is_audible, nearby_area_shoot.is_invisible, nearby_area_shoot.speed,
                                players.user_ped())
                        elseif state == "draw" then
                            DRAW_LINE(start_pos, pos)
                        end
                    else
                        local bones = Nearby_Area_Shoot_Target_Vehicle_Body_List[nearby_area_shoot.target_vehicle_body]
                        for _, bone in pairs(bones) do
                            local bone_index = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(veh, bone)
                            if bone_index ~= -1 then
                                pos = ENTITY.GET_WORLD_POSITION_OF_ENTITY_BONE(veh, bone_index)

                                if nearby_area_shoot.start_from_player then
                                    local player_pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
                                    start_pos.x = player_pos.x + nearby_area_shoot.x
                                    start_pos.y = player_pos.y + nearby_area_shoot.y
                                    start_pos.z = player_pos.z + nearby_area_shoot.z
                                else
                                    start_pos.x = pos.x + nearby_area_shoot.x
                                    start_pos.y = pos.y + nearby_area_shoot.y
                                    start_pos.z = pos.z + nearby_area_shoot.z
                                end

                                if state == "shoot" then
                                    local ignore_entity = players.user_ped()
                                    if PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
                                        ignore_entity = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
                                    end

                                    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(start_pos.x, start_pos.y,
                                        start_pos.z,
                                        pos.x, pos.y, pos.z,
                                        nearby_area_shoot.damage, false, weaponHash, owner,
                                        nearby_area_shoot.is_audible, nearby_area_shoot.is_invisible,
                                        nearby_area_shoot.speed,
                                        ignore_entity)
                                elseif state == "draw" then
                                    DRAW_LINE(start_pos, pos)
                                end
                            end
                        end
                    end

                end

            end
        end
    end

    --- OBJECT ---
    if nearby_area_shoot.target_object ~= 1 then
        for _, ent in pairs(GET_NEARBY_OBJECTS(players.user(), nearby_area.radius)) do
            local obj = nil
            if nearby_area_shoot.target_object == 2 and IS_HOSTILE_ENTITY(ent) then
                obj = ent
            end

            if obj ~= nil then
                local pos, start_pos = {}, {}

                pos = ENTITY.GET_ENTITY_COORDS(obj)

                if nearby_area_shoot.start_from_player then
                    local player_pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
                    start_pos.x = player_pos.x + nearby_area_shoot.x
                    start_pos.y = player_pos.y + nearby_area_shoot.y
                    start_pos.z = player_pos.z + nearby_area_shoot.z
                else
                    start_pos.x = pos.x + nearby_area_shoot.x
                    start_pos.y = pos.y + nearby_area_shoot.y
                    start_pos.z = pos.z + nearby_area_shoot.z
                end

                if state == "shoot" then
                    local ignore_entity = players.user_ped()

                    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(start_pos.x, start_pos.y, start_pos.z,
                        pos.x, pos.y, pos.z,
                        nearby_area_shoot.damage, false, weaponHash, owner,
                        nearby_area_shoot.is_audible, nearby_area_shoot.is_invisible, nearby_area_shoot.speed,
                        ignore_entity)
                elseif state == "draw" then
                    DRAW_LINE(start_pos, pos)
                end
            end

        end
    end

end

menu.toggle_loop(Nearby_Area_Shoot, "绘制模拟射击连线", {}, "", function()
    Shoot_Nearby_Area("draw")
end)

menu.divider(Nearby_Area_Shoot, "")
menu.action(Nearby_Area_Shoot, "射击", { "shoot_area" }, "", function()
    Shoot_Nearby_Area("shoot")
end)
menu.slider(Nearby_Area_Shoot, "循环延迟", { "nearby_area_shoot_delay" }, "单位: ms", 0, 5000, 1000, 100,
    function(value)
        nearby_area_shoot.delay = value
    end)
menu.toggle_loop(Nearby_Area_Shoot, "循环射击", {}, "", function()
    Shoot_Nearby_Area("shoot")
    util.yield(nearby_area_shoot.delay)
end)


------------------------
-------- 任务实体 -------
------------------------
local MISSION_ENTITY = menu.list(Entity_options, "管理任务实体", {}, "")

menu.action(MISSION_ENTITY, "传送到 电脑", { "tp_desk" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(521)
    if not HUD.DOES_BLIP_EXIST(blip) then
        util.toast("No PC Found")
    else
        local coords = HUD.GET_BLIP_COORDS(blip)
        TELEPORT(coords.x - 1.0, coords.y + 1.0, coords.z)
    end
end)

-------- 办公室拉货 --------
local MISSION_ENTITY_cargo = menu.list(MISSION_ENTITY, "办公室拉货", {}, "")

local MISSION_ENTITY_cargo_remove = menu.list(MISSION_ENTITY_cargo, "移除冷却时间", {}, "来自Heist Control")
menu.divider(MISSION_ENTITY_cargo_remove, "购买和出售")
menu.toggle_loop(MISSION_ENTITY_cargo_remove, "特种货物", { "coolspecial" }, "", function()
    SET_INT_GLOBAL(262145 + 15553, 0) -- Buy, 153204142
    SET_INT_GLOBAL(262145 + 15554, 0) -- Sell, 1291620941
end, function()
    SET_INT_GLOBAL(262145 + 15553, 300000)
    SET_INT_GLOBAL(262145 + 15554, 1800000)
end)
menu.toggle_loop(MISSION_ENTITY_cargo_remove, "载具货物", { "coolveh" }, "", function()
    SET_INT_GLOBAL(262145 + 19683, 0) -- -82707601
    SET_INT_GLOBAL(262145 + 19684, 0) -- 1 Vehicle, 1001423248
    SET_INT_GLOBAL(262145 + 19685, 0) -- 2 Vehicles, 240134765
    SET_INT_GLOBAL(262145 + 19686, 0) -- 3 Vehicles, 1915379148
    SET_INT_GLOBAL(262145 + 19687, 0) -- 4 Vehicles, -824005590
end, function()
    SET_INT_GLOBAL(262145 + 19683, 180000)
    SET_INT_GLOBAL(262145 + 19684, 1200000)
    SET_INT_GLOBAL(262145 + 19685, 1680000)
    SET_INT_GLOBAL(262145 + 19686, 2340000)
    SET_INT_GLOBAL(262145 + 19687, 2880000)
end)

menu.action(MISSION_ENTITY_cargo, "传送到 特种货物", { "tp_cargo" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(478)
    if not HUD.DOES_BLIP_EXIST(blip) then
        util.toast("No Cargo Found")
    else
        local coords = HUD.GET_BLIP_COORDS(blip)
        TELEPORT(coords.x, coords.y, coords.z + 1.0)
    end
end)
menu.action(MISSION_ENTITY_cargo, "特种货物 传送到我", { "tp_me_cargo" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(478)
    if not HUD.DOES_BLIP_EXIST(blip) then
        util.toast("No Cargo Found")
    else
        local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            TP_TO_ME(ent, 0.0, 2.0, -0.5)
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
            --vehicle
            if HUD.GET_BLIP_INFO_ID_TYPE(blip) == 1 then
                TP_INTO_VEHICLE(ent, "delete", "delete")
            end
        else
            util.toast("No Entity, Can't Teleport To Me")
        end
    end
end)
menu.action(MISSION_ENTITY_cargo, "散货板条箱 传送到我", {}, "", function()
    local entity_list = GetEntity_ByModelHash("pickup", true, -265116550, 1688540826, -1143129136) --货物
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, -0.5)
        end
    else
        util.toast("Not Found")
    end
end)
menu.action(MISSION_ENTITY_cargo, "要追踪的车 传送到我", {}, "Trackify追踪车", function()
    local entity_list = GetEntity_ByModelHash("object", true, -1322183878, -2022916910) --车里的货物
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            if ENTITY.IS_ENTITY_ATTACHED(ent) then
                local attached_ent = ENTITY.GET_ENTITY_ATTACHED_TO(ent)
                TP_TO_ME(attached_ent, 0.0, 2.0, -1.0)
                SET_ENTITY_HEAD_TO_ENTITY(attached_ent, players.user_ped())
                TP_INTO_VEHICLE(attached_ent, "delete", "delete")
            end
        end
    else
        util.toast("Not Found")
    end
end)

--Model Hash: -1235210928(object) 卢佩 水下 要炸的货箱
menu.action(MISSION_ENTITY_cargo, "卢佩：水下货箱 获取", {}, "先获取到才能传送", function()
    --货箱里面 要拾取的包裹
    local water_cargo_hash_list = { 388143302, -36934887, 319657375, 924741338, -1249748547 }
    --拾取包裹 实体list
    water_cargo_ent = {}
    local num = 0
    for k, ent in pairs(entities.get_all_objects_as_handles()) do
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
            if isInTable(water_cargo_hash_list, EntityHash) then
                num = num + 1
                table.insert(water_cargo_ent, ent)
            end
        end
    end
    --util.toast("Number: " .. num)
    menu.set_max_value(menu_Water_Cargo_TP, num)
end)
menu_Water_Cargo_TP = menu.click_slider(MISSION_ENTITY_cargo, "卢佩：水下货箱 传送到那里", {}, "",
    0, 0, 0, 1, function(value)
    if value > 0 then
        local ent = water_cargo_ent[value]
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            if ENTITY.IS_ENTITY_ATTACHED(ent) then
                local attached_ent = ENTITY.GET_ENTITY_ATTACHED_TO(ent)
                TP_TO_ENTITY(attached_ent, 0.0, -2.5, 0.0)
                SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), attached_ent)
            end
        else
            util.toast("实体不存在")
        end
    end
end)

menu.action(MISSION_ENTITY_cargo, "传送到 仓库助理", {}, "让他去拉货", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(480)
    if not HUD.DOES_BLIP_EXIST(blip) then
        util.toast("Not Found")
    else
        local coords = HUD.GET_BLIP_COORDS(blip)
        TELEPORT(coords.x - 1.0, coords.y, coords.z)
    end
end)

menu.divider(MISSION_ENTITY_cargo, "载具货物")
menu.action(MISSION_ENTITY_cargo, "传送到 载具货物", { "tp_vehcargo" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(523)
    if not HUD.DOES_BLIP_EXIST(blip) then
        util.toast("No Vehicle Found")
    else
        local coords = HUD.GET_BLIP_COORDS(blip)
        TELEPORT(coords.x, coords.y, coords.z + 1.0)
    end
end)
menu.action(MISSION_ENTITY_cargo, "载具货物 传送到我", { "tpme_vehcargo" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(523)
    if not HUD.DOES_BLIP_EXIST(blip) then
        util.toast("No Vehicle Cargo Found")
    else
        local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            TP_TO_ME(ent, 0.0, 2.0, -0.5)
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
            --vehicle
            if HUD.GET_BLIP_INFO_ID_TYPE(blip) == 1 then
                TP_INTO_VEHICLE(ent, "delete", "delete")
            end
        else
            util.toast("No Entity, Can't Teleport To Me")
        end
    end
end)



-------- 地堡拉货 --------
local MISSION_ENTITY_bunker = menu.list(MISSION_ENTITY, "地堡拉货", {}, "")

menu.action(MISSION_ENTITY_bunker, "传送到 原材料", { "tp_bsupplies" }, "", function()
    local blip1 = HUD.GET_NEXT_BLIP_INFO_ID(556)
    local blip2 = HUD.GET_NEXT_BLIP_INFO_ID(561)
    local blip3 = HUD.GET_NEXT_BLIP_INFO_ID(477)

    if HUD.DOES_BLIP_EXIST(blip1) then
        local coords = HUD.GET_BLIP_COORDS(blip1)
        TELEPORT(coords.x, coords.y + 2.0, coords.z + 1.0)
    elseif HUD.DOES_BLIP_EXIST(blip2) then
        local coords = HUD.GET_BLIP_COORDS(blip2)
        TELEPORT(coords.x, coords.y, coords.z + 1.0)
    elseif HUD.DOES_BLIP_EXIST(blip3) then
        local coords = HUD.GET_BLIP_COORDS(blip3)
        TELEPORT(coords.x, coords.y, coords.z + 1.0)
    else
        util.toast("No Bunker Supplies Found")
    end
end)
menu.action(MISSION_ENTITY_bunker, "原材料 传送到我", { "tpme_bsupplies" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(556)
    if not HUD.DOES_BLIP_EXIST(blip) then
        util.toast("No Vehicle Cargo Found")
    else
        local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            TP_TO_ME(ent, 0.0, 2.0, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
            --vehicle
            if HUD.GET_BLIP_INFO_ID_TYPE(blip) == 1 then
                TP_INTO_VEHICLE(ent, "delete", "delete")
            end
        else
            util.toast("No Entity, Can't Teleport To Me")
        end
    end
end)
menu.action(MISSION_ENTITY_bunker, "原材料：箱子 传送到我", {}, "游艇 货轮", function()
    local entity_list = GetEntity_ByModelHash("pickup", true, -955159266)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, -1.0)
        end
    else
        util.toast("Not Found")
    end
end)
menu.action(MISSION_ENTITY_bunker, "长鳍追飞机：掉落货物 传送到我", {}, "", function()
    local entity_list = GetEntity_ByModelHash("object", true, 91541528)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, 1.0)
        end
    else
        util.toast("Not Found")
    end
end)
menu.action(MISSION_ENTITY_bunker, "长鳍追飞机：炸掉长鳍", {},
    "不再等飞机慢慢地投放货物", function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, 1861786828) --长鳍
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            ENTITY.SET_ENTITY_INVINCIBLE(ent, false)
            local pos = ENTITY.GET_ENTITY_COORDS(ent)
            add_own_explosion(players.user_ped(), pos)
        end
    else
        util.toast("Not Found")
    end
end)
menu.action(MISSION_ENTITY_bunker, "消灭对手行动单位：箱子 全部爆炸", {}, "", function()
    local entity_list = GetEntity_ByModelHash("object", true, -986153641)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            add_own_explosion(players.user_ped(), pos)
        end
    else
        util.toast("Not Found")
    end
end)
menu.action(MISSION_ENTITY_bunker, "消灭对手行动单位：载具 全部爆炸", {}, "", function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, 788747387, -1050465301, -1860900134)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            local pos = ENTITY.GET_ENTITY_COORDS(ent)
            add_own_explosion(players.user_ped(), pos)
        end
    else
        util.toast("Not Found")
    end
end)
menu.action(MISSION_ENTITY_bunker, "摧毁卡车 全部爆炸", {}, "", function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, 904750859)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            local pos = ENTITY.GET_ENTITY_COORDS(ent)
            add_own_explosion(players.user_ped(), pos)
        end
    else
        util.toast("Not Found")
    end
end)
menu.action(MISSION_ENTITY_bunker, "骇入飞机 传送到我", {}, "传送到头上并冻结", function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, -32878452)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            ENTITY.FREEZE_ENTITY_POSITION(ent, true)
            TP_TO_ME(ent, 0.0, 0.0, 10.0)
        end
    else
        util.toast("Not Found")
    end
end)



-------- 佩里科岛抢劫 --------
local MISSION_ENTITY_perico = menu.list(MISSION_ENTITY, "佩里科岛抢劫", {}, "")

menu.action(MISSION_ENTITY_perico, "传送到虎鲸 任务面板", { "tp_kosatka_in" },
    "需要提前叫出虎鲸", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(760)
    if not HUD.DOES_BLIP_EXIST(blip) then
        util.toast("未找到虎鲸")
    else
        TELEPORT(1561.2369, 385.8771, -49.689915, 175)
    end
end)
menu.action(MISSION_ENTITY_perico, "传送到虎鲸 外面甲板", { "tp_kosatka_out" },
    "需要提前叫出虎鲸", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(760)
    if not HUD.DOES_BLIP_EXIST(blip) then
        util.toast("未找到虎鲸")
    else
        local pos = HUD.GET_BLIP_COORDS(blip)
        local heading = HUD.GET_BLIP_ROTATION(blip)
        TELEPORT(pos.x - 5.25, pos.y + 30.84, pos.z + 3, heading + 180)
    end
end)

menu.divider(MISSION_ENTITY_perico, "侦查")
menu.action(MISSION_ENTITY_perico, "美杜莎 传送到驾驶位", {}, "", function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, 1077420264) --美杜莎
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            VEHICLE.SET_VEHICLE_ENGINE_ON(ent, true, true, false)
            ENTITY.SET_ENTITY_INVINCIBLE(ent, true)
            PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), ent, -1)
        end
    end
end)
menu.action(MISSION_ENTITY_perico, "信号塔 传送到那里", {}, "", function()
    local entity_list = GetEntity_ByModelHash("object", true, 1981815996) --信号塔
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, -0.5, 0.5)
            SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ent)
        end
    end
end)

menu.divider(MISSION_ENTITY_perico, "前置")
menu.action(MISSION_ENTITY_perico, "长崎 传送到我并坐进尖锥魅影", {},
    "生成并坐进尖锥魅影 传送长崎到后面", function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, -1352468814) --长崎
    if next(entity_list) ~= nil then
        local modelHash = util.joaat("phantom2")
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0.0, 2.0, 0.0)
        local veh = Create_Network_Vehicle(modelHash, coords.x, coords.y, coords.z, PLAYER_HEADING())

        TP_INTO_VEHICLE(veh)

        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, -10.0, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
        end
    end
end)
menu.action(MISSION_ENTITY_perico, "保险箱密码 传送到那里", {}, "赌场 保安队长", function()
    local entity_list = GetEntity_ByModelHash("ped", true, -1109568186)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, 0.0, 0.5)
        end
    end
end)
menu.action(MISSION_ENTITY_perico, "等离子切割枪包裹 传送到我", {}, "", function()
    local entity_list = GetEntity_ByModelHash("pickup", true, -802406134)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 0.0, 2.0)
        end
    end
end)
menu.action(MISSION_ENTITY_perico, "指纹复制器 传送到我", {}, "地下车库", function()
    local entity_list = GetEntity_ByModelHash("pickup", true, 1506325614)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 0.0, 2.0)
        end
    end
end)
menu.action(MISSION_ENTITY_perico, "割据 传送到那里", {}, "工地", function()
    local entity_list = GetEntity_ByModelHash("pickup", true, 1871441709)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, 1.5, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ent, -180)
        end
    end
end)
menu.action(MISSION_ENTITY_perico, "武器 炸掉女武神", {}, "不再等他慢慢地飞", function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, -1600252419) --女武神
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            local pos = ENTITY.GET_ENTITY_COORDS(ent)
            add_own_explosion(players.user_ped(), pos)
        end
    end
end)

menu.divider(MISSION_ENTITY_perico, "佩里科岛")
menu.action(MISSION_ENTITY_perico, "信号塔 传送到我", {}, "", function()
    local entity_list = GetEntity_ByModelHash("object", false, 1981815996)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, -1.0)
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
        end
    end
end)
menu.action(MISSION_ENTITY_perico, "发电站 传送到我", {}, "", function()
    local entity_list = GetEntity_ByModelHash("object", false, 1650252819)
    if next(entity_list) ~= nil then
        local x = 0.0
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, x, 2.0, 0.5)
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
            x = x + 1.5
        end
    end
end)
menu.action(MISSION_ENTITY_perico, "保安服 传送到我", {}, "", function()
    local entity_list = GetEntity_ByModelHash("object", false, -1141961823)
    if next(entity_list) ~= nil then
        local x = 0.0
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, x, 2.0, -1.0)
            x = x + 1.0
        end
    end
end)
menu.action(MISSION_ENTITY_perico, "螺旋切割器 传送到我", {}, "", function()
    local entity_list = GetEntity_ByModelHash("pickup", false, -710382954)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, -1.0)
        end
    end
end)
menu.action(MISSION_ENTITY_perico, "抓钩 传送到我", {}, "", function()
    local entity_list = GetEntity_ByModelHash("pickup", false, -1789904450)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, -1.0)
        end
    end
end)
menu.action(MISSION_ENTITY_perico, "运货卡车 传送到我", {}, "自动删除npc卡车司机", function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, 2014313426)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
            TP_INTO_VEHICLE(ent, "", "delete")
        end
    end
end)
-----
local MISSION_ENTITY_perico_other = menu.list(MISSION_ENTITY_perico, "其它", {}, "")

menu.action(MISSION_ENTITY_perico_other, "获取豪宅内黄金数量", {},
    "先获取黄金数量才能传送", function()
    --黄金实体list
    gold_vault_ent = {}
    local num = 0
    for k, ent in pairs(entities.get_all_objects_as_handles()) do
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
            if EntityHash == -180074230 then
                num = num + 1
                table.insert(gold_vault_ent, ent)
            end
        end
    end
    util.toast("Number: " .. num)
    menu.set_max_value(menu_Gold_Vault_TP, num)
    menu.set_max_value(menu_Gold_Vault_TP2, num)
end)
menu_Gold_Vault_TP = menu.click_slider(MISSION_ENTITY_perico_other, "黄金 传送到我", {}, "很容易卡住，最好第三人称，在干掉主要目标之前拿"
    , 0, 0, 0, 1, function(value)
    if value > 0 then
        local ent = gold_vault_ent[value]
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            TP_TO_ME(ent, 0.0, 1.0, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
        else
            util.toast("实体不存在")
        end
    end
end)
menu_Gold_Vault_TP2 = menu.click_slider(MISSION_ENTITY_perico_other, "传送到 黄金", {}, "",
    0, 0, 0, 1, function(value)
    if value > 0 then
        local ent = gold_vault_ent[value]
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            TP_TO_ENTITY(ent, 0.0, -1.0, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ent)
        else
            util.toast("实体不存在")
        end
    end
end)

menu.action(MISSION_ENTITY_perico_other, "干掉主要目标玻璃柜、保险箱", {},
    "会在豪宅外生成主要目标包裹", function()
    local entity_list = GetEntity_ByModelHash("object", false, -1714533217, 1098122770) --玻璃柜、保险箱
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            ENTITY.SET_ENTITY_HEALTH(ent, 0)
        end
    end
end)
menu.action(MISSION_ENTITY_perico_other, "主要目标掉落包裹 传送到我", {},
    "携带主要目标者死亡后掉落的包裹", function()
    --包裹 Model Hash: -1851147549 (pickup)
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(765)
    if not HUD.DOES_BLIP_EXIST(blip) then
        util.toast("Not Found")
    else
        local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            TP_TO_ME(ent)
        end
    end
end)
menu.action(MISSION_ENTITY_perico_other, "办公室保险箱 传送到我", {},
    "保险箱门和里面的现金", function()
    local entity_list = GetEntity_ByModelHash("object", false, 485111592) --保险箱
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, -0.5, 1.0, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped(), 180.0)
        end
    end

    entity_list = GetEntity_ByModelHash("pickup", false, -2143192170) --现金
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 1.0, 0.0)
        end
    end
end)



-------- 赌场抢劫 --------
local MISSION_ENTITY_casion = menu.list(MISSION_ENTITY, "赌场抢劫", {}, "")

menu.divider(MISSION_ENTITY_casion, "侦查")
menu.action(MISSION_ENTITY_casion, "保安 传送到我", {}, "侦查前置", function()
    local entity_list = GetEntity_ByModelHash("ped", true, -1094177627)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, 10.0)
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
        end
    end
end)

local casion_invest_pos = {
    { 1131.7562, 278.7316, -51.0408 },
    { 1146.7454, 243.3848, -51.0408 },
    { 1105.9666, 259.99405, -50.840923 }
}
menu.click_slider(MISSION_ENTITY_casion, "赌场 传送到骇入位置", {}, "进入赌场后再传送",
    1, 3, 1, 1, function(value)
    local pos = casion_invest_pos[value]
    TELEPORT(pos[1], pos[2], pos[3])
end)

menu.divider(MISSION_ENTITY_casion, "前置")
menu.action(MISSION_ENTITY_casion, "武器 传送到我", {}, "摩托车帮 长方形板条包裹"
    , function()
    local entity_list = GetEntity_ByModelHash("pickup", true, 798951501)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, -1.0)
        end
    end
end)
menu.action(MISSION_ENTITY_casion, "武器：车 传送到我", {}, "国安局面包车 武器在防暴车内"
    , function()
    local entity_list = GetEntity_ByModelHash("object", true, 1885839156)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            if ENTITY.IS_ENTITY_ATTACHED(ent) then
                local attached_ent = ENTITY.GET_ENTITY_ATTACHED_TO(ent)
                TP_TO_ME(attached_ent, 0.0, 2.0, -1.0)
                SET_ENTITY_HEAD_TO_ENTITY(attached_ent, players.user_ped())
                TP_INTO_VEHICLE(attached_ent, "delete", "delete")
            end
        end
    end
end)
menu.action(MISSION_ENTITY_casion, "武器：飞机 传送到驾驶位", {}, "走私犯 水上飞机"
    , function()
    --Model Hash: -1628917549 (pickup) 炸毁飞机掉落的货物
    local entity_list = GetEntity_ByModelHash("vehicle", true, 1043222410)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_INTO_VEHICLE(ent, "delete", "delete")
            ENTITY.SET_ENTITY_INVINCIBLE(ent, true)
        end
    end
end)
menu.action(MISSION_ENTITY_casion, "载具：天威 传送到我", {}, "天威 经典版", function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, 931280609)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, -1.0)
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
            TP_INTO_VEHICLE(ent, "", "delete")
        end
    end
end)
menu.action(MISSION_ENTITY_casion, "骇入装置 传送到我", {},
    "FIB大楼 电脑旁边 提箱\n国安局总部 服务器或桌子旁边", function()
    local entity_list = GetEntity_ByModelHash("pickup", true, -155327337)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, -1.0)
        end
    end
end)
menu.action(MISSION_ENTITY_casion, "金库门禁卡：狱警 传送到我", {}, "监狱巴士 监狱 狱警",
    function()
        local entity_list = GetEntity_ByModelHash("ped", true, 1456041926)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ME(ent, 0.0, 2.0, -1.0)
            end
        end
    end)
menu.action(MISSION_ENTITY_casion, "金库门禁卡：保安 传送到我", {},
    "醉酒保安和偷情保安", function()
    local entity_list = GetEntity_ByModelHash("ped", true, -1575488699, -1425378987)
    if next(entity_list) ~= nil then
        local x = 0.0
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, x, 2.0, 10.0)
            x = x + 3.0
        end
    end
end)
menu.action(MISSION_ENTITY_casion, "巡逻路线：车 传送到我", {}, "某辆车后备箱里的箱子", function()
    local entity_list = GetEntity_ByModelHash("object", true, 1265214509)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            if ENTITY.IS_ENTITY_ATTACHED(ent) then
                local attached_ent = ENTITY.GET_ENTITY_ATTACHED_TO(ent)
                TP_TO_ME(attached_ent, 0.0, 4.0, -1.0)
                SET_ENTITY_HEAD_TO_ENTITY(attached_ent, players.user_ped())
            end
        end
    end
end)
menu.action(MISSION_ENTITY_casion, "杜根货物 全部爆炸", {}, "直升机 车 船\n一次性炸不完，多炸几次"
    , function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, -1671539132, 1747439474, 1448677353)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            local pos = ENTITY.GET_ENTITY_COORDS(ent)
            add_own_explosion(players.user_ped(), pos)
        end
    end
end)
menu.action(MISSION_ENTITY_casion, "电钻 传送到那里", {}, "工地 箱子里的电钻", function()
    local entity_list = GetEntity_ByModelHash("pickup", true, -12990308)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, 0.0, 0.5)
        end
    end
end)
menu.action(MISSION_ENTITY_casion, "二级保安证：尸体 传送到那里", {}, "灵车 医院 泊车员尸体",
    function()
        local entity_list = GetEntity_ByModelHash("object", true, 771433594)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ENTITY(ent, -1.0, 0.0, 0.0)
                SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ent, -80.0)
            end
        end
    end)
menu.action(MISSION_ENTITY_casion, "二级保安证：保安证 传送到我", {}, "聚会 小卡片", function()
    local entity_list = GetEntity_ByModelHash("pickup", true, -2018799718)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 1.0, 0.0)
        end
    end
end)

menu.divider(MISSION_ENTITY_casion, "隐迹潜踪")
menu.action(MISSION_ENTITY_casion, "无人机零件 传送到我", {},
    "会先炸掉无人机，再传送掉落的零件", function()
    --Model Hash: 1657647215 纳米无人机 (object)
    --Model Hash: -1285013058 无人机炸毁后掉落的零件（pickup）
    local entity_list = GetEntity_ByModelHash("object", true, 1657647215)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            local pos = ENTITY.GET_ENTITY_COORDS(ent)
            add_own_explosion(players.user_ped(), pos)
        end
    end
    util.yield(1500)
    entity_list = GetEntity_ByModelHash("pickup", true, -1285013058)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, -1.0)
        end
    end
end)
menu.action(MISSION_ENTITY_casion, "金库激光器 传送到我", {}, "", function()
    local entity_list = GetEntity_ByModelHash("pickup", true, 1953119208)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, -1.0)
        end
    end
end)

menu.divider(MISSION_ENTITY_casion, "兵不厌诈")
menu.action(MISSION_ENTITY_casion, "古倍科技套装 传送到我", {}, "", function()
    local entity_list = GetEntity_ByModelHash("pickup", true, 1425667258)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, -1.0)
        end
    end
end)
menu.action(MISSION_ENTITY_casion, "金库钻孔机 传送到我", {}, "全福银行", function()
    local entity_list = GetEntity_ByModelHash("pickup", true, 415149220)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, -1.0)
        end
    end
end)
menu.action(MISSION_ENTITY_casion, "国安局套装 传送到我", {}, "警察局", function()
    local entity_list = GetEntity_ByModelHash("pickup", true, -1713985235)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, -1.0)
        end
    end
end)

menu.divider(MISSION_ENTITY_casion, "气势汹汹")
menu.action(MISSION_ENTITY_casion, "热能炸药 传送到我", {}, "", function()
    local entity_list = GetEntity_ByModelHash("pickup", true, -2043162923)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, -1.0)
        end
    end
end)
menu.action(MISSION_ENTITY_casion, "金库炸药 传送到我", {}, "要潜水下去 难找恶心", function()
    local entity_list = GetEntity_ByModelHash("pickup", true, -681938663)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, -1.0)
        end
    end
end)
menu.action(MISSION_ENTITY_casion, "加固防弹衣 传送到我", {}, "地堡 箱子", function()
    local entity_list = GetEntity_ByModelHash("pickup", true, 1715697304)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, 0.0)
        end
    end
end)
menu.action(MISSION_ENTITY_casion, "加固防弹衣：潜水套装 传送到我", {}, "人道实验室", function()
    local entity_list = GetEntity_ByModelHash("object", true, 788248216)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, -1.0)
        end
    end
end)

menu.divider(MISSION_ENTITY_casion, "赌场")
menu.action(MISSION_ENTITY_casion, "小金库现金车 传送到那里", {}, "", function()
    local entity_list = GetEntity_ByModelHash("object", true, 1736112330)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, 0.0, 0.5)
        end
    end
end)
menu.action(MISSION_ENTITY_casion, "获取金库内推车数量", {},
    "先获取推车数量才能传送", function()
    --手推车 实体list
    vault_trolley_ent = {}
    local num = 0
    for k, ent in pairs(entities.get_all_objects_as_handles()) do
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
            if EntityHash == 412463629 then
                num = num + 1
                table.insert(vault_trolley_ent, ent)
            elseif EntityHash == 1171655821 then
                num = num + 1
                table.insert(vault_trolley_ent, ent)
            elseif EntityHash == 1401432049 then
                num = num + 1
                table.insert(vault_trolley_ent, ent)
            end
        end
    end
    util.toast("Number: " .. num)
    menu.set_max_value(menu_Vault_Trolley_TP, num)
end)
menu_Vault_Trolley_TP = menu.click_slider(MISSION_ENTITY_casion, "金库内推车 传送到那里", {}, "",
    0, 0, 0, 1, function(value)
    if value > 0 then
        local ent = vault_trolley_ent[value]
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, 0.0, 0.0, 0.5)
            ENTITY.SET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), coords.x, coords.y, coords.z, true, false, false, false)
            TP_TO_ENTITY(ent, 0.0, 0.0, 0.5)
            SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ent)
        else
            util.toast("实体不存在")
        end
    end
end)



-------- 合约 别惹德瑞 --------
local MISSION_ENTITY_contract = menu.list(MISSION_ENTITY, "别惹德瑞", {}, "")

menu.divider(MISSION_ENTITY_contract, "夜生活泄密")
menu.action(MISSION_ENTITY_contract, "夜总会：传送到 录像带", {}, "", function()
    TELEPORT(-1617.9883, -3013.7363, -75.20509)
    ENTITY.SET_ENTITY_HEADING(players.user_ped(), 203.7907)
end)
menu.action(MISSION_ENTITY_contract, "船坞：传送到 船里", {}, "绿色的船",
    function()
        local entity_list = GetEntity_ByModelHash("vehicle", true, 908897389)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_INTO_VEHICLE(ent)
            end
        end
    end)
menu.action(MISSION_ENTITY_contract, "船坞：传送到 证据", {}, "德瑞照片",
    function()
        local entity_list = GetEntity_ByModelHash("object", true, -1702870637)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ENTITY(ent, 0.0, 0.0, 0.5)
            end
        end
    end)
menu.action(MISSION_ENTITY_contract, "夜生活泄密：传送到 抢夺电脑", {}, "", function()
    TELEPORT(944.01764, 7.9015555, 116.1642)
    ENTITY.SET_ENTITY_HEADING(players.user_ped(), 279.8804)
end)

menu.divider(MISSION_ENTITY_contract, "上流社会泄密")
menu.action(MISSION_ENTITY_contract, "乡村俱乐部：炸掉礼车", {}, "", function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, -420911112)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            local pos = ENTITY.GET_ENTITY_COORDS(ent)
            add_own_explosion(players.user_ped(), pos)
        end
    end
end)
menu.action(MISSION_ENTITY_contract, "乡村俱乐部：门禁 传送到我", {}, "车内NPC",
    function()
        local entity_list = GetEntity_ByModelHash("ped", true, -912318012)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ME(ent, 0.0, 2.0, 0.0)
            end
        end
    end)
menu.action(MISSION_ENTITY_contract, "宾客名单：律师 传送到我", {}, "", function()
    local entity_list = GetEntity_ByModelHash("ped", true, 600300561)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, 0.0)
        end
    end
end)
menu.action(MISSION_ENTITY_contract, "上流社会泄密：炸掉直升机", {}, "",
    function()
        local entity_list = GetEntity_ByModelHash("vehicle", true, 1075432268)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                local pos = ENTITY.GET_ENTITY_COORDS(ent)
                add_own_explosion(players.user_ped(), pos)
            end
        end
    end)
menu.action(MISSION_ENTITY_contract, "上流社会泄密：坐进直升机", {}, "",
    function()
        local entity_list = GetEntity_ByModelHash("vehicle", true, 1075432268)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                PED.SET_PED_INTO_VEHICLE(players.user_ped(), ent, -2)
            end
        end
    end)

menu.divider(MISSION_ENTITY_contract, "南中心区泄密")
menu.action(MISSION_ENTITY_contract, "强化弗农", {}, "", function()
    local entity_list = GetEntity_ByModelHash("ped", true, -843935326)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            local weaponHash = util.joaat("WEAPON_SPECIALCARBINE")
            WEAPON.GIVE_WEAPON_TO_PED(ent, weaponHash, -1, false, true)
            WEAPON.SET_CURRENT_PED_WEAPON(ent, weaponHash, false)
            Increase_Ped_Combat_Ability(ent, true, false)
            Increase_Ped_Combat_Attributes(ent)
            util.toast("Done!")
        end
    end
end)
menu.action(MISSION_ENTITY_contract, "南中心区泄密：底盘车 传送到我", {}, "",
    function()
        local entity_list = GetEntity_ByModelHash("vehicle", true, -1013450936)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ME(ent, 0.0, 2.0, 0.0)
                SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
                TP_INTO_VEHICLE(ent, "", "tp")
                ENTITY.SET_ENTITY_HEALTH(ent, 10000)
            end
        end
    end)



------- 富兰克林电话任务 -------
local MISSION_ENTITY_payphone = menu.list(MISSION_ENTITY, "富兰克林电话任务", {}, "")

local MISSION_ENTITY_payphone_remove = menu.list(MISSION_ENTITY_payphone, "移除冷却时间", {}, "来自Heist Control")
menu.toggle_loop(MISSION_ENTITY_payphone_remove, "跳过电话暗杀和合约的冷却", { "agccoolhit" },
    "Make sure enabled before starting any contract or hit.", function()
        SET_INT_GLOBAL(262145 + 31701, 0) -- -1462622971
        SET_INT_GLOBAL(262145 + 31765, 0) -- -2036534141
    end, function()
    SET_INT_GLOBAL(262145 + 31701, 300000)
    SET_INT_GLOBAL(262145 + 31765, 500)
end)
menu.toggle_loop(MISSION_ENTITY_payphone_remove, "移除安保合约任务冷却", { "agcremcool" }, "", function()
    SET_INT_GLOBAL(262145 + 31781, 0) -- 1872071131
end, function()
    SET_INT_GLOBAL(262145 + 31781, 1200000)
end)

menu.action(MISSION_ENTITY_payphone, "传送到 电话亭", { "tppayphone" },
    "Teleport to Payphone (must have called Franklin already)", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(817)
    if not HUD.DOES_BLIP_EXIST(blip) then
        util.toast("No Vehicle Found")
    else
        local coords = HUD.GET_BLIP_COORDS(blip)
        TELEPORT(coords.x, coords.y, coords.z + 1.0)
    end
end)

----- 电话暗杀 -----
local MISSION_ENTITY_payphone_hit = menu.list(MISSION_ENTITY_payphone, "电话暗杀", {}, "")

menu.divider(MISSION_ENTITY_payphone_hit, "死宅散户")
menu.action(MISSION_ENTITY_payphone_hit, "目标NPC 传送到我", {}, "", function()
    for _, ped in pairs(entities.get_all_peds_as_handles()) do
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ped) then
            local blip = HUD.GET_BLIP_FROM_ENTITY(ped)
            if HUD.DOES_BLIP_EXIST(blip) and HUD.GET_BLIP_SPRITE(blip) == 432 then
                TP_TO_ME(ped, 0.0, 2.0, 0.0)
                WEAPON.REMOVE_ALL_PED_WEAPONS(ped)
                Disable_Ped_Flee(ent)

                util.yield(200)
            end
        end
    end
end)

menu.divider(MISSION_ENTITY_payphone_hit, "流星歌星")
menu.action(MISSION_ENTITY_payphone_hit, "目标载具 传送到我", {}, "", function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, 2038480341)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 5.0, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped(), 180.0)
            VEHICLE.SET_VEHICLE_FORWARD_SPEED(ent, 0.0)
            for i = 0, 5, 1 do
                VEHICLE.SET_VEHICLE_TYRE_BURST(ent, i, true, 1000.0)
            end

        end
    end
end)
menu.action(MISSION_ENTITY_payphone_hit, "维戈斯帮改装车 传送到我", {}, "", function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, -1013450936)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 1.0, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
            TP_INTO_VEHICLE(ent)
        end
    end
end)
menu.action(MISSION_ENTITY_payphone_hit, "卡车车头 传送到我", {}, "", function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, 569305213, -2137348917)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 1.0, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
            TP_INTO_VEHICLE(ent)
        end
    end
end)
menu.action(MISSION_ENTITY_payphone_hit, "警车 传送到我", {}, "", function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, 1912215274)
    if next(entity_list) ~= nil then
        x = 0.0
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, x, 1.0, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
            TP_INTO_VEHICLE(ent)
            x = x + 3.0
        end
    end
end)

menu.divider(MISSION_ENTITY_payphone_hit, "科技企业家")
menu.action(MISSION_ENTITY_payphone_hit, "出租车 传送到我", {}, "", function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, -956048545)
    if next(entity_list) ~= nil then
        x = 0.0
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, x, 1.0, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
            TP_INTO_VEHICLE(ent)
            x = x + 3.0
        end
    end
end)

menu.divider(MISSION_ENTITY_payphone_hit, "法官")
menu.action(MISSION_ENTITY_payphone_hit, "传送到 高尔夫球场", {}, "领取高尔夫装备", function()
    TELEPORT(-1368.963, 56.357, 54.101, 278.422)
end)
menu.action(MISSION_ENTITY_payphone_hit, "目标NPC 传送到我", {}, "", function()
    local entity_list = GetEntity_ByModelHash("ped", true, 2111372120)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, 0.0)
        end
    end
end)

menu.divider(MISSION_ENTITY_payphone_hit, "共同创办人")
menu.action(MISSION_ENTITY_payphone_hit, "目标载具 最大速度为0", {}, "", function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, -2033222435)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            ENTITY.SET_ENTITY_MAX_SPEED(ent, 0.0)
            util.toast("Done!")
        end
    end
end)

menu.divider(MISSION_ENTITY_payphone_hit, "工地总裁")
menu.action(MISSION_ENTITY_payphone_hit, "传送到 装备", {}, "", function()
    local entity_list = GetEntity_ByModelHash("object", true, -86518587)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, -1.0, 1.0)
            SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ent)
        end
    end
end)
menu.action(MISSION_ENTITY_payphone_hit, "目标NPC 传送到集装箱附近", {}, "", function()
    local target_ped_list = GetEntity_ByModelHash("ped", true, -973145378)
    if next(target_ped_list) ~= nil then
        for k, ent in pairs(target_ped_list) do

            local entity_list = GetEntity_ByModelHash("object", true, 874602658)
            if next(entity_list) ~= nil then
                local target_object = entity_list[1]
                TP_ENTITY_TO_ENTITY(ent, target_object, 0.0, 0.0, -3.0)
            end

        end
    end
end)
menu.action(MISSION_ENTITY_payphone_hit, "目标NPC 传送到油罐附近", {}, "", function()
    local target_ped_list = GetEntity_ByModelHash("ped", true, -973145378)
    if next(target_ped_list) ~= nil then
        for k, ent in pairs(target_ped_list) do

            local entity_list = GetEntity_ByModelHash("object", true, -46303329)
            if next(entity_list) ~= nil then
                local target_object = entity_list[1]
                TP_ENTITY_TO_ENTITY(ent, target_object, -2.0, 0.0, 1.0)
            end

        end
    end
end)
menu.action(MISSION_ENTITY_payphone_hit, "目标NPC 传送到推土机附近", {}, "", function()
    local target_ped_list = GetEntity_ByModelHash("ped", true, -973145378)
    if next(target_ped_list) ~= nil then
        for k, ent in pairs(target_ped_list) do

            local entity_list = GetEntity_ByModelHash("vehicles", true, 1886712733)
            if next(entity_list) ~= nil then
                local target_object = 0
                for _, obj in pairs(t) do
                    local ped = GET_PED_IN_VEHICLE_SEAT(obj, -1)
                    if ped and not IS_PED_PLAYER(ped) then
                        target_object = obj
                    end
                end
                if ENTITY.DOES_ENTITY_EXIST(target_object) then
                    TP_ENTITY_TO_ENTITY(ent, target_object, 0.0, 6.0, 1.0)
                end
            end

        end
    end
end)





----- 安保合约 -----
local MISSION_ENTITY_payphone_contract = menu.list(MISSION_ENTITY_payphone, "安保合约", {}, "")

menu.divider(MISSION_ENTITY_payphone_contract, "回收贵重物品")
menu.action(MISSION_ENTITY_payphone_contract, "传送到 保险箱", {}, "", function()
    local entity_list = GetEntity_ByModelHash("object", true, -798293264)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, -0.5, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ent)
        end
    end
end)
menu.action(MISSION_ENTITY_payphone_contract, "传送到 保险箱密码", {}, "", function()
    local entity_list = GetEntity_ByModelHash("object", true, 367638847)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, 0.0, 0.5)
        end
    end
end)

menu.divider(MISSION_ENTITY_payphone_contract, "变现资产")
menu.action(MISSION_ENTITY_payphone_contract, "坐进要跟踪的车并加速", {},
    "梅利威瑟，亚美尼亚帮", function()
    local entity_list = GetEntity_ByModelHash("ped", true, 2047212121, -39239064)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            local blip = HUD.GET_BLIP_FROM_ENTITY(ent)
            if HUD.GET_BLIP_SPRITE(blip) == 225 then
                local veh = PED.GET_VEHICLE_PED_IS_IN(ent)
                if veh then
                    PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), veh, -2)
                    VEHICLE.MODIFY_VEHICLE_TOP_SPEED(veh, 500.0)
                    PED.SET_DRIVER_ABILITY(ent, 1.0)
                    PED.SET_DRIVER_AGGRESSIVENESS(ent, 1.0)
                    TASK.SET_DRIVE_TASK_DRIVING_STYLE(ent, 262144)
                    util.toast("Done!")
                end
            end
        end
    end
end)
menu.action(MISSION_ENTITY_payphone_contract, "要跟踪的摩托车 加速", {},
    "失落摩托帮，狗仔队", function()
    local entity_list = GetEntity_ByModelHash("ped", true, 1330042375, -322270187)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            local blip = HUD.GET_BLIP_FROM_ENTITY(ent)
            if HUD.GET_BLIP_SPRITE(blip) == 348 then
                local veh = PED.GET_VEHICLE_PED_IS_IN(ent)
                if veh then
                    VEHICLE.MODIFY_VEHICLE_TOP_SPEED(veh, 500.0)
                    PED.SET_DRIVER_ABILITY(ent, 1.0)
                    PED.SET_DRIVER_AGGRESSIVENESS(ent, 1.0)
                    TASK.SET_DRIVE_TASK_DRIVING_STYLE(ent, 262144)
                    util.toast("Done!")
                end
            end
        end
    end
end)

menu.divider(MISSION_ENTITY_payphone_contract, "资产保护")
menu.action(MISSION_ENTITY_payphone_contract, "酒桶&木箱&设备 无敌", {}, "", function()
    local entity_list = GetEntity_ByModelHash("object", true, -1597216682, 1329706303, 1503555850, -534405572)
    if next(entity_list) ~= nil then
        local i = 0
        for k, ent in pairs(entity_list) do
            ENTITY.SET_ENTITY_INVINCIBLE(ent, true)
            ENTITY.SET_ENTITY_PROOFS(ent, true, true, true, true, true, true, true, true)
            i = i + 1
        end
        util.toast("Done!\nNumber: " .. i)
    end
end)
menu.action(MISSION_ENTITY_payphone_contract, "保安 无敌强化", {}, "", function()
    local entity_list = GetEntity_ByModelHash("ped", true, -1575488699, -634611634)
    if next(entity_list) ~= nil then
        local i = 0
        for k, ent in pairs(entity_list) do
            local weaponHash = util.joaat("WEAPON_SPECIALCARBINE")
            WEAPON.GIVE_WEAPON_TO_PED(ent, weaponHash, -1, false, true)
            WEAPON.SET_CURRENT_PED_WEAPON(ent, weaponHash, false)
            Increase_Ped_Combat_Ability(ent, true, false)
            Increase_Ped_Combat_Attributes(ent)
            i = i + 1
        end
        util.toast("Done!\nNumber: " .. i)
    end
end)
menu.action(MISSION_ENTITY_payphone_contract, "毁掉资产 任务失败", {}, "不再等待漫长的10分钟",
    function()
        local entity_list = GetEntity_ByModelHash("object", true, -1597216682, 1329706303, 1503555850, -534405572)
        if next(entity_list) ~= nil then
            local i = 0
            for k, ent in pairs(entity_list) do
                ENTITY.SET_ENTITY_HEALTH(ent, 0)
                i = i + 1
            end
            util.toast("Done!\nNumber: " .. i)
        end
    end)

menu.divider(MISSION_ENTITY_payphone_contract, "载具回收")
menu.action(MISSION_ENTITY_payphone_contract, "厢形车 传送到驾驶位", {}, "人道实验室 失窃动物",
    function()
        local entity_list = GetEntity_ByModelHash("object", true, 485150676)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                if ENTITY.IS_ENTITY_ATTACHED(ent) then
                    local attached_ent = ENTITY.GET_ENTITY_ATTACHED_TO(ent)
                    TP_INTO_VEHICLE(attached_ent, "delete")
                end
            end
        end
    end)
menu.action(MISSION_ENTITY_payphone_contract, "机库门锁 传送到那里", {}, "", function()
    TELEPORT(-1249.1301, -2979.6404, -48.49219, 269.879)
end)

menu.divider(MISSION_ENTITY_payphone_contract, "救援行动")
menu.action(MISSION_ENTITY_payphone_contract, "传送到 客户", {}, "", function()
    local entity_list = GetEntity_ByModelHash("ped", true, -2076336881, -1589423867, 826475330, 2093736314)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            ENTITY.SET_ENTITY_INVINCIBLE(ent, true)
            ENTITY.SET_ENTITY_PROOFS(ent, true, true, true, true, true, true, true, true)

            TP_TO_ENTITY(ent, 0.0, 0.5, 0.0)
        end
    end
end)



------- 摩托帮合约 -------
local MISSION_ENTITY_mc = menu.list(MISSION_ENTITY, "摩托帮合约", {}, "")

menu.action(MISSION_ENTITY_mc, "传送到 货物", { "tp_mc_product" }, "", function()
    local blip1 = HUD.GET_NEXT_BLIP_INFO_ID(501)
    local blip2 = HUD.GET_NEXT_BLIP_INFO_ID(64)
    local blip3 = HUD.GET_NEXT_BLIP_INFO_ID(427)
    local blip4 = HUD.GET_NEXT_BLIP_INFO_ID(423)

    if HUD.DOES_BLIP_EXIST(blip1) then
        local coords = HUD.GET_BLIP_COORDS(blip1)
        TELEPORT(coords.x, coords.y - 1.5, coords.z) --MC Product
    elseif HUD.DOES_BLIP_EXIST(blip2) then
        local coords = HUD.GET_BLIP_COORDS(blip2)
        TELEPORT(coords.x, coords.y - 1.5, coords.z) --Heli
    elseif HUD.DOES_BLIP_EXIST(blip3) then
        local coords = HUD.GET_BLIP_COORDS(blip3)
        TELEPORT(coords.x, coords.y, coords.z + 1.0) --Boat
    elseif HUD.DOES_BLIP_EXIST(blip4) then
        local coords = HUD.GET_BLIP_COORDS(blip4)
        TELEPORT(coords.x, coords.y + 1.5, coords.z - 1.0) --Plane
    else
        util.toast("No MC Product Found")
    end
end)
menu.action(MISSION_ENTITY_mc, "回收暴君：传送到 割据", {}, "", function()
    local entity_list = GetEntity_ByModelHash("object", true, 339736694)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, -0.8, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ent)
        end
    end
end)
menu.action(MISSION_ENTITY_mc, "回收暴君：传送到 暴君钥匙", {}, "", function()
    local entity_list = GetEntity_ByModelHash("object", true, 2105669131)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, -0.8, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ent)
        end
    end
end)
menu.action(MISSION_ENTITY_mc, "回收暴君：传送到 货箱", {}, "有暴君的货箱", function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, 884483972)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            if ENTITY.IS_ENTITY_ATTACHED(ent) then
                local attached_ent = ENTITY.GET_ENTITY_ATTACHED_TO(ent)

                TP_TO_ENTITY(attached_ent, 0.0, -2.5, 0.0)
                SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), attached_ent)

                VEHICLE.SET_VEHICLE_ENGINE_ON(ent, true, true, false)
            end
        end
    end
end)



------- 机库拉货 -------
local MISSION_ENTITY_air = menu.list(MISSION_ENTITY, "机库拉货", {}, "")

local MISSION_ENTITY_air_remove = menu.list(MISSION_ENTITY_air, "移除冷却时间", {}, "来自Heist Control")
menu.toggle_loop(MISSION_ENTITY_air_remove, "空运货物", { "coolair" }, "", function()
    SET_INT_GLOBAL(262145 + 22751, 0) -- Tobacco, Counterfeit Goods, 1278611667
    SET_INT_GLOBAL(262145 + 22752, 0) -- Animal Materials, Art, Jewelry, -1424847540
    SET_INT_GLOBAL(262145 + 22753, 0) -- Narcotics, Chemicals, Medical Supplies, -1817541754
    SET_INT_GLOBAL(262145 + 22754, 0) -- Additional Time per Player, 1722502526
    SET_INT_GLOBAL(262145 + 22755, 0) -- Sale, -1091356151
end, function()
    SET_INT_GLOBAL(262145 + 22751, 120000)
    SET_INT_GLOBAL(262145 + 22752, 180000)
    SET_INT_GLOBAL(262145 + 22753, 240000)
    SET_INT_GLOBAL(262145 + 22754, 60000)
    SET_INT_GLOBAL(262145 + 22755, 2000)
end)

menu.action(MISSION_ENTITY_air, "传送到 货物", { "tp_air_product" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(568)
    if not HUD.DOES_BLIP_EXIST(blip) then
        util.toast("No Air Product Found")
    else
        local coords = HUD.GET_BLIP_COORDS(blip)
        TELEPORT(coords.x, coords.y, coords.z + 1.0)
    end
end)
menu.action(MISSION_ENTITY_air, "货物 传送到我", { "tp_me_air_product" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(568)
    if not HUD.DOES_BLIP_EXIST(blip) then
        local entity_list = GetEntity_ByModelHash("pickup", true, -1270906188)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ME(ent, 0.0, 2.0, -0.5)
            end
        else
            util.toast("No Air Product Found")
        end
    else
        local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            TP_TO_ME(ent, 0.0, 2.0, -0.5)
        else
            util.toast("No Entity, Can't Teleport To Me")
        end
    end
end)
menu.action(MISSION_ENTITY_air, "货物(载具) 传送到我", {}, "", function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, 788747387, -305727417, -1386191424, 744705981, -
        1205689942)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 1.0, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
            TP_INTO_VEHICLE(ent, "delete", "delete")
        end
    end
end)
menu.action(MISSION_ENTITY_air, "毁掉 泰坦号", {}, "", function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, 1981688531)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 0.0, 20.0)
            util.yield(2000)
            entities.delete(ent)
        end
    end
end)

menu.action(MISSION_ENTITY_air, "爆炸 所有敌对载具", { "veh_hostile_explode" }, "", function()
    for _, vehicle in pairs(entities.get_all_vehicles_as_handles()) do
        if IS_HOSTILE_ENTITY(vehicle) then
            local coords = ENTITY.GET_ENTITY_COORDS(vehicle)
            add_own_explosion(players.user_ped(), coords, 4, { isAudible = false })
        end
    end
end)
menu.action(MISSION_ENTITY_air, "爆炸 所有敌对NPC", { "ped_hostile_explode" }, "", function()
    for _, ped in pairs(entities.get_all_peds_as_handles()) do
        if IS_HOSTILE_ENTITY(ped) then
            local coords = ENTITY.GET_ENTITY_COORDS(ped)
            add_own_explosion(players.user_ped(), coords, 4, { isAudible = false })
        end
    end
end)
menu.action(MISSION_ENTITY_air, "爆炸 所有敌对物体", { "obj_hostile_explode" }, "", function()
    for _, object in pairs(entities.get_all_objects_as_handles()) do
        if IS_HOSTILE_ENTITY(object) then
            local coords = ENTITY.GET_ENTITY_COORDS(object)
            add_own_explosion(players.user_ped(), coords, 4, { isAudible = false })
        end
    end
end)



------- 其它 -------
local MISSION_ENTITY_other = menu.list(MISSION_ENTITY, "其它", {}, "")

menu.action(MISSION_ENTITY_other, "传送到 夜总会VIP客户", { "tp_radar_vip" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(480)
    if HUD.DOES_BLIP_EXIST(blip) then
        local coords = HUD.GET_BLIP_COORDS(blip)
        TELEPORT(coords.x, coords.y, coords.z + 0.8)
    end
end)
menu.action(MISSION_ENTITY_other, "传送到 地图蓝点", { "tp_radar_blue" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(143)
    if HUD.DOES_BLIP_EXIST(blip) then
        local coords = HUD.GET_BLIP_COORDS(blip)
        TELEPORT(coords.x, coords.y, coords.z + 0.8)
    end
end)
menu.action(MISSION_ENTITY_other, "出口载具 传送到我", {}, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(143)
    if HUD.DOES_BLIP_EXIST(blip) then
        local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
        if ENTITY.IS_ENTITY_A_VEHICLE(ent) then
            TP_TO_ME(ent, 0.0, 2.0, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
            TP_INTO_VEHICLE(ent)
        end
    end
end)
menu.action(MISSION_ENTITY_other, "传送到 载具出口码头", {}, "", function()
    TELEPORT(1171.784, -2974.434, 6.502)
end)
menu.action(MISSION_ENTITY_other, "打开 恐霸屏幕", { "open_terrorbyte" }, "", function()
    if util.is_session_started() and not util.is_session_transition_active() then
        SET_INT_GLOBAL(Globals.IsUsingComputerScreen, 1)
        START_SCRIPT(Globals.SpecialCargoBuyScreenString, Globals.SpecialCargoBuyScreenArgs)
    end
end)



--------------------------
--------- 所有实体 ---------
--------------------------
local ALL_ENTITY_MANAGE = menu.list(Entity_options, "管理所有实体", {}, "")

------------------
--- 所有任务实体 ---
------------------
local MISSION_ENTITY_All = menu.list(ALL_ENTITY_MANAGE, "所有任务实体", {}, "")

local mission_ent_all_data = {
    type = "Ped", --实体类型
    -- 筛选设置 --
    mission = 2,
    distance = 0,
    blip = 1,
    move = 1,
    --ped
    except_player = true,
    combat = 1,
    ped_state = 1,
    --vehicle
    driver = 1,
}

menu.list_select(MISSION_ENTITY_All, "实体类型", {}, "", EntityType_ListItem, 1, function(value)
    mission_ent_all_data.type = EntityType_ListItem[value][1]
end)

--- 筛选设置 ---
local MISSION_ENTITY_All_Screen = menu.list(MISSION_ENTITY_All, "筛选设置", {}, "")
menu.list_select(MISSION_ENTITY_All_Screen, "任务实体", {}, "", { { "关闭" }, { "是" }, { "否" } }, 2,
    function(value)
        mission_ent_all_data.mission = value
    end)
menu.slider_float(MISSION_ENTITY_All_Screen, "范围", { "mission_ent_all_data_distance" }, "和玩家之间的距离是否在范围之内\n0表示全部范围"
    , 0, 100000, 0
    , 100, function(value)
    mission_ent_all_data.distance = value * 0.01
end)
menu.list_select(MISSION_ENTITY_All_Screen, "地图标记", {}, "", { { "关闭" }, { "有" }, { "没有" } }, 1,
    function(value)
        mission_ent_all_data.blip = value
    end)
menu.list_select(MISSION_ENTITY_All_Screen, "移动状态", {}, "", { { "关闭" }, { "静止" }, { "正在移动" } }, 1
    ,
    function(value)
        mission_ent_all_data.move = value
    end)
menu.divider(MISSION_ENTITY_All_Screen, "Ped")
menu.toggle(MISSION_ENTITY_All_Screen, "排除玩家", {}, "", function(toggle)
    mission_ent_all_data.except_player = toggle
end, true)
menu.list_select(MISSION_ENTITY_All_Screen, "与玩家敌对", {}, "", { { "关闭" }, { "是" }, { "否" } }, 1,
    function(value)
        mission_ent_all_data.combat = value
    end)
menu.list_select(MISSION_ENTITY_All_Screen, "状态", {}, "", { { "关闭" }, { "步行" }, { "载具内" }, { "已死亡" },
    { "正在射击" } }, 1,
    function(value)
        mission_ent_all_data.ped_state = value
    end)
menu.divider(MISSION_ENTITY_All_Screen, "Vehicle")
menu.list_select(MISSION_ENTITY_All_Screen, "司机", {}, "", { { "关闭" }, { "没有" }, { "NPC" }, { "玩家" } }, 1
    ,
    function(value)
        mission_ent_all_data.driver = value
    end)

--检查是否符合筛选条件
local function Check_match_condition(ent)
    local is_match = true
    --任务实体
    if mission_ent_all_data.mission > 1 then
        is_match = false
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            if mission_ent_all_data.mission == 2 then
                is_match = true
            end
        else
            if mission_ent_all_data.mission == 3 then
                is_match = true
            end
        end

        if not is_match then
            return false
        end
    end
    --范围
    if mission_ent_all_data.distance > 0 then
        local my_pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        local ent_pos = ENTITY.GET_ENTITY_COORDS(ent)
        if vect.dist(my_pos, ent_pos) <= mission_ent_all_data.distance then
        else
            return false
        end
    end
    --地图标记
    if mission_ent_all_data.blip > 1 then
        is_match = false
        if HUD.GET_BLIP_FROM_ENTITY(ent) > 0 then
            if mission_ent_all_data.blip == 2 then
                is_match = true
            end
        else
            if mission_ent_all_data.blip == 3 then
                is_match = true
            end
        end

        if not is_match then
            return false
        end
    end
    --移动状态
    if mission_ent_all_data.move > 1 then
        is_match = false
        if ENTITY.GET_ENTITY_SPEED(ent) == 0 then
            if mission_ent_all_data.move == 2 then
                is_match = true
            end
        else
            if mission_ent_all_data.move == 3 then
                is_match = true
            end
        end

        if not is_match then
            return false
        end
    end
    --- Ped ---
    if ENTITY.IS_ENTITY_A_PED(ent) then
        --排除玩家
        if mission_ent_all_data.except_player and IS_PED_PLAYER(ent) then
            return false
        end
        --与玩家敌对
        if mission_ent_all_data.combat > 1 then
            is_match = false
            if PED.IS_PED_IN_COMBAT(ent, players.user_ped()) then
                if mission_ent_all_data.combat == 2 then
                    is_match = true
                end
            else
                if mission_ent_all_data.combat == 3 then
                    is_match = true
                end
            end

            if not is_match then
                return false
            end
        end
        --状态
        if mission_ent_all_data.ped_state > 1 then
            if mission_ent_all_data.ped_state == 2 and PED.IS_PED_ON_FOOT(ent) then
            elseif mission_ent_all_data.ped_state == 3 and PED.IS_PED_IN_ANY_VEHICLE(ent, false) then
            elseif mission_ent_all_data.ped_state == 4 and ENTITY.IS_ENTITY_DEAD(ent) then
            elseif mission_ent_all_data.ped_state == 5 and PED.IS_PED_SHOOTING(ent) then
            else
                return false
            end
        end
    end
    --- Vehicle ---
    if ENTITY.IS_ENTITY_A_VEHICLE(ent) then
        --司机
        if mission_ent_all_data.driver > 1 then
            if mission_ent_all_data.driver == 2 and VEHICLE.IS_VEHICLE_SEAT_FREE(ent, -1, false) then
            elseif not VEHICLE.IS_VEHICLE_SEAT_FREE(ent, -1, false) then
                local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ent, -1)
                if mission_ent_all_data.driver == 3 and not IS_PED_PLAYER(driver) then
                elseif mission_ent_all_data.driver == 4 and IS_PED_PLAYER(driver) then
                else
                    return false
                end
            else
                return false
            end
        end
    end

    return is_match
end

local function Init_mission_ent_list()
    -- 任务实体 list
    mission_ent_list = {}
    -- 任务实体列表 menu.list
    mission_ent_menu_list = {}
    -- 所有任务实体列表 menu.list
    mission_ent_all_menu_list = {}
    -- 任务实体数量
    mission_ent_count = 0
end

Init_mission_ent_list()
local function Clear_mission_ent_list()
    if next(mission_ent_all_menu_list) ~= nil then
        menu.delete(mission_ent_all_menu_list[1])
        menu.delete(mission_ent_all_menu_list[2])
    end
    for k, v in pairs(mission_ent_menu_list) do
        if v ~= nil and menu.is_ref_valid(v) then
            menu.delete(v)
        end
    end
    Init_mission_ent_list()
    menu.set_menu_name(MISSION_ENTITY_All_divider, "实体列表")
end

menu.action(MISSION_ENTITY_All, "获取任务实体列表", {}, "", function()
    Clear_mission_ent_list()
    local all_ent = get_all_entities(mission_ent_all_data.type)

    for k, ent in pairs(all_ent) do
        if Check_match_condition(ent) then
            table.insert(mission_ent_list, ent)

            -- menu_name
            local modelHash = ENTITY.GET_ENTITY_MODEL(ent)
            local modelName = util.reverse_joaat(modelHash)
            local name = k .. ". "
            if modelName ~= "" then
                name = name .. modelName
            else
                name = name .. modelHash
            end
            -- help_text
            local text = ""
            local display_name = util.get_label_text(VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(modelHash))
            if display_name ~= "NULL" then
                text = text .. "Display Name: " .. display_name .. "\n"
            end
            local owner = entities.get_owner(entities.handle_to_pointer(ent))
            owner = players.get_name(owner)
            text = text .. "Hash: " .. modelHash .. "\nOwner: " .. owner

            --任务实体列表 menu.list
            local menu_list = menu.list(MISSION_ENTITY_All, name, {}, text)

            local index = "a" .. k
            Entity_Control.generate_menu(menu_list, ent, index)

            table.insert(mission_ent_menu_list, menu_list)

            --任务实体数量
            mission_ent_count = mission_ent_count + 1
        end
    end

    --全部任务实体
    if mission_ent_count == 0 then
        menu.set_menu_name(MISSION_ENTITY_All_divider, "实体列表")
    else
        menu.set_menu_name(MISSION_ENTITY_All_divider, "实体列表 (" .. mission_ent_count .. ")")

        mission_ent_all_menu_list[1] = menu.divider(MISSION_ENTITY_All, "")
        mission_ent_all_menu_list[2] = menu.list(MISSION_ENTITY_All, "全部实体管理", {}, "")
        Entity_Control.entities(mission_ent_all_menu_list[2], mission_ent_list)
    end

end)

menu.action(MISSION_ENTITY_All, "清空列表", {}, "", function()
    Clear_mission_ent_list()
end)
MISSION_ENTITY_All_divider = menu.divider(MISSION_ENTITY_All, "实体列表")


------------------------
--- 自定义 Model Hash ---
------------------------
local MISSION_ENTITY_custom = menu.list(ALL_ENTITY_MANAGE, "自定义 Model Hash", {}, "")

local custom_hash_entity = {
    hash = 0,
    type = "Ped",
    is_mission = true,
}
menu.text_input(MISSION_ENTITY_custom, "Model Hash ", { "custom_model_hash" }, "", function(value)
    custom_hash_entity.hash = tonumber(value)
end)
menu.action(MISSION_ENTITY_custom, "转换复制内容", {}, "删除Model Hash: \n自动填充到Hash输入框",
    function()
        local text = util.get_clipboard_text()
        local num = string.gsub(text, "Model Hash: ", "")
        menu.trigger_commands("custommodelhash " .. num)
    end)

custom_hash_entity_Type = menu.list_select(MISSION_ENTITY_custom, "实体类型", {}, "", EntityType_ListItem, 1,
    function(value)
        custom_hash_entity.type = EntityType_ListItem[value][1]
    end)
menu.toggle(MISSION_ENTITY_custom, "任务实体", {}, "是否为任务实体", function(toggle)
    custom_hash_entity.is_mission = toggle
end, true)

Saved_Hash_List.MISSION_ENTITY_custom = menu.list_action(MISSION_ENTITY_custom, "已保存的 Hash", {},
    "点击填充到Hash输入框和选择实体类型",
    Saved_Hash_List.get_list_item_data(), function(value)
    local Name = Saved_Hash_List.get_list()[value]
    local Hash, Type = Saved_Hash_List.read(Name)
    menu.trigger_commands("custommodelhash " .. Hash)
    menu.set_value(custom_hash_entity_Type, GET_ENTITY_TYPE_INDEX(Type))
end)

menu.divider(MISSION_ENTITY_custom, "")

local function Init_custom_hash_ent_list()
    -- 自定义hash的实体 list
    custom_hash_ent_list = {}
    -- 自定义hash实体列表 menu.list
    custom_hash_ent_menu_list = {}
    -- 自定义hash所有实体 menu.list
    custom_hash_all_ent_menu_list = {}
    -- 自定义hash的实体数量
    custom_hash_ent_count = 0
end

Init_custom_hash_ent_list()
local function Clear_custom_hash_ent_list()
    if next(custom_hash_all_ent_menu_list) ~= nil then
        menu.delete(custom_hash_all_ent_menu_list[1])
        menu.delete(custom_hash_all_ent_menu_list[2])
    end
    for _, v in pairs(custom_hash_ent_menu_list) do
        if v ~= nil and menu.is_ref_valid(v) then
            menu.delete(v)
        end
    end
    Init_custom_hash_ent_list()
    menu.set_menu_name(MISSION_ENTITY_custom_divider, "实体列表")
end

menu.action(MISSION_ENTITY_custom, "获取所有实体列表", {}, "", function()
    Clear_custom_hash_ent_list()
    ---
    local custom_all_entity = get_all_entities(custom_hash_entity.type)

    ---
    if tonumber(custom_hash_entity.hash) ~= nil and STREAMING.IS_MODEL_VALID(tonumber(custom_hash_entity.hash)) then
        for k, ent2 in pairs(custom_all_entity) do
            local modelHash = ENTITY.GET_ENTITY_MODEL(ent2)
            if modelHash == custom_hash_entity.hash then
                local ent
                if custom_hash_entity.is_mission then
                    if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent2) then
                        ent = ent2
                    end
                else
                    ent = ent2
                end
                -----
                if ent ~= nil then
                    table.insert(custom_hash_ent_list, ent) --entity

                    -- menu_name
                    local modelName = util.reverse_joaat(modelHash)
                    local name = k .. ". "
                    if modelName ~= "" then
                        name = name .. modelName
                    else
                        name = name .. modelHash
                    end
                    -- help_text
                    local text = ""

                    local display_name = util.get_label_text(VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(modelHash))
                    if display_name ~= "NULL" then
                        text = text .. "Display Name: " .. display_name .. "\n"
                    end

                    local owner = entities.get_owner(entities.handle_to_pointer(ent))
                    owner = players.get_name(owner)
                    text = text .. "Hash: " .. modelHash .. "\nOwner: " .. owner

                    local menu_list = menu.list(MISSION_ENTITY_custom, name, {}, text)

                    local index = "c" .. k
                    Entity_Control.generate_menu(menu_list, ent, index)

                    table.insert(custom_hash_ent_menu_list, menu_list)

                    -- 实体数量
                    custom_hash_ent_count = custom_hash_ent_count + 1
                end

            end
        end

        --全部实体
        if custom_hash_ent_count == 0 then
            menu.set_menu_name(MISSION_ENTITY_custom_divider, "实体列表")
            util.toast("No this entity !")
        else
            menu.set_menu_name(MISSION_ENTITY_custom_divider, "实体列表 (" .. custom_hash_ent_count .. ")")

            custom_hash_all_ent_menu_list[1] = menu.divider(MISSION_ENTITY_custom, "")
            custom_hash_all_ent_menu_list[2] = menu.list(MISSION_ENTITY_custom, "全部实体管理", {}, "")
            Entity_Control.entities(custom_hash_all_ent_menu_list[2], custom_hash_ent_list)
        end

    else
        util.toast("Wrong model hash !")
    end
end)

menu.action(MISSION_ENTITY_custom, "清空列表", {}, "", function()
    Clear_custom_hash_ent_list()
end)
MISSION_ENTITY_custom_divider = menu.divider(MISSION_ENTITY_custom, "实体列表")


----------------------
--- 保存的 Hash 列表 ---
----------------------
Saved_Hash_List.Manage_Hash_List_Menu = menu.list(ALL_ENTITY_MANAGE, "保存的 Hash 列表", {}, "")

--添加
local Manage_Hash_List_Menu_add = menu.list(Saved_Hash_List.Manage_Hash_List_Menu, "添加", {}, "")

local manage_hash_list_add = {
    name = "",
    hash = 0,
    type = "Ped"
}
menu.text_input(Manage_Hash_List_Menu_add, "名称", { "manage_hash_list_add_name" }, "", function(value)
    manage_hash_list_add.name = value
end)
menu.text_input(Manage_Hash_List_Menu_add, "Hash", { "manage_hash_list_add_hash" }, "", function(value)
    manage_hash_list_add.hash = value
end)
menu.list_select(Manage_Hash_List_Menu_add, "实体类型", {}, "", EntityType_ListItem, 1,
    function(value)
        value = EntityType_ListItem[value][1]
        manage_hash_list_add.type = value
    end)
menu.action(Manage_Hash_List_Menu_add, "添加", {}, "", function()
    if manage_hash_list_add.name ~= "" then
        if tonumber(manage_hash_list_add.hash) ~= nil and STREAMING.IS_MODEL_VALID(manage_hash_list_add.hash) then
            Saved_Hash_List.write(manage_hash_list_add.name, manage_hash_list_add.hash, manage_hash_list_add.type)
            util.toast("已添加")
        else
            util.toast("Wrong Hash !")
        end
    else
        util.toast("请输入名称")
    end

end)

menu.divider(Saved_Hash_List.Manage_Hash_List_Menu, "列表")
Saved_Hash_List.generate_menu_list(Saved_Hash_List.Manage_Hash_List_Menu)



menu.divider(Entity_options, "")
---------------------------
-------- 实体信息枪 ---------
---------------------------
local Entity_Info_Gun = menu.list(Entity_options, "实体信息枪", {}, "获取瞄准射击的实体信息")

local ent_info_isShowOnScreen = true --显示在屏幕上
local ent_info_item_data = {} --实体信息 list action item data

menu.toggle_loop(Entity_Info_Gun, "开启", { "info_gun" }, "", function()
    draw_point_in_center()
    local ent = GetEntity_PlayerIsAimingAt(players.user())
    if ent ~= nil and IS_AN_ENTITY(ent) then
        ent_info_item_data = GetEntityInfo_ListItem(ent)
        if next(ent_info_item_data) ~= nil then

            menu.set_list_action_options(ent_info_menu_list_action, ent_info_item_data)

            --显示在屏幕上
            if ent_info_isShowOnScreen then
                local text = ""
                for _, info in pairs(ent_info_item_data) do
                    if info[1] ~= nil then
                        text = text .. info[1] .. "\n"
                    end
                end
                DrawString(text, 0.7)
                --directx.draw_text(0.5, 0.0, text, ALIGN_TOP_LEFT, 0.75, color.purple)
            end
        end
    end
end)

menu.toggle(Entity_Info_Gun, "显示在屏幕上", {}, "", function(toggle)
    ent_info_isShowOnScreen = toggle
end, true)

menu.divider(Entity_Info_Gun, "")
ent_info_menu_list_action = menu.list_action(Entity_Info_Gun, "查看实体信息", {}, "", ent_info_item_data,
    function(value)
        local name = ent_info_item_data[value][1]
        util.copy_to_clipboard(name, false)
        util.toast("Copied!\n" .. name)
    end)

menu.action(Entity_Info_Gun, "复制实体信息", {}, "", function()
    local text = ""
    for _, info in pairs(ent_info_item_data) do
        if info[1] ~= nil then
            text = text .. info[1] .. "\n"
        end
    end
    util.copy_to_clipboard(text, false)
    util.toast("完成")
end)
menu.action(Entity_Info_Gun, "保存实体信息到日志", {}, "", function()
    local text = ""
    for _, info in pairs(ent_info_item_data) do
        if info[1] ~= nil then
            text = text .. info[1] .. "\n"
        end
    end
    util.log(text)
    util.toast("完成")
end)
