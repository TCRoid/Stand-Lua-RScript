-- Game Variables
-- 1.70-3411

--------------------------------
-- Globals
--------------------------------

Globals = {
    GunVanSpawnCoords = 1950373,
    GunVanLocation = 2652568 + 2706,
}


local _MPGlobalsAmbience = 2739811
-- MPGlobalsAmbienceStruct
MPGlobalsAmbience = {
    -- Launch Vehicle Drop
    bLaunchVehicleDropTruck = _MPGlobalsAmbience + 956,
    bLaunchVehicleDropAvenger = _MPGlobalsAmbience + 964,
    bLaunchVehicleDropHackerTruck = _MPGlobalsAmbience + 969,
    bLaunchVehicleDropSubmarine = _MPGlobalsAmbience + 991,
    bLaunchVehicleDropSubmarineDinghy = _MPGlobalsAmbience + 1003,
    bLaunchVehicleDropAcidLab = _MPGlobalsAmbience + 970,
    bLaunchVehicleDropSupportBike = _MPGlobalsAmbience + 1025,

    -- Lester Disable Cops
    iLesterDisableCopsBitset = _MPGlobalsAmbience + 4692,
    iLesterDisableCopsProg = _MPGlobalsAmbience + 4693,
    timeCopsDisabled = _MPGlobalsAmbience + 4695,

    -- Ballistics Armor Drop
    bLaunchBallisticsDrop = _MPGlobalsAmbience + 927,
    bEquipBallisticsDrop = _MPGlobalsAmbience + 928,
    bRemoveBallisticsDrop = _MPGlobalsAmbience + 929,

    -- RC Vehicle
    bLaunchRCBandito = _MPGlobalsAmbience + 6995,
    bLaunchRCTank = _MPGlobalsAmbience + 6996,

    -- StreetDealersStruct
    sStreetDealers = {
        iActiveLocations = _MPGlobalsAmbience + 6852 -- +1+[0~2]*7
    },
}


local _g_FMMC_STRUCT = 4718592
-- FMMC_GLOBAL_STRUCT
g_FMMC_STRUCT = {
    iFixedCamera = _g_FMMC_STRUCT + 157365,

    iRootContentIDHash = _g_FMMC_STRUCT + 128476,
    tl63MissionName = _g_FMMC_STRUCT + 127185,

    iTeamNames = _g_FMMC_STRUCT + 108374 + 1,   -- +[0~3]
    tlCustomName = _g_FMMC_STRUCT + 108379 + 1, -- +[0~3]*4
}





--------------------------------
-- Locals
--------------------------------

Locals = {
    ["gb_casino_heist"] = {
        iRangeHackingTime = 2353,
        iRandomModeInt1 = 4470 + 1522
    },
    ["fm_content_security_contract"] = {
        eMissionSubvariation = 7268 + 1357 + 1,
        stModeTimer = 7268 + 1388,
        iGenericSet = 140 + 34,
        iTimeLimit = 277 + 1568
    },
    ["fm_content_island_heist"] = {
        stModeTimer = 13433 + 1479
    },
    ["gb_smuggler"] = {
        stModeTimer = 1985 + 768
    },
    ["fm_content_smuggler_resupply"] = {
        stModeTimer = 6166 + 1326
    },



    ["fm_mission_controller"] = {
        sFMMC_SBD = {
            -- MC_serverBD_1.sFMMC_SBD.niVehicle[index]
            niVehicle = 22995 + 834 + 81 + 1
        },
    },
    ["fm_mission_controller_2020"] = {
        sFMMC_SBD = {
            -- MC_serverBD_1.sFMMC_SBD.niVehicle[index]
            niVehicle = 55623 + 777 + 81 + 1
        },
    },
}





--------------------------------
-- Functions
--------------------------------

--- 获取团队名称
--- @param team integer
--- @return string
function GET_TEAM_NAME(team)
    if team < 0 then
        return util.get_label_text("HEIST_RL_NONE") -- UNASSIGNED
    end

    local labelName = "COR_TEAM_" -- or "FMMC_TEAM_"

    local teamName = GLOBAL_GET_INT(g_FMMC_STRUCT.iTeamNames + team)
    if teamName == 38 then -- ciTEAM_NAME_MAX
        local customName = GLOBAL_GET_STRING(g_FMMC_STRUCT.tlCustomName + team * 4)
        return util.get_label_text(customName)
    end

    return util.get_label_text(labelName .. teamName)
end
