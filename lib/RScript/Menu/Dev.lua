------------------------------------------
------------    Dev Options    -----------
------------------------------------------

menu.textslider_stateful(Dev_Options, "Copy My Coords & Heading", { "copymypos" }, "", {
    "without key", "with key"
}, function(value)
    local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    local heading = ENTITY.GET_ENTITY_HEADING(players.user_ped())

    local text = ""
    if value == 1 then
        text = string.format("%.10f, %.10f, %.10f, %.10f", coords.x, coords.y, coords.z, heading)
    elseif value == 2 then
        text = string.format("x = %.10f, y = %.10f, z = %.10f, heading = %.10f", coords.x, coords.y, coords.z, heading)
    end
    util.copy_to_clipboard(text, false)
    util.toast("Copied!\n" .. text)
end)

menu.action(Dev_Options, "Get Network Time", {}, "", function()
    util.toast("Network Time: " .. NETWORK.GET_NETWORK_TIME() ..
        "\nNetwork Time(String): " .. NETWORK.GET_TIME_AS_STRING(NETWORK.GET_NETWORK_TIME()) ..
        "\nAccurate Network Time: " .. NETWORK.GET_NETWORK_TIME_ACCURATE() ..
        "\nCloud Time: " .. NETWORK.GET_CLOUD_TIME_AS_INT())
end)
menu.action(Dev_Options, "Get Interior ID", { "getinteriorid" }, "", function()
    if INTERIOR.IS_INTERIOR_SCENE() then
        local interior = INTERIOR.GET_INTERIOR_FROM_ENTITY(players.user_ped())
        if INTERIOR.IS_VALID_INTERIOR(interior) then
            local text = "Interior ID: " .. interior

            util.copy_to_clipboard(text, false)
            util.toast("Copied!\n" .. text)
        end
    end
end)

menu.action(Dev_Options, "GET_PICKUP_GENERATION_RANGE_MULTIPLIER", {}, "Default: 1.0", function()
    util.toast(OBJECT.GET_PICKUP_GENERATION_RANGE_MULTIPLIER())
end)
menu.click_slider_float(Dev_Options, "SET_PICKUP_GENERATION_RANGE_MULTIPLIER", { "set_pickup_range" }, "",
    0, 100000, 100000, 100, function(value)
        OBJECT.SET_PICKUP_GENERATION_RANGE_MULTIPLIER(value * 0.01)
    end)


local radius_draw_sphere = 10.0
local dev_draw_sphere = menu.slider_float(Dev_Options, "DRAW_MARKER_SPHERE", { "radius_draw_sphere" }, "",
    0, 100000, 1000, 100, function(value)
        radius_draw_sphere = value * 0.01
    end)
menu.on_tick_in_viewport(dev_draw_sphere, function()
    if menu.is_focused(dev_draw_sphere) then
        local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        DRAW_MARKER_SPHERE(coords, radius_draw_sphere)
    end
end)


menu.toggle_loop(Dev_Options, "GET_IS_TASK_ACTIVE", { "show_active_task" }, "", function()
    for i = 0, 530, 1 do
        if TASK.GET_IS_TASK_ACTIVE(players.user_ped(), i) then
            util.draw_debug_text("Task Active: " .. tostring(i))
        end
    end
end)


local eventGroup = 1
local eventData = memory.alloc(13 * 8)
menu.toggle_loop(Dev_Options, "Event Network Entity Damage", {}, "", function()
    for eventIndex = 0, SCRIPT.GET_NUMBER_OF_EVENTS(eventGroup) - 1 do
        local eventType = SCRIPT.GET_EVENT_AT_INDEX(eventGroup, eventIndex)
        if eventType == 186 then                                                     -- CEventNetworkEntityDamage
            if SCRIPT.GET_EVENT_DATA(eventGroup, eventIndex, eventData, 13) then
                local Victim = memory.read_int(eventData)                            -- entity
                local Attacker = memory.read_int(eventData + 1 * 8)                  -- entity
                local Damage = memory.read_float(eventData + 2 * 8)                  -- float
                local EnduranceDamage = memory.read_float(eventData + 3 * 8)         -- float
                local VictimIncapacitated = memory.read_int(eventData + 4 * 8)       -- bool
                local VictimDestroyed = memory.read_int(eventData + 5 * 8)           -- bool
                local WeaponHash = memory.read_int(eventData + 6 * 8)                -- int
                local VictimSpeed = memory.read_float(eventData + 7 * 8)             -- float
                local AttackerSpeed = memory.read_float(eventData + 8 * 8)           -- float
                local IsResponsibleForCollision = memory.read_int(eventData + 9 * 8) -- bool
                local IsHeadShot = memory.read_int(eventData + 10 * 8)               -- bool
                local IsWithMeleeWeapon = memory.read_int(eventData + 11 * 8)        -- bool
                local HitMaterial = memory.read_int(eventData + 12 * 8)              -- int

                local text = "Victim: " .. Victim ..
                    "\nAttacker: " .. Attacker ..
                    "\nDamage: " .. Damage ..
                    "\nEndurance Damage: " .. EnduranceDamage ..
                    "\nVictim Incapacitated: " .. VictimIncapacitated ..
                    "\nVictim Destroyed: " .. VictimDestroyed ..
                    "\nWeapon Hash: " .. WeaponHash ..
                    "\nVictim Speed: " .. VictimSpeed ..
                    "\nAttacker Speed: " .. AttackerSpeed ..
                    "\nIs Responsible For Collision: " .. IsResponsibleForCollision ..
                    "\nIs Head Shot: " .. IsHeadShot ..
                    "\nIs With Melee Weapon: " .. IsWithMeleeWeapon ..
                    "\nHit Material: " .. HitMaterial ..
                    "\nEvent Index: " .. eventNum ..
                    "\n"


                util.toast(text, TOAST_ALL)
            end
        end
    end
end)


menu.toggle_loop(Dev_Options, "Log Content Info", { "log_content_info" }, "", function()
    local content_id = NETWORK.UGC_GET_CONTENT_ID(0)
    if content_id ~= nil then
        local text = "Content Name: " .. tostring(NETWORK.UGC_GET_CONTENT_NAME(0)) ..
            "\nContent ID: " .. content_id ..
            "\nContent Path: " .. tostring(NETWORK.UGC_GET_CONTENT_PATH(0, 0)) ..
            "\nRoot Content ID: " .. tostring(NETWORK.UGC_GET_ROOT_CONTENT_ID(0)) ..
            "\nUser: " .. tostring(NETWORK.UGC_GET_CONTENT_USER_NAME(0)) ..
            " (ID: " .. tostring(NETWORK.UGC_GET_CONTENT_USER_ID(0)) .. ")"

        util.toast(text, TOAST_ALL)
    end
end)



--------------------
-- 地图标记点
--------------------
local dev_map_blips = menu.list(Dev_Options, "地图标记点", { "dev_map_blips" }, "")

local map_blips = {
    menu_list = {},
}

menu.action(dev_map_blips, "获取地图所有标记点", {}, "相同的获取最近的, 由近到远排序", function()
    rs_menu.delete_menu_list(map_blips.menu_list)
    map_blips.menu_list = {}

    local blip_list = {}
    for i = 0, 866, 1 do
        local blip = HUD.GET_CLOSEST_BLIP_INFO_ID(i)
        if HUD.DOES_BLIP_EXIST(blip) then
            table.insert(blip_list, blip)
        end
    end

    if next(blip_list) ~= nil then
        -- sort
        local player_pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        table.sort(blip_list, function(a, b)
            local distance_a = v3.distance(HUD.GET_BLIP_COORDS(a), player_pos)
            local distance_b = v3.distance(HUD.GET_BLIP_COORDS(b), player_pos)
            return distance_a < distance_b
        end)

        for _, blip in pairs(blip_list) do
            local blip_type = Blip_T.Type[HUD.GET_BLIP_INFO_ID_TYPE(blip)]

            -- menu_list
            local menu_name = HUD.GET_BLIP_SPRITE(blip) .. ". " .. blip_type
            local help_text = "Distance: " .. v3.distance(HUD.GET_BLIP_COORDS(blip), player_pos)
            local menu_list = menu.list(dev_map_blips, menu_name, {}, help_text)
            table.insert(map_blips.menu_list, menu_list)

            -- generate_menu
            menu.toggle(menu_list, "Flashs", {}, "", function(toggle)
                HUD.SET_BLIP_FLASHES(blip, toggle)
            end, HUD.IS_BLIP_FLASHING(blip))
            menu.readonly(menu_list, "Colour", HUD.GET_BLIP_COLOUR(blip))
            menu.readonly(menu_list, "HUD Colour", HUD.GET_BLIP_HUD_COLOUR(blip))
        end
    end
end)
menu.action(dev_map_blips, "清空", {}, "", function()
    rs_menu.delete_menu_list(map_blips.menu_list)
    map_blips.menu_list = {}
end)
menu.divider(dev_map_blips, "列表")






menu.action(Dev_Options, "关闭电脑界面", { "shut_computer" }, "", function()
    local script_list = {
        "appbunkerbusiness", "appsmuggler", "appbusinesshub", "appbikerbusiness",
        "apparcadebusinesshub", "apphackertruck", "appfixersecurity", "appavengeroperations",
        "appcovertops"
    }
    for key, script in pairs(script_list) do
        if IS_SCRIPT_RUNNING(script) then
            SET_INT_GLOBAL(Globals.IsUsingComputerScreen, 0)
            MISC.TERMINATE_ALL_SCRIPTS_WITH_THIS_NAME(script)
        end
    end
end)
