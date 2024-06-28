----------------------------------------
-- Local Player Functions
----------------------------------------

--- 传送玩家
--- @param coords v3
--- @param heading? float
function teleport(coords, heading)
    local ent = entities.get_user_vehicle_as_handle(false)
    if ent == INVALID_GUID then
        ent = players.user_ped()
    end

    TP_ENTITY(ent, coords, heading)
end

--- 传送玩家
--- @param x float
--- @param y float
--- @param z float
--- @param heading? float
function teleport2(x, y, z, heading)
    teleport(v3.new(x, y, z), heading)
end

--- 设置/获取玩家朝向
--- @param heading? float
--- @return float
function user_heading(heading)
    local ent = entities.get_user_vehicle_as_handle(false)
    if ent == INVALID_GUID then
        ent = players.user_ped()
    end

    if heading ~= nil then
        ENTITY.SET_ENTITY_HEADING(ent, heading)
        return heading
    end
    return ENTITY.GET_ENTITY_HEADING(ent)
end

--- 获取玩家室内ID，不在室内则返回-1
--- @return integer
function user_interior()
    if INTERIOR.IS_INTERIOR_SCENE() then
        return INTERIOR.GET_INTERIOR_FROM_ENTITY(players.user_ped())
    end
    return -1
end

--- 传送实体到玩家 `offset`: 左/右，前/后，上/下
--- @param entity Entity
--- @param offsetX? float
--- @param offsetY? float
--- @param offsetZ? float
function tp_entity_to_me(entity, offsetX, offsetY, offsetZ)
    offsetX = offsetX or 0.0
    offsetY = offsetY or 0.0
    offsetZ = offsetZ or 0.0
    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), offsetX, offsetY, offsetZ)
    TP_ENTITY(entity, coords)
end

--- 传送玩家到实体 `offset`: 左/右，前/后，上/下
--- @param entity Entity
--- @param offsetX? float
--- @param offsetY? float
--- @param offsetZ? float
function tp_to_entity(entity, offsetX, offsetY, offsetZ)
    offsetX = offsetX or 0.0
    offsetY = offsetY or 0.0
    offsetZ = offsetZ or 0.0
    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, offsetX, offsetY, offsetZ)
    teleport(coords)
end

--- 玩家传送进载具
--- @param vehicle Vehicle
--- @param door? string *delete* : 删除车门
--- @param driver? string *tp* : 传送司机到外面, *delete* : 删除司机
--- @param seat? int default: -1
function tp_into_vehicle(vehicle, door, driver, seat)
    seat = seat or -1

    unlock_vehicle_doors(vehicle)
    clear_vehicle_wanted(vehicle)
    -- unfreeze
    ENTITY.FREEZE_ENTITY_POSITION(vehicle, false)
    VEHICLE.SET_VEHICLE_UNDRIVEABLE(vehicle, false)

    if door == "delete" then
        VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, 0, true) -- left front door
    end

    if driver ~= nil then
        local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, seat)
        if ped ~= 0 then
            if driver == "tp" then
                set_entity_move(ped, 0.0, 5.0, 3.0)
            elseif driver == "delete" then
                entities.delete(ped)
            end
        end
    end

    VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, false)
    VEHICLE.SET_HELI_BLADES_FULL_SPEED(vehicle)

    PED.SET_PED_INTO_VEHICLE(players.user_ped(), vehicle, seat)
end

--- 传送载具到玩家，玩家传送进载具
--- @param vehicle Vehicle
--- @param door? string *delete* : 删除车门
--- @param driver? string *tp* : 传送司机到外面, *delete* : 删除司机
--- @param seat? int default: -1
function tp_vehicle_to_me(vehicle, door, driver, seat)
    ENTITY_HEADING(vehicle, user_heading())
    tp_entity_to_me(vehicle)
    tp_into_vehicle(vehicle, door, driver, seat)
end

--- 传送拾取物到玩家
--- @param pickup Pickup
--- @param attachToSelf? boolean
function tp_pickup_to_me(pickup, attachToSelf)
    if ENTITY.IS_ENTITY_ATTACHED(pickup) then
        ENTITY.DETACH_ENTITY(pickup, true, true)
        ENTITY.SET_ENTITY_VISIBLE(pickup, true, false)
    end
    OBJECT.SET_PICKUP_OBJECT_COLLECTABLE_IN_VEHICLE(pickup)

    if attachToSelf then
        OBJECT.ATTACH_PORTABLE_PICKUP_TO_PED(pickup, players.user_ped())
    else
        tp_entity_to_me(pickup)
    end
end

--- 玩家与实体绘制连线
--- @param entity Entity
--- @param colour Colour?
function draw_line_to_entity(entity, colour)
    local player_pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    local ent_pos = ENTITY.GET_ENTITY_COORDS(entity)
    DRAW_LINE(player_pos, ent_pos, colour)
end

----------------------------------------
-- Entity Functions
----------------------------------------

--- 获取实体类型 (Integer)
--- @param entity Entity
--- @return ENTITY_TYPE
function get_entity_type(entity)
    if not ENTITY.DOES_ENTITY_EXIST(entity) or not ENTITY.IS_AN_ENTITY(entity) then
        return ENTITY_NONE
    end

    if ENTITY.IS_ENTITY_A_PED(entity) then
        return ENTITY_PED
    end

    if ENTITY.IS_ENTITY_A_VEHICLE(entity) then
        return ENTITY_VEHICLE
    end

    if ENTITY.IS_ENTITY_AN_OBJECT(entity) then
        if OBJECT.IS_OBJECT_A_PICKUP(entity) or OBJECT.IS_OBJECT_A_PORTABLE_PICKUP(entity) then
            return ENTITY_PICKUP
        end
        return ENTITY_OBJECT
    end

    return ENTITY_NONE
end

--- 获取实体类型 (String)
---
--- `text_type`: 1 小写, 2 首字母大写, 3 大写 (默认: 2)
--- @param entity Entity
--- @param textType integer?
--- @return string
function get_entity_type_text(entity, textType)
    local entity_type_list = {
        [ENTITY_NONE] = "No Entity",
        [ENTITY_PED] = "Ped",
        [ENTITY_VEHICLE] = "Vehicle",
        [ENTITY_OBJECT] = "Object",
        [ENTITY_PICKUP] = "Pickup"
    }

    local entity_type = get_entity_type(entity)
    entity_type = entity_type_list[entity_type]

    if textType == 1 then
        return string.lower(entity_type)
    end
    if textType == 3 then
        return string.upper(entity_type)
    end
    return entity_type
end

---设置实体左/右、前/后、上/下移动
--- @param entity Entity
--- @param offsetX float
--- @param offsetY float
--- @param offsetZ float
function set_entity_move(entity, offsetX, offsetY, offsetZ)
    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, offsetX, offsetY, offsetZ)
    TP_ENTITY(entity, coords)
end

---设置实体与目标实体之间的朝向角度差
--- @param setEntity Entity
--- @param toEntity Entity
--- @param angle? float
function set_entity_heading_to_entity(setEntity, toEntity, angle)
    angle = angle or 0.0
    local heading = ENTITY.GET_ENTITY_HEADING(toEntity)
    ENTITY.SET_ENTITY_HEADING(setEntity, heading + angle)
end

---传送实体到目标实体 `offset`: 左/右，前/后，上/下
--- @param tpEntity Entity
--- @param toEntity Entity
--- @param offsetX? float
--- @param offsetY? float
--- @param offsetZ? float
function tp_entity_to_entity(tpEntity, toEntity, offsetX, offsetY, offsetZ)
    offsetX = offsetX or 0.0
    offsetY = offsetY or 0.0
    offsetZ = offsetZ or 0.0
    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(toEntity, offsetX, offsetY, offsetZ)
    TP_ENTITY(tpEntity, coords)
end

--- @param entity Entity
--- @param toggle boolean
function set_entity_godmode(entity, toggle)
    if not ENTITY.DOES_ENTITY_EXIST(entity) then
        return false
    end

    ENTITY.SET_ENTITY_INVINCIBLE(entity, toggle)
    ENTITY.SET_ENTITY_PROOFS(entity, toggle, toggle, toggle, toggle, toggle, toggle, toggle, toggle)
    ENTITY.SET_ENTITY_CAN_BE_DAMAGED(entity, not toggle)
end

----------------------------------------
-- Get Entities Functions
----------------------------------------

--- 获取对应类型的所有实体
--- @param entityType ENTITY_TYPE
--- @return table<int, Entity>
function get_all_entities(entityType)
    if entityType == ENTITY_PED then
        return entities.get_all_peds_as_handles()
    end
    if entityType == ENTITY_VEHICLE then
        return entities.get_all_vehicles_as_handles()
    end
    if entityType == ENTITY_OBJECT then
        return entities.get_all_objects_as_handles()
    end
    if entityType == ENTITY_PICKUP then
        return entities.get_all_pickups_as_handles()
    end

    return {}
end

--- 获取对应类型的所有实体指针
--- @param entityType ENTITY_TYPE
--- @return table<int, pointer>
function get_all_entities_as_pointers(entityType)
    if entityType == ENTITY_PED then
        return entities.get_all_peds_as_pointers()
    end
    if entityType == ENTITY_VEHICLE then
        return entities.get_all_vehicles_as_pointers()
    end
    if entityType == ENTITY_OBJECT then
        return entities.get_all_objects_as_pointers()
    end
    if entityType == ENTITY_PICKUP then
        return entities.get_all_pickups_as_pointers()
    end

    return {}
end

--- 通过 model hash 获取实体
--- @param entityType ENTITY_TYPE
--- @param isMission boolean
--- @param ... Hash
--- @return table<int, Entity>
function get_entities_by_hash(entityType, isMission, ...)
    local entity_list = {}
    local hash_list = { ... }

    for key, entity_ptr in pairs(get_all_entities_as_pointers(entityType)) do
        local entity_hash = entities.get_model_hash(entity_ptr)
        for _, hash in pairs(hash_list) do
            if entity_hash == hash then
                local entity = entities.pointer_to_handle(entity_ptr)

                if isMission then
                    if ENTITY.IS_ENTITY_A_MISSION_ENTITY(entity) then
                        table.insert(entity_list, entity)
                    end
                else
                    table.insert(entity_list, entity)
                end
            end
        end
    end

    return entity_list
end

--- 通过 model hash 获取指定脚本的任务实体
--- @param entityType ENTITY_TYPE
--- @param scriptName string
--- @param ... Hash
--- @return table<int, Entity>
function get_mission_entities_by_hash(entityType, scriptName, ...)
    if not IS_SCRIPT_RUNNING(scriptName) then
        return {}
    end

    local entity_list = {}
    local hash_list = { ... }

    for key, entity_ptr in pairs(get_all_entities_as_pointers(entityType)) do
        local entity_hash = entities.get_model_hash(entity_ptr)
        for _, hash in pairs(hash_list) do
            if entity_hash == hash then
                local entity = entities.pointer_to_handle(entity_ptr)

                if GET_ENTITY_SCRIPT(entity) == scriptName then
                    table.insert(entity_list, entity)
                end
            end
        end
    end

    return entity_list
end

--- 获取指定脚本的任务拾取物
--- @param scriptName string
--- @return table<int, Entity>
function get_mission_pickups(scriptName)
    if not IS_SCRIPT_RUNNING(scriptName) then
        return {}
    end

    local entity_list = {}
    for _, entity in pairs(entities.get_all_pickups_as_handles()) do
        if GET_ENTITY_SCRIPT(entity) == scriptName then
            table.insert(entity_list, entity)
        end
    end
    return entity_list
end

--- 获取距离坐标最近的实体
--- @param entityType ENTITY_TYPE
--- @param coords v3
--- @param isMission boolean? default: false
--- @param radius float? default: 100.0
--- @return Entity
function get_closest_entity(entityType, coords, isMission, radius)
    radius = radius or 100.0
    local closest_disance = 9999.0
    local closest_ent = 0

    for _, ent in pairs(get_all_entities(entityType)) do
        if isMission and not ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            goto continue
        end

        local ent_pos = ENTITY.GET_ENTITY_COORDS(ent)
        local distance = v3.distance(coords, ent_pos)
        if distance <= radius then
            if distance < closest_disance then
                closest_disance = distance
                closest_ent = ent
            end
        end

        ::continue::
    end

    return closest_ent
end

--- 获取坐标附近的实体
--- @param entityType ENTITY_TYPE
--- @param coords v3
--- @param radius float
--- @return table<int, Entity>
function get_nearby_entities(entityType, coords, radius)
    local entity_list = {}
    for _, ent in pairs(get_all_entities(entityType)) do
        local ent_pos = ENTITY.GET_ENTITY_COORDS(ent)
        if radius <= 0 then
            table.insert(entity_list, ent)
        elseif v3.distance(coords, ent_pos) <= radius then
            table.insert(entity_list, ent)
        end
    end
    return entity_list
end

----------------------------------------
-- Check Entity Functions
----------------------------------------

--- 判断是否为玩家
--- @param ped Ped
--- @return boolean
function is_player_ped(ped)
    return entities.is_player_ped(ped)
end

--- 判断是否为玩家载具
--- @param vehicle Vehicle
--- @return boolean
function is_player_vehicle(vehicle)
    if vehicle == entities.get_user_vehicle_as_handle() or vehicle == entities.get_user_personal_vehicle_as_handle() then
        return true
    end

    local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1, false)
    if driver ~= 0 then
        if is_player_ped(driver) then
            return true
        end
    end

    return false
end

--- 判断是否为实体
--- @param entity Entity
--- @return boolean
function IS_AN_ENTITY(entity)
    if ENTITY.DOES_ENTITY_EXIST(entity) then
        if ENTITY.IS_ENTITY_A_PED(entity) or ENTITY.IS_ENTITY_A_VEHICLE(entity) or ENTITY.IS_ENTITY_AN_OBJECT(entity) then
            return true
        end
    end
    return false
end

--- 判断是否为拾取物
--- @param entity Entity
--- @return boolean
function IS_ENTITY_A_PICKUP(entity)
    if ENTITY.IS_ENTITY_AN_OBJECT(entity) then
        if OBJECT.IS_OBJECT_A_PICKUP(entity) or OBJECT.IS_OBJECT_A_PORTABLE_PICKUP(entity) then
            return true
        end
    end
    return false
end

--- 判断是否为敌对实体
--- @param entity Entity
--- @return boolean
function is_hostile_entity(entity)
    if ENTITY.IS_ENTITY_A_PED(entity) then
        if is_hostile_ped(entity) then
            return true
        end
    end

    if ENTITY.IS_ENTITY_A_VEHICLE(entity) then
        local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(entity, -1)
        if is_hostile_ped(driver) then
            return true
        end
    end

    local blip = HUD.GET_BLIP_FROM_ENTITY(entity)
    if HUD.DOES_BLIP_EXIST(blip) then
        local blip_colour = HUD.GET_BLIP_COLOUR(blip)
        if blip_colour == 1 or blip_colour == 59 then -- red
            return true
        end
    end

    return false
end

----------------------------------------
-- Create Entity Functions
----------------------------------------

--- @param ped_type int
--- @param hash Hash
--- @param coords v3
--- @param heading float
--- @param is_networked boolean? [default = true]
--- @param is_mission boolean? [default = true]
--- @return Ped
function create_ped(ped_type, hash, coords, heading, is_networked, is_mission)
    if is_networked == nil then is_networked = true end
    if is_mission == nil then is_mission = true end

    request_model(hash)
    local ped = PED.CREATE_PED(ped_type, hash, coords.x, coords.y, coords.z, heading, is_networked, is_mission)

    ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(ped, true, 1)
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
            NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(net_id, pid, true)
        end
    end

    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
    return ped
end

--- @param hash Hash
--- @param coords v3
--- @param heading float
--- @param is_networked boolean? [default = true]
--- @param is_mission boolean? [default = true]
--- @return Vehicle
function create_vehicle(hash, coords, heading, is_networked, is_mission)
    if is_networked == nil then is_networked = true end
    if is_mission == nil then is_mission = true end

    request_model(hash)
    local veh = VEHICLE.CREATE_VEHICLE(hash, coords.x, coords.y, coords.z, heading, is_networked, is_mission, false)

    ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(veh, true, 1)
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
            NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(net_id, pid, true)
        end
    end

    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
    return veh
end

--- @param hash Hash
--- @param coords v3
--- @param is_networked boolean? [default = true]
--- @param is_mission boolean? [default = true]
--- @return Object
function create_object(hash, coords, is_networked, is_mission)
    if is_networked == nil then is_networked = true end
    if is_mission == nil then is_mission = true end

    request_model(hash)
    local obj = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, coords.x, coords.y, coords.z, is_networked, is_mission, false)

    ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(obj, true, 1)
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
            NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(net_id, pid, true)
        end
    end

    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
    return obj
end

----------------------------------------
-- Clone Entity Functions
----------------------------------------

---复制Ped
--- @param target_ped Ped
--- @param coords v3
--- @param heading float
--- @param is_networked boolean
--- @return Ped
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
--- @param target_vehicle Vehicle
--- @param clone_vehicle Vehicle
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
--- @param target_vehicle Vehicle
--- @param coords v3
--- @param heading float
--- @param is_networked boolean
--- @return Vehicle
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
--- @param target_object Object
--- @param coords v3
--- @param is_networked boolean
--- @return Object
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

----------------------------------------
-- Vehicle Functions
----------------------------------------

--- 升级载具（排除涂装、车轮）
--- @param vehicle Vehicle
function upgrade_vehicle(vehicle)
    if not ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        return
    end

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

--- 修复载具
--- @param vehicle Vehicle
function fix_vehicle(vehicle)
    if not ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        return
    end

    VEHICLE.SET_VEHICLE_FIXED(vehicle)
    VEHICLE.SET_VEHICLE_DEFORMATION_FIXED(vehicle)
    VEHICLE.SET_VEHICLE_DIRT_LEVEL(vehicle, 0.0)
    VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, 5000.0)
    SET_ENTITY_HEALTH(vehicle, ENTITY.GET_ENTITY_MAX_HEALTH(vehicle))
end

--- 强化载具
--- @param vehicle Vehicle
function strong_vehicle(vehicle)
    if not ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        return
    end

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
    VEHICLE.SET_DISABLE_DAMAGE_WITH_PICKED_UP_ENTITY(vehicle, 1)
    VEHICLE.SET_VEHICLE_USES_MP_PLAYER_DAMAGE_MULTIPLIER(vehicle, 1)
    VEHICLE.SET_FORCE_VEHICLE_ENGINE_DAMAGE_BY_BULLET(vehicle, false)

    --Explode
    VEHICLE.SET_VEHICLE_NO_EXPLOSION_DAMAGE_FROM_DRIVER(vehicle, true)
    VEHICLE.SET_DISABLE_EXPLODE_FROM_BODY_DAMAGE_ON_COLLISION(vehicle, 1)
    VEHICLE.SET_VEHICLE_EXPLODES_ON_HIGH_EXPLOSION_DAMAGE(vehicle, false)
    VEHICLE.SET_VEHICLE_EXPLODES_ON_EXPLOSION_DAMAGE_AT_ZERO_BODY_HEALTH(vehicle, false)
    VEHICLE.SET_ALLOW_VEHICLE_EXPLODES_ON_CONTACT(vehicle, false)

    --Heli
    VEHICLE.SET_HELI_TAIL_BOOM_CAN_BREAK_OFF(vehicle, false)
    VEHICLE.SET_DISABLE_HELI_EXPLODE_FROM_BODY_DAMAGE(vehicle, 1)

    --MP Only
    VEHICLE.SET_PLANE_RESIST_TO_EXPLOSION(vehicle, true)
    VEHICLE.SET_HELI_RESIST_TO_EXPLOSION(vehicle, true)

    --Remove Check
    VEHICLE.REMOVE_VEHICLE_UPSIDEDOWN_CHECK(vehicle)
    VEHICLE.REMOVE_VEHICLE_STUCK_CHECK(vehicle)
end

--- 解锁载具车门
--- @param vehicle Vehicle
function unlock_vehicle_doors(vehicle)
    if not ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        return
    end

    VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle, 1)
    VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(vehicle, false)
    VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_NON_SCRIPT_PLAYERS(vehicle, false)
    VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_TEAMS(vehicle, false)
    VEHICLE.SET_DONT_ALLOW_PLAYER_TO_ENTER_VEHICLE_IF_LOCKED_FOR_PLAYER(vehicle, false)

    VEHICLE.SET_VEHICLE_IS_CONSIDERED_BY_PLAYER(vehicle, true)
    VEHICLE.SET_VEHICLE_EXCLUSIVE_DRIVER(vehicle, 0, 0)
end

--- 清除载具通缉状态
--- @param vehicle Vehicle
function clear_vehicle_wanted(vehicle)
    if not ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        return
    end

    VEHICLE.SET_VEHICLE_HAS_BEEN_OWNED_BY_PLAYER(vehicle, true)
    VEHICLE.SET_VEHICLE_IS_STOLEN(vehicle, false)
    VEHICLE.SET_VEHICLE_IS_WANTED(vehicle, false)
    VEHICLE.SET_POLICE_FOCUS_WILL_TRACK_VEHICLE(vehicle, false)
    VEHICLE.SET_VEHICLE_INFLUENCES_WANTED_LEVEL(vehicle, false)
    VEHICLE.SET_DISABLE_WANTED_CONES_RESPONSE(vehicle, true)
end

--- 获取最近的载具生成点
--- - - -
--- `nodeType`: 0 = main roads, 1 = any dry path, 3 = water
--- @param coords v3
--- @param nodeType integer
--- @return boolean, v3, float
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

--- 获取随机的载具生成点
--- @param coords v3
--- @param radius float
--- @return boolean, v3, integer
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

--- 获取载具内所有Ped
---
--- 返回 ped num 和 ped table
--- @param vehicle Vehicle
--- @return integer, table<int, ped>
function get_vehicle_peds(vehicle)
    local num = 0
    local peds = {}
    if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
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

--- 通过载具Hash获取载具名称
--- @param modelHash Hash
--- @return string
function get_vehicle_display_name_by_hash(modelHash)
    if not STREAMING.IS_MODEL_VALID(modelHash) then
        return "NULL"
    end

    return util.get_label_text(VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(modelHash))
end

--- 获取载具名称
--- @param vehicle Vehicle
--- @return string
function get_vehicle_display_name(vehicle)
    if not ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        return "NULL"
    end

    local hash = ENTITY.GET_ENTITY_MODEL(vehicle)
    return util.get_label_text(VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(hash))
end

----------------------------------------
-- Ped Functions
----------------------------------------

--- 增强NPC作战能力
--- @param ped Ped
--- @param isGodmode boolean? [default = false]
--- @param canRagdoll boolean? [default = true]
function increase_ped_combat_ability(ped, isGodmode, canRagdoll)
    if not ENTITY.IS_ENTITY_A_PED(ped) then
        return
    end

    if isGodmode == nil then isGodmode = false end
    if canRagdoll == nil then canRagdoll = true end

    -- GODMODE
    ENTITY.SET_ENTITY_INVINCIBLE(ped, isGodmode)
    ENTITY.SET_ENTITY_PROOFS(ped, isGodmode, isGodmode, isGodmode, isGodmode, isGodmode, isGodmode, isGodmode,
        isGodmode)

    -- RAGDOLL
    PED.SET_PED_CAN_RAGDOLL(ped, canRagdoll)

    -- PERCEPTIVE
    PED.SET_PED_HIGHLY_PERCEPTIVE(ped, true)
    PED.SET_PED_VISUAL_FIELD_PERIPHERAL_RANGE(ped, 500.0)
    PED.SET_PED_SEEING_RANGE(ped, 500.0)
    PED.SET_PED_HEARING_RANGE(ped, 500.0)
    PED.SET_PED_ID_RANGE(ped, 500.0)
    PED.SET_PED_VISUAL_FIELD_MIN_ANGLE(ped, -180.0)
    PED.SET_PED_VISUAL_FIELD_MAX_ANGLE(ped, 180.0)
    PED.SET_PED_VISUAL_FIELD_MIN_ELEVATION_ANGLE(ped, -180.0)
    PED.SET_PED_VISUAL_FIELD_MAX_ELEVATION_ANGLE(ped, 180.0)
    PED.SET_PED_VISUAL_FIELD_CENTER_ANGLE(ped, 90.0)

    -- WEAPON
    PED.SET_PED_CAN_SWITCH_WEAPON(ped, true)
    WEAPON.SET_PED_INFINITE_AMMO_CLIP(ped, true)
    WEAPON.SET_EQIPPED_WEAPON_START_SPINNING_AT_FULL_SPEED(ped)

    -- COMBAT
    PED.SET_PED_SHOOT_RATE(ped, 1000)
    PED.SET_PED_ACCURACY(ped, 100)
    PED.SET_PED_COMBAT_ABILITY(ped, 2)       -- Professional
    PED.SET_PED_COMBAT_RANGE(ped, 2)         -- Far
    -- PED.SET_PED_COMBAT_MOVEMENT(ped, 2) -- Will Advance
    PED.SET_PED_TARGET_LOSS_RESPONSE(ped, 1) -- Never Lose Target

    -- COMBAT FLOAT
    PED.SET_COMBAT_FLOAT(ped, 6, 1.0) -- Weapon Accuracy
    PED.SET_COMBAT_FLOAT(ped, 7, 1.0) -- Fight Proficiency

    -- FLEE ATTRIBUTES
    PED.SET_PED_FLEE_ATTRIBUTES(ped, 512, true) -- Never Flee

    -- TASK PATH
    TASK.SET_PED_PATH_CAN_USE_CLIMBOVERS(ped, true)
    TASK.SET_PED_PATH_CAN_USE_LADDERS(ped, true)
    TASK.SET_PED_PATH_CAN_DROP_FROM_HEIGHT(ped, true)
    TASK.SET_PED_PATH_AVOID_FIRE(ped, false)
    TASK.SET_PED_PATH_MAY_ENTER_WATER(ped, true)

    -- CONFIG FLAG
    PED.SET_PED_CONFIG_FLAG(ped, 107, true)  -- Dont Activate Ragdoll From BulletImpact
    PED.SET_PED_CONFIG_FLAG(ped, 108, true)  -- Dont Activate Ragdoll From Explosions
    PED.SET_PED_CONFIG_FLAG(ped, 109, true)  -- Dont Activate Ragdoll From Fire
    PED.SET_PED_CONFIG_FLAG(ped, 110, true)  -- Dont Activate Ragdoll From Electrocution
    PED.SET_PED_CONFIG_FLAG(ped, 430, false) -- Ignore Being On Fire

    -- OTHER
    PED.SET_PED_SUFFERS_CRITICAL_HITS(ped, false) -- Disable Headshot
    PED.SET_DISABLE_HIGH_FALL_DEATH(ped, true)
end

--- 增强NPC作战属性
--- @param ped Ped
function increase_ped_combat_attributes(ped)
    if not ENTITY.IS_ENTITY_A_PED(ped) then
        return
    end

    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 4, true)   -- Can Use Dynamic Strafe Decisions
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 5, true)   -- Always Fight
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 6, false)  -- Flee Whilst In Vehicle
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 13, true)  -- Aggressive
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 14, true)  -- Can Investigate
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 17, false) -- Always Flee
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 20, true)  -- Can Taunt In Vehicle
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 21, true)  -- Can Chase Target On Foot
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 22, true)  -- Will Drag Injured Peds to Safety
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 24, true)  -- Use Proximity Firing Rate
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 27, true)  -- Perfect Accuracy
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 28, true)  -- Can Use Frustrated Advance
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 29, true)  -- Move To Location Before Cover Search
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 38, true)  -- Disable Bullet Reactions
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 39, true)  -- Can Bust
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 41, true)  -- Can Commandeer Vehicles
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 42, true)  -- Can Flank
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)  -- Can Fight Armed Peds When Not Armed
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 49, false) -- Use Enemy Accuracy Scaling
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 52, true)  -- Use Vehicle Attack
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 53, true)  -- Use Vehicle Attack If Vehicle Has Mounted Guns
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 54, true)  -- Always Equip Best Weapon
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 55, true)  -- Can See Underwater Peds
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 58, true)  -- Disable Flee From Combat
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 60, true)  -- Can Throw Smoke Grenade
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 78, true)  -- Disable All Randoms Flee
end

---清理NPC外观
--- @param ped Ped
function clear_ped_body(ped)
    if not ENTITY.IS_ENTITY_A_PED(ped) then
        return
    end

    PED.RESET_PED_VISIBLE_DAMAGE(ped)
    PED.CLEAR_PED_LAST_DAMAGE_BONE(ped)
    PED.CLEAR_PED_BLOOD_DAMAGE(ped)
    PED.CLEAR_PED_WETNESS(ped)
    PED.CLEAR_PED_ENV_DIRT(ped)
end

--- @param ped Ped
function clear_ped_all_tasks(ped)
    if not ENTITY.IS_ENTITY_A_PED(ped) then
        return
    end

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

--- 是否为敌对NPC
--- @param ped Ped
--- @return boolean
function is_hostile_ped(ped)
    if not ENTITY.IS_ENTITY_A_PED(ped) then
        return false
    end

    if PED.IS_PED_IN_COMBAT(ped, players.user_ped()) then
        return true
    end

    local rel = PED.GET_RELATIONSHIP_BETWEEN_PEDS(ped, players.user_ped())
    if rel == 3 or rel == 4 or rel == 5 then -- Dislike or Wanted or Hate
        return true
    end

    return false
end

--- 是否为友好NPC
--- @param ped Ped
--- @return boolean
function is_friendly_ped(ped)
    if not ENTITY.IS_ENTITY_A_PED(ped) then
        return false
    end

    local rel = PED.GET_RELATIONSHIP_BETWEEN_PEDS(ped, players.user_ped())
    if rel == 0 or rel == 1 then -- Respect or Like
        return true
    end

    return false
end

--- @param ped Ped
--- @param weaponHash Hash
--- @param setCurrent boolean [default = true]
function give_weapon_to_ped(ped, weaponHash, setCurrent)
    if setCurrent == nil then setCurrent = true end
    WEAPON.GIVE_DELAYED_WEAPON_TO_PED(ped, weaponHash, -1, setCurrent)
end

--- 通过 Ped 获取玩家ID
--- @param ped Ped
--- @return Player
function get_player_from_ped(ped)
    return NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(ped)
end

----------------------------------------
-- Weapon Functions
----------------------------------------

--- 获取Ped当前使用的武器或载具武器的Hash，和武器类型
---
--- 武器类型 (integer):
--- - `1`: Ped Weapon
--- - `2`: Vehicle Weapon
--- @param ped Ped
--- @return Hash, integer
function get_ped_current_weapon(ped)
    local ptr = memory.alloc_int()

    if WEAPON.GET_CURRENT_PED_WEAPON(ped, ptr, true) then
        local weapon_hash = memory.read_int(ptr)
        if weapon_hash ~= 0 then
            return weapon_hash, 1
        end
    end

    if WEAPON.GET_CURRENT_PED_VEHICLE_WEAPON(ped, ptr) then
        local weapon_hash = memory.read_int(ptr)
        if weapon_hash ~= 0 then
            return weapon_hash, 2
        end
    end

    return 0, 0
end

--- 获取Ped当前的武器Hash
--- @param ped Ped
--- @return Hash
function get_ped_weapon(ped)
    if not ENTITY.IS_ENTITY_A_PED(ped) then
        return 0
    end

    local ptr = memory.alloc_int()
    if WEAPON.GET_CURRENT_PED_WEAPON(ped, ptr, true) then
        return memory.read_int(ptr)
    end
    return 0
end

--- 获取Ped当前的载具武器Hash
--- @param ped Ped
--- @return Hash
function get_ped_vehicle_weapon(ped)
    if not ENTITY.IS_ENTITY_A_PED(ped) then
        return 0
    end

    local ptr = memory.alloc_int()
    if WEAPON.GET_CURRENT_PED_VEHICLE_WEAPON(ped, ptr) then
        return memory.read_int(ptr)
    end
    return 0
end

--- 通过武器Hash获取武器名称
--- @param weaponHash Hash
--- @return string
function get_weapon_name_by_hash(weaponHash)
    if WEAPON.IS_WEAPON_VALID(weaponHash) then
        -- for _, item in pairs(util.get_weapons()) do
        --     if item.hash == weaponHash then
        --         return util.get_label_text(item.label_key)
        --     end
        -- end
        return Weapon_T.WeaponNameList[weaponHash] or ""
    end
    return ""
end

----------------------------------------
-- Network Functions
----------------------------------------

--- 请求控制实体
--- @param entity Entity
--- @param timeout integer?
--- @return boolean
function request_control(entity, timeout)
    if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity) and util.is_session_started() then
        return entities.request_control(entity, timeout)
    end
    return true
end

--- 请求控制实体，如果失败则通知
--- @param entity Entity
--- @param timeout integer?
--- @return boolean
function request_control2(entity, timeout)
    if request_control(entity, timeout) then
        return true
    end
    util.toast("未能成功控制实体，请重试")
    return false
end

--- 是否已控制实体
--- @param entity Entity
--- @return boolean
function has_control_entity(entity)
    return NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity)
end

--- @param entity Entity
--- @param can_migrate? boolean
--- @return boolean
function set_entity_networked(entity, can_migrate)
    if not ENTITY.DOES_ENTITY_EXIST(entity) then
        return false
    end

    if can_migrate == nil then can_migrate = true end

    NETWORK.NETWORK_REGISTER_ENTITY_AS_NETWORKED(entity)

    local net_id = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(entity)
    NETWORK.SET_NETWORK_ID_CAN_MIGRATE(net_id, can_migrate)
    NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(net_id, true)
    for _, pid in pairs(players.list()) do
        NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(net_id, pid, true)
    end

    return NETWORK.NETWORK_GET_ENTITY_IS_NETWORKED(entity)
end

----------------------------------------
-- Blip Functions
----------------------------------------

--- 获取标记点实体
--- @param blip Blip
--- @return Entity
function get_entity_from_blip(blip)
    if not HUD.DOES_BLIP_EXIST(blip) then
        return 0
    end

    local entity = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
    if not ENTITY.DOES_ENTITY_EXIST(entity) then
        return 0
    end

    return entity
end

--- 获取标记点坐标
--- @param blip Blip
--- @return v3
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

--- 为实体添加标记点并显示一段时间，已有标记点则闪烁一段时间
--- @param ent Entity
--- @param blipSprite integer
--- @param colour integer
--- @param time integer ms
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

----------------------------------------
-- Streaming Functions
----------------------------------------

--- 请求模型资源
--- @param Hash Hash
function request_model(Hash)
    if STREAMING.IS_MODEL_VALID(Hash) then
        STREAMING.REQUEST_MODEL(Hash)
        while not STREAMING.HAS_MODEL_LOADED(Hash) do
            STREAMING.REQUEST_MODEL(Hash)
            util.yield()
        end
    end
end

--- 请求武器资源
--- @param Hash Hash
function request_weapon_asset(Hash)
    if WEAPON.IS_WEAPON_VALID(Hash) then
        WEAPON.REQUEST_WEAPON_ASSET(Hash, 31, 0)
        while not WEAPON.HAS_WEAPON_ASSET_LOADED(Hash) do
            WEAPON.REQUEST_WEAPON_ASSET(Hash, 31, 0)
            util.yield()
        end
    end
end

--- 请求粒子资源
--- @param asset string
function request_ptfx_asset(asset)
    STREAMING.REQUEST_NAMED_PTFX_ASSET(asset)
    while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(asset) do
        util.yield()
    end
    GRAPHICS.USE_PARTICLE_FX_ASSET(asset)
end

----------------------------------------
-- Draw Functions
----------------------------------------

--- @param pos0 v3
--- @param pos1 v3
--- @param pos2 v3
--- @param pos3 v3
--- @param colour Colour
local draw_rect = function(pos0, pos1, pos2, pos3, colour)
    GRAPHICS.DRAW_POLY(pos0.x, pos0.y, pos0.z, pos1.x, pos1.y, pos1.z, pos3.x, pos3.y, pos3.z, colour.r, colour.g,
        colour.b, colour.a)
    GRAPHICS.DRAW_POLY(pos3.x, pos3.y, pos3.z, pos2.x, pos2.y, pos2.z, pos0.x, pos0.y, pos0.z, colour.r, colour.g,
        colour.b, colour.a)
end

--- @param entity Entity
--- @param showPoly? boolean
--- @param colour? Colour
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

--- @param text string
--- @param x float
--- @param y float
--- @param scale? float [default = 0.5]
--- @param margin? float [default = 0.01]
--- @param text_color? Color
--- @param background_color? Color
function draw_text_box(text, x, y, scale, margin, text_color, background_color)
    scale = scale or 0.5
    margin = margin or 0.01
    text_color = text_color or Colors.white
    background_color = background_color or { r = 0.0, g = 0.0, b = 0.0, a = 0.6 }

    local text_width, text_height = directx.get_text_size(text, scale)
    directx.draw_rect(x, y, text_width + margin * 2, text_height + margin * 2, background_color)
    directx.draw_text(x + margin, y + margin, text, ALIGN_TOP_LEFT, scale, text_color)
end

--- @param text string
--- @param scale? float [default = 0.5]
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
    directx.draw_text(0.5, 0.01, text, ALIGN_TOP_LEFT, scale, Colors.white)
end

function draw_centred_point()
    directx.draw_texture(Texture.crosshair, 0.02, 0.02, 0.5, 0.5, 0.5, 0.5, 0, Colors.white)
end

----------------------------------------
-- Camera & Aim Functions
----------------------------------------

--- @param distance number
--- @return v3
function get_offset_from_cam(distance)
    local rot = CAM.GET_FINAL_RENDERED_CAM_ROT(2)
    local pos = CAM.GET_FINAL_RENDERED_CAM_COORD()
    local dir = rot:toDir()
    dir:mul(distance)
    local offset = v3.new(pos)
    offset:add(dir)
    return offset
end

local TraceFlag <const> = {
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

--- @param distance number
--- @param flag? integer
--- @return RaycastResult
--- - - -
--- class **RaycastResult** :
--- - `didHit` *boolean*
--- - `endCoords` *v3*
--- - `surfaceNormal` *v3*
--- - `hitEntity` *Entity*
function get_raycast_result(distance, flag)
    flag = flag or TraceFlag.everything
    local result = {}
    local didHit = memory.alloc(1)
    local endCoords = v3.new()
    local normal = v3.new()
    local hitEntity = memory.alloc_int()
    local camPos = CAM.GET_FINAL_RENDERED_CAM_COORD()
    local offset = get_offset_from_cam(distance)

    local handle = SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(
        camPos.x, camPos.y, camPos.z,
        offset.x, offset.y, offset.z,
        flag,
        players.user_ped(),
        3) -- SCRIPT_SHAPETEST_OPTION_IGNORE_GLASS | SCRIPT_SHAPETEST_OPTION_IGNORE_SEE_THROUGH

    local shapetest_status = SHAPETEST.GET_SHAPE_TEST_RESULT(handle, didHit,
        memory.addrof(endCoords), memory.addrof(normal), hitEntity)

    if shapetest_status ~= 2 then
        return result
    end

    result.didHit = memory.read_byte(didHit) ~= 0
    result.endCoords = endCoords
    result.surfaceNormal = normal
    result.hitEntity = memory.read_int(hitEntity)
    return result
end

----------------------------------------
-- Colour Functions
----------------------------------------

--- @class Colour
--- @field r number | integer
--- @field g number | integer
--- @field b number | integer
--- @field a number | integer

--- @return Colour
function get_random_colour()
    local colour = { a = 255 }
    colour.r = math.random(0, 255)
    colour.g = math.random(0, 255)
    colour.b = math.random(0, 255)
    return colour
end

--- 颜色数值 [0 - 1]格式 转换到 [0 - 255]格式 (float -> int)
--- @param colour Colour
--- @return Colour
function to_rage_colour(colour)
    return {
        r = math.ceil(colour.r * 255),
        g = math.ceil(colour.g * 255),
        b = math.ceil(colour.b * 255),
        a = math.ceil(colour.a * 255)
    }
end

--- 颜色数值 [0 - 255]格式 转换到 [0 - 1]格式 (int -> float)
--- @param colour Colour
--- @return Colour
function to_stand_colour(colour)
    return {
        r = string.format("%.2f", colour.r / 255),
        g = string.format("%.2f", colour.g / 255),
        b = string.format("%.2f", colour.b / 255),
        a = string.format("%.2f", colour.a / 255),
    }
end

local org_blip_colours <const> = {
    [-1] = 4,
    [0] = -140542977,
    [1] = -494486529,
    [2] = -269576193,
    [3] = 1906946047,
    [4] = -1601388033,
    [5] = -1915836417,
    [6] = -1244206337,
    [7] = -1299151617,
    [8] = 8680191,
    [9] = -665487873,
    [10] = 509909247,
    [11] = 733312511,
    [12] = -376614913,
    [13] = -1982670849,
    [14] = -2038592001
}

---获取玩家组织地图标记点的颜色
--- @param player_id player
--- @return integer
function get_org_blip_colour(player_id)
    return org_blip_colours[players.get_org_colour(player_id)]
end

----------------------------------------
-- Misc Functions
----------------------------------------

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
--- @param model Hash
--- @return number
--- @return number
--- @return number
function calculate_model_size(model)
    local minVec = v3.new()
    local maxVec = v3.new()
    MISC.GET_MODEL_DIMENSIONS(model, minVec, maxVec)
    return (maxVec:getX() - minVec:getX()), (maxVec:getY() - minVec:getY()), (maxVec:getZ() - minVec:getZ())
end

--- @param num number
--- @param places integer
--- @return number?
function round(num, places)
    return tonumber(string.format('%.' .. (places or 0) .. 'f', num))
end

--- @param bool boolean
--- @param true_text string? [默认: 是]
--- @param false_text string? [默认: 否]
--- @return string
function bool_to_string(bool, true_text, false_text)
    if bool then
        return true_text or "是"
    end
    return false_text or "否"
end

---返回a和b的中间值
--- @param a number
--- @param b number
--- @return number
function get_middle_num(a, b)
    local min = math.min(a, b)
    local max = math.max(a, b)
    local middle = min + (max - min) * 0.5
    return middle
end

--- @param text string
--- @return boolean
function to_boolean(text)
    if text == 'true' or text == "1" then
        return true
    end
    return false
end

----------------------------------------
-- Table Functions
----------------------------------------

--- 遍历表 判断某值是否在表中
--- @param tbl table
--- @param value any
--- @return boolean
function is_in_table(tbl, value)
    for k, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

----------------------------------------
-- Notification Functions
----------------------------------------

THEFEED_POST = {}

--- @param message string
function THEFEED_POST.TEXT(message)
    util.BEGIN_TEXT_COMMAND_THEFEED_POST(message)
    HUD.END_TEXT_COMMAND_THEFEED_POST_TICKER(false, false)
end

---Dev Mode Notify
--- @param text string
--- @param log? boolean
function notify(text, log)
    if not DEV_MODE then
        return
    end
    text = "[RScript] " .. text
    util.toast(text)

    if log == nil then log = true end
    if log then
        util.log(text)
    end
end

----------------------------------------
-- Other Functions
----------------------------------------

---爆头击杀NPC
--- @param targetPed Ped
--- @param weaponHash Hash? default: 584646201(WEAPON_APPISTOL)
--- @param owner Ped?
function shoot_ped_head(targetPed, weaponHash, owner)
    local head_pos = PED.GET_PED_BONE_COORDS(targetPed, 0x322c, 0, 0, 0)
    local vector = ENTITY.GET_ENTITY_FORWARD_VECTOR(targetPed)
    local start_pos = {}
    start_pos.x = head_pos.x + vector.x
    start_pos.y = head_pos.y + vector.y
    start_pos.z = head_pos.z + vector.z

    local target_ped_veh = GET_VEHICLE_PED_IS_IN(targetPed)

    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(
        start_pos.x, start_pos.y, start_pos.z,
        head_pos.x, head_pos.y, head_pos.z,
        1000, true,
        weaponHash or 584646201,
        owner or 0,
        false, false, 1000,
        target_ped_veh, targetPed)
end

---玩家爆炸敌对NPC(无声)
function explode_hostile_peds()
    for _, ped in pairs(entities.get_all_peds_as_handles()) do
        if is_hostile_entity(ped) then
            local coords = ENTITY.GET_ENTITY_COORDS(ped)
            add_owned_explosion(players.user_ped(), coords, 4, { isAudible = false })
        end
    end
end

---玩家爆炸敌对载具(无声)
function explode_hostile_vehicles()
    for _, vehicle in pairs(entities.get_all_vehicles_as_handles()) do
        if is_hostile_entity(vehicle) then
            SET_ENTITY_HEALTH(vehicle, 0)
            VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, -4000.0)

            local coords = ENTITY.GET_ENTITY_COORDS(vehicle)
            add_owned_explosion(players.user_ped(), coords, 4, { isAudible = false })
        end
    end
end

---玩家爆炸敌对物体(无声)
function explode_hostile_objects()
    for _, object in pairs(entities.get_all_objects_as_handles()) do
        if is_hostile_entity(object) then
            SET_ENTITY_HEALTH(object, 0)

            local coords = ENTITY.GET_ENTITY_COORDS(object)
            add_owned_explosion(players.user_ped(), coords, 4, { isAudible = false })
        end
    end
end

---生成实体阻挡任务刷新点
--- @param point_list table<int, table<pos_x, pos_y, pos_z, heading>>
--- @param hash Hash?
function block_mission_generate_point(point_list, hash)
    hash = hash or util.joaat("khanjali")

    local i = 0
    request_model(hash)
    for _, data in pairs(point_list) do
        local coords = v3.new(data[1], data[2], data[3])
        local vehicle = entities.create_vehicle(hash, coords, data[4])
        if vehicle ~= INVALID_GUID then
            i = i + 1
            SET_VEHICLE_ON_GROUND_PROPERLY(vehicle)
        end
    end
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)

    util.toast("完成！\n数量: " .. i)
end
