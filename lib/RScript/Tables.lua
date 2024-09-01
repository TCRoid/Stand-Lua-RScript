------------------------
-- ENUM ENTITY_TYPE
------------------------

ENTITY_NONE = 0
ENTITY_PED = 1
ENTITY_VEHICLE = 2
ENTITY_OBJECT = 3
ENTITY_PICKUP = 4
ENTITY_ALL = 5


------------------------
-- Consts
------------------------

HIGHEST_INT = 2147483647
LOWEST_INT = -2147483647


------------------------
-- Tables
------------------------

-- 颜色 [0 - 1]格式
Colors = {
    white = { r = 1.0, g = 1.0, b = 1.0, a = 1.0 },
    black = { r = 0.0, g = 0.0, b = 0.0, a = 1.0 },

    red = { r = 1.0, g = 0.0, b = 0.0, a = 1.0 },
    green = { r = 0.0, g = 1.0, b = 0.0, a = 1.0 },
    blue = { r = 0.0, g = 0.0, b = 1.0, a = 1.0 },

    purple = { r = 1.0, g = 0.0, b = 1.0, a = 1.0 },
}


RS_T = {
    -- `ListItem` 常用武器
    CommonWeapons = {
        { util.joaat("WEAPON_KNIFE"), "小刀" },
        { util.joaat("WEAPON_APPISTOL"), "穿甲手枪" },
        { util.joaat("WEAPON_STUNGUN"), "电击枪" },
        { util.joaat("WEAPON_MICROSMG"), "微型冲锋枪" },
        { util.joaat("WEAPON_SPECIALCARBINE"), "特质卡宾步枪" },
        { util.joaat("WEAPON_ASSAULTSHOTGUN"), "突击霰弹枪" },
        { util.joaat("WEAPON_MINIGUN"), "火神机枪" },
        { util.joaat("WEAPON_RPG"), "火箭筒" },
        { util.joaat("WEAPON_RAILGUN"), "电磁步枪" },
    },

    -- `List` 常用载具
    CommonVehicles = {
        { model = "police3", name = "警车", help_text = "" },
        { model = "khanjali", name = "坦克", help_text = "" },
        { model = "kuruma2", name = "骷髅马", help_text = "" },
        { model = "polmav", name = "警用直升机", help_text = "" },
        { model = "bullet", name = "子弹", help_text = "大街上随处可见的超级跑车" },
        { model = "bati", name = "801巴提", help_text = "" },
        { model = "oppressor2", name = "暴君MK2", help_text = "" },
        { model = "buzzard", name = "秃鹰攻击直升机", help_text = "" },
    },

    -- `List` 载具武器
    --
    -- weapon_model, weapon_label, display_name_label, class_id, vehicle_model
    VehicleWeapons = {
        {
            weapon_model = "VEHICLE_WEAPON_AKULA_TURRET_SINGLE",
            weapon_label = "",
            display_name_label = "akula",
            class_id = 15,
            vehicle_model = "akula"
        },
        {
            weapon_model = "VEHICLE_WEAPON_AKULA_MISSILE",
            weapon_label = "",
            display_name_label = "akula",
            class_id = 15,
            vehicle_model = "akula"
        },
        {
            weapon_model = "VEHICLE_WEAPON_AKULA_TURRET_DUAL",
            weapon_label = "",
            display_name_label = "akula",
            class_id = 15,
            vehicle_model = "akula"
        },
        {
            weapon_model = "VEHICLE_WEAPON_AKULA_MINIGUN",
            weapon_label = "",
            display_name_label = "akula",
            class_id = 15,
            vehicle_model = "akula"
        },
        {
            weapon_model = "VEHICLE_WEAPON_AKULA_BARRAGE",
            weapon_label = "",
            display_name_label = "akula",
            class_id = 15,
            vehicle_model = "akula"
        },
        {
            weapon_model = "VEHICLE_WEAPON_PLAYER_BUZZARD",
            weapon_label = "WT_V_PLRBUL",
            display_name_label = "ANNIHL",
            class_id = 15,
            vehicle_model = "annihilator"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SPACE_ROCKET",
            weapon_label = "WT_V_PLANEMSL",
            display_name_label = "ANNIHL",
            class_id = 15,
            vehicle_model = "annihilator"
        },
        {
            weapon_model = "VEHICLE_WEAPON_ANNIHILATOR2_MINI",
            weapon_label = "",
            display_name_label = "ANNIHLATOR2",
            class_id = 15,
            vehicle_model = "annihilator2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_ANNIHILATOR2_MISSILE",
            weapon_label = "",
            display_name_label = "ANNIHLATOR2",
            class_id = 15,
            vehicle_model = "annihilator2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_ANNIHILATOR2_BARRAGE",
            weapon_label = "",
            display_name_label = "ANNIHLATOR2",
            class_id = 15,
            vehicle_model = "annihilator2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_APC_CANNON",
            weapon_label = "",
            display_name_label = "APC",
            class_id = 19,
            vehicle_model = "apc"
        },
        {
            weapon_model = "VEHICLE_WEAPON_APC_MISSILE",
            weapon_label = "",
            display_name_label = "APC",
            class_id = 19,
            vehicle_model = "apc"
        },
        {
            weapon_model = "VEHICLE_WEAPON_APC_MG",
            weapon_label = "",
            display_name_label = "APC",
            class_id = 19,
            vehicle_model = "apc"
        },
        {
            weapon_model = "VEHICLE_WEAPON_ARDENT_MG",
            weapon_label = "",
            display_name_label = "ARDENT",
            class_id = 5,
            vehicle_model = "ardent"
        },
        {
            weapon_model = "VEHICLE_WEAPON_AVENGER_CANNON",
            weapon_label = "",
            display_name_label = "avenger",
            class_id = 16,
            vehicle_model = "avenger"
        },
        {
            weapon_model = "VEHICLE_WEAPON_AVENGER_CANNON",
            weapon_label = "",
            display_name_label = "avenger",
            class_id = 16,
            vehicle_model = "avenger2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_AVENGER_CANNON",
            weapon_label = "",
            display_name_label = "avenger3",
            class_id = 16,
            vehicle_model = "avenger3"
        },
        {
            weapon_model = "VEHICLE_WEAPON_AVENGER3_MINIGUN",
            weapon_label = "",
            display_name_label = "avenger3",
            class_id = 16,
            vehicle_model = "avenger3"
        },
        {
            weapon_model = "VEHICLE_WEAPON_AVENGER3_MISSILE",
            weapon_label = "",
            display_name_label = "avenger3",
            class_id = 16,
            vehicle_model = "avenger3"
        },
        {
            weapon_model = "VEHICLE_WEAPON_AVENGER_CANNON",
            weapon_label = "",
            display_name_label = "avenger3",
            class_id = 16,
            vehicle_model = "avenger4"
        },
        {
            weapon_model = "VEHICLE_WEAPON_AVENGER3_MINIGUN",
            weapon_label = "",
            display_name_label = "avenger3",
            class_id = 16,
            vehicle_model = "avenger4"
        },
        {
            weapon_model = "VEHICLE_WEAPON_AVENGER3_MISSILE",
            weapon_label = "",
            display_name_label = "avenger3",
            class_id = 16,
            vehicle_model = "avenger4"
        },
        {
            weapon_model = "VEHICLE_WEAPON_BARRAGE_TOP_MG",
            weapon_label = "",
            display_name_label = "barrage",
            class_id = 19,
            vehicle_model = "barrage"
        },
        {
            weapon_model = "VEHICLE_WEAPON_BARRAGE_TOP_MINIGUN",
            weapon_label = "",
            display_name_label = "barrage",
            class_id = 19,
            vehicle_model = "barrage"
        },
        {
            weapon_model = "VEHICLE_WEAPON_BARRAGE_REAR_MG",
            weapon_label = "",
            display_name_label = "barrage",
            class_id = 19,
            vehicle_model = "barrage"
        },
        {
            weapon_model = "VEHICLE_WEAPON_BARRAGE_REAR_MINIGUN",
            weapon_label = "",
            display_name_label = "barrage",
            class_id = 19,
            vehicle_model = "barrage"
        },
        {
            weapon_model = "VEHICLE_WEAPON_BARRAGE_REAR_GL",
            weapon_label = "",
            display_name_label = "barrage",
            class_id = 19,
            vehicle_model = "barrage"
        },
        {
            weapon_model = "VEHICLE_WEAPON_CANNON_BLAZER",
            weapon_label = "WT_V_PLRBUL",
            display_name_label = "BLAZER5",
            class_id = 9,
            vehicle_model = "blazer5"
        },
        {
            weapon_model = "VEHICLE_WEAPON_BOMBUSHKA_DUALMG",
            weapon_label = "",
            display_name_label = "BOMBUSHKA",
            class_id = 16,
            vehicle_model = "bombushka"
        },
        {
            weapon_model = "VEHICLE_WEAPON_BOMBUSHKA_CANNON",
            weapon_label = "",
            display_name_label = "BOMBUSHKA",
            class_id = 16,
            vehicle_model = "bombushka"
        },
        {
            weapon_model = "VEHICLE_WEAPON_TURRET_BOXVILLE",
            weapon_label = "WT_V_TURRET",
            display_name_label = "BOXVILLE5",
            class_id = 12,
            vehicle_model = "boxville5"
        },
        {
            weapon_model = "VEHICLE_WEAPON_BRUISER_50CAL",
            weapon_label = "",
            display_name_label = "Bruiser",
            class_id = 9,
            vehicle_model = "bruiser"
        },
        {
            weapon_model = "VEHICLE_WEAPON_BRUISER_50CAL",
            weapon_label = "",
            display_name_label = "bruiser2",
            class_id = 9,
            vehicle_model = "bruiser2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_BRUISER2_50CAL_LASER",
            weapon_label = "",
            display_name_label = "bruiser2",
            class_id = 9,
            vehicle_model = "bruiser2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_BRUISER_50CAL",
            weapon_label = "",
            display_name_label = "bruiser3",
            class_id = 9,
            vehicle_model = "bruiser3"
        },
        {
            weapon_model = "VEHICLE_WEAPON_BRUTUS_50CAL",
            weapon_label = "",
            display_name_label = "brutus",
            class_id = 9,
            vehicle_model = "brutus"
        },
        {
            weapon_model = "VEHICLE_WEAPON_BRUTUS_50CAL",
            weapon_label = "",
            display_name_label = "brutus2",
            class_id = 9,
            vehicle_model = "brutus2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_BRUTUS2_50CAL_LASER",
            weapon_label = "",
            display_name_label = "brutus2",
            class_id = 9,
            vehicle_model = "brutus2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_BRUTUS_50CAL",
            weapon_label = "",
            display_name_label = "brutus3",
            class_id = 9,
            vehicle_model = "brutus3"
        },
        {
            weapon_model = "VEHICLE_WEAPON_GRANGER2_MG",
            weapon_label = "",
            display_name_label = "BUFFALO4",
            class_id = 4,
            vehicle_model = "buffalo4"
        },
        {
            weapon_model = "VEHICLE_WEAPON_PLAYER_BUZZARD",
            weapon_label = "WT_V_PLRBUL",
            display_name_label = "buzzard",
            class_id = 15,
            vehicle_model = "buzzard"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SPACE_ROCKET",
            weapon_label = "WT_V_PLANEMSL",
            display_name_label = "buzzard",
            class_id = 15,
            vehicle_model = "buzzard"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SEARCHLIGHT",
            weapon_label = "",
            display_name_label = "buzzard",
            class_id = 15,
            vehicle_model = "buzzard"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SEARCHLIGHT",
            weapon_label = "",
            display_name_label = "buzzard2",
            class_id = 15,
            vehicle_model = "Buzzard2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_CARACARA_MG",
            weapon_label = "",
            display_name_label = "caracara",
            class_id = 9,
            vehicle_model = "caracara"
        },
        {
            weapon_model = "VEHICLE_WEAPON_CARACARA_MINIGUN",
            weapon_label = "",
            display_name_label = "caracara",
            class_id = 9,
            vehicle_model = "caracara"
        },
        {
            weapon_model = "VEHICLE_WEAPON_FLAMETHROWER",
            weapon_label = "",
            display_name_label = "cerberus",
            class_id = 20,
            vehicle_model = "cerberus"
        },
        {
            weapon_model = "VEHICLE_WEAPON_FLAMETHROWER_SCIFI",
            weapon_label = "",
            display_name_label = "cerberus2",
            class_id = 20,
            vehicle_model = "cerberus2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_FLAMETHROWER",
            weapon_label = "",
            display_name_label = "cerberus3",
            class_id = 20,
            vehicle_model = "cerberus3"
        },
        {
            weapon_model = "VEHICLE_WEAPON_GRANGER2_MG",
            weapon_label = "",
            display_name_label = "Champion",
            class_id = 7,
            vehicle_model = "champion"
        },
        {
            weapon_model = "VEHICLE_WEAPON_CHERNO_MISSILE",
            weapon_label = "",
            display_name_label = "chernobog",
            class_id = 19,
            vehicle_model = "chernobog"
        },
        {
            weapon_model = "VEHICLE_WEAPON_COMET_MG",
            weapon_label = "",
            display_name_label = "comet4",
            class_id = 6,
            vehicle_model = "comet4"
        },
        {
            weapon_model = "VEHICLE_WEAPON_CONADA2_MINIGUN",
            weapon_label = "",
            display_name_label = "conada2",
            class_id = 15,
            vehicle_model = "conada2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_CONADA2_MISSILE",
            weapon_label = "",
            display_name_label = "conada2",
            class_id = 15,
            vehicle_model = "conada2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SEARCHLIGHT",
            weapon_label = "",
            display_name_label = "conada2",
            class_id = 15,
            vehicle_model = "conada2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_DEATHBIKE_DUALMINIGUN",
            weapon_label = "",
            display_name_label = "deathbike",
            class_id = 8,
            vehicle_model = "deathbike"
        },
        {
            weapon_model = "VEHICLE_WEAPON_DEATHBIKE2_MINIGUN_LASER",
            weapon_label = "",
            display_name_label = "deathbike2",
            class_id = 8,
            vehicle_model = "deathbike2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_DEATHBIKE_DUALMINIGUN",
            weapon_label = "",
            display_name_label = "deathbike3",
            class_id = 8,
            vehicle_model = "deathbike3"
        },
        {
            weapon_model = "VEHICLE_WEAPON_GRANGER2_MG",
            weapon_label = "",
            display_name_label = "DEITY",
            class_id = 1,
            vehicle_model = "deity"
        },
        {
            weapon_model = "VEHICLE_WEAPON_DELUXO_MG",
            weapon_label = "",
            display_name_label = "deluxo",
            class_id = 5,
            vehicle_model = "deluxo"
        },
        {
            weapon_model = "VEHICLE_WEAPON_DELUXO_MISSILE",
            weapon_label = "",
            display_name_label = "deluxo",
            class_id = 5,
            vehicle_model = "deluxo"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SEARCHLIGHT",
            weapon_label = "",
            display_name_label = "DINGHY",
            class_id = 14,
            vehicle_model = "Dinghy"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SEARCHLIGHT",
            weapon_label = "",
            display_name_label = "DINGHY",
            class_id = 14,
            vehicle_model = "dinghy2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SEARCHLIGHT",
            weapon_label = "",
            display_name_label = "DINGHY",
            class_id = 14,
            vehicle_model = "dinghy3"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SEARCHLIGHT",
            weapon_label = "",
            display_name_label = "DINGHY",
            class_id = 14,
            vehicle_model = "dinghy4"
        },
        {
            weapon_model = "VEHICLE_WEAPON_TURRET_DINGHY5_50CAL",
            weapon_label = "",
            display_name_label = "dinghy5",
            class_id = 14,
            vehicle_model = "dinghy5"
        },
        {
            weapon_model = "VEHICLE_WEAPON_DOMINATOR4_50CAL",
            weapon_label = "",
            display_name_label = "dominator4",
            class_id = 4,
            vehicle_model = "dominator4"
        },
        {
            weapon_model = "VEHICLE_WEAPON_DOMINATOR4_50CAL",
            weapon_label = "",
            display_name_label = "dominator5",
            class_id = 4,
            vehicle_model = "dominator5"
        },
        {
            weapon_model = "VEHICLE_WEAPON_DOMINATOR5_50CAL_LASER",
            weapon_label = "",
            display_name_label = "dominator5",
            class_id = 4,
            vehicle_model = "dominator5"
        },
        {
            weapon_model = "VEHICLE_WEAPON_DOMINATOR4_50CAL",
            weapon_label = "",
            display_name_label = "dominator6",
            class_id = 4,
            vehicle_model = "dominator6"
        },
        {
            weapon_model = "VEHICLE_WEAPON_DUNE_MG",
            weapon_label = "",
            display_name_label = "DUNE3",
            class_id = 9,
            vehicle_model = "dune3"
        },
        {
            weapon_model = "VEHICLE_WEAPON_DUNE_GRENADELAUNCHER",
            weapon_label = "",
            display_name_label = "DUNE3",
            class_id = 9,
            vehicle_model = "dune3"
        },
        {
            weapon_model = "VEHICLE_WEAPON_DUNE_MINIGUN",
            weapon_label = "",
            display_name_label = "DUNE3",
            class_id = 9,
            vehicle_model = "dune3"
        },
        {
            weapon_model = "VEHICLE_WEAPON_WATER_CANNON",
            weapon_label = "",
            display_name_label = "firetruk",
            class_id = 18,
            vehicle_model = "firetruk"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SEARCHLIGHT",
            weapon_label = "",
            display_name_label = "frogger",
            class_id = 15,
            vehicle_model = "Frogger"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SEARCHLIGHT",
            weapon_label = "",
            display_name_label = "frogger",
            class_id = 15,
            vehicle_model = "frogger2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_GRANGER2_MG",
            weapon_label = "",
            display_name_label = "GRANGER2",
            class_id = 2,
            vehicle_model = "granger2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_HALFTRACK_DUALMG",
            weapon_label = "",
            display_name_label = "HALFTRACK",
            class_id = 19,
            vehicle_model = "halftrack"
        },
        {
            weapon_model = "VEHICLE_WEAPON_HALFTRACK_QUADMG",
            weapon_label = "",
            display_name_label = "HALFTRACK",
            class_id = 19,
            vehicle_model = "halftrack"
        },
        {
            weapon_model = "VEHICLE_WEAPON_HAVOK_MINIGUN",
            weapon_label = "",
            display_name_label = "HAVOK",
            class_id = 15,
            vehicle_model = "havok"
        },
        {
            weapon_model = "VEHICLE_WEAPON_HUNTER_MG",
            weapon_label = "",
            display_name_label = "Hunter",
            class_id = 15,
            vehicle_model = "hunter"
        },
        {
            weapon_model = "VEHICLE_WEAPON_HUNTER_MISSILE",
            weapon_label = "",
            display_name_label = "Hunter",
            class_id = 15,
            vehicle_model = "hunter"
        },
        {
            weapon_model = "VEHICLE_WEAPON_HUNTER_CANNON",
            weapon_label = "",
            display_name_label = "Hunter",
            class_id = 15,
            vehicle_model = "hunter"
        },
        {
            weapon_model = "VEHICLE_WEAPON_HUNTER_BARRAGE",
            weapon_label = "",
            display_name_label = "Hunter",
            class_id = 15,
            vehicle_model = "hunter"
        },
        {
            weapon_model = "VEHICLE_WEAPON_PLAYER_LAZER",
            weapon_label = "WT_V_LZRCAN",
            display_name_label = "HYDRA",
            class_id = 16,
            vehicle_model = "hydra"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SPACE_ROCKET",
            weapon_label = "WT_V_PLANEMSL",
            display_name_label = "HYDRA",
            class_id = 16,
            vehicle_model = "hydra"
        },
        {
            weapon_model = "VEHICLE_WEAPON_IGNUS2_TURRET_MINI",
            weapon_label = "",
            display_name_label = "IGNUS2",
            class_id = 7,
            vehicle_model = "ignus2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_IMPALER2_50CAL",
            weapon_label = "",
            display_name_label = "impaler2",
            class_id = 4,
            vehicle_model = "impaler2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_IMPALER2_50CAL",
            weapon_label = "",
            display_name_label = "impaler3",
            class_id = 4,
            vehicle_model = "impaler3"
        },
        {
            weapon_model = "VEHICLE_WEAPON_IMPALER3_50CAL_LASER",
            weapon_label = "",
            display_name_label = "impaler3",
            class_id = 4,
            vehicle_model = "impaler3"
        },
        {
            weapon_model = "VEHICLE_WEAPON_IMPALER2_50CAL",
            weapon_label = "",
            display_name_label = "impaler4",
            class_id = 4,
            vehicle_model = "impaler4"
        },
        {
            weapon_model = "VEHICLE_WEAPON_IMPERATOR_50CAL",
            weapon_label = "",
            display_name_label = "imperator",
            class_id = 4,
            vehicle_model = "imperator"
        },
        {
            weapon_model = "VEHICLE_WEAPON_MORTAR_KINETIC",
            weapon_label = "",
            display_name_label = "imperator",
            class_id = 4,
            vehicle_model = "imperator"
        },
        {
            weapon_model = "VEHICLE_WEAPON_IMPERATOR_50CAL",
            weapon_label = "",
            display_name_label = "imperator2",
            class_id = 4,
            vehicle_model = "imperator2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_MORTAR_KINETIC",
            weapon_label = "",
            display_name_label = "imperator2",
            class_id = 4,
            vehicle_model = "imperator2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_IMPERATOR2_50CAL_LASER",
            weapon_label = "",
            display_name_label = "imperator2",
            class_id = 4,
            vehicle_model = "imperator2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_IMPERATOR_50CAL",
            weapon_label = "",
            display_name_label = "imperator3",
            class_id = 4,
            vehicle_model = "imperator3"
        },
        {
            weapon_model = "VEHICLE_WEAPON_MORTAR_KINETIC",
            weapon_label = "",
            display_name_label = "imperator3",
            class_id = 4,
            vehicle_model = "imperator3"
        },
        {
            weapon_model = "VEHICLE_WEAPON_TURRET_INSURGENT",
            weapon_label = "WT_V_TURRET",
            display_name_label = "insurgent",
            class_id = 9,
            vehicle_model = "insurgent"
        },
        {
            weapon_model = "VEHICLE_WEAPON_TURRET_INSURGENT",
            weapon_label = "WT_V_TURRET",
            display_name_label = "INSURGENT2",
            class_id = 9,
            vehicle_model = "insurgent2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_TURRET_INSURGENT",
            weapon_label = "WT_V_TURRET",
            display_name_label = "insurgent3",
            class_id = 9,
            vehicle_model = "insurgent3"
        },
        {
            weapon_model = "VEHICLE_WEAPON_INSURGENT_MINIGUN",
            weapon_label = "",
            display_name_label = "insurgent3",
            class_id = 9,
            vehicle_model = "insurgent3"
        },
        {
            weapon_model = "VEHICLE_WEAPON_ISSI4_50CAL",
            weapon_label = "",
            display_name_label = "issi4",
            class_id = 0,
            vehicle_model = "issi4"
        },
        {
            weapon_model = "VEHICLE_WEAPON_MORTAR_KINETIC",
            weapon_label = "",
            display_name_label = "issi4",
            class_id = 0,
            vehicle_model = "issi4"
        },
        {
            weapon_model = "VEHICLE_WEAPON_ISSI4_50CAL",
            weapon_label = "",
            display_name_label = "issi5",
            class_id = 0,
            vehicle_model = "issi5"
        },
        {
            weapon_model = "VEHICLE_WEAPON_ISSI5_50CAL_LASER",
            weapon_label = "",
            display_name_label = "issi5",
            class_id = 0,
            vehicle_model = "issi5"
        },
        {
            weapon_model = "VEHICLE_WEAPON_MORTAR_KINETIC",
            weapon_label = "",
            display_name_label = "issi5",
            class_id = 0,
            vehicle_model = "issi5"
        },
        {
            weapon_model = "VEHICLE_WEAPON_ISSI4_50CAL",
            weapon_label = "",
            display_name_label = "issi6",
            class_id = 0,
            vehicle_model = "issi6"
        },
        {
            weapon_model = "VEHICLE_WEAPON_MORTAR_KINETIC",
            weapon_label = "",
            display_name_label = "issi6",
            class_id = 0,
            vehicle_model = "issi6"
        },
        {
            weapon_model = "VEHICLE_WEAPON_JB700_MG",
            weapon_label = "",
            display_name_label = "jb7002",
            class_id = 5,
            vehicle_model = "jb7002"
        },
        {
            weapon_model = "VEHICLE_WEAPON_GRANGER2_MG",
            weapon_label = "",
            display_name_label = "JUBILEE",
            class_id = 2,
            vehicle_model = "jubilee"
        },
        {
            weapon_model = "VEHICLE_WEAPON_KHANJALI_CANNON",
            weapon_label = "",
            display_name_label = "khanjali",
            class_id = 19,
            vehicle_model = "khanjali"
        },
        {
            weapon_model = "VEHICLE_WEAPON_KHANJALI_CANNON_HEAVY",
            weapon_label = "",
            display_name_label = "khanjali",
            class_id = 19,
            vehicle_model = "khanjali"
        },
        {
            weapon_model = "VEHICLE_WEAPON_KHANJALI_MG",
            weapon_label = "",
            display_name_label = "khanjali",
            class_id = 19,
            vehicle_model = "khanjali"
        },
        {
            weapon_model = "VEHICLE_WEAPON_KHANJALI_GL",
            weapon_label = "",
            display_name_label = "khanjali",
            class_id = 19,
            vehicle_model = "khanjali"
        },
        {
            weapon_model = "VEHICLE_WEAPON_KOSATKA_TORPEDO",
            weapon_label = "",
            display_name_label = "kosatka",
            class_id = 14,
            vehicle_model = "kosatka"
        },
        {
            weapon_model = "VEHICLE_WEAPON_PLAYER_LAZER",
            weapon_label = "WT_V_LZRCAN",
            display_name_label = "LAZER",
            class_id = 16,
            vehicle_model = "Lazer"
        },
        {
            weapon_model = "VEHICLE_WEAPON_PLANE_ROCKET",
            weapon_label = "WT_V_PLANEMSL",
            display_name_label = "LAZER",
            class_id = 16,
            vehicle_model = "Lazer"
        },
        {
            weapon_model = "VEHICLE_WEAPON_TURRET_LIMO",
            weapon_label = "WT_V_TURRET",
            display_name_label = "LIMO2",
            class_id = 1,
            vehicle_model = "limo2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SEARCHLIGHT",
            weapon_label = "",
            display_name_label = "maverick",
            class_id = 15,
            vehicle_model = "maverick"
        },
        {
            weapon_model = "VEHICLE_WEAPON_TURRET_INSURGENT",
            weapon_label = "WT_V_TURRET",
            display_name_label = "menacer",
            class_id = 9,
            vehicle_model = "menacer"
        },
        {
            weapon_model = "VEHICLE_WEAPON_INSURGENT_MINIGUN",
            weapon_label = "",
            display_name_label = "menacer",
            class_id = 9,
            vehicle_model = "menacer"
        },
        {
            weapon_model = "VEHICLE_WEAPON_MENACER_MG",
            weapon_label = "",
            display_name_label = "menacer",
            class_id = 9,
            vehicle_model = "menacer"
        },
        {
            weapon_model = "VEHICLE_WEAPON_MICROLIGHT_MG",
            weapon_label = "",
            display_name_label = "MICROLIGHT",
            class_id = 16,
            vehicle_model = "microlight"
        },
        {
            weapon_model = "VEHICLE_WEAPON_RCTANK_GUN",
            weapon_label = "",
            display_name_label = "minitank",
            class_id = 19,
            vehicle_model = "minitank"
        },
        {
            weapon_model = "VEHICLE_WEAPON_RCTANK_FLAME",
            weapon_label = "",
            display_name_label = "minitank",
            class_id = 19,
            vehicle_model = "minitank"
        },
        {
            weapon_model = "VEHICLE_WEAPON_RCTANK_ROCKET",
            weapon_label = "",
            display_name_label = "minitank",
            class_id = 19,
            vehicle_model = "minitank"
        },
        {
            weapon_model = "VEHICLE_WEAPON_RCTANK_LAZER",
            weapon_label = "",
            display_name_label = "minitank",
            class_id = 19,
            vehicle_model = "minitank"
        },
        {
            weapon_model = "VEHICLE_WEAPON_MOGUL_NOSE",
            weapon_label = "",
            display_name_label = "MOGUL",
            class_id = 16,
            vehicle_model = "mogul"
        },
        {
            weapon_model = "VEHICLE_WEAPON_MOGUL_DUALNOSE",
            weapon_label = "",
            display_name_label = "MOGUL",
            class_id = 16,
            vehicle_model = "mogul"
        },
        {
            weapon_model = "VEHICLE_WEAPON_MOGUL_TURRET",
            weapon_label = "",
            display_name_label = "MOGUL",
            class_id = 16,
            vehicle_model = "mogul"
        },
        {
            weapon_model = "VEHICLE_WEAPON_MOGUL_DUALTURRET",
            weapon_label = "",
            display_name_label = "MOGUL",
            class_id = 16,
            vehicle_model = "mogul"
        },
        {
            weapon_model = "VEHICLE_WEAPON_DOGFIGHTER_MG",
            weapon_label = "",
            display_name_label = "MOLOTOK",
            class_id = 16,
            vehicle_model = "molotok"
        },
        {
            weapon_model = "VEHICLE_WEAPON_DOGFIGHTER_MISSILE",
            weapon_label = "",
            display_name_label = "MOLOTOK",
            class_id = 16,
            vehicle_model = "molotok"
        },
        {
            weapon_model = "VEHICLE_WEAPON_MONSTER3_GLKIN",
            weapon_label = "",
            display_name_label = "monster3",
            class_id = 9,
            vehicle_model = "monster3"
        },
        {
            weapon_model = "VEHICLE_WEAPON_MONSTER3_GLKIN",
            weapon_label = "",
            display_name_label = "monster4",
            class_id = 9,
            vehicle_model = "monster4"
        },
        {
            weapon_model = "VEHICLE_WEAPON_MONSTER3_GLKIN",
            weapon_label = "",
            display_name_label = "monster5",
            class_id = 9,
            vehicle_model = "monster5"
        },
        {
            weapon_model = "VEHICLE_WEAPON_MULE4_MG",
            weapon_label = "",
            display_name_label = "mule4",
            class_id = 20,
            vehicle_model = "mule4"
        },
        {
            weapon_model = "VEHICLE_WEAPON_MULE4_MISSILE",
            weapon_label = "",
            display_name_label = "mule4",
            class_id = 20,
            vehicle_model = "mule4"
        },
        {
            weapon_model = "VEHICLE_WEAPON_MULE4_TURRET_GL",
            weapon_label = "",
            display_name_label = "mule4",
            class_id = 20,
            vehicle_model = "mule4"
        },
        {
            weapon_model = "VEHICLE_WEAPON_NIGHTSHARK_MG",
            weapon_label = "",
            display_name_label = "NIGHTSHARK",
            class_id = 9,
            vehicle_model = "nightshark"
        },
        {
            weapon_model = "VEHICLE_WEAPON_DOGFIGHTER_MG",
            weapon_label = "",
            display_name_label = "NOKOTA",
            class_id = 16,
            vehicle_model = "nokota"
        },
        {
            weapon_model = "VEHICLE_WEAPON_DOGFIGHTER_MISSILE",
            weapon_label = "",
            display_name_label = "NOKOTA",
            class_id = 16,
            vehicle_model = "nokota"
        },
        {
            weapon_model = "VEHICLE_WEAPON_OPPRESSOR_MG",
            weapon_label = "",
            display_name_label = "OPPRESSOR",
            class_id = 8,
            vehicle_model = "oppressor"
        },
        {
            weapon_model = "VEHICLE_WEAPON_OPPRESSOR_MISSILE",
            weapon_label = "",
            display_name_label = "OPPRESSOR",
            class_id = 8,
            vehicle_model = "oppressor"
        },
        {
            weapon_model = "VEHICLE_WEAPON_OPPRESSOR2_MG",
            weapon_label = "",
            display_name_label = "oppressor2",
            class_id = 8,
            vehicle_model = "oppressor2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_OPPRESSOR2_CANNON",
            weapon_label = "",
            display_name_label = "oppressor2",
            class_id = 8,
            vehicle_model = "oppressor2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_OPPRESSOR2_MISSILE",
            weapon_label = "",
            display_name_label = "oppressor2",
            class_id = 8,
            vehicle_model = "oppressor2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_PARAGON2_MG",
            weapon_label = "",
            display_name_label = "paragon2",
            class_id = 6,
            vehicle_model = "paragon2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_GRANGER2_MG",
            weapon_label = "",
            display_name_label = "PATRIOT3",
            class_id = 9,
            vehicle_model = "patriot3"
        },
        {
            weapon_model = "VEHICLE_WEAPON_TURRET_PATROLBOAT_50CAL",
            weapon_label = "",
            display_name_label = "patrolboat",
            class_id = 14,
            vehicle_model = "patrolboat"
        },
        {
            weapon_model = "VEHICLE_WEAPON_PATROLBOAT_DUALMG",
            weapon_label = "",
            display_name_label = "patrolboat",
            class_id = 14,
            vehicle_model = "patrolboat"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SEARCHLIGHT",
            weapon_label = "",
            display_name_label = "polmav",
            class_id = 15,
            vehicle_model = "polmav"
        },
        {
            weapon_model = "VEHICLE_WEAPON_POUNDER2_MINI",
            weapon_label = "",
            display_name_label = "pounder2",
            class_id = 20,
            vehicle_model = "pounder2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_POUNDER2_MISSILE",
            weapon_label = "",
            display_name_label = "pounder2",
            class_id = 20,
            vehicle_model = "pounder2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_POUNDER2_BARRAGE",
            weapon_label = "",
            display_name_label = "pounder2",
            class_id = 20,
            vehicle_model = "pounder2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_POUNDER2_GL",
            weapon_label = "",
            display_name_label = "pounder2",
            class_id = 20,
            vehicle_model = "pounder2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_RADAR",
            weapon_label = "",
            display_name_label = "predator",
            class_id = 14,
            vehicle_model = "Predator"
        },
        {
            weapon_model = "VEHICLE_WEAPON_DOGFIGHTER_MG",
            weapon_label = "",
            display_name_label = "PYRO",
            class_id = 16,
            vehicle_model = "pyro"
        },
        {
            weapon_model = "VEHICLE_WEAPON_DOGFIGHTER_MISSILE",
            weapon_label = "",
            display_name_label = "PYRO",
            class_id = 16,
            vehicle_model = "pyro"
        },
        {
            weapon_model = "VEHICLE_WEAPON_RAIJU_CANNONS",
            weapon_label = "",
            display_name_label = "raiju",
            class_id = 16,
            vehicle_model = "raiju"
        },
        {
            weapon_model = "VEHICLE_WEAPON_RAIJU_MISSILES",
            weapon_label = "",
            display_name_label = "raiju",
            class_id = 16,
            vehicle_model = "raiju"
        },
        {
            weapon_model = "VEHICLE_WEAPON_REVOLTER_MG",
            weapon_label = "",
            display_name_label = "revolter",
            class_id = 6,
            vehicle_model = "revolter"
        },
        {
            weapon_model = "VEHICLE_WEAPON_TANK",
            weapon_label = "WT_V_TANK",
            display_name_label = "rhino",
            class_id = 19,
            vehicle_model = "RHINO"
        },
        {
            weapon_model = "VEHICLE_WEAPON_WATER_CANNON",
            weapon_label = "",
            display_name_label = "riot2",
            class_id = 18,
            vehicle_model = "riot2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_ROGUE_MG",
            weapon_label = "",
            display_name_label = "Rogue",
            class_id = 16,
            vehicle_model = "rogue"
        },
        {
            weapon_model = "VEHICLE_WEAPON_ROGUE_CANNON",
            weapon_label = "",
            display_name_label = "Rogue",
            class_id = 16,
            vehicle_model = "rogue"
        },
        {
            weapon_model = "VEHICLE_WEAPON_ROGUE_MISSILE",
            weapon_label = "",
            display_name_label = "Rogue",
            class_id = 16,
            vehicle_model = "rogue"
        },
        {
            weapon_model = "VEHICLE_WEAPON_RUINER_BULLET",
            weapon_label = "WT_V_PLRBUL",
            display_name_label = "RUINER2",
            class_id = 4,
            vehicle_model = "ruiner2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_RUINER_ROCKET",
            weapon_label = "WT_V_PLANEMSL",
            display_name_label = "RUINER2",
            class_id = 4,
            vehicle_model = "ruiner2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_PLAYER_SAVAGE",
            weapon_label = "WT_V_LZRCAN",
            display_name_label = "savage",
            class_id = 15,
            vehicle_model = "savage"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SPACE_ROCKET",
            weapon_label = "WT_V_PLANEMSL",
            display_name_label = "savage",
            class_id = 15,
            vehicle_model = "savage"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SAVESTRA_MG",
            weapon_label = "",
            display_name_label = "savestra",
            class_id = 5,
            vehicle_model = "savestra"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SCARAB_50CAL",
            weapon_label = "",
            display_name_label = "scarab",
            class_id = 19,
            vehicle_model = "scarab"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SCARAB_50CAL",
            weapon_label = "",
            display_name_label = "scarab2",
            class_id = 19,
            vehicle_model = "scarab2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SCARAB2_50CAL_LASER",
            weapon_label = "",
            display_name_label = "scarab2",
            class_id = 19,
            vehicle_model = "scarab2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SCARAB_50CAL",
            weapon_label = "",
            display_name_label = "scarab3",
            class_id = 19,
            vehicle_model = "scarab3"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SCRAMJET_MG",
            weapon_label = "",
            display_name_label = "scramjet",
            class_id = 7,
            vehicle_model = "scramjet"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SCRAMJET_MISSILE",
            weapon_label = "",
            display_name_label = "scramjet",
            class_id = 7,
            vehicle_model = "scramjet"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SEABREEZE_MG",
            weapon_label = "",
            display_name_label = "SEABREEZE",
            class_id = 16,
            vehicle_model = "seabreeze"
        },
        {
            weapon_model = "VEHICLE_WEAPON_HAVOK_MINIGUN",
            weapon_label = "",
            display_name_label = "Sparrow",
            class_id = 15,
            vehicle_model = "seasparrow"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SPACE_ROCKET",
            weapon_label = "WT_V_PLANEMSL",
            display_name_label = "Sparrow",
            class_id = 15,
            vehicle_model = "seasparrow"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SEASPARROW2_MINIGUN",
            weapon_label = "",
            display_name_label = "SPARROW2",
            class_id = 15,
            vehicle_model = "seasparrow2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SPACE_ROCKET",
            weapon_label = "WT_V_PLANEMSL",
            display_name_label = "SPARROW2",
            class_id = 15,
            vehicle_model = "seasparrow2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SEASPARROW2_MINIGUN",
            weapon_label = "",
            display_name_label = "SPARROW3",
            class_id = 15,
            vehicle_model = "seasparrow3"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SPACE_ROCKET",
            weapon_label = "WT_V_PLANEMSL",
            display_name_label = "SPARROW3",
            class_id = 15,
            vehicle_model = "seasparrow3"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SLAMVAN4_50CAL",
            weapon_label = "",
            display_name_label = "slamvan4",
            class_id = 4,
            vehicle_model = "slamvan4"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SLAMVAN4_50CAL",
            weapon_label = "",
            display_name_label = "slamvan5",
            class_id = 4,
            vehicle_model = "slamvan5"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SLAMVAN5_50CAL_LASER",
            weapon_label = "",
            display_name_label = "slamvan5",
            class_id = 4,
            vehicle_model = "slamvan5"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SLAMVAN4_50CAL",
            weapon_label = "",
            display_name_label = "slamvan6",
            class_id = 4,
            vehicle_model = "slamvan6"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SPEEDO4_MG",
            weapon_label = "",
            display_name_label = "speedo4",
            class_id = 12,
            vehicle_model = "speedo4"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SPEEDO4_TURRET_MG",
            weapon_label = "",
            display_name_label = "speedo4",
            class_id = 12,
            vehicle_model = "speedo4"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SPEEDO4_TURRET_MINI",
            weapon_label = "",
            display_name_label = "speedo4",
            class_id = 12,
            vehicle_model = "speedo4"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SPEEDO4_MG",
            weapon_label = "",
            display_name_label = "speedo4",
            class_id = 12,
            vehicle_model = "speedo5"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SPEEDO4_TURRET_MG",
            weapon_label = "",
            display_name_label = "speedo4",
            class_id = 12,
            vehicle_model = "speedo5"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SPEEDO4_TURRET_MINI",
            weapon_label = "",
            display_name_label = "speedo4",
            class_id = 12,
            vehicle_model = "speedo5"
        },
        {
            weapon_model = "VEHICLE_WEAPON_DOGFIGHTER_MG",
            weapon_label = "",
            display_name_label = "STARLING",
            class_id = 16,
            vehicle_model = "starling"
        },
        {
            weapon_model = "VEHICLE_WEAPON_DOGFIGHTER_MISSILE",
            weapon_label = "",
            display_name_label = "STARLING",
            class_id = 16,
            vehicle_model = "starling"
        },
        {
            weapon_model = "VEHICLE_WEAPON_STREAMER_NOSEMG",
            weapon_label = "",
            display_name_label = "streamer216",
            class_id = 16,
            vehicle_model = "streamer216"
        },
        {
            weapon_model = "VEHICLE_WEAPON_STRIKEFORCE_CANNON",
            weapon_label = "",
            display_name_label = "strikeforce",
            class_id = 16,
            vehicle_model = "strikeforce"
        },
        {
            weapon_model = "VEHICLE_WEAPON_STRIKEFORCE_MISSILE",
            weapon_label = "",
            display_name_label = "strikeforce",
            class_id = 16,
            vehicle_model = "strikeforce"
        },
        {
            weapon_model = "VEHICLE_WEAPON_STRIKEFORCE_BARRAGE",
            weapon_label = "",
            display_name_label = "strikeforce",
            class_id = 16,
            vehicle_model = "strikeforce"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SUBCAR_MG",
            weapon_label = "",
            display_name_label = "stromberg",
            class_id = 5,
            vehicle_model = "stromberg"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SUBCAR_MISSILE",
            weapon_label = "",
            display_name_label = "stromberg",
            class_id = 5,
            vehicle_model = "stromberg"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SUBCAR_TORPEDO",
            weapon_label = "",
            display_name_label = "stromberg",
            class_id = 5,
            vehicle_model = "stromberg"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SEARCHLIGHT",
            weapon_label = "",
            display_name_label = "SVOLITO",
            class_id = 15,
            vehicle_model = "supervolito"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SEARCHLIGHT",
            weapon_label = "",
            display_name_label = "SVOLITO2",
            class_id = 15,
            vehicle_model = "supervolito2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SEARCHLIGHT",
            weapon_label = "",
            display_name_label = "SWIFT",
            class_id = 15,
            vehicle_model = "swift"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SEARCHLIGHT",
            weapon_label = "",
            display_name_label = "swift2",
            class_id = 15,
            vehicle_model = "swift2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_TAMPA_MISSILE",
            weapon_label = "",
            display_name_label = "TAMPA3",
            class_id = 4,
            vehicle_model = "tampa3"
        },
        {
            weapon_model = "VEHICLE_WEAPON_TAMPA_MORTAR",
            weapon_label = "",
            display_name_label = "TAMPA3",
            class_id = 4,
            vehicle_model = "tampa3"
        },
        {
            weapon_model = "VEHICLE_WEAPON_TAMPA_FIXEDMINIGUN",
            weapon_label = "",
            display_name_label = "TAMPA3",
            class_id = 4,
            vehicle_model = "tampa3"
        },
        {
            weapon_model = "VEHICLE_WEAPON_TAMPA_DUALMINIGUN",
            weapon_label = "",
            display_name_label = "TAMPA3",
            class_id = 4,
            vehicle_model = "tampa3"
        },
        {
            weapon_model = "VEHICLE_WEAPON_TURRET_TECHNICAL",
            weapon_label = "WT_V_TURRET",
            display_name_label = "TECHNICAL",
            class_id = 9,
            vehicle_model = "technical"
        },
        {
            weapon_model = "VEHICLE_WEAPON_TURRET_TECHNICAL",
            weapon_label = "WT_V_TURRET",
            display_name_label = "TECHNICAL2",
            class_id = 9,
            vehicle_model = "technical2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_TURRET_TECHNICAL",
            weapon_label = "WT_V_TURRET",
            display_name_label = "technical3",
            class_id = 9,
            vehicle_model = "technical3"
        },
        {
            weapon_model = "VEHICLE_WEAPON_TECHNICAL_MINIGUN",
            weapon_label = "",
            display_name_label = "technical3",
            class_id = 9,
            vehicle_model = "technical3"
        },
        {
            weapon_model = "VEHICLE_WEAPON_HACKER_MISSILE",
            weapon_label = "",
            display_name_label = "terbyte",
            class_id = 20,
            vehicle_model = "terbyte"
        },
        {
            weapon_model = "VEHICLE_WEAPON_HACKER_MISSILE_HOMING",
            weapon_label = "",
            display_name_label = "terbyte",
            class_id = 20,
            vehicle_model = "terbyte"
        },
        {
            weapon_model = "VEHICLE_WEAPON_THRUSTER_MG",
            weapon_label = "",
            display_name_label = "thruster",
            class_id = 19,
            vehicle_model = "thruster"
        },
        {
            weapon_model = "VEHICLE_WEAPON_THRUSTER_MISSILE",
            weapon_label = "",
            display_name_label = "thruster",
            class_id = 19,
            vehicle_model = "thruster"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SUBCAR_MG",
            weapon_label = "",
            display_name_label = "toreador",
            class_id = 5,
            vehicle_model = "toreador"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SUBCAR_MISSILE",
            weapon_label = "",
            display_name_label = "toreador",
            class_id = 5,
            vehicle_model = "toreador"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SUBCAR_TORPEDO",
            weapon_label = "",
            display_name_label = "toreador",
            class_id = 5,
            vehicle_model = "toreador"
        },
        {
            weapon_model = "VEHICLE_WEAPON_MOBILEOPS_CANNON",
            weapon_label = "",
            display_name_label = "TRLARGE",
            class_id = 11,
            vehicle_model = "trailerlarge"
        },
        {
            weapon_model = "VEHICLE_WEAPON_TRAILER_QUADMG",
            weapon_label = "",
            display_name_label = "TRSMALL2",
            class_id = 19,
            vehicle_model = "trailersmall2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_TRAILER_MISSILE",
            weapon_label = "",
            display_name_label = "TRSMALL2",
            class_id = 19,
            vehicle_model = "trailersmall2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_TRAILER_DUALAA",
            weapon_label = "",
            display_name_label = "TRSMALL2",
            class_id = 19,
            vehicle_model = "trailersmall2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_TULA_NOSEMG",
            weapon_label = "",
            display_name_label = "TULA",
            class_id = 16,
            vehicle_model = "tula"
        },
        {
            weapon_model = "VEHICLE_WEAPON_TULA_MG",
            weapon_label = "",
            display_name_label = "TULA",
            class_id = 16,
            vehicle_model = "tula"
        },
        {
            weapon_model = "VEHICLE_WEAPON_TULA_DUALMG",
            weapon_label = "",
            display_name_label = "TULA",
            class_id = 16,
            vehicle_model = "tula"
        },
        {
            weapon_model = "VEHICLE_WEAPON_TULA_MINIGUN",
            weapon_label = "",
            display_name_label = "TULA",
            class_id = 16,
            vehicle_model = "tula"
        },
        {
            weapon_model = "VEHICLE_WEAPON_NOSE_TURRET_VALKYRIE",
            weapon_label = "WT_V_PLRBUL",
            display_name_label = "VALKYRIE",
            class_id = 15,
            vehicle_model = "valkyrie"
        },
        {
            weapon_model = "VEHICLE_WEAPON_TURRET_VALKYRIE",
            weapon_label = "WT_V_TURRET",
            display_name_label = "VALKYRIE",
            class_id = 15,
            vehicle_model = "valkyrie"
        },
        {
            weapon_model = "VEHICLE_WEAPON_TURRET_VALKYRIE",
            weapon_label = "WT_V_TURRET",
            display_name_label = "VALKYRI2",
            class_id = 15,
            vehicle_model = "valkyrie2"
        },
        {
            weapon_model = "VEHICLE_WEAPON_VIGILANTE_MG",
            weapon_label = "",
            display_name_label = "Vigilante",
            class_id = 7,
            vehicle_model = "vigilante"
        },
        {
            weapon_model = "VEHICLE_WEAPON_VIGILANTE_MISSILE",
            weapon_label = "",
            display_name_label = "Vigilante",
            class_id = 7,
            vehicle_model = "vigilante"
        },
        {
            weapon_model = "VEHICLE_WEAPON_VISERIS_MG",
            weapon_label = "",
            display_name_label = "viseris",
            class_id = 5,
            vehicle_model = "viseris"
        },
        {
            weapon_model = "VEHICLE_WEAPON_VOLATOL_DUALMG",
            weapon_label = "",
            display_name_label = "volatol",
            class_id = 16,
            vehicle_model = "volatol"
        },
        {
            weapon_model = "VEHICLE_WEAPON_SEARCHLIGHT",
            weapon_label = "",
            display_name_label = "VOLATUS",
            class_id = 15,
            vehicle_model = "volatus"
        },
        {
            weapon_model = "VEHICLE_WEAPON_ZR380_50CAL",
            weapon_label = "",
            display_name_label = "zr380",
            class_id = 6,
            vehicle_model = "zr380"
        },
        {
            weapon_model = "VEHICLE_WEAPON_ZR380_50CAL",
            weapon_label = "",
            display_name_label = "zr3802",
            class_id = 6,
            vehicle_model = "zr3802"
        },
        {
            weapon_model = "VEHICLE_WEAPON_ZR3802_50CAL_LASER",
            weapon_label = "",
            display_name_label = "zr3802",
            class_id = 6,
            vehicle_model = "zr3802"
        },
        {
            weapon_model = "VEHICLE_WEAPON_ZR380_50CAL",
            weapon_label = "",
            display_name_label = "zr3803",
            class_id = 6,
            vehicle_model = "zr3803"
        },
    }
}


Enum = {
    -- `Enum` 语言类型
    LanguageType = {
        [-1] = "Undefined",
        [0] = "English",
        [1] = "French",
        [2] = "German",
        [3] = "Italian",
        [4] = "Spanish",
        [5] = "Portuguese",
        [6] = "Polish",
        [7] = "Russian",
        [8] = "Korean",
        [9] = "Chinese Traditional",
        [10] = "Japanese",
        [11] = "Mexican",
        [12] = "Chinese Simplified",
    },
}


Ped_T = {
    -- `Enum` Ped 类型
    Type = {
        [0] = "Player 0",
        [1] = "Player 1",
        [2] = "Network Player",
        [3] = "Player 2",
        [4] = "Civilian Male",
        [5] = "Civilian Female",
        [6] = "Cop",
        [7] = "Gang Albanian",
        [8] = "Gang Biker 1",
        [9] = "Gang Biker 2",
        [10] = "Gang Italian",
        [11] = "Gang Russian",
        [12] = "Gang Russian 2",
        [13] = "Gang Irish",
        [14] = "Gang Jamaican",
        [15] = "Gang African American",
        [16] = "Gang Korean",
        [17] = "Gang Chinese Japanese",
        [18] = "Gang Puerto Rican",
        [19] = "Dealer",
        [20] = "Medic",
        [21] = "Fireman",
        [22] = "Criminal",
        [23] = "Bum",
        [24] = "Prostitute",
        [25] = "Special",
        [26] = "Mission",
        [27] = "Swat",
        [28] = "Animal",
        [29] = "Army",
    },

    -- `Enum` NPC 作战移动方式
    CombatMovement = {
        [0] = "Stationary",
        [1] = "Defensive",
        [2] = "Will Advance",
        [3] = "Will Retreat",
    },

    -- `Enum` NPC 作战能力
    CombatAbility = {
        [0] = "Poor",
        [1] = "Average",
        [2] = "Professional",
    },

    -- `Enum` NPC 作战范围
    CombatRange = {
        [0] = "Near",
        [1] = "Medium",
        [2] = "Far",
        [3] = "Very Far",
    },

    -- `Enum` NPC 警觉度
    Alertness = {
        [0] = "Not Alert",         -- Ped hasn't received any events recently
        [1] = "Alert",             -- Ped has received at least one event
        [2] = "Very Alert",        -- Ped has received multiple events
        [3] = "Must Go To Combat", -- This value basically means the ped should be in combat but isn't because he's not allowed to investigate etc
    },

    -- `Enum` Ped 之间的关系类型
    RelationshipType = {
        [0] = "Respect",
        [1] = "Like",
        [2] = "Ignore",
        [3] = "Dislike",
        [4] = "Wanted",
        [5] = "Hate",
        [6] = "Dead",
        [255] = "None",
    },

    -- `ListItem` NPC 驾驶载具风格
    DrivingStyle = {
        ListItem = {
            { 1, "正常" },
            { 2, "半冲刺" },
            { 3, "反向" },
            { 4, "无视红绿灯" },
            { 5, "避开交通" },
            { 6, "极度避开交通" },
            { 7, "有时超车" },
            { 8, "受到惊吓" },
        },
        ValueList = {
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
            6,
        },
    },

    -- `ListItem` NPC 射击模式
    FirePattern = {
        ListItem = {
            { 1,  "Burst Fire" },
            { 2,  "Burst Fire In Cover" },
            { 3,  "Burst Fire Driveby" },
            { 4,  "From Ground" },
            { 5,  "Delay Fire By One Sec" },
            { 6,  "Full Auto" },
            { 7,  "Single Shot" },
            { 8,  "Burst Fire Pistol" },
            { 9,  "Burst Fire Smg" },
            { 10, "Burst Fire Rifle" },
            { 11, "Burst Fire Mg" },
            { 12, "Burst Fire Pumpshotgun" },
            { 13, "Burst Fire Heli" },
            { 14, "Burst Fire Micro" },
            { 15, "Short Bursts" },
            { 16, "Slow Fire Tank" },
        },
        ValueList = {
            1073727030,
            40051185,
            -753768974,
            577037782,
            2055493265,
            -957453492,
            1566631136,
            -1608983670,
            1863348768,
            -1670073338,
            -1250703948,
            12239771,
            -1857128337,
            1122960381,
            445831135,
            -490063247,
        }
    },

    -- `List` NPC 作战属性
    CombatAttributes = {
        -- { name, comment }
        List = {
            { "Use Cover",      "AI will only use cover if this is set" },
            { "Use Vehicle",    "AI will only use vehicles if this is set" },
            { "Do Drivebys",    "AI will only driveby from a vehicle if this is set" },
            { "Leave Vehicles", "Will be forced to stay in a ny vehicel if this isn't set" },
            { "Can Use Dynamic Strafe Decisions",
                "This ped can make decisions on whether to strafe or not based on distance to destination, recent bullet events, etc." },
            { "Always Fight",           "Ped will always fight upon getting threat response task" },
            { "Flee Whilst In Vehicle", "If in combat and in a vehicle, the ped will flee rather than attacking" },
            { "Just Follow Vehicle",
                "If in combat and chasing in a vehicle, the ped will keep a distance behind rather than ramming" },
            { "Will Scan For Dead Peds", "Peds will scan for and react to dead peds found" },
            { "Just Seek Cover",         "The ped will seek cover only" },
            { "Blind Fire In Cover",     "Ped will only blind fire when in cover" },
            { "Aggressive",              "Ped may advance" },
            { "Can Investigate",         "Ped can investigate events such as distant gunfire, footsteps, explosions etc" },
            { "Can Use Radio",           "Ped can use a radio to call for backup (happens after a reaction)" },
            { "Always Flee",             "Ped will always flee upon getting threat response task" },
            { "Can Taunt In Vehicle",    "Ped can do unarmed taunts in vehicle" },
            { "Can Chase Target On Foot",
                "Ped will be able to chase their targets if both are on foot and the target is running away" },
            { "Will Drag Injured Peds To Safety", "Ped can drag injured peds to safety" },
            { "Requires Los To Shoot",            "Ped will require LOS to the target it is aiming at before shooting" },
            { "Use Proximity Firing Rate",
                "Ped is allowed to use proximity based fire rate (increasing fire rate at closer distances)" },
            { "Disable Secondary Target",
                "Normally peds can switch briefly to a secondary target in combat, setting this will prevent that" },
            { "Disable Entry Reactions",
                "This will disable the flinching combat entry reactions for peds, instead only playing the turn and aim anims" },
            { "Perfect Accuracy",           "Force ped to be 100% accurate in all situations (added by Jay Reinebold)" },
            { "Can Use Frustrated Advance",
                "If we don't have cover and can't see our target it's possible we will advance, even if the target is in cover" },
            { "Move To Location Before Cover Search",
                "This will have the ped move to defensive areas and within attack windows before performing the cover search" },
            { "Can Shoot Without Los",
                "Allow shooting of our weapon even if we don't have LOS (this isn't X-ray vision as it only affects weapon firing)" },
            { "Maintain Min Distance To Target",
                "Ped will try to maintain a min distance to the target, even if using defensive areas (currently only for cover finding + usage)" },
            { "Can Use Peeking Variations", "Allows ped to use steamed variations of peeking anims" },
            { "Disable Pinned Down",        "Disables pinned down behaviors" },
            { "Disable Pin Down Others",    "Disables pinning down others" },
            { "Open Combat When Defensive Area Is Reached",
                "When defensive area is reached the area is cleared and the ped is set to use defensive combat movement" },
            { "Disable Bullet Reactions",             "Disables bullet reactions" },
            { "Can Bust",                             "Allows ped to bust the player" },
            { "Ignored By Other Peds When Wanted",    "This ped is ignored by other peds when wanted" },
            { "Can Commandeer Vehicles",              "Ped is allowed to \"jack\" vehicles when needing to chase a target in combat" },
            { "Can Flank",                            "Ped is allowed to flank" },
            { "Switch To Advance If Cant Find Cover", "Ped will switch to advance if they can't find cover" },
            { "Switch To Defensive If In Cover",      "Ped will switch to defensive if they are in cover" },
            { "Clear Primary Defensive Area When Reached",
                "Ped will clear their primary defensive area when it is reached" },
            { "Can Fight Armed Peds When Not Armed", "Ped is allowed to fight armed peds when not armed" },
            { "Enable Tactical Points When Defensive",
                "Ped is not allowed to use tactical points if set to use defensive movement (will only use cover)" },
            { "Disable Cover Arc Adjustments",
                "Ped cannot adjust cover arcs when testing cover safety (atm done on corner cover points when  ped usingdefensive area + no LOS)" },
            { "Use Enemy Accuracy Scaling",
                "Ped may use reduced accuracy with large number of enemies attacking the same local player target" },
            { "Can Charge",                          "Ped is allowed to charge the enemy position" },
            { "Remove Area Set Will Advance When Defensive Area Reached",
                "When defensive area is reached the area is cleared and the ped is set to use will advance movement" },
            { "Use Vehicle Attack",       "Use the vehicle attack mission during combat (only works on driver)" },
            { "Use Vehicle Attack If Vehicle Has Mounted Guns",
                "Use the vehicle attack mission during combat if the vehicle has mounted guns (only works on driver)" },
            { "Always Equip Best Weapon", "Always equip best weapon in combat" },
            { "Can See Underwater Peds",  "Ignores in water at depth visibility check" },
            { "Disable Aim At Ai Targets In Helis",
                "Will prevent this ped from aiming at any AI targets that are in helicopters" },
            { "Disable Seek Due To Line Of Sight",             "Disables peds seeking due to no clear line of sight" },
            { "Disable Flee From Combat",
                "To be used when releasing missions peds if we don't want them fleeing from combat (mission peds already prevent flee)" },
            { "Disable Target Changes During Vehicle Pursuit", "Disables target changes during vehicle pursuit" },
            { "Can Throw Smoke Grenade",                       "Ped may throw a smoke grenade at player loitering in combat" },
            { "Clear Area Set Defensive If Defensive Cannot Be Reached",
                "Will clear a set defensive area if that area cannot be reached" },
            { "Disable Block From Pursue During Vehicle Chase", "Disable block from pursue during vehicle chases" },
            { "Disable Spin Out During Vehicle Chase",          "Disable spin out during vehicle chases" },
            { "Disable Cruise In Front During Block During Vehicle Chase",
                "Disable cruise in front during block during vehicle chases" },
            { "Can Ignore Blocked Los Weighting",
                "Makes it more likely that the ped will continue targeting a target with blocked los for a few seconds" },
            { "Disable React To Buddy Shot",                   "Disables the react to buddy shot behaviour." },
            { "Prefer Navmesh During Vehicle Chase",           "Prefer pathing using navmesh over road nodes" },
            { "Allowed To Avoid Offroad During Vehicle Chase", "Ignore road edges when avoiding" },
            { "Permit Charge Beyond Defensive Area",
                "Permits ped to charge a target outside the assigned defensive area." },
            { "Use Rockets Against Vehicles Only",
                "This ped will switch to an RPG if target is in a vehicle, otherwise will use alternate weapon." },
            { "Disable Tactical Points Without Clear Los",   "Disables peds moving to a tactical point without clear los" },
            { "Disable Pull Alongside During Vehicle Chase", "Disables pull alongside during vehicle chase" },
            { "Disable All Randoms Flee",
                "If set on a ped, they will not flee when all random peds flee is set to TRUE (they are still able to flee due to other reasons)" },
            { "Will Generate Dead Ped Seen Script Events",
                "This ped will send out a script DeadPedSeenEvent when they see a dead ped" },
            { "Use Max Sense Range When Receiving Events",
                "This will use the receiving peds sense range rather than the range supplied to the communicate event" },
            { "Restrict In Vehicle Aiming To Current Side",
                "When aiming from a vehicle the ped will only aim at targets on his side of the vehicle" },
            { "Use Default Blocked Los Position And Direction",
                "LOS to the target is blocked we return to our default position and direction until we have LOS (no aiming)" },
            { "Requires Los To Aim",
                "LOS to the target is blocked we return to our default position and direction until we have LOS (no aiming)" },
            { "Can Cruise And Block In Vehicle",
                "Allow vehicles spawned infront of target facing away to enter cruise and wait to block approaching target" },
            { "Prefer Air Combat When In Aircraft",
                "Peds flying aircraft will prefer to target other aircraft over entities on the ground" },
            { "Allow Dog Fighting", "Allow peds flying aircraft to use dog fighting behaviours" },
            { "Prefer Non Aircraft Targets",
                "This will make the weight of targets who aircraft vehicles be reduced greatly compared to targets on foot or in ground based vehicles" },
            { "Prefer Known Targets When Combat Closest Target",
                "When peds are tasked to go to combat, they keep searching for a known target for a while before forcing an unknown one" },
            { "Force Check Attack Angle For Mounted Guns",
                "Only allow mounted weapons to fire if within the correct attack angle (default 25-degree cone). On a flag in order to keep exiting behaviour and only fix in specific cases." },
            { "Block Fire For Vehicle Passenger Mounted Guns",
                "Blocks the firing state for passenger-controlled mounted weapons. Existing flags USE_VEHICLE_ATTACK and USE_VEHICLE_ATTACK_IF_VEHICLE_HAS_MOUNTED_GUNS only work for drivers." },
        },
        ValueList = {
            0, 1, 2, 3, 4, 5, 6, 7, 9, 11, 12, 13, 14, 15, 17, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 34, 35,
            36,
            37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 62, 64, 65,
            66,
            67, 68, 69, 70, 71, 72, 73, 74, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90,
        },
    },

    -- `List` NPC 作战数值
    CombatFloat = {
        -- { name, comment }
        List = {
            { "Blind Fire Chance",
                "Chance to blind fire from cover, range is 0.0-1.0 (default is 0.05 for civilians, law doesn't blind fire)" },
            { "Burst Duration In Cover", "How long each burst from cover should last (default is 2.0)" },
            { "Max Shooting Distance",
                "The maximum distance the ped will try to shoot from (will override weapon range if set to anything > 0.0, default is -1.0)" },
            { "Time Between Bursts In Cover",
                "How long to wait, in cover, between firing bursts (< 0.0 will disable firing, unless cover fire is requested, default is 1.25)" },
            { "Time Between Peeks",      "How long to wait before attempting to peek again (default is 10.0)" },
            { "Strafe When Moving Chance",
                "A chance to strafe to cover, range is 0.0-1.0 (0.0 will force them to run, 1.0 will force strafe and shoot, default is 1.0)" },
            { "Weapon Accuracy",   "default is 0.4" },
            { "Fight Proficiency", "How well an opponent can melee fight, range is 0.0-1.0 (default is 0.5)" },
            { "Walk When Strafing Chance",
                "The possibility of a ped walking while strafing rather than jog/run, range is 0.0-1.0 (default is 0.0)" },
            { "Heli Speed Modifier", "The speed modifier when driving a heli in combat" },
            { "Heli Senses Range",   "The range of the ped's senses (sight, identification, hearing) when in a heli" },
            { "Attack Window Distance For Cover",
                "The distance we'll use for cover based behaviour in attack windows Default is -1.0 (disabled), range is -1.0 to 150.0" },
            { "Time To Invalidate Injured Target",
                "How long to stop combat an injured target if there is no other valid target, if target is player in singleplayer this will happen indefinitely unless explicitly disabled by setting to 0.0, default = 10.0 range = 0-50" },
            { "Min Distance To Target",
                "Min distance the ped will use if CA_MAINTAIN_MIN_DISTANCE_TO_TARGET is set, default 5.0 (currently only for cover search + usage)" },
            { "Bullet Impact Detection Range", "The range at which the ped will detect the bullet impact event" },
            { "Aim Turn Threshold",            "The threshold at which the ped will perform an aim turn" },
            { "Optimal Cover Distance",        "" },
            { "Automobile Speed Modifier",     "The speed modifier when driving an automobile in combat" },
            { "Speed To Flee In Vehicle",      "" },
            { "Trigger Charge Time Near",      "How long to wait before charging a close target hiding in cover" },
            { "Trigger Charge Time Far",       "How long to wait before charging a distant target hiding in cover" },
            { "Max Distance To Hear Events",   "Max distance peds can hear an event from, even if the sound is louder" },
            { "Max Distance To Hear Events Using Los",
                "Max distance peds can hear an event from, even if the sound is louder if the ped is using LOS to hear events (CPED_CONFIG_FLAG_CheckLoSForSoundEvents)" },
            { "Homing Rocket Break Lock Angle",
                "Angle between the rocket and target where lock-on will stop, range is 0.0-1.0, (default is 0.2), the bigger the number the easier to break lock" },
            { "Homing Rocket Break Lock Angle Close",
                "Angle between the rocket and target where lock-on will stop, when rocket is within HOMING_ROCKET_BREAK_LOCK_CLOSE_DISTANCE, range is 0.0-1.0, (default is 0.6), the bigger the number the easier to break lock" },
            { "Homing Rocket Break Lock Close Distance",
                "Distance at which we check HOMING_ROCKET_BREAK_LOCK_ANGLE_CLOSE rather than HOMING_ROCKET_BREAK_LOCK_ANGLE" },
            { "Homing Rocket Turn Rate Modifier",
                "Alters homing characteristics defined for the weapon (1.0 is default, <1.0 slow turn rates, >1.0 speed them up" },
            { "Time Between Aggressive Moves During Vehicle Chase",
                "Sets the time delay between aggressive moves during vehicle chases. -1.0 means use random values, 0.0 means never" },
            { "Max Vehicle Turret Firing Range", "Max firing range for a ped in vehicle turret seat" },
            { "Weapon Damage Modifier",
                "Multiplies the weapon damage dealt by the ped, range is 0.0-10.0 (default is 1.0)" },
        },
        ValueList = {
            0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29,
        },
    },

    -- `Enum` Ped Director Name *[ped_hash] = label_key*
    DirectorName = {
        [-413447396] = "CM_PROAIR",
        [1561705728] = "CM_PROBAR",
        [-1613485779] = "CM_PROBOU",
        [-912318012] = "CM_PROCEO",
        [-1606864033] = "CM_PROCEO",
        [261586155] = "CM_PROCHE",
        [-610530921] = "CM_PROCOO",
        [-730659924] = "CM_PRODOC",
        [579932932] = "CM_PRODOR",
        [-521758348] = "CM_PRODRA",
        [-570394627] = "CM_PROIT",
        [-527186490] = "CM_PROMAI",
        [2124742566] = "CM_PROMAR",
        [-1280051738] = "CM_PROOFF",
        [532905404] = "CM_PROOFF",
        [1092080539] = "CM_PROSCI",
        [1264851357] = "CM_PROSTY",
        [429425116] = "CM_PROSTY",
        [999748158] = "CM_PROVAL",
        [-1589423867] = "CM_PROVEN",
        [-1106743555] = "CM_PROVEN",
        [-1387498932] = "CM_PROWAI",
        [1567728751] = "CM_PROAIH",
        [-1745486195] = "CM_PROAUP",
        [1055701597] = "CM_PROBIN",
        [1535236204] = "CM_PROFAS",
        [373000027] = "CM_PROHAI",
        [-1366884940] = "CM_PROINT",
        [664399832] = "CM_PROLAW",
        [-1371020112] = "CM_PROPON",
        [826475330] = "CM_PROREL",
        [42647445] = "CM_PROSTR",
        [-1211756494] = "CM_PROTEA",
        [1312913862] = "CM_UPTEAS",
        [534725268] = "CM_UPTECC",
        [349505262] = "CM_UPTHAW",
        [587703123] = "CM_UPTMIR",
        [1423699487] = "CM_UPTROC",
        [-1047300121] = "CM_UPTVIN",
        [-1514497514] = "CM_UPTHIP",
        [-2109222095] = "CM_UPTCOU",
        [435429221] = "CM_UPTART",
        [-85696186] = "CM_UPTBOH",
        [1146800212] = "CM_UPTPOR",
        [549978415] = "CM_UPTRIC",
        [1546450936] = "CM_UPTROH",
        [920595805] = "CM_UPTVIB",
        [793439294] = "CM_UPTWAN",
        [1750583735] = "CM_DOWSOU",
        [-1538846349] = "CM_DOWEL1",
        [891398354] = "CM_DOWDAD",
        [321657486] = "CM_DOWEL2",
        [-1007618204] = "CM_DOWSTM",
        [115168927] = "CM_DOWCOU",
        [951767867] = "CM_DOWCOU",
        [330231874] = "CM_DOWCO2",
        [1641152947] = "CM_DOWSTR",
        [744758650] = "CM_DOWSTR",
        [1674107025] = "CM_DOWEMO",
        [-173013091] = "CM_DOWEM2",
        [70821038] = "CM_DOWTEE",
        [153984193] = "CM_DOWCOL",
        [-88831029] = "CM_DOWSOC",
        [1519319503] = "CM_DOWDAV",
        [32417469] = "CM_VAGMIS",
        [-1332260293] = "CM_VAGMIS",
        [516505552] = "CM_VAGDO1",
        [-1935621530] = "CM_VAGDO1",
        [390939205] = "CM_VAGDO2",
        [1224306523] = "CM_VAGDO2",
        [1768677545] = "CM_VAGMET",
        [-681546704] = "CM_VAGSAN",
        [-569505431] = "CM_VAGSAN",
        [1001210244] = "CM_VAGME2",
        [1822107721] = "CM_VAGOLD",
        [2064532783] = "CM_VAGYOU",
        [1596003233] = "CM_VAGPR1",
        [-1313105063] = "CM_VAGPR2",
        [1077785853] = "CM_BEATOU",
        [-1859912896] = "CM_BEATOU",
        [2021631368] = "CM_BEALOA",
        [-2077764712] = "CM_BEAOLD",
        [-771835772] = "CM_BEAVES",
        [-945854168] = "CM_BEAVES",
        [600300561] = "CM_BEADEL",
        [808859815] = "CM_BEADEL",
        [-408329255] = "CM_BEASUN",
        [605602864] = "CM_BEABEA",
        [1264920838] = "CM_BEAMU1",
        [-920443780] = "CM_BEAMU2",
        [1004114196] = "CM_BEAMUS",
        [-1425378987] = "CM_SPOYOG",
        [-1004861906] = "CM_SPOYOG",
        [-356333586] = "CM_SPOSUR",
        [1767892582] = "CM_SPOSKA",
        [-640198516] = "CM_SPOSK1",
        [-1044093321] = "CM_SPOSK2",
        [-1342520604] = "CM_SPOSK3",
        [2114544056] = "CM_SPOSK4",
        [919005580] = "CM_SPOSK5",
        [623927022] = "CM_SPORU1",
        [-2076336881] = "CM_SPORU2",
        [-951490775] = "CM_SPORUN",
        [-37334073] = "CM_SPOCYC",
        [-178150202] = "CM_SPOROC",
        [1694362237] = "CM_SPOMO1",
        [2007797722] = "CM_SPOMO2",
        [1416254276] = "CM_SPOTEN",
        [1426880966] = "CM_SPOTEN",
        [-685776591] = "CM_SPOGO1",
        [-1444213182] = "CM_SPOGO2",
        [2111372120] = "CM_SPOGOF",
        [-1176698112] = "CM_GANTRB",
        [2119136831] = "CM_GANTG1",
        [-9308122] = "CM_GANTG2",
        [891945583] = "CM_GANKOB",
        [2093736314] = "CM_GANKOL",
        [611648169] = "CM_GANKOG",
        [1520708641] = "CM_GANCHO",
        [2010389054] = "CM_GANEPS1",
        [-1434255461] = "CM_GANEPS2",
        [1755064960] = "CM_GANEPSF",
        [1371553700] = "CM_GANSTR",
        [1466037421] = "CM_GANAZB",
        [1226102803] = "CM_GANVAB",
        [1752208920] = "CM_GANAZG",
        [-1773333796] = "CM_GANVAG",
        [-1872961334] = "CM_GANMGB",
        [663522487] = "CM_GANMGG",
        [846439045] = "CM_GANMGL",
        [-236444766] = "CM_GANMOB",
        [-39239064] = "CM_GANMOG",
        [-412008429] = "CM_GANMOL",
        [1330042375] = "CM_GANLOO",
        [1032073858] = "CM_GANLOM",
        [850468060] = "CM_GANLOS",
        [-44746786] = "CM_GANLOH",
        [-198252413] = "CM_GANBAE",
        [588969535] = "CM_GANBLO",
        [1746653202] = "CM_GANOGB",
        [599294057] = "CM_GANBAS",
        [-398748745] = "CM_GANCHA",
        [-613248456] = "CM_GANDAV",
        [-2077218039] = "CM_GANFOR",
        [-1244692252] = "CM_GANALT",
        [-2132435154] = "CM_GANAL1",
        [1430544400] = "CM_GANAL2",
        [1268862154] = "CM_GANAL3",
        [-407694286] = "CM_COSAST",
        [-1408326184] = "CM_COSSPY",
        [773063444] = "CM_COSCOR",
        [-598109171] = "CM_COSPOG",
        [1011059922] = "CM_COSSPA",
        [1684083350] = "CM_COSALI",
        [71929310] = "CM_COSCLO",
        [1021093698] = "CM_COSMIM",
        [2035992488] = "CM_COSSTR",
        [-163714847] = "CM_MILPL1",
        [-1422914553] = "CM_MILPL2",
        [-265970301] = "CM_MILMIG",
        [-220552467] = "CM_MILSRG",
        [1702441027] = "CM_MILCOR",
        [1490458366] = "CM_MILPRI",
        [1925237458] = "CM_MILBAT",
        [1657546978] = "CM_MILMIM",
        [-1275859404] = "CM_MILMEP",
        [2047212121] = "CM_MILMEC",
        [788443093] = "CM_MILMEL",
        [-1806291497] = "CM_LABFAR",
        [-317922106] = "CM_LABMIG",
        [-715445259] = "CM_LABMIG",
        [-673538407] = "CM_LABCN1",
        [-973145378] = "CM_LABCN2",
        [-1635724594] = "CM_LABCN3",
        [-294281201] = "CM_LABGAB",
        [1097048408] = "CM_LABFAC",
        [1777626099] = "CM_LABFAC",
        [1240094341] = "CM_LABGAR",
        [-1452549652] = "CM_LABJAN",
        [349680864] = "CM_LABSAD",
        [-2039072303] = "CM_LABDOC",
        [1142162924] = "CM_LABME1",
        [-1105135100] = "CM_LABME2",
        [1209091352] = "CM_LABBUG",
        [-1229853272] = "CM_EMEFIR",
        [1581098148] = "CM_EMEPOL",
        [368603149] = "CM_EMEPOL",
        [-306416314] = "CM_EMEFIB",
        [-1920001264] = "CM_EMENOO",
        [788443093] = "CM_EMEDOA",
        [1650288984] = "CM_EMEIAA",
        [1939545845] = "CM_EMEHIG",
        [-1286380898] = "CM_EMEPAR",
        [-905948951] = "CM_EMECOA",
        [-1614285257] = "CM_EMERAN",
        [189425762] = "CM_EMEBAY",
        [1250841910] = "CM_EMEBAY",
        [1096929346] = "CM_EMESHE",
        [-1782092083] = "CM_TRAAR1",
        [1669696074] = "CM_TRAAR2",
        [1644266841] = "CM_TRAAIR",
        [1650036788] = "CM_TRAPO1",
        [1936142927] = "CM_TRAPO2",
        [-1614577886] = "CM_TRAPO3",
        [-792862442] = "CM_TRAPO4",
        [1985653476] = "CM_TRATRA",
        [1498487404] = "CM_TRATRU",
        [-1692214353] = "CM_STOFRA",
        [-1686040670] = "CM_STOTRE",
        [225514697] = "CM_STOMIC",
        [1830688247] = "CM_STOAMA",
        [-1113448868] = "CM_STOBEV",
        [-1111799518] = "CM_STOBRA",
        [678319271] = "CM_STOCHR",
        [365775923] = "CM_STODAV",
        [1952555184] = "CM_STODEV",
        [-872673803] = "CM_STODRF",
        [-795819184] = "CM_STOFAB",
        [-1313761614] = "CM_STOFLO",
        [1459905209] = "CM_STOJIM",
        [1706635382] = "CM_STOLAM",
        [-538688539] = "CM_STOLAZ",
        [1302784073] = "CM_STOLES",
        [1005070462] = "CM_STOMAU",
        [503621995] = "CM_STOTHO",
        [-1124046095] = "CM_STONER",
        [-982642292] = "CM_STOPAT",
        [1283141381] = "CM_STOSIM",
        [-2034368986] = "CM_STOSOL",
        [941695432] = "CM_STOSTE",
        [915948376] = "CM_STOSTR",
        [226559113] = "CM_STOTAN",
        [-597926235] = "CM_STOTAO",
        [-566941131] = "CM_STOTRA",
        [-1835459726] = "CM_STOWAD",
        [-264140789] = "CM_SPEAND",
        [1380197501] = "CM_SPEBAY",
        [1189322339] = "CM_SPEBIL",
        [1191548746] = "CM_SPECLI",
        [-1001079621] = "CM_SPEGRI",
        [-1230338610] = "CM_SPEJAN",
        [469792763] = "CM_SPEJER",
        [-835930287] = "CM_SPEJES",
        [-927261102] = "CM_SPEMAN",
        [1021093698] = "CM_SPEMIM",
        [894928436] = "CM_SPEPAM",
        [880829941] = "CM_SPEIMP",
        [-1404353274] = "CM_SPEZOM",
        [193469166] = "CM_HSTGUS",
        [193469166] = "CM_HSTKAR",
        [193469166] = "CM_HSTPAC",
        [193469166] = "CM_HSTCHE",
        [193469166] = "CM_HSTHUG",
        [193469166] = "CM_HSTNOR",
        [193469166] = "CM_HSTDAR",
        [-1715797768] = "CM_HSTPAI",
        [-1715797768] = "CM_HSTCHR",
        [-1715797768] = "CM_HSTRIC",
        [994527967] = "CM_HSTEDD",
        [994527967] = "CM_HSTTAL",
        [994527967] = "CM_HSTKRM",
        [-832573324] = "CM_ANIBOAR",
        [1462895032] = "CM_ANICAT",
        [-50684386] = "CM_ANICOW",
        [1682622302] = "CM_ANICOY",
        [-664053099] = "CM_ANIDEE",
        [1318032802] = "CM_ANIHUS",
        [307287994] = "CM_ANIMOU",
        [-1323586730] = "CM_ANIPIG",
        [1125994524] = "CM_ANIPOO",
        [1832265812] = "CM_ANIPUG",
        [-541762431] = "CM_ANIRAB",
        [882848737] = "CM_ANIRET",
        [-1788665315] = "CM_ANIROT",
        [1126154828] = "CM_ANISHE",
        [-1384627013] = "CM_ANIWES",
        [-1430839454] = "CM_ANICHI",
        [1457690978] = "CM_ANICOR",
        [402729631] = "CM_ANICRO",
        [1794449327] = "CM_ANIHEN",
        [111281960] = "CM_ANIPGN",
        [-745300483] = "CM_ANISEA",
        [1641334641] = "HAIR_GROUP_E0",
    },
}


Vehicle_T = {
    -- `Enum` Vehicle 门锁状态
    DoorLockStatus = {
        [0] = "None",
        [1] = "Unlocked",
        [2] = "Locked",
        [3] = "Lockout Player Only",
        [4] = "Locked Player Inside",
        [5] = "Locked Initially",
        [6] = "Force Shut Doors",
        [7] = "Locked But Can Be Damaged",
        [8] = "Locked But Boot Unlocked",
        [9] = "Locked No Passengers",
        [10] = "Cannot Enter",
    },

    -- `ListItem` 载具电台
    RadioStation = {
        ListItem = {
            { 0, "关闭", {}, "" },
            { 1, "布莱恩郡之声", {}, "" },
            { 2, "蓝色方舟", {}, "" },
            { 3, "全球电台", {}, "" },
            { 4, "飞莲电台", {}, "" },
            { 5, "真相 91.1", {}, "" },
            { 6, "实验室", {}, "" },
            { 7, "明镜公园之音", {}, "" },
            { 8, "103.2 空间", {}, "" },
            { 9, "好麦坞大道电台", {}, "" },
            { 10, "金发洛圣都 97.8 电台", {}, "" },
            { 11, "洛圣都地下电台", {}, "" },
            { 12, "iFruit 电台", {}, "" },
            { 13, "自电台", {}, "" },
            { 14, "洛圣都摇滚台", {}, "" },
            { 15, "无止境流行乐电台", {}, "" },
            { 16, "洛圣都广播电台", {}, "" },
            { 17, "X 频道", {}, "" },
            { 18, "叛逆电台", {}, "" },
            { 19, "灵魂之蜡电台", {}, "" },
            { 20, "东洛电台", {}, "" },
            { 21, "西海岸经典", {}, "" },
            { 22, "MOTOMAMI 洛圣都", {}, "" },
            { 23, "西海岸谈话电台", {}, "" },
            { 24, "媒体播放器", {}, "" },
            { 25, "音乐柜", {}, "" },
            { 26, "库尔特 FM", {}, "" },
            { 27, "放松依旧洛圣都", {}, "" }
        },
        LabelList = {
            "OFF",
            "RADIO_11_TALK_02",               -- Blaine County Radio
            "RADIO_12_REGGAE",                -- The Blue Ark
            "RADIO_13_JAZZ",                  -- Worldwide FM
            "RADIO_14_DANCE_02",              -- FlyLo FM
            "RADIO_15_MOTOWN",                -- The Lowdown 9.11
            "RADIO_20_THELAB",                -- The Lab
            "RADIO_16_SILVERLAKE",            -- Radio Mirror Park
            "RADIO_17_FUNK",                  -- Space 103.2
            "RADIO_18_90S_ROCK",              -- Vinewood Boulevard Radio
            "RADIO_21_DLC_XM17",              -- Blonded Los Santos 97.8 FM
            "RADIO_22_DLC_BATTLE_MIX1_RADIO", -- Los Santos Underground Radio
            "RADIO_23_DLC_XM19_RADIO",        -- iFruit Radio
            "RADIO_19_USER",                  -- Self Radio
            "RADIO_01_CLASS_ROCK",            -- Los Santos Rock Radio
            "RADIO_02_POP",                   -- Non-Stop-Pop FM
            "RADIO_03_HIPHOP_NEW",            -- Radio Los Santos
            "RADIO_04_PUNK",                  -- Channel X
            "RADIO_06_COUNTRY",               -- Rebel Radio
            "RADIO_07_DANCE_01",              -- Soulwax FM
            "RADIO_08_MEXICAN",               -- East Los FM
            "RADIO_09_HIPHOP_OLD",            -- West Coast Classics
            "RADIO_37_MOTOMAMI",              -- MOTOMAMI Los Santos
            "RADIO_05_TALK_01",               -- West Coast Talk Radio
            "RADIO_36_AUDIOPLAYER",           -- Media Player
            "RADIO_35_DLC_HEI4_MLR",          -- The Music Locker
            "RADIO_34_DLC_HEI4_KULT",         -- Kult FM
            "RADIO_27_DLC_PRHEI4",            -- Still Slipping Los Santos
        },
    },

    -- `ListItem` 直升机模式
    HeliMode = {
        { 0,     "None",                              {}, "" },
        { 1,     "Attain Requested Orientation",      {}, "" },
        { 2,     "Dont Modify Orientation",           {}, "" },
        { 4,     "Dont Modify Pitch",                 {}, "" },
        { 8,     "Dont Modify Throttle",              {}, "" },
        { 16,    "Dont Modify Roll",                  {}, "" },
        { 32,    "Land On Arrival",                   {}, "" },
        { 64,    "Dont Do Avoidance",                 {}, "" },
        { 128,   "Start Engine Immediately",          {}, "" },
        { 256,   "Force Height Map Avoidance",        {}, "" },
        { 512,   "Dont Clamp Probes To Destination",  {}, "" },
        { 1024,  "Enable Timeslicing When Possible",  {}, "" },
        { 2048,  "Circle Opposite Direction",         {}, "" },
        { 4096,  "Maintain Height Above Terrain",     {}, "" },
        { 8192,  "Ignore Hidden Entities DuringLand", {}, "" },
        { 16384, "Disable AllHeight Map Avoidance",   {}, "" },
        { 320,   "Height Map Only Avoidance",         {}, "" }
    },

    -- `ListItem` 载具任务类型
    MissionType = {
        { 1, "Cruise", {}, "巡航" },
        { 2, "Ram", {}, "猛撞" },
        { 3, "Block", {}, "阻挡" },
        { 4, "Go To", {}, "前往" },
        { 5, "Stop", {}, "停止" },
        { 6, "Attack", {}, "攻击" },
        { 7, "Follow", {}, "跟随" },
        { 8, "Flee", {}, "逃跑" },
        { 9, "Circle", {}, "围绕" },
        { 10, "Escort Left", {}, "左边护送" },
        { 11, "Escort Right", {}, "右边护送" },
        { 12, "Escort Rear", {}, "后面护送" },
        { 13, "Escort Front", {}, "前面护送" },
        { 14, "Go To Racing", {}, "参加比赛？" },
        { 15, "Follow Recording", {}, "跟踪录制" },
        { 16, "Police Behaviour", {}, "警察行为" },
        { 17, "Park Perpendicular", {}, "垂直停车？" },
        { 18, "Park Parallel", {}, "并行停车" },
        { 19, "Land", {}, "降落" },
        { 20, "Land and Wait", {}, "降落并等待" },
        { 21, "Crash", {}, "碰撞" },
        { 22, "Pull Over", {}, "靠边停车" },
        { 23, "Protect", {}, "保护" }
    },
}


Blip_T = {
    -- `Enum` 标记点类型
    Type = {
        [0] = "Unused",
        [1] = "Vehicle",
        [2] = "Ped",
        [3] = "Object",
        [4] = "Coords",
        [5] = "Contact",
        [6] = "Pickup",
        [7] = "Radius",
        [8] = "Weapon Pickup",
        [9] = "Cop",
        [10] = "Stealth",
        [11] = "Area",
    },

    -- `ListItem` 标记点显示类型
    DisplayId = {
        { 0,  "Doesn't show up, ever, anywhere." },
        { 1,  "Doesn't show up, ever, anywhere." },
        { 2,  "Shows on both main map and minimap.", {}, "Selectable on map" },
        { 3,  "Shows on main map only.",             {}, "Selectable on map" },
        { 4,  "Shows on main map only.",             {}, "Selectable on map" },
        { 5,  "Shows on minimap only." },
        { 6,  "Shows on both main map and minimap.", {}, "Selectable on map" },
        { 7,  "Doesn't show up, ever, anywhere." },
        { 8,  "Shows on both main map and minimap.", {}, "Not selectable on map" },
        { 9,  "Shows on minimap only." },
        { 10, "Shows on both main map and minimap.", {}, "Not selectable on map" },
    },
}


Misc_T = {
    -- `ListItem` 实体类型
    EntityType = {
        { ENTITY_PED, "Ped", {}, "NPC" },
        { ENTITY_VEHICLE, "Vehicle", {}, "载具" },
        { ENTITY_OBJECT, "Object", {}, "物体" },
        { ENTITY_PICKUP, "Pickup", {}, "拾取物" }
    },

    -- `ListItem` 实体类型(All)
    EntityTypeAll = {
        { ENTITY_ALL, "All", {}, "全部类型实体" },
        { ENTITY_PED, "Ped", {}, "NPC" },
        { ENTITY_VEHICLE, "Vehicle", {}, "载具" },
        { ENTITY_OBJECT, "Object", {}, "物体" },
        { ENTITY_PICKUP, "Pickup", {}, "拾取物" }
    },

    -- `ListItem` NPC 类型
    PedType = {
        { 1, "全部NPC(排除友好)", {}, "" },
        { 2, "敌对NPC", {}, "" },
        { 3, "全部NPC", {}, "" }
    },

    -- `ListItem` 爆炸类型
    ExplosionType = {
        { -1, "Dont Care" },
        { 0,  "Grenade" },
        { 1,  "Grenade Launcher" },
        { 2,  "Sticky Bomb" },
        { 3,  "Molotov" },
        { 4,  "Rocket" },
        { 5,  "Tank Shell" },
        { 6,  "Hi Octane" },
        { 7,  "Car" },
        { 8,  "Plane" },
        { 9,  "Petrol Pump" },
        { 10, "Bike" },
        { 11, "Steam" },
        { 12, "Flame" },
        { 13, "Water Hydrant" },
        { 14, "Gas Canister Flame" },
        { 15, "Boat" },
        { 16, "Ship" },
        { 17, "Truck" },
        { 18, "Bullet" },
        { 19, "Smoke Grenade Launcher" },
        { 20, "Smoke Grenade" },
        { 21, "BZ Gas" },
        { 22, "Flare" },
        { 23, "Gas Canister" },
        { 24, "Extinguisher" },
        { 25, "Programmable AR" },
        { 26, "Train" },
        { 27, "Barrel (Blue)" },
        { 28, "Propane" },
        { 29, "Blimp" },
        { 30, "Flame Explode" },
        { 31, "Tanker" },
        { 32, "Plane Rocket" },
        { 33, "Vehicle Bullet" },
        { 34, "Gas Tank" },
        { 35, "Bird Crap" },
        { 36, "Railgun" },
        { 37, "Blimp (Red & Cyan)" },
        { 38, "Firework" },
        { 39, "Snowball" },
        { 40, "Proximity Mine" },
        { 41, "Valkyrie Cannon" },
        { 42, "Air Defence" },
        { 43, "Pipe Bomb" },
        { 44, "Vehicle Mine" },
        { 45, "Explosive Ammo" },
        { 46, "APC Shell" },
        { 47, "Cluster Bomb" },
        { 48, "Gas Bomb" },
        { 49, "Incendiary Bomb" },
        { 50, "Standard Bomb" },
        { 51, "Torpedo" },
        { 52, "Torpedo (Underwater)" },
        { 53, "Bombushka Cannon" },
        { 54, "Cluster Bomb 2" },
        { 55, "Hunter Barrage" },
        { 56, "Hunter Cannon" },
        { 57, "Rogue Cannon" },
        { 58, "Underwater Mine" },
        { 59, "Orbital Cannon" },
        { 60, "Standard Bomb (Wide)" },
        { 61, "Explosive Ammo (Shotgun)" },
        { 62, "Oppressor Mk2 Cannon" },
        { 63, "Kinetic Mortar" },
        { 64, "Kinetic Vehicle Mine" },
        { 65, "Emp Vehicle Mine" },
        { 66, "Spike Vehicle Mine" },
        { 67, "Slick Vehicle Mine" },
        { 68, "Tar Vehicle Mine" },
        { 69, "Script Drone" },
        { 70, "Raygun" },
        { 71, "Buried Mine" },
        { 72, "Script Missile" },
        { 73, "RC Tank Rocket" },
        { 74, "Water Bomb" },
        { 75, "Water Bomb 2" },
        { 76, "Cnc Spike Mine" },
        { 77, "BZ Gas Mk2" },
        { 78, "Flash Grenade" },
        { 79, "Stun Grenade" },
        { 80, "Cnc Kinetic Ram" },
        { 81, "Large Missile" },
        { 82, "Big Submarine" },
        { 83, "Emp Launcher" },
        { 84, "Railgun XM3" },
        { 85, "Balanced Cannons" }
    },


    GunVanPosition = {
        [0] = { -29.532, 6435.136, 31.162 },
        [1] = { 1705.214, 4819.167, 41.75 },
        [2] = { 1795.522, 3899.753, 33.869 },
        [3] = { 1335.536, 2758.746, 51.099 },
        [4] = { 795.583, 1210.78, 338.962 },
        [5] = { -3192.67, 1077.205, 20.594 },
        [6] = { -789.719, 5400.921, 33.915 },
        [7] = { -24.384, 3048.167, 40.703 },
        [8] = { 2666.786, 1469.324, 24.237 },
        [9] = { -1454.966, 2667.503, 3.2 },
        [10] = { 2340.418, 3054.188, 47.888 },
        [11] = { 1509.183, -2146.795, 76.853 },
        [12] = { 1137.404, -1358.654, 34.322 },
        [13] = { -57.208, -2658.793, 5.737 },
        [14] = { 1905.017, 565.222, 175.558 },
        [15] = { 974.484, -1718.798, 30.296 },
        [16] = { 779.077, -3266.297, 5.719 },
        [17] = { -587.728, -1637.208, 19.611 },
        [18] = { 733.99, -736.803, 26.165 },
        [19] = { -1694.632, -454.082, 40.712 },
        [20] = { -1330.726, -1163.948, 4.313 },
        [21] = { -496.618, 40.231, 52.316 },
        [22] = { 275.527, 66.509, 94.108 },
        [23] = { 260.928, -763.35, 30.559 },
        [24] = { -478.025, -741.45, 30.299 },
        [25] = { 894.94, 3603.911, 32.56 },
        [26] = { -2166.511, 4289.503, 48.733 },
        [27] = { 1465.633, 6553.67, 13.771 },
        [28] = { 1101.032, -335.172, 66.944 },
        [29] = { 149.683, -1655.674, 29.028 },
    },
    DeadDropCoords = {
        [0] = {
            [0] = { 1113.557, -645.957, 56.091 },
            [1] = { 1142.874, -662.951, 57.135 },
            [2] = { 1146.691, -703.717, 56.167 },
            [3] = { 1073.542, -678.236, 56.583 },
            [4] = { 1046.454, -722.915, 56.419 }
        },
        [1] = {
            [0] = { 2064.713, 3489.88, 44.223 },
            [1] = { 2081.859, 3553.254, 42.157 },
            [2] = { 2014.72, 3551.499, 42.726 },
            [3] = { 1997.019, 3507.838, 39.666 },
            [4] = { 2045.597, 3564.346, 39.343 }
        },
        [2] = {
            [0] = { -1317.344, -1481.97, 3.923 },
            [1] = { -1350.041, -1478.273, 4.567 },
            [2] = { -1393.87, -1445.139, 3.437 },
            [3] = { -1367.034, -1413.992, 2.611 },
            [4] = { -1269.861, -1426.272, 3.556 }
        },
        [3] = {
            [0] = { -295.468, 2787.385, 59.864 },
            [1] = { -284.69, 2848.234, 53.266 },
            [2] = { -329.193, 2803.404, 57.787 },
            [3] = { -306.847, 2825.6, 58.219 },
            [4] = { -336.046, 2829.988, 55.448 }
        },
        [4] = {
            [0] = { -1725.245, 233.946, 57.685 },
            [1] = { -1639.892, 225.521, 60.336 },
            [2] = { -1648.48, 212.049, 59.777 },
            [3] = { -1693.318, 156.665, 63.855 },
            [4] = { -1699.193, 179.574, 63.185 }
        },
        [5] = {
            [0] = { -949.714, -710.658, 19.604 },
            [1] = { -938.774, -781.817, 19.657 },
            [2] = { -884.91, -786.863, 15.043 },
            [3] = { -895.257, -729.943, 19.143 },
            [4] = { -932.986, -746.452, 19.008 }
        },
        [6] = {
            [0] = { -425.948, 1213.342, 324.936 },
            [1] = { -387.267, 1137.65, 321.704 },
            [2] = { -477.999, 1135.36, 320.123 },
            [3] = { -431.822, 1119.449, 325.964 },
            [4] = { -387.902, 1161.655, 324.529 }
        },
        [7] = {
            [0] = { -3381.278, 965.534, 7.426 },
            [1] = { -3427.724, 979.944, 7.526 },
            [2] = { -3413.606, 961.845, 11.038 },
            [3] = { -3419.585, 977.595, 11.167 },
            [4] = { -3425.687, 961.215, 7.536 }
        },
        [8] = {
            [0] = { -688.732, 5828.4, 16.696 },
            [1] = { -673.425, 5799.744, 16.467 },
            [2] = { -710.348, 5769.631, 16.75 },
            [3] = { -699.926, 5801.619, 16.504 },
            [4] = { -660.359, 5781.733, 18.774 }
        },
        [9] = {
            [0] = { 38.717, 6264.173, 32.88 },
            [1] = { 84.67, 6292.286, 30.731 },
            [2] = { 97.17, 6288.558, 38.447 },
            [3] = { 14.453, 6243.932, 35.445 },
            [4] = { 67.52, 6261.744, 32.029 }
        },
        [10] = {
            [0] = { 2954.598, 4671.458, 50.106 },
            [1] = { 2911.146, 4637.608, 49.3 },
            [2] = { 2945.212, 4624.044, 49.078 },
            [3] = { 2941.139, 4617.117, 52.114 },
            [4] = { 2895.884, 4686.396, 48.094 }
        },
        [11] = {
            [0] = { 1332.319, 4271.446, 30.646 },
            [1] = { 1353.332, 4387.911, 43.541 },
            [2] = { 1337.892, 4321.563, 38.093 },
            [3] = { 1386.603, 4366.511, 42.236 },
            [4] = { 1303.193, 4313.509, 36.939 }
        },
        [12] = {
            [0] = { 2720.03, 1572.762, 20.204 },
            [1] = { 2663.161, 1581.395, 24.418 },
            [2] = { 2658.245, 1643.373, 24.061 },
            [3] = { 2671.003, 1561.394, 23.882 },
            [4] = { 2660.104, 1606.54, 28.61 }
        },
        [13] = {
            [0] = { 211.775, -934.269, 23.466 },
            [1] = { 198.265, -884.039, 30.696 },
            [2] = { 189.542, -919.726, 29.96 },
            [3] = { 169.504, -934.841, 29.228 },
            [4] = { 212.376, -934.807, 29.007 }
        },
        [14] = {
            [0] = { 1330.113, -2520.754, 46.365 },
            [1] = { 1328.954, -2538.302, 46.976 },
            [2] = { 1237.506, -2572.335, 39.791 },
            [3] = { 1244.602, -2563.721, 42.646 },
            [4] = { 1278.421, -2565.117, 43.544 }
        }
    },
}


Weapon_T = {
    -- `ListItem` 全部武器
    AllWeapons = {
        { 0, "无", { "none" }, "", "" }
    },

    -- `ListItem` 全部武器（无近战武器）
    AllWeaponsWithoutMelee = {},

    -- `Enum` 全部武器名称
    WeaponNameList = {},
}

for key, item in pairs(util.get_weapons()) do
    local menu_name = util.get_label_text(item.label_key)
    local command_names = string.gsub(util.reverse_joaat(item.hash), "weapon_", "")
    command_names = string.gsub(command_names, "_", "")

    local list_item = { item.hash, menu_name, { command_names }, "", item.category }

    table.insert(Weapon_T.AllWeapons, list_item)

    if item.category_id ~= 0 then
        table.insert(Weapon_T.AllWeaponsWithoutMelee, list_item)
    end

    Weapon_T.WeaponNameList[item.hash] = menu_name
end


PackedStats = {
    DAILYCOLLECT_DEAD_DROP_LOCATION_0 = 41213,
    DAILYCOLLECT_DEAD_DROP_AREA_0 = 41214,
}
