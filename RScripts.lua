---------------------------
--- Author: Rostal
---------------------------

util.keep_running()
util.require_natives("natives-1663599433")

-- 脚本版本
local Script_Version <const> = "2023/1/1"

-- 支持的GTA线上版本
local Support_GTAO <const> = 1.64



------------------------------
--------- File & Dir ---------
------------------------------
-- Store
local StoreDir <const> = filesystem.store_dir() .. "RScripts\\"
if not filesystem.exists(StoreDir) then
    filesystem.mkdir(StoreDir)
end

-- Resources
local ResourceDir <const> = filesystem.resources_dir() .. "RScripts\\"
Texture = {
    file = {
        point = ResourceDir .. "point.png",
    },
}
for _, file in pairs(Texture.file) do
    if not filesystem.exists(file) then
        util.toast("缺少文件: " .. file)
        util.toast("脚本已停止运行")
        util.stop_script()
    end
end

Texture.point = directx.create_texture(Texture.file.point)

-- Libs
local ScriptDir <const> = filesystem.scripts_dir()
local Required_Files <const> = {
    "lib\\RScripts\\labels.lua",
    "lib\\RScripts\\variables.lua",
    "lib\\RScripts\\functions.lua",
    "lib\\RScripts\\functions2.lua",
    "lib\\RScripts\\Menu\\Entity_options.lua",
    "lib\\RScripts\\Menu\\Mission_options.lua",
    "lib\\RScripts\\Menu\\Dev_options.lua",
}
for _, file in pairs(Required_Files) do
    local file_path = ScriptDir .. file
    if not filesystem.exists(file_path) then
        util.toast("缺少文件: " .. file_path)
        util.toast("脚本已停止运行")
        util.stop_script()
    end
end

require "RScripts.labels"
require "RScripts.variables"
require "RScripts.functions"
require "RScripts.functions2"



---返回实体信息 list item data
function GetEntityInfo_ListItem(ent)
    if ent ~= nil and ENTITY.DOES_ENTITY_EXIST(ent) then
        local ent_info_item_data = {}
        local t = ""

        local model_hash = ENTITY.GET_ENTITY_MODEL(ent)

        --Model Name
        local model_name = util.reverse_joaat(model_hash)
        if model_name ~= "" then
            t = "Model Name: " .. model_name
        end
        table.insert(ent_info_item_data, newTableValue(1, t))

        --Hash
        t = "Model Hash: " .. model_hash
        table.insert(ent_info_item_data, newTableValue(1, t))

        --Type
        local entity_type = GET_ENTITY_TYPE(ent, 2)
        t = "Entity Type: " .. entity_type
        table.insert(ent_info_item_data, newTableValue(1, t))

        --Mission Entity
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            t = "Mission Entity: True"
        else
            t = "Mission Entity: False"
        end
        table.insert(ent_info_item_data, newTableValue(1, t))

        --Health
        t = "Entity Health: " .. ENTITY.GET_ENTITY_HEALTH(ent) .. "/" .. ENTITY.GET_ENTITY_MAX_HEALTH(ent)
        table.insert(ent_info_item_data, newTableValue(1, t))

        --Dead
        if ENTITY.IS_ENTITY_DEAD(ent) then
            t = "Entity Dead: True"
            ent_info = newTableValue(1, t)
            table.insert(ent_info_item_data, ent_info)
        end

        --Position
        local ent_pos = ENTITY.GET_ENTITY_COORDS(ent)
        t = "Coords: " ..
            string.format("%.4f", ent_pos.x) ..
            ", " .. string.format("%.4f", ent_pos.y) .. ", " .. string.format("%.4f", ent_pos.z)
        table.insert(ent_info_item_data, newTableValue(1, t))

        local my_pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        -- t = "Your Coords: " ..
        --     string.format("%.4f", my_pos.x) ..
        --     ", " .. string.format("%.4f", my_pos.y) .. ", " .. string.format("%.4f", my_pos.z)
        -- ent_info = newTableValue(1, t)
        -- table.insert(ent_info_item_data, ent_info)

        --Heading
        t = "Entity Heading: " .. string.format("%.4f", ENTITY.GET_ENTITY_HEADING(ent))
        table.insert(ent_info_item_data, newTableValue(1, t))

        t = "Your Heading: " .. string.format("%.4f", ENTITY.GET_ENTITY_HEADING(players.user_ped()))
        table.insert(ent_info_item_data, newTableValue(1, t))

        --Distance
        local distance = vect.dist(my_pos, ent_pos)
        t = "Distance: " .. string.format("%.4f", distance)
        table.insert(ent_info_item_data, newTableValue(1, t))

        --Subtract with your position
        local pos_sub = vect.subtract(my_pos, ent_pos)
        t = "Subtract Coords X: " ..
            string.format("%.2f", pos_sub.x) ..
            ", Y: " .. string.format("%.2f", pos_sub.y) .. ", Z: " .. string.format("%.2f", pos_sub.z)
        table.insert(ent_info_item_data, newTableValue(1, t))

        --Speed
        local speed = ENTITY.GET_ENTITY_SPEED(ent)
        t = "Entity Speed: " .. string.format("%.4f", speed)
        table.insert(ent_info_item_data, newTableValue(1, t))

        --Blip
        local blip = HUD.GET_BLIP_FROM_ENTITY(ent)
        if blip > 0 then
            local blip_id = HUD.GET_BLIP_SPRITE(blip)
            t = "Blip Sprite ID: " .. blip_id
            table.insert(ent_info_item_data, newTableValue(1, t))

            local blip_colour = HUD.GET_BLIP_COLOUR(blip)
            t = "Blip Colour: " .. blip_colour
            table.insert(ent_info_item_data, newTableValue(1, t))
        end

        --Networked
        t = "Networked Entity: "
        if NETWORK.NETWORK_GET_ENTITY_IS_LOCAL(ent) then
            t = t .. "Local"
        end
        if NETWORK.NETWORK_GET_ENTITY_IS_NETWORKED(ent) then
            t = t .. " & Networked"
        end
        table.insert(ent_info_item_data, newTableValue(1, t))

        --Owner
        local owner = entities.get_owner(entities.handle_to_pointer(ent))
        owner = players.get_name(owner)
        t = "Entity Owner: " .. owner
        table.insert(ent_info_item_data, newTableValue(1, t))

        ----- Attached Entity -----
        if ENTITY.IS_ENTITY_ATTACHED(ent) then
            ent_info = newTableValue(1, "\n-----  Attached Entity  -----")
            table.insert(ent_info_item_data, ent_info)

            local attached_entity = ENTITY.GET_ENTITY_ATTACHED_TO(ent)
            local attached_hash = ENTITY.GET_ENTITY_MODEL(attached_entity)

            --Model Name
            local attached_model_name = util.reverse_joaat(attached_hash)
            if attached_model_name ~= "" then
                t = "Model Name: " .. attached_model_name
                ent_info = newTableValue(1, t)
                table.insert(ent_info_item_data, ent_info)
            end

            --Hash
            t = "Model Hash: " .. attached_hash
            ent_info = newTableValue(1, t)
            table.insert(ent_info_item_data, ent_info)

            --Type
            t = "Entity Type: " .. GET_ENTITY_TYPE(attached_entity, 2)
            ent_info = newTableValue(1, t)
            table.insert(ent_info_item_data, ent_info)
        end

        ----- Ped -----
        if ENTITY.IS_ENTITY_A_PED(ent) then
            ent_info = newTableValue(1, "\n-----  Ped  -----")
            table.insert(ent_info_item_data, ent_info)

            --Ped Type
            local ped_type = PED.GET_PED_TYPE(ent)
            t = "Ped Type: " .. enum_PedType[ped_type + 1]
            ent_info = newTableValue(1, t)
            table.insert(ent_info_item_data, ent_info)

            --Armour
            t = "Armour: " .. PED.GET_PED_ARMOUR(ent)
            ent_info = newTableValue(1, t)
            table.insert(ent_info_item_data, ent_info)

            --Money
            t = "Money: " .. PED.GET_PED_MONEY(ent)
            ent_info = newTableValue(1, t)
            table.insert(ent_info_item_data, ent_info)

            --Defensive Area
            if PED.IS_PED_DEFENSIVE_AREA_ACTIVE(ent) then
                local def_pos = PED.GET_PED_DEFENSIVE_AREA_POSITION(ent)
                t = "Defensive Area Position: " ..
                    string.format("%.4f", def_pos.x) ..
                    ", " .. string.format("%.4f", def_pos.y) .. ", " .. string.format("%.4f", def_pos.z)
                ent_info = newTableValue(1, t)
                table.insert(ent_info_item_data, ent_info)
            end

            --Visual Field Center Angle
            t = "Visual Field Center Angle: " .. PED.GET_PED_VISUAL_FIELD_CENTER_ANGLE(ent)
            ent_info = newTableValue(1, t)
            table.insert(ent_info_item_data, ent_info)

            --Accuracy
            t = "Accuracy: " .. PED.GET_PED_ACCURACY(ent)
            ent_info = newTableValue(1, t)
            table.insert(ent_info_item_data, ent_info)

            --Combat Movement
            local combat_movement = PED.GET_PED_COMBAT_MOVEMENT(ent)
            t = "Combat Movement: " .. enum_CombatMovement[combat_movement + 1]
            ent_info = newTableValue(1, t)
            table.insert(ent_info_item_data, ent_info)

            --Combat Range
            local combat_range = PED.GET_PED_COMBAT_RANGE(ent)
            t = "Combat Range: " .. enum_CombatRange[combat_range + 1]
            ent_info = newTableValue(1, t)
            table.insert(ent_info_item_data, ent_info)

            --Alertness
            local alertness = PED.GET_PED_ALERTNESS(ent)
            if alertness >= 0 then
                t = "Alertness: " .. enum_Alertness[alertness + 1]
                ent_info = newTableValue(1, t)
                table.insert(ent_info_item_data, ent_info)
            end

            --Dead
            if PED.IS_PED_DEAD_OR_DYING(ent, 1) then
                ent_info = newTableValue(1, "\n-----  Dead Ped  -----")
                table.insert(ent_info_item_data, ent_info)

                local cause_model_hash = PED.GET_PED_CAUSE_OF_DEATH(ent)

                --Cause of Death Model
                local cause_model_name = util.reverse_joaat(cause_model_hash)
                if cause_model_name ~= "" then
                    t = "Cause of Death Model: " .. cause_model_name
                    ent_info = newTableValue(1, t)
                    table.insert(ent_info_item_data, ent_info)
                end

                --Cause of Death Hash
                t = "Cause of Death Hash: " .. cause_model_hash
                ent_info = newTableValue(1, t)
                table.insert(ent_info_item_data, ent_info)

                --Death Time
                t = "Death Time: " .. PED.GET_PED_TIME_OF_DEATH(ent)
                ent_info = newTableValue(1, t)
                table.insert(ent_info_item_data, ent_info)
            end
        end

        ----- Vehicle -----
        if ENTITY.IS_ENTITY_A_VEHICLE(ent) then
            ent_info = newTableValue(1, "\n-----  Vehicle  -----")
            table.insert(ent_info_item_data, ent_info)

            --Display Name
            local display_name = util.get_label_text(VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(model_hash))
            if display_name ~= "NULL" then
                t = "Display Name: " .. display_name
                ent_info = newTableValue(1, t)
                table.insert(ent_info_item_data, ent_info)
            end

            --Vehicle Class
            local vehicle_class = VEHICLE.GET_VEHICLE_CLASS(ent)
            t = "Vehicle Class: " .. util.get_label_text("VEH_CLASS_" .. vehicle_class)
            ent_info = newTableValue(1, t)
            table.insert(ent_info_item_data, ent_info)

            --Engine Health
            t = "Engine Health: " .. VEHICLE.GET_VEHICLE_ENGINE_HEALTH(ent)
            ent_info = newTableValue(1, t)
            table.insert(ent_info_item_data, ent_info)

            --Petrol Tank Health
            t = "Petrol Tank Health: " .. VEHICLE.GET_VEHICLE_PETROL_TANK_HEALTH(ent)
            ent_info = newTableValue(1, t)
            table.insert(ent_info_item_data, ent_info)

            --Body Health
            t = "Body Health: " .. VEHICLE.GET_VEHICLE_BODY_HEALTH(ent)
            ent_info = newTableValue(1, t)
            table.insert(ent_info_item_data, ent_info)

            --- HELI ---
            if VEHICLE.IS_THIS_MODEL_A_HELI(model_hash) then
                --Heli Main Rotor Health
                t = "Heli Main Rotor Health: " .. VEHICLE.GET_HELI_MAIN_ROTOR_HEALTH(ent)
                ent_info = newTableValue(1, t)
                table.insert(ent_info_item_data, ent_info)

                --Heli Tail Rotor Health
                t = "Heli Tail Rotor Health: " .. VEHICLE.GET_HELI_TAIL_ROTOR_HEALTH(ent)
                ent_info = newTableValue(1, t)
                table.insert(ent_info_item_data, ent_info)

                --Heli Boom Rotor Health
                t = "Heli Boom Rotor Health: " .. VEHICLE.GET_HELI_TAIL_BOOM_HEALTH(ent)
                ent_info = newTableValue(1, t)
                table.insert(ent_info_item_data, ent_info)
            end

            --Dirt Level
            local dirt_level = VEHICLE.GET_VEHICLE_DIRT_LEVEL(ent)
            t = "Dirt Level: " .. string.format("%.2f", dirt_level)
            ent_info = newTableValue(1, t)
            table.insert(ent_info_item_data, ent_info)

            --Door Lock Status
            local door_lock_status = VEHICLE.GET_VEHICLE_DOOR_LOCK_STATUS(ent)
            t = "Door Lock Status: " .. enum_VehicleLockStatus[door_lock_status + 1]
            ent_info = newTableValue(1, t)
            table.insert(ent_info_item_data, ent_info)

        end

        return ent_info_item_data
    else
        local t = { "实体不存在" }
        return t
    end
end

main_tick_handler = {
    draw_point_on_screen = false,
}

control_ent_tick_handler = {
    Showing_info = {
        toggle = false,
        ent = nil,
    },
    Drawing_line = {
        toggle = false,
        ent = nil,
    },
    Drawing_bounding_box = {
        toggle = false,
        ent = nil,
    },
    TP_to_ME = {
        toggle = false,
        ent = nil,
        x = nil,
        y = nil,
        z = nil,
    },
}

local function Clear_control_ent_tick_handler()
    control_ent_tick_handler.Showing_info.toggle = false
    control_ent_tick_handler.Drawing_line.toggle = false
    control_ent_tick_handler.Drawing_bounding_box.toggle = false
    control_ent_tick_handler.TP_to_ME.toggle = false
end

util.create_tick_handler(function()
    --在屏幕上显示实体信息
    if control_ent_tick_handler.Showing_info.toggle then
        if not ENTITY.DOES_ENTITY_EXIST(control_ent_tick_handler.Showing_info.ent) then
            util.toast("该实体已经不存在")
            control_ent_tick_handler.Showing_info.toggle = false
        else
            local ent_info_item_data = GetEntityInfo_ListItem(control_ent_tick_handler.Showing_info.ent)
            local text = ""
            for _, info in pairs(ent_info_item_data) do
                if info[1] ~= nil then
                    text = text .. info[1] .. "\n"
                end
            end
            DrawString(text, 0.7)
        end
    end

    --和实体连线
    if control_ent_tick_handler.Drawing_line.toggle then
        if not ENTITY.DOES_ENTITY_EXIST(control_ent_tick_handler.Drawing_line.ent) then
            util.toast("该实体已经不存在")
            control_ent_tick_handler.Drawing_line.toggle = false
        else
            local pos1 = ENTITY.GET_ENTITY_COORDS(players.user_ped())
            local pos2 = ENTITY.GET_ENTITY_COORDS(control_ent_tick_handler.Drawing_line.ent)
            DRAW_LINE(pos1, pos2)
            util.draw_ar_beacon(pos2)
        end
    end

    --描绘实体边界框
    if control_ent_tick_handler.Drawing_bounding_box.toggle then
        if not ENTITY.DOES_ENTITY_EXIST(control_ent_tick_handler.Drawing_bounding_box.ent) then
            util.toast("该实体已经不存在")
            control_ent_tick_handler.Drawing_bounding_box.toggle = false
        else
            draw_bounding_box(control_ent_tick_handler.Drawing_bounding_box.ent)
        end
    end

    --锁定实体传送到我
    if control_ent_tick_handler.TP_to_ME.toggle then
        if not ENTITY.DOES_ENTITY_EXIST(control_ent_tick_handler.TP_to_ME.ent) then
            util.toast("该实体已经不存在")
            control_ent_tick_handler.TP_to_ME.toggle = false
        else
            TP_TO_ME(control_ent_tick_handler.TP_to_ME.ent, control_ent_tick_handler.TP_to_ME.x,
                control_ent_tick_handler.TP_to_ME.y, control_ent_tick_handler.TP_to_ME.z)
        end
    end

    ------
    if main_tick_handler.draw_point_on_screen then
        draw_point_in_center()
    end

end)



------------------------------------------
--------- Entity Control Functions -------
---------------- START -------------------


Entity_Control = {}

------ 创建对应实体的menu操作 ------
function Entity_Control.generate_menu(menu_parent, ent, index)
    Entity_Control.entity(menu_parent, ent, index)

    if ENTITY.IS_ENTITY_A_PED(ent) then
        Entity_Control.ped(menu_parent, ent, index)
    end

    if ENTITY.IS_ENTITY_A_VEHICLE(ent) then
        Entity_Control.vehicle(menu_parent, ent, index)
    end

    if IS_ENTITY_A_PICKUP(ent) then
        Entity_Control.pickup(menu_parent, ent, index)
    end
end

--- Entity ---
function Entity_Control.entity(menu_parent, ent, index)
    menu.divider(menu_parent, menu.get_menu_name(menu_parent))

    menu.toggle(menu_parent, "描绘实体连线", {}, "", function(toggle)
        if toggle then
            if control_ent_tick_handler.Drawing_line.toggle then
                util.toast("正在描绘连线其它的实体")
            else
                control_ent_tick_handler.Drawing_line.ent = ent
                control_ent_tick_handler.Drawing_line.toggle = true
            end
        else
            if control_ent_tick_handler.Drawing_line.toggle and control_ent_tick_handler.Drawing_line.ent ~= ent then
            else
                control_ent_tick_handler.Drawing_line.toggle = false
            end
        end
    end)
    menu.toggle(menu_parent, "描绘实体边界框", {}, "", function(toggle)
        if toggle then
            if control_ent_tick_handler.Drawing_bounding_box.toggle then
                util.toast("正在描绘其它的实体")
            else
                control_ent_tick_handler.Drawing_bounding_box.ent = ent
                control_ent_tick_handler.Drawing_bounding_box.toggle = true
            end
        else
            if control_ent_tick_handler.Drawing_bounding_box.toggle and
                control_ent_tick_handler.Drawing_bounding_box.ent ~= ent then
            else
                control_ent_tick_handler.Drawing_bounding_box.toggle = false
            end
        end
    end)
    menu.toggle(menu_parent, "显示实体信息", {}, "", function(toggle)
        if toggle then
            if control_ent_tick_handler.Showing_info.toggle then
                util.toast("正在显示其它的实体信息")
            else
                control_ent_tick_handler.Showing_info.ent = ent
                control_ent_tick_handler.Showing_info.toggle = true
            end
        else
            if control_ent_tick_handler.Showing_info.toggle and control_ent_tick_handler.Showing_info.ent ~= ent then
            else
                control_ent_tick_handler.Showing_info.toggle = false
            end
        end
    end)
    menu.action(menu_parent, "复制实体信息", {}, "", function()
        local ent_info_item_data = GetEntityInfo_ListItem(ent)
        local text = ""
        for _, info in pairs(ent_info_item_data) do
            if info[1] ~= nil then
                text = text .. info[1] .. "\n"
            end
        end
        util.copy_to_clipboard(text, false)
        util.toast("完成")
    end)
    menu.action(menu_parent, "复制Hash", {}, "", function()
        local text = ENTITY.GET_ENTITY_MODEL(ent)
        util.copy_to_clipboard(text, false)
        util.toast(text)
    end)

    local save_hash = menu.list(menu_parent, "保存到 Hash 列表", {}, "")
    local save_ent_hash_name = util.reverse_joaat(ENTITY.GET_ENTITY_MODEL(ent))
    menu.text_input(save_hash, "名称", { "save_ent_hash" .. index }, "", function(value)
        save_ent_hash_name = value
    end, save_ent_hash_name)
    menu.action(save_hash, "保存", {}, "", function()
        Saved_Hash_List.save(save_ent_hash_name, ent)
    end)

    menu.click_slider(menu_parent, "请求控制实体", { "request_ctrl_ent" .. index }, "发送请求控制的次数",
        1, 100
        , 20, 1, function(value)
        if RequestControl(ent, value) then
            util.toast("请求控制成功！")
        else
            util.toast("请求控制失败")
        end
    end)

    local entity_options = menu.list(menu_parent, "Entity 选项", {}, "")
    menu.toggle(entity_options, "无敌", {}, "", function(toggle)
        ENTITY.SET_ENTITY_INVINCIBLE(ent, toggle)
        ENTITY.SET_ENTITY_PROOFS(ent, toggle, toggle, toggle, toggle, toggle, toggle, toggle, toggle)
    end)
    menu.toggle(entity_options, "冻结", {}, "", function(toggle)
        ENTITY.FREEZE_ENTITY_POSITION(ent, toggle)
    end)
    menu.list_action(entity_options, "爆炸", {}, "选择爆炸类型", ExplosionType_ListItem, function(value)
        local pos = ENTITY.GET_ENTITY_COORDS(ent)
        add_explosion(pos, value - 2)
    end)
    menu.toggle(entity_options, "无碰撞", {}, "可以直接穿过实体", function(toggle)
        ENTITY.SET_ENTITY_COLLISION(ent, not toggle, not toggle)
    end)
    menu.toggle(entity_options, "隐形", {}, "将实体隐形", function(toggle)
        ENTITY.SET_ENTITY_VISIBLE(ent, not toggle, 0)
    end)
    menu.toggle(entity_options, "无重力", {}, "", function(toggle)
        ENTITY.SET_ENTITY_HAS_GRAVITY(ent, not toggle)
    end)
    menu.toggle(entity_options, "添加地图标记", {}, "", function(toggle)
        if toggle then
            local blip = HUD.GET_BLIP_FROM_ENTITY(ent)
            --no blip
            if blip == 0 then
                local color = 27
                --ped combat
                if ENTITY.IS_ENTITY_A_PED(ent) then
                    if PED.IS_PED_IN_COMBAT(ent, players.user_ped()) then
                        color = 1
                    end
                end
                --vehicle combat
                if ENTITY.IS_ENTITY_A_VEHICLE(ent) then
                    local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ent, -1)
                    if ped then
                        if PED.IS_PED_IN_COMBAT(ped, players.user_ped()) then
                            color = 1
                        end
                    end
                end
                --
                blip = HUD.ADD_BLIP_FOR_ENTITY(ent)
                HUD.SET_BLIP_COLOUR(blip, color)
                util.create_tick_handler(function()
                    if not toggle then
                        return false
                    elseif ENTITY.DOES_ENTITY_EXIST(ent) and not ENTITY.IS_ENTITY_DEAD(ent) then
                        local heading = ENTITY.GET_ENTITY_HEADING(ent)
                        HUD.SET_BLIP_ROTATION(blip, round(heading))
                    elseif not HUD.DOES_BLIP_EXIST(blip) then
                        return false
                    else
                        util.remove_blip(blip)
                        return false
                    end
                end)
            end
        else
            local blip = HUD.GET_BLIP_FROM_ENTITY(ent)
            if blip > 0 then
                util.remove_blip(blip)
            end
        end
    end)
    menu.click_slider(entity_options, "设置透明度", { "ctrl_ent" .. index .. "_alpha" },
        "Ranging from 0 to 255 but chnages occur after every 20 percent (after every 51).", 0, 255, 0, 5,
        function(value)
            ENTITY.SET_ENTITY_ALPHA(ent, value, false)
        end)
    menu.click_slider(entity_options, "设置最大速度", { "ctrl_ent" .. index .. "_max_speed" }, "", 0.0, 1000.0, 0.0
        , 10.0,
        function(value)
            ENTITY.SET_ENTITY_MAX_SPEED(ent, value)
        end)
    menu.action(entity_options, "设置为任务实体", {}, "避免实体被自动清理", function()
        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ent, true, true)
        ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION(ent, true)
        if ENTITY.IS_ENTITY_A_VEHICLE(ent) then
            VEHICLE.SET_VEHICLE_STAYS_FROZEN_WHEN_CLEANED_UP(ent, true)
            VEHICLE.SET_CLEAR_FREEZE_WAITING_ON_COLLISION_ONCE_PLAYER_ENTERS(ent, false)
        end
        util.toast(ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent))
    end)
    menu.action(entity_options, "设置为网络实体", {}, "可将本地实体同步给其他玩家", function()
        util.toast(Set_Entity_Networked(ent))
    end)
    menu.action(entity_options, "删除", {}, "", function()
        entities.delete_by_handle(ent)
    end)

    ----- Health -----
    local health_options = menu.list(menu_parent, "实体血量", {}, "")
    local readonly_ent_health = menu.readonly(health_options, "血量")
    menu.on_tick_in_viewport(readonly_ent_health, function()
        local health = ENTITY.GET_ENTITY_HEALTH(ent)
        local max_health = ENTITY.GET_ENTITY_MAX_HEALTH(ent)
        menu.set_value(readonly_ent_health, health .. "/" .. max_health)
    end)
    menu.divider(health_options, "设置血量")
    local ctrl_ent_health = 1000
    menu.slider(health_options, "血量", { "ctrl_ent" .. index .. "_health" }, "", 0, 100000, 1000, 100,
        function(value)
            ctrl_ent_health = value
        end)
    menu.action(health_options, "当前血量", {}, "", function()
        ENTITY.SET_ENTITY_HEALTH(ent, ctrl_ent_health)
    end)
    menu.action(health_options, "最大血量", {}, "", function()
        ENTITY.SET_ENTITY_MAX_HEALTH(ent, ctrl_ent_health)
    end)

    Entity_Control.teleport(menu_parent, ent, index)
    Entity_Control.movement(menu_parent, ent, index)
end

function Entity_Control.teleport(menu_parent, ent, index)
    ----- Teleport -----
    local teleport_options = menu.list(menu_parent, "传送 选项", {}, "")
    local ctrl_ent_tp_x = 0.0
    local ctrl_ent_tp_y = 2.0
    local ctrl_ent_tp_z = 0.0
    menu.slider_float(teleport_options, "前/后", { "ctrl_ent" .. index .. "_tp_x" }, "", -5000, 5000, 200, 50,
        function(value)
            ctrl_ent_tp_y = value * 0.01
        end)
    menu.slider_float(teleport_options, "上/下", { "ctrl_ent" .. index .. "_tp_y" }, "", -5000, 5000, 0, 50,
        function(value)
            ctrl_ent_tp_z = value * 0.01
        end)
    menu.slider_float(teleport_options, "左/右", { "ctrl_ent" .. index .. "_tp_z" }, "", -5000, 5000, 0, 50,
        function(value)
            ctrl_ent_tp_x = value * 0.01
        end)

    menu.action(teleport_options, "传送到实体", {}, "", function()
        TP_TO_ENTITY(ent, ctrl_ent_tp_x, ctrl_ent_tp_y, ctrl_ent_tp_z)
    end)
    menu.action(teleport_options, "传送到我", {}, "", function()
        TP_TO_ME(ent, ctrl_ent_tp_x, ctrl_ent_tp_y, ctrl_ent_tp_z)
    end)
    menu.toggle(teleport_options, "锁定传送到我", {}, "如果更改了位移，需要重新开关此选项",
        function(toggle)
            if toggle then
                if control_ent_tick_handler.TP_to_ME.toggle then
                    util.toast("正在锁定传送其它的实体")
                else
                    control_ent_tick_handler.TP_to_ME.ent = ent
                    control_ent_tick_handler.TP_to_ME.x = ctrl_ent_tp_x
                    control_ent_tick_handler.TP_to_ME.y = ctrl_ent_tp_y
                    control_ent_tick_handler.TP_to_ME.z = ctrl_ent_tp_z
                    control_ent_tick_handler.TP_to_ME.toggle = true
                end
            else
                if control_ent_tick_handler.TP_to_ME.toggle and control_ent_tick_handler.TP_to_ME.ent ~= ent then
                else
                    control_ent_tick_handler.TP_to_ME.toggle = false
                end
            end
        end)
end

function Entity_Control.movement(menu_parent, ent, index)
    ----- Movement -----
    local movement_options = menu.list(menu_parent, "移动 选项", {}, "")
    menu.click_slider_float(movement_options, "前/后 移动", { "ctrl_ent" .. index .. "_move_y" }, "", -10000, 10000,
        0, 50, function(value)
        value = value * 0.01
        SET_ENTITY_MOVE(ent, 0.0, value, 0.0)
    end)
    menu.click_slider_float(movement_options, "左/右 移动", { "ctrl_ent" .. index .. "_move_x" }, "", -10000, 10000,
        0, 50, function(value)
        value = value * 0.01
        SET_ENTITY_MOVE(ent, value, 0.0, 0.0)
    end)
    menu.click_slider_float(movement_options, "上/下 移动", { "ctrl_ent" .. index .. "_move_z" }, "", -10000, 10000,
        0, 50, function(value)
        value = value * 0.01
        SET_ENTITY_MOVE(ent, 0.0, 0.0, value)
    end)
    menu.click_slider_float(movement_options, "朝向", { "ctrl_ent" .. index .. "_head" }, "", -36000, 36000, 0, 100,
        function(value)
            value = value * 0.01
            local head = ENTITY.GET_ENTITY_HEADING(ent)
            ENTITY.SET_ENTITY_HEADING(ent, head + value)
        end)

    menu.divider(movement_options, "坐标")
    menu.action(movement_options, "刷新坐标", {}, "", function()
        local coords = ENTITY.GET_ENTITY_COORDS(ent)
        local pos = {}
        pos.x = string.format("%.2f", coords.x)
        pos.y = string.format("%.2f", coords.y)
        pos.z = string.format("%.2f", coords.z)
        menu.trigger_commands("ctrlent" .. index .. "x " .. pos.x)
        menu.trigger_commands("ctrlent" .. index .. "y " .. pos.y)
        menu.trigger_commands("ctrlent" .. index .. "z " .. pos.z)
    end)

    local coords = ENTITY.GET_ENTITY_COORDS(ent)
    local pos = {}
    pos.x = string.format("%.2f", coords.x) * 100
    pos.y = string.format("%.2f", coords.y) * 100
    pos.z = string.format("%.2f", coords.z) * 100
    menu.slider_float(movement_options, "X:", { "ctrl_ent" .. index .. "_x" }, "", -1000000, 1000000,
        math.ceil(pos.x), 50, function(value)
        local coords = ENTITY.GET_ENTITY_COORDS(ent)
        coords.x = value * 0.01
        SET_ENTITY_COORDS(ent, coords)
    end)
    menu.slider_float(movement_options, "Y:", { "ctrl_ent" .. index .. "_y" }, "", -1000000, 1000000,
        math.ceil(pos.y), 50, function(value)
        local coords = ENTITY.GET_ENTITY_COORDS(ent)
        coords.y = value * 0.01
        SET_ENTITY_COORDS(ent, coords)
    end)
    menu.slider_float(movement_options, "Z:", { "ctrl_ent" .. index .. "_z" }, "", -1000000, 1000000,
        math.ceil(pos.z), 50, function(value)
        local coords = ENTITY.GET_ENTITY_COORDS(ent)
        coords.z = value * 0.01
        SET_ENTITY_COORDS(ent, coords)
    end)
end

--- Ped ---
function Entity_Control.ped(menu_parent, ped, index)
    local ped_options = menu.list(menu_parent, "Ped 选项", {}, "")
    menu.toggle(ped_options, "燃烧", {}, "", function(toggle)
        if toggle then
            FIRE.START_ENTITY_FIRE(ped)
        else
            FIRE.STOP_ENTITY_FIRE(ped)
        end
    end)
    menu.action(ped_options, "传送到我的载具", {}, "", function()
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
        if vehicle then
            if VEHICLE.ARE_ANY_VEHICLE_SEATS_FREE(vehicle) then
                PED.SET_PED_INTO_VEHICLE(ped, vehicle, -2)
            end
        end
    end)
    menu.list_action(ped_options, "给予武器", {}, "", WeaponName_ListItem, function(value)
        local weaponHash = util.joaat(WeaponModel_List[value])
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
        local clone_ped = Create_Network_Ped(ped_type, model, coords.x, coords.y, coords.z, heading)
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
        PED.RESET_PED_VISIBLE_DAMAGE(ped)
        PED.CLEAR_PED_LAST_DAMAGE_BONE(ped)
        PED.CLEAR_PED_BLOOD_DAMAGE(ped)
        PED.CLEAR_PED_WETNESS(ped)
        PED.CLEAR_PED_ENV_DIRT(ped)
    end)

    Entity_Control.ped_combat(menu_parent, ped, index)
    Entity_Control.ped_task(menu_parent, ped, index)
end

function Entity_Control.ped_combat(menu_parent, ped, index)
    local ped_combat_options = menu.list(menu_parent, "NPC作战能力选项", {}, "")
    menu.action(ped_combat_options, "一键无敌强化NPC", {}, "适用于友方NPC", function()
        Increase_Ped_Combat_Ability(ped, true, false)
        Increase_Ped_Combat_Attributes(ped)
        util.toast("Done!")
    end)
    menu.click_slider(ped_combat_options, "射击频率", {}, "", 0, 1000, 100, 10, function(value)
        PED.SET_PED_SHOOT_RATE(ped, value)
    end)
    menu.click_slider(ped_combat_options, "精准度", {}, "", 0, 100, 50, 10, function(value)
        PED.SET_PED_ACCURACY(ped, value)
    end)
    menu.slider_text(ped_combat_options, "战斗能力", {}, "", enum_CombatAbility, function(value)
        PED.SET_PED_COMBAT_ABILITY(ped, value - 1)
    end)
    menu.slider_text(ped_combat_options, "战斗范围", {}, "", enum_CombatRange, function(value)
        PED.SET_PED_COMBAT_RANGE(ped, value - 1)
    end)
    menu.slider_text(ped_combat_options, "战斗走位", {}, "", enum_CombatMovement, function(value)
        PED.SET_PED_COMBAT_MOVEMENT(ped, value - 1)
    end)
    menu.slider_text(ped_combat_options, "警觉度", {}, "", enum_Alertness, function(value)
        PED.SET_PED_ALERTNESS(ped, value - 1)
    end)
    menu.list_action(ped_combat_options, "射击模式", {}, "", Ped_FirePattern_ListItem, function(value)
        PED.SET_PED_FIRING_PATTERN(ped, value)
    end)


    local combat_attributes_options = menu.list(ped_combat_options, "NPC作战属性", {}, "")
    local combat_attributes_menus = {}
    menu.toggle(combat_attributes_options, "全部开/关", {}, "", function(toggle)
        for i, the_menu in pairs(combat_attributes_menus) do
            menu.set_value(the_menu, toggle)
        end
    end)
    for id, data in pairs(Ped_CombatAttributes_List) do
        combat_attributes_menus[id] = menu.toggle(combat_attributes_options, data[1], {}, data[2], function(toggle)
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, id, toggle)
        end)
    end

    local combat_float_options = menu.list(ped_combat_options, "NPC作战数值", {}, "")
    local combat_float_menus = {}
    for id, data in pairs(Ped_CombatFloat_List) do
        local default = string.format("%.2f", PED.GET_COMBAT_FLOAT(ped, id))
        default = tonumber(default) * 100
        combat_float_menus[id] = menu.click_slider_float(combat_float_options, data[1], {}, data[2], 0, 50000, default,
            10, function(value)
            PED.SET_COMBAT_FLOAT(ped, id, value * 0.01)
        end)
    end

end

function Entity_Control.ped_task(menu_parent, ped, index)
    local ped_task_options = menu.list(menu_parent, "Ped Task 选项", {}, "")

    menu.action(ped_task_options, "Clear Ped Tasks Immediately", {}, "", function()
        TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
    end)
    menu.action(ped_task_options, "Clear Ped All Tasks", {}, "", function()
        Clear_Ped_All_Tasks(ped)
    end)

    --- Ped Task Follow ---
    local task_follow = menu.list(ped_task_options, "NPC 跟随", {}, "")
    local ped_follow = {
        x = 0.0,
        y = -1.0,
        z = 0.0,
        movementSpeed = 7.0,
        timeout = -1,
        stoppingRange = 10.0,
        persistFollowing = true
    }
    menu.slider_float(task_follow, "左/右", { "task_ped" .. index .. "follow_x" }, "", -10000, 10000, 0, 100,
        function(value)
            ped_follow.x = value * 0.01
        end)
    menu.slider_float(task_follow, "前/后", { "task_ped" .. index .. "follow_y" }, "", -10000, 10000, -100, 100,
        function(value)
            ped_follow.y = value * 0.01
        end)
    menu.slider_float(task_follow, "上/下", { "task_ped" .. index .. "follow_z" }, "", -10000, 10000, 0, 100,
        function(value)
            ped_follow.z = value * 0.01
        end)
    menu.slider_float(task_follow, "移动速度", { "task_ped" .. index .. "follow_movementSpeed" }, "", 0, 100000, 700
        , 100,
        function(value)
            ped_follow.movementSpeed = value * 0.01
        end)
    menu.slider(task_follow, "超时时间", { "task_ped" .. index .. "follow_timeout" }, "", -1, 10000, -1, 1,
        function(value)
            ped_follow.timeout = value
        end)
    menu.slider_float(task_follow, "停止跟随的最远距离", { "task_ped" .. index .. "follow_stoppingRange" }, "",
        0, 100000, 1000, 100,
        function(value)
            ped_follow.stoppingRange = value * 0.01
        end)
    menu.toggle(task_follow, "持续跟随", {}, "", function(toggle)
        ped_follow.persistFollowing = toggle
    end, true)
    menu.action(task_follow, "设置任务", {}, "", function()
        TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(ped, players.user_ped(), ped_follow.x, ped_follow.y, ped_follow.z,
            ped_follow.movementSpeed,
            ped_follow.timeout, ped_follow.stoppingRange, ped_follow.persistFollowing)
        util.toast("Done!")
    end)

    menu.action(ped_task_options, "躲在掩体处", {}, "", function()
        TASK.TASK_STAY_IN_COVER(ped)
    end)
    menu.toggle(ped_task_options, "朝向面对我", {}, "", function(toggle)
        if toggle then
            TASK.TASK_TURN_PED_TO_FACE_ENTITY(ped, players.user_ped(), -1)
        else
            TASK.TASK_TURN_PED_TO_FACE_ENTITY(ped, players.user_ped(), 0)
        end
    end)
    menu.click_slider_float(ped_task_options, "讨厌附近目标", { "task_ped" .. index .. "hated_around" }, "",
        0, 50000, 0, 10, function(value)
        TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(ped, value * 0.01, 0)
    end)

end

--- Vehicle ---
function Entity_Control.vehicle(menu_parent, vehicle, index)
    local vehicle_options = menu.list(menu_parent, "Vehicle 选项", {}, "")
    menu.action(vehicle_options, "传送到载具内", {}, "", function()
        if VEHICLE.ARE_ANY_VEHICLE_SEATS_FREE(vehicle) then
            PED.SET_PED_INTO_VEHICLE(players.user_ped(), vehicle, -2)
        else
            util.toast("载具已无空座位")
        end
    end)
    menu.action(vehicle_options, "传送到载具驾驶位（强制）", {}, "会踢出原座位的NPC", function()
        if VEHICLE.IS_VEHICLE_SEAT_FREE(vehicle, -1, false) then
            PED.SET_PED_INTO_VEHICLE(players.user_ped(), vehicle, -1)
        else
            local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
            if ped then
                local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(vehicle, 0.0, 0.0, 3.0)
                SET_ENTITY_COORDS(ped, coords)
                PED.SET_PED_INTO_VEHICLE(players.user_ped(), vehicle, -1)
            end
        end
    end)
    menu.action(vehicle_options, "传送到载具副驾驶位（强制）", {}, "会踢出原座位的NPC", function()
        if VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(vehicle) > 1 then
            if VEHICLE.IS_VEHICLE_SEAT_FREE(vehicle, 0, false) then
                PED.SET_PED_INTO_VEHICLE(players.user_ped(), vehicle, 0)
            else
                local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, 0)
                if ped then
                    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(vehicle, 0.0, 0.0, 3.0)
                    SET_ENTITY_COORDS(ped, coords)
                    PED.SET_PED_INTO_VEHICLE(players.user_ped(), vehicle, 0)
                end
            end
        end
    end)
    menu.action(vehicle_options, "清空载具", {}, "全部传送出去", function()
        local num, peds = Get_Peds_In_Vehicle(vehicle)
        if num > 0 then
            for k, ped in pairs(peds) do
                SET_ENTITY_MOVE(ped, 0.0, 0.0, 3.0)
            end
        end
    end)

    menu.click_slider(vehicle_options, "向前加速", { "ctrl_veh" .. index .. "_forward_speed" }, "", 0.0, 1000.0, 30.0
        , 10.0, function(value)
        VEHICLE.SET_VEHICLE_FORWARD_SPEED(vehicle, value)
    end)

    menu.action(vehicle_options, "修复载具", {}, "", function()
        Fix_Vehicle(vehicle)
    end)
    menu.action(vehicle_options, "升级载具", {}, "", function()
        Upgrade_Vehicle(vehicle)
    end)

    local ctrl_veh_window_list_item = {
        { "删除车窗" },
        { "摇下车窗" },
        { "摇上车窗" },
        { "粉碎车窗" },
        { "修复车窗" }
    }
    menu.list_action(vehicle_options, "车窗", {}, "", ctrl_veh_window_list_item, function(value)
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
    menu.slider_text(vehicle_options, "破坏车门", {}, "", { "拆下车门", "删除车门" }, function(value)
        if value == 1 then
            for i = 0, 3 do
                VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, i, false)
            end
        else
            for i = 0, 3 do
                VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, i, true)
            end
        end
    end)
    menu.toggle(vehicle_options, "车门开关", {}, "", function(toggle)
        if toggle then
            for i = 0, 3 do
                VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, i, false, false)
            end
        else
            VEHICLE.SET_VEHICLE_DOORS_SHUT(vehicle, false)
        end
    end)
    menu.toggle(vehicle_options, "车门锁", {}, "", function(toggle)
        if toggle then
            VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle, 2)
        else
            VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle, 1)
        end
    end)
    menu.toggle(vehicle_options, "爆胎", {}, "", function(toggle)
        if toggle then
            for i = 0, 5 do
                VEHICLE.SET_VEHICLE_TYRE_BURST(vehicle, i, true, 1000.0)
            end
        else
            for i = 0, 5 do
                VEHICLE.SET_VEHICLE_TYRE_FIXED(vehicle, i)
            end
        end
    end)
    menu.action(vehicle_options, "随机喷漆", {}, "", function()
        local primary, secundary = get_random_colour(), get_random_colour()
        VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(vehicle, primary.r, primary.g, primary.b)
        VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(vehicle, secundary.r, secundary.g, secundary.b)
    end)

    Entity_Control.vehicle_health(menu_parent, vehicle, index)
    Entity_Control.vehicle_task(menu_parent, vehicle, index)
end

function Entity_Control.vehicle_health(menu_parent, vehicle, index)
    local hash = ENTITY.GET_ENTITY_MODEL(vehicle)
    local vehicle_health_options = menu.list(menu_parent, "Vehicle Health 选项", {}, "")

    menu.click_slider(vehicle_health_options, "引擎血量", { "ctrl_veh" .. index .. "_engine_health" },
        "1000.0 = full, 0.0 = go on fire, -1000.0 = burnt out", -1000, 1000,
        1000, 100, function(value)
        VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, value)
    end)
    menu.click_slider(vehicle_health_options, "油箱血量", { "ctrl_veh" .. index .. "_petrol_tank_health" },
        "1000.0 = full, 0.0 = go on fire, -1000.0 = burnt out", -1000, 1000,
        1000, 100, function(value)
        VEHICLE.SET_VEHICLE_PETROL_TANK_HEALTH(vehicle, value)
    end)
    menu.click_slider(vehicle_health_options, "外观血量", { "ctrl_veh" .. index .. "_body_health" },
        "1000.0 = full, 0.0 = damaged", -1000, 1000,
        1000, 100, function(value)
        VEHICLE.SET_VEHICLE_BODY_HEALTH(vehicle, value)
    end)

    if VEHICLE.IS_THIS_MODEL_A_PLANE(hash) then
        menu.click_slider(vehicle_health_options, "飞机引擎血量", { "ctrl_veh" .. index .. "_plane_engine_health" },
            "the same as the above function but it allows the engine health on planes to be set higher than the max health"
            , -1000, 10000, 1000, 100, function(value)
            VEHICLE.SET_PLANE_ENGINE_HEALTH(vehicle, value)
        end)
    end

    if VEHICLE.IS_THIS_MODEL_A_HELI(hash) then
        menu.click_slider(vehicle_health_options, "直升机主旋翼血量", { "ctrl_veh" .. index .. "_main_rotor_health" },
            "", -1000, 1000, 1000, 100, function(value)
            VEHICLE.SET_HELI_MAIN_ROTOR_HEALTH(vehicle, value)
        end)
        menu.click_slider(vehicle_health_options, "直升机尾旋翼血量", { "ctrl_veh" .. index .. "_tail_rotor_health" },
            "", -1000, 1000, 1000, 100, function(value)
            VEHICLE.SET_HELI_TAIL_ROTOR_HEALTH(vehicle, value)
        end)
    end




    local vehicle_other_attribute = menu.list(vehicle_health_options, "其它属性", {}, "")
    menu.toggle(vehicle_other_attribute, "禁止发动机故障失火", {}, "", function(toggle)
        VEHICLE.SET_VEHICLE_CAN_ENGINE_MISSFIRE(vehicle, not toggle)
    end)
    menu.toggle(vehicle_other_attribute, "禁止漏油", {}, "", function(toggle)
        VEHICLE.SET_VEHICLE_CAN_LEAK_OIL(vehicle, not toggle)
        VEHICLE.SET_VEHICLE_CAN_LEAK_PETROL(vehicle, not toggle)
    end)
    menu.toggle(vehicle_other_attribute, "禁止油箱起火", {}, "", function(toggle)
        VEHICLE.SET_DISABLE_VEHICLE_PETROL_TANK_FIRES(vehicle, toggle)
    end)
    menu.toggle(vehicle_other_attribute, "禁止油箱伤害", {}, "", function(toggle)
        VEHICLE.SET_DISABLE_VEHICLE_PETROL_TANK_DAMAGE(vehicle, toggle)
    end)
    menu.toggle(vehicle_other_attribute, "禁止发动机起火", {}, "", function(toggle)
        VEHICLE.SET_DISABLE_VEHICLE_ENGINE_FIRES(vehicle, toggle)
    end)
    menu.toggle(vehicle_other_attribute, "禁止因碰撞身体损坏而爆炸", {}, "", function(toggle)
        local value = 0
        if toggle then
            value = 1
        end
        VEHICLE.SET_DISABLE_EXPLODE_FROM_BODY_DAMAGE_ON_COLLISION(vehicle, value)
    end)
    menu.toggle(vehicle_other_attribute, "禁止载具部分分离", {}, "", function(toggle)
        VEHICLE.SET_VEHICLE_CAN_BREAK(vehicle, not toggle)
    end)

    if VEHICLE.IS_THIS_MODEL_A_HELI(hash) then
        menu.toggle(vehicle_other_attribute, "禁止直升机尾翼损坏", {}, "", function(toggle)
            VEHICLE.SET_HELI_TAIL_BOOM_CAN_BREAK_OFF(vehicle, not toggle)
        end)
        menu.toggle(vehicle_other_attribute, "提高直升机防炸性", {},
            "(MP Only) Heli might survive from 2 or more explosions when set", function(toggle)
            VEHICLE.SET_HELI_RESIST_TO_EXPLOSION(vehicle, toggle)
        end)
        menu.toggle(vehicle_other_attribute, "禁止直升机身体损坏而爆炸", {}, "", function(toggle)
            VEHICLE.SET_DISABLE_HELI_EXPLODE_FROM_BODY_DAMAGE(vehicle, toggle)
        end)
    end

    if VEHICLE.IS_THIS_MODEL_A_PLANE(hash) then
        menu.toggle(vehicle_other_attribute, "提高飞机防炸性", {},
            "(MP Only) Plane might survive from 2 or more explosions when set", function(toggle)
            VEHICLE.SET_PLANE_RESIST_TO_EXPLOSION(vehicle, toggle)
        end)
    end

end

function Entity_Control.vehicle_task(menu_parent, vehicle, index)
    local ped = GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
    if ped then
        local veh_task_options = menu.list(menu_parent, "Vehicle Task 选项", {}, "")

        menu.action(veh_task_options, "Clear Driver Tasks Immediately", {}, "", function()
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
        end)
        menu.action(veh_task_options, "Clear Driver All Tasks", {}, "", function()
            Clear_Ped_All_Tasks(ped)
        end)

        --- Vehicle Task Follow ---
        local task_follow = menu.list(veh_task_options, "载具 跟随", {}, "")
        local veh_follow = {
            speed = 30.0,
            drivingStyle = 786603,
            minDistance = 5.0
        }
        menu.slider_float(task_follow, "速度", { "task_veh" .. index .. "follow_speed" }, "", 0, 100000, 3000
            , 100,
            function(value)
                veh_follow.speed = value * 0.01
            end)
        menu.list_select(task_follow, "驾驶风格", {}, "", DrivingStyleName_ListItem, 1, function(value)
            veh_follow.drivingStyle = DrivingStyle_List[value]
        end)
        menu.slider_float(task_follow, "最小跟随距离", { "task_veh" .. index .. "follow_minDistance" }, "", 0
            , 100000, 500
            , 100,
            function(value)
                veh_follow.minDistance = value * 0.01
            end)
        menu.action(task_follow, "设置任务", {}, "", function()
            TASK.TASK_VEHICLE_FOLLOW(ped, vehicle, players.user_ped(), veh_follow.speed, veh_follow.drivingStyle,
                veh_follow.minDistance)
            util.toast("Done!")
        end)


        --- Vehicle Task Escort ---
        local task_escort = menu.list(veh_task_options, "载具 护送", {}, "")
        local veh_escort = {
            mode = -1,
            speed = 30.0,
            drivingStyle = 786603,
            minDistance = 5.0,
            minHeightAboveTerrain = 20,
            noRoadsDistance = 5.0
        }
        local task_veh_escort_mode_list = {
            { "后面" }, -- -1
            { "前面" }, -- 0
            { "左边" }, -- 1
            { "右边" }, -- 2
            { "后左边" }, -- 3
            { "后右边" }, -- 4
        }
        menu.list_select(task_escort, "护送模式", {},
            "The mode defines the relative position to the targetVehicle. The ped will try to position its vehicle there."
            , task_veh_escort_mode_list, 1, function(value)
            veh_escort.mode = value - 2
        end)
        menu.slider_float(task_escort, "速度", { "task_veh" .. index .. "escort_speed" }, "", 0, 100000, 3000
            , 100,
            function(value)
                veh_escort.speed = value * 0.01
            end)
        menu.list_select(task_escort, "驾驶风格", {}, "", DrivingStyleName_ListItem, 1, function(value)
            veh_escort.drivingStyle = DrivingStyle_List[value]
        end)
        menu.slider_float(task_escort, "最小跟随距离", { "task_veh" .. index .. "escort_minDistance" },
            "minDistance is ignored if drivingstyle is avoiding traffic, but Rushed is fine.", 0
            , 100000, 500
            , 100,
            function(value)
                veh_escort.minDistance = value * 0.01
            end)
        menu.slider(task_escort, "离地面最小高度", { "task_veh" .. index .. "escort_minHeightAboveTerrain" }, "",
            0, 1000, 20, 1, function(value)
            veh_escort.minHeightAboveTerrain = value
        end)
        menu.slider_float(task_escort, "No Roads Distance", { "task_veh" .. index .. "escort_noRoadsDistance" },
            "if the target is closer than noRoadsDistance, the driver will ignore pathing/roads and follow you directly."
            , 0
            , 100000, 500
            , 100,
            function(value)
                veh_escort.noRoadsDistance = value * 0.01
            end)
        menu.action(task_escort, "设置任务", {},
            "Makes a ped follow the targetVehicle with <minDistance> in between.", function()
            if PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
                local target_vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
                TASK.TASK_VEHICLE_ESCORT(ped, vehicle, target_vehicle, veh_escort.mode, veh_escort.speed,
                    veh_escort.drivingStyle, veh_escort.minDistance, veh_escort.minHeightAboveTerrain,
                    veh_escort.noRoadsDistance)
                util.toast("Done!")
            else
                util.toast("你需要先进入一辆载具后才能设置任务")
            end
        end)


        --- Vehicle Task Mission ---
        local task_mission = menu.list(veh_task_options, "载具 设置任务", {}, "")
        local veh_mission = {
            missionType = 7,
            maxSpeed = 500.0,
            drivingStyle = 786603,
            minDistance = 5.0,
            straightLineDistance = 0.0,
            DriveAgainstTraffic = true,
        }

        menu.list_select(task_mission, "任务类型", {}, "", Vehicle_MissionType_ListItem, 7, function(value)
            veh_mission.missionType = value
        end)
        menu.slider(task_mission, "最大速度", { "task_veh" .. index .. "mission_maxSpeed" }, "", 0, 1000, 500, 10,
            function(value)
                veh_mission.maxSpeed = value
            end)
        menu.list_select(task_mission, "驾驶风格", {}, "", DrivingStyleName_ListItem, 1, function(value)
            veh_mission.drivingStyle = DrivingStyle_List[value]
        end)
        menu.slider_float(task_mission, "最小距离", { "task_veh" .. index .. "mission_minDistance" }, "", 0,
            100000, 500, 100, function(value)
            veh_mission.minDistance = value * 0.01
        end)
        menu.slider_float(task_mission, "直线距离", { "task_veh" .. index .. "mission_straightLineDistance" }, "", 0
            , 100000, 0, 100, function(value)
            veh_mission.straightLineDistance = value * 0.01
        end)
        menu.toggle(task_mission, "DriveAgainstTraffic", {}, "", function(toggle)
            veh_mission.DriveAgainstTraffic = toggle
        end, true)
        menu.action(task_mission, "设置任务", {}, "", function()
            TASK.TASK_VEHICLE_MISSION_PED_TARGET(ped, vehicle, players.user_ped(), veh_mission.missionType,
                veh_mission.maxSpeed, veh_mission.drivingStyle, veh_mission.minDistance, veh_mission.straightLineDistance
                , veh_mission.DriveAgainstTraffic)
            util.toast("Done!")
        end)


    end
end

--- Pickup ---
function Entity_Control.pickup(menu_parent, pickup, index)
    local pickup_options = menu.list(menu_parent, "Pickup 选项", {}, "")
    local modelHash = ENTITY.GET_ENTITY_MODEL(pickup)

    menu.action(pickup_options, "是否被收集", {}, "", function()
        util.toast(OBJECT.HAS_PICKUP_BEEN_COLLECTED(pickup))
    end)
    menu.click_slider(pickup_options, "玩家最大携带量", { "ctrl_pickup" .. index .. "max_carried" }, "", 0, 1000,
        1, 1, function(value)
        OBJECT.SET_MAX_NUM_PORTABLE_PICKUPS_CARRIED_BY_PLAYER(modelHash, value)
    end)
    menu.toggle(pickup_options, "不可收集", {}, "", function(toggle)
        OBJECT.SET_PICKUP_UNCOLLECTABLE(pickup, toggle)
    end)

end

--- All Entities ---
function Entity_Control.entities(menu_parent, entity_list)
    menu.click_slider(menu_parent, "请求控制实体", { "request_ctrl_ents" }, "发送请求控制的次数", 1, 100
        , 20, 1, function(value)
        local success_num = 0
        local fail_num = 0
        for k, ent in pairs(entity_list) do
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                if RequestControl(ent, value) then
                    success_num = success_num + 1
                else
                    fail_num = fail_num + 1
                end
            end
        end
        util.toast("Done!\nSuccess : " .. success_num .. "\nFail : " .. fail_num)
    end)
    menu.toggle(menu_parent, "无敌", {}, "", function(toggle)
        for k, ent in pairs(entity_list) do
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                ENTITY.SET_ENTITY_INVINCIBLE(ent, toggle)
                ENTITY.SET_ENTITY_PROOFS(ent, toggle, toggle, toggle, toggle, toggle, toggle, toggle, toggle)
            end
        end
        util.toast("Done!")
    end)
    menu.toggle(menu_parent, "冻结", {}, "", function(toggle)
        for k, ent in pairs(entity_list) do
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                ENTITY.FREEZE_ENTITY_POSITION(ent, toggle)
            end
        end
        util.toast("Done!")
    end)
    menu.toggle(menu_parent, "燃烧", {}, "", function(toggle)
        for k, ent in pairs(entity_list) do
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                if toggle then
                    FIRE.START_ENTITY_FIRE(ent)
                else
                    FIRE.STOP_ENTITY_FIRE(ent)
                end
            end
        end
        util.toast("Done!")
    end)
    menu.list_action(menu_parent, "爆炸", {}, "选择爆炸类型", ExplosionType_ListItem, function(value)
        for k, ent in pairs(entity_list) do
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                local pos = ENTITY.GET_ENTITY_COORDS(ent)
                add_explosion(pos, value - 2)
            end
        end
        util.toast("Done!")
    end)
    menu.click_slider(menu_parent, "设置实体血量", { "ctrl_ents_health" }, "", 0, 100000
        , 100, 100, function(value)
        for k, ent in pairs(entity_list) do
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                ENTITY.SET_ENTITY_HEALTH(ent, value)
            end
        end
        util.toast("Done!")
    end)
    menu.click_slider(menu_parent, "设置最大速度", { "ctrl_ents_max_speed" }, "", 0.0, 1000.0, 0.0
        , 10.0,
        function(value)
            for k, ent in pairs(entity_list) do
                if ENTITY.DOES_ENTITY_EXIST(ent) then
                    ENTITY.SET_ENTITY_MAX_SPEED(ent, value)
                end
            end
            util.toast("Done!")
        end)
    menu.action(menu_parent, "删除", {}, "", function()
        for k, ent in pairs(entity_list) do
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                entities.delete_by_handle(ent)
            end
        end
        util.toast("Done!")
    end)

    Entity_Control.entities_teleport(menu_parent, entity_list)
    Entity_Control.entities_movement(menu_parent, entity_list)
end

function Entity_Control.entities_teleport(menu_parent, entity_list)
    ----- Teleport -----
    local teleport_options = menu.list(menu_parent, "传送 选项", {}, "")
    local ctrl_ents_tp_x = 0.0
    local ctrl_ents_tp_y = 2.0
    local ctrl_ents_tp_z = 0.0
    local ctrl_ents_tp_delay = 1500
    menu.slider_float(teleport_options, "前/后", { "ctrl_ents_tp_y" }, "", -5000, 5000, 200, 50,
        function(value)
            ctrl_ents_tp_y = value * 0.01
        end)
    menu.slider_float(teleport_options, "上/下", { "ctrl_ents_tp_z" }, "", -5000, 5000, 0, 50,
        function(value)
            ctrl_ents_tp_z = value * 0.01
        end)
    menu.slider_float(teleport_options, "左/右", { "ctrl_ents_tp_x" }, "", -5000, 5000, 0, 50,
        function(value)
            ctrl_ents_tp_x = value * 0.01
        end)
    menu.slider(teleport_options, "传送延时", { "ctrl_ents_tp_delay" }, "单位: ms", 0, 5000, 1500, 100,
        function(value)
            ctrl_ents_tp_delay = value
        end)

    menu.action(teleport_options, "传送到我", {}, "", function()
        for k, ent in pairs(entity_list) do
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                TP_TO_ME(ent, ctrl_ents_tp_x, ctrl_ents_tp_y, ctrl_ents_tp_z)
                util.yield(ctrl_ents_tp_delay)
            end
        end
        util.toast("Done!")
    end)
end

function Entity_Control.entities_movement(menu_parent, entity_list)
    ----- Movement -----
    local movement_options = menu.list(menu_parent, "移动 选项", {}, "")
    menu.click_slider_float(movement_options, "前/后 移动", { "ctrl_ents_move_y" }, "", -10000, 10000,
        0, 50,
        function(value)
            value = value * 0.01
            for k, ent in pairs(entity_list) do
                if ENTITY.DOES_ENTITY_EXIST(ent) then
                    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, 0.0, value, 0.0)
                    ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
                end
            end
            util.toast("Done!")
        end)
    menu.click_slider_float(movement_options, "左/右 移动", { "ctrl_ents_move_x" }, "", -10000, 10000,
        0, 50,
        function(value)
            value = value * 0.01
            for k, ent in pairs(entity_list) do
                if ENTITY.DOES_ENTITY_EXIST(ent) then
                    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, value, 0.0, 0.0)
                    ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
                end
            end
            util.toast("Done!")
        end)
    menu.click_slider_float(movement_options, "上/下 移动", { "ctrl_ents_move_z" }, "", -10000, 10000,
        0, 50,
        function(value)
            value = value * 0.01
            for k, ent in pairs(entity_list) do
                if ENTITY.DOES_ENTITY_EXIST(ent) then
                    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, 0.0, 0.0, value)
                    ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
                end
            end
            util.toast("Done!")
        end)
    menu.click_slider_float(movement_options, "朝向", { "ctrl_ents_head" }, "", -36000, 36000, 0, 100,
        function(value)
            value = value * 0.01
            for k, ent in pairs(entity_list) do
                if ENTITY.DOES_ENTITY_EXIST(ent) then
                    local head = ENTITY.GET_ENTITY_HEADING(ent)
                    ENTITY.SET_ENTITY_HEADING(ent, head + value)
                end
            end
            util.toast("Done!")
        end)
end

----------------- END --------------------
-------- Entity Control Functions --------
------------------------------------------




------------------------------
------- 保存的 Hash 列表 -------
------------------------------

-- 格式 --
-- name
-- hash \n type
Saved_Hash_List = {
    dir = StoreDir .. "Saved Hash List",
    MISSION_ENTITY_custom = nil, --menu.list_action
    Manage_Hash_List_Menu = nil, --menu.list
}

if not filesystem.exists(Saved_Hash_List.dir) then
    filesystem.mkdir(Saved_Hash_List.dir)
end

---@return table
function Saved_Hash_List.get_list()
    local file_name_list = {}
    for i, path in pairs(filesystem.list_files(Saved_Hash_List.dir)) do
        if not filesystem.is_dir(path) then
            local filename, ext = string.match(path, '^.+\\(.+)%.(.+)$')

            table.insert(file_name_list, filename)
        end
    end
    return file_name_list
end

---@return table
function Saved_Hash_List.get_list_item_data()
    local list_item_data = {}
    for i, path in pairs(filesystem.list_files(Saved_Hash_List.dir)) do
        if not filesystem.is_dir(path) then
            local Name, ext = string.match(path, '^.+\\(.+)%.(.+)$')
            local Hash, Type = Saved_Hash_List.read(Name)

            local temp = { "", {}, "" }
            temp[1] = Name
            temp[3] = "Hash: " .. Hash .. "\nType: " .. Type
            table.insert(list_item_data, temp)
        end
    end
    return list_item_data
end

---@return table
function Saved_Hash_List.get_list_item_data2()
    local list_item_data = { { "无" }, { "刷新列表" } }
    for i, path in pairs(filesystem.list_files(Saved_Hash_List.dir)) do
        if not filesystem.is_dir(path) then
            local Name, ext = string.match(path, '^.+\\(.+)%.(.+)$')
            local Hash, Type = Saved_Hash_List.read(Name)

            local temp = { "", {}, "" }
            temp[1] = Name
            temp[3] = "Hash: " .. Hash .. "\nType: " .. Type
            table.insert(list_item_data, temp)
        end
    end
    return list_item_data
end

---return Hash, Type
---@param Name string
---@return string, string
function Saved_Hash_List.read(Name)
    local file = assert(io.open(Saved_Hash_List.dir .. "\\" .. Name .. ".txt", "r"))
    local content = { 0, "No Entity" }
    for line in file:lines() do
        --table.insert(content, line)
        if tonumber(line) ~= nil then
            content[1] = line
        else
            content[2] = line
        end
    end
    file:close()
    return content[1], content[2]
end

---@param Name string
---@param Hash string
---@param Type string
function Saved_Hash_List.write(Name, Hash, Type)
    if Name ~= "" then
        local file = assert(io.open(Saved_Hash_List.dir .. "\\" .. Name .. ".txt", "w+"))
        file:write(Hash .. "\n" .. Type)
        file:close()

        Saved_Hash_List.refresh()
    end
end

---@param Name string
function Saved_Hash_List.rename(old_Name, new_Name)
    if new_Name ~= "" and new_Name ~= old_Name then
        local old_path = Saved_Hash_List.dir .. "\\" .. old_Name .. ".txt"
        local new_path = Saved_Hash_List.dir .. "\\" .. new_Name .. ".txt"
        if not os.rename(old_path, new_path) then
            util.toast("重命名失败")
        else
            Saved_Hash_List.refresh()
        end
    end
end

---@param Name string
---@return boolean
function Saved_Hash_List.delete(Name)
    if Name ~= "" then
        if not os.remove(Saved_Hash_List.dir .. "\\" .. Name .. ".txt") then
            util.toast("删除失败")
        else
            Saved_Hash_List.refresh()
        end
    end
end

Manage_Saved_Hash_Menu_List = {} --每个 Hash 的 menu.list
function Saved_Hash_List.generate_menu_list(menu_parent)
    for k, v in pairs(Manage_Saved_Hash_Menu_List) do
        if v ~= nil and menu.is_ref_valid(v) then
            menu.delete(v)
        end
    end
    Manage_Saved_Hash_Menu_List = {}

    for i, path in pairs(filesystem.list_files(Saved_Hash_List.dir)) do
        if not filesystem.is_dir(path) then
            local Name, ext = string.match(path, '^.+\\(.+)%.(.+)$')
            local Hash, Type = Saved_Hash_List.read(Name)
            local help_text = "Hash: " .. Hash .. "\nType: " .. Type

            local menu_list = menu.list(menu_parent, Name, {}, help_text)
            table.insert(Manage_Saved_Hash_Menu_List, menu_list)

            menu.text_input(menu_list, "名称", { "saved_hash_name" .. Name }, "", function(value)
                Saved_Hash_List.rename(Name, value)
            end, Name)

            menu.text_input(menu_list, "Hash", { "saved_hash" .. Name }, "", function(value)
                if tonumber(value) ~= nil and STREAMING.IS_MODEL_VALID(value) then
                    local tHash, tType = Saved_Hash_List.read(Name)
                    Saved_Hash_List.write(Name, value, tType)
                else
                    util.toast("Wrong Hash !")
                end
            end, Hash)

            menu.list_select(menu_list, "实体类型", {}, "", EntityType_ListItem, GET_ENTITY_TYPE_INDEX(Type),
                function(value)
                    value = EntityType_ListItem[value][1]
                    local tHash, tType = Saved_Hash_List.read(Name)
                    Saved_Hash_List.write(Name, tHash, value)
                end)

            menu.action(menu_list, "删除", {}, "", function()
                Saved_Hash_List.delete(Name)
            end)

        end
    end
end

---@param Name string
---@param ent Entity
function Saved_Hash_List.save(Name, ent)
    if ENTITY.DOES_ENTITY_EXIST(ent) then
        if Name ~= "" then
            local Hash = ENTITY.GET_ENTITY_MODEL(ent)
            local Type = GET_ENTITY_TYPE(ent, 2)
            Saved_Hash_List.write(Name, Hash, Type)
            util.toast("已保存")
        else
            util.toast("请输入名称")
        end
    else
        util.toast("实体已经不存在")
    end
end

function Saved_Hash_List.refresh()
    if menu.is_ref_valid(Saved_Hash_List.MISSION_ENTITY_custom) then
        menu.set_list_action_options(Saved_Hash_List.MISSION_ENTITY_custom, Saved_Hash_List.get_list_item_data())
    end
    if menu.is_ref_valid(Saved_Hash_List.Manage_Hash_List_Menu) then
        Saved_Hash_List.generate_menu_list(Saved_Hash_List.Manage_Hash_List_Menu)
    end
end

----- SCRIPT START -----
if not SCRIPT_SILENT_START then
    local GTAO = tonumber(NETWORK.GET_ONLINE_VERSION())
    if Support_GTAO ~= GTAO then
        util.toast("支持的GTA线上版本: " .. Support_GTAO .. "\n当前GTA线上版本: " .. GTAO)
    end
end



--
menu.divider(menu.my_root(), "RScript")

--------------------------------
------------ 自我选项 ------------
--------------------------------
local Self_options = menu.list(menu.my_root(), "自我选项", {}, "")

-------------------
--- 自定义血量护甲 ---
-------------------
local Self_Custom_options = menu.list(Self_options, "自定义血量护甲", {}, "")

--- 自定义最大生命值 ---
menu.divider(Self_Custom_options, "生命")

local defaultHealth = ENTITY.GET_ENTITY_MAX_HEALTH(PLAYER.PLAYER_PED_ID())
local moddedHealth = defaultHealth
menu.slider(Self_Custom_options, "自定义最大生命值", { "set_max_health" }, "生命值将被修改为指定的数值"
    , 50, 100000, defaultHealth, 50, function(value)
    moddedHealth = value
end)

menu.toggle_loop(Self_Custom_options, "开启", {}, "改变你的最大生命值。一些菜单会将你标记为作弊者。当它被禁用时，它会返回到默认的最大生命值。"
    , function()
        if PED.GET_PED_MAX_HEALTH(PLAYER.PLAYER_PED_ID()) ~= moddedHealth then
            PED.SET_PED_MAX_HEALTH(PLAYER.PLAYER_PED_ID(), moddedHealth)
            ENTITY.SET_ENTITY_HEALTH(PLAYER.PLAYER_PED_ID(), moddedHealth)
        end
    end, function()
    PED.SET_PED_MAX_HEALTH(PLAYER.PLAYER_PED_ID(), defaultHealth)
    ENTITY.SET_ENTITY_HEALTH(PLAYER.PLAYER_PED_ID(), defaultHealth)
end)

menu.click_slider(Self_Custom_options, "设置当前生命值", { "set_health" }, "", 0, 100000, defaultHealth, 50,
    function(value)
        ENTITY.SET_ENTITY_HEALTH(PLAYER.PLAYER_PED_ID(), value)
    end)

--- 自定义最大护甲 ---
menu.divider(Self_Custom_options, "护甲")

local defaultArmour = PLAYER.GET_PLAYER_MAX_ARMOUR(PLAYER.PLAYER_ID())
local moddedArmour = defaultArmour
menu.slider(Self_Custom_options, "自定义最大护甲值", { "set_max_armour" }, "护甲将被修改为指定的数值"
    ,
    50, 100000, defaultArmour, 50, function(value)
    moddedArmour = value
end)

menu.toggle_loop(Self_Custom_options, "开启", {}, "改变你的最大护甲值。一些菜单会将你标记为作弊者。当它被禁用时，它会返回到默认的最大护甲值。"
    , function()
        if PLAYER.GET_PLAYER_MAX_ARMOUR(PLAYER.PLAYER_ID()) ~= moddedArmour then
            PLAYER.SET_PLAYER_MAX_ARMOUR(PLAYER.PLAYER_ID(), moddedArmour)
            PED.SET_PED_ARMOUR(PLAYER.PLAYER_PED_ID(), moddedArmour)
        end
    end, function()
    PLAYER.SET_PLAYER_MAX_ARMOUR(PLAYER.PLAYER_ID(), defaultArmour)
    PED.SET_PED_ARMOUR(PLAYER.PLAYER_PED_ID(), defaultArmour)
end)

menu.click_slider(Self_Custom_options, "设置当前护甲值", { "set_armour" }, "", 0, 100000, defaultArmour, 50,
    function(value)
        PED.SET_PED_ARMOUR(PLAYER.PLAYER_PED_ID(), value)
    end)

-------------------
--- 自定义生命恢复 ---
-------------------
local Self_Custom_recharge_options = menu.list(Self_options, "自定义生命恢复", {}, "")

local custom_recharge = {
    normal_limit = 0.25,
    normal_mult = 1.0,
    cover_limit = 0.25,
    cover_mult = 1.0,
    vehicle_limit = 0.25,
    vehicle_mult = 1.0
}

menu.toggle_loop(Self_Custom_recharge_options, "开启", {}, "", function()
    if PED.IS_PED_IN_COVER(players.user_ped(), false) then
        PLAYER.SET_PLAYER_HEALTH_RECHARGE_MAX_PERCENT(players.user(), custom_recharge.cover_limit)
        PLAYER.SET_PLAYER_HEALTH_RECHARGE_MULTIPLIER(players.user(), custom_recharge.cover_mult)
    elseif PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
        PLAYER.SET_PLAYER_HEALTH_RECHARGE_MAX_PERCENT(players.user(), custom_recharge.vehicle_limit)
        PLAYER.SET_PLAYER_HEALTH_RECHARGE_MULTIPLIER(players.user(), custom_recharge.vehicle_mult)
    else
        PLAYER.SET_PLAYER_HEALTH_RECHARGE_MAX_PERCENT(players.user(), custom_recharge.normal_limit)
        PLAYER.SET_PLAYER_HEALTH_RECHARGE_MULTIPLIER(players.user(), custom_recharge.normal_mult)
    end
end, function()
    PLAYER.SET_PLAYER_HEALTH_RECHARGE_MAX_PERCENT(players.user(), 0.25)
    PLAYER.SET_PLAYER_HEALTH_RECHARGE_MULTIPLIER(players.user(), 1.0)
end)

menu.divider(Self_Custom_recharge_options, "站立不动状态")
menu.slider(Self_Custom_recharge_options, "恢复程度", { "normal_recharge_limit" }, "恢复到血量的多少，单位%\n默认：25%"
    , 1, 100, 25, 10, function(value)
    custom_recharge.normal_limit = value * 0.01
end)
menu.slider(Self_Custom_recharge_options, "恢复速度", { "normal_recharge_mult" }, "恢复速度\n默认：1.0", 1.0,
    100.0, 1.0, 1.0, function(value)
    custom_recharge.normal_mult = value
end)

menu.divider(Self_Custom_recharge_options, "掩体内")
menu.slider(Self_Custom_recharge_options, "恢复程度", { "cover_recharge_limit" }, "恢复到血量的多少，单位%\n默认：25%"
    , 1, 100, 25, 10, function(value)
    custom_recharge.cover_limit = value * 0.01
end)
menu.slider(Self_Custom_recharge_options, "恢复速度", { "cover_recharge_mult" }, "恢复速度\n默认：1.0", 1.0,
    100.0, 1.0, 1.0, function(value)
    custom_recharge.cover_mult = value
end)

menu.divider(Self_Custom_recharge_options, "载具内")
menu.slider(Self_Custom_recharge_options, "恢复程度", { "vehicle_recharge_limit" }, "恢复到血量的多少，单位%\n默认：25%"
    , 1, 100, 25, 10, function(value)
    custom_recharge.vehicle_limit = value * 0.01
end)
menu.slider(Self_Custom_recharge_options, "恢复速度", { "vehicle_recharge_mult" }, "恢复速度\n默认：1.0", 1.0
    ,
    100.0, 1.0, 1.0, function(value)
    custom_recharge.vehicle_mult = value
end)

-------------------
--- 自定义血量下限 ---
-------------------
local Self_Custom_low_limit = menu.list(Self_options, "自定义血量下限", {}, "")

local low_health_limit = 0.5
menu.slider(Self_Custom_low_limit, "设置血量下限(%)", { "low_health_limit" }, "可以到达的最低血量，单位%"
    , 10, 100, 50, 10
    , function(value)
    low_health_limit = value * 0.01
end)
menu.toggle_loop(Self_Custom_low_limit, "锁定血量", {}, "当你的血量到达你设置的血量下限值后，锁定你的血量，防不住爆炸"
    , function()
    if not PLAYER.IS_PLAYER_DEAD(players.user()) then
        local maxHealth = ENTITY.GET_ENTITY_MAX_HEALTH(players.user_ped()) - 100
        local toLock_health = math.ceil(maxHealth * low_health_limit + 100)
        if ENTITY.GET_ENTITY_HEALTH(players.user_ped()) < toLock_health then
            ENTITY.SET_ENTITY_HEALTH(players.user_ped(), toLock_health)
        end
    end
end)
menu.toggle_loop(Self_Custom_low_limit, "补满血量", {}, "当你的血量到达你设置的血量下限值后，补满你的血量"
    , function()
    if not PLAYER.IS_PLAYER_DEAD(players.user()) then
        local maxHealth = ENTITY.GET_ENTITY_MAX_HEALTH(players.user_ped()) - 100
        local toLock_health = math.ceil(maxHealth * low_health_limit + 100)
        if ENTITY.GET_ENTITY_HEALTH(players.user_ped()) < toLock_health then
            ENTITY.SET_ENTITY_HEALTH(players.user_ped(), maxHealth + 100)
        end
    end
end)
------

menu.toggle_loop(Self_options, "显示血量和护甲", {}, "信息显示", function()
    local current_health = ENTITY.GET_ENTITY_HEALTH(PLAYER.PLAYER_PED_ID())
    local max_health = PED.GET_PED_MAX_HEALTH(PLAYER.PLAYER_PED_ID())
    local current_armour = PED.GET_PED_ARMOUR(PLAYER.PLAYER_PED_ID())
    local max_armour = PLAYER.GET_PLAYER_MAX_ARMOUR(PLAYER.PLAYER_ID())
    local text = "血量： " .. current_health .. "/" .. max_health .. "\n护甲： " ..
        current_armour .. "/" .. max_armour
    util.draw_debug_text(text)
end)

menu.toggle_loop(Self_options, "警察无视", {}, "", function()
    PLAYER.SET_POLICE_IGNORE_PLAYER(PLAYER.PLAYER_ID(), true)
end, function()
    PLAYER.SET_POLICE_IGNORE_PLAYER(PLAYER.PLAYER_ID(), false)
end)
menu.toggle_loop(Self_options, "所有人无视", {}, "", function()
    PLAYER.SET_EVERYONE_IGNORE_PLAYER(PLAYER.PLAYER_ID(), true)
end, function()
    PLAYER.SET_EVERYONE_IGNORE_PLAYER(PLAYER.PLAYER_ID(), false)
end)
menu.toggle_loop(Self_options, "行动无声", {}, "", function()
    PLAYER.SET_PLAYER_NOISE_MULTIPLIER(PLAYER.PLAYER_ID(), 0.0)
    PLAYER.SET_PLAYER_SNEAKING_NOISE_MULTIPLIER(PLAYER.PLAYER_ID(), 0.0)
end)
menu.toggle_loop(Self_options, "不会被帮派骚乱", {}, "", function()
    PLAYER.SET_PLAYER_CAN_BE_HASSLED_BY_GANGS(PLAYER.PLAYER_ID(), false)
end, function()
    PLAYER.SET_PLAYER_CAN_BE_HASSLED_BY_GANGS(PLAYER.PLAYER_ID(), true)
end)
menu.toggle_loop(Self_options, "不可被拽出载具", {}, "", function()
    PED.SET_PED_CAN_BE_DRAGGED_OUT(PLAYER.PLAYER_PED_ID(), false)
end, function()
    PED.SET_PED_CAN_BE_DRAGGED_OUT(PLAYER.PLAYER_PED_ID(), true)
end)
menu.toggle_loop(Self_options, "载具内不可被射击", {}, "在载具内不会受伤", function()
    PED.SET_PED_CAN_BE_SHOT_IN_VEHICLE(PLAYER.PLAYER_PED_ID(), false)
end, function()
    PED.SET_PED_CAN_BE_SHOT_IN_VEHICLE(PLAYER.PLAYER_PED_ID(), true)
end)
menu.toggle_loop(Self_options, "禁止为玩家调度警察", {}, "不会一直刷出新的警察，最好在被通缉前开启"
    , function()
        PLAYER.SET_DISPATCH_COPS_FOR_PLAYER(PLAYER.PLAYER_ID(), false)
    end, function()
    PLAYER.SET_DISPATCH_COPS_FOR_PLAYER(PLAYER.PLAYER_ID(), true)
end)
menu.toggle_loop(Self_options, "禁用NPC伤害", {}, "", function()
    PED.SET_AI_WEAPON_DAMAGE_MODIFIER(0.0)
    PED.SET_AI_MELEE_WEAPON_DAMAGE_MODIFIER(0.0)
end, function()
    PED.RESET_AI_WEAPON_DAMAGE_MODIFIER()
    PED.RESET_AI_MELEE_WEAPON_DAMAGE_MODIFIER()
end)





--------------------------------
------------ 武器选项 ------------
--------------------------------
local Weapon_options = menu.list(menu.my_root(), "武器选项", {}, "")

menu.toggle(Weapon_options, "可以射击队友", {}, "使你在游戏中能够射击队友", function(toggle)
    PED.SET_CAN_ATTACK_FRIENDLY(PLAYER.PLAYER_PED_ID(), toggle, false)
end)
menu.toggle_loop(Weapon_options, "翻滚时自动换弹夹", {}, "当你做翻滚动作时更换弹夹", function()
    if TASK.GET_IS_TASK_ACTIVE(PLAYER.PLAYER_PED_ID(), 4) and PAD.IS_CONTROL_PRESSED(2, 22) and
        not PED.IS_PED_SHOOTING(PLAYER.PLAYER_PED_ID()) then
        --checking if player is rolling
        util.yield(900)
        WEAPON.REFILL_AMMO_INSTANTLY(PLAYER.PLAYER_PED_ID())
    end
end)
menu.toggle_loop(Weapon_options, "无限弹药", { "inf_clip" }, "锁定弹夹，可以避免子弹过多的检测",
    function()
        WEAPON.SET_PED_INFINITE_AMMO_CLIP(PLAYER.PLAYER_PED_ID(), true)
    end, function()
    WEAPON.SET_PED_INFINITE_AMMO_CLIP(PLAYER.PLAYER_PED_ID(), false)
end)
menu.toggle_loop(Weapon_options, "锁定最大弹药", { "lock_ammo" }, "锁定当前武器为最大弹药\n内存读写操作，易崩溃"
    , function()
    local curWeaponMem = memory.alloc_int()
    local junk = WEAPON.GET_CURRENT_PED_WEAPON(PLAYER.PLAYER_PED_ID(), curWeaponMem, 1)
    local curWeapon = memory.read_int(curWeaponMem)
    memory.free(curWeaponMem)

    local curAmmoMem = memory.alloc_int()
    junk = WEAPON.GET_MAX_AMMO(PLAYER.PLAYER_PED_ID(), curWeapon, curAmmoMem)
    local curAmmoMax = memory.read_int(curAmmoMem)
    memory.free(curAmmoMem)

    if curAmmoMax > 0 then
        WEAPON.SET_PED_AMMO(PLAYER.PLAYER_PED_ID(), curWeapon, curAmmoMax)
    end
end)


------------------------
------- 视野工具枪 -------
------------------------
local Weapon_Cam_Gun = menu.list(Weapon_options, "视野工具枪", {}, "玩家镜头中心的位置")


local Cam_Gun = {
    select = 1,

}

--- Shoot ---
Cam_Gun.shoot_setting = {
    shoot_method = 1,
    delay = 100,

    weapon_select = 1,
    weapon_hash = "PLAYER_WEAPON",
    vehicle_weapon_hash = "VEHICLE_WEAPON",

    is_owned = false,
    CreateTraceVfx = true,
    AllowRumble = true,
    damage = 1000,
    speed = 1000,
    PerfectAccuracy = false,

    start_from_player = false,
    x = 0.0,
    y = 0.0,
    z = 2.0,
}

function Cam_Gun.Shoot_Pos(pos, state)
    local user_ped = players.user_ped()

    local weaponHash = Cam_Gun.shoot_setting.weapon_hash
    if Cam_Gun.shoot_setting.weapon_select == 2 then
        weaponHash = Cam_Gun.shoot_setting.vehicle_weapon_hash
    end

    if weaponHash == "PLAYER_WEAPON" then
        local pWeapon = memory.alloc_int()
        WEAPON.GET_CURRENT_PED_WEAPON(user_ped, pWeapon, true)
        weaponHash = memory.read_int(pWeapon)
    elseif weaponHash == "VEHICLE_WEAPON" then
        local pWeapon = memory.alloc_int()
        WEAPON.GET_CURRENT_PED_VEHICLE_WEAPON(user_ped, pWeapon)
        weaponHash = memory.read_int(pWeapon)
    end
    if not WEAPON.HAS_WEAPON_ASSET_LOADED(weaponHashHash) then
        Request_Weapon_Asset(weaponHash)
    end

    local owner = 0
    if Cam_Gun.shoot_setting.is_owned then
        owner = user_ped
    end

    local start_pos = v3.new()
    if Cam_Gun.shoot_setting.start_from_player then
        local player_pos = ENTITY.GET_ENTITY_COORDS(user_ped)
        start_pos.x = player_pos.x + Cam_Gun.shoot_setting.x
        start_pos.y = player_pos.y + Cam_Gun.shoot_setting.y
        start_pos.z = player_pos.z + Cam_Gun.shoot_setting.z
    else
        start_pos.x = pos.x + Cam_Gun.shoot_setting.x
        start_pos.y = pos.y + Cam_Gun.shoot_setting.y
        start_pos.z = pos.z + Cam_Gun.shoot_setting.z
    end

    if state == "drawing_line" then
        DRAW_LINE(start_pos, pos)
    elseif state == "shoot" then
        local ignore_entity = user_ped
        if PED.IS_PED_IN_ANY_VEHICLE(user_ped, false) then
            ignore_entity = PED.GET_VEHICLE_PED_IS_IN(user_ped, false)
        end

        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(start_pos.x, start_pos.y, start_pos.z,
            pos.x, pos.y, pos.z,
            Cam_Gun.shoot_setting.damage, Cam_Gun.shoot_setting.PerfectAccuracy, weaponHash, owner,
            Cam_Gun.shoot_setting.CreateTraceVfx, Cam_Gun.shoot_setting.AllowRumble, Cam_Gun.shoot_setting.speed,
            ignore_entity)
    end

end

function Cam_Gun.Shoot()
    local cam_pos
    if Cam_Gun.shoot_setting.shoot_method == 1 then
        local result = get_raycast_result(1500, -1)
        if result.didHit then
            cam_pos = result.endCoords
        end
    elseif Cam_Gun.shoot_setting.shoot_method == 2 then
        cam_pos = get_offset_from_cam(1500)
    end

    if cam_pos ~= nil then
        Cam_Gun.Shoot_Pos(cam_pos, "shoot")
        util.yield(Cam_Gun.shoot_setting.delay)
    end
end

--- Explosion ---
Cam_Gun.explosion_setting = {
    delay = 100,
    explosionType = 2,
    is_owned = false,
    damage = 1000,
    is_audible = true,
    is_invisible = false,
    camera_shake = 0.0,
}

function Cam_Gun.Explosion()
    local result = get_raycast_result(1500, -1)
    local cam_pos = result.endCoords
    if result.didHit and cam_pos ~= nil then
        if Cam_Gun.explosion_setting.is_owned then
            FIRE.ADD_OWNED_EXPLOSION(players.user_ped(), cam_pos.x, cam_pos.y, cam_pos.z,
                Cam_Gun.explosion_setting.explosionType, Cam_Gun.explosion_setting.damage,
                Cam_Gun.explosion_setting.is_audible, Cam_Gun.explosion_setting.is_invisible,
                Cam_Gun.explosion_setting.camera_shake)
        else
            FIRE.ADD_EXPLOSION(cam_pos.x, cam_pos.y, cam_pos.z, Cam_Gun.explosion_setting.explosionType,
                Cam_Gun.explosion_setting.damage, Cam_Gun.explosion_setting.is_audible,
                Cam_Gun.explosion_setting.is_invisible
                , Cam_Gun.explosion_setting.camera_shake, false)
        end
        util.yield(Cam_Gun.explosion_setting.delay)
    end
end

--- Fire ---
Cam_Gun.fire_setting = {
    fire_ids = {},
    maxChildren = 25,
    isGasFire = false,
}

function Cam_Gun.Fire()
    local result = get_raycast_result(1500, -1)
    local cam_pos = result.endCoords
    if result.didHit and cam_pos ~= nil then
        local fire_id = FIRE.START_SCRIPT_FIRE(cam_pos.x, cam_pos.y, cam_pos.z, Cam_Gun.fire_setting.maxChildren,
            Cam_Gun.fire_setting.isGasFire)
        table.insert(Cam_Gun.fire_setting.fire_ids, fire_id)
    end
end

menu.toggle_loop(Weapon_Cam_Gun, "开启[按住E键]", { "cam_gun" }, "", function()
    main_tick_handler.draw_point_on_screen = true
    if PAD.IS_CONTROL_PRESSED(0, 51) then
        if Cam_Gun.select == 1 then
            Cam_Gun.Shoot()
        elseif Cam_Gun.select == 2 then
            Cam_Gun.Explosion()
        elseif Cam_Gun.select == 3 then
            Cam_Gun.Fire()
        end
    end
end, function()
    main_tick_handler.draw_point_on_screen = false
end)

menu.list_select(Weapon_Cam_Gun, "选择操作", { "cam_gun_select" }, "", {
    { "射击", { "shoot" }, "" },
    { "爆炸", { "explosion" }, "" },
    { "燃烧", { "fire" }, "" },
}, 1, function(value)
    Cam_Gun.select = value
end)


menu.divider(Weapon_Cam_Gun, "设置")
----------------
-- 射击设置
----------------
local Cam_Gun_shoot = menu.list(Weapon_Cam_Gun, "射击", {}, "")

menu.toggle_loop(Cam_Gun_shoot, "绘制射击连线", {}, "", function()
    main_tick_handler.draw_point_on_screen = true

    local cam_pos
    if Cam_Gun.shoot_setting.shoot_method == 1 then
        local result = get_raycast_result(1500, -1)
        if result.didHit then
            cam_pos = result.endCoords
        end
    elseif Cam_Gun.shoot_setting.shoot_method == 2 then
        cam_pos = get_offset_from_cam(1500)
    end

    if cam_pos ~= nil then
        Cam_Gun.Shoot_Pos(cam_pos, "drawing_line")
    end

end, function()
    main_tick_handler.draw_point_on_screen = false
end)

menu.list_select(Cam_Gun_shoot, "射击方式", {}, "", {
    { "方式1", {}, "射击的坐标更加准确，只能向实体或地面射击" },
    { "方式2", {}, "射击的坐标不是很准确，但可以向空中射击" }
}, 1, function(value)
    Cam_Gun.shoot_setting.shoot_method = value
end)
menu.slider(Cam_Gun_shoot, "循环延迟", { "cam_gun_shoot_delay" }, "单位: ms", 0, 5000, 100, 10,
    function(value)
        Cam_Gun.shoot_setting.delay = value
    end)

local Cam_Gun_shoot_weapon = menu.list(Cam_Gun_shoot, "武器", {}, "")
menu.list_select(Cam_Gun_shoot_weapon, "武器类型", {}, "", { { "手持武器" }, { "载具武器" } }, 1,
    function(value)
        Cam_Gun.shoot_setting.weapon_select = value
    end)
menu.list_select(Cam_Gun_shoot_weapon, "手持武器", {}, "", AllWeapons_NoMelee_ListItem, 1, function(value)
    Cam_Gun.shoot_setting.weapon_hash = AllWeapons_NoMelee_ListItem[value][3]
end)
menu.list_select(Cam_Gun_shoot_weapon, "载具武器", {}, "", All_VehicleWeapons_ListItem, 1, function(value)
    Cam_Gun.shoot_setting.vehicle_weapon_hash = All_VehicleWeapons_ListItem[value][3]
end)

menu.toggle(Cam_Gun_shoot, "署名射击", {}, "以玩家名义", function(toggle)
    Cam_Gun.shoot_setting.is_owned = toggle
end)
menu.slider(Cam_Gun_shoot, "伤害", { "cam_gun_shoot_damage" }, "", 0, 10000, 1000, 100,
    function(value)
        Cam_Gun.shoot_setting.damage = value
    end)
menu.slider(Cam_Gun_shoot, "速度", { "cam_gun_shoot_speed" }, "", 0, 10000, 1000, 100,
    function(value)
        Cam_Gun.shoot_setting.speed = value
    end)
menu.toggle(Cam_Gun_shoot, "Create Trace Vfx", {}, "", function(toggle)
    Cam_Gun.shoot_setting.CreateTraceVfx = toggle
end, true)
menu.toggle(Cam_Gun_shoot, "Allow Rumble", {}, "", function(toggle)
    Cam_Gun.shoot_setting.AllowRumble = toggle
end, true)
menu.toggle(Cam_Gun_shoot, "Perfect Accuracy", {}, "", function(toggle)
    Cam_Gun.shoot_setting.PerfectAccuracy = toggle
end)
menu.divider(Cam_Gun_shoot, "起始射击位置偏移")
menu.toggle(Cam_Gun_shoot, "从玩家位置起始射击", {}, "如果关闭，则起始位置为目标位置+偏移\n如果开启，建议偏移Z>1.0"
    ,
    function(toggle)
        Cam_Gun.shoot_setting.start_from_player = toggle
    end)
menu.slider_float(Cam_Gun_shoot, "X", { "cam_gun_shoot_x" }, "", -10000, 10000, 0, 10,
    function(value)
        value = value * 0.01
        Cam_Gun.shoot_setting.x = value
    end)
menu.slider_float(Cam_Gun_shoot, "Y", { "cam_gun_shoot_y" }, "", -10000, 10000, 0, 10,
    function(value)
        value = value * 0.01
        Cam_Gun.shoot_setting.y = value
    end)
menu.slider_float(Cam_Gun_shoot, "Z", { "cam_gun_shoot_z" }, "", -10000, 10000, 200, 10,
    function(value)
        value = value * 0.01
        Cam_Gun.shoot_setting.z = value
    end)

----------------
-- 爆炸设置
----------------
local Cam_Gun_explosion = menu.list(Weapon_Cam_Gun, "爆炸", {}, "")

menu.slider(Cam_Gun_explosion, "循环延迟", { "cam_gun_explosion_delay" }, "单位: ms", 0, 5000, 100, 10,
    function(value)
        Cam_Gun.explosion_setting.delay = value
    end)
menu.list_select(Cam_Gun_explosion, "爆炸类型", {}, "", ExplosionType_ListItem, 4, function(index)
    Cam_Gun.explosion_setting.explosionType = index - 2
end)
menu.toggle(Cam_Gun_explosion, "署名爆炸", {}, "以玩家名义", function(toggle)
    Cam_Gun.explosion_setting.is_owned = toggle
end)
menu.slider(Cam_Gun_explosion, "伤害", { "cam_gun_explosion_damage" }, "", 0, 10000, 1000, 100,
    function(value)
        Cam_Gun.explosion_setting.damage = value
    end)
menu.toggle(Cam_Gun_explosion, "可听见", {}, "", function(toggle)
    Cam_Gun.explosion_setting.is_audible = toggle
end, true)
menu.toggle(Cam_Gun_explosion, "不可见", {}, "", function(toggle)
    Cam_Gun.explosion_setting.is_invisible = toggle
end)
menu.slider_float(Cam_Gun_explosion, "镜头晃动", { "cam_gun_explosion_camera_shake" }, "", 0, 1000, 0, 10,
    function(value)
        value = value * 0.01
        Cam_Gun.explosion_setting.camera_shake = value
    end)

----------------
-- 燃烧设置
----------------
local Cam_Gun_fire = menu.list(Weapon_Cam_Gun, "燃烧", {}, "")

menu.slider(Cam_Gun_fire, "max Children", { "cam_gun_fire_maxChildren" },
    "The max amount of times a fire can spread to other objects.", 0, 25, 25, 1, function(value)
    Cam_Gun.fire_setting.maxChildren = value
end)
menu.toggle(Cam_Gun_fire, "is Gas Fire", {}, "Whether or not the fire is powered by gasoline.", function(toggle)
    Cam_Gun.fire_setting.isGasFire = toggle
end)
menu.action(Cam_Gun_fire, "REMOVE_SCRIPT_FIRE", {}, "", function()
    if next(Cam_Gun.fire_setting.fire_ids) ~= nil then
        for k, v in pairs(Cam_Gun.fire_setting.fire_ids) do
            FIRE.REMOVE_SCRIPT_FIRE(v)
        end
        Cam_Gun.fire_setting.fire_ids = {}
    end
end)



------------------------
------- 实体控制枪 -------
------------------------
local Weapon_Entity_Control = menu.list(Weapon_options, "实体控制枪", {}, "控制你所瞄准的实体")

local entity_control_data = {
    entity_type = "全部",
}

local function entity_control_Head(menu_parent, ent)
    menu.action(menu_parent, "检测该实体是否存在", {}, "", function()
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            util.toast("实体存在")
        else
            util.toast("该实体已经不存在，请删除此条实体记录！")
        end
    end)
    menu.action(menu_parent, "删除此条实体记录", {}, "", function()
        menu.delete(menu_parent)
        clearTableValue(control_ent_menu_list, menu_parent)
        clearTableValue(control_ent_list, ent)

        control_ent_count = control_ent_count - 1
        if control_ent_count <= 0 then
            menu.set_menu_name(Weapon_Entity_Control_divider, "实体控制列表")
        else
            menu.set_menu_name(Weapon_Entity_Control_divider, "实体控制列表 (" .. control_ent_count .. ")")
        end
    end)
end

local function Init_control_ent_list()
    -- 所有控制的实体
    control_ent_list = {}
    -- 所有控制实体的menu.list
    control_ent_menu_list = {}
    -- 控制实体的索引
    control_ent_index = 1
    -- 已记录实体的数量
    control_ent_count = 0
end

Init_control_ent_list()

menu.toggle_loop(Weapon_Entity_Control, "开启", { "ctrl_gun" }, "", function()
    draw_point_in_center()
    local ent
    local Type = entity_control_data.entity_type
    local temp_ent = GetEntity_PlayerIsAimingAt(players.user())
    if temp_ent ~= nil then
        if Type == "全部" then
            if IS_AN_ENTITY(temp_ent) then
                ent = temp_ent
            end
        else
            local ent_type = GET_ENTITY_TYPE(temp_ent, 2)
            if Type == ent_type then
                ent = temp_ent
            end
        end

        if ent ~= nil then
            --Draw Line
            local pos1 = ENTITY.GET_ENTITY_COORDS(players.user_ped())
            local pos2 = ENTITY.GET_ENTITY_COORDS(ent)
            GRAPHICS.DRAW_LINE(pos1.x, pos1.y, pos1.z, pos2.x, pos2.y, pos2.z, 255, 0, 255, 255)

            if not isInTable(control_ent_list, ent) then
                table.insert(control_ent_list, ent) --entity

                -- menu_name
                local modelHash = ENTITY.GET_ENTITY_MODEL(ent)
                local modelName = util.reverse_joaat(modelHash)
                local menu_name = control_ent_index .. ". "
                if modelName ~= "" then
                    menu_name = menu_name .. modelName
                else
                    menu_name = menu_name .. modelHash
                end
                -- help_text
                local text = ""

                local display_name = util.get_label_text(VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(modelHash))
                if display_name ~= "NULL" then
                    text = text .. "Display Name: " .. display_name .. "\n"
                end

                local entity_type = GET_ENTITY_TYPE(ent, 2)
                local owner = entities.get_owner(entities.handle_to_pointer(ent))
                owner = players.get_name(owner)
                text = text .. "Hash: " .. modelHash .. "\nType: " .. entity_type .. "\nOwner: " .. owner

                util.toast(menu_name .. "\n" .. text)

                -- 实体控制列表 menu.list
                local menu_list = menu.list(Weapon_Entity_Control, menu_name, {}, text)

                entity_control_Head(menu_list, ent)
                Entity_Control.generate_menu(menu_list, ent, control_ent_index)

                table.insert(control_ent_menu_list, menu_list) --menu.list

                control_ent_index = control_ent_index + 1
                control_ent_count = control_ent_count + 1
                if control_ent_count == 0 then
                    menu.set_menu_name(Weapon_Entity_Control_divider, "实体控制列表")
                else
                    menu.set_menu_name(Weapon_Entity_Control_divider, "实体控制列表 (" .. control_ent_count .. ")")
                end
            end


        end

    end
end)

local Weapon_Entity_Control_TypeListItem = {
    { "全部", {}, "全部类型实体" },
    { "Ped", {}, "NPC" },
    { "Vehicle", {}, "载具" },
    { "Object", {}, "物体" },
    { "Pickup", {}, "拾取物" }
}
menu.list_select(Weapon_Entity_Control, "实体类型", {}, "", Weapon_Entity_Control_TypeListItem, 1,
    function(index, name)
        entity_control_data.entity_type = name
    end)
menu.action(Weapon_Entity_Control, "清除记录的实体", {}, "", function()
    for k, v in pairs(control_ent_menu_list) do
        if v ~= nil and menu.is_ref_valid(v) then
            menu.delete(v)
        end
    end
    Init_control_ent_list()
    menu.set_menu_name(Weapon_Entity_Control_divider, "实体控制列表")
end)
Weapon_Entity_Control_divider = menu.divider(Weapon_Entity_Control, "实体控制列表")



--------------------------------
------------ 载具选项 ------------
--------------------------------
local Vehicle_options = menu.list(menu.my_root(), "载具选项", {}, "")

----- 载具改装 -----
local Vehicle_MOD_options = menu.list(Vehicle_options, "载具改装", {}, "")

local vehicle_mod = {
    performance = 2,
    turbo = true,
    spoilers = 1,
    suspension = 1,
    xenon = -1,
    extra_types = 1,

    neon = {
        toggle = false,
        r = 0,
        g = 0,
        b = 0,
        left = false,
        right = false,
        front = false,
        rear = false,
    },
    tyre_smoke = {
        toggle = false,
        r = 255,
        g = 255,
        b = 255,
    },
    plate = {
        toggle = false,
        text = "ROCKSTAR",
    },
    bullet_tyre = true,
    unbreakable_doors = false,
    unbreakable_lights = false,
}

local VehicleMOD_ListItem = {
    { "默认", {}, "不进行改装" },
    { "顶级" }
}
local Vehicle_MOD_Kits = menu.list(Vehicle_MOD_options, "改装选项", {}, "")
menu.list_select(Vehicle_MOD_Kits, "主要性能", {}, "引擎、刹车、变速箱、防御", VehicleMOD_ListItem, 2,
    function(value)
        vehicle_mod.performance = value
    end)
menu.toggle(Vehicle_MOD_Kits, "涡轮增压", {}, "", function(toggle)
    vehicle_mod.turbo = toggle
end, true)
menu.list_select(Vehicle_MOD_Kits, "尾翼", {}, "", VehicleMOD_ListItem, 1, function(value)
    vehicle_mod.spoilers = value
end)
menu.list_select(Vehicle_MOD_Kits, "悬挂", {}, "", VehicleMOD_ListItem, 1, function(value)
    vehicle_mod.suspension = value
end)
menu.slider(Vehicle_MOD_Kits, "前车灯", { "vehicle_xenon_light" }, "", -1, 12, -1, 1, function(value)
    vehicle_mod.xenon = value

    if PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
        local veh = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
        if veh then
            if vehicle_mod.xenon >= 0 then
                VEHICLE.TOGGLE_VEHICLE_MOD(veh, 22, true)
                VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(veh, vehicle_mod.xenon)
            else
                VEHICLE.TOGGLE_VEHICLE_MOD(veh, 22, false)
            end
        end
    end

end)
menu.list_select(Vehicle_MOD_Kits, "其它改装配件", {}, "侧裙、保险杠等，排除涂装、车轮、喇叭",
    VehicleMOD_ListItem, 1, function(value)
    vehicle_mod.extra_types = value
end)

local Vehicle_MOD_neon = menu.list(Vehicle_MOD_Kits, "霓虹灯", {}, "")
menu.toggle(Vehicle_MOD_neon, "开启", {}, "", function(toggle)
    vehicle_mod.neon.toggle = toggle
end)
menu.colour(Vehicle_MOD_neon, "颜色", { "vehicle_neon_colour" }, "", 1, 1, 1
    , 1, false, function(colour)
    vehicle_mod.neon.r = math.ceil(255 * colour.r)
    vehicle_mod.neon.g = math.ceil(255 * colour.g)
    vehicle_mod.neon.b = math.ceil(255 * colour.b)
end)
menu.toggle(Vehicle_MOD_neon, "左", {}, "", function(toggle)
    vehicle_mod.neon.left = toggle
end)
menu.toggle(Vehicle_MOD_neon, "右", {}, "", function(toggle)
    vehicle_mod.neon.right = toggle
end)
menu.toggle(Vehicle_MOD_neon, "前", {}, "", function(toggle)
    vehicle_mod.neon.front = toggle
end)
menu.toggle(Vehicle_MOD_neon, "后", {}, "", function(toggle)
    vehicle_mod.neon.rear = toggle
end)

local Vehicle_MOD_tyre_smoke = menu.list(Vehicle_MOD_Kits, "轮胎烟雾", {}, "")
menu.toggle(Vehicle_MOD_tyre_smoke, "开启", {}, "", function(toggle)
    vehicle_mod.tyre_smoke.toggle = toggle
end)
menu.colour(Vehicle_MOD_tyre_smoke, "颜色", { "vehicle_tyre_smoke_colour" }, "设置R,G,B都为0会使载具轮胎烟雾为独立日颜色"
    , 1, 1, 1
    , 1, false, function(colour)
    vehicle_mod.tyre_smoke.r = math.ceil(255 * colour.r)
    vehicle_mod.tyre_smoke.g = math.ceil(255 * colour.g)
    vehicle_mod.tyre_smoke.b = math.ceil(255 * colour.b)
end)

local Vehicle_MOD_plate = menu.list(Vehicle_MOD_Kits, "车牌", {}, "")
menu.toggle(Vehicle_MOD_plate, "开启", {}, "", function(toggle)
    vehicle_mod.plate.toggle = toggle
end)
menu.text_input(Vehicle_MOD_plate, "内容", { "vehicle_plate_text" }, "最大8个字符", function(value)
    vehicle_mod.plate.text = value
end, "ROCKSTAR")


local Vehicle_MOD_Extra_options = menu.list(Vehicle_MOD_options, "其它改装选项", {}, "")
menu.toggle(Vehicle_MOD_Extra_options, "防弹轮胎", {}, "", function(toggle)
    vehicle_mod.bullet_tyre = toggle
end, true)
menu.toggle(Vehicle_MOD_Extra_options, "不可损坏的车门", {}, "", function(toggle)
    vehicle_mod.unbreakable_doors = toggle
end)
menu.toggle(Vehicle_MOD_Extra_options, "不可损坏的车灯", {}, "", function(toggle)
    vehicle_mod.unbreakable_lights = toggle
end)

local function Custom_Mod_Vehicle(vehicle)
    VEHICLE.SET_VEHICLE_MOD_KIT(vehicle, 0)

    if vehicle_mod.performance == 2 then
        for k, v in pairs({ 11, 12, 13, 16 }) do
            local mod_num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, v)
            VEHICLE.SET_VEHICLE_MOD(vehicle, v, mod_num - 1, false)
        end
    end

    if vehicle_mod.turbo then
        VEHICLE.TOGGLE_VEHICLE_MOD(vehicle, 18, true)
    end

    if vehicle_mod.spoilers == 2 then
        local mod_num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, 0)
        VEHICLE.SET_VEHICLE_MOD(vehicle, 0, mod_num - 1, false)
    end

    if vehicle_mod.suspension == 2 then
        local mod_num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, 15)
        VEHICLE.SET_VEHICLE_MOD(vehicle, 15, mod_num - 1, false)
    end

    if vehicle_mod.extra_types == 2 then
        local extra_type_list = {
            1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
            25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38,
            39, 40, 41, 42, 43, 44, 45, 46
        }
        for k, v in pairs(extra_type_list) do
            local mod_num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, v)
            if mod_num > 0 then
                VEHICLE.SET_VEHICLE_MOD(vehicle, v, mod_num - 1, false)
            end
        end
    end

    if vehicle_mod.xenon >= 0 then
        VEHICLE.TOGGLE_VEHICLE_MOD(vehicle, 22, true)
        VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(vehicle, vehicle_mod.xenon)
    end

    if vehicle_mod.neon.toggle then
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehicle, 0, vehicle_mod.neon.left)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehicle, 1, vehicle_mod.neon.right)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehicle, 2, vehicle_mod.neon.front)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehicle, 3, vehicle_mod.neon.rear)
        VEHICLE.SET_VEHICLE_NEON_COLOUR(vehicle, vehicle_mod.neon.r, vehicle_mod.neon.g,
            vehicle_mod.neon.b)
    end

    if vehicle_mod.tyre_smoke.toggle then
        VEHICLE.TOGGLE_VEHICLE_MOD(vehicle, 20, true)
        VEHICLE.SET_VEHICLE_TYRE_SMOKE_COLOR(vehicle, vehicle_mod.tyre_smoke.r, vehicle_mod.tyre_smoke.g
            , vehicle_mod.tyre_smoke.b)
    end

    if vehicle_mod.plate.toggle then
        VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, vehicle_mod.plate.text)
    end

    -- 其它改装选项
    if vehicle_mod.bullet_tyre then
        VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(vehicle, false)
    end
    if vehicle_mod.unbreakable_doors then
        for i = 0, 3 do
            VEHICLE.SET_DOOR_ALLOWED_TO_BE_BROKEN_OFF(vehicle, i, false)
        end
    end
    if vehicle_mod.unbreakable_lights then
        VEHICLE.SET_VEHICLE_HAS_UNBREAKABLE_LIGHTS(vehicle, true)
    end
end

menu.toggle_loop(Vehicle_MOD_options, "开启自动改装", { "auto_mod_vehicle" }, "自动改装正在进入的载具",
    function()
        if PED.IS_PED_GETTING_INTO_A_VEHICLE(players.user_ped()) then
            local veh = PED.GET_VEHICLE_PED_IS_ENTERING(players.user_ped())
            if veh then
                Custom_Mod_Vehicle(veh)
            end
        end
    end)
menu.action(Vehicle_MOD_options, "改装载具", { "mod_vehicle" }, "改装当前载具或上一辆载具", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        Custom_Mod_Vehicle(vehicle)
    end
end)


----- 载具车窗 -----
local Vehicle_Window_options = menu.list(Vehicle_options, "载具车窗", {}, "")

local VehicleWindows_ListItem = {
    { "全部" },
    { "左前车窗" }, -- 0
    { "右前车窗" }, -- 1
    { "左后车窗" }, -- 2
    { "右后车窗" }, -- 3
    { "前挡风车窗" }, -- 4
    { "后挡风车窗" } -- 5
}
local vehicle_window_select = 1 --选择的车窗
menu.list_select(Vehicle_Window_options, "选择车窗", {}, "", VehicleWindows_ListItem, 1, function(value)
    vehicle_window_select = value
end)

menu.toggle_loop(Vehicle_Window_options, "修复车窗", {}, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        if vehicle_window_select == 1 then
            for i = 0, 7 do
                VEHICLE.FIX_VEHICLE_WINDOW(vehicle, i)
            end
        elseif vehicle_window_select > 1 then
            VEHICLE.FIX_VEHICLE_WINDOW(vehicle, vehicle_window_select - 2)
        end
    end
end)
menu.toggle_loop(Vehicle_Window_options, "摇下车窗", {}, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        if vehicle_window_select == 1 then
            for i = 0, 7 do
                VEHICLE.ROLL_DOWN_WINDOW(vehicle, i)
            end
        elseif vehicle_window_select > 1 then
            VEHICLE.ROLL_DOWN_WINDOW(vehicle, vehicle_window_select - 2)
        end
    end
end, function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        if vehicle_window_select == 1 then
            for i = 0, 7 do
                VEHICLE.ROLL_UP_WINDOW(vehicle, i)
            end
        elseif vehicle_window_select > 1 then
            VEHICLE.ROLL_UP_WINDOW(vehicle, vehicle_window_select - 2)
        end
    end
end)
menu.toggle_loop(Vehicle_Window_options, "粉碎车窗", {}, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        if vehicle_window_select == 1 then
            for i = 0, 7 do
                VEHICLE.SMASH_VEHICLE_WINDOW(vehicle, i)
            end
        elseif vehicle_window_select > 1 then
            VEHICLE.SMASH_VEHICLE_WINDOW(vehicle, vehicle_window_select - 2)
        end
    end
end)


----- 载具门 -----
local Vehicle_Door_options = menu.list(Vehicle_options, "载具门", {}, "")

local VehicleDoors_ListItem = {
    { "全部" },
    { "左前门" }, -- VEH_EXT_DOOR_DSIDE_F = 0
    { "右前门" }, -- VEH_EXT_DOOR_DSIDE_R = 1
    { "左后门" }, -- VEH_EXT_DOOR_PSIDE_F = 2
    { "右后门" }, -- VEH_EXT_DOOR_PSIDE_R = 3
    { "引擎盖" }, -- VEH_EXT_BONNET = 4
    { "后备箱" } -- VEH_EXT_BOOT = 5
}
local vehicle_door_select = 1 --选择的车门
menu.list_select(Vehicle_Door_options, "选择车门", {}, "", VehicleDoors_ListItem, 1, function(value)
    vehicle_door_select = value
end)

menu.toggle_loop(Vehicle_Door_options, "打开车门", {}, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        if vehicle_door_select == 1 then
            for i = 0, 3 do
                VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, i, false, false)
            end
        elseif vehicle_door_select > 1 then
            VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, vehicle_door_select - 2, false, false)
        end
    end
end)
menu.action(Vehicle_Door_options, "关闭车门", {}, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        if vehicle_door_select == 1 then
            for i = 0, 3 do
                VEHICLE.SET_VEHICLE_DOOR_SHUT(vehicle, i, false)
            end
        elseif vehicle_door_select > 1 then
            VEHICLE.SET_VEHICLE_DOOR_SHUT(vehicle, vehicle_door_select - 2, false)
        end
    end
end)
menu.toggle_loop(Vehicle_Door_options, "破坏车门", {}, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        if vehicle_door_select == 1 then
            for i = 0, 3 do
                VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, i, false)
            end
        elseif vehicle_door_select > 1 then
            VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, vehicle_door_select - 2, false)
        end
    end
end)
menu.toggle_loop(Vehicle_Door_options, "删除车门", {}, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        if vehicle_door_select == 1 then
            for i = 0, 3 do
                VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, i, true)
            end
        elseif vehicle_door_select > 1 then
            VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, vehicle_door_select - 2, true)
        end
    end
end)
menu.toggle(Vehicle_Door_options, "车门不可损坏", {}, "", function(toggle)
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        if vehicle_door_select == 1 then
            for i = 0, 3 do
                VEHICLE.SET_DOOR_ALLOWED_TO_BE_BROKEN_OFF(vehicle, i, not toggle)
            end
        elseif vehicle_door_select > 1 then
            VEHICLE.SET_DOOR_ALLOWED_TO_BE_BROKEN_OFF(vehicle, vehicle_door_select - 2, not toggle)
        end
    end
end)


----- 载具锁门 -----
local Vehicle_DoorLock_options = menu.list(Vehicle_options, "载具锁门", {}, "")

local VehicleDoorsLock_ListItem = {
    { "解锁" }, --VEHICLELOCK_UNLOCKED == 1
    { "上锁" }, --VEHICLELOCK_LOCKED
    { "LOCKOUT PLAYER ONLY", {}, "只对玩家锁门？" }, --VEHICLELOCK_LOCKOUT_PLAYER_ONLY
    { "玩家锁定在里面" }, --VEHICLELOCK_LOCKED_PLAYER_INSIDE
    { "LOCKED INITIALLY" }, --VEHICLELOCK_LOCKED_INITIALLY
    { "强制关闭车门" }, --VEHICLELOCK_FORCE_SHUT_DOORS
    { "上锁但可被破坏", {}, "可以破开车窗开门" }, --VEHICLELOCK_LOCKED_BUT_CAN_BE_DAMAGED
    { "上锁但后备箱解锁" }, --VEHICLELOCK_LOCKED_BUT_BOOT_UNLOCKED
    { "上锁无乘客" }, --VEHICLELOCK_LOCKED_NO_PASSENGERS
    { "不能进入", {}, "按F无上车动作" } --VEHICLELOCK_CANNOT_ENTER
}
local vehicle_door_lock_select = 1 --选择的锁门类型
menu.list_select(Vehicle_DoorLock_options, "锁门类型", {}, "", VehicleDoorsLock_ListItem, 1, function(value)
    vehicle_door_lock_select = value
end)

menu.action(Vehicle_DoorLock_options, "设置载具门锁状态", {}, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle, vehicle_door_lock_select)
    end
end)
menu.slider_text(Vehicle_DoorLock_options, "设置单个门锁状态", {}, "貌似无效", { "左前门", "右前门",
    "左后门",
    "右后门" }, function(value)
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        VEHICLE.SET_VEHICLE_INDIVIDUAL_DOORS_LOCKED(vehicle, value - 1, vehicle_door_lock_select)
    end
end)

menu.toggle(Vehicle_DoorLock_options, "对所有玩家锁门", {}, "", function(toggle)
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(vehicle, toggle)
    end
end)


----- 载具车灯 -----
local Vehicle_Light_options = menu.list(Vehicle_options, "载具车灯", {}, "")

local VehicleLightState_ListItem = {
    { "正常", {}, "车辆正常开灯，关闭，然后是近光灯，远光灯" }, --0
    { "总是关闭", {}, "不会开灯" }, --1
    { "总是开启", {}, "总是开灯" } --2
}
menu.list_action(Vehicle_Light_options, "设置车灯状态", {}, "", VehicleLightState_ListItem, function(value)
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        VEHICLE.SET_VEHICLE_LIGHTS(vehicle, value - 1)
    end
end)

menu.toggle(Vehicle_Light_options, "车灯不会损坏", {}, "", function(toggle)
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        VEHICLE.SET_VEHICLE_HAS_UNBREAKABLE_LIGHTS(vehicle, toggle)
    end
end)


----- 载具电台 -----
local Vehicle_Radio_options = menu.list(Vehicle_options, "载具电台", {}, "")

-- 载具电台 Labels
local Vehicle_Radio_Stations = {
    "RADIO_11_TALK_02", -- Blaine County Radio
    "RADIO_12_REGGAE", -- The Blue Ark
    "RADIO_13_JAZZ", -- Worldwide FM
    "RADIO_14_DANCE_02", -- FlyLo FM
    "RADIO_15_MOTOWN", -- The Lowdown 9.11
    "RADIO_20_THELAB", -- The Lab
    "RADIO_16_SILVERLAKE", -- Radio Mirror Park
    "RADIO_17_FUNK", -- Space 103.2
    "RADIO_18_90S_ROCK", -- Vinewood Boulevard Radio
    "RADIO_21_DLC_XM17", -- Blonded Los Santos 97.8 FM
    "RADIO_22_DLC_BATTLE_MIX1_RADIO", -- Los Santos Underground Radio
    "RADIO_23_DLC_XM19_RADIO", -- iFruit Radio
    "RADIO_19_USER", -- Self Radio
    "RADIO_01_CLASS_ROCK", -- Los Santos Rock Radio
    "RADIO_02_POP", -- Non-Stop-Pop FM
    "RADIO_03_HIPHOP_NEW", -- Radio Los Santos
    "RADIO_04_PUNK", -- Channel X
    "RADIO_05_TALK_01", -- West Coast Talk Radio
    "RADIO_06_COUNTRY", -- Rebel Radio
    "RADIO_07_DANCE_01", -- Soulwax FM
    "RADIO_08_MEXICAN", -- East Los FM
    "RADIO_09_HIPHOP_OLD", -- West Coast Classics
    "RADIO_36_AUDIOPLAYER", -- Media Player
    "RADIO_35_DLC_HEI4_MLR", -- The Music Locker
    "RADIO_34_DLC_HEI4_KULT", -- Kult FM
    "RADIO_27_DLC_PRHEI4", -- Still Slipping Los Santos
}
local VehicleRadio_ListItem = { { "关闭", {}, "OFF" } }
for k, name in pairs(Vehicle_Radio_Stations) do
    local temp = { "", {}, "" }
    temp[1] = util.get_label_text(name)
    temp[3] = name
    table.insert(VehicleRadio_ListItem, temp)
end

local vehicle_radio_station_select = 1
menu.list_select(Vehicle_Radio_options, "选择电台", {}, "", VehicleRadio_ListItem, 1, function(value)
    vehicle_radio_station_select = value
end)
menu.toggle_loop(Vehicle_Radio_options, "自动更改电台", {}, "当你进入一辆载具时，更改载具的电台",
    function()
        if PED.IS_PED_GETTING_INTO_A_VEHICLE(players.user_ped()) then
            local veh = PED.GET_VEHICLE_PED_IS_ENTERING(players.user_ped())
            if veh then
                local stationName = VehicleRadio_ListItem[vehicle_radio_station_select][3]
                AUDIO.SET_VEH_RADIO_STATION(veh, stationName)
            end
        end
    end)
menu.toggle(Vehicle_Radio_options, "关闭电台", {}, "关闭后当前载具将无法选择更改电台",
    function(toggle)
        local vehicle = entities.get_user_vehicle_as_handle()
        if vehicle then
            AUDIO.SET_VEHICLE_RADIO_ENABLED(vehicle, not toggle)
        end
    end)


----- 个人载具 -----
local Vehicle_Personal_options = menu.list(Vehicle_options, "个人载具", {}, "")
menu.action(Vehicle_Personal_options, "打开引擎和左车门", {}, "", function()
    local vehicle = entities.get_user_personal_vehicle_as_handle()
    if vehicle then
        VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, false)
        VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, 0, false, false)
    end
end)
menu.action(Vehicle_Personal_options, "开启载具引擎", { "veh_engine_on" }, "个人载具和上一辆载具",
    function()
        local vehicle = entities.get_user_personal_vehicle_as_handle()
        if vehicle then
            VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, false)
        end

        local last_vehicle = entities.get_user_vehicle_as_handle()
        if last_vehicle and last_vehicle ~= vehicle then
            VEHICLE.SET_VEHICLE_ENGINE_ON(last_vehicle, true, true, false)
        end
    end)
menu.action(Vehicle_Personal_options, "打开左车门", {}, "", function()
    local vehicle = entities.get_user_personal_vehicle_as_handle()
    if vehicle then
        VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, 0, false, false)
    end
end)
menu.action(Vehicle_Personal_options, "打开左右车门", {}, "", function()
    local vehicle = entities.get_user_personal_vehicle_as_handle()
    if vehicle then
        VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, 0, false, false)
        VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, 1, false, false)
    end
end)
menu.list_action(Vehicle_Personal_options, "传送到附近", { "veh_tp_near" }, "会传送在路边等位置", {
    { "上一辆载具", { "last" } },
    { "个人载具", { "personal" } }
}, function(value)
    local vehicle = 0
    if not PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
        vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), true)
    end
    if value == 2 then
        vehicle = entities.get_user_personal_vehicle_as_handle()
    end
    if vehicle then
        local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        local bool, coords, heading = Get_Closest_Vehicle_Node(pos, 0)
        if bool then
            ENTITY.SET_ENTITY_COORDS(vehicle, coords.x, coords.y, coords.z, true, false, false, false)
            ENTITY.SET_ENTITY_HEADING(vehicle, heading)
            Fix_Vehicle(vehicle)
            VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(vehicle, 5.0)
            VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, false)
            --show blip
            SHOW_BLIP_TIMER(vehicle, 225, 27, 5000)
        else
            util.toast("未找到合适位置")
        end
    end
end)



----- 载具武器 -----
local Vehicle_Weapon_options = menu.list(Vehicle_options, "载具武器", {}, "")

local veh_weapon_data = {
    delay = 100,
    direction = {
        [1] = true, -- front
        [2] = false, -- rear
        [3] = false, -- left
        [4] = false, -- right
        [5] = false, -- up
        [6] = false, -- down
    },

    weapon_select = 1,
    weapon_hash = "PLAYER_WEAPON",
    vehicle_weapon_hash = "VEHICLE_WEAPON",

    is_owned = false,
    damage = 1000,
    speed = 1000,
    CreateTraceVfx = true,
    AllowRumble = true,
    PerfectAccuracy = false,
    start_offset = {
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
    }
}

local function get_middle_num(a, b)
    local min = math.min(a, b)
    local max = math.max(a, b)
    local middle = min + (max - min) * 0.5
    return middle
end

local function Vehicle_Weapon_Shoot(vehicle, direction, state)
    local weaponHash = veh_weapon_data.weapon_hash
    if veh_weapon_data.weapon_select == 2 then
        weaponHash = veh_weapon_data.vehicle_weapon_hash
    end

    if weaponHash == "PLAYER_WEAPON" then
        local pWeapon = memory.alloc_int()
        WEAPON.GET_CURRENT_PED_WEAPON(user_ped, pWeapon, true)
        weaponHash = memory.read_int(pWeapon)
    elseif weaponHash == "VEHICLE_WEAPON" then
        local pWeapon = memory.alloc_int()
        WEAPON.GET_CURRENT_PED_VEHICLE_WEAPON(user_ped, pWeapon)
        weaponHash = memory.read_int(pWeapon)
    end
    if not WEAPON.HAS_WEAPON_ASSET_LOADED(weaponHashHash) then
        Request_Weapon_Asset(weaponHash)
    end

    local owner = 0
    if veh_weapon_data.is_owned then
        owner = players.user_ped()
    end

    local min, max = v3.new(), v3.new()
    MISC.GET_MODEL_DIMENSIONS(ENTITY.GET_ENTITY_MODEL(vehicle), min, max)

    local offset_z = get_middle_num(min.z, max.z)
    local offsets = {}
    local start_offset, end_offset

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

    start_offset = v3.new(veh_weapon_data.start_offset[direction])
    end_offset:mul(500.0)

    local start_pos, end_pos
    for k, offset in pairs(offsets) do
        offset:add(start_offset)
        start_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(vehicle, offset.x, offset.y, offset.z)

        offset:add(end_offset)
        end_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(vehicle, offset.x, offset.y, offset.z)

        if state == "drawing_line" then
            DRAW_LINE(start_pos, end_pos)
        elseif state == "shoot" then
            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(start_pos.x, start_pos.y, start_pos.z,
                end_pos.x, end_pos.y, end_pos.z,
                veh_weapon_data.damage, veh_weapon_data.PerfectAccuracy, weaponHash, owner,
                veh_weapon_data.CreateTraceVfx, veh_weapon_data.AllowRumble, veh_weapon_data.speed,
                vehicle)
        end

    end
end

menu.toggle_loop(Vehicle_Weapon_options, "开启[按住E键]", { "veh_weapon" }, "", function()
    if PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) and PAD.IS_CONTROL_PRESSED(0, 51) then
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
        if vehicle then
            for k, v in pairs(veh_weapon_data.direction) do
                if v then
                    Vehicle_Weapon_Shoot(vehicle, k, "shoot")
                end
            end
            util.yield(veh_weapon_data.delay)
        end
    end
end)

menu.toggle_loop(Vehicle_Weapon_options, "绘制射击连线", {}, "", function()
    local vehicle = GET_VEHICLE_PED_IS_IN(players.user_ped())
    if vehicle then
        for k, v in pairs(veh_weapon_data.direction) do
            if v then
                Vehicle_Weapon_Shoot(vehicle, k, "drawing_line")
            end
        end
    end
end)
menu.divider(Vehicle_Weapon_options, "设置")
menu.slider(Vehicle_Weapon_options, "循环延迟", { "veh_weapon_delay" }, "单位: ms", 0, 5000, 100, 10,
    function(value)
        veh_weapon_data.delay = value
    end)

local Vehicle_Weapon_direction = menu.list(Vehicle_Weapon_options, "方向", {}, "")
for k, v in pairs({ "前", "后", "左", "右", "上", "下" }) do
    menu.toggle(Vehicle_Weapon_direction, v, {}, "", function(toggle)
        veh_weapon_data.direction[k] = toggle
    end, veh_weapon_data.direction[k])
end

local Vehicle_Weapon_select = menu.list(Vehicle_Weapon_options, "武器", {}, "")
menu.list_select(Vehicle_Weapon_select, "武器类型", {}, "", { { "手持武器" }, { "载具武器" } }, 1,
    function(value)
        veh_weapon_data.weapon_select = value
    end)
menu.list_select(Vehicle_Weapon_select, "手持武器", {}, "", AllWeapons_NoMelee_ListItem, 1, function(value)
    veh_weapon_data.weapon_hash = AllWeapons_NoMelee_ListItem[value][3]
end)
menu.list_select(Vehicle_Weapon_select, "载具武器", {}, "", All_VehicleWeapons_ListItem, 1, function(value)
    veh_weapon_data.vehicle_weapon_hash = All_VehicleWeapons_ListItem[value][3]
end)

menu.toggle(Vehicle_Weapon_options, "署名射击", {}, "以玩家名义", function(toggle)
    veh_weapon_data.is_owned = toggle
end)
menu.slider(Vehicle_Weapon_options, "伤害", { "veh_weapon_damage" }, "", 0, 10000, 1000, 100,
    function(value)
        veh_weapon_data.damage = value
    end)
menu.slider(Vehicle_Weapon_options, "速度", { "veh_weapon_speed" }, "", 0, 10000, 1000, 100,
    function(value)
        veh_weapon_data.speed = value
    end)
menu.toggle(Vehicle_Weapon_options, "Create Trace Vfx", {}, "", function(toggle)
    veh_weapon_data.CreateTraceVfx = toggle
end, true)
menu.toggle(Vehicle_Weapon_options, "Allow Rumble", {}, "", function(toggle)
    veh_weapon_data.AllowRumble = toggle
end, true)
menu.toggle(Vehicle_Weapon_options, "Perfect Accuracy", {}, "", function(toggle)
    veh_weapon_data.PerfectAccuracy = toggle
end)
local Vehicle_Weapon_startOffset = menu.list(Vehicle_Weapon_options, "起始射击位置偏移", {}, "")
for k, v in pairs({ "前", "后", "左", "右", "上", "下" }) do
    local menu_list = menu.list(Vehicle_Weapon_startOffset, v, {}, "")

    menu.slider_float(menu_list, "X", { "veh_weapon_dir" .. k .. "_x" }, "", -10000, 10000,
        veh_weapon_data.start_offset[k].x * 100, 10,
        function(value)
            value = value * 0.01
            veh_weapon_data.start_offset[k].x = value
        end)
    menu.slider_float(menu_list, "Y", { "veh_weapon_dir" .. k .. "_y" }, "", -10000, 10000,
        veh_weapon_data.start_offset[k].y * 100, 10,
        function(value)
            value = value * 0.01
            veh_weapon_data.start_offset[k].y = value
        end)
    menu.slider_float(menu_list, "Z", { "veh_weapon_dir" .. k .. "_z" }, "", -10000, 10000,
        veh_weapon_data.start_offset[k].z * 100, 10,
        function(value)
            value = value * 0.01
            veh_weapon_data.start_offset[k].z = value
        end)
end




----------
local veh_dirt_level = 0.0
menu.click_slider(Vehicle_options, "载具灰尘程度", { "veh_dirt_level" }, "载具全身灰尘程度", 0.0, 15.0, 0.0
    , 1.0,
    function(value)
        veh_dirt_level = value
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
        if vehicle then
            VEHICLE.SET_VEHICLE_DIRT_LEVEL(vehicle, veh_dirt_level)
        end
    end)
menu.toggle_loop(Vehicle_options, "锁定载具灰尘程度", {}, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        VEHICLE.SET_VEHICLE_DIRT_LEVEL(vehicle, veh_dirt_level)
    end
end)
menu.toggle_loop(Vehicle_options, "防弹轮胎", {}, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(vehicle, false)
    end
end)
menu.toggle_loop(Vehicle_options, "载具引擎快速开启", {}, "减少载具启动引擎时间", function()
    if PED.IS_PED_GETTING_INTO_A_VEHICLE(PLAYER.PLAYER_PED_ID()) then
        local veh = PED.GET_VEHICLE_PED_IS_ENTERING(PLAYER.PLAYER_PED_ID())
        if veh then
            VEHICLE.SET_VEHICLE_ENGINE_HEALTH(veh, 1000)
            VEHICLE.SET_VEHICLE_ENGINE_ON(veh, true, true, true)
        end
    end
end)
menu.toggle_loop(Vehicle_options, "解锁正在进入的载具", {}, "解锁你正在进入的载具,对于锁住的玩家载具也有效果。"
    , function()
    if PED.IS_PED_IN_ANY_VEHICLE(PLAYER.PLAYER_PED_ID(), false) then
        local v = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED(v, 1)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(v, false)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_PLAYER(v, PLAYER.PLAYER_ID(), false)
        VEHICLE.SET_VEHICLE_UNDRIVEABLE(v, false)
        ENTITY.FREEZE_ENTITY_POSITION(v, false)
    else
        local veh = PED.GET_VEHICLE_PED_IS_TRYING_TO_ENTER(PLAYER.PLAYER_PED_ID())
        if veh ~= 0 then
            if RequestControl(veh) then
                VEHICLE.SET_VEHICLE_DOORS_LOCKED(veh, 1)
                VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(veh, false)
                VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_PLAYER(veh, PLAYER.PLAYER_ID(), false)
                VEHICLE.SET_VEHICLE_HAS_BEEN_OWNED_BY_PLAYER(veh, false)
                VEHICLE.SET_VEHICLE_UNDRIVEABLE(veh, false)
                ENTITY.FREEZE_ENTITY_POSITION(veh, false)
            else
                util.toast("请求控制失败，请重试")
            end
        end
    end
end)
menu.toggle_loop(Vehicle_options, "禁用载具喇叭", {}, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        AUDIO.SET_HORN_ENABLED(vehicle, false)
    end
end, function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        AUDIO.SET_HORN_ENABLED(vehicle, true)
    end
end)




-----------------------------------
------------ 世界实体选项 -----------
-----------------------------------
require "RScripts.Menu.Entity_options"




--------------------------------
------------ 战局选项 ------------
--------------------------------
local Session_options = menu.list(menu.my_root(), "战局选项", {}, "")

----------------
-- 阻挡区域
----------------
local BlockArea_options = menu.list(Session_options, "阻挡区域", {}, "")

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
    }
}

local block_area_AreaData = {
    -- x, y, z
    {
        -- radar_car_mod_shop 72
        { 1174.7074, 2644.4497, 36.7552 },
        { 113.2615, 6624.2803, 30.7871 },
        { -354.5272, -135.4011, 38.1850 },
        { 724.5240, -1089.0811, 21.1692 },
        { -1147.3138, -1992.4344, 12.1803 },
    },
    {
        -- radar_gun_shop 110
        { 1697.9788, 3753.2002, 33.7053 },
        { -1111.2375, 2688.4626, 17.6131 },
        { 2569.6116, 302.5760, 107.7349 },
        { -325.8904, 6077.0264, 30.4548 },
        { 245.2711, -45.8126, 68.9410 },
        { 844.1248, -1025.5707, 27.1948 },
        { -1313.9485, -390.9637, 35.5920 },
        { -664.2178, -943.3646, 20.8292 },
        { -3165.2307, 1082.8551, 19.8438 },
    },
    {
        -- radar_shootingrange_gunshop 313
        { 17.6804, -1114.2880, 28.7970 },
        { 811.8699, -2149.1016, 28.6363 },
    },
    {
        -- radar_barber 71
        { 1933.1191, 3726.0791, 31.8444 },
        { -280.8165, 6231.7705, 30.6955 },
        { 1208.3335, -470.9170, 65.2080 },
        { -30.7448, -148.4921, 56.0765 },
        { -821.9946, -187.1776, 36.5689 },
        { 133.5702, -1710.9180, 28.2916 },
        { -1287.0822, -1116.5576, 5.9901 },
    },
    {
        -- radar_clothes_store 73
        { 80.6650, -1391.6694, 28.3761 },
        { 419.5310, -807.5787, 28.4896 },
        { -818.6218, -1077.5330, 10.3282 },
        { -158.2199, -304.9663, 38.7350 },
        { 126.6853, -212.5027, 53.5578 },
        { -715.3598, -155.7742, 36.4105 },
        { -1199.8092, -776.6886, 16.3237 },
        { -1455.0045, -233.1862, 48.7936 },
        { -3168.9663, 1055.2869, 19.8632 },
        { 618.1857, 2752.5667, 41.0881 },
        { -1094.0487, 2704.1707, 18.0873 },
        { 1197.9722, 2704.2205, 37.1572 },
        { 1687.8812, 4820.5498, 41.0096 },
        { -0.2361, 6516.0454, 30.8684 },
    },
    {
        -- radar_tattoo 75
        { -1153.9481, -1425.0186, 3.9544 },
        { 321.6098, 179.4165, 102.5865 },
        { 1322.4547, -1651.1252, 51.1885 },
        { -3169.4204, 1074.7272, 19.8343 },
        { 1861.6853, 3750.0798, 32.0318 },
        { -290.1603, 6199.0947, 30.4871 },
    },
    {
        -- radar_crim_holdups 52
        { 1965.0542, 3740.5552, 31.3448 },
        { 1394.1692, 3599.8601, 34.0121 },
        { 2682.0034, 3282.5432, 54.2411 },
        { 1698.8085, 4929.1978, 41.0783 },
        { 1166.3920, 2703.5042, 37.1573 },
        { 544.2802, 2672.8113, 41.1566 },
        { 1731.2098, 6411.4033, 34.0372 },
        { 2559.2471, 385.5266, 107.6230 },
        { 376.6533, 323.6471, 102.5664 },
        { 1159.5421, -326.6986, 67.9230 },
        { 1141.3596, -980.8802, 45.4155 },
        { -1822.2866, 788.0060, 137.1859 },
        { -711.7210, -916.6965, 18.2145 },
        { -1491.0565, -383.5728, 39.1706 },
        { 29.0641, -1349.2128, 28.5036 },
        { -1226.4644, -902.5864, 11.2783 },
        { -53.1240, -1756.4054, 28.4210 },
        { -3240.3169, 1004.4334, 11.8307 },
        { -3038.9082, 589.5187, 6.9048 },
        { -2973.2617, 390.8184, 14.0433 },
    }
}

menu.list_select(BlockArea_options, "选择区域", {}, "", block_area_data.area_ListItem, 1, function(value)
    block_area_data.setting.area = value
end)
menu.action(BlockArea_options, "阻挡", {}, "", function()
    local count = 0
    local hash = block_area_data.object_ListData[block_area_data.setting.obj][1]
    local Type = block_area_data.object_ListData[block_area_data.setting.obj][2]
    local ent = 0
    local area = block_area_AreaData[block_area_data.setting.area]

    Request_Model(hash)
    for k, pos in pairs(area) do
        if Type == "object" then
            ent = entities.create_object(hash, v3.new(pos[1], pos[2], pos[3] + 1.0))
        end

        if ENTITY.DOES_ENTITY_EXIST(ent) then
            ENTITY.FREEZE_ENTITY_POSITION(ent, block_area_data.setting.freeze)
            ENTITY.SET_ENTITY_VISIBLE(ent, block_area_data.setting.visible, 0)
            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ent, true, true)
            ENTITY.SET_ENTITY_INVINCIBLE(ent, true)
            Set_Entity_Networked(ent, false)
            count = count + 1
        end
    end

    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
    util.toast("阻挡完成！\n阻挡区域: " .. count .. " 个")
end)

-----
menu.divider(BlockArea_options, "设置")
menu.list_select(BlockArea_options, "阻挡物体", {}, "", block_area_data.object_ListItem, 1, function(value)
    block_area_data.setting.obj = value
end)
menu.toggle(BlockArea_options, "冻结", {}, "", function(toggle)
    block_area_data.setting.freeze = toggle
end, true)
menu.toggle(BlockArea_options, "可见", {}, "", function(toggle)
    block_area_data.setting.visible = toggle
end, true)


menu.action(Session_options, "停止观看", {}, "停止观看战局内其他玩家", function()
    local name = players.get_name(players.user())
    menu.trigger_commands("spectate" .. name .. ' on')
    util.yield(3000)
    menu.trigger_commands("spectate" .. name .. ' off')
end)





--------------------------------
------------ 保镖选项 ------------
--------------------------------
local Bodyguard_options = menu.list(menu.my_root(), "保镖选项", {}, "")

Relationship = {
    friendly_group = 0,
}

function Relationship:addGroup(GroupName)
    local ptr = memory.alloc_int()
    PED.ADD_RELATIONSHIP_GROUP(GroupName, ptr)
    local rel = memory.read_int(ptr)
    memory.free(ptr)
    return rel
end

function Relationship:friendly(ped)
    if not PED.DOES_RELATIONSHIP_GROUP_EXIST(Relationship.friendly_group) then
        Relationship.friendly_group = Relationship:addGroup("friendly_group")
        PED.SET_RELATIONSHIP_BETWEEN_GROUPS(0, Relationship.friendly_group, Relationship.friendly_group)
    end
    PED.SET_PED_RELATIONSHIP_GROUP_HASH(ped, Relationship.friendly_group)
end

Group = {}
function Group:getSize(ID)
    local unkPtr, sizePtr = memory.alloc(1), memory.alloc(1)
    PED.GET_GROUP_SIZE(ID, unkPtr, sizePtr)
    return memory.read_int(sizePtr)
end

function Group:pushMember(ped)
    local groupID = PLAYER.GET_PLAYER_GROUP(players.user())
    local RelationGroupHash = util.joaat("rgFM_AiLike_HateAiHate")

    if not PED.IS_PED_IN_GROUP(ped) then
        PED.SET_PED_AS_GROUP_MEMBER(ped, groupID)
        PED.SET_PED_NEVER_LEAVES_GROUP(ped, true)
    end
    PED.SET_PED_RELATIONSHIP_GROUP_HASH(ped, RelationGroupHash)
    PED.SET_GROUP_SEPARATION_RANGE(groupID, 9999.0)
    --PED.SET_GROUP_FORMATION_SPACING(groupID, v3(1.0, 0.9, 3.0))
    --PED.SET_GROUP_FORMATION(groupID, self.formation)
end

Bodyguard = {
    setting = {},
}

Bodyguard.npc = {
    --选择的保镖模型
    model_select = 1,
    --生成的保镖NPC list
    list = {},
    --生成的保镖NPC对应的menu list
    menu_list = {},
    --序号
    index = 1,
}

Bodyguard.heli = {
    --选择的直升机类型
    model_select = 1,
    --生成的保镖直升机 list
    list = {},
    --生成的保镖直升机里面的NPC list
    npc_list = {},
    --生成的保镖直升机对应的menu list
    menu_list = {},
    --序号
    index = 1,
}

--生成保镖NPC 默认设置
Bodyguard.setting.npc = {
    godmode = false,
    health = 1000,
    no_ragdoll = false,
    weapon = "WEAPON_MICROSMG",
    see_hear_range = 500,
    accuracy = 100,
    shoot_rate = 1000,
    combat_ability = 2,
    combat_range = 2,
    combat_movement = 1,
    target_loss_response = 1,
    fire_pattern = -957453492,
}

--生成保镖直升机 默认设置
Bodyguard.setting.heli = {
    godmode = false,
    health = 10000,
    Speed = 300,
    drivingStyle = 786603,
    CustomOffsets = -1.0,
    MinHeightAboveTerrain = 20,
    HeliMode = 0,
}

function Bodyguard.set_npc_attribute(ped)
    --INVINCIBLE
    ENTITY.SET_ENTITY_INVINCIBLE(ped, Bodyguard.setting.npc.godmode)
    ENTITY.SET_ENTITY_PROOFS(ped, Bodyguard.setting.npc.godmode, Bodyguard.setting.npc.godmode,
        Bodyguard.setting.npc.godmode,
        Bodyguard.setting.npc.godmode, Bodyguard.setting.npc.godmode, Bodyguard.setting.npc.godmode,
        Bodyguard.setting.npc.godmode,
        Bodyguard.setting.npc.godmode)
    --HEALTH
    ENTITY.SET_ENTITY_MAX_HEALTH(ped, Bodyguard.setting.npc.health)
    ENTITY.SET_ENTITY_HEALTH(ped, Bodyguard.setting.npc.health)
    --RAGDOLL
    PED.SET_PED_CAN_RAGDOLL(ped, not Bodyguard.setting.npc.no_ragdoll)
    PED.DISABLE_PED_INJURED_ON_GROUND_BEHAVIOUR(ped)
    PED.SET_PED_CAN_PLAY_AMBIENT_ANIMS(ped, false)
    PED.SET_PED_CAN_PLAY_AMBIENT_BASE_ANIMS(ped, false)
    --WEAPON
    local weapon_smoke = util.joaat("WEAPON_SMOKEGRENADE")
    WEAPON.GIVE_WEAPON_TO_PED(ped, weapon_smoke, -1, false, false)
    local weaponHash = util.joaat(Bodyguard.setting.npc.weapon)
    WEAPON.GIVE_WEAPON_TO_PED(ped, weaponHash, -1, false, true)
    WEAPON.SET_CURRENT_PED_WEAPON(ped, weaponHash, false)
    WEAPON.SET_PED_DROPS_WEAPONS_WHEN_DEAD(ped, false)
    PED.SET_PED_CAN_SWITCH_WEAPON(ped, true)
    WEAPON.SET_PED_INFINITE_AMMO_CLIP(ped, true)
    --PERCEPTIVE
    PED.SET_PED_SEEING_RANGE(ped, Bodyguard.setting.npc.see_hear_range)
    PED.SET_PED_HEARING_RANGE(ped, Bodyguard.setting.npc.see_hear_range)
    PED.SET_PED_ID_RANGE(ped, Bodyguard.setting.npc.see_hear_range)
    PED.SET_PED_VISUAL_FIELD_PERIPHERAL_RANGE(ped, Bodyguard.setting.npc.see_hear_range)
    PED.SET_PED_HIGHLY_PERCEPTIVE(ped, true)
    PED.SET_PED_VISUAL_FIELD_MIN_ANGLE(ped, 90.0)
    PED.SET_PED_VISUAL_FIELD_MAX_ANGLE(ped, 90.0)
    PED.SET_PED_VISUAL_FIELD_MIN_ELEVATION_ANGLE(ped, 90.0)
    PED.SET_PED_VISUAL_FIELD_MAX_ELEVATION_ANGLE(ped, 90.0)
    PED.SET_PED_VISUAL_FIELD_CENTER_ANGLE(ped, 90.0)
    --COMBAT
    PED.SET_PED_COMBAT_ABILITY(ped, Bodyguard.setting.npc.combat_ability)
    PED.SET_PED_COMBAT_RANGE(ped, Bodyguard.setting.npc.combat_range)
    PED.SET_PED_COMBAT_MOVEMENT(ped, Bodyguard.setting.npc.combat_movement)
    PED.SET_PED_TARGET_LOSS_RESPONSE(ped, Bodyguard.setting.npc.target_loss_response)
    --COMBAT ATTRIBUTES
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 4, true) --Can Use Dynamic Strafe Decisions
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 5, true) --Always Fight
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 6, false) --Flee Whilst In Vehicle
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 13, true) --Aggressive
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 14, true) --Can Investigate
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 17, false) --Always Flee
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 20, true) --Can Taunt In Vehicle
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 21, true) --Can Chase Target On Foot
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 22, true) --Will Drag Injured Peds to Safety
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 24, true) --Use Proximity Firing Rate
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 27, true) --Perfect Accuracy
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 28, true) --Can Use Frustrated Advance
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 29, true) --Move To Location Before Cover Search
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 38, true) --Disable Bullet Reactions
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 39, true) --Can Bust
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 41, true) --Can Commandeer Vehicles
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 42, true) --Can Flank
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true) --Can Fight Armed Peds When Not Armed
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 49, false) --Use Enemy Accuracy Scaling
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 52, true) --Use Vehicle Attack
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 53, true) --Use Vehicle Attack If Vehicle Has Mounted Guns
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 54, true) --Always Equip Best Weapon
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 55, true) --Can See Underwater Peds
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 58, true) --Disable Flee From Combat
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 60, true) --Can Throw Smoke Grenade
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 78, true) --Disable All Randoms Flee
    --FLEE ATTRIBUTES
    PED.SET_PED_FLEE_ATTRIBUTES(ped, 512, true) -- NEVER_FLEE
    --TASK
    TASK.SET_PED_PATH_CAN_USE_CLIMBOVERS(ped, true)
    TASK.SET_PED_PATH_CAN_USE_LADDERS(ped, true)
    TASK.SET_PED_PATH_CAN_DROP_FROM_HEIGHT(ped, true)
    TASK.SET_PED_PATH_AVOID_FIRE(ped, false)
    TASK.SET_PED_PATH_MAY_ENTER_WATER(ped, true)
end

function Bodyguard.generate_npc_menu(menu_parent, ped, index)
    Entity_Control.generate_menu(menu_parent, ped, index)
end

function Bodyguard.generate_heli_menu(menu_parent, heli, index)
    Entity_Control.generate_menu(menu_parent, heli, index)
end

------------------
----- 保镖NPC -----
------------------
local Bodyguard_NPC_options = menu.list(Bodyguard_options, "保镖NPC", {}, "")

local Bodyguard_NPC_name_ListItem = {
    { "富兰克林", {}, "" },
    { "麦克", {}, "" },
    { "崔佛", {}, "" },
    { "莱斯特", {}, "" },
    { "埃万保安", {}, "" },
    { "埃万重甲兵", {}, "" },
    { "越狱光头", {}, "" },
    { "吉米", {}, "麦克儿子" },
    { "崔西", {}, "麦克女儿" },
    { "阿曼达", {}, "麦克妻子" },
}
local Bodyguard_NPC_model_list = {
    "player_one",
    "player_zero",
    "player_two",
    "ig_lestercrest",
    "mp_m_avongoon",
    "u_m_y_juggernaut_01",
    "ig_rashcosvki",
    "ig_jimmydisanto",
    "ig_tracydisanto",
    "ig_amandatownley",
}

menu.list_select(Bodyguard_NPC_options, "选择模型", {}, "", Bodyguard_NPC_name_ListItem, 1
    , function(value)
    Bodyguard.npc.model_select = value
end)

menu.action(Bodyguard_NPC_options, "生成保镖", {}, "", function()
    local groupID = PLAYER.GET_PLAYER_GROUP(players.user())
    if Group:getSize(groupID) >= 7 then
        util.toast("保镖人数已达到上限")
    else
        local modelHash = util.joaat(Bodyguard_NPC_model_list[Bodyguard.npc.model_select])
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0.0, 2.0, 0.0)
        local heading = PLAYER_HEADING() + 180
        local ped = Create_Network_Ped(26, modelHash, coords.x, coords.y, coords.z, heading)
        --BLIP
        local blip = HUD.ADD_BLIP_FOR_ENTITY(ped)
        HUD.SET_BLIP_SPRITE(blip, 271)
        HUD.SET_BLIP_COLOUR(blip, 3)
        HUD.SET_BLIP_SCALE(blip, 0.5)

        Bodyguard.set_npc_attribute(ped)

        -- 添加进保镖小组
        Group:pushMember(ped)
        table.insert(Bodyguard.npc.list, ped)
        -- 创建对应的menu
        local index = Bodyguard.npc.index
        local menu_name = Bodyguard_NPC_name_ListItem[Bodyguard.npc.model_select][1]
        local menu_list = menu.list(Bodyguard_NPC_options, index .. ". " .. menu_name, {}, "")
        index = "bg" .. index
        Bodyguard.generate_npc_menu(menu_list, ped, index)
        table.insert(Bodyguard.npc.menu_list, menu_list)

        Bodyguard.npc.index = Bodyguard.npc.index + 1
    end
end)

menu.divider(Bodyguard_NPC_options, "管理保镖")

local Bodyguard_NPC_manage_all = menu.list(Bodyguard_NPC_options, "所有保镖", {}, "")
menu.toggle(Bodyguard_NPC_manage_all, "无敌", {}, "", function(toggle)
    for k, ent in pairs(Bodyguard.npc.list) do
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            ENTITY.SET_ENTITY_INVINCIBLE(ent, toggle)
            ENTITY.SET_ENTITY_PROOFS(ent, toggle, toggle, toggle, toggle, toggle, toggle, toggle, toggle)
        end
    end
end)
menu.list_action(Bodyguard_NPC_manage_all, "给予武器", {}, "", WeaponName_ListItem, function(value)
    for k, ent in pairs(Bodyguard.npc.list) do
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            local weaponHash = util.joaat(WeaponModel_List[value])
            WEAPON.GIVE_WEAPON_TO_PED(ent, weaponHash, -1, false, true)
            WEAPON.SET_CURRENT_PED_WEAPON(ent, weaponHash, false)
        end
    end
end)
menu.action(Bodyguard_NPC_manage_all, "传送到我", {}, "", function()
    local y = 2.0
    for k, ent in pairs(Bodyguard.npc.list) do
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            TP_TO_ME(ent, 0.0, y, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped(), 180.0)
            y = y + 1.0
        end
    end
end)
menu.action(Bodyguard_NPC_manage_all, "删除", {}, "", function()
    for k, ent in pairs(Bodyguard.npc.list) do
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            entities.delete_by_handle(ent)
        end
    end
    for k, v in pairs(Bodyguard.npc.menu_list) do
        if v ~= nil and menu.is_ref_valid(v) then
            menu.delete(v)
        end
    end
    Bodyguard.npc.list = {} --生成的保镖NPC list
    Bodyguard.npc.menu_list = {} --生成的保镖直升机对应的menu list
end)


--------------------
----- 保镖直升机 -----
--------------------
local Bodyguard_Heli_options = menu.list(Bodyguard_options, "保镖直升机", {}, "")

local Bodyguard_Heli_name_ListItem = {
    { "女武神" },
    { "秃鹰" },
    { "猎杀者" },
    { "警用小蛮牛" },
}
local Bodyguard_Heli_model_list = {
    "valkyrie", "buzzard", "hunter", "polmav"
}

menu.list_select(Bodyguard_Heli_options, "直升机类型", {}, "", Bodyguard_Heli_name_ListItem,
    1, function(value)
    Bodyguard.heli.model_select = value
end)

menu.action(Bodyguard_Heli_options, "生成保镖直升机", {}, "", function()
    local heli_hash = util.joaat(Bodyguard_Heli_model_list[Bodyguard.heli.model_select])
    local ped_hash = util.joaat("s_m_y_blackops_01")

    local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    pos.x = pos.x + math.random(-10, 10)
    pos.y = pos.y + math.random(-10, 10)
    pos.z = pos.z + 30

    local heli = Create_Network_Vehicle(heli_hash, pos.x, pos.y, pos.z, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
    --BLIP
    add_blip_for_entity(heli, 422, 26)
    --INVINCIBLE
    ENTITY.SET_ENTITY_INVINCIBLE(heli, Bodyguard.setting.heli.godmode)
    ENTITY.SET_ENTITY_PROOFS(heli, Bodyguard.setting.heli.godmode, Bodyguard.setting.heli.godmode,
        Bodyguard.setting.heli.godmode, Bodyguard.setting.heli.godmode, Bodyguard.setting.heli.godmode,
        Bodyguard.setting.heli.godmode, Bodyguard.setting.heli.godmode, Bodyguard.setting.heli.godmode)
    VEHICLE.SET_VEHICLE_CAN_BREAK(heli, Bodyguard.setting.heli.godmode)
    --HEALTH
    ENTITY.SET_ENTITY_MAX_HEALTH(heli, Bodyguard.setting.heli.health)
    ENTITY.SET_ENTITY_HEALTH(heli, Bodyguard.setting.heli.health)
    --BEHAVIOUR
    VEHICLE.SET_HELI_BLADES_FULL_SPEED(heli)
    VEHICLE.SET_VEHICLE_SEARCHLIGHT(heli, true, true)
    VEHICLE.SET_VEHICLE_HAS_UNBREAKABLE_LIGHTS(heli, true)
    VEHICLE.SET_HELI_TAIL_BOOM_CAN_BREAK_OFF(heli, true)

    table.insert(Bodyguard.heli.list, heli)

    Relationship:friendly(players.user_ped())

    ------
    local pilot = Create_Network_Ped(29, ped_hash, pos.x, pos.y, pos.z, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
    PED.SET_PED_INTO_VEHICLE(pilot, heli, -1)
    --PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(pilot, true)
    --TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(pilot, true)
    --TASK.TASK_HELI_MISSION(pilot, heli, 0, players.user_ped(), 0.0, 0.0, 0.0, 23, 80.0, 50.0, -1.0, 0, 10, -1.0, 0)
    TASK.TASK_VEHICLE_HELI_PROTECT(pilot, heli, players.user_ped(), Bodyguard.setting.heli.Speed,
        Bodyguard.setting.heli.drivingStyle, Bodyguard.setting.heli.CustomOffsets,
        Bodyguard.setting.heli.MinHeightAboveTerrain, Bodyguard.setting.heli.HeliMode)
    PED.SET_PED_KEEP_TASK(pilot, true)

    Bodyguard.set_npc_attribute(pilot)
    PED.SET_PED_CAN_BE_SHOT_IN_VEHICLE(pilot, false)
    PED.SET_PED_CAN_BE_KNOCKED_OFF_VEHICLE(pilot, 1)

    Relationship:friendly(pilot)
    table.insert(Bodyguard.heli.npc_list, pilot)

    ------
    local seats = VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(heli_hash) - 2
    for seat = 0, seats do
        local ped = Create_Network_Ped(29, ped_hash, pos.x, pos.y, pos.z, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
        PED.SET_PED_INTO_VEHICLE(ped, heli, seat)

        Bodyguard.set_npc_attribute(ped)
        PED.SET_PED_CAN_BE_SHOT_IN_VEHICLE(ped, false)
        PED.SET_PED_CAN_BE_KNOCKED_OFF_VEHICLE(ped, 1)

        Relationship:friendly(ped)
        table.insert(Bodyguard.heli.npc_list, ped)
    end

    -- 创建对应的menu
    local index = Bodyguard.heli.index
    local menu_name = Bodyguard_Heli_name_ListItem[Bodyguard.heli.model_select][1]
    local menu_list = menu.list(Bodyguard_Heli_options, index .. ". " .. menu_name, {}, "")
    index = "bgh" .. index
    Bodyguard.generate_heli_menu(menu_list, heli, index)
    table.insert(Bodyguard.heli.menu_list, menu_list)

    Bodyguard.heli.index = Bodyguard.heli.index + 1
end)

menu.divider(Bodyguard_Heli_options, "管理保镖直升机")

local Bodyguard_Heli_manage_all = menu.list(Bodyguard_Heli_options, "所有保镖直升机", {}, "")
menu.toggle(Bodyguard_Heli_manage_all, "无敌", {}, "", function(toggle)
    for k, ent in pairs(Bodyguard.heli.npc_list) do
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            ENTITY.SET_ENTITY_INVINCIBLE(ent, toggle)
            ENTITY.SET_ENTITY_PROOFS(ent, toggle, toggle, toggle, toggle, toggle, toggle, toggle, toggle)

        end
    end
    for k, ent in pairs(Bodyguard.heli.list) do
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            ENTITY.SET_ENTITY_INVINCIBLE(ent, toggle)
            ENTITY.SET_ENTITY_PROOFS(ent, toggle, toggle, toggle, toggle, toggle, toggle, toggle, toggle)
            VEHICLE.SET_VEHICLE_CAN_BREAK(ent, toggle)
        end
    end
end)
menu.action(Bodyguard_Heli_manage_all, "传送到我", {}, "", function()
    for k, ent in pairs(Bodyguard.heli.list) do
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            TP_TO_ME(ent, math.random(-10, 10), math.random(-10, 10), 30)
        end
    end
end)
menu.action(Bodyguard_Heli_manage_all, "删除", {}, "", function()
    for k, ent in pairs(Bodyguard.heli.npc_list) do
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            entities.delete_by_handle(ent)
        end
    end
    for k, ent in pairs(Bodyguard.heli.list) do
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            entities.delete_by_handle(ent)
        end
    end
    for k, v in pairs(Bodyguard.heli.menu_list) do
        if v ~= nil and menu.is_ref_valid(v) then
            menu.delete(v)
        end
    end

    Bodyguard.heli.list = {} --生成的保镖直升机 list
    Bodyguard.heli.npc_list = {} --生成的保镖直升机里面的NPC list
    Bodyguard.heli.menu_list = {} --生成的保镖直升机对应的menu list
    Bodyguard.heli.index = 1
end)


----------------
----- 设置 ------
----------------
menu.divider(Bodyguard_options, "设置")

----- 保镖NPC -----
local Bodyguard_npc_setting = menu.list(Bodyguard_options, "保镖NPC 默认设置", {}, "")
menu.toggle(Bodyguard_npc_setting, "无敌", {}, "", function(toggle)
    Bodyguard.setting.npc.godmode = toggle
end)
menu.slider(Bodyguard_npc_setting, "生命", { "bodyguard_npc_health" }, "", 100, 30000, 1000, 100,
    function(value)
        Bodyguard.setting.npc.health = value
    end)
menu.toggle(Bodyguard_npc_setting, "不会摔倒", {}, "", function(toggle)
    Bodyguard.setting.npc.no_ragdoll = toggle
end)
menu.list_select(Bodyguard_npc_setting, "武器", {}, "", WeaponName_ListItem, 4, function(value)
    Bodyguard.setting.npc.weapon = WeaponModel_List[value]
end)
menu.divider(Bodyguard_npc_setting, "作战能力")
menu.slider(Bodyguard_npc_setting, "视力听觉范围", { "bodyguard_npc_see_hear_range" }, "", 10, 1000, 500,
    100, function(value)
    Bodyguard.setting.npc.see_hear_range = value
end)
menu.slider(Bodyguard_npc_setting, "精确度", { "bodyguard_npc_accuracy" }, "", 0, 100, 100, 10,
    function(value)
        Bodyguard.setting.npc.accuracy = value
    end)
menu.slider(Bodyguard_npc_setting, "射击频率", { "bodyguard_npc_shoot_rate" }, "", 0, 1000, 1000, 100,
    function(value)
        Bodyguard.setting.npc.shoot_rate = value
    end)
menu.list_select(Bodyguard_npc_setting, "作战技能", {}, "", { { "弱" }, { "普通" }, { "专业" } }, 3,
    function(value)
        Bodyguard.setting.npc.combat_ability = value - 1
    end)
menu.list_select(Bodyguard_npc_setting, "作战范围", {}, "", { { "近" }, { "中等" }, { "远" }, { "非常远" } }
    , 3, function(value)
    Bodyguard.setting.npc.combat_range = value - 1
end)
menu.list_select(Bodyguard_npc_setting, "作战走位", {}, "", { { "站立" }, { "防卫" }, { "会前进" },
    { "会后退" } }, 2, function(value)
    Bodyguard.setting.npc.combat_movement = value - 1
end)
menu.list_select(Bodyguard_npc_setting, "失去目标时反应", {}, "", { { "退出战斗" }, { "从不失去目标" },
    { "寻找目标" } }, 2, function(value)
    Bodyguard.setting.npc.target_loss_response = value - 1
end)
menu.list_select(Bodyguard_npc_setting, "射击模式", {}, "", Ped_FirePattern_ListItem, -957453492, function(value)
    Bodyguard.setting.npc.fire_pattern = value
end)

----- 保镖直升机 -----
local Bodyguard_heli_setting = menu.list(Bodyguard_options, "保镖直升机 默认设置", {}, "")
menu.toggle(Bodyguard_heli_setting, "无敌", {}, "", function(toggle)
    Bodyguard.setting.heli.godmode = toggle
end)
menu.slider(Bodyguard_heli_setting, "生命", { "bodyguard_heli_health" }, "", 100, 30000, 10000, 100,
    function(value)
        Bodyguard.setting.heli.health = value
    end)
menu.divider(Bodyguard_heli_setting, "任务设置")
menu.slider(Bodyguard_heli_setting, "速度", { "bodyguard_heli_Speed" }, "", 0, 10000, 300, 10,
    function(value)
        Bodyguard.setting.heli.Speed = value
    end)
menu.list_select(Bodyguard_heli_setting, "驾驶风格", {}, "", DrivingStyleName_ListItem, 1, function(value)
    Bodyguard.setting.heli.drivingStyle = DrivingStyle_List[value]
end)
menu.slider_float(Bodyguard_heli_setting, "Custom Offset", { "bodyguard_heli_CustomOffset" }, "", -100000, 100000, -100,
    10, function(value)
    Bodyguard.setting.heli.CustomOffsets = value
end)
menu.slider(Bodyguard_heli_setting, "地面上的最小高度", { "bodyguard_heli_MinHeightAboveTerrain" }, "", 0, 10000
    , 20, 1,
    function(value)
        Bodyguard.setting.heli.MinHeightAboveTerrain = value
    end)
menu.list_select(Bodyguard_heli_setting, "直升机模式", {}, "", HeliMode_ListItem, 0, function(value)
    Bodyguard.setting.heli.HeliMode = value
end)





--------------------------------
------------ 保护选项 ------------
--------------------------------
local Protect_options = menu.list(menu.my_root(), "保护选项", {}, "")

menu.toggle_loop(Protect_options, "移除爆炸", {}, "范围: 10", function()
    local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    FIRE.STOP_FIRE_IN_RANGE(pos.x, pos.y, pos.z, 10.0)
    FIRE.STOP_ENTITY_FIRE(players.user_ped())
end)
menu.toggle_loop(Protect_options, "移除粒子效果", {}, "范围: 10", function()
    local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    GRAPHICS.REMOVE_PARTICLE_FX_IN_RANGE(pos.x, pos.y, pos.z, 10.0)
    GRAPHICS.REMOVE_PARTICLE_FX_FROM_ENTITY(players.user_ped())
end)
menu.toggle_loop(Protect_options, "移除黏弹和感应地雷", {}, "", function()
    local weaponHash = util.joaat("WEAPON_PROXMINE")
    WEAPON.REMOVE_ALL_PROJECTILES_OF_TYPE(weaponHash, false)
    weaponHash = util.joaat("WEAPON_STICKYBOMB")
    WEAPON.REMOVE_ALL_PROJECTILES_OF_TYPE(weaponHash, false)
end)
menu.toggle_loop(Protect_options, "移除防空区域", {}, "", function()
    WEAPON.REMOVE_ALL_AIR_DEFENCE_SPHERES()
end)
menu.toggle_loop(Protect_options, "移除载具上的黏弹", {}, "", function()
    local vehicle = GET_VEHICLE_PED_IS_IN(players.user_ped())
    if vehicle then
        NETWORK.REMOVE_ALL_STICKY_BOMBS_FROM_ENTITY(vehicle)
    end
end)
menu.toggle_loop(Protect_options, "停止所有声音", {}, "", function()
    for i = 0, 99 do
        AUDIO.STOP_SOUND(i)
    end
end)




--------------------------------
------------ 任务选项 -----------
--------------------------------
require "RScripts.Menu.Mission_options"






--------------------------------
------------ 其它选项 -----------
--------------------------------
local Other_options = menu.list(menu.my_root(), "其它选项", {}, "")

Dev_options = menu.list(Other_options, "开发者选项", {}, "")
require "RScripts.Menu.Dev_options"


------------------
--- 零食护甲编辑 ---
------------------
local Other_options_SnackArmour = menu.list(Other_options, "零食护甲编辑", {}, "")

menu.action(Other_options_SnackArmour, "补满全部零食", {}, "", function()
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
menu.action(Other_options_SnackArmour, "补满全部护甲", {}, "", function()
    STAT_SET_INT("MP_CHAR_ARMOUR_1_COUNT", 10)
    STAT_SET_INT("MP_CHAR_ARMOUR_2_COUNT", 10)
    STAT_SET_INT("MP_CHAR_ARMOUR_3_COUNT", 10)
    STAT_SET_INT("MP_CHAR_ARMOUR_4_COUNT", 10)
    STAT_SET_INT("MP_CHAR_ARMOUR_5_COUNT", 10)
    util.toast("完成！")
end)
menu.action(Other_options_SnackArmour, "补满呼吸器", {}, "", function()
    STAT_SET_INT("BREATHING_APPAR_BOUGHT", 20)
    util.toast("完成！")
end)

menu.divider(Other_options_SnackArmour, "零食")
menu.click_slider(Other_options_SnackArmour, "PQ豆", { "snack_yum" }, "+15 Health", 0, 999, 30, 1, function(value)
    STAT_SET_INT("NO_BOUGHT_YUM_SNACKS", value)
    util.toast("完成！")
end)
menu.click_slider(Other_options_SnackArmour, "宝力旺", { "snack_health" }, "+45 Health", 0, 999, 15, 1,
    function(value)
        STAT_SET_INT("NO_BOUGHT_HEALTH_SNACKS", value)
        util.toast("完成！")
    end)
menu.click_slider(Other_options_SnackArmour, "麦提来", { "snack_epic" }, "+30 Health", 0, 999, 5, 1,
    function(value)
        STAT_SET_INT("NO_BOUGHT_EPIC_SNACKS", value)
        util.toast("完成！")
    end)
menu.click_slider(Other_options_SnackArmour, "易可乐", { "snack_orange" }, "+36 Health", 0, 999, 10, 1,
    function(value)
        STAT_SET_INT("NUMBER_OF_ORANGE_BOUGHT", value)
        util.toast("完成！")
    end)
menu.click_slider(Other_options_SnackArmour, "尿汤啤", { "snack_bourge" }, "", 0, 999, 10, 1, function(value)
    STAT_SET_INT("NUMBER_OF_BOURGE_BOUGHT", value)
    util.toast("完成！")
end)
menu.click_slider(Other_options_SnackArmour, "蓝醉香槟", { "snack_champ" }, "", 0, 999, 5, 1, function(value)
    STAT_SET_INT("NUMBER_OF_CHAMP_BOUGHT", value)
    util.toast("完成！")
end)
menu.click_slider(Other_options_SnackArmour, "香烟", { "snack_cigarettes" }, "-5 Health", 0, 999, 20, 1,
    function(value)
        STAT_SET_INT("CIGARETTES_BOUGHT", value)
        util.toast("完成！")
    end)
menu.click_slider(Other_options_SnackArmour, "霜碧", { "snack_sprunk" }, "+36 Health", 0, 999, 10, 1,
    function(value)
        STAT_SET_INT("NUMBER_OF_SPRUNK_BOUGHT", value)
        util.toast("完成！")
    end)


--------------------
----- 标记点选项 -----
--------------------
local Blip_options = menu.list(Other_options, "标记点选项", {}, "")

------------------
-- 地图全部标记点
------------------
local Blip_all = menu.list(Blip_options, "地图全部标记点", {}, "")

local blip_count = 0 -- 获取到的标记点数量
local blip_menu_list = {} -- 标记点列表 menu.list

local function Init_blip_menu_list()
    if next(blip_menu_list) ~= nil then
        for k, v in pairs(blip_menu_list) do
            if v ~= nil and menu.is_ref_valid(v) then
                menu.delete(v)
            end
        end
    end
    menu.set_menu_name(Blip_all_divider, "标记点列表")
    blip_count = 0
    blip_menu_list = {} -- menu.list
end

local function generate_blip_menu(menu_parent, blip)
    menu.divider(menu_parent, menu.get_menu_name(menu_parent))

    local sprite = HUD.GET_BLIP_SPRITE(blip)
    local blip_type = GET_BLIP_TYPE(blip)

    ----- 信息显示 -----
    local readonly_menu_list = {}
    local blip_info = menu.list(menu_parent, "查看标记点信息", {}, "")
    menu.readonly(blip_info, "Sprite", sprite)
    readonly_menu_list[1] = menu.readonly(blip_info, "Type", HUD.GET_BLIP_INFO_ID_TYPE(blip))
    readonly_menu_list[2] = menu.readonly(blip_info, "Colour")
    readonly_menu_list[3] = menu.readonly(blip_info, "HUD Colour")
    readonly_menu_list[4] = menu.readonly(blip_info, "Display")
    readonly_menu_list[5] = menu.readonly(blip_info, "Rotation")
    menu.divider(blip_info, "Coords")
    readonly_menu_list[6] = menu.readonly(blip_info, "X")
    readonly_menu_list[7] = menu.readonly(blip_info, "Y")
    readonly_menu_list[8] = menu.readonly(blip_info, "Z")

    menu.on_tick_in_viewport(readonly_menu_list[1], function()
        if HUD.DOES_BLIP_EXIST(blip) then
            menu.set_value(readonly_menu_list[2], HUD.GET_BLIP_COLOUR(blip))
            menu.set_value(readonly_menu_list[3], HUD.GET_BLIP_HUD_COLOUR(blip))
            menu.set_value(readonly_menu_list[4], HUD.GET_BLIP_INFO_ID_DISPLAY(blip))
            menu.set_value(readonly_menu_list[5], HUD.GET_BLIP_ROTATION(blip))
            local coords = HUD.GET_BLIP_COORDS(blip)
            menu.set_value(readonly_menu_list[6], coords.x)
            menu.set_value(readonly_menu_list[7], coords.y)
            menu.set_value(readonly_menu_list[8], coords.z)
        end
    end)

    ----- 标记点设置 -----
    local blip_setting = menu.list(menu_parent, "标记点设置", {}, "")
    menu.click_slider(blip_setting, "Set Sprite", { "set_blip" .. sprite .. "sprite" }, "", 0, 826, sprite, 1,
        function(value)
            HUD.SET_BLIP_SPRITE(blip, value)
        end)
    menu.click_slider(blip_setting, "Set Colour", { "set_blip" .. sprite .. "colour" }, "", 0, 85,
        HUD.GET_BLIP_HUD_COLOUR(blip), 1,
        function(value)
            HUD.SET_BLIP_COLOUR(blip, value)
        end)
    menu.list_select(blip_setting, "Set Display", {}, "", Blip_DisplayID_ListItem, HUD.GET_BLIP_INFO_ID_DISPLAY(blip) + 1
        , function(value)
        HUD.SET_BLIP_DISPLAY(blip, value - 1)
    end)
    menu.toggle(blip_setting, "Flashs", {}, "", function(toggle)
        HUD.SET_BLIP_FLASHES(blip, toggle)
    end, HUD.IS_BLIP_FLASHING(blip))
    menu.toggle(blip_setting, "Set As Short Range", {},
        "Sets whether or not the specified blip should only be displayed when nearby, or on the minimap.",
        function(toggle)
            HUD.SET_BLIP_AS_SHORT_RANGE(blip, toggle)
        end, HUD.IS_BLIP_SHORT_RANGE(blip))
    menu.slider_text(blip_setting, "Set Friendly", {}, "", { "Friendly", "Enemy" }, function(value)
        local toggle = true
        if value == 2 then
            toggle = false
        end
        HUD.SET_BLIP_AS_FRIENDLY(blip, toggle)
    end)
    menu.toggle(blip_setting, "Set Radius Edge", {}, "Enabling this on a radius blip will make it outline only.",
        function(toggle)
            HUD.SET_RADIUS_BLIP_EDGE(blip, toggle)
        end)
    menu.click_slider_float(blip_setting, "Set Scale", { "set_blip" .. sprite .. "scale" }, "", 0, 1000, 100, 10,
        function(value)
            HUD.SET_BLIP_SCALE(blip, value * 0.01)
        end)
    menu.toggle(blip_setting, "Show Height On Blip", {}, "", function(toggle)
        HUD.SHOW_HEIGHT_ON_BLIP(blip, toggle)
    end)


    menu.divider(menu_parent, "Type: " .. blip_type)

    ----- 传送选项 -----
    local teleport_options = menu.list(menu_parent, "传送", {}, "")
    local tp_offset = {
        x = 0.0,
        y = 2.0,
        z = 0.0
    }
    menu.slider_float(teleport_options, "前/后", { "blip" .. sprite .. "_tp_x" }, "", -5000, 5000, 200, 50,
        function(value)
            tp_offset.y = value * 0.01
        end)
    menu.slider_float(teleport_options, "上/下", { "blip" .. sprite .. "_tp_y" }, "", -5000, 5000, 0, 50,
        function(value)
            tp_offset.z = value * 0.01
        end)
    menu.slider_float(teleport_options, "左/右", { "blip" .. sprite .. "_tp_z" }, "", -5000, 5000, 0, 50,
        function(value)
            tp_offset.x = value * 0.01
        end)

    menu.action(teleport_options, "传送到标记点", {}, "直接传送到坐标", function()
        if not IS_BLIP_ENTITY(blip) then
            local pos = HUD.GET_BLIP_COORDS(blip)
            if pos ~= nil then
                TELEPORT(pos.x, pos.y, pos.z + 1.0)
            end
        else
            local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
            TP_TO_ENTITY(ent, tp_offset.x, tp_offset.y, tp_offset.z)
        end
    end)
    menu.action(teleport_options, "传送到标记点 (Safe)", {}, "会传送到地面", function()
        if not IS_BLIP_ENTITY(blip) then
            local pos = GET_BLIP_COORDS(blip)
            if pos ~= nil then
                TELEPORT(pos.x, pos.y, pos.z)
            end
        else
            local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
            TP_TO_ENTITY(ent, tp_offset.x, tp_offset.y, tp_offset.z)
        end
    end)
    menu.action(teleport_options, "传送到我", {}, "", function()
        if not IS_BLIP_ENTITY(blip) then
            util.toast("标记点不是实体，无法传送到我")
        else
            local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
            TP_TO_ME(ent, tp_offset.x, tp_offset.y, tp_offset.z)
        end
    end)

end

menu.action(Blip_all, "获取地图显示的全部标记点", {}, "重复的标记点只能获取到最近的一个",
    function()
        Init_blip_menu_list()

        for i = 0, 826, 1 do
            -- local blip = HUD.GET_FIRST_BLIP_INFO_ID(i)
            local blip = HUD.GET_CLOSEST_BLIP_INFO_ID(i)
            if HUD.DOES_BLIP_EXIST(blip) then
                local blip_name = All_Blips[i + 1]
                local blip_type = GET_BLIP_TYPE(blip)

                local menu_name = i .. ". " .. blip_name
                local help_text = "Type: " .. blip_type
                local menu_list = menu.list(Blip_all, menu_name, {}, help_text)
                generate_blip_menu(menu_list, blip)

                table.insert(blip_menu_list, menu_list)

                blip_count = blip_count + 1
                menu.set_menu_name(Blip_all_divider, "标记点列表 (" .. blip_count .. ")")
            end
        end

    end)

menu.action(Blip_all, "清空列表", {}, "", function()
    Init_blip_menu_list()
end)
Blip_all_divider = menu.divider(Blip_all, "标记点列表")



------------------
-- 自定义标记点
------------------
local Blip_custom = menu.list(Blip_options, "自定义标记点", {}, "")

local waypoint_blip_sprite = 8
menu.slider_text(Blip_custom, "标记点类型", {}, "点击应用修改\n只作用于第一个标记的大头针位置"
    , { "标记点位置", "大头针位置" }, function(value)
    if value == 1 then
        waypoint_blip_sprite = 8
    elseif value == 2 then
        waypoint_blip_sprite = 162
    end
end)

menu.toggle(Blip_custom, "在小地图上显示标记点", {}, "", function(toggle)
    local blip = HUD.GET_FIRST_BLIP_INFO_ID(waypoint_blip_sprite)
    if blip > 0 then
        if toggle then
            HUD.SET_BLIP_DISPLAY(blip, 2)
        else
            HUD.SET_BLIP_DISPLAY(blip, 3)
        end
    end
end)
menu.toggle(Blip_custom, "闪烁标记点", {}, "", function(toggle)
    local blip = HUD.GET_FIRST_BLIP_INFO_ID(waypoint_blip_sprite)
    if blip > 0 then
        HUD.SET_BLIP_FLASHES(blip, toggle)
    end
end)
menu.action(Blip_custom, "通知坐标", {}, "", function()
    local blip = HUD.GET_FIRST_BLIP_INFO_ID(waypoint_blip_sprite)
    if blip == 0 then
        util.toast("No Waypoint Found")
    else
        local pos = GET_BLIP_COORDS(blip)
        if pos ~= nil then
            local text = pos.x .. ", " .. pos.y .. ", " .. pos.z
            util.toast(text)
        end
    end
end)

menu.divider(Blip_custom, "在标记点位置")

local Waypoint_CreateVehicle = menu.list(Blip_custom, "生成载具", {}, "")
local Waypoint_Vehicle_ListItem = {
    --name, model, help_text
    { "警车", "police3", "" },
    { "坦克", "khanjali", "可汗贾利" },
    { "骷髅马", "kuruma2", "" },
    { "直升机", "polmav", "警用直升机" },
    { "摩托车", "bati", "801" },
}
for k, data in pairs(Waypoint_Vehicle_ListItem) do
    local name = "生成" .. data[1]
    menu.action(Waypoint_CreateVehicle, name, {}, data[3], function()
        local blip = HUD.GET_FIRST_BLIP_INFO_ID(waypoint_blip_sprite)
        if blip == 0 then
            util.toast("No Waypoint Found")
        else
            local pos = GET_BLIP_COORDS(blip)
            if pos ~= nil then
                local hash = util.joaat(data[2])
                local vehicle = Create_Network_Vehicle(hash, pos.x, pos.y, pos.z + 1.0, 0)
                if vehicle then
                    Upgrade_Vehicle(vehicle)
                    ENTITY.SET_ENTITY_INVINCIBLE(vehicle, true)
                    util.toast("Done!")
                end
            end
        end
    end)
end

local Waypoint_CreatePickup = menu.list(Blip_custom, "生成拾取物", {}, "")
local Waypoint_Pickup_ListItem = {
    --name, model, pickupHash, value
    { "医药包", "prop_ld_health_pack", 2406513688, 100 },
    { "护甲", "prop_armour_pickup", 1274757841, 100 },
    { "火神机枪", "W_MG_Minigun", 792114228, 100 },
}
for k, data in pairs(Waypoint_Pickup_ListItem) do
    local name = "生成" .. data[1]
    menu.action(Waypoint_CreatePickup, name, {}, "", function()
        local blip = HUD.GET_FIRST_BLIP_INFO_ID(waypoint_blip_sprite)
        if blip == 0 then
            util.toast("No Waypoint Found")
        else
            local pos = GET_BLIP_COORDS(blip)
            if pos ~= nil then
                local modelHash = util.joaat(data[2])
                local pickupHash = data[3]
                Create_Network_Pickup(pickupHash, pos.x, pos.y, pos.z, modelHash, data[4])
                util.toast("Done!")
            end
        end
    end)
end

local Waypoint_Explosion = menu.list(Blip_custom, "爆炸", {}, "")
local waypoint_explosion_type = 2
menu.list_select(Waypoint_Explosion, "爆炸类型", {}, "", ExplosionType_ListItem, 4, function(index)
    waypoint_explosion_type = index - 2
end)
menu.action(Waypoint_Explosion, "爆炸", {}, "", function()
    local blip = HUD.GET_FIRST_BLIP_INFO_ID(waypoint_blip_sprite)
    if blip == 0 then
        util.toast("No Waypoint Found")
    else
        local pos = GET_BLIP_COORDS(blip)
        if pos ~= nil then
            add_explosion(pos, waypoint_explosion_type)
        end
    end
end)

menu.action(Waypoint_Explosion, "RPG轰炸", {}, "以玩家的名义轰炸", function()
    local blip = HUD.GET_FIRST_BLIP_INFO_ID(waypoint_blip_sprite)
    if blip == 0 then
        util.toast("No Waypoint Found")
    else
        local pos = GET_BLIP_COORDS(blip)
        if pos ~= nil then
            local weaponHash = util.joaat("WEAPON_RPG")
            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z + 10.0, pos.x, pos.y, pos.z, 1000, false,
                weaponHash, players.user_ped(), true, false, 1000)
        end
    end
end)

-------------------
----- 请求服务 -----
-------------------
local Request_Service_options = menu.list(Other_options, "请求服务", {}, "")

menu.toggle_loop(Request_Service_options, "移除CEO技能费用和冷却时间", {}, "", function()
    for k, v in pairs(Globals.ceo_ability_list) do
        local g1 = 262145 + v.cost[1]
        SET_INT_GLOBAL(g1, 0)
        local g2 = 262145 + v.cooldown[1]
        SET_INT_GLOBAL(g2, 0)
    end
end, function()
    for k, v in pairs(Globals.ceo_ability_list) do
        local g1 = 262145 + v.cost[1]
        SET_INT_GLOBAL(g1, v.cost[2])
        local g2 = 262145 + v.cooldown[1]
        SET_INT_GLOBAL(g2, v.cooldown[2])
    end
end)
menu.toggle_loop(Request_Service_options, "移除CEO载具请求费用", {}, "", function()
    for k, v in pairs(Globals.ceo_vehicle_request_cost) do
        local g1 = 262145 + v[1]
        SET_INT_GLOBAL(g1, 0)
    end
end, function()
    for k, v in pairs(Globals.ceo_vehicle_request_cost) do
        local g1 = 262145 + v[1]
        SET_INT_GLOBAL(g1, v[2])
    end
end)

menu.action(Request_Service_options, "请求重型装甲", { "ammo_drop" }, "请求弹道装甲和火神机枪",
    function()
        SET_INT_GLOBAL(Globals.Ballistic_Armor, 1)
    end)
menu.action(Request_Service_options, "重型装甲包裹 传送到我", {}, "", function()
    local entity_model_hash = 1688540826
    for k, ent in pairs(entities.get_all_pickups_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            TP_TO_ME(ent, 0.0, 2.0, 0.0)
        end
    end
end)
menu.toggle(Request_Service_options, "请求RC坦克", {}, "", function(toggle)
    if toggle then
        SET_INT_GLOBAL(Globals.RC_Tank, 1)
    else
        SET_INT_GLOBAL(Globals.RC_Tank, 0)
    end
end)
menu.toggle(Request_Service_options, "请求RC匪徒", {}, "", function(toggle)
    if toggle then
        SET_INT_GLOBAL(Globals.RC_Bandito, 1)
    else
        SET_INT_GLOBAL(Globals.RC_Bandito, 0)
    end
end)

menu.divider(Request_Service_options, "无视犯罪")
menu.toggle_loop(Request_Service_options, "锁定倒计时", {}, "无视犯罪的倒计时", function()
    SET_INT_GLOBAL(Globals.NCOPS.time, NETWORK.GET_NETWORK_TIME())
    util.yield(5000)
end)
menu.action(Request_Service_options, "警察无视犯罪", { "no_cops" }, "莱斯特电话请求", function()
    SET_INT_GLOBAL(Globals.NCOPS.type, 5)
    SET_INT_GLOBAL(Globals.NCOPS.flag, 1)
    SET_INT_GLOBAL(Globals.NCOPS.time, NETWORK.GET_NETWORK_TIME())
end)
menu.click_slider(Request_Service_options, "贿赂当局 倒计时时间", {}, "单位:分钟", 1, 60, 2, 1,
    function(value)
        SET_INT_GLOBAL(Globals.GB_BRIBE_AUTHORITIES_DURATION, value * 60 * 1000)
        util.toast("Done!")
    end)
menu.toggle(Request_Service_options, "贿赂当局", {}, "CEO技能", function(toggle)
    if toggle then
        SET_INT_GLOBAL(Globals.NCOPS.type, 81)
        SET_INT_GLOBAL(Globals.NCOPS.flag, 1)
        SET_INT_GLOBAL(Globals.NCOPS.time, NETWORK.GET_NETWORK_TIME())
    else
        SET_INT_GLOBAL(Globals.NCOPS.time, 0)
    end
end)

menu.divider(Request_Service_options, "幽灵组织")
menu.click_slider(Request_Service_options, "倒计时时间", {}, "单位:分钟", 1, 60, 3, 1,
    function(value)
        SET_INT_GLOBAL(Globals.GB_GHOST_ORG_DURATION, value * 60 * 1000)
        util.toast("Done!")
    end)
-- menu.action(Request_Service_options, "幽灵组织", { "ghost_org" }, "CEO技能\n~Not Working~", function() end)

-------------------
----- 聊天选项 -----
-------------------
local Chat_options = menu.list(Other_options, "聊天选项", {}, "")

menu.toggle_loop(Chat_options, "打字时禁用来电电话", {}, "避免在打字时有电话把输入框挤掉",
    function()
        if chat.is_open() then
            menu.trigger_commands("nophonespam on")
        else
            menu.trigger_commands("nophonespam off")
        end
    end, function()
    menu.trigger_commands("nophonespam off")
end)

menu.divider(Chat_options, "记录打字输入内容")
local typing_text_list = {}
local typing_text_list_item = {}
local typing_text_now = ""
menu.toggle_loop(Chat_options, "开启", {}, "", function()
    if chat.is_open() then
        if chat.get_state() > 0 then
            typing_text_now = chat.get_draft()
        end
    else
        if typing_text_now ~= "" and not isInTable(typing_text_list, typing_text_now) then
            table.insert(typing_text_list, typing_text_now)

            local temp = newTableValue(1, typing_text_now)
            table.insert(typing_text_list_item, temp)
            typing_text_now = ""

            menu.set_list_action_options(typing_text_list_action, typing_text_list_item)
        end

    end
end)

menu.action(Chat_options, "清空记录内容", {}, "", function()
    typing_text_list = {}
    typing_text_list_item = {}
    typing_text_now = ""
    menu.set_list_action_options(typing_text_list_action, typing_text_list_item)
end)
local typing_text_send_to_team = false
menu.toggle(Chat_options, "发送到团队", {}, "", function(toggle)
    typing_text_send_to_team = toggle
end)
typing_text_list_action = menu.list_action(Chat_options, "查看记录内容", {}, "点击即可弹出输入框",
    typing_text_list_item, function(value)
    local text = typing_text_list_item[value][1]
    chat.ensure_open_with_empty_draft(typing_text_send_to_team)
    chat.add_to_draft(text)
end)


-----
menu.toggle_loop(Other_options, "跳到下一条对话", { "skip_talk" }, "快速跳过对话", function()
    if AUDIO.IS_SCRIPTED_CONVERSATION_ONGOING() then
        AUDIO.SKIP_TO_NEXT_SCRIPTED_CONVERSATION_LINE()
    end
end)
menu.action(Other_options, "停止对话", { "stop_talk" }, "", function()
    if AUDIO.IS_SCRIPTED_CONVERSATION_ONGOING() then
        AUDIO.STOP_SCRIPTED_CONVERSATION(false)
    end
end)
local simulate_left_click_delay = 50 --ms
menu.toggle_loop(Other_options, "模拟鼠标左键点击", { "left_click" }, "用于拿取目标财物时",
    function()
        PAD.SET_CONTROL_VALUE_NEXT_FRAME(0, 237, 1)
        util.yield(simulate_left_click_delay)
    end)
menu.slider(Other_options, "模拟点击延迟", { "delay_left_click" }, "单位: ms", 0, 5000, 50, 10,
    function(value)
        simulate_left_click_delay = value
    end)
menu.action(Other_options, "Clear Tick Handler", {}, "用于解决控制实体的描绘连线、显示信息、锁定传送等问题"
    , function()
    Clear_control_ent_tick_handler()
end)




--------------------------------
-------------- 关于 -------------
--------------------------------
local About_options = menu.list(menu.my_root(), "关于", {}, "")

menu.readonly(About_options, "Author", "Rostal")
menu.hyperlink(About_options, "Github", "https://github.com/TCRoid/Stand-Lua-RScript")
menu.readonly(About_options, "Version", Script_Version)
menu.readonly(About_options, "Support GTAO Version", Support_GTAO)


---------------------------------------------------------------





------------------------------------
------------ 玩家列表选项 ------------
------------------------------------

local PlayerFunctions = function(pId)
    local Player_MainMenu = menu.list(menu.player_root(pId), "RScript", {}, "")

    -----------------------------
    ---------- 恶搞选项 ----------
    -----------------------------
    local Trolling_options = menu.list(Player_MainMenu, "恶搞选项", {}, "")

    menu.action(Trolling_options, "小笼子", {}, "", function()
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        if not PED.IS_PED_IN_ANY_VEHICLE(player_ped) then
            local modelHash = util.joaat("prop_gold_cont_01")
            local pos = ENTITY.GET_ENTITY_COORDS(player_ped)
            local obj = Create_Network_Object(modelHash, pos.x, pos.y, pos.z - 1.0)
            ENTITY.FREEZE_ENTITY_POSITION(obj, true)
        end
    end)

    menu.action(Trolling_options, "小查攻击", {}, "", function()
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        local modelHash = util.joaat("A_C_Chop")
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0.0, -1.0, 0.0)
        local heading = ENTITY.GET_ENTITY_HEADING(player_ped)

        local g_ped = Create_Network_Ped(28, modelHash, coords.x, coords.y, coords.z, heading)

        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(g_ped, true)
        TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(g_ped, true)
        TASK.TASK_COMBAT_PED(g_ped, player_ped, 0, 16)
        PED.SET_PED_KEEP_TASK(g_ped, true)

        PED.SET_PED_MONEY(g_ped, 2000)
        ENTITY.SET_ENTITY_MAX_HEALTH(g_ped, 30000)
        ENTITY.SET_ENTITY_HEALTH(g_ped, 30000)

        Increase_Ped_Combat_Ability(g_ped, false, false)
        Increase_Ped_Combat_Attributes(g_ped)
    end)

    menu.action(Trolling_options, "载具内敌人攻击", {}, "", function()
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_ped, true)
        if vehicle then
            local modelHash = util.joaat("A_M_M_ACult_01")
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0.0, 0.0, 2.0)
            local heading = ENTITY.GET_ENTITY_HEADING(player_ped)

            local g_ped = Create_Network_Ped(26, modelHash, coords.x, coords.y, coords.z, heading)
            PED.SET_PED_INTO_VEHICLE(g_ped, vehicle, -2)

            PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(g_ped, true)
            TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(g_ped, true)
            TASK.TASK_COMBAT_PED(g_ped, player_ped, 0, 16)
            PED.SET_PED_KEEP_TASK(g_ped, true)

            PED.SET_PED_MONEY(g_ped, 2000)
            ENTITY.SET_ENTITY_MAX_HEALTH(g_ped, 30000)
            ENTITY.SET_ENTITY_HEALTH(g_ped, 30000)
            PED.SET_PED_CAN_BE_SHOT_IN_VEHICLE(g_ped, false)

            local weaponHash = util.joaat("WEAPON_MICROSMG")
            WEAPON.GIVE_WEAPON_TO_PED(g_ped, weaponHash, -1, false, true)
            WEAPON.SET_CURRENT_PED_WEAPON(g_ped, weaponHash, true)

            Increase_Ped_Combat_Ability(g_ped, false, false)
            Increase_Ped_Combat_Attributes(g_ped)
            PED.SET_PED_COMBAT_ATTRIBUTES(g_ped, 3, false) --CanLeaveVehicle
        else
            util.toast("未找到玩家的载具")
        end
    end)

    menu.action(Trolling_options, "生成敌人抢夺载具", {}, "", function()
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_ped, true)
        if vehicle then
            local modelHash = util.joaat("A_M_M_ACult_01")
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(vehicle, -2.0, 0.0, 0.0)
            local heading = ENTITY.GET_ENTITY_HEADING(player_ped)

            local g_ped = Create_Network_Ped(26, modelHash, coords.x, coords.y, coords.z, heading)

            PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(g_ped, true)
            TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(g_ped, true)
            TASK.TASK_COMBAT_PED(g_ped, player_ped, 0, 16)
            PED.SET_PED_KEEP_TASK(g_ped, true)

            PED.SET_PED_MONEY(g_ped, 2000)
            ENTITY.SET_ENTITY_MAX_HEALTH(g_ped, 30000)
            ENTITY.SET_ENTITY_HEALTH(g_ped, 30000)
            PED.SET_PED_CAN_BE_SHOT_IN_VEHICLE(g_ped, false)

            local weaponHash = util.joaat("WEAPON_MICROSMG")
            WEAPON.GIVE_WEAPON_TO_PED(g_ped, weaponHash, -1, false, true)
            WEAPON.SET_CURRENT_PED_WEAPON(g_ped, weaponHash, true)

            Increase_Ped_Combat_Ability(g_ped, false, false)
            Increase_Ped_Combat_Attributes(g_ped)

            TASK.TASK_ENTER_VEHICLE(g_ped, vehicle, -1, -1, 5.0, 16, 0)
            TASK.TASK_VEHICLE_DRIVE_TO_COORD(g_ped, vehicle, math.random(1000), math.random(1000), math.random(100),
                100
                , 1, ENTITY.GET_ENTITY_MODEL(vehicle), 786996, 5, 0)
        else
            util.toast("未找到玩家的载具")

        end
    end)


    --- 传送所有实体 ---
    local Trolling_options_AllEntities = menu.list(Trolling_options, "传送所有实体", {}, "")

    local TPtoPlayer_delay = 100 --ms
    local is_TPtoPlayer_run = false
    local is_Exclude_mission = true
    local function TP_Entities_TO_Player(entity_list, player_ped, Type)
        local i = 0
        for k, ent in pairs(entity_list) do
            if is_TPtoPlayer_run then

                if is_Exclude_mission and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
                else
                    if ENTITY.IS_ENTITY_A_PED(ent) then
                        if not IS_PED_PLAYER(ent) then
                            RequestControl(ent)
                            TP_ENTITY_TO_ENTITY(ent, player_ped, 0.0, 0.0, 2.0)
                            i = i + 1
                        end
                    elseif ENTITY.IS_ENTITY_A_VEHICLE(ent) then
                        if not IS_PLAYER_VEHICLE(ent) then
                            RequestControl(ent)
                            TP_ENTITY_TO_ENTITY(ent, player_ped, 0.0, 0.0, 2.0)
                            i = i + 1
                        end
                    else
                        RequestControl(ent)
                        TP_ENTITY_TO_ENTITY(ent, player_ped, 0.0, 0.0, 2.0)
                        i = i + 1
                    end

                end
                util.yield(TPtoPlayer_delay)

            else
                -- 停止传送
                util.toast("Done!\n" .. Type .. " Number : " .. i)
                return false
            end
        end
        -- 完成传送
        util.toast("Done!\n" .. Type .. " Number : " .. i)
        is_TPtoPlayer_run = false
        return true
    end

    menu.slider(Trolling_options_AllEntities, "传送延时", { "TP_delay" }, "单位: ms", 0, 5000, 100, 100,
        function(value)
            TPtoPlayer_delay = value
        end)
    menu.toggle(Trolling_options_AllEntities, "排除任务实体", {}, "", function()
        is_Exclude_mission = value
    end, true)

    menu.action(Trolling_options_AllEntities, "传送所有 行人 到此玩家", {}, "", function()
        if is_TPtoPlayer_run then
            util.toast("上次的还未传送完成呢")
        else
            is_TPtoPlayer_run = true
            local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
            TP_Entities_TO_Player(entities.get_all_peds_as_handles(), player_ped, "Ped")
        end
    end)
    menu.action(Trolling_options_AllEntities, "传送所有 载具 到此玩家", {}, "", function()
        if is_TPtoPlayer_run then
            util.toast("上次的还未传送完成呢")
        else
            is_TPtoPlayer_run = true
            local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
            TP_Entities_TO_Player(entities.get_all_vehicles_as_handles(), player_ped, "Vehicle")
        end
    end)
    menu.action(Trolling_options_AllEntities, "传送所有 物体 到此玩家", {}, "", function()
        if is_TPtoPlayer_run then
            util.toast("上次的还未传送完成呢")
        else
            is_TPtoPlayer_run = true
            local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
            TP_Entities_TO_Player(entities.get_all_objects_as_handles(), player_ped, "Object")
        end
    end)
    menu.action(Trolling_options_AllEntities, "传送所有 拾取物 到此玩家", {}, "", function()
        if is_TPtoPlayer_run then
            util.toast("上次的还未传送完成呢")
        else
            is_TPtoPlayer_run = true
            local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
            TP_Entities_TO_Player(entities.get_all_pickups_as_handles(), player_ped, "Pickup")
        end
    end)
    menu.action(Trolling_options_AllEntities, "停止传送", {}, "", function()
        is_TPtoPlayer_run = false
    end)


    --- 此玩家附近载具 ---
    local Trolling_options_NearbyVeh = menu.list(Trolling_options, "此玩家附近载具", {}, "")

    local Player_NearbyVeh_radius = 60.0
    menu.slider(Trolling_options_NearbyVeh, "范围半径", { "nearby_veh_radius" }, "", 0.0, 1000.0, 60.0, 10.0,
        function(value)
            Player_NearbyVeh_radius = value
        end)

    menu.toggle_loop(Trolling_options_NearbyVeh, "附近司机追赶此玩家", {}, "", function()
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        for _, vehicle in pairs(GET_NEARBY_VEHICLES(pId, Player_NearbyVeh_radius)) do
            if not VEHICLE.IS_VEHICLE_SEAT_FREE(vehicle, -1, false) then
                local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1, false)
                if not IS_PED_PLAYER(driver) and not TASK.GET_IS_TASK_ACTIVE(driver, 363) then
                    RequestControl(driver)
                    PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(driver, true)
                    TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(driver, true)
                    TASK.TASK_VEHICLE_CHASE(driver, player_ped)
                    PED.SET_PED_KEEP_TASK(driver, true)
                    PED.SET_PED_FLEE_ATTRIBUTES(driver, 0, false)
                    PED.SET_PED_COMBAT_ATTRIBUTES(driver, 46, true)
                end
            end
        end
    end)

    local veh_mission_type = 6
    menu.list_select(Trolling_options_NearbyVeh, "Vehicle Mission Type", {}, "", Vehicle_MissionType_ListItem, 6,
        function(value)
            veh_mission_type = value
        end)
    menu.toggle_loop(Trolling_options_NearbyVeh, "Task Vehicle Mission Target Player", {}, "", function()
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        for _, vehicle in pairs(GET_NEARBY_VEHICLES(pId, Player_NearbyVeh_radius)) do
            if not VEHICLE.IS_VEHICLE_SEAT_FREE(vehicle, -1, false) then
                local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1, false)
                if not IS_PED_PLAYER(driver) and TASK.GET_ACTIVE_VEHICLE_MISSION_TYPE(vehicle) ~= veh_mission_type then
                    RequestControl(driver)
                    PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(driver, true)
                    TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(driver, true)
                    TASK.TASK_VEHICLE_MISSION_PED_TARGET(driver, vehicle, player_ped, veh_mission_type, 500.0, 0, 0.0,
                        0.0, true)
                    PED.SET_PED_KEEP_TASK(driver, true)
                    PED.SET_PED_FLEE_ATTRIBUTES(driver, 0, false)
                    PED.SET_PED_COMBAT_ATTRIBUTES(driver, 46, true)
                end
            end
        end
    end)


    --- 此玩家附近行人 ---
    local Trolling_options_NearbyPed = menu.list(Trolling_options, "此玩家附近行人", {}, "")

    local Player_NearbyPed_radius = 60.0
    menu.slider(Trolling_options_NearbyPed, "范围半径", { "nearby_ped_radius" }, "", 0.0, 1000.0, 60.0, 10.0,
        function(value)
            Player_NearbyPed_radius = value
        end)

    menu.toggle_loop(Trolling_options_NearbyPed, "附近行人逮捕此玩家", {}, "", function()
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        for _, ped in pairs(GET_NEARBY_PEDS(pId, Player_NearbyPed_radius)) do
            if not IS_PED_PLAYER(ped) and not TASK.IS_PED_RUNNING_ARREST_TASK(ped) then
                RequestControl(ped)
                PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
                TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
                TASK.TASK_ARREST_PED(ped, player_ped)
                PED.SET_PED_KEEP_TASK(ped, true)
                PED.SET_PED_FLEE_ATTRIBUTES(driver, 0, false)
                PED.SET_PED_COMBAT_ATTRIBUTES(driver, 46, true)
            end
        end
    end)

    menu.divider(Trolling_options_NearbyPed, "附近行人敌对此玩家")
    local Player_NearbyPed_Combat = {
        weapon = util.joaat(WeaponModel_List[1]),
        is_enhance = false,
        is_perfect = false,
        is_drop_money = false,
        health_mult = 1
    }
    menu.toggle_loop(Trolling_options_NearbyPed, "开启", {}, "", function()
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        local weapon_smoke = util.joaat("WEAPON_SMOKEGRENADE")
        for _, ped in pairs(GET_NEARBY_PEDS(pId, Player_NearbyPed_radius)) do
            if not IS_PED_PLAYER(ped) and not PED.IS_PED_IN_COMBAT(ped, player_ped) then
                RequestControl(ped)

                WEAPON.GIVE_WEAPON_TO_PED(ped, weapon_smoke, -1, false, false)
                WEAPON.GIVE_WEAPON_TO_PED(ped, Player_NearbyPed_Combat.weapon, -1, false, true)
                WEAPON.SET_CURRENT_PED_WEAPON(ped, Player_NearbyPed_Combat.weapon, false)

                local health = ENTITY.GET_ENTITY_MAX_HEALTH(ped)
                ENTITY.SET_ENTITY_HEALTH(ped, health * Player_NearbyPed_Combat.health_mult)

                PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
                TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
                TASK.TASK_COMBAT_PED(ped, player_ped, 0, 16)
                PED.SET_PED_KEEP_TASK(ped, true)
                WEAPON.SET_PED_DROPS_WEAPONS_WHEN_DEAD(ped, false)

                PED.SET_PED_FLEE_ATTRIBUTES(ped, 0, false)
                PED.SET_PED_COMBAT_ATTRIBUTES(ped, 5, true) --AlwaysFight
                PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true) --CanFightArmedPedsWhenNotArmed
                PED.SET_PED_COMBAT_ATTRIBUTES(ped, 58, true) --DisableFleeFromCombat
                --强化作战能力
                if Player_NearbyPed_Combat.is_enhance then
                    WEAPON.SET_PED_INFINITE_AMMO_CLIP(ped, true)
                    PED.SET_PED_SHOOT_RATE(ped, 1000.0)

                    PED.SET_PED_HIGHLY_PERCEPTIVE(ped, true)
                    PED.SET_PED_VISUAL_FIELD_PERIPHERAL_RANGE(ped, 500.0)
                    PED.SET_PED_SEEING_RANGE(ped, 500.0)
                    PED.SET_PED_HEARING_RANGE(ped, 500.0)

                    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 0, true) --CanUseCover
                    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 1, true) --CanUseVehicles
                    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 2, true) --CanDoDrivebys
                    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 12, true) --BlindFireWhenInCover
                    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 13, true) --Aggressive
                    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 20, true) --CanTauntInVehicle
                    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 21, true) --CanChaseTargetOnFoot
                    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 41, true) --CanCommandeerVehicles
                    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 55, true) --CanSeeUnderwaterPeds
                    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 60, true) --CanThrowSmokeGrenade

                    PED.SET_PED_COMBAT_MOVEMENT(ped, 2) --WillAdvance
                    PED.SET_PED_COMBAT_ABILITY(ped, 2) --Professional
                    PED.SET_PED_COMBAT_RANGE(ped, 2) --Far
                    PED.SET_PED_TARGET_LOSS_RESPONSE(ped, 1) --NeverLoseTarget
                end
                if Player_NearbyPed_Combat.is_perfect then
                    PED.SET_PED_ACCURACY(ped, 100.0)
                    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 27, true) --PerfectAccuracy
                end
                if Player_NearbyPed_Combat.is_drop_money then
                    PED.SET_PED_MONEY(ped, 2000)
                end

            end
        end
    end)

    menu.list_select(Trolling_options_NearbyPed, "设置武器", {}, "", WeaponName_ListItem, 1,
        function(value)
            Player_NearbyPed_Combat.weapon = util.joaat(WeaponModel_List[value])
        end)
    menu.toggle(Trolling_options_NearbyPed, "强化作战能力", {}, "如果npc会逃跑的话，开启这个",
        function(toggle)
            Player_NearbyPed_Combat.is_enhance = toggle
        end)
    menu.toggle(Trolling_options_NearbyPed, "完美精准度", {}, "", function(toggle)
        Player_NearbyPed_Combat.is_perfect = toggle
    end)
    menu.slider(Trolling_options_NearbyPed, "血量加倍", { "nearbyped_health_mult" }, "", 1, 100, 1, 1,
        function(value)
            Player_NearbyPed_Combat.health_mult = value
        end)
    menu.toggle(Trolling_options_NearbyPed, "掉落现金为2000", {}, "当做击杀奖励", function(toggle)
        Player_NearbyPed_Combat.is_drop_money = toggle
    end)

    menu.toggle_loop(Trolling_options, "循环举报", { "rs_report" }, "", function()
        if pId ~= players.user() then
            local player_name = players.get_name(pId)
            menu.trigger_commands("reportvcannoying " .. player_name)
            menu.trigger_commands("reportvchate " .. player_name)
            menu.trigger_commands("reportannoying " .. player_name)
            menu.trigger_commands("reporthate " .. player_name)
            menu.trigger_commands("reportexploits " .. player_name)
            menu.trigger_commands("reportbugabuse " .. player_name)
        end
        util.yield(500)
    end)



    -----------------------------
    ---------- 友好选项 ----------
    -----------------------------
    local Friendly_options = menu.list(Player_MainMenu, "友好选项", {}, "")

    local Friendly_Generete_Pickup = menu.list(Friendly_options, "生成拾取物", {}, "")
    menu.action(Friendly_Generete_Pickup, "生成医药包", {}, "", function()
        local modelHash = util.joaat("prop_ld_health_pack")
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0.0, 0.0, 0.0)
        local pickupHash = 2406513688
        Create_Network_Pickup(pickupHash, coords.x, coords.y, coords.z, modelHash, 100)
    end)
    menu.action(Friendly_Generete_Pickup, "生成护甲", {}, "", function()
        local modelHash = util.joaat("prop_armour_pickup")
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0.0, 0.0, 0.0)
        local pickupHash = 1274757841
        Create_Network_Pickup(pickupHash, coords.x, coords.y, coords.z, modelHash, 100)
    end)
    menu.action(Friendly_Generete_Pickup, "生成零食(PQ豆)", {}, "", function()
        local modelHash = util.joaat("PROP_CHOC_PQ")
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0.0, 0.0, 0.0)
        local pickupHash = 483577702
        Create_Network_Pickup(pickupHash, coords.x, coords.y, coords.z, modelHash, 30)
    end)
    menu.action(Friendly_Generete_Pickup, "生成降落伞", {}, "", function()
        local modelHash = util.joaat("p_parachute_s_shop")
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0.0, 0.0, 0.0)
        local pickupHash = 1735599485
        Create_Network_Pickup(pickupHash, coords.x, coords.y, coords.z, modelHash, 2)
    end)
    menu.action(Friendly_Generete_Pickup, "生成呼吸器", {}, "", function()
        local modelHash = util.joaat("PROP_LD_HEALTH_PACK")
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0.0, 0.0, 0.0)
        local pickupHash = 3889104844
        Create_Network_Pickup(pickupHash, coords.x, coords.y, coords.z, modelHash, 20)
    end)
    menu.action(Friendly_Generete_Pickup, "生成火神机枪", {}, "", function()
        local modelHash = util.joaat("W_MG_Minigun")
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0.0, 0.0, 0.0)
        local pickupHash = 792114228
        Create_Network_Pickup(pickupHash, coords.x, coords.y, coords.z, modelHash, 100)

        modelHash = util.joaat("prop_ld_ammo_pack_02")
        pickupHash = 4065984953
        Create_Network_Pickup(pickupHash, coords.x, coords.y, coords.z, modelHash, 9999)
    end)

    local Friendly_Give_Pickup = menu.list(Friendly_options, "给予拾取物", {}, "")
    local Pickup_Reward_ListItem = {
        { "REWARD_HEALTH" },
        { "REWARD_HEALTH_ENTER_VEHICLE" },
        { "REWARD_ARMOUR" },
        { "REWARD_MONEY_VARIABLE" },
        { "REWARD_HEALTH_VARIABLE" },
        { "REWARD_STAT_WEAPON" },
        { "REWARD_STAT_HEALTH" },
        { "REWARD_STAT_HEALTH_VARIABLE" },
        { "REWARD_VEHICLE_FIX" },
        { "REWARD_PARACHUTE" },
    }
    local Pickup_Reward_select = 1
    menu.list_select(Friendly_Give_Pickup, "选择", {}, "", Pickup_Reward_ListItem,
        1, function(value)
        Pickup_Reward_select = value
    end)
    menu.action(Friendly_Give_Pickup, "给予拾取物", {}, "Only works on remote players.", function()
        local reward = Pickup_Reward_ListItem[Pickup_Reward_select][1]
        players.give_pickup_reward(pId, reward)
    end)

    menu.toggle_loop(Friendly_options, "循环称赞", {}, "", function()
        if pId ~= players.user() then
            local player_name = players.get_name(pId)
            menu.trigger_commands("commendhelpful " .. player_name)
            menu.trigger_commands("commendfriendly " .. player_name)
        end
        util.yield(500)
    end)




    -------------------------
    --- 自定义Model生成实体 ---
    -------------------------
    local CustomModel_Generate = menu.list(Player_MainMenu, "自定义Model生成实体", {}, "")
    local CustomModel_Generate_Data = {
        hash = 0,
        type = 1,
        x = 0.0,
        y = 0.0,
        z = 0.0,
        is_invincible = false,
        is_freeze = false,
        is_invisible = false,
        cant_migrate = false,
        no_collision = false,
        --saved hash
        is_select = false,
        select_hash = 0,
        select_type = 1,
    }

    menu.text_input(CustomModel_Generate, "Model Hash ", { "generate_custom_model" }, "",
        function(value)
            CustomModel_Generate_Data.hash = tonumber(value)
        end)
    menu.action(CustomModel_Generate, "转换复制内容", {}, "删除Model Hash: \n便于直接粘贴Ctrl+V",
        function()
            local text = util.get_clipboard_text()
            local num = string.gsub(text, "Model Hash: ", "")
            util.copy_to_clipboard(num, false)
            util.toast("Copied!\n" .. num)
        end)

    local EntityType_ListItem = {
        { "Ped" }, --1
        { "Vehicle" }, --2
        { "Object" }, --3
    }
    menu.list_select(CustomModel_Generate, "实体类型", {}, "", EntityType_ListItem, 1,
        function(index)
            CustomModel_Generate_Data.type = index
        end)
    menu.slider_float(CustomModel_Generate, "左/右", { "generate_custom_model_x" }, "", -10000, 10000, 0, 100,
        function(value)
            CustomModel_Generate_Data.x = value * 0.01
        end)
    menu.slider_float(CustomModel_Generate, "前/后", { "generate_custom_model_y" }, "", -10000, 10000, 0, 100,
        function(value)
            CustomModel_Generate_Data.y = value * 0.01
        end)
    menu.slider_float(CustomModel_Generate, "上/下", { "generate_custom_model_z" }, "", -10000, 10000, 0, 100,
        function(value)
            CustomModel_Generate_Data.z = value * 0.01
        end)

    local CustomModel_Generate_Setting = menu.list(CustomModel_Generate, "属性", {}, "")
    menu.toggle(CustomModel_Generate_Setting, "无敌", {}, "", function(toggle)
        CustomModel_Generate_Data.is_invincible = toggle
    end)
    menu.toggle(CustomModel_Generate_Setting, "冻结", {}, "", function(toggle)
        CustomModel_Generate_Data.is_freeze = toggle
    end)
    menu.toggle(CustomModel_Generate_Setting, "不可见", {}, "", function(toggle)
        CustomModel_Generate_Data.is_invisible = toggle
    end)
    menu.toggle(CustomModel_Generate_Setting, "不可控制", {}, "", function(toggle)
        CustomModel_Generate_Data.cant_migrate = toggle
    end)
    menu.toggle(CustomModel_Generate_Setting, "无碰撞", {}, "", function(toggle)
        CustomModel_Generate_Data.no_collision = toggle
    end)

    --menu.divider(CustomModel_Generate, "")
    CustomModel_Generate_Saved = menu.list_select(CustomModel_Generate, "保存的Hash", {}, "",
        Saved_Hash_List.get_list_item_data2(), 1, function(value)
        if value == 1 then
            --None
            CustomModel_Generate_Data.is_select = false
        elseif value == 2 then
            --Refresh List
            CustomModel_Generate_Data.is_select = false

            menu.set_list_action_options(CustomModel_Generate_Saved, Saved_Hash_List.get_list_item_data2())
            util.toast("已刷新，请重新打开该列表")
        else
            CustomModel_Generate_Data.is_select = true

            local Name = Saved_Hash_List.get_list()[value - 2]
            local Hash, Type = Saved_Hash_List.read(Name)
            CustomModel_Generate_Data.select_hash = Hash
            CustomModel_Generate_Data.select_type = GET_ENTITY_TYPE_INDEX(Type)
        end
    end)

    menu.action(CustomModel_Generate, "生成实体", {}, "", function()
        local hash = CustomModel_Generate_Data.hash
        local Type = CustomModel_Generate_Data.type
        if CustomModel_Generate_Data.is_select then
            hash = CustomModel_Generate_Data.select_hash
            Type = CustomModel_Generate_Data.select_type
        end

        hash = tonumber(hash)
        if hash ~= nil and STREAMING.IS_MODEL_VALID(hash) then
            local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, CustomModel_Generate_Data.x,
                CustomModel_Generate_Data.y, CustomModel_Generate_Data.z)
            local heading = ENTITY.GET_ENTITY_HEADING(player_ped)

            local ent
            if Type == 1 then
                ent = Create_Network_Ped(26, hash, coords.x, coords.y, coords.z, heading)
            elseif Type == 2 then
                ent = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, heading)
            elseif Type == 3 then
                ent = Create_Network_Object(hash, coords.x, coords.y, coords.z)
            else
                util.toast("不支持生成该类型实体")
            end

            if ent ~= nil then
                ENTITY.SET_ENTITY_INVINCIBLE(ent, CustomModel_Generate_Data.is_invincible)
                ENTITY.FREEZE_ENTITY_POSITION(ent, CustomModel_Generate_Data.is_freeze)
                ENTITY.SET_ENTITY_VISIBLE(ent, not CustomModel_Generate_Data.is_invisible, 0)
                if CustomModel_Generate_Data.cant_migrate then
                    entities.set_can_migrate(entities.handle_to_pointer(ent), false)
                end
                if CustomModel_Generate_Data.no_collision then
                    ENTITY.SET_ENTITY_COLLISION(ent, false, false)
                end
            end
        else
            util.toast("Wrong model hash !")
        end

    end)


    ----- END -----
end

----- 玩家列表 -----
local PlayersList = players.list(true, true, true)
for i = 1, #PlayersList do
    PlayerFunctions(PlayersList[i])
end

players.on_join(PlayerFunctions)
