----------------------------------
--   GTA Online Version: 1.64   --
----------------------------------

Globals = {
    IsUsingComputerScreen = 75693,

    -- appHackerTruck
    SpecialCargoBuyScreenString = "appHackerTruck",
    SpecialCargoBuyScreenArgs = 4592, -- arg count needed to properly start the script, possibly outdated


    ceo_ability_list = {
        -- global, default_value
        { cost = { 12847, 1000 }, cooldown = { 12834, 30000 } }, -- Drop Ammo
        { cost = { 12848, 1500 }, cooldown = { 12835, 30000 } }, -- Drop Armor
        { cost = { 12849, 1000 }, cooldown = { 12836, 30000 } }, -- Drop Bull Shark
        { cost = { 12850, 12000 }, cooldown = { 12837, 600000 } }, -- Ghost Organization
        { cost = { 12851, 15000 }, cooldown = { 12838, 600000 } }, -- Bribe Authorities
    },
    ceo_vehicle_request_cost = {
        -- global, default_value
        { 12842, 20000 }, { 12843, 5000 }, { 12844, 5000 }, { 12845, 5000 }, { 12846, 25000 },
        { 15959, 5000 }, { 15960, 5000 }, { 15961, 5000 },
        { 15968, 10000 }, { 15969, 7000 }, { 15970, 9000 }, { 15971, 5000 }, { 15972, 5000 }, { 15973, 5000 },
        { 19302, 5000 }, { 19304, 10000 },
    },

    RC_Bandito = 2793044 + 6874, -- freemode.c, (..., joaat("rcbandito"), 1)
    RC_Tank = 2793044 + 6875, -- freemode.c, (..., joaat("minitank"), 1)
    Ballistic_Armor = 2793044 + 884, -- freemode.c, (!NETWORK::NETWORK_IS_SCRIPT_ACTIVE("AM_AMMO_DROP", PLAYER::PLAYER_ID(), true, 0))

    GB_GHOST_ORG_DURATION = 262145 + 13149,
    GB_BRIBE_AUTHORITIES_DURATION = 262145 + 13150,

    -- 无视犯罪
    NCOPS = {
        type = 2793044 + 4654,
        flag = 2793044 + 4655,
        time = 2793044 + 4657,
    },

}


Locals = {
    -- fm_mission_controller_2020
    MC_TLIVES_2020 = 48647 + 868 + 1,


    -- fm_mission_controller
    MC_TLIVES = 26133 + 1325 + 1,
}
