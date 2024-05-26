-- Game Variables
-- 1.68-3179

--------------------------------
--  Tunables
--------------------------------

TunablesI = {
    ["DISABLE_STAT_CAP_CHECK"] = 167,
    ["TURN_SNOW_ON_OFF"] = 4575,

    ["GB_GHOST_ORG_DURATION"] = 13349,
    ["GB_BRIBE_AUTHORITIES_DURATION"] = 13350,

    ["XM22_GUN_VAN_SLOT_WEAPON_TYPE_0"] = 34328,
}

TunablesF = {
    ["AI_HEALTH"] = 165,
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
