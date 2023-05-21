--------------------------------------------
-- Alternative for Native Functions
--------------------------------------------

---@param entity Entity
---@param coords v3
function SET_ENTITY_COORDS(entity, coords)
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entity, coords.x, coords.y, coords.z, true, false, false)
end

---@param vehicle Vehicle
---@param seat integer
---@return Ped
function GET_PED_IN_VEHICLE_SEAT(vehicle, seat)
    if not VEHICLE.IS_VEHICLE_SEAT_FREE(vehicle, seat, false) then
        return VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, seat)
    end
    return 0
end

---@param ped Ped
---@return Vehicle
function GET_VEHICLE_PED_IS_IN(ped)
    if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
        return PED.GET_VEHICLE_PED_IS_IN(ped, false)
    end
    return 0
end

---`colour` range: r, g, b, alpha = 0-255
---@param start_pos v3
---@param end_pos v3
---@param colour? Colour
function DRAW_LINE(start_pos, end_pos, colour)
    colour = colour or { r = 255, g = 0, b = 255, a = 255 }
    GRAPHICS.DRAW_LINE(start_pos.x, start_pos.y, start_pos.z, end_pos.x, end_pos.y, end_pos.z, colour.r, colour.g,
        colour.b, colour.a)
end

---`colour` range: r, g, b = 0-255, alpha = 0-1.0
---@param coords v3
---@param radius float
---@param colour? Colour
function DRAW_MARKER_SPHERE(coords, radius, colour)
    colour = colour or { r = 200, g = 50, b = 200, a = 0.5 }
    GRAPHICS.DRAW_MARKER_SPHERE(coords.x, coords.y, coords.z, radius, colour.r, colour.g, colour.b, colour.a)
end

---Creates an explosion at the co-ordinates.
---@param coords v3
---@param explosionType? integer [default = 2]
---@param optionalParams? table<key, value>
--- - - -
--- **optionalParams:**
--- - `damageScale` *float* [default = 1.0]
--- - `isAudible` *boolean* [default = true]
--- - `isInvisible` *boolean* [default = false]
--- - `cameraShake` *float* [default = 0.0]
--- - `noDamage` *boolean* [default = false]
function add_explosion(coords, explosionType, optionalParams)
    explosionType = explosionType or 2
    local Params = optionalParams or {}
    Params.damageScale = Params.damageScale or 1.0
    if Params.isAudible == nil then Params.isAudible = true end
    Params.cameraShake = Params.cameraShake or 0.0

    FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z,
        explosionType,
        Params.damageScale, Params.isAudible, Params.isInvisible, Params.cameraShake, Params.noDamage)
end

---Creates an explosion at the co-ordinates owned by a specific ped.
---@param owner Ped
---@param coords v3
---@param explosionType? integer [default = 2]
---@param optionalParams? table<key, value>
--- - - -
--- **optionalParams:**
--- - `damageScale` *float* [default = 1.0]
--- - `isAudible` *boolean* [default = true]
--- - `isInvisible` *boolean* [default = false]
--- - `cameraShake` *float* [default = 0.0]
function add_owned_explosion(owner, coords, explosionType, optionalParams)
    explosionType = explosionType or 2
    local Params = optionalParams or {}
    Params.damageScale = Params.damageScale or 1.0
    if Params.isAudible == nil then Params.isAudible = true end
    Params.cameraShake = Params.cameraShake or 0.0

    FIRE.ADD_OWNED_EXPLOSION(owner, coords.x, coords.y, coords.z,
        explosionType,
        Params.damageScale, Params.isAudible, Params.isInvisible, Params.cameraShake)
end

---!!! DON'T USE
---
---Fires an instant hit bullet between the two points taking into account an entity to ignore for damage.
---@param startCoords v3
---@param endCoords v3
---@param optionalParams? table<key, value>
--- - - -
--- **optionalParams:**
--- - `damage` *integer* [default = 1000]
--- - `perfectAccuracy` *boolean* [default = false]
--- - `weaponHash` *Hash* [default = 4058111347(WEAPON_APPISTOL)]
--- - `owner` *Ped* [default = NULL]
--- - `createTraceVfx` *boolean* [default = true]
--- - `allowRumble` *boolean* [default = true]
--- - `speed` *integer* [default = 1000]
--- - `ignoreEntity` *Entity* [default = 0]
function shoot_single_bullet(startCoords, endCoords, optionalParams)
    local Params = optionalParams or {}
    Params.damage = Params.damage or 1000
    Params.weaponHash = Params.weaponHash or 4058111347
    Params.owner = Params.owner or 0
    if Params.createTraceVfx == nil then Params.createTraceVfx = true end
    if Params.allowRumble == nil then Params.allowRumble = true end
    Params.speed = Params.speed or 1000
    Params.ignoreEntity = Params.ignoreEntity or 0

    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(
        startCoords.x, startCoords.y, startCoords.z,
        endCoords.x, endCoords.y, endCoords.z,
        Params.damage, Params.perfectAccuracy, Params.weaponHash, Params.owner,
        Params.createTraceVfx, Params.allowRumble, Params.speed, Params.ignoreEntity)
end

---Trigger a set piece (non looped) particle effect on an entity with an offset position and orientation.
---@param fxName string
---@param entity Entity
---@param offset v3?
---@param rotation v3?
---@param scale float?
---@param invertAxis table<key, boolean>?
function start_ptfx_on_entity(fxName, entity, offset, rotation, scale, invertAxis)
    offset = offset or v3(0, 0, 0)
    rotation = rotation or v3(0, 0, 0)
    scale = scale or 1.0
    invertAxis = invertAxis or { x = false, y = false, z = false }

    GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_ON_ENTITY(fxName, entity,
        offset.x, offset.y, offset.z,
        rotation.x, rotation.y, rotation.z,
        scale,
        invertAxis.x, invertAxis.y, invertAxis.z)
end

---Trigger a set piece (non looped) particle effect at a world position and orientation.
---@param fxName string
---@param coords v3
---@param rotation v3?
---@param scale float?
---@param invertAxis table<key, boolean>?
---@param ignoreScopeChecks boolean? use this ONLY for the ion cannon effects, otherwise request permission from network code
function start_ptfx_at_coord(fxName, coords, rotation, scale, invertAxis, ignoreScopeChecks)
    rotation = rotation or v3(0, 0, 0)
    scale = scale or 1.0
    invertAxis = invertAxis or { x = false, y = false, z = false }

    GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(fxName,
        coords.x, coords.y, coords.z,
        rotation.x, rotation.y, rotation.z,
        scale,
        invertAxis.x, invertAxis.y, invertAxis.z,
        ignoreScopeChecks)
end

----------------------------------------
-- Only Work for Player Functions
----------------------------------------

---@param x float
---@param y float
---@param z float
---@param heading? float
function TELEPORT(x, y, z, heading)
    local tp = players.user_ped()
    local veh = GET_VEHICLE_PED_IS_IN(tp)
    if veh ~= 0 then
        tp = veh
    end
    SET_ENTITY_COORDS(tp, v3.new(x, y, z))

    if heading ~= nil then
        ENTITY.SET_ENTITY_HEADING(tp, heading)
    end
end

---@param coords v3
---@param heading? float
function TELEPORT2(coords, heading)
    local tp = players.user_ped()
    local veh = GET_VEHICLE_PED_IS_IN(tp)
    if veh ~= 0 then
        tp = veh
    end
    SET_ENTITY_COORDS(tp, coords)

    if heading ~= nil then
        ENTITY.SET_ENTITY_HEADING(tp, heading)
    end
end

---设置/获取玩家的朝向
---@param heading? float
---@return float
function PLAYER_HEADING(heading)
    local ent = players.user_ped()
    local veh = GET_VEHICLE_PED_IS_IN(ent)
    if veh ~= 0 then
        ent = veh
    end

    if heading ~= nil then
        ENTITY.SET_ENTITY_HEADING(ent, heading)
    end

    return ENTITY.GET_ENTITY_HEADING(ent)
end

---传送实体到玩家
---@param ent Entity
---@param offsetX? float
---@param offsetY? float
---@param offsetZ? float
function TP_TO_ME(ent, offsetX, offsetY, offsetZ)
    if offsetX == nil then offsetX = 0.0 end
    if offsetY == nil then offsetY = 0.0 end
    if offsetZ == nil then offsetZ = 0.0 end
    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), offsetX, offsetY, offsetZ)
    SET_ENTITY_COORDS(ent, coords)
end

---玩家传送到实体
---@param ent Entity
---@param offsetX? float
---@param offsetY? float
---@param offsetZ? float
function TP_TO_ENTITY(ent, offsetX, offsetY, offsetZ)
    if offsetX == nil then offsetX = 0.0 end
    if offsetY == nil then offsetY = 0.0 end
    if offsetZ == nil then offsetZ = 0.0 end
    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, offsetX, offsetY, offsetZ)
    TELEPORT(coords.x, coords.y, coords.z)
end

---玩家传送进载具驾驶位
---@param vehicle Vehicle
---@param door? string
---@param driver? string
---
--- "delete": 删除车门, "open": 打开车门
---
--- "tp": 传送司机到外面, "delete": 删除司机
function TP_INTO_VEHICLE(vehicle, door, driver)
    if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        --unlock doors
        VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle, 1)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(vehicle, false)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_PLAYER(vehicle, players.user(), false)
        --driver
        local ped = GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
        if ped ~= 0 then
            if driver == "tp" then
                local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(vehicle, 0.0, 5.0, 3.0)
                SET_ENTITY_COORDS(ped, coords)
            elseif driver == "delete" then
                entities.delete_by_handle(ped)
            end
        end
        --tp into
        VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, false)
        PED.SET_PED_INTO_VEHICLE(players.user_ped(), vehicle, -1)
        --door
        if door == "delete" then
            VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, 0, true)
        elseif door == "open" then
            VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, 0, false, false)
        end
    end
end

---传送载具到玩家，并且坐进驾驶位
---@param vehicle Vehicle
---@param door? string
---@param driver? string
---
--- "delete": 删除车门, "open": 打开车门
---
--- "tp": 传送司机到外面, "delete": 删除司机
function TP_VEHICLE_TO_ME(vehicle, door, driver)
    if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        SET_ENTITY_HEAD_TO_ENTITY(vehicle, players.user_ped())
        TP_TO_ME(vehicle, 0.0, 0.0, 0.0)
        TP_INTO_VEHICLE(vehicle, door, driver)
    end
end

-----------------------------
-- Entity Functions
-----------------------------

---请求控制实体
---@param entity Entity
---@param tick? integer
---@return boolean
function RequestControl(entity, tick)
    if tick == nil then tick = 20 end
    if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity) and util.is_session_started() then
        entities.set_can_migrate(entities.handle_to_pointer(entity), true)

        local i = 0
        while not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity) and i <= tick do
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
            i = i + 1
            util.yield()
        end
    end
    return NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity)
end

---是否已控制实体
---@param entity Entity
---@return boolean
function hasControl(entity)
    return NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity)
end

---判断是否为玩家
---@param Ped Ped
---@return boolean
function IS_PED_PLAYER(Ped)
    if ENTITY.IS_ENTITY_A_PED(Ped) then
        if PED.GET_PED_TYPE(Ped) >= 4 then
            return false
        else
            return true
        end
    end
    return false
end

---判断是否为玩家载具
---@param vehicle Vehicle
---@return boolean
function IS_PLAYER_VEHICLE(vehicle)
    if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        if vehicle == entities.get_user_vehicle_as_handle() or vehicle == entities.get_user_personal_vehicle_as_handle() then
            return true
        elseif not VEHICLE.IS_VEHICLE_SEAT_FREE(vehicle, -1, false) then
            local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
            if ped ~= 0 then
                if IS_PED_PLAYER(ped) then
                    return true
                end
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

---@param entity Entity
---@return boolean
function IS_ENTITY_A_PICKUP(entity)
    if ENTITY.IS_ENTITY_AN_OBJECT(entity) then
        if OBJECT.IS_OBJECT_A_PICKUP(entity) or OBJECT.IS_OBJECT_A_PORTABLE_PICKUP(entity) then
            return true
        end
    end
    return false
end

---判断是否为敌对实体
---@param entity Entity
---@return boolean
function IS_HOSTILE_ENTITY(entity)
    if ENTITY.DOES_ENTITY_EXIST(entity) then
        if ENTITY.IS_ENTITY_A_PED(entity) then
            if is_hostile_ped(entity) then
                return true
            end
        end

        if ENTITY.IS_ENTITY_A_VEHICLE(entity) then
            local driver = GET_PED_IN_VEHICLE_SEAT(entity, -1)
            if is_hostile_ped(entity) then
                return true
            end
        end

        local blip = HUD.GET_BLIP_FROM_ENTITY(entity)
        if HUD.DOES_BLIP_EXIST(blip) then
            local blip_color = HUD.GET_BLIP_COLOUR(blip)
            if isInTable(Blip_Color_Red, blip_color) then
                return true
            end
        end
    end
    return false
end

---获取实体类型 (String)
---
---`text_type`: 1 小写, 2 首字母大写, 3 大写 (默认: 2)
---@param entity Entity
---@param text_type integer?
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

---设置实体左右、前后、上下移动
---@param entity Entity
---@param offsetX float
---@param offsetY float
---@param offsetZ float
function SET_ENTITY_MOVE(entity, offsetX, offsetY, offsetZ)
    if ENTITY.DOES_ENTITY_EXIST(entity) then
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, offsetX, offsetY, offsetZ)
        SET_ENTITY_COORDS(entity, coords)
    end
end

---@param set_ent Entity
---@param to_ent Entity
---@param angle? float
---要设置的实体，要朝向的实体，角度差
---
---最终设置：要朝向的实体的角度 + 角度差
function SET_ENTITY_HEAD_TO_ENTITY(set_ent, to_ent, angle)
    if angle == nil then angle = 0.0 end
    local Head = ENTITY.GET_ENTITY_HEADING(to_ent)
    ENTITY.SET_ENTITY_HEADING(set_ent, Head + angle)
end

---@param tp_ent Entity
---@param to_ent Entity
---@param offsetX? float
---@param offsetY? float
---@param offsetZ? float
---要传送的实体，传送到实体，左/右，前/后，上/下
function TP_ENTITY_TO_ENTITY(tp_ent, to_ent, offsetX, offsetY, offsetZ)
    if offsetX == nil then offsetX = 0.0 end
    if offsetY == nil then offsetY = 0.0 end
    if offsetZ == nil then offsetZ = 0.0 end
    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(to_ent, offsetX, offsetY, offsetZ)
    SET_ENTITY_COORDS(tp_ent, coords)
end

---@param ent Entity
---@param can_migrate? boolean
---@return boolean
function set_entity_networked(ent, can_migrate)
    if ENTITY.DOES_ENTITY_EXIST(ent) then
        if can_migrate == nil then can_migrate = true end

        ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(ent, true)
        ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION(ent, true)

        NETWORK.NETWORK_REGISTER_ENTITY_AS_NETWORKED(ent)

        local net_id = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(ent)
        NETWORK.SET_NETWORK_ID_CAN_MIGRATE(net_id, can_migrate)
        NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(net_id, true)
        for _, pid in pairs(players.list()) do
            if players.exists(pid) then
                NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(net_id, pid, true)
            end
        end

        return NETWORK.NETWORK_GET_ENTITY_IS_NETWORKED(ent)
    end
    return false
end

---获取对应类型的所有实体
---@param Type string
---@return table<int, entity>
function get_all_entities(Type)
    local all_entity = {}
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
    return all_entity
end

---通过model hash寻找实体
---@param Type string
---@param isMission boolean
---@param ... Hash
---@return table<int, entity>
function get_entities_by_hash(Type, isMission, ...)
    local all_entity = get_all_entities(Type)

    local entity_list = {}
    local args = { ... } -- Hash list

    for k, ent in pairs(all_entity) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        for _, Hash in pairs(args) do
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

---@param ent Entity
---@param toggle boolean
function set_entity_godmode(ent, toggle)
    ENTITY.SET_ENTITY_INVINCIBLE(ent, toggle)
    ENTITY.SET_ENTITY_PROOFS(ent, toggle, toggle, toggle, toggle, toggle, toggle, toggle, toggle)
end

---@param entity Entity
---@param target Entity
---@return float
function get_distance_between_entities(entity, target)
    if not ENTITY.DOES_ENTITY_EXIST(entity) or not ENTITY.DOES_ENTITY_EXIST(target) then
        return 0.0
    end
    local pos = ENTITY.GET_ENTITY_COORDS(entity, true)
    return ENTITY.GET_ENTITY_COORDS(target, true):distance(pos)
end

-----------------------------------
-- Create Entity Functions
-----------------------------------

---@param pedType int
---@param modelHash Hash
---@param x float
---@param y float
---@param z float
---@param heading float
---@return Ped
function Create_Network_Ped(pedType, modelHash, x, y, z, heading)
    request_model(modelHash)
    local ped = PED.CREATE_PED(pedType, modelHash, x, y, z, heading, true, true)

    ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(ped, true)
    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ped, true, false)
    ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION(ped, true)

    NETWORK.NETWORK_REGISTER_ENTITY_AS_NETWORKED(ped)
    local net_id = NETWORK.PED_TO_NET(ped)
    NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(net_id, true)
    NETWORK.SET_NETWORK_ID_CAN_MIGRATE(net_id, true)
    for _, pid in pairs(players.list()) do
        NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(net_id, pid, true)
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
    request_model(modelHash)
    local veh = VEHICLE.CREATE_VEHICLE(modelHash, x, y, z, heading, true, true, false)

    VEHICLE.SET_VEHICLE_ENGINE_ON(veh, true, true, false)
    VEHICLE.SET_VEHICLE_DIRT_LEVEL(veh, 0.0)
    VEHICLE.SET_VEHICLE_HAS_BEEN_OWNED_BY_PLAYER(veh, true)
    VEHICLE.SET_VEHICLE_STAYS_FROZEN_WHEN_CLEANED_UP(veh, true)
    VEHICLE.SET_CLEAR_FREEZE_WAITING_ON_COLLISION_ONCE_PLAYER_ENTERS(veh, false)

    ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(veh, true)
    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(veh, true, false)
    ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION(veh, true)

    NETWORK.NETWORK_REGISTER_ENTITY_AS_NETWORKED(veh)
    local net_id = NETWORK.VEH_TO_NET(veh)
    NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(net_id, true)
    NETWORK.SET_NETWORK_ID_CAN_MIGRATE(net_id, true)
    for _, pid in pairs(players.list()) do
        NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(net_id, pid, true)
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
    request_model(modelHash)
    local pickup = OBJECT.CREATE_AMBIENT_PICKUP(pickupHash, x, y, z, 4, value, modelHash, false, true)

    OBJECT.SET_PICKUP_OBJECT_COLLECTABLE_IN_VEHICLE(pickup)

    ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(pickup, true)
    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(pickup, true, false)
    ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION(pickup, true)

    NETWORK.NETWORK_REGISTER_ENTITY_AS_NETWORKED(pickup)
    local net_id = NETWORK.OBJ_TO_NET(pickup)
    NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(net_id, true)
    NETWORK.SET_NETWORK_ID_CAN_MIGRATE(net_id, true)
    for _, pid in pairs(players.list()) do
        NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(net_id, pid, true)
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
    request_model(modelHash)
    local obj = OBJECT.CREATE_OBJECT_NO_OFFSET(modelHash, x, y, z, true, true, false)

    ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(obj, true)
    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(obj, true, false)
    ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION(obj, true)

    NETWORK.NETWORK_REGISTER_ENTITY_AS_NETWORKED(obj)
    local net_id = NETWORK.OBJ_TO_NET(obj)
    NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(net_id, true)
    NETWORK.SET_NETWORK_ID_CAN_MIGRATE(net_id, true)
    for _, pid in pairs(players.list()) do
        NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(net_id, pid, true)
    end

    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(modelHash)
    return obj
end

---@param ped_type int
---@param hash Hash
---@param coords v3
---@param heading float
---@param is_networked boolean? [default = true]
---@param is_mission boolean? [default = true]
---@return Ped
function create_ped(ped_type, hash, coords, heading, is_networked, is_mission)
    if is_networked == nil then is_networked = true end
    if is_mission == nil then is_mission = true end

    request_model(hash)
    local ped = PED.CREATE_PED(ped_type, hash, coords.x, coords.y, coords.z, heading, is_networked, is_mission)

    ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(ped, true)
    ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION(ped, true)

    if is_mission then
        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ped, true, false)
    end

    if is_networked then
        NETWORK.NETWORK_REGISTER_ENTITY_AS_NETWORKED(ped)
        local net_id = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(ped)
        NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(net_id, true)
        NETWORK.SET_NETWORK_ID_CAN_MIGRATE(net_id, true)
        for _, pid in pairs(players.list()) do
            if players.exists(pid) then
                NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(net_id, pid, true)
            end
        end
    end

    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
    return ped
end

---@param hash Hash
---@param coords v3
---@param heading float
---@param is_networked boolean? [default = true]
---@param is_mission boolean? [default = true]
---@return Vehicle
function create_vehicle(hash, coords, heading, is_networked, is_mission)
    if is_networked == nil then is_networked = true end
    if is_mission == nil then is_mission = true end

    request_model(hash)
    local veh = VEHICLE.CREATE_VEHICLE(hash, coords.x, coords.y, coords.z, heading, is_networked, is_mission, false)

    ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(veh, true)
    ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION(veh, true)

    if is_mission then
        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(veh, true, false)
    end

    if is_networked then
        NETWORK.NETWORK_REGISTER_ENTITY_AS_NETWORKED(veh)
        local net_id = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(veh)
        NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(net_id, true)
        NETWORK.SET_NETWORK_ID_CAN_MIGRATE(net_id, true)
        for _, pid in pairs(players.list()) do
            if players.exists(pid) then
                NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(net_id, pid, true)
            end
        end
    end

    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
    return veh
end

---@param hash Hash
---@param coords v3
---@param is_networked boolean? [default = true]
---@param is_mission boolean? [default = true]
---@return Object
function create_object(hash, coords, is_networked, is_mission)
    if is_networked == nil then is_networked = true end
    if is_mission == nil then is_mission = true end

    request_model(hash)
    local obj = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, coords.x, coords.y, coords.z, is_networked, is_mission, false)

    ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(obj, true)
    ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION(obj, true)

    if is_mission then
        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(obj, true, false)
    end

    if is_networked then
        NETWORK.NETWORK_REGISTER_ENTITY_AS_NETWORKED(obj)
        local net_id = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(obj)
        NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(net_id, true)
        NETWORK.SET_NETWORK_ID_CAN_MIGRATE(net_id, true)
        for _, pid in pairs(players.list()) do
            if players.exists(pid) then
                NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(net_id, pid, true)
            end
        end
    end

    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
    return obj
end

-----------------------------------
-- Clone Entity Functions
-----------------------------------

---复制Ped
---@param target_ped Ped
---@param coords v3
---@param heading float
---@param is_networked boolean
---@return Ped
function clone_target_ped(target_ped, coords, heading, is_networked)
    if ENTITY.DOES_ENTITY_EXIST(target_ped) and ENTITY.IS_ENTITY_A_PED(target_ped) then
        local ped_type = PED.GET_PED_TYPE(target_ped)
        local hash = ENTITY.GET_ENTITY_MODEL(target_ped)

        local clone_ped = create_ped(ped_type, hash, coords, heading, is_networked)
        PED.CLONE_PED_TO_TARGET(target_ped, clone_ped)

        return clone_ped
    end
    return 0
end

---复制目标Vehicle的数据 应用到 克隆Vehicle
---@param target_vehicle Vehicle
---@param clone_vehicle Vehicle
function clone_target_vehicle_data(target_vehicle, clone_vehicle)
    VEHICLE.SET_VEHICLE_MOD_KIT(clone_vehicle, 0)

    for i = 17, 22 do
        VEHICLE.TOGGLE_VEHICLE_MOD(clone_vehicle, i, VEHICLE.IS_TOGGLE_MOD_ON(target_vehicle, i))
    end
    for i = 0, 49 do
        local modValue = VEHICLE.GET_VEHICLE_MOD(target_vehicle, i)
        VEHICLE.SET_VEHICLE_MOD(clone_vehicle, i, modValue)
    end
    for i = 1, 14 do
        VEHICLE.SET_VEHICLE_EXTRA(clone_vehicle, i, not VEHICLE.IS_VEHICLE_EXTRA_TURNED_ON(target_vehicle, i))
    end

    local colorR, colorG, colorB = memory.alloc(1), memory.alloc(1), memory.alloc(1)
    if VEHICLE.GET_IS_VEHICLE_PRIMARY_COLOUR_CUSTOM(target_vehicle) then
        VEHICLE.GET_VEHICLE_CUSTOM_PRIMARY_COLOUR(target_vehicle, colorR, colorG, colorB)
        VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(clone_vehicle, memory.read_ubyte(colorR), memory.read_ubyte(colorG),
            memory.read_ubyte(colorB))
    else
        VEHICLE.GET_VEHICLE_MOD_COLOR_1(target_vehicle, colorR, colorG, colorB)
        VEHICLE.SET_VEHICLE_MOD_COLOR_1(clone_vehicle, memory.read_ubyte(colorR), memory.read_ubyte(colorG),
            memory.read_ubyte(colorB))
    end
    if VEHICLE.GET_IS_VEHICLE_SECONDARY_COLOUR_CUSTOM(target_vehicle) then
        VEHICLE.GET_VEHICLE_CUSTOM_SECONDARY_COLOUR(target_vehicle, colorR, colorG, colorB)
        VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(clone_vehicle, memory.read_ubyte(colorR), memory.read_ubyte(colorG),
            memory.read_ubyte(colorB))
    else
        VEHICLE.GET_VEHICLE_MOD_COLOR_2(target_vehicle, colorR, colorG)
        VEHICLE.SET_VEHICLE_MOD_COLOR_2(clone_vehicle, memory.read_ubyte(colorR), memory.read_ubyte(colorG))
    end
    VEHICLE.GET_VEHICLE_COLOURS(target_vehicle, colorR, colorG)
    VEHICLE.SET_VEHICLE_COLOURS(clone_vehicle, memory.read_ubyte(colorR), memory.read_ubyte(colorG))
    VEHICLE.GET_VEHICLE_EXTRA_COLOURS(target_vehicle, colorR, colorG)
    VEHICLE.SET_VEHICLE_EXTRA_COLOURS(clone_vehicle, memory.read_ubyte(colorR), memory.read_ubyte(colorG))
    VEHICLE.GET_VEHICLE_EXTRA_COLOUR_5(target_vehicle, colorR)
    VEHICLE.GET_VEHICLE_EXTRA_COLOUR_6(target_vehicle, colorG)
    VEHICLE.SET_VEHICLE_EXTRA_COLOUR_5(clone_vehicle, memory.read_ubyte(colorR))
    VEHICLE.SET_VEHICLE_EXTRA_COLOUR_6(clone_vehicle, memory.read_ubyte(colorG))

    VEHICLE.GET_VEHICLE_TYRE_SMOKE_COLOR(target_vehicle, colorR, colorG, colorB)
    VEHICLE.SET_VEHICLE_TYRE_SMOKE_COLOR(clone_vehicle, memory.read_ubyte(colorR), memory.read_ubyte(colorG),
        memory.read_ubyte(colorB))
    VEHICLE.GET_VEHICLE_NEON_COLOUR(target_vehicle, colorR, colorG, colorB)
    VEHICLE.SET_VEHICLE_NEON_COLOUR(clone_vehicle, memory.read_ubyte(colorR), memory.read_ubyte(colorG),
        memory.read_ubyte(colorB))

    for i = 0, 3 do
        VEHICLE.SET_VEHICLE_NEON_ENABLED(clone_vehicle, i, VEHICLE.GET_VEHICLE_NEON_ENABLED(target_vehicle, i))
    end

    local windowTint = VEHICLE.GET_VEHICLE_WINDOW_TINT(target_vehicle)
    VEHICLE.SET_VEHICLE_WINDOW_TINT(clone_vehicle, windowTint)

    local lightsColor = VEHICLE.GET_VEHICLE_XENON_LIGHT_COLOR_INDEX(target_vehicle)
    VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(clone_vehicle, lightsColor)

    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(clone_vehicle,
        VEHICLE.GET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(target_vehicle))
    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(clone_vehicle, VEHICLE.GET_VEHICLE_NUMBER_PLATE_TEXT(target_vehicle))

    VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(clone_vehicle, VEHICLE.GET_VEHICLE_TYRES_CAN_BURST(target_vehicle))

    VEHICLE.SET_VEHICLE_DIRT_LEVEL(clone_vehicle, VEHICLE.GET_VEHICLE_DIRT_LEVEL(target_vehicle))

    local roofState = VEHICLE.GET_CONVERTIBLE_ROOF_STATE(target_vehicle)
    if roofState == 1 or roofState == 2 then
        VEHICLE.LOWER_CONVERTIBLE_ROOF(clone_vehicle, true)
    end
end

---复制Vehicle
---@param target_vehicle Vehicle
---@param coords v3
---@param heading float
---@param is_networked boolean
---@return Vehicle
function clone_target_vehicle(target_vehicle, coords, heading, is_networked)
    if ENTITY.DOES_ENTITY_EXIST(target_vehicle) and ENTITY.IS_ENTITY_A_VEHICLE(target_vehicle) then
        local hash = ENTITY.GET_ENTITY_MODEL(target_vehicle)

        local clone_vehicle = create_vehicle(hash, coords, heading, is_networked)
        clone_target_vehicle_data(target_vehicle, clone_vehicle)

        return clone_vehicle
    end
    return 0
end

---复制Object
---@param target_object Object
---@param coords v3
---@param is_networked boolean
---@return Object
function clone_target_object(target_object, coords, is_networked)
    if ENTITY.DOES_ENTITY_EXIST(target_object) and ENTITY.IS_ENTITY_AN_OBJECT(target_object) then
        local hash = ENTITY.GET_ENTITY_MODEL(target_object)

        local clone_object = create_object(hash, coords, is_networked)

        local rotation = ENTITY.GET_ENTITY_ROTATION(target_object, 2)
        ENTITY.SET_ENTITY_ROTATION(clone_object, rotation.x, rotation.y, rotation.z, 2, true)

        return clone_object
    end
    return 0
end

-----------------------------------
-- Nearby Entity Functions
-----------------------------------

---returns a list of nearby vehicles given player Id
function GET_NEARBY_VEHICLES(pid, radius)
    local vehicles = {}
    local p = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
    local p_pos = ENTITY.GET_ENTITY_COORDS(p)
    for k, vehicle in pairs(entities.get_all_vehicles_as_handles()) do
        local veh_pos = ENTITY.GET_ENTITY_COORDS(vehicle)
        if radius <= 0 then
            table.insert(vehicles, vehicle)
        elseif v3.distance(p_pos, veh_pos) <= radius then
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
            if radius <= 0 then
                table.insert(peds, ped)
            elseif v3.distance(p_pos, ped_pos) <= radius then
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
        if radius <= 0 then
            table.insert(objs, obj)
        elseif v3.distance(p_pos, obj_pos) <= radius then
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
        if radius <= 0 then
            table.insert(objs, obj)
        elseif v3.distance(p_pos, obj_pos) <= radius then
            table.insert(objs, obj)
        end
    end
    return objs
end

-----------------------------
-- Vehicle Functions
-----------------------------

---升级载具（排除涂装、车轮）
---@param vehicle Vehicle
function upgrade_vehicle(vehicle)
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
---@param vehicle Vehicle
function fix_vehicle(vehicle)
    if ENTITY.DOES_ENTITY_EXIST(vehicle) and ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        VEHICLE.SET_VEHICLE_FIXED(vehicle)
        VEHICLE.SET_VEHICLE_DEFORMATION_FIXED(vehicle)
        VEHICLE.SET_VEHICLE_DIRT_LEVEL(vehicle, 0.0)
        VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, 1000.0)
    end
end

---强化载具
---@param vehicle Vehicle
function strong_vehicle(vehicle)
    if ENTITY.DOES_ENTITY_EXIST(vehicle) and ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        VEHICLE.SET_VEHICLE_CAN_BREAK(vehicle, false)
        VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(vehicle, false)
        VEHICLE.SET_VEHICLE_WHEELS_CAN_BREAK(vehicle, false)
        for i = 0, 5 do
            if VEHICLE.GET_IS_DOOR_VALID(vehicle, i) then
                VEHICLE.SET_DOOR_ALLOWED_TO_BE_BROKEN_OFF(vehicle, i, false)
            end
        end
        VEHICLE.SET_VEHICLE_HAS_UNBREAKABLE_LIGHTS(vehicle, true)

        VEHICLE.SET_VEHICLE_CAN_ENGINE_MISSFIRE(vehicle, false)
        VEHICLE.SET_VEHICLE_CAN_LEAK_OIL(vehicle, false)
        VEHICLE.SET_VEHICLE_CAN_LEAK_PETROL(vehicle, false)

        VEHICLE.SET_DISABLE_VEHICLE_ENGINE_FIRES(vehicle, true)
        VEHICLE.SET_DISABLE_VEHICLE_PETROL_TANK_FIRES(vehicle, true)
        VEHICLE.SET_DISABLE_VEHICLE_PETROL_TANK_DAMAGE(vehicle, true)

        VEHICLE.SET_VEHICLE_STRONG(vehicle, true)
        VEHICLE.SET_VEHICLE_HAS_STRONG_AXLES(vehicle, true)

        --Damage
        VEHICLE.VEHICLE_SET_RAMP_AND_RAMMING_CARS_TAKE_DAMAGE(vehicle, false)
        VEHICLE.SET_INCREASE_WHEEL_CRUSH_DAMAGE(vehicle, false)
        VEHICLE.SET_DISABLE_DAMAGE_WITH_PICKED_UP_ENTITY(vehicle, true)
        VEHICLE.SET_VEHICLE_USES_MP_PLAYER_DAMAGE_MULTIPLIER(vehicle, true)

        --Explode
        VEHICLE.SET_VEHICLE_NO_EXPLOSION_DAMAGE_FROM_DRIVER(vehicle, true)
        VEHICLE.SET_DISABLE_EXPLODE_FROM_BODY_DAMAGE_ON_COLLISION(vehicle, 1)
        VEHICLE.SET_VEHICLE_EXPLODES_ON_HIGH_EXPLOSION_DAMAGE(vehicle, false)
        VEHICLE.SET_VEHICLE_EXPLODES_ON_EXPLOSION_DAMAGE_AT_ZERO_BODY_HEALTH(vehicle, false)
        VEHICLE.SET_ALLOW_VEHICLE_EXPLODES_ON_CONTACT(vehicle, false)

        --Heli
        VEHICLE.SET_HELI_TAIL_BOOM_CAN_BREAK_OFF(vehicle, false)
        VEHICLE.SET_DISABLE_HELI_EXPLODE_FROM_BODY_DAMAGE(vehicle, true)

        --MP Only
        VEHICLE.SET_PLANE_RESIST_TO_EXPLOSION(vehicle, true)
        VEHICLE.SET_HELI_RESIST_TO_EXPLOSION(vehicle, true)

        --Remove Check
        VEHICLE.REMOVE_VEHICLE_UPSIDEDOWN_CHECK(vehicle)
        VEHICLE.REMOVE_VEHICLE_STUCK_CHECK(vehicle)
    end
end

---解锁载具车门
---@param vehicle Vehicle
function unlock_vehicle_doors(vehicle)
    if ENTITY.DOES_ENTITY_EXIST(vehicle) and ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle, 1)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(vehicle, false)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_NON_SCRIPT_PLAYERS(vehicle, false)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_TEAMS(vehicle, false)
        VEHICLE.SET_DONT_ALLOW_PLAYER_TO_ENTER_VEHICLE_IF_LOCKED_FOR_PLAYER(vehicle, false)
    end
end

---获取最近的载具生成点
--- - - -
---`nodeType`: 0 = main roads, 1 = any dry path, 3 = water
---@param coords v3
---@param nodeType integer
---@return boolean, v3, float
function get_closest_vehicle_node(coords, nodeType)
    local outCoords = v3.new()
    local outHeading = memory.alloc(4)
    if PATHFIND.GET_CLOSEST_VEHICLE_NODE_WITH_HEADING(coords.x, coords.y, coords.z,
            memory.addrof(outCoords), outHeading, nodeType, 3.0, 0) then
        return true, outCoords, memory.read_float(outHeading)
    else
        return false
    end
end

---获取随机的载具生成点
---@param coords v3
---@param radius float
---@return boolean, v3, integer
function get_random_vehicle_node(coords, radius)
    local vecReturn = v3.new()
    local NodeAddress = memory.alloc_int()
    if PATHFIND.GET_RANDOM_VEHICLE_NODE(coords.x, coords.y, coords.z, radius,
            0, false, false, memory.addrof(vecReturn), NodeAddress) then
        return true, vecReturn, memory.read_int(NodeAddress)
    else
        return false
    end
end

---获取载具内所有Ped
--- - - -
---返回 ped num 和 ped table
---@param vehicle Vehicle
---@return integer, table<int, ped>
function get_vehicle_peds(vehicle)
    local num = 0
    local peds = {}
    if ENTITY.DOES_ENTITY_EXIST(vehicle) and ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        local seats = VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(vehicle)
        for i = -1, seats - 1 do
            if not VEHICLE.IS_VEHICLE_SEAT_FREE(vehicle, i, false) then
                local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, i)

                num = num + 1
                table.insert(peds, ped)
            end
        end
    end
    return num, peds
end

---获取距离最近的载具
---@param coords v3
---@param is_mission boolean?
---@param radius float?
---@return Vehicle
function get_closest_vehicle(coords, is_mission, radius)
    radius = radius or 999999.0
    local closest_disance = 999999.0
    local vehicle = 0
    for k, veh in pairs(entities.get_all_vehicles_as_handles()) do
        if is_mission and not ENTITY.IS_ENTITY_A_MISSION_ENTITY(veh) then
        else
            local pos = ENTITY.GET_ENTITY_COORDS(veh)
            local distance = v3.distance(coords, pos)
            if distance <= radius then
                if distance < closest_disance then
                    closest_disance = distance
                    vehicle = veh
                end
            end
        end
    end
    return vehicle
end

---通过载具Hash获取载具名称
---@param modelHash Hash
---@return string
function get_vehicle_display_name_by_hash(modelHash)
    local display_name = "NULL"
    if STREAMING.IS_MODEL_VALID(modelHash) then
        display_name = util.get_label_text(VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(modelHash))
    end
    return display_name
end

---获取载具名称
---@param vehicle Vehicle
---@return string
function get_vehicle_display_name(vehicle)
    local display_name = "NULL"
    if ENTITY.DOES_ENTITY_EXIST(vehicle) and ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        local hash = ENTITY.GET_ENTITY_MODEL(vehicle)
        display_name = util.get_label_text(VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(hash))
    end
    return display_name
end

-----------------------------
-- Ped Functions
-----------------------------

---增强NPC作战能力
---@param ped Ped
---@param isGodmode boolean? [default = false]
---@param canRagdoll boolean? [default = true]
function increase_ped_combat_ability(ped, isGodmode, canRagdoll)
    if isGodmode == nil then isGodmode = false end
    if canRagdoll == nil then canRagdoll = true end

    if ENTITY.DOES_ENTITY_EXIST(ped) and ENTITY.IS_ENTITY_A_PED(ped) then
        ENTITY.SET_ENTITY_INVINCIBLE(ped, isGodmode)
        ENTITY.SET_ENTITY_PROOFS(ped, isGodmode, isGodmode, isGodmode, isGodmode, isGodmode, isGodmode, isGodmode,
            isGodmode)
        PED.SET_PED_CAN_RAGDOLL(ped, canRagdoll)

        --- PERCEPTIVE ---
        PED.SET_PED_HIGHLY_PERCEPTIVE(ped, true)
        PED.SET_PED_VISUAL_FIELD_PERIPHERAL_RANGE(ped, 500.0)
        PED.SET_PED_SEEING_RANGE(ped, 500.0)
        PED.SET_PED_HEARING_RANGE(ped, 500.0)
        PED.SET_PED_ID_RANGE(ped, 500.0)
        PED.SET_PED_VISUAL_FIELD_MIN_ANGLE(ped, 90.0)
        PED.SET_PED_VISUAL_FIELD_MAX_ANGLE(ped, 90.0)
        PED.SET_PED_VISUAL_FIELD_MIN_ELEVATION_ANGLE(ped, 90.0)
        PED.SET_PED_VISUAL_FIELD_MAX_ELEVATION_ANGLE(ped, 90.0)
        PED.SET_PED_VISUAL_FIELD_CENTER_ANGLE(ped, 90.0)

        --- WEAPON ---
        PED.SET_PED_CAN_SWITCH_WEAPON(ped, true)
        WEAPON.SET_PED_INFINITE_AMMO_CLIP(ped, true)
        PED.SET_PED_SHOOT_RATE(ped, 1000)
        PED.SET_PED_ACCURACY(ped, 100)

        --- COMBAT ---
        PED.SET_PED_COMBAT_ABILITY(ped, 2)       -- Professional
        PED.SET_PED_COMBAT_RANGE(ped, 2)         -- Far
        -- PED.SET_PED_COMBAT_MOVEMENT(ped, 2) -- WillAdvance
        PED.SET_PED_TARGET_LOSS_RESPONSE(ped, 1) -- NeverLoseTarget

        --- FLEE ATTRIBUTES ---
        PED.SET_PED_FLEE_ATTRIBUTES(ped, 512, true) -- NEVER_FLEE

        --- TASK ---
        TASK.SET_PED_PATH_CAN_USE_CLIMBOVERS(ped, true)
        TASK.SET_PED_PATH_CAN_USE_LADDERS(ped, true)
        TASK.SET_PED_PATH_CAN_DROP_FROM_HEIGHT(ped, true)
        TASK.SET_PED_PATH_AVOID_FIRE(ped, false)
        TASK.SET_PED_PATH_MAY_ENTER_WATER(ped, true)

        PED.SET_PED_SUFFERS_CRITICAL_HITS(ped, false) -- Sets if a healthy character can be killed by a single bullet (e.g. headshot)
    end
end

---增强NPC作战属性
---@param ped Ped
function increase_ped_combat_attributes(ped)
    if ENTITY.DOES_ENTITY_EXIST(ped) and ENTITY.IS_ENTITY_A_PED(ped) then
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 4, true)   --Can Use Dynamic Strafe Decisions
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 5, true)   --Always Fight
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 6, false)  --Flee Whilst In Vehicle
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 13, true)  --Aggressive
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 14, true)  --Can Investigate
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 17, false) --Always Flee
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 20, true)  --Can Taunt In Vehicle
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 21, true)  --Can Chase Target On Foot
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 22, true)  --Will Drag Injured Peds to Safety
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 24, true)  --Use Proximity Firing Rate
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 27, true)  --Perfect Accuracy
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 28, true)  --Can Use Frustrated Advance
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 29, true)  --Move To Location Before Cover Search
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 38, true)  --Disable Bullet Reactions
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 39, true)  --Can Bust
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 41, true)  --Can Commandeer Vehicles
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 42, true)  --Can Flank
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)  --Can Fight Armed Peds When Not Armed
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 49, false) --Use Enemy Accuracy Scaling
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 52, true)  --Use Vehicle Attack
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 53, true)  --Use Vehicle Attack If Vehicle Has Mounted Guns
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 54, true)  --Always Equip Best Weapon
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 55, true)  --Can See Underwater Peds
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 58, true)  --Disable Flee From Combat
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 60, true)  --Can Throw Smoke Grenade
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 78, true)  --Disable All Randoms Flee
    end
end

---@param ped Ped
function clear_ped_all_tasks(ped)
    if ENTITY.DOES_ENTITY_EXIST(ped) and ENTITY.IS_ENTITY_A_PED(ped) then
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
end

---@param ped Ped
function disable_ped_flee_attributes(ped)
    if ENTITY.DOES_ENTITY_EXIST(ped) and ENTITY.IS_ENTITY_A_PED(ped) then
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 6, false)  -- FLEE_WHILST_IN_VEHICLE
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 17, false) -- ALWAYS_FLEE
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)  -- CAN_FIGHT_ARMED_PEDS_WHEN_NOT_ARMED
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 58, true)  -- DISABLE_FLEE_FROM_COMBAT
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 78, true)  -- DISABLE_ALL_RANDOMS_FLEE

        PED.SET_PED_FLEE_ATTRIBUTES(ped, 512, true)   -- NEVER_FLEE
    end
end

---是否为敌对NPC
---@param ped Ped
---@return boolean
function is_hostile_ped(ped)
    if ENTITY.DOES_ENTITY_EXIST(ped) and ENTITY.IS_ENTITY_A_PED(ped) then
        if PED.IS_PED_IN_COMBAT(ped, players.user_ped()) then
            return true
        end

        local rel = PED.GET_RELATIONSHIP_BETWEEN_PEDS(ped, players.user_ped())
        if rel == 4 or rel == 5 then -- Wanted or Hate
            return true
        end
    end
    return false
end

---是否为友好NPC
---@param ped Ped
---@return boolean
function is_friendly_ped(ped)
    if ENTITY.DOES_ENTITY_EXIST(ped) and ENTITY.IS_ENTITY_A_PED(ped) then
        local rel = PED.GET_RELATIONSHIP_BETWEEN_PEDS(ent, players.user_ped())
        if rel == 0 or rel == 1 then -- Respect or Like
            return true
        end
    end
    return false
end

-----------------------------
-- Weapon Functions
-----------------------------

---获取Ped当前的武器Hash
---@param ped Ped
---@return Hash
function get_ped_weapon(ped)
    local weaponHash = 0
    if ENTITY.DOES_ENTITY_EXIST(ped) and ENTITY.IS_ENTITY_A_PED(ped) then
        local ptr = memory.alloc_int()
        WEAPON.GET_CURRENT_PED_WEAPON(ped, ptr, true)
        weaponHash = memory.read_int(ptr)
    end
    return weaponHash
end

---获取Ped当前的载具武器Hash
---@param ped Ped
---@return Hash
function get_ped_vehicle_weapon(ped)
    local weaponHash = 0
    if ENTITY.DOES_ENTITY_EXIST(ped) and ENTITY.IS_ENTITY_A_PED(ped) then
        local ptr = memory.alloc_int()
        if WEAPON.GET_CURRENT_PED_VEHICLE_WEAPON(ped, ptr) then
            weaponHash = memory.read_int(ptr)
        end
    end
    return weaponHash
end

-----------------------------
-- Blip Functions
-----------------------------

---获取标记点坐标
---@param blip Blip
---@return v3
function GET_BLIP_COORDS(blip)
    if not HUD.DOES_BLIP_EXIST(blip) then
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

---获取标记点类型
---@param blip Blip
---@return string
function GET_BLIP_TYPE(blip)
    if not HUD.DOES_BLIP_EXIST(blip) then
        return ""
    end

    local blip_type = HUD.GET_BLIP_INFO_ID_TYPE(blip)
    return enum_BlipType[blip_type]
end

---判断标记点是否为实体
---@param blip Blip
---@return boolean
function IS_BLIP_ENTITY(blip)
    if not HUD.DOES_BLIP_EXIST(blip) then
        return false
    end
    local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
    if ENTITY.DOES_ENTITY_EXIST(ent) then
        return true
    end
    return false
end

---为实体添加地图标记
---@param entity Entity
---@param blipSprite integer
---@param colour color
---@return Blip
function add_blip_for_entity(entity, blipSprite, colour)
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

---为实体添加标记点并显示一段时间，已有标记点则闪烁一段时间
---@param ent Entity
---@param blipSprite integer
---@param colour integer
---@param time integer ms
function SHOW_BLIP_TIMER(ent, blipSprite, colour, time)
    util.create_thread(function()
        local blip = HUD.GET_BLIP_FROM_ENTITY(ent)
        --no blip
        if not HUD.DOES_BLIP_EXIST(blip) then
            blip = HUD.ADD_BLIP_FOR_ENTITY(ent)
            HUD.SET_BLIP_SPRITE(blip, blipSprite)
            HUD.SET_BLIP_COLOUR(blip, colour)
            util.yield(time)
            util.remove_blip(blip)
        else
            HUD.SET_BLIP_FLASH_TIMER(blip, time)
        end
    end)
end

-------------------------------
-- Streaming Functions
-------------------------------

---请求模型资源
---@param Hash Hash
function request_model(Hash)
    if STREAMING.IS_MODEL_VALID(Hash) then
        STREAMING.REQUEST_MODEL(Hash)
        while not STREAMING.HAS_MODEL_LOADED(Hash) do
            STREAMING.REQUEST_MODEL(Hash)
            util.yield()
        end
    end
end

---请求武器资源
---@param Hash Hash
function request_weapon_asset(Hash)
    if WEAPON.IS_WEAPON_VALID(Hash) then
        WEAPON.REQUEST_WEAPON_ASSET(Hash, 31, 0)
        while not WEAPON.HAS_WEAPON_ASSET_LOADED(Hash) do
            WEAPON.REQUEST_WEAPON_ASSET(Hash, 31, 0)
            util.yield()
        end
    end
end

---请求粒子资源
---@param asset string
function request_ptfx_asset(asset)
    STREAMING.REQUEST_NAMED_PTFX_ASSET(asset)
    while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(asset) do
        util.yield()
    end
    GRAPHICS.USE_PARTICLE_FX_ASSET(asset)
end

-----------------------------
-- Draw Functions
-----------------------------

---@param pos0 v3
---@param pos1 v3
---@param pos2 v3
---@param pos3 v3
---@param colour Colour
local draw_rect = function(pos0, pos1, pos2, pos3, colour)
    GRAPHICS.DRAW_POLY(pos0.x, pos0.y, pos0.z, pos1.x, pos1.y, pos1.z, pos3.x, pos3.y, pos3.z, colour.r, colour.g,
        colour.b, colour.a)
    GRAPHICS.DRAW_POLY(pos3.x, pos3.y, pos3.z, pos2.x, pos2.y, pos2.z, pos0.x, pos0.y, pos0.z, colour.r, colour.g,
        colour.b, colour.a)
end

---@param entity Entity
---@param showPoly? boolean
---@param colour? Colour
function draw_bounding_box(entity, showPoly, colour)
    if not ENTITY.DOES_ENTITY_EXIST(entity) then
        return
    end
    colour = colour or { r = 0, g = 255, b = 0, a = 255 }
    local min = v3.new()
    local max = v3.new()
    MISC.GET_MODEL_DIMENSIONS(ENTITY.GET_ENTITY_MODEL(entity), min, max)
    min:abs();
    max:abs()

    local upperLeftRear = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, -max.x, -max.y, max.z)
    local upperRightRear = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, min.x, -max.y, max.z)
    local lowerLeftRear = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, -max.x, -max.y, -min.z)
    local lowerRightRear = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, min.x, -max.y, -min.z)

    DRAW_LINE(upperLeftRear, upperRightRear, colour)
    DRAW_LINE(lowerLeftRear, lowerRightRear, colour)
    DRAW_LINE(upperLeftRear, lowerLeftRear, colour)
    DRAW_LINE(upperRightRear, lowerRightRear, colour)

    local upperLeftFront = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, -max.x, min.y, max.z)
    local upperRightFront = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, min.x, min.y, max.z)
    local lowerLeftFront = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, -max.x, min.y, -min.z)
    local lowerRightFront = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, min.x, min.y, -min.z)

    DRAW_LINE(upperLeftFront, upperRightFront, colour)
    DRAW_LINE(lowerLeftFront, lowerRightFront, colour)
    DRAW_LINE(upperLeftFront, lowerLeftFront, colour)
    DRAW_LINE(upperRightFront, lowerRightFront, colour)

    DRAW_LINE(upperLeftRear, upperLeftFront, colour)
    DRAW_LINE(upperRightRear, upperRightFront, colour)
    DRAW_LINE(lowerLeftRear, lowerLeftFront, colour)
    DRAW_LINE(lowerRightRear, lowerRightFront, colour)

    if showPoly then
        draw_rect(lowerLeftRear, upperLeftRear, lowerLeftFront, upperLeftFront, colour)
        draw_rect(upperRightRear, lowerRightRear, upperRightFront, lowerRightFront, colour)

        draw_rect(lowerLeftFront, upperLeftFront, lowerRightFront, upperRightFront, colour)
        draw_rect(upperLeftRear, lowerLeftRear, upperRightRear, lowerRightRear, colour)

        draw_rect(upperRightRear, upperRightFront, upperLeftRear, upperLeftFront, colour)
        draw_rect(lowerRightFront, lowerRightRear, lowerLeftFront, lowerLeftRear, colour)
    end
end

---@param text string
---@param x float
---@param y float
---@param scale? float [default = 0.5]
---@param margin? float [default = 0.01]
---@param text_color? Color
---@param background_color? Color
function draw_text_box(text, x, y, scale, margin, text_color, background_color)
    scale = scale or 0.5
    margin = margin or 0.01
    text_color = text_color or color.white
    background_color = background_color or { r = 0.0, g = 0.0, b = 0.0, a = 0.6 }

    local text_width, text_height = directx.get_text_size(text, scale)
    directx.draw_rect(x, y, text_width + margin * 2, text_height + margin * 2, background_color)
    directx.draw_text(x + margin, y + margin, text, ALIGN_TOP_LEFT, scale, text_color)
end

---@param text string
---@param scale? float [default = 0.5]
function DrawString(text, scale)
    scale = scale or 0.5
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

function draw_point_in_center()
    --HUD.DISPLAY_SNIPER_SCOPE_THIS_FRAME()
    --directx.draw_texture(Texture.point, 0.0016, 0, 0.5, 0.5, 0.5, 0.5, 0, color.white)
    directx.draw_texture(Texture.crosshair, 0.03, 0.03, 0.5, 0.5, 0.5, 0.5, 0, color.white)
end

-----------------------------
-- Camera & Aim Functions
-----------------------------

---@param distance number
---@return v3
function get_offset_from_cam(distance)
    local rot = CAM.GET_FINAL_RENDERED_CAM_ROT(2)
    local pos = CAM.GET_FINAL_RENDERED_CAM_COORD()
    local dir = rot:toDir()
    dir:mul(distance)
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

---@class RaycastResult
---@field didHit boolean
---@field endCoords v3
---@field surfaceNormal v3
---@field hitEntity Entity
---@param distance number
---@param flag? integer
---@return RaycastResult
function get_raycast_result(distance, flag)
    local result = {}
    flag = flag or TraceFlag.everything
    local didHit = memory.alloc(1)
    local endCoords = v3.new()
    local normal = v3.new()
    local hitEntity = memory.alloc_int()
    local camPos = CAM.GET_FINAL_RENDERED_CAM_COORD()
    local offset = get_offset_from_cam(distance)

    local handle = SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(camPos.x, camPos.y, camPos.z, offset.x,
        offset.y, offset.z, flag, players.user_ped(), 7)
    SHAPETEST.GET_SHAPE_TEST_RESULT(handle, didHit, memory.addrof(endCoords), memory.addrof(normal), hitEntity)

    result.didHit = memory.read_byte(didHit) ~= 0
    result.endCoords = endCoords
    result.surfaceNormal = normal
    result.hitEntity = memory.read_int(hitEntity)
    return result
end

---返回玩家正在瞄准的实体
---@param player player
---@return Entity|nil
function get_entity_player_is_aiming_at(player)
    local ent = nil
    if PLAYER.IS_PLAYER_FREE_AIMING(player) then
        local ptr = memory.alloc_int()
        if PLAYER.GET_ENTITY_PLAYER_IS_FREE_AIMING_AT(player, ptr) then
            ent = memory.read_int(ptr)

            if ENTITY.IS_ENTITY_A_PED(ent) and PED.IS_PED_IN_ANY_VEHICLE(ent) then
                local vehicle = PED.GET_VEHICLE_PED_IS_IN(ent, false)
                ent = vehicle
            end
        end
    end
    return ent
end

-----------------------------
-- Misc Functions
-----------------------------

---坐标计算
Vector = {
    ['new'] = function(x, y, z)
        return { ['x'] = x, ['y'] = y, ['z'] = z }
    end,
    --return a - b
    ['subtract'] = function(a, b)
        return Vector.new(a.x - b.x, a.y - b.y, a.z - b.z)
    end,
    --return a + b
    ['add'] = function(a, b)
        return Vector.new(a.x + b.x, a.y + b.y, a.z + b.z)
    end,
    ['mag'] = function(a)
        return math.sqrt(a.x ^ 2 + a.y ^ 2 + a.z ^ 2)
    end,
    ['norm'] = function(a)
        local mag = Vector.mag(a)
        return Vector.div(a, mag)
    end,
    --return a * b
    ['mult'] = function(a, b)
        return Vector.new(a.x * b, a.y * b, a.z * b)
    end,
    --return a / b
    ['div'] = function(a, b)
        return Vector.new(a.x / b, a.y / b, a.z / b)
    end,
    --return the distance between two vectors
    ['dist'] = function(a, b)
        return Vector.mag(Vector.subtract(a, b))
    end
}

---计算模型大小，返回 long, width, height
---@param model Hash
---@return number
---@return number
---@return number
function calculate_model_size(model)
    local minVec = v3.new()
    local maxVec = v3.new()
    MISC.GET_MODEL_DIMENSIONS(model, minVec, maxVec)
    return (maxVec:getX() - minVec:getX()), (maxVec:getY() - minVec:getY()), (maxVec:getZ() - minVec:getZ())
end

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

---@param bool boolean
---@return string
function bool_to_string(bool)
    if bool then
        return "是"
    else
        return "否"
    end
end

-------------------------
-- Table Functions
-------------------------

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

-----------------------------
-- Notification Functions
-----------------------------

THEFEED_POST = {}

---@param message string
function THEFEED_POST.TEXT(message)
    util.BEGIN_TEXT_COMMAND_THEFEED_POST(message)
    HUD.END_TEXT_COMMAND_THEFEED_POST_TICKER(false, false)
end

-----------------------------
-- Fun Functions
-----------------------------

---实体坠落爆炸
---@param entity Entity
---@param owner Ped
function fall_entity_explosion(entity, owner)
    ENTITY.FREEZE_ENTITY_POSITION(entity, false)
    ENTITY.SET_ENTITY_MAX_SPEED(entity, 99999.0)

    if ENTITY.IS_ENTITY_A_PED(entity) then
        TASK.CLEAR_PED_TASKS_IMMEDIATELY(entity)
        PED.SET_PED_TO_RAGDOLL(entity, 500, 500, 0, false, false, false)
    end
    ENTITY.APPLY_FORCE_TO_ENTITY(entity, 1, 0.0, 0.0, 30.0, math.random(-2, 2), math.random(-2, 2), 0.0, 0, false,
        false
        , true, false, false)
    util.yield(1000)
    ENTITY.APPLY_FORCE_TO_ENTITY(entity, 1, 0.0, 0.0, -100.0, 0.0, 0.0, 0.0, 0, false, false, true, false, false)
    util.yield(300)

    local coords = ENTITY.GET_ENTITY_COORDS(entity)
    if owner then
        FIRE.ADD_OWNED_EXPLOSION(owner, coords.x, coords.y, coords.z, 4, 1.0, true, false, 0.0)
    else
        FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, 4, 1.0, true, false, 0.0, false)
    end
end
