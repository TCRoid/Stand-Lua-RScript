-- 颜色
color = {
    purple = {
        r = 1.0,
        g = 0.0,
        b = 1.0,
        a = 1.0
    },
    black = {
        r = 0.0,
        g = 0.0,
        b = 0.0,
        a = 1.0
    },
    white = {
        r = 1.0,
        g = 1.0,
        b = 1.0,
        a = 1.0
    }
}

-- 武器
WeaponName_ListItem = {
    { "小刀" },
    { "穿甲手枪" },
    { "电击枪" },
    { "微型冲锋枪" },
    { "特质卡宾步枪" },
    { "突击霰弹枪" },
    { "火神机枪" },
    { "火箭筒" },
    { "电磁步枪" }
}
WeaponModel_List = {
    "WEAPON_KNIFE",
    "WEAPON_APPISTOL",
    "WEAPON_STUNGUN",
    "WEAPON_MICROSMG",
    "WEAPON_SPECIALCARBINE",
    "WEAPON_ASSAULTSHOTGUN",
    "WEAPON_MINIGUN",
    "WEAPON_RPG",
    "WEAPON_RAILGUN"
}

-- 驾驶风格
DrivingStyleName_ListItem = {
    { "正常" },
    { "半冲刺" },
    { "反向" },
    { "无视红绿灯" },
    { "避开交通" },
    { "极度避开交通" },
    { "有时超车" },
}
DrivingStyle_List = {
    786603,
    1074528293,
    8388614,
    1076,
    2883621,
    786468,
    262144,
    786469,
    512,
    5,
    6
}

-- 实体类型
EntityType_ListItem = {
    { "Ped", {}, "NPC" },
    { "Vehicle", {}, "载具" },
    { "Object", {}, "物体" },
    { "Pickup", {}, "拾取物" }
}

-- enum
enum_PedType = {
    "PLAYER_0",
    "PLAYER_1",
    "NETWORK_PLAYER",
    "PLAYER_2",
    "CIVMALE",
    "CIVFEMALE",
    "COP",
    "GANG_ALBANIAN",
    "GANG_BIKER_1",
    "GANG_BIKER_2",
    "GANG_ITALIAN",
    "GANG_RUSSIAN",
    "GANG_RUSSIAN_2",
    "GANG_IRISH",
    "GANG_JAMAICAN",
    "GANG_AFRICAN_AMERICAN",
    "GANG_KOREAN",
    "GANG_CHINESE_JAPANESE",
    "GANG_PUERTO_RICAN",
    "DEALER",
    "MEDIC",
    "FIREMAN",
    "CRIMINAL",
    "BUM",
    "PROSTITUTE",
    "SPECIAL",
    "MISSION",
    "SWAT",
    "ANIMAL",
    "ARMY"
}

enum_CombatMovement = {
    "Stationary",
    "Defensive",
    "WillAdvance",
    "WillRetreat"
}

enum_CombatAbility = {
    "Poor",
    "Average",
    "Professional",
    "NumTypes"
}

enum_CombatRange = {
    "Near",
    "Medium",
    "Far",
    "VeryFar",
    "NumRanges"
}

enum_VehicleLockStatus = {
    "None", --0
    "Unlocked", --1
    "Locked", --2
    "LockedForPlayer", --3
    "StickPlayerInside", --4, -- Doesn't allow players to exit the vehicle with the exit vehicle key.
    "CanBeBrokenInto", --7, -- Can be broken into the car. If the glass is broken, the value will be set to 1
    "CanBeBrokenIntoPersist", --8, -- Can be broken into persist
    "CannotBeTriedToEnter" --10, -- Cannot be tried to enter (Nothing happens when you press the vehicle enter key).
}

enum_Alertness = {
    "Neutral", --0
    "Heard something", --1 gun shot, hit, etc
    "Knows", --2 the origin of the event
    "Fully alerted" --3 is facing the event?
}

-- blip
Blip_Color_Red = {
    1, 2, 3, 4, 5, 49, 59, 66, 67, 68, 69, 75
}

-- 爆炸类型 explosionType = index - 2
ExplosionType_ListItem = {
    { "Dont Care" }, -- -1
    { "Grenade" }, -- 0
    { "Grenade Launcher" }, -- 1
    { "Sticky Bomb" }, -- 2
    { "Molotov" }, -- 3
    { "Rocket" }, -- 4
    { "Tank Shell" }, -- 5
    { "Hi Octane" }, -- 6
    { "Car" }, -- 7
    { "Plane" }, -- 8
    { "Petrol Pump" }, -- 9
    { "Bike" }, -- 10
    { "Steam" }, -- 11
    { "Flame" }, -- 12
    { "Water Hydrant" }, -- 13
    { "Gas Canister Flame" }, -- 14
    { "Boat" }, -- 15
    { "Ship" }, -- 16
    { "Truck" }, -- 17
    { "Bullet" }, -- 18
    { "Smoke Grenade Launcher" }, -- 19
    { "Smoke Grenade" }, -- 20
    { "BZ Gas" }, -- 21
    { "Flare" }, -- 22
    { "Gas Canister" }, -- 23
    { "Extinguisher" }, -- 24
    { "Programmable AR" }, -- 25
    { "Train" }, -- 26
    { "Barrel (Blue)" }, -- 27
    { "Propane" }, -- 28
    { "Blimp" }, -- 29
    { "Flame Explode" }, -- 30
    { "Tanker" }, -- 31
    { "Plane Rocket" }, -- 32
    { "Vehicle Bullet" }, -- 33
    { "Gas Tank" }, -- 34
    { "Bird Crap" }, -- 35
    { "Railgun" }, -- 36
    { "Blimp (Red & Cyan)" }, -- 37
    { "Firework" }, -- 38
    { "Snowball" }, -- 39
    { "Proximity Mine" }, -- 40
    { "Valkyrie Cannon" }, -- 41
    { "Air Defence" }, -- 42
    { "Pipe Bomb" }, -- 43
    { "Vehicle Mine" }, -- 44
    { "Explosive Ammo" }, -- 45
    { "APC Shell" }, -- 46
    { "Cluster Bomb" }, -- 47
    { "Gas Bomb" }, -- 48
    { "Incendiary Bomb" }, -- 49
    { "Standard Bomb" }, -- 50
    { "Torpedo" }, -- 51
    { "Torpedo (Underwater)" }, -- 52
    { "Bombushka Cannon" }, -- 53
    { "Cluster Bomb 2" }, -- 54
    { "Hunter Barrage" }, -- 55
    { "Hunter Cannon" }, -- 56
    { "Rogue Cannon" }, -- 57
    { "Underwater Mine" }, -- 58
    { "Orbital Cannon" }, -- 59
    { "Standard Bomb (Wide)" }, -- 60
    { "Explosive Ammo (Shotgun)" }, -- 61
    { "Oppressor MKII Cannon" }, -- 62
    { "Kinetic Mortar" }, -- 63
    { "Kinetic Vehicle Mine" }, -- 64
    { "Emp Vehicle Mine" }, -- 65
    { "Spike Vehicle Mine" }, -- 66
    { "Slick Vehicle Mine" }, -- 67
    { "Tar Vehicle Mine" }, -- 68
    { "Script Drone" }, -- 69
    { "Raygun" }, -- 70
    { "Buried Mine" }, -- 71
    { "Script Missile" }, -- 72
    { "RC Tank Rocket" }, -- 73
    { "Water Bomb" }, -- 74
    { "Water Bomb 2" }, -- 75
    { "0xf728c4a9" }, -- 76
    { "0xbaec056f" }, -- 77
    { "Flash Grenade" }, -- 78
    { "Stun Grenade" }, -- 79
    { "0x763d3b3b" }, -- 80
    { "Large Missile" }, -- 81
    { "Big Submarine" }, -- 82
    { "Emp Launcher" } -- 83
}



-- 所有武器（无近战武器）
AllWeapons_NoClose_ListItem = {
    { "玩家手持武器", {}, "PLAYER_WEAPON" }
}

for k, v in pairs(util.get_weapons()) do
    -- The inner tables contain hash, label_key, category, & category_id
    local t = { "label", {}, "hash" }
    t[1] = util.get_label_text(v.label_key)
    t[3] = tostring(v.hash)

    if v.category_id ~= 0 then
        table.insert(AllWeapons_NoClose_ListItem, t)
    end
end


-- 所有载具武器
-- hash = label_name
VehicleWeapons_withLabelName = {
    [util.joaat('vehicle_weapon_cannon_blazer')] = 'WT_V_PLRBUL', --tested
    [util.joaat('vehicle_weapon_enemy_laser')] = 'WT_A_ENMYLSR',
    [util.joaat('vehicle_weapon_plane_rocket')] = 'WT_V_PLANEMSL',
    [util.joaat('vehicle_weapon_player_bullet')] = 'WT_V_PLRBUL',
    [util.joaat('vehicle_weapon_player_buzzard')] = 'WT_V_PLRBUL',
    [util.joaat('vehicle_weapon_player_hunter')] = 'WT_V_PLRBUL',
    [util.joaat('vehicle_weapon_player_laser')] = 'WT_V_PLRLSR',
    [util.joaat('vehicle_weapon_player_lazer')] = 'WT_V_LZRCAN', --tested on the hydra, and lazer
    [util.joaat('vehicle_weapon_rotors')] = 'WT_INVALID',
    [util.joaat('vehicle_weapon_ruiner_bullet')] = 'WT_V_PLRBUL',
    [util.joaat('vehicle_weapon_ruiner_rocket')] = 'WT_V_PLANEMSL',
    [util.joaat('vehicle_weapon_searchlight')] = 'WT_INVALID',
    [util.joaat('vehicle_weapon_radar')] = 'WT_INVALID',
    [util.joaat('vehicle_weapon_space_rocket')] = 'WT_V_PLANEMSL', --tested on seasparrow, seems weird that it isnt rocket
    [util.joaat('vehicle_weapon_turret_boxville')] = 'WT_V_TURRET',
    [util.joaat('vehicle_weapon_tank')] = 'WT_V_TANK', --tested
    [util.joaat('vehicle_weapon_akula_missile')] = 'WT_V_PLANEMSL',
    [util.joaat('vehicle_weapon_ardent_mg')] = 'WT_V_TURRET',
    [util.joaat('vehicle_weapon_comet_mg')] = 'WT_V_TURRET',
    [util.joaat('vehicle_weapon_granger2_mg')] = 'WT_V_TURRET',
    [util.joaat('vehicle_weapon_menacer_mg')] = 'WT_V_TURRET',
    [util.joaat('vehicle_weapon_nightshark_mg')] = 'WT_V_TURRET',
    [util.joaat('vehicle_weapon_revolter_mg')] = 'WT_V_TURRET',
    [util.joaat('vehicle_weapon_savestra_mg')] = 'WT_V_TURRET',
    [util.joaat('vehicle_weapon_viseris_mg')] = 'WT_V_TURRET',
    [util.joaat('vehicle_weapon_akula_turret_single')] = 'WT_V_TURRET',
    [util.joaat('vehicle_weapon_avenger_cannon')] = 'WT_V_LZRCAN',
    [util.joaat('vehicle_weapon_mobileops_cannon')] = 'WT_V_LZRCAN',
    [util.joaat('vehicle_weapon_akula_minigun')] = 'WT_V_TURRET',
    [util.joaat('vehicle_weapon_insurgent_minigun')] = 'WT_MINIGUN', --tested
    [util.joaat('vehicle_weapon_technical_minigun')] = 'WT_MINIGUN',
    [util.joaat('vehicle_weapon_brutus_50cal')] = 'WT_V_MG50_2',
    [util.joaat('vehicle_weapon_dominator4_50cal')] = 'WT_V_MG50_2',
    [util.joaat('vehicle_weapon_impaler2_50cal')] = 'WT_V_MG50_2',
    [util.joaat('vehicle_weapon_imperator_50cal')] = 'WT_V_MG50_2',
    [util.joaat('vehicle_weapon_slamvan4_50cal')] = 'WT_V_MG50_2', --tested
    [util.joaat('vehicle_weapon_zr380_50cal')] = 'WT_V_MG50_2', --tested
    [util.joaat('vehicle_weapon_brutus2_50cal_laser')] = 'WT_V_MG50_2L',
    [util.joaat('vehicle_weapon_impaler3_50cal_laser')] = 'WT_V_MG50_2L',
    [util.joaat('vehicle_weapon_imperator2_50cal_laser')] = 'WT_V_MG50_2L',
    [util.joaat('vehicle_weapon_slamvan5_50cal_laser')] = 'WT_V_MG50_2L',
    [util.joaat('vehicle_weapon_zr3802_50cal_laser')] = 'WT_V_MG50_2L',
    [util.joaat('vehicle_weapon_dominator5_50cal_laser')] = 'WT_V_MG50_2L',
    --pretty much 99% accurate
    [util.joaat('vehicle_weapon_khanjali_cannon_heavy')] = 'WT_V_KHA_HCA',
    [util.joaat('vehicle_weapon_khanjali_gl')] = 'WT_V_KHA_GL',
    [util.joaat('vehicle_weapon_khanjali_mg')] = 'WT_V_KHA_MG',
    [util.joaat('vehicle_weapon_khanjali_cannon')] = 'WT_V_KHA_CA',
    [util.joaat('vehicle_weapon_volatol_dualmg')] = 'WT_V_VOL_MG',
    [util.joaat('vehicle_weapon_akula_barrage')] = 'WT_V_AKU_BA',
    [util.joaat('vehicle_weapon_akula_turret_dual')] = 'WT_V_AKU_TD',
    [util.joaat('vehicle_weapon_tampa_missile')] = 'WT_V_TAM_MISS',
    [util.joaat('vehicle_weapon_tampa_dualminigun')] = 'WT_V_TAM_DMINI',
    [util.joaat('vehicle_weapon_tampa_fixedminigun')] = 'WT_V_TAM_FMINI',
    [util.joaat('vehicle_weapon_tampa_mortar')] = 'WT_V_TAM_MORT',
    [util.joaat('vehicle_weapon_apc_cannon')] = 'WT_V_APC_C',
    [util.joaat('vehicle_weapon_apc_missile')] = 'WT_V_APC_M',
    [util.joaat('vehicle_weapon_apc_mg')] = 'WT_V_APC_S',
    [util.joaat('vehicle_weapon_kosatka_torpedo')] = 'WT_V_KOS_TO',
    [util.joaat('vehicle_weapon_seasparrow2_minigun')] = 'WT_V_SPRW_MINI',
    [util.joaat('vehicle_weapon_annihilator2_barrage')] = 'WT_V_ANTOR_BA',
    [util.joaat('vehicle_weapon_annihilator2_missile')] = 'WT_V_ANTOR_MI',
    [util.joaat('vehicle_weapon_annihilator2_mini')] = 'WT_V_PLRBUL',
    [util.joaat('vehicle_weapon_rctank_gun')] = 'WT_V_RCT_MG',
    [util.joaat('vehicle_weapon_rctank_flame')] = 'WT_V_RCT_FL',
    [util.joaat('vehicle_weapon_rctank_rocket')] = 'WT_V_RCT_RK',
    [util.joaat('vehicle_weapon_rctank_lazer')] = 'WT_V_RCT_LZ',
    [util.joaat('vehicle_weapon_cherno_missile')] = 'WT_V_CHE_MI',
    [util.joaat('vehicle_weapon_barrage_top_mg')] = 'WT_V_BAR_TMG',
    [util.joaat('vehicle_weapon_barrage_top_minigun')] = 'WT_V_BAR_TMI',
    [util.joaat('vehicle_weapon_barrage_rear_mg')] = 'WT_V_BAR_RMG',
    [util.joaat('vehicle_weapon_barrage_rear_minigun')] = 'WT_V_BAR_RMI',
    [util.joaat('vehicle_weapon_barrage_rear_gl')] = 'WT_V_BAR_RGL',
    [util.joaat('vehicle_weapon_deluxo_mg')] = 'WT_V_DEL_MG',
    [util.joaat('vehicle_weapon_deluxo_missile')] = 'WT_V_DEL_MI',
    [util.joaat('vehicle_weapon_subcar_mg')] = 'WT_V_SUB_MG',
    [util.joaat('vehicle_weapon_subcar_missile')] = 'WT_V_SUB_MI',
    [util.joaat('vehicle_weapon_subcar_torpedo')] = 'WT_V_SUB_TO',
    [util.joaat('vehicle_weapon_thruster_mg')] = 'WT_V_THR_MG',
    [util.joaat('vehicle_weapon_thruster_missile')] = 'WT_V_THR_MI',
    [util.joaat('vehicle_weapon_mogul_nose')] = 'WT_V_MOG_NOSE',
    [util.joaat('vehicle_weapon_mogul_dualnose')] = 'WT_V_MOG_DNOSE',
    [util.joaat('vehicle_weapon_mogul_dualturret')] = 'WT_V_MOG_DTURR',
    [util.joaat('vehicle_weapon_mogul_turret')] = 'WT_V_MOG_TURR',
    [util.joaat('vehicle_weapon_tula_mg')] = 'WT_V_TUL_MG',
    [util.joaat('vehicle_weapon_tula_minigun')] = 'WT_V_TUL_MINI',
    [util.joaat('vehicle_weapon_tula_nosemg')] = 'WT_V_TUL_NOSE',
    [util.joaat('vehicle_weapon_tula_dualmg')] = 'WT_V_TUL_DUAL',
    [util.joaat('vehicle_weapon_vigilante_mg')] = 'WT_V_VGL_MG',
    [util.joaat('vehicle_weapon_vigilante_missile')] = 'WT_V_VGL_MISS',
    [util.joaat('vehicle_weapon_seabreeze_mg')] = 'WT_V_SBZ_MG',
    [util.joaat('vehicle_weapon_bombushka_cannon')] = 'WT_V_BSHK_CANN',
    [util.joaat('vehicle_weapon_bombushka_dualmg')] = 'WT_V_BSHK_DUAL',
    [util.joaat('vehicle_weapon_hunter_mg')] = 'WT_V_HUNT_MG',
    [util.joaat('vehicle_weapon_hunter_missile')] = 'WT_V_HUNT_MISS',
    [util.joaat('vehicle_weapon_hunter_barrage')] = 'WT_V_HUNT_BARR',
    [util.joaat('vehicle_weapon_hunter_cannon')] = 'WT_V_HUNT_CANN',
    [util.joaat('vehicle_weapon_microlight_mg')] = 'WT_V_MCRL_MG',
    [util.joaat('vehicle_weapon_caracara_mg')] = 'WT_V_TURRET',
    [util.joaat('vehicle_weapon_caracara_minigun')] = 'WT_V_TEC_MINI',
    [util.joaat('vehicle_weapon_deathbike_dualminigun')] = 'WT_V_DBK_MINI',
    [util.joaat('vehicle_weapon_deathbike2_minigun_laser')] = 'WT_V_MG50_2L',
    [util.joaat('vehicle_weapon_trailer_quadmg')] = 'WT_V_TR_QUADMG',
    [util.joaat('vehicle_weapon_trailer_dualaa')] = 'WT_V_TR_DUALAA',
    [util.joaat('vehicle_weapon_trailer_missile')] = 'WT_V_TR_MISS',
    [util.joaat('vehicle_weapon_halftrack_dualmg')] = 'WT_V_HT_DUALMG',
    [util.joaat('vehicle_weapon_halftrack_quadmg')] = 'WT_V_HT_QUADMG',
    [util.joaat('vehicle_weapon_oppressor_mg')] = 'WT_V_OP_MG',
    [util.joaat('vehicle_weapon_oppressor_missile')] = 'WT_V_OP_MISS',
    [util.joaat('vehicle_weapon_dune_mg')] = 'WT_V_DU_MG',
    [util.joaat('vehicle_weapon_dune_grenadelauncher')] = 'WT_V_DU_GL',
    [util.joaat('vehicle_weapon_dune_minigun')] = 'WT_V_DU_MINI',
    [util.joaat('vehicle_weapon_nose_turret_valkyrie')] = 'WT_V_PLRBUL',
    [util.joaat('vehicle_weapon_turret_valkyrie')] = 'WT_V_TURRET',
    [util.joaat('vehicle_weapon_turret_technical')] = 'WT_V_TURRET',
    [util.joaat('vehicle_weapon_player_savage')] = 'WT_V_LZRCAN',
    [util.joaat('vehicle_weapon_turret_limo')] = 'WT_V_TURRET',
    [util.joaat('vehicle_weapon_speedo4_mg')] = 'WT_V_COM_MG',
    [util.joaat('vehicle_weapon_speedo4_turret_mg')] = 'WT_V_SPD_TMG',
    [util.joaat('vehicle_weapon_speedo4_turret_mini')] = 'WT_V_SPD_TMI',
    [util.joaat('vehicle_weapon_pounder2_mini')] = 'WT_V_COM_MG',
    [util.joaat('vehicle_weapon_pounder2_missile')] = 'WT_V_TAM_MISS',
    [util.joaat('vehicle_weapon_pounder2_barrage')] = 'WT_V_POU_BA',
    [util.joaat('vehicle_weapon_pounder2_gl')] = 'WT_V_KHA_GL',
    [util.joaat('vehicle_weapon_rogue_mg')] = 'WT_V_ROG_MG',
    [util.joaat('vehicle_weapon_rogue_cannon')] = 'WT_V_ROG_CANN',
    [util.joaat('vehicle_weapon_rogue_missile')] = 'WT_V_ROG_MISS',
    [util.joaat('vehicle_weapon_monster3_glkin')] = 'WT_V_GREN_KIN',
    [util.joaat('vehicle_weapon_mortar_kinetic')] = 'WT_V_MORTAR_KIN', --??? idk
    [util.joaat('vehicle_weapon_mortar_explosive')] = 'WT_V_TAM_MORT', --??? idk
    [util.joaat('vehicle_weapon_scarab_50cal')] = 'WT_V_MG50_2',
    [util.joaat('vehicle_weapon_scarab2_50cal_laser')] = 'WT_V_MG50_2L',
    [util.joaat('vehicle_weapon_strikeforce_barrage')] = 'WT_V_HUNT_BARR',
    [util.joaat('vehicle_weapon_strikeforce_cannon')] = 'WT_V_ROG_CANN',
    [util.joaat('vehicle_weapon_strikeforce_missile')] = 'WT_V_HUNT_MISS',
    [util.joaat('vehicle_weapon_hacker_missile')] = 'WT_V_LZRCAN', --(hacker means terrorbyte, im gonna have to test if these are accuate)
    [util.joaat('vehicle_weapon_hacker_missile_homing')] = 'WT_V_LZRCAN',
    [util.joaat('vehicle_weapon_flamethrower')] = 'WT_V_FLAME', --tested
    [util.joaat('vehicle_weapon_flamethrower_scifi')] = 'WT_V_FLAME', --tested, this is the flamethrower on the future shock cerberus
    [util.joaat('vehicle_weapon_havok_minigun')] = 'WT_V_HAV_MINI',
    [util.joaat('vehicle_weapon_dogfighter_mg')] = 'WT_V_DGF_MG',
    [util.joaat('vehicle_weapon_dogfighter_missile')] = 'WT_V_DGF_MISS',
    [util.joaat('vehicle_weapon_paragon2_mg')] = 'WT_V_COM_MG',
    [util.joaat('vehicle_weapon_scramjet_mg')] = 'WT_V_VGL_MG',
    [util.joaat('vehicle_weapon_scramjet_missile')] = 'WT_V_VGL_MISS',
    [util.joaat('vehicle_weapon_oppressor2_mg')] = 'WT_V_OP_MG',
    [util.joaat('vehicle_weapon_oppressor2_cannon')] = 'WT_V_ROG_CANN',
    [util.joaat('vehicle_weapon_oppressor2_missile')] = 'WT_V_OP_MISS',
    [util.joaat('vehicle_weapon_mule4_mg')] = 'WT_V_COM_MG',
    [util.joaat('vehicle_weapon_mule4_missile')] = 'WT_V_TAM_MISS',
    [util.joaat('vehicle_weapon_mule4_turret_gl')] = 'WT_V_KHA_GL',
    [util.joaat('vehicle_weapon_mine')] = 'WT_VEHMINE', --unsure about these mines
    [util.joaat('vehicle_weapon_mine_emp')] = 'WT_VEHMINE',
    [util.joaat('vehicle_weapon_mine_emp_rc')] = 'WT_VEHMINE',
    [util.joaat('vehicle_weapon_mine_kinetic')] = 'WT_VEHMINE',
    [util.joaat('vehicle_weapon_mine_kinetic_rc')] = 'WT_VEHMINE',
    [util.joaat('vehicle_weapon_mine_slick')] = 'WT_VEHMINE',
    [util.joaat('vehicle_weapon_mine_slick_rc')] = 'WT_VEHMINE',
    [util.joaat('vehicle_weapon_mine_spike')] = 'WT_VEHMINE',
    [util.joaat('vehicle_weapon_mine_spike_rc')] = 'WT_VEHMINE',
    [util.joaat('vehicle_weapon_mine_tar')] = 'WT_VEHMINE',
    [util.joaat('vehicle_weapon_mine_tar_rc')] = 'WT_VEHMINE',
    [util.joaat('vehicle_weapon_issi4_50cal')] = 'WT_V_MG50_2',
    [util.joaat('vehicle_weapon_issi5_50cal_laser')] = 'WT_V_MG50_2L',
    [util.joaat('vehicle_weapon_turret_insurgent')] = 'WT_V_TURRET',
    [util.joaat('vehicle_weapon_jb700_mg')] = 'WT_V_COM_MG',
    [util.joaat('vehicle_weapon_patrolboat_dualmg')] = 'WT_V_PAT_DUAL',
    [util.joaat('vehicle_weapon_turret_dinghy5_50cal')] = 'WT_V_PAT_TURRET',
    [util.joaat('vehicle_weapon_turret_patrolboat_50cal')] = 'WT_V_PAT_TURRET',
    [util.joaat('vehicle_weapon_bruiser_50cal')] = 'WT_V_MG50_2',
    [util.joaat('vehicle_weapon_bruiser2_50cal_laser')] = 'WT_V_MG50_2L',
}

-- hash = string_name
VehicleWeapons_withStringName = {
    [util.joaat('vehicle_weapon_bomb')] = 'Bomb',
    [util.joaat('vehicle_weapon_bomb_cluster')] = 'Cluster Bomb',
    [util.joaat('vehicle_weapon_bomb_gas')] = 'Gas Bomb',
    [util.joaat('vehicle_weapon_bomb_incendiary')] = 'Incendiary Bomb',
    [util.joaat('vehicle_weapon_bomb_standard_wide')] = 'Standard Wide Bomb',
    [util.joaat('vehicle_weapon_sub_missile_homing')] = 'Homing Missiles',
    [util.joaat('vehicle_weapon_water_cannon')] = 'Water Cannon',
}

-- All_VehicleWeapons_ListItem = {}

-- for k, v in pairs(VehicleWeapons_withLabelName) do
--     local t = { "label", {}, "hash" }
--     t[1] = util.get_label_text(v)
--     t[3] = tostring(k)

--     table.insert(All_VehicleWeapons_ListItem, t)
-- end
-- for k, v in pairs(VehicleWeapons_withStringName) do
--     local t = { "label", {}, "hash" }
--     t[1] = v
--     t[3] = tostring(k)

--     table.insert(All_VehicleWeapons_ListItem, t)
-- end
