----------------------------------------
-- Alternative for Native Functions
----------------------------------------

---@param entity Entity
---@param coords v3
---@param heading? float
function TP_ENTITY(entity, coords, heading)
    if heading ~= nil then
        ENTITY.SET_ENTITY_HEADING(entity, heading)
    end
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entity, coords.x, coords.y, coords.z, true, false, false)
end

---@param heading? float
---@return float
function ENTITY_HEADING(entity, heading)
    if heading ~= nil then
        ENTITY.SET_ENTITY_HEADING(entity, heading)
        return heading
    end
    return ENTITY.GET_ENTITY_HEADING(entity)
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
    GRAPHICS.DRAW_LINE(start_pos.x, start_pos.y, start_pos.z,
        end_pos.x, end_pos.y, end_pos.z,
        colour.r, colour.g, colour.b, colour.a)
end

---`colour` range: r, g, b = 0-255, alpha = 0-1.0
---@param coords v3
---@param radius float
---@param colour? Colour
function DRAW_MARKER_SPHERE(coords, radius, colour)
    colour = colour or { r = 200, g = 50, b = 200, a = 0.5 }
    GRAPHICS.DRAW_MARKER_SPHERE(coords.x, coords.y, coords.z, radius,
        colour.r, colour.g, colour.b, colour.a)
end

----------------------------------------
-- Compact Params Natives
----------------------------------------

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
    Params.isAudible = Params.isAudible or true
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

---Fires an instant hit bullet between the two points taking into account an entity to ignore for damage.
---@param startCoords v3
---@param endCoords v3
---@param optionalParams? table<key, value>
--- - - -
--- **optionalParams:**
--- - `damage` *integer* [default = 1000]
--- - `perfectAccuracy` *boolean* [default = false]
--- - `weaponHash` *Hash* [default = 3220176749(WEAPON_ASSAULTRIFLE)]
--- - `owner` *Ped* [default = 0]
--- - `createTraceVfx` *boolean* [default = true]
--- - `allowRumble` *boolean* [default = true]
--- - `speed` *integer* [default = 1000]
--- - `ignoreEntity` *Entity* [default = 0]
--- - `targetEntity` *Entity* [default = 0]
--- - - -
--- `perfectAccuracy` sets the bullets at the exact point otherwise it applys a spread to the bullets.
---
--- `weaponHash` can be projectiles but then the `endCoords` is the direction and not where it will land.
---
--- Setting the `targetEntity` parameter will enable homing code if the weapon is a rocket.
function shoot_single_bullet(startCoords, endCoords, optionalParams)
    local Params = optionalParams or {}
    Params.damage = Params.damage or 1000
    Params.weaponHash = Params.weaponHash or 3220176749
    Params.owner = Params.owner or 0
    Params.createTraceVfx = Params.createTraceVfx or true
    Params.allowRumble = Params.allowRumble or true
    Params.speed = Params.speed or 1000
    Params.ignoreEntity = Params.ignoreEntity or 0
    Params.targetEntity = Params.targetEntity or 0

    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(
        startCoords.x, startCoords.y, startCoords.z,
        endCoords.x, endCoords.y, endCoords.z,
        Params.damage, Params.perfectAccuracy, Params.weaponHash, Params.owner,
        Params.createTraceVfx, Params.allowRumble, Params.speed,
        Params.ignoreEntity, Params.targetEntity)
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
-- Default Params Natives
----------------------------------------

---@param entity Entity
---@param health integer
function SET_ENTITY_HEALTH(entity, health)
    ENTITY.SET_ENTITY_HEALTH(entity, health, 0, 0)
end

---@param vehicle Vehicle
---@param toggle boolean
function SET_VEHICLE_ENGINE_ON(vehicle, toggle)
    VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, toggle, true, false)
end

---@param vehicle Vehicle
function SET_VEHICLE_ON_GROUND_PROPERLY(vehicle)
    VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(vehicle, 5.0)
end

---@param entity Entity
---@return string|nil
function GET_ENTITY_SCRIPT(entity)
    local entity_script = ENTITY.GET_ENTITY_SCRIPT(entity, 0)
    if entity_script == nil then return nil end
    return string.lower(entity_script)
end
