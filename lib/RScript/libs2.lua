----------------------------------------
-- Misc Functions
----------------------------------------

---十进制数字转二进制数字，以table形式返回
---
---`bit` 从1开始，需要减1
---@param decimal integer
---@return table<bit, bin>
function decimal_to_binary(decimal)
    local binary = {}
    local i = 1
    while decimal > 0 do
        binary[i] = decimal % 2
        decimal = math.floor(decimal / 2)
        i = i + 1
    end
    return binary
end

----------------------------------------
-- Other Functions
----------------------------------------

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
    ENTITY.APPLY_FORCE_TO_ENTITY(entity,
        1,
        0.0, 0.0, 30.0,
        math.random(-2, 2), math.random(-2, 2), 0.0,
        0,
        false, false, true, false, false)
    util.yield(1000)
    ENTITY.APPLY_FORCE_TO_ENTITY(entity,
        1,
        0.0, 0.0, -100.0,
        0.0, 0.0, 0.0,
        0,
        false, false, true, false, false)
    util.yield(300)

    local coords = ENTITY.GET_ENTITY_COORDS(entity)
    if owner then
        FIRE.ADD_OWNED_EXPLOSION(owner, coords.x, coords.y, coords.z, 4, 1.0, true, false, 0.0)
    else
        FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, 4, 1.0, true, false, 0.0, false)
    end
end
