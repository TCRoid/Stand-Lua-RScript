----------------------------------
--   GTA Online Version: 1.67   --
----------------------------------

Globals = {
    IsUsingComputerScreen = 75816,

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
    VC_WORK_REQUEST_COOLDOWN = 262145 + 27440,
    BUNKER_RESEARCH_REQUEST_COOLDOWN = 262145 + 33076, -- 370341838
    NC_GOODS_REQUEST_COOLDOWN = 262145 + 33077,        -- 236343681
}

Globals.SpecialCargo = {
    EXEC_CONTRABAND_TYPE_REFRESH_TIME = 262145 + 15734,
    EXEC_CONTRABAND_SPECIAL_ITEM_THRESHOLD = 262145 + 15735,
    EXEC_CONTRABAND_SPECIAL_ITEM_CHANCE = 262145 + 15736,
    Buy_Offsets = {
        15765, -- EXEC_DISABLE_BUY_AFTERMATH
        15771, -- EXEC_DISABLE_BUY_AMBUSHED
        15772, -- EXEC_DISABLE_BUY_ASSASSINATE
        15778, -- EXEC_DISABLE_BUY_BOATATTACK
        15784, -- EXEC_DISABLE_BUY_BREAKUPDEAL
        15790, -- EXEC_DISABLE_BUY_CARGODROP
        15791, -- EXEC_DISABLE_BUY_CRASHSITE
        15797, -- EXEC_DISABLE_BUY_GANGHIDEOUT
        15824, -- EXEC_DISABLE_BUY_HELITAKEDOWN
        15825, -- EXEC_DISABLE_BUY_IMPOUNDED
        15831, -- EXEC_DISABLE_BUY_MOVEDCOLLECTION
        15832, -- EXEC_DISABLE_BUY_MOVINGCOLLECTION
        15833, -- EXEC_DISABLE_BUY_MULTIPLEMOVINGVEHICLES
        15834, -- EXEC_DISABLE_BUY_POLICESTING
        15840, -- EXEC_DISABLE_BUY_STEALTRANSPORTER
        15841, -- EXEC_DISABLE_BUY_THIEF
        15842, -- EXEC_DISABLE_BUY_TRACKIFY
        15843, -- EXEC_DISABLE_BUY_TRAPPED
        15849, -- EXEC_DISABLE_BUY_VALKYRIETAKEDOWN
        15850, -- EXEC_DISABLE_BUY_VEHICLECOLLECTION
    },
    Buy_Names = {
        { "Aftermath", "包裹*3\n无需踩黄点" },
        { "Ambushed", "被埋伏\n厢型车" },
        { "Assassinate", "前往有利位置干掉目标" },
        { "Boat Attack", "出海，摧毁船只" },
        { "Break Up Deal", "厢型车\n不用踩黄点" },
        { "Air Drop", "在空投区扔信号弹" },
        { "Crash Site", "坠机点" },
        { "Gang Fights", "厢型车\n不用踩黄点" },
        { "Heli Takedown", "干掉直升机" },
        { "Police Confiscation", "走漏风声，货被羁押" },
        { "Spooked", "卖家收到惊吓，前往备用交易点" },
        { "Moving Collection", "第三方势力抢走货物" },
        { "Multiple Moving Vehicles", "多个追踪器信号" },
        { "Police Sting", "警察埋伏\n不用踩黄点" },
        { "Police Transporter", "执法人员扣押货物" },
        { "Thief", "干掉盗贼" },
        { "Trackify Searching", "追踪载具" },
        { "Trapped", "厢型车\n不用踩黄点" },
        { "Valkyrie Takedown", "干掉女武神" },
        { "Vehicle Collection", "厢型车\n不用踩黄点" },
    },
    Sell_Offsets = {
        15855, -- EXEC_DISABLE_SELL_AIRATTACKED
        15861, -- EXEC_DISABLE_SELL_AIRCLEARAREA
        15867, -- EXEC_DISABLE_SELL_AIRDROP
        15873, -- EXEC_DISABLE_SELL_AIRFLYLOW
        15874, -- EXEC_DISABLE_SELL_AIRRESTRICTED
        15880, -- EXEC_DISABLE_SELL_ATTACKED
        15881, -- EXEC_DISABLE_SELL_DEFAULT
        15882, -- EXEC_DISABLE_SELL_DEFEND
        15904, -- EXEC_DISABLE_SELL_MULTIPLE
        15910, -- EXEC_DISABLE_SELL_NODAMAGE
        15911, -- EXEC_DISABLE_SELL_SEAATTACKED
        15917, -- EXEC_DISABLE_SELL_SEADEFEND
        15923, -- EXEC_DISABLE_SELL_STING
        15929, -- EXEC_DISABLE_SELL_TRACKIFY
    },
    Sell_Names = {
        { "Air Attacked", "" },
        { "Air Clear Area", "" },
        { "Air Drop", "" },
        { "Air Fly Low", "" },
        { "Air Restricted", "" },
        { "Attacked", "卡车\n每辆车1个点" },
        { "Default", "卡车\n每辆车1个点" },
        { "Defend", "卡车，干掉敌人保护货物\n每辆车1个点" },
        { "Multiple", "卡车\n每辆车5个点" },
        { "(推荐) No Damage", "卡车，完好无损送达加运送奖励\n每辆车1个点" },
        { "Sea Attacked", "" },
        { "Sea Defend", "" },
        { "Sting", "卡车，会触发通缉\n每辆车5个点" },
        { "Trackify", "" },
    },
}

Globals.Bunker = {
    GR_RESUPPLY_PACKAGE_VALUE = 262145 + 21703,
    GR_RESUPPLY_VEHICLE_VALUE = 262145 + 21704,
    Steal_Offsets = {
        21824, -- GR_STEAL_VAN_STEAL_VAN_WEIGHTING
        21826, -- GR_STEAL_APC_STEAL_APC_WEIGHTING
        21829, -- GR_STEAL_RHINO_STEAL_RHINO_WEIGHTING
        21833, -- GR_RIVAL_OPERATION_RIVAL_OPERATION_WEIGHTING
        21835, -- GR_STEAL_TECHNICAL_STEAL_TECHNICAL_WEIGHTING
        21837, -- GR_DIVERSION_DIVERSION_WEIGHTING
        21839, -- GR_FLASHLIGHT_FLASHLIGHT_WEIGHTING
        21845, -- GR_ALTRUISTS_ALTRUIST_WEIGHTING
        21847, -- GR_DESTROY_TRUCKS_DESTROY_TRUCKS_WEIGHTING
        21850, -- GR_YACHT_SEARCH_YACHT_SEARCH_WEIGHTING
        21852, -- GR_FLY_SWATTER_FLY_SWATTER_WEIGHTING
        21854, -- GR_STEAL_RAILGUNS_STEAL_RAILGUNS_WEIGHTING
        21857, -- GR_STEAL_MINIGUNS_STEAL_MINIGUNS_WEIGHTING
    },
    Steal_Names = {
        { "偷取厢型车", "" },
        { "偷取APC", "" },
        { "偷取坦克", "" },
        { "消灭对手行动单位", "" },
        { "偷取铁尼高", "" },
        { "Diversion", "不可进行" },
        { "矿坑", "" },
        { "利他教营地", "" },
        { "(推荐) 摧毁卡车", "不用踩黄点" },
        { "搜查码头或游艇", "" },
        { "干掉直升机", "" },
        { "偷取电磁步枪", "" },
        { "Steal Miniguns", "不可进行" },
    },
    Sell_Offsets = {
        21868, -- GR_MOVE_WEAPONS_MOVE_WEAPONS_WEIGHTING
        21870, -- 926342835
        21874, -- GR_AMBUSHED_AMBUSHED_WEIGHTING
        21876, -- GR_HILL_CLIMB_HILL_CLIMB_WEIGHTING
        21878, -- GR_ROUGH_TERRAIN_ROUGH_TERRAIN_WEIGHTING
        21880, -- GR_PHANTOM_PHANTOM_WEIGHTING
    },
    Sell_Names = {
        { "Move Weapons", "" },
        { "Unknown", "" },
        { "Ambushed", "" },
        { "Hill Climb", "" },
        { "Rough Terrain", "" },
        { "(推荐) 尖锥魅影", "两辆" },
    },
}

Globals.AirFreight = {
    Steal_Offsets = {
        22941, -- SMUG_STEAL_STEAL_AIRCRAFT_WEIGHTING
        22943, -- SMUG_STEAL_THERMAL_SCOPE_WEIGHTING
        22945, -- SMUG_STEAL_BEACON_GRAB_WEIGHTING
        22947, -- SMUG_STEAL_INFILTRATION_WEIGHTING
        22949, -- SMUG_STEAL_STUNT_PILOT_WEIGHTING
        22951, -- SMUG_STEAL_BOMB_BASE_WEIGHTING
        22953, -- SMUG_STEAL_SPLASH_LANDING_WEIGHTING
        22955, -- SMUG_STEAL_BLACKBOX_WEIGHTING
        22957, -- SMUG_STEAL_DOGFIGHT_WEIGHTING
        22959, -- SMUG_STEAL_CARGO_PLANE_WEIGHTING
        22962, -- SMUG_STEAL_ROOF_ATTACK_WEIGHTING
        22964, -- SMUG_STEAL_BOMBING_RUN_WEIGHTING
        22966, -- SMUG_STEAL_ESCORT_WEIGHTING
        22968, -- SMUG_STEAL_BOMB_ROOF_WEIGHTING
    },
    Steal_Names = {
        { "Steal Aircraft", "" },
        { "Air Ambulance", "多人任务" },
        { "摧毁干扰器", "" },
        { "运兵直升机潜入监狱", "需要进入运兵直升机" },
        { "特技表演", "" },
        { "摧毁基地", "不用踩黄点" },
        { "打捞点", "飞往打捞点，消灭打捞团队" },
        { "(推荐) 搜寻坠毁的小蛮牛", "不用踩黄点" },
        { "拦截梅利威瑟喷气机", "不用踩黄点" },
        { "拦截货机", "" },
        { "屋顶", "飞往屋顶，摧毁箱子" },
        { "摧毁目标", "不用踩黄点" },
        { "护送泰坦", "" },
        { "Roof Bombings", "多人任务" },
    },
    Sell_Offsets = {
        22970, -- SMUG_SELL_HEAVY_LIFTING_WEIGHTING
        23007, -- SMUG_SELL_CONTESTED_WEIGHTING
        23009, -- -779747251
        23011, -- SMUG_SELL_PRECISION_DELIVERY_WEIGHTING
        23013, -- SMUG_SELL_FLYING_FORTRESS_WEIGHTING
        23015, -- SMUG_SELL_FLY_LOW_WEIGHTING
        23017, -- SMUG_SELL_AIR_DELIVERY_WEIGHTING
        23019, -- SMUG_SELL_AIR_POLICE_WEIGHTING
        23021, -- 1786784008
    },
    Sell_Names = {
        { "吊挂直升机", "一个点" },
        { "猎杀者", "在投放点消灭敌人\n5个点" },
        { "浩劫者", "每架两个点" },
        { "运兵直升机", "" },
        { "Flying Fortress", "多人任务" },
        { "Fly Low", "5个点" },
        { "Air Delivery", "5个点" },
        { "莫古尔", "会有通缉\n5个点" },
        { "Unknown", "不可进行" },
    },
}

Globals.Biker = {
    BIKER_RESUPPLY_PACKAGE_VALUE = 262145 + 18560,
    BIKER_RESUPPLY_VEHICLE_VALUE = 262145 + 18561,
    Steal_Offsets = {
        18570, -- BIKER_RESUPPLY_WEED_FARM_WEIGHTING
        18577, -- BIKER_RESUPPLY_FRAGILE_SUPPLIES_WEIGHTING
        18585, -- BIKER_RESUPPLY_LURE_WEIGHTING
        18594, -- BIKER_RESUPPLY_MEET_CONTACT_WEIGHTING
        18603, -- BIKER_RESUPPLY_DESTROY_CRATES_WEIGHTING
        18610, -- BIKER_RESUPPLY_SECURITY_VANS_WEIGHTING
        18611, -- BIKER_RESUPPLY_REPAIRMAN_WEIGHTING
        18618, -- BIKER_RESUPPLY_BANK_WEIGHTING
        18628, -- BIKER_RESUPPLY_DRUG_LAB_WEIGHTING
        18635, -- BIKER_RESUPPLY_CHEMICALS_WEIGHTING
        18640, -- BIKER_RESUPPLY_KILL_DEALERS_WEIGHTING
        18647, -- BIKER_RESUPPLY_STEAL_VEHICLE_WEIGHTING
        18648, -- 448987950
        18649, -- BIKER_RESUPPLY_BIKER_MELEE_WEIGHTING
        18651, -- BIKER_RESUPPLY_SIGNAL_FLARE_WEIGHTING
        18656, -- BIKER_RESUPPLY_INTIMIDATION_WEIGHTING
    },
    Steal_Names = {
        { "Raid Nasty People", "仅大麻种植场可进行" },
        { "易碎原材料", "" },
        { "引诱警察", "吸引警察注意，保持通缉等级，直到原材料出现" },
        { "Meeting a Contact", "仅证件伪造办公室可进行" },
        { "摧毁箱子", "" },
        { "搜寻运载原材料的厢型车", "" },
        { "Repairman", "" },
        { "Fleeca Bank Robbery", "仅假钞工厂可进行" },
        { "Colombian Flake", "仅冰毒实验室可进行" },
        { "Disrupt Operations", "仅可卡因作坊可进行" },
        { "干掉敌人", "" },
        { "(推荐) 偷取载具", "不用踩黄点" },
        { "龙舌兰酒吧", "传送到门口后杀死所有敌人" },
        { "将敌人从摩托车上击落", "" },
        { "投掷信号弹", "" },
        { "威胁目标", "" },
    },
    Sell_Offsets = {
        18693, -- BIKER_DISABLE_SELL_CONVOY
        18695, -- BIKER_DISABLE_SELL_TRASHMASTER
        18699, -- BIKER_DISABLE_SELL_PROVEN
        18701, -- 864548199
        18706, -- BIKER_DISABLE_SELL_BORDER_PATROL
        18728, -- BIKER_DISABLE_SELL_HELICOPTER_DROP
        18731, -- BIKER_DISABLE_SELL_POSTMAN
        18733, -- -1893108522
        18740, -- BIKER_DISABLE_SELL_STING_OP
        18742, -- BIKER_DISABLE_SELL_BENSON
        18748, -- BIKER_DISABLE_SELL_BAG_DROP
        18753, -- BIKER_DISABLE_SELL_RACE
        18758, -- BIKER_DISABLE_CLUB_RUN
    },
    Sell_Names = {
        { "(推荐) Convoy", "卡车\n1个点" },
        { "Trashmaster", "垃圾车\n每辆车5个点" },
        { "Proven", "不可进行" },
        { "Unknown1", "不可进行" },
        { "Border Patrol", "船\n每只船5个点" },
        { "Helicopter Drop", "直升机\n每架5个点" },
        { "Postman", "厢型车\n每辆车5个点" },
        { "Unknown2", "嘟嘟鸟飞机\n每架5个点" },
        { "Sting Op", "不可进行" },
        { "Benson", "摩托车\n每辆车1个点" },
        { "Bag Drop", "多人任务" },
        { "Race", "多人任务" },
        { "Club Run", "多人任务" },
    },
    BIKER_DISABLE_SELL_BORDER_PATROL_0 = 262145 + 18707, -- _9 = 18716
}

Globals.AcidLab = {
    ACID_LAB_RESUPPLY_CRATE_VALUE = 262145 + 32918,
}

Globals.Payphone = {
    Hit_Offsets = {
        31956, -- PAYPHONE_TAXI_WEIGHTING
        31957, -- PAYPHONE_GOLF_WEIGHTING
        31958, -- PAYPHONE_MOTEL_WEIGHTING
        31959, -- -2129051069
        31961, -- PAYPHONE_CONSTRUCTION_WEIGHTING
        31962, -- PAYPHONE_JOYRIDER_WEIGHTING

        -- 31960, -- 37939428
        -- 31963, -- PAYPHONE_APPROACH_WEIGHTING
    },
    Hit_Names = {
        "科技企业家(出租车)",
        "法官(高尔夫)",
        "共同创办人(汽车旅馆)",
        "死宅散户",
        "工地总裁",
        "流行歌星",

        -- "Unknown",
        -- "Approach",
    },
}

function Globals.SpecialCargo.ClearMissionHistory()
    local EXEC_BUY_MISSIONS_HISTORY = 262145 + 16264
    local buy_base = 1895156 + 1 + players.user() * 609 + 10 + 312 + 1
    -- freemode.c Global_1895156[PLAYER::PLAYER_ID() /*609*/].f_10.f_312[iVar0] = ..., Search EXEC_BUY_MISSIONS_HISTORY

    local i = 0
    while i < GET_INT_GLOBAL(EXEC_BUY_MISSIONS_HISTORY) do
        SET_INT_GLOBAL(buy_base + i, -1)
        i = i + 1
    end

    local EXEC_SELL_MISSIONS_HISTORY = 262145 + 16265
    local sell_base = 2794162 + 5231 + 349 + 1
    -- gb_contraband_sell.c if (Global_2794162.f_5231.f_349[iVar0] == iParam0), Search EXEC_SELL_MISSIONS_HISTORY

    local i = 0
    while i < GET_INT_GLOBAL(EXEC_SELL_MISSIONS_HISTORY) do
        SET_INT_GLOBAL(sell_base + i, -1)
        i = i + 1
    end
end

function Globals.Bunker.ClearMissionHistory()
    local GR_RESUPPLY_GENERAL_HISTORY_LIST = 262145 + 21818 -- -405844416
    local resupply_base = 1895156 + 1 + players.user() * 609 + 10 + 378 + 1
    -- freemode.c Global_1895156[PLAYER::PLAYER_ID() /*609*/].f_10.f_378[iVar0] = ..., Search GR_RESUPPLY_GENERAL_HISTORY_LIST

    local i = 0
    while i < GET_INT_GLOBAL(GR_RESUPPLY_GENERAL_HISTORY_LIST) do
        SET_INT_GLOBAL(resupply_base + i, -1)
        i = i + 1
    end

    local GR_GENERAL_HISTORY_LIST = 262145 + 21860 -- 1667999010
    local sell_base = 1895156 + 1 + players.user() * 609 + 10 + 387 + 1
    -- freemode.c Global_1895156[PLAYER::PLAYER_ID() /*609*/].f_10.f_387[iVar0] = ..., Search GR_GENERAL_HISTORY_LIST

    local i = 0
    while i < GET_INT_GLOBAL(GR_GENERAL_HISTORY_LIST) do
        SET_INT_GLOBAL(sell_base + i, -1)
        i = i + 1
    end
end

function Globals.AirFreight.ClearMissionHistory()
    local SMUG_BUY_HISTORY_LIST = 262145 + 22885 -- -1676961419
    local buy_base = 1895156 + 1 + players.user() * 609 + 10 + 394 + 1
    -- freemode.c Global_1895156[PLAYER::PLAYER_ID() /*609*/].f_10.f_394[iVar0] = ..., Search -1676961419

    local i = 0
    while i < GET_INT_GLOBAL(SMUG_BUY_HISTORY_LIST) do
        SET_INT_GLOBAL(buy_base + i, -1)
        i = i + 1
    end

    local SMUG_SELL_HISTORY_LIST = 262145 + 22975
    local sell_base = 1895156 + 1 + players.user() * 609 + 10 + 403 + 1
    -- freemode.c Global_1895156[PLAYER::PLAYER_ID() /*609*/].f_10.f_403[iVar0] = ..., Search SMUG_SELL_HISTORY_LIST

    local i = 0
    while i < GET_INT_GLOBAL(SMUG_SELL_HISTORY_LIST) do
        SET_INT_GLOBAL(sell_base + i, -1)
        i = i + 1
    end
end

function Globals.Biker.ClearMissionHistory()
    local BIKER_RESUPPLY_HISTORY_LIST = 262145 + 18567 -- 1185530883
    local resupply_base = 1895156 + 1 + players.user() * 609 + 10 + 196 + 1
    -- freemode.c if (Global_1895156[iVar0 /*609*/].f_10.f_196[iVar1] == iParam0), Search 1185530883

    local i = 0
    while i < GET_INT_GLOBAL(BIKER_RESUPPLY_HISTORY_LIST) do
        SET_INT_GLOBAL(resupply_base + i, -1)
        i = i + 1
    end

    local BIKER_SELL_HISTORY_LIST = 262145 + 18687 -- 731581918
    local sell_base = 2794162 + 5231 + 358 + 1
    -- gb_biker_contraband_sell.c if (Global_2794162.f_5231.f_358[iVar0] == iParam0), Search 731581918

    local i = 0
    while i < GET_INT_GLOBAL(BIKER_SELL_HISTORY_LIST) do
        SET_INT_GLOBAL(sell_base + i, -1)
        i = i + 1
    end
end

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

function Globals.RemoveCooldown.CeoAbility(toggle)
    local tunables = {
        13007, -- GB_DROP_AMMO_COOLDOWN
        13008, -- GB_DROP_ARMOR_COOLDOWN
        13009, -- GB_DROP_BULLSHARK_COOLDOWN
        13010, -- GB_GHOST_ORG_COOLDOWN
        13011, -- GB_BRIBE_AUTHORITIES_COOLDOWN
    }
    local default_value = {
        30000, 30000, 30000, 600000, 600000,
    }

    if toggle then
        for key, offset in pairs(tunables) do
            SET_INT_GLOBAL(262145 + offset, 0)
        end
    else
        for key, offset in pairs(tunables) do
            SET_INT_GLOBAL(262145 + offset, default_value[key])
        end
    end
end

function Globals.RemoveCooldown.OtherVehicle(toggle)
    local tunables = {
        11884, -- PEGASUS_CRIM_COOL_DOWN
        12124, -- LESTER_VEHICLE_CRIM_COOL_DOWN
        22046, -- ACID_LAB_REQUEST_COOLDOWN
        28615, -- 247954694 (MK2)
        31116, -- IH_MOON_POOL_COOLDOWN
        33466, -- TONY_LIMO_COOLDOWN_TIME
        33467, -- BUNKER_VEHICLE_COOLDOWN_TIME
    }
    local default_value = {
        300000,
        300000,
        300000,
        120000,
        300000,
        120000,
        120000,
    }

    if toggle then
        for key, offset in pairs(tunables) do
            SET_INT_GLOBAL(262145 + offset, 0)
        end
    else
        for key, offset in pairs(tunables) do
            SET_INT_GLOBAL(262145 + offset, default_value[key])
        end
    end
end

Globals.Biker.Contracts = {}

function Globals.Biker.Contracts.MinPlayer(toggle)
    local tunables = {
        18830, -- BIKER_GUNS_FOR_HIRE_MIN_PLAYERS
        18850, -- BIKER_WEAPON_OF_CHOICE_MIN_PLAYERS
        18868, -- BIKER_NINE_TENTHS_MIN_PLAYERS
        18898, -- BIKER_FRAGILE_GOODS_MIN_PLAYERS
        18911, -- BIKER_OUTRIDER_MIN_PLAYERS
    }

    if toggle then
        for _, offset in pairs(tunables) do
            SET_INT_GLOBAL(262145 + offset, 1)
        end
    else
        for _, offset in pairs(tunables) do
            SET_INT_GLOBAL(262145 + offset, 2)
        end
    end
end

function Globals.DisableBusinessRaid(toggle)
    local tunables = {
        15851, -- EXEC_DISABLE_DEFEND_MISSIONS
        15852, -- EXEC_DISABLE_DEFEND_FLEEING
        15853, -- EXEC_DISABLE_DEFEND_UNDER_ATTACK
        18776, -- BIKER_DISABLE_DEFEND_POLICE_RAID
        18780, -- BIKER_DISABLE_DEFEND_SHOOTOUT
        18782, -- BIKER_DISABLE_DEFEND_GETAWAY
        18784, -- BIKER_DISABLE_DEFEND_CRASH_DEAL
        18786, -- -133464516
        18788, -- BIKER_DISABLE_DEFEND_SNITCH
        21886, -- GR_DEFEND_VALKYRIE_DISABLE_VALKYRIE
        21891, -- GR_DEFEND_DISARM_BOMBS_DISABLE_DISARM_BOMBS
    }

    if toggle then
        for _, offset in pairs(tunables) do
            SET_INT_GLOBAL(262145 + offset, 1)
        end
    else
        for _, offset in pairs(tunables) do
            SET_INT_GLOBAL(262145 + offset, 0)
        end
    end
end

Locals = {
    -- fm_mission_controller_2020
    MC_TLIVES_2020 = 51905 + 868 + 1,

    -- fm_mission_controller
    MC_TLIVES = 26136 + 1325 + 1,
}
