---------------------------------
------------ 开发者选项 -----------
---------------------------------

menu.action(Dev_options, "Copy My Coords & Heading", { "copymypos" }, "", function()
    local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    local heading = ENTITY.GET_ENTITY_HEADING(players.user_ped())
    local text = coords.x .. ", " .. coords.y .. ", " .. coords.z .. "\n" .. heading
    util.copy_to_clipboard(text, false)
    util.toast("Copied!\n" .. text)
end)
menu.action(Dev_options, "GET_NETWORK_TIME", {}, "", function()
    util.toast(NETWORK.GET_NETWORK_TIME())
end)
menu.action(Dev_options, "Clear Player Ped Tasks", { "clstask" }, "", function()
    local ped = players.user_ped()
    TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
    TASK.CLEAR_PED_TASKS(ped)
    TASK.CLEAR_DEFAULT_PRIMARY_TASK(ped)
    TASK.CLEAR_PED_SECONDARY_TASK(ped)
    TASK.TASK_CLEAR_LOOK_AT(ped)
    TASK.TASK_CLEAR_DEFENSIVE_AREA(ped)
    TASK.CLEAR_DRIVEBY_TASK_UNDERNEATH_DRIVING_TASK(ped)
end)
menu.action(Dev_options, "GET_PICKUP_GENERATION_RANGE_MULTIPLIER", {}, "", function()
    util.toast(OBJECT.GET_PICKUP_GENERATION_RANGE_MULTIPLIER())
end)
menu.click_slider_float(Dev_options, "SET_PICKUP_GENERATION_RANGE_MULTIPLIER", { "set_pickup_range" }, "",
    0, 100000, 100000, 100, function(value)
        OBJECT.SET_PICKUP_GENERATION_RANGE_MULTIPLIER(value * 0.01)
    end)

menu.action(Dev_options, "FORCE_PED_AI_AND_ANIMATION_UPDATE", {}, "", function()
    PED.FORCE_PED_AI_AND_ANIMATION_UPDATE(players.user_ped())
end)


local radius_draw_sphere = 10.0
local dev_draw_sphere = menu.slider_float(Dev_options, "DRAW_MARKER_SPHERE", { "radius_draw_sphere" }, "",
    0, 100000, 1000, 100, function(value)
        radius_draw_sphere = value * 0.01
    end)
menu.on_tick_in_viewport(dev_draw_sphere, function()
    if menu.is_focused(dev_draw_sphere) then
        local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        DRAW_MARKER_SPHERE(coords, radius_draw_sphere)
    end
end)



--------------------
-- 其它
--------------------
menu.toggle_loop(Dev_options, "GET_IS_TASK_ACTIVE", { "show_active_task" }, "", function()
    for i = 0, 530, 1 do
        if TASK.GET_IS_TASK_ACTIVE(players.user_ped(), i) then
            util.draw_debug_text("Task Active: " .. tostring(i))
        end
    end
end)


local eventGroup = 1
local eventData = memory.alloc(13 * 8)
menu.toggle_loop(Dev_options, "Event Network Entity Damage", {}, "", function()
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

