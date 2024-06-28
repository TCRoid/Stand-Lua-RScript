------------------------------------------
--          Bodyguard Options
------------------------------------------

local Bodyguard_Options <const> = menu.list(Menu_Root, "保镖选项", {}, "")


local Bodyguard = {
    onTick = false,
}

Bodyguard.Setting = {
    ped = {
        godmode = false,
        health = 5000,
        no_ragdoll = false,
        weapon_main = util.joaat("WEAPON_SPECIALCARBINE"),
        weapon_secondary = util.joaat("WEAPON_MICROSMG"),
        weapon_damamge_modifier = 1.0,
        formation = 0,
        relationship = util.joaat("PLAYER"),
    },
    heli = {
        godmode = false,
        health = 10000,
        speed = 300,
        drivingStyle = 786603,
        customOffsets = -1.0,
        minHeightAboveTerrain = 20,
        heliMode = 0,
    },
}

Bodyguard.Group = {
    Formation = {
        { 0, "自由" },
        { 1, "围绕" },
        { 3, "直线" },
        { 4, "Arrow" },
    },
    Relationship = {
        { util.joaat("PLAYER"),                     "Player" },
        { util.joaat("rgFM_AiLike"),                "Like Players" },
        { util.joaat("rgFM_AiDislike"),             "Dislike Players, Like Gangs" },
        { util.joaat("rgFM_AiHate"),                "Hate Players, Like Gangs" },
        { util.joaat("rgFM_AiLike_HateAiHate"),     "Like Players, Hate Player Haters" },
        { util.joaat("rgFM_AiDislikePlyrLikeCops"), "Dislike Players, Like Cops" },
        { util.joaat("rgFM_AiHatePlyrLikeCops"),    "Hate Players, Like Cops" },
        { util.joaat("rgFM_HateEveryOne"),          "Hate Everyone" },
    },
}

function Bodyguard.Group.GetSize()
    local GroupID = PLAYER.GET_PLAYER_GROUP(players.user())
    local HasLeaderPtr, FollowersNumberPtr = memory.alloc(1), memory.alloc(1)
    PED.GET_GROUP_SIZE(GroupID, HasLeaderPtr, FollowersNumberPtr)
    return memory.read_int(FollowersNumberPtr)
end

function Bodyguard.Group.AddMember(ped)
    local group_id = PLAYER.GET_PLAYER_GROUP(players.user())
    PED.SET_PED_AS_GROUP_LEADER(players.user_ped(), group_id)
    PED.SET_GROUP_SEPARATION_RANGE(group_id, 9999.0)
    PED.SET_GROUP_FORMATION_SPACING(group_id, 1.0, -1.0, -1.0)
    PED.SET_GROUP_FORMATION(group_id, Bodyguard.Setting.ped.formation)

    if not PED.IS_PED_IN_GROUP(ped) then
        PED.SET_PED_AS_GROUP_MEMBER(ped, group_id)
        PED.SET_PED_NEVER_LEAVES_GROUP(ped, true)
        PED.SET_PED_CAN_TELEPORT_TO_GROUP_LEADER(ped, group_id, true)
    end
end

function Bodyguard.Group.SetPedRelationship(ped)
    local group_hash = Bodyguard.Setting.ped.relationship
    if group_hash == util.joaat("PLAYER") then
        group_hash = PED.GET_PED_RELATIONSHIP_GROUP_HASH(players.user_ped())
    end
    PED.SET_RELATIONSHIP_BETWEEN_GROUPS(0, group_hash, group_hash) -- Respect
    PED.SET_RELATIONSHIP_GROUP_AFFECTS_WANTED_LEVEL(group_hash, false)

    PED.SET_PED_RELATIONSHIP_GROUP_HASH(ped, group_hash)
    ENTITY.SET_ENTITY_CAN_BE_DAMAGED_BY_RELATIONSHIP_GROUP(ped, false, group_hash)
end

function Bodyguard.AddBlipForPed(ped)
    local blip = HUD.ADD_BLIP_FOR_ENTITY(ped)
    HUD.SET_BLIP_SPRITE(blip, 271)
    HUD.SET_BLIP_COLOUR(blip, 3)
    HUD.SET_BLIP_SCALE(blip, 0.5)
end

function Bodyguard.SetPedAttribute(ped)
    -- GODMODE
    if Bodyguard.Setting.ped.godmode then
        set_entity_godmode(ped, true)
    end
    -- HEALTH
    ENTITY.SET_ENTITY_MAX_HEALTH(ped, Bodyguard.Setting.ped.health)
    SET_ENTITY_HEALTH(ped, Bodyguard.Setting.ped.health)
    -- RAGDOLL
    PED.SET_PED_CAN_RAGDOLL(ped, not Bodyguard.Setting.ped.no_ragdoll)
    PED.DISABLE_PED_INJURED_ON_GROUND_BEHAVIOUR(ped)
    PED.SET_PED_CAN_PLAY_AMBIENT_ANIMS(ped, false)
    PED.SET_PED_CAN_PLAY_AMBIENT_BASE_ANIMS(ped, false)
    -- WEAPON
    WEAPON.GIVE_WEAPON_TO_PED(ped, util.joaat("WEAPON_SMOKEGRENADE"), -1, false, false)

    WEAPON.GIVE_WEAPON_TO_PED(ped, Bodyguard.Setting.ped.weapon_main, -1, false, true)
    WEAPON.SET_CURRENT_PED_WEAPON(ped, Bodyguard.Setting.ped.weapon_main, false)
    WEAPON.GIVE_WEAPON_TO_PED(ped, Bodyguard.Setting.ped.weapon_secondary, -1, false, false)

    WEAPON.SET_PED_DROPS_WEAPONS_WHEN_DEAD(ped, false)
    PED.SET_PED_CAN_SWITCH_WEAPON(ped, true)
    WEAPON.SET_PED_INFINITE_AMMO_CLIP(ped, true)
    WEAPON.SET_EQIPPED_WEAPON_START_SPINNING_AT_FULL_SPEED(ped)
    -- PERCEPTIVE
    PED.SET_PED_SEEING_RANGE(ped, 500.0)
    PED.SET_PED_HEARING_RANGE(ped, 500.0)
    PED.SET_PED_ID_RANGE(ped, 500.0)
    PED.SET_PED_VISUAL_FIELD_PERIPHERAL_RANGE(ped, 500.0)
    PED.SET_PED_HIGHLY_PERCEPTIVE(ped, true)
    PED.SET_PED_VISUAL_FIELD_MIN_ANGLE(ped, -180.0)
    PED.SET_PED_VISUAL_FIELD_MAX_ANGLE(ped, 180.0)
    PED.SET_PED_VISUAL_FIELD_MIN_ELEVATION_ANGLE(ped, -180.0)
    PED.SET_PED_VISUAL_FIELD_MAX_ELEVATION_ANGLE(ped, 180.0)
    PED.SET_PED_VISUAL_FIELD_CENTER_ANGLE(ped, 90.0)
    -- COMBAT
    PED.SET_PED_SHOOT_RATE(ped, 1000)
    PED.SET_PED_ACCURACY(ped, 100)
    PED.SET_PED_COMBAT_ABILITY(ped, 2)                 -- Professional
    PED.SET_PED_COMBAT_RANGE(ped, 2)                   -- Far
    PED.SET_PED_COMBAT_MOVEMENT(ped, 1)                -- Defensive
    PED.SET_PED_TARGET_LOSS_RESPONSE(ped, 2)           -- Search For Target
    -- COMBAT ATTRIBUTES
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 4, true)        -- Can Use Dynamic Strafe Decisions
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 5, true)        -- Always Fight
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 6, false)       -- Flee Whilst In Vehicle
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 13, true)       -- Aggressive
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 14, true)       -- Can Investigate
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 17, false)      -- Always Flee
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 20, true)       -- Can Taunt In Vehicle
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 21, true)       -- Can Chase Target On Foot
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 22, true)       -- Will Drag Injured Peds to Safety
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 24, true)       -- Use Proximity Firing Rate
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 27, true)       -- Perfect Accuracy
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 28, true)       -- Can Use Frustrated Advance
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 38, true)       -- Disable Bullet Reactions
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 39, true)       -- Can Bust
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 41, true)       -- Can Commandeer Vehicles
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 42, true)       -- Can Flank
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)       -- Can Fight Armed Peds When Not Armed
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 49, false)      -- Use Enemy Accuracy Scaling
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 52, true)       -- Use Vehicle Attack
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 53, true)       -- Use Vehicle Attack If Vehicle Has Mounted Guns
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 54, true)       -- Always Equip Best Weapon
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 55, true)       -- Can See Underwater Peds
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 58, true)       -- Disable Flee From Combat
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 60, true)       -- Can Throw Smoke Grenade
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 78, true)       -- Disable All Randoms Flee
    -- COMBAT FLOAT
    PED.SET_COMBAT_FLOAT(ped, 6, 1.0)                  -- Weapon Accuracy
    PED.SET_COMBAT_FLOAT(ped, 7, 1.0)                  -- Fight Proficiency
    PED.SET_COMBAT_FLOAT(ped, 9, 1.0)                  -- Heli Speed Modifier
    PED.SET_COMBAT_FLOAT(ped, 10, 200.0)               -- Heli Senses Range
    PED.SET_COMBAT_FLOAT(ped, 26, 10.0)                -- Homing Rocket Turn Rate Modifier
    PED.SET_COMBAT_FLOAT(ped, 29,
        Bodyguard.Setting.ped.weapon_damamge_modifier) -- Weapon Damamge Modifier
    -- FLEE ATTRIBUTES
    PED.SET_PED_FLEE_ATTRIBUTES(ped, 512, true)        -- Never Flee
    -- TASK PATH
    TASK.SET_PED_PATH_CAN_USE_CLIMBOVERS(ped, true)
    TASK.SET_PED_PATH_CAN_USE_LADDERS(ped, true)
    TASK.SET_PED_PATH_CAN_DROP_FROM_HEIGHT(ped, true)
    TASK.SET_PED_PATH_AVOID_FIRE(ped, false)
    TASK.SET_PED_PATH_MAY_ENTER_WATER(ped, true)
    -- CONFIG FLAG
    PED.SET_PED_CONFIG_FLAG(ped, 32, false)       -- Will Fly Through Windscreen
    PED.SET_PED_CONFIG_FLAG(ped, 42, true)        -- Dont Influence Wanted Level
    PED.SET_PED_CONFIG_FLAG(ped, 107, true)       -- Dont Activate Ragdoll From BulletImpact
    PED.SET_PED_CONFIG_FLAG(ped, 108, true)       -- Dont Activate Ragdoll From Explosions
    PED.SET_PED_CONFIG_FLAG(ped, 109, true)       -- Dont Activate Ragdoll From Fire
    PED.SET_PED_CONFIG_FLAG(ped, 110, true)       -- Dont Activate Ragdoll From Electrocution
    PED.SET_PED_CONFIG_FLAG(ped, 140, false)      -- Can Attack Friendly
    PED.SET_PED_CONFIG_FLAG(ped, 430, false)      -- Ignore Being On Fire
    -- OTHER
    PED.SET_PED_SUFFERS_CRITICAL_HITS(ped, false) -- Disable Headshot
    PED.SET_DISABLE_HIGH_FALL_DEATH(ped, true)

    entities.set_can_migrate(ped, false)
end

function Bodyguard.TickHandler()
    if Bodyguard.onTick then
        return true
    end

    Bodyguard.onTick = true
    util.create_tick_handler(function()
        if not Bodyguard.onTick then
            return false
        end

        local keep_running_flag = false

        for _, ped in pairs(Bodyguard.NPC.members) do
            if ENTITY.DOES_ENTITY_EXIST(ped) and not ENTITY.IS_ENTITY_DEAD(ped) then
                PED.SET_PED_NO_TIME_DELAY_BEFORE_SHOT(ped)
                keep_running_flag = true
            end
        end
        for _, ped in pairs(Bodyguard.Heli.pedList) do
            if ENTITY.DOES_ENTITY_EXIST(ped) and not ENTITY.IS_ENTITY_DEAD(ped) then
                PED.SET_PED_NO_TIME_DELAY_BEFORE_SHOT(ped)
                keep_running_flag = true
            end
        end
        for _, heli in pairs(Bodyguard.Heli.heliList) do
            local blip = HUD.GET_BLIP_FROM_ENTITY(heli)
            if ENTITY.DOES_ENTITY_EXIST(heli) and HUD.DOES_BLIP_EXIST(blip) then
                if not ENTITY.IS_ENTITY_DEAD(heli) then
                    HUD.SET_BLIP_ROTATION(blip, math.ceil(ENTITY_HEADING(heli)))
                    keep_running_flag = true
                else
                    util.remove_blip(blip)
                end
            end
        end

        if not keep_running_flag then
            notify("Stop Bodyguard Tick Handler")

            Bodyguard.onTick = false
            return false
        end
    end)
end

------------------------
-- Bodyguard NPC
------------------------

local Bodyguard_NPC <const> = menu.list(Bodyguard_Options, "保镖NPC", {}, "")

Bodyguard.NPC = {
    members = {}, -- 保镖 ped list

    ped_models = {
        { util.joaat("ig_LesterCrest"), "莱斯特", {}, "" },
        { util.joaat("IG_ARY_02"), "德瑞", {}, "" },
        { util.joaat("ig_LamarDavis"), "拉玛", {}, "" },
        { util.joaat("mp_m_Avongoon"), "埃万保安", {}, "" },
        { util.joaat("u_m_y_Juggernaut_01"), "埃万重甲兵", {}, "" },
        { util.joaat("ig_rashcosvki"), "越狱光头", {}, "" },
        { util.joaat("ig_JimmyDisanto"), "吉米", {}, "麦克儿子" },
        { util.joaat("ig_TracyDisanto"), "崔西", {}, "麦克女儿" },
        { util.joaat("ig_AmandaTownley"), "阿曼达", {}, "麦克妻子" },
        { util.joaat("player_one"), "富兰克林", {}, "可能会被其他Stand用户阻止生成" },
        { util.joaat("player_zero"), "麦克", {}, "可能会被其他Stand用户阻止生成" },
        { util.joaat("player_two"), "崔佛", {}, "" },
    },
}

function Bodyguard.NPC.ClearDeletedPeds()
    for key, ped in pairs(Bodyguard.NPC.members) do
        if not ENTITY.DOES_ENTITY_EXIST(ped) then
            table.remove(Bodyguard.NPC.members, key)
        end
    end
end

function Bodyguard.NPC.AllMembers(callback)
    for _, ped in pairs(Bodyguard.NPC.members) do
        if ENTITY.DOES_ENTITY_EXIST(ped) and not ENTITY.IS_ENTITY_DEAD(ped) then
            callback(ped)
        end
    end
end

-- 保镖 ped hash
Bodyguard.NPC.model_hash = Bodyguard.NPC.ped_models[1][1]

menu.list_select(Bodyguard_NPC, "保镖模型", {}, "",
    Bodyguard.NPC.ped_models, Bodyguard.NPC.model_hash, function(value)
        Bodyguard.NPC.model_hash = value
    end)
menu.action(Bodyguard_NPC, "生成保镖", {}, "", function()
    if Bodyguard.Group.GetSize() >= 7 then
        util.toast("保镖人数已达到上限")
        return
    end

    local model_hash = Bodyguard.NPC.model_hash
    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0.0, 2.0, 0.0)
    local heading = user_heading() + 180.0
    local ped = create_ped(26, model_hash, coords, heading)

    Bodyguard.Group.AddMember(ped)
    Bodyguard.Group.SetPedRelationship(ped)
    Bodyguard.AddBlipForPed(ped)
    Bodyguard.SetPedAttribute(ped)

    Bodyguard.NPC.ClearDeletedPeds()
    table.insert(Bodyguard.NPC.members, ped)

    Bodyguard.TickHandler()
end)

menu.divider(Bodyguard_NPC, "管理保镖")

menu.list_select(Bodyguard_NPC, "保镖队形", {}, "", Bodyguard.Group.Formation, 0, function(value)
    Bodyguard.Setting.ped.formation = value

    local group_id = PLAYER.GET_PLAYER_GROUP(players.user())
    PED.SET_GROUP_FORMATION(group_id, Bodyguard.Setting.ped.formation)
end)

----------------
-- All NPC
----------------

local Bodyguard_NPC_All <const> = menu.list(Bodyguard_NPC, "所有保镖", {}, "")

menu.action(Bodyguard_NPC_All, "传送到我", {}, "", function()
    local y = 2.0
    Bodyguard.NPC.AllMembers(function(ped)
        tp_entity_to_me(ped, 0.0, y, 0.0)
        ENTITY_HEADING(ped, user_heading() + 180.0)
        y = y + 1.0
    end)
end)
menu.toggle(Bodyguard_NPC_All, "无敌", {}, "", function(toggle)
    Bodyguard.NPC.AllMembers(function(ped)
        set_entity_godmode(ped, toggle)
    end)
end)
menu.action(Bodyguard_NPC_All, "恢复", {}, "恢复生命值,清理NPC血迹", function()
    Bodyguard.NPC.AllMembers(function(ped)
        SET_ENTITY_HEALTH(ped, ENTITY.GET_ENTITY_MAX_HEALTH(ped))
        clear_ped_body(ped)
    end)
end)
menu.list_action(Bodyguard_NPC_All, "给予武器", {}, "", RS_T.CommonWeapons, function(value)
    local weaponHash = value
    Bodyguard.NPC.AllMembers(function(ped)
        WEAPON.GIVE_WEAPON_TO_PED(ped, weaponHash, -1, false, true)
        WEAPON.SET_CURRENT_PED_WEAPON(ped, weaponHash, false)
    end)
end)
menu.divider(Bodyguard_NPC_All, "删除")
menu.action(Bodyguard_NPC_All, "删除已死亡", {}, "", function()
    for key, ent in pairs(Bodyguard.NPC.members) do
        if ENTITY.DOES_ENTITY_EXIST(ent) and ENTITY.IS_ENTITY_DEAD(ent) then
            entities.delete(ent)

            table.remove(Bodyguard.NPC.members, key)
        end
    end
end)
menu.action(Bodyguard_NPC_All, "删除全部", {}, "", function()
    for _, ent in pairs(Bodyguard.NPC.members) do
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            entities.delete(ent)
        end
    end

    Bodyguard.NPC.members = {}
end)






--------------------------------
--      Bodyguard Heli
--------------------------------

local Bodyguard_Heli <const> = menu.list(Bodyguard_Options, "保镖直升机", {}, "")

local BodyguardHeliModels <const> = {
    { model = "valkyrie",     label = "Valkyrie",    vehWeapons = nil },
    { model = "hunter",       label = "Hunter",      vehWeapons = { "VEHICLE_WEAPON_HUNTER_MISSILE", "VEHICLE_WEAPON_HUNTER_CANNON", "VEHICLE_WEAPON_HUNTER_BARRAGE" } },
    { model = "akula",        label = "Akula",       vehWeapons = { "VEHICLE_WEAPON_AKULA_MISSILE", "VEHICLE_WEAPON_AKULA_MINIGUN" }, },
    { model = "savage",       label = "Savage",      vehWeapons = { "VEHICLE_WEAPON_SPACE_ROCKET", "VEHICLE_WEAPON_PLAYER_SAVAGE" }, },
    { model = "annihilator2", label = "ANNIHLATOR2", vehWeapons = { "VEHICLE_WEAPON_ANNIHILATOR2_MISSILE", "VEHICLE_WEAPON_ANNIHILATOR2_MINI" }, },
    { model = "buzzard",      label = "Buzzard",     vehWeapons = { "VEHICLE_WEAPON_SPACE_ROCKET", "VEHICLE_WEAPON_PLAYER_BUZZARD" }, },
    { model = "polmav",       label = "Polmav",      vehWeapons = nil }
}

Bodyguard.Heli = {
    heliModel = "",
    heliModelListItem = {},
    heliLabels = {},
    heliWeapons = {},

    pedList = {},
    heliList = {},
    menuList = {},
    index = 0,
}

function Bodyguard.Heli.Init()
    for _, item in pairs(BodyguardHeliModels) do
        local model_hash = util.joaat(item.model)
        local label_text = util.get_label_text(item.label)
        local list_item = { model_hash, label_text }
        table.insert(Bodyguard.Heli.heliModelListItem, list_item)

        Bodyguard.Heli.heliWeapons[model_hash] = item.vehWeapons
        Bodyguard.Heli.heliLabels[model_hash] = label_text
    end

    Bodyguard.Heli.heliModel = Bodyguard.Heli.heliModelListItem[1][1]
end

Bodyguard.Heli.Init()

function Bodyguard.Heli.AddBlipForHeli(heli)
    local blip = HUD.ADD_BLIP_FOR_ENTITY(heli)
    HUD.SET_BLIP_SPRITE(blip, 422)
    HUD.SET_BLIP_COLOUR(blip, 26)
    HUD.SHOW_HEIGHT_ON_BLIP(blip, false)
end

function Bodyguard.Heli.SetHeliAttribute(heli)
    -- GODMODE
    if Bodyguard.Setting.heli.godmode then
        set_entity_godmode(heli, true)
    end
    -- HEALTH
    ENTITY.SET_ENTITY_MAX_HEALTH(heli, Bodyguard.Setting.heli.health)
    SET_ENTITY_HEALTH(heli, Bodyguard.Setting.heli.health)
    local heli_health = 10000
    VEHICLE.SET_VEHICLE_ENGINE_HEALTH(heli, heli_health)
    VEHICLE.SET_VEHICLE_BODY_HEALTH(heli, heli_health)
    VEHICLE.SET_VEHICLE_PETROL_TANK_HEALTH(heli, heli_health)
    VEHICLE.SET_HELI_MAIN_ROTOR_HEALTH(heli, heli_health)
    VEHICLE.SET_HELI_TAIL_ROTOR_HEALTH(heli, heli_health)
    -- BEHAVIOUR
    SET_VEHICLE_ENGINE_ON(heli, true)
    VEHICLE.SET_HELI_BLADES_FULL_SPEED(heli)
    VEHICLE.SET_VEHICLE_SEARCHLIGHT(heli, true, true)
    strong_vehicle(heli)
    -- UPGRADE
    for _, mod_type in pairs({ 5, 11, 12, 13, 16 }) do
        local mod_num = VEHICLE.GET_NUM_VEHICLE_MODS(heli, mod_type)
        VEHICLE.SET_VEHICLE_MOD(heli, mod_type, mod_num - 1, false)
    end
    VEHICLE.TOGGLE_VEHICLE_MOD(heli, 18, true)

    entities.set_can_migrate(heli, false)
end

function Bodyguard.Heli.SetPedAttribute(ped)
    Bodyguard.SetPedAttribute(ped)

    PED.SET_PED_CAN_BE_SHOT_IN_VEHICLE(ped, false)

    PED.SET_PED_CAN_BE_KNOCKED_OFF_VEHICLE(ped, 1)
    PED.SET_PED_CAN_BE_DRAGGED_OUT(ped, false)
    PED.SET_DRIVER_ABILITY(ped, 1.0)

    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 3, false) -- Leave Vehicles
end

function Bodyguard.Heli.GenerateMenu(menu_name, index, heli_data)
    local heli = heli_data.heli
    local pilot = heli_data.pilot
    local members = heli_data.members
    local heli_weapons = heli_data.heli_weapons


    local menu_parent = Bodyguard_Heli
    local menu_list = menu.list(menu_parent, menu_name, {}, "", function()
        if not ENTITY.DOES_ENTITY_EXIST(heli) then
            util.toast("保镖直升机已不存在")
            return
        end
        if ENTITY.IS_ENTITY_DEAD(heli) then
            util.toast("保镖直升机已死亡")
            return
        end
    end)
    Bodyguard.Heli.menuList[index] = menu_list


    local on_tick = menu.divider(menu_list, menu_name)
    menu.on_tick_in_viewport(on_tick, function()
        if ENTITY.DOES_ENTITY_EXIST(heli) and not ENTITY.IS_ENTITY_DEAD(heli) then
            draw_line_to_entity(heli)
        end
    end)

    menu.action(menu_list, "传送到我", {}, "", function()
        tp_entity_to_me(heli, math.random(-60, 60), math.random(-60, 60), 30)
    end)
    menu.textslider(menu_list, "无敌", {}, "", { "设置", "取消" }, function(value)
        local toggle = true
        if value == 2 then
            toggle = false
        end

        set_entity_godmode(heli, toggle)
        set_entity_godmode(pilot, toggle)
        for _, ped in pairs(members) do
            set_entity_godmode(ped, toggle)
        end
    end)
    menu.action(menu_list, "恢复", {}, "", function()
        SET_ENTITY_HEALTH(heli, ENTITY.GET_ENTITY_MAX_HEALTH(heli))
        fix_vehicle(heli)

        SET_ENTITY_HEALTH(pilot, ENTITY.GET_ENTITY_MAX_HEALTH(ped))
        clear_ped_body(pilot)

        for _, ped in pairs(members) do
            SET_ENTITY_HEALTH(ped, ENTITY.GET_ENTITY_MAX_HEALTH(ped))
            clear_ped_body(ped)
        end
    end)

    if heli_weapons ~= nil then
        local list_item = {}
        for _, weapon_model in pairs(heli_weapons) do
            table.insert(list_item, { util.joaat(weapon_model), weapon_model })
        end
        menu.list_action(menu_list, "主驾驶载具武器", {}, "", list_item, function(value)
            WEAPON.SET_CURRENT_PED_VEHICLE_WEAPON(pilot, value)
        end)
    end

    menu.action(menu_list, "删除", {}, "", function()
        if ENTITY.DOES_ENTITY_EXIST(heli) then
            entities.delete(heli)
        end
        if ENTITY.DOES_ENTITY_EXIST(pilot) then
            entities.delete(pilot)
        end
        for _, ped in pairs(members) do
            if ENTITY.DOES_ENTITY_EXIST(ped) then
                entities.delete(ped)
            end
        end

        menu.delete(menu_list)
    end)
end

function Bodyguard.Heli.AllPeds(callback)
    for _, ped in pairs(Bodyguard.Heli.pedList) do
        if ENTITY.DOES_ENTITY_EXIST(ped) and not ENTITY.IS_ENTITY_DEAD(ped) then
            callback(ped)
        end
    end
end

function Bodyguard.Heli.AllHelis(callback)
    for _, heli in pairs(Bodyguard.Heli.heliList) do
        if ENTITY.DOES_ENTITY_EXIST(heli) and not ENTITY.IS_ENTITY_DEAD(heli) then
            callback(heli)
        end
    end
end

menu.list_select(Bodyguard_Heli, "直升机模型", {}, "",
    Bodyguard.Heli.heliModelListItem, Bodyguard.Heli.heliModel, function(value)
        Bodyguard.Heli.heliModel = value
    end)

menu.action(Bodyguard_Heli, "生成保镖直升机", {}, "", function()
    local heli_hash = Bodyguard.Heli.heliModel
    local ped_hash = util.joaat("s_m_y_blackops_01")
    local heading = user_heading()
    local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    coords.x = coords.x + math.random(-30, 30)
    coords.y = coords.y + math.random(-30, 30)
    coords.z = coords.z + 30.0

    -- Heli
    local heli = create_vehicle(heli_hash, coords, heading)
    Bodyguard.Heli.AddBlipForHeli(heli)
    Bodyguard.Heli.SetHeliAttribute(heli)

    -- Pilot
    local pilot = create_ped(29, ped_hash, coords, heading)
    PED.SET_PED_INTO_VEHICLE(pilot, heli, -1)
    TASK.TASK_VEHICLE_HELI_PROTECT(pilot, heli, players.user_ped(),
        Bodyguard.Setting.heli.speed,
        Bodyguard.Setting.heli.drivingStyle,
        Bodyguard.Setting.heli.customOffsets,
        Bodyguard.Setting.heli.minHeightAboveTerrain,
        Bodyguard.Setting.heli.heliMode)
    PED.SET_PED_KEEP_TASK(pilot, true)

    Bodyguard.Group.SetPedRelationship(pilot)
    Bodyguard.Heli.SetPedAttribute(pilot)

    -- Pilot Vehicle Weapon
    local heli_weapons = Bodyguard.Heli.heliWeapons[heli_hash]
    if heli_weapons ~= nil then
        WEAPON.SET_CURRENT_PED_VEHICLE_WEAPON(pilot, util.joaat(heli_weapons[1]))
    end

    Bodyguard.Heli.index = Bodyguard.Heli.index + 1
    Bodyguard.Heli.heliList[Bodyguard.Heli.index] = heli

    table.insert(Bodyguard.Heli.pedList, pilot)


    -- Other Members
    local members = {}
    local seats = VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(heli_hash) - 2
    for seat = 0, seats do
        local ped = create_ped(29, ped_hash, coords, heading)
        PED.SET_PED_INTO_VEHICLE(ped, heli, seat)

        Bodyguard.Group.SetPedRelationship(ped)
        Bodyguard.Heli.SetPedAttribute(ped)

        table.insert(Bodyguard.Heli.pedList, ped)
        table.insert(members, ped)
    end


    -- Generate Menu
    local menu_name = Bodyguard.Heli.index .. ". " .. Bodyguard.Heli.heliLabels[heli_hash]
    local heli_data = { heli = heli, pilot = pilot, members = members, heli_weapons = heli_weapons }
    Bodyguard.Heli.GenerateMenu(menu_name, Bodyguard.Heli.index, heli_data)


    Bodyguard.TickHandler()
end)

menu.divider(Bodyguard_Heli, "管理保镖直升机")

----------------
-- All Heli
----------------

local Bodyguard_Heli_All2 <const> = menu.list(Bodyguard_Heli, "所有保镖直升机", {}, "")

menu.action(Bodyguard_Heli_All2, "传送到我", {}, "", function()
    Bodyguard.Heli.AllHelis(function(heli)
        tp_entity_to_me(heli, math.random(-60, 60), math.random(-60, 60), 30)
    end)
end)
menu.textslider(Bodyguard_Heli_All2, "无敌", {}, "", { "设置", "取消" }, function(value)
    local toggle = true
    if value == 2 then
        toggle = false
    end

    Bodyguard.Heli.AllPeds(function(ped)
        set_entity_godmode(ped, toggle)
    end)
    Bodyguard.Heli.AllHelis(function(heli)
        set_entity_godmode(heli, toggle)
    end)
end)
menu.action(Bodyguard_Heli_All2, "恢复", {}, "恢复生命值，清理NPC血迹，修复载具", function()
    Bodyguard.Heli.AllPeds(function(ped)
        SET_ENTITY_HEALTH(ped, ENTITY.GET_ENTITY_MAX_HEALTH(ped))
        clear_ped_body(ped)
    end)
    Bodyguard.Heli.AllHelis(function(heli)
        SET_ENTITY_HEALTH(heli, ENTITY.GET_ENTITY_MAX_HEALTH(heli))
        fix_vehicle(heli)
    end)
end)
menu.textslider(Bodyguard_Heli_All2, "禁用直升机碰撞", {},
    "避免卡在墙里等情况，但可能会导致某些座位的NPC掉出载具", { "设置", "取消" }, function(value)
        local toggle = true
        if value == 2 then
            toggle = false
        end

        Bodyguard.Heli.AllHelis(function(heli)
            ENTITY.SET_ENTITY_COLLISION(heli, not toggle, true)
        end)
    end)
menu.divider(Bodyguard_Heli_All2, "删除")
menu.action(Bodyguard_Heli_All2, "删除已死亡", {}, "", function()
    for key, ent in pairs(Bodyguard.Heli.pedList) do
        if ENTITY.DOES_ENTITY_EXIST(ent) and ENTITY.IS_ENTITY_DEAD(ent) then
            entities.delete(ent)

            --table.remove(Bodyguard.Heli.pedList, key)
        end
    end
    for key, ent in pairs(Bodyguard.Heli.heliList) do
        if ENTITY.DOES_ENTITY_EXIST(ent) and ENTITY.IS_ENTITY_DEAD(ent) then
            entities.delete(ent)

            --table.remove(Bodyguard.Heli.heliList, key)
        end
    end
end)
menu.action(Bodyguard_Heli_All2, "删除全部", {}, "", function()
    for _, ent in pairs(Bodyguard.Heli.pedList) do
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            entities.delete(ent)
        end
    end
    for _, ent in pairs(Bodyguard.Heli.heliList) do
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            entities.delete(ent)
        end
    end
    Bodyguard.Heli.pedList = {}
    Bodyguard.Heli.heliList = {}

    rs_menu.delete_menu_list(Bodyguard.Heli.menuList)
    Bodyguard.Heli.index = 0
end)









--

menu.divider(Bodyguard_Options, "默认设置")

--------------------------------
-- Bodyguard NPC Setting
--------------------------------

local Bodyguard_NPC_Setting <const> = menu.list(Bodyguard_Options, "保镖NPC设置", {}, "")

menu.toggle(Bodyguard_NPC_Setting, "无敌", {}, "", function(toggle)
    Bodyguard.Setting.ped.godmode = toggle
end)
menu.slider(Bodyguard_NPC_Setting, "生命", { "bodyguard_npc_health" }, "",
    100, 100000, 5000, 100, function(value)
        Bodyguard.Setting.ped.health = value
    end)
menu.toggle(Bodyguard_NPC_Setting, "不会摔倒", {}, "", function(toggle)
    Bodyguard.Setting.ped.no_ragdoll = toggle
end)
menu.list_select(Bodyguard_NPC_Setting, "主武器", {}, "", RS_T.CommonWeapons,
    util.joaat("WEAPON_SPECIALCARBINE"), function(value)
        Bodyguard.Setting.ped.weapon_main = value
    end)
menu.list_select(Bodyguard_NPC_Setting, "副武器", {}, "", RS_T.CommonWeapons,
    util.joaat("WEAPON_MICROSMG"), function(value)
        Bodyguard.Setting.ped.weapon_secondary = value
    end)
menu.slider_float(Bodyguard_NPC_Setting, "武器伤害倍数", { "bodyguard_npc_weapon_damamge_modifier" }, "",
    0, 1000, 100, 50, function(value)
        Bodyguard.Setting.ped.weapon_damamge_modifier = value * 0.01
    end)
menu.list_select(Bodyguard_NPC_Setting, "行为", {}, "", Bodyguard.Group.Relationship, util.joaat("PLAYER"), function(value)
    Bodyguard.Setting.ped.relationship = value
end)



--------------------------------
-- Bodyguard Heli Setting
--------------------------------

local Bodyguard_Heli_Setting <const> = menu.list(Bodyguard_Options, "保镖直升机设置", {}, "")

menu.toggle(Bodyguard_Heli_Setting, "无敌", {}, "", function(toggle)
    Bodyguard.Setting.heli.godmode = toggle
end)
menu.slider(Bodyguard_Heli_Setting, "生命", { "bodyguard_heli_health" }, "", 100, 30000, 10000, 100,
    function(value)
        Bodyguard.Setting.heli.health = value
    end)
menu.divider(Bodyguard_Heli_Setting, "任务设置")
menu.slider(Bodyguard_Heli_Setting, "速度", { "bodyguard_heli_speed" }, "", 0, 10000, 300, 10,
    function(value)
        Bodyguard.Setting.heli.speed = value
    end)
menu.list_select(Bodyguard_Heli_Setting, "驾驶风格", {}, "", Ped_T.DrivingStyle.ListItem, 1, function(value)
    Bodyguard.Setting.heli.drivingStyle = Ped_T.DrivingStyle.ValueList[value]
end)
menu.slider_float(Bodyguard_Heli_Setting, "Custom Offset", { "bodyguard_heli_customOffset" }, "",
    -100000, 100000, -100, 10, function(value)
        Bodyguard.Setting.heli.customOffsets = value
    end)
menu.slider(Bodyguard_Heli_Setting, "地面上的最小高度", { "bodyguard_heli_minHeightAboveTerrain" }, "",
    0, 10000, 20, 1, function(value)
        Bodyguard.Setting.heli.minHeightAboveTerrain = value
    end)
menu.list_select(Bodyguard_Heli_Setting, "直升机模式", {}, "", Vehicle_T.HeliMode, 0, function(value)
    Bodyguard.Setting.heli.heliMode = value
end)
