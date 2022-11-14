--- Author: Rostal
--- Last edit date: 2022/11/14

util.require_natives("natives-1663599433")
util.keep_running()


---------------------------------------
---------------- LABELS ---------------
---------------------------------------
local Support_GTAO = 1.63

-- 颜色
local color = {
    purple = {
        r = 1.0,
        g = 0.0,
        b = 1.0,
        a = 1.0
    },
    black = {
        r = 0.0,
        g = 0.0,
        b = 0.0,
        a = 1.0
    },
    white = {
        r = 1.0,
        g = 1.0,
        b = 1.0,
        a = 1.0
    }
}

-- 武器
local weapon_name_ListItem = {
    { "小刀" },
    { "穿甲手枪" },
    { "电击枪" },
    { "微型冲锋枪" },
    { "特质卡宾步枪" },
    { "突击霰弹枪" },
    { "火神机枪" },
    { "火箭筒" },
    { "电磁步枪" }
}
local weapon_model_list = {
    "WEAPON_KNIFE",
    "WEAPON_APPISTOL",
    "WEAPON_STUNGUN",
    "WEAPON_MICROSMG",
    "WEAPON_SPECIALCARBINE",
    "WEAPON_ASSAULTSHOTGUN",
    "WEAPON_MINIGUN",
    "WEAPON_RPG",
    "WEAPON_RAILGUN"
}

-- 驾驶风格
local driving_style_name_ListItem = {
    { "正常" },
    { "半冲刺" },
    { "反向" },
    { "无视红绿灯" },
    { "避开交通" },
    { "极度避开交通" },
    { "有时超车" },
}
local driving_style_list = {
    786603,
    1074528293,
    8388614,
    1076,
    2883621,
    786468,
    262144,
    786469,
    512,
    5,
    6
}

-- 实体类型
local entity_type_ListItem = {
    { "Ped", {}, "NPC" },
    { "Vehicle", {}, "载具" },
    { "Object", {}, "物体" },
    { "Pickup", {}, "拾取物" }
}

-- enum
local enum_PedType = {
    "PLAYER_0",
    "PLAYER_1",
    "NETWORK_PLAYER",
    "PLAYER_2",
    "CIVMALE",
    "CIVFEMALE",
    "COP",
    "GANG_ALBANIAN",
    "GANG_BIKER_1",
    "GANG_BIKER_2",
    "GANG_ITALIAN",
    "GANG_RUSSIAN",
    "GANG_RUSSIAN_2",
    "GANG_IRISH",
    "GANG_JAMAICAN",
    "GANG_AFRICAN_AMERICAN",
    "GANG_KOREAN",
    "GANG_CHINESE_JAPANESE",
    "GANG_PUERTO_RICAN",
    "DEALER",
    "MEDIC",
    "FIREMAN",
    "CRIMINAL",
    "BUM",
    "PROSTITUTE",
    "SPECIAL",
    "MISSION",
    "SWAT",
    "ANIMAL",
    "ARMY"
}

local enum_CombatMovement = {
    "Stationary",
    "Defensive",
    "WillAdvance",
    "WillRetreat"
}

local enum_CombatAbility = {
    "Poor",
    "Average",
    "Professional",
    "NumTypes"
}

local enum_CombatRange = {
    "Near",
    "Medium",
    "Far",
    "VeryFar",
    "NumRanges"
}

local enum_VehicleLockStatus = {
    "None", --0
    "Unlocked", --1
    "Locked", --2
    "LockedForPlayer", --3
    "StickPlayerInside", --4, -- Doesn't allow players to exit the vehicle with the exit vehicle key.
    "CanBeBrokenInto", --7, -- Can be broken into the car. If the glass is broken, the value will be set to 1
    "CanBeBrokenIntoPersist", --8, -- Can be broken into persist
    "CannotBeTriedToEnter" --10, -- Cannot be tried to enter (Nothing happens when you press the vehicle enter key).
}

local enum_Alertness = {
    "Neutral", --0
    "Heard something", --1 gun shot, hit, etc
    "Knows", --2 the origin of the event
    "Fully alerted" --3 is facing the event?
}




---------------------------------------
--------------- Functions -------------
---------------------------------------

-- 请求模型
-- 1) requests all the given models
-- 2) waits till all of them have been loaded
function RequestModels(...)
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

---请求控制实体
---@param entity Entity
---@param tick integer
---@return boolean
function RequestControl(entity, tick)
    if tick == nil then tick = 20 end
    entities.set_can_migrate(entities.handle_to_pointer(entity), true)
    local i = 0
    while not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity) and i <= tick do
        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
        i = i + 1
        util.yield(100)
    end
    return NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity)
end

---判断是否为玩家
---@param Ped Ped
---@return boolean
function IS_PED_PLAYER(Ped)
    if PED.GET_PED_TYPE(Ped) >= 4 then
        return false
    else
        return true
    end
end

---判断是否为玩家载具
---@param Vehicle Vehicle
---@return boolean
function IS_PLAYER_VEHICLE(Vehicle)
    if Vehicle == entities.get_user_vehicle_as_handle() or Vehicle == entities.get_user_personal_vehicle_as_handle() then
        return true
    elseif not VEHICLE.IS_VEHICLE_SEAT_FREE(Vehicle, -1, false) then
        local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(Vehicle, -1)
        if ped > 0 then
            if IS_PED_PLAYER(ped) then
                return true
            end
        end
    end
    return false
end

---判断是否为实体
---@param entity Entity
---@return boolean
function IS_AN_ENTITY(entity)
    if ENTITY.DOES_ENTITY_EXIST(entity) then
        if ENTITY.IS_ENTITY_A_PED(entity) or ENTITY.IS_ENTITY_A_VEHICLE(entity) or ENTITY.IS_ENTITY_AN_OBJECT(entity) then
            return true
        end
    end
    return false
end

---获取实体类型
---
---text_type: 1 小写, 2 首字母大写, 3 大写
---@param entity Entity
---@param text_type integer
---@return string
function GET_ENTITY_TYPE(entity, text_type)
    local entity_type = "No Entity"
    if ENTITY.DOES_ENTITY_EXIST(entity) and ENTITY.IS_AN_ENTITY(entity) then
        if ENTITY.IS_ENTITY_A_PED(entity) then
            entity_type = "Ped"
        elseif ENTITY.IS_ENTITY_A_VEHICLE(entity) then
            entity_type = "Vehicle"
        elseif ENTITY.IS_ENTITY_AN_OBJECT(entity) then
            entity_type = "Object"
            if OBJECT.IS_OBJECT_A_PICKUP(entity) or OBJECT.IS_OBJECT_A_PORTABLE_PICKUP(entity) then
                entity_type = "Pickup"
            end
        end
    end
    if text_type == 1 then
        return string.lower(entity_type)
    elseif text_type == 3 then
        return string.upper(entity_type)
    else
        return entity_type
    end
end

---String to Integer
---
---1: Ped, 2: Vehicle, 3: Object, 4: Pickup, 5: No Entity
---@param Type string
---@return integer
function GET_ENTITY_TYPE_INDEX(Type)
    Type = string.lower(Type)
    if Type == "ped" then
        return 1
    elseif Type == "vehicle" then
        return 2
    elseif Type == "object" then
        return 3
    elseif Type == "pickup" then
        return 4
    else
        return 5
    end
end

----- 玩家自身的传送 -----

---@param X float
---@param Y float
---@param Z float
---@param heading float
function TELEPORT(X, Y, Z, heading)
    local p = players.user_ped()
    if PED.IS_PED_IN_ANY_VEHICLE(p, false) then
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(p, false)
        ENTITY.SET_ENTITY_COORDS(vehicle, X, Y, Z)
    else
        ENTITY.SET_ENTITY_COORDS(p, X, Y, Z)
    end

    if heading ~= nil then
        ENTITY.SET_ENTITY_HEADING(p, heading)
    end
end

---@param ent Entity
---@param x float
---@param y float
---@param z float
function TP_TO_ME(ent, x, y, z)
    if x == nil then x = 0.0 end
    if y == nil then y = 0.0 end
    if z == nil then z = 0.0 end
    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), x, y, z)
    ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
end

---@param ent Entity
---@param x float
---@param y float
---@param z float
function TP_TO_ENTITY(ent, x, y, z)
    if x == nil then x = 0.0 end
    if y == nil then y = 0.0 end
    if z == nil then z = 0.0 end
    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, x, y, z)
    ENTITY.SET_ENTITY_COORDS(players.user_ped(), coords.x, coords.y, coords.z, true, false, false, false)
end

--- TP into driver seat
---@param ent Entity
---@param door string
---@param driver string
---
--- "delete": delete door, "open": open door
---
--- "tp": tp driver out, "delete": delete driver
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
    if x == nil then x = 0.0 end
    if y == nil then y = 0.0 end
    if z == nil then z = 0.0 end
    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(to_ent, x, y, z)
    ENTITY.SET_ENTITY_COORDS(tp_ent, coords.x, coords.y, coords.z, true, false, false, false)
end

-----------------
----- TABLE -----
-----------------

---遍历数组 判断某值是否在表中
function isInTable(tbl, value)
    for k, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

---根据值清空对应的元素（非删除操作）
function clearTableValue(tbl, value)
    for k, v in pairs(tbl) do
        if v == value then
            tbl[k] = nil
        end
    end
end

---@return table
function newTableValue(pos, value)
    local tbl = {}
    tbl[pos] = value
    return tbl
end

---坐标计算
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
---@return number?
function round(num, places)
    return tonumber(string.format('%.' .. (places or 0) .. 'f', num))
end

---@param dist number
---@return v3
function get_offset_from_cam(dist)
    local rot = CAM.GET_FINAL_RENDERED_CAM_ROT(2)
    local pos = CAM.GET_FINAL_RENDERED_CAM_COORD()
    local dir = rot:toDir()
    dir:mul(dist)
    local offset = v3.new(pos)
    offset:add(dir)
    return offset
end

local TraceFlag = {
    everything = 4294967295,
    none = 0,
    world = 1,
    vehicles = 2,
    pedsSimpleCollision = 4,
    peds = 8,
    objects = 16,
    water = 32,
    foliage = 256,
}

---@param dist number
---@param flag integer
---@return RaycastResult
function get_raycast_result(dist, flag)
    local result = {}
    flag = flag or TraceFlag.everything
    local didHit = memory.alloc(1)
    local endCoords = v3.new()
    local normal = v3.new()
    local hitEntity = memory.alloc_int()
    local camPos = CAM.GET_FINAL_RENDERED_CAM_COORD()
    local offset = get_offset_from_cam(dist)

    local handle = SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(camPos.x, camPos.y, camPos.z, offset.x,
        offset.y, offset.z, flag, players.user_ped(), 7)
    SHAPETEST.GET_SHAPE_TEST_RESULT(handle, didHit, memory.addrof(endCoords), memory.addrof(normal), hitEntity)

    result.didHit = memory.read_byte(didHit) ~= 0
    result.endCoords = endCoords
    result.surfaceNormal = normal
    result.hitEntity = memory.read_int(hitEntity)
    return result
end

---@param blip integer
---@return v3
function GET_BLIP_COORDS(blip)
    if blip == 0 then
        return nil
    end
    local pos = HUD.GET_BLIP_COORDS(blip)
    local tick = 0
    local success, groundz = util.get_ground_z(pos.x, pos.y)
    while not success and tick < 10 do
        util.yield()
        success, groundz = util.get_ground_z(pos.x, pos.y)
        tick = tick + 1
    end
    if success then pos.z = groundz end
    return pos
end

---returns a list of nearby vehicles given player Id
function GET_NEARBY_VEHICLES(pid, radius)
    local vehicles = {}
    local p = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
    local p_pos = ENTITY.GET_ENTITY_COORDS(p)
    for k, vehicle in pairs(entities.get_all_vehicles_as_handles()) do
        local veh_pos = ENTITY.GET_ENTITY_COORDS(vehicle)
        if vect.dist(p_pos, veh_pos) <= radius then
            table.insert(vehicles, vehicle)
        end
    end
    return vehicles
end

---returns a list of nearby peds given player Id
function GET_NEARBY_PEDS(pid, radius)
    local peds = {}
    local p = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
    local p_pos = ENTITY.GET_ENTITY_COORDS(p)
    for k, ped in pairs(entities.get_all_peds_as_handles()) do
        if ped ~= p then
            local ped_pos = ENTITY.GET_ENTITY_COORDS(ped)
            if vect.dist(p_pos, ped_pos) <= radius then
                table.insert(peds, ped)
            end
        end
    end
    return peds
end

---returns a list of nearby objects given player Id
function GET_NEARBY_OBJECTS(pid, radius)
    local objs = {}
    local p = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
    local p_pos = ENTITY.GET_ENTITY_COORDS(p)
    for k, obj in pairs(entities.get_all_objects_as_handles()) do
        local obj_pos = ENTITY.GET_ENTITY_COORDS(obj)
        if vect.dist(p_pos, obj_pos) <= radius then
            table.insert(objs, obj)
        end
    end
    return objs
end

---returns a list of nearby pickups given player Id
function GET_NEARBY_PICKUPS(pid, radius)
    local objs = {}
    local p = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
    local p_pos = ENTITY.GET_ENTITY_COORDS(p)
    for k, obj in pairs(entities.get_all_pickups_as_handles()) do
        local obj_pos = ENTITY.GET_ENTITY_COORDS(obj)
        if vect.dist(p_pos, obj_pos) <= radius then
            table.insert(objs, obj)
        end
    end
    return objs
end

---返回玩家正在瞄准的实体
function GetEntity_PlayerIsAimingAt(player)
    local ent
    if PLAYER.IS_PLAYER_FREE_AIMING(player) then
        local ptr = memory.alloc_int()
        if PLAYER.GET_ENTITY_PLAYER_IS_FREE_AIMING_AT(player, ptr) then
            ent = memory.read_int(ptr)
        end
        if ENTITY.IS_ENTITY_A_PED(ent) and PED.IS_PED_IN_ANY_VEHICLE(ent) then
            local vehicle = PED.GET_VEHICLE_PED_IS_IN(ent, false)
            ent = vehicle
        end
    end
    return ent
end

---返回玩家正在瞄准的实体 Plus
function GetEntity_PlayerIsAimingAt_Plus(player)
    local ent
    if PLAYER.IS_PLAYER_FREE_AIMING(player) then
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player)
        local range = WEAPON.GET_MAX_RANGE_OF_CURRENT_PED_WEAPON(player_ped) --max range: 1500
        local raycastResult = get_raycast_result(range)
        if raycastResult.didHit then
            ent = raycastResult.hitEntity
        end
    end
    return ent
end

---通过Model Hash寻找实体
---@param Type string
---@param isMission boolean
---@return table
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

---为实体添加地图标记
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

---@param pedType int
---@param modelHash Hash
---@param x float
---@param y float
---@param z float
---@param heading float
---@return Ped
function Create_Network_Ped(pedType, modelHash, x, y, z, heading)
    RequestModels(modelHash)
    local ped = PED.CREATE_PED(pedType, modelHash, x, y, z, heading, true, false)

    ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(ped, true, 1)
    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ped, true, false)
    ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION(ped, true)

    NETWORK.NETWORK_REGISTER_ENTITY_AS_NETWORKED(ped)
    local net_id = NETWORK.PED_TO_NET(ped)
    NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(net_id, true)
    NETWORK.SET_NETWORK_ID_CAN_MIGRATE(net_id, true)
    for _, player in pairs(players.list(true, true, true)) do
        NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(net_id, player, true)
    end

    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(modelHash)
    return ped
end

---@param modelHash Hash
---@param x float
---@param y float
---@param z float
---@param heading float
---@return Vehicle
function Create_Network_Vehicle(modelHash, x, y, z, heading)
    RequestModels(modelHash)
    local veh = VEHICLE.CREATE_VEHICLE(modelHash, x, y, z, heading, true, false, true)

    VEHICLE.SET_VEHICLE_ENGINE_ON(veh, true, true, false)
    VEHICLE.SET_VEHICLE_STAYS_FROZEN_WHEN_CLEANED_UP(veh, true)
    VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(veh, 5.0)
    VEHICLE.SET_VEHICLE_DIRT_LEVEL(veh, 0.0)
    VEHICLE.SET_VEHICLE_IS_STOLEN(veh, false)
    VEHICLE.SET_CLEAR_FREEZE_WAITING_ON_COLLISION_ONCE_PLAYER_ENTERS(veh, false)

    ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(veh, true, 1)
    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(veh, true, false)
    ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION(veh, true)

    NETWORK.NETWORK_REGISTER_ENTITY_AS_NETWORKED(veh)
    local net_id = NETWORK.VEH_TO_NET(veh)
    NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(net_id, true)
    NETWORK.SET_NETWORK_ID_CAN_MIGRATE(net_id, true)
    for _, player in pairs(players.list(true, true, true)) do
        NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(net_id, player, true)
    end

    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(modelHash)
    return veh
end

---@param pickupHash Hash
---@param x float
---@param y float
---@param z float
---@param modelHash Hash
---@param value int
---@return Pickup
function Create_Network_Pickup(pickupHash, x, y, z, modelHash, value)
    RequestModels(modelHash)
    local pickup = OBJECT.CREATE_AMBIENT_PICKUP(pickupHash, x, y, z, 0, value, modelHash, false, true)

    OBJECT.SET_PICKUP_OBJECT_COLLECTABLE_IN_VEHICLE(pickup)

    ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(pickup, true, 1)
    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(pickup, true, false)
    ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION(pickup, true)

    NETWORK.NETWORK_REGISTER_ENTITY_AS_NETWORKED(pickup)
    local net_id = NETWORK.OBJ_TO_NET(pickup)
    NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(net_id, true)
    NETWORK.SET_NETWORK_ID_CAN_MIGRATE(net_id, true)
    for _, player in pairs(players.list(true, true, true)) do
        NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(net_id, player, true)
    end

    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(modelHash)
    return pickup
end

---@param modelHash Hash
---@param x float
---@param y float
---@param z float
---@return Object
function Create_Network_Object(modelHash, x, y, z)
    RequestModels(modelHash)
    local obj = OBJECT.CREATE_OBJECT(modelHash, x, y, z, true, false, false)

    ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(obj, true, 1)
    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(obj, true, false)
    ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION(obj, true)

    NETWORK.NETWORK_REGISTER_ENTITY_AS_NETWORKED(obj)
    local net_id = NETWORK.OBJ_TO_NET(obj)
    NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(net_id, true)
    NETWORK.SET_NETWORK_ID_CAN_MIGRATE(net_id, true)
    for _, player in pairs(players.list(true, true, true)) do
        NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(net_id, player, true)
    end

    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(modelHash)
    return obj
end

---@param ent Entity
---@param canMigrate boolean
---@return boolean
function Set_Entity_Networked(ent, canMigrate)
    if ENTITY.DOES_ENTITY_EXIST(ent) then
        if canMigrate == nil then canMigrate = true end
        ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(ent, true, 1)
        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ent, true, false)
        ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION(ent, true)

        NETWORK.NETWORK_REGISTER_ENTITY_AS_NETWORKED(ent)
        local net_id = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(ent)
        NETWORK.SET_NETWORK_ID_CAN_MIGRATE(net_id, canMigrate)
        NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(net_id, true)
        for _, player in pairs(players.list(true, true, true)) do
            NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(net_id, player, true)
        end
        return NETWORK.NETWORK_GET_ENTITY_IS_NETWORKED(ent)
    end
    return false
end

---获取载具指定座位的NPC
function get_vehicle_ped(vehicle, seat)
    if not VEHICLE.IS_VEHICLE_SEAT_FREE(vehicle, seat, false) then
        return VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, seat)
    end
    return false
end

---升级载具（排除涂装、车轮）
function Upgrade_Vehicle(vehicle)
    if ENTITY.DOES_ENTITY_EXIST(vehicle) and ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        VEHICLE.SET_VEHICLE_MOD_KIT(vehicle, 0)
        for i = 0, 50 do
            if i ~= 48 and i ~= 23 and i ~= 24 then
                local mod_num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                if mod_num > 0 then
                    VEHICLE.SET_VEHICLE_MOD(vehicle, i, mod_num - 1, false)
                end
            end
        end
        VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(vehicle, false)
        VEHICLE.SET_VEHICLE_WHEELS_CAN_BREAK(vehicle, false)
        VEHICLE.SET_VEHICLE_HAS_UNBREAKABLE_LIGHTS(vehicle, true)
        VEHICLE.SET_VEHICLE_CAN_ENGINE_MISSFIRE(vehicle, false)
        VEHICLE.SET_VEHICLE_CAN_LEAK_OIL(vehicle, false)
        VEHICLE.SET_VEHICLE_CAN_LEAK_PETROL(vehicle, false)

        VEHICLE.SET_DISABLE_VEHICLE_ENGINE_FIRES(vehicle, true)
        VEHICLE.SET_DISABLE_VEHICLE_PETROL_TANK_FIRES(vehicle, true)
        VEHICLE.SET_DISABLE_VEHICLE_PETROL_TANK_DAMAGE(vehicle, true)

        for i = 0, 3 do
            VEHICLE.SET_DOOR_ALLOWED_TO_BE_BROKEN_OFF(vehicle, i, false)
        end
        VEHICLE.SET_HELI_TAIL_BOOM_CAN_BREAK_OFF(vehicle, false)
    end
end

---修复载具
function Fix_Vehicle(vehicle)
    if ENTITY.DOES_ENTITY_EXIST(vehicle) and ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        VEHICLE.SET_VEHICLE_FIXED(vehicle)
        VEHICLE.SET_VEHICLE_DEFORMATION_FIXED(vehicle)
        VEHICLE.SET_VEHICLE_DIRT_LEVEL(vehicle, 0.0)
        VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, 1000.0)
    end
end

---获取最近的生成载具点
---
---nodeType: 0 = main roads, 1 = any dry path, 3 = water
---@param pos Vector3
---@param nodeType integer
---@return boolean, Vector3, float
function Get_Closest_Vehicle_Node(pos, nodeType)
    local outCoords = v3.new()
    local outHeading = memory.alloc(4)
    if PATHFIND.GET_CLOSEST_VEHICLE_NODE_WITH_HEADING(pos.x, pos.y, pos.z, memory.addrof(outCoords), outHeading, nodeType
        , 3.0,
        0) then
        return true, outCoords, memory.read_float(outHeading)
    else
        return false
    end
end

---@param ent Entity
---@param sprite integer
---@param colour integer
---@param time integer ms
function SHOW_BLIP_TIMER(ent, sprite, colour, time)
    util.create_thread(function()
        local blip = HUD.GET_BLIP_FROM_ENTITY(ent)
        --no blip
        if blip == 0 then
            blip = HUD.ADD_BLIP_FOR_ENTITY(ent)
            HUD.SET_BLIP_SPRITE(blip, sprite)
            HUD.SET_BLIP_COLOUR(blip, colour)
            util.yield(time)
            util.remove_blip(blip)
        end
    end)
end

function Draw_Rect_In_Center()
    directx.draw_rect(0.5 - 0.001, 0.5 - 0.002, 0.002, 0.004, color.white)
end

---@param text string
---@param scale float
function DrawString(text, scale)
    if scale == nil then scale = 0.5 end
    local background = {
        r = 0.0,
        g = 0.0,
        b = 0.0,
        a = 0.6
    }
    local text_width, text_height = directx.get_text_size(text, scale)

    directx.draw_rect(0.5 - 0.01, 0.0, text_width + 0.02, text_height + 0.02, background)
    directx.draw_text(0.5, 0.01, text, ALIGN_TOP_LEFT, scale, color.white)
end

-- 返回实体信息 list item data
function GetEntityInfo_ListItem(ent)
    if ent ~= nil and ENTITY.DOES_ENTITY_EXIST(ent) then
        local ent_info_item_data = {}
        local ent_info = {}
        local t = ""

        local model_hash = ENTITY.GET_ENTITY_MODEL(ent)

        --Model Name
        local model_name = util.reverse_joaat(model_hash)
        if model_name ~= "" then
            t = "Model Name: " .. model_name
        end
        ent_info = newTableValue(1, t)
        table.insert(ent_info_item_data, ent_info)

        --Hash
        t = "Model Hash: " .. model_hash
        ent_info = newTableValue(1, t)
        table.insert(ent_info_item_data, ent_info)

        --Type
        local entity_type = GET_ENTITY_TYPE(ent, 2)
        t = "Entity Type: " .. entity_type
        ent_info = newTableValue(1, t)
        table.insert(ent_info_item_data, ent_info)

        --Mission Entity
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            t = "Mission Entity: True"
        else
            t = "Mission Entity: False"
        end
        ent_info = newTableValue(1, t)
        table.insert(ent_info_item_data, ent_info)

        --Health
        t = "Entity Health: " .. ENTITY.GET_ENTITY_HEALTH(ent) .. "/" .. ENTITY.GET_ENTITY_MAX_HEALTH(ent)
        ent_info = newTableValue(1, t)
        table.insert(ent_info_item_data, ent_info)

        --Dead
        if ENTITY.IS_ENTITY_DEAD(ent) then
            t = "Entity Dead: True"
            ent_info = newTableValue(1, t)
            table.insert(ent_info_item_data, ent_info)
        end

        --Position
        local ent_pos = ENTITY.GET_ENTITY_COORDS(ent)
        t = "Coords: " ..
            string.format("%.4f", ent_pos.x) ..
            ", " .. string.format("%.4f", ent_pos.y) .. ", " .. string.format("%.4f", ent_pos.z)
        ent_info = newTableValue(1, t)
        table.insert(ent_info_item_data, ent_info)

        local my_pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        -- t = "Your Coords: " ..
        --     string.format("%.4f", my_pos.x) ..
        --     ", " .. string.format("%.4f", my_pos.y) .. ", " .. string.format("%.4f", my_pos.z)
        -- ent_info = newTableValue(1, t)
        -- table.insert(ent_info_item_data, ent_info)

        --Heading
        t = "Entity Heading: " .. string.format("%.4f", ENTITY.GET_ENTITY_HEADING(ent))
        ent_info = newTableValue(1, t)
        table.insert(ent_info_item_data, ent_info)

        t = "Your Heading: " .. string.format("%.4f", ENTITY.GET_ENTITY_HEADING(players.user_ped()))
        ent_info = newTableValue(1, t)
        table.insert(ent_info_item_data, ent_info)

        --Distance
        local distance = vect.dist(my_pos, ent_pos)
        t = "Distance: " .. string.format("%.4f", distance)
        ent_info = newTableValue(1, t)
        table.insert(ent_info_item_data, ent_info)

        --Subtract with your position
        local pos_sub = vect.subtract(my_pos, ent_pos)
        t = "Subtract Coords X: " ..
            string.format("%.2f", pos_sub.x) ..
            ", Y: " .. string.format("%.2f", pos_sub.y) .. ", Z: " .. string.format("%.2f", pos_sub.z)
        ent_info = newTableValue(1, t)
        table.insert(ent_info_item_data, ent_info)

        --Speed
        local speed = ENTITY.GET_ENTITY_SPEED(ent)
        t = "Entity Speed: " .. string.format("%.4f", speed)
        ent_info = newTableValue(1, t)
        table.insert(ent_info_item_data, ent_info)

        --Blip
        local blip = HUD.GET_BLIP_FROM_ENTITY(ent)
        if blip > 0 then
            local blip_id = HUD.GET_BLIP_SPRITE(blip)
            t = "Blip Sprite ID: " .. blip_id
            ent_info = newTableValue(1, t)
            table.insert(ent_info_item_data, ent_info)

            local blip_colour = HUD.GET_BLIP_COLOUR(blip)
            t = "Blip Colour: " .. blip_colour
            ent_info = newTableValue(1, t)
            table.insert(ent_info_item_data, ent_info)
        end

        --Networked
        if NETWORK.NETWORK_GET_ENTITY_IS_NETWORKED(ent) then
            t = "Networked Entity: True"
        elseif NETWORK.NETWORK_GET_ENTITY_IS_LOCAL(ent) then
            t = "Networked Entity: Local"
        end
        ent_info = newTableValue(1, t)
        table.insert(ent_info_item_data, ent_info)

        --Owner
        local owner = entities.get_owner(entities.handle_to_pointer(ent))
        owner = players.get_name(owner)
        t = "Entity Owner: " .. owner
        ent_info = newTableValue(1, t)
        table.insert(ent_info_item_data, ent_info)

        ----- Attached Entity -----
        if ENTITY.IS_ENTITY_ATTACHED(ent) then
            ent_info = newTableValue(1, "\n-----  Attached Entity  -----")
            table.insert(ent_info_item_data, ent_info)

            local attached_entity = ENTITY.GET_ENTITY_ATTACHED_TO(ent)
            local attached_hash = ENTITY.GET_ENTITY_MODEL(attached_entity)

            --Model Name
            local attached_model_name = util.reverse_joaat(attached_hash)
            if attached_model_name ~= "" then
                t = "Model Name: " .. attached_model_name
                ent_info = newTableValue(1, t)
                table.insert(ent_info_item_data, ent_info)
            end

            --Hash
            t = "Model Hash: " .. attached_hash
            ent_info = newTableValue(1, t)
            table.insert(ent_info_item_data, ent_info)

            --Type
            t = "Entity Type: " .. GET_ENTITY_TYPE(attached_entity, 2)
            ent_info = newTableValue(1, t)
            table.insert(ent_info_item_data, ent_info)
        end

        ----- Ped -----
        if ENTITY.IS_ENTITY_A_PED(ent) then
            ent_info = newTableValue(1, "\n-----  Ped  -----")
            table.insert(ent_info_item_data, ent_info)

            --Ped Type
            local ped_type = PED.GET_PED_TYPE(ent)
            t = "Ped Type: " .. enum_PedType[ped_type + 1]
            ent_info = newTableValue(1, t)
            table.insert(ent_info_item_data, ent_info)

            --Armour
            t = "Armour: " .. PED.GET_PED_ARMOUR(ent)
            ent_info = newTableValue(1, t)
            table.insert(ent_info_item_data, ent_info)

            --Money
            t = "Money: " .. PED.GET_PED_MONEY(ent)
            ent_info = newTableValue(1, t)
            table.insert(ent_info_item_data, ent_info)

            --Defensive Area
            if PED.IS_PED_DEFENSIVE_AREA_ACTIVE(ent) then
                local def_pos = PED.GET_PED_DEFENSIVE_AREA_POSITION(ent)
                t = "Defensive Area Position: " ..
                    string.format("%.4f", def_pos.x) ..
                    ", " .. string.format("%.4f", def_pos.y) .. ", " .. string.format("%.4f", def_pos.z)
                ent_info = newTableValue(1, t)
                table.insert(ent_info_item_data, ent_info)
            end

            --Visual Field Center Angle
            t = "Visual Field Center Angle: " .. PED.GET_PED_VISUAL_FIELD_CENTER_ANGLE(ent)
            ent_info = newTableValue(1, t)
            table.insert(ent_info_item_data, ent_info)

            --Accuracy
            t = "Accuracy: " .. PED.GET_PED_ACCURACY(ent)
            ent_info = newTableValue(1, t)
            table.insert(ent_info_item_data, ent_info)

            --Combat Movement
            local combat_movement = PED.GET_PED_COMBAT_MOVEMENT(ent)
            t = "Combat Movement: " .. enum_CombatMovement[combat_movement + 1]
            ent_info = newTableValue(1, t)
            table.insert(ent_info_item_data, ent_info)

            --Combat Range
            local combat_range = PED.GET_PED_COMBAT_RANGE(ent)
            t = "Combat Range: " .. enum_CombatRange[combat_range + 1]
            ent_info = newTableValue(1, t)
            table.insert(ent_info_item_data, ent_info)

            --Alertness
            local alertness = PED.GET_PED_ALERTNESS(ent)
            if alertness >= 0 then
                t = "Alertness: " .. enum_Alertness[alertness + 1]
                ent_info = newTableValue(1, t)
                table.insert(ent_info_item_data, ent_info)
            end

            --Dead
            if PED.IS_PED_DEAD_OR_DYING(ent, 1) then
                ent_info = newTableValue(1, "\n-----  Dead Ped  -----")
                table.insert(ent_info_item_data, ent_info)

                local cause_model_hash = PED.GET_PED_CAUSE_OF_DEATH(ent)

                --Cause of Death Model
                local cause_model_name = util.reverse_joaat(cause_model_hash)
                if cause_model_name ~= "" then
                    t = "Cause of Death Model: " .. cause_model_name
                    ent_info = newTableValue(1, t)
                    table.insert(ent_info_item_data, ent_info)
                end

                --Cause of Death Hash
                t = "Cause of Death Hash: " .. cause_model_hash
                ent_info = newTableValue(1, t)
                table.insert(ent_info_item_data, ent_info)

                --Death Time
                t = "Death Time: " .. PED.GET_PED_TIME_OF_DEATH(ent)
                ent_info = newTableValue(1, t)
                table.insert(ent_info_item_data, ent_info)
            end
        end

        ----- Vehicle -----
        if ENTITY.IS_ENTITY_A_VEHICLE(ent) then
            ent_info = newTableValue(1, "\n-----  Vehicle  -----")
            table.insert(ent_info_item_data, ent_info)

            --Display Name
            local display_name = util.get_label_text(VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(model_hash))
            if display_name ~= "NULL" then
                t = "Display Name: " .. display_name
                ent_info = newTableValue(1, t)
                table.insert(ent_info_item_data, ent_info)
            end

            --Vehicle Class
            local vehicle_class = VEHICLE.GET_VEHICLE_CLASS(ent)
            t = "Vehicle Class: " .. util.get_label_text("VEH_CLASS_" .. vehicle_class)
            ent_info = newTableValue(1, t)
            table.insert(ent_info_item_data, ent_info)

            --Engine Health
            t = "Engine Health: " .. VEHICLE.GET_VEHICLE_ENGINE_HEALTH(ent)
            ent_info = newTableValue(1, t)
            table.insert(ent_info_item_data, ent_info)

            --Petrol Tank Health
            t = "Petrol Tank Health: " .. VEHICLE.GET_VEHICLE_PETROL_TANK_HEALTH(ent)
            ent_info = newTableValue(1, t)
            table.insert(ent_info_item_data, ent_info)

            --Body Health
            t = "Body Health: " .. VEHICLE.GET_VEHICLE_BODY_HEALTH(ent)
            ent_info = newTableValue(1, t)
            table.insert(ent_info_item_data, ent_info)

            --- HELI ---
            if VEHICLE.IS_THIS_MODEL_A_HELI(model_hash) then
                --Heli Main Rotor Health
                t = "Heli Main Rotor Health: " .. VEHICLE.GET_HELI_MAIN_ROTOR_HEALTH(ent)
                ent_info = newTableValue(1, t)
                table.insert(ent_info_item_data, ent_info)

                --Heli Tail Rotor Health
                t = "Heli Tail Rotor Health: " .. VEHICLE.GET_HELI_TAIL_ROTOR_HEALTH(ent)
                ent_info = newTableValue(1, t)
                table.insert(ent_info_item_data, ent_info)

                --Heli Boom Rotor Health
                t = "Heli Boom Rotor Health: " .. VEHICLE.GET_HELI_TAIL_BOOM_HEALTH(ent)
                ent_info = newTableValue(1, t)
                table.insert(ent_info_item_data, ent_info)
            end

            --Dirt Level
            local dirt_level = VEHICLE.GET_VEHICLE_DIRT_LEVEL(ent)
            t = "Dirt Level: " .. string.format("%.2f", dirt_level)
            ent_info = newTableValue(1, t)
            table.insert(ent_info_item_data, ent_info)

            --Door Lock Status
            local door_lock_status = VEHICLE.GET_VEHICLE_DOOR_LOCK_STATUS(ent)
            t = "Door Lock Status: " .. enum_VehicleLockStatus[door_lock_status + 1]
            ent_info = newTableValue(1, t)
            table.insert(ent_info_item_data, ent_info)

        end

        return ent_info_item_data
    else
        local t = { "实体不存在" }
        return t
    end
end

------------------------------------------
--------- Entity Control Functions -------
---------------- START -------------------

control_ent_tick_handler = {
    Showing_info = {
        toggle = false,
        ent = nil,
    },
    Drawing_line = {
        toggle = false,
        ent = nil,
    },
    TP_to_ME = {
        toggle = false,
        ent = nil,
        x = nil,
        y = nil,
        z = nil,
    },
}

util.create_tick_handler(function()
    --在屏幕上显示实体信息
    if control_ent_tick_handler.Showing_info.toggle then
        if not ENTITY.DOES_ENTITY_EXIST(control_ent_tick_handler.Showing_info.ent) then
            util.toast("该实体已经不存在")
            control_ent_tick_handler.Showing_info.toggle = false
        else
            local ent_info_item_data = GetEntityInfo_ListItem(control_ent_tick_handler.Showing_info.ent)
            local text = ""
            for _, info in pairs(ent_info_item_data) do
                if info[1] ~= nil then
                    text = text .. info[1] .. "\n"
                end
            end
            DrawString(text, 0.7)
        end
    end

    --和实体连线
    if control_ent_tick_handler.Drawing_line.toggle then
        if not ENTITY.DOES_ENTITY_EXIST(control_ent_tick_handler.Drawing_line.ent) then
            util.toast("该实体已经不存在")
            control_ent_tick_handler.Drawing_line.toggle = false
        else
            local pos1 = ENTITY.GET_ENTITY_COORDS(players.user_ped())
            local pos2 = ENTITY.GET_ENTITY_COORDS(control_ent_tick_handler.Drawing_line.ent)
            GRAPHICS.DRAW_LINE(pos1.x, pos1.y, pos1.z, pos2.x, pos2.y, pos2.z, 255, 0, 255, 255)
            util.draw_ar_beacon(pos2)
        end
    end

    --锁定实体传送到我
    if control_ent_tick_handler.TP_to_ME.toggle then
        if not ENTITY.DOES_ENTITY_EXIST(control_ent_tick_handler.TP_to_ME.ent) then
            util.toast("该实体已经不存在")
            control_ent_tick_handler.TP_to_ME.toggle = false
        else
            TP_TO_ME(control_ent_tick_handler.TP_to_ME.ent, control_ent_tick_handler.TP_to_ME.x,
                control_ent_tick_handler.TP_to_ME.y, control_ent_tick_handler.TP_to_ME.z)
        end
    end

end)

function Clear_control_ent_tick_handler()
    control_ent_tick_handler.Showing_info.toggle = false
    control_ent_tick_handler.Drawing_line.toggle = false
    control_ent_tick_handler.TP_to_ME.toggle = false
end

-- 无敌强化NPC
function control_ped_enhanced(ped)
    ENTITY.SET_ENTITY_INVINCIBLE(ped, true)
    ENTITY.SET_ENTITY_PROOFS(ped, true, true, true, true, true, true, true, true)
    PED.SET_PED_CAN_RAGDOLL(ped, false)

    PED.SET_PED_HIGHLY_PERCEPTIVE(ped, true)
    PED.SET_PED_VISUAL_FIELD_PERIPHERAL_RANGE(ped, 500.0)
    PED.SET_PED_SEEING_RANGE(ped, 500.0)
    PED.SET_PED_HEARING_RANGE(ped, 500.0)
    PED.SET_PED_VISUAL_FIELD_MIN_ANGLE(ped, 90.0)
    PED.SET_PED_VISUAL_FIELD_MAX_ANGLE(ped, 90.0)
    PED.SET_PED_VISUAL_FIELD_MIN_ELEVATION_ANGLE(ped, 90.0)
    PED.SET_PED_VISUAL_FIELD_MAX_ELEVATION_ANGLE(ped, 90.0)
    PED.SET_PED_VISUAL_FIELD_CENTER_ANGLE(ped, 90.0)

    WEAPON.SET_PED_INFINITE_AMMO_CLIP(ped, true)
    PED.SET_PED_SHOOT_RATE(ped, 1000)
    PED.SET_PED_ACCURACY(ped, 100)

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
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 55, true) --CanSeeUnderwaterPeds
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 58, true) --DisableFleeFromCombat

    PED.SET_PED_COMBAT_MOVEMENT(ped, 2) --WillAdvance
    PED.SET_PED_COMBAT_ABILITY(ped, 2) --Professional
    PED.SET_PED_COMBAT_RANGE(ped, 2) --Far
    PED.SET_PED_TARGET_LOSS_RESPONSE(ped, 1) --NeverLoseTarget

    PED.SET_COMBAT_FLOAT(ped, 10, 500.0)
end

------ 创建对应实体的menu操作 ------

--- All entity type ---
function entity_control_all(menu_parent, ent, index)
    menu.divider(menu_parent, menu.get_menu_name(menu_parent))
    menu.toggle(menu_parent, "描绘实体连线", {}, "", function(toggle)
        if toggle then
            if control_ent_tick_handler.Drawing_line.toggle then
                util.toast("正在描绘连线其它的实体")
            else
                control_ent_tick_handler.Drawing_line.ent = ent
                control_ent_tick_handler.Drawing_line.toggle = true
            end
        else
            if control_ent_tick_handler.Drawing_line.toggle and control_ent_tick_handler.Drawing_line.ent ~= ent then
            else
                control_ent_tick_handler.Drawing_line.toggle = false
            end
        end
    end)
    menu.toggle(menu_parent, "显示实体信息", {}, "", function(toggle)
        if toggle then
            if control_ent_tick_handler.Showing_info.toggle then
                util.toast("正在显示其它的实体信息")
            else
                control_ent_tick_handler.Showing_info.ent = ent
                control_ent_tick_handler.Showing_info.toggle = true
            end
        else
            if control_ent_tick_handler.Showing_info.toggle and control_ent_tick_handler.Showing_info.ent ~= ent then
            else
                control_ent_tick_handler.Showing_info.toggle = false
            end
        end
    end)
    menu.action(menu_parent, "复制实体信息", {}, "", function()
        local ent_info_item_data = GetEntityInfo_ListItem(ent)
        local text = ""
        for _, info in pairs(ent_info_item_data) do
            if info[1] ~= nil then
                text = text .. info[1] .. "\n"
            end
        end
        util.copy_to_clipboard(text, false)
        util.toast("完成")
    end)

    local save_hash = menu.list(menu_parent, "保存到 Hash 列表", {}, "")
    local save_ent_hash_name = ""
    menu.text_input(save_hash, "名称", { "save_ent_hash" .. index }, "", function(value)
        save_ent_hash_name = value
    end)
    menu.action(save_hash, "保存", {}, "", function()
        Saved_Hash_List.save(save_ent_hash_name, ent)
    end)

    menu.click_slider(menu_parent, "请求控制实体", { "request_ctrl_ent" .. index }, "发送请求控制的次数",
        1, 100
        , 20, 1, function(value)
        if RequestControl(ent, value) then
            util.toast("请求控制成功！")
        else
            util.toast("请求控制失败")
        end
    end)

    local entity_options = menu.list(menu_parent, "Entity 选项", {}, "")
    menu.toggle(entity_options, "无敌", {}, "", function(toggle)
        ENTITY.SET_ENTITY_INVINCIBLE(ent, toggle)
        ENTITY.SET_ENTITY_PROOFS(ent, toggle, toggle, toggle, toggle, toggle, toggle, toggle, toggle)
    end)
    menu.toggle(entity_options, "冻结", {}, "", function(toggle)
        ENTITY.FREEZE_ENTITY_POSITION(ent, toggle)
    end)
    menu.toggle(entity_options, "燃烧", {}, "似乎只对NPC有效", function(toggle)
        if toggle then
            FIRE.START_ENTITY_FIRE(ent)
        else
            FIRE.STOP_ENTITY_FIRE(ent)
        end
    end)
    menu.click_slider(entity_options, "爆炸", { "ctrl_ent" .. index .. "_explosion" }, "选择爆炸类型", -1, 83, 2
        , 1, function(value)
        local pos = ENTITY.GET_ENTITY_COORDS(ent)
        FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z - 0.5, value, 100.0, true, false, 0.0, false)
    end)
    menu.toggle(entity_options, "无碰撞", {}, "可以直接穿过实体", function(toggle)
        ENTITY.SET_ENTITY_COLLISION(ent, not toggle, not toggle)
    end)
    menu.toggle(entity_options, "隐形", {}, "将实体隐形", function(toggle)
        ENTITY.SET_ENTITY_VISIBLE(ent, not toggle, 0)
    end)
    menu.toggle(entity_options, "无重力", {}, "", function(toggle)
        ENTITY.SET_ENTITY_HAS_GRAVITY(ent, not toggle)
    end)
    menu.toggle(entity_options, "添加地图标记", {}, "", function(toggle)
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
    menu.click_slider(entity_options, "设置透明度", { "ctrl_ent" .. index .. "_alpha" },
        "Ranging from 0 to 255 but chnages occur after every 20 percent (after every 51).", 0, 255, 0, 5,
        function(value)
            ENTITY.SET_ENTITY_ALPHA(ent, value, false)
        end)
    menu.click_slider(entity_options, "设置最大速度", { "ctrl_ent" .. index .. "_max_speed" }, "", 0.0, 1000.0, 0.0
        , 10.0,
        function(value)
            ENTITY.SET_ENTITY_MAX_SPEED(ent, value)
        end)
    menu.action(entity_options, "设置为任务实体", {}, "避免实体被自动清理", function()
        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ent, true, true)
        ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION(ent, true)
        if ENTITY.IS_ENTITY_A_VEHICLE(ent) then
            VEHICLE.SET_VEHICLE_STAYS_FROZEN_WHEN_CLEANED_UP(ent, true)
            VEHICLE.SET_CLEAR_FREEZE_WAITING_ON_COLLISION_ONCE_PLAYER_ENTERS(ent, false)
        end
        util.toast(ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent))
    end)
    menu.action(entity_options, "设置为网络实体", {}, "可将本地实体同步给其他玩家", function()
        util.toast(Set_Entity_Networked(ent))
    end)
    menu.action(entity_options, "删除", {}, "", function()
        entities.delete_by_handle(ent)
    end)

    menu.divider(entity_options, "血量")
    menu.action(entity_options, "获取当前血量", {}, "", function()
        local health = ENTITY.GET_ENTITY_HEALTH(ent)
        local max_health = ENTITY.GET_ENTITY_MAX_HEALTH(ent)
        util.toast("Health: " .. health .. "/" .. max_health)
    end)
    local ctrl_ent_health = 1000
    menu.slider(entity_options, "血量", { "ctrl_ent" .. index .. "_health" }, "", 0, 100000, 1000, 100,
        function(value)
            ctrl_ent_health = value
        end)
    menu.action(entity_options, "设置血量", {}, "", function()
        ENTITY.SET_ENTITY_HEALTH(ent, ctrl_ent_health)
    end)
    menu.action(entity_options, "设置最大血量", {}, "", function()
        ENTITY.SET_ENTITY_MAX_HEALTH(ent, ctrl_ent_health)
    end)

    ----- Teleport -----
    local teleport_options = menu.list(menu_parent, "传送 选项", {}, "")
    local ctrl_ent_tp_x = 0.0
    local ctrl_ent_tp_y = 2.0
    local ctrl_ent_tp_z = 0.0
    menu.slider_float(teleport_options, "前/后", { "ctrl_ent" .. index .. "_tp_x" }, "", -5000, 5000, 200, 50,
        function(value)
            ctrl_ent_tp_y = value * 0.01
        end)
    menu.slider_float(teleport_options, "上/下", { "ctrl_ent" .. index .. "_tp_y" }, "", -5000, 5000, 0, 50,
        function(value)
            ctrl_ent_tp_z = value * 0.01
        end)
    menu.slider_float(teleport_options, "左/右", { "ctrl_ent" .. index .. "_tp_z" }, "", -5000, 5000, 0, 50,
        function(value)
            ctrl_ent_tp_x = value * 0.01
        end)

    menu.action(teleport_options, "传送到实体", {}, "", function()
        TP_TO_ENTITY(ent, ctrl_ent_tp_x, ctrl_ent_tp_y, ctrl_ent_tp_z)
    end)
    menu.action(teleport_options, "传送到我", {}, "", function()
        TP_TO_ME(ent, ctrl_ent_tp_x, ctrl_ent_tp_y, ctrl_ent_tp_z)
    end)
    menu.toggle(teleport_options, "锁定传送到我", {}, "如果更改了位移，需要重新开关此选项",
        function(toggle)
            if toggle then
                if control_ent_tick_handler.TP_to_ME.toggle then
                    util.toast("正在锁定传送其它的实体")
                else
                    control_ent_tick_handler.TP_to_ME.ent = ent
                    control_ent_tick_handler.TP_to_ME.x = ctrl_ent_tp_x
                    control_ent_tick_handler.TP_to_ME.y = ctrl_ent_tp_y
                    control_ent_tick_handler.TP_to_ME.z = ctrl_ent_tp_z
                    control_ent_tick_handler.TP_to_ME.toggle = true
                end
            else
                if control_ent_tick_handler.TP_to_ME.toggle and control_ent_tick_handler.TP_to_ME.ent ~= ent then
                else
                    control_ent_tick_handler.TP_to_ME.toggle = false
                end
            end
        end)

    ----- Movement -----
    local movement_options = menu.list(menu_parent, "移动 选项", {}, "")
    menu.click_slider_float(movement_options, "前/后 移动", { "ctrl_ent" .. index .. "_move_y" }, "", -10000, 10000,
        0, 50,
        function(value)
            value = value * 0.01
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, 0.0, value, 0.0)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
        end)
    menu.click_slider_float(movement_options, "左/右 移动", { "ctrl_ent" .. index .. "_move_x" }, "", -10000, 10000,
        0, 50,
        function(value)
            value = value * 0.01
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, value, 0.0, 0.0)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
        end)
    menu.click_slider_float(movement_options, "上/下 移动", { "ctrl_ent" .. index .. "_move_z" }, "", -10000, 10000,
        0, 50,
        function(value)
            value = value * 0.01
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, 0.0, 0.0, value)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
        end)
    menu.click_slider_float(movement_options, "朝向", { "ctrl_ent" .. index .. "_head" }, "", -36000, 36000, 0, 100,
        function(value)
            value = value * 0.01
            local head = ENTITY.GET_ENTITY_HEADING(ent)
            ENTITY.SET_ENTITY_HEADING(ent, head + value)
        end)

    menu.divider(movement_options, "坐标")
    menu.action(movement_options, "刷新坐标", {}, "", function()
        local coords = ENTITY.GET_ENTITY_COORDS(ent)
        local pos = {}
        pos.x = string.format("%.2f", coords.x)
        pos.y = string.format("%.2f", coords.y)
        pos.z = string.format("%.2f", coords.z)
        menu.trigger_commands("ctrlent" .. index .. "x " .. pos.x)
        menu.trigger_commands("ctrlent" .. index .. "y " .. pos.y)
        menu.trigger_commands("ctrlent" .. index .. "z " .. pos.z)
    end)

    local coords = ENTITY.GET_ENTITY_COORDS(ent)
    local pos = {}
    pos.x = string.format("%.2f", coords.x) * 100
    pos.y = string.format("%.2f", coords.y) * 100
    pos.z = string.format("%.2f", coords.z) * 100
    menu.slider_float(movement_options, "X:", { "ctrl_ent" .. index .. "_x" }, "", -1000000, 1000000,
        math.ceil(pos.x),
        50
        , function(value)
        value = value * 0.01
        local coords = ENTITY.GET_ENTITY_COORDS(ent)
        ENTITY.SET_ENTITY_COORDS(ent, value, coords.y, coords.z, true, false, false, false)
    end)
    menu.slider_float(movement_options, "Y:", { "ctrl_ent" .. index .. "_y" }, "", -1000000, 1000000,
        math.ceil(pos.y), 50,
        function(value)
            value = value * 0.01
            local coords = ENTITY.GET_ENTITY_COORDS(ent)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, value, coords.z, true, false, false, false)
        end)
    menu.slider_float(movement_options, "Z:", { "ctrl_ent" .. index .. "_z" }, "", -1000000, 1000000,
        math.ceil(pos.z), 50,
        function(value)
            value = value * 0.01
            local coords = ENTITY.GET_ENTITY_COORDS(ent)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, value, true, false, false, false)
        end)

end

--- Ped entity type ---
function entity_control_ped(menu_parent, ped, index)
    local ped_options = menu.list(menu_parent, "Ped 选项", {}, "")
    menu.action(ped_options, "传送到我的载具", {}, "", function()
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
        if vehicle then
            if VEHICLE.ARE_ANY_VEHICLE_SEATS_FREE(vehicle) then
                PED.SET_PED_INTO_VEHICLE(ped, vehicle, -2)
            end
        end
    end)
    menu.list_action(ped_options, "给予武器", {}, "", weapon_name_ListItem, function(value)
        local weaponHash = util.joaat(weapon_model_list[value])
        WEAPON.GIVE_WEAPON_TO_PED(ped, weaponHash, -1, false, true)
        WEAPON.SET_CURRENT_PED_WEAPON(ped, weaponHash, false)
    end)
    menu.action(ped_options, "移除全部武器", {}, "", function()
        WEAPON.REMOVE_ALL_PED_WEAPONS(ped)
    end)
    menu.action(ped_options, "克隆", {}, "", function()
        local model = ENTITY.GET_ENTITY_MODEL(ped)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 0.0, 2.0)
        local ped_type = PED.GET_PED_TYPE(ped)
        local heading = ENTITY.GET_ENTITY_HEADING(ped)
        local clone_ped = Create_Network_Ped(ped_type, model, coords.x, coords.y, coords.z, heading)
        PED.CLONE_PED_TO_TARGET(ped, clone_ped)
    end)
    menu.action(ped_options, "随机变装", {}, "", function()
        PED.SET_PED_RANDOM_COMPONENT_VARIATION(ped, 0)
        PED.SET_PED_RANDOM_PROPS(ped)
    end)
    menu.action(ped_options, "与玩家友好", {}, "", function()
        local player_rel_hash = PED.GET_PED_RELATIONSHIP_GROUP_HASH(players.user_ped())
        PED.SET_RELATIONSHIP_BETWEEN_GROUPS(0, player_rel_hash, player_rel_hash)
        PED.SET_PED_RELATIONSHIP_GROUP_HASH(ped, player_rel_hash)
    end)

    local ped_combat_options = menu.list(menu_parent, "NPC作战能力选项", {}, "")
    menu.action(ped_combat_options, "一键无敌强化NPC", {}, "适用于友方NPC", function()
        control_ped_enhanced(ped)
        util.toast("Done!")
    end)
    menu.click_slider(ped_combat_options, "射击频率", {}, "", 0, 1000, 100, 10, function(value)
        PED.SET_PED_SHOOT_RATE(ped, value)
    end)
    menu.click_slider(ped_combat_options, "精准度", {}, "", 0, 100, 50, 10, function(value)
        PED.SET_PED_ACCURACY(ped, value)
    end)
    menu.slider_text(ped_combat_options, "战斗能力", {}, "", { "Poor", "Average", "Professional", "NumTypes" },
        function(value)
            local eCombatAbility = {
                CA_Poor,
                CA_Average,
                CA_Professional,
                CA_NumTypes
            }
            PED.SET_PED_COMBAT_ABILITY(ped, eCombatAbility[value])
        end)
    menu.slider_text(ped_combat_options, "战斗范围", {}, "", { "Near", "Medium", "Far", "VeryFar", "NumRanges" },
        function(value)
            local eCombatRange = {
                CR_Near,
                CR_Medium,
                CR_Far,
                CR_VeryFar,
                CR_NumRanges
            }
            PED.SET_PED_COMBAT_RANGE(ped, eCombatRange[value])
        end)
    menu.slider_text(ped_combat_options, "战斗走位", {}, "",
        { "Stationary", "Defensive", "WillAdvance", "WillRetreat" },
        function(value)
            local eCombatMovement = {
                CM_Stationary,
                CM_Defensive,
                CM_WillAdvance,
                CM_WillRetreat
            }
            PED.SET_PED_COMBAT_MOVEMENT(ped, eCombatMovement[value])
        end)

    local ped_task_options = menu.list(menu_parent, "Ped Task 选项", {}, "")

    menu.action(ped_task_options, "Clear Ped Tasks Immediately", {}, "", function()
        TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
    end)
    menu.action(ped_task_options, "Clear Ped All Tasks", {}, "", function()
        TASK.CLEAR_PED_TASKS(ped)
        TASK.CLEAR_DEFAULT_PRIMARY_TASK(ped)
        TASK.CLEAR_PED_SECONDARY_TASK(ped)
        TASK.TASK_CLEAR_LOOK_AT(ped)
        TASK.TASK_CLEAR_DEFENSIVE_AREA(ped)
        TASK.CLEAR_DRIVEBY_TASK_UNDERNEATH_DRIVING_TASK(ped)
        if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
            local veh = PED.GET_VEHICLE_PED_IS_USING(ped)
            TASK.CLEAR_PRIMARY_VEHICLE_TASK(veh)
            TASK.CLEAR_VEHICLE_CRASH_TASK(veh)
        end
    end)

    --- Ped Task Follow ---
    local task_follow = menu.list(ped_task_options, "NPC 跟随", {}, "")
    local ped_follow = {
        x = 0.0,
        y = -1.0,
        z = 0.0,
        movementSpeed = 7.0,
        timeout = -1,
        stoppingRange = 10.0,
        persistFollowing = true
    }
    menu.slider_float(task_follow, "offsetX", { "task_ped" .. index .. "follow_x" }, "", -10000, 10000, 0, 100,
        function(value)
            ped_follow.x = value * 0.01
        end)
    menu.slider_float(task_follow, "offsetY", { "task_ped" .. index .. "follow_y" }, "", -10000, 10000, -100, 100,
        function(value)
            ped_follow.y = value * 0.01
        end)
    menu.slider_float(task_follow, "offsetZ", { "task_ped" .. index .. "follow_z" }, "", -10000, 10000, 0, 100,
        function(value)
            ped_follow.z = value * 0.01
        end)
    menu.slider_float(task_follow, "移动速度", { "task_ped" .. index .. "follow_movementSpeed" }, "", 0, 100000, 700
        , 100,
        function(value)
            ped_follow.movementSpeed = value * 0.01
        end)
    menu.slider(task_follow, "超时时间", { "task_ped" .. index .. "follow_timeout" }, "", -1, 10000, -1, 1,
        function(value)
            ped_follow.timeout = value
        end)
    menu.slider_float(task_follow, "停止跟随的最远距离", { "task_ped" .. index .. "follow_stoppingRange" }, "",
        0, 100000, 1000, 100,
        function(value)
            ped_follow.stoppingRange = value * 0.01
        end)
    menu.toggle(task_follow, "持续跟随", {}, "", function(toggle)
        ped_follow.persistFollowing = toggle
    end, true)
    menu.action(task_follow, "设置任务", {}, "", function()
        TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(ped, players.user_ped(), ped_follow.x, ped_follow.y, ped_follow.z,
            ped_follow.movementSpeed,
            ped_follow.timeout, ped_follow.stoppingRange, ped_follow.persistFollowing)
        util.toast("Done!")
    end)

    menu.action(ped_task_options, "躲在掩体处", {}, "", function()
        TASK.TASK_STAY_IN_COVER(ped)
    end)

end

--- Vehicle entity type ---
function entity_control_vehicle(menu_parent, vehicle, index)
    local vehicle_options = menu.list(menu_parent, "Vehicle 选项", {}, "")
    menu.action(vehicle_options, "传送到载具内", {}, "", function()
        if VEHICLE.ARE_ANY_VEHICLE_SEATS_FREE(vehicle) then
            PED.SET_PED_INTO_VEHICLE(players.user_ped(), vehicle, -2)
        else
            util.toast("载具已无空座位")
        end
    end)
    menu.action(vehicle_options, "传送到载具驾驶位（强制）", {}, "会踢出原座位的NPC", function()
        if VEHICLE.IS_VEHICLE_SEAT_FREE(vehicle, -1, false) then
            PED.SET_PED_INTO_VEHICLE(players.user_ped(), vehicle, -1)
        else
            local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
            if ped then
                local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(vehicle, 0.0, 0.0, 3.0)
                ENTITY.SET_ENTITY_COORDS(ped, coords.x, coords.y, coords.z, true, false, false, false)
                PED.SET_PED_INTO_VEHICLE(players.user_ped(), vehicle, -1)
            end
        end
    end)
    menu.action(vehicle_options, "传送到载具副驾驶位（强制）", {}, "会踢出原座位的NPC", function()
        if VEHICLE.GET_VEHICLE_NUMBER_OF_PASSENGERS(vehicle, true, false) > 1 then
            if VEHICLE.IS_VEHICLE_SEAT_FREE(vehicle, 0, false) then
                PED.SET_PED_INTO_VEHICLE(players.user_ped(), vehicle, 0)
            else
                local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, 0)
                if ped then
                    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(vehicle, 0.0, 0.0, 3.0)
                    ENTITY.SET_ENTITY_COORDS(ped, coords.x, coords.y, coords.z, true, false, false, false)
                    PED.SET_PED_INTO_VEHICLE(players.user_ped(), vehicle, 0)
                end
            end
        end
    end)

    menu.click_slider(vehicle_options, "向前加速", { "ctrl_veh" .. index .. "_forward_speed" }, "", 0.0, 1000.0, 30.0
        , 10.0,
        function(value)
            VEHICLE.SET_VEHICLE_FORWARD_SPEED(vehicle, value)
        end)

    menu.action(vehicle_options, "修复载具", {}, "", function()
        Fix_Vehicle(vehicle)
    end)
    menu.action(vehicle_options, "升级载具", {}, "", function()
        Upgrade_Vehicle(vehicle)
    end)

    local ctrl_veh_window_list_item = {
        { "删除车窗" },
        { "摇下车窗" },
        { "摇上车窗" },
        { "粉碎车窗" },
        { "修复车窗" }
    }
    menu.list_action(vehicle_options, "车窗", {}, "", ctrl_veh_window_list_item, function(value)
        if value == 1 then
            for i = 0, 7 do
                VEHICLE.REMOVE_VEHICLE_WINDOW(vehicle, i)
            end
        elseif value == 2 then
            for i = 0, 7 do
                VEHICLE.ROLL_DOWN_WINDOW(vehicle, i)
            end
        elseif value == 3 then
            for i = 0, 7 do
                VEHICLE.ROLL_UP_WINDOW(vehicle, i)
            end
        elseif value == 4 then
            for i = 0, 7 do
                VEHICLE.SMASH_VEHICLE_WINDOW(vehicle, i)
            end
        elseif value == 5 then
            for i = 0, 7 do
                VEHICLE.FIX_VEHICLE_WINDOW(vehicle, i)
            end
        end
    end)
    menu.slider_text(vehicle_options, "破坏车门", {}, "", { "拆下车门", "删除车门" }, function(value)
        if value == 1 then
            for i = 0, 3 do
                VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, i, false)
            end
        else
            for i = 0, 3 do
                VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, i, true)
            end
        end
    end)
    menu.toggle(vehicle_options, "车门开关", {}, "", function(toggle)
        if toggle then
            for i = 0, 3 do
                VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, i, false, false)
            end
        else
            VEHICLE.SET_VEHICLE_DOORS_SHUT(vehicle, false)
        end
    end)
    menu.toggle(vehicle_options, "车门锁", {}, "", function(toggle)
        if toggle then
            VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle, 2)
        else
            VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle, 1)
        end
    end)
    menu.toggle(vehicle_options, "爆胎", {}, "", function(toggle)
        if toggle then
            for i = 0, 5 do
                VEHICLE.SET_VEHICLE_TYRE_BURST(vehicle, i, true, 1000.0)
            end
        else
            for i = 0, 5 do
                VEHICLE.SET_VEHICLE_TYRE_FIXED(vehicle, i)
            end
        end
    end)

    local ped = get_vehicle_ped(vehicle, -1)
    if ped then
        local veh_task_options = menu.list(menu_parent, "Vehicle Task 选项", {}, "")

        menu.action(veh_task_options, "Clear Driver Tasks Immediately", {}, "", function()
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
        end)
        menu.action(veh_task_options, "Clear Driver All Tasks", {}, "", function()
            TASK.CLEAR_PED_TASKS(ped)
            TASK.CLEAR_DEFAULT_PRIMARY_TASK(ped)
            TASK.CLEAR_PED_SECONDARY_TASK(ped)
            TASK.TASK_CLEAR_LOOK_AT(ped)
            TASK.TASK_CLEAR_DEFENSIVE_AREA(ped)
            TASK.CLEAR_DRIVEBY_TASK_UNDERNEATH_DRIVING_TASK(ped)
            if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
                local veh = PED.GET_VEHICLE_PED_IS_USING(ped)
                TASK.CLEAR_PRIMARY_VEHICLE_TASK(veh)
                TASK.CLEAR_VEHICLE_CRASH_TASK(veh)
            end
        end)

        --- Vehicle Task Follow ---
        local task_follow = menu.list(veh_task_options, "载具 跟随", {}, "")
        local veh_follow = {
            speed = 30.0,
            drivingStyle = 786603,
            minDistance = 5.0
        }
        menu.slider_float(task_follow, "速度", { "task_veh" .. index .. "follow_speed" }, "", 0, 100000, 3000
            , 100,
            function(value)
                veh_follow.speed = value * 0.01
            end)
        menu.list_select(task_follow, "驾驶风格", {}, "", driving_style_name_ListItem, 1, function(value)
            veh_follow.drivingStyle = driving_style_list[value]
        end)
        menu.slider_float(task_follow, "最小跟随距离", { "task_veh" .. index .. "follow_minDistance" }, "", 0
            , 100000, 500
            , 100,
            function(value)
                veh_follow.minDistance = value * 0.01
            end)
        menu.action(task_follow, "设置任务", {}, "", function()
            TASK.TASK_VEHICLE_FOLLOW(ped, vehicle, players.user_ped(), veh_follow.speed, veh_follow.drivingStyle,
                veh_follow.minDistance)
            util.toast("Done!")
        end)

        --- Vehicle Task Escort ---
        local task_escort = menu.list(veh_task_options, "载具 护送", {}, "")
        local veh_escort = {
            mode = -1,
            speed = 30.0,
            drivingStyle = 786603,
            minDistance = 5.0,
            minHeightAboveTerrain = 20,
            noRoadsDistance = 5.0
        }
        local task_veh_escort_mode_list = {
            { "后面" }, -- -1
            { "前面" }, -- 0
            { "左边" }, -- 1
            { "右边" }, -- 2
            { "后左边" }, -- 3
            { "后右边" }, -- 4
        }
        menu.list_select(task_escort, "护送模式", {},
            "The mode defines the relative position to the targetVehicle. The ped will try to position its vehicle there."
            , task_veh_escort_mode_list, 1, function(value)
            veh_escort.mode = value - 2
        end)
        menu.slider_float(task_escort, "速度", { "task_veh" .. index .. "escort_speed" }, "", 0, 100000, 3000
            , 100,
            function(value)
                veh_escort.speed = value * 0.01
            end)
        menu.list_select(task_escort, "驾驶风格", {}, "", driving_style_name_ListItem, 1, function(value)
            veh_escort.drivingStyle = driving_style_list[value]
        end)
        menu.slider_float(task_escort, "最小跟随距离", { "task_veh" .. index .. "escort_minDistance" },
            "minDistance is ignored if drivingstyle is avoiding traffic, but Rushed is fine.", 0
            , 100000, 500
            , 100,
            function(value)
                veh_escort.minDistance = value * 0.01
            end)
        menu.slider(task_escort, "minHeightAboveTerrain", { "task_veh" .. index .. "escort_minHeightAboveTerrain" }, "",
            0, 1000, 20, 1, function(value)
            veh_escort.minHeightAboveTerrain = value
        end)
        menu.slider_float(task_escort, "No Roads Distance", { "task_veh" .. index .. "escort_noRoadsDistance" },
            "if the target is closer than noRoadsDistance, the driver will ignore pathing/roads and follow you directly."
            , 0
            , 100000, 500
            , 100,
            function(value)
                veh_escort.noRoadsDistance = value * 0.01
            end)
        menu.action(task_escort, "设置任务", {},
            "Makes a ped follow the targetVehicle with <minDistance> in between.", function()
            if PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
                local target_vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
                TASK.TASK_VEHICLE_ESCORT(ped, vehicle, target_vehicle, veh_escort.mode, veh_escort.speed,
                    veh_escort.drivingStyle, veh_escort.minDistance, veh_escort.minHeightAboveTerrain,
                    veh_escort.noRoadsDistance)
                util.toast("Done!")
            else
                util.toast("你需要先进入一辆载具后才能设置任务")
            end
        end)


    end


end

--- All Entities Control ---
function all_entities_control(menu_parent, entity_list)
    menu.click_slider(menu_parent, "请求控制实体", { "request_ctrl_ents" }, "发送请求控制的次数", 1, 100
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
    menu.click_slider(menu_parent, "爆炸", { "ctrl_ents_explosion" }, "选择爆炸类型", -1, 83, 2
        , 1, function(value)
        for k, ent in pairs(entity_list) do
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                local pos = ENTITY.GET_ENTITY_COORDS(ent)
                FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z - 0.5, value, 100.0, true, false, 0.0, false)
            end
        end
        util.toast("Done!")
    end)
    menu.click_slider(menu_parent, "设置实体血量", { "ctrl_ents_health" }, "", 0, 100000
        , 100, 100, function(value)
        for k, ent in pairs(entity_list) do
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                ENTITY.SET_ENTITY_HEALTH(ent, value)
            end
        end
        util.toast("Done!")
    end)
    menu.click_slider(menu_parent, "设置最大速度", { "ctrl_ents_max_speed" }, "", 0.0, 1000.0, 0.0
        , 10.0,
        function(value)
            for k, ent in pairs(entity_list) do
                if ENTITY.DOES_ENTITY_EXIST(ent) then
                    ENTITY.SET_ENTITY_MAX_SPEED(ent, value)
                end
            end
            util.toast("Done!")
        end)
    menu.action(menu_parent, "删除", {}, "", function()
        for k, ent in pairs(entity_list) do
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                entities.delete_by_handle(ent)
            end
        end
        util.toast("Done!")
    end)

    ----- Teleport -----
    local teleport_options = menu.list(menu_parent, "传送 选项", {}, "")
    local ctrl_ents_tp_x = 0.0
    local ctrl_ents_tp_y = 2.0
    local ctrl_ents_tp_z = 0.0
    local ctrl_ents_tp_delay = 1500
    menu.slider_float(teleport_options, "前/后", { "ctrl_ents_tp_y" }, "", -5000, 5000, 200, 50,
        function(value)
            ctrl_ents_tp_y = value * 0.01
        end)
    menu.slider_float(teleport_options, "上/下", { "ctrl_ents_tp_z" }, "", -5000, 5000, 0, 50,
        function(value)
            ctrl_ents_tp_z = value * 0.01
        end)
    menu.slider_float(teleport_options, "左/右", { "ctrl_ents_tp_x" }, "", -5000, 5000, 0, 50,
        function(value)
            ctrl_ents_tp_x = value * 0.01
        end)
    menu.slider(teleport_options, "传送延时", { "ctrl_ents_tp_delay" }, "单位: ms", 0, 5000, 1500, 100,
        function(value)
            ctrl_ents_tp_delay = value
        end)

    menu.action(teleport_options, "传送到我", {}, "", function()
        for k, ent in pairs(entity_list) do
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                TP_TO_ME(ent, ctrl_ents_tp_x, ctrl_ents_tp_y, ctrl_ents_tp_z)
                util.yield(ctrl_ents_tp_delay)
            end
        end
        util.toast("Done!")
    end)

    ----- Movement -----
    local movement_options = menu.list(menu_parent, "移动 选项", {}, "")
    menu.click_slider_float(movement_options, "前/后 移动", { "ctrl_ents_move_y" }, "", -10000, 10000,
        0, 50,
        function(value)
            value = value * 0.01
            for k, ent in pairs(entity_list) do
                if ENTITY.DOES_ENTITY_EXIST(ent) then
                    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, 0.0, value, 0.0)
                    ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
                end
            end
            util.toast("Done!")
        end)
    menu.click_slider_float(movement_options, "左/右 移动", { "ctrl_ents_move_x" }, "", -10000, 10000,
        0, 50,
        function(value)
            value = value * 0.01
            for k, ent in pairs(entity_list) do
                if ENTITY.DOES_ENTITY_EXIST(ent) then
                    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, value, 0.0, 0.0)
                    ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
                end
            end
            util.toast("Done!")
        end)
    menu.click_slider_float(movement_options, "上/下 移动", { "ctrl_ents_move_z" }, "", -10000, 10000,
        0, 50,
        function(value)
            value = value * 0.01
            for k, ent in pairs(entity_list) do
                if ENTITY.DOES_ENTITY_EXIST(ent) then
                    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, 0.0, 0.0, value)
                    ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
                end
            end
            util.toast("Done!")
        end)
    menu.click_slider_float(movement_options, "朝向", { "ctrl_ents_head" }, "", -36000, 36000, 0, 100,
        function(value)
            value = value * 0.01
            for k, ent in pairs(entity_list) do
                if ENTITY.DOES_ENTITY_EXIST(ent) then
                    local head = ENTITY.GET_ENTITY_HEADING(ent)
                    ENTITY.SET_ENTITY_HEADING(ent, head + value)
                end
            end
            util.toast("Done!")
        end)

end

----------------- END --------------------
-------- Entity Control Functions --------
------------------------------------------



--------------------------
----- STAT Functions -----
--------------------------
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

function ADD_MP_INDEX(Stat)
    if not IS_MPPLY(Stat) then
        Stat = MP_INDEX() .. Stat
    end
    return Stat
end

function STAT_SET_INT(Stat, Value)
    STATS.STAT_SET_INT(util.joaat(ADD_MP_INDEX(Stat)), Value, true)
end

function STAT_SET_FLOAT(Stat, Value)
    STATS.STAT_SET_FLOAT(util.joaat(ADD_MP_INDEX(Stat)), Value, true)
end

function STAT_SET_BOOL(Stat, Value)
    STATS.STAT_SET_BOOL(util.joaat(ADD_MP_INDEX(Stat)), Value, true)
end

function STAT_SET_STRING(Stat, Value)
    STATS.STAT_SET_STRING(util.joaat(ADD_MP_INDEX(Stat)), Value, true)
end

function STAT_SET_DATE(Stat, Year, Month, Day, Hour, Min)
    local DatePTR = memory.alloc(7 * 8)
    memory.write_int(DatePTR, Year)
    memory.write_int(DatePTR + 8, Month)
    memory.write_int(DatePTR + 16, Day)
    memory.write_int(DatePTR + 24, Hour)
    memory.write_int(DatePTR + 32, Min)
    memory.write_int(DatePTR + 40, 0) -- Second
    memory.write_int(DatePTR + 48, 0) -- Millisecond
    STATS.STAT_SET_DATE(util.joaat(ADD_MP_INDEX(Stat)), DatePTR, 7, true)
end

function STAT_SET_INCREMENT(Stat, Value)
    STATS.STAT_INCREMENT(util.joaat(ADD_MP_INDEX(Stat)), Value, true)
end

function STAT_GET_INT(Stat)
    local IntPTR = memory.alloc_int()
    STATS.STAT_GET_INT(util.joaat(ADD_MP_INDEX(Stat)), IntPTR, -1)
    return memory.read_int(IntPTR)
end

function STAT_GET_FLOAT(Stat)
    local FloatPTR = memory.alloc_int()
    STATS.STAT_GET_FLOAT(util.joaat(ADD_MP_INDEX(Stat)), FloatPTR, -1)
    return tonumber(string.format("%.3f", memory.read_float(FloatPTR)))
end

function STAT_GET_BOOL(Stat)
    if STAT_GET_INT(Stat) == 0 then
        return "false"
    elseif STAT_GET_INT(Stat) == 1 then
        return "true"
    else
        return "STAT_UNKNOWN"
    end
end

function STAT_GET_STRING(Stat)
    return STATS.STAT_GET_STRING(util.joaat(ADD_MP_INDEX(Stat)), -1)
end

function STAT_GET_DATE(Stat, Sort)
    local DatePTR = memory.alloc(7 * 8)
    STATS.STAT_GET_DATE(util.joaat(ADD_MP_INDEX(Stat)), DatePTR, 7, true)
    local Add = 0
    if Sort == "Year" then
        Add = 0
    elseif Sort == "Month" then
        Add = 8
    elseif Sort == "Day" then
        Add = 16
    elseif Sort == "Hour" then
        Add = 24
    elseif Sort == "Min" then
        Add = 32
    end
    return memory.read_int(DatePTR + Add)
end

----------------------------
----- GLOBAL Functions -----
----------------------------
function SET_INT_GLOBAL(Global, Value)
    memory.write_int(memory.script_global(Global), Value)
end

function SET_FLOAT_GLOBAL(Global, Value)
    memory.write_float(memory.script_global(Global), Value)
end

function GET_INT_GLOBAL(Global)
    return memory.read_int(memory.script_global(Global))
end

function GET_FLOAT_GLOBAL(Global)
    return memory.read_float(memory.script_global(Global))
end

---------------------------
----- LOCAL Functions -----
---------------------------
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



------------------------------
--------- File & Dir ---------
------------------------------
StoreDir = filesystem.store_dir() .. "RScripts\\"
if not filesystem.exists(StoreDir) then
    filesystem.mkdir(StoreDir)
end


------------------------------
------- 保存的 Hash 列表 -------
------------------------------

-- 格式 --
-- name
-- hash \n type
Saved_Hash_List = {
    dir = StoreDir .. "Saved Hash List",
    MISSION_ENTITY_custom = nil, --menu.list_action
    Manage_Hash_List_Menu = nil, --menu.list
}

if not filesystem.exists(Saved_Hash_List.dir) then
    filesystem.mkdir(Saved_Hash_List.dir)
end

---@return table
function Saved_Hash_List.get_list()
    local file_name_list = {}
    for i, path in ipairs(filesystem.list_files(Saved_Hash_List.dir)) do
        if not filesystem.is_dir(path) then
            local filename, ext = string.match(path, '^.+\\(.+)%.(.+)$')

            table.insert(file_name_list, filename)
        end
    end
    return file_name_list
end

---@return table
function Saved_Hash_List.get_list_item_data()
    local list_item_data = {}
    for i, path in ipairs(filesystem.list_files(Saved_Hash_List.dir)) do
        if not filesystem.is_dir(path) then
            local Name, ext = string.match(path, '^.+\\(.+)%.(.+)$')
            local Hash, Type = Saved_Hash_List.read(Name)

            local temp = { "", {}, "" }
            temp[1] = Name
            temp[3] = "Hash: " .. Hash .. "\nType: " .. Type
            table.insert(list_item_data, temp)
        end
    end
    return list_item_data
end

---@return table
function Saved_Hash_List.get_list_item_data2()
    local list_item_data = { { "无" }, { "刷新列表" } }
    for i, path in ipairs(filesystem.list_files(Saved_Hash_List.dir)) do
        if not filesystem.is_dir(path) then
            local Name, ext = string.match(path, '^.+\\(.+)%.(.+)$')
            local Hash, Type = Saved_Hash_List.read(Name)

            local temp = { "", {}, "" }
            temp[1] = Name
            temp[3] = "Hash: " .. Hash .. "\nType: " .. Type
            table.insert(list_item_data, temp)
        end
    end
    return list_item_data
end

---return Hash, Type
---@param Name string
---@return string, string
function Saved_Hash_List.read(Name)
    local file = assert(io.open(Saved_Hash_List.dir .. "\\" .. Name .. ".txt", "r"))
    local content = { 0, "No Entity" }
    for line in file:lines() do
        --table.insert(content, line)
        if tonumber(line) ~= nil then
            content[1] = line
        else
            content[2] = line
        end
    end
    file:close()
    return content[1], content[2]
end

---@param Name string
---@param Hash string
---@param Type string
function Saved_Hash_List.write(Name, Hash, Type)
    if Name ~= "" then
        local file = assert(io.open(Saved_Hash_List.dir .. "\\" .. Name .. ".txt", "w+"))
        file:write(Hash .. "\n" .. Type)
        file:close()

        Saved_Hash_List.refresh()
    end
end

---@param Name string
function Saved_Hash_List.rename(old_Name, new_Name)
    if new_Name ~= "" and new_Name ~= old_Name then
        local old_path = Saved_Hash_List.dir .. "\\" .. old_Name .. ".txt"
        local new_path = Saved_Hash_List.dir .. "\\" .. new_Name .. ".txt"
        if not os.rename(old_path, new_path) then
            util.toast("重命名失败")
        else
            Saved_Hash_List.refresh()
        end
    end
end

---@param Name string
---@return boolean
function Saved_Hash_List.delete(Name)
    if Name ~= "" then
        if not os.remove(Saved_Hash_List.dir .. "\\" .. Name .. ".txt") then
            util.toast("删除失败")
        else
            Saved_Hash_List.refresh()
        end
    end
end

Manage_Saved_Hash_Menu_List = {} --每个 Hash 的 menu.list
function Saved_Hash_List.generate_menu_list(menu_parent)
    for k, v in pairs(Manage_Saved_Hash_Menu_List) do
        if v ~= nil and menu.is_ref_valid(v) then
            menu.delete(v)
        end
    end
    Manage_Saved_Hash_Menu_List = {}

    for i, path in ipairs(filesystem.list_files(Saved_Hash_List.dir)) do
        if not filesystem.is_dir(path) then
            local Name, ext = string.match(path, '^.+\\(.+)%.(.+)$')
            local Hash, Type = Saved_Hash_List.read(Name)
            local help_text = "Hash: " .. Hash .. "\nType: " .. Type

            local menu_list = menu.list(menu_parent, Name, {}, help_text)
            table.insert(Manage_Saved_Hash_Menu_List, menu_list)

            menu.text_input(menu_list, "名称", { "saved_hash_name" .. Name }, "", function(value)
                Saved_Hash_List.rename(Name, value)
            end, Name)

            menu.text_input(menu_list, "Hash", { "saved_hash" .. Name }, "", function(value)
                if tonumber(value) ~= nil and STREAMING.IS_MODEL_VALID(value) then
                    local tHash, tType = Saved_Hash_List.read(Name)
                    Saved_Hash_List.write(Name, value, tType)
                else
                    util.toast("Wrong Hash !")
                end
            end, Hash)

            menu.list_select(menu_list, "实体类型", {}, "", entity_type_ListItem, GET_ENTITY_TYPE_INDEX(Type),
                function(value)
                    value = entity_type_ListItem[value][1]
                    local tHash, tType = Saved_Hash_List.read(Name)
                    Saved_Hash_List.write(Name, tHash, value)
                end)

            menu.action(menu_list, "删除", {}, "", function()
                Saved_Hash_List.delete(Name)
            end)

        end
    end
end

---@param Name string
---@param ent Entity
function Saved_Hash_List.save(Name, ent)
    if ENTITY.DOES_ENTITY_EXIST(ent) then
        if Name ~= "" then
            local Hash = ENTITY.GET_ENTITY_MODEL(ent)
            local Type = GET_ENTITY_TYPE(ent, 2)
            Saved_Hash_List.write(Name, Hash, Type)
            util.toast("已保存")
        else
            util.toast("请输入名称")
        end
    else
        util.toast("实体已经不存在")
    end
end

function Saved_Hash_List.refresh()
    if menu.is_ref_valid(Saved_Hash_List.MISSION_ENTITY_custom) then
        menu.set_list_action_options(Saved_Hash_List.MISSION_ENTITY_custom, Saved_Hash_List.get_list_item_data())
    end
    if menu.is_ref_valid(Saved_Hash_List.Manage_Hash_List_Menu) then
        Saved_Hash_List.generate_menu_list(Saved_Hash_List.Manage_Hash_List_Menu)
    end
end

----- SCRIPT START -----
if SCRIPT_MANUAL_START then
    local GTAO = tonumber(NETWORK.GET_ONLINE_VERSION())
    if Support_GTAO ~= GTAO then
        util.toast("支持的GTA线上版本: " .. Support_GTAO .. "\n当前GTA线上版本: " .. GTAO)
    end
end



--
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
menu.divider(Self_Custom_options, "生命")

local defaultHealth = ENTITY.GET_ENTITY_MAX_HEALTH(PLAYER.PLAYER_PED_ID())
local moddedHealth = defaultHealth
menu.slider(Self_Custom_options, "自定义最大生命值", { "set_max_health" }, "生命值将被修改为指定的数值"
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

menu.click_slider(Self_Custom_options, "设置当前生命值", { "set_health" }, "", 0, 100000, defaultHealth, 50,
    function(value)
        ENTITY.SET_ENTITY_HEALTH(PLAYER.PLAYER_PED_ID(), value)
    end)

--- 自定义最大护甲 ---
menu.divider(Self_Custom_options, "护甲")

local defaultArmour = PLAYER.GET_PLAYER_MAX_ARMOUR(PLAYER.PLAYER_ID())
local moddedArmour = defaultArmour
menu.slider(Self_Custom_options, "自定义最大护甲值", { "set_max_armour" }, "护甲将被修改为指定的数值"
    ,
    50, 100000, defaultArmour, 50, function(value)
    moddedArmour = value
end)

menu.toggle_loop(Self_Custom_options, "开启", {}, "改变你的最大护甲值。一些菜单会将你标记为作弊者。当它被禁用时，它会返回到默认的最大护甲值。"
    , function()
        if PLAYER.GET_PLAYER_MAX_ARMOUR(PLAYER.PLAYER_ID()) ~= moddedArmour then
            PLAYER.SET_PLAYER_MAX_ARMOUR(PLAYER.PLAYER_ID(), moddedArmour)
            PED.SET_PED_ARMOUR(PLAYER.PLAYER_PED_ID(), moddedArmour)
        end
    end, function()
    PLAYER.SET_PLAYER_MAX_ARMOUR(PLAYER.PLAYER_ID(), defaultArmour)
    PED.SET_PED_ARMOUR(PLAYER.PLAYER_PED_ID(), defaultArmour)
end)

menu.click_slider(Self_Custom_options, "设置当前护甲值", { "set_armour" }, "", 0, 100000, defaultArmour, 50,
    function(value)
        PED.SET_PED_ARMOUR(PLAYER.PLAYER_PED_ID(), value)
    end)

-------------------
--- 自定义生命恢复 ---
-------------------
local Self_Custom_recharge_options = menu.list(Self_options, "自定义生命恢复", {}, "")

local custom_recharge = {
    normal_limit = 0.25,
    normal_mult = 1.0,
    cover_limit = 0.25,
    cover_mult = 1.0,
    vehicle_limit = 0.25,
    vehicle_mult = 1.0
}

menu.toggle_loop(Self_Custom_recharge_options, "开启", {}, "", function()
    if PED.IS_PED_IN_COVER(players.user_ped(), false) then
        PLAYER.SET_PLAYER_HEALTH_RECHARGE_MAX_PERCENT(players.user(), custom_recharge.cover_limit)
        PLAYER.SET_PLAYER_HEALTH_RECHARGE_MULTIPLIER(players.user(), custom_recharge.cover_mult)
    elseif PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
        PLAYER.SET_PLAYER_HEALTH_RECHARGE_MAX_PERCENT(players.user(), custom_recharge.vehicle_limit)
        PLAYER.SET_PLAYER_HEALTH_RECHARGE_MULTIPLIER(players.user(), custom_recharge.vehicle_mult)
    else
        PLAYER.SET_PLAYER_HEALTH_RECHARGE_MAX_PERCENT(players.user(), custom_recharge.normal_limit)
        PLAYER.SET_PLAYER_HEALTH_RECHARGE_MULTIPLIER(players.user(), custom_recharge.normal_mult)
    end
end, function()
    PLAYER.SET_PLAYER_HEALTH_RECHARGE_MAX_PERCENT(players.user(), 0.25)
    PLAYER.SET_PLAYER_HEALTH_RECHARGE_MULTIPLIER(players.user(), 1.0)
end)

menu.divider(Self_Custom_recharge_options, "站立不动状态")
menu.slider(Self_Custom_recharge_options, "恢复程度", { "normal_recharge_limit" }, "恢复到血量的多少，单位%\n默认：25%"
    , 1, 100, 25, 10, function(value)
    custom_recharge.normal_limit = value * 0.01
end)
menu.slider(Self_Custom_recharge_options, "恢复速度", { "normal_recharge_mult" }, "恢复速度\n默认：1.0", 1.0,
    100.0, 1.0, 1.0, function(value)
    custom_recharge.normal_mult = value
end)

menu.divider(Self_Custom_recharge_options, "掩体内")
menu.slider(Self_Custom_recharge_options, "恢复程度", { "cover_recharge_limit" }, "恢复到血量的多少，单位%\n默认：25%"
    , 1, 100, 25, 10, function(value)
    custom_recharge.cover_limit = value * 0.01
end)
menu.slider(Self_Custom_recharge_options, "恢复速度", { "cover_recharge_mult" }, "恢复速度\n默认：1.0", 1.0,
    100.0, 1.0, 1.0, function(value)
    custom_recharge.cover_mult = value
end)

menu.divider(Self_Custom_recharge_options, "载具内")
menu.slider(Self_Custom_recharge_options, "恢复程度", { "vehicle_recharge_limit" }, "恢复到血量的多少，单位%\n默认：25%"
    , 1, 100, 25, 10, function(value)
    custom_recharge.vehicle_limit = value * 0.01
end)
menu.slider(Self_Custom_recharge_options, "恢复速度", { "vehicle_recharge_mult" }, "恢复速度\n默认：1.0", 1.0
    ,
    100.0, 1.0, 1.0, function(value)
    custom_recharge.vehicle_mult = value
end)

-------------------
--- 自定义血量下限 ---
-------------------
local Self_Custom_low_limit = menu.list(Self_options, "自定义血量下限", {}, "")

local low_health_limit = 0.5
menu.slider(Self_Custom_low_limit, "设置血量下限(%)", { "low_health_limit" }, "可以到达的最低血量，单位%"
    , 10, 100, 50, 10
    , function(value)
    low_health_limit = value * 0.01
end)
menu.toggle_loop(Self_Custom_low_limit, "锁定血量", {}, "当你的血量到达你设置的血量下限值后，锁定你的血量，防不住爆炸"
    , function()
    if not PLAYER.IS_PLAYER_DEAD(players.user()) then
        local maxHealth = ENTITY.GET_ENTITY_MAX_HEALTH(players.user_ped()) - 100
        local toLock_health = math.ceil(maxHealth * low_health_limit + 100)
        if ENTITY.GET_ENTITY_HEALTH(players.user_ped()) < toLock_health then
            ENTITY.SET_ENTITY_HEALTH(players.user_ped(), toLock_health)
        end
    end
end)
menu.toggle_loop(Self_Custom_low_limit, "补满血量", {}, "当你的血量到达你设置的血量下限值后，补满你的血量"
    , function()
    if not PLAYER.IS_PLAYER_DEAD(players.user()) then
        local maxHealth = ENTITY.GET_ENTITY_MAX_HEALTH(players.user_ped()) - 100
        local toLock_health = math.ceil(maxHealth * low_health_limit + 100)
        if ENTITY.GET_ENTITY_HEALTH(players.user_ped()) < toLock_health then
            ENTITY.SET_ENTITY_HEALTH(players.user_ped(), maxHealth + 100)
        end
    end
end)
------

menu.toggle_loop(Self_options, "显示血量和护甲", {}, "信息显示", function()
    local current_health = ENTITY.GET_ENTITY_HEALTH(PLAYER.PLAYER_PED_ID())
    local max_health = PED.GET_PED_MAX_HEALTH(PLAYER.PLAYER_PED_ID())
    local current_armour = PED.GET_PED_ARMOUR(PLAYER.PLAYER_PED_ID())
    local max_armour = PLAYER.GET_PLAYER_MAX_ARMOUR(PLAYER.PLAYER_ID())
    local text = "血量： " .. current_health .. "/" .. max_health .. "\n护甲： " ..
        current_armour .. "/" .. max_armour
    util.draw_debug_text(text)
end)

menu.toggle_loop(Self_options, "警察无视", {}, "", function()
    PLAYER.SET_POLICE_IGNORE_PLAYER(PLAYER.PLAYER_ID(), true)
end, function()
    PLAYER.SET_POLICE_IGNORE_PLAYER(PLAYER.PLAYER_ID(), false)
end)
menu.toggle_loop(Self_options, "所有人无视", {}, "", function()
    PLAYER.SET_EVERYONE_IGNORE_PLAYER(PLAYER.PLAYER_ID(), true)
end, function()
    PLAYER.SET_EVERYONE_IGNORE_PLAYER(PLAYER.PLAYER_ID(), false)
end)
menu.toggle_loop(Self_options, "行动无声", {}, "", function()
    PLAYER.SET_PLAYER_NOISE_MULTIPLIER(PLAYER.PLAYER_ID(), 0.0)
end)
menu.toggle_loop(Self_options, "不会被帮派骚乱", {}, "", function()
    PLAYER.SET_PLAYER_CAN_BE_HASSLED_BY_GANGS(PLAYER.PLAYER_ID(), false)
end, function()
    PLAYER.SET_PLAYER_CAN_BE_HASSLED_BY_GANGS(PLAYER.PLAYER_ID(), true)
end)
menu.toggle_loop(Self_options, "不可被拽出载具", {}, "", function()
    PED.SET_PED_CAN_BE_DRAGGED_OUT(PLAYER.PLAYER_PED_ID(), false)
end, function()
    PED.SET_PED_CAN_BE_DRAGGED_OUT(PLAYER.PLAYER_PED_ID(), true)
end)
menu.toggle_loop(Self_options, "载具内不可被射击", {}, "在载具内不会受伤", function()
    PED.SET_PED_CAN_BE_SHOT_IN_VEHICLE(PLAYER.PLAYER_PED_ID(), false)
end, function()
    PED.SET_PED_CAN_BE_SHOT_IN_VEHICLE(PLAYER.PLAYER_PED_ID(), true)
end)
menu.toggle_loop(Self_options, "禁止为玩家调度警察", {}, "不会一直刷出新的警察，最好在被通缉前开启"
    , function()
        PLAYER.SET_DISPATCH_COPS_FOR_PLAYER(PLAYER.PLAYER_ID(), false)
    end, function()
    PLAYER.SET_DISPATCH_COPS_FOR_PLAYER(PLAYER.PLAYER_ID(), true)
end)
menu.toggle_loop(Self_options, "禁用NPC伤害", {}, "", function()
    PED.SET_AI_WEAPON_DAMAGE_MODIFIER(0.0)
    PED.SET_AI_MELEE_WEAPON_DAMAGE_MODIFIER(0.0)
end, function()
    PED.RESET_AI_WEAPON_DAMAGE_MODIFIER()
    PED.RESET_AI_MELEE_WEAPON_DAMAGE_MODIFIER()
end)



--------------------------------
------------ 武器选项 ------------
--------------------------------
local Weapon_options = menu.list(menu.my_root(), "武器选项", {}, "")

menu.toggle(Weapon_options, "可以射击队友", {}, "使你在游戏中能够射击队友", function(toggle)
    PED.SET_CAN_ATTACK_FRIENDLY(PLAYER.PLAYER_PED_ID(), toggle, false)
end)
menu.toggle_loop(Weapon_options, "翻滚时自动换弹夹", {}, "当你做翻滚动作时更换弹夹", function()
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
    local curWeaponMem = memory.alloc_int()
    local junk = WEAPON.GET_CURRENT_PED_WEAPON(PLAYER.PLAYER_PED_ID(), curWeaponMem, 1)
    local curWeapon = memory.read_int(curWeaponMem)
    memory.free(curWeaponMem)

    local curAmmoMem = memory.alloc_int()
    junk = WEAPON.GET_MAX_AMMO(PLAYER.PLAYER_PED_ID(), curWeapon, curAmmoMem)
    local curAmmoMax = memory.read_int(curAmmoMem)
    memory.free(curAmmoMem)

    if curAmmoMax > 0 then
        WEAPON.SET_PED_AMMO(PLAYER.PLAYER_PED_ID(), curWeapon, curAmmoMax)
    end
end)
menu.toggle_loop(Weapon_options, "移除黏弹和感应地雷", {}, "", function()
    local weaponHash = util.joaat("WEAPON_PROXMINE")
    WEAPON.REMOVE_ALL_PROJECTILES_OF_TYPE(weaponHash, false)
    weaponHash = util.joaat("WEAPON_STICKYBOMB")
    WEAPON.REMOVE_ALL_PROJECTILES_OF_TYPE(weaponHash, false)
end)

------- 实体控制枪 -------
local Weapon_Entity_control = menu.list(Weapon_options, "实体控制枪", {}, "控制你所瞄准的实体")

local function entity_control_Head(menu_parent, ent)
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

        control_ent_count = control_ent_count - 1
        if control_ent_count <= 0 then
            menu.set_menu_name(Weapon_Entity_control_divider, "实体控制列表")
        else
            menu.set_menu_name(Weapon_Entity_control_divider, "实体控制列表 (" .. control_ent_count .. ")")
        end
    end)
end

local function Init_control_ent_list()
    -- 所有控制的实体
    control_ent_list = {}
    -- 所有控制实体的menu.list
    control_ent_menu_list = {}
    -- 控制实体的索引
    control_ent_index = 1
    -- 已记录实体的数量
    control_ent_count = 0
end

Init_control_ent_list()

menu.toggle_loop(Weapon_Entity_control, "开启", { "ctrl_gun" }, "", function()
    Draw_Rect_In_Center()
    local ent = GetEntity_PlayerIsAimingAt(players.user())
    if ent ~= nil and IS_AN_ENTITY(ent) then
        --Draw Line
        local pos1 = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        local pos2 = ENTITY.GET_ENTITY_COORDS(ent)
        GRAPHICS.DRAW_LINE(pos1.x, pos1.y, pos1.z, pos2.x, pos2.y, pos2.z, 255, 0, 255, 255)

        if not isInTable(control_ent_list, ent) then
            table.insert(control_ent_list, ent) --entity

            -- menu_name
            local modelHash = ENTITY.GET_ENTITY_MODEL(ent)
            local modelName = util.reverse_joaat(modelHash)
            local menu_name = control_ent_index .. ". "
            if modelName ~= "" then
                menu_name = menu_name .. modelName
            else
                menu_name = menu_name .. modelHash
            end
            -- help_text
            local text = ""

            local display_name = util.get_label_text(VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(modelHash))
            if display_name ~= "NULL" then
                text = text .. "Display Name: " .. display_name .. "\n"
            end

            local entity_type = GET_ENTITY_TYPE(ent, 2)
            local owner = entities.get_owner(entities.handle_to_pointer(ent))
            owner = players.get_name(owner)
            text = text .. "Hash: " .. modelHash .. "\nType: " .. entity_type .. "\nOwner: " .. owner

            util.toast(menu_name .. "\n" .. text)

            -- 实体控制列表 menu.list
            local menu_list = menu.list(Weapon_Entity_control, menu_name, {}, text)

            -- entity
            entity_control_Head(menu_list, ent)
            entity_control_all(menu_list, ent, control_ent_index)
            -- ped
            if ENTITY.IS_ENTITY_A_PED(ent) then
                entity_control_ped(menu_list, ent, control_ent_index)
            end
            -- vehicle
            if ENTITY.IS_ENTITY_A_VEHICLE(ent) then
                entity_control_vehicle(menu_list, ent, control_ent_index)
            end

            table.insert(control_ent_menu_list, menu_list) --menu.list

            control_ent_index = control_ent_index + 1
            control_ent_count = control_ent_count + 1
            if control_ent_count == 0 then
                menu.set_menu_name(Weapon_Entity_control_divider, "实体控制列表")
            else
                menu.set_menu_name(Weapon_Entity_control_divider, "实体控制列表 (" .. control_ent_count .. ")")
            end
        end

    end
end)

menu.action(Weapon_Entity_control, "清除记录的实体", {}, "", function()
    for k, v in pairs(control_ent_menu_list) do
        if v ~= nil and menu.is_ref_valid(v) then
            menu.delete(v)
        end
    end
    Init_control_ent_list()
    menu.set_menu_name(Weapon_Entity_control_divider, "实体控制列表")
end)
Weapon_Entity_control_divider = menu.divider(Weapon_Entity_control, "实体控制列表")



--------------------------------
------------ 载具选项 ------------
--------------------------------
local Vehicle_options = menu.list(menu.my_root(), "载具选项", {}, "")

----- 载具改装 -----
local Vehicle_MOD_options = menu.list(Vehicle_options, "载具改装", {}, "")

local vehicle_mod = {
    performance = 2,
    turbo = true,
    spoilers = 1,
    suspension = 1,
    xenon = -1,
    extra_types = 1,

    neon = {
        toggle = false,
        r = 0,
        g = 0,
        b = 0,
        left = false,
        right = false,
        front = false,
        rear = false,
    },
    tyre_smoke = {
        toggle = false,
        r = 255,
        g = 255,
        b = 255,
    },
    plate = {
        toggle = false,
        text = "ROCKSTAR",
    },
    bullet_tyre = true,
    unbreakable_doors = false,
    unbreakable_lights = false,
}

local VehicleMOD_ListItem = {
    { "默认", {}, "不进行改装" },
    { "顶级" }
}
local Vehicle_MOD_Kits = menu.list(Vehicle_MOD_options, "改装选项", {}, "")
menu.list_select(Vehicle_MOD_Kits, "主要性能", {}, "引擎、刹车、变速箱、防御", VehicleMOD_ListItem, 2,
    function(value)
        vehicle_mod.performance = value
    end)
menu.toggle(Vehicle_MOD_Kits, "涡轮增压", {}, "", function(toggle)
    vehicle_mod.turbo = toggle
end, true)
menu.list_select(Vehicle_MOD_Kits, "尾翼", {}, "", VehicleMOD_ListItem, 1, function(value)
    vehicle_mod.spoilers = value
end)
menu.list_select(Vehicle_MOD_Kits, "悬挂", {}, "", VehicleMOD_ListItem, 1, function(value)
    vehicle_mod.suspension = value
end)
menu.slider(Vehicle_MOD_Kits, "前车灯", { "vehicle_xenon_light" }, "", -1, 12, -1, 1, function(value)
    vehicle_mod.xenon = value

    if PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
        local veh = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
        if veh then
            if vehicle_mod.xenon >= 0 then
                VEHICLE.TOGGLE_VEHICLE_MOD(veh, 22, true)
                VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(veh, vehicle_mod.xenon)
            else
                VEHICLE.TOGGLE_VEHICLE_MOD(veh, 22, false)
            end
        end
    end

end)
menu.list_select(Vehicle_MOD_Kits, "其它改装配件", {}, "侧裙、保险杠等，排除涂装、车轮、喇叭",
    VehicleMOD_ListItem, 1, function(value)
    vehicle_mod.extra_types = value
end)

local Vehicle_MOD_neon = menu.list(Vehicle_MOD_Kits, "霓虹灯", {}, "")
menu.toggle(Vehicle_MOD_neon, "开启", {}, "", function(toggle)
    vehicle_mod.neon.toggle = toggle
end)
menu.colour(Vehicle_MOD_neon, "颜色", { "vehicle_neon_colour" }, "", 1, 1, 1
    , 1, false, function(colour)
    vehicle_mod.neon.r = math.ceil(255 * colour.r)
    vehicle_mod.neon.g = math.ceil(255 * colour.g)
    vehicle_mod.neon.b = math.ceil(255 * colour.b)
end)
menu.toggle(Vehicle_MOD_neon, "左", {}, "", function(toggle)
    vehicle_mod.neon.left = toggle
end)
menu.toggle(Vehicle_MOD_neon, "右", {}, "", function(toggle)
    vehicle_mod.neon.right = toggle
end)
menu.toggle(Vehicle_MOD_neon, "前", {}, "", function(toggle)
    vehicle_mod.neon.front = toggle
end)
menu.toggle(Vehicle_MOD_neon, "后", {}, "", function(toggle)
    vehicle_mod.neon.rear = toggle
end)

local Vehicle_MOD_tyre_smoke = menu.list(Vehicle_MOD_Kits, "轮胎烟雾", {}, "")
menu.toggle(Vehicle_MOD_tyre_smoke, "开启", {}, "", function(toggle)
    vehicle_mod.tyre_smoke.toggle = toggle
end)
menu.colour(Vehicle_MOD_tyre_smoke, "颜色", { "vehicle_tyre_smoke_colour" }, "设置R,G,B都为0会使载具轮胎烟雾为独立日颜色"
    , 1, 1, 1
    , 1, false, function(colour)
    vehicle_mod.tyre_smoke.r = math.ceil(255 * colour.r)
    vehicle_mod.tyre_smoke.g = math.ceil(255 * colour.g)
    vehicle_mod.tyre_smoke.b = math.ceil(255 * colour.b)
end)

local Vehicle_MOD_plate = menu.list(Vehicle_MOD_Kits, "车牌", {}, "")
menu.toggle(Vehicle_MOD_plate, "开启", {}, "", function(toggle)
    vehicle_mod.plate.toggle = toggle
end)
menu.text_input(Vehicle_MOD_plate, "内容", { "vehicle_plate_text" }, "最大8个字符", function(value)
    vehicle_mod.plate.text = value
end, "ROCKSTAR")


local Vehicle_MOD_Extra_options = menu.list(Vehicle_MOD_options, "其它改装选项", {}, "")
menu.toggle(Vehicle_MOD_Extra_options, "防弹轮胎", {}, "", function(toggle)
    vehicle_mod.bullet_tyre = toggle
end, true)
menu.toggle(Vehicle_MOD_Extra_options, "不可损坏的车门", {}, "", function(toggle)
    vehicle_mod.unbreakable_doors = toggle
end)
menu.toggle(Vehicle_MOD_Extra_options, "不可损坏的车灯", {}, "", function(toggle)
    vehicle_mod.unbreakable_lights = toggle
end)

local function Custom_Mod_Vehicle(vehicle)
    VEHICLE.SET_VEHICLE_MOD_KIT(vehicle, 0)

    if vehicle_mod.performance == 2 then
        for k, v in pairs({ 11, 12, 13, 16 }) do
            local mod_num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, v)
            VEHICLE.SET_VEHICLE_MOD(vehicle, v, mod_num - 1, false)
        end
    end

    if vehicle_mod.turbo then
        VEHICLE.TOGGLE_VEHICLE_MOD(vehicle, 18, true)
    end

    if vehicle_mod.spoilers == 2 then
        local mod_num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, 0)
        VEHICLE.SET_VEHICLE_MOD(vehicle, 0, mod_num - 1, false)
    end

    if vehicle_mod.suspension == 2 then
        local mod_num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, 15)
        VEHICLE.SET_VEHICLE_MOD(vehicle, 15, mod_num - 1, false)
    end

    if vehicle_mod.extra_types == 2 then
        local extra_type_list = {
            1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
            25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38,
            39, 40, 41, 42, 43, 44, 45, 46
        }
        for k, v in pairs(extra_type_list) do
            local mod_num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, v)
            if mod_num > 0 then
                VEHICLE.SET_VEHICLE_MOD(vehicle, v, mod_num - 1, false)
            end
        end
    end

    if vehicle_mod.xenon >= 0 then
        VEHICLE.TOGGLE_VEHICLE_MOD(vehicle, 22, true)
        VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(vehicle, vehicle_mod.xenon)
    end

    if vehicle_mod.neon.toggle then
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehicle, 0, vehicle_mod.neon.left)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehicle, 1, vehicle_mod.neon.right)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehicle, 2, vehicle_mod.neon.front)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehicle, 3, vehicle_mod.neon.rear)
        VEHICLE.SET_VEHICLE_NEON_COLOUR(vehicle, vehicle_mod.neon.r, vehicle_mod.neon.g,
            vehicle_mod.neon.b)
    end

    if vehicle_mod.tyre_smoke.toggle then
        VEHICLE.TOGGLE_VEHICLE_MOD(vehicle, 20, true)
        VEHICLE.SET_VEHICLE_TYRE_SMOKE_COLOR(vehicle, vehicle_mod.tyre_smoke.r, vehicle_mod.tyre_smoke.g
            , vehicle_mod.tyre_smoke.b)
    end

    if vehicle_mod.plate.toggle then
        VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, vehicle_mod.plate.text)
    end

    -- 其它改装选项
    if vehicle_mod.bullet_tyre then
        VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(vehicle, false)
    end
    if vehicle_mod.unbreakable_doors then
        for i = 0, 3 do
            VEHICLE.SET_DOOR_ALLOWED_TO_BE_BROKEN_OFF(vehicle, i, false)
        end
    end
    if vehicle_mod.unbreakable_lights then
        VEHICLE.SET_VEHICLE_HAS_UNBREAKABLE_LIGHTS(vehicle, true)
    end
end

menu.toggle_loop(Vehicle_MOD_options, "开启自动改装", { "auto_mod_vehicle" }, "自动改装正在进入的载具",
    function()
        if PED.IS_PED_GETTING_INTO_A_VEHICLE(players.user_ped()) then
            local veh = PED.GET_VEHICLE_PED_IS_ENTERING(players.user_ped())
            if veh then
                Custom_Mod_Vehicle(veh)
            end
        end
    end)
menu.action(Vehicle_MOD_options, "改装载具", { "mod_vehicle" }, "改装当前载具或上一辆载具", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        Custom_Mod_Vehicle(vehicle)
    end
end)


----- 载具车窗 -----
local Vehicle_Window_options = menu.list(Vehicle_options, "载具车窗", {}, "")

local VehicleWindows_ListItem = {
    { "全部" },
    { "左前车窗" },
    { "右前车窗" },
    { "左后车窗" },
    { "右后车窗" },
    { "前挡风车窗" },
    { "后挡风车窗" }
}
local vehicle_window_select = 1 --选择的车窗
menu.list_select(Vehicle_Window_options, "选择车窗", {}, "", VehicleWindows_ListItem, 1, function(value)
    vehicle_window_select = value
end)

menu.toggle_loop(Vehicle_Window_options, "修复车窗", {}, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        if vehicle_window_select == 1 then
            for i = 0, 7 do
                VEHICLE.FIX_VEHICLE_WINDOW(vehicle, i)
            end
        elseif vehicle_window_select > 1 then
            VEHICLE.FIX_VEHICLE_WINDOW(vehicle, vehicle_window_select - 2)
        end
    end
end)
menu.toggle_loop(Vehicle_Window_options, "摇下车窗", {}, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        if vehicle_window_select == 1 then
            for i = 0, 7 do
                VEHICLE.ROLL_DOWN_WINDOW(vehicle, i)
            end
        elseif vehicle_window_select > 1 then
            VEHICLE.ROLL_DOWN_WINDOW(vehicle, vehicle_window_select - 2)
        end
    end
end, function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        if vehicle_window_select == 1 then
            for i = 0, 7 do
                VEHICLE.ROLL_UP_WINDOW(vehicle, i)
            end
        elseif vehicle_window_select > 1 then
            VEHICLE.ROLL_UP_WINDOW(vehicle, vehicle_window_select - 2)
        end
    end
end)
menu.toggle_loop(Vehicle_Window_options, "粉碎车窗", {}, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        if vehicle_window_select == 1 then
            for i = 0, 7 do
                VEHICLE.SMASH_VEHICLE_WINDOW(vehicle, i)
            end
        elseif vehicle_window_select > 1 then
            VEHICLE.SMASH_VEHICLE_WINDOW(vehicle, vehicle_window_select - 2)
        end
    end
end)


----- 载具门 -----
local Vehicle_Door_options = menu.list(Vehicle_options, "载具门", {}, "")

local VehicleDoors_ListItem = {
    { "全部" },
    { "左前门" }, --VEH_EXT_DOOR_DSIDE_F == 0
    { "右前门" }, --VEH_EXT_DOOR_DSIDE_R == 1
    { "左后门" }, --VEH_EXT_DOOR_PSIDE_F == 2
    { "右后门" }, --VEH_EXT_DOOR_PSIDE_R == 3
    { "引擎盖" }, --VEH_EXT_BONNET == 4
    { "后备箱" } --VEH_EXT_BOOT == 5
}
local vehicle_door_select = 1 --选择的车门
menu.list_select(Vehicle_Door_options, "选择车门", {}, "", VehicleDoors_ListItem, 1, function(value)
    vehicle_door_select = value
end)

menu.toggle_loop(Vehicle_Door_options, "打开车门", {}, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        if vehicle_door_select == 1 then
            for i = 0, 3 do
                VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, i, false, false)
            end
        elseif vehicle_door_select > 1 then
            VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, vehicle_door_select - 2, false, false)
        end
    end
end)
menu.action(Vehicle_Door_options, "关闭车门", {}, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        if vehicle_door_select == 1 then
            for i = 0, 3 do
                VEHICLE.SET_VEHICLE_DOOR_SHUT(vehicle, i, false)
            end
        elseif vehicle_door_select > 1 then
            VEHICLE.SET_VEHICLE_DOOR_SHUT(vehicle, vehicle_door_select - 2, false)
        end
    end
end)
menu.toggle_loop(Vehicle_Door_options, "破坏车门", {}, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        if vehicle_door_select == 1 then
            for i = 0, 3 do
                VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, i, false)
            end
        elseif vehicle_door_select > 1 then
            VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, vehicle_door_select - 2, false)
        end
    end
end)
menu.toggle_loop(Vehicle_Door_options, "删除车门", {}, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        if vehicle_door_select == 1 then
            for i = 0, 3 do
                VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, i, true)
            end
        elseif vehicle_door_select > 1 then
            VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, vehicle_door_select - 2, true)
        end
    end
end)
menu.toggle(Vehicle_Door_options, "车门不可损坏", {}, "", function(toggle)
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        if vehicle_door_select == 1 then
            for i = 0, 3 do
                VEHICLE.SET_DOOR_ALLOWED_TO_BE_BROKEN_OFF(vehicle, i, not toggle)
            end
        elseif vehicle_door_select > 1 then
            VEHICLE.SET_DOOR_ALLOWED_TO_BE_BROKEN_OFF(vehicle, vehicle_door_select - 2, not toggle)
        end
    end
end)


----- 载具锁门 -----
local Vehicle_DoorLock_options = menu.list(Vehicle_options, "载具锁门", {}, "")

local VehicleDoorsLock_ListItem = {
    { "解锁" }, --VEHICLELOCK_UNLOCKED == 1
    { "上锁" }, --VEHICLELOCK_LOCKED
    { "LOCKOUT PLAYER ONLY", {}, "只对玩家锁门？" }, --VEHICLELOCK_LOCKOUT_PLAYER_ONLY
    { "玩家锁定在里面" }, --VEHICLELOCK_LOCKED_PLAYER_INSIDE
    { "LOCKED INITIALLY" }, --VEHICLELOCK_LOCKED_INITIALLY
    { "强制关闭车门" }, --VEHICLELOCK_FORCE_SHUT_DOORS
    { "上锁但可被破坏", {}, "可以破开车窗开门" }, --VEHICLELOCK_LOCKED_BUT_CAN_BE_DAMAGED
    { "上锁但后备箱解锁" }, --VEHICLELOCK_LOCKED_BUT_BOOT_UNLOCKED
    { "上锁无乘客" }, --VEHICLELOCK_LOCKED_NO_PASSENGERS
    { "不能进入", {}, "按F无上车动作" } --VEHICLELOCK_CANNOT_ENTER
}
local vehicle_door_lock_select = 1 --选择的锁门类型
menu.list_select(Vehicle_DoorLock_options, "锁门类型", {}, "", VehicleDoorsLock_ListItem, 1, function(value)
    vehicle_door_lock_select = value
end)

menu.action(Vehicle_DoorLock_options, "设置载具门锁状态", {}, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle, vehicle_door_lock_select)
    end
end)
menu.slider_text(Vehicle_DoorLock_options, "设置单个门锁状态", {}, "貌似无效", { "左前门", "右前门",
    "左后门",
    "右后门" }, function(value)
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        VEHICLE.SET_VEHICLE_INDIVIDUAL_DOORS_LOCKED(vehicle, value - 1, vehicle_door_lock_select)
    end
end)

menu.toggle(Vehicle_DoorLock_options, "对所有玩家锁门", {}, "", function(toggle)
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(vehicle, toggle)
    end
end)


----- 载具车灯 -----
local Vehicle_Light_options = menu.list(Vehicle_options, "载具车灯", {}, "")

local VehicleLightState_ListItem = {
    { "正常", {}, "车辆正常开灯，关闭，然后是近光灯，远光灯" }, --0
    { "总是关闭", {}, "不会开灯" }, --1
    { "总是开启", {}, "总是开灯" } --2
}
menu.list_action(Vehicle_Light_options, "设置车灯状态", {}, "", VehicleLightState_ListItem, function(value)
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        VEHICLE.SET_VEHICLE_LIGHTS(vehicle, value - 1)
    end
end)

menu.toggle(Vehicle_Light_options, "车灯不会损坏", {}, "", function(toggle)
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        VEHICLE.SET_VEHICLE_HAS_UNBREAKABLE_LIGHTS(vehicle, toggle)
    end
end)


----- 载具电台 -----
local Vehicle_Radio_options = menu.list(Vehicle_options, "载具电台", {}, "")

local Vehicle_Radio_Stations = {
    "RADIO_11_TALK_02", -- Blaine County Radio
    "RADIO_12_REGGAE", -- The Blue Ark
    "RADIO_13_JAZZ", -- Worldwide FM
    "RADIO_14_DANCE_02", -- FlyLo FM
    "RADIO_15_MOTOWN", -- The Lowdown 9.11
    "RADIO_20_THELAB", -- The Lab
    "RADIO_16_SILVERLAKE", -- Radio Mirror Park
    "RADIO_17_FUNK", -- Space 103.2
    "RADIO_18_90S_ROCK", -- Vinewood Boulevard Radio
    "RADIO_21_DLC_XM17", -- Blonded Los Santos 97.8 FM
    "RADIO_22_DLC_BATTLE_MIX1_RADIO", -- Los Santos Underground Radio
    "RADIO_23_DLC_XM19_RADIO", -- iFruit Radio
    "RADIO_19_USER", -- Self Radio
    "RADIO_01_CLASS_ROCK", -- Los Santos Rock Radio
    "RADIO_02_POP", -- Non-Stop-Pop FM
    "RADIO_03_HIPHOP_NEW", -- Radio Los Santos
    "RADIO_04_PUNK", -- Channel X
    "RADIO_05_TALK_01", -- West Coast Talk Radio
    "RADIO_06_COUNTRY", -- Rebel Radio
    "RADIO_07_DANCE_01", -- Soulwax FM
    "RADIO_08_MEXICAN", -- East Los FM
    "RADIO_09_HIPHOP_OLD", -- West Coast Classics
    "RADIO_36_AUDIOPLAYER", -- Media Player
    "RADIO_35_DLC_HEI4_MLR", -- The Music Locker
    "RADIO_34_DLC_HEI4_KULT", -- Kult FM
    "RADIO_27_DLC_PRHEI4", -- Still Slipping Los Santos
}
local VehicleRadio_ListItem = { { "关闭", {}, "OFF" } }
for k, name in pairs(Vehicle_Radio_Stations) do
    local temp = { "", {}, "" }
    temp[1] = util.get_label_text(name)
    temp[3] = name
    table.insert(VehicleRadio_ListItem, temp)
end

local vehicle_radio_station_select = 1
menu.list_select(Vehicle_Radio_options, "选择电台", {}, "", VehicleRadio_ListItem, 1, function(value)
    vehicle_radio_station_select = value
end)
menu.toggle_loop(Vehicle_Radio_options, "自动更改电台", {}, "当你进入一辆载具时，更改载具的电台",
    function()
        if PED.IS_PED_GETTING_INTO_A_VEHICLE(players.user_ped()) then
            local veh = PED.GET_VEHICLE_PED_IS_ENTERING(players.user_ped())
            if veh then
                local stationName = VehicleRadio_ListItem[vehicle_radio_station_select][3]
                AUDIO.SET_VEH_RADIO_STATION(veh, stationName)
            end
        end
    end)
menu.toggle(Vehicle_Radio_options, "关闭电台", {}, "关闭后当前载具将无法选择更改电台",
    function(toggle)
        local vehicle = entities.get_user_vehicle_as_handle()
        if vehicle then
            AUDIO.SET_VEHICLE_RADIO_ENABLED(vehicle, not toggle)
        end
    end)


----- 个人载具 -----
local Vehicle_Personal_options = menu.list(Vehicle_options, "个人载具", {}, "")
menu.action(Vehicle_Personal_options, "打开引擎和左车门", {}, "", function()
    local vehicle = entities.get_user_personal_vehicle_as_handle()
    if vehicle then
        VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, false)
        VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, 0, false, false)
    end
end)
menu.action(Vehicle_Personal_options, "开启载具引擎", {}, "个人载具和上一辆载具", function()
    local vehicle = entities.get_user_personal_vehicle_as_handle()
    if vehicle then
        VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, false)
    end

    local last_vehicle = entities.get_user_vehicle_as_handle()
    if last_vehicle and last_vehicle ~= vehicle then
        VEHICLE.SET_VEHICLE_ENGINE_ON(last_vehicle, true, true, false)
    end
end)
menu.action(Vehicle_Personal_options, "打开左车门", {}, "", function()
    local vehicle = entities.get_user_personal_vehicle_as_handle()
    if vehicle then
        VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, 0, false, false)
    end
end)
menu.action(Vehicle_Personal_options, "打开左右车门", {}, "", function()
    local vehicle = entities.get_user_personal_vehicle_as_handle()
    if vehicle then
        VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, 0, false, false)
        VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, 1, false, false)
    end
end)
menu.slider_text(Vehicle_Personal_options, "传送到附近", { "pv_tp_near" }, "会传送在路边等位置",
    { "上一辆载具",
        "个人载具" },
    function(value)
        local vehicle = 0
        if not PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
            vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), true)
        end
        if value == 2 then
            vehicle = entities.get_user_personal_vehicle_as_handle()
        end
        if vehicle then
            local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
            local bool, coords, heading = Get_Closest_Vehicle_Node(pos, 0)
            if bool then
                ENTITY.SET_ENTITY_COORDS(vehicle, coords.x, coords.y, coords.z, true, false, false, false)
                ENTITY.SET_ENTITY_HEADING(vehicle, heading)
                Fix_Vehicle(vehicle)
                VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(vehicle, 5.0)
                VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, false)
                --show blip
                SHOW_BLIP_TIMER(vehicle, 225, 27, 5000)
            else
                util.toast("未找到合适位置")
            end
        end
    end)

--------
menu.action(Vehicle_options, "修复载具无法移动", {}, "尝试而已", function()
    if PED.IS_PED_IN_ANY_VEHICLE(PLAYER.PLAYER_PED_ID(), false) then
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
        if vehicle then
            if RequestControl(vehicle) then
                VEHICLE.SET_VEHICLE_HAS_BEEN_OWNED_BY_PLAYER(vehicle, false)
                VEHICLE.SET_VEHICLE_UNDRIVEABLE(vehicle, false)
                VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, 1000)
                VEHICLE.SET_VEHICLE_PETROL_TANK_HEALTH(vehicle, 1000)
                ENTITY.FREEZE_ENTITY_POSITION(vehicle, false)
                VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, false)
            else
                util.toast("请求控制失败，请重试")
            end
        end
    end
end)

local veh_dirt_level = 0.0
menu.click_slider(Vehicle_options, "载具灰尘程度", {}, "载具全身灰尘程度", 0.0, 15.0, 0.0, 1.0,
    function(value)
        veh_dirt_level = value
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
        if vehicle then
            VEHICLE.SET_VEHICLE_DIRT_LEVEL(vehicle, veh_dirt_level)
        end
    end)
menu.toggle_loop(Vehicle_options, "锁定载具灰尘程度", {}, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        VEHICLE.SET_VEHICLE_DIRT_LEVEL(vehicle, veh_dirt_level)
    end
end)

menu.toggle_loop(Vehicle_options, "防弹轮胎", {}, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(vehicle, false)
    end
end)

menu.toggle_loop(Vehicle_options, "载具引擎快速开启", {}, "减少载具启动引擎时间", function()
    if PED.IS_PED_GETTING_INTO_A_VEHICLE(PLAYER.PLAYER_PED_ID()) then
        local veh = PED.GET_VEHICLE_PED_IS_ENTERING(PLAYER.PLAYER_PED_ID())
        if veh then
            VEHICLE.SET_VEHICLE_ENGINE_HEALTH(veh, 1000)
            VEHICLE.SET_VEHICLE_ENGINE_ON(veh, true, true, true)
        end
    end
end)
menu.toggle_loop(Vehicle_options, "解锁正在进入的载具", {}, "解锁你正在进入的载具,对于锁住的玩家载具也有效果。"
    , function()
    if PED.IS_PED_IN_ANY_VEHICLE(PLAYER.PLAYER_PED_ID(), false) then
        local v = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED(v, 1)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(v, false)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_PLAYER(v, PLAYER.PLAYER_ID(), false)
        VEHICLE.SET_VEHICLE_UNDRIVEABLE(v, false)
        ENTITY.FREEZE_ENTITY_POSITION(v, false)
    else
        local veh = PED.GET_VEHICLE_PED_IS_TRYING_TO_ENTER(PLAYER.PLAYER_PED_ID())
        if veh ~= 0 then
            if RequestControl(veh) then
                VEHICLE.SET_VEHICLE_DOORS_LOCKED(veh, 1)
                VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(veh, false)
                VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_PLAYER(veh, PLAYER.PLAYER_ID(), false)
                VEHICLE.SET_VEHICLE_HAS_BEEN_OWNED_BY_PLAYER(veh, false)
                VEHICLE.SET_VEHICLE_UNDRIVEABLE(veh, false)
                ENTITY.FREEZE_ENTITY_POSITION(veh, false)
            else
                util.toast("请求控制失败，请重试")
            end
        end
    end
end)



-----------------------------------
------------ 世界实体选项 ------------
-----------------------------------
local Entity_options = menu.list(menu.my_root(), "世界实体选项", {}, "")
-----
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
            if NEAR_PED_onlyHostile then
                if PED.IS_PED_IN_COMBAT(ent, players.user_ped()) then
                    local head_pos = PED.GET_PED_BONE_COORDS(ent, 0x322c, 0, 0, 0)
                    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(head_pos.x, head_pos.y, head_pos.z + 0.1, head_pos.x,
                        head_pos.y, head_pos.z, 1000, false, weaponHash, players.user_ped(), false, false, 1000)
                end
            else
                local head_pos = PED.GET_PED_BONE_COORDS(ent, 0x322c, 0, 0, 0)
                MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(head_pos.x, head_pos.y, head_pos.z + 0.1, head_pos.x,
                    head_pos.y, head_pos.z, 1000, false, weaponHash, players.user_ped(), false, false, 1000)
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
control_nearby_vehicles_toggles = {
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
control_nearby_vehicles_data = {
    forward_speed = 30,
    max_speed = 0,
    alpha = 0,
}
control_nearby_vehicles_setting = {
    radius = 30.0,
    time_delay = 1000,
    exclude_mission = true,
    exclude_dead = true
}

is_Control_nearby_vehicles = false
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
                    FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, 2, 100.0, true, false, 0, false)
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
control_nearby_peds_toggles = {
    --Trolling
    force_forward = false,
    drop_weapon = false,
    ignore_events = false,
    explode_head = false,
    --Friendly
    drop_money = false,
    give_weapon = false
}
control_nearby_peds_data = {
    forward_degree = 30,
    drop_money_amount = 100,
    weapon_hash = 4130548542
}
control_nearby_peds_setting = {
    radius = 30.0,
    time_delay = 1000,
    exclude_ped_in_vehicle = true,
    exclude_mission = true,
    exclude_dead = true
}

is_Control_nearby_peds = false
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

menu.slider(Nearby_Vehicle_options, "范围半径", { "radius_nearby_vehicle" }, "", 0.0, 1000.0, 30.0, 10.0,
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

menu.slider(Nearby_Ped_options, "范围半径", { "radius_nearby_ped" }, "", 0.0, 1000.0, 30.0, 10.0, function(value)
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
menu.list_select(Nearby_Ped_Friendly_options, "设置武器", {}, "", weapon_name_ListItem, 1, function(value)
    control_nearby_peds_data.weapon_hash = util.joaat(weapon_model_list[value])
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
menu.slider_text(Nearby_Ped_Combat_setting, "作战技能", {}, "", { "弱", "普通", "专业" }, function(value)
    nearby_ped_combat.combat_ability = value - 1
end)
menu.slider_text(Nearby_Ped_Combat_setting, "作战范围", {}, "", { "近", "中等", "远", "非常远" },
    function(value)
        nearby_ped_combat.combat_range = value - 1
    end)
menu.slider_text(Nearby_Ped_Combat_setting, "作战走位", {}, "", { "站立", "防卫", "会前进", "会后退" },
    function(value)
        nearby_ped_combat.combat_movement = value - 1
    end)
menu.slider_text(Nearby_Ped_Combat_setting, "失去目标时反应", {}, "", { "退出战斗", "从不失去目标",
    "寻找目标" }, function(value)
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
    for _, ped in ipairs(entities.get_all_peds_as_handles()) do
        if IS_PED_PLAYER(ped) then
        elseif PED.IS_PED_DEAD_OR_DYING(ped) or ENTITY.IS_ENTITY_DEAD(ped) then
        elseif nearby_ped_cleartask.exclude_mission and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ped) then
        elseif nearby_ped_cleartask.only_combat and not PED.IS_PED_IN_COMBAT(ped, players.user_ped()) then
        else
            if nearby_ped_cleartask.clear_task then
                TASK.CLEAR_PED_TASKS(ped)
                TASK.CLEAR_DEFAULT_PRIMARY_TASK(ped)
                TASK.CLEAR_PED_SECONDARY_TASK(ped)
                TASK.TASK_CLEAR_LOOK_AT(ped)
                TASK.TASK_CLEAR_DEFENSIVE_AREA(ped)
                TASK.CLEAR_DRIVEBY_TASK_UNDERNEATH_DRIVING_TASK(ped)

                if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
                    local veh = PED.GET_VEHICLE_PED_IS_USING(ped)
                    TASK.CLEAR_PRIMARY_VEHICLE_TASK(veh)
                    TASK.CLEAR_VEHICLE_CRASH_TASK(veh)
                end
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
    radius = 30.0
}
menu.slider(Nearby_Area_options, "范围半径", { "radius_nearby_area" }, "", 0.0, 1000.0, 30.0, 10.0,
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
menu.toggle_loop(Nearby_Area_Clear, "清理区域", {}, "清理区域内所有东西", function()
    local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
    MISC.CLEAR_AREA(coords.x, coords.y, coords.z, nearby_area.radius, true, false, false, false)
end)
menu.toggle_loop(Nearby_Area_Clear, "清理载具", {}, "清理区域内所有载具", function()
    local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
    MISC.CLEAR_AREA_OF_VEHICLES(coords.x, coords.y, coords.z, nearby_area.radius, false, false, false, false, false,
        false)
end)
menu.toggle_loop(Nearby_Area_Clear, "清理行人", {}, "清理区域内所有行人", function()
    local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
    MISC.CLEAR_AREA_OF_PEDS(coords.x, coords.y, coords.z, nearby_area.radius, 1)
end)
menu.toggle_loop(Nearby_Area_Clear, "清理警察", {}, "清理区域内所有警察", function()
    local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
    MISC.CLEAR_AREA_OF_COPS(coords.x, coords.y, coords.z, nearby_area.radius, 0)
end)
menu.toggle_loop(Nearby_Area_Clear, "清理物体", {}, "清理区域内所有物体", function()
    local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
    MISC.CLEAR_AREA_OF_OBJECTS(coords.x, coords.y, coords.z, nearby_area.radius, 0)
end)
menu.toggle_loop(Nearby_Area_Clear, "清理投掷物", {}, "清理区域内所有子弹、炮弹、投掷物等",
    function()
        local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
        MISC.CLEAR_AREA_OF_PROJECTILES(coords.x, coords.y, coords.z, nearby_area.radius, 0)
    end)

-------------
-- 射击区域
-------------
local Nearby_Area_Shoot = menu.list(Nearby_Area_options, "射击区域", {}, "")
local nearby_area_shoot = {
    target_ped = 2,
    target_ped_body = 2,
    target_vehicle = 1,
    target_vehicle_body = 1,
    weapon = "PLAYER_WEAPON",
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
    { "全部载具", {}, "排除玩家载具" },
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

-----
local Nearby_Area_Shoot_Setting = menu.list(Nearby_Area_Shoot, "设置", {}, "")
menu.divider(Nearby_Area_Shoot_Setting, "属性")

local Nearby_Area_Shoot_Weapon = {
    { "玩家手持武器", {}, "PLAYER_WEAPON" },
    { "穿甲手枪", {}, "WEAPON_APPISTOL" },
    { "电击枪", {}, "WEAPON_STUNGUN" },
    { "原子能枪", {}, "WEAPON_RAYPISTOL" },
    { "微型冲锋枪", {}, "WEAPON_MICROSMG" },
    { "特质卡宾步枪", {}, "WEAPON_SPECIALCARBINE" },
    { "突击霰弹枪", {}, "WEAPON_ASSAULTSHOTGUN" },
    { "火箭筒", {}, "WEAPON_RPG" },
    { "电磁步枪", {}, "WEAPON_RAILGUN" },
}
menu.list_select(Nearby_Area_Shoot_Setting, "武器", {}, "", Nearby_Area_Shoot_Weapon, 1, function(value)
    nearby_area_shoot.weapon = Nearby_Area_Shoot_Weapon[value][3]
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
menu.toggle(Nearby_Area_Shoot_Setting, "可听见", {}, "", function(toggle)
    nearby_area_shoot.is_audible = toggle
end, true)
menu.toggle(Nearby_Area_Shoot_Setting, "不可见", {}, "", function(toggle)
    nearby_area_shoot.is_invisible = toggle
end)
menu.toggle(Nearby_Area_Shoot_Setting, "从玩家位置起始射击", {}, "如果关闭，则起始位置为目标位置+偏移\n如果开启，建议偏移Z>1.0"
    ,
    function(toggle)
        nearby_area_shoot.start_from_player = toggle
    end)

menu.divider(Nearby_Area_Shoot_Setting, "起始射击位置偏移")
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
    local weaponHash
    if nearby_area_shoot.weapon == "PLAYER_WEAPON" then
        local pWeapon = memory.alloc_int()
        WEAPON.GET_CURRENT_PED_WEAPON(players.user_ped(), pWeapon, true)
        weaponHash = memory.read_int(pWeapon)
    else
        weaponHash = util.joaat(nearby_area_shoot.weapon)
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
                elseif nearby_area_shoot.target_ped == 5 and PED.IS_PED_IN_COMBAT(ent, players.user_ped()) then
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
                        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(start_pos.x, start_pos.y, start_pos.z,
                            pos.x, pos.y, pos.z,
                            nearby_area_shoot.damage, false, weaponHash, owner,
                            nearby_area_shoot.is_audible, nearby_area_shoot.is_invisible, nearby_area_shoot.speed,
                            players.user_ped())
                    elseif state == "draw" then
                        GRAPHICS.DRAW_LINE(start_pos.x, start_pos.y, start_pos.z, pos.x, pos.y, pos.z, 255, 0, 255, 255)
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
                elseif nearby_area_shoot.target_vehicle == 3 then
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
                            GRAPHICS.DRAW_LINE(start_pos.x, start_pos.y, start_pos.z, pos.x, pos.y, pos.z, 255, 0, 255,
                                255)
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
                                    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(start_pos.x, start_pos.y,
                                        start_pos.z,
                                        pos.x, pos.y, pos.z,
                                        nearby_area_shoot.damage, false, weaponHash, owner,
                                        nearby_area_shoot.is_audible, nearby_area_shoot.is_invisible,
                                        nearby_area_shoot.speed,
                                        players.user_ped())
                                elseif state == "draw" then
                                    GRAPHICS.DRAW_LINE(start_pos.x, start_pos.y, start_pos.z, pos.x, pos.y, pos.z, 255, 0
                                        , 255, 255)
                                end
                            end
                        end
                    end

                end

            end
        end
    end

end

menu.toggle_loop(Nearby_Area_Shoot, "绘制模拟射击连线", {}, "", function()
    Shoot_Nearby_Area("draw")
end)

menu.divider(Nearby_Area_Shoot, "")
menu.action(Nearby_Area_Shoot, "射击", {}, "", function()
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
menu.toggle_loop(MISSION_ENTITY_cargo_remove, "特种货物", { "hccoolspecial" }, "", function()
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
        end
    end)

menu.action(MISSION_ENTITY_cargo, "特种货物 传送到我", {}, "By Blip\nBlip Sprite ID: 478", function()
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
            TP_TO_ME(ent, 0.0, 2.0, -0.5)
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

--Model Hash: -1235210928(object) 卢佩 水下 要炸的货箱
menu.action(MISSION_ENTITY_cargo, "卢佩：水下货箱 获取", {},
    "先获取到才能传送\n货箱里面 要拾取的包裹\nModel Hash: 388143302, -36934887, 319657375, 924741338, -1249748547"
    , function()
    --
    local water_cargo_hash_list = { 388143302, -36934887, 319657375, 924741338, -1249748547 }
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

menu.action(MISSION_ENTITY_cargo, "传送到仓库助理", {}, "让他去拉货\nBy Blip\nBlip Sprite ID: 480"
    , function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(480)
    local coords = HUD.GET_BLIP_COORDS(blip)
    if coords.x == 0 and coords.y == 0 and coords.z == 0 then
        util.toast("Not Found")
    else
        ENTITY.SET_ENTITY_COORDS(players.user_ped(), coords.x - 1.0, coords.y, coords.z, false, false, false, false)
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
menu.action(MISSION_ENTITY_bunker, "原材料：箱子 传送到我", {}, "游艇 货轮\nModel Hash: -955159266",
    function()
        local entity_list = GetEntity_ByModelHash("pickup", true, -955159266)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ME(ent, 0.0, 2.0, -1.0)
            end
        else
            util.toast("Not Found")
        end
    end)
menu.action(MISSION_ENTITY_bunker, "长鳍追飞机：掉落货物 传送到我", {}, "\nModel Hash: 91541528",
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
menu.action(MISSION_ENTITY_bunker, "长鳍追飞机：炸掉长鳍", {}, "不想等飞机慢慢地投放货物\nModel Hash: 1861786828"
    , function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, 1861786828)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            ENTITY.SET_ENTITY_INVINCIBLE(ent, false)
            local pos = ENTITY.GET_ENTITY_COORDS(ent)
            FIRE.ADD_OWNED_EXPLOSION(players.user_ped(), pos.x, pos.y, pos.z - 0.5, 2, 5.0, true, false
                , 0, false)
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
                FIRE.ADD_OWNED_EXPLOSION(players.user_ped(), pos.x, pos.y, pos.z + 0.2, 2, 10.0, true,
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
            FIRE.ADD_OWNED_EXPLOSION(players.user_ped(), pos.x, pos.y, pos.z - 0.5, 2, 5.0, true, false
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
            FIRE.ADD_OWNED_EXPLOSION(players.user_ped(), pos.x, pos.y, pos.z - 0.5, 2, 5.0, true, false
                , 0, false)
        end
    else
        util.toast("Not Found")
    end
end)
menu.action(MISSION_ENTITY_bunker, "骇入飞机 传送到我", {}, "传送到头上并冻结\nModel Hash: -32878452",
    function()
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

----- 佩里科岛抢劫 -----
local MISSION_ENTITY_perico = menu.list(MISSION_ENTITY, "佩里科岛抢劫", {}, "")

menu.action(MISSION_ENTITY_perico, "传送到虎鲸 任务面板", {}, "需要提前叫出虎鲸", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(760)
    if not HUD.DOES_BLIP_EXIST(blip) then
        util.toast("未找到虎鲸")
    else
        TELEPORT(1561.2369, 385.8771, -49.689915, 175)
    end
end)
menu.action(MISSION_ENTITY_perico, "传送到虎鲸 外面甲板", {}, "需要提前叫出虎鲸", function()
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
menu.action(MISSION_ENTITY_perico, "美杜莎 传送到驾驶位", {}, "\nModel Hash: 1077420264", function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, 1077420264)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            VEHICLE.SET_VEHICLE_ENGINE_ON(ent, true, true, false)
            ENTITY.SET_ENTITY_INVINCIBLE(ent, true)
            PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), ent, -1)
        end
    end
end)
menu.action(MISSION_ENTITY_perico, "信号塔 传送到那里", {}, "\nModel Hash: 1981815996",
    function()
        local entity_list = GetEntity_ByModelHash("object", true, 1981815996)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ENTITY(ent, 0.0, -0.5, 0.5)
                SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ent)
            end
        end
    end)

menu.divider(MISSION_ENTITY_perico, "前置")
menu.action(MISSION_ENTITY_perico, "长崎 传送到我并坐进尖锥魅影", {},
    "生成并坐进尖锥魅影 传送长崎到后面\nModel Hash: -1352468814"
    , function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, -1352468814)
    if next(entity_list) ~= nil then
        local objHash = util.joaat("phantom2")
        RequestModels(objHash)
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
menu.action(MISSION_ENTITY_perico, "保险箱密码 传送到那里", {}, "赌场 保安队长\nModel Hash: -1109568186"
    , function()
    local entity_list = GetEntity_ByModelHash("ped", true, -1109568186)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, 0.0, 0.5)
        end
    end
end)
menu.action(MISSION_ENTITY_perico, "等离子切割枪包裹 传送到我", {}, "\nModel Hash: -802406134",
    function()
        local entity_list = GetEntity_ByModelHash("pickup", true, -802406134)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ME(ent, 0.0, 0.0, 2.0)
            end
        end
    end)
menu.action(MISSION_ENTITY_perico, "指纹复制器 传送到我", {}, "地下车库\nModel Hash: 1506325614",
    function()
        local entity_list = GetEntity_ByModelHash("pickup", true, 1506325614)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ME(ent, 0.0, 0.0, 2.0)
            end
        end
    end)
menu.action(MISSION_ENTITY_perico, "割据 传送到那里", {}, "工地\nModel Hash: 1871441709", function()
    local entity_list = GetEntity_ByModelHash("pickup", true, 1871441709)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, 1.5, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ent, -180)
        end
    end
end)
menu.action(MISSION_ENTITY_perico, "武器 炸掉女武神", {}, "\nModel Hash: -1600252419", function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, -1600252419)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            local pos = ENTITY.GET_ENTITY_COORDS(ent)
            FIRE.ADD_OWNED_EXPLOSION(players.user_ped(), pos.x, pos.y, pos.z - 0.5, 2, 5.0, true, false
                , 0, false)
        end
    end
end)

menu.divider(MISSION_ENTITY_perico, "佩里科岛")
menu.action(MISSION_ENTITY_perico, "信号塔 传送到我", {}, "\nModel Hash: 1981815996", function()
    local entity_list = GetEntity_ByModelHash("object", false, 1981815996)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, -1.0)
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
        end
    end
end)
menu.action(MISSION_ENTITY_perico, "发电站 传送到我", {}, "\nModel Hash: 1650252819", function()
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
menu.action(MISSION_ENTITY_perico, "保安服 传送到我", {}, "\nModel Hash: -1141961823",
    function()
        local entity_list = GetEntity_ByModelHash("object", false, -1141961823)
        if next(entity_list) ~= nil then
            local x = 0.0
            for k, ent in pairs(entity_list) do
                TP_TO_ME(ent, x, 2.0, -1.0)
                x = x + 1.0
            end
        end
    end)
menu.action(MISSION_ENTITY_perico, "螺旋切割器 传送到我", {}, "\nModel Hash: -710382954",
    function()
        local entity_list = GetEntity_ByModelHash("pickup", false, -710382954)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ME(ent, 0.0, 2.0, -1.0)
            end
        end
    end)
menu.action(MISSION_ENTITY_perico, "抓钩 传送到我", {}, "\nModel Hash: -1789904450", function()
    local entity_list = GetEntity_ByModelHash("pickup", false, -1789904450)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, -1.0)
        end
    end
end)
menu.action(MISSION_ENTITY_perico, "运货卡车 传送到我", {}, "自动删除npc卡车司机\nModel Hash: 2014313426"
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
---
local MISSION_ENTITY_perico_other = menu.list(MISSION_ENTITY_perico, "其它", {}, "")

menu.action(MISSION_ENTITY_perico_other, "获取豪宅内黄金数量", {},
    "先获取黄金数量才能传送\nModel Hash: -180074230",
    function()
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
    , 0, 0, 0, 1,
    function(value)
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
menu_Gold_Vault_TP2 = menu.click_slider(MISSION_ENTITY_perico_other, "传送到 黄金", {}, "", 0, 0, 0, 1,
    function(value)
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
    "会在豪宅外生成主要目标包裹\nModel Hash: -1714533217, 1098122770"
    ,
    function()
        local entity_list = GetEntity_ByModelHash("object", false, -1714533217, 1098122770)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                ENTITY.SET_ENTITY_HEALTH(ent, 0)
            end
        end
    end)
menu.action(MISSION_ENTITY_perico_other, "主要目标掉落包裹 传送到我", {},
    "携带主要目标者死亡后掉落的包裹\nBlip Sprite ID: 765\nModel Hash: -1851147549 (pickup)", function()
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
    "保险箱门和里面的现金\nModel Hash: 485111592, -2143192170",
    function()
        local entity_list = GetEntity_ByModelHash("object", false, 485111592)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ME(ent, -0.5, 1.0, 0.0)
                SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped(), 180.0)
            end
        end
        entity_list = GetEntity_ByModelHash("pickup", false, -2143192170)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ME(ent, 0.0, 1.0, 0.0)
            end
        end
    end)


----- 赌场抢劫 -----
local MISSION_ENTITY_casion = menu.list(MISSION_ENTITY, "赌场抢劫", {}, "")

menu.divider(MISSION_ENTITY_casion, "侦查")
menu.action(MISSION_ENTITY_casion, "保安 传送到我", {}, "侦查前置\nModel Hash: -1094177627",
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
    { 1146.7454, 243.3848, -51.0408 },
    { 1105.9666, 259.99405, -50.840923 }
}
menu.click_slider(MISSION_ENTITY_casion, "赌场 传送到骇入位置", {}, "进入赌场后再传送", 1, 3, 1
    , 1,
    function(value)
        local pos = casion_invest_pos[value]
        TELEPORT(pos[1], pos[2], pos[3])
    end)

menu.divider(MISSION_ENTITY_casion, "前置")
menu.action(MISSION_ENTITY_casion, "武器 传送到我", {}, "摩托车帮 长方形板条包裹\nModel Hash: 798951501"
    , function()
    local entity_list = GetEntity_ByModelHash("pickup", true, 798951501)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, -1.0)
        end
    end
end)
menu.action(MISSION_ENTITY_casion, "武器：车 传送到我", {}, "国安局面包车 武器在防暴车内\nModel Hash: 1885839156"
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
menu.action(MISSION_ENTITY_casion, "武器：飞机 传送到驾驶位", {}, "走私犯 水上飞机\nModel Hash: 1043222410"
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
menu.action(MISSION_ENTITY_casion, "载具：天威 传送到我", {}, "天威 经典版\nModel Hash: 931280609",
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
menu.action(MISSION_ENTITY_casion, "骇入装置 传送到我", {},
    "FIB大楼 电脑旁边 提箱\n国安局总部 服务器或桌子旁边\nModel Hash: -155327337",
    function()
        local entity_list = GetEntity_ByModelHash("pickup", true, -155327337)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ME(ent, 0.0, 2.0, -1.0)
            end
        end
    end)
menu.action(MISSION_ENTITY_casion, "金库门禁卡：狱警 传送到我", {},
    "监狱巴士 监狱 狱警\nModel Hash: 1456041926", function()
    local entity_list = GetEntity_ByModelHash("ped", true, 1456041926)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, -1.0)
        end
    end
end)
menu.action(MISSION_ENTITY_casion, "金库门禁卡：保安 传送到我", {},
    "醉酒保安和偷情保安\nModel Hash: -1575488699, -1425378987", function()
    local entity_list = GetEntity_ByModelHash("ped", true, -1575488699, -1425378987)
    if next(entity_list) ~= nil then
        local x = 0.0
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, x, 2.0, 10.0)
            x = x + 3.0
        end
    end
end)
menu.action(MISSION_ENTITY_casion, "巡逻路线：车 传送到我", {}, "某辆车后备箱里的箱子\nModel Hash: 1265214509"
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
menu.action(MISSION_ENTITY_casion, "杜根货物 全部爆炸", {},
    "直升机 车 船\n一次性炸不完，多炸几次\nModel Hash: -1671539132, 1747439474, 1448677353",
    function()
        local entity_list = GetEntity_ByModelHash("vehicle", true, -1671539132, 1747439474, 1448677353)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                local pos = ENTITY.GET_ENTITY_COORDS(ent)
                FIRE.ADD_OWNED_EXPLOSION(players.user_ped(), pos.x, pos.y, pos.z - 0.5, 2, 5.0, true,
                    false
                    , 0, false)
            end
        end
    end)
menu.action(MISSION_ENTITY_casion, "电钻 传送到那里", {}, "工地 箱子里的电钻\nModel Hash: -12990308"
    , function()
    local entity_list = GetEntity_ByModelHash("pickup", true, -12990308)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, 0.0, 0.5)
        end
    end
end)
menu.action(MISSION_ENTITY_casion, "二级保安证：尸体 传送到那里", {},
    "灵车 医院 泊车员尸体\nModel Hash: 771433594", function()
    local entity_list = GetEntity_ByModelHash("object", true, 771433594)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, -1.0, 0.0, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ent, -80.0)
        end
    end
end)
menu.action(MISSION_ENTITY_casion, "二级保安证：保安证 传送到我", {}, "聚会 小卡片\nModel Hash: -2018799718"
    , function()
    local entity_list = GetEntity_ByModelHash("pickup", true, -2018799718)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 1.0, 0.0)
        end
    end
end)

menu.divider(MISSION_ENTITY_casion, "隐迹潜踪")
menu.action(MISSION_ENTITY_casion, "无人机零件 传送到我", {},
    "炸掉无人机，传送掉落的零件\nModel Hash: 1657647215, -1285013058", function()
    --Model Hash: 1657647215 纳米无人机 (object)
    --Model Hash: -1285013058 无人机炸毁后掉落的零件（pickup）
    local entity_list = GetEntity_ByModelHash("object", true, 1657647215)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            local pos = ENTITY.GET_ENTITY_COORDS(ent)
            FIRE.ADD_OWNED_EXPLOSION(players.user_ped(), pos.x, pos.y, pos.z - 0.5, 2, 5.0, true, false
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
menu.action(MISSION_ENTITY_casion, "金库激光器 传送到我", {}, "\nModel Hash: 1953119208", function()
    local entity_list = GetEntity_ByModelHash("pickup", true, 1953119208)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, -1.0)
        end
    end
end)

menu.divider(MISSION_ENTITY_casion, "兵不厌诈")
menu.action(MISSION_ENTITY_casion, "古倍科技套装 传送到我", {}, "\nModel Hash: 1425667258",
    function()
        local entity_list = GetEntity_ByModelHash("pickup", true, 1425667258)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ME(ent, 0.0, 2.0, -1.0)
            end
        end
    end)
menu.action(MISSION_ENTITY_casion, "金库钻孔机 传送到我", {}, "全福银行\nModel Hash: 415149220",
    function()
        local entity_list = GetEntity_ByModelHash("pickup", true, 415149220)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ME(ent, 0.0, 2.0, -1.0)
            end
        end
    end)
menu.action(MISSION_ENTITY_casion, "国安局套装 传送到我", {}, "警察局\nModel Hash: -1713985235",
    function()
        local entity_list = GetEntity_ByModelHash("pickup", true, -1713985235)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ME(ent, 0.0, 2.0, -1.0)
            end
        end
    end)

menu.divider(MISSION_ENTITY_casion, "气势汹汹")
menu.action(MISSION_ENTITY_casion, "热能炸药 传送到我", {}, "\nModel Hash: -2043162923", function()
    local entity_list = GetEntity_ByModelHash("pickup", true, -2043162923)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, -1.0)
        end
    end
end)
menu.action(MISSION_ENTITY_casion, "金库炸药 传送到我", {}, "要潜水下去 难找恶心\nModel Hash: -681938663"
    , function()
    local entity_list = GetEntity_ByModelHash("pickup", true, -681938663)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, -1.0)
        end
    end
end)
menu.action(MISSION_ENTITY_casion, "加固防弹衣 传送到我", {}, "地堡 箱子\nModel Hash: 1715697304",
    function()
        local entity_list = GetEntity_ByModelHash("pickup", true, 1715697304)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ME(ent, 0.0, 2.0, 0.0)
            end
        end
    end)
menu.action(MISSION_ENTITY_casion, "加固防弹衣：潜水套装 传送到我", {}, "人道实验室\nModel Hash: 788248216"
    , function()
    local entity_list = GetEntity_ByModelHash("object", true, 788248216)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, -1.0)
        end
    end
end)

menu.divider(MISSION_ENTITY_casion, "赌场")
menu.action(MISSION_ENTITY_casion, "小金库现金车 传送到那里", {}, "\nModel Hash: 1736112330",
    function()
        local entity_list = GetEntity_ByModelHash("object", true, 1736112330)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ENTITY(ent, 0.0, 0.0, 0.5)
            end
        end
    end)


menu.action(MISSION_ENTITY_casion, "获取金库内推车数量", {},
    "先获取推车数量才能传送\nModel Hash: 412463629, 1171655821, 1401432049", function()
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

menu_Vault_Trolley_TP = menu.click_slider(MISSION_ENTITY_casion, "金库内推车 传送到那里", {}, ""
    , 0
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
menu.action(MISSION_ENTITY_contract, "夜总会：传送到 录像带", {}, "", function()
    TELEPORT(-1617.9883, -3013.7363, -75.20509)
    ENTITY.SET_ENTITY_HEADING(players.user_ped(), 203.7907)
end)
menu.action(MISSION_ENTITY_contract, "船坞：传送到 船里", {}, "绿色的船\nModel Hash: 908897389",
    function()
        local entity_list = GetEntity_ByModelHash("vehicle", true, 908897389)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_INTO_VEHICLE(ent)
            end
        end
    end)
menu.action(MISSION_ENTITY_contract, "船坞：传送到 证据", {}, "德瑞照片\nModel Hash: -1702870637",
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
menu.action(MISSION_ENTITY_contract, "乡村俱乐部：炸掉礼车", {}, "\nModel Hash: -420911112", function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, -420911112)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            local pos = ENTITY.GET_ENTITY_COORDS(ent)
            FIRE.ADD_OWNED_EXPLOSION(players.user_ped(), pos.x, pos.y, pos.z - 0.5, 2, 5.0, true, false
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
                FIRE.ADD_OWNED_EXPLOSION(players.user_ped(), pos.x, pos.y, pos.z - 0.5, 2, 5.0, true,
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

menu.action(MISSION_ENTITY_payphone, "回收贵重物品：传送到 保险箱", {}, "\nModel Hash: -798293264",
    function()
        local entity_list = GetEntity_ByModelHash("object", true, -798293264)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ENTITY(ent, 0.0, -0.5, 0.0)
                SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ent)
            end
        end
    end)
menu.action(MISSION_ENTITY_payphone, "回收贵重物品：传送到 保险箱密码", {},
    "\nModel Hash: 367638847", function()
    local entity_list = GetEntity_ByModelHash("object", true, 367638847)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, 0.0, 0.5)
        end
    end
end)
menu.action(MISSION_ENTITY_payphone, "变现资产：坐进要跟踪的车并加速", {},
    "梅利威瑟，亚美尼亚帮\nModel Hash: 2047212121, -39239064"
    , function()
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
menu.action(MISSION_ENTITY_payphone, "资产保护：保安 无敌强化", {}, "\nModel Hash: -1575488699, -634611634",
    function()
        local entity_list = GetEntity_ByModelHash("ped", true, -1575488699, -634611634)
        if next(entity_list) ~= nil then
            local i = 0
            for k, ent in pairs(entity_list) do
                local weaponHash = util.joaat("WEAPON_SPECIALCARBINE")
                WEAPON.GIVE_WEAPON_TO_PED(ent, weaponHash, -1, false, true)
                WEAPON.SET_CURRENT_PED_WEAPON(ent, weaponHash, false)
                control_ped_enhanced(ent)
                i = i + 1
            end
            util.toast("Done!\nNumber: " .. i)
        end
    end)
menu.action(MISSION_ENTITY_payphone, "资产保护：毁掉资产 任务失败", {},
    "不再等待漫长的10分钟\nModel Hash: -1597216682, 1329706303, 1503555850, -534405572", function()
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
menu.action(MISSION_ENTITY_payphone, "救援行动：传送到 客户", {},
    "\nModel Hash: -2076336881, -1589423867, 826475330, 2093736314", function()
    local entity_list = GetEntity_ByModelHash("ped", true, -2076336881, -1589423867, 826475330, 2093736314)
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
menu.action(MISSION_ENTITY_payphone, "载具回收：摩托车 传送到我", {},
    "里佛\nModel Hash: 1993851908, 1353120668"
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
    combat = 1,
    ped_state = 1,
    --vehicle
    driver = 1,
}

menu.list_select(MISSION_ENTITY_All, "实体类型", {}, "", entity_type_ListItem, 1, function(value)
    mission_ent_all_data.type = entity_type_ListItem[value][1]
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
    local all_ent
    if mission_ent_all_data.type == "Ped" then
        all_ent = entities.get_all_peds_as_handles()
    elseif mission_ent_all_data.type == "Vehicle" then
        all_ent = entities.get_all_vehicles_as_handles()
    elseif mission_ent_all_data.type == "Object" then
        all_ent = entities.get_all_objects_as_handles()
    elseif mission_ent_all_data.type == "Pickup" then
        all_ent = entities.get_all_pickups_as_handles()
    end

    for k, ent in pairs(all_ent) do
        if mission_ent_all_data.type == "Ped" and IS_PED_PLAYER(ent) then --排除玩家
        elseif Check_match_condition(ent) then
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
            --entity
            entity_control_all(menu_list, ent, index)
            --ped
            if ENTITY.IS_ENTITY_A_PED(ent) then
                entity_control_ped(menu_list, ent, index)
            end
            --vehicle
            if ENTITY.IS_ENTITY_A_VEHICLE(ent) then
                entity_control_vehicle(menu_list, ent, index)
            end

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
        all_entities_control(mission_ent_all_menu_list[2], mission_ent_list)
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

custom_hash_entity_Type = menu.list_select(MISSION_ENTITY_custom, "实体类型", {}, "", entity_type_ListItem, 1,
    function(value)
        custom_hash_entity.type = entity_type_ListItem[value][1]
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
    local custom_all_entity
    if custom_hash_entity.type == "Ped" then
        custom_all_entity = entities.get_all_peds_as_handles()
    elseif custom_hash_entity.type == "Vehicle" then
        custom_all_entity = entities.get_all_vehicles_as_handles()
    elseif custom_hash_entity.type == "Object" then
        custom_all_entity = entities.get_all_objects_as_handles()
    elseif custom_hash_entity.type == "Pickup" then
        custom_all_entity = entities.get_all_pickups_as_handles()
    end
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
                    -- entity
                    entity_control_all(menu_list, ent, index)
                    -- ped
                    if ENTITY.IS_ENTITY_A_PED(ent) then
                        entity_control_ped(menu_list, ent, index)
                    end
                    -- vehicle
                    if ENTITY.IS_ENTITY_A_VEHICLE(ent) then
                        entity_control_vehicle(menu_list, ent, index)
                    end
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
            all_entities_control(custom_hash_all_ent_menu_list[2], custom_hash_ent_list)
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
menu.list_select(Manage_Hash_List_Menu_add, "实体类型", {}, "", entity_type_ListItem, 1,
    function(value)
        value = entity_type_ListItem[value][1]
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
    Draw_Rect_In_Center()
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




--------------------------------
------------ 战局选项 ------------
--------------------------------
local Session_options = menu.list(menu.my_root(), "战局选项", {}, "")

local Session_BlockArea_options = menu.list(Session_options, "阻挡区域", {}, "")

local BlockArea_ListItem = {
    { "全部改车王" }, { "本尼改车坊" }, { "赌场" },
}
local BlockArea_ListData = {
    { { -357.66544, -134.26419, 38.237751, 340.001 }, { -1144.0569, -1989.5784, 12.9626, 40.001 },
        { 721.08496, -1088.8752, 22.046721, 0.001 },
        { 115.59574, 6621.5693, 31.646144, 310.001 }, { 110.460236, 6615.827, 31.660228, 310.001 } },
    { { -205.6571, -1308.4313, 31.0932, 270.001 } },
    { { 925.2641, 48.6246, 80.7647, 325.001 }, { 935.29553, -0.5328601, 78.56404, 235.001 } },
}
local BlockArea_Obj = {
    "木板"
}
local BlockArea_ObjData = {
    { "309416120", "object" }
}
local BlockArea_Setting = {
    area = 1,
    obj = 1,
    visible = true,
    freeze = true,
}

menu.list_select(Session_BlockArea_options, "选择区域", {}, "", BlockArea_ListItem, 1, function(value)
    BlockArea_Setting.area = value
end)
menu.action(Session_BlockArea_options, "阻挡", {}, "", function()
    local i = 0
    local hash = BlockArea_ObjData[BlockArea_Setting.obj][1]
    local Type = BlockArea_ObjData[BlockArea_Setting.obj][2]
    RequestModels(hash)
    local ent

    local area = BlockArea_ListData[BlockArea_Setting.area]
    for k, pos in pairs(area) do
        if Type == "object" then
            ent = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, pos[1], pos[2], pos[3], true, true, true)
        end
        if ent then
            ENTITY.SET_ENTITY_HEADING(ent, pos[4])
            ENTITY.SET_ENTITY_VISIBLE(ent, BlockArea_Setting.visible, 0)
            ENTITY.FREEZE_ENTITY_POSITION(ent, BlockArea_Setting.freeze)
            Set_Entity_Networked(ent, false)
            i = i + 1
        end
    end

    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
    util.toast("阻挡完成！\n阻挡区域: " .. i .. " 个")
end)
-----
menu.divider(Session_BlockArea_options, "设置")
menu.slider_text(Session_BlockArea_options, "阻挡物体", {}, "", BlockArea_Obj, function(value)
    BlockArea_Setting.obj = value
end)
menu.toggle(Session_BlockArea_options, "可见", {}, "", function(toggle)
    BlockArea_Setting.visible = toggle
end, true)
menu.toggle(Session_BlockArea_options, "冻结", {}, "", function(toggle)
    BlockArea_Setting.freeze = toggle
end, true)



--------------------------------
------------ 保镖选项 ------------
--------------------------------
local Bodyguard_options = menu.list(menu.my_root(), "保镖选项", {}, "")

--------- Functions ---------
Relationship = {
    friendly_group = 0,
}

function Relationship:addGroup(GroupName)
    local ptr = memory.alloc_int()
    PED.ADD_RELATIONSHIP_GROUP(GroupName, ptr)
    local rel = memory.read_int(ptr)
    memory.free(ptr)
    return rel
end

function Relationship:friendly(ped)
    if not PED.DOES_RELATIONSHIP_GROUP_EXIST(Relationship.friendly_group) then
        Relationship.friendly_group = Relationship:addGroup("friendly_group")
        PED.SET_RELATIONSHIP_BETWEEN_GROUPS(0, Relationship.friendly_group, Relationship.friendly_group)
    end
    PED.SET_PED_RELATIONSHIP_GROUP_HASH(ped, Relationship.friendly_group)
end

Group = {}
function Group:getSize(ID)
    local unkPtr, sizePtr = memory.alloc(1), memory.alloc(1)
    PED.GET_GROUP_SIZE(ID, unkPtr, sizePtr)
    return memory.read_int(sizePtr)
end

function Group:pushMember(ped)
    local groupID = PLAYER.GET_PLAYER_GROUP(players.user())
    local RelationGroupHash = util.joaat("rgFM_AiLike_HateAiHate")

    if not PED.IS_PED_IN_GROUP(ped) then
        PED.SET_PED_AS_GROUP_MEMBER(ped, groupID)
        PED.SET_PED_NEVER_LEAVES_GROUP(ped, true)
    end
    PED.SET_PED_RELATIONSHIP_GROUP_HASH(ped, RelationGroupHash)
    PED.SET_GROUP_SEPARATION_RANGE(groupID, 9999.0)
    --PED.SET_GROUP_FORMATION_SPACING(groupID, v3(1.0, 0.9, 3.0))
    --PED.SET_GROUP_FORMATION(groupID, self.formation)
end

------------------
----- 保镖NPC -----
------------------
local Bodyguard_NPC_options = menu.list(Bodyguard_options, "保镖NPC", {}, "")

local npc_name_list_select = {
    { "富兰克林", {}, "" },
    { "麦克", {}, "" },
    { "崔佛", {}, "" },
    { "莱斯特", {}, "" },
    { "席桑达", {}, "改装铺NPC" },
    { "埃万保安", {}, "" },
    { "埃万重甲兵", {}, "" },
}
local npc_model_list_select = {
    "player_one", "player_zero", "player_two", "ig_lestercrest", "ig_sessanta", "mp_m_avongoon", "u_m_y_juggernaut_01"
}
--生成保镖的默认设置
local bodyguard_npc_set = {
    model = "player_one",
    godmode = false,
    health = 1000,
    no_ragdoll = false,
    weapon = "WEAPON_MICROSMG",
    no_clip = false,
    see_hear_range = 300,
    accuracy = 100,
    shoot_rate = 800,
    combat_ability = 2,
    combat_range = 2,
    combat_movement = 2,
    target_loss_response = 1,
    BF_PerfectAccuracy = false,
}
--生成的保镖
local bodyguard_npc_list = {}

menu.list_select(Bodyguard_NPC_options, "选择模型", {}, "", npc_name_list_select, 1, function(value)
    bodyguard_npc_set.model = npc_model_list_select[value]
end)

local Bodyguard_NPC_default_setting = menu.list(Bodyguard_NPC_options, "默认生成设置", {}, "")
menu.toggle(Bodyguard_NPC_default_setting, "无敌", {}, "", function(toggle)
    bodyguard_npc_set.godmode = toggle
end)
menu.slider(Bodyguard_NPC_default_setting, "生命", { "bodyguard_npc_health" }, "", 100, 30000, 1000, 100,
    function(value)
        bodyguard_npc_set.health = value
    end)
menu.toggle(Bodyguard_NPC_default_setting, "不会摔倒", {}, "", function(toggle)
    bodyguard_npc_set.no_ragdoll = toggle
end)
menu.list_select(Bodyguard_NPC_default_setting, "武器", {}, "", weapon_name_ListItem, 4, function(value)
    bodyguard_npc_set.weapon = weapon_model_list[value]
end)
menu.toggle(Bodyguard_NPC_default_setting, "不换弹夹", {}, "", function(toggle)
    bodyguard_npc_set.no_clip = toggle
end)
menu.divider(Bodyguard_NPC_default_setting, "作战能力")
menu.slider(Bodyguard_NPC_default_setting, "视力听觉范围", { "bodyguard_npc_see_hear_range" }, "", 10, 1000, 300,
    100,
    function(value)
        bodyguard_npc_set.see_hear_range = value
    end)
menu.slider(Bodyguard_NPC_default_setting, "精确度", { "bodyguard_npc_accuracy" }, "", 0, 100, 100, 10,
    function(value)
        bodyguard_npc_set.accuracy = value
    end)
menu.slider(Bodyguard_NPC_default_setting, "射击频率", { "bodyguard_npc_shoot_rate" }, "", 0, 1000, 800, 100,
    function(value)
        bodyguard_npc_set.shoot_rate = value
    end)
menu.slider_text(Bodyguard_NPC_default_setting, "作战技能", {}, "", { "弱", "普通", "专业" }, function(value)
    bodyguard_npc_set.combat_ability = value - 1
end)
menu.slider_text(Bodyguard_NPC_default_setting, "作战范围", {}, "", { "近", "中等", "远", "非常远" },
    function(value)
        bodyguard_npc_set.combat_range = value - 1
    end)
menu.slider_text(Bodyguard_NPC_default_setting, "作战走位", {}, "", { "站立", "防卫", "会前进", "会后退" }
    ,
    function(value)
        bodyguard_npc_set.combat_movement = value - 1
    end)
menu.slider_text(Bodyguard_NPC_default_setting, "失去目标时反应", {}, "", { "退出战斗", "从不失去目标",
    "寻找目标" }, function(value)
    bodyguard_npc_set.target_loss_response = value - 1
end)
menu.divider(Bodyguard_NPC_default_setting, "作战属性")
menu.toggle(Bodyguard_NPC_default_setting, "完美精准度", {}, "", function(toggle)
    bodyguard_npc_set.BF_PerfectAccuracy = toggle
end)
------
menu.action(Bodyguard_NPC_options, "生成保镖", {}, "", function()
    local groupID = PLAYER.GET_PLAYER_GROUP(players.user())
    if Group:getSize(groupID) >= 7 then
        util.toast("保镖人数已达到上限")
    else
        local modelHash = util.joaat(bodyguard_npc_set.model)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0.0, 2.0, 0.0)
        local heading = ENTITY.GET_ENTITY_HEADING(players.user_ped()) + 180
        local ped = Create_Network_Ped(PED_TYPE_MISSION, modelHash, coords.x, coords.y, coords.z, heading)
        --INVINCIBLE
        ENTITY.SET_ENTITY_INVINCIBLE(ped, bodyguard_npc_set.godmode)
        ENTITY.SET_ENTITY_PROOFS(ped, bodyguard_npc_set.godmode, bodyguard_npc_set.godmode, bodyguard_npc_set.godmode,
            bodyguard_npc_set.godmode, bodyguard_npc_set.godmode, bodyguard_npc_set.godmode, bodyguard_npc_set.godmode,
            bodyguard_npc_set.godmode)
        --HEALTH
        ENTITY.SET_ENTITY_MAX_HEALTH(ped, bodyguard_npc_set.health)
        ENTITY.SET_ENTITY_HEALTH(ped, bodyguard_npc_set.health)

        PED.SET_PED_CAN_RAGDOLL(ped, not bodyguard_npc_set.no_ragdoll)
        PED.DISABLE_PED_INJURED_ON_GROUND_BEHAVIOUR(ped)
        PED.SET_PED_CAN_PLAY_AMBIENT_ANIMS(ped, false)
        PED.SET_PED_CAN_PLAY_AMBIENT_BASE_ANIMS(ped, false)
        --WEAPON
        local weaponHash = util.joaat(bodyguard_npc_set.weapon)
        WEAPON.GIVE_WEAPON_TO_PED(ped, weaponHash, -1, false, true)
        WEAPON.SET_CURRENT_PED_WEAPON(ped, weaponHash, false)
        WEAPON.SET_PED_DROPS_WEAPONS_WHEN_DEAD(ped, false)
        PED.SET_PED_CAN_SWITCH_WEAPON(ped, true)
        WEAPON.SET_PED_INFINITE_AMMO_CLIP(ped, bodyguard_npc_set.no_clip)
        --PERCEPTIVE
        PED.SET_PED_SEEING_RANGE(ped, bodyguard_npc_set.see_hear_range)
        PED.SET_PED_HEARING_RANGE(ped, bodyguard_npc_set.see_hear_range)
        --PED.SET_PED_VISUAL_FIELD_PERIPHERAL_RANGE(bodyguard_npc_set.see_hear_range)
        PED.SET_PED_HIGHLY_PERCEPTIVE(ped, true)
        PED.SET_PED_VISUAL_FIELD_MIN_ANGLE(ped, 90.0)
        PED.SET_PED_VISUAL_FIELD_MAX_ANGLE(ped, 90.0)
        PED.SET_PED_VISUAL_FIELD_MIN_ELEVATION_ANGLE(ped, 90.0)
        PED.SET_PED_VISUAL_FIELD_MAX_ELEVATION_ANGLE(ped, 90.0)
        PED.SET_PED_VISUAL_FIELD_CENTER_ANGLE(ped, 90.0)
        --COMBAT
        PED.SET_PED_COMBAT_ABILITY(ped, bodyguard_npc_set.combat_ability)
        PED.SET_PED_COMBAT_RANGE(ped, bodyguard_npc_set.combat_range)
        PED.SET_PED_COMBAT_MOVEMENT(ped, bodyguard_npc_set.combat_movement)
        PED.SET_PED_TARGET_LOSS_RESPONSE(ped, bodyguard_npc_set.target_loss_response)
        --COMBAT ATTRIBUTES
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 0, true) --CanUseCover
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 1, true) --CanUseVehicles
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 2, true) --CanDoDrivebys
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 5, true) --AlwaysFight
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 12, true) --BlindFireWhenInCover
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 13, true) --Aggressive
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 17, false) --AlwaysFlee
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 20, true) --CanTauntInVehicle
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 21, true) --CanChaseTargetOnFoot
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 41, true) --CanCommandeerVehicles
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true) --CanFightArmedPedsWhenNotArmed
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 55, true) --CanSeeUnderwaterPeds
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 58, true) --DisableFleeFromCombat

        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 27, bodyguard_npc_set.BF_PerfectAccuracy)
        ----
        Group:pushMember(ped)
        table.insert(bodyguard_npc_list, ped)
    end
end)

menu.divider(Bodyguard_NPC_options, "管理保镖")
menu.toggle(Bodyguard_NPC_options, "所有保镖无敌", {}, "", function(toggle)
    for k, ent in pairs(bodyguard_npc_list) do
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            ENTITY.SET_ENTITY_INVINCIBLE(ent, toggle)
            ENTITY.SET_ENTITY_PROOFS(ent, toggle, toggle, toggle, toggle, toggle, toggle, toggle, toggle)
        end
    end
end)
menu.list_action(Bodyguard_NPC_options, "给予所有保镖武器", {}, "", weapon_name_ListItem, function(value)
    for k, ent in pairs(bodyguard_npc_list) do
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            local weaponHash = util.joaat(weapon_model_list[value])
            WEAPON.GIVE_WEAPON_TO_PED(ent, weaponHash, -1, false, true)
            WEAPON.SET_CURRENT_PED_WEAPON(ent, weaponHash, false)
        end
    end
end)
menu.action(Bodyguard_NPC_options, "所有保镖传送到我", {}, "", function()
    local y = 2.0
    for k, ent in pairs(bodyguard_npc_list) do
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            TP_TO_ME(ent, 0.0, y, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped(), 180.0)
            y = y + 1.0
        end
    end
end)
menu.action(Bodyguard_NPC_options, "删除已死亡保镖", {}, "", function()
    for k, ent in pairs(bodyguard_npc_list) do
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            if ENTITY.IS_ENTITY_DEAD(ent) then
                entities.delete_by_handle(ent)
                table.remove(bodyguard_npc_list, k)
            end
        end
    end
end)
menu.action(Bodyguard_NPC_options, "删除所有保镖", {}, "", function()
    for k, ent in pairs(bodyguard_npc_list) do
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            entities.delete_by_handle(ent)
        end
    end
    bodyguard_npc_list = {} --生成的保镖
end)


--------------------
----- 保镖直升机 -----
--------------------
local Bodyguard_Heli_options = menu.list(Bodyguard_options, "保镖直升机", {}, "")

local heli_list = {} --生成的直升机
local heli_ped_list = {} --直升机内的保镖

local bodyguard_heli = {
    name = "valkyrie",
    heli_godmode = false,
    ped_godmode = false
}

local heli_name_list_select = {
    { "女武神" },
    { "秃鹰" },
    { "猎杀者" },
    { "警用小蛮牛" },
}
local heli_model_list_select = {
    "valkyrie", "buzzard", "hunter", "polmav"
}
menu.list_select(Bodyguard_Heli_options, "直升机类型", {}, "", heli_name_list_select, 1,
    function(value)
        bodyguard_heli.name = heli_model_list_select[value]
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

    RequestModels(ped_hash, heli_hash)
    Relationship:friendly(players.user_ped())
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

    PED.SET_PED_HIGHLY_PERCEPTIVE(pilot, true)
    PED.SET_PED_VISUAL_FIELD_PERIPHERAL_RANGE(pilot, 500.0)
    PED.SET_PED_SEEING_RANGE(pilot, 500.0)
    PED.SET_PED_HEARING_RANGE(pilot, 500.0)

    PED.SET_PED_COMBAT_MOVEMENT(pilot, 1) --Defensive
    PED.SET_PED_COMBAT_ABILITY(pilot, 2) --Professional
    PED.SET_PED_COMBAT_RANGE(pilot, 1) --Medium
    PED.SET_PED_TARGET_LOSS_RESPONSE(pilot, 1) --NeverLoseTarget

    PED.SET_COMBAT_FLOAT(pilot, 10, 500.0)
    PED.SET_PED_CAN_BE_SHOT_IN_VEHICLE(pilot, false)
    --health
    PED.SET_PED_MAX_HEALTH(pilot, 10000)
    ENTITY.SET_ENTITY_HEALTH(pilot, 10000)
    ENTITY.SET_ENTITY_INVINCIBLE(pilot, bodyguard_heli.ped_godmode)

    Relationship:friendly(pilot)
    table.insert(heli_ped_list, pilot)

    local seats = VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(heli_hash) - 2
    for seat = 0, seats do
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
        PED.SET_PED_SHOOT_RATE(ped, 1000)
        PED.SET_PED_ACCURACY(ped, 100)

        PED.SET_PED_HIGHLY_PERCEPTIVE(ped, true)
        PED.SET_PED_VISUAL_FIELD_PERIPHERAL_RANGE(ped, 500.0)
        PED.SET_PED_SEEING_RANGE(ped, 500.0)
        PED.SET_PED_HEARING_RANGE(ped, 500.0)
        PED.SET_PED_VISUAL_FIELD_MIN_ANGLE(ped, 90.0)
        PED.SET_PED_VISUAL_FIELD_MAX_ANGLE(ped, 90.0)
        PED.SET_PED_VISUAL_FIELD_MIN_ELEVATION_ANGLE(ped, 90.0)
        PED.SET_PED_VISUAL_FIELD_MAX_ELEVATION_ANGLE(ped, 90.0)
        PED.SET_PED_VISUAL_FIELD_CENTER_ANGLE(ped, 90.0)

        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 0, true) --CanUseCover
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 1, true) --CanUseVehicles
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 2, true) --CanDoDrivebys
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 3, false) --CanLeaveVehicle
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 5, true) --AlwaysFight
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 12, true) --BlindFireWhenInCover
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 13, true) --Aggressive
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 20, true) --CanTauntInVehicle
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 21, true) --CanChaseTargetOnFoot
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 27, true) --PerfectAccuracy
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 41, true) --CanCommandeerVehicles
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true) --CanFightArmedPedsWhenNotArmed
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 55, true) --CanSeeUnderwaterPeds
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 58, true) --DisableFleeFromCombat

        PED.SET_PED_COMBAT_MOVEMENT(ped, 1) --Defensive
        PED.SET_PED_COMBAT_ABILITY(ped, 2) --Professional
        PED.SET_PED_COMBAT_RANGE(ped, 2) --Far
        PED.SET_PED_TARGET_LOSS_RESPONSE(ped, 1) --NeverLoseTarget

        PED.SET_COMBAT_FLOAT(ped, 10, 500.0)
        PED.SET_PED_CAN_BE_SHOT_IN_VEHICLE(ped, false)
        --health
        PED.SET_PED_MAX_HEALTH(ped, 1000)
        ENTITY.SET_ENTITY_HEALTH(ped, 1000)
        ENTITY.SET_ENTITY_INVINCIBLE(ped, bodyguard_heli.ped_godmode)

        Relationship:friendly(ped)
        table.insert(heli_ped_list, ped)
    end

    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(heli_hash)
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(ped_hash)
end)

menu.divider(Bodyguard_Heli_options, "管理保镖直升机")
menu.toggle(Bodyguard_Heli_options, "所有保镖直升机无敌", {}, "", function(toggle)
    for k, ent in pairs(heli_ped_list) do
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            ENTITY.SET_ENTITY_INVINCIBLE(ent, toggle)
        end
    end
    for k, ent in pairs(heli_list) do
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            ENTITY.SET_ENTITY_INVINCIBLE(ent, toggle)
        end
    end
end)
menu.action(Bodyguard_Heli_options, "所有保镖直升机传送到我", {}, "", function()
    for k, ent in pairs(heli_list) do
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            TP_TO_ME(ent, math.random(-10, 10), math.random(-10, 10), 30)
        end
    end
end)
menu.action(Bodyguard_Heli_options, "删除所有保镖直升机", {}, "", function()
    for k, ent in pairs(heli_ped_list) do
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            entities.delete_by_handle(ent)
        end
    end
    for k, ent in pairs(heli_list) do
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            entities.delete_by_handle(ent)
        end
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
    FIRE.STOP_ENTITY_FIRE(PLAYER.PLAYER_PED_ID())
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
        if index == 1 then
            cut_global_base = 1973321 + 823 + 56
        elseif index == 2 then
            cut_global_base = 1966534 + 2325
        elseif index == 3 then
            cut_global_base = 1962546 + 812 + 50
        end
        --util.toast(cut_global_base)
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
local Casion_Heist = menu.list(Mission_options, "赌场抢劫", {}, "")

menu.divider(Casion_Heist, "第二面板")
local Casion_Heist_Custom = menu.list(Casion_Heist, "自定义可选任务", {}, "")

local bitset0 = 0
local bitset0_temp = 0
local Casion_Heist_Custom_ListItem = {
    { "toggle", "巡逻路线", 2, "" },
    { "toggle", "杜根货物", 4, "是否会显示对钩而已" },
    { "toggle", "电钻", 16, "" },
    { "toggle", "枪手诱饵", 64, "" },
    { "toggle", "更换载具", 128, "" },
    { "divider", "隐迹潜踪" },
    { "toggle", "潜入套装", 8, "" },
    { "toggle", "电磁脉冲设备", 32, "" },
    { "divider", "兵不厌诈" },
    { "toggle", "进场：除虫大师", 256 + 512, "" },
    { "toggle", "进场：维修工", 1024 + 2048, "" },
    { "toggle", "进场：古倍科技", 4096 + 8192, "" },
    { "toggle", "进场：名人", 16384 + 32768, "" },
    { "toggle", "离场：国安局", 65536, "" },
    { "toggle", "离场：消防员", 131072, "" },
    { "toggle", "离场：豪赌客", 262144, "" },
    { "divider", "气势汹汹" },
    { "toggle", "加固防弹衣", 1048576, "" },
    { "toggle", "镗床", 2621440, "" }
}

for k, data in pairs(Casion_Heist_Custom_ListItem) do
    if data[1] == "toggle" then
        menu.toggle(Casion_Heist_Custom, data[2], {}, data[4], function(toggle)
            if toggle then
                bitset0_temp = bitset0_temp + data[3]
            else
                bitset0_temp = bitset0_temp - data[3]
            end
        end)
    else
        menu.divider(Casion_Heist_Custom, data[2])
    end
end
menu.divider(Casion_Heist_Custom, "")
menu.action(Casion_Heist_Custom, "添加到 BITSET0", {}, "", function()
    bitset0 = bitset0_temp
    util.toast("当前值为: " .. bitset0)
end)

menu.divider(Casion_Heist, "BITSET0 设置")
menu.action(Casion_Heist, "读取当前 BITSET0 值", {}, "", function()
    util.toast(bitset0)
end)
menu.slider(Casion_Heist, "自定义 BITSET0 值", { "bitset0" }, "", 0, 16777216, 0, 1, function(value)
    bitset0 = value
    util.toast("已修改为: " .. bitset0)
end)
menu.divider(Casion_Heist, "")
menu.action(Casion_Heist, "写入 BITSET0 值", {}, "写入到 H3OPT_BITSET0", function()
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
menu.click_slider(Team_Lives, "修改生命数", { "tlive_perico" }, "fm_mission_controller_2020", -1, 30000, 0, 1,
    function(value)
        team_live_cayo = value
        if SCRIPT.HAS_SCRIPT_LOADED("fm_mission_controller_2020") then
            SET_INT_LOCAL("fm_mission_controller_2020", 44664 + 865 + 1, team_live_cayo)
        else
            util.toast("This Script Has Not Loaded")
        end
    end)

menu.divider(Team_Lives, "赌场抢劫&联系人差事")
menu.action(Team_Lives, "获取当前生命数", {}, "", function()
    if SCRIPT.HAS_SCRIPT_LOADED("fm_mission_controller") then
        local value = GET_INT_LOCAL("fm_mission_controller", 26105 + 1322 + 1)
        util.toast(value)
    else
        util.toast("This Script Has Not Loaded")
    end
end)

local team_live_casino = 0
menu.click_slider(Team_Lives, "修改生命数", { "tlive_casino" }, "fm_mission_controller", -1, 30000, 0, 1,
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

-- tuneables_processing.c
local Tunables_Globals = {
    Auto_Shop_Contract_Setup = 262145 + 31669, -- -425845436 (float)
    Auto_Shop_Contract_Finale = 262145 + 31670, -- -394140353 (float)
    Exotic_Export_Delivery = 262145 + 31672, -- 1870939070 (float)
    ----- VIP/CEO Work
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
        tuneable_rep_mult = Value * 0.01
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
menu.list_select(Local_Editor, "数据类型", {}, "", { { "INT" }, { "FLOAT" } }, 1, function(value)
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

menu.divider(Local_Editor, "写入")
local local_write = 0
menu.text_input(Local_Editor, "要写入的值", { "local_write" }, "务必注意int类型和float类型的格式",
    function(value)
        local_write = value
    end)
menu.action(Local_Editor, "写入 Local", {}, "", function()
    if local_address > 0 and tonumber(local_write) ~= nil then
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
    if local_address > 0 and tonumber(local_write) ~= nil then
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
menu.list_select(Global_Editor, "数据类型", {}, "", { { "INT" }, { "FLOAT" } }, 1,
    function(value)
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

menu.divider(Global_Editor, "写入")
local global_write = 0
menu.text_input(Global_Editor, "要写入的值", { "global_write" }, "务必注意int类型和float类型的格式",
    function(value)
        global_write = value
    end)
menu.action(Global_Editor, "写入 Global", {}, "", function()
    if global_address > 0 and tonumber(global_write) ~= nil then
        if global_type == "int" then
            SET_INT_GLOBAL(global_address, global_write)
        elseif global_type == "float" then
            SET_FLOAT_GLOBAL(global_address, global_write)
        end
    end
end)
menu.toggle_loop(Global_Editor, "锁定写入 Global", {}, "", function()
    if global_address > 0 and tonumber(global_write) ~= nil then
        if global_type == "int" then
            SET_INT_GLOBAL(global_address, global_write)
        elseif global_type == "float" then
            SET_FLOAT_GLOBAL(global_address, global_write)
        end
    end
end)

--- Stat Editor ---
local Stat_Editor = menu.list(Mission_options, "Stat Editor", {}, "")
-----
local Stat_Playtime = menu.list(Stat_Editor, "游玩时间", {}, "")

local Stat_Playtime_ListItem_Method = {
    { "覆盖", {}, "会将时间修改成所设置的时间\n最大24.8天" },
    { "增加", {}, "会在当前时间的基础上增加设置的时间\n最大50000天" }
}
local Stat_Playtime_Method = menu.list_select(Stat_Playtime, "选择方式", {}, "", Stat_Playtime_ListItem_Method, 1,
    function() end)
menu.divider(Stat_Playtime, "设置时间")
local Stat_Playtime_Year = menu.slider(Stat_Playtime, "年", { "stat_playtime_year" }, "", 0, 100, 0, 1, function() end)
local Stat_Playtime_Day = menu.slider(Stat_Playtime, "天", { "stat_playtime_day" }, "", 0, 50000, 0, 1, function() end)
local Stat_Playtime_Hour = menu.slider(Stat_Playtime, "小时", { "stat_playtime_hour" }, "", 0, 50000, 0, 1,
    function() end)
local Stat_Playtime_Min = menu.slider(Stat_Playtime, "分钟", { "stat_playtime_min" }, "", 0, 50000, 0, 1,
    function() end)

menu.divider(Stat_Playtime, "")
local Stat_Playtime_ListItem_Stat = {
    { "GTA在线模式中花费的时间", {}, "MP_PLAYING_TIME" },
    { "以第一人称视角进行游戏的时间", {}, "MP_FIRST_PERSON_CAM_TIME" },
    { "第三人称视角游戏时间", {}, "TOTAL_PLAYING_TIME" },
    { "死斗游戏中花费的时间", {}, "MPPLY_TOTAL_TIME_SPENT_DEATHMAT" },
    { "竞速中花费的时间", {}, "MPPLY_TOTAL_TIME_SPENT_RACES" },
    { "制作器中花费的时间", {}, "MPPLY_TOTAL_TIME_MISSION_CREATO" },
    { "持续时间最长单人战局", {}, "LONGEST_PLAYING_TIME" },
    { "每场战局平均用时", {}, "AVERAGE_TIME_PER_SESSON" },
    { "游泳时间", {}, "TIME_SWIMMING" },
    { "潜水时间", {}, "TIME_UNDERWATER" },
    { "步行时间", {}, "TIME_WALKING" },
    { "掩体躲藏时间", {}, "TIME_IN_COVER" },
    { "摩托车骑行时间", {}, "TIME_DRIVING_BIKE" },
    { "直升机飞行时间", {}, "TIME_DRIVING_HELI" },
    { "飞机飞行时间", {}, "TIME_DRIVING_PLANE" },
    { "船只航行时间", {}, "TIME_DRIVING_BOAT" },
    { "沙滩车驾驶时间", {}, "TIME_DRIVING_QUADBIKE" },
    { "自行车骑行时间", {}, "TIME_DRIVING_BICYCLE" },
    { "被通缉持续时间", {}, "TOTAL_CHASE_TIME" },
    { "上一次通缉等级持续时间", {}, "LAST_CHASE_TIME" },
    { "最长通缉等级持续时间", {}, "LONGEST_CHASE_TIME" },
    { "五星通缉等级持续时间", {}, "TOTAL_TIME_MAX_STARS" }
}
local Stat_Playtime_Select = menu.list_select(Stat_Playtime, "Stat", {}, "", Stat_Playtime_ListItem_Stat, 1,
    function() end)
menu.action(Stat_Playtime, "设置", {}, "", function()
    local stat = Stat_Playtime_ListItem_Stat[menu.get_value(Stat_Playtime_Select)][3]
    local year = menu.get_value(Stat_Playtime_Year) * 365 * 24 * 60 * 60 * 1000
    local day = menu.get_value(Stat_Playtime_Day) * 24 * 60 * 60 * 1000
    local hour = menu.get_value(Stat_Playtime_Hour) * 60 * 60 * 1000
    local min = menu.get_value(Stat_Playtime_Min) * 60 * 1000

    if menu.get_value(Stat_Playtime_Method) == 1 then
        STAT_SET_INT(stat, year + day + hour + min)
    else
        STAT_SET_INCREMENT(stat, year + day + hour + min)
    end

    util.toast("设置完成!\n请等待云保存完成!")
    menu.trigger_commands("forcecloudsave")
end)
menu.action(Stat_Playtime, "读取", {}, "", function()
    local stat = Stat_Playtime_ListItem_Stat[menu.get_value(Stat_Playtime_Select)][3]
    local value = STAT_GET_INT(stat)
    util.toast(value)
end)

-----
local Stat_Date = menu.list(Stat_Editor, "日期", {}, "")

menu.divider(Stat_Date, "设置日期")
local Stat_Date_Year = menu.slider(Stat_Date, "年", { "stat_date_year" }, "", 2013, os.date("%Y"), 2013, 1,
    function() end)
local Stat_Date_Month = menu.slider(Stat_Date, "月", { "stat_date_month" }, "", 1, 12, 1, 1, function() end)
local Stat_Date_Day = menu.slider(Stat_Date, "日", { "stat_date_day" }, "", 1, 31, 1, 1, function() end)
local Stat_Date_Hour = menu.slider(Stat_Date, "时", { "stat_date_hour" }, "", 0, 24, 0, 1, function() end)
local Stat_Date_Min = menu.slider(Stat_Date, "分", { "stat_date_min" }, "", 0, 60, 0, 1, function() end)

menu.divider(Stat_Date, "")
local Stat_Date_ListItem_Stat = {
    { "制作的角色时间", {}, "CHAR_DATE_CREATED" },
    { "最后一次升级时间", {}, "CHAR_DATE_RANKUP" },
}
local Stat_Date_Select = menu.list_select(Stat_Date, "Stat", {}, "", Stat_Date_ListItem_Stat, 1, function() end)
menu.action(Stat_Date, "设置", {}, "", function()
    local stat = Stat_Date_ListItem_Stat[menu.get_value(Stat_Date_Select)][3]
    local year = menu.get_value(Stat_Date_Year)
    local month = menu.get_value(Stat_Date_Month)
    local day = menu.get_value(Stat_Date_Day)
    local hour = menu.get_value(Stat_Date_Hour)
    local min = menu.get_value(Stat_Date_Min)
    STAT_SET_DATE(stat, year, month, day, hour, min)
    util.toast("设置完成!\n请等待云保存完成!")
    menu.trigger_commands("forcecloudsave")
end)
menu.action(Stat_Date, "读取", {}, "", function()
    local stat = Stat_Date_ListItem_Stat[menu.get_value(Stat_Date_Select)][3]
    util.toast(STAT_GET_DATE(stat, "Year") ..
        "年" ..
        STAT_GET_DATE(stat, "Month") ..
        "月" .. STAT_GET_DATE(stat, "Day") .. "日" .. STAT_GET_DATE(stat, "Hour") ..
        "时" .. STAT_GET_DATE(stat, "Min") .. "分")
end)

-----
local Stat_Skill = menu.list(Stat_Editor, "属性技能", {}, "")

local Stat_Skill_ListItem_Stat = {
    { "体力", {}, "SCRIPT_INCREASE_STAM" },
    { "射击", {}, "SCRIPT_INCREASE_SHO" },
    { "力量", {}, "SCRIPT_INCREASE_STRN" },
    { "潜行", {}, "SCRIPT_INCREASE_STL" },
    { "飞行", {}, "SCRIPT_INCREASE_FLY" },
    { "驾驶", {}, "SCRIPT_INCREASE_DRIV" },
    { "肺活量", {}, "SCRIPT_INCREASE_LUNG" }
}
local Stat_Skill_Select = menu.list_select(Stat_Skill, "技能", {}, "", Stat_Skill_ListItem_Stat, 1, function() end)
menu.action(Stat_Skill, "读取", {}, "", function()
    local stat = Stat_Skill_ListItem_Stat[menu.get_value(Stat_Skill_Select)][3]
    util.toast(STAT_GET_INT(stat))
end)
menu.divider(Stat_Skill, "")
local Stat_Skill_INT = menu.slider(Stat_Skill, "值", { "stat_skill_int" }, "", 0, 100, 100, 1, function() end)
menu.action(Stat_Skill, "设置", {}, "", function()
    local stat = Stat_Skill_ListItem_Stat[menu.get_value(Stat_Skill_Select)][3]
    STAT_SET_INT(stat, menu.get_value(Stat_Skill_INT))
    util.toast("设置完成!\n请等待云保存完成!")
    menu.trigger_commands("forcecloudsave")
end)


------ 任务助手 ------
local Mission_Assistant = menu.list(Mission_options, "任务助手", {}, "")

--- 附近街道 ---
local Mission_Assistant_Nearby_Road = menu.list(Mission_Assistant, "附近街道", {}, "")

menu.divider(Mission_Assistant_Nearby_Road, "生成载具")
local mission_assistant_neayby_road_toggle = true
menu.toggle(Mission_Assistant_Nearby_Road, "生成载具为无敌", {}, "", function(toggle)
    mission_assistant_neayby_road_toggle = toggle
end, true)


local Nearby_Road_ListItem = {
    --name, model, help_text
    { "警车", "police3", "可用于越狱警察局任务" },
    { "坦克", "khanjali", "可汗贾利" },
    { "骷髅马", "kuruma2", "" },
    { "直升机", "polmav", "警用直升机" },
    { "子弹", "bullet", "大街上随处可见的超级跑车" },
    { "摩托车", "bati", "801" },
}
for k, data in pairs(Nearby_Road_ListItem) do
    local name = "生成" .. data[1]
    local model = data[2]
    menu.action(Mission_Assistant_Nearby_Road, name, {}, data[3], function()
        local hash = util.joaat(model)
        local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        local bool, coords, heading = Get_Closest_Vehicle_Node(pos, 0)
        if bool then
            local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, heading)
            if vehicle then
                Upgrade_Vehicle(vehicle)
                ENTITY.SET_ENTITY_INVINCIBLE(vehicle, mission_assistant_neayby_road_toggle)
                util.toast("Done!")
                SHOW_BLIP_TIMER(vehicle, 225, 27, 5000)
            end
        end
    end)
end


--- 公寓抢劫 ---
menu.divider(Mission_Assistant, "公寓抢劫")

local Mission_Assistant_Prison = menu.list(Mission_Assistant, "越狱", {}, "")
menu.action(Mission_Assistant_Prison, "飞机：目的地 生成坦克", {}, "", function()
    local coords = {
        x = 2183.927, y = 4759.426, z = 41.676
    }
    local heading = 73.373
    local hash = util.joaat("khanjali")
    local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, heading)
    if vehicle then
        Upgrade_Vehicle(vehicle)
        ENTITY.SET_ENTITY_INVINCIBLE(vehicle, true)
        util.toast("Done!")
    end
end)
menu.action(Mission_Assistant_Prison, "终章：监狱内 生成骷髅马", {}, "", function()
    local coords = {
        x = 1722.397, y = 2514.426, z = 45.305
    }
    local heading = 116.175
    local hash = util.joaat("kuruma2")
    local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, heading)
    if vehicle then
        Upgrade_Vehicle(vehicle)
        ENTITY.SET_ENTITY_INVINCIBLE(vehicle, true)
        util.toast("Done!")
    end
end)
menu.action(Mission_Assistant_Prison, "终章：美杜莎 无敌", {}, "\nModel Hash: 1077420264", function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, 1077420264)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            if RequestControl(ent) then
                ENTITY.SET_ENTITY_INVINCIBLE(ent, true)
                util.toast("Done!")
            end
        end
    end
end)
menu.action(Mission_Assistant_Prison, "终章：秃鹰直升机 无敌", {}, "\nModel Hash: 788747387", function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, 788747387)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            if RequestControl(ent) then
                ENTITY.SET_ENTITY_INVINCIBLE(ent, true)
                util.toast("Done!")
            end
        end
    end
end)
menu.action(Mission_Assistant_Prison, "终章：敌对天煞 传送到海洋并冻结", {}, "\nModel Hash: -1281684762",
    function()
        local coords = {
            x = 4912, y = -4910, z = 20
        }
        local entity_list = GetEntity_ByModelHash("vehicle", true, -1281684762)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                if RequestControl(ent) then
                    ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
                    ENTITY.FREEZE_ENTITY_POSITION(ent, true)
                    util.toast("Done!")
                end
            end
        end
    end)
-- Model Name: ig_rashcosvki
menu.action(Mission_Assistant_Prison, "终章：光头 无敌强化", {}, "\nModel Hash: 940330470", function()
    local entity_list = GetEntity_ByModelHash("ped", true, 940330470)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            if RequestControl(ent) then
                local weaponHash = util.joaat("WEAPON_APPISTOL")
                WEAPON.GIVE_WEAPON_TO_PED(ent, weaponHash, -1, false, true)
                WEAPON.SET_CURRENT_PED_WEAPON(ent, weaponHash, false)
                control_ped_enhanced(ent)
                util.toast("Done!")
            end
        end
    end
end)
menu.action(Mission_Assistant_Prison, "终章：光头 传送到我后面", {}, "\nModel Hash: 940330470", function()
    local entity_list = GetEntity_ByModelHash("ped", true, 940330470)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            if RequestControl(ent) then
                TP_TO_ME(ent, 0.0, -2.0, 0.0)
                util.toast("Done!")
            end
        end
    end
end)
menu.action(Mission_Assistant_Prison, "终章：光头 传送到我的载具", {}, "\nModel Hash: 940330470",
    function()
        local entity_list = GetEntity_ByModelHash("ped", true, 940330470)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                if RequestControl(ent) then
                    local vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
                    if vehicle then
                        if VEHICLE.ARE_ANY_VEHICLE_SEATS_FREE(vehicle) then
                            PED.SET_PED_INTO_VEHICLE(ent, vehicle, -2)
                            util.toast("Done!")
                        end
                    end
                end
            end
        end
    end)

local Mission_Assistant_Huamane = menu.list(Mission_Assistant, "突袭人道实验室", {}, "")
menu.action(Mission_Assistant_Huamane, "关键密码：目的地 生成坦克", {}, "", function()
    local coords = {
        x = 142.122, y = -1061.271, z = 29.746
    }
    local head = 69.686
    local hash = util.joaat("khanjali")
    local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, head)
    if vehicle then
        Upgrade_Vehicle(vehicle)
        ENTITY.SET_ENTITY_INVINCIBLE(vehicle, true)
        util.toast("Done!")
    end
end)
menu.action(Mission_Assistant_Huamane, "电磁装置：九头蛇 无敌", {}, "\nModel Hash: 970385471", function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, 970385471)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            if RequestControl(ent) then
                ENTITY.SET_ENTITY_INVINCIBLE(ent, true)
                util.toast("Done!")
            end
        end
    end
end)
menu.action(Mission_Assistant_Huamane, "运送电磁装置：叛乱分子 传送到目的地", {},
    "\nModel Hash: 2071877360",
    function()
        local coords = {
            x = 3339.7307, y = 3670.7246, z = 43.8973
        }
        local head = 312.5133
        local entity_list = GetEntity_ByModelHash("vehicle", true, 2071877360)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                local blip = HUD.GET_BLIP_FROM_ENTITY(ent)
                if blip > 0 then
                    if RequestControl(ent) then
                        ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
                        ENTITY.SET_ENTITY_HEADING(ent, head)
                        util.toast("Done!")
                    end
                end
            end
        end
    end)
menu.action(Mission_Assistant_Huamane, "终章：女武神 无敌", {}, "\nModel Hash: -1600252419", function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, -1600252419)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            if RequestControl(ent) then
                ENTITY.SET_ENTITY_INVINCIBLE(ent, true)
                util.toast("Done!")
            end
        end
    end
end)

local Mission_Assistant_Series = menu.list(Mission_Assistant, "首轮募资", {}, "")
menu.action(Mission_Assistant_Series, "可卡因：直升机 无敌", {}, "\nModel Hash: 744705981", function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, 744705981)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            if RequestControl(ent) then
                ENTITY.SET_ENTITY_INVINCIBLE(ent, true)
                util.toast("Done!")
            end
        end
    end
end)
menu.action(Mission_Assistant_Series, "窃取冰毒：油罐车 无敌", {}, "\nModel Hash: 1956216962", function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, 1956216962)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            if RequestControl(ent) then
                ENTITY.SET_ENTITY_INVINCIBLE(ent, true)
                util.toast("Done!")
            end
        end
    end
end)
menu.action(Mission_Assistant_Series, "窃取冰毒：油罐车位置 生成尖锥魅影", {}, "", function()
    local coords = {
        x = 2416.0986, y = 5012.4545, z = 46.6019
    }
    local heading = 132.7993
    local hash = util.joaat("phantom2")
    local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, heading)
    if vehicle then
        Upgrade_Vehicle(vehicle)
        ENTITY.SET_ENTITY_INVINCIBLE(vehicle, true)
        util.toast("Done!")
    end
end)

local Mission_Assistant_Pacific = menu.list(Mission_Assistant, "太平洋标准银行", {}, "")
menu.action(Mission_Assistant_Pacific, "厢型车：司机 传送到海洋并冻结", {}, "\nModel Hash: 444171386",
    function()
        local coords = {
            x = 4912, y = -4910, z = 20
        }
        local entity_list = GetEntity_ByModelHash("vehicle", true, 444171386)
        if next(entity_list) ~= nil then
            local i = 0
            for k, ent in pairs(entity_list) do
                local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ent, -1)
                if ped and not IS_PED_PLAYER(ped) then
                    if RequestControl(ped) then
                        TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                        ENTITY.SET_ENTITY_COORDS(ped, coords.x, coords.y, coords.z, true, false, false, false)
                        ENTITY.FREEZE_ENTITY_POSITION(ped, true)
                        coords.x = coords.x + 3
                        coords.y = coords.y + 3
                        i = i + 1
                    end
                end
            end
            util.toast("Done!\nNumber: " .. i)
        end
    end)
menu.action(Mission_Assistant_Pacific, "厢型车：传送到目的地", {}, "传送司机到海洋，车传送到莱斯特工厂\nModel Hash: 444171386"
    , function()
    local coords = {
        x = 4912, y = -4910, z = 20
    }
    local coords2 = {
        x = 760, y = -983, z = 26
    }
    local head = 93.6973
    local entity_list = GetEntity_ByModelHash("vehicle", true, 444171386)
    if next(entity_list) ~= nil then
        local i = 0
        for k, ent in pairs(entity_list) do
            local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ent, -1)
            if ped and not IS_PED_PLAYER(ped) then
                if RequestControl(ped) then
                    TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                    ENTITY.SET_ENTITY_COORDS(ped, coords.x, coords.y, coords.z, true, false, false, false)
                    ENTITY.FREEZE_ENTITY_POSITION(ped, true)
                    coords.x = coords.x + 3
                end
            end
            if RequestControl(ent) then
                ENTITY.SET_ENTITY_COORDS(ent, coords2.x, coords2.y, coords2.z, true, false, false, false)
                ENTITY.SET_ENTITY_HEADING(ent, head)
                coords2.y = coords2.y + 3.5
                i = i + 1
            end
        end
        util.toast("Done!\nNumber: " .. i)
    end
end)
menu.action(Mission_Assistant_Pacific, "信号：岛上 生成直升机", {}, "撤离时", function()
    local coords = {
        x = -2188.197, y = 5128.990, z = 11.672
    }
    local head = 314.255
    local hash = util.joaat("polmav")
    local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, head)
    if vehicle then
        Upgrade_Vehicle(vehicle)
        ENTITY.SET_ENTITY_INVINCIBLE(vehicle, true)
        util.toast("Done!")
    end
end)
menu.action(Mission_Assistant_Pacific, "车队：目的地 生成坦克", {}, "", function()
    local coords = {
        x = -196.452, y = 4221.374, z = 45.376
    }
    local head = 313.298
    local hash = util.joaat("khanjali")
    local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, head)
    if vehicle then
        Upgrade_Vehicle(vehicle)
        ENTITY.SET_ENTITY_INVINCIBLE(vehicle, true)
        util.toast("Done!")
    end
end)
menu.action(Mission_Assistant_Pacific, "车队：卡车 无敌", {}, "\nModel Hash: 630371791", function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, 630371791)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            if RequestControl(ent) then
                ENTITY.SET_ENTITY_INVINCIBLE(ent, true)
                util.toast("Done!")
            end
        end
    end
end)
menu.action(Mission_Assistant_Pacific, "摩托车：雷克卓 升级无敌", {}, "\nModel Hash: 640818791", function()
    local entity_list = GetEntity_ByModelHash("vehicle", true, 640818791)
    if next(entity_list) ~= nil then
        local i = 0
        for k, ent in pairs(entity_list) do
            if RequestControl(ent) then
                ENTITY.SET_ENTITY_INVINCIBLE(ent, true)
                Upgrade_Vehicle(ent)
                i = i + 1
            end
        end
        util.toast("Done!\nNumber: " .. i)
    end
end)
menu.action(Mission_Assistant_Pacific, "终章：摩托车位置 生成骷髅马", {}, "", function()
    local coords = {
        x = 36.002, y = 94.153, z = 78.751
    }
    local head = 249.426
    local hash = util.joaat("kuruma2")
    local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, head)
    if vehicle then
        Upgrade_Vehicle(vehicle)
        ENTITY.SET_ENTITY_INVINCIBLE(vehicle, true)
        util.toast("Done!")
    end
end)
menu.action(Mission_Assistant_Pacific, "终章：摩托车位置 生成直升机", {}, "", function()
    local coords = {
        x = 52.549, y = 88.787, z = 78.683
    }
    local head = 15.508
    local hash = util.joaat("polmav")
    local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, head)
    if vehicle then
        Upgrade_Vehicle(vehicle)
        ENTITY.SET_ENTITY_INVINCIBLE(vehicle, true)
        util.toast("Done!")
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
menu.action(Other_options_Developer, "GET_NETWORK_TIME", {}, "", function()
    util.toast(NETWORK.GET_NETWORK_TIME())
end)
menu.action(Other_options_Developer, "GET_MAX_RANGE_OF_CURRENT_PED_WEAPON", {}, "", function()
    util.toast(WEAPON.GET_MAX_RANGE_OF_CURRENT_PED_WEAPON(players.user_ped()))
end)
menu.action(Other_options_Developer, "Clear Player Ped Tasks", { "clsped" }, "", function()
    local ped = players.user_ped()
    TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
    TASK.CLEAR_PED_TASKS(ped)
    TASK.CLEAR_DEFAULT_PRIMARY_TASK(ped)
    TASK.CLEAR_PED_SECONDARY_TASK(ped)
    TASK.TASK_CLEAR_LOOK_AT(ped)
    TASK.TASK_CLEAR_DEFENSIVE_AREA(ped)
    TASK.CLEAR_DRIVEBY_TASK_UNDERNEATH_DRIVING_TASK(ped)
end)
menu.slider_text(Other_options_Developer, "设置周围物体可碰撞", {}, "", { "Object", "Pickup" },
    function(value)
        local entity_list = {}
        if value == 1 then
            entity_list = entities.get_all_objects_as_handles()
        elseif value == 2 then
            entity_list = entities.get_all_pickups_as_handles()
        end
        for k, ent in pairs(entity_list) do
            ENTITY.SET_ENTITY_COLLISION(ent, true, true)
            ENTITY.ENABLE_ENTITY_BULLET_COLLISION(ent)
        end
        util.toast("Done!")
    end)



------------------
--- 零食护甲编辑 ---
------------------
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

--------------------
----- 标记点选项 -----
--------------------
local Other_options_Waypoint = menu.list(Other_options, "标记点选项", {}, "")

local waypoint_blip_sprite = 8
menu.slider_text(Other_options_Waypoint, "标记点类型", {}, "点击应用修改\n只作用于第一个标记的大头针位置"
    , { "标记点位置", "大头针位置" }, function(value)
    if value == 1 then
        waypoint_blip_sprite = 8
    elseif value == 2 then
        waypoint_blip_sprite = 162
    end
end)

menu.toggle(Other_options_Waypoint, "在小地图上显示标记点", {}, "", function(toggle)
    local blip = HUD.GET_FIRST_BLIP_INFO_ID(waypoint_blip_sprite)
    if blip > 0 then
        if toggle then
            HUD.SET_BLIP_DISPLAY(blip, 2)
        else
            HUD.SET_BLIP_DISPLAY(blip, 3)
        end
    end
end)
menu.toggle(Other_options_Waypoint, "闪烁标记点", {}, "", function(toggle)
    local blip = HUD.GET_FIRST_BLIP_INFO_ID(waypoint_blip_sprite)
    if blip > 0 then
        HUD.SET_BLIP_FLASHES(blip, toggle)
    end
end)
menu.action(Other_options_Waypoint, "通知坐标", {}, "", function()
    local blip = HUD.GET_FIRST_BLIP_INFO_ID(waypoint_blip_sprite)
    if blip == 0 then
        util.toast("No Waypoint Found")
    else
        local pos = GET_BLIP_COORDS(blip)
        if pos ~= nil then
            local text = pos.x .. ", " .. pos.y .. ", " .. pos.z
            util.toast(text)
        end
    end
end)

menu.divider(Other_options_Waypoint, "在标记点位置")

local Waypoint_CreateVehicle = menu.list(Other_options_Waypoint, "生成载具", {}, "")
local Waypoint_Vehicle_ListItem = {
    --name, model, help_text
    { "警车", "police3", "" },
    { "坦克", "khanjali", "可汗贾利" },
    { "骷髅马", "kuruma2", "" },
    { "直升机", "polmav", "警用直升机" },
    { "摩托车", "bati", "801" },
}
for k, data in pairs(Waypoint_Vehicle_ListItem) do
    local name = "生成" .. data[1]
    menu.action(Waypoint_CreateVehicle, name, {}, data[3], function()
        local blip = HUD.GET_FIRST_BLIP_INFO_ID(waypoint_blip_sprite)
        if blip == 0 then
            util.toast("No Waypoint Found")
        else
            local pos = GET_BLIP_COORDS(blip)
            if pos ~= nil then
                local hash = util.joaat(data[2])
                local vehicle = Create_Network_Vehicle(hash, pos.x, pos.y, pos.z + 1.0, 0)
                if vehicle then
                    Upgrade_Vehicle(vehicle)
                    ENTITY.SET_ENTITY_INVINCIBLE(vehicle, true)
                    util.toast("Done!")
                end
            end
        end
    end)
end

local Waypoint_CreatePickup = menu.list(Other_options_Waypoint, "生成拾取物", {}, "")
local Waypoint_Pickup_ListItem = {
    --name, model, pickupHash, value
    { "医药包", "prop_ld_health_pack", 2406513688, 100 },
    { "护甲", "prop_armour_pickup", 1274757841, 100 },
    { "火神机枪", "W_MG_Minigun", 792114228, 100 },
}
for k, data in pairs(Waypoint_Pickup_ListItem) do
    local name = "生成" .. data[1]
    menu.action(Waypoint_CreatePickup, name, {}, "", function()
        local blip = HUD.GET_FIRST_BLIP_INFO_ID(waypoint_blip_sprite)
        if blip == 0 then
            util.toast("No Waypoint Found")
        else
            local pos = GET_BLIP_COORDS(blip)
            if pos ~= nil then
                local modelHash = util.joaat(data[2])
                local pickupHash = data[3]
                Create_Network_Pickup(pickupHash, pos.x, pos.y, pos.z, modelHash, data[4])
                util.toast("Done!")
            end
        end
    end)
end

local Waypoint_Explosion = menu.list(Other_options_Waypoint, "爆炸", {}, "")
local waypoint_explosion_type = 2
menu.slider(Waypoint_Explosion, "爆炸类型", { "waypoint_explosion_type" }, "", -1, 83, 2, 1, function(value)
    waypoint_explosion_type = value
end)
menu.action(Waypoint_Explosion, "爆炸", {}, "", function()
    local blip = HUD.GET_FIRST_BLIP_INFO_ID(waypoint_blip_sprite)
    if blip == 0 then
        util.toast("No Waypoint Found")
    else
        local pos = GET_BLIP_COORDS(blip)
        if pos ~= nil then
            FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, waypoint_explosion_type, 1000, true, false, 0.0, false)
        end
    end
end)

menu.action(Waypoint_Explosion, "RPG轰炸", {}, "以玩家的名义轰炸", function()
    local blip = HUD.GET_FIRST_BLIP_INFO_ID(waypoint_blip_sprite)
    if blip == 0 then
        util.toast("No Waypoint Found")
    else
        local pos = GET_BLIP_COORDS(blip)
        if pos ~= nil then
            local weaponHash = util.joaat("WEAPON_RPG")
            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z + 10.0, pos.x, pos.y, pos.z, 1000, false,
                weaponHash, players.user_ped(), true, false, 1000)
        end
    end
end)

-------------------
----- 请求服务 -----
-------------------
local Request_Service_options = menu.list(Other_options, "请求服务", {}, "")

menu.action(Request_Service_options, "请求重型装甲", { "ammo_drop" }, "请求弹道装甲和火神机枪",
    function()
        SET_INT_GLOBAL(2815059 + 884, 1)
    end)
menu.action(Request_Service_options, "重型装甲包裹 传送到我", {}, "\nModel Hash: 1688540826", function()
    local entity_model_hash = 1688540826
    for k, ent in pairs(entities.get_all_pickups_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 2.0, 0.0)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
        end
    end
end)
menu.toggle(Request_Service_options, "请求RC坦克", {}, "", function(toggle)
    if toggle then
        SET_INT_GLOBAL(2815059 + 6752, 1)
    else
        SET_INT_GLOBAL(2815059 + 6752, 0)
    end
end)
menu.toggle(Request_Service_options, "请求RC匪徒", {}, "", function(toggle)
    if toggle then
        SET_INT_GLOBAL(2815059 + 6751, 1)
    else
        SET_INT_GLOBAL(2815059 + 6751, 0)
    end
end)

menu.divider(Request_Service_options, "无视犯罪")
menu.toggle_loop(Request_Service_options, "锁定倒计时", {}, "无视犯罪的倒计时", function()
    SET_INT_GLOBAL(2815059 + 4627, NETWORK.GET_NETWORK_TIME())
    util.yield(5000)
end)
menu.action(Request_Service_options, "警察无视犯罪", { "no_cops" }, "莱斯特电话请求", function()
    SET_INT_GLOBAL(2815059 + 4624, 5)
    SET_INT_GLOBAL(2815059 + 4625, 1)
    SET_INT_GLOBAL(2815059 + 4627, NETWORK.GET_NETWORK_TIME())
end)
menu.click_slider(Request_Service_options, "贿赂当局 倒计时时间", {}, "单位:分钟", 1, 60, 2, 1,
    function(value)
        SET_INT_GLOBAL(262145 + 13147, value * 60 * 1000)
        util.toast("Done!")
    end)
menu.toggle(Request_Service_options, "贿赂当局", {}, "CEO技能", function(toggle)
    if toggle then
        SET_INT_GLOBAL(2815059 + 4624, 81)
        SET_INT_GLOBAL(2815059 + 4625, 1)
        SET_INT_GLOBAL(2815059 + 4627, NETWORK.GET_NETWORK_TIME())
    else
        SET_INT_GLOBAL(2815059 + 4627, 0)
    end
end)

menu.divider(Request_Service_options, "幽灵组织")
menu.click_slider(Request_Service_options, "倒计时时间", {}, "单位:分钟", 1, 60, 3, 1,
    function(value)
        SET_INT_GLOBAL(262145 + 13146, value * 60 * 1000)
        util.toast("Done!")
    end)
menu.action(Request_Service_options, "幽灵组织", { "ghost_orz" }, "CEO技能\n~Not Working~", function()
    local Var0 = GET_INT_GLOBAL(1892703 + 1 + PLAYER.PLAYER_ID() * 599 + 10)
    SET_INT_GLOBAL(2689235 + 1 + Var0 * 453 + 208, 1)
end)

-------------------
----- 聊天选项 -----
-------------------
local Chat_options = menu.list(Other_options, "聊天选项", {}, "")

menu.toggle_loop(Chat_options, "打字时禁用来电电话", {}, "避免在打字时有电话把输入框挤掉",
    function()
        if chat.is_open() then
            menu.trigger_commands("nophonespam on")
        else
            menu.trigger_commands("nophonespam off")
        end
    end, function()
    menu.trigger_commands("nophonespam off")
end)

menu.divider(Chat_options, "记录打字输入内容")
local typing_text_list = {}
local typing_text_list_item = {}
local typing_text_now = ""
menu.toggle_loop(Chat_options, "开启", {}, "", function()
    if chat.is_open() then
        if chat.get_state() > 0 then
            typing_text_now = chat.get_draft()
        end
    else
        if typing_text_now ~= "" and not isInTable(typing_text_list, typing_text_now) then
            table.insert(typing_text_list, typing_text_now)

            local temp = newTableValue(1, typing_text_now)
            table.insert(typing_text_list_item, temp)
            typing_text_now = ""

            menu.set_list_action_options(typing_text_list_action, typing_text_list_item)
        end

    end
end)

menu.action(Chat_options, "清空记录内容", {}, "", function()
    typing_text_list = {}
    typing_text_list_item = {}
    typing_text_now = ""
    menu.set_list_action_options(typing_text_list_action, typing_text_list_item)
end)
local typing_text_send_to_team = false
menu.toggle(Chat_options, "发送到团队", {}, "", function(toggle)
    typing_text_send_to_team = toggle
end)
typing_text_list_action = menu.list_action(Chat_options, "查看记录内容", {}, "点击即可弹出输入框",
    typing_text_list_item, function(value)
    local text = typing_text_list_item[value][1]
    chat.ensure_open_with_empty_draft(typing_text_send_to_team)
    chat.add_to_draft(text)
end)


-----
menu.toggle_loop(Other_options, "跳到下一条对话", { "skip_talk" }, "快速跳过对话", function()
    if AUDIO.IS_SCRIPTED_CONVERSATION_ONGOING() then
        AUDIO.SKIP_TO_NEXT_SCRIPTED_CONVERSATION_LINE()
    end
end)
menu.action(Other_options, "停止对话", { "stop_talk" }, "", function()
    if AUDIO.IS_SCRIPTED_CONVERSATION_ONGOING() then
        AUDIO.STOP_SCRIPTED_CONVERSATION(false)
    end
end)
local simulate_left_click_delay = 50 --ms
menu.toggle_loop(Other_options, "模拟鼠标左键点击", { "left_click" }, "用于拿取目标财物时",
    function()
        PAD.SET_CONTROL_VALUE_NEXT_FRAME(0, 237, 1)
        util.yield(simulate_left_click_delay)
    end)
menu.slider(Other_options, "模拟点击延迟", { "left_click_delay" }, "单位: ms", 0, 5000, 50, 10,
    function(value)
        simulate_left_click_delay = value
    end)
menu.action(Other_options, "Clear Tick Handler", {}, "用于解决控制实体的描绘连线、显示信息、锁定传送等问题"
    , function()
    Clear_control_ent_tick_handler()
end)




---------------------------------------------------------------





------------------------------------
------------ 玩家列表选项 ------------
------------------------------------

local PlayerFunctions = function(pId)
    local Player_MainMenu = menu.list(menu.player_root(pId), "RScript", {}, "")

    -----------------------------
    ---------- 恶搞选项 ----------
    -----------------------------
    local Trolling_options = menu.list(Player_MainMenu, "恶搞选项", {}, "")

    menu.action(Trolling_options, "小笼子", {}, "", function()
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        if not PED.IS_PED_IN_ANY_VEHICLE(player_ped) then
            local modelHash = util.joaat("prop_gold_cont_01")
            local pos = ENTITY.GET_ENTITY_COORDS(player_ped)
            local obj = Create_Network_Object(modelHash, pos.x, pos.y, pos.z - 1.0)
            ENTITY.FREEZE_ENTITY_POSITION(obj, true)
        end
    end)

    menu.action(Trolling_options, "小查攻击", {}, "", function()
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        local modelHash = util.joaat("A_C_Chop")
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0.0, -1.0, 0.0)
        local heading = ENTITY.GET_ENTITY_HEADING(player_ped)

        local g_ped = Create_Network_Ped(PED_TYPE_CIVMALE, modelHash, coords.x, coords.y, coords.z, heading)

        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(g_ped, true)
        TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(g_ped, true)
        TASK.TASK_COMBAT_PED(g_ped, player_ped, 0, 16)
        PED.SET_PED_KEEP_TASK(g_ped, true)

        PED.SET_PED_MONEY(g_ped, 2000)
        ENTITY.SET_ENTITY_MAX_HEALTH(g_ped, 30000)
        ENTITY.SET_ENTITY_HEALTH(g_ped, 30000)
        PED.SET_PED_CAN_RAGDOLL(g_ped, false)

        PED.SET_PED_HIGHLY_PERCEPTIVE(g_ped, true)
        PED.SET_PED_VISUAL_FIELD_PERIPHERAL_RANGE(g_ped, 500.0)
        PED.SET_PED_SEEING_RANGE(g_ped, 500)
        PED.SET_PED_HEARING_RANGE(g_ped, 500)

        PED.SET_PED_AS_ENEMY(g_ped, true)
        PED.SET_PED_SHOOT_RATE(g_ped, 1000.0)
        PED.SET_PED_ACCURACY(g_ped, 100.0)

        PED.SET_PED_COMBAT_ATTRIBUTES(g_ped, 5, true) --AlwaysFight
        PED.SET_PED_COMBAT_ATTRIBUTES(g_ped, 13, true) --Aggressive
        PED.SET_PED_COMBAT_ATTRIBUTES(g_ped, 21, true) --CanChaseTargetOnFoot
        PED.SET_PED_COMBAT_ATTRIBUTES(g_ped, 27, true) --PerfectAccuracy
        PED.SET_PED_COMBAT_ATTRIBUTES(g_ped, 46, true) --CanFightArmedPedsWhenNotArmed
        PED.SET_PED_COMBAT_ATTRIBUTES(g_ped, 58, true) --DisableFleeFromCombat

        PED.SET_PED_COMBAT_MOVEMENT(g_ped, 2) --WillAdvance
        PED.SET_PED_COMBAT_ABILITY(g_ped, 2) --Professional
        PED.SET_PED_COMBAT_RANGE(g_ped, 2) --Far
        PED.SET_PED_TARGET_LOSS_RESPONSE(g_ped, 1) --NeverLoseTarget
        PED.SET_COMBAT_FLOAT(g_ped, 10, 500.0)
    end)

    menu.action(Trolling_options, "载具内敌人攻击", {}, "", function()
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        if PED.IS_PED_IN_ANY_VEHICLE(player_ped) then
            local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_ped, false)
            local modelHash = util.joaat("A_M_M_ACult_01")
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0.0, 0.0, 2.0)
            local heading = ENTITY.GET_ENTITY_HEADING(player_ped)

            local g_ped = Create_Network_Ped(PED_TYPE_CIVMALE, modelHash, coords.x, coords.y, coords.z, heading)
            PED.SET_PED_INTO_VEHICLE(g_ped, vehicle, -2)

            PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(g_ped, true)
            TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(g_ped, true)
            TASK.TASK_COMBAT_PED(g_ped, player_ped, 0, 16)
            PED.SET_PED_KEEP_TASK(g_ped, true)

            PED.SET_PED_MONEY(g_ped, 2000)
            ENTITY.SET_ENTITY_MAX_HEALTH(g_ped, 30000)
            ENTITY.SET_ENTITY_HEALTH(g_ped, 30000)
            PED.SET_PED_CAN_RAGDOLL(g_ped, false)

            local weaponHash = util.joaat("WEAPON_MICROSMG")
            WEAPON.GIVE_WEAPON_TO_PED(g_ped, weaponHash, -1, false, true)
            WEAPON.SET_CURRENT_PED_WEAPON(g_ped, weaponHash, true)
            WEAPON.SET_PED_INFINITE_AMMO_CLIP(g_ped, true)
            PED.SET_PED_SHOOT_RATE(g_ped, 1000)
            PED.SET_PED_ACCURACY(g_ped, 100)

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
            PED.SET_PED_COMBAT_ATTRIBUTES(g_ped, 55, true) --CanSeeUnderwaterPeds
            PED.SET_PED_COMBAT_ATTRIBUTES(g_ped, 58, true) --DisableFleeFromCombat

            PED.SET_PED_COMBAT_MOVEMENT(g_ped, 2) --WillAdvance
            PED.SET_PED_COMBAT_ABILITY(g_ped, 2) --Professional
            PED.SET_PED_COMBAT_RANGE(g_ped, 2) --Far
            PED.SET_PED_TARGET_LOSS_RESPONSE(g_ped, 1) --NeverLoseTarget
            PED.SET_COMBAT_FLOAT(g_ped, 10, 500.0)
        end
    end)


    --- 传送所有实体 ---
    local Trolling_options_AllEntities = menu.list(Trolling_options, "传送所有实体", {}, "")

    local TPtoPlayer_delay = 100 --ms
    local is_TPtoPlayer_run = false
    local is_Exclude_mission = true
    local function TP_Entities_TO_Player(entity_list, player_ped, Type)
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
                util.toast("Done!\n" .. Type .. " Number : " .. i)
                return false
            end
        end
        -- 完成传送
        util.toast("Done!\n" .. Type .. " Number : " .. i)
        is_TPtoPlayer_run = false
        return true
    end

    menu.slider(Trolling_options_AllEntities, "传送延时", { "TP_delay" }, "单位: ms", 0, 5000, 100, 100,
        function(value)
            TPtoPlayer_delay = value
        end)
    menu.toggle(Trolling_options_AllEntities, "排除任务实体", {}, "", function()
        is_Exclude_mission = value
    end, true)

    menu.action(Trolling_options_AllEntities, "传送所有 行人 到此玩家", {}, "", function()
        if is_TPtoPlayer_run then
            util.toast("上次的还未传送完成呢")
        else
            is_TPtoPlayer_run = true
            local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
            TP_Entities_TO_Player(entities.get_all_peds_as_handles(), player_ped, "Ped")
        end
    end)
    menu.action(Trolling_options_AllEntities, "传送所有 载具 到此玩家", {}, "", function()
        if is_TPtoPlayer_run then
            util.toast("上次的还未传送完成呢")
        else
            is_TPtoPlayer_run = true
            local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
            TP_Entities_TO_Player(entities.get_all_vehicles_as_handles(), player_ped, "Vehicle")
        end
    end)
    menu.action(Trolling_options_AllEntities, "传送所有 物体 到此玩家", {}, "", function()
        if is_TPtoPlayer_run then
            util.toast("上次的还未传送完成呢")
        else
            is_TPtoPlayer_run = true
            local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
            TP_Entities_TO_Player(entities.get_all_objects_as_handles(), player_ped, "Object")
        end
    end)
    menu.action(Trolling_options_AllEntities, "传送所有 拾取物 到此玩家", {}, "", function()
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


    --- 此玩家附近载具 ---
    local Trolling_options_NearbyVeh = menu.list(Trolling_options, "此玩家附近载具", {}, "")

    local Player_NearbyVeh_radius = 60.0
    menu.slider(Trolling_options_NearbyVeh, "范围半径", { "nearby_veh_radius" }, "", 0.0, 1000.0, 60.0, 10.0,
        function(value)
            Player_NearbyVeh_radius = value
        end)

    menu.toggle_loop(Trolling_options_NearbyVeh, "附近司机追赶此玩家", {}, "", function()
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        for _, vehicle in pairs(GET_NEARBY_VEHICLES(pId, Player_NearbyVeh_radius)) do
            if not VEHICLE.IS_VEHICLE_SEAT_FREE(vehicle, -1, false) then
                local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1, false)
                if not IS_PED_PLAYER(driver) and not TASK.GET_IS_TASK_ACTIVE(driver, 363) then
                    RequestControl(driver)
                    PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(driver, true)
                    TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(driver, true)
                    TASK.TASK_VEHICLE_CHASE(driver, player_ped)
                    PED.SET_PED_KEEP_TASK(driver, true)
                end
            end
        end
    end)

    local VehicleMissionType = {
        { "Cruise", {}, "巡航" },
        { "Ram", {}, "猛撞" },
        { "Block", {}, "阻挡" },
        { "GoTo", {}, "前往" },
        { "Stop", {}, "停止" },
        { "Attack", {}, "攻击" },
        { "Follow", {}, "跟随" },
        { "Flee", {}, "逃跑" },
        { "Circle", {}, "围绕" },
        { "Escort", {}, "护送，护卫" },
        { "FollowRecording", {}, "跟踪录制" },
        { "PoliceBehaviour", {}, "警察行为" },
        { "Land", {}, "降落" },
        { "Land2", {}, "降落" },
        { "Crash", {}, "碰撞" },
        { "PullOver", {}, "靠边停车" },
        { "HeliProtect", {}, "直升机保护" },
    }
    local VehicleMissionType_id = {
        1, 2, 3, 4, 5, 6, 7, 8, 9, 12, 15, 16, 19, 20, 21, 22, 23
    }
    local veh_mission_type = 6
    menu.list_select(Trolling_options_NearbyVeh, "Vehicle Mission Type", {}, "", VehicleMissionType, 6,
        function(value)
            veh_mission_type = VehicleMissionType_id[value]
        end)
    menu.toggle_loop(Trolling_options_NearbyVeh, "Task Vehicle Mission Target Player", {}, "", function()
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        for _, vehicle in pairs(GET_NEARBY_VEHICLES(pId, Player_NearbyVeh_radius)) do
            if not VEHICLE.IS_VEHICLE_SEAT_FREE(vehicle, -1, false) then
                local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1, false)
                if not IS_PED_PLAYER(driver) and TASK.GET_ACTIVE_VEHICLE_MISSION_TYPE(vehicle) ~= veh_mission_type then
                    RequestControl(driver)
                    PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(driver, true)
                    TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(driver, true)
                    TASK.TASK_VEHICLE_MISSION_PED_TARGET(driver, vehicle, player_ped, veh_mission_type, 300.0, 0, 0.0,
                        0.0, true)
                    PED.SET_PED_KEEP_TASK(driver, true)
                end
            end
        end
    end)


    --- 此玩家附近行人 ---
    local Trolling_options_NearbyPed = menu.list(Trolling_options, "此玩家附近行人", {}, "")

    local Player_NearbyPed_radius = 60.0
    menu.slider(Trolling_options_NearbyPed, "范围半径", { "nearby_ped_radius" }, "", 0.0, 1000.0, 60.0, 10.0,
        function(value)
            Player_NearbyPed_radius = value
        end)

    menu.toggle_loop(Trolling_options_NearbyPed, "附近行人逮捕此玩家", {}, "", function()
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        for _, ped in pairs(GET_NEARBY_PEDS(pId, Player_NearbyPed_radius)) do
            if not IS_PED_PLAYER(ped) and not TASK.IS_PED_RUNNING_ARREST_TASK(ped) then
                RequestControl(ped)
                PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
                TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
                TASK.TASK_ARREST_PED(ped, player_ped)
                PED.SET_PED_KEEP_TASK(ped, true)
            end
        end
    end)

    menu.divider(Trolling_options_NearbyPed, "附近行人敌对此玩家")
    local Player_NearbyPed_Combat = {
        weapon = util.joaat(weapon_model_list[1]),
        is_enhance = false,
        is_perfect = false,
        is_drop_money = false,
        health_mult = 1
    }
    menu.toggle_loop(Trolling_options_NearbyPed, "开启", {}, "", function()
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        local weapon_smoke = util.joaat("WEAPON_SMOKEGRENADE")
        for _, ped in pairs(GET_NEARBY_PEDS(pId, Player_NearbyPed_radius)) do
            if not IS_PED_PLAYER(ped) and not PED.IS_PED_IN_COMBAT(ped, player_ped) then
                RequestControl(ped)

                WEAPON.GIVE_WEAPON_TO_PED(ped, weapon_smoke, -1, false, false)
                WEAPON.GIVE_WEAPON_TO_PED(ped, Player_NearbyPed_Combat.weapon, -1, false, true)
                WEAPON.SET_CURRENT_PED_WEAPON(ped, Player_NearbyPed_Combat.weapon, false)

                local health = ENTITY.GET_ENTITY_HEALTH(ped)
                ENTITY.SET_ENTITY_HEALTH(ped, health * Player_NearbyPed_Combat.health_mult)

                PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
                TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
                TASK.TASK_COMBAT_PED(ped, player_ped, 0, 16)
                PED.SET_PED_KEEP_TASK(ped, true)
                WEAPON.SET_PED_DROPS_WEAPONS_WHEN_DEAD(ped, false)

                PED.SET_PED_FLEE_ATTRIBUTES(ped, 0, false)
                PED.SET_PED_COMBAT_ATTRIBUTES(ped, 5, true) --AlwaysFight
                PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true) --CanFightArmedPedsWhenNotArmed
                PED.SET_PED_COMBAT_ATTRIBUTES(ped, 58, true) --DisableFleeFromCombat
                --强化作战能力
                if Player_NearbyPed_Combat.is_enhance then
                    WEAPON.SET_PED_INFINITE_AMMO_CLIP(ped, true)
                    PED.SET_PED_SHOOT_RATE(ped, 1000.0)

                    PED.SET_PED_HIGHLY_PERCEPTIVE(ped, true)
                    PED.SET_PED_VISUAL_FIELD_PERIPHERAL_RANGE(ped, 500.0)
                    PED.SET_PED_SEEING_RANGE(ped, 500.0)
                    PED.SET_PED_HEARING_RANGE(ped, 500.0)

                    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 0, true) --CanUseCover
                    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 1, true) --CanUseVehicles
                    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 2, true) --CanDoDrivebys
                    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 12, true) --BlindFireWhenInCover
                    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 13, true) --Aggressive
                    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 20, true) --CanTauntInVehicle
                    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 21, true) --CanChaseTargetOnFoot
                    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 41, true) --CanCommandeerVehicles
                    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 55, true) --CanSeeUnderwaterPeds
                    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 60, true) --CanThrowSmokeGrenade

                    PED.SET_PED_COMBAT_MOVEMENT(ped, 2) --WillAdvance
                    PED.SET_PED_COMBAT_ABILITY(ped, 2) --Professional
                    PED.SET_PED_COMBAT_RANGE(ped, 2) --Far
                    PED.SET_PED_TARGET_LOSS_RESPONSE(ped, 1) --NeverLoseTarget
                end
                if Player_NearbyPed_Combat.is_perfect then
                    PED.SET_PED_ACCURACY(ped, 100.0)
                    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 27, true) --PerfectAccuracy
                end
                if Player_NearbyPed_Combat.is_drop_money then
                    PED.SET_PED_MONEY(ped, 2000)
                end

            end
        end
    end)

    menu.list_select(Trolling_options_NearbyPed, "设置武器", {}, "", weapon_name_ListItem, 1,
        function(value)
            Player_NearbyPed_Combat.weapon = util.joaat(weapon_model_list[value])
        end)
    menu.toggle(Trolling_options_NearbyPed, "强化作战能力", {}, "如果npc会逃跑的话，开启这个",
        function(toggle)
            Player_NearbyPed_Combat.is_enhance = toggle
        end)
    menu.toggle(Trolling_options_NearbyPed, "完美精准度", {}, "百发百中", function(toggle)
        Player_NearbyPed_Combat.is_perfect = toggle
    end)
    menu.slider(Trolling_options_NearbyPed, "血量加倍", { "nearbyped_health_mult" }, "", 1, 100, 1, 1,
        function(value)
            Player_NearbyPed_Combat.health_mult = value
        end)
    menu.toggle(Trolling_options_NearbyPed, "掉落现金为2000", {}, "当做击杀奖励", function(toggle)
        Player_NearbyPed_Combat.is_drop_money = toggle
    end)

    menu.toggle_loop(Trolling_options, "循环举报", { "rs_report" }, "", function()
        if pId ~= players.user() then
            local player_name = players.get_name(pId)
            menu.trigger_commands("reportvcannoying " .. player_name)
            menu.trigger_commands("reportvchate " .. player_name)
            menu.trigger_commands("reportannoying " .. player_name)
            menu.trigger_commands("reporthate " .. player_name)
            menu.trigger_commands("reportexploits " .. player_name)
            menu.trigger_commands("reportbugabuse " .. player_name)
        end
        util.yield(500)
    end)



    -----------------------------
    ---------- 友好选项 ----------
    -----------------------------
    local Friendly_options = menu.list(Player_MainMenu, "友好选项", {}, "")

    menu.action(Friendly_options, "生成医药包", {}, "", function()
        local modelHash = util.joaat("prop_ld_health_pack")
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0.0, 0.0, 0.0)
        local pickupHash = 2406513688
        Create_Network_Pickup(pickupHash, coords.x, coords.y, coords.z, modelHash, 100)
    end)
    menu.action(Friendly_options, "生成护甲", {}, "", function()
        local modelHash = util.joaat("prop_armour_pickup")
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0.0, 0.0, 0.0)
        local pickupHash = 1274757841
        Create_Network_Pickup(pickupHash, coords.x, coords.y, coords.z, modelHash, 100)
    end)
    menu.action(Friendly_options, "生成零食(PQ豆)", {}, "", function()
        local modelHash = util.joaat("PROP_CHOC_PQ")
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0.0, 0.0, 0.0)
        local pickupHash = 483577702
        Create_Network_Pickup(pickupHash, coords.x, coords.y, coords.z, modelHash, 30)
    end)
    menu.action(Friendly_options, "生成降落伞", {}, "", function()
        local modelHash = util.joaat("p_parachute_s_shop")
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0.0, 0.0, 0.0)
        local pickupHash = 1735599485
        Create_Network_Pickup(pickupHash, coords.x, coords.y, coords.z, modelHash, 2)
    end)
    menu.action(Friendly_options, "生成呼吸器", {}, "", function()
        local modelHash = util.joaat("PROP_LD_HEALTH_PACK")
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0.0, 0.0, 0.0)
        local pickupHash = 3889104844
        Create_Network_Pickup(pickupHash, coords.x, coords.y, coords.z, modelHash, 20)
    end)
    menu.action(Friendly_options, "生成火神机枪", {}, "", function()
        local modelHash = util.joaat("W_MG_Minigun")
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0.0, 0.0, 0.0)
        local pickupHash = 792114228
        Create_Network_Pickup(pickupHash, coords.x, coords.y, coords.z, modelHash, 100)

        modelHash = util.joaat("prop_ld_ammo_pack_02")
        pickupHash = 4065984953
        Create_Network_Pickup(pickupHash, coords.x, coords.y, coords.z, modelHash, 9999)
    end)

    menu.toggle_loop(Friendly_options, "循环称赞", {}, "", function()
        if pId ~= players.user() then
            local player_name = players.get_name(pId)
            menu.trigger_commands("commendhelpful " .. player_name)
            menu.trigger_commands("commendfriendly " .. player_name)
        end
        util.yield(500)
    end)


    -------------------------
    --- 自定义Model生成实体 ---
    -------------------------
    local CustomModel_Generate = menu.list(Player_MainMenu, "自定义Model生成实体", {}, "")
    local CustomModel_Generate_Data = {
        hash = 0,
        type = 1,
        x = 0.0,
        y = 0.0,
        z = 0.0,
        is_invincible = false,
        is_freeze = false,
        is_invisible = false,
        cant_migrate = false,
        no_collision = false,
        --saved hash
        is_select = false,
        select_hash = 0,
        select_type = 1,
    }

    menu.text_input(CustomModel_Generate, "Model Hash ", { "generate_custom_model" }, "",
        function(value)
            CustomModel_Generate_Data.hash = tonumber(value)
        end)
    menu.action(CustomModel_Generate, "转换复制内容", {}, "删除Model Hash: \n便于直接粘贴Ctrl+V",
        function()
            local text = util.get_clipboard_text()
            local num = string.gsub(text, "Model Hash: ", "")
            util.copy_to_clipboard(num, false)
            util.toast("Copied!\n" .. num)
        end)

    local EntityType_ListItem = {
        { "Ped" }, --1
        { "Vehicle" }, --2
        { "Object" }, --3
    }
    menu.list_select(CustomModel_Generate, "实体类型", {}, "", EntityType_ListItem, 1,
        function(index)
            CustomModel_Generate_Data.type = index
        end)
    menu.slider_float(CustomModel_Generate, "左/右", { "generate_custom_model_x" }, "", -10000, 10000, 0, 100,
        function(value)
            CustomModel_Generate_Data.x = value * 0.01
        end)
    menu.slider_float(CustomModel_Generate, "前/后", { "generate_custom_model_y" }, "", -10000, 10000, 0, 100,
        function(value)
            CustomModel_Generate_Data.y = value * 0.01
        end)
    menu.slider_float(CustomModel_Generate, "上/下", { "generate_custom_model_z" }, "", -10000, 10000, 0, 100,
        function(value)
            CustomModel_Generate_Data.z = value * 0.01
        end)

    local CustomModel_Generate_Setting = menu.list(CustomModel_Generate, "属性", {}, "")
    menu.toggle(CustomModel_Generate_Setting, "无敌", {}, "", function(toggle)
        CustomModel_Generate_Data.is_invincible = toggle
    end)
    menu.toggle(CustomModel_Generate_Setting, "冻结", {}, "", function(toggle)
        CustomModel_Generate_Data.is_freeze = toggle
    end)
    menu.toggle(CustomModel_Generate_Setting, "不可见", {}, "", function(toggle)
        CustomModel_Generate_Data.is_invisible = toggle
    end)
    menu.toggle(CustomModel_Generate_Setting, "不可控制", {}, "", function(toggle)
        CustomModel_Generate_Data.cant_migrate = toggle
    end)
    menu.toggle(CustomModel_Generate_Setting, "无碰撞", {}, "", function(toggle)
        CustomModel_Generate_Data.no_collision = toggle
    end)

    --menu.divider(CustomModel_Generate, "")
    CustomModel_Generate_Saved = menu.list_select(CustomModel_Generate, "保存的Hash", {}, "",
        Saved_Hash_List.get_list_item_data2(), 1, function(value)
        if value == 1 then
            --None
            CustomModel_Generate_Data.is_select = false
        elseif value == 2 then
            --Refresh List
            CustomModel_Generate_Data.is_select = false

            menu.set_list_action_options(CustomModel_Generate_Saved, Saved_Hash_List.get_list_item_data2())
            util.toast("已刷新，请重新打开该列表")
        else
            CustomModel_Generate_Data.is_select = true

            local Name = Saved_Hash_List.get_list()[value - 2]
            local Hash, Type = Saved_Hash_List.read(Name)
            CustomModel_Generate_Data.select_hash = Hash
            CustomModel_Generate_Data.select_type = GET_ENTITY_TYPE_INDEX(Type)
        end
    end)

    menu.action(CustomModel_Generate, "生成实体", {}, "", function()
        local hash = CustomModel_Generate_Data.hash
        local Type = CustomModel_Generate_Data.type
        if CustomModel_Generate_Data.is_select then
            hash = CustomModel_Generate_Data.select_hash
            Type = CustomModel_Generate_Data.select_type
        end

        hash = tonumber(hash)
        if hash ~= nil and STREAMING.IS_MODEL_VALID(hash) then
            local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, CustomModel_Generate_Data.x,
                CustomModel_Generate_Data.y, CustomModel_Generate_Data.z)
            local heading = ENTITY.GET_ENTITY_HEADING(player_ped)

            local ent
            if Type == 1 then
                ent = Create_Network_Ped(PED_TYPE_MISSION, hash, coords.x, coords.y, coords.z, heading)
            elseif Type == 2 then
                ent = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, heading)
            elseif Type == 3 then
                ent = Create_Network_Object(hash, coords.x, coords.y, coords.z)
            else
                util.toast("不支持生成该类型实体")
            end

            if ent ~= nil then
                ENTITY.SET_ENTITY_INVINCIBLE(ent, CustomModel_Generate_Data.is_invincible)
                ENTITY.FREEZE_ENTITY_POSITION(ent, CustomModel_Generate_Data.is_freeze)
                ENTITY.SET_ENTITY_VISIBLE(ent, not CustomModel_Generate_Data.is_invisible, 0)
                if CustomModel_Generate_Data.cant_migrate then
                    entities.set_can_migrate(entities.handle_to_pointer(ent), false)
                end
                if CustomModel_Generate_Data.no_collision then
                    ENTITY.SET_ENTITY_COLLISION(ent, false, false)
                end
            end
        else
            util.toast("Wrong model hash !")
        end

    end)


    ----- END -----
end

----- 玩家列表 -----
local PlayersList = players.list(true, true, true)
for i = 1, #PlayersList do
    PlayerFunctions(PlayersList[i])
end

players.on_join(PlayerFunctions)
