---颜色 [0 - 1]格式
Colors = {
    white = { r = 1.0, g = 1.0, b = 1.0, a = 1.0 },
    black = { r = 0.0, g = 0.0, b = 0.0, a = 1.0 },

    red = { r = 1.0, g = 0.0, b = 0.0, a = 1.0 },
    green = { r = 0.0, g = 1.0, b = 0.0, a = 1.0 },
    blue = { r = 0.0, g = 0.0, b = 1.0, a = 1.0 },

    purple = { r = 1.0, g = 0.0, b = 1.0, a = 1.0 },
}

-- 常用武器
Weapon_Common = {
    ListItem = {
        { "小刀" },
        { "穿甲手枪" },
        { "电击枪" },
        { "微型冲锋枪" },
        { "特质卡宾步枪" },
        { "突击霰弹枪" },
        { "火神机枪" },
        { "火箭筒" },
        { "电磁步枪" },
    },
    ModelList = {
        "WEAPON_KNIFE",
        "WEAPON_APPISTOL",
        "WEAPON_STUNGUN",
        "WEAPON_MICROSMG",
        "WEAPON_SPECIALCARBINE",
        "WEAPON_ASSAULTSHOTGUN",
        "WEAPON_MINIGUN",
        "WEAPON_RPG",
        "WEAPON_RAILGUN",
    }
}

-- 常用载具
Vehicle_Common = {
    { model = "police3",    name = "警车",                help_text = "" },
    { model = "khanjali",   name = "坦克",                help_text = "" },
    { model = "kuruma2",    name = "骷髅马",             help_text = "" },
    { model = "polmav",     name = "警用直升机",       help_text = "" },
    { model = "bullet",     name = "子弹",                help_text = "大街上随处可见的超级跑车" },
    { model = "bati",       name = "801巴提",             help_text = "" },
    { model = "oppressor2", name = "暴君MK2",             help_text = "" },
    { model = "buzzard",    name = "秃鹰攻击直升机", help_text = "" },
}

-- 实体类型
EntityType_ListItem = {
    { "Ped",     {}, "NPC" },
    { "Vehicle", {}, "载具" },
    { "Object",  {}, "物体" },
    { "Pickup",  {}, "拾取物" }
}


------------ enum ------------

-- Ped 类型
enum_PedType = {
    [0] = "PLAYER_0",
    [1] = "PLAYER_1",
    [2] = "NETWORK_PLAYER",
    [3] = "PLAYER_2",
    [4] = "CIVMALE",
    [5] = "CIVFEMALE",
    [6] = "COP",
    [7] = "GANG_ALBANIAN",
    [8] = "GANG_BIKER_1",
    [9] = "GANG_BIKER_2",
    [10] = "GANG_ITALIAN",
    [11] = "GANG_RUSSIAN",
    [12] = "GANG_RUSSIAN_2",
    [13] = "GANG_IRISH",
    [14] = "GANG_JAMAICAN",
    [15] = "GANG_AFRICAN_AMERICAN",
    [16] = "GANG_KOREAN",
    [17] = "GANG_CHINESE_JAPANESE",
    [18] = "GANG_PUERTO_RICAN",
    [19] = "DEALER",
    [20] = "MEDIC",
    [21] = "FIREMAN",
    [22] = "CRIMINAL",
    [23] = "BUM",
    [24] = "PROSTITUTE",
    [25] = "SPECIAL",
    [26] = "MISSION",
    [27] = "SWAT",
    [28] = "ANIMAL",
    [29] = "ARMY",
}

-- Ped 作战移动方式
enum_CombatMovement = {
    [0] = "Stationary",
    [1] = "Defensive",
    [2] = "Will Advance",
    [3] = "Will Retreat",
}

-- Ped 作战能力
enum_CombatAbility = {
    [0] = "Poor",
    [1] = "Average",
    [2] = "Professional",
}

-- Ped 作战范围
enum_CombatRange = {
    [0] = "Near",
    [1] = "Medium",
    [2] = "Far",
    [3] = "Very Far",
}

-- Ped 警觉度
enum_Alertness = {
    [0] = "Not Alert",         -- Ped hasn't received any events recently
    [1] = "Alert",             -- Ped has received at least one event
    [2] = "Very Alert",        -- Ped has received multiple events
    [3] = "Must Go To Combat", -- This value basically means the ped should be in combat but isn't because he's not allowed to investigate etc
}

-- Ped 之间的关系类型
enum_RelationshipType = {
    [0] = "Respect",
    [1] = "Like",
    [2] = "Ignore",
    [3] = "Dislike",
    [4] = "Wanted",
    [5] = "Hate",
    [6] = "Dead",
    [255] = "None",
}

-- 载具 门锁状态
enum_VehicleLockStatus = {
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
}

-- 标记点类型
enum_BlipType = {
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
}

-- 语言类型
enum_LanguageType = {
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
}


------------ list item ------------

-- 载具电台
Vehicle_RadioStation = {
    ListItem = {
        { "关闭",                      {}, "" },
        { "布莱恩郡之声",          {}, "" },
        { "蓝色方舟",                {}, "" },
        { "全球电台",                {}, "" },
        { "飞莲电台",                {}, "" },
        { "真相 91.1",                 {}, "" },
        { "实验室",                   {}, "" },
        { "明镜公园之音",          {}, "" },
        { "103.2 空间",                {}, "" },
        { "好麦坞大道电台",       {}, "" },
        { "金发洛圣都 97.8 电台", {}, "" },
        { "洛圣都地下电台",       {}, "" },
        { "iFruit 电台",               {}, "" },
        { "自电台",                   {}, "" },
        { "洛圣都摇滚台",          {}, "" },
        { "无止境流行乐电台",    {}, "" },
        { "洛圣都广播电台",       {}, "" },
        { "X 频道",                    {}, "" },
        { "叛逆电台",                {}, "" },
        { "灵魂之蜡电台",          {}, "" },
        { "东洛电台",                {}, "" },
        { "西海岸经典",             {}, "" },
        { "MOTOMAMI 洛圣都",          {}, "" },
        { "西海岸谈话电台",       {}, "" },
        { "媒体播放器",             {}, "" },
        { "音乐柜",                   {}, "" },
        { "库尔特 FM",                {}, "" },
        { "放松依旧洛圣都",       {}, "" },
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
}

-- 载具驾驶风格(NPC)
Vehicle_DrivingStyle = {
    ListItem = {
        { "正常" },
        { "半冲刺" },
        { "反向" },
        { "无视红绿灯" },
        { "避开交通" },
        { "极度避开交通" },
        { "有时超车" },
        { "受到惊吓" },
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
}

-- 直升机模式
Vehicle_HeliMode = {
    ListItem = {
        { "None",                              {}, "" },
        { "Attain Requested Orientation",      {}, "" },
        { "Dont Modify Orientation",           {}, "" },
        { "Dont Modify Pitch",                 {}, "" },
        { "Dont Modify Throttle",              {}, "" },
        { "Dont Modify Roll",                  {}, "" },
        { "Land On Arrival",                   {}, "" },
        { "Dont Do Avoidance",                 {}, "" },
        { "Start Engine Immediately",          {}, "" },
        { "Force Height Map Avoidance",        {}, "" },
        { "Dont Clamp Probes To Destination",  {}, "" },
        { "Enable Timeslicing When Possible",  {}, "" },
        { "Circle Opposite Direction",         {}, "" },
        { "Maintain Height Above Terrain",     {}, "" },
        { "Ignore Hidden Entities DuringLand", {}, "" },
        { "Disable AllHeight Map Avoidance",   {}, "" },
        { "Height Map Only Avoidance",         {}, "" },
    },
    ValueList = {
        0,
        1,
        2,
        4,
        8,
        16,
        32,
        64,
        128,
        256,
        512,
        1024,
        2048,
        4096,
        8192,
        16384,
        320,
    }
}

-- 载具任务类型
Vehicle_MissionType = {
    ListItem = {
        { "Cruise",             {}, "巡航" },
        { "Ram",                {}, "猛撞" },
        { "Block",              {}, "阻挡" },
        { "Go To",              {}, "前往" },
        { "Stop",               {}, "停止" },
        { "Attack",             {}, "攻击" },
        { "Follow",             {}, "跟随" },
        { "Flee",               {}, "逃跑" },
        { "Circle",             {}, "围绕" },
        { "Escort Left",        {}, "左边护送" },
        { "Escort Right",       {}, "右边护送" },
        { "Escort Rear",        {}, "后面护送" },
        { "Escort Front",       {}, "前面护送" },
        { "Go To Racing",       {}, "参加比赛？" },
        { "Follow Recording",   {}, "跟踪录制" },
        { "Police Behaviour",   {}, "警察行为" },
        { "Park Perpendicular", {}, "垂直停车？" },
        { "Park Parallel",      {}, "并行停车" },
        { "Land",               {}, "降落" },
        { "Land and Wait",      {}, "降落并等待" },
        { "Crash",              {}, "碰撞" },
        { "Pull Over",          {}, "靠边停车" },
        { "Protect",            {}, "保护" },
    },
    ValueList = {
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23,
    }
}


-- NPC射击模式
Ped_FirePattern = {
    ListItem = {
        { "Burst Fire" },
        { "Burst Fire In Cover" },
        { "Burst Fire Driveby" },
        { "From Ground" },
        { "Delay Fire By One Sec" },
        { "Full Auto" },
        { "Single Shot" },
        { "Burst Fire Pistol" },
        { "Burst Fire Smg" },
        { "Burst Fire Rifle" },
        { "Burst Fire Mg" },
        { "Burst Fire Pumpshotgun" },
        { "Burst Fire Heli" },
        { "Burst Fire Micro" },
        { "Short Bursts" },
        { "Slow Fire Tank" },
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
}

-- NPC作战属性
Ped_CombatAttributes = {
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
        { "Permit Charge Beyond Defensive Area",           "Permits ped to charge a target outside the assigned defensive area." },
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
        0, 1, 2, 3, 4, 5, 6, 7, 9, 11, 12, 13, 14, 15, 17, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 34, 35, 36,
        37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 62, 64, 65, 66,
        67, 68, 69, 70, 71, 72, 73, 74, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90,
    },
}

-- NPC作战数值
Ped_CombatFloat = {
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
}




-- blip color
Blip_Color_Red = {
    1,  -- BLIP_COLOUR_RED
    49, -- BLIP_COLOUR_FRIENDLY
    59, -- BLIP_COLOUR_HUDCOLOUR_RED
    75,
    79,
}

-- all blip  blipName = blipSprite + 1
All_Blips = {
    "radar_higher",                      -- 0
    "radar_level",                       -- 1
    "radar_lower",                       -- 2
    "radar_police_ped",                  -- 3
    "radar_wanted_radius",               -- 4
    "radar_area_blip",                   -- 5
    "radar_centre",                      -- 6
    "radar_north",                       -- 7
    "radar_waypoint",                    -- 8
    "radar_radius_blip",                 -- 9
    "radar_radius_outline_blip",         -- 10
    "radar_weapon_higher",               -- 11
    "radar_weapon_lower",                -- 12
    "radar_higher_ai",                   -- 13
    "radar_lower_ai",                    -- 14
    "radar_police_heli_spin",            -- 15
    "radar_police_plane_move",           -- 16
    "radar_numbered_1",                  -- 17
    "radar_numbered_2",                  -- 18
    "radar_numbered_3",                  -- 19
    "radar_numbered_4",                  -- 20
    "radar_numbered_5",                  -- 21
    "radar_numbered_6",                  -- 22
    "radar_numbered_7",                  -- 23
    "radar_numbered_8",                  -- 24
    "radar_numbered_9",                  -- 25
    "radar_numbered_10",                 -- 26
    "radar_mp_crew",                     -- 27
    "radar_mp_friendlies",               -- 28
    "radar_empty",                       -- 29
    "radar_empty",                       -- 30
    "radar_empty",                       -- 31
    "radar_script_objective",            -- 32
    "radar_empty",                       -- 33
    "radar_empty",                       -- 34
    "radar_station",                     -- 35
    "radar_cable_car",                   -- 36
    "radar_activities",                  -- 37
    "radar_raceflag",                    -- 38
    "radar_fire",                        -- 39
    "radar_safehouse",                   -- 40
    "radar_police",                      -- 41
    "radar_police_chase",                -- 42
    "radar_police_heli",                 -- 43
    "radar_bomb_a",                      -- 44
    "radar_bomb_b",                      -- 45
    "radar_bomb_c",                      -- 46
    "radar_snitch",                      -- 47
    "radar_planning_locations",          -- 48
    "radar_crim_arrest",                 -- 49
    "radar_crim_carsteal",               -- 50
    "radar_crim_drugs",                  -- 51
    "radar_crim_holdups",                -- 52
    "radar_crim_pimping",                -- 53
    "radar_crim_player",                 -- 54
    "radar_fence",                       -- 55
    "radar_cop_patrol",                  -- 56
    "radar_cop_player",                  -- 57
    "radar_crim_wanted",                 -- 58
    "radar_heist",                       -- 59
    "radar_police_station",              -- 60
    "radar_hospital",                    -- 61
    "radar_assassins_mark",              -- 62
    "radar_elevator",                    -- 63
    "radar_helicopter",                  -- 64
    "radar_joyriders",                   -- 65
    "radar_random_character",            -- 66
    "radar_security_van",                -- 67
    "radar_tow_truck",                   -- 68
    "radar_drive_thru",                  -- 69
    "radar_illegal_parking",             -- 70
    "radar_barber",                      -- 71
    "radar_car_mod_shop",                -- 72
    "radar_clothes_store",               -- 73
    "radar_gym",                         -- 74
    "radar_tattoo",                      -- 75
    "radar_armenian_family",             -- 76
    "radar_lester_family",               -- 77
    "radar_michael_family",              -- 78
    "radar_trevor_family",               -- 79
    "radar_jewelry_heist",               -- 80
    "radar_drag_race",                   -- 81
    "radar_drag_race_finish",            -- 82
    "radar_car_carrier",                 -- 83
    "radar_rampage",                     -- 84
    "radar_vinewood_tours",              -- 85
    "radar_lamar_family",                -- 86
    "radar_taco_van",                    -- 87
    "radar_franklin_family",             -- 88
    "radar_chinese_strand",              -- 89
    "radar_flight_school",               -- 90
    "radar_eye_sky",                     -- 91
    "radar_air_hockey",                  -- 92
    "radar_bar",                         -- 93
    "radar_base_jump",                   -- 94
    "radar_basketball",                  -- 95
    "radar_biolab_heist",                -- 96
    "radar_bowling",                     -- 97
    "radar_burger_shot",                 -- 98
    "radar_cabaret_club",                -- 99
    "radar_car_wash",                    -- 100
    "radar_cluckin_bell",                -- 101
    "radar_comedy_club",                 -- 102
    "radar_darts",                       -- 103
    "radar_docks_heist",                 -- 104
    "radar_fbi_heist",                   -- 105
    "radar_fbi_officers_strand",         -- 106
    "radar_finale_bank_heist",           -- 107
    "radar_financier_strand",            -- 108
    "radar_golf",                        -- 109
    "radar_gun_shop",                    -- 110
    "radar_internet_cafe",               -- 111
    "radar_michael_family_exile",        -- 112
    "radar_nice_house_heist",            -- 113
    "radar_random_female",               -- 114
    "radar_random_male",                 -- 115
    "radar_repo",                        -- 116
    "radar_restaurant",                  -- 117
    "radar_rural_bank_heist",            -- 118
    "radar_shooting_range",              -- 119
    "radar_solomon_strand",              -- 120
    "radar_strip_club",                  -- 121
    "radar_tennis",                      -- 122
    "radar_trevor_family_exile",         -- 123
    "radar_michael_trevor_family",       -- 124
    "radar_vehicle_spawn",               -- 125
    "radar_triathlon",                   -- 126
    "radar_off_road_racing",             -- 127
    "radar_gang_cops",                   -- 128
    "radar_gang_mexicans",               -- 129
    "radar_gang_bikers",                 -- 130
    "radar_gang_families",               -- 131
    "radar_gang_professionals",          -- 132
    "radar_snitch_red",                  -- 133
    "radar_crim_cuff_keys",              -- 134
    "radar_cinema",                      -- 135
    "radar_music_venue",                 -- 136
    "radar_police_station_blue",         -- 137
    "radar_airport",                     -- 138
    "radar_crim_saved_vehicle",          -- 139
    "radar_weed_stash",                  -- 140
    "radar_hunting",                     -- 141
    "radar_pool",                        -- 142
    "radar_objective_blue",              -- 143
    "radar_objective_green",             -- 144
    "radar_objective_red",               -- 145
    "radar_objective_yellow",            -- 146
    "radar_arms_dealing",                -- 147
    "radar_mp_friend",                   -- 148
    "radar_celebrity_theft",             -- 149
    "radar_weapon_assault_rifle",        -- 150
    "radar_weapon_bat",                  -- 151
    "radar_weapon_grenade",              -- 152
    "radar_weapon_health",               -- 153
    "radar_weapon_knife",                -- 154
    "radar_weapon_molotov",              -- 155
    "radar_weapon_pistol",               -- 156
    "radar_weapon_rocket",               -- 157
    "radar_weapon_shotgun",              -- 158
    "radar_weapon_smg",                  -- 159
    "radar_weapon_sniper",               -- 160
    "radar_mp_noise",                    -- 161
    "radar_poi",                         -- 162
    "radar_passive",                     -- 163
    "radar_usingmenu",                   -- 164
    "radar_friend_franklin_p",           -- 165
    "radar_friend_franklin_x",           -- 166
    "radar_friend_michael_p",            -- 167
    "radar_friend_michael_x",            -- 168
    "radar_friend_trevor_p",             -- 169
    "radar_friend_trevor_x",             -- 170
    "radar_gang_cops_partner",           -- 171
    "radar_friend_lamar",                -- 172
    "radar_weapon_minigun",              -- 173
    "radar_weapon_grenadeLauncher",      -- 174
    "radar_weapon_armour",               -- 175
    "radar_property_takeover",           -- 176
    "radar_gang_mexicans_highlight",     -- 177
    "radar_gang_bikers_highlight",       -- 178
    "radar_triathlon_cycling",           -- 179
    "radar_triathlon_swimming",          -- 180
    "radar_property_takeover_bikers",    -- 181
    "radar_property_takeover_cops",      -- 182
    "radar_property_takeover_vagos",     -- 183
    "radar_camera",                      -- 184
    "radar_centre_red",                  -- 185
    "radar_handcuff_keys_bikers",        -- 186
    "radar_handcuff_keys_vagos",         -- 187
    "radar_handcuffs_closed_bikers",     -- 188
    "radar_handcuffs_closed_vagos",      -- 189
    "radar_handcuffs_open_bikers",       -- 190
    "radar_handcuffs_open_vagos",        -- 191
    "radar_camera_badger",               -- 192
    "radar_camera_facade",               -- 193
    "radar_camera_ifruit",               -- 194
    "radar_crim_arrest_bikers",          -- 195
    "radar_crim_arrest_vagos",           -- 196
    "radar_yoga",                        -- 197
    "radar_taxi",                        -- 198
    "radar_numbered_11",                 -- 199
    "radar_numbered_12",                 -- 200
    "radar_numbered_13",                 -- 201
    "radar_numbered_14",                 -- 202
    "radar_numbered_15",                 -- 203
    "radar_numbered_16",                 -- 204
    "radar_shrink",                      -- 205
    "radar_epsilon",                     -- 206
    "radar_financier_strand_grey",       -- 207
    "radar_trevor_family_grey",          -- 208
    "radar_trevor_family_red",           -- 209
    "radar_franklin_family_grey",        -- 210
    "radar_franklin_family_blue",        -- 211
    "radar_franklin_a",                  -- 212
    "radar_franklin_b",                  -- 213
    "radar_franklin_c",                  -- 214
    "radar_numbered_red_1",              -- 215
    "radar_numbered_red_2",              -- 216
    "radar_numbered_red_3",              -- 217
    "radar_numbered_red_4",              -- 218
    "radar_numbered_red_5",              -- 219
    "radar_numbered_red_6",              -- 220
    "radar_numbered_red_7",              -- 221
    "radar_numbered_red_8",              -- 222
    "radar_numbered_red_9",              -- 223
    "radar_numbered_red_10",             -- 224
    "radar_gang_vehicle",                -- 225
    "radar_gang_vehicle_bikers",         -- 226
    "radar_gang_vehicle_cops",           -- 227
    "radar_gang_vehicle_vagos",          -- 228
    "radar_guncar",                      -- 229
    "radar_driving_bikers",              -- 230
    "radar_driving_cops",                -- 231
    "radar_driving_vagos",               -- 232
    "radar_gang_cops_highlight",         -- 233
    "radar_shield_bikers",               -- 234
    "radar_shield_cops",                 -- 235
    "radar_shield_vagos",                -- 236
    "radar_custody_bikers",              -- 237
    "radar_custody_vagos",               -- 238
    "radar_gang_wanted_bikers",          -- 239
    "radar_gang_wanted_bikers_1",        -- 240
    "radar_gang_wanted_bikers_2",        -- 241
    "radar_gang_wanted_bikers_3",        -- 242
    "radar_gang_wanted_bikers_4",        -- 243
    "radar_gang_wanted_bikers_5",        -- 244
    "radar_gang_wanted_vagos",           -- 245
    "radar_gang_wanted_vagos_1",         -- 246
    "radar_gang_wanted_vagos_2",         -- 247
    "radar_gang_wanted_vagos_3",         -- 248
    "radar_gang_wanted_vagos_4",         -- 249
    "radar_gang_wanted_vagos_5",         -- 250
    "radar_arms_dealing_air",            -- 251
    "radar_playerstate_arrested",        -- 252
    "radar_playerstate_custody",         -- 253
    "radar_playerstate_driving",         -- 254
    "radar_playerstate_keyholder",       -- 255
    "radar_playerstate_partner",         -- 256
    "radar_gang_wanted_1",               -- 257
    "radar_gang_wanted_2",               -- 258
    "radar_gang_wanted_3",               -- 259
    "radar_gang_wanted_4",               -- 260
    "radar_gang_wanted_5",               -- 261
    "radar_ztype",                       -- 262
    "radar_stinger",                     -- 263
    "radar_packer",                      -- 264
    "radar_monroe",                      -- 265
    "radar_fairground",                  -- 266
    "radar_property",                    -- 267
    "radar_gang_highlight",              -- 268
    "radar_altruist",                    -- 269
    "radar_ai",                          -- 270
    "radar_on_mission",                  -- 271
    "radar_cash_pickup",                 -- 272
    "radar_chop",                        -- 273
    "radar_dead",                        -- 274
    "radar_territory_locked",            -- 275
    "radar_cash_lost",                   -- 276
    "radar_cash_vagos",                  -- 277
    "radar_cash_cops",                   -- 278
    "radar_hooker",                      -- 279
    "radar_friend",                      -- 280
    "radar_mission_2to4",                -- 281
    "radar_mission_2to8",                -- 282
    "radar_mission_2to12",               -- 283
    "radar_mission_2to16",               -- 284
    "radar_custody_dropoff",             -- 285
    "radar_onmission_cops",              -- 286
    "radar_onmission_lost",              -- 287
    "radar_onmission_vagos",             -- 288
    "radar_crim_carsteal_cops",          -- 289
    "radar_crim_carsteal_bikers",        -- 290
    "radar_crim_carsteal_vagos",         -- 291
    "radar_band_strand",                 -- 292
    "radar_simeon_family",               -- 293
    "radar_mission_1",                   -- 294
    "radar_mission_2",                   -- 295
    "radar_friend_darts",                -- 296
    "radar_friend_comedyclub",           -- 297
    "radar_friend_cinema",               -- 298
    "radar_friend_tennis",               -- 299
    "radar_friend_stripclub",            -- 300
    "radar_friend_livemusic",            -- 301
    "radar_friend_golf",                 -- 302
    "radar_bounty_hit",                  -- 303
    "radar_ugc_mission",                 -- 304
    "radar_horde",                       -- 305
    "radar_cratedrop",                   -- 306
    "radar_plane_drop",                  -- 307
    "radar_sub",                         -- 308
    "radar_race",                        -- 309
    "radar_deathmatch",                  -- 310
    "radar_arm_wrestling",               -- 311
    "radar_mission_1to2",                -- 312
    "radar_shootingrange_gunshop",       -- 313
    "radar_race_air",                    -- 314
    "radar_race_land",                   -- 315
    "radar_race_sea",                    -- 316
    "radar_tow",                         -- 317
    "radar_garbage",                     -- 318
    "radar_drill",                       -- 319
    "radar_spikes",                      -- 320
    "radar_firetruck",                   -- 321
    "radar_minigun2",                    -- 322
    "radar_bugstar",                     -- 323
    "radar_submarine",                   -- 324
    "radar_chinook",                     -- 325
    "radar_getaway_car",                 -- 326
    "radar_mission_bikers_1",            -- 327
    "radar_mission_bikers_1to2",         -- 328
    "radar_mission_bikers_2",            -- 329
    "radar_mission_bikers_2to4",         -- 330
    "radar_mission_bikers_2to8",         -- 331
    "radar_mission_bikers_2to12",        -- 332
    "radar_mission_bikers_2to16",        -- 333
    "radar_mission_cops_1",              -- 334
    "radar_mission_cops_1to2",           -- 335
    "radar_mission_cops_2",              -- 336
    "radar_mission_cops_2to4",           -- 337
    "radar_mission_cops_2to8",           -- 338
    "radar_mission_cops_2to12",          -- 339
    "radar_mission_cops_2to16",          -- 340
    "radar_mission_vagos_1",             -- 341
    "radar_mission_vagos_1to2",          -- 342
    "radar_mission_vagos_2",             -- 343
    "radar_mission_vagos_2to4",          -- 344
    "radar_mission_vagos_2to8",          -- 345
    "radar_mission_vagos_2to12",         -- 346
    "radar_mission_vagos_2to16",         -- 347
    "radar_gang_bike",                   -- 348
    "radar_gas_grenade",                 -- 349
    "radar_property_for_sale",           -- 350
    "radar_gang_attack_package",         -- 351
    "radar_martin_madrazzo",             -- 352
    "radar_enemy_heli_spin",             -- 353
    "radar_boost",                       -- 354
    "radar_devin",                       -- 355
    "radar_dock",                        -- 356
    "radar_garage",                      -- 357
    "radar_golf_flag",                   -- 358
    "radar_hangar",                      -- 359
    "radar_helipad",                     -- 360
    "radar_jerry_can",                   -- 361
    "radar_mask",                        -- 362
    "radar_heist_prep",                  -- 363
    "radar_incapacitated",               -- 364
    "radar_spawn_point_pickup",          -- 365
    "radar_boilersuit",                  -- 366
    "radar_completed",                   -- 367
    "radar_rockets",                     -- 368
    "radar_garage_for_sale",             -- 369
    "radar_helipad_for_sale",            -- 370
    "radar_dock_for_sale",               -- 371
    "radar_hangar_for_sale",             -- 372
    "radar_placeholder_6",               -- 373
    "radar_business",                    -- 374
    "radar_business_for_sale",           -- 375
    "radar_race_bike",                   -- 376
    "radar_parachute",                   -- 377
    "radar_team_deathmatch",             -- 378
    "radar_race_foot",                   -- 379
    "radar_vehicle_deathmatch",          -- 380
    "radar_barry",                       -- 381
    "radar_dom",                         -- 382
    "radar_maryann",                     -- 383
    "radar_cletus",                      -- 384
    "radar_josh",                        -- 385
    "radar_minute",                      -- 386
    "radar_omega",                       -- 387
    "radar_tonya",                       -- 388
    "radar_paparazzo",                   -- 389
    "radar_aim",                         -- 390
    "radar_cratedrop_background",        -- 391
    "radar_green_and_net_player1",       -- 392
    "radar_green_and_net_player2",       -- 393
    "radar_green_and_net_player3",       -- 394
    "radar_green_and_friendly",          -- 395
    "radar_net_player1_and_net_player2", -- 396
    "radar_net_player1_and_net_player3", -- 397
    "radar_creator",                     -- 398
    "radar_creator_direction",           -- 399
    "radar_abigail",                     -- 400
    "radar_blimp",                       -- 401
    "radar_repair",                      -- 402
    "radar_testosterone",                -- 403
    "radar_dinghy",                      -- 404
    "radar_fanatic",                     -- 405
    "radar_invisible",                   -- 406
    "radar_info_icon",                   -- 407
    "radar_capture_the_flag",            -- 408
    "radar_last_team_standing",          -- 409
    "radar_boat",                        -- 410
    "radar_capture_the_flag_base",       -- 411
    "radar_mp_crew",                     -- 412
    "radar_capture_the_flag_outline",    -- 413
    "radar_capture_the_flag_base_nobag", -- 414
    "radar_weapon_jerrycan",             -- 415
    "radar_rp",                          -- 416
    "radar_level_inside",                -- 417
    "radar_bounty_hit_inside",           -- 418
    "radar_capture_the_usaflag",         -- 419
    "radar_capture_the_usaflag_outline", -- 420
    "radar_tank",                        -- 421
    "radar_player_heli",                 -- 422
    "radar_player_plane",                -- 423
    "radar_player_jet",                  -- 424
    "radar_centre_stroke",               -- 425
    "radar_player_guncar",               -- 426
    "radar_player_boat",                 -- 427
    "radar_mp_heist",                    -- 428
    "radar_temp_1",                      -- 429
    "radar_temp_2",                      -- 430
    "radar_temp_3",                      -- 431
    "radar_temp_4",                      -- 432
    "radar_temp_5",                      -- 433
    "radar_temp_6",                      -- 434
    "radar_race_stunt",                  -- 435
    "radar_hot_property",                -- 436
    "radar_urbanwarfare_versus",         -- 437
    "radar_king_of_the_castle",          -- 438
    "radar_player_king",                 -- 439
    "radar_dead_drop",                   -- 440
    "radar_penned_in",                   -- 441
    "radar_beast",                       -- 442
    "radar_edge_pointer",                -- 443
    "radar_edge_crosstheline",           -- 444
    "radar_mp_lamar",                    -- 445
    "radar_bennys",                      -- 446
    "radar_corner_number_1",             -- 447
    "radar_corner_number_2",             -- 448
    "radar_corner_number_3",             -- 449
    "radar_corner_number_4",             -- 450
    "radar_corner_number_5",             -- 451
    "radar_corner_number_6",             -- 452
    "radar_corner_number_7",             -- 453
    "radar_corner_number_8",             -- 454
    "radar_yacht",                       -- 455
    "radar_finders_keepers",             -- 456
    "radar_assault_package",             -- 457
    "radar_hunt_the_boss",               -- 458
    "radar_sightseer",                   -- 459
    "radar_turreted_limo",               -- 460
    "radar_belly_of_the_beast",          -- 461
    "radar_yacht_location",              -- 462
    "radar_pickup_beast",                -- 463
    "radar_pickup_zoned",                -- 464
    "radar_pickup_random",               -- 465
    "radar_pickup_slow_time",            -- 466
    "radar_pickup_swap",                 -- 467
    "radar_pickup_thermal",              -- 468
    "radar_pickup_weed",                 -- 469
    "radar_weapon_railgun",              -- 470
    "radar_seashark",                    -- 471
    "radar_pickup_hidden",               -- 472
    "radar_warehouse",                   -- 473
    "radar_warehouse_for_sale",          -- 474
    "radar_office",                      -- 475
    "radar_office_for_sale",             -- 476
    "radar_truck",                       -- 477
    "radar_contraband",                  -- 478
    "radar_trailer",                     -- 479
    "radar_vip",                         -- 480
    "radar_cargobob",                    -- 481
    "radar_area_outline_blip",           -- 482
    "radar_pickup_accelerator",          -- 483
    "radar_pickup_ghost",                -- 484
    "radar_pickup_detonator",            -- 485
    "radar_pickup_bomb",                 -- 486
    "radar_pickup_armoured",             -- 487
    "radar_stunt",                       -- 488
    "radar_weapon_lives",                -- 489
    "radar_stunt_premium",               -- 490
    "radar_adversary",                   -- 491
    "radar_biker_clubhouse",             -- 492
    "radar_biker_caged_in",              -- 493
    "radar_biker_turf_war",              -- 494
    "radar_biker_joust",                 -- 495
    "radar_production_weed",             -- 496
    "radar_production_crack",            -- 497
    "radar_production_fake_id",          -- 498
    "radar_production_meth",             -- 499
    "radar_production_money",            -- 500
    "radar_package",                     -- 501
    "radar_capture_1",                   -- 502
    "radar_capture_2",                   -- 503
    "radar_capture_3",                   -- 504
    "radar_capture_4",                   -- 505
    "radar_capture_5",                   -- 506
    "radar_capture_6",                   -- 507
    "radar_capture_7",                   -- 508
    "radar_capture_8",                   -- 509
    "radar_capture_9",                   -- 510
    "radar_capture_10",                  -- 511
    "radar_quad",                        -- 512
    "radar_bus",                         -- 513
    "radar_drugs_package",               -- 514
    "radar_pickup_jump",                 -- 515
    "radar_adversary_4",                 -- 516
    "radar_adversary_8",                 -- 517
    "radar_adversary_10",                -- 518
    "radar_adversary_12",                -- 519
    "radar_adversary_16",                -- 520
    "radar_laptop",                      -- 521
    "radar_pickup_deadline",             -- 522
    "radar_sports_car",                  -- 523
    "radar_warehouse_vehicle",           -- 524
    "radar_reg_papers",                  -- 525
    "radar_police_station_dropoff",      -- 526
    "radar_junkyard",                    -- 527
    "radar_ex_vech_1",                   -- 528
    "radar_ex_vech_2",                   -- 529
    "radar_ex_vech_3",                   -- 530
    "radar_ex_vech_4",                   -- 531
    "radar_ex_vech_5",                   -- 532
    "radar_ex_vech_6",                   -- 533
    "radar_ex_vech_7",                   -- 534
    "radar_target_a",                    -- 535
    "radar_target_b",                    -- 536
    "radar_target_c",                    -- 537
    "radar_target_d",                    -- 538
    "radar_target_e",                    -- 539
    "radar_target_f",                    -- 540
    "radar_target_g",                    -- 541
    "radar_target_h",                    -- 542
    "radar_jugg",                        -- 543
    "radar_pickup_repair",               -- 544
    "radar_steeringwheel",               -- 545
    "radar_trophy",                      -- 546
    "radar_pickup_rocket_boost",         -- 547
    "radar_pickup_homing_rocket",        -- 548
    "radar_pickup_machinegun",           -- 549
    "radar_pickup_parachute",            -- 550
    "radar_pickup_time_5",               -- 551
    "radar_pickup_time_10",              -- 552
    "radar_pickup_time_15",              -- 553
    "radar_pickup_time_20",              -- 554
    "radar_pickup_time_30",              -- 555
    "radar_supplies",                    -- 556
    "radar_property_bunker",             -- 557
    "radar_gr_wvm_1",                    -- 558
    "radar_gr_wvm_2",                    -- 559
    "radar_gr_wvm_3",                    -- 560
    "radar_gr_wvm_4",                    -- 561
    "radar_gr_wvm_5",                    -- 562
    "radar_gr_wvm_6",                    -- 563
    "radar_gr_covert_ops",               -- 564
    "radar_adversary_bunker",            -- 565
    "radar_gr_moc_upgrade",              -- 566
    "radar_gr_w_upgrade",                -- 567
    "radar_sm_cargo",                    -- 568
    "radar_sm_hangar",                   -- 569
    "radar_tf_checkpoint",               -- 570
    "radar_race_tf",                     -- 571
    "radar_sm_wp1",                      -- 572
    "radar_sm_wp2",                      -- 573
    "radar_sm_wp3",                      -- 574
    "radar_sm_wp4",                      -- 575
    "radar_sm_wp5",                      -- 576
    "radar_sm_wp6",                      -- 577
    "radar_sm_wp7",                      -- 578
    "radar_sm_wp8",                      -- 579
    "radar_sm_wp9",                      -- 580
    "radar_sm_wp10",                     -- 581
    "radar_sm_wp11",                     -- 582
    "radar_sm_wp12",                     -- 583
    "radar_sm_wp13",                     -- 584
    "radar_sm_wp14",                     -- 585
    "radar_nhp_bag",                     -- 586
    "radar_nhp_chest",                   -- 587
    "radar_nhp_orbit",                   -- 588
    "radar_nhp_veh1",                    -- 589
    "radar_nhp_base",                    -- 590
    "radar_nhp_overlay",                 -- 591
    "radar_nhp_turret",                  -- 592
    "radar_nhp_mg_firewall",             -- 593
    "radar_nhp_mg_node",                 -- 594
    "radar_nhp_wp1",                     -- 595
    "radar_nhp_wp2",                     -- 596
    "radar_nhp_wp3",                     -- 597
    "radar_nhp_wp4",                     -- 598
    "radar_nhp_wp5",                     -- 599
    "radar_nhp_wp6",                     -- 600
    "radar_nhp_wp7",                     -- 601
    "radar_nhp_wp8",                     -- 602
    "radar_nhp_wp9",                     -- 603
    "radar_nhp_cctv",                    -- 604
    "radar_nhp_starterpack",             -- 605
    "radar_nhp_turret_console",          -- 606
    "radar_nhp_mg_mir_rotate",           -- 607
    "radar_nhp_mg_mir_static",           -- 608
    "radar_nhp_mg_proxy",                -- 609
    "radar_acsr_race_target",            -- 610
    "radar_acsr_race_hotring",           -- 611
    "radar_acsr_wp1",                    -- 612
    "radar_acsr_wp2",                    -- 613
    "radar_bat_club_property",           -- 614
    "radar_bat_cargo",                   -- 615
    "radar_bat_truck",                   -- 616
    "radar_bat_hack_jewel",              -- 617
    "radar_bat_hack_gold",               -- 618
    "radar_bat_keypad",                  -- 619
    "radar_bat_hack_target",             -- 620
    "radar_pickup_dtb_health",           -- 621
    "radar_pickup_dtb_blast_increase",   -- 622
    "radar_pickup_dtb_blast_decrease",   -- 623
    "radar_pickup_dtb_bomb_increase",    -- 624
    "radar_pickup_dtb_bomb_decrease",    -- 625
    "radar_bat_rival_club",              -- 626
    "radar_bat_drone",                   -- 627
    "radar_bat_cash_reg",                -- 628
    "radar_cctv",                        -- 629
    "radar_bat_assassinate",             -- 630
    "radar_bat_pbus",                    -- 631
    "radar_bat_wp1",                     -- 632
    "radar_bat_wp2",                     -- 633
    "radar_bat_wp3",                     -- 634
    "radar_bat_wp4",                     -- 635
    "radar_bat_wp5",                     -- 636
    "radar_bat_wp6",                     -- 637
    "radar_blimp_2",                     -- 638
    "radar_oppressor_2",                 -- 639
    "radar_bat_wp7",                     -- 640
    "radar_arena_series",                -- 641
    "radar_arena_premium",               -- 642
    "radar_arena_workshop",              -- 643
    "radar_race_wars",                   -- 644
    "radar_arena_turret",                -- 645
    "radar_arena_rc_car",                -- 646
    "radar_arena_rc_workshop",           -- 647
    "radar_arena_trap_fire",             -- 648
    "radar_arena_trap_flip",             -- 649
    "radar_arena_trap_sea",              -- 650
    "radar_arena_trap_turn",             -- 651
    "radar_arena_trap_pit",              -- 652
    "radar_arena_trap_mine",             -- 653
    "radar_arena_trap_bomb",             -- 654
    "radar_arena_trap_wall",             -- 655
    "radar_arena_trap_brd",              -- 656
    "radar_arena_trap_sbrd",             -- 657
    "radar_arena_bruiser",               -- 658
    "radar_arena_brutus",                -- 659
    "radar_arena_cerberus",              -- 660
    "radar_arena_deathbike",             -- 661
    "radar_arena_dominator",             -- 662
    "radar_arena_impaler",               -- 663
    "radar_arena_imperator",             -- 664
    "radar_arena_issi",                  -- 665
    "radar_arena_sasquatch",             -- 666
    "radar_arena_scarab",                -- 667
    "radar_arena_slamvan",               -- 668
    "radar_arena_zr380",                 -- 669
    "radar_ap",                          -- 670
    "radar_comic_store",                 -- 671
    "radar_cop_car",                     -- 672
    "radar_rc_time_trials",              -- 673
    "radar_king_of_the_hill",            -- 674
    "radar_king_of_the_hill_teams",      -- 675
    "radar_rucksack",                    -- 676
    "radar_shipping_container",          -- 677
    "radar_agatha",                      -- 678
    "radar_casino",                      -- 679
    "radar_casino_table_games",          -- 680
    "radar_casino_wheel",                -- 681
    "radar_casino_concierge",            -- 682
    "radar_casino_chips",                -- 683
    "radar_casino_horse_racing",         -- 684
    "radar_adversary_featured",          -- 685
    "radar_roulette_1",                  -- 686
    "radar_roulette_2",                  -- 687
    "radar_roulette_3",                  -- 688
    "radar_roulette_4",                  -- 689
    "radar_roulette_5",                  -- 690
    "radar_roulette_6",                  -- 691
    "radar_roulette_7",                  -- 692
    "radar_roulette_8",                  -- 693
    "radar_roulette_9",                  -- 694
    "radar_roulette_10",                 -- 695
    "radar_roulette_11",                 -- 696
    "radar_roulette_12",                 -- 697
    "radar_roulette_13",                 -- 698
    "radar_roulette_14",                 -- 699
    "radar_roulette_15",                 -- 700
    "radar_roulette_16",                 -- 701
    "radar_roulette_17",                 -- 702
    "radar_roulette_18",                 -- 703
    "radar_roulette_19",                 -- 704
    "radar_roulette_20",                 -- 705
    "radar_roulette_21",                 -- 706
    "radar_roulette_22",                 -- 707
    "radar_roulette_23",                 -- 708
    "radar_roulette_24",                 -- 709
    "radar_roulette_25",                 -- 710
    "radar_roulette_26",                 -- 711
    "radar_roulette_27",                 -- 712
    "radar_roulette_28",                 -- 713
    "radar_roulette_29",                 -- 714
    "radar_roulette_30",                 -- 715
    "radar_roulette_31",                 -- 716
    "radar_roulette_32",                 -- 717
    "radar_roulette_33",                 -- 718
    "radar_roulette_34",                 -- 719
    "radar_roulette_35",                 -- 720
    "radar_roulette_36",                 -- 721
    "radar_roulette_0",                  -- 722
    "radar_roulette_00",                 -- 723
    "radar_limo",                        -- 724
    "radar_weapon_alien",                -- 725
    "radar_race_open_wheel",             -- 726
    "radar_rappel",                      -- 727
    "radar_swap_car",                    -- 728
    "radar_scuba_gear",                  -- 729
    "radar_cpanel_1",                    -- 730
    "radar_cpanel_2",                    -- 731
    "radar_cpanel_3",                    -- 732
    "radar_cpanel_4",                    -- 733
    "radar_snow_truck",                  -- 734
    "radar_buggy_1",                     -- 735
    "radar_buggy_2",                     -- 736
    "radar_zhaba",                       -- 737
    "radar_gerald",                      -- 738
    "radar_ron",                         -- 739
    "radar_arcade",                      -- 740
    "radar_drone_controls",              -- 741
    "radar_rc_tank",                     -- 742
    "radar_stairs",                      -- 743
    "radar_camera_2",                    -- 744
    "radar_winky",                       -- 745
    "radar_mini_sub",                    -- 746
    "radar_kart_retro",                  -- 747
    "radar_kart_modern",                 -- 748
    "radar_military_quad",               -- 749
    "radar_military_truck",              -- 750
    "radar_ship_wheel",                  -- 751
    "radar_ufo",                         -- 752
    "radar_seasparrow2",                 -- 753
    "radar_dinghy2",                     -- 754
    "radar_patrol_boat",                 -- 755
    "radar_retro_sports_car",            -- 756
    "radar_squadee",                     -- 757
    "radar_folding_wing_jet",            -- 758
    "radar_valkyrie2",                   -- 759
    "radar_sub2",                        -- 760
    "radar_bolt_cutters",                -- 761
    "radar_rappel_gear",                 -- 762
    "radar_keycard",                     -- 763
    "radar_password",                    -- 764
    "radar_island_heist_prep",           -- 765
    "radar_island_party",                -- 766
    "radar_control_tower",               -- 767
    "radar_underwater_gate",             -- 768
    "radar_power_switch",                -- 769
    "radar_compound_gate",               -- 770
    "radar_rappel_point",                -- 771
    "radar_keypad",                      -- 772
    "radar_sub_controls",                -- 773
    "radar_sub_periscope",               -- 774
    "radar_sub_missile",                 -- 775
    "radar_painting",                    -- 776
    "radar_car_meet",                    -- 777
    "radar_car_test_area",               -- 778
    "radar_auto_shop_property",          -- 779
    "radar_docks_export",                -- 780
    "radar_prize_car",                   -- 781
    "radar_test_car",                    -- 782
    "radar_car_robbery_board",           -- 783
    "radar_car_robbery_prep",            -- 784
    "radar_street_race_series",          -- 785
    "radar_pursuit_series",              -- 786
    "radar_car_meet_organiser",          -- 787
    "radar_securoserv",                  -- 788
    "radar_bounty_collectibles",         -- 789
    "radar_movie_collectibles",          -- 790
    "radar_trailer_ramp",                -- 791
    "radar_race_organiser",              -- 792
    "radar_chalkboard_list",             -- 793
    "radar_export_vehicle",              -- 794
    "radar_train",                       -- 795
    "radar_heist_diamond",               -- 796
    "radar_heist_doomsday",              -- 797
    "radar_heist_island",                -- 798
    "radar_slamvan2",                    -- 799
    "radar_crusader",                    -- 800
    "radar_construction_outfit",         -- 801
    "radar_overlay_jammed",              -- 802
    "radar_heist_island_unavailable",    -- 803
    "radar_heist_diamond_unavailable",   -- 804
    "radar_heist_doomsday_unavailable",  -- 805
    "radar_placeholder_7",               -- 806
    "radar_placeholder_8",               -- 807
    "radar_placeholder_9",               -- 808
    "radar_featured_series",             -- 809
    "radar_vehicle_for_sale",            -- 810
    "radar_van_keys",                    -- 811
    "radar_suv_service",                 -- 812
    "radar_security_contract",           -- 813
    "radar_safe",                        -- 814
    "radar_ped_r",                       -- 815
    "radar_ped_e",                       -- 816
    "radar_payphone",                    -- 817
    "radar_patriot3",                    -- 818
    "radar_music_studio",                -- 819
    "radar_jubilee",                     -- 820
    "radar_granger2",                    -- 821
    "radar_explosive_charge",            -- 822
    "radar_deity",                       -- 823
    "radar_d_champion",                  -- 824
    "radar_buffalo4",                    -- 825
    "radar_agency",                      -- 826
}

-- DisplayID = index - 1
Blip_DisplayID_ListItem = {
    { "Doesn't show up, ever, anywhere." },                                 -- 0
    { "Doesn't show up, ever, anywhere." },                                 -- 1
    { "Shows on both main map and minimap.", {}, "Selectable on map" },     -- 2
    { "Shows on main map only.",             {}, "Selectable on map" },     -- 3
    { "Shows on main map only.",             {}, "Selectable on map" },     -- 4
    { "Shows on minimap only." },                                           -- 5
    { "Shows on both main map and minimap.", {}, "Selectable on map" },     -- 6
    { "Doesn't show up, ever, anywhere." },                                 -- 7
    { "Shows on both main map and minimap.", {}, "Not selectable on map" }, -- 8
    { "Shows on minimap only." },                                           -- 9
    { "Shows on both main map and minimap.", {}, "Not selectable on map" }, -- 9
}



-- 爆炸类型 explosionType = index - 2
ExplosionType_ListItem = {
    { "Dont Care" },                -- -1
    { "Grenade" },                  -- 0
    { "Grenade Launcher" },         -- 1
    { "Sticky Bomb" },              -- 2
    { "Molotov" },                  -- 3
    { "Rocket" },                   -- 4
    { "Tank Shell" },               -- 5
    { "Hi Octane" },                -- 6
    { "Car" },                      -- 7
    { "Plane" },                    -- 8
    { "Petrol Pump" },              -- 9
    { "Bike" },                     -- 10
    { "Steam" },                    -- 11
    { "Flame" },                    -- 12
    { "Water Hydrant" },            -- 13
    { "Gas Canister Flame" },       -- 14
    { "Boat" },                     -- 15
    { "Ship" },                     -- 16
    { "Truck" },                    -- 17
    { "Bullet" },                   -- 18
    { "Smoke Grenade Launcher" },   -- 19
    { "Smoke Grenade" },            -- 20
    { "BZ Gas" },                   -- 21
    { "Flare" },                    -- 22
    { "Gas Canister" },             -- 23
    { "Extinguisher" },             -- 24
    { "Programmable AR" },          -- 25
    { "Train" },                    -- 26
    { "Barrel (Blue)" },            -- 27
    { "Propane" },                  -- 28
    { "Blimp" },                    -- 29
    { "Flame Explode" },            -- 30
    { "Tanker" },                   -- 31
    { "Plane Rocket" },             -- 32
    { "Vehicle Bullet" },           -- 33
    { "Gas Tank" },                 -- 34
    { "Bird Crap" },                -- 35
    { "Railgun" },                  -- 36
    { "Blimp (Red & Cyan)" },       -- 37
    { "Firework" },                 -- 38
    { "Snowball" },                 -- 39
    { "Proximity Mine" },           -- 40
    { "Valkyrie Cannon" },          -- 41
    { "Air Defence" },              -- 42
    { "Pipe Bomb" },                -- 43
    { "Vehicle Mine" },             -- 44
    { "Explosive Ammo" },           -- 45
    { "APC Shell" },                -- 46
    { "Cluster Bomb" },             -- 47
    { "Gas Bomb" },                 -- 48
    { "Incendiary Bomb" },          -- 49
    { "Standard Bomb" },            -- 50
    { "Torpedo" },                  -- 51
    { "Torpedo (Underwater)" },     -- 52
    { "Bombushka Cannon" },         -- 53
    { "Cluster Bomb 2" },           -- 54
    { "Hunter Barrage" },           -- 55
    { "Hunter Cannon" },            -- 56
    { "Rogue Cannon" },             -- 57
    { "Underwater Mine" },          -- 58
    { "Orbital Cannon" },           -- 59
    { "Standard Bomb (Wide)" },     -- 60
    { "Explosive Ammo (Shotgun)" }, -- 61
    { "Oppressor Mk2 Cannon" },     -- 62
    { "Kinetic Mortar" },           -- 63
    { "Kinetic Vehicle Mine" },     -- 64
    { "Emp Vehicle Mine" },         -- 65
    { "Spike Vehicle Mine" },       -- 66
    { "Slick Vehicle Mine" },       -- 67
    { "Tar Vehicle Mine" },         -- 68
    { "Script Drone" },             -- 69
    { "Raygun" },                   -- 70
    { "Buried Mine" },              -- 71
    { "Script Missile" },           -- 72
    { "RC Tank Rocket" },           -- 73
    { "Water Bomb" },               -- 74
    { "Water Bomb 2" },             -- 75
    { "Cnc Spike Mine" },           -- 76
    { "BZ Gas Mk2" },               -- 77
    { "Flash Grenade" },            -- 78
    { "Stun Grenade" },             -- 79
    { "Cnc Kinetic Ram" },          -- 80
    { "Large Missile" },            -- 81
    { "Big Submarine" },            -- 82
    { "Emp Launcher" }              -- 83
}



-- 载具武器
local VehicleWeapons = {
    -- { model_name, label_key }
    { "VEHICLE_WEAPON_TANK",                 "WT_V_TANK" },
    { "VEHICLE_WEAPON_SPACE_ROCKET",         "WT_V_PLANEMSL" },
    { "VEHICLE_WEAPON_PLANE_ROCKET",         "WT_V_PLANEMSL" },
    { "VEHICLE_WEAPON_PLAYER_LASER",         "WT_V_PLRLSR" },
    { "VEHICLE_WEAPON_PLAYER_BULLET",        "WT_V_PLRBUL" },
    { "VEHICLE_WEAPON_PLAYER_BUZZARD",       "WT_V_PLRBUL" },
    { "VEHICLE_WEAPON_PLAYER_HUNTER",        "WT_V_PLRBUL" },
    { "VEHICLE_WEAPON_PLAYER_LAZER",         "WT_V_LZRCAN" },
    { "VEHICLE_WEAPON_ENEMY_LASER",          "WT_A_ENMYLSR" },
    { "VEHICLE_WEAPON_TURRET_INSURGENT",     "WT_V_TURRET" },
    { "VEHICLE_WEAPON_TURRET_TECHNICAL",     "WT_V_TURRET" },
    { "VEHICLE_WEAPON_NOSE_TURRET_VALKYRIE", "WT_V_PLRBUL" },
    { "VEHICLE_WEAPON_TURRET_VALKYRIE",      "WT_V_TURRET" },
    { "VEHICLE_WEAPON_PLAYER_SAVAGE",        "WT_V_LZRCAN" },
    { "VEHICLE_WEAPON_TURRET_LIMO",          "WT_V_TURRET" },
    { "VEHICLE_WEAPON_TURRET_BOXVILLE",      "WT_V_TURRET" },
    { "VEHICLE_WEAPON_CANNON_BLAZER",        "WT_V_PLRBUL" },
    { "VEHICLE_WEAPON_RUINER_BULLET",        "WT_V_PLRBUL" },
    { "VEHICLE_WEAPON_RUINER_ROCKET",        "WT_V_PLANEMSL" },
}

All_VehicleWeapons_ListItem = {
    { "载具当前使用的武器", {}, "VEHICLE_CURRENT_WEAPON" }
}

for k, v in pairs(VehicleWeapons) do
    local t = { "label", {}, "hash" }
    local label = util.get_label_text(v[2]) .. " (" .. string.gsub(v[1], "VEHICLE_WEAPON_", "") .. ")"
    t[1] = label
    t[3] = tostring(util.joaat(v[1]))
    table.insert(All_VehicleWeapons_ListItem, t)
end

