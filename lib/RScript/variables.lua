----------------------------------
--   GTA Online Version: 1.64   --
----------------------------------

Globals = {
    IsUsingComputerScreen = 75693,

    -- appHackerTruck
    SpecialCargoBuyScreenString = "appHackerTruck",
    SpecialCargoBuyScreenArgs = 4592, -- arg count needed to properly start the script, possibly outdated

    CEO_Ability = {
        -- global, default_value
        Cost = {
            { 12847, 1000 }, -- Drop Ammo
            { 12848, 1500 }, -- Drop Armor
            { 12849, 1000 }, -- Drop Bull Shark
            { 12850, 12000 }, -- Ghost Organization
            { 12851, 15000 }, -- Bribe Authorities
            { 15890, 5000 }, -- Request Luxury Helicopter
        },
        Cooldown = {
            { 12834, 30000 }, -- Drop Ammo
            { 12835, 30000 }, -- Drop Armor
            { 12836, 30000 }, -- Drop Bull Shark
            { 12837, 600000 }, -- Ghost Organization
            { 12838, 600000 }, -- Bribe Authorities
        },
    },

    CEO_Vehicle_Request_Cost = {
        -- global, default_value
        { 12842, 20000 }, { 12843, 5000 }, { 12844, 5000 }, { 12845, 5000 }, { 12846, 25000 },
        { 15959, 5000 }, { 15960, 5000 }, { 15961, 5000 },
        { 15968, 10000 }, { 15969, 7000 }, { 15970, 9000 }, { 15971, 5000 }, { 15972, 5000 }, { 15973, 5000 },
        { 19302, 5000 }, { 19304, 10000 },
    },

    RC_Bandito = 2793046 + 6874, -- freemode.c, (..., joaat("rcbandito"), 1)
    RC_Tank = 2793046 + 6875, -- freemode.c, (..., joaat("minitank"), 1)
    Ballistic_Armor = 2793046 + 896, -- freemode.c, (!NETWORK::NETWORK_IS_SCRIPT_ACTIVE("AM_AMMO_DROP", PLAYER::PLAYER_ID(), true, 0))

    -- 无视犯罪
    NCOPS = {
        type = 2793046 + 4654,
        flag = 2793046 + 4655,
        time = 2793046 + 4657,
    },

    GB_GHOST_ORG_DURATION = 262145 + 13149,
    GB_BRIBE_AUTHORITIES_DURATION = 262145 + 13150,
    FIXER_SECURITY_CONTRACT_REFRESH_TIME = 262145 + 31700,
    GB_CALL_VEHICLE_COOLDOWN = 262145 + 12832,
}

Globals.RemoveCooldown = {}

function Globals.RemoveCooldown.SpecialCargo(toggle)
    if toggle then
        SET_INT_GLOBAL(262145 + 15553, 0) -- EXEC_BUY_COOLDOWN
        SET_INT_GLOBAL(262145 + 15554, 0) -- EXEC_SELL_COOLDOWN
    else
        SET_INT_GLOBAL(262145 + 15553, 300000)
        SET_INT_GLOBAL(262145 + 15554, 1800000)
    end
end

function Globals.RemoveCooldown.VehicleCargo(toggle)
    if toggle then
        SET_INT_GLOBAL(262145 + 19314, 0) -- IMPEXP_STEAL_COOLDOWN
        SET_INT_GLOBAL(262145 + 19682, 0) -- 1 Vehicle, 1001423248
        SET_INT_GLOBAL(262145 + 19683, 0) -- 2 Vehicles, 240134765
        SET_INT_GLOBAL(262145 + 19684, 0) -- 3 Vehicles, 1915379148
        SET_INT_GLOBAL(262145 + 19685, 0) -- 4 Vehicles, -824005590
    else
        SET_INT_GLOBAL(262145 + 19314, 180000)
        SET_INT_GLOBAL(262145 + 19682, 1200000)
        SET_INT_GLOBAL(262145 + 19683, 1680000)
        SET_INT_GLOBAL(262145 + 19684, 2340000)
        SET_INT_GLOBAL(262145 + 19685, 2880000)
    end
end

function Globals.RemoveCooldown.AirFreightCargo(toggle)
    if toggle then
        SET_INT_GLOBAL(262145 + 22751, 0) -- Tobacco, Counterfeit Goods, SMUG_STEAL_EASY_COOLDOWN_TIMER
        SET_INT_GLOBAL(262145 + 22752, 0) -- Animal Materials, Art, Jewelry, SMUG_STEAL_MED_COOLDOWN_TIMER
        SET_INT_GLOBAL(262145 + 22753, 0) -- Narcotics, Chemicals, Medical Supplies, SMUG_STEAL_HARD_COOLDOWN_TIMER
        SET_INT_GLOBAL(262145 + 22754, 0) -- Additional Time per Player, 1722502526
        SET_INT_GLOBAL(262145 + 22755, 0) -- Sale, -1091356151
    else
        SET_INT_GLOBAL(262145 + 22751, 120000)
        SET_INT_GLOBAL(262145 + 22752, 180000)
        SET_INT_GLOBAL(262145 + 22753, 240000)
        SET_INT_GLOBAL(262145 + 22754, 60000)
        SET_INT_GLOBAL(262145 + 22755, 2000)
    end
end

function Globals.RemoveCooldown.PayphoneHitAndContract(toggle)
    if toggle then
        SET_INT_GLOBAL(262145 + 31701, 0) -- FIXER_SECURITY_CONTRACT_COOLDOWN_TIME
        SET_INT_GLOBAL(262145 + 31765, 0) -- -2036534141
        SET_INT_GLOBAL(262145 + 31781, 0) -- 1872071131
    else
        SET_INT_GLOBAL(262145 + 31701, 300000)
        SET_INT_GLOBAL(262145 + 31765, 500)
        SET_INT_GLOBAL(262145 + 31781, 1200000)
    end
end

Locals = {
    -- fm_mission_controller_2020
    MC_TLIVES_2020 = 48647 + 868 + 1,


    -- fm_mission_controller
    MC_TLIVES = 26133 + 1325 + 1,
}
