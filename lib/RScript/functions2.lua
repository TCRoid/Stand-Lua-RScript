--------------------------
-- Online Functions
--------------------------

--- @return boolean
function IS_IN_SESSION()
    return util.is_session_started() and not util.is_session_transition_active()
end

--------------------------
-- Script Functions
--------------------------

--- @param script string
--- @return boolean
function IS_SCRIPT_RUNNING(script)
    return SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(util.joaat(script)) > 0
end

--- @param script string
--- @param arg_count integer
--- @return boolean
function START_SCRIPT(script, arg_count)
    if not SCRIPT.DOES_SCRIPT_EXIST(script) then
        return false
    end
    if IS_SCRIPT_RUNNING(script) then
        return true
    end
    SCRIPT.REQUEST_SCRIPT(script)
    while not SCRIPT.HAS_SCRIPT_LOADED(script) do
        util.yield()
    end
    SYSTEM.START_NEW_SCRIPT(script, arg_count or 0)
    SCRIPT.SET_SCRIPT_AS_NO_LONGER_NEEDED(script)
    return true
end

--- @param script string
--- @return boolean
function IS_MISSION_SCRIPT(script)
    return script == "fm_mission_controller" or script == "fm_mission_controller_2020"
end

--------------------------
-- Stat Functions
--------------------------

function ADD_MP_INDEX(stat)
    local Exceptions = {
        "MP_CHAR_STAT_RALLY_ANIM",
        "MP_CHAR_ARMOUR_1_COUNT",
        "MP_CHAR_ARMOUR_2_COUNT",
        "MP_CHAR_ARMOUR_3_COUNT",
        "MP_CHAR_ARMOUR_4_COUNT",
        "MP_CHAR_ARMOUR_5_COUNT",
    }
    for _, exception in pairs(Exceptions) do
        if stat == exception then
            return "MP" .. util.get_char_slot() .. "_" .. stat
        end
    end

    if not string.contains(stat, "MP_") and not string.contains(stat, "MPPLY_") then
        return "MP" .. util.get_char_slot() .. "_" .. stat
    end
    return stat
end

function STAT_SET_INT(stat, value)
    STATS.STAT_SET_INT(util.joaat(ADD_MP_INDEX(stat)), value, true)
end

function STAT_SET_FLOAT(stat, value)
    STATS.STAT_SET_FLOAT(util.joaat(ADD_MP_INDEX(stat)), value, true)
end

function STAT_SET_BOOL(stat, value)
    STATS.STAT_SET_BOOL(util.joaat(ADD_MP_INDEX(stat)), value, true)
end

function STAT_SET_STRING(stat, value)
    STATS.STAT_SET_STRING(util.joaat(ADD_MP_INDEX(stat)), value, true)
end

function STAT_SET_DATE(stat, year, month, day, hour, min)
    local DatePTR = memory.alloc(8 * 7)
    memory.write_int(DatePTR, year)
    memory.write_int(DatePTR + 8, month)
    memory.write_int(DatePTR + 16, day)
    memory.write_int(DatePTR + 24, hour)
    memory.write_int(DatePTR + 32, min)
    memory.write_int(DatePTR + 40, 0) -- Seconds
    memory.write_int(DatePTR + 48, 0) -- Milliseconds
    STATS.STAT_SET_DATE(util.joaat(ADD_MP_INDEX(stat)), DatePTR, 7, true)
end

function STAT_INCREMENT(stat, value)
    STATS.STAT_INCREMENT(util.joaat(ADD_MP_INDEX(stat)), value, true)
end

function STAT_GET_INT(stat)
    local IntPTR = memory.alloc_int()
    STATS.STAT_GET_INT(util.joaat(ADD_MP_INDEX(stat)), IntPTR, -1)
    return memory.read_int(IntPTR)
end

function STAT_GET_FLOAT(stat)
    local FloatPTR = memory.alloc_int()
    STATS.STAT_GET_FLOAT(util.joaat(ADD_MP_INDEX(stat)), FloatPTR, -1)
    return tonumber(string.format("%.3f", memory.read_float(FloatPTR)))
end

function STAT_GET_BOOL(stat)
    if STAT_GET_INT(stat) ~= 0 then
        return "true"
    else
        return "false"
    end
end

function STAT_GET_STRING(stat)
    return STATS.STAT_GET_STRING(util.joaat(ADD_MP_INDEX(stat)), -1)
end

function STAT_GET_DATE(stat, type)
    local DatePTR = memory.alloc(8 * 7)
    STATS.STAT_GET_DATE(util.joaat(ADD_MP_INDEX(stat)), DatePTR, 7, true)
    local DateTypes = {
        "Years",
        "Months",
        "Days",
        "Hours",
        "Mins",
        -- Seconds,
        -- Milliseconds,
    }
    for i = 1, #DateTypes do
        if type == DateTypes[i] then
            return memory.read_int(DatePTR + 8 * (i - 1))
        end
    end
end

----------------------------
-- Global Functions
----------------------------

--- @param global integer
--- @param value integer
function GLOBAL_SET_INT(global, value)
    memory.write_int(memory.script_global(global), value)
end

--- @param global integer
--- @param value float
function GLOBAL_SET_FLOAT(global, value)
    memory.write_float(memory.script_global(global), value)
end

--- @param global integer
--- @return integer
function GLOBAL_GET_INT(global)
    return memory.read_int(memory.script_global(global))
end

--- @param global integer
--- @return float
function GLOBAL_GET_FLOAT(global)
    return memory.read_float(memory.script_global(global))
end

---------------------------
-- Tunable Functions
---------------------------

--- @param offset integer
--- @param value integer
function TUNABLE_SET_INT(offset, value)
    GLOBAL_SET_INT(262145 + offset, value)
end

--- @param offset integer
--- @param value float
function TUNABLE_SET_FLOAT(offset, value)
    GLOBAL_SET_FLOAT(262145 + offset, value)
end

--- @param offset integer
--- @return integer
function TUNABLE_GET_INT(offset)
    return GLOBAL_GET_INT(262145 + offset)
end

--- @param offset integer
--- @return float
function TUNABLE_GET_FLOAT(offset)
    return GLOBAL_GET_FLOAT(262145 + offset)
end

---------------------------
-- Local Functions
---------------------------

--- @param script string
--- @param script_local integer
--- @param value integer
function LOCAL_SET_INT(script, script_local, value)
    if memory.script_local(script, script_local) ~= 0 then
        memory.write_int(memory.script_local(script, script_local), value)
    end
end

--- @param script string
--- @param script_local integer
--- @param value float
function LOCAL_SET_FLOAT(script, script_local, value)
    if memory.script_local(script, script_local) ~= 0 then
        memory.write_float(memory.script_local(script, script_local), value)
    end
end

--- @param script string
--- @param script_local integer
---@return integer
function LOCAL_GET_INT(script, script_local)
    if memory.script_local(script, script_local) ~= 0 then
        local value = memory.read_int(memory.script_local(script, script_local))
        if value ~= nil then
            return value
        end
    end
end

--- @param script string
--- @param script_local integer
---@return float
function LOCAL_GET_FLOAT(script, script_local)
    if memory.script_local(script, script_local) ~= 0 then
        local value = memory.read_float(memory.script_local(script, script_local))
        if value ~= nil then
            return value
        end
    end
end

--- @param script string
--- @param script_local integer
--- @param bit integer
function LOCAL_SET_BIT(script, script_local, bit)
    local addr = memory.script_local(script, script_local)
    if addr ~= 0 then
        memory.write_int(addr, SET_BIT(memory.read_int(addr), bit))
    end
end

---------------------------
-- Bit Functions
---------------------------

--- @param bits integer
--- @param place integer
--- @return integer
function SET_BIT(bits, place)
    return (bits | (1 << place))
end

--- @param bits integer
--- @param place integer
--- @return integer
function CLEAR_BIT(bits, place)
    return (bits & ~(1 << place))
end

--- @param bits integer
--- @param place integer
--- @return integer
function BIT_TEST(bits, place)
    return (bits & (1 << place)) ~= 0
end
