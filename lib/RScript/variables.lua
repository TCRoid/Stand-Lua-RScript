-- Game Variables
-- 1.69-3274

--------------------------------
-- Globals
--------------------------------

Globals = {
    GunVanSpawnCoords = 1949748,
    GunVanLocation = 2652592 + 2671,
}


local _MPGlobalsAmbience = 2738934
-- MPGlobalsAmbienceStruct
MPGlobalsAmbience = {
    -- Launch Vehicle Drop
    bLaunchVehicleDropTruck = _MPGlobalsAmbience + 945,
    bLaunchVehicleDropAvenger = _MPGlobalsAmbience + 953,
    bLaunchVehicleDropHackerTruck = _MPGlobalsAmbience + 958,
    bLaunchVehicleDropSubmarine = _MPGlobalsAmbience + 975,
    bLaunchVehicleDropSubmarineDinghy = _MPGlobalsAmbience + 987,
    bLaunchVehicleDropAcidLab = _MPGlobalsAmbience + 959,
    bLaunchVehicleDropSupportBike = _MPGlobalsAmbience + 1009,

    -- Lester Disable Cops
    iLesterDisableCopsBitset = _MPGlobalsAmbience + 4676,
    iLesterDisableCopsProg = _MPGlobalsAmbience + 4677,
    timeCopsDisabled = _MPGlobalsAmbience + 4679,

    -- Ballistics Armor Drop
    bLaunchBallisticsDrop = _MPGlobalsAmbience + 916,
    bEquipBallisticsDrop = _MPGlobalsAmbience + 917,
    bRemoveBallisticsDrop = _MPGlobalsAmbience + 918,

    -- RC Vehicle
    bLaunchRCBandito = _MPGlobalsAmbience + 6956,
    bLaunchRCTank = _MPGlobalsAmbience + 6957,
}


local _g_FMMC_STRUCT = 4718592
-- FMMC_GLOBAL_STRUCT
g_FMMC_STRUCT = {
    iFixedCamera = _g_FMMC_STRUCT + 155346,

    iRootContentIDHash = _g_FMMC_STRUCT + 127178,
    tl63MissionName = _g_FMMC_STRUCT + 127185,

    iTeamNames = _g_FMMC_STRUCT + 107178 + 1,   -- +[0~3]
    tlCustomName = _g_FMMC_STRUCT + 107183 + 1, -- +[0~3]*4
}





--------------------------------
-- Locals
--------------------------------

Locals = {
    -- Diamond Casino Heist Prep
    gb_casino_heist = {
        phone_hack_progress = 2332,
        camera_hack_position = 4413 + 1522,
        target_package_number = 4413 + 1592,
    },

    -- Security Contract
    fm_content_security_contract = {
        mission_time = 256 + 1550,
        mission_type = 7136 + 1339 + 1,
        realize_assets_destination = 119 + 34,
    },

    -- Cayo Perico Heist Prep
    fm_content_island_heist = {
        mission_start_time = 13311 + 1460,
    },

    -- Air Freight
    gb_smuggler = {
        mission_start_time = 1934 + 768,
    },
    fm_content_smuggler_resupply = {
        mission_start_time = 6045 + 1319,
    },


    ---- Mission Controller

    ["fm_mission_controller"] = {
        sFMMC_SBD = {
            -- MC_serverBD_1.sFMMC_SBD.niVehicle[index]
            niVehicle = 22960 + 834 + 81 + 1
        },
    },
    ["fm_mission_controller_2020"] = {
        sFMMC_SBD = {
            -- MC_serverBD_1.sFMMC_SBD.niVehicle[index]
            niVehicle = 53558 + 777 + 81 + 1
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
