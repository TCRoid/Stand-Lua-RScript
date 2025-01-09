-- Game Variables
-- 1.70-3411

--------------------------------
--  Tunables
--------------------------------

TunablesI = {
    ["DISABLE_STAT_CAP_CHECK"] = 158,
    ["TURN_SNOW_ON_OFF"] = 4413,

    ["GB_GHOST_ORG_DURATION"] = 13117,
    ["GB_BRIBE_AUTHORITIES_DURATION"] = 13118,

    ["XM22_GUN_VAN_SLOT_WEAPON_TYPE_0"] = 33273,
}

TunablesF = {
    ["AI_HEALTH"] = 156,
}

local g_sMPTunables = 262145


--------------------------------
-- Functions
--------------------------------

Tunables = {}

--- @param tunable_name string
--- @param value int
function Tunables.SetInt(tunable_name, value)
    GLOBAL_SET_INT(g_sMPTunables + TunablesI[tunable_name], value)
end

--- @param tunable_list_name string
--- @param value int
function Tunables.SetIntList(tunable_list_name, value)
    for _, offset in pairs(TunablesI[tunable_list_name]) do
        GLOBAL_SET_INT(g_sMPTunables + offset, value)
    end
end

--- @param tunable_name string
--- @param value float
function Tunables.SetFloat(tunable_name, value)
    GLOBAL_SET_FLOAT(g_sMPTunables + TunablesF[tunable_name], value)
end

--- @param tunable_list_name string
--- @param value float
function Tunables.SetFloatList(tunable_list_name, value)
    for _, offset in pairs(TunablesF[tunable_list_name]) do
        GLOBAL_SET_FLOAT(g_sMPTunables + offset, value)
    end
end

--------------------------------
-- Tunable Service
--------------------------------

local TunableServiceData = {
    Int = {},
    Float = {}
}

TunableService = {}

function TunableService.RegisterInt(tunable_name, value)
    local addr = g_sMPTunables + TunablesI[tunable_name]
    GLOBAL_SET_INT(addr, value)

    TunableServiceData.Int[addr] = value
end

function TunableService.RemoveInt(tunable_name)
    local addr = g_sMPTunables + TunablesI[tunable_name]

    TunableServiceData.Int[addr] = nil
end

function TunableService.RegisterToggle(tunable_name, toggle)
    local addr = g_sMPTunables + TunablesI[tunable_name]

    local value = toggle and 1 or 0
    GLOBAL_SET_INT(addr, value)

    if toggle then
        TunableServiceData.Int[addr] = value
    else
        TunableServiceData.Int[addr] = nil
    end
end

function TunableService.HandleInt()
    for addr, value in pairs(TunableServiceData.Int) do
        GLOBAL_SET_INT(addr, value)
    end
end
