-- GTA Online Version: 1.68-3095

----------------------------
-- Tunables
----------------------------

Tunables = {
    -- CEO Ability
    GB_GHOST_ORG_DURATION = 13349,
    GB_BRIBE_AUTHORITIES_DURATION = 13350,

    FIXER_SECURITY_CONTRACT_REFRESH_TIME = 32023,
    TURN_SNOW_ON_OFF = 4575,
    AI_HEALTH = 165,

    -- Cooldown
    GB_CALL_VEHICLE_COOLDOWN = 13032,
    VC_WORK_REQUEST_COOLDOWN = 27510,

    BUNKER_RESEARCH_REQUEST_COOLDOWN = 33198, -- 370341838
    NC_GOODS_REQUEST_COOLDOWN = 33199,        -- 236343681

    -- Special Cargo
    EXEC_CONTRABAND_TYPE_REFRESH_TIME = 15762,
    EXEC_CONTRABAND_SPECIAL_ITEM_THRESHOLD = 15763,
    EXEC_CONTRABAND_SPECIAL_ITEM_CHANCE = 15764,

    -- Bunker
    GR_RESUPPLY_PACKAGE_VALUE = 21733,
    GR_RESUPPLY_VEHICLE_VALUE = 21734,

    -- Biker
    BIKER_RESUPPLY_PACKAGE_VALUE = 18590,
    BIKER_RESUPPLY_VEHICLE_VALUE = 18591,

    -- Acid Lab
    ACID_LAB_RESUPPLY_CRATE_VALUE = 33039,
}

----------------------------
-- Globals
----------------------------

Globals = {
    IsUsingComputerScreen = 76369,
    MissionCameraLock = 4718592 + 54310,

    RC_Bandito = 2738587 + 6918,
    RC_Tank = 2738587 + 6919,
    BallisticArmor = 2738587 + 901,

    -- 无视犯罪
    NCOPS = {
        type = 2738587 + 4661,
        flag = 2738587 + 4662,
        time = 2738587 + 4664,
    },
}

Globals.SpecialCargo = {
    Buy_Offsets = {
        15793, -- EXEC_DISABLE_BUY_AFTERMATH
        15799, -- EXEC_DISABLE_BUY_AMBUSHED
        15800, -- EXEC_DISABLE_BUY_ASSASSINATE
        15806, -- EXEC_DISABLE_BUY_BOATATTACK
        15812, -- EXEC_DISABLE_BUY_BREAKUPDEAL
        15818, -- EXEC_DISABLE_BUY_CARGODROP
        15819, -- EXEC_DISABLE_BUY_CRASHSITE
        15825, -- EXEC_DISABLE_BUY_GANGHIDEOUT
        15852, -- EXEC_DISABLE_BUY_HELITAKEDOWN
        15853, -- EXEC_DISABLE_BUY_IMPOUNDED
        15859, -- EXEC_DISABLE_BUY_MOVEDCOLLECTION
        15860, -- EXEC_DISABLE_BUY_MOVINGCOLLECTION
        15861, -- EXEC_DISABLE_BUY_MULTIPLEMOVINGVEHICLES
        15862, -- EXEC_DISABLE_BUY_POLICESTING
        15868, -- EXEC_DISABLE_BUY_STEALTRANSPORTER
        15869, -- EXEC_DISABLE_BUY_THIEF
        15870, -- EXEC_DISABLE_BUY_TRACKIFY
        15871, -- EXEC_DISABLE_BUY_TRAPPED
        15877, -- EXEC_DISABLE_BUY_VALKYRIETAKEDOWN
        15878, -- EXEC_DISABLE_BUY_VEHICLECOLLECTION
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
        15883, -- EXEC_DISABLE_SELL_AIRATTACKED
        15889, -- EXEC_DISABLE_SELL_AIRCLEARAREA
        15895, -- EXEC_DISABLE_SELL_AIRDROP
        15901, -- EXEC_DISABLE_SELL_AIRFLYLOW
        15902, -- EXEC_DISABLE_SELL_AIRRESTRICTED
        15908, -- EXEC_DISABLE_SELL_ATTACKED
        15909, -- EXEC_DISABLE_SELL_DEFAULT
        15910, -- EXEC_DISABLE_SELL_DEFEND
        15932, -- EXEC_DISABLE_SELL_MULTIPLE
        15938, -- EXEC_DISABLE_SELL_NODAMAGE
        15939, -- EXEC_DISABLE_SELL_SEAATTACKED
        15945, -- EXEC_DISABLE_SELL_SEADEFEND
        15951, -- EXEC_DISABLE_SELL_STING
        15957, -- EXEC_DISABLE_SELL_TRACKIFY
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

function Globals.SpecialCargo.NoWanted(toggle)
    local offsets = {
        15740, -- EXEC_BUY_ASSASSINATE_WANTED_CAP
        15741, -- EXEC_BUY_BOATATTACK_WANTED_CAP
        15742, -- EXEC_BUY_CRASHSITE_WANTED_CAP
        15748, -- EXEC_BUY_IMPOUNDED_WANTED_CAP
        15749, -- EXEC_BUY_POLICESTING_WANTED_CAP
        15750, -- EXEC_BUY_STEALTRANSPORTER_WANTED_CAP
        16872, -- EXEC_BUY_LOSE_THE_COPS_WANTED_CAP
        16876, -- EXEC_BUY_STEALTRANSPORTER_EASY_WANTED_CAP
        16877, -- EXEC_BUY_STEALTRANSPORTER_MEDIUM_WANTED_CAP
        16878, -- EXEC_BUY_ASSASSINATE_EASY_WANTED_CAP
        16879, -- EXEC_BUY_ASSASSINATE_MEDIUM_WANTED_CAP
        16880, -- EXEC_BUY_CRASHSITE_EASY_WANTED_CAP
        16881, -- EXEC_BUY_CRASHSITE_MEDIUM_WANTED_CAP
        16882, -- EXEC_BUY_IMPOUNDED_EASY_WANTED_CAP
        16883, -- EXEC_BUY_IMPOUNDED_MEDIUM_WANTED_CAP
        16884, -- EXEC_BUY_POLICESTING_EASY_WANTED_CAP
        16885, -- EXEC_BUY_POLICESTING_MEDIUM_WANTED_CAP
        16889, -- EXEC_BUY_MEDIUM_WANTED_RATING_CAP
        16893, -- EXEC_BUY_EASY_WANTED_RATING_CAP
        15767, -- EXEC_SELL_AIRFLYLOW_WANTED_CAP
        15769, -- EXEC_SELL_AIRRESTRICTED_WANTED_CAP
        15788, -- EXEC_SELL_STING_WANTED_CAP
        16914, -- EXEC_SELL_HARD_WANTED_CAP
    }
    local defaults = {
        3,
        3,
        3,
        3,
        3,
        3,
        1,
        1,
        2,
        1,
        2,
        1,
        2,
        1,
        2,
        1,
        2,
        2,
        1,
        2,
        3,
        3,
        3,
    }

    if toggle then
        for key, offset in pairs(offsets) do
            TUNABLE_SET_INT(offset, 0)
        end
    else
        for key, offset in pairs(offsets) do
            TUNABLE_SET_INT(offset, defaults[key])
        end
    end
end

function Globals.SpecialCargo.ClearMissionHistory()
    local buy_history_list = 7 -- EXEC_BUY_MISSIONS_HISTORY
    local buy_history_base = 1886967 + 1 + players.user() * 609 + 10 + 312 + 1
    -- freemode.c Global_1886967[PLAYER::PLAYER_ID() /*609*/].f_10.f_312[iVar0] = ..., Search EXEC_BUY_MISSIONS_HISTORY

    local i = 0
    while i < buy_history_list do
        GLOBAL_SET_INT(buy_history_base + i, -1)
        i = i + 1
    end

    local sell_history_list = 7 -- EXEC_SELL_MISSIONS_HISTORY
    local sell_history_base = 2738587 + 5234 + 350 + 1
    -- gb_contraband_sell.c if (Global_2738587.f_5234.f_350[iVar0] == iParam0), Search EXEC_SELL_MISSIONS_HISTORY

    i = 0
    while i < sell_history_list do
        GLOBAL_SET_INT(sell_history_base + i, -1)
        i = i + 1
    end
end

Globals.Bunker = {
    Steal_Offsets = {
        21854, -- GR_STEAL_VAN_STEAL_VAN_WEIGHTING
        21856, -- GR_STEAL_APC_STEAL_APC_WEIGHTING
        21859, -- GR_STEAL_RHINO_STEAL_RHINO_WEIGHTING
        21863, -- GR_RIVAL_OPERATION_RIVAL_OPERATION_WEIGHTING
        21865, -- GR_STEAL_TECHNICAL_STEAL_TECHNICAL_WEIGHTING
        21867, -- GR_DIVERSION_DIVERSION_WEIGHTING
        21869, -- GR_FLASHLIGHT_FLASHLIGHT_WEIGHTING
        21875, -- GR_ALTRUISTS_ALTRUIST_WEIGHTING
        21877, -- GR_DESTROY_TRUCKS_DESTROY_TRUCKS_WEIGHTING
        21880, -- GR_YACHT_SEARCH_YACHT_SEARCH_WEIGHTING
        21882, -- GR_FLY_SWATTER_FLY_SWATTER_WEIGHTING
        21884, -- GR_STEAL_RAILGUNS_STEAL_RAILGUNS_WEIGHTING
        21887, -- GR_STEAL_MINIGUNS_STEAL_MINIGUNS_WEIGHTING
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
        21898, -- GR_MOVE_WEAPONS_MOVE_WEAPONS_WEIGHTING
        21900, -- 926342835
        21904, -- GR_AMBUSHED_AMBUSHED_WEIGHTING
        21906, -- GR_HILL_CLIMB_HILL_CLIMB_WEIGHTING
        21908, -- GR_ROUGH_TERRAIN_ROUGH_TERRAIN_WEIGHTING
        21910, -- GR_PHANTOM_PHANTOM_WEIGHTING
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

function Globals.Bunker.ClearMissionHistory()
    local resupply_history_list = 6 -- GR_RESUPPLY_GENERAL_HISTORY_LIST
    local resupply_history_base = 1886967 + 1 + players.user() * 609 + 10 + 378 + 1
    -- freemode.c Global_1886967[PLAYER::PLAYER_ID() /*609*/].f_10.f_378[iVar0] = ..., Search GR_RESUPPLY_GENERAL_HISTORY_LIST

    local i = 0
    while i < resupply_history_list do
        GLOBAL_SET_INT(resupply_history_base + i, -1)
        i = i + 1
    end

    local sell_history_list = 2 -- GR_GENERAL_HISTORY_LIST
    local sell_history_base = 1886967 + 1 + players.user() * 609 + 10 + 387 + 1
    -- freemode.c Global_1886967[PLAYER::PLAYER_ID() /*609*/].f_10.f_387[iVar0] = ..., Search GR_GENERAL_HISTORY_LIST

    i = 0
    while i < sell_history_list do
        GLOBAL_SET_INT(sell_history_base + i, -1)
        i = i + 1
    end
end

Globals.AirFreight = {
    Steal_Offsets = {
        22971, -- SMUG_STEAL_STEAL_AIRCRAFT_WEIGHTING
        22973, -- SMUG_STEAL_THERMAL_SCOPE_WEIGHTING
        22975, -- SMUG_STEAL_BEACON_GRAB_WEIGHTING
        22977, -- SMUG_STEAL_INFILTRATION_WEIGHTING
        22979, -- SMUG_STEAL_STUNT_PILOT_WEIGHTING
        22981, -- SMUG_STEAL_BOMB_BASE_WEIGHTING
        22983, -- SMUG_STEAL_SPLASH_LANDING_WEIGHTING
        22985, -- SMUG_STEAL_BLACKBOX_WEIGHTING
        22987, -- SMUG_STEAL_DOGFIGHT_WEIGHTING
        22989, -- SMUG_STEAL_CARGO_PLANE_WEIGHTING
        22992, -- SMUG_STEAL_ROOF_ATTACK_WEIGHTING
        22994, -- SMUG_STEAL_BOMBING_RUN_WEIGHTING
        22996, -- SMUG_STEAL_ESCORT_WEIGHTING
        22998, -- SMUG_STEAL_BOMB_ROOF_WEIGHTING
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
        23000, -- SMUG_SELL_HEAVY_LIFTING_WEIGHTING
        23037, -- SMUG_SELL_CONTESTED_WEIGHTING
        23039, -- -779747251
        23041, -- SMUG_SELL_PRECISION_DELIVERY_WEIGHTING
        23043, -- SMUG_SELL_FLYING_FORTRESS_WEIGHTING
        23045, -- SMUG_SELL_FLY_LOW_WEIGHTING
        23047, -- SMUG_SELL_AIR_DELIVERY_WEIGHTING
        23049, -- SMUG_SELL_AIR_POLICE_WEIGHTING
        23051, -- 1786784008
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

function Globals.AirFreight.ClearMissionHistory()
    local steal_history_list = 6 -- -1676961419
    local steal_history_base = 1886967 + 1 + players.user() * 609 + 10 + 394 + 1
    -- freemode.c Global_1886967[PLAYER::PLAYER_ID() /*609*/].f_10.f_394[iVar0] = ..., Search -1676961419

    local i = 0
    while i < steal_history_list do
        GLOBAL_SET_INT(steal_history_base + i, -1)
        i = i + 1
    end

    local sell_history_list = 4 -- SMUG_SELL_HISTORY_LIST
    local sell_history_base = 1886967 + 1 + players.user() * 609 + 10 + 403 + 1
    -- freemode.c Global_1886967[PLAYER::PLAYER_ID() /*609*/].f_10.f_403[iVar0] = ..., Search SMUG_SELL_HISTORY_LIST

    i = 0
    while i < sell_history_list do
        GLOBAL_SET_INT(sell_history_base + i, -1)
        i = i + 1
    end
end

Globals.Biker = {
    Steal_Offsets = {
        18600, -- BIKER_RESUPPLY_WEED_FARM_WEIGHTING
        18607, -- BIKER_RESUPPLY_FRAGILE_SUPPLIES_WEIGHTING
        18615, -- BIKER_RESUPPLY_LURE_WEIGHTING
        18624, -- BIKER_RESUPPLY_MEET_CONTACT_WEIGHTING
        18633, -- BIKER_RESUPPLY_DESTROY_CRATES_WEIGHTING
        18640, -- BIKER_RESUPPLY_SECURITY_VANS_WEIGHTING
        18641, -- BIKER_RESUPPLY_REPAIRMAN_WEIGHTING
        18648, -- BIKER_RESUPPLY_BANK_WEIGHTING
        18658, -- BIKER_RESUPPLY_DRUG_LAB_WEIGHTING
        18665, -- BIKER_RESUPPLY_CHEMICALS_WEIGHTING
        18670, -- BIKER_RESUPPLY_KILL_DEALERS_WEIGHTING
        18677, -- BIKER_RESUPPLY_STEAL_VEHICLE_WEIGHTING
        18678, -- 448987950
        18679, -- BIKER_RESUPPLY_BIKER_MELEE_WEIGHTING
        18681, -- BIKER_RESUPPLY_SIGNAL_FLARE_WEIGHTING
        18686, -- BIKER_RESUPPLY_INTIMIDATION_WEIGHTING
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
        18723, -- BIKER_DISABLE_SELL_CONVOY
        18725, -- BIKER_DISABLE_SELL_TRASHMASTER
        18729, -- BIKER_DISABLE_SELL_PROVEN
        18731, -- 864548199
        18736, -- BIKER_DISABLE_SELL_BORDER_PATROL
        18758, -- BIKER_DISABLE_SELL_HELICOPTER_DROP
        18761, -- BIKER_DISABLE_SELL_POSTMAN
        18763, -- -1893108522
        18770, -- BIKER_DISABLE_SELL_STING_OP
        18772, -- BIKER_DISABLE_SELL_BENSON
        18778, -- BIKER_DISABLE_SELL_BAG_DROP
        18783, -- BIKER_DISABLE_SELL_RACE
        18788, -- BIKER_DISABLE_CLUB_RUN
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

    BIKER_DISABLE_SELL_BORDER_PATROL_0 = 262145 + 18737, -- _9 = 18746
}

function Globals.Biker.ClearMissionHistory()
    local resupply_history_list = 6 -- 1185530883
    local resupply_history_base = 1886967 + 1 + players.user() * 609 + 10 + 196 + 1
    -- freemode.c if (Global_1886967[iVar0 /*609*/].f_10.f_196[iVar1] == iParam0), Search 1185530883

    local i = 0
    while i < resupply_history_list do
        GLOBAL_SET_INT(resupply_history_base + i, -1)
        i = i + 1
    end

    local sell_history_list = 6 -- 731581918
    local sell_history_base = 2738587 + 5234 + 359 + 1
    -- gb_biker_contraband_sell.c if (Global_2738587.f_5234.f_359[iVar0] == iParam0), Search 731581918

    i = 0
    while i < sell_history_list do -- 6
        GLOBAL_SET_INT(sell_history_base + i, -1)
        i = i + 1
    end
end

Globals.VehicleCargo = {}

function Globals.VehicleCargo.NoWanted(toggle)
    local offsets = {
        19533, -- IMPEXP_STEAL_HARD_WANTED_CAP
        19537, -- IMPEXP_STEAL_MEDIUM_WANTED_CAP
        19543, -- IMPEXP_STEAL_EASY_WANTED_CAP
        19562, -- IMPEXP_POLICE_CHASE_WANTED_CAP
        16872, -- EXEC_BUY_LOSE_THE_COPS_WANTED_CAP
    }
    local defaults = {
        3,
        2,
        1,
        3,
        1,
    }

    if toggle then
        for key, offset in pairs(offsets) do
            TUNABLE_SET_INT(offset, 0)
        end
    else
        for key, offset in pairs(offsets) do
            TUNABLE_SET_INT(offset, defaults[key])
        end
    end
end

function Globals.VehicleCargo.NoDamageReduction(toggle)
    local offsets = {
        19868, -- IMPEXP_STEAL_REDUCTION_HARD
        19869, -- IMPEXP_STEAL_REDUCTION_MEDIUM
        19870, -- IMPEXP_STEAL_REDUCTION_EASY
        19613, -- IMPEXP_SELL_REDUCTION_BUYER1_HARD
        19614, -- IMPEXP_SELL_REDUCTION_BUYER1_MEDIUM
        19615, -- IMPEXP_SELL_REDUCTION_BUYER1_EASY
        19616, -- IMPEXP_SELL_REDUCTION_BUYER2_HARD
        19617, -- IMPEXP_SELL_REDUCTION_BUYER2_MEDIUM
        19618, -- IMPEXP_SELL_REDUCTION_BUYER2_EASY
        19619, -- IMPEXP_SELL_REDUCTION_BUYER3_HARD
        19620, -- IMPEXP_SELL_REDUCTION_BUYER3_MEDIUM
        19621, -- IMPEXP_SELL_REDUCTION_BUYER3_EASY
    }
    local defaults = {
        49,
        30,
        18,
        28,
        18,
        11,
        45,
        28,
        17,
        62,
        39,
        23,
    }

    if toggle then
        for key, offset in pairs(offsets) do
            TUNABLE_SET_INT(offset, 0)
        end
    else
        for key, offset in pairs(offsets) do
            TUNABLE_SET_INT(offset, defaults[key])
        end
    end
end

Globals.Payphone = {
    Hit_Offsets = {
        32072, -- PAYPHONE_TAXI_WEIGHTING
        32073, -- PAYPHONE_GOLF_WEIGHTING
        32074, -- PAYPHONE_MOTEL_WEIGHTING
        32075, -- -2129051069
        32077, -- PAYPHONE_CONSTRUCTION_WEIGHTING
        32078, -- PAYPHONE_JOYRIDER_WEIGHTING
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

Globals.RemoveCooldown = {}

function Globals.RemoveCooldown.SpecialCargo(toggle)
    local offsets = {
        15756, -- EXEC_BUY_COOLDOWN
        15757, -- EXEC_SELL_COOLDOWN
    }
    local defaults = {
        300000,
        1800000,
    }

    if toggle then
        for key, offset in pairs(offsets) do
            TUNABLE_SET_INT(offset, 0)
        end
    else
        for key, offset in pairs(offsets) do
            TUNABLE_SET_INT(offset, defaults[key])
        end
    end
end

function Globals.RemoveCooldown.VehicleCargo(toggle)
    local offsets = {
        19524, -- IMPEXP_STEAL_COOLDOWN
        19892, -- 1001423248
        19893, -- 240134765
        19894, -- 1915379148
        19895, -- -824005590
    }
    local defaults = {
        180000,
        1200000,
        1680000,
        2340000,
        2880000,
    }

    if toggle then
        for key, offset in pairs(offsets) do
            TUNABLE_SET_INT(offset, 0)
        end
    else
        for key, offset in pairs(offsets) do
            TUNABLE_SET_INT(offset, defaults[key])
        end
    end
end

function Globals.RemoveCooldown.AirFreightCargo(toggle)
    local offsets = {
        22961, -- SMUG_STEAL_EASY_COOLDOWN_TIMER
        22962, -- SMUG_STEAL_MED_COOLDOWN_TIMER
        22963, -- SMUG_STEAL_HARD_COOLDOWN_TIMER
        22964, -- 1722502526
        22965, -- -1091356151
    }
    local defaults = {
        120000,
        180000,
        240000,
        60000,
        2000,
    }

    if toggle then
        for key, offset in pairs(offsets) do
            TUNABLE_SET_INT(offset, 0)
        end
    else
        for key, offset in pairs(offsets) do
            TUNABLE_SET_INT(offset, defaults[key])
        end
    end
end

function Globals.RemoveCooldown.PayphoneHitAndContract(toggle)
    local offsets = {
        32024, -- FIXER_SECURITY_CONTRACT_COOLDOWN_TIME
        32089, -- -2036534141
        32105, -- 1872071131
    }
    local defaults = {
        300000,
        500,
        1200000,
    }

    if toggle then
        for key, offset in pairs(offsets) do
            TUNABLE_SET_INT(offset, 0)
        end
    else
        for key, offset in pairs(offsets) do
            TUNABLE_SET_INT(offset, defaults[key])
        end
    end
end

function Globals.RemoveCooldown.CeoAbility(toggle)
    local offsets = {
        13034, -- GB_DROP_AMMO_COOLDOWN
        13035, -- GB_DROP_ARMOR_COOLDOWN
        13036, -- GB_DROP_BULLSHARK_COOLDOWN
        13037, -- GB_GHOST_ORG_COOLDOWN
        13038, -- GB_BRIBE_AUTHORITIES_COOLDOWN
    }
    local defaults = {
        30000, 30000, 30000, 600000, 600000,
    }

    if toggle then
        for key, offset in pairs(offsets) do
            TUNABLE_SET_INT(offset, 0)
        end
    else
        for key, offset in pairs(offsets) do
            TUNABLE_SET_INT(offset, defaults[key])
        end
    end
end

function Globals.RemoveCooldown.OtherVehicle(toggle)
    local offsets = {
        11911, -- PEGASUS_CRIM_COOL_DOWN
        12151, -- LESTER_VEHICLE_CRIM_COOL_DOWN
        22076, -- ACID_LAB_REQUEST_COOLDOWN
        28685, -- 247954694
        31190, -- IH_MOON_POOL_COOLDOWN
        33588, -- TONY_LIMO_COOLDOWN_TIME
        33589, -- BUNKER_VEHICLE_COOLDOWN_TIME
    }
    local defaults = {
        300000,
        300000,
        300000,
        120000,
        300000,
        120000,
        120000,
    }

    if toggle then
        for key, offset in pairs(offsets) do
            TUNABLE_SET_INT(offset, 0)
        end
    else
        for key, offset in pairs(offsets) do
            TUNABLE_SET_INT(offset, defaults[key])
        end
    end
end

Globals.Biker.Contracts = {}

function Globals.Biker.Contracts.MinPlayer(toggle)
    local offsets = {
        18860, -- BIKER_GUNS_FOR_HIRE_MIN_PLAYERS
        18880, -- BIKER_WEAPON_OF_CHOICE_MIN_PLAYERS
        18898, -- BIKER_NINE_TENTHS_MIN_PLAYERS
        18928, -- BIKER_FRAGILE_GOODS_MIN_PLAYERS
        18941, -- BIKER_OUTRIDER_MIN_PLAYERS
    }

    if toggle then
        for _, offset in pairs(offsets) do
            TUNABLE_SET_INT(offset, 1)
        end
    else
        for _, offset in pairs(offsets) do
            TUNABLE_SET_INT(offset, 2)
        end
    end
end

function Globals.DisableBusinessRaid(toggle)
    local offsets = {
        15879, -- EXEC_DISABLE_DEFEND_MISSIONS
        15880, -- EXEC_DISABLE_DEFEND_FLEEING
        15881, -- EXEC_DISABLE_DEFEND_UNDER_ATTACK
        18806, -- BIKER_DISABLE_DEFEND_POLICE_RAID
        18810, -- BIKER_DISABLE_DEFEND_SHOOTOUT
        18812, -- BIKER_DISABLE_DEFEND_GETAWAY
        18814, -- BIKER_DISABLE_DEFEND_CRASH_DEAL
        18816, -- -133464516
        18818, -- BIKER_DISABLE_DEFEND_SNITCH
        21916, -- GR_DEFEND_VALKYRIE_DISABLE_VALKYRIE
        21921, -- GR_DEFEND_DISARM_BOMBS_DISABLE_DISARM_BOMBS
    }

    if toggle then
        for _, offset in pairs(offsets) do
            TUNABLE_SET_INT(offset, 1)
        end
    else
        for _, offset in pairs(offsets) do
            TUNABLE_SET_INT(offset, 0)
        end
    end
end

Globals.Request = {
    VehicleProperty = {
        { global = 2738587 + 930, command = "moc", name = "机动作战中心" },
        { global = 2738587 + 938, command = "avenger", name = "复仇者" },
        { global = 2738587 + 943, command = "terrorbyte", name = "恐霸" },
        { global = 2738587 + 960, command = "kosatka", name = "虎鲸" },
        { global = 2738587 + 972, command = "dinghy", name = "长崎" },
        { global = 2738587 + 944, command = "acidlab", name = "致幻剂实验室" },
        { global = 2738587 + 994, command = "bikeacidlab", name = "致幻剂送货摩托车" },
    },
}

----------------------------
-- Locals
----------------------------

Locals = {
    fm_mission_controller = {
        team_lives = 26154 + 1325 + 1,
    },

    fm_mission_controller_2020 = {
        team_lives = 55004 + 868 + 1,
    },

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

function Locals.SkipHacking()
    local script = "fm_mission_controller_2020"
    if IS_SCRIPT_RUNNING(script) then
        -- Skip The Hacking Process
        if LOCAL_GET_INT(script, 24333) == 4 then
            LOCAL_SET_INT(script, 24333, 5)
        end
        -- Skip Cutting The Sewer Grill
        if LOCAL_GET_INT(script, 29118) == 4 then
            LOCAL_SET_INT(script, 29118, 6)
        end
        -- Skip Cutting The Glass
        LOCAL_SET_FLOAT(script, 30357 + 3, 100)

        LOCAL_SET_INT(script, 978 + 135, 3) -- For ULP Missions
    end

    script = "fm_mission_controller"
    if IS_SCRIPT_RUNNING(script) then
        -- For Fingerprint
        if LOCAL_GET_INT(script, 52985) ~= 1 then
            LOCAL_SET_INT(script, 52985, 5)
        end
        -- For Keypad
        if LOCAL_GET_INT(script, 54047) ~= 1 then
            LOCAL_SET_INT(script, 54047, 5)
        end
        -- Skip Drilling The Vault Door
        local Value = LOCAL_GET_INT(script, 10107 + 37)
        LOCAL_SET_INT(script, 10107 + 7, Value)

        -- Doomsday Heist
        LOCAL_SET_INT(script, 1512, 3)       -- For ACT I, Setup: Server Farm (Lester)
        LOCAL_SET_INT(script, 1543, 2)
        LOCAL_SET_INT(script, 1269 + 135, 3) -- For ACT III

        -- Fleeca Heist
        LOCAL_SET_INT(script, 11760 + 24, 7)     -- Skip The Hacking Process
        LOCAL_SET_FLOAT(script, 10067 + 11, 100) -- Skip Drilling

        -- Pacific Standard Heist
        LOCAL_SET_BIT(script, 9773, 9) -- Skip The Hacking Process
    end

    script = "fm_content_island_heist"
    if IS_SCRIPT_RUNNING(script) then
        LOCAL_SET_BIT(script, 10040, 9)
    end
end

function Locals.VoltageHack()
    local script = "fm_mission_controller_2020"
    if IS_SCRIPT_RUNNING(script) then
        local current_value = LOCAL_GET_INT(script, 1722)
        LOCAL_SET_INT(script, 1721, current_value)
    end

    script = "fm_content_island_heist"
    if IS_SCRIPT_RUNNING(script) then
        local current_value = LOCAL_GET_INT(script, 765)
        LOCAL_SET_INT(script, 764, current_value)
    end
end

function Locals.StashHouseCode()
    local script = "fm_content_stash_house"
    if not IS_SCRIPT_RUNNING(script) then
        return
    end

    for i = 0, 2 do
        LOCAL_SET_FLOAT(script, 117 + 22 + 1 + i * 2, 0)
        LOCAL_SET_INT(script, 117 + 22 + 1 + i * 2 + 1, 0)
    end

    if TASK.GET_IS_TASK_ACTIVE(players.user_ped(), 135) then
        PAD.SET_CONTROL_VALUE_NEXT_FRAME(0, 237, 1)
    end
end
