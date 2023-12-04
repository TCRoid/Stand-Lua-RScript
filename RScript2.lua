--------------------------------
-- Author: Rostal
--------------------------------

util.require_natives("2944b", "init")

local SCRIPT_VERSION <const> = "2023/12/2"

local SUPPORT_GTAO <const> = 1.67



--------------------------------------
----------    File & Dir    ----------
--------------------------------------

-- Lib
local SCRIPT_LIB_DIR <const> = filesystem.scripts_dir() .. "lib\\RScript\\"
local REQUIRED_FILES <const> = {
    "Tables.lua",
    "alternatives.lua",
    "functions.lua",
    "functions2.lua",
    "libs2.lua",
    "utils.lua",
    "Menu\\Player.lua",
}
for _, file in pairs(REQUIRED_FILES) do
    local file_path = SCRIPT_LIB_DIR .. file
    if not filesystem.exists(file_path) then
        util.toast("[RScript] 缺少文件: " .. file_path, TOAST_ALL)
        util.toast("脚本已停止运行")
        util.stop_script()
    end
end

-- Require
require "RScript.Tables"
require "RScript.alternatives"
require "RScript.functions"
require "RScript.functions2"
require "RScript.libs2"
require "RScript.utils"





local Tunables <const> = {
    XM22_GUN_VAN_SLOT_WEAPON_TYPE_0 = 34094,

    -- Contact Mission
    CONTACT_MISSION_TIME_PERIOD_1 = 8523,
    CONTACT_MISSION_CASH_TIME_PERIOD_1_PERCENTAGE = 8532,
    CONTACT_MISSION_CASH_PLAYER_MULTIPLIER_1 = 8542,
    CONTACT_MISSION_CASH_DIFFICULTY_MULTIPLIER_EASY = 8550,
    CONTACT_MISSION_FAIL_CASH_TIME_PERIOD_2_DIVIDER = 8554,
    CONTACT_MISSION_RP_TIME_PERIOD_1_PERCENTAGE = 8574,
    CONTACT_MISSION_RP_DIFFICULTY_MULTIPLIER_EASY = 8585,
    CONTACT_MISSION_FAIL_RP_TIME_PERIOD_2_DIVIDER = 8564,

    -- Health & Armour
    MAX_HEALTH_MULTIPLIER = 107,
    HEALTH_REGEN_RATE_MULTIPLIER = 109,
    HEALTH_REGEN_MAX_MULTIPLIER = 110,
    MAX_ARMOR_MULTIPLIER = 112,

    CasinoHeist = {
        TargetWeighting = {
            29016, -- CH_VAULT_WEIGHTING_CASH
            29017, -- CH_VAULT_WEIGHTING_ART
            29018, -- CH_VAULT_WEIGHTING_GOLD
            29019, -- CH_VAULT_WEIGHTING_DIAMONDS
        },
    },

    PericoHeist = {
        TargetWeighting = {
            30118, -- H4_TARGET_WEIGHTING_TEQUILA
            30119, -- H4_TARGET_WEIGHTING_PEARL_NECKLACE
            30120, -- H4_TARGET_WEIGHTING_BEARER_BONDS
            30121, -- H4_TARGET_WEIGHTING_PINK_DIAMOND
            30122, -- H4_TARGET_WEIGHTING_SAPPHIRE_PANTHER_STATUE
        },
    },
}

local Globals <const> = {
    GunVanSpawnPoint = 1956855,
}


local Loop_Handler = {
    Tunables = {
        ContactMission = {},
    },
}





---------------------------------------------
----------    Script Menu Start    ----------
---------------------------------------------

if not SCRIPT_SILENT_START then
    local GTAO = tonumber(NETWORK.GET_ONLINE_VERSION())
    if SUPPORT_GTAO ~= GTAO then
        util.toast("支持的GTA线上版本: " .. SUPPORT_GTAO .. "\n当前GTA线上版本: " .. GTAO)
    end
end



Menu_Root = menu.my_root()

menu.divider(Menu_Root, "RScript2")




----------------------------------------------
----------    Nearby Ped Options    ----------
----------------------------------------------

local Nearby_Ped_Options <const> = menu.list(Menu_Root, "附近NPC选项", {}, "")

--#region Nearby Ped Options

local NearbyPed = {
    can_handler_run = false,
    is_handler_runing = false,

    setting = {
        radius = 60.0,
        ped_select = 1,
        time_delay = 1000,
        exclude_ped_in_vehicle = true,
        exclude_friendly = true,
        exclude_mission = true,
        exclude_dead = true,
    },
    toggles = {},
    data = {
        forward_degree = 30,
        drop_money_amount = 100,
        weapon_hash = 4130548542,
        launch_height = 30.0,
        force_field = {
            strength = 1.0,
            direction = 1,
            ragdoll = true,
        },
    },
    callback = {},
}

function NearbyPed.CheckPed(ped)
    -- 排除 玩家
    if is_player_ped(ped) then
        return false
    end
    -- 排除 载具内NPC
    if NearbyPed.setting.exclude_ped_in_vehicle and PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
        return false
    end
    -- 排除 友好NPC
    if NearbyPed.setting.exclude_friendly and is_friendly_ped(ped) then
        return false
    end
    -- 排除 任务NPC
    if NearbyPed.setting.exclude_mission and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ped) then
        return false
    end
    -- 排除 已死亡实体
    if NearbyPed.setting.exclude_dead and ENTITY.IS_ENTITY_DEAD(ped) then
        return false
    end
    -- 敌对NPC
    if NearbyPed.setting.ped_select == 2 and not is_hostile_ped(ped) then
        return false
    end

    return true
end

function NearbyPed.GetPeds()
    local peds = {}
    local player_pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    local radius = NearbyPed.setting.radius

    for k, ent in pairs(entities.get_all_peds_as_handles()) do
        local ped = 0

        local ent_pos = ENTITY.GET_ENTITY_COORDS(ent)
        if radius <= 0 then
            ped = ent
        elseif v3.distance(player_pos, ent_pos) <= radius then
            ped = ent
        end

        if ped ~= 0 and NearbyPed.CheckPed(ped) then
            table.insert(peds, ped)
        end
    end
    return peds
end

function NearbyPed.ToggleChanged(key, toggle)
    NearbyPed.toggles[key] = toggle

    NearbyPed.TickHandler()
end

function NearbyPed.TickHandler()
    local is_all_false = true
    for key, bool in pairs(NearbyPed.toggles) do
        if bool then
            is_all_false = false
            break
        end
    end
    if is_all_false then
        NearbyPed.can_handler_run = false
    else
        if not NearbyPed.is_handler_running then
            NearbyPed.can_handler_run = true
            NearbyPed.ControlPeds()
        end
    end
end

function NearbyPed.ControlPeds()
    util.create_tick_handler(function()
        if not NearbyPed.can_handler_run then
            NearbyPed.is_handler_running = false
            util.log("[RScript] Control Nearby Peds: Stop Tick Handler")
            return false
        end

        NearbyPed.is_handler_runing = true

        for _, ped in pairs(NearbyPed.GetPeds()) do
            request_control(ped)

            for key, bool in pairs(NearbyPed.toggles) do
                if bool then
                    if NearbyPed.callback[key] ~= nil then
                        NearbyPed.callback[key](ped)
                    end
                end
            end
        end

        util.yield(NearbyPed.setting.time_delay)
    end)
end

menu.slider_float(Nearby_Ped_Options, "范围半径", { "radius_nearby_ped" },
    "若半径是0, 则为全部范围", 0, 100000, 6000, 1000, function(value)
        NearbyPed.setting.radius = value * 0.01
    end)
menu.toggle_loop(Nearby_Ped_Options, "绘制范围", {}, "", function()
    local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    DRAW_MARKER_SPHERE(coords, NearbyPed.setting.radius)
end)
menu.list_select(Nearby_Ped_Options, "NPC类型", {}, "", {
    { "全部NPC", {}, "" },
    { "敌对NPC", {}, "" },
}, 1, function(value)
    NearbyPed.setting.ped_select = value
end)


--#region Nearby Ped Setting

local Nearby_Ped_Setting <const> = menu.list(Nearby_Ped_Options, "设置", {}, "")

menu.slider(Nearby_Ped_Setting, "循环时间间隔", { "delay_nearby_ped" }, "单位: ms",
    0, 5000, 1000, 100, function(value)
        NearbyPed.setting.time_delay = value
    end)
menu.divider(Nearby_Ped_Setting, "排除")
menu.toggle(Nearby_Ped_Setting, "排除 载具内NPC", {}, "", function(toggle)
    NearbyPed.setting.exclude_ped_in_vehicle = toggle
end, true)
menu.toggle(Nearby_Ped_Setting, "排除 友好NPC", {}, "", function(toggle)
    NearbyPed.setting.exclude_friendly = toggle
end, true)
menu.toggle(Nearby_Ped_Setting, "排除 任务NPC", {}, "", function(toggle)
    NearbyPed.setting.exclude_mission = toggle
end, true)
menu.toggle(Nearby_Ped_Setting, "排除 已死亡实体", {}, "", function(toggle)
    NearbyPed.setting.exclude_dead = toggle
end, true)

--#endregion Nearby Ped Setting



--#region Nearby Ped Trolling

local Nearby_Ped_Trolling <const> = menu.list(Nearby_Ped_Options, "恶搞选项", {}, "")

--------------------
-- Delay Loop
--------------------

menu.slider(Nearby_Ped_Trolling, "推进程度", { "nearby_ped_forward_degree" }, "",
    0, 1000, 30, 10, function(value)
        NearbyPed.data.forward_speed = value
    end)
menu.toggle(Nearby_Ped_Trolling, "设置向前推进", {}, "", function(toggle)
    NearbyPed.ToggleChanged("force_forward", toggle)

    NearbyPed.callback["force_forward"] = function(ped)
        ENTITY.SET_ENTITY_MAX_SPEED(ped, 99999)
        local vector = ENTITY.GET_ENTITY_FORWARD_VECTOR(ped)
        local force = Vector.mult(vector, NearbyPed.data.forward_degree)
        ENTITY.APPLY_FORCE_TO_ENTITY(ped,
            1,
            force.x, force.y, force.z,
            0.0, 0.0, 0.0,
            1,
            false, true, true, true, true)
    end
end)
menu.toggle(Nearby_Ped_Trolling, "丢弃武器", {}, "", function(toggle)
    NearbyPed.ToggleChanged("drop_weapon", toggle)

    NearbyPed.callback["drop_weapon"] = function(ped)
        WEAPON.SET_PED_DROPS_WEAPONS_WHEN_DEAD(ped)
        WEAPON.SET_PED_AMMO_TO_DROP(ped, 9999)
        WEAPON.SET_PED_DROPS_WEAPON(ped)
    end
end)
menu.toggle(Nearby_Ped_Trolling, "爆头", {}, "", function(toggle)
    NearbyPed.ToggleChanged("explode_head", toggle)

    NearbyPed.callback["explode_head"] = function(ped)
        local weaponHash = util.joaat("WEAPON_APPISTOL")
        PED.EXPLODE_PED_HEAD(ped, weaponHash)
    end
end)
menu.toggle(Nearby_Ped_Trolling, "摔倒", {}, "", function(toggle)
    NearbyPed.ToggleChanged("ragdoll", toggle)

    NearbyPed.callback["ragdoll"] = function(ped)
        PED.SET_PED_TO_RAGDOLL(ped, 500, 500, 0, false, false, false)
    end
end)
menu.toggle(Nearby_Ped_Trolling, "忽略临时事件", {}, "", function(toggle)
    NearbyPed.ToggleChanged("block_temporary", toggle)

    NearbyPed.callback["block_temporary"] = function(ped)
        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
        TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS_FOR_AMBIENT_PEDS_THIS_FRAME(true)
    end
end)
menu.toggle(Nearby_Ped_Trolling, "清除任务", {}, "", function(toggle)
    NearbyPed.ToggleChanged("clear_task", toggle)

    NearbyPed.callback["clear_task"] = function(ped)
        TASK.CLEAR_PED_TASKS(ped)
        TASK.CLEAR_DEFAULT_PRIMARY_TASK(ped)
        TASK.CLEAR_PED_SECONDARY_TASK(ped)
    end
end)
menu.toggle(Nearby_Ped_Trolling, "立即清除任务", {}, "", function(toggle)
    NearbyPed.ToggleChanged("clear_task_immediately", toggle)

    NearbyPed.callback["clear_task_immediately"] = function(ped)
        TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
    end
end)


--------------------
-- Once
--------------------

menu.divider(Nearby_Ped_Trolling, "")

menu.slider(Nearby_Ped_Trolling, "上天高度", { "nearby_ped_launch" }, "",
    0, 1000, 30, 10, function(value)
        NearbyPed.data.launch_height = value
    end)
menu.action(Nearby_Ped_Trolling, "发射上天", {}, "", function()
    for k, ped in pairs(NearbyPed.GetPeds()) do
        ENTITY.APPLY_FORCE_TO_ENTITY(ped,
            1,
            0.0, 0.0, NearbyPed.data.launch_height,
            0.0, 0.0, 0.0,
            0,
            false, false, true, false, false)
    end
end)
menu.action(Nearby_Ped_Trolling, "坠落爆炸", {}, "", function()
    for k, ped in pairs(NearbyPed.GetPeds()) do
        util.create_thread(function()
            fall_entity_explosion(ped)
        end)
    end
end)


--------------------
-- No Delay Loop
--------------------

menu.divider(Nearby_Ped_Trolling, "力场")

menu.slider_float(Nearby_Ped_Trolling, "强度", { "nearby_ped_forcefield_strength" }, "",
    100, 10000, 100, 100, function(value)
        NearbyPed.data.force_field.strength = value * 0.01
    end)
menu.textslider_stateful(Nearby_Ped_Trolling, "方向", {}, "", { "推开", "拉进" }, function(value)
    NearbyPed.data.force_field.direction = value
end)
menu.toggle(Nearby_Ped_Trolling, "摔倒", {}, "", function(toggle)
    NearbyPed.data.force_field.ragdoll = toggle
end, true)
menu.toggle_loop(Nearby_Ped_Trolling, "开启力场", {}, "", function()
    for k, ped in pairs(NearbyPed.GetPeds()) do
        local force = ENTITY.GET_ENTITY_COORDS(ped)
        v3.sub(force, ENTITY.GET_ENTITY_COORDS(players.user_ped()))
        v3.normalise(force)
        v3.mul(force, NearbyPed.data.force_field.strength)

        if NearbyPed.data.force_field.direction == 2 then
            v3.mul(force, -1)
        end
        if NearbyPed.data.force_field.ragdoll then
            PED.SET_PED_TO_RAGDOLL(ped, 500, 500, 0, false, false, false)
        end
        ENTITY.APPLY_FORCE_TO_ENTITY(ped,
            3,
            force.x, force.y, force.z,
            0, 0, 0.5,
            0,
            false, false, true, false, false)
    end
end)

--#endregion Nearby Ped Trolling



--#region Nearby Ped Friendly

local Nearby_Ped_Friendly <const> = menu.list(Nearby_Ped_Options, "友好选项", {}, "")

--------------------
-- Delay Loop
--------------------

menu.slider(Nearby_Ped_Friendly, "现金数量", { "nearby_ped_drop_money_amonut" }, "",
    0, 2000, 100, 100, function(value)
        NearbyPed.data.drop_money_amount = value
    end)
menu.toggle(Nearby_Ped_Friendly, "设置掉落现金", {}, "", function(toggle)
    NearbyPed.ToggleChanged("drop_money", toggle)

    NearbyPed.callback["drop_money"] = function(ped)
        PED.SET_PED_MONEY(ped, NearbyPed.data.drop_money_amount)
        PED.SET_AMBIENT_PEDS_DROP_MONEY(true)
    end
end)
menu.list_select(Nearby_Ped_Friendly, "武器", {}, "", RS_T.CommonWeapons.ListItem, 1, function(value)
    NearbyPed.data.weapon_hash = util.joaat(Weapon_Common.ModelList[value])
end)
menu.toggle(Nearby_Ped_Friendly, "给予武器", {}, "", function(toggle)
    NearbyPed.ToggleChanged("give_weapon", toggle)

    NearbyPed.callback["give_weapon"] = function(ped)
        WEAPON.GIVE_WEAPON_TO_PED(ped, NearbyPed.data.weapon_hash, -1, false, true)
        WEAPON.SET_CURRENT_PED_WEAPON(ped, NearbyPed.data.weapon_hash, false)
    end
end)

--#endregion Nearby Ped Friendly



--#region Nearby Ped Combat

local Nearby_Ped_Combat <const> = menu.list(Nearby_Ped_Options, "作战能力选项", {}, "")

NearbyPed.Combat = {
    health = 100,
    investigate = 1,
    weapon = 1,
    ability = 1,
    range = 1,
    movement = 1,
    target_loss_response = 1,
    behavior = 1,
}

menu.toggle_loop(Nearby_Ped_Combat, "设置作战能力", {}, "", function()
    local combat_data = NearbyPed.Combat

    for k, ped in pairs(NearbyPed.GetPeds()) do
        -- 生命值
        if combat_data.health >= 100 then
            SET_ENTITY_HEALTH(ped, combat_data.health)
        end
        -- 侦查能力
        if combat_data.investigate > 1 then
            if combat_data.investigate == 2 then
                -- 弱化
                PED.SET_PED_SEEING_RANGE(ped, 0)
                PED.SET_PED_HEARING_RANGE(ped, 0)
                PED.SET_PED_ID_RANGE(ped, 0)

                PED.SET_PED_VISUAL_FIELD_PERIPHERAL_RANGE(ped, 0)
                PED.SET_PED_VISUAL_FIELD_MIN_ANGLE(ped, 0)
                PED.SET_PED_VISUAL_FIELD_MAX_ANGLE(ped, 0)
                PED.SET_PED_VISUAL_FIELD_MIN_ELEVATION_ANGLE(ped, 0)
                PED.SET_PED_VISUAL_FIELD_MAX_ELEVATION_ANGLE(ped, 0)
                PED.SET_PED_VISUAL_FIELD_CENTER_ANGLE(ped, 0)

                PED.SET_PED_HIGHLY_PERCEPTIVE(ped, false)

                PED.SET_PED_COMBAT_ATTRIBUTES(ped, 14, false) -- CA_CAN_INVESTIGATE
                PED.SET_PED_COMBAT_ATTRIBUTES(ped, 79, false) -- CA_WILL_GENERATE_DEAD_PED_SEEN_SCRIPT_EVENTS
                PED.SET_PED_COMBAT_ATTRIBUTES(ped, 80, false) -- CA_USE_MAX_SENSE_RANGE_WHEN_RECEIVING_EVENTS

                PED.SET_COMBAT_FLOAT(ped, 14, 0)              -- CCF_BULLET_IMPACT_DETECTION_RANGE
                PED.SET_COMBAT_FLOAT(ped, 21, 0)              -- CCF_MAX_DISTANCE_TO_HEAR_EVENTS
                PED.SET_COMBAT_FLOAT(ped, 22, 0)              -- CCF_MAX_DISTANCE_TO_HEAR_EVENTS_USING_LOS

                PED.SET_PED_CONFIG_FLAG(ped, 213, false)      -- PCF_ListensToSoundEvents
                PED.SET_PED_CONFIG_FLAG(ped, 294, true)       -- PCF_DisableShockingEvents
                PED.SET_PED_CONFIG_FLAG(ped, 315, false)      -- PCF_CheckLoSForSoundEvents
            else
                -- 强化
                PED.SET_PED_SEEING_RANGE(ped, 500)
                PED.SET_PED_HEARING_RANGE(ped, 500)
                PED.SET_PED_ID_RANGE(ped, 500)

                PED.SET_PED_VISUAL_FIELD_PERIPHERAL_RANGE(ped, 100)
                PED.SET_PED_VISUAL_FIELD_MIN_ANGLE(ped, 90)
                PED.SET_PED_VISUAL_FIELD_MAX_ANGLE(ped, 90)
                PED.SET_PED_VISUAL_FIELD_MIN_ELEVATION_ANGLE(ped, 90)
                PED.SET_PED_VISUAL_FIELD_MAX_ELEVATION_ANGLE(ped, 90)
                PED.SET_PED_VISUAL_FIELD_CENTER_ANGLE(ped, 90)

                PED.SET_PED_HIGHLY_PERCEPTIVE(ped, true)

                PED.SET_PED_COMBAT_ATTRIBUTES(ped, 14, true) -- CA_CAN_INVESTIGATE
                PED.SET_PED_COMBAT_ATTRIBUTES(ped, 79, true) -- CA_WILL_GENERATE_DEAD_PED_SEEN_SCRIPT_EVENTS
                PED.SET_PED_COMBAT_ATTRIBUTES(ped, 80, true) -- CA_USE_MAX_SENSE_RANGE_WHEN_RECEIVING_EVENTS

                PED.SET_COMBAT_FLOAT(ped, 14, 100)           -- CCF_BULLET_IMPACT_DETECTION_RANGE
                PED.SET_COMBAT_FLOAT(ped, 21, 100)           -- CCF_MAX_DISTANCE_TO_HEAR_EVENTS
                PED.SET_COMBAT_FLOAT(ped, 22, 100)           -- CCF_MAX_DISTANCE_TO_HEAR_EVENTS_USING_LOS

                PED.SET_PED_CONFIG_FLAG(ped, 213, true)      -- PCF_ListensToSoundEvents
                PED.SET_PED_CONFIG_FLAG(ped, 294, false)     -- PCF_DisableShockingEvents
                PED.SET_PED_CONFIG_FLAG(ped, 315, true)      -- PCF_CheckLoSForSoundEvents
            end
        end
        -- 武器能力
        if combat_data.weapon > 1 then
            if combat_data.weapon == 2 then
                -- 弱化
                PED.SET_PED_ACCURACY(ped, 0)
                PED.SET_PED_SHOOT_RATE(ped, 0)
                PED.SET_PED_COMBAT_ATTRIBUTES(ped, 27, false) -- CA_PERFECT_ACCURACY
                PED.SET_COMBAT_FLOAT(ped, 6, 0)               -- CCF_WEAPON_ACCURACY
            else
                -- 强化
                PED.SET_PED_ACCURACY(ped, 100)
                PED.SET_PED_SHOOT_RATE(ped, 1000)
                PED.SET_PED_COMBAT_ATTRIBUTES(ped, 27, true) -- CA_PERFECT_ACCURACY
                PED.SET_COMBAT_FLOAT(ped, 6, 1.0)            -- CCF_WEAPON_ACCURACY
            end
        end
        -- 作战技能
        if combat_data.ability > 1 then
            PED.SET_PED_COMBAT_ABILITY(ped, combat_data.ability - 2)
        end
        -- 作战范围
        if combat_data.range > 1 then
            PED.SET_PED_COMBAT_RANGE(ped, combat_data.range - 2)
        end
        -- 作战走位
        if combat_data.movement > 1 then
            PED.SET_PED_COMBAT_MOVEMENT(ped, combat_data.movement - 2)
        end
        -- 失去目标时反应
        if combat_data.target_loss_response > 1 then
            PED.SET_PED_TARGET_LOSS_RESPONSE(ped, combat_data.target_loss_response - 2)
        end
        -- 其它行为
        if NearbyPed.Combat.behavior == 2 then
            PED.STOP_PED_WEAPON_FIRING_WHEN_DROPPED(ped)
            PED.DISABLE_PED_INJURED_ON_GROUND_BEHAVIOUR(ped)
            PED.REMOVE_PED_DEFENSIVE_AREA(ped, false)
        end
    end

    util.yield(NearbyPed.setting.time_delay)
end)

menu.divider(Nearby_Ped_Combat, "设置")
menu.slider(Nearby_Ped_Combat, "生命值", { "nearby_ped_combat_health" }, "数值低于100则不进行修改",
    0, 10000, 100, 100, function(value)
        NearbyPed.Combat.health = value
    end)
menu.list_select(Nearby_Ped_Combat, "侦查能力", {},
    "视力、听力、识别、锥形视野、视野角度、高度警觉性 等等", {
        { "无操作", {}, "" },
        { "弱化", {}, "" },
        { "强化", {}, "" },
    }, 1, function(value)
        NearbyPed.Combat.investigate = value
    end)
menu.list_select(Nearby_Ped_Combat, "武器能力", {},
    "精准度、射击频率", {
        { "无操作", {}, "" },
        { "弱化", {}, "" },
        { "强化", {}, "" },
    }, 1, function(value)
        NearbyPed.Combat.weapon = value
    end)
menu.list_select(Nearby_Ped_Combat, "作战技能", {}, "", {
    "无操作", "弱", "普通", "专业"
}, 1, function(value)
    NearbyPed.Combat.ability = value
end)
menu.list_select(Nearby_Ped_Combat, "作战范围", {}, "", {
    "无操作", "近", "中等", "远", "非常远"
}, 1, function(value)
    NearbyPed.Combat.range = value
end)
menu.list_select(Nearby_Ped_Combat, "作战走位", {}, "", {
    "无操作", "站立", "防卫", "会前进", "会后退"
}, 1, function(value)
    NearbyPed.Combat.movement = value
end)
menu.list_select(Nearby_Ped_Combat, "失去目标时反应", {}, "", {
    "无操作", "退出战斗", "从不失去目标", "寻找目标"
}, 1, function(value)
    NearbyPed.Combat.target_loss_response = value
end)
menu.list_select(Nearby_Ped_Combat, "其它行为", {},
    "武器掉落时走火、受伤时在地面打滚、防卫区域", {
        { "无操作", {}, "" },
        { "禁用", {}, "" },
    }, 1, function(value)
        NearbyPed.Combat.behavior = value
    end)

--#endregion Nearby Ped Combat


--#endregion Nearby Ped Options




--------------------------------------------------
----------    Nearby Vehicle Options    ----------
--------------------------------------------------

local Nearby_Vehicle_Options <const> = menu.list(Menu_Root, "附近载具选项", {}, "")

--#region Nearby Vehicle Options

local NearbyVehicle = {
    can_handler_run = false,
    is_handler_runing = false,

    setting = {
        radius = 60.0,
        vehicle_select = 1,
        time_delay = 1000,
        exclude_player = true,
        exclude_mission = true,
        exclude_dead = true,
    },
    toggles = {},
    data = {
        forward_speed = 30,
        max_speed = 0,
        alpha = 0,
        force_field = 1.0,
        launch_height = 30.0,
    },
    callback = {},
}

function NearbyVehicle.CheckVehicle(vehicle)
    -- 排除 玩家载具
    if NearbyVehicle.setting.exclude_player and is_player_vehicle(vehicle) then
        return false
    end
    -- 排除 任务载具
    if NearbyVehicle.setting.exclude_mission and ENTITY.IS_ENTITY_A_MISSION_ENTITY(vehicle) then
        return false
    end
    -- 排除 已死亡实体
    if NearbyVehicle.setting.exclude_dead and ENTITY.IS_ENTITY_DEAD(vehicle) then
        return false
    end
    -- NPC载具
    if NearbyVehicle.setting.vehicle_select == 2 then
        local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1, false)
        if not ENTITY.IS_ENTITY_A_PED(driver) then
            return false
        end
    end
    -- 敌对载具
    if NearbyVehicle.setting.vehicle_select == 3 and not is_hostile_entity(vehicle) then
        return false
    end
    -- 空载具
    if NearbyVehicle.setting.vehicle_select == 4 and not VEHICLE.IS_VEHICLE_SEAT_FREE(vehicle, -1, false) then
        return false
    end

    return true
end

function NearbyVehicle.GetVehicles()
    local vehicles = {}
    local player_pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    local radius = NearbyVehicle.setting.radius

    for k, ent in pairs(entities.get_all_vehicles_as_handles()) do
        local vehicle = 0

        local ent_pos = ENTITY.GET_ENTITY_COORDS(ent)
        if radius <= 0 then
            vehicle = ent
        elseif v3.distance(player_pos, ent_pos) <= radius then
            vehicle = ent
        end

        if vehicle ~= 0 and NearbyVehicle.CheckVehicle(vehicle) then
            table.insert(vehicles, vehicle)
        end
    end

    return vehicles
end

function NearbyVehicle.ToggleChanged(key, toggle)
    NearbyVehicle.toggles[key] = toggle

    NearbyVehicle.TickHandler()
end

function NearbyVehicle.SelectChanged(key, value)
    if value == 1 then
        NearbyVehicle.toggles[key] = false
    else
        NearbyVehicle.toggles[key] = true
    end

    NearbyVehicle.TickHandler()
end

function NearbyVehicle.TickHandler()
    local is_all_false = true
    for key, bool in pairs(NearbyVehicle.toggles) do
        if bool then
            is_all_false = false
            break
        end
    end
    if is_all_false then
        NearbyVehicle.can_handler_run = false
    else
        if not NearbyVehicle.is_handler_running then
            NearbyVehicle.can_handler_run = true
            NearbyVehicle.ControlVehicles()
        end
    end
end

function NearbyVehicle.ControlVehicles()
    util.create_tick_handler(function()
        if not NearbyVehicle.can_handler_run then
            NearbyVehicle.is_handler_running = false
            util.log("[RScript] Control Nearby Vehicles: Stop Tick Handler")
            return false
        end

        NearbyVehicle.is_handler_running = true

        for _, vehicle in pairs(NearbyVehicle.GetVehicles()) do
            request_control(vehicle)

            for key, bool in pairs(NearbyVehicle.toggles) do
                if bool then
                    if NearbyVehicle.callback[key] ~= nil then
                        NearbyVehicle.callback[key](vehicle)
                    end
                end
            end
        end

        util.yield(NearbyVehicle.setting.time_delay)
    end)
end

menu.slider_float(Nearby_Vehicle_Options, "范围半径", { "radius_nearby_vehicle" },
    "若半径是0, 则为全部范围", 0, 100000, 6000, 1000, function(value)
        NearbyVehicle.setting.radius = value * 0.01
    end)
menu.toggle_loop(Nearby_Vehicle_Options, "绘制范围", {}, "", function()
    local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    DRAW_MARKER_SPHERE(coords, NearbyVehicle.setting.radius)
end)

menu.list_select(Nearby_Vehicle_Options, "载具类型", {}, "", {
    { "全部载具", {}, "" },
    { "NPC载具", {}, "有NPC作为司机驾驶的载具" },
    { "敌对载具", {}, "有敌对地图标记点或敌对NPC驾驶的载具" },
    { "空载具", {}, "无人驾驶的载具" },
}, 1, function(value)
    NearbyVehicle.setting.vehicle_select = value
end)


--#region Nearby Vehicle Setting

local Nearby_Vehicle_Setting <const> = menu.list(Nearby_Vehicle_Options, "设置", {}, "")

menu.slider(Nearby_Vehicle_Setting, "循环时间间隔", { "delay_nearby_vehicle" }, "单位: ms",
    0, 5000, 1000, 100, function(value)
        NearbyVehicle.setting.time_delay = value
    end)
menu.divider(Nearby_Vehicle_Setting, "排除")
menu.toggle(Nearby_Vehicle_Setting, "排除 玩家载具", {}, "", function(toggle)
    NearbyVehicle.setting.exclude_player = toggle
end, true)
menu.toggle(Nearby_Vehicle_Setting, "排除 任务载具", {}, "", function(toggle)
    NearbyVehicle.setting.exclude_mission = toggle
end, true)
menu.toggle(Nearby_Vehicle_Setting, "排除 已死亡实体", {}, "", function(toggle)
    NearbyVehicle.setting.exclude_dead = toggle
end, true)

--#endregion Nearby Vehicle Setting



--#region Nearby Vehicle Trolling

local Nearby_Vehicle_Trolling <const> = menu.list(Nearby_Vehicle_Options, "恶搞选项", {}, "")

----------------------
-- Delay Loop
----------------------

menu.toggle(Nearby_Vehicle_Trolling, "移除无敌", {}, "", function(toggle)
    NearbyVehicle.ToggleChanged("remove_godmode", toggle)

    NearbyVehicle.callback["remove_godmode"] = function(vehicle)
        set_entity_godmode(vehicle, false)
    end
end)
menu.list_select(Nearby_Vehicle_Trolling, "车门", {}, "", {
    "无操作", "打开", "拆下", "删除"
}, 1, function(value)
    NearbyVehicle.SelectChanged("door", value)

    if value == 2 then
        NearbyVehicle.callback["door"] = function(vehicle)
            for i = 0, 3 do
                if VEHICLE.GET_IS_DOOR_VALID(vehicle, i) then
                    VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, i, false, false)
                end
            end
        end
    elseif value == 3 then
        NearbyVehicle.callback["door"] = function(vehicle)
            for i = 0, 3 do
                if VEHICLE.GET_IS_DOOR_VALID(vehicle, i) then
                    VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, i, false)
                end
            end
        end
    elseif value == 4 then
        NearbyVehicle.callback["door"] = function(vehicle)
            for i = 0, 3 do
                if VEHICLE.GET_IS_DOOR_VALID(vehicle, i) then
                    VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, i, true)
                end
            end
        end
    end
end)
menu.list_select(Nearby_Vehicle_Trolling, "车窗", {}, "", {
    "无操作", "删除", "破坏"
}, 1, function(value)
    NearbyVehicle.SelectChanged("window", value)

    if value == 2 then
        NearbyVehicle.callback["window"] = function(vehicle)
            for i = 0, 7 do
                VEHICLE.REMOVE_VEHICLE_WINDOW(vehicle, i)
            end
        end
    elseif value == 3 then
        NearbyVehicle.callback["window"] = function(vehicle)
            for i = 0, 7 do
                VEHICLE.SMASH_VEHICLE_WINDOW(vehicle, i)
            end
        end
    end
end)
menu.toggle(Nearby_Vehicle_Trolling, "破坏引擎", {}, "", function(toggle)
    NearbyVehicle.ToggleChanged("kill_engine", toggle)

    NearbyVehicle.callback["kill_engine"] = function(vehicle)
        VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, -4000)
    end
end)
menu.toggle(Nearby_Vehicle_Trolling, "爆胎", {}, "", function(toggle)
    NearbyVehicle.ToggleChanged("burst_tyre", toggle)

    NearbyVehicle.callback["burst_tyre"] = function(vehicle)
        for i = 0, 5 do
            if not VEHICLE.IS_VEHICLE_TYRE_BURST(vehicle, i, true) then
                VEHICLE.SET_VEHICLE_TYRE_BURST(vehicle, i, true, 1000.0)
            end
        end
    end
end)
menu.toggle(Nearby_Vehicle_Trolling, "布满灰尘", {}, "", function(toggle)
    NearbyVehicle.ToggleChanged("full_dirt", toggle)

    NearbyVehicle.callback["full_dirt"] = function(vehicle)
        VEHICLE.SET_VEHICLE_DIRT_LEVEL(vehicle, 15.0)
    end
end)
menu.toggle(Nearby_Vehicle_Trolling, "分离车轮", {}, "", function(toggle)
    NearbyVehicle.ToggleChanged("detach_wheel", toggle)

    NearbyVehicle.callback["detach_wheel"] = function(vehicle)
        for i = 0, 5 do
            entities.detach_wheel(vehicle, i)
        end
    end
end)
menu.toggle(Nearby_Vehicle_Trolling, "司机跳出载具", {}, "", function(toggle)
    NearbyVehicle.ToggleChanged("leave_vehicle", toggle)

    NearbyVehicle.callback["leave_vehicle"] = function(vehicle)
        local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
        if ped ~= 0 and not TASK.GET_IS_TASK_ACTIVE(ped, 176) then
            TASK.TASK_LEAVE_VEHICLE(ped, vehicle, 4160)
        end
    end
end)
menu.list_select(Nearby_Vehicle_Trolling, "爆炸", {}, "", {
    "无操作", "匿名爆炸", "署名爆炸"
}, 1, function(value)
    NearbyVehicle.SelectChanged("explosion", value)

    if value == 2 then
        NearbyVehicle.callback["explosion"] = function(vehicle)
            local pos = ENTITY.GET_ENTITY_COORDS(vehicle)
            add_explosion(pos)
        end
    elseif value == 3 then
        NearbyVehicle.callback["explosion"] = function(vehicle)
            local pos = ENTITY.GET_ENTITY_COORDS(vehicle)
            add_owned_explosion(players.user_ped(), pos)
        end
    end
end)

menu.slider(Nearby_Vehicle_Trolling, "加速度", { "nearby_veh_forward_speed" }, "",
    0, 1000, 30, 10, function(value)
        NearbyVehicle.data.forward_speed = value
    end)
menu.toggle(Nearby_Vehicle_Trolling, "设置向前加速", {}, "", function(toggle)
    NearbyVehicle.ToggleChanged("forward_speed", toggle)

    NearbyVehicle.callback["forward_speed"] = function(vehicle)
        VEHICLE.SET_VEHICLE_FORWARD_SPEED(vehicle, NearbyVehicle.data.forward_speed)
    end
end)

menu.slider(Nearby_Vehicle_Trolling, "最大速度", { "nearby_veh_max_speed" }, "",
    0, 1000, 0, 10, function(value)
        NearbyVehicle.data.max_speed = value
    end)
menu.toggle(Nearby_Vehicle_Trolling, "设置实体最大速度", {}, "", function(toggle)
    NearbyVehicle.ToggleChanged("max_speed", toggle)

    NearbyVehicle.callback["max_speed"] = function(vehicle)
        ENTITY.SET_ENTITY_MAX_SPEED(vehicle, NearbyVehicle.data.max_speed)
    end
end)

menu.slider(Nearby_Vehicle_Trolling, "透明度", { "nearby_veh_alpha" },
    "Ranging from 0 to 255 but chnages occur after every 20 percent (after every 51).", 0, 255, 0, 5, function(value)
        NearbyVehicle.data.alpha = value
    end)
menu.toggle(Nearby_Vehicle_Trolling, "设置透明度", {}, "", function(toggle)
    NearbyVehicle.ToggleChanged("alpha", toggle)

    NearbyVehicle.callback["alpha"] = function(vehicle)
        ENTITY.SET_ENTITY_ALPHA(vehicle, NearbyVehicle.data.alpha, false)
    end
end)


----------------------
-- No Delay Loop
----------------------

menu.divider(Nearby_Vehicle_Trolling, "")

menu.toggle_loop(Nearby_Vehicle_Trolling, "强行停止", {}, "", function()
    for k, vehicle in pairs(NearbyVehicle.GetVehicles()) do
        VEHICLE.SET_VEHICLE_FORWARD_SPEED(vehicle, 0)
    end
end)

menu.slider_float(Nearby_Vehicle_Trolling, "力场强度", { "nearby_veh_forcefield" }, "",
    100, 10000, 100, 100, function(value)
        NearbyVehicle.data.force_field = value * 0.01
    end)
menu.toggle_loop(Nearby_Vehicle_Trolling, "力场 (推开)", {}, "", function()
    for k, vehicle in pairs(NearbyVehicle.GetVehicles()) do
        local force = ENTITY.GET_ENTITY_COORDS(vehicle)
        v3.sub(force, ENTITY.GET_ENTITY_COORDS(players.user_ped()))
        v3.normalise(force)
        v3.mul(force, NearbyVehicle.data.force_field)
        ENTITY.APPLY_FORCE_TO_ENTITY(vehicle,
            3,
            force.x, force.y, force.z,
            0, 0, 0.5,
            0,
            false, false, true, false, false)
    end
end)


----------------------
-- Once
----------------------

menu.divider(Nearby_Vehicle_Trolling, "")

menu.action(Nearby_Vehicle_Trolling, "颠倒", {}, "", function()
    for k, vehicle in pairs(NearbyVehicle.GetVehicles()) do
        ENTITY.APPLY_FORCE_TO_ENTITY(vehicle,
            1,
            0.0, 0.0, 5.0,
            5.0, 0.0, 0.0,
            0,
            false, true, true, true, true)
    end
end)
menu.action(Nearby_Vehicle_Trolling, "随机喷漆", {}, "", function()
    for k, vehicle in pairs(NearbyVehicle.GetVehicles()) do
        local primary, secundary = get_random_colour(), get_random_colour()
        VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(vehicle, primary.r, primary.g, primary.b)
        VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(vehicle, secundary.r, secundary.g, secundary.b)
    end
end)

menu.slider(Nearby_Vehicle_Trolling, "上天高度", { "nearby_veh_launch" }, "",
    0, 1000, 30, 10, function(value)
        NearbyVehicle.data.launch_height = value
    end)
menu.action(Nearby_Vehicle_Trolling, "发射上天", {}, "", function()
    for k, vehicle in pairs(NearbyVehicle.GetVehicles()) do
        ENTITY.APPLY_FORCE_TO_ENTITY(vehicle,
            1,
            0.0, 0.0, NearbyVehicle.data.launch_height,
            0.0, 0.0, 0.0,
            0,
            false, false, true, false, false)
    end
end)

--#endregion Nearby Vehicle Trolling



--#region Nearby Vehicle Friendly

local Nearby_Vehicle_Friendly <const> = menu.list(Nearby_Vehicle_Options, "友好选项", {}, "")

----------------------
-- Delay Loop
----------------------

menu.toggle(Nearby_Vehicle_Friendly, "给予无敌", {}, "", function(toggle)
    NearbyVehicle.ToggleChanged("give_godmode", toggle)

    NearbyVehicle.callback["give_godmode"] = function(vehicle)
        set_entity_godmode(vehicle, true)
    end
end)
menu.toggle(Nearby_Vehicle_Friendly, "修复载具", {}, "", function(toggle)
    NearbyVehicle.ToggleChanged("fix_vehicle", toggle)

    NearbyVehicle.callback["fix_vehicle"] = function(vehicle)
        fix_vehicle(vehicle)
    end
end)
menu.toggle(Nearby_Vehicle_Friendly, "修复引擎", {}, "", function(toggle)
    NearbyVehicle.ToggleChanged("fix_engine", toggle)

    NearbyVehicle.callback["fix_engine"] = function(vehicle)
        VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, 1000)
    end
end)
menu.toggle(Nearby_Vehicle_Friendly, "修复车胎", {}, "", function(toggle)
    NearbyVehicle.ToggleChanged("fix_tyre", toggle)

    NearbyVehicle.callback["fix_tyre"] = function(vehicle)
        for i = 0, 5 do
            VEHICLE.SET_VEHICLE_TYRE_FIXED(vehicle, i)
        end
    end
end)
menu.toggle(Nearby_Vehicle_Friendly, "修复车窗", {}, "", function(toggle)
    NearbyVehicle.ToggleChanged("fix_window", toggle)

    NearbyVehicle.callback["fix_window"] = function(vehicle)
        for i = 0, 7 do
            VEHICLE.FIX_VEHICLE_WINDOW(vehicle, i)
        end
    end
end)
menu.toggle(Nearby_Vehicle_Friendly, "清洁外观", {}, "", function(toggle)
    NearbyVehicle.ToggleChanged("clean_dirt", toggle)

    NearbyVehicle.callback["clean_dirt"] = function(vehicle)
        VEHICLE.SET_VEHICLE_DIRT_LEVEL(vehicle, 0.0)
    end
end)
menu.toggle(Nearby_Vehicle_Friendly, "升级载具", {}, "", function(toggle)
    NearbyVehicle.ToggleChanged("upgrade_vehicle", toggle)

    NearbyVehicle.callback["upgrade_vehicle"] = function(vehicle)
        upgrade_vehicle(vehicle)
    end
end)

--#endregion Nearby Vehicle Friendly


--#endregion Nearby Vehicle Options





-------------------------------------------
----------    Session Options    ----------
-------------------------------------------

local Session_Options <const> = menu.list(Menu_Root, "战局选项", {}, "")

--#region Block Area Options

local Block_Area_Options <const> = menu.list(Session_Options, "阻挡区域", {}, "")

local block_area_data = {
    area_ListItem = {
        { "改车王" },
        { "武器店" },
        { "带靶场的武器店" },
        { "理发店" },
        { "服装店" },
        { "纹身店" },
        { "商店" },
    },
    object_ListItem = {
        { "UFO" },
    },
    object_ListData = {
        -- hash, type
        { 1241740398, "object" },
    },
    setting = {
        area = 1,
        obj = 1,
        visible = true,
        freeze = true,
        no_collision = false,
    },
}

local block_area_AreaData = {
    -- { x, y, z }
    {
        -- radar_car_mod_shop 72
        { 1174.7074,  2644.4497,  36.7552 },
        { 113.2615,   6624.2803,  30.7871 },
        { -354.5272,  -135.4011,  38.1850 },
        { 724.5240,   -1089.0811, 21.1692 },
        { -1147.3138, -1992.4344, 12.1803 },
    },
    {
        -- radar_gun_shop 110
        { 1697.9788,  3753.2002,  33.7053 },
        { -1111.2375, 2688.4626,  17.6131 },
        { 2569.6116,  302.5760,   107.7349 },
        { -325.8904,  6077.0264,  30.4548 },
        { 245.2711,   -45.8126,   68.9410 },
        { 844.1248,   -1025.5707, 27.1948 },
        { -1313.9485, -390.9637,  35.5920 },
        { -664.2178,  -943.3646,  20.8292 },
        { -3165.2307, 1082.8551,  19.8438 },
    },
    {
        -- radar_shootingrange_gunshop 313
        { 17.6804,  -1114.2880, 28.7970 },
        { 811.8699, -2149.1016, 28.6363 },
    },
    {
        -- radar_barber 71
        { 1933.1191,  3726.0791,  31.8444 },
        { -280.8165,  6231.7705,  30.6955 },
        { 1208.3335,  -470.9170,  65.2080 },
        { -30.7448,   -148.4921,  56.0765 },
        { -821.9946,  -187.1776,  36.5689 },
        { 133.5702,   -1710.9180, 28.2916 },
        { -1287.0822, -1116.5576, 5.9901 },
    },
    {
        -- radar_clothes_store 73
        { 80.6650,    -1391.6694, 28.3761 },
        { 419.5310,   -807.5787,  28.4896 },
        { -818.6218,  -1077.5330, 10.3282 },
        { -158.2199,  -304.9663,  38.7350 },
        { 126.6853,   -212.5027,  53.5578 },
        { -715.3598,  -155.7742,  36.4105 },
        { -1199.8092, -776.6886,  16.3237 },
        { -1455.0045, -233.1862,  48.7936 },
        { -3168.9663, 1055.2869,  19.8632 },
        { 618.1857,   2752.5667,  41.0881 },
        { -1094.0487, 2704.1707,  18.0873 },
        { 1197.9722,  2704.2205,  37.1572 },
        { 1687.8812,  4820.5498,  41.0096 },
        { -0.2361,    6516.0454,  30.8684 },
    },
    {
        -- radar_tattoo 75
        { -1153.9481, -1425.0186, 3.9544 },
        { 321.6098,   179.4165,   102.5865 },
        { 1322.4547,  -1651.1252, 51.1885 },
        { -3169.4204, 1074.7272,  19.8343 },
        { 1861.6853,  3750.0798,  32.0318 },
        { -290.1603,  6199.0947,  30.4871 },
    },
    {
        -- radar_crim_holdups 52
        { 1965.0542,  3740.5552,  31.3448 },
        { 1394.1692,  3599.8601,  34.0121 },
        { 2682.0034,  3282.5432,  54.2411 },
        { 1698.8085,  4929.1978,  41.0783 },
        { 1166.3920,  2703.5042,  37.1573 },
        { 544.2802,   2672.8113,  41.1566 },
        { 1731.2098,  6411.4033,  34.0372 },
        { 2559.2471,  385.5266,   107.6230 },
        { 376.6533,   323.6471,   102.5664 },
        { 1159.5421,  -326.6986,  67.9230 },
        { 1141.3596,  -980.8802,  45.4155 },
        { -1822.2866, 788.0060,   137.1859 },
        { -711.7210,  -916.6965,  18.2145 },
        { -1491.0565, -383.5728,  39.1706 },
        { 29.0641,    -1349.2128, 28.5036 },
        { -1226.4644, -902.5864,  11.2783 },
        { -53.1240,   -1756.4054, 28.4210 },
        { -3240.3169, 1004.4334,  11.8307 },
        { -3038.9082, 589.5187,   6.9048 },
        { -2973.2617, 390.8184,   14.0433 },
    }
}

menu.list_select(Block_Area_Options, "选择区域", {}, "", block_area_data.area_ListItem, 1, function(value)
    block_area_data.setting.area = value
end)
menu.action(Block_Area_Options, "阻挡", {}, "", function()
    local count = 0
    local hash = block_area_data.object_ListData[block_area_data.setting.obj][1]
    local Type = block_area_data.object_ListData[block_area_data.setting.obj][2]
    local ent = 0
    local area = block_area_AreaData[block_area_data.setting.area]

    request_model(hash)
    for k, pos in pairs(area) do
        if Type == "object" then
            ent = entities.create_object(hash, v3.new(pos[1], pos[2], pos[3] + 1.0))
        end

        if ENTITY.DOES_ENTITY_EXIST(ent) then
            ENTITY.FREEZE_ENTITY_POSITION(ent, block_area_data.setting.freeze)
            ENTITY.SET_ENTITY_VISIBLE(ent, block_area_data.setting.visible, 0)
            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ent, true, false)
            ENTITY.SET_ENTITY_INVINCIBLE(ent, true)
            ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION(ent, true)
            set_entity_networked(ent, false)

            if block_area_data.setting.no_collision then
                ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(ent, players.user_ped(), false)
                ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(players.user_ped(), ent, false)
            end

            count = count + 1
        end
    end

    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
    util.toast("阻挡完成！\n阻挡区域: " .. count .. " 个")
end)


menu.divider(Block_Area_Options, "设置")
menu.list_select(Block_Area_Options, "阻挡物体", {}, "", block_area_data.object_ListItem, 1, function(value)
    block_area_data.setting.obj = value
end)
menu.toggle(Block_Area_Options, "冻结", {}, "", function(toggle)
    block_area_data.setting.freeze = toggle
end, true)
menu.toggle(Block_Area_Options, "可见", {}, "", function(toggle)
    block_area_data.setting.visible = toggle
end, true)
menu.toggle(Block_Area_Options, "与玩家自身没有碰撞", {}, "玩家自身可以穿过这些阻挡物",
    function(toggle)
        block_area_data.setting.no_collision = toggle
    end)


menu.divider(Block_Area_Options, "特定阻挡")
menu.action(Block_Area_Options, "阻挡天基炮", {}, "会生成一个阻挡天基炮房间的铁门", function()
    local hash = util.joaat("h4_prop_h4_garage_door_01a")
    local coords = v3(335.9, 4833.9, -59.0)

    request_model(hash)
    local ent = entities.create_object(hash, coords)
    set_entity_networked(ent, false)
    ENTITY.SET_ENTITY_HEADING(ent, 125.0)
    ENTITY.FREEZE_ENTITY_POSITION(ent, true)
    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ent, true, false)

    ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(ent, players.user_ped(), false)
    ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(players.user_ped(), ent, false)

    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
    util.toast("完成！")
end)

--#endregion Block Area Options


--#region Population Density

local Population_Density <const> = menu.list(Session_Options, "交通人口密度", {}, "")

menu.action(Population_Density, "立刻充满行人", { "fill_ped_population" }, "", function()
    PED.INSTANTLY_FILL_PED_POPULATION()
end)
menu.action(Population_Density, "立刻充满交通", { "fill_vehicle_population" }, "", function()
    VEHICLE.INSTANTLY_FILL_VEHICLE_POPULATION()
end)

-----
local Population_Density_Frame <const> = menu.list(Population_Density, "设置交通人口密度", {}, "")
local population_density_frame = {
    ped = 1.0,
    random_vehicle = 1.0,
    parked_vehicle = 1.0,
}

menu.toggle_loop(Population_Density_Frame, "开启", {}, "", function()
    PED.SET_PED_DENSITY_MULTIPLIER_THIS_FRAME(population_density_frame.ped)
    VEHICLE.SET_RANDOM_VEHICLE_DENSITY_MULTIPLIER_THIS_FRAME(population_density_frame.random_vehicle)
    VEHICLE.SET_PARKED_VEHICLE_DENSITY_MULTIPLIER_THIS_FRAME(population_density_frame.parked_vehicle)
end)
menu.slider_float(Population_Density_Frame, "Ped", { "population_density_frame_ped" }, "",
    0, 100, 100, 10, function(value)
        population_density_frame.ped = value * 0.01
    end)
menu.slider_float(Population_Density_Frame, "Random Vehicle", { "population_density_frame_random_vehicle" }, "",
    0, 100, 100, 10, function(value)
        population_density_frame.random_vehicle = value * 0.01
    end)
menu.slider_float(Population_Density_Frame, "Parked Vehicle", { "population_density_frame_parked_vehicle" }, "",
    0, 100, 100, 10, function(value)
        population_density_frame.parked_vehicle = value * 0.01
    end)


-----
local Population_Density_Sphere <const> = menu.list(Population_Density, "覆盖交通人口密度", {},
    "添加一个新的交通人口密度范围覆盖当前交通人口密度")

local population_density_sphere = {
    id = 0,
    pedDensity = 1.0,
    trafficDensity = 1.0,
    localOnly = false,
}

menu.toggle(Population_Density_Sphere, "覆盖范围", {}, "切换战局后会失效，需要重新操作",
    function(toggle)
        if toggle then
            population_density_sphere.id = MISC.ADD_POP_MULTIPLIER_SPHERE(1.1, 1.1, 1.1, 15000.0,
                population_density_sphere.pedDensity, population_density_sphere.trafficDensity,
                population_density_sphere.localOnly, true)
            MISC.CLEAR_AREA(1.1, 1.1, 1.1, 19999.9, true, false, false, true)
        else
            if MISC.DOES_POP_MULTIPLIER_SPHERE_EXIST(population_density_sphere.id) then
                MISC.REMOVE_POP_MULTIPLIER_SPHERE(population_density_sphere.id, false)
            end
        end
    end)
menu.divider(Population_Density_Sphere, "设置")
menu.slider_float(Population_Density_Sphere, "人口密度", { "population_density_sphere_pedDensity" }, "",
    0, 100, 100, 10, function(value)
        population_density_sphere.pedDensity = value * 0.01
    end)
menu.slider_float(Population_Density_Sphere, "交通密度", { "population_density_sphere_trafficDensity" }, "",
    0, 100, 100, 10, function(value)
        population_density_sphere.trafficDensity = value * 0.01
    end)
menu.toggle(Population_Density_Sphere, "仅本地有效", {}, "", function(toggle)
    population_density_sphere.localOnly = toggle
end)

--#endregion Population Density




-------------------------------------------
----------    Mission Options    ----------
-------------------------------------------

local Mission_Options <const> = menu.list(Menu_Root, "任务选项", {}, "")

--#region Heist Cut Editor

local Heist_Cut_Editor <const> = menu.list(Mission_Options, "抢劫分红编辑", {}, "")

local HeistCut = {
    ListItem = {
        { "佩里科岛" },
        { "赌场抢劫" },
        { "末日豪劫" },
    },
    ValueList = {
        1978495 + 825 + 56,
        1971696 + 2325,
        1967630 + 812 + 50,
    },
    NonHost = 2684820 + 6606,
}

local cut_global_base = HeistCut.ValueList[1]
menu.list_select(Heist_Cut_Editor, "当前抢劫", {}, "", HeistCut.ListItem, 1, function(value)
    cut_global_base = HeistCut.ValueList[value]
end)

menu.click_slider(Heist_Cut_Editor, "玩家1 (房主)", { "cut1edit" }, "", 0, 300, 85, 5, function(value)
    SET_INT_GLOBAL(cut_global_base + 1, value)
end)
menu.click_slider(Heist_Cut_Editor, "玩家2", { "cut2edit" }, "", 0, 300, 85, 5, function(value)
    SET_INT_GLOBAL(cut_global_base + 2, value)
end)
menu.click_slider(Heist_Cut_Editor, "玩家3", { "cut3edit" }, "", 0, 300, 85, 5, function(value)
    SET_INT_GLOBAL(cut_global_base + 3, value)
end)
menu.click_slider(Heist_Cut_Editor, "玩家4", { "cut4edit" }, "", 0, 300, 85, 5, function(value)
    SET_INT_GLOBAL(cut_global_base + 4, value)
end)
menu.divider(Heist_Cut_Editor, "")
menu.click_slider(Heist_Cut_Editor, "自己 (非主机)", { "cutmyselfedit" }, "", 0, 300, 85, 5, function(value)
    SET_INT_GLOBAL(HeistCut.NonHost, value)
end)

--#endregion Heist Cut Editor


--#region Heist Prep Editor

local Heist_Prep_Editor = menu.list(Mission_Options, "抢劫前置编辑", {}, "")

----------------
-- 赌场抢劫
----------------
local Casion_Heist <const> = menu.list(Heist_Prep_Editor, "赌场抢劫", {}, "")

local casion_heist = {
    optional = {
        bitset0 = 0,
        menu_input = nil,
        menu_list = {},
    },
}

menu.divider(Casion_Heist, "第二面板")
local Casion_Heist_Optional = menu.list(Casion_Heist, "自定义可选任务", {}, "")

menu.action(Casion_Heist_Optional, "读取 H3OPT_BITSET0", {}, "", function()
    local value = STAT_GET_INT("H3OPT_BITSET0")
    menu.set_value(casion_heist.optional.menu_input, value)
    util.toast(value)
end)
casion_heist.optional.menu_input = menu.slider(Casion_Heist_Optional, "H3OPT_BITSET0", { "CH_H3OPT_BITSET0" }, "",
    0, 16777216, 0, 1, function(value)
        casion_heist.optional.bitset0 = value
    end)
menu.action(Casion_Heist_Optional, "解析 H3OPT_BITSET0", {}, "", function()
    local value = casion_heist.optional.bitset0

    for _, command in pairs(casion_heist.optional.menu_list) do
        menu.set_value(command, false)
    end

    for bit, bin in pairs(decimal_to_binary(value)) do
        bit = bit - 1
        if bin == 1 then
            local command = casion_heist.optional.menu_list[bit]
            if command ~= nil and menu.is_ref_valid(command) then
                menu.set_value(command, true)
            end
        end
    end
end)
menu.action(Casion_Heist_Optional, "写入 H3OPT_BITSET0", {}, "", function()
    STAT_SET_INT("H3OPT_BITSET0", casion_heist.optional.bitset0)
    util.toast("已将 H3OPT_BITSET0 修改为: " .. casion_heist.optional.bitset0)
end)

menu.divider(Casion_Heist_Optional, "任务列表")

local Casion_Heist_Optional_Preps_ListData = {
    { menu = "toggle", name = "Support Crew Selected [必选]", bit = 0, help_text = "" },
    { menu = "toggle", name = "巡逻路线", bit = 1, help_text = "" },
    { menu = "toggle", name = "杜根货物", bit = 2, help_text = "是否会显示对钩而已" },
    { menu = "toggle", name = "电钻", bit = 4, help_text = "" },
    { menu = "toggle", name = "枪手诱饵", bit = 6, help_text = "" },
    { menu = "toggle", name = "更换载具", bit = 7, help_text = "" },
    { menu = "divider", name = "隐迹潜踪" },
    { menu = "toggle", name = "潜入套装", bit = 3, help_text = "" },
    { menu = "toggle", name = "电磁脉冲设备", bit = 5, help_text = "" },
    { menu = "divider", name = "兵不厌诈" },
    { menu = "toggle", name = "进场: 除虫大师1", bit = 8, help_text = "" },
    { menu = "toggle", name = "进场: 除虫大师2", bit = 9, help_text = "" },
    { menu = "toggle", name = "进场: 维修工1", bit = 10, help_text = "" },
    { menu = "toggle", name = "进场: 维修工2", bit = 11, help_text = "" },
    { menu = "toggle", name = "进场: 古倍科技1", bit = 12, help_text = "" },
    { menu = "toggle", name = "进场: 古倍科技2", bit = 13, help_text = "" },
    { menu = "toggle", name = "进场: 名人1", bit = 14, help_text = "" },
    { menu = "toggle", name = "进场: 名人2", bit = 15, help_text = "" },
    { menu = "toggle", name = "离场: 国安局", bit = 16, help_text = "" },
    { menu = "toggle", name = "离场: 消防员", bit = 17, help_text = "" },
    { menu = "toggle", name = "离场: 豪赌客", bit = 18, help_text = "" },
    { menu = "divider", name = "气势汹汹" },
    { menu = "toggle", name = "镗床", bit = 19, help_text = "" },
    { menu = "toggle", name = "加固防弹衣", bit = 20, help_text = "" },
}
for k, item in pairs(Casion_Heist_Optional_Preps_ListData) do
    if item.menu == "toggle" then
        local menu_toggle = menu.toggle(Casion_Heist_Optional, item.name, {}, item.help_text,
            function(toggle, click_type)
                if click_type ~= CLICK_SCRIPTED then
                    local value = casion_heist.optional.bitset0
                    if toggle then
                        value = value + (1 << item.bit)
                    else
                        value = value - (1 << item.bit)
                    end
                    menu.set_value(casion_heist.optional.menu_input, value)
                end
            end)

        casion_heist.optional.menu_list[item.bit] = menu_toggle
    else
        menu.divider(Casion_Heist_Optional, item.name)
    end
end


----------------
-- 末日豪劫
----------------
local Doomsday_Heist <const> = menu.list(Heist_Prep_Editor, "末日豪劫", {}, "")

local doomsday_heist = {
    prep = {
        gangops_fm = 0,
        menu_input = nil,
        menu_list = {},
        list_data = {
            { menu = "divider", name = "末日一: 数据泄露" },
            { menu = "toggle", name = "医疗装备", bit = 0, help_text = "" },
            { menu = "toggle", name = "德罗索", bit = 1, help_text = "" },
            { menu = "toggle", name = "阿库拉", bit = 2, help_text = "" },
            { menu = "divider", name = "末日二: 博格丹危机" },
            { menu = "toggle", name = "钥匙卡", bit = 3, help_text = "" },
            { menu = "toggle", name = "ULP情报", bit = 4, help_text = "" },
            { menu = "toggle", name = "防暴车", bit = 5, help_text = "" },
            { menu = "toggle", name = "斯特龙伯格", bit = 6, help_text = "" },
            { menu = "toggle", name = "鱼雷电控单元", bit = 7, help_text = "" },
            { menu = "divider", name = "末日三: 末日将至" },
            { menu = "toggle", name = "标记资金", bit = 8, help_text = "" },
            { menu = "toggle", name = "侦察", bit = 9, help_text = "" },
            { menu = "toggle", name = "切尔诺伯格", bit = 10, help_text = "" },
            { menu = "toggle", name = "飞行路线", bit = 11, help_text = "" },
            { menu = "toggle", name = "试验场情报", bit = 12, help_text = "" },
            { menu = "toggle", name = "机载电脑", bit = 13, help_text = "" },
        },
    },

    setup = {
        gangops_flow = 0,
        menu_input = nil,
        menu_list = {},
        list_data = {
            { menu = "divider", name = "末日一: 数据泄露" },
            { menu = "toggle", name = "亡命速递", bit = 0, help_text = "" },
            { menu = "toggle", name = "拦截信号", bit = 1, help_text = "" },
            { menu = "toggle", name = "服务器群组", bit = 2, help_text = "" },
            { menu = "divider", name = "末日二: 博格丹危机" },
            { menu = "toggle", name = "复仇者", bit = 4, help_text = "" },
            { menu = "toggle", name = "营救ULP", bit = 5, help_text = "" },
            { menu = "toggle", name = "抢救硬盘", bit = 6, help_text = "" },
            { menu = "toggle", name = "潜水艇侦察", bit = 7, help_text = "" },
            { menu = "divider", name = "末日三: 末日将至" },
            { menu = "toggle", name = "营救14号探员", bit = 9, help_text = "" },
            { menu = "toggle", name = "护送ULP探员", bit = 10, help_text = "" },
            { menu = "toggle", name = "巴拉杰", bit = 11, help_text = "" },
            { menu = "toggle", name = "可汗贾利", bit = 12, help_text = "" },
            { menu = "toggle", name = "空中防御", bit = 13, help_text = "" },
        },
    }
}

local Doomsday_Heist_Preps = menu.list(Doomsday_Heist, "前置任务", {}, "")

menu.action(Doomsday_Heist_Preps, "读取 GANGOPS_FM_MISSION_PROG", {}, "", function()
    local value = STAT_GET_INT("GANGOPS_FM_MISSION_PROG")
    menu.set_value(doomsday_heist.prep.menu_input, value)
    util.toast(value)
end)
doomsday_heist.prep.menu_input = menu.slider(Doomsday_Heist_Preps, "GANGOPS_FM 值", { "doomsday_heist_gangops_fm" }, "",
    0, 16777216, 0, 1, function(value)
        doomsday_heist.prep.gangops_fm = value
    end)
menu.action(Doomsday_Heist_Preps, "解析当前 GANGOPS_FM 值", {}, "", function()
    local value = doomsday_heist.prep.gangops_fm

    for _, command in pairs(doomsday_heist.prep.menu_list) do
        menu.set_value(command, false)
    end

    for bit, bin in pairs(decimal_to_binary(value)) do
        bit = bit - 1
        if bin == 1 then
            local command = doomsday_heist.prep.menu_list[bit]
            if command ~= nil and menu.is_ref_valid(command) then
                menu.set_value(command, true)
            end
        end
    end
end)
menu.action(Doomsday_Heist_Preps, "写入 GANGOPS_FM_MISSION_PROG", {}, "", function()
    STAT_SET_INT("GANGOPS_FM_MISSION_PROG", doomsday_heist.prep.gangops_fm)
    util.toast("已将 GANGOPS_FM_MISSION_PROG 修改为: " .. doomsday_heist.prep.gangops_fm)
end)

-- 任务列表
for k, item in pairs(doomsday_heist.prep.list_data) do
    if item.menu == "toggle" then
        local menu_toggle = menu.toggle(Doomsday_Heist_Preps, item.name, {}, item.help_text, function(toggle, click_type)
            if click_type ~= CLICK_SCRIPTED then
                local value = doomsday_heist.prep.gangops_fm
                if toggle then
                    value = value + (1 << item.bit)
                else
                    value = value - (1 << item.bit)
                end
                menu.set_value(doomsday_heist.prep.menu_input, value)
            end
        end)

        doomsday_heist.prep.menu_list[item.bit] = menu_toggle
    else
        menu.divider(Doomsday_Heist_Preps, item.name)
    end
end


local Doomsday_Heist_Setups = menu.list(Doomsday_Heist, "准备任务", {}, "")

menu.action(Doomsday_Heist_Setups, "读取 GANGOPS_FLOW_MISSION_PROG", {}, "", function()
    local value = STAT_GET_INT("GANGOPS_FLOW_MISSION_PROG")
    menu.set_value(doomsday_heist.setup.menu_input, value)
    util.toast(value)
end)
doomsday_heist.setup.menu_input = menu.slider(Doomsday_Heist_Setups, "GANGOPS_FLOW 值",
    { "doomsday_heist_gangops_flow" }, "", 0, 16777216, 0, 1, function(value)
        doomsday_heist.setup.gangops_flow = value
    end)
menu.action(Doomsday_Heist_Setups, "解析当前 GANGOPS_FM 值", {}, "", function()
    local value = doomsday_heist.setup.gangops_flow

    for _, command in pairs(doomsday_heist.setup.menu_list) do
        menu.set_value(command, false)
    end

    for bit, bin in pairs(decimal_to_binary(value)) do
        bit = bit - 1
        if bin == 1 then
            local command = doomsday_heist.setup.menu_list[bit]
            if command ~= nil and menu.is_ref_valid(command) then
                menu.set_value(command, true)
            end
        end
    end
end)
menu.action(Doomsday_Heist_Setups, "写入 GANGOPS_FLOW_MISSION_PROG", {}, "", function()
    STAT_SET_INT("GANGOPS_FLOW_MISSION_PROG", doomsday_heist.setup.gangops_flow)
    util.toast("已将 GANGOPS_FLOW_MISSION_PROG 修改为: " .. doomsday_heist.setup.gangops_flow)
end)

-- 任务列表
for k, item in pairs(doomsday_heist.setup.list_data) do
    if item.menu == "toggle" then
        local menu_toggle = menu.toggle(Doomsday_Heist_Setups, item.name, {}, item.help_text,
            function(toggle, click_type)
                if click_type ~= CLICK_SCRIPTED then
                    local value = doomsday_heist.setup.gangops_flow
                    if toggle then
                        value = value + (1 << item.bit)
                    else
                        value = value - (1 << item.bit)
                    end
                    menu.set_value(doomsday_heist.setup.menu_input, value)
                end
            end)

        doomsday_heist.setup.menu_list[item.bit] = menu_toggle
    else
        menu.divider(Doomsday_Heist_Setups, item.name)
    end
end

--#endregion




-------------------------------------------
----------    Tunable Options    ----------
-------------------------------------------

local Tunable_Options <const> = menu.list(Menu_Root, "可调整项", {}, "")

local tTunable = {
    MaxHealthMulti = 1.0,
    MaxArmourMulti = 1.0,
    HealthRegenRateMulti = 1.0,
    HealthRegenMaxMulti = 1.0,
}

--#region Gun Van

local Gun_Van <const> = menu.list(Tunable_Options, "厢型车武器", {}, "")

for i = 1, 10 do
    local global_addr = 262145 + Tunables.XM22_GUN_VAN_SLOT_WEAPON_TYPE_0 + i
    local default = GET_INT_GLOBAL(global_addr)
    menu.text_input(Gun_Van, "Weapon Slot " .. i, { "slot_" .. i .. "gun_van_weapon" }, "", function(value)
        value = tonumber(value)
        if value ~= nil and WEAPON.IS_WEAPON_VALID(value) then
            SET_INT_GLOBAL(global_addr, value)
            util.toast("完成")
        end
    end, default)
end

menu.divider(Gun_Van, "")
rs_menu.all_weapons(Gun_Van, "全部武器", {}, "复制武器Hash", function(hash)
    util.copy_to_clipboard(hash, true)
end)

menu.action(Gun_Van, "附近生成厢型车", {}, "", function()
    local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    -- local vector = ENTITY.GET_ENTITY_FORWARD_VECTOR(players.user_ped())
    -- local spawn_point = v3.new()

    -- if MISC.FIND_SPAWN_POINT_IN_DIRECTION(coords.x, coords.y, coords.z,
    --         vector.x, vector.y, vector.z,
    --         25.0,
    --         memory.addrof(spawn_point)) then
    --     local Addr = memory.script_global(Globals.GunVanSpawnPoint)
    --     if Addr ~= 0 then
    --         memory.write_vector3(Addr, spawn_point)
    --         util.toast("完成！")
    --     end
    -- end

    local bool, spawn_point, heading = get_closest_vehicle_node(coords, 1)
    if bool then
        local Addr = memory.script_global(Globals.GunVanSpawnPoint)
        if Addr ~= 0 then
            memory.write_vector3(Addr, spawn_point)
            util.toast("完成！")
        end
    end
end)
menu.action(Gun_Van, "传送到厢型车", {}, "", function()
    local Addr = memory.script_global(Globals.GunVanSpawnPoint)
    if Addr ~= 0 then
        local coords = memory.read_vector3(Addr)
        if v3.toString(coords) == "0, 0, 0" then
            return
        end
        teleport2(coords.x, coords.y, coords.z + 2.0)
    end
end)

--#endregion


--#region Contact Mission

local Contact_Mission <const> = menu.list(Tunable_Options, "联系人差事", {}, "关闭后切换战局恢复默认值")

menu.toggle(Contact_Mission, "最大化任务时间", {}, "获取最大化收益", function(toggle)
    Loop_Handler.Tunables.ContactMission.MaxMissionTime = toggle
    Loop_Handler.Tunables.ContactMission.MaxMissionTime_Callback = function()
        for i = 0, 8 do
            tunables.set_int(Tunables.CONTACT_MISSION_TIME_PERIOD_1 + i, 0)
        end
    end
    Loop_Handler.Tunables.ContactMission.MaxMissionTime_Callback()
end)
menu.toggle(Contact_Mission, "最大化现金收益", {}, "游戏默认的最高倍率", function(toggle)
    Loop_Handler.Tunables.ContactMission.MaxCashEarning = toggle
    Loop_Handler.Tunables.ContactMission.MaxCashEarning_Callback = function()
        for i = 0, 9 do
            tunables.set_float(Tunables.CONTACT_MISSION_CASH_TIME_PERIOD_1_PERCENTAGE + i, 2.0)
        end
        for i = 0, 3 do
            tunables.set_float(Tunables.CONTACT_MISSION_CASH_PLAYER_MULTIPLIER_1 + i, 1.3)
        end
        for i = 0, 2 do
            tunables.set_float(Tunables.CONTACT_MISSION_CASH_DIFFICULTY_MULTIPLIER_EASY + i, 1.5)
        end
        for i = 0, 8 do
            tunables.set_float(Tunables.CONTACT_MISSION_FAIL_CASH_TIME_PERIOD_2_DIVIDER + i, 3.5)
        end
    end
    Loop_Handler.Tunables.ContactMission.MaxCashEarning_Callback()
end)
menu.toggle(Contact_Mission, "最大化经验收益", {}, "游戏默认的最高倍率", function(toggle)
    Loop_Handler.Tunables.ContactMission.MaxRpEarning = toggle
    Loop_Handler.Tunables.ContactMission.MaxRpEarning_Callback = function()
        for i = 0, 9 do
            tunables.set_float(Tunables.CONTACT_MISSION_RP_TIME_PERIOD_1_PERCENTAGE + i, 2.0)
        end
        for i = 0, 2 do
            tunables.set_float(Tunables.CONTACT_MISSION_RP_DIFFICULTY_MULTIPLIER_EASY + i, 1.5)
        end
        for i = 0, 8 do
            tunables.set_float(Tunables.CONTACT_MISSION_FAIL_RP_TIME_PERIOD_2_DIVIDER + i, 2.5)
        end
    end
    Loop_Handler.Tunables.ContactMission.MaxRpEarning_Callback()
end)

--#endregion Contact Mission


--#region Health Armour

local Health_Armour <const> = menu.list(Tunable_Options, "生命和护甲倍率", {}, "")

menu.slider_float(Health_Armour, "最大生命值倍率", { "t_MaxHealthMulti" }, "",
    100, 2000, 100, 100, function(value)
        tTunable.MaxHealthMulti = value * 0.01
        tunables.set_float(Tunables.MAX_HEALTH_MULTIPLIER, tTunable.MaxHealthMulti)
    end)
menu.slider_float(Health_Armour, "最大护甲值倍率", { "t_MaxArmourMulti" }, "",
    100, 2000, 100, 100, function(value)
        tTunable.MaxArmourMulti = value * 0.01
        tunables.set_float(Tunables.MAX_ARMOR_MULTIPLIER, tTunable.MaxArmourMulti)
    end)
menu.slider_float(Health_Armour, "生命恢复速度倍率", { "t_HealthRegenRateMulti" }, "",
    100, 2000, 100, 100, function(value)
        tTunable.HealthRegenRateMulti = value * 0.01
        tunables.set_float(Tunables.HEALTH_REGEN_RATE_MULTIPLIER, tTunable.HealthRegenRateMulti)
    end)
menu.slider_float(Health_Armour, "生命恢复程度倍率", { "t_HealthRegenMaxMulti" }, "",
    100, 2000, 100, 100, function(value)
        tTunable.HealthRegenMaxMulti = value * 0.01
        tunables.set_float(Tunables.HEALTH_REGEN_MAX_MULTIPLIER, tTunable.HealthRegenMaxMulti)
    end)

--#endregion Health Armour


--#region Heist Target Weighting

local Heist_Target_Weight <const> = menu.list(Tunable_Options, "抢劫主要目标概率", {}, "侦查任务开启前设置")

menu.divider(Heist_Target_Weight, "佩里科岛抢劫")

local PericoHeistTargets = {
    { "西西米托龙舌兰", "tequila" },
    { "红宝石项链", "necklace" },
    { "不记名债券", "bonds" },
    { "粉钻", "diamond" },
    { "猎豹雕像", "statue" },
}
for key, item in pairs(PericoHeistTargets) do
    local offset = Tunables.PericoHeist.TargetWeighting[key]
    local default_value = math.ceil(tunables.get_float(offset) * 100)

    menu.slider_float(Heist_Target_Weight, item[1], { "t_h4_target_weight" .. item[2] }, "",
        0, 100, default_value, 10, function(value)
            tunables.set_float(offset, value * 0.01)
        end)
end

menu.divider(Heist_Target_Weight, "赌场抢劫")

local CasinoHeistTargets = {
    { "现金", "cash" },
    { "艺术品", "art" },
    { "黄金", "gold" },
    { "钻石", "diamond" },
}
for key, item in pairs(CasinoHeistTargets) do
    local offset = Tunables.CasinoHeist.TargetWeighting[key]
    local default_value = math.ceil(tunables.get_float(offset) * 100)

    menu.slider_float(Heist_Target_Weight, item[1], { "t_ch_target_weight" .. item[2] }, "",
        0, 100, default_value, 10, function(value)
            tunables.set_float(offset, value * 0.01)
        end)
end

--#endregion Heist Target Weighting




---------------------------------------
----------    Stat Editor    ----------
---------------------------------------

local Stat_Editor <const> = menu.list(Menu_Root, "Stat Editor", {}, "")

local tStatEditor = {}

--#region Stat Skill

local Stat_Skill <const> = menu.list(Stat_Editor, "属性技能", {}, "")

tStatEditor.Skill = {
    stat_select = 1,
    value = 100,

    stat_list_item = {
        { "体力", {}, "SCRIPT_INCREASE_STAM" },
        { "射击", {}, "SCRIPT_INCREASE_SHO" },
        { "力量", {}, "SCRIPT_INCREASE_STRN" },
        { "潜行", {}, "SCRIPT_INCREASE_STL" },
        { "飞行", {}, "SCRIPT_INCREASE_FLY" },
        { "驾驶", {}, "SCRIPT_INCREASE_DRIV" },
        { "肺活量", {}, "SCRIPT_INCREASE_LUNG" },
    },
}

menu.list_select(Stat_Skill, "选择属性", {}, "", tStatEditor.Skill.stat_list_item, 1, function(value)
    tStatEditor.Skill.stat_select = value
end)

menu.action(Stat_Skill, "读取", {}, "", function()
    local stat = tStatEditor.Skill.stat_list_item[tStatEditor.Skill.stat_select][3]
    local value = STAT_GET_INT(stat)

    menu.set_value(tStatEditor.Skill.readonly, value)
end)
tStatEditor.Skill.readonly = menu.readonly(Stat_Skill, "数值")

menu.divider(Stat_Skill, "设置")
menu.slider(Stat_Skill, "数值", { "stat_skill_value" }, "",
    0, 100, 100, 1, function(value)
        tStatEditor.Skill.value = value
    end)
menu.action(Stat_Skill, "设置", {}, "", function()
    local stat = tStatEditor.Skill.stat_list_item[tStatEditor.Skill.stat_select][3]
    STAT_SET_INT(stat, tStatEditor.Skill.value)

    menu.trigger_commands("forcecloudsave")
    util.toast("设置完成!\n请等待云保存完成!")
end)

--#endregion Stat Skill


--#region Stat Commons

local Stat_Commons <const> = menu.list(Stat_Editor, "Some Stats", {}, "")

tStatEditor.Commons = {
    stat = "",
    type = 1,
    value = "",

    list_item = {},
    value_list = {},
}

tStatEditor.Commons.ListData = {
    { name = "死亡总数", stat = "DEATHS", type = 1 },
    { name = "爆炸死亡数", stat = "DIED_IN_EXPLOSION", type = 1 },
    { name = "坠落死亡数", stat = "DIED_IN_FALL", type = 1 },
    { name = "火烧死亡数", stat = "DIED_IN_FIRE", type = 1 },
    { name = "撞死次数", stat = "DIED_IN_ROAD", type = 1 },
    { name = "溺水死亡数", stat = "DIED_IN_DROWNING", type = 1 },
    { name = "击杀警察数", stat = "KILLS_COP", type = 1 },
    { name = "击杀国安局人员数", stat = "KILLS_SWAT", type = 1 },
    { name = "被通缉次数", stat = "NO_TIMES_WANTED_LEVEL", type = 1 },
    { name = "已获得通缉星数", stat = "STARS_ATTAINED", type = 1 },
    { name = "消除的通缉星数", stat = "STARS_EVADED", type = 1 },
    { name = "最喜欢的摩托车", stat = "FAVOUTFITBIKETYPEALLTIME", type = 1 },
    { name = "驾驶陆上载具达到的最高速度", stat = "FASTEST_SPEED", type = 2 },
    { name = "驾驶过最快的陆上载具", stat = "TOP_SPEED_CAR", type = 1 },
}

for key, item in pairs(tStatEditor.Commons.ListData) do
    table.insert(tStatEditor.Commons.list_item, { item.name })
    table.insert(tStatEditor.Commons.value_list, { item.stat, item.type })
end

menu.list_select(Stat_Commons, "选择 Stat", {}, "", tStatEditor.Commons.list_item, 1, function(value)
    local item = tStatEditor.Commons.value_list[value]
    tStatEditor.Commons.stat = item[1]
    menu.set_value(tStatEditor.Commons.stat_readonly, item[1])
    menu.set_value(tStatEditor.Commons.stat_type, item[2])
end)

tStatEditor.Commons.stat_readonly = menu.readonly(Stat_Commons, "Stat")
tStatEditor.Commons.stat_type = menu.list_select(Stat_Commons, "类型", {}, "", {
    { "int" }, { "float" }, { "string" }, { "bool" },
}, 1, function(value)
    tStatEditor.Commons.type = value
end)

menu.action(Stat_Commons, "读取", {}, "", function()
    local stat = tStatEditor.Commons.stat
    local value = ""

    if stat == "" then
        return
    end

    if tStatEditor.Commons.type == 1 then
        value = STAT_GET_INT(stat)
    elseif tStatEditor.Commons.type == 2 then
        value = STAT_GET_FLOAT(stat)
    elseif tStatEditor.Commons.type == 3 then
        value = STAT_GET_STRING(stat)
    elseif tStatEditor.Commons.type == 4 then
        value = STAT_GET_BOOL(stat)
    end

    menu.set_value(tStatEditor.Commons.stat_readvalue, tostring(value))
end)
tStatEditor.Commons.stat_readvalue = menu.readonly(Stat_Commons, "值")

menu.divider(Stat_Commons, "设置")
menu.text_input(Stat_Commons, "值", { "some_stats_input" }, "注意格式\nbool: 需输入'true'或'false'",
    function(value)
        tStatEditor.Commons.value = value
    end)
menu.action(Stat_Commons, "设置", {}, "", function()
    local stat = tStatEditor.Commons.stat
    local value = tStatEditor.Commons.value
    local error = nil

    if stat == "" then
        return
    end

    if tStatEditor.Commons.type == 1 then
        value = tonumber(value)
        if value then
            STAT_SET_INT(stat, value)
        else
            error = "格式错误！"
        end
    elseif tStatEditor.Commons.type == 2 then
        value = tonumber(value)
        if value then
            STAT_SET_FLOAT(stat, value)
        else
            error = "格式错误！"
        end
    elseif tStatEditor.Commons.type == 3 then
        STAT_SET_STRING(stat, tostring(value))
    elseif tStatEditor.Commons.type == 4 then
        if value == "true" then
            STAT_SET_BOOL(stat, true)
        elseif value == "false" then
            STAT_SET_BOOL(stat, false)
        else
            error = "格式错误！"
        end
    end

    if error then
        util.toast("设置失败: " .. error)
    else
        util.toast("设置完成！\nStat: " .. ADD_MP_INDEX(stat) .. "\nValue: " .. tostring(value))
    end
end)

--#endregion Stat Commons










-----------------------------------------
----------    About Options    ----------
-----------------------------------------

local About_Options <const> = menu.list(Menu_Root, "关于", {}, "")

menu.readonly(About_Options, "Author", "Rostal")
menu.hyperlink(About_Options, "Github", "https://github.com/TCRoid/Stand-Lua-RScript")
menu.readonly(About_Options, "Version", SCRIPT_VERSION)
menu.readonly(About_Options, "Support GTAO Version", SUPPORT_GTAO)




------------------------------------------
----------    Player Options    ----------
------------------------------------------

require "RScript.Menu.Player"





----------------------------------------
----------    Backend Loop    ----------
----------------------------------------

util.create_tick_handler(function()
    ------------------------
    -- Tunables
    ------------------------

    if IS_SCRIPT_RUNNING("tuneables_processing") then
        local tunables = Loop_Handler.Tunables

        --------    Contact Mission    --------

        if tunables.ContactMission.MaxMissionTime then
            Loop_Handler.Tunables.ContactMission.MaxMissionTime_Callback()
        end
        if tunables.ContactMission.MaxCashEarning then
            Loop_Handler.Tunables.ContactMission.MaxCashEarning_Callback()
        end
        if tunables.ContactMission.MaxRpEarning then
            Loop_Handler.Tunables.ContactMission.MaxRpEarning_Callback()
        end


        --------    Health Armour    --------

        if tTunable.MaxHealthMulti ~= 1.0 then
            tunables.set_float(Tunables.MAX_HEALTH_MULTIPLIER, tTunable.MaxHealthMulti)
        end
        if tTunable.MaxArmourMulti ~= 1.0 then
            tunables.set_float(Tunables.MAX_ARMOR_MULTIPLIER, tTunable.MaxArmourMulti)
        end
        if tTunable.HealthRegenRateMulti ~= 1.0 then
            tunables.set_float(Tunables.HEALTH_REGEN_RATE_MULTIPLIER, tTunable.HealthRegenRateMulti)
        end
        if tTunable.HealthRegenMaxMulti ~= 1.0 then
            tunables.set_float(Tunables.HEALTH_REGEN_MAX_MULTIPLIER, tTunable.HealthRegenMaxMulti)
        end
    end
end)




---------------------------------------
----------        END        ----------
---------------------------------------
