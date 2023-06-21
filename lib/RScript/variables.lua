----------------------------------
--   GTA Online Version: 1.67   --
----------------------------------

Globals = {
    IsUsingComputerScreen = 75816,

    -- CEO技能的费用和冷却时间
    CEO_Ability = {
        -- global, default_value
        Cost = {
            { 13020, 1000 },  -- Drop Ammo
            { 13021, 1500 },  -- Drop Armor
            { 13022, 1000 },  -- Drop Bull Shark
            { 13023, 12000 }, -- Ghost Organization
            { 13024, 15000 }, -- Bribe Authorities
            { 16070, 5000 },  -- Request Luxury Helicopter
        },
        Cooldown = {
            { 13007, 30000 },  -- Drop Ammo
            { 13008, 30000 },  -- Drop Armor
            { 13009, 30000 },  -- Drop Bullshark
            { 13010, 600000 }, -- Ghost Organization
            { 13011, 600000 }, -- Bribe Authorities
        },
    },

    -- CEO载具的费用
    CEO_Vehicle_Request_Cost = {
        -- global, default_value
        { 13015, 20000 }, -- Turreted Limo
        { 13016, 5000 },  -- Cognoscenti (Armored)
        { 13017, 5000 },  -- Schafter LWB (Armored)
        { 13018, 5000 },  -- Baller LE LWB (Armored)
        { 13019, 25000 }, -- Buzzard Attack Chopper
        { 16139, 5000 },  -- Enduro
        { 16140, 5000 },  -- Dune Buggy
        { 16141, 5000 },  -- Mesa
        { 16148, 10000 }, -- Volatus
        { 16149, 7000 },  -- Rumpo Custom
        { 16150, 9000 },  -- Brickade
        { 16151, 5000 },  -- Dinghy
        { 16152, 5000 },  -- XLS
        { 16153, 5000 },  -- Havok
        { 19482, 5000 },  -- Super Diamond
        { 19484, 10000 }, -- Supervolito
    },

    RC_Bandito = 2794162 + 6879,     -- freemode.c, (..., joaat("rcbandito"), 1)
    RC_Tank = 2794162 + 6880,        -- freemode.c, (..., joaat("minitank"), 1)
    Ballistic_Armor = 2794162 + 901, -- freemode.c, (!NETWORK::NETWORK_IS_SCRIPT_ACTIVE("AM_AMMO_DROP", PLAYER::PLAYER_ID(), true, 0))

    -- 无视犯罪
    NCOPS = {
        type = 2794162 + 4661,
        flag = 2794162 + 4662,
        time = 2794162 + 4664,
    },
    GB_GHOST_ORG_DURATION = 262145 + 13322,
    GB_BRIBE_AUTHORITIES_DURATION = 262145 + 13323,
    FIXER_SECURITY_CONTRACT_REFRESH_TIME = 262145 + 31907,
    GB_CALL_VEHICLE_COOLDOWN = 262145 + 13005,
    TURN_SNOW_ON_OFF = 262145 + 4752,
    AI_HEALTH = 262145 + 165,
}

Globals.RemoveCooldown = {}

function Globals.RemoveCooldown.SpecialCargo(toggle)
    if toggle then
        SET_INT_GLOBAL(262145 + 15728, 0) -- EXEC_BUY_COOLDOWN
        SET_INT_GLOBAL(262145 + 15729, 0) -- EXEC_SELL_COOLDOWN
    else
        SET_INT_GLOBAL(262145 + 15728, 300000)
        SET_INT_GLOBAL(262145 + 15729, 1800000)
    end
end

function Globals.RemoveCooldown.VehicleCargo(toggle)
    if toggle then
        SET_INT_GLOBAL(262145 + 19494, 0) -- IMPEXP_STEAL_COOLDOWN
        SET_INT_GLOBAL(262145 + 19862, 0) -- 1 Vehicle, 1001423248
        SET_INT_GLOBAL(262145 + 19863, 0) -- 2 Vehicles, 240134765
        SET_INT_GLOBAL(262145 + 19864, 0) -- 3 Vehicles, 1915379148
        SET_INT_GLOBAL(262145 + 19865, 0) -- 4 Vehicles, -824005590
    else
        SET_INT_GLOBAL(262145 + 19494, 180000)
        SET_INT_GLOBAL(262145 + 19862, 1200000)
        SET_INT_GLOBAL(262145 + 19863, 1680000)
        SET_INT_GLOBAL(262145 + 19864, 2340000)
        SET_INT_GLOBAL(262145 + 19865, 2880000)
    end
end

function Globals.RemoveCooldown.AirFreightCargo(toggle)
    if toggle then
        SET_INT_GLOBAL(262145 + 22931, 0) -- Tobacco, Counterfeit Goods, SMUG_STEAL_EASY_COOLDOWN_TIMER
        SET_INT_GLOBAL(262145 + 22932, 0) -- Animal Materials, Art, Jewelry, SMUG_STEAL_MED_COOLDOWN_TIMER
        SET_INT_GLOBAL(262145 + 22933, 0) -- Narcotics, Chemicals, Medical Supplies, SMUG_STEAL_HARD_COOLDOWN_TIMER
        SET_INT_GLOBAL(262145 + 22934, 0) -- Additional Time per Player, 1722502526
        SET_INT_GLOBAL(262145 + 22935, 0) -- Sale, -1091356151
    else
        SET_INT_GLOBAL(262145 + 22931, 120000)
        SET_INT_GLOBAL(262145 + 22932, 180000)
        SET_INT_GLOBAL(262145 + 22933, 240000)
        SET_INT_GLOBAL(262145 + 22934, 60000)
        SET_INT_GLOBAL(262145 + 22935, 2000)
    end
end

function Globals.RemoveCooldown.PayphoneHitAndContract(toggle)
    if toggle then
        SET_INT_GLOBAL(262145 + 31908, 0) -- FIXER_SECURITY_CONTRACT_COOLDOWN_TIME
        SET_INT_GLOBAL(262145 + 31973, 0) -- -2036534141
        SET_INT_GLOBAL(262145 + 31989, 0) -- 1872071131
    else
        SET_INT_GLOBAL(262145 + 31908, 300000)
        SET_INT_GLOBAL(262145 + 31973, 500)
        SET_INT_GLOBAL(262145 + 31989, 1200000)
    end
end


Locals = {
    -- fm_mission_controller_2020
    MC_TLIVES_2020 = 51905 + 868 + 1,
    -- fm_mission_controller
    MC_TLIVES = 26136 + 1325 + 1,

    appHackerTruckArgs = 4592, -- arg count needed to properly start the script, possibly outdated
}
