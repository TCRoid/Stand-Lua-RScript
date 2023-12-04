local ALL_BLIPS_NUMBER <const> = 866



------------------------------------------
----------    Entity Control    ----------
------------------------------------------

Entity_Control = {
    menu_parent = 0,
    ctrl_entity = 0,
    index = 0,

    entity_list = {},
}

Entity_Control.__index = Entity_Control


--- 返回 menu_name, help_text
--- @param entity Entity
--- @param index integer
--- @return string, string
function Entity_Control.GetMenuInfo(entity, index)
    local modelHash = ENTITY.GET_ENTITY_MODEL(entity)

    local menu_name = ""
    local help_text = ""

    local modelName = util.reverse_joaat(modelHash)
    if modelName ~= "" then
        menu_name = modelName
    else
        menu_name = modelHash
    end

    if ENTITY.IS_ENTITY_A_VEHICLE(entity) then
        local display_name = util.get_label_text(VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(modelHash))
        if display_name ~= "NULL" then
            menu_name = display_name
        end

        if entity == entities.get_user_vehicle_as_handle() then
            if PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
                menu_name = menu_name .. " [当前载具]"
            else
                menu_name = menu_name .. " [上一辆载具]"
            end
        elseif entity == entities.get_user_personal_vehicle_as_handle() then
            menu_name = menu_name .. " [个人载具]"
        elseif not VEHICLE.IS_VEHICLE_SEAT_FREE(entity, -1, false) then
            local driver_player = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(
                VEHICLE.GET_PED_IN_VEHICLE_SEAT(entity, -1, false))
            if players.exists(driver_player) then
                menu_name = menu_name .. " [" .. players.get_name(driver_player) .. "]"
            end
        end

        help_text = "Model: " .. modelName .. "\n"
    end

    local owner = entities.get_owner(entity)
    owner = players.get_name(owner)

    menu_name = index .. ". " .. menu_name
    help_text = help_text .. "Hash: " .. modelHash .. "\nOwner: " .. owner

    if ENTITY.IS_ENTITY_A_MISSION_ENTITY(entity) then
        local entity_script = ENTITY.GET_ENTITY_SCRIPT(entity, 0)
        if entity_script ~= nil then
            help_text = help_text .. "\nScript: " .. string.lower(entity_script)
        end
    end

    return menu_name, help_text
end

--- 创建对应实体的menu操作
--- @param menu_parent commandRef
--- @param entity Entity
--- @param index integer
function Entity_Control.GenerateMenu(menu_parent, entity, index)
    local self = setmetatable({}, Entity_Control)
    self.menu_parent = menu_parent
    self.ctrl_entity = entity
    self.index = index

    self:Base()
    self:Entity()

    if ENTITY.IS_ENTITY_A_PED(entity) then
        self:Ped()
    end

    if ENTITY.IS_ENTITY_A_VEHICLE(entity) then
        self:Vehicle()
    end

    if IS_ENTITY_A_PICKUP(entity) then
        self:Pickup()
    end
end

------------------------
-- Entity
------------------------

function Entity_Control:Base()
    local menu_parent = self.menu_parent
    local entity = self.ctrl_entity
    local index = self.index

    menu.divider(menu_parent, menu.get_menu_name(menu_parent))

    menu.toggle(menu_parent, "描绘实体连线", {}, "", function(toggle)
        if toggle then
            if Loop_Handler.Entity.draw_line.toggle then
                util.toast("正在描绘连线其它实体")
            else
                Loop_Handler.Entity.draw_line.entity = entity
                Loop_Handler.Entity.draw_line.toggle = true
            end
        else
            if Loop_Handler.Entity.draw_line.entity == entity then
                Loop_Handler.Entity.draw_line.toggle = false
            end
        end
    end)
    menu.toggle(menu_parent, "显示实体信息", {}, "", function(toggle)
        if toggle then
            if Loop_Handler.Entity.show_info.toggle then
                util.toast("正在显示其它的实体信息")
            else
                Loop_Handler.Entity.show_info.entity = entity
                Loop_Handler.Entity.show_info.toggle = true
            end
        else
            if Loop_Handler.Entity.show_info.entity == entity then
                Loop_Handler.Entity.show_info.toggle = false
            end
        end
    end)
    menu.toggle(menu_parent, "预览实体", {}, "", function(toggle)
        if toggle then
            if Loop_Handler.Entity.preview_ent.toggle then
                util.toast("正在预览其它的实体")
            else
                Loop_Handler.Entity.preview_ent.ent = entity
                Loop_Handler.Entity.preview_ent.toggle = true
            end
        else
            if Loop_Handler.Entity.preview_ent.ent == entity then
                Loop_Handler.Entity.preview_ent.toggle = false
            end
        end
    end)


    local ent_info = menu.list(menu_parent, "实体信息", {}, "")
    menu.readonly(ent_info, "实体 Index:", entity)
    menu.readonly(ent_info, "实体 Hash:", ENTITY.GET_ENTITY_MODEL(entity))

    menu.toggle(ent_info, "描绘实体边界框", {}, "", function(toggle)
        if toggle then
            if Loop_Handler.Entity.draw_bounding_box.toggle then
                util.toast("正在描绘其它的实体")
            else
                Loop_Handler.Entity.draw_bounding_box.entity = entity
                Loop_Handler.Entity.draw_bounding_box.toggle = true
            end
        else
            if Loop_Handler.Entity.draw_bounding_box.entity == entity then
                Loop_Handler.Entity.draw_bounding_box.toggle = false
            end
        end
    end)
    menu.textslider_stateful(ent_info, "实体信息", {}, "", {
        "复制", "输出到日志"
    }, function(value)
        local text = Entity_Info.GetBaseInfoText(entity)
        util.copy_to_clipboard(text, false)
        if value == 2 then
            util.log(text)
        end
        util.toast("完成")
    end)


    menu.click_slider(menu_parent, "请求控制实体", { "request_ctrl_ent" .. index }, "超时时间\n单位: ms",
        1, 5000, 2000, 500, function(value)
            if request_control(entity, value) then
                util.toast("请求控制成功！")
            else
                util.toast("请求控制失败")
            end
        end)
end

function Entity_Control:Entity()
    local menu_parent = self.menu_parent
    local entity = self.ctrl_entity
    local index = self.index

    local entity_options = menu.list(menu_parent, "Entity 选项", {}, "")

    menu.toggle(entity_options, "无敌", {}, "", function(toggle)
        set_entity_godmode(entity, toggle)
    end)

    menu.toggle(entity_options, "冻结", {}, "", function(toggle)
        ENTITY.FREEZE_ENTITY_POSITION(entity, toggle)
    end,rs_memory.is_entity_froze(entities.handle_to_pointer(entity)))

    local explosion_type = 4
    menu.list_select(entity_options, "选择爆炸类型", {}, "", Misc_T.ExplosionType, 6, function(value)
        explosion_type = value - 2
    end)
    menu.toggle_loop(entity_options, "爆炸", {}, "", function()
        local pos = ENTITY.GET_ENTITY_COORDS(entity)
        add_explosion(pos, explosion_type)

        util.yield(500)
    end)

    menu.toggle(entity_options, "无碰撞", {}, "可以直接穿过实体", function(toggle)
        ENTITY.SET_ENTITY_COLLISION(entity, not toggle, true)
    end, ENTITY.GET_ENTITY_COLLISION_DISABLED(entity))

    menu.toggle(entity_options, "隐形", {}, "将实体隐形", function(toggle)
        ENTITY.SET_ENTITY_VISIBLE(entity, not toggle, 0)
    end, not ENTITY.IS_ENTITY_VISIBLE(entity))

    menu.click_slider(entity_options, "透明度", { "ctrl_ent" .. index .. "_alpha" },
        "Ranging from 0 to 255 but chnages occur after every 20 percent (after every 51).",
        0, 255, ENTITY.GET_ENTITY_ALPHA(entity), 5, function(value)
            ENTITY.SET_ENTITY_ALPHA(entity, value, false)
        end)

    menu.click_slider(entity_options, "最大速度", { "ctrl_ent" .. index .. "_max_speed" }, "",
        0, 1000, 0, 10, function(value)
            ENTITY.SET_ENTITY_MAX_SPEED(entity, value)
        end)

    menu.action(entity_options, "设置为任务实体", {}, "避免实体被自动清理", function()
        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(entity, true, true)
        ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION(entity, true)
        if ENTITY.IS_ENTITY_A_VEHICLE(entity) then
            VEHICLE.SET_VEHICLE_STAYS_FROZEN_WHEN_CLEANED_UP(entity, true)
            VEHICLE.SET_CLEAR_FREEZE_WAITING_ON_COLLISION_ONCE_PLAYER_ENTERS(entity, false)
        end
        util.toast(ENTITY.IS_ENTITY_A_MISSION_ENTITY(entity))
    end)
    menu.action(entity_options, "设置为网络实体", {}, "可将本地实体同步给其他玩家", function()
        util.toast(set_entity_networked(entity))
    end)
    menu.action(entity_options, "删除", {}, "", function()
        entities.delete(entity)
    end)

    if ENTITY.IS_ENTITY_ATTACHED(entity) then
        menu.action(entity_options, "Detach Entity", {}, "", function()
            ENTITY.DETACH_ENTITY(entity, true, true)
        end)
    end



    ----------
    self:EntityHealth()
    self:Teleport()
    self:Movement()
    self:Blip()
end

function Entity_Control:EntityHealth()
    local menu_parent = self.menu_parent
    local entity = self.ctrl_entity
    local index = self.index

    local health_options = menu.list(menu_parent, "实体血量", {}, "")

    local readonly_ent_health = menu.readonly(health_options, "血量")
    menu.on_tick_in_viewport(readonly_ent_health, function()
        local health = ENTITY.GET_ENTITY_HEALTH(entity)
        local max_health = ENTITY.GET_ENTITY_MAX_HEALTH(entity)
        menu.set_value(readonly_ent_health, health .. "/" .. max_health)
    end)

    menu.divider(health_options, "设置血量")

    local ctrl_ent_health = 1000
    menu.slider(health_options, "血量", { "ctrl_ent" .. index .. "_health" }, "",
        0, 100000, 1000, 100, function(value)
            ctrl_ent_health = value
        end)
    menu.action(health_options, "当前血量", {}, "", function()
        SET_ENTITY_HEALTH(entity, ctrl_ent_health)
    end)
    menu.action(health_options, "最大血量", {}, "", function()
        ENTITY.SET_ENTITY_MAX_HEALTH(entity, ctrl_ent_health)
    end)
end

function Entity_Control:Teleport()
    local menu_parent = self.menu_parent
    local entity = self.ctrl_entity
    local index = self.index

    local teleport_options = menu.list(menu_parent, "传送 选项", {}, "")

    local tp = {
        x = 0.0,
        y = 2.0,
        z = 0.0,
    }

    menu.action(teleport_options, "传送到我", {}, "", function()
        tp_entity_to_me(entity, tp.x, tp.y, tp.z)
    end)
    menu.action(teleport_options, "传送到实体", {}, "", function()
        tp_to_entity(entity, tp.x, tp.y, tp.z)
    end)

    menu.divider(teleport_options, "偏移")
    menu.slider_float(teleport_options, "前/后", { "ctrl_ent" .. index .. "_tp_x" }, "",
        -10000, 10000, 200, 50, function(value)
            tp.y = value * 0.01
        end)
    menu.slider_float(teleport_options, "上/下", { "ctrl_ent" .. index .. "_tp_y" }, "",
        -10000, 10000, 0, 50, function(value)
            tp.z = value * 0.01
        end)
    menu.slider_float(teleport_options, "左/右", { "ctrl_ent" .. index .. "_tp_z" }, "",
        -10000, 10000, 0, 50, function(value)
            tp.x = value * 0.01
        end)

    menu.divider(teleport_options, "锁定传送")
    local lock_tp = 1
    menu.list_select(teleport_options, "方式", {}, "", {
        { "实体传送到我" }, { "我传送到实体" }
    }, 1, function(value)
        lock_tp = value
    end)
    menu.toggle(teleport_options, "锁定传送", {}, "如果更改了偏移，需要重新开关此选项",
        function(toggle)
            if toggle then
                if Loop_Handler.Entity.lock_tp.toggle then
                    util.toast("正在锁定传送其它实体")
                else
                    Loop_Handler.Entity.lock_tp.entity = entity
                    Loop_Handler.Entity.lock_tp.method = lock_tp
                    Loop_Handler.Entity.lock_tp.x = tp.x
                    Loop_Handler.Entity.lock_tp.y = tp.y
                    Loop_Handler.Entity.lock_tp.z = tp.z
                    Loop_Handler.Entity.lock_tp.toggle = true
                end
            else
                if Loop_Handler.Entity.lock_tp.entity == entity then
                    Loop_Handler.Entity.lock_tp.toggle = false
                end
            end
        end)
end

function Entity_Control:Movement()
    local menu_parent = self.menu_parent
    local entity = self.ctrl_entity
    local index = self.index

    local movement_options = menu.list(menu_parent, "移动 选项", {}, "")

    menu.click_slider_float(movement_options, "前/后 移动", { "ctrl_ent" .. index .. "_move_y" }, "",
        -10000, 10000, 0, 50, function(value)
            set_entity_move(entity, 0.0, value * 0.01, 0.0)
        end)
    menu.click_slider_float(movement_options, "左/右 移动", { "ctrl_ent" .. index .. "_move_x" }, "",
        -10000, 10000, 0, 50, function(value)
            set_entity_move(entity, value * 0.01, 0.0, 0.0)
        end)
    menu.click_slider_float(movement_options, "上/下 移动", { "ctrl_ent" .. index .. "_move_z" }, "",
        -10000, 10000, 0, 50, function(value)
            set_entity_move(entity, 0.0, 0.0, value * 0.01)
        end)
    menu.click_slider_float(movement_options, "朝向(加减)", { "ctrl_ent" .. index .. "_heading" }, "",
        -36000, 36000, 0, 500,
        function(value)
            ENTITY_HEADING(entity, ENTITY_HEADING(entity) + value * 0.01)
        end)
    menu.click_slider_float(movement_options, "朝向(设置)", { "ctrl_ent" .. index .. "set_heading" }, "",
        -36000, 36000, 0, 500,
        function(value)
            ENTITY_HEADING(entity, value * 0.01)
        end)

    menu.divider(movement_options, "坐标")
    local coord_menu = {}
    menu.action(movement_options, "刷新坐标", {}, "", function()
        local coords = ENTITY.GET_ENTITY_COORDS(entity)
        local pos = {}
        pos.x = round(coords.x, 2) * 100
        pos.y = round(coords.y, 2) * 100
        pos.z = round(coords.z, 2) * 100
        menu.set_value(coord_menu.x, math.ceil(pos.x))
        menu.set_value(coord_menu.y, math.ceil(pos.y))
        menu.set_value(coord_menu.z, math.ceil(pos.z))
    end)

    local coords = ENTITY.GET_ENTITY_COORDS(entity)
    local pos = {}
    pos.x = round(coords.x, 2) * 100
    pos.y = round(coords.y, 2) * 100
    pos.z = round(coords.z, 2) * 100
    coord_menu.x = menu.slider_float(movement_options, "X:", { "ctrl_ent" .. index .. "_x" }, "",
        -1000000, 1000000, math.ceil(pos.x), 50, function(value, prev_value, click_type)
            if click_type ~= CLICK_SCRIPTED then
                local coords = ENTITY.GET_ENTITY_COORDS(entity)
                coords.x = value * 0.01
                TP_ENTITY(entity, coords)
            end
        end)
    coord_menu.y = menu.slider_float(movement_options, "Y:", { "ctrl_ent" .. index .. "_y" }, "",
        -1000000, 1000000, math.ceil(pos.y), 50, function(value, prev_value, click_type)
            if click_type ~= CLICK_SCRIPTED then
                local coords = ENTITY.GET_ENTITY_COORDS(entity)
                coords.y = value * 0.01
                TP_ENTITY(entity, coords)
            end
        end)
    coord_menu.z = menu.slider_float(movement_options, "Z:", { "ctrl_ent" .. index .. "_z" }, "",
        -1000000, 1000000, math.ceil(pos.z), 50, function(value, prev_value, click_type)
            if click_type ~= CLICK_SCRIPTED then
                local coords = ENTITY.GET_ENTITY_COORDS(entity)
                coords.z = value * 0.01
                TP_ENTITY(entity, coords)
            end
        end)
end

function Entity_Control:Blip()
    local menu_parent = self.menu_parent
    local entity = self.ctrl_entity
    local index = self.index

    local blip = HUD.GET_BLIP_FROM_ENTITY(entity)
    if not HUD.DOES_BLIP_EXIST(blip) then
        return
    end

    local blip_options = menu.list(menu_parent, "地图标记点 选项", {}, "")

    menu.slider(blip_options, "Blip Sprite", { "ctrl_ent" .. index .. "_blip_sprite" }, "",
        0, ALL_BLIPS_NUMBER, HUD.GET_BLIP_SPRITE(blip), 1, function(value)
            HUD.SET_BLIP_SPRITE(blip, value)
        end)

    menu.slider(blip_options, "Blip Colour", { "ctrl_ent" .. index .. "_blip_colour" }, "",
        0, 85, HUD.GET_BLIP_COLOUR(blip), 1, function(value)
            HUD.SET_BLIP_COLOUR(blip, value)
        end)

    menu.slider_float(blip_options, "Blip Scale", { "ctrl_ent" .. index .. "_blip_scale" }, "",
        0, 1000, 100, 10, function(value)
            HUD.SET_BLIP_SCALE(blip, value * 0.01)
        end)

    menu.toggle(blip_options, "Flashs", {}, "", function(toggle)
        HUD.SET_BLIP_FLASHES(blip, toggle)
    end, HUD.IS_BLIP_FLASHING(blip))

    menu.toggle(blip_options, "Short Range", {}, "", function(toggle)
        HUD.SET_BLIP_AS_SHORT_RANGE(blip, toggle)
    end, HUD.IS_BLIP_SHORT_RANGE(blip))

    menu.list_select(blip_options, "Blip Display", {}, "", Blip_T.DisplayId,
        HUD.GET_BLIP_INFO_ID_DISPLAY(blip) + 1, function(value)
            HUD.SET_BLIP_DISPLAY(blip, value - 1)
        end)
end

------------------------
-- Ped
------------------------

function Entity_Control:Ped()
    local menu_parent = self.menu_parent
    local ped = self.ctrl_entity
    local index = self.index

    local ped_options = menu.list(menu_parent, "Ped 选项", {}, "")

    menu.toggle(ped_options, "燃烧", {}, "", function(toggle)
        if toggle then
            FIRE.START_ENTITY_FIRE(ped)
        else
            FIRE.STOP_ENTITY_FIRE(ped)
        end
    end)
    menu.action(ped_options, "传送到我的载具", {}, "", function()
        local vehicle = entities.get_user_vehicle_as_handle(false)
        if vehicle ~= INVALID_GUID then
            if VEHICLE.ARE_ANY_VEHICLE_SEATS_FREE(vehicle) then
                PED.SET_PED_INTO_VEHICLE(ped, vehicle, -2)
            end
        end
    end)
    menu.list_action(ped_options, "给予武器", {}, "", RS_T.CommonWeapons.ListItem, function(value)
        local weaponHash = util.joaat(RS_T.CommonWeapons.ModelList[value])
        WEAPON.GIVE_WEAPON_TO_PED(ped, weaponHash, -1, false, true)
        WEAPON.SET_CURRENT_PED_WEAPON(ped, weaponHash, false)
    end)
    menu.action(ped_options, "移除全部武器", {}, "", function()
        WEAPON.REMOVE_ALL_PED_WEAPONS(ped)
    end)
    menu.action(ped_options, "克隆", {}, "", function()
        local model = ENTITY.GET_ENTITY_MODEL(ped)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 0.0, 2.0)
        local ped_type = PED.GET_PED_TYPE(ped)
        local heading = ENTITY.GET_ENTITY_HEADING(ped)
        local clone_ped = create_ped(ped_type, model, coords, heading)
        PED.CLONE_PED_TO_TARGET(ped, clone_ped)
    end)
    menu.action(ped_options, "随机变装", {}, "", function()
        PED.SET_PED_RANDOM_COMPONENT_VARIATION(ped, 0)
        PED.SET_PED_RANDOM_PROPS(ped)
    end)
    menu.action(ped_options, "与玩家友好", {}, "", function()
        local player_rel_hash = PED.GET_PED_RELATIONSHIP_GROUP_HASH(players.user_ped())
        PED.SET_RELATIONSHIP_BETWEEN_GROUPS(0, player_rel_hash, player_rel_hash)
        PED.SET_PED_RELATIONSHIP_GROUP_HASH(ped, player_rel_hash)
    end)
    menu.action(ped_options, "清理外观", {}, "", function()
        clear_ped_body(ped)
    end)
    menu.action(ped_options, "复活", {}, "", function()
        PED.RESURRECT_PED(ped)
    end)
    menu.action(ped_options, "Clear Ped Tasks Immediately", {}, "", function()
        TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
    end)




    ----------
end

------------------------
-- Vehicle
------------------------

function Entity_Control:Vehicle()
    local menu_parent = self.menu_parent
    local vehicle = self.ctrl_entity
    local index = self.index

    local vehicle_options = menu.list(menu_parent, "Vehicle 选项", {}, "")

    menu.textslider_stateful(vehicle_options, "载具传送到我", {}, "会将原座位的NPC传送出去",
        { "驾驶位", "空座位" }, function(value)
            ENTITY_HEADING(vehicle, user_heading())
            tp_entity_to_me(vehicle)
            if value == 1 then
                local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1, false)
                if ped ~= 0 then
                    set_entity_move(ped, 0.0, 0.0, 3.0)
                end
                PED.SET_PED_INTO_VEHICLE(players.user_ped(), vehicle, -1)
            elseif value == 2 then
                PED.SET_PED_INTO_VEHICLE(players.user_ped(), vehicle, -2)
            end
        end)

    menu.textslider_stateful(vehicle_options, "传送到载具内", {}, "会将原座位的NPC传送出去",
        { "空座位", "驾驶位", "副驾驶位" }, function(value)
            if value == 1 then
                if VEHICLE.ARE_ANY_VEHICLE_SEATS_FREE(vehicle) then
                    PED.SET_PED_INTO_VEHICLE(players.user_ped(), vehicle, -2)
                else
                    util.toast("载具已无空座位")
                end
            elseif value == 2 then
                if VEHICLE.IS_VEHICLE_SEAT_FREE(vehicle, -1, false) then
                    PED.SET_PED_INTO_VEHICLE(players.user_ped(), vehicle, -1)
                else
                    local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
                    if ped ~= 0 then
                        set_entity_move(ped, 0.0, 0.0, 3.0)
                        PED.SET_PED_INTO_VEHICLE(players.user_ped(), vehicle, -1)
                    end
                end
            elseif value == 3 then
                if VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(vehicle) > 0 then
                    if VEHICLE.IS_VEHICLE_SEAT_FREE(vehicle, 0, false) then
                        PED.SET_PED_INTO_VEHICLE(players.user_ped(), vehicle, 0)
                    else
                        local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, 0)
                        if ped ~= 0 then
                            set_entity_move(ped, 0.0, 0.0, 3.0)
                            PED.SET_PED_INTO_VEHICLE(players.user_ped(), vehicle, 0)
                        end
                    end
                else
                    util.toast("载具无副驾驶位")
                end
            end
        end)

    menu.action(vehicle_options, "清空载具", {}, "将NPC全部传送出去", function()
        local num, peds = get_vehicle_peds(vehicle)
        if num > 0 then
            for k, ped in pairs(peds) do
                set_entity_move(ped, 0.0, 0.0, 3.0)
            end
        end
    end)

    menu.click_slider(vehicle_options, "向前加速", { "ctrl_veh" .. index .. "_forward_speed" },
        "", 0, 1000, 30, 10, function(value)
            VEHICLE.SET_VEHICLE_FORWARD_SPEED(vehicle, value)
        end)
    menu.click_slider(vehicle_options, "向前加速XY", { "ctrl_veh" .. index .. "_forward_speed_xy" },
        "if the vehicle is in the air this will only set the xy speed.", 0, 1000, 30, 10, function(value)
            VEHICLE.SET_VEHICLE_FORWARD_SPEED_XY(vehicle, value)
        end)

    menu.action(vehicle_options, "修复载具", {}, "", function()
        fix_vehicle(vehicle)
    end)
    menu.action(vehicle_options, "升级载具", {}, "", function()
        upgrade_vehicle(vehicle)
    end)
    menu.action(vehicle_options, "强化载具", {}, "", function()
        strong_vehicle(vehicle)
    end)

    menu.list_action(vehicle_options, "车窗", {}, "", {
        { "删除车窗" },
        { "摇下车窗" },
        { "摇上车窗" },
        { "粉碎车窗" },
        { "修复车窗" },
    }, function(value)
        if value == 1 then
            for i = 0, 7 do
                VEHICLE.REMOVE_VEHICLE_WINDOW(vehicle, i)
            end
        elseif value == 2 then
            for i = 0, 7 do
                VEHICLE.ROLL_DOWN_WINDOW(vehicle, i)
            end
        elseif value == 3 then
            for i = 0, 7 do
                VEHICLE.ROLL_UP_WINDOW(vehicle, i)
            end
        elseif value == 4 then
            for i = 0, 7 do
                VEHICLE.SMASH_VEHICLE_WINDOW(vehicle, i)
            end
        elseif value == 5 then
            for i = 0, 7 do
                VEHICLE.FIX_VEHICLE_WINDOW(vehicle, i)
            end
        end
    end)
    menu.list_action(vehicle_options, "车门", {}, "", {
        { "打开车门" },
        { "关闭车门" },
        { "拆下车门" },
        { "删除车门" },
    }, function(value)
        if value == 1 then
            for i = 0, 3 do
                VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, i, false, false)
            end
        elseif value == 2 then
            VEHICLE.SET_VEHICLE_DOORS_SHUT(vehicle, false)
        elseif value == 3 then
            for i = 0, 3 do
                VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, i, false)
            end
        elseif value == 4 then
            for i = 0, 3 do
                VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, i, true)
            end
        end
    end)

    menu.textslider_stateful(vehicle_options, "引擎", {}, "", { "打开", "关闭" }, function(value)
        if value == 1 then
            VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, false)
        elseif value == 2 then
            VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, false, true, false)
        end
    end)
    menu.textslider_stateful(vehicle_options, "车门锁", {}, "", { "解锁", "上锁" }, function(value)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle, value)
    end)
    menu.textslider_stateful(vehicle_options, "车胎", {}, "", { "爆胎", "修复" }, function(value)
        if value == 1 then
            for i = 0, 7 do
                VEHICLE.SET_VEHICLE_TYRE_BURST(vehicle, i, true, 1000.0)
            end
        elseif value == 2 then
            for i = 0, 7 do
                VEHICLE.SET_VEHICLE_TYRE_FIXED(vehicle, i)
            end
        end
    end)
    menu.action(vehicle_options, "分离车轮", {}, "", function(value)
        for i = 0, 7 do
            entities.detach_wheel(vehicle, i)
        end
    end)

    menu.click_slider(vehicle_options, "Modify Top Speed (%)", { "ctrl_veh" .. index .. "_top_speed" },
        "", -100, 100, 0, 10, function(value)
            VEHICLE.MODIFY_VEHICLE_TOP_SPEED(vehicle, value)
        end)
    menu.click_slider(vehicle_options, "Set Max Speed", { "ctrl_veh" .. index .. "_max_speed" },
        "", 0, 10000, 500, 50, function(value)
            VEHICLE.SET_VEHICLE_MAX_SPEED(vehicle, value)
        end)



    ----------
    self:VehicleHealth()
end

function Entity_Control:VehicleHealth()
    local menu_parent = self.menu_parent
    local vehicle = self.ctrl_entity
    local index = self.index

    local vehicle_health_options = menu.list(menu_parent, "Vehicle Health 选项", {}, "")

    local hash = ENTITY.GET_ENTITY_MODEL(vehicle)

    menu.click_slider(vehicle_health_options, "引擎血量", { "ctrl_veh" .. index .. "_engine_health" },
        "1000.0 = full, 0.0 = go on fire, -1000.0 = burnt out", -1000, 10000,
        1000, 500, function(value)
            VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, value)
        end)
    menu.click_slider(vehicle_health_options, "油箱血量", { "ctrl_veh" .. index .. "_petrol_tank_health" },
        "1000.0 = full, 0.0 = go on fire, -1000.0 = burnt out", -1000, 10000,
        1000, 500, function(value)
            VEHICLE.SET_VEHICLE_PETROL_TANK_HEALTH(vehicle, value)
        end)
    menu.click_slider(vehicle_health_options, "外观血量", { "ctrl_veh" .. index .. "_body_health" },
        "1000.0 = full, 0.0 = damaged", -1000, 10000,
        1000, 500, function(value)
            VEHICLE.SET_VEHICLE_BODY_HEALTH(vehicle, value)
        end)


    if VEHICLE.IS_THIS_MODEL_A_PLANE(hash) then
        menu.click_slider(vehicle_health_options, "飞机引擎血量", { "ctrl_veh" .. index .. "_plane_engine_health" },
            "the same as the above function but it allows the engine health on planes to be set higher than the max health.",
            -1000, 10000, 1000, 500, function(value)
                VEHICLE.SET_PLANE_ENGINE_HEALTH(vehicle, value)
            end)
    end


    if VEHICLE.IS_THIS_MODEL_A_HELI(hash) then
        menu.click_slider(vehicle_health_options, "直升机主旋翼血量",
            { "ctrl_veh" .. index .. "_main_rotor_health" }, "",
            -1000, 10000, 1000, 500, function(value)
                VEHICLE.SET_HELI_MAIN_ROTOR_HEALTH(vehicle, value)
            end)
        menu.click_slider(vehicle_health_options, "直升机尾旋翼血量",
            { "ctrl_veh" .. index .. "_tail_rotor_health" }, "",
            -1000, 10000, 1000, 500, function(value)
                VEHICLE.SET_HELI_TAIL_ROTOR_HEALTH(vehicle, value)
            end)
    end
end

------------------------
-- Pickup
------------------------

function Entity_Control:Pickup()
    local menu_parent = self.menu_parent
    local pickup = self.ctrl_entity
    local index = self.index

    local pickup_options = menu.list(menu_parent, "Pickup 选项", {}, "")

    menu.action(pickup_options, "Attach to Self", {}, "", function()
        OBJECT.ATTACH_PORTABLE_PICKUP_TO_PED(pickup, players.user_ped())
    end)
    menu.action(pickup_options, "Detach from Ped", {}, "", function()
        OBJECT.DETACH_PORTABLE_PICKUP_FROM_PED(pickup)
    end)
    menu.toggle(pickup_options, "Hide When Detached", {}, "", function(toggle)
        OBJECT.HIDE_PORTABLE_PICKUP_WHEN_DETACHED(pickup, toggle)
    end)
    menu.toggle(pickup_options, "Suppress Sound", {}, "", function(toggle)
        OBJECT.SUPPRESS_PICKUP_SOUND_FOR_PICKUP(pickup, toggle and 1 or 0)
    end)
    menu.toggle(pickup_options, "Glow When Uncollectable", {}, "", function(toggle)
        OBJECT.SET_PICKUP_OBJECT_GLOW_WHEN_UNCOLLECTABLE(pickup, toggle)
    end)
    menu.toggle(pickup_options, "Arrow Marker", {}, "", function(toggle)
        OBJECT.SET_PICKUP_OBJECT_ARROW_MARKER(pickup, toggle)
    end)
    menu.toggle(pickup_options, "Arrow Marker When Uncollectable", {}, "", function(toggle)
        OBJECT.ALLOW_PICKUP_ARROW_MARKER_WHEN_UNCOLLECTABLE(pickup, toggle)
    end)
    menu.toggle(pickup_options, "Transparent When Uncollectable", {}, "", function(toggle)
        OBJECT.SET_PICKUP_OBJECT_TRANSPARENT_WHEN_UNCOLLECTABLE(pickup, toggle)
    end)
    menu.toggle(pickup_options, "Set Pickup Presist", {}, "Sets a portable pickup to persist after converting to ambient",
        function(toggle)
            OBJECT.SET_PORTABLE_PICKUP_PERSIST(pickup, toggle)
        end)
    menu.action(pickup_options, "Collectable in Vehicle", {}, "", function()
        OBJECT.SET_PICKUP_OBJECT_COLLECTABLE_IN_VEHICLE(pickup)
    end)
    menu.list_action(pickup_options, "阻止收集", {}, "", {
        "阻止", "阻止(仅本地)", "不阻止", "不阻止(仅本地)"
    }, function(value)
        local bPrevent, bLocalOnly = true, false
        if value == 2 then
            bPrevent, bLocalOnly = true, true
        elseif value == 3 then
            bPrevent, bLocalOnly = false, false
        elseif value == 4 then
            bPrevent, bLocalOnly = false, true
        end

        OBJECT.PREVENT_COLLECTION_OF_PORTABLE_PICKUP(pickup, bPrevent, bLocalOnly)
    end)

    menu.divider(pickup_options, "Model Hash")
    local hash = ENTITY.GET_ENTITY_MODEL(pickup)
    menu.click_slider(pickup_options, "最大携带数量", {}, "", 1, 20, 8, 1, function(value)
        OBJECT.SET_MAX_NUM_PORTABLE_PICKUPS_CARRIED_BY_PLAYER(hash, value)
    end)
    menu.toggle(pickup_options, "允许收集(本地)", {}, "", function(toggle)
        OBJECT.SET_LOCAL_PLAYER_PERMITTED_TO_COLLECT_PICKUPS_WITH_MODEL(hash, toggle)
    end)
end

------------------------
-- All Entities
------------------------

function Entity_Control.Entities(menu_parent, entity_list)
    local self = setmetatable({}, Entity_Control)
    self.menu_parent = menu_parent
    self.entity_list = entity_list

    menu.click_slider(menu_parent, "请求控制实体", { "request_ctrl_ents" }, "超时时间\n单位: ms",
        1, 5000, 2000, 500, function(value)
            local success_num = 0
            local fail_num = 0
            for k, entity in pairs(entity_list) do
                if ENTITY.DOES_ENTITY_EXIST(entity) then
                    if request_control(entity, value) then
                        success_num = success_num + 1
                    else
                        fail_num = fail_num + 1
                    end
                end
            end
            util.toast("完成！\n成功: " .. success_num .. "\n失败: " .. fail_num)
        end)

    menu.toggle(menu_parent, "无敌", {}, "", function(toggle)
        for k, entity in pairs(entity_list) do
            if ENTITY.DOES_ENTITY_EXIST(entity) then
                set_entity_godmode(entity, toggle)
            end
        end
        util.toast("完成！")
    end)
    menu.toggle(menu_parent, "冻结", {}, "", function(toggle)
        for k, entity in pairs(entity_list) do
            if ENTITY.DOES_ENTITY_EXIST(entity) then
                ENTITY.FREEZE_ENTITY_POSITION(entity, toggle)
            end
        end
        util.toast("完成！")
    end)
    menu.toggle(menu_parent, "燃烧", {}, "", function(toggle)
        for k, entity in pairs(entity_list) do
            if ENTITY.DOES_ENTITY_EXIST(entity) then
                if toggle then
                    FIRE.START_ENTITY_FIRE(entity)
                else
                    FIRE.STOP_ENTITY_FIRE(entity)
                end
            end
        end
        util.toast("完成！")
    end)

    local explosion_type = 4
    menu.list_select(menu_parent, "选择爆炸类型", {}, "", Misc_T.ExplosionType, 6, function(value)
        explosion_type = value - 2
    end)
    menu.toggle_loop(menu_parent, "爆炸", {}, "", function()
        for k, entity in pairs(entity_list) do
            if ENTITY.DOES_ENTITY_EXIST(entity) then
                local pos = ENTITY.GET_ENTITY_COORDS(entity)
                add_explosion(pos, explosion_type)
            end
        end
        util.yield(500)
    end)

    menu.click_slider(menu_parent, "设置实体血量", { "ctrl_ents_health" }, "",
        0, 100000, 100, 100, function(value)
            for k, entity in pairs(entity_list) do
                if ENTITY.DOES_ENTITY_EXIST(entity) then
                    SET_ENTITY_HEALTH(entity, value)
                end
            end
            util.toast("完成！")
        end)
    menu.click_slider(menu_parent, "设置最大速度", { "ctrl_ents_max_speed" }, "",
        0, 1000, 0, 10, function(value)
            for k, entity in pairs(entity_list) do
                if ENTITY.DOES_ENTITY_EXIST(entity) then
                    ENTITY.SET_ENTITY_MAX_SPEED(entity, value)
                end
            end
            util.toast("完成！")
        end)
    menu.action(menu_parent, "删除", {}, "", function()
        for k, entity in pairs(entity_list) do
            if ENTITY.DOES_ENTITY_EXIST(entity) then
                entities.delete(entity)
            end
        end
        util.toast("完成！")
    end)


    ----------
    self:EntitiesTeleport()
    self:EntitiesMovement()
end

function Entity_Control:EntitiesTeleport()
    local menu_parent = self.menu_parent
    local entity_list = self.entity_list


    local teleport_options = menu.list(menu_parent, "传送 选项", {}, "")

    local tp = {
        x = 0.0,
        y = 2.0,
        z = 0.0,
    }
    local tp_delay = 1000

    menu.slider_float(teleport_options, "前/后", { "ctrl_ents_tp_y" }, "",
        -5000, 5000, 200, 50, function(value)
            tp.y = value * 0.01
        end)
    menu.slider_float(teleport_options, "上/下", { "ctrl_ents_tp_z" }, "",
        -5000, 5000, 0, 50, function(value)
            tp.z = value * 0.01
        end)
    menu.slider_float(teleport_options, "左/右", { "ctrl_ents_tp_x" }, "",
        -5000, 5000, 0, 50, function(value)
            tp.x = value * 0.01
        end)
    menu.slider(teleport_options, "传送延时", { "ctrl_ents_tp_delay" }, "单位: ms",
        0, 5000, 1000, 100, function(value)
            tp_delay = value
        end)

    menu.action(teleport_options, "传送到我", {}, "", function()
        for _, entity in pairs(entity_list) do
            if ENTITY.DOES_ENTITY_EXIST(entity) then
                tp_entity_to_me(entity, tp.x, tp.y, tp.z)

                util.yield(tp_delay)
            end
        end
        util.toast("完成！")
    end)
end

function Entity_Control:EntitiesMovement()
    local menu_parent = self.menu_parent
    local entity_list = self.entity_list


    local movement_options = menu.list(menu_parent, "移动 选项", {}, "")

    menu.click_slider_float(movement_options, "前/后 移动", { "ctrl_ents_move_y" }, "",
        -10000, 10000, 0, 50, function(value)
            value = value * 0.01
            for _, entity in pairs(entity_list) do
                if ENTITY.DOES_ENTITY_EXIST(entity) then
                    set_entity_move(entity, 0.0, value, 0.0)
                end
            end
            util.toast("完成！")
        end)
    menu.click_slider_float(movement_options, "左/右 移动", { "ctrl_ents_move_x" }, "",
        -10000, 10000, 0, 50, function(value)
            value = value * 0.01
            for _, entity in pairs(entity_list) do
                if ENTITY.DOES_ENTITY_EXIST(entity) then
                    set_entity_move(entity, value, 0.0, 0.0)
                end
            end
            util.toast("完成！")
        end)
    menu.click_slider_float(movement_options, "上/下 移动", { "ctrl_ents_move_z" }, "",
        -10000, 10000, 0, 50, function(value)
            value = value * 0.01
            for _, entity in pairs(entity_list) do
                if ENTITY.DOES_ENTITY_EXIST(entity) then
                    set_entity_move(entity, 0.0, 0.0, value)
                end
            end
            util.toast("完成！")
        end)
    menu.click_slider_float(movement_options, "朝向(加减)", { "ctrl_ents_heading" }, "",
        -36000, 36000, 0, 500, function(value)
            value = value * 0.01
            for _, entity in pairs(entity_list) do
                if ENTITY.DOES_ENTITY_EXIST(entity) then
                    ENTITY_HEADING(entity, ENTITY_HEADING(entity) + value)
                end
            end
            util.toast("完成！")
        end)
    menu.click_slider_float(movement_options, "朝向(设置)", { "ctrl_ents_set_heading" }, "",
        -36000, 36000, 0, 500, function(value)
            value = value * 0.01
            for _, entity in pairs(entity_list) do
                if ENTITY.DOES_ENTITY_EXIST(entity) then
                    ENTITY_HEADING(entity, value)
                end
            end
            util.toast("完成！")
        end)
end
