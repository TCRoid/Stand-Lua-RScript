--------------------------------
------------ 娱乐选项 ------------
--------------------------------

local Fun_options = menu.list(menu.my_root(), "娱乐选项", {}, "")




----------------------
-- 玩家受到伤害时
----------------------
local Player_Damage = menu.list(Fun_options, "玩家受到伤害时", {}, "")

local player_damage = {
    eventData = memory.alloc(13 * 8),
    screenX = memory.alloc(8),
    screenY = memory.alloc(8),
    bonePtr = memory.alloc(4),

    number = {
        enable = false,


        duration = 3000, -- ms
        text_scale = 0.8,
        text_colour = Colors.red,
        -- 显示位置
        pos_select = 1,
        text_x = 0.5,
        text_y = 0.5,
    },

    attacker = {
        enable = false,

        toggle = {
            exclude_player = true,
            dead = false,
            explosion = false,
            owned_explosion = false,
            shoot_head = false,
            fire = false,
            remove_weapon = false,
        },
    },
}

function player_damage.to_screen_coords(coords)
    local x, y = 0, 0
    if GRAPHICS.GET_SCREEN_COORD_FROM_WORLD_COORD(coords.x, coords.y, coords.z,
            player_damage.screenX, player_damage.screenY) then
        x = memory.read_float(player_damage.screenX)
        y = memory.read_float(player_damage.screenY)
    end
    return x, y
end

function player_damage.draw_damage_number(text, eventData)
    local duration = player_damage.number.duration / 1000
    local text_colour = player_damage.number.text_colour
    local scale = player_damage.number.text_scale

    local x, y = player_damage.number.text_x, player_damage.number.text_y
    if player_damage.number.pos_select == 2 then
        if PED.GET_PED_LAST_DAMAGE_BONE(players.user_ped(), player_damage.bonePtr) then
            local boneId = memory.read_byte(player_damage.bonePtr)
            local bone_coords = PED.GET_PED_BONE_COORDS(players.user_ped(), boneId, 0.0, 0.0, 0.0)
            x, y = player_damage.to_screen_coords(bone_coords)
        else
            x, y = player_damage.to_screen_coords(ENTITY.GET_ENTITY_COORDS(players.user_ped()))
        end
    end

    util.create_tick_handler(function()
        local delta_time = MISC.GET_FRAME_TIME()

        local alpha = math.min(1, duration)
        directx.draw_text(x, y, text, ALIGN_CENTRE, scale,
            { r = text_colour.r, g = text_colour.g, b = text_colour.b, a = text_colour.a * alpha }, false)

        y = y - 0.002
        duration = duration - delta_time * 2
        if duration <= 0 then
            return false
        end
    end)
end

function player_damage.attacker_reaction(attacker, eventData)
    local toggle = player_damage.attacker.toggle

    -- 排除玩家
    if toggle.exclude_player and IS_PED_PLAYER(attacker) then
    else
        -- 死亡
        if toggle.dead then
            ENTITY.SET_ENTITY_HEALTH(attacker, 0)
        end
        -- 匿名爆炸
        if toggle.explosion then
            local pos = ENTITY.GET_ENTITY_COORDS(attacker)
            add_explosion(pos, 4)
        end
        -- 署名爆炸
        if toggle.owned_explosion then
            local pos = ENTITY.GET_ENTITY_COORDS(attacker)
            add_owned_explosion(players.user_ped(), pos, 4)
        end
        -- 爆头击杀
        if toggle.shoot_head then
            shoot_ped_head(attacker, util.joaat("WEAPON_PISTOL"))
        end
        -- 燃烧
        if toggle.fire then
            FIRE.START_ENTITY_FIRE(attacker)
        end
        -- 移除武器
        if toggle.remove_weapon then
            WEAPON.REMOVE_ALL_PED_WEAPONS(attacker)
        end
    end
end

menu.toggle_loop(Player_Damage, "开启", {}, "仅在线上模式才有效\n需要关闭无敌", function()
    if IS_IN_SESSION() then
        for eventIndex = 0, SCRIPT.GET_NUMBER_OF_EVENTS(1) - 1 do
            local eventType = SCRIPT.GET_EVENT_AT_INDEX(1, eventIndex)
            if eventType == 186 then -- CEventNetworkEntityDamage
                if SCRIPT.GET_EVENT_DATA(1, eventIndex, player_damage.eventData, 13) then
                    local eventData = {}
                    eventData.Victim = memory.read_int(player_damage.eventData)           -- entity
                    eventData.Attacker = memory.read_int(player_damage.eventData + 1 * 8) -- entity
                    eventData.Damage = memory.read_float(player_damage.eventData + 2 * 8) -- float
                    -- eventData.EnduranceDamage = memory.read_float(player_damage.eventData + 3 * 8)   -- float
                    -- eventData.VictimIncapacitated = memory.read_int(player_damage.eventData + 4 * 8) -- bool
                    eventData.VictimDestroyed = memory.read_int(player_damage.eventData + 5 * 8) -- bool
                    eventData.WeaponHash = memory.read_int(player_damage.eventData + 6 * 8)      -- int
                    -- eventData.VictimSpeed = memory.read_float(player_damage.eventData + 7 * 8)             -- float
                    -- eventData.AttackerSpeed = memory.read_float(player_damage.eventData + 8 * 8)           -- float
                    -- eventData.IsResponsibleForCollision = memory.read_int(player_damage.eventData + 9 * 8) -- bool
                    -- eventData.IsHeadShot = memory.read_int(player_damage.eventData + 10 * 8)               -- bool
                    -- eventData.IsWithMeleeWeapon = memory.read_int(player_damage.eventData + 11 * 8)        -- bool
                    -- eventData.HitMaterial = memory.read_int(player_damage.eventData + 12 * 8)              -- int


                    -- 受害者为玩家
                    if eventData.Victim == players.user_ped() then
                        -- 伤害数值显示
                        if player_damage.number.enable then
                            player_damage.draw_damage_number(round(eventData.Damage, 2), eventData)
                        end

                        -- 攻击者反应
                        if player_damage.attacker.enable and eventData.Attacker ~= players.user_ped() then
                            player_damage.attacker_reaction(eventData.Attacker, eventData)
                        end
                    end
                end
            end
        end
    end
end)

menu.divider(Player_Damage, "选项")


----- 伤害数值显示  -----
menu.toggle(Player_Damage, "伤害数值显示", {}, "", function(toggle)
    player_damage.number.enable = toggle
end)

local Player_Damage_Number = menu.list(Player_Damage, "伤害数值显示设置", {}, "")

menu.slider(Player_Damage_Number, "显示时长(毫秒)", { "player_damage_number_duration" }, "",
    500, 10000, 3000, 500, function(value)
        player_damage.number.duration = value
    end)
menu.slider_float(Player_Damage_Number, "文字大小", { "player_damage_number_text_scale" }, "",
    1, 1000, 70, 5, function(value)
        player_damage.number.text_scale = value * 0.01
    end)
menu.colour(Player_Damage_Number, "文字颜色", { "player_damage_number_text_colour" }, "",
    Colors.red, true, function(value)
        player_damage.number.text_colour = value
    end)

menu.list_select(Player_Damage_Number, "位置", {}, "", {
    { "固定位置" }, { "受到伤害的位置", {}, "玩家位置" }
}, 1, function(value)
    player_damage.number.pos_select = value
end)
menu.slider_float(Player_Damage_Number, "固定位置 X", { "player_damage_number_text_x" }, "",
    0, 100, 50, 1, function(value)
        player_damage.number.text_x = value * 0.01
    end)
menu.slider_float(Player_Damage_Number, "固定位置 Y", { "player_damage_number_text_y" }, "",
    0, 100, 50, 1, function(value)
        player_damage.number.text_y = value * 0.01
    end)

menu.action(Player_Damage_Number, "测试效果", {}, "", function()
    player_damage.draw_damage_number(math.random(0, 100))
end)


----- 攻击者反应 -----
menu.toggle(Player_Damage, "攻击者反应", {}, "", function(toggle)
    player_damage.attacker.enable = toggle
end)

local Player_Damage_Attacker = menu.list(Player_Damage, "攻击者反应设置", {}, "")

menu.toggle(Player_Damage_Attacker, "排除玩家", {}, "", function(toggle)
    player_damage.attacker.toggle.exclude_player = toggle
end, true)
menu.toggle(Player_Damage_Attacker, "死亡", {}, "", function(toggle)
    player_damage.attacker.toggle.dead = toggle
end)
menu.toggle(Player_Damage_Attacker, "匿名爆炸", {}, "", function(toggle)
    player_damage.attacker.toggle.explosion = toggle
end)
menu.toggle(Player_Damage_Attacker, "署名爆炸", {}, "", function(toggle)
    player_damage.attacker.toggle.owned_explosion = toggle
end)
menu.toggle(Player_Damage_Attacker, "爆头击杀", {}, "", function(toggle)
    player_damage.attacker.toggle.shoot_head = toggle
end)
menu.toggle(Player_Damage_Attacker, "燃烧", {}, "", function(toggle)
    player_damage.attacker.toggle.fire = toggle
end)
menu.toggle(Player_Damage_Attacker, "移除武器", {}, "", function(toggle)
    player_damage.attacker.toggle.remove_weapon = toggle
end)




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
            ----- 击杀者 -----
            local ent = PED.GET_PED_SOURCE_OF_DEATH(player_ped)
            if IS_AN_ENTITY(ent) and ent ~= player_ped then
                -- 排除玩家
                if self_death_reaction.killer.exclude_player and IS_PED_PLAYER(ent) then
                else
                    local pos = ENTITY.GET_ENTITY_COORDS(ent)
                    -- 爆炸
                    if self_death_reaction.killer.explosion then
                        util.create_thread(function()
                            for i = 1, self_death_reaction.killer.explosion, 1 do
                                local coords = ENTITY.GET_ENTITY_COORDS(ent)
                                add_owned_explosion(player_ped, coords, 4)
                                util.yield(300)
                            end
                        end)
                    end
                    -- 坠落爆炸
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
                    -- RPG轰炸
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
                    -- 死亡
                    if self_death_reaction.killer.dead then
                        ENTITY.SET_ENTITY_HEALTH(ent, 0)
                    end
                    -- 冻结
                    if self_death_reaction.killer.freeze then
                        ENTITY.FREEZE_ENTITY_POSITION(ent, true)
                    end
                    -- 燃烧
                    if self_death_reaction.killer.fire then
                        FIRE.START_ENTITY_FIRE(ent)
                    end
                    -- 标记点
                    if self_death_reaction.killer.blip then
                        local blip = add_blip_for_entity(ent, 303, 1)
                        table.insert(self_death_reaction.killer.blip_list, blip)
                    end
                end
            end


            ----- 死亡位置 -----
            local dead_pos = ENTITY.GET_ENTITY_COORDS(player_ped)

            -- 爆炸
            if self_death_reaction.position.explosion > 0 then
                util.create_thread(function()
                    for i = 1, self_death_reaction.position.explosion, 1 do
                        add_owned_explosion(player_ped, dead_pos, 4)
                        util.yield(300)
                    end
                end)
            end
            -- 标记点
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
                        -- 请求控制
                        RequestControl(vehicle)
                        -- 破坏引擎
                        if vehicle_collision_reaction.kill_engine then
                            VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, -4000)
                        end
                        -- 爆胎
                        if vehicle_collision_reaction.burst_tyre then
                            for i = 0, 5 do
                                if not VEHICLE.IS_VEHICLE_TYRE_BURST(vehicle, i, true) then
                                    VEHICLE.SET_VEHICLE_TYRE_BURST(vehicle, i, true, 1000.0)
                                end
                            end
                        end
                        -- 推开
                        if vehicle_collision_reaction.push_away then
                            local force = ENTITY.GET_ENTITY_COORDS(vehicle)
                            v3.sub(force, ENTITY.GET_ENTITY_COORDS(player_veh))
                            v3.normalise(force)
                            v3.mul(force, vehicle_collision_reaction.push_away_strength)
                            ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 3, force.x, force.y, force.z,
                                0, 0, 0.5, 0,
                                false, false, true, false, false)
                        end
                        -- 发射上天
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
        if vehicle ~= INVALID_GUID then
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
