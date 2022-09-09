--- Author: Rostal
--- Last edit date: 2022/9/9

util.require_natives("1660775568")

---------------------------------------
--------------- Functions -------------
---------------------------------------

-- 请求模型
-- 1) requests all the given models
-- 2) waits till all of them have been loaded
function requestModels(...)
    local arg = { ... }
    for _, model in ipairs(arg) do
        if not STREAMING.IS_MODEL_VALID(model) then
            error("tried to request an invalid model")
        end
        STREAMING.REQUEST_MODEL(model)
        while not STREAMING.HAS_MODEL_LOADED(model) do
            util.yield()
        end
    end
end

-- 请求控制实体
function RequestControl(entity, tick)
    if tick == nil then
        tick = 20
    end
    local i = 0
    while not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity) and i <= tick do
        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
        i = i + 1
        util.yield(100)
    end
    return NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity)
end

-- 判断ped是否为玩家
function IS_PED_PLAYER(Ped)
    if PED.GET_PED_TYPE(Ped) >= 4 then
        return false
    else
        return true
    end
end

-- 判断是否为玩家载具
function IS_PLAYER_VEHICLE(Vehicle)
    if Vehicle == entities.get_user_vehicle_as_handle() or Vehicle == entities.get_user_personal_vehicle_as_handle() then
        return true
    elseif not VEHICLE.IS_VEHICLE_SEAT_FREE(Vehicle, -1, false) then
        local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(Vehicle, -1)
        if ped then
            if IS_PED_PLAYER(ped) then
                return true
            end
        end
    end
    return false
end

----- 玩家自身的传送 -----
function TELEPORT(X, Y, Z)
    local p = players.user_ped()
    if PED.IS_PED_IN_ANY_VEHICLE(p, false) then
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(p, false)
        ENTITY.SET_ENTITY_COORDS(vehicle, X, Y, Z)
    else
        ENTITY.SET_ENTITY_COORDS(p, X, Y, Z)
    end
end

function TP_TO_ME(ent, x, y, z)
    if x == nil then
        x = 0.0
    end
    if y == nil then
        y = 0.0
    end
    if z == nil then
        z = 0.0
    end
    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), x, y, z)
    ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
end

function TP_TO_ENTITY(ent, x, y, z)
    if x == nil then
        x = 0.0
    end
    if y == nil then
        y = 0.0
    end
    if z == nil then
        z = 0.0
    end
    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, x, y, z)
    ENTITY.SET_ENTITY_COORDS(players.user_ped(), coords.x, coords.y, coords.z, true, false, false, false)
end

-- TP into driver seat
---@param ent Entity
---@param door string
---@param driver string
--- "delete": delete door, "open": open door ;
--- "tp": tp driver out, "delete": delete driver ;
function TP_INTO_VEHICLE(ent, door, driver)
    if ENTITY.IS_ENTITY_A_VEHICLE(ent) then
        --unlock doors
        VEHICLE.SET_VEHICLE_DOORS_LOCKED(ent, 1)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(ent, false)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_PLAYER(ent, players.user(), false)
        --driver
        if not VEHICLE.IS_VEHICLE_SEAT_FREE(ent, -1, false) then
            local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ent, -1)
            if ped then
                if driver == "tp" then
                    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, 0.0, 5.0, 3.0)
                    ENTITY.SET_ENTITY_COORDS(ped, coords.x, coords.y, coords.z, true, false, false, false)
                elseif driver == "delete" then
                    entities.delete_by_handle(ped)
                end
            end
        end
        --tp into
        VEHICLE.SET_VEHICLE_ENGINE_ON(ent, true, true, false)
        PED.SET_PED_INTO_VEHICLE(players.user_ped(), ent, -1)
        --door
        if door == "delete" then
            VEHICLE.SET_VEHICLE_DOOR_BROKEN(ent, 0, true)
        elseif door == "open" then
            VEHICLE.SET_VEHICLE_DOOR_OPEN(ent, 0, false, false)
        end

    end
end

--------- END ---------

---@param set_ent Entity
---@param to_ent Entity
---@param angle float
--- 要设置的实体，要朝向的实体，角度差
function SET_ENTITY_HEAD_TO_ENTITY(set_ent, to_ent, angle)
    if angle == nil then
        angle = 0.0
    end
    local Head = ENTITY.GET_ENTITY_HEADING(to_ent)
    ENTITY.SET_ENTITY_HEADING(set_ent, Head + angle)
end

---@param tp_ent Entity
---@param to_ent Entity
---@param x float
---@param y float
---@param z float
--- 要传送的实体，传送到实体，左/右，前/后，上/下
function TP_ENTITY_TO_ENTITY(tp_ent, to_ent, x, y, z)
    if x == nil then
        x = 0.0
    end
    if y == nil then
        y = 0.0
    end
    if z == nil then
        z = 0.0
    end
    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(to_ent, x, y, z)
    ENTITY.SET_ENTITY_COORDS(tp_ent, coords.x, coords.y, coords.z, true, false, false, false)
end

vect = {
    ['new'] = function(x, y, z)
        return { ['x'] = x, ['y'] = y, ['z'] = z }
    end,
    ['subtract'] = function(a, b)
        return vect.new(a.x - b.x, a.y - b.y, a.z - b.z)
    end,
    ['add'] = function(a, b)
        return vect.new(a.x + b.x, a.y + b.y, a.z + b.z)
    end,
    ['mag'] = function(a)
        return math.sqrt(a.x ^ 2 + a.y ^ 2 + a.z ^ 2)
    end,
    ['norm'] = function(a)
        local mag = vect.mag(a)
        return vect.div(a, mag)
    end,
    ['mult'] = function(a, b)
        return vect.new(a.x * b, a.y * b, a.z * b)
    end,
    ['div'] = function(a, b)
        return vect.new(a.x / b, a.y / b, a.z / b)
    end,
    ['dist'] = function(a, b)
        --returns the distance between two vectors
        return vect.mag(vect.subtract(a, b))
    end
}

color = {
    ["purple"] = {
        ["r"] = 1.0,
        ["g"] = 0.0,
        ["b"] = 1.0,
        ["a"] = 1.0
    }
}

---@return Colour
function get_random_colour()
    local colour = { a = 255 }
    colour.r = math.random(0, 255)
    colour.g = math.random(0, 255)
    colour.b = math.random(0, 255)
    return colour
end

---@param num number
---@param places integer
---@return number
function round(num, places)
    return tonumber(string.format('%.' .. (places or 0) .. 'f', num))
end

-- returns a list of nearby vehicles given player Id
function GET_NEARBY_VEHICLES(pid, radius)
    local vehicles = {}
    local p = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
    local pos = ENTITY.GET_ENTITY_COORDS(p)
    local v = PED.GET_VEHICLE_PED_IS_IN(p, false)
    for k, vehicle in pairs(entities.get_all_vehicles_as_handles()) do
        local veh_pos = ENTITY.GET_ENTITY_COORDS(vehicle)
        if vehicle ~= v and vect.dist(pos, veh_pos) <= radius then
            table.insert(vehicles, vehicle)
        end
    end
    return vehicles
end

-- returns a list of nearby peds given player Id
function GET_NEARBY_PEDS(pid, radius)
    local peds = {}
    local p = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
    local pos = ENTITY.GET_ENTITY_COORDS(p)
    for k, ped in pairs(entities.get_all_peds_as_handles()) do
        if ped ~= p then
            local ped_pos = ENTITY.GET_ENTITY_COORDS(ped)
            if vect.dist(pos, ped_pos) <= radius then
                table.insert(peds, ped)
            end
        end
    end
    return peds
end

-- 返回正在瞄准的实体
function GetEntity_PlayerIsAimingAt(p)
    local ent
    if PLAYER.IS_PLAYER_FREE_AIMING(p) then
        local ptr = memory.alloc_int()
        if PLAYER.GET_ENTITY_PLAYER_IS_FREE_AIMING_AT(p, ptr) then
            ent = memory.read_int(ptr)
        end
        memory.free(ptr)
        if ENTITY.IS_ENTITY_A_PED(ent) and PED.IS_PED_IN_ANY_VEHICLE(ent) then
            local vehicle = PED.GET_VEHICLE_PED_IS_IN(ent, false)
            ent = vehicle
        end
    end
    return ent
end

-- 通过Model Hash寻找实体
function GetEntity_ByModelHash(Type, isMission, ...)
    local all_entity
    Type = string.lower(Type)
    if Type == "ped" then
        all_entity = entities.get_all_peds_as_handles()
    elseif Type == "vehicle" then
        all_entity = entities.get_all_vehicles_as_handles()
    elseif Type == "object" then
        all_entity = entities.get_all_objects_as_handles()
    elseif Type == "pickup" then
        all_entity = entities.get_all_pickups_as_handles()
    end

    local entity_list = {}
    local arg = { ... } --Hash list

    for k, ent in pairs(all_entity) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        for _, Hash in ipairs(arg) do
            if EntityHash == Hash then
                if isMission then
                    if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
                        table.insert(entity_list, ent)
                    end
                else
                    table.insert(entity_list, ent)
                end
            end
        end
    end

    return entity_list
end

-- 为实体添加地图标记
function AddBlip_ForEntity(entity, blipSprite, colour)
    local blip = HUD.ADD_BLIP_FOR_ENTITY(entity)
    HUD.SET_BLIP_SPRITE(blip, blipSprite)
    HUD.SET_BLIP_COLOUR(blip, colour)
    HUD.SHOW_HEIGHT_ON_BLIP(blip, false)
    util.create_tick_handler(function()
        if ENTITY.DOES_ENTITY_EXIST(entity) and not ENTITY.IS_ENTITY_DEAD(entity) then
            local heading = ENTITY.GET_ENTITY_HEADING(entity)
            HUD.SET_BLIP_ROTATION(blip, round(heading))
        elseif not HUD.DOES_BLIP_EXIST(blip) then
            return false
        else
            util.remove_blip(blip)
            return false
        end
    end)
    return blip
end

-- 返回实体信息的数组
local EntityInfo_List_MAX_SIZE = 18
function GetEntityInfo_List(ent)
    if ent ~= nil and ENTITY.DOES_ENTITY_EXIST(ent) then
        local entityinfo = {}
        local t = ""

        --ModelName
        local model_name = util.reverse_joaat(ENTITY.GET_ENTITY_MODEL(ent))
        if model_name == "" or model_name == nil then
            t = "Model Name: None"
        else
            t = "Model Name: " .. model_name
        end
        table.insert(entityinfo, t)

        --Hash
        t = "Model Hash: " .. ENTITY.GET_ENTITY_MODEL(ent)
        table.insert(entityinfo, t)

        --Type
        local entity_types = { "No entity", "Ped", "Vehicle", "Object" }
        local entity_type = entity_types[ENTITY.GET_ENTITY_TYPE(ent) + 1]
        if ENTITY.GET_ENTITY_TYPE(ent) == 3 then
            --object
            if OBJECT.IS_OBJECT_A_PICKUP(ent) or OBJECT.IS_OBJECT_A_PORTABLE_PICKUP(ent) then
                entity_type = "Pickup"
            end
        end
        t = "Entity Type: " .. entity_type
        table.insert(entityinfo, t)

        --MissionEntity
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            t = "Mission Entity: True"
        else
            t = "Mission Entity: False"
        end
        table.insert(entityinfo, t)

        --Attached
        if ENTITY.IS_ENTITY_ATTACHED(ent) then
            t = "Entity Attached: True"
            table.insert(entityinfo, t)

            local attached_entity = ENTITY.GET_ENTITY_ATTACHED_TO(ent)
            t = "Attached Entity Model Hash: " .. ENTITY.GET_ENTITY_MODEL(attached_entity)
            table.insert(entityinfo, t)
        else
            t = "Entity Attached: False"
            table.insert(entityinfo, t)
        end

        --Health
        t = "Entity Health: " .. ENTITY.GET_ENTITY_HEALTH(ent)
        table.insert(entityinfo, t)

        --Dead
        if ENTITY.IS_ENTITY_DEAD(ent) then
            t = "Entity Dead: True"
            table.insert(entityinfo, t)
        end

        --Position
        local pos = ENTITY.GET_ENTITY_COORDS(ent)
        t = "Coords X : " .. pos.x
        table.insert(entityinfo, t)
        t = "Coords Y : " .. pos.y
        table.insert(entityinfo, t)
        t = "Coords Z : " .. pos.z
        table.insert(entityinfo, t)

        --Heading
        t = "Entity Heading: " .. ENTITY.GET_ENTITY_HEADING(ent)
        table.insert(entityinfo, t)
        t = "Your Heading: " .. ENTITY.GET_ENTITY_HEADING(players.user_ped())
        table.insert(entityinfo, t)

        --Distance
        local my_pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        local ent_pos = ENTITY.GET_ENTITY_COORDS(ent)
        t = "Distance: " .. vect.dist(my_pos, ent_pos)
        table.insert(entityinfo, t)

        --Diffierence with your position
        local pos_sub = vect.subtract(my_pos, ent_pos)
        t = "Subtract X: " ..
            string.format("%.2f", pos_sub.x) ..
            ", Y: " .. string.format("%.2f", pos_sub.y) .. ", Z: " .. string.format("%.2f", pos_sub.z)
        table.insert(entityinfo, t)

        --Speed
        t = "Entity Speed: " .. ENTITY.GET_ENTITY_SPEED(ent)
        table.insert(entityinfo, t)

        --Blip
        local blip = HUD.GET_BLIP_FROM_ENTITY(ent)
        if blip > 0 then
            local blip_id = HUD.GET_BLIP_SPRITE(blip)
            t = "Blip Sprite ID: " .. blip_id
            table.insert(entityinfo, t)

            local blip_colour = HUD.GET_BLIP_COLOUR(blip)
            t = "Blip Colour: " .. blip_colour
            table.insert(entityinfo, t)
        end

        return entityinfo
    end
end

-- 在屏幕上显示实体信息
isShowing_onScreen = false
function ShowEntityInfo_OnScreen(ent)
    util.create_tick_handler(function()
        if isShowing_onScreen and ENTITY.DOES_ENTITY_EXIST(ent) then
            local entity_info_list = GetEntityInfo_List(ent)
            local text = ""
            for k, info in pairs(entity_info_list) do
                if info ~= nil then
                    text = text .. info .. "\n"
                end
            end
            directx.draw_text(0.5, 0.0, text, ALIGN_TOP_LEFT, 0.8, color.purple)
        elseif isShowing_onScreen and not ENTITY.DOES_ENTITY_EXIST(ent) then
            util.toast("该实体已经不存在")
            return false
        else
            return false
        end
    end)
end

-- 遍历数组 判断某值是否在表中
function isInTable(tbl, value)
    for k, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

-- 根据值清空对应的元素（非删除操作）
function clearTableValue(tbl, value)
    for k, v in pairs(tbl) do
        if v == value then
            tbl[k] = nil
        end
    end
end

------------------------------------------
--------- Entity Control Functions -------
---------------- START -------------------

-- 无敌强化NPC
function control_ped_enhanced(ped)
    ENTITY.SET_ENTITY_INVINCIBLE(ped, true)
    ENTITY.SET_ENTITY_PROOFS(ped, true, true, true, true, true, true, true, true)
    PED.SET_PED_CAN_RAGDOLL(ped, false)

    PED.SET_PED_HIGHLY_PERCEPTIVE(ped, true)
    PED.SET_PED_VISUAL_FIELD_PERIPHERAL_RANGE(ped, 500.0)
    PED.SET_PED_SEEING_RANGE(ped, 500.0)
    PED.SET_PED_HEARING_RANGE(ped, 500.0)

    WEAPON.SET_PED_INFINITE_AMMO_CLIP(ped, true)
    PED.SET_PED_SHOOT_RATE(ped, 1000.0)
    PED.SET_PED_ACCURACY(ped, 100.0)

    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 0, true) --CanUseCover
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 1, true) --CanUseVehicles
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 2, true) --CanDoDrivebys
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 5, true) --AlwaysFight
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 12, true) --BlindFireWhenInCover
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 13, true) --Aggressive
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 20, true) --CanTauntInVehicle
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 21, true) --CanChaseTargetOnFoot
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 27, true) --PerfectAccuracy
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 41, true) --CanCommandeerVehicles
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true) --CanFightArmedPedsWhenNotArmed

    PED.SET_PED_COMBAT_MOVEMENT(ped, 2)
    PED.SET_PED_COMBAT_ABILITY(ped, 2)
    PED.SET_PED_COMBAT_RANGE(ped, 2)
    PED.SET_PED_TARGET_LOSS_RESPONSE(ped, 1)
    PED.SET_COMBAT_FLOAT(ped, 10, 500.0)
end

-- 创建对应实体的menu操作
--- All entity type ---
function entity_control_all(menu_parent, ent)
    menu.divider(menu_parent, "Entity")

    menu_ShowEntityInfo = menu.toggle(menu_parent, "显示实体信息", {}, "", function(toggle)
        if toggle then
            if not isShowing_onScreen then
                isShowing_onScreen = true
                ShowEntityInfo_OnScreen(ent)
            else
                util.toast("正在显示其它的实体信息")
                menu.set_value(menu_ShowEntityInfo, false) --not working
            end
        else
            if isShowing_onScreen then
                isShowing_onScreen = false
            end
        end
    end)
    menu.action(menu_parent, "复制实体信息", {}, "", function()
        local text = ""
        for k, info in pairs(GetEntityInfo_List(ent)) do
            if info ~= nil then
                text = text .. info .. "\n"
            end
        end
        util.copy_to_clipboard(text, false)
        util.toast("完成")
    end)

    menu.toggle(menu_parent, "无敌", {}, "", function(toggle)
        ENTITY.SET_ENTITY_INVINCIBLE(ent, toggle)
        ENTITY.SET_ENTITY_PROOFS(ent, toggle, toggle, toggle, toggle, toggle, toggle, toggle, toggle)
    end)
    menu.toggle(menu_parent, "冻结", {}, "", function(toggle)
        ENTITY.FREEZE_ENTITY_POSITION(ent, toggle)
    end)
    menu.toggle(menu_parent, "燃烧", {}, "", function(toggle)
        if toggle then
            FIRE.START_ENTITY_FIRE(ent)
        else
            FIRE.STOP_ENTITY_FIRE(ent)
        end
    end)
    menu.toggle(menu_parent, "添加地图标记", {}, "", function(toggle)
        if toggle then
            local blip = HUD.GET_BLIP_FROM_ENTITY(ent)
            --no blip
            if blip == 0 then
                local color = 27
                --ped combat
                if ENTITY.IS_ENTITY_A_PED(ent) then
                    if PED.IS_PED_IN_COMBAT(ent, players.user_ped()) then
                        color = 1
                    end
                end
                --vehicle combat
                if ENTITY.IS_ENTITY_A_VEHICLE(ent) then
                    local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ent, -1)
                    if ped then
                        if PED.IS_PED_IN_COMBAT(ped, players.user_ped()) then
                            color = 1
                        end
                    end
                end
                --
                blip = HUD.ADD_BLIP_FOR_ENTITY(ent)
                HUD.SET_BLIP_COLOUR(blip, color)
                util.create_tick_handler(function()
                    if not toggle then
                        return false
                    elseif ENTITY.DOES_ENTITY_EXIST(ent) and not ENTITY.IS_ENTITY_DEAD(ent) then
                        local heading = ENTITY.GET_ENTITY_HEADING(ent)
                        HUD.SET_BLIP_ROTATION(blip, round(heading))
                    elseif not HUD.DOES_BLIP_EXIST(blip) then
                        return false
                    else
                        util.remove_blip(blip)
                        return false
                    end
                end)
            end
        else
            local blip = HUD.GET_BLIP_FROM_ENTITY(ent)
            if blip > 0 then
                util.remove_blip(blip)
            end
        end
    end)
    menu.click_slider(menu_parent, "请求控制实体", { "request_control_ent" }, "发送请求控制的次数", 1, 100
        , 20, 1, function(value)
        if RequestControl(ent, value) then
            util.toast("请求控制成功！")
        else
            util.toast("请求控制失败")
        end
    end)
    ----
    menu.divider(menu_parent, "血量")
    menu.action(menu_parent, "获取当前血量", {}, "", function()
        util.toast("当前血量: " .. ENTITY.GET_ENTITY_HEALTH(ent))
    end)
    local control_ent_health = 1000
    menu.slider(menu_parent, "血量", { "control_ent_health" }, "", 0, 100000, 1000, 100, function(value)
        control_ent_health = value
    end)
    menu.action(menu_parent, "设置血量", {}, "", function()
        ENTITY.SET_ENTITY_HEALTH(ent, control_ent_health)
    end)
    ----
    menu.divider(menu_parent, "传送")
    menu.action(menu_parent, "传送到实体", {}, "", function()
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, 0.0, 0.0, 0.0)
        ENTITY.SET_ENTITY_COORDS(players.user_ped(), coords.x, coords.y, coords.z, true, false, false, false)
    end)

    menu.click_slider(menu_parent, "传送到我前/后", {}, "", -50.0, 50.0, 2.0, 1.0, function(value)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0.0, value, 0.0)
        ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
    end)
    menu.click_slider(menu_parent, "传送到我上/下", {}, "", -50.0, 50.0, 2.0, 1.0, function(value)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0.0, 0.0, value)
        ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
    end)
    menu.click_slider(menu_parent, "传送到我左/右", {}, "", -50.0, 50.0, 2.0, 1.0, function(value)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), value, 0.0, 0.0)
        ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
    end)

    menu.toggle_loop(menu_parent, "锁定传送在我头上", {}, "", function()
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0.0, 0.0, 2.0)
        ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
    end)
    ----
    menu.divider(menu_parent, "移动")
    menu.click_slider(menu_parent, "前/后移动", {}, "", -100.0, 100.0, 0.0, 1.0, function(value)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, 0.0, value, 0.0)
        ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
    end)
    menu.click_slider(menu_parent, "左/右移动", {}, "", -100.0, 100.0, 0.0, 1.0, function(value)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, value, 0.0, 0.0)
        ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
    end)
    menu.click_slider(menu_parent, "上/下移动", {}, "", -100.0, 100.0, 0.0, 1.0, function(value)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, 0.0, 0.0, value)
        ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
    end)

    menu.click_slider(menu_parent, "朝向", {}, "", -360, 360, 0, 10, function(value)
        local head = ENTITY.GET_ENTITY_HEADING(ent)
        ENTITY.SET_ENTITY_HEADING(ent, head + value)
    end)
    ----
    menu.click_slider(menu_parent, "设置最大速度", { "control_ent_max_speed" }, "", 0.0, 1000.0, 0.0, 10.0,
        function(value)
            ENTITY.SET_ENTITY_MAX_SPEED(ent, value)
        end)

    menu.action(menu_parent, "爆炸", {}, "", function()
        local pos = ENTITY.GET_ENTITY_COORDS(ent)
        FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z - 0.5, EXP_TAG_STICKYBOMB, 5.0, true, false, 0, false)
    end)

    menu.toggle(menu_parent, "设置为任务实体", {}, "避免实体被自动清理", function(toggle)
        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ent, toggle, toggle)
    end)
end

--- Ped entity type ---
function entity_control_ped(menu_parent, ped)
    menu.divider(menu_parent, "Ped")

    menu.action(menu_parent, "传送到我的载具", {}, "", function()
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
        if vehicle then
            if VEHICLE.ARE_ANY_VEHICLE_SEATS_FREE(vehicle) then
                PED.SET_PED_INTO_VEHICLE(ped, vehicle, -2)
            end
        end
    end)

    menu.action(menu_parent, "移除全部武器", {}, "", function()
        WEAPON.REMOVE_ALL_PED_WEAPONS(ped)
    end)

    local weapon_list = {
        "微型冲锋枪", "特质卡宾步枪", "突击霰弹枪", "火神机枪", "火箭筒", "电磁步枪"
    }
    local weapon_list_model = {
        "WEAPON_MICROSMG", "WEAPON_SPECIALCARBINE", "WEAPON_ASSAULTSHOTGUN", "WEAPON_MINIGUN", "WEAPON_RPG",
        "WEAPON_RAILGUN"
    }
    menu.action_slider(menu_parent, "给予武器", {}, "", weapon_list, function(value)
        local weaponHash = util.joaat(weapon_list_model[value])
        WEAPON.GIVE_WEAPON_TO_PED(ped, weaponHash, -1, false, true)
        WEAPON.SET_CURRENT_PED_WEAPON(ped, weaponHash, false)
    end)

    menu.divider(menu_parent, "作战能力")
    menu.action(menu_parent, "一键无敌强化NPC", {}, "适用于友方NPC", function()
        control_ped_enhanced(ped)
        util.toast("Done!")
    end)
    menu.click_slider(menu_parent, "射击频率", {}, "", 0, 1000, 100, 10, function(value)
        PED.SET_PED_SHOOT_RATE(ped, value)
    end)
    menu.click_slider(menu_parent, "精准度", {}, "", 0, 100, 50, 10, function(value)
        PED.SET_PED_ACCURACY(ped, value)
    end)
    menu.slider_text(menu_parent, "战斗能力", {}, "", { "Poor", "Average", "Professional", "NumTypes" },
        function(index)
            local eCombatAbility = {
                CA_Poor,
                CA_Average,
                CA_Professional,
                CA_NumTypes
            }
            PED.SET_PED_COMBAT_ABILITY(ped, eCombatAbility[index])
        end)
    menu.slider_text(menu_parent, "战斗范围", {}, "", { "Near", "Medium", "Far", "VeryFar", "NumRanges" },
        function(index)
            local eCombatRange = {
                CR_Near,
                CR_Medium,
                CR_Far,
                CR_VeryFar,
                CR_NumRanges
            }
            PED.SET_PED_COMBAT_RANGE(ped, eCombatRange[index])
        end)
    menu.slider_text(menu_parent, "战斗走位", {}, "", { "Stationary", "Defensive", "WillAdvance", "WillRetreat" },
        function(index)
            local eCombatMovement = {
                CM_Stationary,
                CM_Defensive,
                CM_WillAdvance,
                CM_WillRetreat
            }
            PED.SET_PED_COMBAT_MOVEMENT(ped, eCombatMovement[index])
        end)
end

--- Vehicle entity type ---
function entity_control_vehicle(menu_parent, vehicle)
    menu.divider(menu_parent, "Vehicle")

    menu.action(menu_parent, "传送到载具内", {}, "", function()
        if VEHICLE.ARE_ANY_VEHICLE_SEATS_FREE(vehicle) then
            PED.SET_PED_INTO_VEHICLE(players.user_ped(), vehicle, -2)
        end
    end)

    menu.action(menu_parent, "传送到载具驾驶位（强制）", {}, "会踢出原座位的NPC", function()
        if VEHICLE.IS_VEHICLE_SEAT_FREE(vehicle, -1, false) then
            PED.SET_PED_INTO_VEHICLE(players.user_ped(), vehicle, -1)
        else
            local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
            if ped then
                local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(vehicle, 0.0, 5.0, 3.0)
                ENTITY.SET_ENTITY_COORDS(ped, coords.x, coords.y, coords.z, true, false, false, false)
                PED.SET_PED_INTO_VEHICLE(players.user_ped(), vehicle, -1)
            end
        end
    end)

    menu.action(menu_parent, "传送到载具副驾驶位（强制）", {}, "会踢出原座位的NPC", function()
        if VEHICLE.GET_VEHICLE_NUMBER_OF_PASSENGERS(vehicle, true, false) > 1 then
            if VEHICLE.IS_VEHICLE_SEAT_FREE(vehicle, 0, false) then
                PED.SET_PED_INTO_VEHICLE(players.user_ped(), vehicle, 0)
            else
                local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, 0)
                if ped then
                    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(vehicle, 0.0, 5.0, 3.0)
                    ENTITY.SET_ENTITY_COORDS(ped, coords.x, coords.y, coords.z, true, false, false, false)
                    PED.SET_PED_INTO_VEHICLE(players.user_ped(), vehicle, 0)
                end
            end
        end
    end)

    menu.click_slider(menu_parent, "向前加速", { "control_veh_forward_speed" }, "", 0.0, 1000.0, 30.0, 10.0,
        function(value)
            VEHICLE.SET_VEHICLE_FORWARD_SPEED(vehicle, value)
        end)

    menu.action(menu_parent, "修复载具", {}, "", function()
        VEHICLE.SET_VEHICLE_FIXED(vehicle)
        VEHICLE.SET_VEHICLE_DEFORMATION_FIXED(vehicle)
        VEHICLE.SET_VEHICLE_DIRT_LEVEL(vehicle, 0.0)
        VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, 1000.0)
    end)

    menu.action(menu_parent, "拆下所有车门", {}, "", function()
        for i = 0, 3 do
            VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, i, false)
        end
    end)

    menu.toggle(menu_parent, "车门开关", {}, "", function(toggle)
        if toggle then
            for i = 0, 3 do
                VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, i, false, false)
            end
        else
            VEHICLE.SET_VEHICLE_DOORS_SHUT(vehicle, false)
        end
    end)

    menu.toggle(menu_parent, "车门锁", {}, "", function(toggle)
        if toggle then
            VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle, 2)
        else
            VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle, 1)
            VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_PLAYER(vehicle, players.user(), false)
            VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(vehicle, false)
        end
    end)

    menu.toggle(menu_parent, "爆胎", {}, "", function(toggle)
        if toggle then
            for i = 0, 5 do
                VEHICLE.SET_VEHICLE_TYRE_BURST(vehicle, i, true, 1000.0)
            end
        else
            for i = 0, 3 do
                VEHICLE.SET_VEHICLE_TYRE_FIXED(vehicle, i)
            end
        end
    end)

end

--- All Entities Control ---
function all_entities_control(menu_parent, entity_list)
    menu.toggle(menu_parent, "无敌", {}, "", function(toggle)
        for k, ent in pairs(entity_list) do
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                ENTITY.SET_ENTITY_INVINCIBLE(ent, toggle)
                ENTITY.SET_ENTITY_PROOFS(ent, toggle, toggle, toggle, toggle, toggle, toggle, toggle, toggle)
            end
        end
        util.toast("Done!")
    end)
    menu.toggle(menu_parent, "冻结", {}, "", function(toggle)
        for k, ent in pairs(entity_list) do
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                ENTITY.FREEZE_ENTITY_POSITION(ent, toggle)
            end
        end
        util.toast("Done!")
    end)
    menu.toggle(menu_parent, "燃烧", {}, "", function(toggle)
        for k, ent in pairs(entity_list) do
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                if toggle then
                    FIRE.START_ENTITY_FIRE(ent)
                else
                    FIRE.STOP_ENTITY_FIRE(ent)
                end
            end
        end
        util.toast("Done!")
    end)
    menu.action(menu_parent, "爆炸", {}, "", function()
        for k, ent in pairs(entity_list) do
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                local pos = ENTITY.GET_ENTITY_COORDS(ent)
                FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z - 0.5, EXP_TAG_STICKYBOMB, 5.0, true, false, 0.0, false)
            end
        end
        util.toast("Done!")
    end)
    menu.click_slider(menu_parent, "请求控制实体", { "request_control_ent" }, "发送请求控制的次数", 1, 100
        , 20, 1, function(value)
        local success_num = 0
        local fail_num = 0
        for k, ent in pairs(entity_list) do
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                if RequestControl(ent, value) then
                    success_num = success_num + 1
                else
                    fail_num = fail_num + 1
                end
            end
        end
        util.toast("Done!\nSuccess : " .. success_num .. "\nFail : " .. fail_num)
    end)

    -----
    menu.divider(menu_parent, "传送到我")
    local entity_list_tp_delay = 1500
    menu.slider(menu_parent, "传送延时", {}, "单位：ms", 0, 5000, 1500, 100, function(value)
        entity_list_tp_delay = value
    end)
    menu.click_slider(menu_parent, "传送到我 前/后", {}, "", -50.0, 50.0, 2.0, 1.0, function(value)
        for k, ent in pairs(entity_list) do
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0.0, value, 0.0)
                ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
                util.yield(entity_list_tp_delay)
            end
        end
        util.toast("Done!")
    end)
    menu.click_slider(menu_parent, "传送到我 上/下", {}, "", -50.0, 50.0, 2.0, 1.0, function(value)
        for k, ent in pairs(entity_list) do
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0.0, 0.0, value)
                ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
                util.yield(entity_list_tp_delay)
            end
        end
        util.toast("Done!")
    end)
    menu.click_slider(menu_parent, "传送到我 左/右", {}, "", -50.0, 50.0, 2.0, 1.0, function(value)
        for k, ent in pairs(entity_list) do
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), value, 0.0, 0.0)
                ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
                util.yield(entity_list_tp_delay)
            end
        end
        util.toast("Done!")
    end)
    ----
    menu.divider(menu_parent, "移动")
    menu.click_slider(menu_parent, "前/后 移动", {}, "", -100.0, 100.0, 0.0, 1.0, function(value)
        for k, ent in pairs(entity_list) do
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, 0.0, value, 0.0)
                ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
            end
        end
        util.toast("Done!")
    end)
    menu.click_slider(menu_parent, "上/下 移动", {}, "", -100.0, 100.0, 0.0, 1.0, function(value)
        for k, ent in pairs(entity_list) do
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, 0.0, 0.0, value)
                ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
            end
        end
        util.toast("Done!")
    end)
    menu.click_slider(menu_parent, "左/右 移动", {}, "", -100.0, 100.0, 0.0, 1.0, function(value)
        for k, ent in pairs(entity_list) do
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, value, 0.0, 0.0)
                ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
            end
        end
        util.toast("Done!")
    end)

end

----------------- END --------------------
-------- Entity Control Functions --------
------------------------------------------



------ Nearby Entity Functions ------
--
-- Vehicle
--
control_nearby_vehicles_toggles = {
    --Trolling
    explosion = false,
    broken_door = false,
    open_door = false,
    kill_engine = false,
    burst_tyre = false,
    full_dirt = false,
    remove_window = false,
    leave_vehicle = false,
    forward_speed = false,
    --Friendly
    godmode = false,
    fix_vehicle = false,
    fix_engine = false,
    fix_tyre = false,
    clean_dirt = false,
}
control_nearby_vehicles_data = {
    forward_speed = 30,
}
control_nearby_vehicles_setting = {
    radius = 30.0,
    time_delay = 10,
}

is_Control_nearby_vehicles = false
function control_nearby_vehicles()
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
            --排除玩家载具
            if not IS_PLAYER_VEHICLE(vehicle) then
                --请求控制
                RequestControl(vehicle)
                --爆炸
                if control_nearby_vehicles_toggles.explosion then
                    local pos = ENTITY.GET_ENTITY_COORDS(vehicle)
                    FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, EXP_TAG_STICKYBOMB, 10.0, true, false, 0, false)
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
                        VEHICLE.SET_VEHICLE_TYRE_BURST(vehicle, i, true, 1000.0)
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
                    if ped then
                        TASK.TASK_LEAVE_VEHICLE(ped, vehicle, 4160)
                    end
                end
                --向前加速
                if control_nearby_vehicles_toggles.forward_speed then
                    VEHICLE.SET_VEHICLE_FORWARD_SPEED(vehicle, control_nearby_vehicles_data.forward_speed)
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

                util.yield(control_nearby_vehicles_setting.time_delay)
                ----
            end
        end

    end)
end

--
-- Ped
--
control_nearby_peds_toggles = {
    --Trolling
    force_forward = false
}
control_nearby_peds_data = {
    forward_degree = 30
}
control_nearby_peds_setting = {
    radius = 30.0,
    time_delay = 10,
    exclude_ped_in_vehicle = true
}

is_Control_nearby_peds = false
function control_nearby_peds()
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
            --排除玩家
            if not IS_PED_PLAYER(ped) then
                --排除载具内NPC
                if control_nearby_peds_setting.exclude_ped_in_vehicle and PED.IS_PED_IN_ANY_VEHICLE(ped, true) then
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

                    util.yield(control_nearby_peds_setting.time_delay)
                    ----
                end
            end
        end

    end)
end

---------------- END ----------------


--- STAT Functions ---
function MP_INDEX()
    return "MP" .. util.get_char_slot() .. "_"
end

function IS_MPPLY(Stat)
    if string.find(Stat, "MPPLY_") or string.find(Stat, "MP_") then
        return true
    else
        return false
    end
end

function STAT_SET_INT(Stat, Value)
    if IS_MPPLY(Stat) then
        STATS.STAT_SET_INT(util.joaat(Stat), Value, true)
    else
        STATS.STAT_SET_INT(util.joaat(MP_INDEX() .. Stat), Value, true)
    end
end

function STAT_SET_FLOAT(Stat, Value)
    if string.find(Stat, "MPPLY_") or string.find(Stat, "MP_") then
        STATS.STAT_SET_FLOAT(util.joaat(Stat), Value, true)
    else
        STATS.STAT_SET_FLOAT(util.joaat(MP_INDEX() .. Stat), Value, true)
    end
end

function STAT_SET_BOOL(Stat, Value)
    if string.find(Stat, "MPPLY_") or string.find(Stat, "MP_") then
        STATS.STAT_SET_BOOL(util.joaat(Stat), Value, true)
    else
        STATS.STAT_SET_BOOL(util.joaat(MP_INDEX() .. Stat), Value, true)
    end
end

function STAT_SET_INCREMENT(Stat, Value)
    if string.find(Stat, "MPPLY_") or string.find(Stat, "MP_") then
        STATS.STAT_INCREMENT(util.joaat(Stat), Value, true)
    else
        STATS.STAT_INCREMENT(util.joaat(MP_INDEX() .. Stat), Value, true)
    end
end

function STAT_GET_INT(Stat)
    local IntPTR = memory.alloc(4)

    if string.find(Stat, "MPPLY_") or string.find(Stat, "MP_") then
        STATS.STAT_GET_INT(util.joaat(Stat), IntPTR, -1)
    else
        STATS.STAT_GET_INT(util.joaat(MP_INDEX() .. Stat), IntPTR, -1)
    end

    return memory.read_int(IntPTR)
end

function STAT_GET_FLOAT(Stat)
    local FloatPTR = memory.alloc(4)

    if string.find(Stat, "MPPLY_") or string.find(Stat, "MP_") then
        STATS.STAT_GET_FLOAT(util.joaat(Stat), FloatPTR, -1)
    else
        STATS.STAT_GET_FLOAT(util.joaat(MP_INDEX() .. Stat), FloatPTR, -1)
    end

    return tonumber(string.format("%.3f", memory.read_float(FloatPTR)))
end

function STAT_GET_BOOL(Stat)
    local BoolPTR = memory.alloc(1)

    if string.find(Stat, "MPPLY_") or string.find(Stat, "MP_") then
        STATS.STAT_GET_BOOL(util.joaat(Stat), BoolPTR, -1)
    else
        STATS.STAT_GET_BOOL(util.joaat(MP_INDEX() .. Stat), BoolPTR, -1)
    end

    if memory.read_byte(BoolPTR) == 1 then
        return "true"
    else
        return "false"
    end
end

--- GLOBAL Functions ---
function SET_INT_GLOBAL(Global, Value)
    memory.write_int(memory.script_global(Global), Value)
end

function SET_FLOAT_GLOBAL(Global, Value)
    memory.write_float(memory.script_global(Global), Value)
end

-- GET
function GET_INT_GLOBAL(Global)
    return memory.read_int(memory.script_global(Global))
end

function GET_FLOAT_GLOBAL(Global)
    return memory.read_float(memory.script_global(Global))
end

--- LOCAL Functions ---
function SET_INT_LOCAL(Script, Local, Value)
    if memory.script_local(Script, Local) ~= 0 then
        memory.write_int(memory.script_local(Script, Local), Value)
    end
end

function SET_FLOAT_LOCAL(Script, Local, Value)
    if memory.script_local(Script, Local) ~= 0 then
        memory.write_float(memory.script_local(Script, Local), Value)
    end
end

-- GET
function GET_INT_LOCAL(Script, Local)
    if memory.script_local(Script, Local) ~= 0 then
        local Value = memory.read_int(memory.script_local(Script, Local))
        if Value ~= nil then
            return Value
        end
    end
end

function GET_FLOAT_LOCAL(Script, Local)
    if memory.script_local(Script, Local) ~= 0 then
        local Value = memory.read_float(memory.script_local(Script, Local))
        if Value ~= nil then
            return Value
        end
    end
end

----------------- END -----------------
-------------- Functions --------------
---------------------------------------

--
util.keep_running()
menu.divider(menu.my_root(), "RScript")

--------------------------------
------------ 自我选项 ------------
--------------------------------
local Self_options = menu.list(menu.my_root(), "自我选项", {}, "")

-------------------
--- 自定义血量护甲 ---
-------------------
local Self_Custom_options = menu.list(Self_options, "自定义血量护甲", {}, "")

--- 自定义最大生命值 ---
menu.divider(Self_Custom_options, "Health")

local defaultHealth = ENTITY.GET_ENTITY_MAX_HEALTH(PLAYER.PLAYER_PED_ID())
local moddedHealth = defaultHealth
menu.slider(Self_Custom_options, "自定义最大生命值", { "setmaxhealth" }, "生命值将被修改为指定的数值"
    , 50, 100000, defaultHealth, 50, function(value)
    moddedHealth = value
end)

menu.toggle_loop(Self_Custom_options, "开启", {}, "改变你的最大生命值。一些菜单会将你标记为作弊者。当它被禁用时，它会返回到默认的最大生命值。"
    , function()
        if PED.GET_PED_MAX_HEALTH(PLAYER.PLAYER_PED_ID()) ~= moddedHealth then
            PED.SET_PED_MAX_HEALTH(PLAYER.PLAYER_PED_ID(), moddedHealth)
            ENTITY.SET_ENTITY_HEALTH(PLAYER.PLAYER_PED_ID(), moddedHealth)
        end
    end, function()
    PED.SET_PED_MAX_HEALTH(PLAYER.PLAYER_PED_ID(), defaultHealth)
    ENTITY.SET_ENTITY_HEALTH(PLAYER.PLAYER_PED_ID(), defaultHealth)
end)

--- 自定义最大护甲 ---
menu.divider(Self_Custom_options, "Armour")

local defaultArmour = PLAYER.GET_PLAYER_MAX_ARMOUR(PLAYER.PLAYER_ID())
local moddedArmour = defaultArmour
menu.slider(Self_Custom_options, "自定义最大护甲值", { "setmaxarmour" }, "护甲将被修改为指定的数值",
    50, 100000, defaultArmour, 50, function(value)
    moddedArmour = value
end)

menu.toggle_loop(Self_Custom_options, "开启", {}, "改变你的最大护甲值。一些菜单会将你标记为作弊者。当它被禁用时，它会返回到默认的最大护甲值。"
    , function()
        if PLAYER.GET_PLAYER_MAX_ARMOUR(PLAYER.PLAYER_ID()) ~= moddedArmour then
            PLAYER.SET_PLAYER_MAX_ARMOUR(PLAYER.PLAYER_ID(), moddedArmour)
            PED.SET_PED_ARMOUR(PLAYER.PLAYER_ID(), moddedArmour)
        end
    end, function()
    PLAYER.SET_PLAYER_MAX_ARMOUR(PLAYER.PLAYER_ID(), defaultArmour)
    PED.SET_PED_ARMOUR(PLAYER.PLAYER_ID(), defaultArmour)
end)

-------------------
--- 自定义生命恢复 ---
-------------------
local Self_Custom_recharge_options = menu.list(Self_options, "自定义生命恢复", {}, "")

local custom_recharge = {
    normal_recharge_limit = 0.25,
    normal_recharge_mult = 1.0,
    cover_recharge_limit = 0.25,
    cover_recharge_mult = 1.0
}

menu.toggle_loop(Self_Custom_recharge_options, "开启", {}, "", function()
    if PED.IS_PED_IN_COVER(players.user_ped(), false) then
        PLAYER._SET_PLAYER_HEALTH_RECHARGE_LIMIT(players.user(), custom_recharge.cover_recharge_limit)
        PLAYER.SET_PLAYER_HEALTH_RECHARGE_MULTIPLIER(players.user(), custom_recharge.cover_recharge_mult)
    else
        PLAYER._SET_PLAYER_HEALTH_RECHARGE_LIMIT(players.user(), custom_recharge.normal_recharge_limit)
        PLAYER.SET_PLAYER_HEALTH_RECHARGE_MULTIPLIER(players.user(), custom_recharge.normal_recharge_mult)
    end
end, function()
    PLAYER._SET_PLAYER_HEALTH_RECHARGE_LIMIT(players.user(), 0.25)
    PLAYER.SET_PLAYER_HEALTH_RECHARGE_MULTIPLIER(players.user(), 1.0)
end)

menu.divider(Self_Custom_recharge_options, "站立不动状态")
menu.slider(Self_Custom_recharge_options, "恢复程度", { "normal_recharge_limit" }, "恢复到血量的多少，单位%\n默认：25%"
    , 1, 100, 25, 10, function(value)
    custom_recharge.normal_recharge_limit = value * 0.01
end)
menu.slider(Self_Custom_recharge_options, "恢复速度", { "normal_recharge_mult" }, "恢复速度\n默认：1.0", 1.0,
    100.0, 1.0, 1.0, function(value)
    custom_recharge.normal_recharge_mult = value
end)

menu.divider(Self_Custom_recharge_options, "掩体状态")
menu.slider(Self_Custom_recharge_options, "恢复程度", { "cover_recharge_limit" }, "恢复到血量的多少，单位%\n默认：25%"
    , 1, 100, 25, 10, function(value)
    custom_recharge.cover_recharge_limit = value * 0.01
end)
menu.slider(Self_Custom_recharge_options, "恢复速度", { "cover_recharge_mult" }, "恢复速度\n默认：1.0", 1.0,
    100.0, 1.0, 1.0, function(value)
    custom_recharge.cover_recharge_mult = value
end)

------
menu.divider(Self_options, "恢复")
menu.action(Self_options, "恢复生命", {}, "恢复到最大血量 MAX_HEALTH", function()
    local maxHealth = PED.GET_PED_MAX_HEALTH(players.user_ped())
    ENTITY.SET_ENTITY_HEALTH(players.user_ped(), maxHealth, 0)
end)
menu.action(Self_options, "恢复护甲", {}, "标准恢复护甲 50&100", function()
    local armour = util.is_session_started() and 50 or 100
    PED.SET_PED_ARMOUR(players.user_ped(), armour)
end)
menu.action(Self_options, "恢复护甲(满)", {}, "恢复到最大护甲 MAX_ARMOUR", function()
    local armour = PLAYER.GET_PLAYER_MAX_ARMOUR(players.user())
    PED.SET_PED_ARMOUR(players.user_ped(), armour)
end)
menu.toggle_loop(Self_options, "掩体内快速恢复生命", {}, "", function()
    if PED.IS_PED_IN_COVER(players.user_ped(), false) then
        PLAYER._SET_PLAYER_HEALTH_RECHARGE_LIMIT(players.user(), 1.0)
        PLAYER.SET_PLAYER_HEALTH_RECHARGE_MULTIPLIER(players.user(), 15.0)
    else
        PLAYER._SET_PLAYER_HEALTH_RECHARGE_LIMIT(players.user(), 0.5)
        PLAYER.SET_PLAYER_HEALTH_RECHARGE_MULTIPLIER(players.user(), 1.0)
    end
end, function()
    PLAYER._SET_PLAYER_HEALTH_RECHARGE_LIMIT(players.user(), 0.25)
    PLAYER.SET_PLAYER_HEALTH_RECHARGE_MULTIPLIER(players.user(), 1.0)
end)

--- 当血量过低时锁定锁定 ---
local maxHealth = ENTITY.GET_ENTITY_MAX_HEALTH(players.user_ped())
local toLockHealth = maxHealth * 0.5
menu.slider(Self_options, "低于多少%血量", { "lockhealth" }, "锁定前到达的最低血量，单位%", 10, 100,
    50, 10, function(value)
    toLockHealth = maxHealth * value * 0.01
end)
menu.toggle_loop(Self_options, "当血量过低时锁定", {}, "当你的血量低于你设置的值后，锁定你的血量，防不住爆炸XD"
    , function()
    if ENTITY.GET_ENTITY_HEALTH(players.user_ped()) < toLockHealth then
        ENTITY.SET_ENTITY_HEALTH(players.user_ped(), toLockHealth)
    end
end)
------
menu.divider(Self_options, "通知")
menu.action(Self_options, "通知当前血量和最大血量", {}, "", function()
    local player_maxhealth = PED.GET_PED_MAX_HEALTH(PLAYER.PLAYER_PED_ID())
    local player_currenthealth = ENTITY.GET_ENTITY_HEALTH(PLAYER.PLAYER_PED_ID())
    util.toast("当前血量：" .. player_currenthealth .. "\n最大血量：" .. player_maxhealth)
end)
menu.action(Self_options, "通知当前护甲和最大护甲", {}, "", function()
    local player_currentarmour = PED.GET_PED_ARMOUR(PLAYER.PLAYER_PED_ID())
    local player_maxarmour = PLAYER.GET_PLAYER_MAX_ARMOUR(PLAYER.PLAYER_ID())
    util.toast("当前护甲：" .. player_currentarmour .. "\n最大护甲：" .. player_maxarmour)
end)
------
menu.divider(Self_options, "")
menu.toggle_loop(Self_options, "警察无视", {}, "", function(toggle)
    PLAYER.SET_POLICE_IGNORE_PLAYER(PLAYER.PLAYER_ID(), toggle)
end)
menu.toggle_loop(Self_options, "所有人无视", {}, "", function(toggle)
    PLAYER.SET_EVERYONE_IGNORE_PLAYER(PLAYER.PLAYER_ID(), toggle)
end)
menu.toggle_loop(Self_options, "行动无声", {}, "", function()
    PLAYER.SET_PLAYER_NOISE_MULTIPLIER(PLAYER.PLAYER_ID(), 0.0)
end)



--------------------------------
------------ 武器选项 ------------
--------------------------------
local Weapon_options = menu.list(menu.my_root(), "武器选项", {}, "")

menu.toggle(Weapon_options, "可以射击队友", {}, "使你在游戏中能够射击队友", function(toggle)
    PED.SET_CAN_ATTACK_FRIENDLY(PLAYER.PLAYER_PED_ID(), toggle, false)
end)
menu.toggle_loop(Weapon_options, '翻滚时自动换弹夹', {}, "当你做翻滚动作时更换弹夹", function()
    if TASK.GET_IS_TASK_ACTIVE(PLAYER.PLAYER_PED_ID(), 4) and PAD.IS_CONTROL_PRESSED(2, 22) and
        not PED.IS_PED_SHOOTING(PLAYER.PLAYER_PED_ID()) then
        --checking if player is rolling
        util.yield(900)
        WEAPON.REFILL_AMMO_INSTANTLY(PLAYER.PLAYER_PED_ID())
    end
end)
menu.toggle_loop(Weapon_options, "无限弹药", { "inf_clip" }, "锁定弹夹，可以避免子弹过多的检测",
    function()
        WEAPON.SET_PED_INFINITE_AMMO_CLIP(PLAYER.PLAYER_PED_ID(), true)
    end, function()
    WEAPON.SET_PED_INFINITE_AMMO_CLIP(PLAYER.PLAYER_PED_ID(), false)
end)
menu.toggle_loop(Weapon_options, "锁定最大弹药", { "lock_ammo" }, "锁定当前武器为最大弹药\n内存读写操作，易崩溃"
    , function()
    local curWeaponMem = memory.alloc()
    local junk = WEAPON.GET_CURRENT_PED_WEAPON(PLAYER.PLAYER_PED_ID(), curWeaponMem, 1)
    local curWeapon = memory.read_int(curWeaponMem)
    memory.free(curWeaponMem)

    local curAmmoMem = memory.alloc()
    junk = WEAPON.GET_MAX_AMMO(PLAYER.PLAYER_PED_ID(), curWeapon, curAmmoMem)
    local curAmmoMax = memory.read_int(curAmmoMem)
    memory.free(curAmmoMem)

    if curAmmoMax > 0 then
        WEAPON.SET_PED_AMMO(PLAYER.PLAYER_PED_ID(), curWeapon, curAmmoMax)
    end
end)

------- 实体控制枪 -------
local Weapon_Entity_control = menu.list(Weapon_options, "实体控制枪", {}, "控制你所瞄准的实体")

function entity_control_Head(menu_parent, ent)
    menu.action(menu_parent, "检测该实体是否存在", {}, "", function()
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            util.toast("实体存在")
        else
            util.toast("该实体已经不存在，请删除此条实体记录！")
        end
    end)
    menu.action(menu_parent, "删除此条实体记录", {}, "", function()
        menu.delete(menu_parent)
        clearTableValue(control_ent_menu_list, menu_parent)
        clearTableValue(control_ent_list, ent)
    end)
end

-- 所有控制的实体
control_ent_list = {}
-- 所有控制实体的menu.list
control_ent_menu_list = {}

menu.toggle_loop(Weapon_Entity_control, "开启", {}, "", function()
    local ent = GetEntity_PlayerIsAimingAt(players.user())
    if ent ~= nil and ENTITY.DOES_ENTITY_EXIST(ent) then
        if not isInTable(control_ent_list, ent) then
            table.insert(control_ent_list, ent)
            ---
            local modelHash = ENTITY.GET_ENTITY_MODEL(ent)
            local entity_types = { "No entity", "Ped", "Vehicle", "Object" }
            local entity_type = entity_types[ENTITY.GET_ENTITY_TYPE(ent) + 1]
            if ENTITY.GET_ENTITY_TYPE(ent) == 3 then
                if OBJECT.IS_OBJECT_A_PICKUP(ent) or OBJECT.IS_OBJECT_A_PORTABLE_PICKUP(ent) then
                    entity_type = "Pickup"
                end
            end
            local entity_info = "Hash: " .. modelHash .. " (" .. entity_type .. ")"
            util.toast(entity_info)
            local text = "Model Name: " .. util.reverse_joaat(modelHash)
            --- 实体控制列表
            local menu_control_entity = menu.list(Weapon_Entity_control, entity_info, {}, text)
            -- entity
            entity_control_Head(menu_control_entity, ent)
            entity_control_all(menu_control_entity, ent)
            -- ped
            if ENTITY.GET_ENTITY_TYPE(ent) == 1 then
                entity_control_ped(menu_control_entity, ent)
            end
            -- vehicle
            if ENTITY.GET_ENTITY_TYPE(ent) == 2 then
                entity_control_vehicle(menu_control_entity, ent)
            end

            table.insert(control_ent_menu_list, menu_control_entity)
        end

    end
end)

menu.action(Weapon_Entity_control, "清除记录的实体", {}, "", function()
    for k, v in pairs(control_ent_menu_list) do
        if v ~= nil then
            menu.delete(v)
        end
    end
    -- 所有控制的实体
    control_ent_list = {}
    -- 所有控制实体的menu.list
    control_ent_menu_list = {}
end)

menu.divider(Weapon_Entity_control, "实体控制列表")

--------------------------------
------------ 载具选项 ------------
--------------------------------
local Vehicle_options = menu.list(menu.my_root(), "载具选项", {}, "")

menu.action(Vehicle_options, "修复载具无法移动", {}, "尝试而已", function()
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
    if vehicle then
        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh)
        if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(veh) then
            for i = 1, 20 do
                NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh)
                util.yield(100)
            end
        end
        VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, 1000)
        VEHICLE.SET_VEHICLE_PETROL_TANK_HEALTH(vehicle, 1000)
        ENTITY.FREEZE_ENTITY_POSITION(vehicle, false)
    end
end)

local dirt_level = 0.0
menu.click_slider(Vehicle_options, "载具灰尘程度", {}, "载具全身灰尘程度", 0.0, 15.0, 0.0, 1.0,
    function(value)
        dirt_level = value
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
        if vehicle then
            VEHICLE.SET_VEHICLE_DIRT_LEVEL(vehicle, dirt_level)
        end
    end)
menu.toggle_loop(Vehicle_options, "锁定载具灰尘程度", {}, "", function()
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
    if vehicle then
        VEHICLE.SET_VEHICLE_DIRT_LEVEL(vehicle, dirt_level)
    end
end)

menu.toggle_loop(Vehicle_options, "防弹轮胎", {}, "", function()
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
    if vehicle then
        VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(vehicle, false)
    end
end)
-----
menu.divider(Vehicle_options, "解锁载具")
menu.toggle_loop(Vehicle_options, "载具引擎快速开启", {}, "减少载具启动引擎时间", function()
    if PED.IS_PED_GETTING_INTO_A_VEHICLE(PLAYER.PLAYER_PED_ID()) then
        local veh = PED.GET_VEHICLE_PED_IS_ENTERING(PLAYER.PLAYER_PED_ID())
        if veh then
            VEHICLE.SET_VEHICLE_ENGINE_HEALTH(veh, 1000)
            VEHICLE.SET_VEHICLE_ENGINE_ON(veh, true, true, false)
        end
    end
end)

--- 解锁正在进入的载具 ---
function UnlockVehicle_PlayerGetIn()
    ::start::
    local localPed = PLAYER.PLAYER_PED_ID()
    local veh = PED.GET_VEHICLE_PED_IS_TRYING_TO_ENTER(localPed)
    if PED.IS_PED_IN_ANY_VEHICLE(localPed, false) then
        local v = PED.GET_VEHICLE_PED_IS_IN(localPed, false)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED(v, 1)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(v, false)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_PLAYER(v, players.user(), false)
        ENTITY.FREEZE_ENTITY_POSITION(v, false)
        util.yield()
    else
        if veh ~= 0 then
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh)
            if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(veh) then
                for i = 1, 20 do
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh)
                    util.yield(100)
                end
            end
            if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(veh) then
                util.toast("Waited 2 secs, couldn't get control!")
                goto start
            else
                util.toast("Has control.")
            end
            VEHICLE.SET_VEHICLE_DOORS_LOCKED(veh, 1)
            VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(veh, false)
            VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_PLAYER(veh, players.user(), false)
            VEHICLE.SET_VEHICLE_HAS_BEEN_OWNED_BY_PLAYER(veh, false)
        end
    end
end

menu.toggle_loop(Vehicle_options, "解锁正在进入的载具", {}, "解锁你正在进入的载具。对于锁住的玩家载具也有效果。"
    , function()
    UnlockVehicle_PlayerGetIn()
end)

-----
menu.divider(Vehicle_options, "载具车窗")
menu.toggle_loop(Vehicle_options, "自动修复前车窗", {}, "", function()
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
    if vehicle then
        VEHICLE.FIX_VEHICLE_WINDOW(vehicle, 6)
    end
end)
menu.toggle_loop(Vehicle_options, "自动修复后车窗", {}, "", function()
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
    if vehicle then
        VEHICLE.FIX_VEHICLE_WINDOW(vehicle, 7)
    end
end)
-----
menu.divider(Vehicle_options, "载具自动门")
menu.toggle_loop(Vehicle_options, "拆下左前门", {}, "", function()
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
    if vehicle then
        VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, 0, false)
    end
end)
menu.toggle_loop(Vehicle_options, "拆下右前门", {}, "", function()
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
    if vehicle then
        VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, 1, false)
    end
end)
menu.toggle_loop(Vehicle_options, "拆下全部门", {}, "", function()
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
    if vehicle then
        VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, 0, false)
        VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, 1, false)
        VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, 2, false)
        VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, 3, false)
    end
end)
-----
menu.divider(Vehicle_options, "个人载具")
menu.action(Vehicle_options, "打开引擎和左车门", {}, "", function()
    local vehicle = entities.get_user_personal_vehicle_as_handle()
    if vehicle then
        VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, false)
        VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, 0, false, false)
    end
end)
menu.action(Vehicle_options, "开启载具引擎", {}, "个人载具和上一辆载具", function()
    local vehicle = entities.get_user_personal_vehicle_as_handle()
    if vehicle then
        VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, false)
    end

    local last_vehicle = entities.get_user_vehicle_as_handle()
    if last_vehicle and last_vehicle ~= vehicle then
        VEHICLE.SET_VEHICLE_ENGINE_ON(last_vehicle, true, true, false)
    end
end)
menu.action(Vehicle_options, "打开左车门", {}, "", function()
    local vehicle = entities.get_user_personal_vehicle_as_handle()
    if vehicle then
        VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, 0, false, false)
    end
end)
menu.action(Vehicle_options, "打开左右车门", {}, "", function()
    local vehicle = entities.get_user_personal_vehicle_as_handle()
    if vehicle then
        VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, 0, false, false)
        VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, 1, false, false)
    end
end)

-----------------------------------
------------ 世界实体选项 ------------
-----------------------------------
local Entity_options = menu.list(menu.my_root(), "世界实体选项", {}, "")
-----
local Entity_NEAR_PED_CAM = menu.list(Entity_options, "管理附近的NPC和摄像头", {}, "来自Heist Control")

menu.divider(Entity_NEAR_PED_CAM, "设置")
local HostilePed = false
menu.toggle(Entity_NEAR_PED_CAM, "只对怀有敌意的NPC有效", {}, "启用：只对怀有敌意的NPC生效" ..
    "\n" .. "禁用：对所有NPC生效", function(Toggle)
    HostilePedToggle = Toggle

    if HostilePedToggle then
        HostilePed = true
    else
        HostilePed = false
    end
end)
-----
menu.divider(Entity_NEAR_PED_CAM, "NPC选项")
menu.action(Entity_NEAR_PED_CAM, "移除NPC武器", {}, "", function()
    for k, ent in pairs(entities.get_all_peds_as_handles()) do
        if not IS_PED_PLAYER(ent) then
            if HostilePed then
                if PED.IS_PED_IN_COMBAT(ent, PLAYER.PLAYER_ID()) then
                    WEAPON.REMOVE_ALL_PED_WEAPONS(ent, true)
                end
            else
                WEAPON.REMOVE_ALL_PED_WEAPONS(ent, true)
            end
        end
    end
end)
menu.action(Entity_NEAR_PED_CAM, "删除所有NPC", {}, "", function()
    for k, ent in pairs(entities.get_all_peds_as_handles()) do
        if not IS_PED_PLAYER(ent) then
            if HostilePed then
                if PED.IS_PED_IN_COMBAT(ent, PLAYER.PLAYER_ID()) then
                    entities.delete_by_handle(ent)
                end
            else
                entities.delete_by_handle(ent)
            end
        end
    end
end)
menu.action(Entity_NEAR_PED_CAM, "杀死所有NPC", {}, "", function()
    for k, ent in pairs(entities.get_all_peds_as_handles()) do
        if not IS_PED_PLAYER(ent) then
            if HostilePed then
                if PED.IS_PED_IN_COMBAT(ent, PLAYER.PLAYER_ID()) then
                    ENTITY.SET_ENTITY_HEALTH(ent, 0.0)
                end
            else
                ENTITY.SET_ENTITY_HEALTH(ent, 0.0)
            end
        end
    end
end)
-----
menu.divider(Entity_NEAR_PED_CAM, "摄像头选项")
menu.action(Entity_NEAR_PED_CAM, "删除摄像头", {}, "几乎可以删除全部摄像头了", function()
    -- Credit goes to Leif.Erickson
    for k, ent in pairs(entities.get_all_objects_as_handles()) do
        local EntityModel = ENTITY.GET_ENTITY_MODEL(ent)
        local Cams = {
            -1233322078,
            168901740,
            -1095296451,
            -173206916,
            -1159421424,
            548760764,
            -1340405475,
            1449155105,
            -354221800,
            -1884701657,
            2090203758,
            -1007354661,
            -1842407088,
            289451089,
            3061645218
        }

        for i = 1, #Cams do
            if EntityModel == Cams[i] then
                entities.delete_by_handle(ent)
            end
        end
    end
end)
menu.action(Entity_NEAR_PED_CAM, "摄像头上天", {}, "上天了就拍不到你了", function()
    -- Credit goes to Leif.Erickson
    for k, ent in pairs(entities.get_all_objects_as_handles()) do
        local EntityModel = ENTITY.GET_ENTITY_MODEL(ent)
        local Cams = {
            -1233322078,
            168901740,
            -1095296451,
            -173206916,
            -1159421424,
            548760764,
            -1340405475,
            1449155105,
            -354221800,
            -1884701657,
            2090203758,
            -1007354661,
            -1842407088,
            289451089,
            3061645218
        }

        for i = 1, #Cams do
            if EntityModel == Cams[i] then
                local pos = ENTITY.GET_ENTITY_COORDS(ent)
                ENTITY.SET_ENTITY_COORDS(ent, pos.x, pos.y, pos.z + 30.0, true, false, false, false)
            end
        end
    end
end)

------------------
----- 附近载具 -----
------------------
local Nearby_Vehicle_options = menu.list(Entity_options, "管理附近载具", {}, "")

menu.slider(Nearby_Vehicle_options, "范围半径", { "radius_nearby_vehicle" }, "", 0.0, 1000.0, 30.0, 10.0,
    function(value)
        control_nearby_vehicles_setting.radius = value
    end)
menu.toggle_loop(Nearby_Vehicle_options, "绘制范围", {}, "", function()
    local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
    GRAPHICS._DRAW_SPHERE(coords.x, coords.y, coords.z, control_nearby_vehicles_setting.radius, 200, 50, 200, 0.5)
end)

menu.slider(Nearby_Vehicle_options, "时间间隔", { "delay_nearby_vehicle" }, "", 0, 3000, 10, 10, function(value)
    control_nearby_vehicles_setting.time_delay = value
end)

----------------------
--  附近载具 恶搞选项
----------------------
local Nearby_Vehicle_Trolling_options = menu.list(Nearby_Vehicle_options, "恶搞选项", {}, "")
menu.toggle(Nearby_Vehicle_Trolling_options, "爆炸", {}, "", function(toggle)
    control_nearby_vehicles_toggles.explosion = toggle
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
menu.slider(Nearby_Vehicle_Trolling_options, "设置向前加的速度", { "set_forward_speed" }, "", 0, 1000, 30, 10,
    function(value)
        control_nearby_vehicles_data.forward_speed = value
    end)
menu.toggle(Nearby_Vehicle_Trolling_options, "向前加速", {}, "混乱的洛圣都XD", function(toggle)
    control_nearby_vehicles_toggles.forward_speed = toggle
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
menu.divider(Nearby_Vehicle_options, "")
menu.action(Nearby_Vehicle_options, "解锁车门", {}, "直接是全部范围", function()
    for k, vehicle in ipairs(entities.get_all_vehicles_as_handles()) do
        VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle, 1)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_PLAYER(vehicle, players.user(), false)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(vehicle, false)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_NON_SCRIPT_PLAYERS(vehicle, false)
        VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, false)
    end
end)
menu.action(Nearby_Vehicle_options, "打开左右车门和引擎", {}, "直接是全部范围", function()
    for k, vehicle in ipairs(entities.get_all_vehicles_as_handles()) do
        VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, false)
        VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, 0, false, false)
        VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, 1, false, false)
    end
end)
menu.action(Nearby_Vehicle_options, "拆下左右车门和打开引擎", {}, "直接是全部范围", function()
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

menu.slider(Nearby_Ped_options, "范围半径", { "radius_nearby_ped" }, "", 0.0, 1000.0, 30.0, 10.0, function(value)
    control_nearby_peds_setting.radius = value
end)
menu.toggle_loop(Nearby_Ped_options, "绘制范围", {}, "", function()
    local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
    GRAPHICS._DRAW_SPHERE(coords.x, coords.y, coords.z, control_nearby_peds_setting.radius, 200, 50, 200, 0.5)
end)

menu.slider(Nearby_Ped_options, "时间间隔", { "delay_nearby_ped" }, "", 0, 3000, 10, 10, function(value)
    control_nearby_peds_setting.time_delay = value
end)
menu.toggle(Nearby_Ped_options, "排除载具内NPC", {}, "", function(toggle)
    control_nearby_peds_setting.exclude_ped_in_vehicle = toggle
end, true)

----------------------
--  附近NPC 恶搞选项
----------------------
local Nearby_Ped_Trolling_options = menu.list(Nearby_Ped_options, "恶搞选项", {}, "")
menu.slider(Nearby_Ped_Trolling_options, "设置向前推进程度", { "set_forward_degree" }, "", 0, 1000, 30, 10,
    function(value)
        control_nearby_peds_data.forward_speed = value
    end)
menu.toggle(Nearby_Ped_Trolling_options, "向前推进", {}, "", function(toggle)
    control_nearby_peds_toggles.force_forward = toggle
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
    for k, ped in ipairs(GET_NEARBY_PEDS(players.user(), radius_nearby_ped)) do
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
--  附近NPC 作战能力
----------------------
local Nearby_Ped_Combat_options = menu.list(Nearby_Ped_options, "作战能力", {}, "")
menu.divider(Nearby_Ped_Combat_options, "弱化NPC")

local nearby_ped_combat = {
    see_range = 0.0,
    hear_range = 0.0,
    peripheral_range = 0.0,
    peripheral_angle = 0.0,
    highly_perceptive = false,
    remove_defensive_area = true,
    can_use_cover = false,
}

menu.slider(Nearby_Ped_Combat_options, "视力范围", { "see_range" }, "", 0.0, 1000.0, 0.0, 1.0, function(value)
    nearby_ped_combat.see_range = value
end)
menu.slider(Nearby_Ped_Combat_options, "听力范围", { "hear_range" }, "", 0.0, 1000.0, 0.0, 1.0, function(value)
    nearby_ped_combat.hear_range = value
end)
menu.slider(Nearby_Ped_Combat_options, "锥形视野范围", { "peripheral_range" }, "", 0.0, 1000.0, 0.0, 1.0,
    function(value)
        nearby_ped_combat.peripheral_range = value
    end)
menu.slider(Nearby_Ped_Combat_options, "侦查角度", { "peripheral_angle" }, "", -90.0, 90.0, 0.0, 1.0,
    function(value)
        nearby_ped_combat.peripheral_angle = value
    end)
menu.toggle(Nearby_Ped_Combat_options, "高度警觉性", {}, "", function(toggle)
    nearby_ped_combat.highly_perceptive = toggle
end)
menu.toggle(Nearby_Ped_Combat_options, "移除防卫区域", {}, "Ped will no longer get angry when you stay near him.",
    function(toggle)
        nearby_ped_combat.remove_defensive_area = toggle
    end, true)
menu.toggle(Nearby_Ped_Combat_options, "会使用掩体", {}, "", function(toggle)
    nearby_ped_combat.can_use_cover = toggle
end)

menu.action(Nearby_Ped_Combat_options, "设置", {}, "直接是全部范围", function()
    for k, ped in ipairs(entities.get_all_peds_as_handles()) do
        if not IS_PED_PLAYER(ped) then
            PED.SET_PED_SEEING_RANGE(ped, nearby_ped_combat.see_range)
            PED.SET_PED_HEARING_RANGE(ped, nearby_ped_combat.hear_range)
            PED.SET_PED_HIGHLY_PERCEPTIVE(ped, nearby_ped_combat.highly_perceptive)
            PED.SET_PED_VISUAL_FIELD_PERIPHERAL_RANGE(ped, nearby_ped_combat.peripheral_range)

            PED.SET_PED_VISUAL_FIELD_MIN_ANGLE(ped, nearby_ped_combat.peripheral_angle)
            PED.SET_PED_VISUAL_FIELD_MAX_ANGLE(ped, nearby_ped_combat.peripheral_angle)
            PED.SET_PED_VISUAL_FIELD_MIN_ELEVATION_ANGLE(ped, nearby_ped_combat.peripheral_angle)
            PED.SET_PED_VISUAL_FIELD_MAX_ELEVATION_ANGLE(ped, nearby_ped_combat.peripheral_angle)
            PED.SET_PED_VISUAL_FIELD_CENTER_ANGLE(ped, nearby_ped_combat.peripheral_angle)

            PED.REMOVE_PED_DEFENSIVE_AREA(ped, nearby_ped_combat.remove_defensive_area)
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 0, nearby_ped_combat.can_use_cover)
        end
    end
end)

------------------
----- 附近区域 -----
------------------
local Nearby_Area_options = menu.list(Entity_options, "管理附近区域", {}, "")

local radius_nearby_area = 30.0
menu.slider(Nearby_Area_options, "范围半径", { "radius_nearby_area" }, "", 0.0, 1000.0, 30.0, 10.0,
    function(value)
        radius_nearby_area = value
    end)
menu.toggle_loop(Nearby_Area_options, "绘制范围", {}, "", function()
    local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
    GRAPHICS._DRAW_SPHERE(coords.x, coords.y, coords.z, radius_nearby_area, 200, 50, 200, 0.5)
end)
---
menu.divider(Nearby_Area_options, "清理 MISC::CLEAR")
menu.toggle_loop(Nearby_Area_options, "清理区域", {}, "清理区域内所有东西", function()
    local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
    MISC.CLEAR_AREA(coords.x, coords.y, coords.z, radius_nearby_area, true, false, false, false)
end)
menu.toggle_loop(Nearby_Area_options, "清理载具", {}, "清理区域内所有载具", function()
    local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
    MISC.CLEAR_AREA_OF_VEHICLES(coords.x, coords.y, coords.z, radius_nearby_area, false, false, false, false, false,
        false)
end)
menu.toggle_loop(Nearby_Area_options, "清理行人", {}, "清理区域内所有行人", function()
    local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
    MISC.CLEAR_AREA_OF_PEDS(coords.x, coords.y, coords.z, radius_nearby_area, 1)
end)
menu.toggle_loop(Nearby_Area_options, "清理警察", {}, "清理区域内所有警察", function()
    local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
    MISC.CLEAR_AREA_OF_COPS(coords.x, coords.y, coords.z, radius_nearby_area, 0)
end)
menu.toggle_loop(Nearby_Area_options, "清理物体", {}, "清理区域内所有物体", function()
    local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
    MISC.CLEAR_AREA_OF_OBJECTS(coords.x, coords.y, coords.z, radius_nearby_area, 0)
end)
menu.toggle_loop(Nearby_Area_options, "清理投掷物", {}, "清理区域内所有子弹、炮弹、投掷物等",
    function()
        local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
        MISC.CLEAR_AREA_OF_PROJECTILES(coords.x, coords.y, coords.z, radius_nearby_area, 0)
    end)

------------------------
-------- 任务实体 --------
------------------------
local MISSION_ENTITY = menu.list(Entity_options, "管理任务实体", {}, "")

menu.action(MISSION_ENTITY, "TP to PC", { "tpdesk" }, "Teleport to PC at the Desk", function()
    local pcD = HUD.GET_BLIP_COORDS(HUD.GET_NEXT_BLIP_INFO_ID(521))
    HUD.GET_BLIP_COORDS(HUD.GET_NEXT_BLIP_INFO_ID(521))
    if pcD.x == 0 and pcD.y == 0 and pcD.z == 0 then
        util.toast("No PC Found")
    else
        ENTITY.SET_ENTITY_COORDS(players.user_ped(), pcD.x - 1.0, pcD.y + 1.0, pcD.z, false, false, false, false)
    end
end)

----- 办公室拉货 -----
local MISSION_ENTITY_cargo = menu.list(MISSION_ENTITY, "办公室拉货", {}, "")

local MISSION_ENTITY_cargo_remove = menu.list(MISSION_ENTITY_cargo, "移除冷却时间", {}, "来自Heist Control")
menu.divider(MISSION_ENTITY_cargo_remove, "购买和出售")
menu.toggle_loop(MISSION_ENTITY_cargo_remove, "特殊货物", { "hccoolspecial" }, "", function()
    SET_INT_GLOBAL(262145 + 15608, 0) -- Buy, 153204142
    SET_INT_GLOBAL(262145 + 15609, 0) -- Sell, 1291620941
end, function()
    SET_INT_GLOBAL(262145 + 15608, 300000)
    SET_INT_GLOBAL(262145 + 15609, 1800000)
end)
menu.toggle_loop(MISSION_ENTITY_cargo_remove, "载具货物", { "hccoolveh" }, "", function()
    SET_INT_GLOBAL(262145 + 19359, 0) -- -82707601
    SET_INT_GLOBAL(262145 + 19727, 0) -- 1 Vehicle, 1001423248
    SET_INT_GLOBAL(262145 + 19728, 0) -- 2 Vehicles, 240134765
    SET_INT_GLOBAL(262145 + 19729, 0) -- 3 Vehicles, 1915379148
    SET_INT_GLOBAL(262145 + 19730, 0) -- 4 Vehicles, -824005590
end, function()
    SET_INT_GLOBAL(262145 + 19359, 180000)
    SET_INT_GLOBAL(262145 + 19727, 1200000)
    SET_INT_GLOBAL(262145 + 19728, 1680000)
    SET_INT_GLOBAL(262145 + 19729, 2340000)
    SET_INT_GLOBAL(262145 + 19730, 2880000)
end)

menu.action(MISSION_ENTITY_cargo, "TP to Special Cargo", { "tpscargo" }, "Teleport to Special Cargo pickup",
    function()
        local blip = HUD.GET_NEXT_BLIP_INFO_ID(478)
        local cPickup = HUD.GET_BLIP_COORDS(blip)
        if cPickup.x == 0 and cPickup.y == 0 and cPickup.z == 0 then
            util.toast("No Cargo Found")
        else
            ENTITY.SET_ENTITY_COORDS(players.user_ped(), cPickup.x, cPickup.y, cPickup.z + 1.0, false, false, false,
                false)

            --vehicle
            if HUD.GET_BLIP_INFO_ID_TYPE(blip) == 1 then
                local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
                VEHICLE.SET_VEHICLE_ENGINE_ON(ent, true, true, false)
                VEHICLE.SET_VEHICLE_DOOR_BROKEN(ent, 0, true)
            end
        end
    end)

menu.action(MISSION_ENTITY_cargo, "特殊货物 传送到我", {}, "By Blip\nBlip Sprite ID: 478", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(478)
    local cPickup = HUD.GET_BLIP_COORDS(blip)
    if cPickup.x == 0 and cPickup.y == 0 and cPickup.z == 0 then
        util.toast("No Cargo Found")
    else
        local blip_type = HUD.GET_BLIP_INFO_ID_TYPE(blip)
        if blip_type == 4 or blip_type == 5 or blip_type == 7 then
            util.toast("Not Entity, Can't Teleport To Me")
        else
            local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
            TP_TO_ME(ent, 0.0, 2.0, -0.5)
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
            --vehicle
            if blip_type == 1 then
                TP_INTO_VEHICLE(ent, "delete", "delete")
            end
        end
    end
end)
menu.action(MISSION_ENTITY_cargo, "散货板条箱 传送到我", {}, "\nModel Hash: -265116550, 1688540826, -1143129136"
    , function()
    local entity_list = GetEntity_ByModelHash("pickup", true, -265116550, 1688540826, -1143129136)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, -1.0)
        end
    else
        util.toast("Not Found")
    end
end)
menu.action(MISSION_ENTITY_cargo, "要追踪的车 传送到我", {},
    "Trackify\n车里的货物\nModel Hash: -1322183878, -2022916910", function()
    local entity_list = GetEntity_ByModelHash("object", true, -1322183878, -2022916910)
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

menu.divider(MISSION_ENTITY_cargo, "卢佩")
menu.action(MISSION_ENTITY_cargo, "卢佩：传送到那里", {}, "和她对话，让她去拉货\nModel Hash: 1108376739"
    , function()
    local entity_list = GetEntity_ByModelHash("ped", true, 1108376739)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, 0.5, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ent, 180.0)
        end
    end
end)

--Model Hash: -1235210928(object) 卢佩 水下 要炸的货箱
menu.action(MISSION_ENTITY_cargo, "卢佩：水下货箱 获取", {},
    "先获取到才能传送\n货箱里面 要拾取的包裹\nModel Hash: 388143302, -36934887, 319657375, 924741338, -1249748547"
    , function()
    --
    water_cargo_hash_list = { 388143302, -36934887, 319657375, 924741338, -1249748547 }
    -- 拾取包裹 实体list
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

menu_Water_Cargo_TP = menu.click_slider(MISSION_ENTITY_cargo, "卢佩：水下货箱 传送到那里", {}, "", 0, 0, 0, 1
    , function(value)
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

menu.divider(MISSION_ENTITY_cargo, "载具货物")
menu.action(MISSION_ENTITY_cargo, "TP to Vehicle Cargo", { "tpvcargo" }, "Teleport to Vehicle Cargo pickup",
    function()
        local vPickup = HUD.GET_BLIP_COORDS(HUD.GET_NEXT_BLIP_INFO_ID(523))
        if vPickup.x == 0 and vPickup.y == 0 and vPickup.z == 0 then
            util.toast("No Vehicle Found")
        else
            ENTITY.SET_ENTITY_COORDS(players.user_ped(), vPickup.x, vPickup.y, vPickup.z, false, false, false, false)
        end
    end)

menu.action(MISSION_ENTITY_cargo, "载具货物 传送到我", {}, "By Blip\nBlip Sprite ID: 523", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(523)
    local cPickup = HUD.GET_BLIP_COORDS(blip)
    if cPickup.x == 0 and cPickup.y == 0 and cPickup.z == 0 then
        util.toast("No Vehicle Found")
    else
        local blip_type = HUD.GET_BLIP_INFO_ID_TYPE(blip)
        if blip_type == 4 or blip_type == 5 or blip_type == 7 then
            util.toast("Not Entity, Can't Teleport To Me")
        else
            local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
            TP_TO_ME(ent, 0.0, 2.0, -0.5)
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
            --vehicle
            if blip_type == 1 then
                TP_INTO_VEHICLE(ent, "delete", "delete")
            end
        end
    end
end)

----- 地堡拉货 -----
local MISSION_ENTITY_bunker = menu.list(MISSION_ENTITY, "地堡拉货", {}, "")

menu.action(MISSION_ENTITY_bunker, "TP to Bunker Supplies/Sale", { "tpBSupplies" },
    "Teleport to Bunker Supplies/Sale Pickup", function()
    local sPickup = HUD.GET_BLIP_COORDS(HUD.GET_NEXT_BLIP_INFO_ID(556))
    local dPickup = HUD.GET_BLIP_COORDS(HUD.GET_NEXT_BLIP_INFO_ID(561))
    local fPickup = HUD.GET_BLIP_COORDS(HUD.GET_NEXT_BLIP_INFO_ID(477))
    local plPickup = HUD.GET_BLIP_COORDS(HUD.GET_NEXT_BLIP_INFO_ID(423))
    if sPickup.x == 0 and sPickup.y == 0 and sPickup.z == 0 then
    elseif sPickup.x ~= 0 and sPickup.y ~= 0 and sPickup.z ~= 0 then
        ENTITY.SET_ENTITY_COORDS(players.user_ped(), sPickup.x, sPickup.y + 2.0, sPickup.z - 1.0, false, false, false,
            false)
        util.toast("TP to Supplies")
    end
    if dPickup.x == 0 and dPickup.y == 0 and dPickup.z == 0 then
    elseif dPickup.x ~= 0 and dPickup.y ~= 0 and dPickup.z ~= 0 then
        ENTITY.SET_ENTITY_COORDS(players.user_ped(), dPickup.x, dPickup.y, dPickup.z, false, false, false, false)
        util.toast("TP to Dune")
    end
    if fPickup.x == 0 and fPickup.y == 0 and fPickup.z == 0 then
    elseif fPickup.x ~= 0 and fPickup.y ~= 0 and fPickup.z ~= 0 then
        ENTITY.SET_ENTITY_COORDS(players.user_ped(), fPickup.x, fPickup.y, fPickup.z + 1.0, false, false, false, false)
        util.toast("TP to Flatbed")
    else
        util.toast("No Bunker Supplies Found")
    end
end)

menu.action(MISSION_ENTITY_bunker, "原材料 传送到我", {}, "By Blip\nBlip Sprite ID: 556", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(556)
    local sPickup = HUD.GET_BLIP_COORDS(blip)
    if sPickup.x == 0 and sPickup.y == 0 and sPickup.z == 0 then
        util.toast("No Bunker Supplies Found")
    elseif sPickup.x ~= 0 and sPickup.y ~= 0 and sPickup.z ~= 0 then
        local blip_type = HUD.GET_BLIP_INFO_ID_TYPE(blip)
        if blip_type == 4 or blip_type == 5 or blip_type == 7 then
            util.toast("Not Entity, Can't Teleport To Me")
        else
            local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
            TP_TO_ME(ent, 0.0, 2.0, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
            --vehicle
            if blip_type == 1 then
                TP_INTO_VEHICLE(ent, "delete", "delete")
            end
        end
    end
end)
menu.action(MISSION_ENTITY_bunker, "原材料：箱子 传送到我", {}, "\nModel Hash: -955159266", function()
    local entity_list = GetEntity_ByModelHash("pickup", true, -955159266)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, -1.0)
        end
    else
        util.toast("Not Found")
    end
end)
menu.action(MISSION_ENTITY_bunker, "游艇：货物 传送到我", {}, "\nModel Hash: -955159266", function()
    local entity_list = GetEntity_ByModelHash("pickup", true, -955159266)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, -1.0)
        end
    else
        util.toast("Not Found")
    end
end)
menu.action(MISSION_ENTITY_bunker, "长鳍追飞机掉落货物 传送到我", {}, "\nModel Hash: 91541528",
    function()
        local entity_list = GetEntity_ByModelHash("object", true, 91541528)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ME(ent, 0.0, 2.0, 1.0)
            end
        else
            util.toast("Not Found")
        end
    end)
menu.action(MISSION_ENTITY_bunker, "消灭对手行动单位：箱子 全部爆炸", {}, "\nModel Hash: -986153641",
    function()
        local entity_list = GetEntity_ByModelHash("object", true, -986153641)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                local pos = ENTITY.GET_ENTITY_COORDS(ent)
                FIRE.ADD_OWNED_EXPLOSION(players.user_ped(), pos.x, pos.y, pos.z + 0.2, EXP_TAG_STICKYBOMB, 10.0, true,
                    false, 0, false)
            end
        else
            util.toast("Not Found")
        end
    end)
menu.action(MISSION_ENTITY_bunker, "消灭对手行动单位：载具 全部爆炸", {},
    "\nModel Hash: 788747387, -1050465301, -1860900134", function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, 788747387, -1050465301, -1860900134)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            local pos = ENTITY.GET_ENTITY_COORDS(ent)
            FIRE.ADD_OWNED_EXPLOSION(players.user_ped(), pos.x, pos.y, pos.z - 0.5, EXP_TAG_STICKYBOMB, 5.0, true, false
                , 0, false)
        end
    else
        util.toast("Not Found")
    end
end)
menu.action(MISSION_ENTITY_bunker, "摧毁卡车 全部爆炸", {}, "\nModel Hash: 904750859", function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, 904750859)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            local pos = ENTITY.GET_ENTITY_COORDS(ent)
            FIRE.ADD_OWNED_EXPLOSION(players.user_ped(), pos.x, pos.y, pos.z - 0.5, EXP_TAG_STICKYBOMB, 5.0, true, false
                , 0, false)
        end
    else
        util.toast("Not Found")
    end
end)

----- 佩里科岛抢劫 -----
local MISSION_ENTITY_perico = menu.list(MISSION_ENTITY, "佩里科岛抢劫", {}, "")

menu.action(MISSION_ENTITY_perico, "侦查：美杜莎 传送到驾驶位", {}, "\nModel Hash: 1077420264", function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, 1077420264)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            VEHICLE.SET_VEHICLE_ENGINE_ON(ent, true, true, false)
            ENTITY.SET_ENTITY_INVINCIBLE(ent, true)
            PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), ent, -1)
        end
    end
end)
menu.action(MISSION_ENTITY_perico, "佩里科岛：信号塔 传送到那里", {}, "\nModel Hash: 1981815996",
    function()
        local entity_list = GetEntity_ByModelHash("object", true, 1981815996)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ENTITY(ent, 0.0, -0.5, 0.5)
                SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ent)
            end
        end
    end)

menu.divider(MISSION_ENTITY_perico, "")
menu.action(MISSION_ENTITY_perico, "前置：长崎 传送到我", {}, "生成并坐进尖锥魅影 传送长崎到后面\nModel Hash: -1352468814"
    , function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, -1352468814)
    if next(entity_list) ~= nil then
        local objHash = util.joaat("phantom2")
        requestModels(objHash)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 2.0, 0.0)
        local phantom = VEHICLE.CREATE_VEHICLE(objHash, coords.x, coords.y, coords.z,
            ENTITY.GET_ENTITY_HEADING(PLAYER.PLAYER_PED_ID()), true, false, true)
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(objHash)

        TP_INTO_VEHICLE(phantom)

        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, -10.0, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
        end
    end
end)
menu.action(MISSION_ENTITY_perico, "前置：保险箱密码 传送到那里", {}, "赌场 保安队长\nModel Hash: -1109568186"
    , function()
    local entity_list = GetEntity_ByModelHash("ped", true, -1109568186)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, 0.0, 0.5)
        end
    end
end)
menu.action(MISSION_ENTITY_perico, "前置：等离子切割枪包裹 传送到我", {}, "\nModel Hash: -802406134",
    function()
        local entity_list = GetEntity_ByModelHash("pickup", true, -802406134)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ME(ent, 0.0, 0.0, 2.0)
            end
        end
    end)
menu.action(MISSION_ENTITY_perico, "前置：指纹复制器 传送到我", {}, "地下车库\nModel Hash: 1506325614",
    function()
        local entity_list = GetEntity_ByModelHash("pickup", true, 1506325614)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ME(ent, 0.0, 0.0, 2.0)
            end
        end
    end)
menu.action(MISSION_ENTITY_perico, "前置：割据 传送到那里", {}, "工地\nModel Hash: 1871441709", function()
    local entity_list = GetEntity_ByModelHash("pickup", true, 1871441709)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, 0.0, 0.5)
        end
    end
end)
menu.action(MISSION_ENTITY_perico, "前置：武器 炸掉女武神", {}, "\nModel Hash: -1600252419", function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, -1600252419)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            local pos = ENTITY.GET_ENTITY_COORDS(ent)
            FIRE.ADD_OWNED_EXPLOSION(players.user_ped(), pos.x, pos.y, pos.z - 0.5, EXP_TAG_STICKYBOMB, 5.0, true, false
                , 0, false)
        end
    end
end)

menu.divider(MISSION_ENTITY_perico, "")
menu.action(MISSION_ENTITY_perico, "佩里科岛：信号塔 传送到我", {}, "\nModel Hash: 1981815996", function()
    local entity_list = GetEntity_ByModelHash("object", false, 1981815996)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, -1.0)
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
        end
    end
end)
menu.action(MISSION_ENTITY_perico, "佩里科岛：发电站 传送到我", {}, "\nModel Hash: 1650252819", function()
    local entity_list = GetEntity_ByModelHash("object", false, 1650252819)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, 0.5)
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
        end
    end
end)
menu.action(MISSION_ENTITY_perico, "佩里科岛：保安服 传送到我", {}, "\nModel Hash: -1141961823",
    function()
        local entity_list = GetEntity_ByModelHash("object", false, -1141961823)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ME(ent, 0.0, 2.0, -1.0)
            end
        end
    end)
menu.action(MISSION_ENTITY_perico, "佩里科岛：螺旋切割器 传送到我", {}, "\nModel Hash: -710382954",
    function()
        local entity_list = GetEntity_ByModelHash("pickup", false, -710382954)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ME(ent, 0.0, 2.0, -1.0)
            end
        end
    end)
menu.action(MISSION_ENTITY_perico, "佩里科岛：抓钩 传送到我", {}, "\nModel Hash: -1789904450", function()
    local entity_list = GetEntity_ByModelHash("pickup", false, -1789904450)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, -1.0)
        end
    end
end)
menu.action(MISSION_ENTITY_perico, "佩里科岛：运货卡车 传送到我", {}, "自动删除npc卡车司机\nModel Hash: 2014313426"
    , function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, 2014313426)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
            TP_INTO_VEHICLE(ent, "", "delete")
        end
    end
end)

----- 赌场抢劫 -----
local MISSION_ENTITY_casion = menu.list(MISSION_ENTITY, "赌场抢劫", {}, "")

menu.action(MISSION_ENTITY_casion, "侦查：保安 传送到我", {}, "侦查前置\nModel Hash: -1094177627",
    function()
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
    { 1146.7454, 243.3848, -51.0408 }
}
menu.slider(MISSION_ENTITY_casion, "侦查：赌场 传送到骇入位置", {}, "进入赌场后再传送", 1, 2, 1, 1,
    function(value)
        local pos = casion_invest_pos[value]
        TELEPORT(pos[1], pos[2], pos[3])
    end)

menu.divider(MISSION_ENTITY_casion, "")
menu.action(MISSION_ENTITY_casion, "前置：武器(车) 传送到我", {}, "国安局面包车 武器在防暴车内\nModel Hash: 1885839156"
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
menu.action(MISSION_ENTITY_casion, "前置：武器 传送到我", {}, "摩托车帮 长方形板条\nModel Hash: 798951501"
    , function()
    local entity_list = GetEntity_ByModelHash("pickup", true, 798951501)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, -1.0)
        end
    end
end)
menu.action(MISSION_ENTITY_casion, "前置：武器(飞机) 传送到驾驶位", {}, "走私犯 水上飞机\nModel Hash: 1043222410"
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
menu.action(MISSION_ENTITY_casion, "前置：载具 传送到我", {}, "天威 经典版\nModel Hash: 931280609",
    function()
        local entity_list = GetEntity_ByModelHash("vehicle", true, 931280609)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ME(ent, 0.0, 2.0, -1.0)
                SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
                TP_INTO_VEHICLE(ent, "", "delete")
            end
        end
    end)
menu.action(MISSION_ENTITY_casion, "前置：骇入装置 传送到我", {},
    "FIB大楼 电脑旁边 提箱\n或者 国安局总部 服务器或桌子旁边\nModel Hash: -155327337",
    function()
        local entity_list = GetEntity_ByModelHash("pickup", true, -155327337)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ME(ent, 0.0, 2.0, -1.0)
            end
        end
    end)
menu.action(MISSION_ENTITY_casion, "前置：金库门禁卡(狱警) 传送到我", {},
    "监狱巴士 监狱 狱警\nModel Hash: 1456041926", function()
    local entity_list = GetEntity_ByModelHash("ped", true, 1456041926)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, -1.0)
        end
    end
end)
menu.action(MISSION_ENTITY_casion, "前置：巡逻路线(车) 传送到我", {}, "某辆车后备箱里的箱子\nModel Hash: 1265214509"
    , function()
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
menu.action(MISSION_ENTITY_casion, "前置：杜根货物 全部爆炸", {},
    "直升机 车 船\n一次性炸不完，多炸几次\nModel Hash: -1671539132, 1747439474, 1448677353",
    function()
        local entity_list = GetEntity_ByModelHash("vehicle", true, -1671539132, 1747439474, 1448677353)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                local pos = ENTITY.GET_ENTITY_COORDS(ent)
                FIRE.ADD_OWNED_EXPLOSION(players.user_ped(), pos.x, pos.y, pos.z - 0.5, EXP_TAG_STICKYBOMB, 5.0, true,
                    false
                    , 0, false)
            end
        end
    end)
menu.action(MISSION_ENTITY_casion, "前置：电钻 传送到那里", {}, "工地 箱子里的电钻\nModel Hash: -12990308"
    , function()
    local entity_list = GetEntity_ByModelHash("pickup", true, -12990308)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, 0.0, 0.5)
        end
    end
end)
menu.action(MISSION_ENTITY_casion, "前置：二级保安证(尸体) 传送到那里", {},
    "灵车 医院 泊车员尸体\nModel Hash: 771433594", function()
    local entity_list = GetEntity_ByModelHash("object", true, 771433594)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, 0.0, 0.5)
        end
    end
end)
menu.action(MISSION_ENTITY_casion, "前置：二级保安证 传送到我", {}, "聚会 小卡片\nModel Hash: -2018799718"
    , function()
    local entity_list = GetEntity_ByModelHash("pickup", true, -2018799718)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 1.0, 0.0)
        end
    end
end)

menu.divider(MISSION_ENTITY_casion, "隐迹潜踪")
menu.action(MISSION_ENTITY_casion, "前置：无人机零件 传送到我", {},
    "炸掉无人机，传送掉落的零件\nModel Hash: 1657647215, -1285013058", function()
    --Model Hash: 1657647215 纳米无人机 (object)
    --Model Hash: -1285013058 无人机炸毁后掉落的零件（pickup）
    local entity_list = GetEntity_ByModelHash("object", true, 1657647215)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            local pos = ENTITY.GET_ENTITY_COORDS(ent)
            FIRE.ADD_OWNED_EXPLOSION(players.user_ped(), pos.x, pos.y, pos.z - 0.5, EXP_TAG_STICKYBOMB, 5.0, true, false
                , 0, false)
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
menu.action(MISSION_ENTITY_casion, "前置：金库激光器 传送到我", {}, "\nModel Hash: 1953119208", function()
    local entity_list = GetEntity_ByModelHash("pickup", true, 1953119208)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, -1.0)
        end
    end
end)

menu.divider(MISSION_ENTITY_casion, "兵不厌诈")
menu.action(MISSION_ENTITY_casion, "前置：古倍科技套装 传送到我", {}, "\nModel Hash: 1425667258",
    function()
        local entity_list = GetEntity_ByModelHash("pickup", true, 1425667258)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ME(ent, 0.0, 2.0, -1.0)
            end
        end
    end)
menu.action(MISSION_ENTITY_casion, "前置：金库钻孔机 传送到我", {}, "全福银行\nModel Hash: 415149220",
    function()
        local entity_list = GetEntity_ByModelHash("pickup", true, 415149220)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ME(ent, 0.0, 2.0, -1.0)
            end
        end
    end)
menu.action(MISSION_ENTITY_casion, "前置：国安局套装 传送到我", {}, "警察局\nModel Hash: -1713985235",
    function()
        local entity_list = GetEntity_ByModelHash("pickup", true, -1713985235)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ME(ent, 0.0, 2.0, -1.0)
            end
        end
    end)

menu.divider(MISSION_ENTITY_casion, "气势汹汹")
menu.action(MISSION_ENTITY_casion, "前置：热能炸药 传送到我", {}, "\nModel Hash: -2043162923", function()
    local entity_list = GetEntity_ByModelHash("pickup", true, -2043162923)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, -1.0)
        end
    end
end)
menu.action(MISSION_ENTITY_casion, "前置：金库炸药 传送到我", {}, "要潜水下去 难找恶心\nModel Hash: -681938663"
    , function()
    local entity_list = GetEntity_ByModelHash("pickup", true, -681938663)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, -1.0)
        end
    end
end)
menu.action(MISSION_ENTITY_casion, "前置：加固防弹衣 传送到我", {}, "地堡 箱子\nModel Hash: 1715697304",
    function()
        local entity_list = GetEntity_ByModelHash("pickup", true, 1715697304)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ME(ent, 0.0, 2.0, 0.0)
            end
        end
    end)

menu.divider(MISSION_ENTITY_casion, "")
menu.action(MISSION_ENTITY_casion, "赌场：小金库手推车 传送到那里", {}, "\nModel Hash: 1736112330",
    function()
        local entity_list = GetEntity_ByModelHash("object", true, 1736112330)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ENTITY(ent, 0.0, 0.0, 0.5)
            end
        end
    end)

menu.action(MISSION_ENTITY_casion, "赌场：获取金库内手推车数量", {},
    "先获取手推车数量才能传送\nModel Hash: 412463629, 1171655821, 1401432049", function()
    -- 手推车 实体list
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

menu_Vault_Trolley_TP = menu.click_slider(MISSION_ENTITY_casion, "赌场：金库内手推车 传送到那里", {}, "", 0
    , 0, 0, 1, function(value)
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

--- 合约 别惹德瑞 ---
local MISSION_ENTITY_contract = menu.list(MISSION_ENTITY, "别惹德瑞", {}, "")

menu.divider(MISSION_ENTITY_contract, "夜生活泄密")
menu.action(MISSION_ENTITY_contract, "夜总会：传送到录像带", {}, "", function()
    TELEPORT(-1617.9883, -3013.7363, -75.20509)
    ENTITY.SET_ENTITY_HEADING(players.user_ped(), 203.7907)
end)
menu.action(MISSION_ENTITY_contract, "船坞：传送到船里", {}, "绿色的船\nModel Hash: 908897389", function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, 908897389)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_INTO_VEHICLE(ent)
        end
    end
end)
menu.action(MISSION_ENTITY_contract, "船坞：传送到证据", {}, "德瑞照片\nModel Hash: -1702870637",
    function()
        local entity_list = GetEntity_ByModelHash("object", true, -1702870637)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ENTITY(ent, 0.0, 0.0, 0.5)
            end
        end
    end)
menu.action(MISSION_ENTITY_contract, "夜生活泄密：传送到抢夺电脑", {}, "", function()
    TELEPORT(944.01764, 7.9015555, 116.1642)
    ENTITY.SET_ENTITY_HEADING(players.user_ped(), 279.8804)
end)

menu.divider(MISSION_ENTITY_contract, "上流社会泄密")
menu.action(MISSION_ENTITY_contract, "乡村俱乐部：炸掉礼车", {}, "\nModel Hash: -420911112", function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, -420911112)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            local pos = ENTITY.GET_ENTITY_COORDS(ent)
            FIRE.ADD_OWNED_EXPLOSION(players.user_ped(), pos.x, pos.y, pos.z - 0.5, EXP_TAG_STICKYBOMB, 5.0, true, false
                , 0, false)
        end
    end
end)
menu.action(MISSION_ENTITY_contract, "乡村俱乐部：门禁 传送到我", {}, "车内NPC\nModel Hash: -912318012",
    function()
        local entity_list = GetEntity_ByModelHash("ped", true, -912318012)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ME(ent, 0.0, 2.0, -1.0)
            end
        end
    end)
menu.action(MISSION_ENTITY_contract, "宾客名单：律师 传送到我", {}, "\nModel Hash: 600300561", function()
    local entity_list = GetEntity_ByModelHash("ped", true, 600300561)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, -1.0)
        end
    end
end)
menu.action(MISSION_ENTITY_contract, "上流社会泄密：炸掉直升机", {}, "\nModel Hash: 1075432268",
    function()
        local entity_list = GetEntity_ByModelHash("vehicle", true, 1075432268)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                local pos = ENTITY.GET_ENTITY_COORDS(ent)
                FIRE.ADD_OWNED_EXPLOSION(players.user_ped(), pos.x, pos.y, pos.z - 0.5, EXP_TAG_STICKYBOMB, 5.0, true,
                    false, 0, false)
            end
        end
    end)
menu.action(MISSION_ENTITY_contract, "上流社会泄密：坐进直升机", {}, "\nModel Hash: 1075432268",
    function()
        local entity_list = GetEntity_ByModelHash("vehicle", true, 1075432268)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                PED.SET_PED_INTO_VEHICLE(players.user_ped(), ent, -2)
            end
        end
    end)

menu.divider(MISSION_ENTITY_contract, "南中心区泄密")
menu.action(MISSION_ENTITY_contract, "强化弗农", {}, "\nModel Hash: -843935326", function()
    local entity_list = GetEntity_ByModelHash("ped", true, -843935326)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            control_ped_enhanced(ent)
            util.toast("Done!")
        end
    end
end)
menu.action(MISSION_ENTITY_contract, "南中心区泄密：底盘车 传送到我", {}, "\nModel Hash: -1013450936",
    function()
        local entity_list = GetEntity_ByModelHash("vehicle", true, -1013450936)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ME(ent, 0.0, 2.0, -1.0)
                SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
                TP_INTO_VEHICLE(ent, "", "tp")
                ENTITY.SET_ENTITY_HEALTH(ent, 10000)
            end
        end
    end)

----- 富兰克林电话任务 -----
local MISSION_ENTITY_payphone = menu.list(MISSION_ENTITY, "富兰克林电话任务", {}, "")

local MISSION_ENTITY_payphone_remove = menu.list(MISSION_ENTITY_payphone, "移除冷却时间", {}, "来自Heist Control")
menu.toggle_loop(MISSION_ENTITY_payphone_remove, "跳过电话暗杀和合约的冷却", { "hcagccoolhit" },
    "Make sure enabled before starting any contract or hit.", function()
        SET_INT_GLOBAL(262145 + 31689, 0) -- -1462622971
        SET_INT_GLOBAL(262145 + 31753, 0) -- -2036534141
    end, function()
    SET_INT_GLOBAL(262145 + 31689, 300000)
    SET_INT_GLOBAL(262145 + 31753, 500)
end)
menu.toggle_loop(MISSION_ENTITY_payphone_remove, "移除安保合约任务冷却", { "hcagcremcool" }, "", function()
    SET_INT_GLOBAL(262145 + 31769, 0) -- 1872071131
end, function()
    SET_INT_GLOBAL(262145 + 31769, 1200000)
end)

menu.action(MISSION_ENTITY_payphone, "TP to Payphone", { "tppayphone" },
    "Teleport to Payphone (must have called Franklin already)", function()
    local payPhon = HUD.GET_BLIP_COORDS(HUD.GET_NEXT_BLIP_INFO_ID(817))
    HUD.GET_BLIP_COORDS(HUD.GET_NEXT_BLIP_INFO_ID(817))
    if payPhon.x == 0 and payPhon.y == 0 and payPhon.z == 0 then
        util.toast("No Payhone Found")
    else
        ENTITY.SET_ENTITY_COORDS(players.user_ped(), payPhon.x, payPhon.y, payPhon.z + 1, false, false, false, false)
    end
end)

menu.divider(MISSION_ENTITY_payphone, "安保合约")

menu.action(MISSION_ENTITY_payphone, "回收贵重物品：保险箱 传送到那里", {}, "\nModel Hash: -798293264",
    function()
        local entity_list = GetEntity_ByModelHash("object", true, -798293264)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ENTITY(ent, 0.0, -0.5, 0.0)
                SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ent)
            end
        end
    end)
menu.action(MISSION_ENTITY_payphone, "回收贵重物品：保险箱密码 传送到那里", {},
    "\nModel Hash: 367638847", function()
    local entity_list = GetEntity_ByModelHash("object", true, 367638847)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, 0.0, 0.5)
        end
    end
end)
menu.action(MISSION_ENTITY_payphone, "变现资产：坐进要跟踪的车", {}, "亚美尼亚帮\nModel Hash: -1485523546"
    , function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, -1485523546)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), ent, -2)
        end
    end
end)
menu.action(MISSION_ENTITY_payphone, "变现资产：要跟踪的摩托车 加速", {},
    "失落摩托帮，狗仔队\nModel Hash: 1330042375, -322270187", function()
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
menu.action(MISSION_ENTITY_payphone, "资产保护：酒桶&木箱&设备 无敌", {},
    "\nModel Hash: -1597216682, 1329706303, 1503555850, -534405572", function()
    local entity_list = GetEntity_ByModelHash("object", true, -1597216682, 1329706303, 1503555850, -534405572)
    local i = 0
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            ENTITY.SET_ENTITY_INVINCIBLE(ent, true)
            ENTITY.SET_ENTITY_PROOFS(ent, true, true, true, true, true, true, true, true)
            i = i + 1
        end
    end
    util.toast("Done!\nNumber: " .. i)
end)
menu.action(MISSION_ENTITY_payphone, "资产保护：保安 无敌强化", {}, "\nModel Hash: -1575488699, -634611634",
    function()
        local entity_list = GetEntity_ByModelHash("ped", true, -1575488699, -634611634)
        local i = 0
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                local weaponHash = util.joaat("WEAPON_SPECIALCARBINE")
                WEAPON.GIVE_WEAPON_TO_PED(ent, weaponHash, -1, false, true)
                WEAPON.SET_CURRENT_PED_WEAPON(ent, weaponHash, false)
                control_ped_enhanced(ent)
                i = i + 1
            end
        end
        util.toast("Done!\nNumber: " .. i)
    end)
menu.action(MISSION_ENTITY_payphone, "救援行动：客户 传送到那里", {},
    "\nModel Hash: -2076336881, -1589423867", function()
    local entity_list = GetEntity_ByModelHash("ped", true, -2076336881, -1589423867)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            ENTITY.SET_ENTITY_INVINCIBLE(ent, true)
            ENTITY.SET_ENTITY_PROOFS(ent, true, true, true, true, true, true, true, true)

            TP_TO_ENTITY(ent, 0.0, 0.5, 0.0)
        end
    end
end)
menu.action(MISSION_ENTITY_payphone, "载具回收：厢形车 传送到驾驶位", {},
    "人道实验室 失窃动物\nModel Hash: 485150676", function()
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
menu.action(MISSION_ENTITY_payphone, "载具回收：摩托车 传送到我", {}, "\nModel Hash: 1993851908, 1353120668"
    , function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, 1993851908, 1353120668)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 1.0, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
            TP_INTO_VEHICLE(ent)
        end
    end
end)
menu.action(MISSION_ENTITY_payphone, "载具回收：机库门锁 传送到那里", {}, "\nModel Hash: 1556427679",
    function()
        TELEPORT(-1249.1301, -2979.6404, -48.49219)
        ENTITY.SET_ENTITY_HEADING(players.user_ped(), 269.879)
    end)

--- 摩托帮合约 ---
local MISSION_ENTITY_mc = menu.list(MISSION_ENTITY, "摩托帮合约", {}, "")

menu.action(MISSION_ENTITY_mc, "TP to MC Product", { "tpMCproduct" }, "Teleport to Motor Cycle Club Product Pickup/Sale"
    , function()
    local pPickup = HUD.GET_BLIP_COORDS(HUD.GET_NEXT_BLIP_INFO_ID(501))
    local hPickup = HUD.GET_BLIP_COORDS(HUD.GET_NEXT_BLIP_INFO_ID(64))
    local bPickup = HUD.GET_BLIP_COORDS(HUD.GET_NEXT_BLIP_INFO_ID(427))
    local plPickup = HUD.GET_BLIP_COORDS(HUD.GET_NEXT_BLIP_INFO_ID(423))
    if pPickup.x == 0 and pPickup.y == 0 and pPickup.z == 0 then
    elseif pPickup.x ~= 0 and pPickup.y ~= 0 and pPickup.z ~= 0 then
        ENTITY.SET_ENTITY_COORDS(players.user_ped(), pPickup.x - 1.5, pPickup.y, pPickup.z, false, false, false, false)
        util.toast("TP to MC Product")
    end
    if hPickup.x == 0 and hPickup.y == 0 and hPickup.z == 0 then
    elseif hPickup.x ~= 0 and hPickup.y ~= 0 and hPickup.z ~= 0 then
        ENTITY.SET_ENTITY_COORDS(players.user_ped(), hPickup.x - 1.5, hPickup.y, hPickup.z, false, false, false, false)
        util.toast("TP to Heli")
    end
    if bPickup.x == 0 and bPickup.y == 0 and bPickup.z == 0 then
    elseif bPickup.x ~= 0 and bPickup.y ~= 0 and bPickup.z ~= 0 then
        ENTITY.SET_ENTITY_COORDS(players.user_ped(), bPickup.x, bPickup.y, bPickup.z + 1.0, false, false, false, false)
        util.toast("TP to Boat")
    end
    if plPickup.x == 0 and plPickup.y == 0 and plPickup.z == 0 then
    elseif plPickup.x ~= 0 and plPickup.y ~= 0 and plPickup.z ~= 0 then
        ENTITY.SET_ENTITY_COORDS(players.user_ped(), plPickup.x, plPickup.y + 1.5, plPickup.z - 1, false, false, false,
            false)
        util.toast("TP to Plane")
    else
        util.toast("No MC Product Found")
    end
end)

menu.action(MISSION_ENTITY_mc, "回收暴君：传送到 割据", {}, "\nModel Hash: 339736694", function()
    local entity_list = GetEntity_ByModelHash("object", true, 339736694)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, -0.8, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ent)
        end
    end
end)
menu.action(MISSION_ENTITY_mc, "回收暴君：传送到 暴君钥匙", {}, "\nModel Hash: 2105669131", function()
    local entity_list = GetEntity_ByModelHash("object", true, 2105669131)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, -0.8, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ent)
        end
    end
end)
menu.action(MISSION_ENTITY_mc, "回收暴君：传送到 货箱", {}, "有暴君的货箱\nModel Hash: 884483972",
    function()
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

------------------------
--- 自定义 Model Hash ---
------------------------
local MISSION_ENTITY_custom = menu.list(MISSION_ENTITY, "自定义 Model Hash", {}, "")

local custom_model_hash
menu.text_input(MISSION_ENTITY_custom, "输入 Model Hash ", { "custom_model_hash" }, "", function(value)
    custom_model_hash = tonumber(value)
end)

menu.action(MISSION_ENTITY_custom, "转换复制内容", {}, "删除Model Hash: \n便于直接粘贴Ctrl+V",
    function()
        local text = util.get_clipboard_text()
        local num = string.gsub(text, "Model Hash: ", "")
        util.copy_to_clipboard(num, false)
        util.toast("Copied!\n" .. num)
    end)

local custom_entity_type = "Ped"
menu.slider_text(MISSION_ENTITY_custom, "实体类型", {}, "点击应用修改",
    { "Ped", "Vehicle", "Object", "Pickup" }, function(value)
    if value == 1 then
        custom_entity_type = "Ped"
    elseif value == 2 then
        custom_entity_type = "Vehicle"
    elseif value == 3 then
        custom_entity_type = "Object"
    elseif value == 4 then
        custom_entity_type = "Pickup"
    end
    util.toast(custom_entity_type)
end)
local custom_isMission = true
menu.toggle(MISSION_ENTITY_custom, "IS A MISSION ENTITY", {}, "是否为任务实体", function(toggle)
    custom_isMission = toggle
end, true)
---
menu.divider(MISSION_ENTITY_custom, "")

local function Init_custom_hash_ent_list()
    -- 自定义hash的实体 list
    custom_hash_ent_list = {}
    -- 自定义hash实体列表 menu.list
    custom_hash_ent_menu_list = {}
    -- 自定义hash所有实体 menu.list
    custom_hash_all_ent_menu_list = {}
end

Init_custom_hash_ent_list()

local function Clear_custom_hash_ent_list()
    if next(custom_hash_all_ent_menu_list) ~= nil then
        menu.delete(custom_hash_all_ent_menu_list[1])
        menu.delete(custom_hash_all_ent_menu_list[2])
    end
    for _, v in pairs(custom_hash_ent_menu_list) do
        if v ~= nil then
            menu.delete(v)
        end
    end
    Init_custom_hash_ent_list()
end

menu.action(MISSION_ENTITY_custom, "获取所有实体列表", {}, "", function()
    Clear_custom_hash_ent_list()
    ---
    local custom_all_entity
    if custom_entity_type == "Ped" then
        custom_all_entity = entities.get_all_peds_as_handles()
    elseif custom_entity_type == "Vehicle" then
        custom_all_entity = entities.get_all_vehicles_as_handles()
    elseif custom_entity_type == "Object" then
        custom_all_entity = entities.get_all_objects_as_handles()
    elseif custom_entity_type == "Pickup" then
        custom_all_entity = entities.get_all_pickups_as_handles()
    end
    ---
    if tonumber(custom_model_hash) ~= nil and STREAMING.IS_MODEL_VALID(tonumber(custom_model_hash)) then
        for k, ent2 in pairs(custom_all_entity) do
            local modelHash = ENTITY.GET_ENTITY_MODEL(ent2)
            if modelHash == custom_model_hash then
                local entity_info = "Hash: " .. modelHash .. " (" .. custom_entity_type .. ")"
                local text = "Model Name: " .. util.reverse_joaat(modelHash) .. "\nindex: " .. k

                local ent
                if custom_isMission then
                    if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent2) then
                        ent = ent2
                    end
                else
                    ent = ent2
                end
                -----
                if ent ~= nil then
                    table.insert(custom_hash_ent_list, ent)
                    local menu_custom_hash_ent = menu.list(MISSION_ENTITY_custom, entity_info, {}, text)
                    -- entity
                    entity_control_all(menu_custom_hash_ent, ent)
                    -- ped
                    if ENTITY.GET_ENTITY_TYPE(ent) == 1 then
                        entity_control_ped(menu_custom_hash_ent, tent)
                    end
                    -- vehicle
                    if ENTITY.GET_ENTITY_TYPE(ent) == 2 then
                        entity_control_vehicle(menu_custom_hash_ent, ent)
                    end
                    table.insert(custom_hash_ent_menu_list, menu_custom_hash_ent)
                end

            end
        end

        if next(custom_hash_ent_list) ~= nil then
            -- 全部实体
            custom_hash_all_ent_menu_list[1] = menu.divider(MISSION_ENTITY_custom, "")
            custom_hash_all_ent_menu_list[2] = menu.list(MISSION_ENTITY_custom, "全部实体管理", {}, "")
            all_entities_control(custom_hash_all_ent_menu_list[2], custom_hash_ent_list)
        else
            util.toast("No this entity !")
        end

    else
        util.toast("Wrong model hash !")
    end
end)

menu.action(MISSION_ENTITY_custom, "清空列表", {}, "", function()
    Clear_custom_hash_ent_list()
end)
menu.divider(MISSION_ENTITY_custom, "实体列表")

----------------------------------
------ All Mission Entities ------
----------------------------------
menu.divider(MISSION_ENTITY, "所有任务实体")

----- PED -----
local MISSION_ENTITY_all_npc = menu.list(MISSION_ENTITY, "所有任务NPC", {}, "")
menu.action(MISSION_ENTITY_all_npc, "任务NPC数量", {}, "", function()
    local mission_entity_num = 0
    for k, ent in pairs(entities.get_all_peds_as_handles()) do
        if not IS_PED_PLAYER(ent) and ent ~= PLAYER.PLAYER_PED_ID() then
            if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
                mission_entity_num = mission_entity_num + 1
            end
        end
    end
    util.toast("Number : " .. mission_entity_num)
end)

---
menu.divider(MISSION_ENTITY_all_npc, "")

local function Init_mission_npc_list()
    -- 任务实体 list
    mission_ent_npc_list = {}
    -- 任务实体列表 menu.list
    mission_ent_npc_menu_list = {}
    -- 所有任务实体 menu.list
    mission_ent_npc_all_menu_list = {}
end

Init_mission_npc_list()

local function Clear_mission_npc_list()
    if next(mission_ent_npc_all_menu_list) ~= nil then
        menu.delete(mission_ent_npc_all_menu_list[1])
        menu.delete(mission_ent_npc_all_menu_list[2])
    end
    for k, v in pairs(mission_ent_npc_menu_list) do
        if v ~= nil then
            menu.delete(v)
        end
    end
    Init_mission_npc_list()
end

menu.action(MISSION_ENTITY_all_npc, "获取所有任务NPC列表", {}, "", function()
    Clear_mission_npc_list()
    for k, ent in pairs(entities.get_all_peds_as_handles()) do
        if not IS_PED_PLAYER(ent) and ent ~= PLAYER.PLAYER_PED_ID() then
            if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
                table.insert(mission_ent_npc_list, ent)
                local modelHash = ENTITY.GET_ENTITY_MODEL(ent)
                local entity_info = "Hash: " .. modelHash
                if PED.IS_PED_IN_COMBAT(ent, PLAYER.PLAYER_ID()) then
                    entity_info = entity_info .. " (敌对)"
                end
                local text = "Model Name: " .. util.reverse_joaat(modelHash) .. "\nindex: " .. k
                --- 任务实体列表
                local menu_mission_entity_npc = menu.list(MISSION_ENTITY_all_npc, entity_info, {}, text)
                entity_control_all(menu_mission_entity_npc, ent)
                entity_control_ped(menu_mission_entity_npc, ent)
                table.insert(mission_ent_npc_menu_list, menu_mission_entity_npc)
            end
        end
    end
    --- 全部任务实体
    if next(mission_ent_npc_list) ~= nil then
        mission_ent_npc_all_menu_list[1] = menu.divider(MISSION_ENTITY_all_npc, "")
        mission_ent_npc_all_menu_list[2] = menu.list(MISSION_ENTITY_all_npc, "全部任务NPC管理", {}, "")
        all_entities_control(mission_ent_npc_all_menu_list[2], mission_ent_npc_list)
    end
end)

menu.action(MISSION_ENTITY_all_npc, "清空列表", {}, "", function()
    Clear_mission_npc_list()
end)
menu.divider(MISSION_ENTITY_all_npc, "任务NPC列表")

----- VEHICLE -----
local MISSION_ENTITY_all_vehicle = menu.list(MISSION_ENTITY, "所有任务载具", {}, "")
menu.action(MISSION_ENTITY_all_vehicle, "任务载具数量", {}, "", function()
    local mission_entity_num = 0
    for k, ent in pairs(entities.get_all_vehicles_as_handles()) do
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            mission_entity_num = mission_entity_num + 1
        end
    end
    util.toast("Number : " .. mission_entity_num)
end)

---
menu.divider(MISSION_ENTITY_all_vehicle, "")

local function Init_mission_vehicle_list()
    -- 任务实体 list
    mission_ent_vehicle_list = {}
    -- 任务实体列表 menu.list
    mission_ent_vehicle_menu_list = {}
    -- 所有任务实体 menu.list
    mission_ent_vehicle_all_menu_list = {}
end

Init_mission_vehicle_list()

local function Clear_mission_vehicle_list()
    if next(mission_ent_vehicle_all_menu_list) ~= nil then
        menu.delete(mission_ent_vehicle_all_menu_list[1])
        menu.delete(mission_ent_vehicle_all_menu_list[2])
    end
    for k, v in pairs(mission_ent_vehicle_menu_list) do
        if v ~= nil then
            menu.delete(v)
        end
    end
    Init_mission_vehicle_list()
end

menu.action(MISSION_ENTITY_all_vehicle, "获取所有任务载具列表", {}, "", function()
    Clear_mission_vehicle_list()
    for k, ent in pairs(entities.get_all_vehicles_as_handles()) do
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            table.insert(mission_ent_vehicle_list, ent)
            local modelHash = ENTITY.GET_ENTITY_MODEL(ent)
            local entity_info = "Hash: " .. modelHash
            local text = "Model Name: " .. util.reverse_joaat(modelHash) .. "\nindex: " .. k
            --- 任务实体列表
            local menu_mission_entity_vehicle = menu.list(MISSION_ENTITY_all_vehicle, entity_info, {}, text)
            entity_control_all(menu_mission_entity_vehicle, ent)
            entity_control_vehicle(menu_mission_entity_vehicle, ent)
            table.insert(mission_ent_vehicle_menu_list, menu_mission_entity_vehicle)
        end
    end
    --- 全部任务实体
    if next(mission_ent_vehicle_list) ~= nil then
        mission_ent_vehicle_all_menu_list[1] = menu.divider(MISSION_ENTITY_all_vehicle, "")
        mission_ent_vehicle_all_menu_list[2] = menu.list(MISSION_ENTITY_all_vehicle, "全部任务载具管理", {}, "")
        all_entities_control(mission_ent_vehicle_all_menu_list[2], mission_ent_vehicle_list)
    end
end)

menu.action(MISSION_ENTITY_all_vehicle, "清空列表", {}, "", function()
    Clear_mission_vehicle_list()
end)
menu.divider(MISSION_ENTITY_all_vehicle, "任务载具列表")

----- OBJECT -----
local MISSION_ENTITY_all_object = menu.list(MISSION_ENTITY, "所有任务物体", {}, "")
menu.action(MISSION_ENTITY_all_object, "任务物体数量", {}, "", function()
    local mission_entity_num = 0
    for k, ent in pairs(entities.get_all_objects_as_handles()) do
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            mission_entity_num = mission_entity_num + 1
        end
    end
    util.toast("Number : " .. mission_entity_num)
end)

---
menu.divider(MISSION_ENTITY_all_object, "")

local function Init_mission_object_list()
    -- 任务实体 list
    mission_ent_object_list = {}
    -- 任务实体列表 menu.list
    mission_ent_object_menu_list = {}
    -- 所有任务实体 menu.list
    mission_ent_object_all_menu_list = {}
end

Init_mission_object_list()

local function Clear_mission_object_list()
    if next(mission_ent_object_all_menu_list) ~= nil then
        menu.delete(mission_ent_object_all_menu_list[1])
        menu.delete(mission_ent_object_all_menu_list[2])
    end
    for k, v in pairs(mission_ent_object_menu_list) do
        if v ~= nil then
            menu.delete(v)
        end
    end
    Init_mission_object_list()
end

menu.action(MISSION_ENTITY_all_object, "获取所有任务物体列表", {}, "", function()
    Clear_mission_object_list()
    for k, ent in pairs(entities.get_all_objects_as_handles()) do
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            table.insert(mission_ent_object_list, ent)
            local modelHash = ENTITY.GET_ENTITY_MODEL(ent)
            local entity_info = "Hash: " .. modelHash
            local text = "Model Name: " .. util.reverse_joaat(modelHash) .. "\nindex: " .. k
            --- 任务实体列表
            local menu_mission_entity_object = menu.list(MISSION_ENTITY_all_object, entity_info, {}, text)
            entity_control_all(menu_mission_entity_object, ent)
            table.insert(mission_ent_object_menu_list, menu_mission_entity_object)
        end
    end
    --- 全部任务实体
    if next(mission_ent_object_list) ~= nil then
        mission_ent_object_all_menu_list[1] = menu.divider(MISSION_ENTITY_all_object, "")
        mission_ent_object_all_menu_list[2] = menu.list(MISSION_ENTITY_all_object, "全部任务物体管理", {}, "")
        all_entities_control(mission_ent_object_all_menu_list[2], mission_ent_object_list)
    end
end)

menu.action(MISSION_ENTITY_all_object, "清空列表", {}, "", function()
    Clear_mission_object_list()
end)
menu.divider(MISSION_ENTITY_all_object, "任务物体列表")

----- PICKUP -----
local MISSION_ENTITY_all_pickup = menu.list(MISSION_ENTITY, "所有任务拾取物", {}, "")
menu.action(MISSION_ENTITY_all_pickup, "任务拾取物数量", {}, "", function()
    local mission_entity_num = 0
    for k, ent in pairs(entities.get_all_pickups_as_handles()) do
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            mission_entity_num = mission_entity_num + 1
        end
    end
    util.toast("Number : " .. mission_entity_num)
end)

---
menu.divider(MISSION_ENTITY_all_pickup, "")

local function Init_mission_pickup_list()
    -- 任务实体 list
    mission_ent_pickup_list = {}
    -- 任务实体列表 menu.list
    mission_ent_pickup_menu_list = {}
    -- 所有任务实体 menu.list
    mission_ent_pickup_all_menu_list = {}
end

Init_mission_pickup_list()

local function Clear_mission_pickup_list()
    if next(mission_ent_pickup_all_menu_list) ~= nil then
        menu.delete(mission_ent_pickup_all_menu_list[1])
        menu.delete(mission_ent_pickup_all_menu_list[2])
    end
    for k, v in pairs(mission_ent_pickup_menu_list) do
        if v ~= nil then
            menu.delete(v)
        end
    end
    Init_mission_pickup_list()
end

menu.action(MISSION_ENTITY_all_pickup, "获取所有任务拾取物列表", {}, "", function()
    Clear_mission_pickup_list()
    for k, ent in pairs(entities.get_all_pickups_as_handles()) do
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            table.insert(mission_ent_pickup_list, ent)
            local modelHash = ENTITY.GET_ENTITY_MODEL(ent)
            local entity_info = "Hash: " .. modelHash
            local text = "Model Name: " .. util.reverse_joaat(modelHash) .. "\nindex: " .. k
            --- 任务实体列表
            local menu_mission_entity_pickup = menu.list(MISSION_ENTITY_all_pickup, entity_info, {}, text)
            entity_control_all(menu_mission_entity_pickup, ent)
            table.insert(mission_ent_pickup_menu_list, menu_mission_entity_pickup)
        end
    end
    --- 全部任务实体
    if next(mission_ent_pickup_list) ~= nil then
        mission_ent_pickup_all_menu_list[1] = menu.divider(MISSION_ENTITY_all_pickup, "")
        mission_ent_pickup_all_menu_list[2] = menu.list(MISSION_ENTITY_all_pickup, "全部任务拾取物管理", {}, "")
        all_entities_control(mission_ent_pickup_all_menu_list[2], mission_ent_pickup_list)
    end
end)

menu.action(MISSION_ENTITY_all_pickup, "清空列表", {}, "", function()
    Clear_mission_pickup_list()
end)
menu.divider(MISSION_ENTITY_all_pickup, "任务拾取物列表")

---

menu.divider(Entity_options, "")
--------------------
----- 实体信息枪 -----
--------------------
local Entity_Info_Gun = menu.list(Entity_options, "实体信息枪", {}, "获取瞄准射击的实体信息")

local isLog_entity_info = false
local isShow_onScreen = false
local entity_info_menu_list = {} --查看实体信息 menu.action
local entity_info_list = {} -- 实体信息 list
menu.toggle_loop(Entity_Info_Gun, "开启", {}, "", function()
    local ent = GetEntity_PlayerIsAimingAt(players.user())
    if ent ~= nil and ENTITY.DOES_ENTITY_EXIST(ent) then
        entity_info_list = GetEntityInfo_List(ent)

        for i = 1, EntityInfo_List_MAX_SIZE do
            if entity_info_list[i] ~= nil then
                menu.set_menu_name(entity_info_menu_list[i], entity_info_list[i])
            end
        end

        -- 记录到日志
        if isLog_entity_info then
            local text = ""
            for k, info in pairs(entity_info_list) do
                if info ~= nil then
                    text = text .. info .. "\n"
                end
            end
            util.log(text)
        end

        --显示在屏幕上
        if isShow_onScreen then
            local text = ""
            for k, info in pairs(entity_info_list) do
                if info ~= nil then
                    text = text .. info .. "\n"
                end
            end
            directx.draw_text(0.5, 0.0, text, ALIGN_TOP_LEFT, 0.8, color.purple)
        end
    end
end)

menu.toggle(Entity_Info_Gun, "显示在屏幕上", {}, "", function(toggle)
    isShow_onScreen = toggle
end)
menu.toggle(Entity_Info_Gun, "记录到日志", {}, "", function(toggle)
    isLog_entity_info = toggle
end)

menu.action(Entity_Info_Gun, "实体信息保存到日志", {}, "", function()
    local text = ""
    for k, info in pairs(entity_info_list) do
        if info ~= nil then
            text = text .. info .. "\n"
        end
    end
    util.log(text)
    util.toast("完成")
end)
menu.action(Entity_Info_Gun, "-> 复制实体信息 <-", {}, "", function()
    local text = ""
    for k, info in pairs(entity_info_list) do
        if info ~= nil then
            text = text .. info .. "\n"
        end
    end
    util.copy_to_clipboard(text, false)
    util.toast("完成")
end)

menu.divider(Entity_Info_Gun, "实体信息查看")
for i = 1, EntityInfo_List_MAX_SIZE do
    entity_info_menu_list[i] = menu.action(Entity_Info_Gun, "", {}, "", function()
        local menu_name = menu.get_menu_name(entity_info_menu_list[i])
        util.copy_to_clipboard(menu_name, false)
        util.toast("Copied!\n" .. menu_name)
    end)
end

--------------------------------
------------ 保镖选项 ------------
--------------------------------
local Bodyguard_options = menu.list(menu.my_root(), "保镖选项", {}, "")

--- Relationship Functions ---
local function addRelationshipGroup(name)
    local ptr = memory.alloc_int()
    PED.ADD_RELATIONSHIP_GROUP(name, ptr)
    local rel = memory.read_int(ptr)
    memory.free(ptr)
    return rel
end

relationship = {}
function relationship:friendly(ped)
    if not PED._DOES_RELATIONSHIP_GROUP_EXIST(self.friendly_group) then
        self.friendly_group = addRelationshipGroup("friendly_group")
        PED.SET_RELATIONSHIP_BETWEEN_GROUPS(0, self.friendly_group, self.friendly_group)
    end
    PED.SET_PED_RELATIONSHIP_GROUP_HASH(ped, self.friendly_group)
end

----- 保镖直升机 -----
local Bodyguard_Heli_options = menu.list(Bodyguard_options, "保镖直升机", {}, "")

local heli_list = {} --生成的直升机
local heli_ped_list = {} --直升机内的保镖

local bodyguard_heli = {
    name = "valkyrie",
    heli_godmode = false,
    ped_godmode = false
}

local sel_heli_name_list = { "女武神", "秃鹰", "猎杀者" }
local sel_heli_model_list = { "valkyrie", "buzzard", "hunter" }
menu.slider_text(Bodyguard_Heli_options, "直升机类型", {}, "", sel_heli_name_list, function(value)
    bodyguard_heli.name = sel_heli_model_list[value]
end)

menu.toggle(Bodyguard_Heli_options, "直升机无敌", {}, "", function(toggle)
    bodyguard_heli.heli_godmode = toggle
end)

menu.action(Bodyguard_Heli_options, "生成保镖直升机", {}, "", function()
    local heli_hash = util.joaat(bodyguard_heli.name)
    local ped_hash = util.joaat("s_m_y_blackops_01")
    local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    pos.x = pos.x + math.random(-10, 10)
    pos.y = pos.y + math.random(-10, 10)
    pos.z = pos.z + 30

    requestModels(ped_hash, heli_hash)
    relationship:friendly(players.user_ped())
    local heli = entities.create_vehicle(heli_hash, pos, CAM.GET_GAMEPLAY_CAM_ROT(0).z)

    if not ENTITY.DOES_ENTITY_EXIST(heli) then
        util.toast("Failed to create vehicle. Please try again")
        return
    else
        local heliNetId = NETWORK.VEH_TO_NET(heli)
        if NETWORK.NETWORK_GET_ENTITY_IS_NETWORKED(NETWORK.NET_TO_PED(heliNetId)) then
            NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(heliNetId, true)
            NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(heliNetId, players.user(), true)
        end
        VEHICLE.SET_VEHICLE_ENGINE_ON(heli, true, true, true)
        VEHICLE.SET_HELI_BLADES_FULL_SPEED(heli)
        VEHICLE.SET_VEHICLE_SEARCHLIGHT(heli, true, true)
        AddBlip_ForEntity(heli, 422, 26)
        --health
        ENTITY.SET_ENTITY_INVINCIBLE(heli, bodyguard_heli.heli_godmode)
        ENTITY.SET_ENTITY_MAX_HEALTH(heli, 10000)
        ENTITY.SET_ENTITY_HEALTH(heli, 10000)

        table.insert(heli_list, heli)
    end

    local pilot = entities.create_ped(29, ped_hash, pos, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
    PED.SET_PED_INTO_VEHICLE(pilot, heli, -1)
    PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(pilot, true)
    TASK.TASK_HELI_MISSION(pilot, heli, 0, players.user_ped(), 0.0, 0.0, 0.0, 23, 80.0, 50.0, -1.0, 0, 10, -1.0, 0)
    PED.SET_PED_KEEP_TASK(pilot, true)
    --health
    PED.SET_PED_MAX_HEALTH(pilot, 1000)
    ENTITY.SET_ENTITY_HEALTH(pilot, 1000)
    ENTITY.SET_ENTITY_INVINCIBLE(pilot, bodyguard_heli.ped_godmode)

    table.insert(heli_ped_list, pilot)

    --local seats = VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(heli)
    for seat = 0, 2 do
        local ped = entities.create_ped(29, ped_hash, pos, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
        local pedNetId = NETWORK.PED_TO_NET(ped)
        if NETWORK.NETWORK_GET_ENTITY_IS_NETWORKED(ped) then
            NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(pedNetId, true)
            NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(pedNetId, players.user(), true)
        end
        PED.SET_PED_INTO_VEHICLE(ped, heli, seat)
        --fight
        WEAPON.GIVE_WEAPON_TO_PED(ped, util.joaat("weapon_mg"), -1, false, true)
        WEAPON.SET_PED_INFINITE_AMMO_CLIP(ped, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 5, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 3, false)
        PED.SET_PED_COMBAT_MOVEMENT(ped, 2)
        PED.SET_PED_COMBAT_ABILITY(ped, 2)
        PED.SET_PED_COMBAT_RANGE(ped, 2)
        PED.SET_PED_SEEING_RANGE(ped, 500.0)
        PED.SET_PED_HEARING_RANGE(ped, 500.0)
        PED.SET_PED_TARGET_LOSS_RESPONSE(ped, 1)
        PED.SET_PED_HIGHLY_PERCEPTIVE(ped, true)
        PED.SET_PED_VISUAL_FIELD_PERIPHERAL_RANGE(ped, 500.0)
        PED.SET_COMBAT_FLOAT(ped, 10, 500.0)
        PED.SET_PED_SHOOT_RATE(ped, 1000.0)
        PED.SET_PED_ACCURACY(ped, 100.0)
        PED.SET_PED_CAN_BE_SHOT_IN_VEHICLE(ped, true)
        --health
        PED.SET_PED_MAX_HEALTH(ped, 1000)
        ENTITY.SET_ENTITY_HEALTH(ped, 1000)
        ENTITY.SET_ENTITY_INVINCIBLE(ped, bodyguard_heli.ped_godmode)

        relationship:friendly(ped)

        table.insert(heli_ped_list, ped)
    end

    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(heli_hash)
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(ped_hash)
end)

menu.divider(Bodyguard_Heli_options, "管理保镖直升机")
menu.action(Bodyguard_Heli_options, "与所有玩家友好", {}, "", function()
    local all_players = players.list(false, true, true)
    for k, pId in pairs(all_players) do
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        relationship:friendly(ped)
    end
end)
menu.toggle(Bodyguard_Heli_options, "所有保镖直升机无敌", {}, "", function(toggle)
    for k, ent in pairs(heli_ped_list) do
        ENTITY.SET_ENTITY_INVINCIBLE(ent, toggle)
    end
    for k, ent in pairs(heli_list) do
        ENTITY.SET_ENTITY_INVINCIBLE(ent, toggle)
    end
end)
menu.action(Bodyguard_Heli_options, "删除所有保镖直升机", {}, "", function()
    for k, ent in pairs(heli_ped_list) do
        entities.delete_by_handle(ent)
    end
    for k, ent in pairs(heli_list) do
        entities.delete_by_handle(ent)
    end
    heli_list = {} --生成的直升机
    heli_ped_list = {} --直升机内的保镖
end)


--------------------------------
------------ 保护选项 ------------
--------------------------------
local Protect_options = menu.list(menu.my_root(), "保护选项", {}, "")

menu.toggle_loop(Protect_options, "移除爆炸", {}, "", function()
    local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
    FIRE.STOP_FIRE_IN_RANGE(pos.x, pos.y, pos.z, 5.0)
end)
menu.toggle_loop(Protect_options, "移除粒子效果", {}, "", function()
    local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
    GRAPHICS.REMOVE_PARTICLE_FX_IN_RANGE(pos.x, pos.y, pos.z, 5.0)
end)


--------------------------------
------------ 任务选项 ------------
--------------------------------
local Mission_options = menu.list(menu.my_root(), "任务选项", {}, "")

--- 分红编辑 ---
local Heist_Cut_Editor = menu.list(Mission_options, "分红编辑", {}, "")

local cut_global_base = 1973321 + 823 + 56
menu.list_select(Heist_Cut_Editor, "当前抢劫", {}, "", { "佩里科岛", "赌场抢劫", "末日豪劫" }, 1,
    function(index)
        if index == 0 then
            cut_global_base = 1973321 + 823 + 56
        elseif index == 1 then
            cut_global_base = 1966534 + 2325
        elseif index == 2 then
            cut_global_base = 1962546 + 812 + 50
        end
        util.toast(cut_global_base)
    end)

menu.click_slider(Heist_Cut_Editor, "玩家1 (房主)", { "Cut_Edit_1" }, "", 0, 300, 85, 5, function(value)
    SET_INT_GLOBAL(cut_global_base + 1, value)
end)
menu.click_slider(Heist_Cut_Editor, "玩家2", { "Cut_Edit_2" }, "", 0, 300, 85, 5, function(value)
    SET_INT_GLOBAL(cut_global_base + 2, value)
end)
menu.click_slider(Heist_Cut_Editor, "玩家3", { "Cut_Edit_3" }, "", 0, 300, 85, 5, function(value)
    SET_INT_GLOBAL(cut_global_base + 3, value)
end)
menu.click_slider(Heist_Cut_Editor, "玩家4", { "Cut_Edit_4" }, "", 0, 300, 85, 5, function(value)
    SET_INT_GLOBAL(cut_global_base + 4, value)
end)

--- 赌场抢劫 ---
local Casion_Heist = menu.list(Mission_options, "赌场抢劫", {}, "Use for Heist Control")

menu.divider(Casion_Heist, "第二面板")
local Casion_Heist_Custom = menu.list(Casion_Heist, "自定义可选任务", {}, "")

local bitset0 = 0 --可选任务
local bitset0_add = {
    add1 = 0,
    add2 = 0,
    add3 = 0,
    add4 = 0,
    add5 = 0,
    add6 = 0,
    add7 = 0,
    add8 = 0,
    add9 = 0,
    add10 = 0,
    add11 = 0,
    add12 = 0,
    add13 = 0,
    add14 = 0,
    add15 = 0,
    add16 = 0
}

menu.toggle(Casion_Heist_Custom, "巡逻路线", {}, "", function(toggle)
    if toggle then
        bitset0_add.add1 = 2
    else
        bitset0_add.add1 = 0
    end
end)
menu.toggle(Casion_Heist_Custom, "杜根货物", {}, "是否会显示对钩而已", function(toggle)
    if toggle then
        bitset0_add.add2 = 4
    else
        bitset0_add.add2 = 0
    end
end)
menu.toggle(Casion_Heist_Custom, "电钻", {}, "", function(toggle)
    if toggle then
        bitset0_add.add3 = 16
    else
        bitset0_add.add3 = 0
    end
end)
menu.toggle(Casion_Heist_Custom, "枪手诱饵", {}, "", function(toggle)
    if toggle then
        bitset0_add.add4 = 64
    else
        bitset0_add.add4 = 0
    end
end)
menu.toggle(Casion_Heist_Custom, "更换载具", {}, "", function(toggle)
    if toggle then
        bitset0_add.add5 = 128
    else
        bitset0_add.add5 = 0
    end
end)

menu.divider(Casion_Heist_Custom, "隐迹潜踪")
menu.toggle(Casion_Heist_Custom, "潜入套装", {}, "", function(toggle)
    if toggle then
        bitset0_add.add6 = 8
    else
        bitset0_add.add6 = 0
    end
end)
menu.toggle(Casion_Heist_Custom, "电磁脉冲设备", {}, "", function(toggle)
    if toggle then
        bitset0_add.add7 = 32
    else
        bitset0_add.add7 = 0
    end
end)

menu.divider(Casion_Heist_Custom, "兵不厌诈")
menu.toggle(Casion_Heist_Custom, "进场：除虫大师", {}, "", function(toggle)
    if toggle then
        bitset0_add.add8 = 256 + 512
    else
        bitset0_add.add8 = 0
    end
end)
menu.toggle(Casion_Heist_Custom, "进场：维修工", {}, "", function(toggle)
    if toggle then
        bitset0_add.add9 = 1024 + 2048
    else
        bitset0_add.add9 = 0
    end
end)
menu.toggle(Casion_Heist_Custom, "进场：古倍科技", {}, "", function(toggle)
    if toggle then
        bitset0_add.add10 = 4096 + 8192
    else
        bitset0_add.add10 = 0
    end
end)
menu.toggle(Casion_Heist_Custom, "进场：名人", {}, "", function(toggle)
    if toggle then
        bitset0_add.add11 = 16384 + 32768
    else
        bitset0_add.add11 = 0
    end
end)
menu.toggle(Casion_Heist_Custom, "离场：国安局", {}, "", function(toggle)
    if toggle then
        bitset0_add.add12 = 65536
    else
        bitset0_add.add12 = 0
    end
end)
menu.toggle(Casion_Heist_Custom, "离场：消防员", {}, "", function(toggle)
    if toggle then
        bitset0_add.add13 = 131072
    else
        bitset0_add.add13 = 0
    end
end)
menu.toggle(Casion_Heist_Custom, "离场：豪赌客", {}, "", function(toggle)
    if toggle then
        bitset0_add.add14 = 262144
    else
        bitset0_add.add14 = 0
    end
end)

menu.divider(Casion_Heist_Custom, "气势汹汹")
menu.toggle(Casion_Heist_Custom, "加固防弹衣", {}, "", function(toggle)
    if toggle then
        bitset0_add.add15 = 1048576
    else
        bitset0_add.add15 = 0
    end
end)
menu.toggle(Casion_Heist_Custom, "镗床", {}, "", function(toggle)
    if toggle then
        bitset0_add.add16 = 2621440
    else
        bitset0_add.add16 = 0
    end
end)

menu.divider(Casion_Heist_Custom, "")
menu.action(Casion_Heist_Custom, "添加至BITSET0", {}, "", function()
    local sum = 0
    for _, i in pairs(bitset0_add) do
        sum = sum + i
    end
    bitset0 = sum
    util.toast("添加完成，当前值为： " .. bitset0)
end)

menu.divider(Casion_Heist, "BITSET0设置")
menu.action(Casion_Heist, "读取当前BITSET0变量值", {}, "", function()
    util.toast(bitset0)
end)
menu.slider(Casion_Heist, "自定义BITSET0变量值", { "bitset0" }, "", 0, 16777216, 0, 1, function(value)
    bitset0 = value
    util.toast("已修改为: " .. bitset0)
end)
menu.divider(Casion_Heist, "")
menu.action(Casion_Heist, "写入BITSET0变量值", {}, "写入到 H3OPT_BITSET0", function()
    STAT_SET_INT("H3OPT_BITSET0", bitset0)
    util.toast("已将 H3OPT_BITSET0 修改为: " .. bitset0)
end)

--- 修改生命数 ---
local Team_Lives = menu.list(Mission_options, "修改生命数", {}, "")

menu.divider(Team_Lives, "佩里科岛&末日&改装铺")
menu.action(Team_Lives, "获取当前生命数", {}, "", function()
    if SCRIPT.HAS_SCRIPT_LOADED("fm_mission_controller_2020") then
        local value = GET_INT_LOCAL("fm_mission_controller_2020", 44664 + 865 + 1)
        util.toast(value)
    else
        util.toast("This Script Has Not Loaded")
    end
end)

local team_live_cayo = 0
menu.click_slider(Team_Lives, "修改生命数", { "tlive_perico" }, "fm_mission_controller_2020", 0, 30000, 0, 1,
    function(value)
        team_live_cayo = value
        if SCRIPT.HAS_SCRIPT_LOADED("fm_mission_controller_2020") then
            SET_INT_LOCAL("fm_mission_controller_2020", 44664 + 865 + 1, team_live_cayo)
        else
            util.toast("This Script Has Not Loaded")
        end
    end)

menu.divider(Team_Lives, "赌场抢劫")
menu.action(Team_Lives, "获取当前生命数", {}, "", function()
    if SCRIPT.HAS_SCRIPT_LOADED("fm_mission_controller") then
        local value = GET_INT_LOCAL("fm_mission_controller", 26105 + 1322 + 1)
        util.toast(value)
    else
        util.toast("This Script Has Not Loaded")
    end
end)

local team_live_casino = 0
menu.click_slider(Team_Lives, "修改生命数", { "tlive_casino" }, "fm_mission_controller", 0, 30000, 0, 1,
    function(value)
        team_live_casino = value
        if SCRIPT.HAS_SCRIPT_LOADED("fm_mission_controller") then
            SET_INT_LOCAL("fm_mission_controller", 26105 + 1322 + 1, team_live_casino)
        else
            util.toast("This Script Has Not Loaded")
        end
    end)

--- 可调整项 ---
local Tuneables_options = menu.list(Mission_options, "可调整项", {}, "慎用")

local Tunables_Globals = {
    Auto_Shop_Contract_Setup = 262145 + 31669, -- -425845436 (float)
    Auto_Shop_Contract_Finale = 262145 + 31670, -- -394140353 (float)
    Exotic_Export_Delivery = 262145 + 31672, -- 1870939070 (float)
    -- -- VIP/CEO Work
    VIP_Work_Cooldown = 262145 + 13078, -- -1404265088
    -- Headhunter
    Headhunter_Cooldown = 262145 + 15523, -- 753551541
    Headhunter_Mission_Time = 262145 + 15528, -- -1167049029
    Headhunter_Bonus_Cash = 262145 + 15541, -- 1800540449
    -- Sightseer
    Sightseer_Mission_Time = 262145 + 12974, -- 1405724919
    Sightseer_Cooldown = 262145 + 12975, -- -1911318106
    Sightseer_Base_Cash = 262145 + 12978, -- 503107913
    Sightseer_Bonus_Cash = 262145 + 12980, -- 2032571281
    -- Payphone
    Payphone_Hit_Payment = 262145 + 31715, -- 1660338738
}
-----
local Tuneables_RepMultiplier = menu.list(Tuneables_options, "车友会声望", {}, "")
local tuneable_rep_mult = 1
menu.slider_float(Tuneables_RepMultiplier, "Multipliers", { "tuneable_rep_mult" }, "", 0, 500000, 100, 100,
    function(Value)
        tuneable_rep_mult = Value / 100
    end)
menu.toggle_loop(Tuneables_RepMultiplier, "改装铺合约 前置", {}, "", function()
    SET_FLOAT_GLOBAL(Tunables_Globals.Auto_Shop_Contract_Setup, tuneable_rep_mult)
end, function()
    SET_FLOAT_GLOBAL(Tunables_Globals.Auto_Shop_Contract_Setup, 1)
end)
menu.toggle_loop(Tuneables_RepMultiplier, "改装铺合约 终章", {}, "", function()
    SET_FLOAT_GLOBAL(Tunables_Globals.Auto_Shop_Contract_Finale, tuneable_rep_mult)
end, function()
    SET_FLOAT_GLOBAL(Tunables_Globals.Auto_Shop_Contract_Finale, 1)
end)
menu.toggle_loop(Tuneables_RepMultiplier, "每日载具出口", {}, "", function()
    SET_FLOAT_GLOBAL(Tunables_Globals.Exotic_Export_Delivery, tuneable_rep_mult)
end, function()
    SET_FLOAT_GLOBAL(Tunables_Globals.Exotic_Export_Delivery, 1)
end)
-----
local Tuneables_CeoWork = menu.list(Tuneables_options, "VIP/CEO 工作", {}, "")
local ceo_work_tuneables = {
    --Headhunter
    headhunter_bonus_cash = 500,
    --Sightseer
    sightseer_base_cash = 20000,
    sightseer_bonus_cash = 500,
}
menu.toggle_loop(Tuneables_CeoWork, "移除冷却时间", {}, "", function()
    SET_INT_GLOBAL(Tunables_Globals.VIP_Work_Cooldown, 0)
    SET_INT_GLOBAL(Tunables_Globals.Headhunter_Cooldown, 0)
    SET_INT_GLOBAL(Tunables_Globals.Sightseer_Cooldown, 0)
end, function()
    SET_INT_GLOBAL(Tunables_Globals.VIP_Work_Cooldown, 300000)
    SET_INT_GLOBAL(Tunables_Globals.Headhunter_Cooldown, 600000)
    SET_INT_GLOBAL(Tunables_Globals.Sightseer_Cooldown, 600000)
end)
menu.toggle_loop(Tuneables_CeoWork, "任务时间加倍(x10)", {}, "", function()
    SET_INT_GLOBAL(Tunables_Globals.Headhunter_Mission_Time, 9000000)
    SET_INT_GLOBAL(Tunables_Globals.Sightseer_Mission_Time, 9000000)
end, function()
    SET_INT_GLOBAL(Tunables_Globals.Headhunter_Mission_Time, 900000)
    SET_INT_GLOBAL(Tunables_Globals.Sightseer_Mission_Time, 900000)
end)
menu.divider(Tuneables_CeoWork, "猎杀专员")
menu.slider(Tuneables_CeoWork, "Bonus Cash", { "headhunter_bonus_cash" }, "", 0, 100000, 500, 100, function(value)
    ceo_work_tuneables.headhunter_bonus_cash = value
end)
menu.toggle_loop(Tuneables_CeoWork, "设置", {}, "", function()
    SET_INT_GLOBAL(Tunables_Globals.Headhunter_Bonus_Cash, ceo_work_tuneables.headhunter_bonus_cash)
end, function()
    SET_INT_GLOBAL(Tunables_Globals.Headhunter_Bonus_Cash, 500)
end)
menu.divider(Tuneables_CeoWork, "观光客")
menu.slider(Tuneables_CeoWork, "Base Cash", { "sightseer_base_cash" }, "", 0, 1000000, 20000, 100, function(value)
    ceo_work_tuneables.sightseer_base_cash = value
end)
menu.slider(Tuneables_CeoWork, "Bonus Cash", { "sightseer_bonus_cash" }, "", 0, 100000, 500, 100, function(value)
    ceo_work_tuneables.sightseer_bonus_cash = value
end)
menu.toggle_loop(Tuneables_CeoWork, "设置", {}, "", function()
    SET_INT_GLOBAL(Tunables_Globals.Sightseer_Base_Cash, ceo_work_tuneables.sightseer_base_cash)
    SET_INT_GLOBAL(Tunables_Globals.Sightseer_Bonus_Cash, ceo_work_tuneables.sightseer_bonus_cash)
end, function()
    SET_INT_GLOBAL(Tunables_Globals.Sightseer_Base_Cash, 20000)
    SET_INT_GLOBAL(Tunables_Globals.Sightseer_Bonus_Cash, 500)
end)
-----
local Tuneables_Payphone = menu.list(Tuneables_options, "电话暗杀", {}, "")
local payphone_hit_payment = 15000
menu.slider(Tuneables_Payphone, "Payphone Hit Payment", { "payphone_hit_payment" }, "", 0, 1000000, 15000, 1000,
    function(value)
        payphone_hit_payment = value
    end)
menu.toggle_loop(Tuneables_Payphone, "设置", {}, "", function()
    SET_INT_GLOBAL(Tunables_Globals.Payphone_Hit_Payment, payphone_hit_payment)
end, function()
    SET_INT_GLOBAL(Tunables_Globals.Payphone_Hit_Payment, 15000)
end)
-----

--- Local Editor ---
local Local_Editor = menu.list(Mission_options, "Local Editor", {}, "")

local mission_script = "fm_mission_controller"
menu.list_select(Local_Editor, "选择脚本", {}, "", {
    { "fm_mission_controller" },
    { "fm_mission_controller_2020" }
}, 1, function(index)
    if index == 1 then
        mission_script = "fm_mission_controller"
    elseif index == 2 then
        mission_script = "fm_mission_controller_2020"
    end
end)

local local_address = 0
menu.slider(Local_Editor, "Local 地址", { "local_address" }, "输入计算总和", 0, 16777216, 0, 1,
    function(value)
        local_address = value
    end)
local local_type = "int"
menu.slider_text(Local_Editor, "数据类型", {}, "", { "INT", "FLOAT" }, function(value)
    if value == 1 then
        local_type = "int"
    elseif value == 2 then
        local_type = "float"
    end
end)
menu.action(Local_Editor, "读取 Local", {}, "", function()
    if local_address > 0 then
        if SCRIPT.HAS_SCRIPT_LOADED(mission_script) then
            local value
            if local_type == "int" then
                value = GET_INT_LOCAL(mission_script, local_address)
            elseif local_type == "float" then
                value = GET_FLOAT_LOCAL(mission_script, local_address)
            end

            if value ~= nil then
                util.toast(value)
            else
                util.toast("No Data")
            end
        else
            util.toast("This Script Has Not Loaded")
        end
    end
end)

local local_write = 0
menu.slider(Local_Editor, "要写入的值", { "local_write" }, "", 0, 16777216, 0, 1, function(value)
    local_write = value
end)
menu.action(Local_Editor, "写入 Local", {}, "", function()
    if local_address > 0 then
        if SCRIPT.HAS_SCRIPT_LOADED(mission_script) then
            if local_type == "int" then
                SET_INT_LOCAL(mission_script, local_address, local_write)
            elseif local_type == "float" then
                SET_FLOAT_LOCAL(mission_script, local_address, local_write)
            end
        else
            util.toast("This Script Has Not Loaded")
        end
    end
end)
menu.toggle_loop(Local_Editor, "锁定写入 Local", {}, "", function()
    if local_address > 0 then
        if SCRIPT.HAS_SCRIPT_LOADED(mission_script) then
            if local_type == "int" then
                SET_INT_LOCAL(mission_script, local_address, local_write)
            elseif local_type == "float" then
                SET_FLOAT_LOCAL(mission_script, local_address, local_write)
            end
        else
            util.toast("This Script Has Not Loaded")
            return
        end
    end
end)

--- Global Editor ---
local Global_Editor = menu.list(Mission_options, "Global Editor", {}, "")

local global_address = 0
menu.slider(Global_Editor, "Global 地址", { "global_address" }, "输入计算总和", 0, 16777216, 0, 1,
    function(value)
        global_address = value
    end)
local global_type = "int"
menu.slider_text(Global_Editor, "数据类型", {}, "", { "INT", "FLOAT" }, function(value)
    if value == 1 then
        global_type = "int"
    elseif value == 2 then
        global_type = "float"
    end
end)
menu.action(Global_Editor, "读取 Global", {}, "", function()
    if global_address > 0 then
        local value
        if global_type == "int" then
            value = GET_INT_GLOBAL(global_address)
        elseif global_type == "float" then
            value = GET_FLOAT_GLOBAL(global_address)
        end

        if value ~= nil then
            util.toast(value)
        else
            util.toast("No Data")
        end
    end
end)

local global_write = 0
menu.slider(Global_Editor, "要写入的值", { "global_write" }, "", 0, 16777216, 0, 1, function(value)
    global_write = value
end)
menu.action(Global_Editor, "写入 Global", {}, "", function()
    if global_address > 0 then
        if global_type == "int" then
            SET_INT_GLOBAL(global_address, global_write)
        elseif global_type == "float" then
            SET_FLOAT_GLOBAL(global_address, global_write)
        end
    end
end)
menu.toggle_loop(Global_Editor, "锁定写入 Global", {}, "", function()
    if global_address > 0 then
        if global_type == "int" then
            SET_INT_GLOBAL(global_address, global_write)
        elseif global_type == "float" then
            SET_FLOAT_GLOBAL(global_address, global_write)
        end
    end
end)

--------------------------------
------------ 其它选项 ------------
--------------------------------
local Other_options = menu.list(menu.my_root(), "其它选项", {}, "")

--- 开发者选项 ---
local Other_options_Developer = menu.list(Other_options, "开发者选项", {}, "")

menu.action(Other_options_Developer, "Copy Coords & Heading", {}, "", function()
    local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    local heading = ENTITY.GET_ENTITY_HEADING(players.user_ped())
    local text = coords.x .. ", " .. coords.y .. ", " .. coords.z .. "\n" .. heading
    util.copy_to_clipboard(text, false)
    util.toast("Copied!\n" .. text)
end)
menu.action(Other_options_Developer, "GET_ENTITY_HEADING", {}, "", function()
    util.toast(ENTITY.GET_ENTITY_HEADING(players.user_ped()))
end)
menu.action(Other_options_Developer, "PARTICIPANT_ID_TO_INT", {}, "", function()
    util.toast(NETWORK.PARTICIPANT_ID_TO_INT())
end)
menu.action(Other_options_Developer, "NETWORK_GET_PLAYER_INDEX", {}, "", function()
    util.toast(NETWORK.NETWORK_GET_PLAYER_INDEX(PLAYER.PLAYER_ID()))
end)
menu.action(Other_options_Developer, "PLAYER_ID", {}, "", function()
    util.toast(PLAYER.PLAYER_ID())
end)
menu.action(Other_options_Developer, "GET_NETWORK_TIME", {}, "", function()
    util.toast(NETWORK.GET_NETWORK_TIME())
end)
-----
local DeveloperTest_APPLY_FORCE_TO_ENTITY = menu.list(Other_options_Developer, "ENTITY::APPLY_FORCE_TO_ENTITY", {}, "")
local DeveloperTest_A_F_T_E_x = 0.0
menu.slider_float(DeveloperTest_APPLY_FORCE_TO_ENTITY, "X", { "DeveloperTest_A_F_T_E_x" }, "", 0, 10000, 0, 10,
    function(value)
        DeveloperTest_A_F_T_E_x = value * 0.01
    end)
local DeveloperTest_A_F_T_E_y = 0.0
menu.slider_float(DeveloperTest_APPLY_FORCE_TO_ENTITY, "Y", { "DeveloperTest_A_F_T_E_y" }, "", 0, 10000, 0, 10,
    function(value)
        DeveloperTest_A_F_T_E_y = value * 0.01
    end)
local DeveloperTest_A_F_T_E_z = 5.0
menu.slider_float(DeveloperTest_APPLY_FORCE_TO_ENTITY, "Z", { "DeveloperTest_A_F_T_E_z" }, "", 0, 10000, 500, 10,
    function(value)
        DeveloperTest_A_F_T_E_z = value * 0.01
    end)
local DeveloperTest_A_F_T_E_offX = 5.0
menu.slider_float(DeveloperTest_APPLY_FORCE_TO_ENTITY, "offX", { "DeveloperTest_A_F_T_E_offX" }, "", 0, 10000, 500, 10,
    function(value)
        DeveloperTest_A_F_T_E_offX = value * 0.01
    end)
local DeveloperTest_A_F_T_E_offY = 0.0
menu.slider_float(DeveloperTest_APPLY_FORCE_TO_ENTITY, "offY", { "DeveloperTest_A_F_T_E_offY" }, "", 0, 10000, 0, 10,
    function(value)
        DeveloperTest_A_F_T_E_offY = value * 0.01
    end)
local DeveloperTest_A_F_T_E_offZ = 0.0
menu.slider_float(DeveloperTest_APPLY_FORCE_TO_ENTITY, "offZ", { "DeveloperTest_A_F_T_E_offZ" }, "", 0, 10000, 0, 10,
    function(value)
        DeveloperTest_A_F_T_E_offZ = value * 0.01
    end)

menu.action(DeveloperTest_APPLY_FORCE_TO_ENTITY, "APPLY_FORCE_TO_ENTITY", {}, "", function()
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
    if vehicle then
        ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, DeveloperTest_A_F_T_E_x, DeveloperTest_A_F_T_E_y,
            DeveloperTest_A_F_T_E_z, DeveloperTest_A_F_T_E_offX, DeveloperTest_A_F_T_E_offY, DeveloperTest_A_F_T_E_offZ,
            1, false, true, true, true, true)
    else
        ENTITY.APPLY_FORCE_TO_ENTITY(players.user_ped(), 1, DeveloperTest_A_F_T_E_x, DeveloperTest_A_F_T_E_y,
            DeveloperTest_A_F_T_E_z, DeveloperTest_A_F_T_E_offX, DeveloperTest_A_F_T_E_offY, DeveloperTest_A_F_T_E_offZ,
            1, false, true, true, true, true)
    end
end)
-----
local DeveloperTest_ADD_EXPLOSION = menu.list(Other_options_Developer, "FIRE::ADD_EXPLOSION", {}, "")
local FIRE_ADD_EXPLOSION = {
    x = 0.0,
    y = 2.0,
    z = -1.0,
    explosionType = 2,
    damageScale = 5.0,
    isAudible = true,
    isInvisible = false,
    cameraShake = 0.0,
    noDamage = false,
    timeDelay = 1500
}
menu.slider(DeveloperTest_ADD_EXPLOSION, "左/右", { "DeveloperTest_ADD_EXPLOSION_x" }, "", -100.0, 100.0, 0.0, 1.0,
    function(value)
        FIRE_ADD_EXPLOSION.x = value
    end)
menu.slider(DeveloperTest_ADD_EXPLOSION, "前/后", { "DeveloperTest_ADD_EXPLOSION_y" }, "", -100.0, 100.0, 2.0, 1.0,
    function(value)
        FIRE_ADD_EXPLOSION.y = value
    end)
menu.slider(DeveloperTest_ADD_EXPLOSION, "上/下", { "DeveloperTest_ADD_EXPLOSION_z" }, "", -100.0, 100.0, -1.0, 1.0,
    function(value)
        FIRE_ADD_EXPLOSION.z = value
    end)
menu.slider(DeveloperTest_ADD_EXPLOSION, "damageScale", { "DeveloperTest_ADD_EXPLOSION_damageScale" }, "", 0.0, 100.0,
    5.0, 1.0, function(value)
    FIRE_ADD_EXPLOSION.damageScale = value
end)
menu.toggle(DeveloperTest_ADD_EXPLOSION, "isAudible", {}, "", function(toggle)
    FIRE_ADD_EXPLOSION.isAudible = toggle
end, true)
menu.toggle(DeveloperTest_ADD_EXPLOSION, "isInvisible", {}, "", function(toggle)
    FIRE_ADD_EXPLOSION.isInvisible = toggle
end)
menu.slider(DeveloperTest_ADD_EXPLOSION, "cameraShake", { "DeveloperTest_ADD_EXPLOSION_cameraShake" }, "", 0.0, 100.0,
    0.0, 1.0, function(value)
    FIRE_ADD_EXPLOSION.cameraShake = value
end)
menu.toggle(DeveloperTest_ADD_EXPLOSION, "noDamage", {}, "", function(toggle)
    FIRE_ADD_EXPLOSION.noDamage = toggle
end)
menu.slider(DeveloperTest_ADD_EXPLOSION, "explosionType", { "DeveloperTest_ADD_EXPLOSION_explosionType" },
    "19: 烟雾, 20: 催泪瓦斯", -1, 83, 2, 1, function(value)
    FIRE_ADD_EXPLOSION.explosionType = value
end)

menu.action(DeveloperTest_ADD_EXPLOSION, "ADD_EXPLOSION", {}, "", function()
    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), FIRE_ADD_EXPLOSION.x,
        FIRE_ADD_EXPLOSION.y, FIRE_ADD_EXPLOSION.z)
    FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, FIRE_ADD_EXPLOSION.explosionType, FIRE_ADD_EXPLOSION.damageScale,
        FIRE_ADD_EXPLOSION.isAudible, FIRE_ADD_EXPLOSION.isInvisible, FIRE_ADD_EXPLOSION.cameraShake,
        FIRE_ADD_EXPLOSION.noDamage)
end)

menu.slider(DeveloperTest_ADD_EXPLOSION, "时间间隔", { "DeveloperTest_ADD_EXPLOSION_timeDelay" }, "", 0, 5000, 1500,
    10, function(value)
    FIRE_ADD_EXPLOSION.timeDelay = value
end)
menu.toggle_loop(DeveloperTest_ADD_EXPLOSION, "ADD_EXPLOSION (Loop)", {}, "", function()
    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), FIRE_ADD_EXPLOSION.x,
        FIRE_ADD_EXPLOSION.y, FIRE_ADD_EXPLOSION.z)
    FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, FIRE_ADD_EXPLOSION.explosionType, FIRE_ADD_EXPLOSION.damageScale,
        FIRE_ADD_EXPLOSION.isAudible, FIRE_ADD_EXPLOSION.isInvisible, FIRE_ADD_EXPLOSION.cameraShake,
        FIRE_ADD_EXPLOSION.noDamage)
    util.yield(FIRE_ADD_EXPLOSION.timeDelay)
end, function()
    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), FIRE_ADD_EXPLOSION.x,
        FIRE_ADD_EXPLOSION.y, FIRE_ADD_EXPLOSION.z)
    FIRE.STOP_FIRE_IN_RANGE(coords.x, coords.y, coords.z, 5.0)
end)
-----
menu.divider(Other_options_Developer, "临时测试")



--- 零食护甲编辑 ---
local Other_options_SnackArmour = menu.list(Other_options, "零食护甲编辑", {}, "")

menu.action(Other_options_SnackArmour, "补满全部零食", {}, "", function()
    STAT_SET_INT("NO_BOUGHT_YUM_SNACKS", 30)
    STAT_SET_INT("NO_BOUGHT_HEALTH_SNACKS", 15)
    STAT_SET_INT("NO_BOUGHT_EPIC_SNACKS", 5)
    STAT_SET_INT("NUMBER_OF_ORANGE_BOUGHT", 10)
    STAT_SET_INT("NUMBER_OF_BOURGE_BOUGHT", 10)
    STAT_SET_INT("NUMBER_OF_CHAMP_BOUGHT", 5)
    STAT_SET_INT("CIGARETTES_BOUGHT", 20)
    util.toast("完成！")
end)
menu.action(Other_options_SnackArmour, "补满全部护甲", {}, "", function()
    STAT_SET_INT("MP_CHAR_ARMOUR_1_COUNT", 10)
    STAT_SET_INT("MP_CHAR_ARMOUR_2_COUNT", 10)
    STAT_SET_INT("MP_CHAR_ARMOUR_3_COUNT", 10)
    STAT_SET_INT("MP_CHAR_ARMOUR_4_COUNT", 10)
    STAT_SET_INT("MP_CHAR_ARMOUR_5_COUNT", 10)
    util.toast("完成！")
end)
menu.action(Other_options_SnackArmour, "补满呼吸器", {}, "", function()
    STAT_SET_INT("BREATHING_APPAR_BOUGHT", 20)
    util.toast("完成！")
end)

menu.divider(Other_options_SnackArmour, "零食")
menu.click_slider(Other_options_SnackArmour, "PQ豆", {}, "+15 Health", 0, 99, 30, 1, function(value)
    STAT_SET_INT("NO_BOUGHT_YUM_SNACKS", value)
    util.toast("完成！")
end)
menu.click_slider(Other_options_SnackArmour, "宝力旺", {}, "+45 Health", 0, 99, 15, 1, function(value)
    STAT_SET_INT("NO_BOUGHT_HEALTH_SNACKS", value)
    util.toast("完成！")
end)
menu.click_slider(Other_options_SnackArmour, "麦提来", {}, "+30 Health", 0, 99, 5, 1, function(value)
    STAT_SET_INT("NO_BOUGHT_EPIC_SNACKS", value)
    util.toast("完成！")
end)
menu.click_slider(Other_options_SnackArmour, "易可乐", {}, "+36 Health", 0, 99, 10, 1, function(value)
    STAT_SET_INT("NUMBER_OF_ORANGE_BOUGHT", value)
    util.toast("完成！")
end)
menu.click_slider(Other_options_SnackArmour, "尿汤啤", {}, "", 0, 99, 10, 1, function(value)
    STAT_SET_INT("NUMBER_OF_BOURGE_BOUGHT", value)
    util.toast("完成！")
end)
menu.click_slider(Other_options_SnackArmour, "蓝醉香槟", {}, "", 0, 99, 5, 1, function(value)
    STAT_SET_INT("NUMBER_OF_CHAMP_BOUGHT", value)
    util.toast("完成！")
end)
menu.click_slider(Other_options_SnackArmour, "香烟", {}, "-5 Health", 0, 99, 20, 1, function(value)
    STAT_SET_INT("CIGARETTES_BOUGHT", value)
    util.toast("完成！")
end)

-----
menu.toggle_loop(Other_options, "跳到下一条对话", { "skip_talk" }, "快速跳过对话", function()
    if AUDIO.IS_SCRIPTED_CONVERSATION_ONGOING() then
        AUDIO.SKIP_TO_NEXT_SCRIPTED_CONVERSATION_LINE()
    end
end)

menu.action(Other_options, "请求重型装甲", {}, "请求弹道装甲和火神机枪", function()
    SET_INT_GLOBAL(2815059 + 884, 1)
end)
menu.action(Other_options, "重型装甲包裹 传送到我", {}, "\nModel Hash: 1688540826", function()
    local entity_model_hash = 1688540826
    for k, ent in pairs(entities.get_all_pickups_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 2.0, 0.0)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
        end
    end
end)

menu.divider(Other_options, "无视犯罪")
menu.action(Other_options, "警察无视犯罪", { "no_cops" }, "莱斯特电话请求", function()
    SET_INT_GLOBAL(2815059 + 4624, 5)
    SET_INT_GLOBAL(2815059 + 4625, 1)
    SET_INT_GLOBAL(2815059 + 4627, NETWORK.GET_NETWORK_TIME())
end)
menu.action(Other_options, "贿赂当局", {}, "CEO技能", function()
    SET_INT_GLOBAL(2815059 + 4624, 81)
    SET_INT_GLOBAL(2815059 + 4625, 1)
    SET_INT_GLOBAL(2815059 + 4627, NETWORK.GET_NETWORK_TIME())
end)
menu.toggle_loop(Other_options, "锁定倒计时", {}, "无视犯罪的倒计时", function()
    SET_INT_GLOBAL(2815059 + 4627, NETWORK.GET_NETWORK_TIME())
end)


---------------------------------------------------------------





------------------------------------
------------ 玩家列表选项 ------------
------------------------------------

GenerateFeatures = function(pId)
    local Player_MainMenu = menu.list(menu.player_root(pId), "RScript", {}, "")

    ---------- 恶搞选项 ----------
    local Trolling_options = menu.list(Player_MainMenu, "恶搞选项", {}, "")

    local function g_cage(pId)
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        local objHash = util.joaat("prop_gold_cont_01")
        requestModels(objHash)
        local pos = ENTITY.GET_ENTITY_COORDS(player_ped)
        local obj = OBJECT.CREATE_OBJECT(objHash, pos.x, pos.y, pos.z - 1.0, true, false, false)
        ENTITY.FREEZE_ENTITY_POSITION(obj, true)
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(objHash)
    end

    menu.action(Trolling_options, "小笼子", {}, "", function()
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        TASK.CLEAR_PED_TASKS_IMMEDIATELY(player_ped)
        if PED.IS_PED_IN_ANY_VEHICLE(player_ped) then
            return
        end
        g_cage(pId)
    end)

    menu.action(Trolling_options, "小查攻击", {}, "", function()
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        local objHash = util.joaat("A_C_Chop")
        requestModels(objHash)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0.0, -1.0, 0.0)
        local heading = ENTITY.GET_ENTITY_HEADING(player_ped)
        local g_ped = PED.CREATE_PED(PED_TYPE_CIVMALE, objHash, coords.x, coords.y, coords.z, heading, true, false)

        NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(NETWORK.PED_TO_NET(g_ped), true)
        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(g_ped, false, true)
        NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(NETWORK.PED_TO_NET(g_ped), pId, true)
        ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(g_ped, true, 1)

        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(g_ped, true)
        TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(g_ped, true)
        TASK.TASK_COMBAT_PED(g_ped, player_ped, 0, 16)
        PED.SET_PED_KEEP_TASK(g_ped, true)

        PED.SET_PED_MONEY(g_ped, 2000)
        PED.SET_PED_MAX_HEALTH(g_ped, 30000)
        ENTITY.SET_ENTITY_HEALTH(g_ped, 30000)
        PED.SET_PED_CAN_RAGDOLL(g_ped, false)

        PED.SET_PED_HIGHLY_PERCEPTIVE(g_ped, true)
        PED.SET_PED_VISUAL_FIELD_PERIPHERAL_RANGE(g_ped, 500.0)
        PED.SET_PED_SEEING_RANGE(g_ped, 500.0)
        PED.SET_PED_HEARING_RANGE(g_ped, 500.0)

        PED.SET_PED_AS_ENEMY(g_ped, true)
        PED.SET_PED_SHOOT_RATE(g_ped, 1000.0)
        PED.SET_PED_ACCURACY(g_ped, 100.0)

        PED.SET_PED_COMBAT_ATTRIBUTES(g_ped, 46, true) --CanFightArmedPedsWhenNotArmed
        PED.SET_PED_COMBAT_ATTRIBUTES(g_ped, 5, true) --AlwaysFight
        PED.SET_PED_COMBAT_ATTRIBUTES(g_ped, 27, true) --PerfectAccuracy
        PED.SET_PED_COMBAT_MOVEMENT(g_ped, 2)
        PED.SET_PED_COMBAT_ABILITY(g_ped, 2)
        PED.SET_PED_COMBAT_RANGE(g_ped, 2)
        PED.SET_PED_TARGET_LOSS_RESPONSE(g_ped, 1)
        PED.SET_COMBAT_FLOAT(g_ped, 10, 500.0)

        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(objHash)
    end)

    menu.action(Trolling_options, "载具内敌人攻击", {}, "", function()
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        if PED.IS_PED_IN_ANY_VEHICLE(player_ped) then
            local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_ped, false)

            local objHash = util.joaat("A_M_M_ACult_01")
            requestModels(objHash)
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0.0, 0.0, 2.0)
            local heading = ENTITY.GET_ENTITY_HEADING(player_ped)
            local g_ped = PED.CREATE_PED(PED_TYPE_CIVMALE, objHash, coords.x, coords.y, coords.z, heading, true, false)
            PED.SET_PED_INTO_VEHICLE(g_ped, vehicle, -2)

            NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(NETWORK.PED_TO_NET(g_ped), true)
            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(g_ped, false, true)
            NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(NETWORK.PED_TO_NET(g_ped), pId, true)
            ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(g_ped, true, 1)

            PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(g_ped, true)
            TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(g_ped, true)
            TASK.TASK_COMBAT_PED(g_ped, player_ped, 0, 16)
            PED.SET_PED_KEEP_TASK(g_ped, true)

            PED.SET_PED_MONEY(g_ped, 2000)
            PED.SET_PED_MAX_HEALTH(g_ped, 30000)
            ENTITY.SET_ENTITY_HEALTH(g_ped, 30000)
            PED.SET_PED_CAN_RAGDOLL(g_ped, false)

            local weaponHash = util.joaat("WEAPON_MICROSMG")
            WEAPON.GIVE_WEAPON_TO_PED(g_ped, weaponHash, -1, false, true)
            WEAPON.SET_CURRENT_PED_WEAPON(g_ped, weaponHash, true)
            WEAPON.SET_PED_INFINITE_AMMO_CLIP(g_ped, true)
            PED.SET_PED_SHOOT_RATE(g_ped, 1000.0)
            PED.SET_PED_ACCURACY(g_ped, 100.0)

            PED.SET_PED_AS_ENEMY(g_ped, true)
            PED.SET_PED_CAN_BE_SHOT_IN_VEHICLE(g_ped, false)

            PED.SET_PED_HIGHLY_PERCEPTIVE(g_ped, true)
            PED.SET_PED_VISUAL_FIELD_PERIPHERAL_RANGE(g_ped, 500.0)
            PED.SET_PED_SEEING_RANGE(g_ped, 500.0)
            PED.SET_PED_HEARING_RANGE(g_ped, 500.0)

            PED.SET_PED_COMBAT_ATTRIBUTES(g_ped, 0, true) --CanUseCover
            PED.SET_PED_COMBAT_ATTRIBUTES(g_ped, 1, true) --CanUseVehicles
            PED.SET_PED_COMBAT_ATTRIBUTES(g_ped, 2, true) --CanDoDrivebys
            PED.SET_PED_COMBAT_ATTRIBUTES(g_ped, 3, false) --CanLeaveVehicle
            PED.SET_PED_COMBAT_ATTRIBUTES(g_ped, 5, true) --AlwaysFight
            PED.SET_PED_COMBAT_ATTRIBUTES(g_ped, 12, true) --BlindFireWhenInCover
            PED.SET_PED_COMBAT_ATTRIBUTES(g_ped, 13, true) --Aggressive
            PED.SET_PED_COMBAT_ATTRIBUTES(g_ped, 20, true) --CanTauntInVehicle
            PED.SET_PED_COMBAT_ATTRIBUTES(g_ped, 21, true) --CanChaseTargetOnFoot
            PED.SET_PED_COMBAT_ATTRIBUTES(g_ped, 27, true) --PerfectAccuracy
            PED.SET_PED_COMBAT_ATTRIBUTES(g_ped, 41, true) --CanCommandeerVehicles
            PED.SET_PED_COMBAT_ATTRIBUTES(g_ped, 46, true) --CanFightArmedPedsWhenNotArmed
            PED.SET_PED_COMBAT_ATTRIBUTES(g_ped, 58, true) --DisableFleeFromCombat
            PED.SET_PED_COMBAT_MOVEMENT(g_ped, 2)
            PED.SET_PED_COMBAT_ABILITY(g_ped, 2)
            PED.SET_PED_COMBAT_RANGE(g_ped, 2)
            PED.SET_PED_TARGET_LOSS_RESPONSE(g_ped, 1)
            PED.SET_COMBAT_FLOAT(g_ped, 10, 500.0)

            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(objHash)
        end
    end)

    --- 生成虎鲸 ---
    local Trolling_options_kosatka = menu.list(Trolling_options, "生成虎鲸", {}, "")

    local ge_kosatka_x = 0.0
    menu.slider(Trolling_options_kosatka, "左/右", { "ge_kosatka_x" }, "", -100.0, 100.0, 0.0, 1.0, function(value)
        ge_kosatka_x = value
    end)
    local ge_kosatka_y = 0.0
    menu.slider(Trolling_options_kosatka, "前/后", { "ge_kosatka_y" }, "", -100.0, 100.0, 0.0, 1.0, function(value)
        ge_kosatka_y = value
    end)
    local ge_kosatka_z = 0.0
    menu.slider(Trolling_options_kosatka, "上/下", { "ge_kosatka_z" }, "高度", -100.0, 100.0, 0.0, 1.0,
        function(value)
            ge_kosatka_z = value
        end)

    menu.action(Trolling_options_kosatka, "生成虎鲸", {}, "", function()
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        local objHash = util.joaat("kosatka")
        requestModels(objHash)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, ge_kosatka_x, ge_kosatka_y, ge_kosatka_z)
        local ge_kosatka = VEHICLE.CREATE_VEHICLE(objHash, coords.x, coords.y, coords.z,
            ENTITY.GET_ENTITY_HEADING(player_ped), true, false, true)

        NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(NETWORK.VEH_TO_NET(ge_kosatka), true)
        NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(NETWORK.VEH_TO_NET(ge_kosatka), pId, true)
        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ge_kosatka, false, true)
        ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(ge_kosatka, true, 1)

        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(objHash)
    end)

    --- 传送所有实体 ---
    local Trolling_options_AllEntities = menu.list(Trolling_options, "传送所有实体", {}, "")

    TPtoPlayer_delay = 100 --ms
    is_TPtoPlayer_run = false
    is_Exclude_mission = true
    local function TP_Entities_TO_Player(entity_list, player_ped, type)
        local i = 0
        for k, ent in pairs(entity_list) do
            if is_TPtoPlayer_run then

                if is_Exclude_mission and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
                else
                    if ENTITY.IS_ENTITY_A_PED(ent) then
                        if not IS_PED_PLAYER(ent) then
                            RequestControl(ent)
                            TP_ENTITY_TO_ENTITY(ent, player_ped, 0.0, 0.0, 2.0)
                            i = i + 1
                        end
                    elseif ENTITY.IS_ENTITY_A_VEHICLE(ent) then
                        if not IS_PLAYER_VEHICLE(ent) then
                            RequestControl(ent)
                            TP_ENTITY_TO_ENTITY(ent, player_ped, 0.0, 0.0, 2.0)
                            i = i + 1
                        end
                    else
                        RequestControl(ent)
                        TP_ENTITY_TO_ENTITY(ent, player_ped, 0.0, 0.0, 2.0)
                        i = i + 1
                    end

                end
                util.yield(TPtoPlayer_delay)

            else
                -- 停止传送
                util.toast("Done!\n" .. type .. " Number : " .. i)
                return false
            end
        end
        -- 完成传送
        util.toast("Done!\n" .. type .. " Number : " .. i)
        is_TPtoPlayer_run = false
        return true
    end

    menu.slider(Trolling_options_AllEntities, "传送延时", { "TP_delay" }, "单位：ms", 0, 5000, 100, 100,
        function(value)
            TPtoPlayer_delay = value
        end)
    menu.toggle(Trolling_options_AllEntities, "排除任务实体", {}, "", function()
        is_Exclude_mission = value
    end, true)

    menu.action(Trolling_options_AllEntities, "传送所有 行人 到他", {}, "", function()
        if is_TPtoPlayer_run then
            util.toast("上次的还未传送完成呢")
        else
            is_TPtoPlayer_run = true
            local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
            TP_Entities_TO_Player(entities.get_all_peds_as_handles(), player_ped, "Ped")
        end
    end)
    menu.action(Trolling_options_AllEntities, "传送所有 载具 到他", {}, "", function()
        if is_TPtoPlayer_run then
            util.toast("上次的还未传送完成呢")
        else
            is_TPtoPlayer_run = true
            local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
            TP_Entities_TO_Player(entities.get_all_vehicles_as_handles(), player_ped, "Vehicle")
        end
    end)
    menu.action(Trolling_options_AllEntities, "传送所有 物体 到他", {}, "", function()
        if is_TPtoPlayer_run then
            util.toast("上次的还未传送完成呢")
        else
            is_TPtoPlayer_run = true
            local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
            TP_Entities_TO_Player(entities.get_all_objects_as_handles(), player_ped, "Object")
        end
    end)
    menu.action(Trolling_options_AllEntities, "传送所有 拾取物 到他", {}, "", function()
        if is_TPtoPlayer_run then
            util.toast("上次的还未传送完成呢")
        else
            is_TPtoPlayer_run = true
            local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
            TP_Entities_TO_Player(entities.get_all_pickups_as_handles(), player_ped, "Pickup")
        end
    end)
    menu.action(Trolling_options_AllEntities, "停止传送", {}, "", function()
        is_TPtoPlayer_run = false
    end)

    ---------- 友好选项 ----------
    local Friendly_options = menu.list(Player_MainMenu, "友好选项", {}, "")

    menu.action(Friendly_options, "掉落医药包", {}, "", function()
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        local pos = ENTITY.GET_ENTITY_COORDS(player_ped)
        local objHash = util.joaat("prop_ld_health_pack")
        requestModels(objHash)
        local pickupHash = 2406513688
        local pickup = OBJECT.CREATE_PICKUP(pickupHash, pos.x, pos.y + 1.0, pos.z, 1, 100, false, objHash)
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(objHash)
    end)

    menu.action(Friendly_options, "掉落护甲", {}, "", function()
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        local pos = ENTITY.GET_ENTITY_COORDS(player_ped)
        local objHash = util.joaat("prop_armour_pickup")
        requestModels(objHash)
        local pickupHash = 1274757841
        local pickup = OBJECT.CREATE_PICKUP(pickupHash, pos.x, pos.y + 1.0, pos.z, 1, 100, false, objHash)
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(objHash)
    end)

    ---------- 恢复选项 ----------
    local Recovery_options = menu.list(Player_MainMenu, "恢复选项", {}, "")

    menu.toggle_loop(Recovery_options, "掉落金钱", {}, "$2000\nCREATE_MONEY_PICKUPS", function()
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        if player_ped ~= PLAYER.PLAYER_PED_ID() then
            local pos = ENTITY.GET_ENTITY_COORDS(player_ped)
            local objHash = util.joaat("prop_cash_pile_01")
            requestModels(objHash)
            OBJECT.CREATE_MONEY_PICKUPS(pos.x, pos.y, pos.z + 1.0, 2000, 1, objHash)
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(objHash)
        end
        util.yield(500)
    end)

    menu.toggle_loop(Recovery_options, "掉落金钱", {}, "$2000\nCREATE_PICKUP", function()
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        if player_ped ~= PLAYER.PLAYER_PED_ID() then
            local pos = ENTITY.GET_ENTITY_COORDS(player_ped)
            local objHash = util.joaat("prop_cash_pile_01")
            requestModels(objHash)
            local pickupHash = 4263048111
            OBJECT.CREATE_PICKUP(pickupHash, pos.x, pos.y, pos.z + 1.0, 1, 2000, false, objHash)
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(objHash)
        end
        util.yield(500)
    end)

    ---------- 崩溃选项 ----------
    local Crash_options = menu.list(Player_MainMenu, "崩溃选项", {}, "")

    menu.action(Crash_options, "5G Crash", {}, "Crash By aplics & IMXNOOBX", function()
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        if player_ped ~= players.user_ped() then
            menu.trigger_commands("anticrashcam on")
            local allvehicles = entities.get_all_vehicles_as_handles()
            for k = 1, 3 do
                for i = 1, #allvehicles do
                    TASK.TASK_VEHICLE_TEMP_ACTION(player_ped, allvehicles[i], 15, 1000)
                    TASK.TASK_VEHICLE_TEMP_ACTION(player_ped, allvehicles[i], 16, 1000)
                    TASK.TASK_VEHICLE_TEMP_ACTION(player_ped, allvehicles[i], 17, 1000)
                    TASK.TASK_VEHICLE_TEMP_ACTION(player_ped, allvehicles[i], 18, 1000)
                end
            end
            menu.trigger_commands("anticrashcam off")
            util.toast("5G Crash sent!")
        end
    end)

    ----- END -----
end

----- 玩家列表 -----
local PlayersList = players.list(true, true, true)
for i = 1, #PlayersList do
    GenerateFeatures(PlayersList[i])
end

players.on_join(GenerateFeatures)
