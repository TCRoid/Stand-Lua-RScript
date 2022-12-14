--------------------------------------------
-- Alternative for Native Functions
--------------------------------------------

---@param entity Entity
---@param coords v3
function SET_ENTITY_COORDS(entity, coords)
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entity, coords.x, coords.y, coords.z, true, false, false)
end

---@param vehicle Vehicle
---@param seat number
---@return Ped
function GET_PED_IN_VEHICLE_SEAT(vehicle, seat)
    if not VEHICLE.IS_VEHICLE_SEAT_FREE(vehicle, seat, false) then
        return VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, seat)
    end
    return false
end

---@param ped Ped
---@return Vehicle
function GET_VEHICLE_PED_IS_IN(ped)
    if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
        return PED.GET_VEHICLE_PED_IS_IN(ped, false)
    end
    return false
end

---@param start_pos v3
---@param end_pos v3
---@param colour? Colour 0-255
function DRAW_LINE(start_pos, end_pos, colour)
    colour = colour or { r = 255, g = 0, b = 255, a = 255 }
    GRAPHICS.DRAW_LINE(start_pos.x, start_pos.y, start_pos.z, end_pos.x, end_pos.y, end_pos.z, colour.r, colour.g,
        colour.b, colour.a)
end

---Creates an explosion at the co-ordinates.
---Default `explosionType` = 2
---@param coords v3
---@param explosionType? integer
---@param add_explosion_Params? table
---@class add_explosion_Params
---@field damageScale float
---@field isAudible boolean
---@field isVisible boolean
---@field cameraShake float
---@field noDamage boolean
function add_explosion(coords, explosionType, add_explosion_Params)
    if explosionType == nil then explosionType = 2 end
    Params = add_explosion_Params or {}
    Params.damageScale = Params.damageScale or 1.0
    if Params.isAudible == nil then Params.isAudible = true end
    Params.cameraShake = Params.cameraShake or 0.0

    FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z,
        explosionType,
        Params.damageScale, Params.isAudible, Params.isInvisible, Params.cameraShake, Params.noDamage)
end

---Creates an explosion at the co-ordinates owned by a specific ped.
---Default `explosionType` = 2
---@param owner Ped
---@param coords v3
---@param explosionType? integer
---@param add_own_explosion_Params? table
---@class add_own_explosion_Params
---@field damageScale float
---@field isAudible boolean
---@field isVisible boolean
---@field cameraShake float
function add_own_explosion(owner, coords, explosionType, add_own_explosion_Params)
    if explosionType == nil then explosionType = 2 end
    Params = add_own_explosion_Params or {}
    Params.damageScale = Params.damageScale or 1.0
    if Params.isAudible == nil then Params.isAudible = true end
    Params.cameraShake = Params.cameraShake or 0.0

    FIRE.ADD_OWNED_EXPLOSION(owner, coords.x, coords.y, coords.z,
        explosionType,
        Params.damageScale, Params.isAudible, Params.isInvisible, Params.cameraShake)
end

---Fires an instant hit bullet between the two points taking into account an entity to ignore for damage.
---@param startCoords v3
---@param endCoords v3
---@param shoot_single_bullet_Params? table
---@class shoot_single_bullet_Params
---@field damage integer
---@field perfectAccuracy boolean
---@field weaponHash Hash
---@field owner Ped
---@field CreateTraceVfx boolean
---@field AllowRumble boolean
---@field speed integer
---@field ignoreEntity Entity
function shoot_single_bullet(startCoords, endCoords, shoot_single_bullet_Params)
    Params = shoot_single_bullet_Params or {}
    Params.damage = Params.damage or 1000
    Params.weaponHash = Params.weaponHash or 4058111347
    Params.owner = Params.owner or 0
    if Params.CreateTraceVfx == nil then Params.CreateTraceVfx = true end
    if Params.AllowRumble == nil then Params.AllowRumble = true end
    Params.speed = Params.speed or 1000
    Params.ignoreEntity = Params.ignoreEntity or 0

    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(startCoords.x, startCoords.y, startCoords.z,
        endCoords.x, endCoords.y, endCoords.z,
        Params.damage, Params.perfectAccuracy, Params.weaponHash, Params.owner,
        Params.CreateTraceVfx, Params.AllowRumble, Params.speed, Params.ignoreEntity)
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
    if veh then
        tp = veh
    end
    SET_ENTITY_COORDS(tp, v3.new(x, y, z))

    if heading ~= nil then
        ENTITY.SET_ENTITY_HEADING(tp, heading)
    end
end

---??????/?????????????????????
---@param heading? float
---@return float
function PLAYER_HEADING(heading)
    if heading ~= nil then
        ENTITY.SET_ENTITY_HEADING(players.user_ped(), heading)
    end

    return ENTITY.GET_ENTITY_HEADING(players.user_ped())
end

---??????????????????
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

---??????????????????
---@param ent Entity
---@param offsetX? float
---@param offsetY? float
---@param offsetZ? float
function TP_TO_ENTITY(ent, offsetX, offsetY, offsetZ)
    if offsetX == nil then offsetX = 0.0 end
    if offsetY == nil then offsetY = 0.0 end
    if offsetZ == nil then offsetZ = 0.0 end
    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, offsetX, offsetY, offsetZ)


    local tp = players.user_ped()
    local veh = GET_VEHICLE_PED_IS_IN(tp)
    if veh then
        tp = veh
    end
    SET_ENTITY_COORDS(tp, coords)
end

---???????????????????????????
---@param ent Entity
---@param door? string
---@param driver? string
---
--- "delete": ????????????, "open": ????????????
---
--- "tp": ?????????????????????, "delete": ????????????
function TP_INTO_VEHICLE(ent, door, driver)
    if ENTITY.IS_ENTITY_A_VEHICLE(ent) then
        --unlock doors
        VEHICLE.SET_VEHICLE_DOORS_LOCKED(ent, 1)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(ent, false)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_PLAYER(ent, players.user(), false)
        --driver
        local ped = GET_PED_IN_VEHICLE_SEAT(ent, -1)
        if ped then
            if driver == "tp" then
                local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, 0.0, 5.0, 3.0)
                ENTITY.SET_ENTITY_COORDS(ped, coords.x, coords.y, coords.z, true, false, false, false)
            elseif driver == "delete" then
                entities.delete_by_handle(ped)
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

-----------------------------
-- Entity Functions
-----------------------------

---??????????????????
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
            util.yield(100)
        end
    end
    return NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity)
end

---?????????????????????
---@param Ped Ped
---@return boolean
function IS_PED_PLAYER(Ped)
    if PED.GET_PED_TYPE(Ped) >= 4 then
        return false
    else
        return true
    end
end

---???????????????????????????
---@param vehicle Vehicle
---@return boolean
function IS_PLAYER_VEHICLE(vehicle)
    if vehicle == entities.get_user_vehicle_as_handle() or vehicle == entities.get_user_personal_vehicle_as_handle() then
        return true
    elseif not VEHICLE.IS_VEHICLE_SEAT_FREE(vehicle, -1, false) then
        local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
        if ped > 0 then
            if IS_PED_PLAYER(ped) then
                return true
            end
        end
    end
    return false
end

---?????????????????????
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

---???????????????????????????
---@param entity Entity
---@return boolean
function IS_HOSTILE_ENTITY(entity)
    if ENTITY.DOES_ENTITY_EXIST(entity) then
        local blip = HUD.GET_BLIP_FROM_ENTITY(entity)
        if HUD.DOES_BLIP_EXIST(blip) then
            local blip_color = HUD.GET_BLIP_COLOUR(blip)
            if isInTable(Blip_Color_Red, blip_color) then
                return true
            end
        end

        if ENTITY.IS_ENTITY_A_PED(entity) then
            if PED.IS_PED_IN_COMBAT(entity, players.user_ped()) then
                return true
            end
        elseif ENTITY.IS_ENTITY_A_VEHICLE(entity) then
            local driver = GET_PED_IN_VEHICLE_SEAT(entity, -1)
            if driver and PED.IS_PED_IN_COMBAT(driver, players.user_ped()) then
                return true
            end
        end

    end
    return false
end

---?????????????????? (String)
---
---text_type: 1 ??????, 2 ???????????????, 3 ??????
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

---??????????????????????????????????????????
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
---???????????????????????????????????????????????????
function SET_ENTITY_HEAD_TO_ENTITY(set_ent, to_ent, angle)
    if angle == nil then angle = 0.0 end
    local Head = ENTITY.GET_ENTITY_HEADING(to_ent)
    ENTITY.SET_ENTITY_HEADING(set_ent, Head + angle)
end

---@param tp_ent Entity
---@param to_ent Entity
---@param x? float
---@param y? float
---@param z? float
---??????????????????????????????????????????/?????????/?????????/???
function TP_ENTITY_TO_ENTITY(tp_ent, to_ent, x, y, z)
    if x == nil then x = 0.0 end
    if y == nil then y = 0.0 end
    if z == nil then z = 0.0 end
    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(to_ent, x, y, z)
    SET_ENTITY_COORDS(tp_ent, coords)
end

---@param ent Entity
---@param canMigrate? boolean
---@return boolean
function Set_Entity_Networked(ent, canMigrate)
    if ENTITY.DOES_ENTITY_EXIST(ent) then
        if canMigrate == nil then canMigrate = true end

        ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(obj, true, 1)
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

---?????????????????????????????????
---@param Type string
---@return table
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

---??????Model Hash????????????
---@param Type string
---@param isMission boolean
---@return table
function GetEntity_ByModelHash(Type, isMission, ...)
    local all_entity = get_all_entities(Type)

    local entity_list = {}
    local arg = { ... } --Hash list

    for k, ent in pairs(all_entity) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        for _, Hash in pairs(arg) do
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
function Set_Entity_Godmode(ent, toggle)
    ENTITY.SET_ENTITY_INVINCIBLE(ent, toggle)
    ENTITY.SET_ENTITY_PROOFS(ent, toggle, toggle, toggle, toggle, toggle, toggle, toggle, toggle)
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
    Request_Model(modelHash)
    local ped = PED.CREATE_PED(pedType, modelHash, x, y, z, heading, true, true)

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
    Request_Model(modelHash)
    local veh = VEHICLE.CREATE_VEHICLE(modelHash, x, y, z, heading, true, true, true)

    VEHICLE.SET_VEHICLE_ENGINE_ON(veh, true, true, false)
    VEHICLE.SET_VEHICLE_STAYS_FROZEN_WHEN_CLEANED_UP(veh, true)
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
    Request_Model(modelHash)
    local pickup = OBJECT.CREATE_AMBIENT_PICKUP(pickupHash, x, y, z, 4, value, modelHash, false, true)

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
    Request_Model(modelHash)
    local obj = OBJECT.CREATE_OBJECT_NO_OFFSET(modelHash, x, y, z, true, true, false)

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

---???????????????????????????????????????
---@param vehicle Vehicle
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

---????????????
---@param vehicle Vehicle
function Fix_Vehicle(vehicle)
    if ENTITY.DOES_ENTITY_EXIST(vehicle) and ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        VEHICLE.SET_VEHICLE_FIXED(vehicle)
        VEHICLE.SET_VEHICLE_DEFORMATION_FIXED(vehicle)
        VEHICLE.SET_VEHICLE_DIRT_LEVEL(vehicle, 0.0)
        VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, 1000.0)
    end
end

---??????????????????????????????
---
---nodeType: 0 = main roads, 1 = any dry path, 3 = water
---@param pos v3
---@param nodeType integer
---@return boolean, v3, float
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

---?????????????????????Ped
---@param vehicle Vehicle
---@return integer
---@return table
function Get_Peds_In_Vehicle(vehicle)
    local num = 0
    local peds = {}
    if ENTITY.DOES_ENTITY_EXIST(vehicle) and ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        local hash = ENTITY.GET_ENTITY_MODEL(vehicle)
        local seats = VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(hash)
        for i = -1, seats - 2 do
            if not VEHICLE.IS_VEHICLE_SEAT_FREE(vehicle, i, false) then
                local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, i)

                num = num + 1
                table.insert(peds, ped)
            end
        end
    end
    return num, peds
end

-----------------------------
-- Ped Functions
-----------------------------

---??????NPC????????????
---@param ped Ped
---@param isGodmode boolean?
---@param canRagdoll boolean?
function Increase_Ped_Combat_Ability(ped, isGodmode, canRagdoll)
    if isGodmode == nil then isGodmode = false end
    if canRagdoll == nil then canRagdoll = true end

    if ENTITY.DOES_ENTITY_EXIST(ped) and ENTITY.IS_ENTITY_A_PED(ped) then
        ENTITY.SET_ENTITY_INVINCIBLE(ped, isGodmode)
        ENTITY.SET_ENTITY_PROOFS(ped, isGodmode, isGodmode, isGodmode, isGodmode, isGodmode, isGodmode, isGodmode,
            isGodmode)
        PED.SET_PED_CAN_RAGDOLL(ped, canRagdoll)

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

        WEAPON.SET_PED_INFINITE_AMMO_CLIP(ped, true)
        PED.SET_PED_SHOOT_RATE(ped, 1000)
        PED.SET_PED_ACCURACY(ped, 100)

        -- PED.SET_PED_COMBAT_MOVEMENT(ped, 2) --WillAdvance
        PED.SET_PED_COMBAT_ABILITY(ped, 2) --Professional
        PED.SET_PED_COMBAT_RANGE(ped, 2) --Far
        PED.SET_PED_TARGET_LOSS_RESPONSE(ped, 1) --NeverLoseTarget

        PED.SET_PED_FLEE_ATTRIBUTES(ped, 512, true) -- NeverFlee
    end
end

---??????NPC????????????
---@param ped Ped
function Increase_Ped_Combat_Attributes(ped)
    if ENTITY.DOES_ENTITY_EXIST(ped) and ENTITY.IS_ENTITY_A_PED(ped) then
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 0, true) --Use Cover
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 1, true) --Use Vehicle
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 4, true) --Can Use Dynamic Strafe Decisions
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 5, true) --Always Fight
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 13, true) --Aggressive
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 17, false) --Always Flee
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 20, true) --Can Taunt In Vehicle
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 21, true) --Can Chase Target On Foot
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 24, true) --Use Proximity Firing Rate
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 27, true) --Perfect Accuracy
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 39, true) --Can Bust
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 41, true) --Can Commandeer Vehicles
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 42, true) --Can Flank
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true) --Can Fight Armed Peds When Not Armed
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 49, false) --Use Enemy Accuracy Scaling
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 52, true) --Use Vehicle Attack
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 53, true) --Use Vehicle Attack If Vehicle Has Mounted Guns
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 54, true) --Always Equip Best Weapon
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 55, true) --Can See Underwater Peds
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 58, true) --Disable Flee From Combat
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 60, true) --Can Throw Smoke Grenade
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 78, true) --Disable All Randoms Flee
    end
end

---@param ped Ped
function Clear_Ped_All_Tasks(ped)
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
function Disable_Ped_Flee(ped)
    if ENTITY.DOES_ENTITY_EXIST(ped) and ENTITY.IS_ENTITY_A_PED(ped) then
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 6, false) -- FLEE_WHILST_IN_VEHICLE
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 17, false) -- ALWAYS_FLEE
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true) -- CAN_FIGHT_ARMED_PEDS_WHEN_NOT_ARMED
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 58, true) -- DISABLE_FLEE_FROM_COMBAT
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 78, true) -- DISABLE_ALL_RANDOMS_FLEE

        PED.SET_PED_FLEE_ATTRIBUTES(ped, 512, true) -- NEVER_FLEE
    end
end

-----------------------------
-- Blip Functions
-----------------------------

---?????????????????????
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

---?????????????????????
---@param blip Blip
---@return string
function GET_BLIP_TYPE(blip)
    if not HUD.DOES_BLIP_EXIST(blip) then
        return ""
    end

    local blip_type = HUD.GET_BLIP_INFO_ID_TYPE(blip)
    return enum_BlipType[blip_type + 1]
end

---??????????????????????????????
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

---???????????????????????????
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

---?????????????????????????????????????????????
---@param ent Entity
---@param blipSprite integer
---@param colour integer
---@param time integer ms
function SHOW_BLIP_TIMER(ent, blipSprite, colour, time)
    util.create_thread(function()
        local blip = HUD.GET_BLIP_FROM_ENTITY(ent)
        --no blip
        if blip == 0 then
            blip = HUD.ADD_BLIP_FOR_ENTITY(ent)
            HUD.SET_BLIP_SPRITE(blip, blipSprite)
            HUD.SET_BLIP_COLOUR(blip, colour)
            util.yield(time)
            util.remove_blip(blip)
        end
    end)
end

-------------------------------
-- Streaming Functions
-------------------------------

---????????????
---@param Hash Hash
function Request_Model(Hash)
    if STREAMING.IS_MODEL_VALID(Hash) then
        STREAMING.REQUEST_MODEL(Hash)
        while not STREAMING.HAS_MODEL_LOADED(Hash) do
            STREAMING.REQUEST_MODEL(Hash)
            util.yield()
        end
    end
end

---??????????????????
---@param Hash Hash
function Request_Weapon_Asset(Hash)
    if WEAPON.IS_WEAPON_VALID(Hash) then
        WEAPON.REQUEST_WEAPON_ASSET(Hash, 31, 0)
        while not WEAPON.HAS_WEAPON_ASSET_LOADED(Hash) do
            WEAPON.REQUEST_WEAPON_ASSET(Hash, 31, 0)
            util.yield()
        end
    end
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
---@param scale? float
---@param margin? float
---@param text_color? Color
---@param background_color? Color
function draw_text_box(text, x, y, scale, margin, text_color, background_color)
    if scale == nil then scale = 0.5 end
    if margin == nil then margin = 0.01 end
    if text_color == nil then text_color = color.white end
    if background_color == nil then background_color = { r = 0.0, g = 0.0, b = 0.0, a = 0.6 } end

    local text_width, text_height = directx.get_text_size(text, scale)
    directx.draw_rect(x, y, text_width + margin * 2, text_height + margin * 2, background_color)
    directx.draw_text(x + margin, y + margin, text, ALIGN_TOP_LEFT, scale, text_color)
end

---@param text string
---@param scale? float
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

function draw_point_in_center()
    directx.draw_texture(Texture.point, 0.0016, 0, 0.5, 0.5, 0.5, 0.5, 0, color.white)
end

-----------------------------
-- Other Functions
-----------------------------

---????????????
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

---@param bool boolean
---@return string
function bool_to_string(bool)
    if bool then
        return "???"
    else
        return "???"
    end
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

---@class RaycastResult
---@field didHit boolean
---@field endCoords v3
---@field surfaceNormal v3
---@field hitEntity Entity
---@param dist number
---@param flag? integer
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

---?????????????????????????????????
---@param player player
---@return Entity|nil
function GetEntity_PlayerIsAimingAt(player)
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

-------------------------
-- Table Functions
-------------------------

---???????????? ???????????????????????????
function isInTable(tbl, value)
    for k, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

---???????????????????????????????????????????????????
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
