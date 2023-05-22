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
-- 信息显示
--------------------
local ent_info = menu.list(Dev_options, "信息显示(菜单显示)", {}, "")

local ent_info_target = 0
local ent_info_list = {
    vehicle = {},
    ped = {},
}

menu.toggle_loop(ent_info, "开启[E键]", {}, "", function()
    draw_point_in_center()

    if PAD.IS_CONTROL_PRESSED(0, 51) then
        local result = get_raycast_result(1500, -1)
        if result.didHit then
            local ent = result.hitEntity
            if IS_AN_ENTITY(ent) then
                ent_info_target = ent

                local text = "Entity Index: " .. tostring(ent) ..
                    "\nHash: " .. tostring(ENTITY.GET_ENTITY_MODEL(ent)) ..
                    "\nType: " .. GET_ENTITY_TYPE(ent)
                THEFEED_POST.TEXT(text)
            end
        end
    end
end)

ent_info_list.hash = menu.readonly(ent_info, "Hash")
ent_info_list.type = menu.readonly(ent_info, "Type")
--------
ent_info_list.ped.divider = menu.divider(ent_info, "Ped")

ent_info_list.ped.combat = menu.readonly(ent_info, "COMBAT")
ent_info_list.ped.group_def_hash = menu.readonly(ent_info, "GROUP_DEFAULT_HASH")
ent_info_list.ped.group_hash = menu.readonly(ent_info, "GROUP_HASH")
ent_info_list.ped.group_rel = menu.readonly(ent_info, "GROUP_RELATIONSHIP")
ent_info_list.ped.group_def_rel = menu.readonly(ent_info, "GROUP_DEFAULT_RELATIONSHIP")


--------
ent_info_list.vehicle.divider = menu.divider(ent_info, "Vehicle")

ent_info_list.vehicle.max_passengers = menu.readonly(ent_info, "MAX_NUMBER_OF_PASSENGERS")
ent_info_list.vehicle.number_seats = menu.readonly(ent_info, "NUMBER_OF_SEATS")


menu.on_tick_in_viewport(ent_info_list.hash, function()
    local ent = ent_info_target
    if ENTITY.DOES_ENTITY_EXIST(ent) then
        local is_ped, is_veh = false, false

        local hash = ENTITY.GET_ENTITY_MODEL(ent)
        menu.set_value(ent_info_list.hash, hash)
        menu.set_value(ent_info_list.type, GET_ENTITY_TYPE(ent))


        if ENTITY.IS_ENTITY_A_PED(ent) then
            is_ped = true

            menu.set_value(ent_info_list.ped.combat, bool_to_string(PED.IS_PED_IN_COMBAT(ent, players.user_ped())))

            local group_def_hash = PED.GET_PED_RELATIONSHIP_GROUP_DEFAULT_HASH(ent)
            menu.set_value(ent_info_list.ped.group_def_hash, group_def_hash)

            local group_hash = PED.GET_PED_RELATIONSHIP_GROUP_HASH(ent)
            menu.set_value(ent_info_list.ped.group_hash, group_hash)

            local player_group = PED.GET_PED_RELATIONSHIP_GROUP_HASH(players.user_ped())
            local group_rel = PED.GET_RELATIONSHIP_BETWEEN_GROUPS(group_hash, player_group)
            menu.set_value(ent_info_list.ped.group_rel, enum_RelationshipType[group_rel])

            local player_def_group = PED.GET_PED_RELATIONSHIP_GROUP_DEFAULT_HASH(players.user_ped())
            local group_def_rel = PED.GET_RELATIONSHIP_BETWEEN_GROUPS(group_def_hash, player_def_group)
            menu.set_value(ent_info_list.ped.group_def_rel, enum_RelationshipType[group_def_rel])
        end
        for k, v in pairs(ent_info_list.ped) do
            menu.set_visible(v, is_ped)
        end


        if ENTITY.IS_ENTITY_A_VEHICLE(ent) then
            is_veh = true
            menu.set_value(ent_info_list.vehicle.max_passengers, VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(ent))
            menu.set_value(ent_info_list.vehicle.number_seats, VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(hash))
        end
        for k, v in pairs(ent_info_list.vehicle) do
            menu.set_visible(v, is_veh)
        end
    end
end)






--------------------
-- 信息显示2
--------------------
local ent_info2 = menu.list(Dev_options, "信息显示(屏幕显示)", {}, "")

local function world_to_screen_coords(x, y, z)
    sc_x = memory.alloc(8)
    sc_y = memory.alloc(8)
    GRAPHICS.GET_SCREEN_COORD_FROM_WORLD_COORD(x, y, z, sc_x, sc_y)
    local ret = {
        x = memory.read_float(sc_x),
        y = memory.read_float(sc_y)
    }
    return ret
end


menu.toggle_loop(ent_info2, "显示NPC关系", {}, "文字显示", function()
    for k, ped in pairs(entities.get_all_peds_as_handles()) do
        if not PED.IS_PED_A_PLAYER(ped) then
            if ENTITY.IS_ENTITY_ON_SCREEN(ped) and ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(ped, players.user_ped(), 17) then
                local coords = ENTITY.GET_ENTITY_COORDS(ped)
                local screen = world_to_screen_coords(coords.x, coords.y, coords.z)

                local rel = PED.GET_RELATIONSHIP_BETWEEN_PEDS(ped, players.user_ped())
                local text = enum_RelationshipType[rel]

                directx.draw_text(screen.x, screen.y, text, ALIGN_TOP_LEFT, 0.5, Colors.purple)
            end
        end
    end
end)







--------------------
-- 实体控制
--------------------
local ent_ctrl = menu.list(Dev_options, "实体控制", {}, "")

local ent_ctrl_target = 0
local ent_ctrl_target_menu

menu.toggle_loop(ent_ctrl, "开启[E键]", {}, "", function()
    draw_point_in_center()

    if PAD.IS_CONTROL_PRESSED(0, 51) then
        local result = get_raycast_result(1500.0, -1)
        if result.didHit then
            local ent = result.hitEntity
            if IS_AN_ENTITY(ent) then
                ent_ctrl_target = ent

                local text = "Entity Index: " .. tostring(ent) ..
                    "\nHash: " .. tostring(ENTITY.GET_ENTITY_MODEL(ent)) ..
                    "\nType: " .. GET_ENTITY_TYPE(ent)
                THEFEED_POST.TEXT(text)

                menu.set_menu_name(ent_ctrl_target_menu, "当前实体: " .. tostring(ent_ctrl_target))
            end
        end
    end
end)

ent_ctrl_target_menu = menu.action(ent_ctrl, "当前实体: 0", {}, "", function()
    if not ENTITY.DOES_ENTITY_EXIST(ent_ctrl_target) then
        util.toast("当前实体已不存在")
    end
end)

menu.divider(ent_ctrl, "操作")


menu.action(ent_ctrl, "get netObject info", {}, "", function()
    local ent = ent_ctrl_target
    if ENTITY.DOES_ENTITY_EXIST(ent) then
        local ptr = entities.handle_to_pointer(ent)
        local netObject = memory.read_long(ptr + 0xD0)
        if netObject ~= 0 then
            local object_type = memory.read_short(netObject + 0x8)
            local object_id = memory.read_short(netObject + 0xA)
            local owner_id = memory.read_byte(netObject + 0x49)
            local control_id = memory.read_byte(netObject + 0x4A)
            local next_owner_id = memory.read_byte(netObject + 0x4B)
            local is_remote = memory.read_byte(netObject + 0x4C)
            local wants_to_delete = memory.read_byte(netObject + 0x4D)
            local should_not_be_delete = memory.read_byte(netObject + 0x4F)

            local text = " object_type: " .. object_type ..
                "\n object_id: " .. object_id ..
                "\n owner_id: " .. owner_id ..
                "\n control_id: " .. control_id ..
                "\n next_owner_id: " .. next_owner_id ..
                "\n is_remote: " .. is_remote ..
                "\n wants_to_delete: " .. wants_to_delete ..
                "\n should_not_be_delete: " .. should_not_be_delete

            util.toast(text)
        end
    end
end)

local Vehicle_Bone_Select = "wheel_lf"
local Vehicle_Bone_ListItem = {
    { "wheel_lf",     {}, "" },
    { "wheel_rf",     {}, "" },
    { "wheel_lr",     {}, "" },
    { "wheel_rr",     {}, "" },
    { "windscreen",   {}, "" },
    { "windscreen_r", {}, "" },
}
menu.list_select(ent_ctrl, "选择骨骼", {}, "", Vehicle_Bone_ListItem, 1, function(index, value)
    Vehicle_Bone_Select = value
end)

menu.toggle_loop(ent_ctrl, "载具骨骼位置", {}, "连线显示", function()
    local ent = ent_ctrl_target
    if ENTITY.DOES_ENTITY_EXIST(ent) and ENTITY.IS_ENTITY_A_VEHICLE(ent) then
        local bone_index = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(ent, Vehicle_Bone_Select)
        if bone_index ~= -1 then
            local pos = ENTITY.GET_WORLD_POSITION_OF_ENTITY_BONE(ent, bone_index)
            local player_pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
            DRAW_LINE(player_pos, pos)
            DrawString("Bone Name: " .. Vehicle_Bone_Select .. "\nBone Index: " .. tostring(bone_index))
        end
    end
end)

menu.toggle_loop(ent_ctrl, "描绘射击连线", {}, "", function()
    local ent = ent_ctrl_target
    if ENTITY.DOES_ENTITY_EXIST(ent) and ENTITY.IS_ENTITY_A_VEHICLE(ent) then
        local bone_index = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(ent, Vehicle_Bone_Select)
        if bone_index ~= -1 then
            local end_pos = ENTITY.GET_WORLD_POSITION_OF_ENTITY_BONE(ent, bone_index)

            local vector = ENTITY.GET_ENTITY_FORWARD_VECTOR(ent)
            local start_pos = {}
            start_pos.x = end_pos.x + vector.x
            start_pos.y = end_pos.y + vector.y
            start_pos.z = end_pos.z + vector.z - 0.5

            DRAW_LINE(start_pos, end_pos)
            DrawString("Bone Name: " .. Vehicle_Bone_Select .. "\nBone Index: " .. tostring(bone_index))
        end
    end
end)
menu.action(ent_ctrl, "射击 4个车轮", {}, "", function()
    local ent = ent_ctrl_target
    if ENTITY.DOES_ENTITY_EXIST(ent) and ENTITY.IS_ENTITY_A_VEHICLE(ent) then
        local weaponHash = util.joaat("WEAPON_APPISTOL")

        for _, bone in pairs({ "wheel_lf", "wheel_rf", "wheel_lr", "wheel_rr" }) do
            local bone_index = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(ent, bone)
            if bone_index ~= -1 then
                local end_pos = ENTITY.GET_WORLD_POSITION_OF_ENTITY_BONE(ent, bone_index)

                local vector = ENTITY.GET_ENTITY_FORWARD_VECTOR(ent)
                local start_pos = {}
                start_pos.x = end_pos.x + vector.x
                start_pos.y = end_pos.y + vector.y
                start_pos.z = end_pos.z + vector.z - 0.5

                MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(
                    start_pos.x, start_pos.y, start_pos.z,
                    end_pos.x, end_pos.y, end_pos.z,
                    1,
                    false,
                    weaponHash,
                    players.user_ped(),
                    false,
                    false,
                    1000)
            end
        end
    end
end)






----------------------
-- Test on Myself
----------------------
local Test_on_Myself = menu.list(Dev_options, "Test on Myself", {}, "")

menu.action(Test_on_Myself, "Get Player Weapon", {}, "", function()
    util.toast(get_ped_weapon(players.user_ped()))
end)
menu.action(Test_on_Myself, "Get Player Vehicle Weapon", {}, "", function()
    util.toast(get_ped_vehicle_weapon(players.user_ped()))
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
