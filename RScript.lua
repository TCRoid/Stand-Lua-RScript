--------------------------------
-- Author: Rostal
--------------------------------

local SCRIPT_START_TIME <const> = util.current_time_millis()

util.require_natives("2944b", "init")

local SCRIPT_VERSION <const> = "2023/12/3"

local SUPPORT_GTAO <const> = 1.67






--------------------------------------
----------    File & Dir    ----------
--------------------------------------

-- Store
local STORE_DIR <const> = filesystem.store_dir() .. "RScript\\"
if not filesystem.exists(STORE_DIR) then
    filesystem.mkdir(STORE_DIR)
end

-- Resource
local RESOURCE_DIR <const> = filesystem.resources_dir() .. "RScript\\"
Texture = {
    file = {
        crosshair = RESOURCE_DIR .. "crosshair.png",
    },
}
for _, file in pairs(Texture.file) do
    if not filesystem.exists(file) then
        util.toast("[RScript] 缺少文件: " .. file, TOAST_ALL)
        util.toast("脚本已停止运行")
        util.stop_script()
    end
end

Texture.crosshair = directx.create_texture(Texture.file.crosshair)

-- Lib
local SCRIPT_LIB_DIR <const> = filesystem.scripts_dir() .. "lib\\RScript\\"
local REQUIRED_FILES <const> = {
    "Tables.lua",
    "variables.lua",
    "alternatives.lua",
    "functions.lua",
    "functions2.lua",
    "utils.lua",
    "EntityLib.lua",
    "Menu\\Entity.lua",
    "Menu\\Mission.lua",
    "Menu\\Online.lua",
    "Menu\\Assistant.lua",
    "Menu\\Bodyguard.lua",
    "Menu\\Dev.lua",
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
require "RScript.variables"
require "RScript.alternatives"
require "RScript.functions"
require "RScript.functions2"
require "RScript.utils"
require "RScript.EntityLib"



-----------------------------------
----------    Setting    ----------
-----------------------------------

Setting = {}

local SETTING_FILE <const> = STORE_DIR .. "setting.txt"

if not filesystem.exists(SETTING_FILE) or not filesystem.is_regular_file(SETTING_FILE) then
    -- Default Setting
    Setting = {
        ["Dev Mode"] = false,
        ["Change Script Entry"] = false,
    }
    util.write_colons_file(SETTING_FILE, Setting)
else
    Setting = util.read_colons_and_tabs_file(SETTING_FILE)
end

---@param key string
---@return boolean|string
function getSetting(key)
    local value = Setting[key]

    if value == nil then
        Setting[key] = false
        return false
    end
    if value == "false" then
        return false
    end
    if value == "true" then
        return true
    end
    return value
end

---@param key string
---@param value boolean|string|number
function setSetting(key, value)
    Setting[key] = value
end

DEV_MODE = getSetting("Dev Mode")



-- Backend Loop
Loop_Handler = {
    Main = {},
    Self = {},
    Tunables = {
        Cooldown = {},
        SpecialCargo = {},
        VehicleCargo = {},
        Bunker = {},
        AirFreight = {},
        Biker = {},
        AcidLab = {},
        Payphone = {},
    },
    Entity = {
        show_info = {},
        draw_line = {},
        draw_bounding_box = {},
        preview_ent = {
            ent = 0,
            clone_ent = 0,
            has_cloned_ent = 0,
            camera_distance = 2.0,
        },
        lock_tp = {},
    },
}


-- Transition Finished
Transition_Handler = {
    Self = {},
}

util.on_transition_finished(function()
    if Transition_Handler.Self.refill_armour then
        menu.trigger_commands("refillarmour")
    end
end)



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

if getSetting("Change Script Entry") then
    Menu_Root = menu.attach_before(menu.ref_by_path("Stand>Settings"),
        menu.list(menu.shadow_root(), "RScript", { "rscript" }, ""))
    menu.action(Menu_Root, "停止脚本", {}, "", function()
        menu.trigger_commands("stopluarscript")
    end)

    menu.divider(menu.my_root(), "RScript")
    menu.action(menu.my_root(), "转到脚本", {}, "", function()
        menu.trigger_commands("rscript")
    end)
end

menu.divider(Menu_Root, "RScript")



----------------------------------------
----------    Self Options    ----------
----------------------------------------

local Self_Options <const> = menu.list(Menu_Root, "自我选项", {}, "")

local tSelf = {}

--#region Health & Armour

local Self_HealthArmour <const> = menu.list(Self_Options, "生命与护甲选项", {}, "")

tSelf.HealthArmour = {
    defaultHealth = 328,
    defaultArmour = 50,
}

menu.toggle_loop(Self_HealthArmour, "信息显示 生命和护甲", {}, "信息显示位置", function()
    local current_health = ENTITY.GET_ENTITY_HEALTH(players.user_ped())
    local max_health = PED.GET_PED_MAX_HEALTH(players.user_ped())
    local current_armour = PED.GET_PED_ARMOUR(players.user_ped())
    local max_armour = PLAYER.GET_PLAYER_MAX_ARMOUR(players.user())

    local text = string.format("生命: %d/%d\n护甲: %d/%d", current_health, max_health, current_armour, max_armour)
    util.draw_debug_text(text)
end)
menu.toggle(Self_HealthArmour, "切换战局自动补满护甲", {}, "", function(toggle)
    Transition_Handler.Self.refill_armour = toggle
end)

menu.divider(Self_HealthArmour, "")
menu.slider(Self_HealthArmour, "设置当前生命值", { "set_health" }, "",
    0, 100000, tSelf.HealthArmour.defaultHealth, 50, function(value)
        SET_ENTITY_HEALTH(players.user_ped(), value)
    end)
menu.slider(Self_HealthArmour, "设置当前护甲值", { "set_armour" }, "",
    0, 100000, tSelf.HealthArmour.defaultArmour, 50, function(value)
        PED.SET_PED_ARMOUR(players.user_ped(), value)
    end)

--#endregion Health & Armour

--#region Health Recharge

local Self_HealthRecharge <const> = menu.list(Self_Options, "生命恢复选项", {}, "")

tSelf.HealthRecharge = {
    maxPercent = 1.0,
    multiplier = 20.0,
}

menu.slider_float(Self_HealthRecharge, "恢复程度", { "self_recharge_percent" }, "",
    1, 100, tSelf.HealthRecharge.maxPercent * 100, 10, function(value)
        tSelf.HealthRecharge.maxPercent = value * 0.01
    end)
menu.slider_float(Self_HealthRecharge, "恢复速度", { "self_recharge_multi" }, "",
    1, 10000, tSelf.HealthRecharge.multiplier * 100, 100, function(value)
        tSelf.HealthRecharge.multiplier = value * 0.01
    end)

menu.toggle_loop(Self_HealthRecharge, "设置生命恢复", { "fast_recharge" }, "", function()
    if PLAYER.GET_PLAYER_HEALTH_RECHARGE_MAX_PERCENT(players.user()) ~= tSelf.HealthRecharge.maxPercent then
        PLAYER.SET_PLAYER_HEALTH_RECHARGE_MAX_PERCENT(players.user(), tSelf.HealthRecharge.maxPercent)
    end
    PLAYER.SET_PLAYER_HEALTH_RECHARGE_MULTIPLIER(players.user(), tSelf.HealthRecharge.multiplier)
end, function()
    PLAYER.SET_PLAYER_HEALTH_RECHARGE_MAX_PERCENT(players.user(), 0.5)
    PLAYER.SET_PLAYER_HEALTH_RECHARGE_MULTIPLIER(players.user(), 1.0)
end)

--#endregion Health Recharge

--#region Wanted

local Self_Wanted <const> = menu.list(Self_Options, "通缉选项", {}, "")

menu.toggle_loop(Self_Wanted, "禁止为玩家调度警察", { "no_dispatch_cops" }, "不会一直刷出新的警察，最好在被通缉前开启",
    function()
        PLAYER.SET_DISPATCH_COPS_FOR_PLAYER(players.user(), false)
    end, function()
        PLAYER.SET_DISPATCH_COPS_FOR_PLAYER(players.user(), true)
    end)
menu.action(Self_Wanted, "强制进入躲避区域", {}, "警星开始闪烁,警察使用锥形视野搜寻", function()
    PLAYER.FORCE_START_HIDDEN_EVASION(players.user())
end)
menu.action(Self_Wanted, "移除当前载具通缉状态", {}, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        VEHICLE.SET_VEHICLE_IS_WANTED(vehicle, false)
        VEHICLE.SET_VEHICLE_INFLUENCES_WANTED_LEVEL(vehicle, false)
        VEHICLE.SET_VEHICLE_HAS_BEEN_OWNED_BY_PLAYER(vehicle, true)
        VEHICLE.SET_VEHICLE_IS_STOLEN(vehicle, false)
        VEHICLE.SET_POLICE_FOCUS_WILL_TRACK_VEHICLE(vehicle, false)
    end
end)

menu.toggle_loop(Self_Wanted, "Low Wanted Level Multiplier", {},
    "Set multiplier to 0.0, default is 1.0", function()
        PLAYER.SET_WANTED_LEVEL_MULTIPLIER(0.0)
    end, function()
        PLAYER.SET_WANTED_LEVEL_MULTIPLIER(1.0)
    end)
menu.toggle_loop(Self_Wanted, "Low Wanted Level Difficulty", {},
    "Set difficulty to 0.0", function()
        PLAYER.SET_WANTED_LEVEL_DIFFICULTY(players.user(), 0.0)
    end, function()
        PLAYER.RESET_WANTED_LEVEL_DIFFICULTY(players.user())
    end)
menu.toggle_loop(Self_Wanted, "Suppress Crime", {},
    "Can be use to disable all instances of a crime type on this frame.", function()
        for i = 1, 50 do
            PLAYER.SUPPRESS_CRIME_THIS_FRAME(players.user(), i)
        end
    end)

--#endregion Wanted

--#region Fall

local Self_Fall <const> = menu.list(Self_Options, "跌落选项", {}, "")

tSelf.Fall = {
    height = 8.0
}

menu.toggle_loop(Self_Fall, "禁止高处跌落直接死亡", {}, "如果血量过低仍然会直接摔死",
    function()
        PED.SET_DISABLE_HIGH_FALL_DEATH(players.user_ped(), true)
    end, function()
        PED.SET_DISABLE_HIGH_FALL_DEATH(players.user_ped(), false)
    end)

menu.slider_float(Self_Fall, "触发跌落动作高度", { "self_fall_distance" }, "",
    0, 10000, tSelf.Fall.height * 100, 100, function(value)
        tSelf.Fall.height = value * 0.01
    end)
menu.toggle_loop(Self_Fall, "设置触发跌落动作高度", {}, "", function()
    PLAYER.SET_PLAYER_FALL_DISTANCE_TO_TRIGGER_RAGDOLL_OVERRIDE(players.user(), tSelf.Fall.height)
end)

--#endregion Fall

--#region Options

menu.toggle_loop(Self_Options, "警察无视", {}, "", function()
    PLAYER.SET_POLICE_IGNORE_PLAYER(players.user(), true)
end, function()
    PLAYER.SET_POLICE_IGNORE_PLAYER(players.user(), false)
end)
menu.toggle_loop(Self_Options, "所有人无视", {}, "", function()
    PLAYER.SET_EVERYONE_IGNORE_PLAYER(players.user(), true)
end, function()
    PLAYER.SET_EVERYONE_IGNORE_PLAYER(players.user(), false)
end)
menu.toggle_loop(Self_Options, "行动无声", {}, "", function()
    PLAYER.SET_PLAYER_NOISE_MULTIPLIER(players.user(), 0.0)
    PLAYER.SET_PLAYER_SNEAKING_NOISE_MULTIPLIER(players.user(), 0.0)
end)
menu.toggle_loop(Self_Options, "不会被帮派骚乱", {}, "", function()
    PLAYER.SET_PLAYER_CAN_BE_HASSLED_BY_GANGS(players.user(), false)
end, function()
    PLAYER.SET_PLAYER_CAN_BE_HASSLED_BY_GANGS(players.user(), true)
end)
menu.toggle_loop(Self_Options, "载具内不可被射击", {}, "在载具内不会受伤", function()
    PED.SET_PED_CAN_BE_SHOT_IN_VEHICLE(players.user_ped(), false)
end, function()
    PED.SET_PED_CAN_BE_SHOT_IN_VEHICLE(players.user_ped(), true)
end)
menu.toggle_loop(Self_Options, "禁用NPC伤害", { "no_ai_damage" }, "", function()
    PED.SET_AI_WEAPON_DAMAGE_MODIFIER(0.0)
    PED.SET_AI_MELEE_WEAPON_DAMAGE_MODIFIER(0.0)
end, function()
    PED.RESET_AI_WEAPON_DAMAGE_MODIFIER()
    PED.RESET_AI_MELEE_WEAPON_DAMAGE_MODIFIER()
end)
menu.toggle_loop(Self_Options, "只能被玩家伤害", {}, "不会被NPC伤害", function()
    ENTITY.SET_ENTITY_ONLY_DAMAGED_BY_PLAYER(players.user_ped(), true)
end, function()
    ENTITY.SET_ENTITY_ONLY_DAMAGED_BY_PLAYER(players.user_ped(), false)
end)
menu.toggle_loop(Self_Options, "禁止被爆头一枪击杀", {}, "", function()
    PED.SET_PED_SUFFERS_CRITICAL_HITS(players.user_ped(), false)
end, function()
    PED.SET_PED_SUFFERS_CRITICAL_HITS(players.user_ped(), true)
end)
menu.toggle_loop(Self_Options, "可以射击队友", {}, "", function()
    PED.SET_CAN_ATTACK_FRIENDLY(players.user_ped(), true, false)
end, function()
    PED.SET_CAN_ATTACK_FRIENDLY(players.user_ped(), false, false)
end)

Loop_Handler.Self.defense_modifier = {
    callback = function(value)
        PLAYER.SET_PLAYER_WEAPON_DEFENSE_MODIFIER(players.user(), value)
        PLAYER.SET_PLAYER_WEAPON_MINIGUN_DEFENSE_MODIFIER(players.user(), value)
        PLAYER.SET_PLAYER_MELEE_WEAPON_DEFENSE_MODIFIER(players.user(), value)
        PLAYER.SET_PLAYER_VEHICLE_DEFENSE_MODIFIER(players.user(), value)
        PLAYER.SET_PLAYER_WEAPON_TAKEDOWN_DEFENSE_MODIFIER(players.user(), value)
    end
}
menu.slider_float(Self_Options, "受伤倍数修改", { "defense_multiplier" }, "数值越低，受到的伤害就越低",
    10, 100, 100, 10, function(value)
        value = value * 0.01

        Loop_Handler.Self.defense_modifier.value = value
        Loop_Handler.Self.defense_modifier.callback(value)
    end)

--#endregion Options




------------------------------------------
----------    Weapon Options    ----------
------------------------------------------

local Weapon_Options <const> = menu.list(Menu_Root, "武器选项", {}, "")

local tWeapon = {}

--#region Weapon Attributes

local Weapon_Attributes <const> = menu.list(Weapon_Options, "武器属性修改", {}, "修改武器属性，应用修改后会一直生效")

local WeaponAttribute = {
    BaseInfo = {
        ["anim_reload_time"] = { offset = 0x134, type = "float" },
        ["vehicle_reload_time"] = { offset = 0x130, type = "float" },
        ["time_between_shots"] = { offset = 0x13c, type = "float" },
        ["alternate_wait_time"] = { offset = 0x150, type = "float" },
        ["reload_time_mp"] = { offset = 0x128, type = "float" },
        ["reload_time_sp"] = { offset = 0x12c, type = "float" },
        ["lock_on_range"] = { offset = 0x288, type = "float" },
        ["weapon_range"] = { offset = 0x28c, type = "float" },
    },
    RocketInfo = {
        ["lifetime"] = { offset = 0x44, type = "float" },
        ["launch_speed"] = { offset = 0x58, type = "float" },
        ["forward_drag_coeff"] = { offset = 0x170, type = "float" },
        ["side_drag_coeff"] = { offset = 0x174, type = "float" },
        ["time_before_homing"] = { offset = 0x178, type = "float" },
        ["pitch_change_rate"] = { offset = 0x188, type = "float" },
        ["yaw_change_rate"] = { offset = 0x18c, type = "float" },
        ["roll_change_rate"] = { offset = 0x190, type = "float" },
        ["max_roll_angle_sin"] = { offset = 0x194, type = "float" },
    },
    HomingParam = {
        ["should_use_homing_params_from_info"] = { offset = 0x0, type = "byte" },
        ["time_before_starting_homing"] = { offset = 0x4, type = "float" },
        ["time_before_homing_angle_break"] = { offset = 0x8, type = "float" },
        ["turn_rate_modifier"] = { offset = 0xc, type = "float" },
        ["pitch_yaw_roll_clamp"] = { offset = 0x10, type = "float" },
        ["default_homing_rocket_break_lock_angle"] = { offset = 0x14, type = "float" },
        ["default_homing_rocket_break_lock_angle_close"] = { offset = 0x18, type = "float" },
        ["default_homing_rocket_break_lock_close_distance"] = { offset = 0x1c, type = "float" },
    },
    Persets = {
        ItemList = {
            {
                menu_name = "载具导弹 无限快速连发",
                help_text = "",
                weapon_type = 2,
                data_list = {
                    { "time_between_shots",  0.2, true },
                    { "alternate_wait_time", 0.2, true },
                    { "reload_time_mp",      0,   true },
                    { "reload_time_sp",      0,   true },
                }
            },
            {
                menu_name = "载具机枪 快速射击",
                help_text = "",
                weapon_type = 2,
                data_list = {
                    { "time_between_shots",  0, true },
                    { "alternate_wait_time", 0, true },
                    { "reload_time_mp",      0, true },
                    { "reload_time_sp",      0, true },
                }
            },
            {
                menu_name = "手持武器 通用设置",
                help_text = "换弹动作速度+0.2, 载具内换弹时间=0, 射击间隔时间-0.02",
                weapon_type = 1,
                data_list = {
                    { "anim_reload_time",    0.2,   false },
                    { "vehicle_reload_time", 0,     true },
                    { "time_between_shots",  -0.02, false },

                }
            },
            {
                menu_name = "制导导弹 增强锁定能力",
                help_text = "",
                weapon_type = 3,
                data_list = {
                    { "lifetime",                                        10.0,  true },
                    { "side_drag_coeff",                                 10.0,  true },
                    { "pitch_change_rate",                               100.0, true },
                    { "yaw_change_rate",                                 100.0, true },
                    { "roll_change_rate",                                100.0, true },
                    { "should_use_homing_params_from_info",              1,     true },
                    { "time_before_starting_homing",                     0.15,  true },
                    { "turn_rate_modifier",                              100.0, true },
                    { "pitch_yaw_roll_clamp",                            8.5,   true },
                    { "default_homing_rocket_break_lock_angle",          0.2,   true },
                    { "default_homing_rocket_break_lock_angle_close",    0.6,   true },
                    { "default_homing_rocket_break_lock_close_distance", 20.0,  true },
                }
            },
        }
    },
    Backups = {},
    Menus = {},
    Index = 0,
}

function WeaponAttribute.CWeaponInfo()
    local ped_ptr = entities.handle_to_pointer(players.user_ped())
    local weapon_manager = entities.get_weapon_manager(ped_ptr)
    local m_weapon_info = weapon_manager + 0x20
    local m_vehicle_weapon_info = weapon_manager + 0x70

    local CWeaponInfo = memory.read_long(m_weapon_info)
    if CWeaponInfo ~= 0 and WEAPON.IS_PED_ARMED(players.user_ped(), 4) then
        return CWeaponInfo
    end

    local CVehicleWeaponInfo = memory.read_long(m_vehicle_weapon_info)
    if CVehicleWeaponInfo ~= 0 then
        return CVehicleWeaponInfo
    end

    return 0
end

function WeaponAttribute.CAmmoInfo(CWeaponInfo)
    if CWeaponInfo == 0 then return 0 end
    if not WeaponAttribute.IsRocket(CWeaponInfo) then
        return 0
    end

    return memory.read_long(CWeaponInfo + 0x60) -- m_ammo_info
end

function WeaponAttribute.CHomingRocketParams(CAmmoInfo)
    if CAmmoInfo == 0 then return 0 end

    return CAmmoInfo + 0x19c -- m_homing_rocket_params
end

function WeaponAttribute.IsRocket(CWeaponInfo)
    local m_damage_type = CWeaponInfo + 0x20
    local m_fire_type = CWeaponInfo + 0x54
    return memory.read_int(m_damage_type) == 5 and memory.read_int(m_fire_type) == 4
end

function WeaponAttribute.GetWeaponName(weaponHash)
    local weaponName = get_weapon_name_by_hash(weaponHash)
    if weaponName == "" then
        weaponName = util.reverse_joaat(weaponHash)
        weaponName = string.gsub(weaponName, "VEHICLE_WEAPON_", "")
    end
    if weaponName == "" then
        weaponName = tostring(weaponHash)
    end

    return weaponName
end

function WeaponAttribute.GetAttributes(CWeaponInfo, weaponName)
    local text = "武器: " .. weaponName
    local attr_value = 0

    for name, item in pairs(WeaponAttribute.BaseInfo) do
        attr_value = memory.read_float(CWeaponInfo + item.offset)

        text = text .. "\n" .. name .. ": " .. attr_value
    end

    local CAmmoInfo = WeaponAttribute.CAmmoInfo(CWeaponInfo)
    if CAmmoInfo ~= 0 then
        for name, item in pairs(WeaponAttribute.RocketInfo) do
            attr_value = memory.read_float(CAmmoInfo + item.offset)

            text = text .. "\n" .. name .. ": " .. attr_value
        end
    end

    local CHomingRocketParams = WeaponAttribute.CHomingRocketParams(CAmmoInfo)
    if CHomingRocketParams ~= 0 then
        for name, item in pairs(WeaponAttribute.HomingParam) do
            if item.type == "float" then
                attr_value = memory.read_float(CHomingRocketParams + item.offset)
            elseif item.type == "byte" then
                attr_value = memory.read_byte(CHomingRocketParams + item.offset)
            end
            text = text .. "\n" .. name .. ": " .. attr_value
        end
    end

    return text
end

function WeaponAttribute.SetAttribute(addr, value, Type, isAddition)
    if addr == 0 then return end

    local get_value = memory.read_float
    local set_value = memory.write_float
    if Type == "byte" then
        get_value = memory.read_byte
        set_value = memory.write_byte
    end

    local default_value = get_value(addr)
    if default_value < -1 then return end
    if default_value > 65536 then return end

    if isAddition then
        value = default_value + value
    end

    set_value(addr, value)
end

function WeaponAttribute.StoreBackup(CWeaponInfo, weaponHash)
    if WeaponAttribute.Backups[weaponHash] then return end

    local t = {}
    local attr_value = 0

    for name, item in pairs(WeaponAttribute.BaseInfo) do
        local addr = CWeaponInfo + item.offset

        attr_value = memory.read_float(addr)

        t[name] = { value = attr_value, type = item.type, addr = addr }
    end

    local CAmmoInfo = WeaponAttribute.CAmmoInfo(CWeaponInfo)
    if CAmmoInfo ~= 0 then
        for name, item in pairs(WeaponAttribute.RocketInfo) do
            local addr = CAmmoInfo + item.offset

            attr_value = memory.read_float(addr)

            t[name] = { value = attr_value, type = item.type, addr = addr }
        end
    end

    local CHomingRocketParams = WeaponAttribute.CHomingRocketParams(CAmmoInfo)
    if CHomingRocketParams ~= 0 then
        for name, item in pairs(WeaponAttribute.HomingParam) do
            local addr = CHomingRocketParams + item.offset
            if item.type == "float" then
                attr_value = memory.read_float(addr)
            elseif item.type == "byte" then
                attr_value = memory.read_byte(addr)
            end
            t[name] = { value = attr_value, type = item.type, addr = addr }
        end
    end

    WeaponAttribute.Backups[weaponHash] = t

    WeaponAttribute.GenerateMenu(CWeaponInfo, weaponHash)
end

function WeaponAttribute.ClearListData()
    for _, value in pairs(WeaponAttribute.Menus) do
        if value then
            return false
        end
    end
    WeaponAttribute.Menus = {}
    WeaponAttribute.Index = 0
end

function WeaponAttribute.GenerateMenu(CWeaponInfo, weaponHash)
    if WeaponAttribute.Menus[weaponHash] then return end
    local weapon_name = WeaponAttribute.GetWeaponName(weaponHash)
    local menu_parent = Weapon_Attributes

    -- menu.list 存进表内
    local menu_list = menu.list(menu_parent, weapon_name, {}, "")
    WeaponAttribute.Menus[weaponHash] = menu_list


    menu.textslider_stateful(menu_list, "读取武器属性", {}, "", {
        "仅通知", "通知并保存到日志"
    }, function(value)
        local text = WeaponAttribute.GetAttributes(CWeaponInfo, weapon_name)

        util.toast(text)
        if value == 2 then
            util.log("\n" .. text)
        end
    end)
    menu.action(menu_list, "恢复默认属性", {}, "", function()
        for key, item in pairs(WeaponAttribute.Backups[weaponHash]) do
            if item.type == "float" then
                memory.write_float(item.addr, item.value)
            elseif item.type == "byte" then
                memory.write_byte(item.addr, item.value)
            end
        end
        util.toast("已恢复默认属性")
    end)
    menu.action(menu_list, "删除此条记录", {}, "会保存默认属性", function()
        menu.delete(menu_list)
        WeaponAttribute.Menus[weaponHash] = nil
        WeaponAttribute.ClearListData()
    end)

    menu.divider(menu_list, "属性列表")

    for name, item in pairs(WeaponAttribute.BaseInfo) do
        local addr = CWeaponInfo + item.offset
        local default_value = memory.read_float(addr)
        menu.text_input(menu_list, name,
            { "weapon_attr" .. WeaponAttribute.Index .. name },
            "", function(value, click_type)
                if click_type ~= CLICK_SCRIPTED then
                    value = tonumber(value)
                    if value then
                        memory.write_float(addr, value)
                    end
                end
            end, default_value)
    end

    local CAmmoInfo = WeaponAttribute.CAmmoInfo(CWeaponInfo)
    if CAmmoInfo ~= 0 then
        menu.divider(menu_list, "RocketInfo")

        for name, item in pairs(WeaponAttribute.RocketInfo) do
            local addr = CAmmoInfo + item.offset
            local default_value = memory.read_float(addr)
            menu.text_input(menu_list, name,
                { "weapon_attr" .. WeaponAttribute.Index .. name },
                "", function(value, click_type)
                    if click_type ~= CLICK_SCRIPTED then
                        value = tonumber(value)
                        if value then
                            memory.write_float(addr, value)
                        end
                    end
                end, default_value)
        end
    end

    local CHomingRocketParams = WeaponAttribute.CHomingRocketParams(CAmmoInfo)
    if CHomingRocketParams ~= 0 then
        menu.divider(menu_list, "HomingRocketParams")

        for name, item in pairs(WeaponAttribute.HomingParam) do
            local addr = CHomingRocketParams + item.offset
            local default_value = 0
            if item.type == "float" then
                default_value = memory.read_float(addr)
            elseif item.type == "byte" then
                default_value = memory.read_byte(addr)
            end
            menu.text_input(menu_list, name,
                { "weapon_attr" .. WeaponAttribute.Index .. name },
                "", function(value, click_type)
                    if click_type ~= CLICK_SCRIPTED then
                        value = tonumber(value)
                        if value then
                            if item.type == "float" then
                                memory.write_float(addr, value)
                            elseif item.type == "byte" then
                                memory.write_byte(addr, value)
                            end
                        end
                    end
                end, default_value)
        end
    end


    -- Index
    WeaponAttribute.Index = WeaponAttribute.Index + 1
end

function WeaponAttribute.Persets.Apply(CWeaponInfo, dataList)
    if CWeaponInfo == 0 then return false end
    local CAmmoInfo = WeaponAttribute.CAmmoInfo(CWeaponInfo)
    local CHomingRocketParams = WeaponAttribute.CHomingRocketParams(CAmmoInfo)

    for _, item in pairs(dataList) do
        local name = item[1]
        local value = item[2]
        local is_override = item[3]

        local info = WeaponAttribute.BaseInfo[name]
        if info then
            WeaponAttribute.SetAttribute(CWeaponInfo + info.offset, value, info.type, not is_override)
            goto continue
        end

        if CAmmoInfo == 0 then
            goto continue
        end
        info = WeaponAttribute.RocketInfo[name]
        if info then
            WeaponAttribute.SetAttribute(CAmmoInfo + info.offset, value, info.type, not is_override)
            goto continue
        end

        if CHomingRocketParams == 0 then
            goto continue
        end
        info = WeaponAttribute.HomingParam[name]
        if info then
            WeaponAttribute.SetAttribute(CHomingRocketParams + info.offset, value, info.type, not is_override)
            goto continue
        end

        ::continue::
    end
end

menu.textslider_stateful(Weapon_Attributes, "读取当前武器属性", {}, "", {
    "仅通知", "通知并保存到日志"
}, function(value)
    local CWeaponInfo = WeaponAttribute.CWeaponInfo()
    if CWeaponInfo ~= 0 then
        local weaponHash = get_ped_current_weapon(players.user_ped())
        local weaponName = WeaponAttribute.GetWeaponName(weaponHash)
        local text = WeaponAttribute.GetAttributes(CWeaponInfo, weaponName)

        util.toast(text)
        if value == 2 then
            util.log("\n" .. text)
        end
    else
        util.toast("不支持近战武器")
    end
end)

menu.action(Weapon_Attributes, "编辑当前武器属性", {}, "", function()
    local CWeaponInfo = WeaponAttribute.CWeaponInfo()
    if CWeaponInfo ~= 0 then
        local weapon_hash = get_ped_current_weapon(players.user_ped())
        WeaponAttribute.StoreBackup(CWeaponInfo, weapon_hash)
    else
        util.toast("不支持近战武器")
    end
end)

menu.divider(Weapon_Attributes, "预设属性")
for _, item in pairs(WeaponAttribute.Persets.ItemList) do
    menu.action(Weapon_Attributes, item.menu_name, {}, item.help_text, function()
        local CWeaponInfo = WeaponAttribute.CWeaponInfo()
        if CWeaponInfo ~= 0 then
            local weapon_hash, weapon_type = get_ped_current_weapon(players.user_ped())
            if item.weapon_type == 3 or weapon_type == item.weapon_type then
                WeaponAttribute.StoreBackup(CWeaponInfo, weapon_hash)
                if WeaponAttribute.Persets.Apply(CWeaponInfo, item.data_list) then
                    local weapon_name = WeaponAttribute.GetWeaponName(weapon_hash)
                    util.toast("武器: " .. weapon_name .. "\n预设属性修改完成")
                end
            end
        end
    end)
end


menu.divider(Weapon_Attributes, "保存的武器列表")

--#endregion Weapon Attributes

--#region Weapon Cam Gun

local Weapon_CamGun <const> = menu.list(Weapon_Options, "视野工具枪", {}, "玩家镜头中心的位置")

local CamGun = {
    select = 1,
}

menu.toggle_loop(Weapon_CamGun, "开启[按住E键]", { "cam_gun" }, "", function()
    Loop_Handler.draw_centred_point(true)
    if PAD.IS_CONTROL_PRESSED(0, 51) then
        if CamGun.select == 1 then
            CamGun.Shoot()
        elseif CamGun.select == 2 then
            CamGun.Explosion()
        elseif CamGun.select == 3 then
            CamGun.Fire()
        end
    end
end, function()
    Loop_Handler.draw_centred_point(false)
end)

menu.list_select(Weapon_CamGun, "选择操作", { "cam_gun_select" }, "", {
    { "射击", { "shoot" }, "" },
    { "爆炸", { "explosion" }, "" },
    { "燃烧", { "fire" }, "" },
}, 1, function(value)
    CamGun.select = value
end)

menu.divider(Weapon_CamGun, "设置")

--#region Cam Gun Shoot

----------------
-- Shoot
----------------

local CamGun_ShootSetting <const> = menu.list(Weapon_CamGun, "射击", {}, "")

CamGun.ShootSetting = {
    shootMethod = 1,
    delay = 100,
    weaponSelect = 1,
    weaponHash = "PLAYER_CURRENT_WEAPON",
    vehicleWeaponHash = "VEHICLE_CURRENT_WEAPON",
    isOwned = false,
    damage = 1000,
    speed = 2000,
    perfectAccuracy = true,
    createTraceVfx = true,
    allowRumble = true,
    startFromPlayer = false,
    offset = v3(0, 0, 2.0),
}

function CamGun.ShootPos(pos, action)
    local user_ped = players.user_ped()

    local start_pos = v3.new()
    if CamGun.ShootSetting.startFromPlayer then
        local player_pos = ENTITY.GET_ENTITY_COORDS(user_ped)
        start_pos = v3.add(player_pos, CamGun.ShootSetting.offset)
    else
        start_pos = v3.add(pos, CamGun.ShootSetting.offset)
    end

    if action == "drawline" then
        DRAW_LINE(start_pos, pos)
    else
        local weaponHash = CamGun.ShootSetting.weaponHash
        if CamGun.ShootSetting.weaponSelect == 2 then
            weaponHash = CamGun.ShootSetting.vehicleWeaponHash
        end

        if weaponHash == "PLAYER_CURRENT_WEAPON" then
            weaponHash = WEAPON.GET_SELECTED_PED_WEAPON(user_ped)
        elseif weaponHash == "VEHICLE_CURRENT_WEAPON" then
            local pWeapon = memory.alloc_int()
            WEAPON.GET_CURRENT_PED_VEHICLE_WEAPON(user_ped, pWeapon)
            weaponHash = memory.read_int(pWeapon)
        end
        if not WEAPON.HAS_WEAPON_ASSET_LOADED(weaponHash) then
            request_weapon_asset(weaponHash)
        end

        local owner = 0
        if CamGun.ShootSetting.isOwned then
            owner = user_ped
        end

        local ignoreEntity = entities.get_user_vehicle_as_handle(false)
        if ignoreEntity == INVALID_GUID then
            ignoreEntity = user_ped
        end

        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(
            start_pos.x, start_pos.y, start_pos.z,
            pos.x, pos.y, pos.z,
            CamGun.ShootSetting.damage,
            CamGun.ShootSetting.perfectAccuracy,
            weaponHash,
            owner,
            CamGun.ShootSetting.createTraceVfx,
            CamGun.ShootSetting.allowRumble,
            CamGun.ShootSetting.speed,
            ignoreEntity,
            0)
    end
end

function CamGun.Shoot()
    local cam_pos
    if CamGun.ShootSetting.shootMethod == 1 then
        local result = get_raycast_result(1500, -1)
        if result.didHit then
            cam_pos = result.endCoords
        end
    elseif CamGun.ShootSetting.shootMethod == 2 then
        cam_pos = get_offset_from_cam(1500)
    end

    if cam_pos ~= nil then
        CamGun.ShootPos(cam_pos)
        util.yield(CamGun.ShootSetting.delay)
    end
end

menu.toggle_loop(CamGun_ShootSetting, "绘制射击连线", {}, "", function()
    Loop_Handler.draw_centred_point(true)

    local cam_pos
    if CamGun.ShootSetting.shootMethod == 1 then
        local result = get_raycast_result(1500, -1)
        if result.didHit then
            cam_pos = result.endCoords
        end
    elseif CamGun.ShootSetting.shootMethod == 2 then
        cam_pos = get_offset_from_cam(1500)
    end

    if cam_pos ~= nil then
        CamGun.ShootPos(cam_pos, "drawline")
    end
end, function()
    Loop_Handler.draw_centred_point(false)
end)

menu.list_select(CamGun_ShootSetting, "射击方式", {}, "", {
    { "方式1", {}, "射击的坐标更加准确，只能向实体或地面射击" },
    { "方式2", {}, "射击的坐标不是很准确，但可以向空中射击" }
}, 1, function(value)
    CamGun.ShootSetting.shootMethod = value
end)
menu.slider(CamGun_ShootSetting, "循环延迟", { "cam_gun_shoot_delay" }, "单位: ms", 0, 5000, 100, 10,
    function(value)
        CamGun.ShootSetting.delay = value
    end)

local CamGun_ShootSetting_Weapon <const> = menu.list(CamGun_ShootSetting, "武器", {}, "")

menu.list_select(CamGun_ShootSetting_Weapon, "武器类型", {}, "",
    { { "手持武器" }, { "载具武器" } }, 1, function(value)
        CamGun.ShootSetting.weaponSelect = value
    end)
local CamGun_ShootSetting_PlayerWeapon = rs_menu.all_weapons_without_melee(CamGun_ShootSetting_Weapon, "手持武器",
    {}, "", function(hash)
        CamGun.ShootSetting.weaponHash = hash
    end, true)
rs_menu.current_weapon_action(CamGun_ShootSetting_PlayerWeapon, "玩家当前使用的武器", function()
    CamGun.ShootSetting.weaponHash = "PLAYER_CURRENT_WEAPON"
end, true)

local CamGun_ShootSetting_VehicleWeapon = rs_menu.vehicle_weapons(CamGun_ShootSetting_Weapon, "载具武器", {}, "",
    function(hash)
        CamGun.ShootSetting.vehicleWeaponHash = hash
    end, true)
rs_menu.current_weapon_action(CamGun_ShootSetting_VehicleWeapon, "载具当前使用的武器", function()
    CamGun.ShootSetting.vehicleWeaponHash = "VEHICLE_CURRENT_WEAPON"
end, true)


menu.toggle(CamGun_ShootSetting, "署名射击", {}, "以玩家名义", function(toggle)
    CamGun.ShootSetting.isOwned = toggle
end)
menu.slider(CamGun_ShootSetting, "伤害", { "cam_gun_shoot_damage" }, "", 0, 10000, 1000, 100,
    function(value)
        CamGun.ShootSetting.damage = value
    end)
menu.slider(CamGun_ShootSetting, "速度", { "cam_gun_shoot_speed" }, "", 0, 10000, 2000, 100,
    function(value)
        CamGun.ShootSetting.speed = value
    end)

menu.divider(CamGun_ShootSetting, "起始射击位置偏移")
menu.toggle(CamGun_ShootSetting, "从玩家位置起始射击", {},
    "如果关闭,则起始位置为目标位置+偏移\n如果开启,建议偏移Z>1.0", function(toggle)
        CamGun.ShootSetting.startFromPlayer = toggle
    end)
menu.slider_float(CamGun_ShootSetting, "X", { "cam_gun_shoot_x" }, "", -10000, 10000, 0, 10,
    function(value)
        CamGun.ShootSetting.offset.x = value * 0.01
    end)
menu.slider_float(CamGun_ShootSetting, "Y", { "cam_gun_shoot_y" }, "", -10000, 10000, 0, 10,
    function(value)
        CamGun.ShootSetting.offset.y = value * 0.01
    end)
menu.slider_float(CamGun_ShootSetting, "Z", { "cam_gun_shoot_z" }, "", -10000, 10000, 200, 10,
    function(value)
        CamGun.ShootSetting.offset.z = value * 0.01
    end)

--#endregion Cam Gun Shoot

--#region Cam Gun Explosion

----------------
-- Explosion
----------------

local CamGun_ExplosionSetting <const> = menu.list(Weapon_CamGun, "爆炸", {}, "")

CamGun.ExplosionSetting = {
    delay = 100,
    explosionType = 2,
    isOwned = false,
    damage = 1000,
    isAudible = true,
    isInvisible = false,
    cameraShake = 0,
}

function CamGun.Explosion()
    local result = get_raycast_result(1500, -1)
    local cam_pos = result.endCoords
    if result.didHit and cam_pos ~= nil then
        if CamGun.ExplosionSetting.isOwned then
            FIRE.ADD_OWNED_EXPLOSION(players.user_ped(),
                cam_pos.x, cam_pos.y, cam_pos.z,
                CamGun.ExplosionSetting.explosionType,
                CamGun.ExplosionSetting.damage,
                CamGun.ExplosionSetting.isAudible,
                CamGun.ExplosionSetting.isInvisible,
                CamGun.ExplosionSetting.cameraShake)
        else
            FIRE.ADD_EXPLOSION(
                cam_pos.x, cam_pos.y, cam_pos.z,
                CamGun.ExplosionSetting.explosionType,
                CamGun.ExplosionSetting.damage,
                CamGun.ExplosionSetting.isAudible,
                CamGun.ExplosionSetting.isInvisible,
                CamGun.ExplosionSetting.cameraShake,
                false)
        end
        util.yield(CamGun.ExplosionSetting.delay)
    end
end

menu.slider(CamGun_ExplosionSetting, "循环延迟", { "cam_gun_explosion_delay" }, "单位: ms", 0, 5000, 100, 10,
    function(value)
        CamGun.ExplosionSetting.delay = value
    end)
menu.list_select(CamGun_ExplosionSetting, "爆炸类型", {}, "", Misc_T.ExplosionType, 4, function(index)
    CamGun.ExplosionSetting.explosionType = index - 2
end)
menu.toggle(CamGun_ExplosionSetting, "署名爆炸", {}, "以玩家名义", function(toggle)
    CamGun.ExplosionSetting.isOwned = toggle
end)
menu.slider(CamGun_ExplosionSetting, "伤害", { "cam_gun_explosion_damage" }, "", 0, 10000, 1000, 100,
    function(value)
        CamGun.ExplosionSetting.damage = value
    end)
menu.toggle(CamGun_ExplosionSetting, "可听见", {}, "", function(toggle)
    CamGun.ExplosionSetting.isAudible = toggle
end, true)
menu.toggle(CamGun_ExplosionSetting, "不可见", {}, "", function(toggle)
    CamGun.ExplosionSetting.isInvisible = toggle
end)

--#endregion Cam Gun Explosion

--#region Cam Gun Fire

----------------
-- Fire
----------------

local CamGun_FireSetting <const> = menu.list(Weapon_CamGun, "燃烧", {}, "有火焰数量生成限制")

CamGun.FireSetting = {
    fireIds = {},
    maxChildren = 25,
    isGasFire = false,
}

function CamGun.Fire()
    local result = get_raycast_result(1500, -1)
    local cam_pos = result.endCoords
    if result.didHit and cam_pos ~= nil then
        local fire_id = FIRE.START_SCRIPT_FIRE(
            cam_pos.x, cam_pos.y, cam_pos.z,
            CamGun.FireSetting.maxChildren,
            CamGun.FireSetting.isGasFire)
        table.insert(CamGun.FireSetting.fireIds, fire_id)
    end
end

menu.slider(CamGun_FireSetting, "max Children", { "cam_gun_fire_maxChildren" },
    "The max amount of times a fire can spread to other objects.", 0, 25, 25, 1, function(value)
        CamGun.FireSetting.maxChildren = value
    end)
menu.toggle(CamGun_FireSetting, "is Gas Fire", {}, "Whether or not the fire is powered by gasoline.", function(toggle)
    CamGun.FireSetting.isGasFire = toggle
end)
menu.action(CamGun_FireSetting, "移除生成的火焰", {}, "", function()
    if next(CamGun.FireSetting.fireIds) ~= nil then
        for k, v in pairs(CamGun.FireSetting.fireIds) do
            FIRE.REMOVE_SCRIPT_FIRE(v)
        end
        CamGun.FireSetting.fireIds = {}
    end
end)

--#endregion Cam Gun Fire

--#endregion Weapon Cam Gun

--#region Options

tWeapon.SpecialAmmo = {
    specialTypeList = {
        { "无", { "none" }, "No Special Ammo" }, -- 0
        { "穿甲子弹", { "ap" }, "Armor Piercing Ammo" }, -- 1
        { "爆炸子弹", { "explosive" }, "Explosive Ammo" }, -- 2
        { "全金属外壳子弹", { "fmj" }, "Full Metal Jacket Ammo" }, -- 3
        { "中空子弹", { "hp" }, "Hollow Point Ammo" }, -- 4
        { "燃烧子弹", { "fire" }, "Incendiary Ammo" }, -- 5
        { "曳光子弹", { "tracer" }, "Tracer Ammo" } -- 6
    }
}
menu.list_action(Weapon_Options, "武器特殊弹药类型", { "special_ammo" }, "对已经配备特殊弹药的武器无效",
    tWeapon.SpecialAmmo.specialTypeList, function(value)
        if not WEAPON.IS_PED_ARMED(players.user_ped(), 4) then
            return
        end

        local weapon_manager = entities.get_weapon_manager(entities.handle_to_pointer(players.user_ped()))
        local m_weapon_info = weapon_manager + 0x20

        local CWeaponInfo = memory.read_long(m_weapon_info)
        if CWeaponInfo ~= 0 then
            local CAmmoInfo = memory.read_long(CWeaponInfo + 0x60)
            if CAmmoInfo ~= 0 then
                local m_ammo_special_type = CAmmoInfo + 0x3c
                memory.write_int(m_ammo_special_type, value - 1)

                local weaponHash = get_ped_weapon(players.user_ped())
                local weaponName = get_weapon_name_by_hash(weaponHash)
                util.toast("武器: " .. weaponName .. "\n弹药类型已修改")
            end
        end
    end)

menu.toggle_loop(Weapon_Options, "无限弹夹", { "inf_clip" }, "锁定弹夹，无需换弹", function()
    WEAPON.SET_PED_INFINITE_AMMO_CLIP(players.user_ped(), true)
end, function()
    WEAPON.SET_PED_INFINITE_AMMO_CLIP(players.user_ped(), false)
end)
menu.toggle_loop(Weapon_Options, "锁定最大弹药", { "lock_ammo" }, "射击时锁定当前武器为最大弹药",
    function()
        if PED.IS_PED_SHOOTING(players.user_ped()) then
            local weaponHash = WEAPON.GET_SELECTED_PED_WEAPON(players.user_ped())
            if weaponHash ~= 0 then
                -- WEAPON.SET_PED_AMMO(players.user_ped(), weaponHash, 9999)
                WEAPON.ADD_AMMO_TO_PED(players.user_ped(), weaponHash, 9999)
            end
        end
    end)
menu.toggle_loop(Weapon_Options, "无限载具武器弹药", { "inf_veh_ammo" }, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        if VEHICLE.DOES_VEHICLE_HAVE_WEAPONS(vehicle) then
            for i = 0, 3 do
                local ammo = VEHICLE.GET_VEHICLE_WEAPON_RESTRICTED_AMMO(vehicle, i)
                if ammo ~= -1 then
                    VEHICLE.SET_VEHICLE_WEAPON_RESTRICTED_AMMO(vehicle, i, -1)
                end
            end
        end
    end
end)
menu.toggle_loop(Weapon_Options, "翻滚时自动换弹夹", {}, "做翻滚动作时自动更换弹夹", function()
    if TASK.GET_IS_TASK_ACTIVE(players.user_ped(), 4) and PAD.IS_CONTROL_PRESSED(2, 22) and
        not PED.IS_PED_SHOOTING(players.user_ped()) then
        --checking if player is rolling
        util.yield(900)
        WEAPON.REFILL_AMMO_INSTANTLY(players.user_ped())
    end
end)
menu.action(Weapon_Options, "移除黏弹和感应地雷", { "remove_projectiles" }, "用来清理扔错地方但又不能炸掉的投掷武器",
    function()
        local weaponHash = util.joaat("WEAPON_PROXMINE")
        WEAPON.REMOVE_ALL_PROJECTILES_OF_TYPE(weaponHash, false)
        weaponHash = util.joaat("WEAPON_STICKYBOMB")
        WEAPON.REMOVE_ALL_PROJECTILES_OF_TYPE(weaponHash, false)
    end)

tWeapon.ReloadInVehicle = {
    modified_addr = 0,
    modified_default = 0,
}
menu.toggle_loop(Weapon_Options, "无载具内换弹时间", {}, "", function()
    if WEAPON.IS_PED_ARMED(players.user_ped(), 4) then
        local weapon_manager = entities.get_weapon_manager(entities.handle_to_pointer(players.user_ped()))
        local weapon_info = memory.read_long(weapon_manager + 0x20)
        if weapon_info ~= 0 then
            local addr = weapon_info + 0x130

            -- 更换了武器
            if addr ~= tWeapon.ReloadInVehicle.modified_addr then
                -- 恢复上一个武器的属性
                if tWeapon.ReloadInVehicle.modified_addr ~= 0 then
                    memory.write_float(tWeapon.ReloadInVehicle.modified_addr, tWeapon.ReloadInVehicle.modified_default)
                end

                -- 备份当前武器的属性
                tWeapon.ReloadInVehicle.modified_addr = addr
                tWeapon.ReloadInVehicle.modified_default = memory.read_float(addr)
            end

            -- 修改武器属性
            memory.write_float(addr, 0)
        end
    end
end, function()
    -- 恢复上一个武器的属性
    if tWeapon.ReloadInVehicle.modified_addr ~= 0 then
        memory.write_float(tWeapon.ReloadInVehicle.modified_addr, tWeapon.ReloadInVehicle.modified_default)
    end
end)

--#endregion Options




-------------------------------------------
----------    Vehicle Options    ----------
-------------------------------------------

local Vehicle_Options <const> = menu.list(Menu_Root, "载具选项", {}, "")

local tVehicle = {}

--#region Vehicle Upgrade

local Vehicle_Upgrade <const> = menu.list(Vehicle_Options, "载具升级强化", {}, "")

tVehicle.Upgrade = {
    performance = true,
    turbo = true,
    ---
    bulletproof_tyre = true,
    unbreakable_door = true,
    unbreakable_light = true,
    unbreak = true,
    ---
    max_health_multiplier = 1,
    health_multiplier = 1,
    damage_scale = 0.5,
    no_driver_explosion_damage = true,
    other_strong = true,
}

function tVehicle.Upgrade.upgrade(vehicle)
    -- 引擎、刹车、变速箱、防御
    if tVehicle.Upgrade.performance then
        for _, mod_type in pairs({ 11, 12, 13, 16 }) do
            local mod_num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, mod_type)
            VEHICLE.SET_VEHICLE_MOD(vehicle, mod_type, mod_num - 1, false)
        end
    end

    -- 涡轮增压
    if tVehicle.Upgrade.turbo then
        VEHICLE.TOGGLE_VEHICLE_MOD(vehicle, 18, true)
    end

    -- 防弹轮胎
    if tVehicle.Upgrade.bulletproof_tyre then
        if VEHICLE.GET_VEHICLE_TYRES_CAN_BURST(vehicle) then
            VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(vehicle, false)
        end
    end

    -- 车门不可损坏
    if tVehicle.Upgrade.unbreakable_door then
        for i = 0, 5 do
            if VEHICLE.GET_IS_DOOR_VALID(vehicle, i) then
                VEHICLE.SET_DOOR_ALLOWED_TO_BE_BROKEN_OFF(vehicle, i, false)
            end
        end
    end

    -- 车灯不可损坏
    if tVehicle.Upgrade.unbreakable_light then
        VEHICLE.SET_VEHICLE_HAS_UNBREAKABLE_LIGHTS(vehicle, true)
    end

    -- 部件不可分离
    if tVehicle.Upgrade.unbreakable_light then
        VEHICLE.SET_VEHICLE_CAN_BREAK(vehicle, false)
    end

    -- 实体最大血量倍数
    if tVehicle.Upgrade.max_health_multiplier > 1 then
        local max_health = ENTITY.GET_ENTITY_MAX_HEALTH(vehicle) * tVehicle.Upgrade.max_health_multiplier
        ENTITY.SET_ENTITY_MAX_HEALTH(vehicle, max_health)
        SET_ENTITY_HEALTH(vehicle, max_health)
    end

    -- 载具血量倍数
    if tVehicle.Upgrade.health_multiplier > 1 then
        local multiple_health = 1000 * tVehicle.Upgrade.health_multiplier
        VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, multiple_health)
        VEHICLE.SET_VEHICLE_BODY_HEALTH(vehicle, multiple_health)
        VEHICLE.SET_VEHICLE_PETROL_TANK_HEALTH(vehicle, multiple_health)
        VEHICLE.SET_HELI_MAIN_ROTOR_HEALTH(vehicle, multiple_health)
        VEHICLE.SET_HELI_TAIL_ROTOR_HEALTH(vehicle, multiple_health)
    end

    -- 受到伤害倍数
    VEHICLE.SET_VEHICLE_DAMAGE_SCALE(vehicle, tVehicle.Upgrade.damage_scale)
    VEHICLE.SET_VEHICLE_WEAPON_DAMAGE_SCALE(vehicle, tVehicle.Upgrade.damage_scale)

    -- 无视载具司机的爆炸
    if tVehicle.Upgrade.no_driver_explosion_damage then
        VEHICLE.SET_VEHICLE_NO_EXPLOSION_DAMAGE_FROM_DRIVER(vehicle, true)
    end

    -- 其它属性增强
    if tVehicle.Upgrade.other_strong then
        VEHICLE.SET_VEHICLE_WHEELS_CAN_BREAK(vehicle, false)

        VEHICLE.SET_VEHICLE_CAN_ENGINE_MISSFIRE(vehicle, false)
        VEHICLE.SET_VEHICLE_CAN_LEAK_OIL(vehicle, false)
        VEHICLE.SET_VEHICLE_CAN_LEAK_PETROL(vehicle, false)

        VEHICLE.SET_DISABLE_VEHICLE_ENGINE_FIRES(vehicle, true)
        VEHICLE.SET_DISABLE_VEHICLE_PETROL_TANK_FIRES(vehicle, true)
        VEHICLE.SET_DISABLE_VEHICLE_PETROL_TANK_DAMAGE(vehicle, true)

        VEHICLE.SET_VEHICLE_STRONG(vehicle, true)
        VEHICLE.SET_VEHICLE_HAS_STRONG_AXLES(vehicle, true)

        --Damage
        VEHICLE.VEHICLE_SET_RAMP_AND_RAMMING_CARS_TAKE_DAMAGE(vehicle, false)
        VEHICLE.SET_INCREASE_WHEEL_CRUSH_DAMAGE(vehicle, false)
        VEHICLE.SET_DISABLE_DAMAGE_WITH_PICKED_UP_ENTITY(vehicle, 1)
        VEHICLE.SET_VEHICLE_USES_MP_PLAYER_DAMAGE_MULTIPLIER(vehicle, 1)
        VEHICLE.SET_FORCE_VEHICLE_ENGINE_DAMAGE_BY_BULLET(vehicle, false)

        --Explode
        VEHICLE.SET_DISABLE_EXPLODE_FROM_BODY_DAMAGE_ON_COLLISION(vehicle, 1)
        VEHICLE.SET_VEHICLE_EXPLODES_ON_HIGH_EXPLOSION_DAMAGE(vehicle, false)
        VEHICLE.SET_VEHICLE_EXPLODES_ON_EXPLOSION_DAMAGE_AT_ZERO_BODY_HEALTH(vehicle, false)

        --Heli
        VEHICLE.SET_HELI_TAIL_BOOM_CAN_BREAK_OFF(vehicle, false)
        VEHICLE.SET_DISABLE_HELI_EXPLODE_FROM_BODY_DAMAGE(vehicle, 1)

        --MP Only
        VEHICLE.SET_PLANE_RESIST_TO_EXPLOSION(vehicle, true)
        VEHICLE.SET_HELI_RESIST_TO_EXPLOSION(vehicle, true)

        --Remove Check
        VEHICLE.REMOVE_VEHICLE_UPSIDEDOWN_CHECK(vehicle)
        VEHICLE.REMOVE_VEHICLE_STUCK_CHECK(vehicle)
    end
end

function tVehicle.Upgrade.remove(vehicle)
    for i = 0, 5 do
        if VEHICLE.GET_IS_DOOR_VALID(vehicle, i) then
            VEHICLE.SET_DOOR_ALLOWED_TO_BE_BROKEN_OFF(vehicle, i, true)
        end
    end
    VEHICLE.SET_VEHICLE_HAS_UNBREAKABLE_LIGHTS(vehicle, false)
    VEHICLE.SET_VEHICLE_CAN_BREAK(vehicle, true)

    ENTITY.SET_ENTITY_MAX_HEALTH(vehicle, 1000)
    SET_ENTITY_HEALTH(vehicle, 1000)

    VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, 1000)
    VEHICLE.SET_VEHICLE_BODY_HEALTH(vehicle, 1000)
    VEHICLE.SET_VEHICLE_PETROL_TANK_HEALTH(vehicle, 1000)
    VEHICLE.SET_HELI_MAIN_ROTOR_HEALTH(vehicle, 1000)
    VEHICLE.SET_HELI_TAIL_ROTOR_HEALTH(vehicle, 1000)

    VEHICLE.SET_VEHICLE_DAMAGE_SCALE(vehicle, 1.0)
    VEHICLE.SET_VEHICLE_WEAPON_DAMAGE_SCALE(vehicle, 1.0)

    VEHICLE.SET_VEHICLE_NO_EXPLOSION_DAMAGE_FROM_DRIVER(vehicle, false)

    VEHICLE.SET_VEHICLE_WHEELS_CAN_BREAK(vehicle, true)

    VEHICLE.SET_VEHICLE_CAN_ENGINE_MISSFIRE(vehicle, true)
    VEHICLE.SET_VEHICLE_CAN_LEAK_OIL(vehicle, true)
    VEHICLE.SET_VEHICLE_CAN_LEAK_PETROL(vehicle, true)

    VEHICLE.SET_DISABLE_VEHICLE_ENGINE_FIRES(vehicle, false)
    VEHICLE.SET_DISABLE_VEHICLE_PETROL_TANK_FIRES(vehicle, false)
    VEHICLE.SET_DISABLE_VEHICLE_PETROL_TANK_DAMAGE(vehicle, false)

    VEHICLE.SET_VEHICLE_STRONG(vehicle, false)
    VEHICLE.SET_VEHICLE_HAS_STRONG_AXLES(vehicle, false)

    VEHICLE.VEHICLE_SET_RAMP_AND_RAMMING_CARS_TAKE_DAMAGE(vehicle, true)
    VEHICLE.SET_INCREASE_WHEEL_CRUSH_DAMAGE(vehicle, true)
    VEHICLE.SET_DISABLE_DAMAGE_WITH_PICKED_UP_ENTITY(vehicle, 0)
    VEHICLE.SET_VEHICLE_USES_MP_PLAYER_DAMAGE_MULTIPLIER(vehicle, 0)
    VEHICLE.SET_FORCE_VEHICLE_ENGINE_DAMAGE_BY_BULLET(vehicle, true)

    VEHICLE.SET_DISABLE_EXPLODE_FROM_BODY_DAMAGE_ON_COLLISION(vehicle, 0)
    VEHICLE.SET_VEHICLE_EXPLODES_ON_HIGH_EXPLOSION_DAMAGE(vehicle, true)
    VEHICLE.SET_VEHICLE_EXPLODES_ON_EXPLOSION_DAMAGE_AT_ZERO_BODY_HEALTH(vehicle, true)

    VEHICLE.SET_HELI_TAIL_BOOM_CAN_BREAK_OFF(vehicle, true)
    VEHICLE.SET_DISABLE_HELI_EXPLODE_FROM_BODY_DAMAGE(vehicle, 0)

    VEHICLE.SET_PLANE_RESIST_TO_EXPLOSION(vehicle, false)
    VEHICLE.SET_HELI_RESIST_TO_EXPLOSION(vehicle, false)
end

menu.action(Vehicle_Upgrade, "升级强化载具", { "strong_veh" }, "升级强化当前或上一辆载具",
    function()
        local vehicle = entities.get_user_vehicle_as_handle()
        if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
            tVehicle.Upgrade.upgrade(vehicle)
            util.toast("载具升级强化完成!")
        else
            util.toast("请先进入载具:)")
        end
    end)
menu.toggle_loop(Vehicle_Upgrade, "自动升级强化载具", { "auto_strong_veh" },
    "自动升级强化正在进入驾驶位的载具", function()
        local user_ped = players.user_ped()
        if PED.IS_PED_GETTING_INTO_A_VEHICLE(user_ped) then
            local veh = PED.GET_VEHICLE_PED_IS_TRYING_TO_ENTER(user_ped)
            if ENTITY.IS_ENTITY_A_VEHICLE(veh) and PED.GET_SEAT_PED_IS_TRYING_TO_ENTER(user_ped) == -1 then
                request_control(veh)
                tVehicle.Upgrade.upgrade(veh)

                -- 通知
                local veh_name = get_vehicle_display_name(veh)
                local text = "进入载具: " .. veh_name
                if has_control_entity(veh) then
                    THEFEED_POST.TEXT(text .. "\n升级强化完成!")
                else
                    THEFEED_POST.TEXT(text .. "\n升级强化未完成: 未能成功控制载具")
                end

                util.yield(50)
            end
        end
    end)

menu.action(Vehicle_Upgrade, "弱化载具属性", {}, "弱化当前或上一辆载具的属性", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        tVehicle.Upgrade.remove(vehicle)
        util.toast("载具弱化完成!")
    else
        util.toast("请先进入载具:)")
    end
end)

menu.divider(Vehicle_Upgrade, "载具性能")
menu.toggle(Vehicle_Upgrade, "主要性能", {}, "引擎、刹车、变速箱、防御", function(toggle)
    tVehicle.Upgrade.performance = toggle
end, true)
menu.toggle(Vehicle_Upgrade, "涡轮增压", {}, "", function(toggle)
    tVehicle.Upgrade.turbo = toggle
end, true)

menu.divider(Vehicle_Upgrade, "载具部件")
menu.toggle(Vehicle_Upgrade, "防弹轮胎", {}, "", function(toggle)
    tVehicle.Upgrade.bulletproof_tyre = toggle
end, true)
menu.toggle(Vehicle_Upgrade, "车门不可损坏", {}, "全部车门", function(toggle)
    tVehicle.Upgrade.unbreakable_door = toggle
end, true)
menu.toggle(Vehicle_Upgrade, "车灯不可损坏", {}, "", function(toggle)
    tVehicle.Upgrade.unbreakable_light = toggle
end, true)
menu.toggle(Vehicle_Upgrade, "部件不可分离", {}, "", function(toggle)
    tVehicle.Upgrade.unbreak = toggle
end, true)

menu.divider(Vehicle_Upgrade, "载具生命")
menu.slider(Vehicle_Upgrade, "实体最大血量倍数", {}, "",
    1, 20, 1, 1, function(value)
        tVehicle.Upgrade.max_health_multiplier = value
    end)
menu.slider(Vehicle_Upgrade, "载具血量倍数", {},
    "引擎血量，车身外观血量，油箱血量，直升机主旋翼和尾旋翼血量\n载具血量 = 1000 * multiplier",
    1, 20, 1, 1, function(value)
        tVehicle.Upgrade.health_multiplier = value
    end)
menu.slider_float(Vehicle_Upgrade, "受到伤害倍数", {}, "数值越低，受到的伤害就越低",
    0, 100, 50, 10, function(value)
        tVehicle.Upgrade.damage_scale = value * 0.01
    end)
menu.toggle(Vehicle_Upgrade, "无视载具司机的爆炸", {}, "司机投掷的炸弹不会对载具造成伤害",
    function(toggle)
        tVehicle.Upgrade.no_driver_explosion_damage = toggle
    end, true)
menu.toggle(Vehicle_Upgrade, "其它属性增强", {}, "其它属性的提高,可以提高防炸性等",
    function(toggle)
        tVehicle.Upgrade.other_strong = toggle
    end, true)

--#endregion Vehicle Upgrade

--#region Vehicle Weapon

local Vehicle_Weapon <const> = menu.list(Vehicle_Options, "载具武器", {}, "")

local VehicleWeapon = {
    delay = 500,
    direction = {
        [1] = true,  -- front
        [2] = false, -- rear
        [3] = false, -- left
        [4] = false, -- right
        [5] = false, -- up
        [6] = false, -- down
    },
    launchNum = 3,
    weaponHash = 4171469727,
    isOwned = false,
    damage = 1000,
    speed = 2000,
    createTraceVfx = true,
    allowRumble = true,
    perfectAccuracy = true,
    startOffset = {
        -- front
        [1] = { x = 0.0, y = 1.0, z = 0.0 },
        -- rear
        [2] = { x = 0.0, y = -1.0, z = 0.0 },
        -- left
        [3] = { x = -1.0, y = 0.0, z = 0.0 },
        -- right
        [4] = { x = 1.0, y = 0.0, z = 0.0 },
        -- up
        [5] = { x = 0.0, y = 0.0, z = 2.5 },
        -- down
        [6] = { x = 0.0, y = 0.0, z = -2.5 },
    },
    disableHorn = true,
}

function VehicleWeapon.GetOffsets(vehicle, direction)
    local min, max = v3.new(), v3.new()
    MISC.GET_MODEL_DIMENSIONS(ENTITY.GET_ENTITY_MODEL(vehicle), min, max)

    local offset_z = get_middle_num(min.z, max.z)
    local offsets = {}
    local startOffset, end_offset

    if direction == 1 then
        offsets[1] = v3.new(min.x, max.y, offset_z)
        offsets[2] = v3.new(get_middle_num(min.x, max.x), max.y, offset_z)
        offsets[3] = v3.new(max.x, max.y, offset_z)
        -- front
        end_offset = v3.new(0.0, 1.0, 0.0)
    elseif direction == 2 then
        offsets[1] = v3.new(min.x, min.y, offset_z)
        offsets[2] = v3.new(get_middle_num(min.x, max.x), min.y, offset_z)
        offsets[3] = v3.new(max.x, min.y, offset_z)
        -- rear
        end_offset = v3.new(0.0, -1.0, 0.0)
    elseif direction == 3 then
        offsets[1] = v3.new(min.x, max.y, offset_z)
        offsets[2] = v3.new(min.x, get_middle_num(min.y, max.y), offset_z)
        offsets[3] = v3.new(min.x, min.y, offset_z)
        -- left
        end_offset = v3.new(-1.0, 0.0, 0.0)
    elseif direction == 4 then
        offsets[1] = v3.new(max.x, max.y, offset_z)
        offsets[2] = v3.new(max.x, get_middle_num(min.y, max.y), offset_z)
        offsets[3] = v3.new(max.x, min.y, offset_z)
        -- right
        end_offset = v3.new(1.0, 0.0, 0.0)
    elseif direction == 5 then
        offsets[1] = v3.new(get_middle_num(min.x, max.x), max.y, offset_z)
        offsets[2] = v3.new(get_middle_num(min.x, max.x), get_middle_num(min.y, max.y), offset_z)
        offsets[3] = v3.new(get_middle_num(min.x, max.x), min.y, offset_z)
        -- up
        end_offset = v3.new(0.0, 0.0, 1.0)
    elseif direction == 6 then
        offsets[1] = v3.new(get_middle_num(min.x, max.x), max.y, offset_z)
        offsets[2] = v3.new(get_middle_num(min.x, max.x), get_middle_num(min.y, max.y), offset_z)
        offsets[3] = v3.new(get_middle_num(min.x, max.x), min.y, offset_z)
        -- down
        end_offset = v3.new(0.0, 0.0, -1.0)
    end

    start_offset = v3.new(VehicleWeapon.startOffset[direction])
    end_offset:mul(500.0) -- distance

    local launchNum = VehicleWeapon.launchNum
    if launchNum == 1 then
        offsets[1] = nil
        offsets[3] = nil
    elseif launchNum == 2 then
        offsets[2] = nil
    end

    return start_offset, end_offset, offsets
end

function VehicleWeapon.Shoot(vehicle)
    local user_ped = players.user_ped()

    local weaponHash = VehicleWeapon.weaponHash
    if weaponHash == "PLAYER_CURRENT_WEAPON" then
        weaponHash = WEAPON.GET_SELECTED_PED_WEAPON(players.user_ped())
    elseif weaponHash == "VEHICLE_CURRENT_WEAPON" then
        local ptr = memory.alloc_int()
        WEAPON.GET_CURRENT_PED_VEHICLE_WEAPON(user_ped, ptr)
        weaponHash = memory.read_int(ptr)
    end
    if not WEAPON.HAS_WEAPON_ASSET_LOADED(weaponHash) then
        request_weapon_asset(weaponHash)
    end

    local owner = 0
    if VehicleWeapon.isOwned then
        owner = user_ped
    end

    for dir, toggle in pairs(VehicleWeapon.direction) do
        if toggle then
            local start_offset, end_offset, offsets = VehicleWeapon.GetOffsets(vehicle, dir)
            local start_pos, end_pos
            for _, offset in pairs(offsets) do
                if offset ~= nil then
                    offset:add(start_offset)
                    start_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(vehicle, offset.x, offset.y, offset.z)

                    offset:add(end_offset)
                    end_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(vehicle, offset.x, offset.y, offset.z)

                    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(
                        start_pos.x, start_pos.y, start_pos.z,
                        end_pos.x, end_pos.y, end_pos.z,
                        VehicleWeapon.damage,
                        VehicleWeapon.perfectAccuracy,
                        weaponHash,
                        owner,
                        VehicleWeapon.createTraceVfx,
                        VehicleWeapon.allowRumble,
                        VehicleWeapon.speed,
                        vehicle,
                        0)
                end
            end
        end
    end
end

function VehicleWeapon.DrawLine(vehicle)
    for dir, toggle in pairs(VehicleWeapon.direction) do
        if toggle then
            local start_offset, end_offset, offsets = VehicleWeapon.GetOffsets(vehicle, dir)
            local start_pos, end_pos
            for _, offset in pairs(offsets) do
                if offset ~= nil then
                    offset:add(start_offset)
                    start_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(vehicle, offset.x, offset.y, offset.z)

                    offset:add(end_offset)
                    end_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(vehicle, offset.x, offset.y, offset.z)

                    DRAW_LINE(start_pos, end_pos)
                end
            end
        end
    end
end

menu.toggle_loop(Vehicle_Weapon, "载具武器[E键射击]", { "veh_weapon" }, "", function()
    local vehicle = entities.get_user_vehicle_as_handle(false)
    if vehicle ~= INVALID_GUID and PAD.IS_CONTROL_PRESSED(0, 51) then
        if VehicleWeapon.disableHorn then
            AUDIO.SET_HORN_ENABLED(vehicle, false)
        end

        VehicleWeapon.Shoot(vehicle)
        util.yield(VehicleWeapon.delay)
    end
end, function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        if VehicleWeapon.disableHorn then
            AUDIO.SET_HORN_ENABLED(vehicle, true)
        end
    end
end)

menu.toggle_loop(Vehicle_Weapon, "绘制射击连线", {}, "", function()
    local vehicle = entities.get_user_vehicle_as_handle(false)
    if vehicle ~= INVALID_GUID then
        VehicleWeapon.DrawLine(vehicle)
    end
end)

----------------
-- Setting
----------------

menu.divider(Vehicle_Weapon, "设置")
menu.slider(Vehicle_Weapon, "循环延迟", { "veh_weapon_delay" }, "单位: ms", 0, 5000, 500, 10,
    function(value)
        VehicleWeapon.delay = value
    end)

local Vehicle_Weapon_Direction <const> = menu.list(Vehicle_Weapon, "方向", {}, "")
for k, v in pairs({ "前", "后", "左", "右", "上", "下" }) do
    menu.toggle(Vehicle_Weapon_Direction, v, {}, "", function(toggle)
        VehicleWeapon.direction[k] = toggle
    end, VehicleWeapon.direction[k])
end

local Vehicle_Weapon_Select <const> = menu.list(Vehicle_Weapon, "武器", {}, "")
VehicleWeapon.Weapon_MenuReadonly = menu.readonly(Vehicle_Weapon_Select, "选择的武器", "VEHICLE_WEAPON_SPACE_ROCKET")

local Vehicle_Weapon_SelectPlayer = rs_menu.all_weapons_without_melee(Vehicle_Weapon_Select, "手持武器",
    {}, "", function(hash, name)
        VehicleWeapon.weaponHash = hash
        menu.set_value(VehicleWeapon.Weapon_MenuReadonly, name)
    end, false)
rs_menu.current_weapon_action(Vehicle_Weapon_SelectPlayer, "玩家当前使用的武器", function()
    VehicleWeapon.weaponHash = "PLAYER_CURRENT_WEAPON"
    menu.set_value(VehicleWeapon.Weapon_MenuReadonly, "PLAYER_CURRENT_WEAPON")
end, false)

local Vehicle_Weapon_SelectVehicle = rs_menu.vehicle_weapons(Vehicle_Weapon_Select, "载具武器",
    {}, "", function(hash, model)
        VehicleWeapon.weaponHash = hash
        menu.set_value(VehicleWeapon.Weapon_MenuReadonly, model)
    end, false)
rs_menu.current_weapon_action(Vehicle_Weapon_SelectVehicle, "载具当前使用的武器", function()
    VehicleWeapon.weaponHash = "VEHICLE_CURRENT_WEAPON"
    menu.set_value(VehicleWeapon.Weapon_MenuReadonly, "VEHICLE_CURRENT_WEAPON")
end, false)


menu.slider(Vehicle_Weapon, "发射数量", { "veh_weapon_launchNum" }, "", 1, 3, 3, 1, function(value)
    VehicleWeapon.launchNum = value
end)
menu.toggle(Vehicle_Weapon, "署名射击", {}, "以玩家名义", function(toggle)
    VehicleWeapon.isOwned = toggle
end)
menu.slider(Vehicle_Weapon, "伤害", { "veh_weapon_damage" }, "", 0, 10000, 1000, 100,
    function(value)
        VehicleWeapon.damage = value
    end)
menu.slider(Vehicle_Weapon, "速度", { "veh_weapon_speed" }, "", 0, 10000, 2000, 100,
    function(value)
        VehicleWeapon.speed = value
    end)


local Vehicle_Weapon_StartOffset <const> = menu.list(Vehicle_Weapon, "起始射击位置偏移", {}, "")
for k, v in pairs({ "前", "后", "左", "右", "上", "下" }) do
    local menu_list = menu.list(Vehicle_Weapon_StartOffset, v, {}, "")

    menu.slider_float(menu_list, "X", { "veh_weapon_dir" .. k .. "_x" }, "",
        -10000, 10000, VehicleWeapon.startOffset[k].x * 100, 10,
        function(value)
            value = value * 0.01
            VehicleWeapon.startOffset[k].x = value
        end)
    menu.slider_float(menu_list, "Y", { "veh_weapon_dir" .. k .. "_y" }, "",
        -10000, 10000, VehicleWeapon.startOffset[k].y * 100, 10,
        function(value)
            value = value * 0.01
            VehicleWeapon.startOffset[k].y = value
        end)
    menu.slider_float(menu_list, "Z", { "veh_weapon_dir" .. k .. "_z" }, "",
        -10000, 10000, VehicleWeapon.startOffset[k].z * 100, 10,
        function(value)
            value = value * 0.01
            VehicleWeapon.startOffset[k].z = value
        end)
end

menu.toggle(Vehicle_Weapon, "禁用载具喇叭", {}, "", function(toggle)
    VehicleWeapon.disableHorn = toggle
end, true)

--#endregion Vehicle Weapon

--#region Vehicle Window

local Vehicle_Window <const> = menu.list(Vehicle_Options, "载具车窗", {}, "")

tVehicle.Window = {
    toggles = {},
    toggleMenus = {},
    windowList = {
        -- index, name
        { 0, "前左车窗" }, -- SC_WINDOW_FRONT_LEFT = 0
        { 1, "前右车窗" }, -- SC_WINDOW_FRONT_RIGHT = 1
        { 2, "后左车窗" }, -- SC_WINDOW_REAR_LEFT = 2
        { 3, "后右车窗" }, -- SC_WINDOW_REAR_RIGHT = 3
        { 4, "中间左车窗" }, -- SC_WINDOW_MIDDLE_LEFT = 4
        { 5, "中间右车窗" }, -- SC_WINDOW_MIDDLE_RIGHT = 5
        { 6, "前挡风车窗" }, -- SC_WINDSCREEN_FRONT = 6
        { 7, "后挡风车窗" }, -- SC_WINDSCREEN_REAR = 7
    },
}

local Vehicle_Window_Select <const> = menu.list(Vehicle_Window, "选择车窗", {}, "")

menu.toggle(Vehicle_Window_Select, "全部开/关", {}, "", function(toggle)
    for key, value in pairs(tVehicle.Window.toggleMenus) do
        if menu.is_ref_valid(value) then
            menu.set_value(value, toggle)
        end
    end
end, true)

for _, item in pairs(tVehicle.Window.windowList) do
    local index = item[1]
    local name = item[2]

    tVehicle.Window.toggles[index] = true
    tVehicle.Window.toggleMenus[index] = menu.toggle(Vehicle_Window_Select, name, {}, "", function(toggle)
        tVehicle.Window.toggles[index] = toggle
    end, true)
end

menu.toggle_loop(Vehicle_Window, "修复车窗", { "fix_veh_window" }, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        for index, toggle in pairs(tVehicle.Window.toggles) do
            if toggle then
                VEHICLE.FIX_VEHICLE_WINDOW(vehicle, index)
            end
        end
    end
end)
menu.toggle_loop(Vehicle_Window, "摇上车窗", { "roll_up_veh_window" }, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        for index, toggle in pairs(tVehicle.Window.toggles) do
            if toggle then
                VEHICLE.ROLL_UP_WINDOW(vehicle, index)
            end
        end
    end
end)
menu.toggle_loop(Vehicle_Window, "摇下车窗", { "roll_down_veh_window" }, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        for index, toggle in pairs(tVehicle.Window.toggles) do
            if toggle then
                VEHICLE.ROLL_DOWN_WINDOW(vehicle, index)
            end
        end
    end
end)
menu.toggle_loop(Vehicle_Window, "粉碎车窗", { "smash_veh_window" }, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        for index, toggle in pairs(tVehicle.Window.toggles) do
            if toggle then
                VEHICLE.SMASH_VEHICLE_WINDOW(vehicle, index)
            end
        end
    end
end)

--#endregion Vehicle Window

--#region Vehicle Door

local Vehicle_Door <const> = menu.list(Vehicle_Options, "载具车门", {}, "")

tVehicle.Door = {
    toggles = {},
    toggleMenus = {},
    doorList = {
        -- index, name
        { 0, "左前门" }, -- VEH_EXT_DOOR_DSIDE_F = 0
        { 1, "右前门" }, -- VEH_EXT_DOOR_DSIDE_R = 1
        { 2, "左后门" }, -- VEH_EXT_DOOR_PSIDE_F = 2
        { 3, "右后门" }, -- VEH_EXT_DOOR_PSIDE_R = 3
        { 4, "引擎盖" }, -- VEH_EXT_BONNET = 4
        { 5, "后备箱" } -- VEH_EXT_BOOT = 5
    },
}

local Vehicle_Door_Select <const> = menu.list(Vehicle_Door, "选择车门", {}, "")

menu.toggle(Vehicle_Door_Select, "全部开/关", {}, "", function(toggle)
    for key, value in pairs(tVehicle.Door.toggleMenus) do
        if menu.is_ref_valid(value) then
            menu.set_value(value, toggle)
        end
    end
end, true)

for _, data in pairs(tVehicle.Door.doorList) do
    local index = data[1]
    local name = data[2]

    tVehicle.Door.toggles[index] = true
    tVehicle.Door.toggleMenus[index] = menu.toggle(Vehicle_Door_Select, name, {}, "", function(toggle)
        tVehicle.Door.toggles[index] = toggle
    end, true)
end

menu.toggle_loop(Vehicle_Door, "打开车门", { "open_veh_door" }, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        for index, toggle in pairs(tVehicle.Door.toggles) do
            if toggle then
                VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, index, false, false)
            end
        end
    end
end)
menu.action(Vehicle_Door, "关闭车门", { "close_veh_door" }, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        for index, toggle in pairs(tVehicle.Door.toggles) do
            if toggle then
                VEHICLE.SET_VEHICLE_DOOR_SHUT(vehicle, index, false)
            end
        end
    end
end)
menu.toggle_loop(Vehicle_Door, "破坏车门", { "broken_veh_door" }, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        for index, toggle in pairs(tVehicle.Door.toggles) do
            if toggle then
                VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, index, false)
            end
        end
    end
end)
menu.toggle_loop(Vehicle_Door, "删除车门", { "delete_veh_door" }, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        for index, toggle in pairs(tVehicle.Door.toggles) do
            if toggle then
                VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, index, true)
            end
        end
    end
end)


menu.divider(Vehicle_Door, "锁门")

tVehicle.DoorLock = {
    ListItem = {
        { "解锁", {}, "" }, -- VEHICLELOCK_UNLOCKED == 1
        { "上锁", {}, "" }, -- VEHICLELOCK_LOCKED
        { "Lock Out Player Only", {}, "" }, -- VEHICLELOCK_LOCKOUT_PLAYER_ONLY
        { "玩家锁定在里面", {}, "" }, -- VEHICLELOCK_LOCKED_PLAYER_INSIDE
        { "Locked Initially", {}, "" }, -- VEHICLELOCK_LOCKED_INITIALLY
        { "强制关闭车门", {}, "" }, -- VEHICLELOCK_FORCE_SHUT_DOORS
        { "上锁但可被破坏", {}, "可以破开车窗开门" }, -- VEHICLELOCK_LOCKED_BUT_CAN_BE_DAMAGED
        { "上锁但后备箱解锁", {}, "" }, -- VEHICLELOCK_LOCKED_BUT_BOOT_UNLOCKED
        { "Locked No Passagers", {}, "" }, -- VEHICLELOCK_LOCKED_NO_PASSENGERS
        { "不能进入", {}, "按F无上车动作" } -- VEHICLELOCK_CANNOT_ENTER
    }
}
menu.list_action(Vehicle_Door, "设置锁门类型", {}, "", tVehicle.DoorLock.ListItem, function(value)
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle, value)
    end
end)

menu.toggle(Vehicle_Door, "对所有玩家锁门", {}, "", function(toggle)
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(vehicle, toggle)
    end
end)
menu.toggle(Vehicle_Door, "对所有团队锁门", {}, "", function(toggle)
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_TEAMS(vehicle, toggle)
    end
end)

--#endregion Vehicle Door

--#region Vehicle Radio

local Vehicle_Radio <const> = menu.list(Vehicle_Options, "载具电台", {}, "")

tVehicle.Radio = {
    station_select = 1,
}

menu.list_select(Vehicle_Radio, "选择电台", {}, "", Vehicle_T.RadioStation.ListItem, 1, function(value)
    tVehicle.Radio.station_select = value
end)
menu.toggle_loop(Vehicle_Radio, "自动更改电台", { "auto_veh_radio" }, "自动更改正在进入驾驶位的载具的电台",
    function()
        if PED.IS_PED_GETTING_INTO_A_VEHICLE(players.user_ped()) then
            local veh = PED.GET_VEHICLE_PED_IS_ENTERING(players.user_ped())
            if ENTITY.IS_ENTITY_A_VEHICLE(veh) and PED.GET_SEAT_PED_IS_TRYING_TO_ENTER(players.user_ped()) == -1 then
                local stationName = Vehicle_RadioStation.LabelList[tVehicle.Radio.station_select]
                AUDIO.SET_VEH_RADIO_STATION(veh, stationName)
                AUDIO.SET_RADIO_TO_STATION_NAME(stationName)
            end
        end
    end)
menu.toggle_loop(Vehicle_Radio, "禁用载具电台", {}, "当前或上一辆载具将无法选择更改电台",
    function()
        local vehicle = entities.get_user_vehicle_as_handle()
        if vehicle ~= INVALID_GUID then
            AUDIO.SET_VEHICLE_RADIO_ENABLED(vehicle, false)
        end
    end, function()
        local vehicle = entities.get_user_vehicle_as_handle()
        if vehicle ~= INVALID_GUID then
            AUDIO.SET_VEHICLE_RADIO_ENABLED(vehicle, true)
        end
    end)
menu.toggle(Vehicle_Radio, "电台只播放音乐", {}, "", function(toggle)
    for _, stationName in pairs(Vehicle_T.RadioStation.LabelList) do
        AUDIO.SET_RADIO_STATION_MUSIC_ONLY(stationName, toggle)
    end
end)

--#endregion Vehicle Radio

--#region Vehicle Info

local Vehicle_Info <const> = menu.list(Vehicle_Options, "载具信息显示", {}, "")

tVehicle.Info = {
    -- show setting --
    only_current_vehicle = true,
    x = 0.26,
    y = 0.80,
    scale = 0.65,
    color = Colors.white,
    -- show info --
    vehicle_name = true,
    entity_health = true,
    engine_health = true,
    body_health = false,
    petrol_tank_health = false,
    heli_health = false,
}

menu.toggle_loop(Vehicle_Info, "显示载具信息", {}, "", function()
    if tVehicle.Info.only_current_vehicle and not PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
        return
    end

    local veh = entities.get_user_vehicle_as_handle()
    if veh ~= INVALID_GUID then
        local text = ""

        if tVehicle.Info.vehicle_name then
            text = text .. get_vehicle_display_name(veh) .. "\n"
        end
        if tVehicle.Info.entity_health then
            text = text .. "实体血量: " ..
                ENTITY.GET_ENTITY_HEALTH(veh) .. "/" .. ENTITY.GET_ENTITY_MAX_HEALTH(veh) .. "\n"
        end
        if tVehicle.Info.engine_health then
            text = text .. "引擎血量: " .. math.ceil(VEHICLE.GET_VEHICLE_ENGINE_HEALTH(veh)) .. "\n"
        end
        if tVehicle.Info.body_health then
            text = text .. "车身外观血量: " .. math.ceil(VEHICLE.GET_VEHICLE_BODY_HEALTH(veh)) .. "\n"
        end
        if tVehicle.Info.petrol_tank_health then
            text = text .. "油箱血量: " .. math.ceil(VEHICLE.GET_VEHICLE_PETROL_TANK_HEALTH(veh)) .. "\n"
        end
        if tVehicle.Info.heli_health and VEHICLE.IS_THIS_MODEL_A_HELI(ENTITY.GET_ENTITY_MODEL(veh)) then
            text = text .. "Heli Main Rotor Health: " .. math.ceil(VEHICLE.GET_HELI_MAIN_ROTOR_HEALTH(veh)) .. "\n"
            text = text .. "Heli Tail Rotor Health: " .. math.ceil(VEHICLE.GET_HELI_TAIL_ROTOR_HEALTH(veh)) .. "\n"
            text = text .. "Heli Boom Rotor Health: " .. math.ceil(VEHICLE.GET_HELI_TAIL_BOOM_HEALTH(veh)) .. "\n"
        end

        directx.draw_text(tVehicle.Info.x, tVehicle.Info.y,
            text,
            ALIGN_TOP_LEFT,
            tVehicle.Info.scale,
            tVehicle.Info.color)
    end
end)

local Vehicle_Info_ShowSetting <const> = menu.list(Vehicle_Info, "显示设置", {}, "")
menu.toggle(Vehicle_Info_ShowSetting, "只显示当前载具信息", {}, "", function(toggle)
    tVehicle.Info.only_current_vehicle = toggle
end, true)
menu.slider_float(Vehicle_Info_ShowSetting, "位置X", { "veh_info_x" }, "", 0, 100, 26, 1, function(value)
    tVehicle.Info.x = value * 0.01
end)
menu.slider_float(Vehicle_Info_ShowSetting, "位置Y", { "veh_info_y" }, "", 0, 100, 80, 1, function(value)
    tVehicle.Info.y = value * 0.01
end)
menu.slider_float(Vehicle_Info_ShowSetting, "文字大小", { "veh_info_scale" }, "",
    0, 1000, 65, 1, function(value)
        tVehicle.Info.scale = value * 0.01
    end)
menu.colour(Vehicle_Info_ShowSetting, "文字颜色", { "veh_info_colour" }, "", Colors.white, false,
    function(colour)
        tVehicle.Info.color = colour
    end)

menu.divider(Vehicle_Info, "显示的信息")
menu.toggle(Vehicle_Info, "载具名称", {}, "", function(toggle)
    tVehicle.Info.vehicle_name = toggle
end, true)
menu.toggle(Vehicle_Info, "实体血量", {}, "", function(toggle)
    tVehicle.Info.entity_health = toggle
end, true)
menu.toggle(Vehicle_Info, "引擎血量", {}, "", function(toggle)
    tVehicle.Info.engine_health = toggle
end, true)
menu.toggle(Vehicle_Info, "车身外观血量", {}, "", function(toggle)
    tVehicle.Info.body_health = toggle
end)
menu.toggle(Vehicle_Info, "油箱血量", {}, "", function(toggle)
    tVehicle.Info.petrol_tank_health = toggle
end)
menu.toggle(Vehicle_Info, "直升机螺旋桨血量", {}, "", function(toggle)
    tVehicle.Info.heli_health = toggle
end)

--#endregion Vehicle Info

--#region Options

local veh_dirt_level = 0.0
menu.click_slider_float(Vehicle_Options, "载具灰尘程度", { "veh_dirt_level" }, "载具全身灰尘程度",
    0, 1500, 0, 100, function(value)
        veh_dirt_level = value * 0.01
        local vehicle = entities.get_user_vehicle_as_handle()
        if vehicle ~= INVALID_GUID then
            if VEHICLE.GET_VEHICLE_DIRT_LEVEL(vehicle) ~= veh_dirt_level then
                VEHICLE.SET_VEHICLE_DIRT_LEVEL(vehicle, veh_dirt_level)
            end
        end
    end)
menu.toggle_loop(Vehicle_Options, "锁定载具灰尘程度", {}, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        if VEHICLE.GET_VEHICLE_DIRT_LEVEL(vehicle) ~= veh_dirt_level then
            VEHICLE.SET_VEHICLE_DIRT_LEVEL(vehicle, veh_dirt_level)
        end
    end
end)
menu.toggle_loop(Vehicle_Options, "自动开启载具引擎", {}, "自动开启正在进入驾驶位的载具的引擎",
    function()
        if PED.IS_PED_GETTING_INTO_A_VEHICLE(players.user_ped()) then
            local veh = PED.GET_VEHICLE_PED_IS_ENTERING(players.user_ped())
            if ENTITY.IS_ENTITY_A_VEHICLE(veh) and PED.GET_SEAT_PED_IS_TRYING_TO_ENTER(players.user_ped()) == -1 then
                VEHICLE.SET_VEHICLE_ENGINE_HEALTH(veh, 1000)
                VEHICLE.SET_VEHICLE_ENGINE_ON(veh, true, true, true)
            end
        end
    end)
menu.toggle_loop(Vehicle_Options, "自动解锁载具车门", {}, "自动解锁正在进入的载具的车门",
    function()
        local vehicle = 0
        if PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
            vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
        else
            vehicle = PED.GET_VEHICLE_PED_IS_TRYING_TO_ENTER(players.user_ped())
        end

        if vehicle ~= 0 then
            if request_control(vehicle) then
                unlock_vehicle_doors(vehicle)
                VEHICLE.SET_VEHICLE_IS_CONSIDERED_BY_PLAYER(vehicle, true)
                VEHICLE.SET_VEHICLE_UNDRIVEABLE(vehicle, false)
                ENTITY.FREEZE_ENTITY_POSITION(vehicle, false)
            else
                util.toast("请求控制失败，请重试")
            end
        end
    end)
menu.toggle_loop(Vehicle_Options, "无限动能回收加速", {}, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        if VEHICLE.GET_VEHICLE_HAS_KERS(vehicle) then
            local vehicle_ptr = entities.handle_to_pointer(vehicle)
            local kers_boost_max = memory.read_float(vehicle_ptr + 0x904)
            memory.write_float(vehicle_ptr + 0x908, kers_boost_max) -- m_kers_boost
        end
    end
end)
menu.toggle_loop(Vehicle_Options, "无限载具跳跃", {}, "然而落地后才能继续跳跃", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        if VEHICLE.GET_CAR_HAS_JUMP(vehicle) then
            local vehicle_ptr = entities.handle_to_pointer(vehicle)
            memory.write_float(vehicle_ptr + 0x390, 5.0) -- m_jump_boost_charge
        end
    end
end)

--#endregion Options




------------------------------------------
----------    Entity Options    ----------
------------------------------------------

require "RScript.Menu.Entity"




-------------------------------------------
----------    Mission Options    ----------
-------------------------------------------

require "RScript.Menu.Mission"




------------------------------------------
----------    Online Options    ----------
------------------------------------------

require "RScript.Menu.Online"




-------------------------------------------
---------    Assistant Options    ---------
-------------------------------------------

require "RScript.Menu.Assistant"




---------------------------------------------
----------    Bodyguard Options    ----------
---------------------------------------------

require "RScript.Menu.Bodyguard"




-------------------------------------------
----------    Clean Options    ------------
-------------------------------------------

local Clear_Options <const> = menu.list(Menu_Root, "清理选项", {}, "移除,清理等")

local tClear = {}

--#region Clear Area

local Clear_Area <const> = menu.list(Clear_Options, "清理区域", {}, "无法清理任务实体")

tClear.Area = {
    radius = 100,
    broadcast = 0,
}

menu.toggle_loop(Clear_Area, "清理区域", { "cls_area" }, "清理区域内所有东西", function()
    local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    MISC.CLEAR_AREA(coords.x, coords.y, coords.z, tClear.Area.radius, true, false, false, cls_broadcast)
end)
menu.toggle_loop(Clear_Area, "清理载具", { "cls_vehicles" }, "清理区域内所有载具", function()
    local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    MISC.CLEAR_AREA_OF_VEHICLES(coords.x, coords.y, coords.z, tClear.Area.radius, false, false, false, false,
        cls_broadcast, false, 0)
end)
menu.toggle_loop(Clear_Area, "清理行人", { "cls_peds" }, "清理区域内所有行人", function()
    local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    MISC.CLEAR_AREA_OF_PEDS(coords.x, coords.y, coords.z, tClear.Area.radius, cls_broadcast)
end)
menu.toggle_loop(Clear_Area, "清理警察", { "cls_cops" }, "清理区域内所有警察", function()
    local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    MISC.CLEAR_AREA_OF_COPS(coords.x, coords.y, coords.z, tClear.Area.radius, cls_broadcast)
end)
menu.toggle_loop(Clear_Area, "清理物体", { "cls_objects" }, "清理区域内所有物体", function()
    local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    MISC.CLEAR_AREA_OF_OBJECTS(coords.x, coords.y, coords.z, tClear.Area.radius, cls_broadcast)
end)
menu.toggle_loop(Clear_Area, "清理投掷物", { "cls_projectiles" }, "清理区域内所有子弹、炮弹、投掷物等",
    function()
        local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        MISC.CLEAR_AREA_OF_PROJECTILES(coords.x, coords.y, coords.z, tClear.Area.radius, cls_broadcast)
    end)

menu.divider(Clear_Area, "设置")
menu.slider_float(Clear_Area, "范围半径", { "cls_radius" }, "",
    0, 100000, tClear.Area.radius * 100, 1000, function(value)
        tClear.Area.radius = value * 0.01
    end)
menu.toggle(Clear_Area, "同步到其它玩家", { "cls_broadcast" }, "", function(toggle)
    tClear.Area.broadcast = toggle and 1 or 0
    util.toast("清理区域 网络同步: " .. tostring(toggle and "开" or "关"))
end)


--#endregion Clear Area

--#region Options

menu.toggle_loop(Clear_Options, "移除爆炸和火焰", { "cls_fire" }, "范围: 30", function()
    local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    FIRE.STOP_FIRE_IN_RANGE(pos.x, pos.y, pos.z, 30.0)
    FIRE.STOP_ENTITY_FIRE(players.user_ped())
end)
menu.toggle_loop(Clear_Options, "移除粒子效果", { "cls_ptfx" }, "范围: 30", function()
    local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    GRAPHICS.REMOVE_PARTICLE_FX_IN_RANGE(pos.x, pos.y, pos.z, 30.0)
    GRAPHICS.REMOVE_PARTICLE_FX_FROM_ENTITY(players.user_ped())
end)
menu.toggle_loop(Clear_Options, "移除视觉效果", { "cls_graphics" }, "", function()
    GRAPHICS.ANIMPOSTFX_STOP_ALL()
    GRAPHICS.CLEAR_TIMECYCLE_MODIFIER()
    --GRAPHICS.SET_TIMECYCLE_MODIFIER("DEFAULT")
end)
menu.toggle_loop(Clear_Options, "移除载具上的黏弹", {}, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        NETWORK.REMOVE_ALL_STICKY_BOMBS_FROM_ENTITY(vehicle, 0)
    end
end)
menu.toggle_loop(Clear_Options, "停止所有声音", {}, "", function()
    for i = 0, 99 do
        AUDIO.STOP_SOUND(i)
        AUDIO.RELEASE_SOUND_ID(i)
    end
end)

menu.divider(Clear_Options, "")
menu.action(Clear_Options, "清理已死亡的任务载具", {}, "", function()
    local num = 0
    for _, ent in pairs(entities.get_all_vehicles_as_handles()) do
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) and ENTITY.IS_ENTITY_DEAD(ent) then
            entities.delete(ent)

            if not ENTITY.DOES_ENTITY_EXIST(num) then
                num = num + 1
            end
        end
    end

    if num > 0 then
        util.toast("清理任务载具数量: " .. num)
    end
end)
menu.action(Clear_Options, "清理已死亡的任务NPC", {}, "", function()
    local num = 0
    for _, ent in pairs(entities.get_all_peds_as_handles()) do
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) and ENTITY.IS_ENTITY_DEAD(ent) then
            entities.delete(ent)

            if not ENTITY.DOES_ENTITY_EXIST(num) then
                num = num + 1
            end
        end
    end

    if num > 0 then
        util.toast("清理任务NPC数量: " .. num)
    end
end)
menu.action(Clear_Options, "中断当前动作", { "cls_task" }, "", function()
    TASK.CLEAR_PED_TASKS_IMMEDIATELY(players.user_ped())
end)

--#endregion Options




-----------------------------------------
----------    Other Options    ----------
-----------------------------------------

local Other_Options <const> = menu.list(Menu_Root, "其它选项", {}, "")

Dev_Options = menu.list(Other_Options, "开发者选项", {}, "")
require "RScript.Menu.Dev"

--#region Snack Armour Editor

local Snack_Armour_Editor <const> = menu.list(Other_Options, "零食护甲编辑", {}, "")

menu.action(Snack_Armour_Editor, "补满全部零食", {}, "", function()
    STAT_SET_INT("NO_BOUGHT_YUM_SNACKS", 30)
    STAT_SET_INT("NO_BOUGHT_HEALTH_SNACKS", 15)
    STAT_SET_INT("NO_BOUGHT_EPIC_SNACKS", 5)
    STAT_SET_INT("NUMBER_OF_ORANGE_BOUGHT", 10)
    STAT_SET_INT("NUMBER_OF_BOURGE_BOUGHT", 10)
    STAT_SET_INT("NUMBER_OF_CHAMP_BOUGHT", 5)
    STAT_SET_INT("CIGARETTES_BOUGHT", 20)
    STAT_SET_INT("NUMBER_OF_SPRUNK_BOUGHT", 10)
    util.toast("完成！")
end)
menu.action(Snack_Armour_Editor, "补满全部护甲", {}, "", function()
    STAT_SET_INT("MP_CHAR_ARMOUR_1_COUNT", 10)
    STAT_SET_INT("MP_CHAR_ARMOUR_2_COUNT", 10)
    STAT_SET_INT("MP_CHAR_ARMOUR_3_COUNT", 10)
    STAT_SET_INT("MP_CHAR_ARMOUR_4_COUNT", 10)
    STAT_SET_INT("MP_CHAR_ARMOUR_5_COUNT", 10)
    util.toast("完成！")
end)
menu.action(Snack_Armour_Editor, "补满呼吸器", {}, "", function()
    STAT_SET_INT("BREATHING_APPAR_BOUGHT", 20)
    util.toast("完成！")
end)

menu.divider(Snack_Armour_Editor, "零食")
menu.click_slider(Snack_Armour_Editor, "PQ豆", { "snack_yum" }, "+15 Health", 0, 999, 30, 1, function(value)
    STAT_SET_INT("NO_BOUGHT_YUM_SNACKS", value)
    util.toast("完成！")
end)
menu.click_slider(Snack_Armour_Editor, "宝力旺", { "snack_health" }, "+45 Health", 0, 999, 15, 1,
    function(value)
        STAT_SET_INT("NO_BOUGHT_HEALTH_SNACKS", value)
        util.toast("完成！")
    end)
menu.click_slider(Snack_Armour_Editor, "麦提来", { "snack_epic" }, "+30 Health", 0, 999, 5, 1,
    function(value)
        STAT_SET_INT("NO_BOUGHT_EPIC_SNACKS", value)
        util.toast("完成！")
    end)
menu.click_slider(Snack_Armour_Editor, "易可乐", { "snack_orange" }, "+36 Health", 0, 999, 10, 1,
    function(value)
        STAT_SET_INT("NUMBER_OF_ORANGE_BOUGHT", value)
        util.toast("完成！")
    end)
menu.click_slider(Snack_Armour_Editor, "尿汤啤", { "snack_bourge" }, "", 0, 999, 10, 1, function(value)
    STAT_SET_INT("NUMBER_OF_BOURGE_BOUGHT", value)
    util.toast("完成！")
end)
menu.click_slider(Snack_Armour_Editor, "蓝醉香槟", { "snack_champ" }, "", 0, 999, 5, 1, function(value)
    STAT_SET_INT("NUMBER_OF_CHAMP_BOUGHT", value)
    util.toast("完成！")
end)
menu.click_slider(Snack_Armour_Editor, "香烟", { "snack_cigarettes" }, "-5 Health", 0, 999, 20, 1,
    function(value)
        STAT_SET_INT("CIGARETTES_BOUGHT", value)
        util.toast("完成！")
    end)
menu.click_slider(Snack_Armour_Editor, "霜碧", { "snack_sprunk" }, "+36 Health", 0, 999, 10, 1,
    function(value)
        STAT_SET_INT("NUMBER_OF_SPRUNK_BOUGHT", value)
        util.toast("完成！")
    end)

--#endregion

--#region Options

local nophonespam = menu.ref_by_command_name("nophonespam")
menu.toggle_loop(Other_Options, "打字时禁用来电电话", {}, "避免在打字时有电话把输入框挤掉",
    function()
        if chat.is_open() then
            if not menu.get_value(nophonespam) then
                menu.set_value(nophonespam, true)
            end
        else
            if menu.get_value(nophonespam) then
                menu.set_value(nophonespam, false)
            end
        end
    end, function()
        menu.set_value(nophonespam, false)
    end)
menu.toggle_loop(Other_Options, "跳到下一条对话", { "skip_talk" }, "快速跳过对话", function()
    if AUDIO.IS_SCRIPTED_CONVERSATION_ONGOING() then
        AUDIO.SKIP_TO_NEXT_SCRIPTED_CONVERSATION_LINE()
    end
end)
menu.toggle_loop(Other_Options, "停止对话", { "stop_talk" }, "快速跳过对话", function()
    if AUDIO.IS_SCRIPTED_CONVERSATION_ONGOING() then
        AUDIO.STOP_SCRIPTED_CONVERSATION(false)
    end
end)
menu.toggle_loop(Other_Options, "自动收集财物", { "auto_collect" }, "模拟鼠标左键点击,用于拿取目标财物时", function()
    if TASK.GET_IS_TASK_ACTIVE(players.user_ped(), 135) then
        PAD.SET_CONTROL_VALUE_NEXT_FRAME(0, 237, 1)
        util.yield(30)
    end
end)
menu.toggle_loop(Other_Options, "步行时第一/三人称快捷切换", {}, "步行时第一人称视角和第三人称近距离视角快捷切换", function()
    if CAM.IS_FOLLOW_PED_CAM_ACTIVE() then
        if CAM.GET_FOLLOW_PED_CAM_VIEW_MODE() == 1 or CAM.GET_FOLLOW_PED_CAM_VIEW_MODE() == 2 then
            CAM.SET_FOLLOW_PED_CAM_VIEW_MODE(4)
        end
    end
end)
menu.action(Other_Options, "清除帮助文本信息", { "cls_help_msg" }, "", function()
    HUD.CLEAR_ALL_HELP_MESSAGES()
end)

--#endregion Options




-------------------------------------------
----------    Setting Options    ----------
-------------------------------------------

local Setting_Options <const> = menu.list(Menu_Root, "设置", {}, "")

menu.toggle(Setting_Options, "开发者模式", {}, "会多些通知", function(toggle)
    DEV_MODE = toggle
    setSetting("Dev Mode", toggle)
end, getSetting("Dev Mode"))
menu.toggle(Setting_Options, "更改脚本入口位置", {}, "入口位置: Stand > 设置 上方\n下次启动脚本生效",
    function(toggle)
        setSetting("Change Script Entry", toggle)
    end, getSetting("Change Script Entry"))





-----------------------------------------
----------    About Options    ----------
-----------------------------------------

local About_Options <const> = menu.list(Menu_Root, "关于", {}, "")

menu.readonly(About_Options, "Author", "Rostal")
menu.hyperlink(About_Options, "Github", "https://github.com/TCRoid/Stand-Lua-RScript")
menu.readonly(About_Options, "Version", SCRIPT_VERSION)
menu.readonly(About_Options, "Support GTAO Version", SUPPORT_GTAO)

menu.divider(About_Options, "Update")
local About_LatestVersion = menu.readonly(About_Options, "Latest Version")
menu.action(About_Options, "Check Update", {}, "Only check version", function()
    if not async_http.have_access() then
        util.toast("本Lua被禁止联网")
        return
    end
    menu.set_value(About_LatestVersion, "Checking...")
    async_http.init("https://raw.githubusercontent.com/TCRoid/Stand-Lua-RScript/main/Version.txt", nil, function(data)
        menu.set_value(About_LatestVersion, data)
        if data == SCRIPT_VERSION then
            util.toast("当前为最新版本")
        else
            util.toast("发现新版本?")
        end
    end, function()
        menu.set_value(About_LatestVersion, "")
        util.toast("获取最新版本信息失败!")
    end)
    async_http.dispatch()
end)






----------------------------------------
----------    Backend Loop    ----------
----------------------------------------

util.create_tick_handler(function()
    ------------------------
    -- Main
    ------------------------

    if Loop_Handler.Main.draw_centred_point then
        draw_centred_point()
    end

    ------------------------
    -- Self
    ------------------------

    if Loop_Handler.Self.defense_modifier.value and Loop_Handler.Self.defense_modifier.value ~= 1.0 then
        Loop_Handler.Self.defense_modifier.callback(Loop_Handler.Self.defense_modifier.value)
    end

    ------------------------
    -- Tunables
    ------------------------

    if IS_SCRIPT_RUNNING("tuneables_processing") then
        local tunables = Loop_Handler.Tunables

        -------- Cooldown --------
        if tunables.Cooldown.SpecialCargo then
            Globals.RemoveCooldown.SpecialCargo(true)
        end
        if tunables.Cooldown.VehicleCargo then
            Globals.RemoveCooldown.VehicleCargo(true)
        end
        if tunables.Cooldown.AirFreightCargo then
            Globals.RemoveCooldown.AirFreightCargo(true)
        end
        if tunables.Cooldown.PayphoneHitAndContract then
            Globals.RemoveCooldown.PayphoneHitAndContract(true)
        end
        if tunables.Cooldown.CeoAbility then
            Globals.RemoveCooldown.CeoAbility(true)
        end
        if tunables.Cooldown.CeoVehicle then
            SET_INT_GLOBAL(Globals.GB_CALL_VEHICLE_COOLDOWN, 0)
        end
        if tunables.Cooldown.OtherVehicle then
            Globals.RemoveCooldown.OtherVehicle(true)
        end

        -------- Special Cargo --------
        if tunables.SpecialCargo.Buy then
            for global, value in pairs(tunables.SpecialCargo.Buy) do
                if value then
                    SET_INT_GLOBAL(global, 1)
                end
            end
        end
        if tunables.SpecialCargo.Sell then
            for global, value in pairs(tunables.SpecialCargo.Sell) do
                if value then
                    SET_INT_GLOBAL(global, 1)
                end
            end
        end
        if tunables.SpecialCargo.Type_Refresh_Time and tunables.SpecialCargo.Type_Refresh_Time ~= 2880 then
            SET_INT_GLOBAL(Globals.SpecialCargo.EXEC_CONTRABAND_TYPE_REFRESH_TIME,
                tunables.SpecialCargo.Type_Refresh_Time)
        end
        if tunables.SpecialCargo.Special_Item_Chance and tunables.SpecialCargo.Special_Item_Chance ~= 0.1 then
            SET_INT_GLOBAL(Globals.SpecialCargo.EXEC_CONTRABAND_SPECIAL_ITEM_CHANCE,
                tunables.SpecialCargo.Special_Item_Chance)
        end
        if tunables.SpecialCargo.NoWanted then
            Globals.SpecialCargo.NoWanted(true)
        end

        -------- Vehicle Cargo --------
        if tunables.VehicleCargo.NoWanted then
            Globals.VehicleCargo.NoWanted(true)
        end
        if tunables.VehicleCargo.NoDamageReduction then
            Globals.VehicleCargo.NoDamageReduction(true)
        end

        -------- Bunker --------
        if tunables.Bunker.Resupply_Package_Value and tunables.Bunker.Resupply_Package_Value ~= 20 then
            SET_INT_GLOBAL(Globals.Bunker.GR_RESUPPLY_PACKAGE_VALUE, tunables.Bunker.Resupply_Package_Value)
        end
        if tunables.Bunker.Resupply_Vehicle_Value and tunables.Bunker.Resupply_Vehicle_Value ~= 40 then
            SET_INT_GLOBAL(Globals.Bunker.GR_RESUPPLY_VEHICLE_VALUE, tunables.Bunker.Resupply_Vehicle_Value)
        end
        if tunables.Bunker.Steal then
            for global, value in pairs(tunables.Bunker.Steal) do
                if value then
                    SET_FLOAT_GLOBAL(global, 0)
                end
            end
        end
        if tunables.Bunker.Sell then
            for global, value in pairs(tunables.Bunker.Sell) do
                if value then
                    SET_FLOAT_GLOBAL(global, 0)
                end
            end
        end

        -------- Air Freight --------
        if tunables.AirFreight.Steal then
            for global, value in pairs(tunables.AirFreight.Steal) do
                if value then
                    SET_FLOAT_GLOBAL(global, 0)
                end
            end
        end
        if tunables.AirFreight.Sell then
            for global, value in pairs(tunables.AirFreight.Sell) do
                if value then
                    SET_FLOAT_GLOBAL(global, 0)
                end
            end
        end

        -------- MC Factory --------
        if tunables.Biker.Resupply_Package_Value and tunables.Biker.Resupply_Package_Value ~= 20 then
            SET_INT_GLOBAL(Globals.Biker.BIKER_RESUPPLY_PACKAGE_VALUE, tunables.Biker.Resupply_Package_Value)
        end
        if tunables.Biker.Resupply_Vehicle_Value and tunables.Biker.Resupply_Vehicle_Value ~= 40 then
            SET_INT_GLOBAL(Globals.Biker.BIKER_RESUPPLY_VEHICLE_VALUE, tunables.Biker.Resupply_Vehicle_Value)
        end
        if tunables.Biker.Steal then
            for global, value in pairs(tunables.Biker.Steal) do
                if value then
                    SET_FLOAT_GLOBAL(global, 0)
                end
            end
        end
        if tunables.Biker.Sell then
            for global, value in pairs(tunables.Biker.Sell) do
                if value then
                    SET_INT_GLOBAL(global, 1)
                end
            end
        end
        if tunables.Biker.Contracts.MinPlayer then
            Globals.Biker.Contracts.MinPlayer(true)
        end

        -------- Acid Lab --------
        if tunables.AcidLab.Resupply_Crate_Value and tunables.AcidLab.Resupply_Crate_Value ~= 25 then
            SET_INT_GLOBAL(Globals.AcidLab.ACID_LAB_RESUPPLY_CRATE_VALUE, tunables.AcidLab.Resupply_Crate_Value)
        end

        -------- Payphone --------
        if tunables.Payphone.Hit then
            for global, value in pairs(tunables.Payphone.Hit) do
                if value then
                    SET_FLOAT_GLOBAL(global, 0)
                end
            end
        end

        -------- Misc --------
        if tunables.DisableBusinessRaid then
            Globals.DisableBusinessRaid(true)
        end
        if tunables.TurnSnow and tunables.TurnSnow ~= 1 then
            if tunables.TurnSnow == 2 then
                SET_INT_GLOBAL(Globals.TURN_SNOW_ON_OFF, 1)
            elseif tunables.TurnSnow == 3 then
                SET_INT_GLOBAL(Globals.TURN_SNOW_ON_OFF, 0)
            end
        end
        if tunables.AiHealth and tunables.AiHealth ~= 1.0 then
            SET_FLOAT_GLOBAL(Globals.AI_HEALTH, tunables.AiHealth)
        end



        notify("tuneables_processing")
    end

    ------------------------
    -- Entity
    ------------------------

    local control_ent = Loop_Handler.Entity

    -- 描绘实体连线
    if control_ent.draw_line.toggle then
        if not ENTITY.DOES_ENTITY_EXIST(control_ent.draw_line.entity) then
            util.toast("描绘实体连线: 目标实体已不存在")
            control_ent.draw_line.toggle = false
        else
            local my_pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
            local ent_pos = ENTITY.GET_ENTITY_COORDS(control_ent.draw_line.entity)
            DRAW_LINE(my_pos, ent_pos)
            util.draw_ar_beacon(ent_pos)
        end
    end

    -- 显示实体信息
    if control_ent.show_info.toggle then
        if not ENTITY.DOES_ENTITY_EXIST(control_ent.show_info.entity) then
            util.toast("显示实体信息: 目标实体已不存在")
            control_ent.show_info.toggle = false
        else
            local text = Entity_Info.GetBaseInfoText(control_ent.show_info.entity)
            DrawString(text, 0.65)
        end
    end

    -- 描绘实体边界框
    if control_ent.draw_bounding_box.toggle then
        if not ENTITY.DOES_ENTITY_EXIST(control_ent.draw_bounding_box.entity) then
            util.toast("描绘实体边界框: 目标实体已不存在")
            control_ent.draw_bounding_box.toggle = false
        else
            draw_bounding_box(control_ent.draw_bounding_box.entity)
        end
    end

    -- 锁定传送
    if control_ent.lock_tp.toggle then
        if not ENTITY.DOES_ENTITY_EXIST(control_ent.lock_tp.entity) then
            util.toast("锁定传送: 目标实体已不存在")
            control_ent.lock_tp.toggle = false
        else
            if control_ent.lock_tp.method == 1 then
                tp_entity_to_me(control_ent.lock_tp.entity,
                    control_ent.lock_tp.x,
                    control_ent.lock_tp.y,
                    control_ent.lock_tp.z)
            else
                tp_to_entity(control_ent.lock_tp.entity,
                    control_ent.lock_tp.x,
                    control_ent.lock_tp.y,
                    control_ent.lock_tp.z)
            end
        end
    end

    -- 预览实体
    if control_ent.preview_ent.toggle then
        local target_ent = control_ent.preview_ent.ent
        local clone_ent = control_ent.preview_ent.clone_ent
        if not ENTITY.DOES_ENTITY_EXIST(target_ent) then
            util.toast("预览实体: 目标实体已不存在")
            control_ent.preview_ent.toggle = false

            if ENTITY.DOES_ENTITY_EXIST(control_ent.preview_ent.clone_ent) then
                entities.delete(control_ent.preview_ent.clone_ent)
                control_ent.preview_ent.has_cloned_ent = 0
            end
        elseif control_ent.preview_ent.has_cloned_ent ~= target_ent and not ENTITY.DOES_ENTITY_EXIST(clone_ent) then
            -- 生成（克隆）预览实体
            local l, w, h = calculate_model_size(ENTITY.GET_ENTITY_MODEL(target_ent))
            control_ent.preview_ent.camera_distance = math.max(l, w, h) + 1.0
            local coords = get_offset_from_cam(control_ent.preview_ent.camera_distance)
            local heading = ENTITY.GET_ENTITY_HEADING(players.user_ped()) + 180.0

            if ENTITY.IS_ENTITY_A_PED(target_ent) then
                clone_ent = clone_target_ped(target_ent, coords, heading, false)
            elseif ENTITY.IS_ENTITY_A_VEHICLE(target_ent) then
                clone_ent = clone_target_vehicle(target_ent, coords, heading, false)
            elseif ENTITY.IS_ENTITY_AN_OBJECT(target_ent) then
                clone_ent = clone_target_object(target_ent, coords, false)
            end

            ENTITY.FREEZE_ENTITY_POSITION(clone_ent, true)
            ENTITY.SET_ENTITY_ALPHA(clone_ent, 206, false)
            ENTITY.SET_ENTITY_COMPLETELY_DISABLE_COLLISION(clone_ent, false, true)

            control_ent.preview_ent.clone_ent = clone_ent
            control_ent.preview_ent.has_cloned_ent = target_ent
        elseif control_ent.preview_ent.has_cloned_ent == target_ent and ENTITY.DOES_ENTITY_EXIST(clone_ent) then
            -- 旋转预览实体
            local coords = get_offset_from_cam(control_ent.preview_ent.camera_distance)
            local heading = ENTITY.GET_ENTITY_HEADING(clone_ent) + 0.5
            TP_ENTITY(clone_ent, coords, heading)
        end
    elseif ENTITY.DOES_ENTITY_EXIST(control_ent.preview_ent.clone_ent) then
        entities.delete(control_ent.preview_ent.clone_ent)
        control_ent.preview_ent.has_cloned_ent = 0
    end
end)

function Loop_Handler.draw_centred_point(toggle)
    Loop_Handler.Main.draw_centred_point = toggle
end

function Loop_Handler.Entity.ClearToggles()
    Loop_Handler.Entity.draw_line.toggle = false
    Loop_Handler.Entity.show_info.toggle = false
    Loop_Handler.Entity.draw_bounding_box.toggle = false
    Loop_Handler.Entity.lock_tp.toggle = false
    Loop_Handler.Entity.preview_ent.toggle = false
end

-----------------------------------------------
----------        Stop Script        ----------
-----------------------------------------------

util.on_pre_stop(function()
    util.write_colons_file(SETTING_FILE, Setting)

    notify("本次脚本运行时长: " .. (util.current_time_millis() - SCRIPT_START_TIME) / 1000 .. " s")
end)




---------------------------------------
----------        END        ----------
---------------------------------------

notify("脚本加载时间: " .. util.current_time_millis() - SCRIPT_START_TIME .. " ms")
