-- Game Variables
-- 1.68-3179

--------------------------------
-- Globals
--------------------------------

Globals = {
    GunVanSpawnCoords = 1948900,
    GunVanLocation = 2652572 + 2650,
}


local _MPGlobalsAmbience = 2738587
-- MPGlobalsAmbienceStruct
MPGlobalsAmbience = {
    -- Launch Vehicle Drop
    bLaunchVehicleDropTruck = _MPGlobalsAmbience + 930,
    bLaunchVehicleDropAvenger = _MPGlobalsAmbience + 938,
    bLaunchVehicleDropHackerTruck = _MPGlobalsAmbience + 943,
    bLaunchVehicleDropSubmarine = _MPGlobalsAmbience + 960,
    bLaunchVehicleDropSubmarineDinghy = _MPGlobalsAmbience + 972,
    bLaunchVehicleDropAcidLab = _MPGlobalsAmbience + 944,
    bLaunchVehicleDropSupportBike = _MPGlobalsAmbience + 994,

    -- Lester Disable Cops
    iLesterDisableCopsBitset = _MPGlobalsAmbience + 4661,
    iLesterDisableCopsProg = _MPGlobalsAmbience + 4662,
    timeCopsDisabled = _MPGlobalsAmbience + 4664,

    -- Ballistics Armor Drop
    bLaunchBallisticsDrop = _MPGlobalsAmbience + 901,
    bEquipBallisticsDrop = _MPGlobalsAmbience + 902,
    bRemoveBallisticsDrop = _MPGlobalsAmbience + 903,

    -- RC Vehicle
    bLaunchRCBandito = _MPGlobalsAmbience + 6918,
    bLaunchRCTank = _MPGlobalsAmbience + 6919,
}


local _g_FMMC_STRUCT = 4718592
-- FMMC_GLOBAL_STRUCT
g_FMMC_STRUCT = {
    iFixedCamera = _g_FMMC_STRUCT + 154310,

    iRootContentIDHash = _g_FMMC_STRUCT + 126144,
    tl63MissionName = _g_FMMC_STRUCT + 126151,
}





--------------------------------
-- Locals
--------------------------------

Locals = {
    -- Diamond Casino Heist Prep
    gb_casino_heist = {
        phone_hack_progress = 2330,
        camera_hack_position = 4280 + 1654,
        target_package_number = 4280 + 1724,
    },

    -- Security Contract
    fm_content_security_contract = {
        mission_time = 254 + 1550,
        mission_type = 7095 + 1339 + 1,
        realize_assets_destination = 117 + 34,
    },

    -- Vehicle Cargo Import & Export
    gb_vehicle_export = {
        vehicle_net_id = 834 + 29 + 1,
        mission_start_time = 834 + 457,
    },

    -- Cayo Perico Heist Prep
    fm_content_island_heist = {
        mission_start_time = 13262 + 1460,
    },

    -- Air Freight
    gb_smuggler = {
        mission_start_time = 1932 + 768,
    },
    fm_content_smuggler_resupply = {
        mission_start_time = 6006 + 1319,
    },
}





--------------------------------
-- Functions
--------------------------------
