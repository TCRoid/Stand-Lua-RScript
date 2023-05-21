--------------------------------
------------ 娱乐选项 ------------
--------------------------------

local Fun_options = menu.list(menu.my_root(), "娱乐选项", {}, "")



--------------------
-- 玩家死亡反应
--------------------
local Self_Death_Reaction = menu.list(Fun_options, "玩家死亡反应", {}, "玩家死亡后对击杀者或死亡地点的反应")

local self_death_reaction = {
    flag = false,
    killer = {
        exclude_player = true,
        explosion = 0,
        rpg = 0,
        fall_explosion = 0,
        dead = false,
        freeze = false,
        fire = false,
        blip = false,
        blip_list = {},
    },
    position = {
        explosion = 0,
        blip = false,
        blip_list = {},
    },
}
menu.toggle_loop(Self_Death_Reaction, "启用", {}, "", function()
    local player_ped = players.user_ped()

    if PLAYER.IS_PLAYER_DEAD(players.user()) then
        if not self_death_reaction.flag then
            --- 击杀者 ---
            local ent = PED.GET_PED_SOURCE_OF_DEATH(player_ped)
            if IS_AN_ENTITY(ent) and ent ~= player_ped then
                --排除玩家
                if self_death_reaction.killer.exclude_player and IS_PED_PLAYER(ent) then
                else
                    local pos = ENTITY.GET_ENTITY_COORDS(ent)

                    --爆炸
                    if self_death_reaction.killer.explosion then
                        util.create_thread(function()
                            for i = 1, self_death_reaction.killer.explosion, 1 do
                                local coords = ENTITY.GET_ENTITY_COORDS(ent)
                                add_owned_explosion(player_ped, coords, 4)
                                util.yield(300)
                            end
                        end)
                    end

                    --坠落爆炸
                    if self_death_reaction.killer.fall_explosion > 0 then
                        util.create_thread(function()
                            ENTITY.FREEZE_ENTITY_POSITION(ent, false)
                            ENTITY.SET_ENTITY_MAX_SPEED(ent, 99999.0)
                            if ENTITY.IS_ENTITY_A_PED(ent) then
                                TASK.CLEAR_PED_TASKS_IMMEDIATELY(ent)
                            end
                            for i = 1, self_death_reaction.killer.fall_explosion, 1 do
                                if ENTITY.IS_ENTITY_A_PED(ent) then
                                    PED.SET_PED_TO_RAGDOLL(ent, 500, 500, 0, false, false, false)
                                end
                                ENTITY.APPLY_FORCE_TO_ENTITY(ent, 1, 0.0, 0.0, 30.0, math.random(-2, 2),
                                    math.random(-2, 2), 0.0, 0, false,
                                    false, true, false, false)
                                util.yield(1000)
                                ENTITY.APPLY_FORCE_TO_ENTITY(ent, 1, 0.0, 0.0, -100.0, 0.0, 0.0, 0.0, 0, false
                                , false, true, false, false)
                                util.yield(300)
                            end
                            local coords = ENTITY.GET_ENTITY_COORDS(ent)
                            FIRE.ADD_OWNED_EXPLOSION(player_ped, coords.x, coords.y, coords.z, 4, 1.0, true,
                                false, 0.0)
                        end)
                    end

                    --RPG轰炸
                    if self_death_reaction.killer.rpg > 0 then
                        util.create_thread(function()
                            local weaponHash = util.joaat("WEAPON_RPG")
                            for i = 1, self_death_reaction.killer.rpg, 1 do
                                local coords = ENTITY.GET_ENTITY_COORDS(ent)
                                MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(coords.x, coords.y, coords.z + 5.0, coords.x,
                                    coords.y, coords.z,
                                    1000,
                                    false, weaponHash, player_ped, true, false, 1000)
                                util.yield(300)
                            end
                        end)
                    end

                    --死亡
                    if self_death_reaction.killer.dead then
                        ENTITY.SET_ENTITY_HEALTH(ent, 0)
                    end

                    --冻结
                    if self_death_reaction.killer.freeze then
                        ENTITY.FREEZE_ENTITY_POSITION(ent, true)
                    end

                    --燃烧
                    if self_death_reaction.killer.fire then
                        FIRE.START_ENTITY_FIRE(ent)
                    end

                    --标记点
                    if self_death_reaction.killer.blip then
                        local blip = add_blip_for_entity(ent, 303, 1)
                        table.insert(self_death_reaction.killer.blip_list, blip)
                    end
                end
            end


            --- 死亡位置 ---
            local dead_pos = ENTITY.GET_ENTITY_COORDS(player_ped)

            if self_death_reaction.position.explosion > 0 then
                util.create_thread(function()
                    for i = 1, self_death_reaction.position.explosion, 1 do
                        add_owned_explosion(player_ped, dead_pos, 4)
                        util.yield(300)
                    end
                end)
            end

            if self_death_reaction.position.blip then
                local blip = HUD.ADD_BLIP_FOR_COORD(dead_pos.x, dead_pos.y, dead_pos.z)
                HUD.SET_BLIP_SPRITE(blip, 274)
                HUD.SET_BLIP_COLOUR(blip, 0)
                table.insert(self_death_reaction.position.blip_list, blip)
            end


            self_death_reaction.flag = true
        end
    else
        self_death_reaction.flag = false
    end
end)

menu.divider(Self_Death_Reaction, "击杀者")
menu.toggle(Self_Death_Reaction, "排除玩家", {}, "", function(toggle)
    self_death_reaction.killer.exclude_player = toggle
end, true)
menu.slider(Self_Death_Reaction, "爆炸", { "death_reaction_killer_explosion" }, "爆炸次数", 0, 10, 0, 1,
    function(value)
        self_death_reaction.killer.explosion = value
    end)
menu.slider(Self_Death_Reaction, "坠落爆炸", { "death_reaction_killer_fall_explosion" }, "坠落次数", 0, 10, 0, 1
, function(value)
    self_death_reaction.killer.fall_explosion = value
end)
menu.slider(Self_Death_Reaction, "RPG轰炸", { "death_reaction_killer_rpg" }, "轰炸次数", 0, 10, 0, 1,
    function(value)
        self_death_reaction.killer.rpg = value
    end)
menu.toggle(Self_Death_Reaction, "死亡", {}, "", function(toggle)
    self_death_reaction.killer.dead = toggle
end)
menu.toggle(Self_Death_Reaction, "冻结", {}, "", function(toggle)
    self_death_reaction.killer.freeze = toggle
end)
menu.toggle(Self_Death_Reaction, "燃烧", {}, "", function(toggle)
    self_death_reaction.killer.fire = toggle
end)
menu.toggle(Self_Death_Reaction, "标记点", {}, "", function(toggle)
    self_death_reaction.killer.blip = toggle
end)
menu.action(Self_Death_Reaction, "清空标记点", {}, "", function()
    for k, v in pairs(self_death_reaction.killer.blip_list) do
        if HUD.DOES_BLIP_EXIST(v) then
            util.remove_blip(v)
        end
    end
    self_death_reaction.killer.blip_list = {}
end)

menu.divider(Self_Death_Reaction, "死亡位置")
menu.slider(Self_Death_Reaction, "爆炸", { "death_reaction_position_explosion" }, "爆炸次数", 0, 10, 0, 1,
    function(value)
        self_death_reaction.position.explosion = value
    end)
menu.toggle(Self_Death_Reaction, "标记点", {}, "", function(toggle)
    self_death_reaction.position.blip = toggle
end)
menu.action(Self_Death_Reaction, "清空标记点", {}, "", function()
    for k, v in pairs(self_death_reaction.position.blip_list) do
        if HUD.DOES_BLIP_EXIST(v) then
            util.remove_blip(v)
        end
    end
    self_death_reaction.position.blip_list = {}
end)




--------------------
-- 载具碰撞反应
--------------------
local Vehicle_Collision_Reaction = menu.list(Fun_options, "载具碰撞反应", {}, "玩家和载具发生碰撞时对载具的反应")

local vehicle_collision_reaction = {
    hit_vehicle = 0,
    exclude_mission = true,
    -- reaction --
    kill_engine = false,
    burst_tyre = false,
    push_away = false,
    push_away_strength = 50,
    launch = false,
    launch_height = 30,
}

menu.toggle_loop(Vehicle_Collision_Reaction, "启用", {}, "", function()
    if PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
        local player_veh = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)

        if ENTITY.HAS_ENTITY_BEEN_DAMAGED_BY_ANY_VEHICLE(player_veh) then
            local vehicle = ENTITY._GET_LAST_ENTITY_HIT_BY_ENTITY(player_veh)
            if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
                if not IS_PLAYER_VEHICLE(vehicle) then
                    if vehicle_collision_reaction.exclude_mission and ENTITY.IS_ENTITY_A_MISSION_ENTITY(vehicle) then
                    else
                        --请求控制
                        RequestControl(vehicle)
                        --破坏引擎
                        if vehicle_collision_reaction.kill_engine then
                            VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, -4000)
                        end
                        --爆胎
                        if vehicle_collision_reaction.burst_tyre then
                            for i = 0, 5 do
                                if not VEHICLE.IS_VEHICLE_TYRE_BURST(vehicle, i, true) then
                                    VEHICLE.SET_VEHICLE_TYRE_BURST(vehicle, i, true, 1000.0)
                                end
                            end
                        end
                        --推开
                        if vehicle_collision_reaction.push_away then
                            local force = ENTITY.GET_ENTITY_COORDS(vehicle)
                            v3.sub(force, ENTITY.GET_ENTITY_COORDS(player_veh))
                            v3.normalise(force)
                            v3.mul(force, vehicle_collision_reaction.push_away_strength)
                            ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 3, force.x, force.y, force.z,
                                0, 0, 0.5, 0,
                                false, false, true, false, false)
                        end
                        --发射上天
                        if vehicle_collision_reaction.launch then
                            ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, 0.0, 0.0, vehicle_collision_reaction.launch_height,
                                0.0, 0.0, 0.0, 0,
                                false, false, true, false, false)
                        end
                    end
                end
            end
        end
    end
end)

menu.toggle(Vehicle_Collision_Reaction, "排除任务载具", {}, "", function(toggle)
    vehicle_collision_reaction.exclude_mission = toggle
end, true)

menu.divider(Vehicle_Collision_Reaction, "反应")
menu.toggle(Vehicle_Collision_Reaction, "破坏引擎", {}, "", function(toggle)
    vehicle_collision_reaction.kill_engine = toggle
end)
menu.toggle(Vehicle_Collision_Reaction, "爆胎", {}, "", function(toggle)
    vehicle_collision_reaction.burst_tyre = toggle
end)
menu.slider(Vehicle_Collision_Reaction, "推开强度", { "veh_collision_reaction_push_away" }, "",
    0, 1000, 50, 10, function(value)
        vehicle_collision_reaction.push_away_strength = value
    end)
menu.toggle(Vehicle_Collision_Reaction, "推开", {}, "", function(toggle)
    vehicle_collision_reaction.push_away = toggle
end)
menu.slider(Vehicle_Collision_Reaction, "上天高度", { "veh_collision_reaction_launch" }, "",
    0, 1000, 10, 10, function(value)
        vehicle_collision_reaction.launch_height = value
    end)
menu.toggle(Vehicle_Collision_Reaction, "发射上天", {}, "", function(toggle)
    vehicle_collision_reaction.launch = toggle
end)




----------------------
-- 运兵直升机连接
----------------------
local Cargobob_Pickup = menu.list(Fun_options, "运兵直升机连接", {}, "")

local cargobob_model_list = {
    util.joaat("cargobob"),
    util.joaat("cargobob2"),
    util.joaat("cargobob3"),
    util.joaat("cargobob4")
}

local function get_player_cargobob()
    local ped = players.user_ped()
    if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
        local veh = PED.GET_VEHICLE_PED_IS_IN(ped, false)
        local hash = ENTITY.GET_ENTITY_MODEL(veh)
        if isInTable(cargobob_model_list, hash) then
            return veh
        end
    end
    return 0
end

-- get the closest vehicle to the player (exclude player current vehicle)
local function get_closest_vehicle_to_player(radius)
    local ped = players.user_ped()
    local current_veh = GET_VEHICLE_PED_IS_IN(ped)
    local coords = ENTITY.GET_ENTITY_COORDS(ped)

    radius = radius or 999999.0
    local closest_disance = 999999.0
    local entity = 0
    for k, veh in pairs(entities.get_all_vehicles_as_handles()) do
        if veh ~= current_veh then
            local pos = ENTITY.GET_ENTITY_COORDS(veh)
            local distance = v3.distance(coords, pos)
            if distance <= radius then
                if distance < closest_disance then
                    closest_disance = distance
                    entity = veh
                end
            end
        end
    end
    return entity
end


local cargobob_pickup_setting = {
    draw_line = true,
    radius = 30,
    bone = -1,
    x = 0.0,
    y = 0.0,
    z = -1.0,
}

menu.toggle_loop(Cargobob_Pickup, "连接最近的载具[H键]", {}, "进入运兵直升机后,按H键连接距离最近的载具",
    function()
        local cargobob = get_player_cargobob()
        if cargobob ~= 0 then
            local ent = VEHICLE.GET_ENTITY_ATTACHED_TO_CARGOBOB(cargobob)
            if not ENTITY.DOES_ENTITY_EXIST(ent) then
                local veh = get_closest_vehicle_to_player(cargobob_pickup_setting.radius)
                if ENTITY.DOES_ENTITY_EXIST(veh) then
                    if cargobob_pickup_setting.draw_line then
                        local player_pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
                        DRAW_LINE(player_pos, ENTITY.GET_ENTITY_COORDS(veh))
                    end

                    if PAD.IS_CONTROL_JUST_RELEASED(2, 104) then -- INPUT_VEH_SHUFFLE
                        if not RequestControl(veh) then
                            util.toast("未能成功控制载具")
                        end

                        VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(veh, 5.0)

                        if not VEHICLE.DOES_CARGOBOB_HAVE_PICK_UP_ROPE(cargobob) then
                            VEHICLE.CREATE_PICK_UP_ROPE_FOR_CARGOBOB(cargobob, 0)
                        end

                        ENTITY.SET_PICK_UP_BY_CARGOBOB_DISABLED(veh, false)

                        if not VEHICLE.CAN_CARGOBOB_PICK_UP_ENTITY(cargobob, veh) then
                            util.toast("无法吊起")
                        end

                        VEHICLE.ATTACH_VEHICLE_TO_CARGOBOB(cargobob, veh, cargobob_pickup_setting.bone,
                            cargobob_pickup_setting.x, cargobob_pickup_setting.y, cargobob_pickup_setting.z)
                    end
                end
            end
        end
    end)

menu.action(Cargobob_Pickup, "强制分离连接的载具", {}, "", function()
    local cargobob = get_player_cargobob()
    if cargobob ~= 0 then
        local ent = VEHICLE.GET_ENTITY_ATTACHED_TO_CARGOBOB(cargobob)
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            VEHICLE.SET_CARGOBOB_FORCE_DONT_DETACH_VEHICLE(cargobob, false)
            VEHICLE.DETACH_ENTITY_FROM_CARGOBOB(cargobob, ent)
        end
    end
end)
menu.toggle(Cargobob_Pickup, "强制无法分离载具", {}, "即使按E也无法分离连接的载具", function(toggle)
    local cargobob = get_player_cargobob()
    if cargobob ~= 0 then
        VEHICLE.SET_CARGOBOB_FORCE_DONT_DETACH_VEHICLE(cargobob, toggle)
    end
end)


menu.divider(Cargobob_Pickup, "设置")
menu.toggle(Cargobob_Pickup, "连线指示", {}, "", function(toggle)
    cargobob_pickup_setting.draw_line = toggle
end, true)
menu.slider(Cargobob_Pickup, "范围半径", { "cargobob_pickup_radius" }, "获取最近距离载具的范围",
    0, 10000, 30, 5,
    function(value)
        cargobob_pickup_setting.radius = value
    end)
menu.slider(Cargobob_Pickup, "Bone Index", { "cargobob_pickup_bone" }, "", -1, 16777216, -1, 1, function(value)
    cargobob_pickup_setting.bone = value
end)
menu.slider_float(Cargobob_Pickup, "Offset X", { "cargobob_pickup_x" }, "", -10000, 10000, 0, 10, function(value)
    cargobob_pickup_setting.x = value * 0.01
end)
menu.slider_float(Cargobob_Pickup, "Offset Y", { "cargobob_pickup_y" }, "", -10000, 10000, 0, 10, function(value)
    cargobob_pickup_setting.y = value * 0.01
end)
menu.slider_float(Cargobob_Pickup, "Offset Z", { "cargobob_pickup_z" }, "", -10000, 10000, -100, 10, function(value)
    cargobob_pickup_setting.z = value * 0.01
end)







----------------
menu.action(Fun_options, "在动画中摧毁载具", { "explode_veh_cutscence" }, "当前载具或上一辆载具",
    function()
        local vehicle = entities.get_user_vehicle_as_handle()
        if vehicle ~= 0 then
            RequestControl(vehicle)
            VEHICLE.EXPLODE_VEHICLE_IN_CUTSCENE(vehicle)
        end
    end)
menu.action(Fun_options, "在动画中摧毁所有载具", { "explode_all_veh_cutscence" }, "排除个人载具",
    function()
        for _, vehicle in pairs(entities.get_all_vehicles_as_handles()) do
            if vehicle ~= entities.get_user_personal_vehicle_as_handle() then
                RequestControl(vehicle)
                VEHICLE.EXPLODE_VEHICLE_IN_CUTSCENE(vehicle)
            end
        end
    end)
