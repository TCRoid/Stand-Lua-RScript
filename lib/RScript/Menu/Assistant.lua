------------------------------------------
--          Assistant Options
------------------------------------------


local Assistant_Options <const> = menu.list(Menu_Root, "助手选项", {}, "")


--#region Draw Ped Box

local Draw_Ped_Box <const> = menu.list(Assistant_Options, "绘制NPC盒子", {}, "[PvE Helper]")

local draw_ped_box = {
    ped_select = 1,
    exclude_vehicle = true,
    radius = 200.0,
    line_height = 1.0,
    box_colour = { r = 255, g = 0, b = 255, a = 220 },
    line_colour = { r = 255, g = 0, b = 255, a = 255 },
}

function draw_ped_box.check_ped(ped)
    if not ENTITY.IS_ENTITY_ON_SCREEN(ped) or not ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(players.user_ped(), ped, 17) then
        return false
    end

    if ENTITY.IS_ENTITY_DEAD(ped) or is_player_ped(ped) then
        return false
    end

    if draw_ped_box.exclude_vehicle and PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
        return false
    end

    if draw_ped_box.ped_select == 1 and is_friendly_ped(ped) then
        return false
    end

    if draw_ped_box.ped_select == 2 and not is_hostile_ped(ped) then
        return false
    end

    return true
end

menu.toggle_loop(Draw_Ped_Box, "绘制NPC头部盒子", {}, "", function()
    for _, ped in pairs(entities.get_all_peds_as_handles()) do
        if draw_ped_box.check_ped(ped) then
            local head_pos = PED.GET_PED_BONE_COORDS(ped, 0x322c, 0, 0, 0)
            -- offsetX: up/down, offsetY: forward/backward, offsetZ: left/right

            if v3.distance(head_pos, ENTITY.GET_ENTITY_COORDS(players.user_ped())) <= draw_ped_box.radius then
                local rot = ENTITY.GET_ENTITY_ROTATION(ped, 2)
                local dimensions = v3(0.22, 0.28, 0.25)
                util.draw_box(head_pos, rot, dimensions,
                    draw_ped_box.box_colour.r, draw_ped_box.box_colour.g, draw_ped_box.box_colour.b,
                    draw_ped_box.box_colour.a)


                local line_pos = PED.GET_PED_BONE_COORDS(ped, 0x322c, draw_ped_box.line_height, 0, 0)
                if PED.IS_PED_HURT(ped) then -- ground behaviour
                    line_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 0.0, draw_ped_box.line_height)
                end
                DRAW_LINE(head_pos, line_pos, draw_ped_box.line_colour)
            end
        end
    end
end)

menu.divider(Draw_Ped_Box, "设置")
menu.list_select(Draw_Ped_Box, "NPC类型", {}, "", {
    { 1, "全部NPC(排除友好)", {}, "" },
    { 2, "敌对NPC", {}, "" },
    { 3, "全部NPC", {}, "" },
}, 1, function(value)
    draw_ped_box.ped_select = value
end)
menu.toggle(Draw_Ped_Box, "排除载具内NPC", {}, "", function(toggle)
    draw_ped_box.exclude_vehicle = toggle
end, true)
menu.slider_float(Draw_Ped_Box, "范围", { "draw_ped_box_radius" }, "",
    1000, 500000, 20000, 5000, function(value)
        draw_ped_box.radius = value * 0.01
    end)
menu.slider_float(Draw_Ped_Box, "指示线高度", { "draw_ped_box_line_height" }, "",
    10, 1000, 100, 10, function(value)
        draw_ped_box.line_height = value * 0.01
    end)
menu.colour(Draw_Ped_Box, "指示线颜色", { "draw_ped_box_line_colour" }, "",
    to_stand_colour(draw_ped_box.line_colour), true, function(colour)
        draw_ped_box.line_colour = to_rage_colour(colour)
    end)
menu.colour(Draw_Ped_Box, "盒子颜色", { "draw_ped_box_colour" }, "",
    to_stand_colour(draw_ped_box.box_colour), true, function(colour)
        draw_ped_box.box_colour = to_rage_colour(colour)
    end)

--#endregion


--#region Nearby Road

local Nearby_Road <const> = menu.list(Assistant_Options, "附近街道生成载具", {}, "")

local nearby_road = {
    nodeType = 0,
    random_radius = 100.0,
    godmode = true,
    strong = true,
    flash_blip = false,
    num = 1,
}

menu.list_select(Nearby_Road, "生成地点", {}, "", {
    { 1, "主要道路" }, { 2, "任意地面" }, { 3, "水 (船)" }, { 4, "随机" },
}, 1, function(value)
    nearby_road.nodeType = value - 1
end)
menu.slider_float(Nearby_Road, "随机范围", { "nearby_road_random_radius" }, "",
    0, 50000, 10000, 500, function(value)
        nearby_road.random_radius = value * 0.01
    end)

menu.toggle(Nearby_Road, "生成载具: 无敌", {}, "", function(toggle)
    nearby_road.godmode = toggle
end, true)
menu.toggle(Nearby_Road, "生成载具: 强化", {}, "", function(toggle)
    nearby_road.strong = toggle
end, true)
menu.toggle(Nearby_Road, "生成载具: 闪烁标记点", {}, "", function(toggle)
    nearby_road.flash_blip = toggle
end)
menu.slider(Nearby_Road, "生成载具数量", { "nearby_road_random_num" }, "",
    1, 20, 1, 1, function(value)
        nearby_road.num = value
    end)

menu.divider(Nearby_Road, "载具列表")

for _, data in pairs(RS_T.CommonVehicles) do
    local name = "生成 " .. data.name
    local hash = util.joaat(data.model)
    menu.action(Nearby_Road, name, {}, data.help_text, function()
        local num = 0
        request_model(hash)

        for i = 1, nearby_road.num do
            local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
            local bool, coords, heading = false, pos, 0

            if nearby_road.nodeType == 3 then
                bool, coords = get_random_vehicle_node(pos, nearby_road.random_radius)
            else
                bool, coords, heading = get_closest_vehicle_node(pos, nearby_road.nodeType)
            end

            if bool then
                local vehicle = entities.create_vehicle(hash, coords, heading)
                if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
                    SET_VEHICLE_ON_GROUND_PROPERLY(vehicle)
                    SET_VEHICLE_ENGINE_ON(vehicle, true)
                    VEHICLE.SET_VEHICLE_DIRT_LEVEL(vehicle, 0.0)
                    VEHICLE.SET_VEHICLE_HAS_BEEN_OWNED_BY_PLAYER(vehicle, true)

                    upgrade_vehicle(vehicle)
                    if nearby_road.godmode then
                        set_entity_godmode(vehicle, true)
                    end
                    if nearby_road.strong then
                        strong_vehicle(vehicle)
                    end
                    if nearby_road.flash_blip then
                        util.create_thread(function()
                            local blip = HUD.ADD_BLIP_FOR_ENTITY(vehicle)
                            HUD.SET_BLIP_SPRITE(blip, 225)
                            HUD.SET_BLIP_COLOUR(blip, 27)
                            util.yield(5000)
                            util.remove_blip(blip)
                        end)
                    end

                    num = num + 1
                end
            end
        end

        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
        util.toast("完成！\n生成数量: " .. num)
    end)
end

--#endregion


--#region Cargobob Pickup

local Cargobob_Pickup <const> = menu.list(Assistant_Options, "运兵直升机连接", {}, "")

local cargobob_pickup = {
    model_list = {
        util.joaat("cargobob"),
        util.joaat("cargobob2"),
        util.joaat("cargobob3"),
        util.joaat("cargobob4")
    },
    draw_line = true,
    radius = 30,
    bone = -1,
    x = 0.0,
    y = 0.0,
    z = -1.0,
}

function cargobob_pickup.get_player_cargobob()
    local ped = players.user_ped()
    if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
        local veh = PED.GET_VEHICLE_PED_IS_IN(ped, false)
        local hash = ENTITY.GET_ENTITY_MODEL(veh)
        if is_in_table(cargobob_pickup.model_list, hash) then
            return veh
        end
    end
    return 0
end

function cargobob_pickup.get_closest_vehicle(radius)
    local ped = players.user_ped()
    local current_veh = GET_VEHICLE_PED_IS_IN(ped)
    local coords = ENTITY.GET_ENTITY_COORDS(ped)

    radius = radius or 9999.0
    local closest_disance = 9999.0
    local entity = 0
    for _, veh in pairs(entities.get_all_vehicles_as_handles()) do
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

menu.toggle_loop(Cargobob_Pickup, "连接最近的载具[H键]", {}, "进入运兵直升机后,按H键连接距离最近的载具",
    function()
        local cargobob = cargobob_pickup.get_player_cargobob()
        if cargobob ~= 0 then
            local ent = VEHICLE.GET_ENTITY_ATTACHED_TO_CARGOBOB(cargobob)
            if not ENTITY.DOES_ENTITY_EXIST(ent) then
                local veh = cargobob_pickup.get_closest_vehicle(cargobob_pickup.radius)
                if ENTITY.DOES_ENTITY_EXIST(veh) then
                    if cargobob_pickup.draw_line then
                        draw_line_to_entity(veh)
                    end

                    if PAD.IS_CONTROL_JUST_RELEASED(2, 104) then --INPUT_VEH_SHUFFLE
                        if not request_control(veh) then
                            util.toast("未能成功控制载具,请重试")
                        end

                        SET_VEHICLE_ON_GROUND_PROPERLY(veh)

                        if not VEHICLE.DOES_CARGOBOB_HAVE_PICK_UP_ROPE(cargobob) then
                            VEHICLE.CREATE_PICK_UP_ROPE_FOR_CARGOBOB(cargobob, 0)
                        end

                        ENTITY.SET_PICK_UP_BY_CARGOBOB_DISABLED(veh, false)

                        if not VEHICLE.CAN_CARGOBOB_PICK_UP_ENTITY(cargobob, veh) then
                            util.toast("无法吊起")
                        end

                        VEHICLE.ATTACH_VEHICLE_TO_CARGOBOB(cargobob, veh,
                            cargobob_pickup.bone,
                            cargobob_pickup.x, cargobob_pickup.y, cargobob_pickup.z)
                    end
                end
            end
        end
    end)

menu.action(Cargobob_Pickup, "强制分离连接的载具", {}, "", function()
    local cargobob = cargobob_pickup.get_player_cargobob()
    if cargobob ~= 0 then
        local ent = VEHICLE.GET_ENTITY_ATTACHED_TO_CARGOBOB(cargobob)
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            VEHICLE.SET_CARGOBOB_FORCE_DONT_DETACH_VEHICLE(cargobob, false)
            VEHICLE.DETACH_ENTITY_FROM_CARGOBOB(cargobob, ent)
        end
    end
end)
menu.toggle(Cargobob_Pickup, "强制无法分离载具", {}, "即使按E也无法分离连接的载具", function(toggle)
    local cargobob = cargobob_pickup.get_player_cargobob()
    if cargobob ~= 0 then
        VEHICLE.SET_CARGOBOB_FORCE_DONT_DETACH_VEHICLE(cargobob, toggle)
    end
end)


menu.divider(Cargobob_Pickup, "设置")
menu.toggle(Cargobob_Pickup, "连线指示", {}, "", function(toggle)
    cargobob_pickup.draw_line = toggle
end, true)
menu.slider_float(Cargobob_Pickup, "范围半径", { "cargobob_pickup_radius" }, "获取最近距离载具的范围",
    0, 100000, 3000, 500, function(value)
        cargobob_pickup.radius = value * 0.01
    end)
menu.slider(Cargobob_Pickup, "Bone Index", { "cargobob_pickup_bone" }, "", -1, 16777216, -1, 1, function(value)
    cargobob_pickup.bone = value
end)
menu.slider_float(Cargobob_Pickup, "Offset X", { "cargobob_pickup_x" }, "", -10000, 10000, 0, 10, function(value)
    cargobob_pickup.x = value * 0.01
end)
menu.slider_float(Cargobob_Pickup, "Offset Y", { "cargobob_pickup_y" }, "", -10000, 10000, 0, 10, function(value)
    cargobob_pickup.y = value * 0.01
end)
menu.slider_float(Cargobob_Pickup, "Offset Z", { "cargobob_pickup_z" }, "", -10000, 10000, -100, 10, function(value)
    cargobob_pickup.z = value * 0.01
end)

--#endregion


--#region Attacked Response

local Attacked_Response <const> = menu.list(Assistant_Options, "玩家受到攻击时反应", {}, "")

local AttackedResponse = {
    reactionType = 1,
    pedReactionType = 1,
    vehicleReactionType = 1,
}

function AttackedResponse.checkAttacker(attacker, isKiller)
    if AttackedResponse.reactionType == 2 and not isKiller then
        return false
    end

    if not ENTITY.DOES_ENTITY_EXIST(attacker) or ENTITY.IS_ENTITY_DEAD(attacker) then
        return false
    end

    return true
end

function AttackedResponse.attackerReaction(attacker)
    if ENTITY.IS_ENTITY_A_PED(attacker) then
        AttackedResponse.pedReaction(attacker)
        return
    end

    if ENTITY.IS_ENTITY_A_VEHICLE(attacker) then
        AttackedResponse.vehicleReaction(attacker)
        return
    end
end

function AttackedResponse.pedReaction(attacker)
    if is_player_ped(attacker) then
        return
    end

    local reactionType = AttackedResponse.pedReactionType

    -- 禁用
    if reactionType == 0 then
        return
    end

    -- 死亡
    if reactionType == 1 then
        SET_ENTITY_HEALTH(attacker, 0)
        return
    end
    -- 爆头击杀
    if reactionType == 2 then
        shoot_ped_head(attacker, util.joaat("WEAPON_PISTOL"), players.user_ped())
        return
    end
    -- 署名爆炸
    if reactionType == 3 then
        local pos = ENTITY.GET_ENTITY_COORDS(attacker)
        add_owned_explosion(players.user_ped(), pos, 4)
        return
    end
    -- 匿名爆炸
    if reactionType == 4 then
        local pos = ENTITY.GET_ENTITY_COORDS(attacker)
        add_explosion(pos, 4)
        return
    end
    -- 燃烧
    if reactionType == 5 then
        FIRE.START_ENTITY_FIRE(attacker)
        return
    end
    -- 电击
    if reactionType == 6 then
        shoot_ped_head(attacker, util.joaat("WEAPON_STUNGUN"), players.user_ped())
        return
    end
    -- 移除武器
    if reactionType == 7 then
        WEAPON.REMOVE_ALL_PED_WEAPONS(attacker)
        return
    end
end

function AttackedResponse.vehicleReaction(attacker)
    local reactionType = AttackedResponse.vehicleReactionType

    -- 禁用
    if reactionType == 0 then
        return
    end

    notify("AttackedResponse.vehicleReaction")

    -- 破坏引擎
    if reactionType == 1 then
        VEHICLE.SET_VEHICLE_ENGINE_HEALTH(attacker, -4000.0)
        return
    end
    -- 爆胎
    if reactionType == 2 then
        for i = 0, 7 do
            VEHICLE.SET_VEHICLE_TYRE_BURST(attacker, i, true, 1000.0)
        end
        return
    end
    -- 卸下车轮
    if reactionType == 3 then
        for i = 0, 7 do
            entities.detach_wheel(attacker, i)
        end
        return
    end
end

local playerAttackedEventData = memory.alloc(13 * 8)

menu.toggle_loop(Attacked_Response, "玩家受到攻击时反应", {}, "仅在线上模式可用并且需要关闭无敌", function()
    local eventData = playerAttackedEventData
    local eventGroup = 1 -- SCRIPT_EVENT_QUEUE_NETWORK
    for eventIndex = 0, SCRIPT.GET_NUMBER_OF_EVENTS(eventGroup) - 1 do
        local eventType = SCRIPT.GET_EVENT_AT_INDEX(eventGroup, eventIndex)
        if eventType == 186 then                                    -- CEventNetworkEntityDamage
            if SCRIPT.GET_EVENT_DATA(eventGroup, eventIndex, eventData, 13) then
                local Victim = memory.read_int(eventData)           -- entity
                local Attacker = memory.read_int(eventData + 1 * 8) -- entity
                -- local Damage = memory.read_float(eventData + 2 * 8) -- float
                -- local EnduranceDamage = memory.read_float(eventData + 3 * 8)         -- float
                -- local VictimIncapacitated = memory.read_int(eventData + 4 * 8)       -- bool
                local VictimDestroyed = memory.read_int(eventData + 5 * 8) -- bool
                -- local WeaponHash = memory.read_int(eventData + 6 * 8)                -- int
                -- local VictimSpeed = memory.read_float(eventData + 7 * 8)             -- float
                -- local AttackerSpeed = memory.read_float(eventData + 8 * 8)           -- float
                -- local IsResponsibleForCollision = memory.read_int(eventData + 9 * 8) -- bool
                -- local IsHeadShot = memory.read_int(eventData + 10 * 8)               -- bool
                -- local IsWithMeleeWeapon = memory.read_int(eventData + 11 * 8)        -- bool
                -- local HitMaterial = memory.read_int(eventData + 12 * 8)              -- int

                if Victim == players.user_ped() and Attacker ~= players.user_ped() then
                    if AttackedResponse.checkAttacker(Attacker, VictimDestroyed) then
                        AttackedResponse.attackerReaction(Attacker)
                    end
                end
            end
        end
    end
end)

menu.divider(Attacked_Response, "选项")

menu.list_select(Attacked_Response, "反应对象", {}, "", {
    { 1, "攻击者", {}, "" },
    { 2, "仅击杀者", {}, "" }
}, 1, function(value)
    AttackedResponse.reactionType = value
end)

menu.list_select(Attacked_Response, "对 NPC 的反应", {}, "", {
    { 0, "禁用" },
    { 1, "死亡" },
    { 2, "爆头击杀" },
    { 3, "署名爆炸" },
    { 4, "匿名爆炸" },
    { 5, "燃烧" },
    { 6, "电击" },
    { 7, "移除武器" },
}, 1, function(value)
    AttackedResponse.pedReactionType = value
end)

menu.list_select(Attacked_Response, "对 载具 的反应", {}, "", {
    { 0, "禁用" },
    { 1, "破坏引擎" },
    { 2, "爆胎" },
    { 3, "卸下车轮" },
}, 1, function(value)
    AttackedResponse.vehicleReactionType = value
end)

--#endregion
