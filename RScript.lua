----------------------------------------------------------------
-- Author: Rostal
-- Github: https://github.com/TCRoid/Stand-Lua-RScript
----------------------------------------------------------------

local SCRIPT_START_TIME <const> = util.current_time_millis()

local SCRIPT_VERSION <const> = "2025/2/2"

local SUPPORT_GAME_VERSION <const> = "1.70-3411"



------------------------------------------
--            Required Files
------------------------------------------

-- Store
STORE_DIR = filesystem.store_dir() .. "RScript\\"
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
        -- util.toast("脚本已停止运行")
        -- util.stop_script()
        return false
    end
end

Texture.crosshair = directx.create_texture(Texture.file.crosshair)

-- Lib
local SCRIPT_LIB_DIR <const> = filesystem.scripts_dir() .. "lib\\RScript\\"
local REQUIRED_FILES <const> = {
    "tables.lua",
    "alternatives.lua",
    "functions.lua",
    "functions2.lua",
    "utils.lua",
    "entity_libs.lua",
    "variables.lua",
    "tunables.lua",

    "Menu\\Self.lua",
    "Menu\\Weapon.lua",
    "Menu\\Vehicle.lua",
    "Menu\\Entity.lua",
    "Menu\\Mission.lua",
    "Menu\\Online.lua",
    "Menu\\Assistant.lua",
    "Menu\\Bodyguard.lua",
    "Menu\\Clean.lua",
    "Menu\\Other.lua",
    "Menu\\Dev.lua",
    "Menu\\Player.lua",
}
for _, file in pairs(REQUIRED_FILES) do
    local file_path = SCRIPT_LIB_DIR .. file
    if not filesystem.exists(file_path) then
        util.toast("[RScript] 缺少文件: " .. file_path, TOAST_ALL)
        -- util.toast("脚本已停止运行")
        -- util.stop_script()
        return false
    end
end

----------------  Require libs  ----------------

util.require_natives("3407a", "init")

local LIB_MODULES <const> = {
    "RScript.tables",
    "RScript.alternatives",
    "RScript.functions",
    "RScript.functions2",
    "RScript.utils",
    "RScript.entity_libs",
    "RScript.variables",
    "RScript.tunables",
}

for _, lib_module in ipairs(LIB_MODULES) do
    require(lib_module)
end



------------------------------------------
--            Setting
------------------------------------------

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

--- @param key string
--- @return boolean|string
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

--- @param key string
--- @param value boolean|string|number
function setSetting(key, value)
    Setting[key] = value
end

------------------------------------------
--            Initialization
------------------------------------------

DEV_MODE = getSetting("Dev Mode")

-- Backend Loop
LoopHandler = {
    Main = {},
    Entity = {
        show_info = {},
        draw_line = {},
        draw_bounding_box = {},
        preview_ent = {
            ent = 0,
            clone_ent = 0,
            has_cloned_ent = 0,
            camera_distance = 2.0
        },
        lock_tp = {}
    }
}

function LoopHandler.drawCentredPoint(toggle)
    LoopHandler.Main.drawCentredPoint = toggle
end

function LoopHandler.Entity.ClearToggles()
    LoopHandler.Entity.draw_line.toggle = false
    LoopHandler.Entity.show_info.toggle = false
    LoopHandler.Entity.draw_bounding_box.toggle = false
    LoopHandler.Entity.lock_tp.toggle = false
    LoopHandler.Entity.preview_ent.toggle = false
end

-- Transition Finished
TransitionData = {
    Self = {}
}

util.on_transition_finished(function()
    if TransitionData.Self.refillArmour then
        menu.trigger_commands("refillarmour")
    end
end)



-- Check Game Version
local CURRENT_GAME_VERSION <const> = menu.get_version().game
if SUPPORT_GAME_VERSION ~= CURRENT_GAME_VERSION then
    local state_text = string.format(
        "支持的游戏版本: %s\n当前游戏版本: %s\n不支持当前游戏版本, 部分功能可能无法使用!",
        SUPPORT_GAME_VERSION, CURRENT_GAME_VERSION)
    util.toast(state_text)
end



----------------------------------------------------------
--                   MENU START
----------------------------------------------------------

Menu_Root = menu.my_root()

if getSetting("Change Script Entry") then
    Menu_Root = menu.attach_before(menu.ref_by_path("Stand>Settings"),
        menu.list(menu.shadow_root(), "RScript", { "RScript" }, ""))

    menu.action(Menu_Root, "停止脚本", {}, "", function()
        menu.trigger_commands("stopluarscript")
    end)

    menu.divider(menu.my_root(), "RScript")
    menu.action(menu.my_root(), "转到脚本", {}, "", function()
        menu.trigger_commands("RScript")
    end)
end

menu.divider(Menu_Root, "RScript")


----------------  Require Modules  ----------------

local MENU_MODULES <const> = {
    "RScript.Menu.Self",
    "RScript.Menu.Weapon",
    "RScript.Menu.Vehicle",
    "RScript.Menu.Entity",
    "RScript.Menu.Mission",
    "RScript.Menu.Online",
    "RScript.Menu.Assistant",
    "RScript.Menu.Bodyguard",
    "RScript.Menu.Clean",
    "RScript.Menu.Other",
    "RScript.Menu.Dev",
    "RScript.Menu.Player",
}

for _, menu_module in ipairs(MENU_MODULES) do
    require(menu_module)
end




------------------------------------------
--            Setting Options
------------------------------------------

local Setting_Options <const> = menu.list(Menu_Root, "设置", {}, "")

menu.toggle(Setting_Options, "开发者模式", {}, "会多些通知", function(toggle)
    DEV_MODE = toggle
    setSetting("Dev Mode", toggle)
end, getSetting("Dev Mode"))

menu.toggle(Setting_Options, "更改脚本入口位置", {},
    "入口位置: Stand > 设置 上方\n下次启动脚本生效", function(toggle)
        setSetting("Change Script Entry", toggle)
    end, getSetting("Change Script Entry"))





------------------------------------------
--            About Options
------------------------------------------

local About_Options <const> = menu.list(Menu_Root, "关于", {}, "")

menu.readonly(About_Options, "Author", "Rostal")
menu.hyperlink(About_Options, "Github", "https://github.com/TCRoid/Stand-Lua-RScript")
menu.readonly(About_Options, "Version", SCRIPT_VERSION)
menu.readonly(About_Options, "Support Game Version", SUPPORT_GAME_VERSION)

menu.divider(About_Options, "Update")
local About_LatestVersion = menu.readonly(About_Options, "Latest Version")
menu.action(About_Options, "Check Update", {}, "Only check version", function()
    if not async_http.have_access() then
        util.toast("本 Lua 被限制禁止联网，请取消限制")
        return
    end
    menu.set_value(About_LatestVersion, "Checking...")
    async_http.init("https://raw.githubusercontent.com/TCRoid/Stand-Lua-RScript/main/Version.txt", nil, function(data)
        menu.set_value(About_LatestVersion, data)
        if data == SCRIPT_VERSION then
            util.toast("当前为最新版本")
        else
            util.toast("疑似发现新版本?")
        end
    end, function()
        menu.set_value(About_LatestVersion, "")
        util.toast("获取最新版本信息失败!")
    end)
    async_http.dispatch()
end)



------------------------------------------
--            Backend Loop
------------------------------------------

util.create_tick_handler(function()
    ------------------------
    -- Main
    ------------------------

    if LoopHandler.Main.drawCentredPoint then
        draw_centred_point()
    end


    ------------------------
    -- Tunables
    ------------------------

    if IS_SCRIPT_RUNNING("tuneables_processing") then
        TunableService.HandleInt()

        notify("tuneables_processing")
    end


    ------------------------
    -- Entity
    ------------------------

    HandleEntityControlLoop()
end)





------------------------------------------
--            Stop Script
------------------------------------------

util.on_pre_stop(function()
    util.write_colons_file(SETTING_FILE, Setting)
end)





----------------------------------------------------------
--                        END
----------------------------------------------------------

notify("脚本加载时间: " .. util.current_time_millis() - SCRIPT_START_TIME .. " ms")
