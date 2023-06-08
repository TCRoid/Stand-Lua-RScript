--------------------------------
------------ 任务选项 -----------
--------------------------------

local Mission_options = menu.list(menu.my_root(), "任务选项", {}, "")



---------------------
-- 分红编辑
---------------------
local Heist_Cut_Editor = menu.list(Mission_options, "分红编辑", {}, "")

local cut_global_base = 1977693 + 823 + 56
local HeistCut = {
    ListItem = {
        { "佩里科岛" },
        { "赌场抢劫" },
        { "末日豪劫" },
    },
    ValueList = {
        1977693 + 823 + 56,
        1970895 + 2325,
        1966831 + 812 + 50,
    },
}
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



---------------------
-- 赌场抢劫
---------------------
local Casion_Heist = menu.list(Mission_options, "赌场抢劫", {}, "")

menu.divider(Casion_Heist, "第二面板")
local Casion_Heist_Custom = menu.list(Casion_Heist, "自定义可选任务", {}, "")

local bitset0 = 0
local bitset0_temp = 0
local Casion_Heist_Custom_ListItem = {
    { "toggle",  "巡逻路线",          2,             "" },
    { "toggle",  "杜根货物",          4,             "是否会显示对钩而已" },
    { "toggle",  "电钻",                16,            "" },
    { "toggle",  "枪手诱饵",          64,            "" },
    { "toggle",  "更换载具",          128,           "" },
    { "divider", "隐迹潜踪" },
    { "toggle",  "潜入套装",          8,             "" },
    { "toggle",  "电磁脉冲设备",    32,            "" },
    { "divider", "兵不厌诈" },
    { "toggle",  "进场：除虫大师", 256 + 512,     "" },
    { "toggle",  "进场：维修工",    1024 + 2048,   "" },
    { "toggle",  "进场：古倍科技", 4096 + 8192,   "" },
    { "toggle",  "进场：名人",       16384 + 32768, "" },
    { "toggle",  "离场：国安局",    65536,         "" },
    { "toggle",  "离场：消防员",    131072,        "" },
    { "toggle",  "离场：豪赌客",    262144,        "" },
    { "divider", "气势汹汹" },
    { "toggle",  "加固防弹衣",       1048576,       "" },
    { "toggle",  "镗床",                2621440,       "" }
}

for k, data in pairs(Casion_Heist_Custom_ListItem) do
    if data[1] == "toggle" then
        menu.toggle(Casion_Heist_Custom, data[2], {}, data[4], function(toggle)
            if toggle then
                bitset0_temp = bitset0_temp + data[3]
            else
                bitset0_temp = bitset0_temp - data[3]
            end
        end)
    else
        menu.divider(Casion_Heist_Custom, data[2])
    end
end
menu.divider(Casion_Heist_Custom, "")
menu.action(Casion_Heist_Custom, "添加到 BITSET0", {}, "", function()
    bitset0 = bitset0_temp
    util.toast("当前值为: " .. bitset0)
end)

menu.divider(Casion_Heist, "BITSET0 设置")
menu.action(Casion_Heist, "读取当前 BITSET0 值", {}, "", function()
    util.toast(bitset0)
end)
menu.slider(Casion_Heist, "自定义 BITSET0 值", { "bitset0" }, "", 0, 16777216, 0, 1, function(value)
    bitset0 = value
    util.toast("已修改为: " .. bitset0)
end)
menu.divider(Casion_Heist, "")
menu.action(Casion_Heist, "写入 BITSET0 值", {}, "写入到 H3OPT_BITSET0", function()
    STAT_SET_INT("H3OPT_BITSET0", bitset0)
    util.toast("已将 H3OPT_BITSET0 修改为: " .. bitset0)
end)



---------------------
-- Local Editor
---------------------
local Local_Editor = menu.list(Mission_options, "Local Editor", { "local_editor" }, "")

local local_editor = {
    script = "fm_mission_controller",
    address = 0,
    type = "int",
    write = "",
}

menu.list_select(Local_Editor, "选择脚本", {}, "", {
    { "fm_mission_controller" },
    { "fm_mission_controller_2020" },
}, 1, function(index)
    if index == 1 then
        local_editor.script = "fm_mission_controller"
    elseif index == 2 then
        local_editor.script = "fm_mission_controller_2020"
    end
end)

menu.slider(Local_Editor, "地址", { "local_address" }, "输入计算总和",
    0, 16777216, 0, 1, function(value)
        local_editor.address = value
    end)
menu.list_select(Local_Editor, "数值类型", {}, "", { { "INT" }, { "FLOAT" } }, 1, function(value)
    if value == 1 then
        local_editor.type = "int"
    elseif value == 2 then
        local_editor.type = "float"
    end
end)

menu.divider(Local_Editor, "读")
menu.action(Local_Editor, "读取", {}, "", function()
    local script = local_editor.script
    local address = local_editor.address
    if SCRIPT.HAS_SCRIPT_LOADED(script) then
        local value
        if local_editor.type == "int" then
            value = GET_INT_LOCAL(script, address)
        elseif local_editor.type == "float" then
            value = GET_FLOAT_LOCAL(script, address)
        end

        if value ~= nil then
            menu.set_value(local_editor.readonly, value)
        else
            menu.set_value(local_editor.readonly, "NULL")
        end
    else
        util.toast("This Script Has Not Loaded")
    end
end)
local_editor.readonly = menu.readonly(Local_Editor, "值")

menu.divider(Local_Editor, "写")
menu.text_input(Local_Editor, "要写入的值", { "local_write" }, "务必注意int类型和float类型的格式",
    function(value)
        local_editor.write = value
    end)
menu.action(Local_Editor, "写入", {}, "", function()
    local script = local_editor.script
    local address = local_editor.address
    local value = tonumber(local_editor.write)
    if value ~= nil then
        if SCRIPT.HAS_SCRIPT_LOADED(script) then
            if local_editor.type == "int" then
                SET_INT_LOCAL(script, address, value)
            elseif local_editor.type == "float" then
                SET_FLOAT_LOCAL(script, address, value)
            end
        else
            util.toast("This Script Has Not Loaded")
        end
    end
end)
menu.toggle_loop(Local_Editor, "锁定写入", {}, "更改地址类型，锁定的也会跟着改变", function()
    local script = local_editor.script
    local address = local_editor.address
    local value = tonumber(local_editor.write)
    if value ~= nil then
        if SCRIPT.HAS_SCRIPT_LOADED(script) then
            if local_editor.type == "int" then
                SET_INT_LOCAL(script, address, value)
            elseif local_editor.type == "float" then
                SET_FLOAT_LOCAL(script, address, value)
            end
        end
    end
end)



---------------------
-- Global Editor
---------------------
local Global_Editor = menu.list(Mission_options, "Global Editor", { "global_editor" }, "")

local global_editor = {
    address1 = 262145,
    address2 = 0,
    type = "int",
    write = "",
}

menu.slider(Global_Editor, "地址1", { "global_address1" }, "", 0, 16777216, 262145, 1, function(value)
    global_editor.address1 = value
end)
menu.slider(Global_Editor, "地址2", { "global_address2" }, "", 0, 16777216, 0, 1, function(value)
    global_editor.address2 = value
end)
menu.list_select(Global_Editor, "数值类型", {}, "", { { "INT" }, { "FLOAT" } }, 1, function(value)
    if value == 1 then
        global_editor.type = "int"
    elseif value == 2 then
        global_editor.type = "float"
    end
end)

menu.divider(Global_Editor, "读")
menu.action(Global_Editor, "读取", {}, "", function()
    local address = global_editor.address1 + global_editor.address2
    local value
    if global_editor.type == "int" then
        value = GET_INT_GLOBAL(address)
    elseif global_editor.type == "float" then
        value = GET_FLOAT_GLOBAL(address)
    end

    if value ~= nil then
        menu.set_value(global_editor.readonly, value)
    else
        menu.set_value(global_editor.readonly, "NULL")
    end
end)
global_editor.readonly = menu.readonly(Global_Editor, "值")

menu.divider(Global_Editor, "写")
menu.text_input(Global_Editor, "要写入的值", { "global_write" }, "务必注意int类型和float类型的格式",
    function(value)
        global_editor.write = value
    end)
menu.action(Global_Editor, "写入", {}, "", function()
    local address = global_editor.address1 + global_editor.address2
    local value = tonumber(global_editor.write)
    if value ~= nil then
        if global_editor.type == "int" then
            SET_INT_GLOBAL(address, value)
        elseif global_editor.type == "float" then
            SET_FLOAT_GLOBAL(address, value)
        end
    end
end)
menu.toggle_loop(Global_Editor, "锁定写入", {}, "更改地址类型，锁定的也会跟着改变", function()
    local address = global_editor.address1 + global_editor.address2
    local value = tonumber(global_editor.write)
    if value ~= nil then
        if global_editor.type == "int" then
            SET_INT_GLOBAL(address, value)
        elseif global_editor.type == "float" then
            SET_FLOAT_GLOBAL(address, value)
        end
    end
end)




---------------------
-- 任务助手
---------------------
local Mission_Assistant = menu.list(Mission_options, "任务助手", {}, "")

--- 附近街道 ---
local Mission_Assistant_Nearby_Road = menu.list(Mission_Assistant, "附近街道", {}, "")

local ma_nearby_road = {
    nodeType = 0,
    random_radius = 60.0,
    godmode = true,
    strong = true,
    flash_blip = true,
}

menu.divider(Mission_Assistant_Nearby_Road, "生成载具")

menu.list_select(Mission_Assistant_Nearby_Road, "生成地点", {}, "", {
    { "主要道路" }, { "任意地面" }, { "水 (船)" }, { "随机" },
}, 1, function(value)
    ma_nearby_road.nodeType = value - 1
end)
menu.slider_float(Mission_Assistant_Nearby_Road, "随机范围", { "ma_nearby_road_random_radius" }, "",
    0, 50000, 6000, 500, function(value)
        ma_nearby_road.random_radius = value * 0.01
    end)

menu.toggle(Mission_Assistant_Nearby_Road, "生成载具: 无敌", {}, "", function(toggle)
    ma_nearby_road.godmode = toggle
end, true)
menu.toggle(Mission_Assistant_Nearby_Road, "生成载具: 强化", {}, "", function(toggle)
    ma_nearby_road.strong = toggle
end, true)
menu.toggle(Mission_Assistant_Nearby_Road, "生成载具: 闪烁标记点", {}, "", function(toggle)
    ma_nearby_road.flash_blip = toggle
end, true)

menu.divider(Mission_Assistant_Nearby_Road, "载具列表")

for _, data in pairs(Vehicle_Common) do
    local name = "生成 " .. data.name
    local hash = util.joaat(data.model)
    menu.action(Mission_Assistant_Nearby_Road, name, {}, data.help_text, function()
        local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        local bool, coords, heading = false, pos, 0

        if ma_nearby_road.nodeType == 3 then
            bool, coords = get_random_vehicle_node(pos, ma_nearby_road.random_radius)
        else
            bool, coords, heading = get_closest_vehicle_node(pos, ma_nearby_road.nodeType)
        end

        if bool then
            local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, heading)
            if ENTITY.DOES_ENTITY_EXIST(vehicle) then
                upgrade_vehicle(vehicle)
                set_entity_godmode(vehicle, ma_nearby_road.godmode)
                if ma_nearby_road.strong then
                    strong_vehicle(vehicle)
                end
                VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(vehicle, 5.0)

                if ma_nearby_road.flash_blip then
                    SHOW_BLIP_TIMER(vehicle, 225, 27, 5000)
                end

                util.toast("完成！")
            end
        end
    end)
end




----- 玩家助手 -----
local Mission_Player_Assistant = menu.list(Mission_Assistant, "玩家助手", {}, "")

local function generate_mpa_player_commands(menu_parent, pid)
    menu.divider(menu_parent, menu.get_menu_name(menu_parent))

    local readonly_menu_list = {}
    local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
    local player_name = players.get_name(pid)

    readonly_menu_list[1] = menu.readonly(menu_parent, "生命")
    readonly_menu_list[2] = menu.readonly(menu_parent, "护甲")
    readonly_menu_list[3] = menu.readonly(menu_parent, "通缉等级")
    readonly_menu_list[4] = menu.readonly(menu_parent, "载具")

    menu.on_tick_in_viewport(readonly_menu_list[1], function()
        local t = ENTITY.GET_ENTITY_HEALTH(player_ped) .. "/" .. ENTITY.GET_ENTITY_MAX_HEALTH(player_ped)
        menu.set_value(readonly_menu_list[1], t)

        menu.set_value(readonly_menu_list[2], PED.GET_PED_ARMOUR(player_ped))
        menu.set_value(readonly_menu_list[3], PLAYER.GET_PLAYER_WANTED_LEVEL(pid))

        if PED.IS_PED_IN_ANY_VEHICLE(player_ped, false) then
            local veh_model = players.get_vehicle_model(pid)
            local display_name = get_vehicle_display_name_by_hash(veh_model)
            menu.set_value(readonly_menu_list[4], display_name)
        else
            menu.set_value(readonly_menu_list[4], "无")
        end
    end)

    menu.toggle(menu_parent, "自动恢复", {}, "", function(value)
        local toggle = "off"
        if value then
            toggle = "on"
        end
        menu.trigger_commands("autoheal" .. player_name .. " " .. toggle)
    end)
    menu.toggle(menu_parent, "永不通缉", {}, "", function(value)
        local toggle = "off"
        if value then
            toggle = "on"
        end
        menu.trigger_commands("bail" .. player_name .. " " .. toggle)
    end)
    menu.action(menu_parent, "给予全部武器", {}, "", function()
        menu.trigger_commands("arm" .. player_name)
    end)
    menu.action(menu_parent, "给予弹药", {}, "", function()
        menu.trigger_commands("ammo" .. player_name)
    end)

    local neayby_veh = menu.list(menu_parent, "在玩家附近生成载具", {}, "")
    local nearby_veh_godmod = menu.toggle(neayby_veh, "生成载具: 无敌", {}, "", function(toggle)
    end, true)
    local nearby_veh_strong = menu.toggle(neayby_veh, "生成载具: 强化", {}, "", function(toggle)
    end, true)

    menu.divider(neayby_veh, "载具列表")

    for _, data in pairs(Vehicle_Common) do
        local name = "生成 " .. data.name
        local hash = util.joaat(data.model)
        menu.action(neayby_veh, name, {}, data.help_text, function()
            local pos = ENTITY.GET_ENTITY_COORDS(player_ped)
            local bool, coords, heading = get_closest_vehicle_node(pos, 1)
            if bool then
                local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, heading)
                if ENTITY.DOES_ENTITY_EXIST(vehicle) then
                    upgrade_vehicle(vehicle)
                    set_entity_godmode(vehicle, menu.get_value(nearby_veh_godmod))
                    if menu.get_value(nearby_veh_strong) then
                        strong_vehicle(vehicle)
                    end
                    VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(vehicle, 5.0)

                    util.toast("完成！")
                    SHOW_BLIP_TIMER(vehicle, 225, 27, 5000)
                end
            end
        end)
    end
end

local mpa_menu_list = {}

menu.action(Mission_Player_Assistant, "刷新玩家列表", {}, "", function()
    for k, v in pairs(mpa_menu_list) do
        if menu.is_ref_valid(v) then
            menu.delete(v)
        end
    end
    mpa_menu_list = {}
    ------
    for k, pid in pairs(players.list()) do
        local name = players.get_name(pid)
        local rank = players.get_rank(pid)
        local menu_name = name .. " (" .. rank .. "级)"

        local team = PLAYER.GET_PLAYER_TEAM(pid)
        local money = players.get_money(pid)
        local language = players.get_language(pid)
        local help_text = "Team: " .. team .. "\nMoney: " .. money .. "\nLanguage: " .. enum_LanguageType[language]

        local player_menu = menu.list(Mission_Player_Assistant, menu_name, {}, help_text)
        table.insert(mpa_menu_list, player_menu)

        generate_mpa_player_commands(player_menu, pid)
    end
end)
menu.toggle_loop(Mission_Player_Assistant, "显示玩家信息", {}, "", function()
    local x, y, scale, margin = 0.45, 0.0, 0.5, 0.01
    for k, pid in pairs(players.list()) do
        local name = players.get_name(pid)
        local rank = players.get_rank(pid)
        local text = name .. " (" .. rank .. "级)"

        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local text_health = ENTITY.GET_ENTITY_HEALTH(player_ped) .. "/" .. ENTITY.GET_ENTITY_MAX_HEALTH(player_ped)
        local armour = PED.GET_PED_ARMOUR(player_ped)
        local wanted = PLAYER.GET_PLAYER_WANTED_LEVEL(pid)
        text = text .. "\n生命值: " .. text_health .. "\n护甲: " .. armour .. "\n通缉等级: " .. wanted

        if PED.IS_PED_IN_ANY_VEHICLE(player_ped, false) then
            local veh_model = players.get_vehicle_model(pid)
            local display_name = get_vehicle_display_name_by_hash(veh_model)
            text = text .. "\n载具: " .. display_name
        else
            text = text .. "\n载具: 无"
        end

        draw_text_box(text, x, y, scale, margin)

        local text_width, text_height = directx.get_text_size(text, scale)
        x = x + text_width + margin * 2
    end
end)
menu.divider(Mission_Player_Assistant, "玩家")




----------
menu.action(Mission_Assistant, "警局楼顶 生成直升机", {}, "", function()
    local data_list = {
        { coords = { x = 578.9077, y = 10.7298, z = 103.6283 },  heading = 181.9320 },
        { coords = { x = 448.8357, y = -980.8952, z = 44.0863 }, heading = 93.0307 },
    }
    local hash = 353883353

    for _, data in pairs(data_list) do
        local coords = data.coords
        local veh = get_closest_vehicle(v3(coords), false, 5.0)
        if ENTITY.DOES_ENTITY_EXIST(veh) then
            VEHICLE.SET_VEHICLE_ENGINE_ON(veh, true, true, false)
            VEHICLE.SET_VEHICLE_HAS_BEEN_OWNED_BY_PLAYER(veh, true)
            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(veh, true, false)
        else
            veh = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, data.heading)
        end

        ENTITY.SET_ENTITY_HEALTH(veh, 10000)
        ENTITY.SET_ENTITY_MAX_HEALTH(veh, 10000)
        strong_vehicle(veh)
    end

    util.toast("完成！")
end)
menu.toggle_loop(Mission_Assistant, "秃鹰直升机 NPC禁用武器", {},
    "禁止NPC使用秃鹰攻击直升机的机枪和导弹", function()
        for k, vehicle in pairs(entities.get_all_vehicles_as_handles()) do
            if ENTITY.GET_ENTITY_MODEL(vehicle) == 788747387 then
                local ped = GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
                if ped ~= 0 and not IS_PED_PLAYER(ped) then
                    if not VEHICLE.IS_VEHICLE_WEAPON_DISABLED(1186503822, vehicle, ped) then
                        RequestControl(vehicle)
                        VEHICLE.DISABLE_VEHICLE_WEAPON(true, 1186503822, vehicle, ped) --VEHICLE_WEAPON_PLAYER_BUZZARD
                        VEHICLE.DISABLE_VEHICLE_WEAPON(true, -123497569, vehicle, ped) --VEHICLE_WEAPON_SPACE_ROCKET
                    end
                end
            end
        end
    end)


--#region Apartment Heist

------ 公寓抢劫 ------
menu.divider(Mission_Assistant, "公寓抢劫")

local Mission_Assistant_Prison = menu.list(Mission_Assistant, "越狱", {}, "")
menu.action(Mission_Assistant_Prison, "飞机：目的地 生成坦克", {}, "", function()
    local coords = { x = 2183.927, y = 4759.426, z = 41.676 }
    local heading = 73.373
    local hash = util.joaat("khanjali")
    local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, heading)
    if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        upgrade_vehicle(vehicle)
        set_entity_godmode(vehicle, true)
        util.toast("完成！")
    end
end)
menu.action(Mission_Assistant_Prison, "巴士：传送到目的地", {}, "", function()
    local coords = { x = 2054.97119, y = 3179.5639, z = 45.43724 }
    local heading = 243.0095
    local entity_list = get_entities_by_hash("vehicle", true, -2007026063)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            local blip = HUD.GET_BLIP_FROM_ENTITY(ent)
            if HUD.DOES_BLIP_EXIST(blip) then
                local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ent, -1)
                if ped ~= 0 and not IS_PED_PLAYER(ped) then
                    RequestControl(ped)
                    TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                    ENTITY.SET_ENTITY_HEALTH(ped, 0)
                end

                RequestControl(ent)
                SET_ENTITY_COORDS(ent, coords)
                ENTITY.SET_ENTITY_HEADING(ent, heading)

                VEHICLE.SET_VEHICLE_IS_WANTED(ent, false)
                VEHICLE.SET_VEHICLE_INFLUENCES_WANTED_LEVEL(ent, false)
                VEHICLE.SET_VEHICLE_HAS_BEEN_OWNED_BY_PLAYER(ent, true)
                VEHICLE.SET_VEHICLE_IS_STOLEN(ent, false)

                if hasControl(ent) then
                    util.toast("完成！")
                else
                    util.toast("未能成功控制实体")
                end
            end
        end
    end
end)
menu.divider(Mission_Assistant_Prison, "终章")
menu.action(Mission_Assistant_Prison, "(破坏)巴士 传送到目的地", {}, "", function()
    local coords = { x = 1679.619873, y = 3278.103759, z = 41.0774383 }
    local heading = 32.8253974
    local entity_list = get_entities_by_hash("vehicle", true, -2007026063)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            local blip = HUD.GET_BLIP_FROM_ENTITY(ent)
            if HUD.DOES_BLIP_EXIST(blip) then
                local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ent, -1)
                if ped ~= 0 and not IS_PED_PLAYER(ped) then
                    RequestControl(ped)
                    TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                    ENTITY.SET_ENTITY_HEALTH(ped, 0)
                end

                RequestControl(ent)
                SET_ENTITY_COORDS(ent, coords)
                ENTITY.SET_ENTITY_HEADING(ent, heading)

                if hasControl(ent) then
                    util.toast("完成！")
                else
                    util.toast("未能成功控制实体")
                end
            end
        end
    end
end)
menu.action(Mission_Assistant_Prison, "监狱内 生成骷髅马", {}, "", function()
    local coords = { x = 1722.397, y = 2514.426, z = 45.305 }
    local heading = 116.175
    local hash = util.joaat("kuruma2")
    local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, heading)
    if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        upgrade_vehicle(vehicle)
        strong_vehicle(vehicle)
        set_entity_godmode(vehicle, true)
        VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(vehicle, 5.0)
        util.toast("完成！")
    end
end)
menu.action(Mission_Assistant_Prison, "美杜莎 无敌", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, 1077420264)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            RequestControl(ent)
            set_entity_godmode(ent, true)
            strong_vehicle(ent)

            if hasControl(ent) then
                util.toast("完成！")
            else
                util.toast("未能成功控制实体")
            end
        end
    end
end)
menu.action(Mission_Assistant_Prison, "秃鹰直升机 无敌", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, 788747387)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            RequestControl(ent)
            set_entity_godmode(ent, true)
            strong_vehicle(ent)

            if hasControl(ent) then
                util.toast("完成！")
            else
                util.toast("未能成功控制实体")
            end
        end
    end
end)
menu.action(Mission_Assistant_Prison, "敌对天煞 传送到海洋", {}, "", function()
    local coords = { x = 4912, y = -4910, z = 20 }
    local entity_list = get_entities_by_hash("vehicle", true, -1281684762)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            RequestControl(ent)
            SET_ENTITY_COORDS(ent, coords)

            if hasControl(ent) then
                util.toast("完成！")
            else
                util.toast("未能成功控制实体")
            end
        end
    end
end)
menu.action(Mission_Assistant_Prison, "敌对天煞 冻结", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, -1281684762)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            RequestControl(ent)
            ENTITY.FREEZE_ENTITY_POSITION(ent, true)

            if hasControl(ent) then
                util.toast("完成！")
            else
                util.toast("未能成功控制实体")
            end
        end
    end
end)
menu.action(Mission_Assistant_Prison, "敌对天煞 禁用导弹", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, -1281684762)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            RequestControl(ent)
            local ped = GET_PED_IN_VEHICLE_SEAT(ent, -1)
            if ped ~= 0 then
                VEHICLE.DISABLE_VEHICLE_WEAPON(true, 3313697558, ent, ped) --VEHICLE_WEAPON_PLANE_ROCKET
            end

            if hasControl(ent) then
                util.toast("完成！")
            else
                util.toast("未能成功控制实体")
            end
        end
    end
end)


-- Model Name: ig_rashcosvki, Hash: 940330470
local Mission_Assistant_Prison_rashcosvki = menu.list(Mission_Assistant_Prison, "光头", {}, "")

menu.action(Mission_Assistant_Prison_rashcosvki, "清除正在执行的任务", {}, "", function()
    local entity_list = get_entities_by_hash("ped", true, 940330470)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            RequestControl(ent)
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(ent)

            if hasControl(ent) then
                util.toast("完成！")
            else
                util.toast("未能成功控制实体")
            end
        end
    end
end)
menu.action(Mission_Assistant_Prison_rashcosvki, "无敌强化", {}, "", function()
    local weaponHash = util.joaat("WEAPON_APPISTOL")

    local entity_list = get_entities_by_hash("ped", true, 940330470)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            RequestControl(ent)
            WEAPON.GIVE_WEAPON_TO_PED(ent, weaponHash, -1, false, true)
            WEAPON.SET_CURRENT_PED_WEAPON(ent, weaponHash, false)

            increase_ped_combat_ability(ped, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 5, true)  --AlwaysFight
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 27, true) --PerfectAccuracy

            if hasControl(ent) then
                util.toast("完成！")
            else
                util.toast("未能成功控制实体")
            end
        end
    end
end)
local Mission_Assistant_Prison_vehicle = 0
menu.action(Mission_Assistant_Prison_rashcosvki, "跑去监狱外围的警车", {},
    "会在监狱外围生成一辆警车", function()
        local hash = util.joaat("police3")
        local coords = { x = 1571.585, y = 2605.450, z = 45.880 }
        local heading = 343.0217

        local entity_list = get_entities_by_hash("ped", true, 940330470)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                RequestControl(ent)

                if not ENTITY.DOES_ENTITY_EXIST(Mission_Assistant_Prison_vehicle) then
                    local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, heading)
                    upgrade_vehicle(vehicle)
                    set_entity_godmode(vehicle, true)
                    strong_vehicle(vehicle)
                    VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(vehicle, 5.0)

                    Mission_Assistant_Prison_vehicle = vehicle
                end

                TASK.TASK_GO_TO_ENTITY(ent, Mission_Assistant_Prison_vehicle, -1, 5.0, 100, 0.0, 0)

                if hasControl(ent) then
                    util.toast("完成！")
                else
                    util.toast("未能成功控制实体")
                end
            end
        end
    end)

menu.divider(Mission_Assistant_Prison_rashcosvki, "玩家")

local function Get_Players_ListItem()
    local Players_ListItem = {
        { "刷新列表", {}, "" }
    }

    local player_list = players.list()
    for k, pid in pairs(player_list) do
        local t = { "", {}, "" }

        local text = players.get_name(pid) .. " (" .. PLAYER.GET_PLAYER_TEAM(pid) .. ")"
        t[1] = text
        t[3] = tostring(pid)
        table.insert(Players_ListItem, t)
    end
    return Players_ListItem
end

local Mission_Assistant_Prison_player = 0
Mission_Assistant_Prison_PlayerSelect = menu.list_select(Mission_Assistant_Prison_rashcosvki, "选择玩家", {}, "",
    Get_Players_ListItem(), 2, function(index)
        if index == 1 then
            Mission_Assistant_Prison_player = -1
            menu.set_list_action_options(Mission_Assistant_Prison_PlayerSelect, Get_Players_ListItem())
            util.toast("已刷新，请重新打开该列表")
        else
            Mission_Assistant_Prison_player = Get_Players_ListItem()[index][3]
        end
    end)
menu.action(Mission_Assistant_Prison_rashcosvki, "传送到玩家/玩家载具", {}, "", function()
    if players.exists(Mission_Assistant_Prison_player) then
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(Mission_Assistant_Prison_player)
        local veh = GET_VEHICLE_PED_IS_IN(player_ped)
        if veh ~= 0 then
            -- 传送到玩家载具
            local entity_list = get_entities_by_hash("ped", true, 940330470)
            if next(entity_list) ~= nil then
                for k, ent in pairs(entity_list) do
                    RequestControl(ent)
                    PED.SET_PED_INTO_VEHICLE(ent, veh, -2)

                    if hasControl(ent) then
                        util.toast("完成！")
                    else
                        util.toast("未能成功控制实体")
                    end
                end
            end
        else
            -- 传送到玩家
            local entity_list = get_entities_by_hash("ped", true, 940330470)
            if next(entity_list) ~= nil then
                for k, ent in pairs(entity_list) do
                    RequestControl(ent)
                    TP_ENTITY_TO_ENTITY(ent, player_ped)

                    if hasControl(ent) then
                        util.toast("完成！")
                    else
                        util.toast("未能成功控制实体")
                    end
                end
            end
        end
    end
end)
menu.action(Mission_Assistant_Prison_rashcosvki, "进入到玩家载具", {}, "TASK_ENTER_VEHICLE", function()
    if players.exists(Mission_Assistant_Prison_player) then
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(Mission_Assistant_Prison_player)
        local veh = GET_VEHICLE_PED_IS_IN(player_ped)
        if veh ~= 0 then
            local entity_list = get_entities_by_hash("ped", true, 940330470)
            if next(entity_list) ~= nil then
                for k, ent in pairs(entity_list) do
                    RequestControl(ent)
                    TASK.TASK_ENTER_VEHICLE(ent, veh, -1, -2, 2.0, 1, 0)

                    if hasControl(ent) then
                        util.toast("完成！")
                    else
                        util.toast("未能成功控制实体")
                    end
                end
            end
        else
            util.toast("玩家没有在载具内")
        end
    end
end)
menu.action(Mission_Assistant_Prison_rashcosvki, "跟随玩家", {}, "TASK_FOLLOW_TO_OFFSET_OF_ENTITY", function()
    if players.exists(Mission_Assistant_Prison_player) then
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(Mission_Assistant_Prison_player)
        local entity_list = get_entities_by_hash("ped", true, 940330470)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                RequestControl(ent)
                TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(ent, player_ped, 0.0, -1.0, 0.0, 20.0, -1, 100.0, true)

                if hasControl(ent) then
                    util.toast("完成！")
                else
                    util.toast("未能成功控制实体")
                end
            end
        end
    end
end)


local Mission_Assistant_Huamane = menu.list(Mission_Assistant, "突袭人道实验室", {}, "")
menu.action(Mission_Assistant_Huamane, "关键密码：目的地 生成坦克", {}, "", function()
    local coords = { x = 142.122, y = -1061.271, z = 29.746 }
    local head = 69.686
    local hash = util.joaat("khanjali")
    local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, head)
    if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        upgrade_vehicle(vehicle)
        set_entity_godmode(vehicle, true)
        util.toast("完成！")
    end
end)
menu.action(Mission_Assistant_Huamane, "电磁装置：九头蛇 无敌", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, 970385471)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            RequestControl(ent)
            set_entity_godmode(ent, true)
            strong_vehicle(ent)

            if hasControl(ent) then
                util.toast("完成！")
            else
                util.toast("未能成功控制实体")
            end
        end
    end
end)
menu.action(Mission_Assistant_Huamane, "电磁装置：天煞 无敌", {}, "没有玩家和NPC驾驶的天煞",
    function()
        local entity_list = get_entities_by_hash("vehicle", true, -1281684762)
        if next(entity_list) ~= nil then
            local i = 0
            for k, ent in pairs(entity_list) do
                if VEHICLE.IS_VEHICLE_SEAT_FREE(ent, -1, true) then
                    RequestControl(ent)
                    set_entity_godmode(ent, true)
                    strong_vehicle(ent)

                    if hasControl(ent) then
                        i = i + 1
                    end
                end
            end
            util.toast("完成！\n数量: " .. tostring(i))
        end
    end)
menu.action(Mission_Assistant_Huamane, "运送电磁装置：叛乱分子 传送到目的地", {}, "", function()
    local coords = { x = 3339.7307, y = 3670.7246, z = 43.8973 }
    local heading = 312.5133
    local entity_list = get_entities_by_hash("vehicle", true, 2071877360)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            local blip = HUD.GET_BLIP_FROM_ENTITY(ent)
            if HUD.DOES_BLIP_EXIST(blip) then
                RequestControl(ent)
                SET_ENTITY_COORDS(ent, coords)
                ENTITY.SET_ENTITY_HEADING(ent, heading)

                if hasControl(ent) then
                    util.toast("完成！")
                else
                    util.toast("未能成功控制实体")
                end
            end
        end
    end
end)
menu.action(Mission_Assistant_Huamane, "终章：女武神 无敌", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, -1600252419)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            RequestControl(ent)
            set_entity_godmode(ent, true)
            strong_vehicle(ent)

            if hasControl(ent) then
                util.toast("完成！")
            else
                util.toast("未能成功控制实体")
            end
        end
    end
end)


local Mission_Assistant_Series = menu.list(Mission_Assistant, "首轮募资", {}, "")
menu.action(Mission_Assistant_Series, "可卡因：直升机 无敌", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, 744705981)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            RequestControl(ent)
            set_entity_godmode(ent, true)
            strong_vehicle(ent)

            if hasControl(ent) then
                util.toast("完成！")
            else
                util.toast("未能成功控制实体")
            end
        end
    end
end)
menu.action(Mission_Assistant_Series, "窃取冰毒：油罐车 无敌", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, 1956216962)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            RequestControl(ent)
            set_entity_godmode(ent, true)
            strong_vehicle(ent)

            if hasControl(ent) then
                util.toast("完成！")
            else
                util.toast("未能成功控制实体")
            end
        end
    end
end)
menu.action(Mission_Assistant_Series, "窃取冰毒：油罐车位置 生成尖锥魅影", {}, "", function()
    local coords = { x = 2416.0986, y = 5012.4545, z = 46.6019 }
    local heading = 132.7993
    local hash = util.joaat("phantom2")
    local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, heading)
    if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        upgrade_vehicle(vehicle)
        set_entity_godmode(vehicle, true)
        strong_vehicle(vehicle)
        VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(vehicle, 5.0)
        util.toast("完成！")
    end
end)


local Mission_Assistant_Pacific = menu.list(Mission_Assistant, "太平洋标准银行", {}, "")
menu.action(Mission_Assistant_Pacific, "厢型车：添加地图标记点", {}, "给车添加地图标记点ABCD",
    function()
        local entity_list = get_entities_by_hash("vehicle", true, 444171386)
        if next(entity_list) ~= nil then
            local blip_sprite = 535 -- radar_target_a
            for k, ent in pairs(entity_list) do
                local blip = HUD.GET_BLIP_FROM_ENTITY(ent)

                if HUD.DOES_BLIP_EXIST(blip) then
                    if HUD.GET_BLIP_SPRITE ~= blip_sprite then
                        util.remove_blip(blip)
                    end
                end

                if not HUD.DOES_BLIP_EXIST(blip) then
                    blip = HUD.ADD_BLIP_FOR_ENTITY(ent)
                    HUD.SET_BLIP_SPRITE(blip, blip_sprite)
                    HUD.SET_BLIP_COLOUR(blip, 5) -- Yellow
                    HUD.SET_BLIP_SCALE(blip, 0.8)
                end

                blip_sprite = blip_sprite + 1
            end
            util.toast("完成！")
        end
    end)
menu.action(Mission_Assistant_Pacific, "厢型车：司机 传送到天上并冻结", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, 444171386)
    if next(entity_list) ~= nil then
        local i = 0
        for k, ent in pairs(entity_list) do
            local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ent, -1)
            if ped ~= 0 and not IS_PED_PLAYER(ped) then
                RequestControl(ped)
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                SET_ENTITY_MOVE(ped, 0.0, 0.0, 500.0)
                ENTITY.FREEZE_ENTITY_POSITION(ped, true)

                if hasControl(ped) then
                    i = i + 1
                end
            end
        end
        util.toast("完成！\n数量: " .. tostring(i))
    end
end)
menu.action(Mission_Assistant_Pacific, "厢型车：传送到目的地", {}, "传送司机到天上，车传送到莱斯特工厂"
, function()
    local coords = { x = 760, y = -983, z = 28 }
    local head = 93.6973
    local entity_list = get_entities_by_hash("vehicle", true, 444171386)
    if next(entity_list) ~= nil then
        local ped_num, veh_num = 0, 0
        for k, ent in pairs(entity_list) do
            local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ent, -1)
            if ped ~= 0 and not IS_PED_PLAYER(ped) then
                RequestControl(ped)
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                SET_ENTITY_MOVE(ped, 0.0, 0.0, 500.0)
                ENTITY.FREEZE_ENTITY_POSITION(ped, true)

                if hasControl(ped) then
                    ped_num = ped_num + 1
                end
            end

            RequestControl(ent)
            SET_ENTITY_COORDS(ent, coords)
            ENTITY.SET_ENTITY_HEADING(ent, head)
            coords.y = coords.y + 3.5

            if hasControl(ent) then
                veh_num = veh_num + 1
            end
        end
        util.toast("完成！\nNPC数量: " .. tostring(ped_num) .. "\n载具数量: " .. tostring(veh_num))
    end
end)
menu.action(Mission_Assistant_Pacific, "信号：岛上 生成直升机", {}, "撤离时", function()
    local coords = { x = -2188.197, y = 5128.990, z = 11.672 }
    local head = 314.255
    local hash = util.joaat("polmav")
    local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, head)
    if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        upgrade_vehicle(vehicle)
        set_entity_godmode(vehicle, true)
        strong_vehicle(vehicle)
        VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(vehicle, 5.0)
        util.toast("完成！")
    end
end)
menu.action(Mission_Assistant_Pacific, "车队：目的地 生成坦克", {}, "", function()
    local coords = { x = -196.452, y = 4221.374, z = 45.376 }
    local head = 313.298
    local hash = util.joaat("khanjali")
    local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, head)
    if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        upgrade_vehicle(vehicle)
        set_entity_godmode(vehicle, true)
        util.toast("完成！")
    end
end)
menu.action(Mission_Assistant_Pacific, "车队：卡车 无敌", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, 630371791)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            RequestControl(ent)
            set_entity_godmode(ent, true)
            strong_vehicle(ent)

            if hasControl(ent) then
                util.toast("完成！")
            else
                util.toast("未能成功控制实体")
            end
        end
    end
end)
menu.action(Mission_Assistant_Pacific, "摩托车：雷克卓 升级无敌", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, 640818791)
    if next(entity_list) ~= nil then
        local i = 0
        for k, ent in pairs(entity_list) do
            RequestControl(ent)
            set_entity_godmode(ent, true)
            upgrade_vehicle(ent)

            if hasControl(ent) then
                i = i + 1
            end
        end
        util.toast("完成！\n数量: " .. tostring(i))
    end
end)
menu.action(Mission_Assistant_Pacific, "终章：摩托车位置 生成骷髅马", {}, "", function()
    local coords = { x = 36.002, y = 94.153, z = 78.751 }
    local head = 249.426
    local hash = util.joaat("kuruma2")
    local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, head)
    if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        upgrade_vehicle(vehicle)
        set_entity_godmode(vehicle, true)
        strong_vehicle(vehicle)
        VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(vehicle, 5.0)
        util.toast("完成！")
    end
end)
menu.action(Mission_Assistant_Pacific, "终章：摩托车位置 生成直升机", {}, "", function()
    local coords = { x = 52.549, y = 88.787, z = 78.683 }
    local head = 15.508
    local hash = util.joaat("polmav")
    local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, head)
    if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        upgrade_vehicle(vehicle)
        set_entity_godmode(vehicle, true)
        strong_vehicle(vehicle)
        VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(vehicle, 5.0)
        util.toast("完成！")
    end
end)

--#endregion Apartment Heist

--#region Doomsday Heist

------ 末日豪劫 ------
menu.divider(Mission_Assistant, "末日豪劫")

local Mission_Assistant_Doomsday_Preps = menu.list(Mission_Assistant, "前置任务", {}, "")

menu.divider(Mission_Assistant_Doomsday_Preps, "末日一: 数据泄露")
menu.action(Mission_Assistant_Doomsday_Preps, "医疗装备：救护车 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, 1171614426)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            RequestControl(ent)
            TP_VEHICLE_TO_ME(ent)

            if not hasControl(ent) then
                util.toast("未能成功控制实体，请重试")
            end
        end
    end
end)
local doomsday_preps_deluxo_menu
local doomsday_preps_deluxo_ent = {} -- 实体列表
doomsday_preps_deluxo_menu = menu.list_action(Mission_Assistant_Doomsday_Preps, "德罗索：载具 传送到我",
    {}, "", { "刷新载具列表" }, function(value)
        if value == 1 then
            local entity_list = get_entities_by_hash("vehicle", true, 1483171323)
            if next(entity_list) ~= nil then
                doomsday_preps_deluxo_ent = {}
                local list_item_data = { "刷新载具列表" }
                local i = 1

                for k, ent in pairs(entity_list) do
                    table.insert(doomsday_preps_deluxo_ent, ent)
                    table.insert(list_item_data, "德罗索 " .. i)
                    i = i + 1
                end

                menu.set_list_action_options(doomsday_preps_deluxo_menu, list_item_data)
                util.toast("已刷新，请重新打开该列表")
            end
        else
            local ent = doomsday_preps_deluxo_ent[value - 1]
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                RequestControl(ent)
                TP_VEHICLE_TO_ME(ent)

                if not hasControl(ent) then
                    util.toast("未能成功控制实体，请重试")
                end
            end
        end
    end)
menu.action(Mission_Assistant_Doomsday_Preps, "德罗索：当前载具 随机主色调", {},
    "无需去改车王改装\n基于Stand命令", function()
        if PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
            local vehicle = entities.get_user_vehicle_as_handle()
            local colour = get_random_colour()
            menu.trigger_commands("vehprimaryred " .. colour.r)
            menu.trigger_commands("vehprimarygreen " .. colour.g)
            menu.trigger_commands("vehprimaryblue " .. colour.b)
        end
    end)
menu.action(Mission_Assistant_Doomsday_Preps, "阿库拉：载具 传送到我", {},
    "需要先去下载飞行数据", function()
        local entity_list = get_entities_by_hash("vehicle", true, 1181327175)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                RequestControl(ent)
                TP_VEHICLE_TO_ME(ent, "", "delete")
                set_entity_godmode(ent, true)

                if not hasControl(ent) then
                    util.toast("未能成功控制实体，请重试")
                end
            end
        end
    end)

menu.divider(Mission_Assistant_Doomsday_Preps, "末日二: 博格丹危机")
menu.action(Mission_Assistant_Doomsday_Preps, "钥匙卡：防暴车 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, -1205689942)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            RequestControl(ent)
            TP_VEHICLE_TO_ME(ent)

            if not hasControl(ent) then
                util.toast("未能成功控制实体，请重试")
            end
        end
    end
end)
menu.action(Mission_Assistant_Doomsday_Preps, "ULP情报：包裹 传送到我", {},
    "先干掉毒贩，下方提示进入公寓后传送", function()
        local entity_list = get_entities_by_hash("pickup", true, -1851147549)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                RequestControl(ent)
                TP_TO_ME(ent)

                if not hasControl(ent) then
                    util.toast("未能成功控制实体，请重试")
                end
            end
        end
    end)
local doomsday_preps_stromberg_menu
local doomsday_preps_stromberg_ent = {} -- 实体列表
doomsday_preps_stromberg_menu = menu.list_action(Mission_Assistant_Doomsday_Preps, "斯特龙伯格：卡车 传送到我",
    {}, "", { "刷新载具列表" }, function(value)
        if value == 1 then
            local entity_list = get_entities_by_hash("object", true, -6020377)
            if next(entity_list) ~= nil then
                doomsday_preps_stromberg_ent = {}
                local list_item_data = { "刷新载具列表" }
                local i = 1

                for k, ent in pairs(entity_list) do
                    if ENTITY.IS_ENTITY_ATTACHED(ent) then
                        local attached_ent = ENTITY.GET_ENTITY_ATTACHED_TO(ent)
                        table.insert(doomsday_preps_stromberg_ent, attached_ent)
                        table.insert(list_item_data, "卡车 " .. i)
                        i = i + 1
                    end
                end

                menu.set_list_action_options(doomsday_preps_stromberg_menu, list_item_data)
                util.toast("已刷新，请重新打开该列表")
            end
        else
            local ent = doomsday_preps_stromberg_ent[value - 1]
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                RequestControl(ent)
                TP_VEHICLE_TO_ME(ent, "", "delete")

                if not hasControl(ent) then
                    util.toast("未能成功控制实体，请重试")
                end
            end
        end
    end)
menu.action(Mission_Assistant_Doomsday_Preps, "鱼雷电控单元：包裹 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("pickup", true, 2096599423)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            RequestControl(ent)
            TP_TO_ME(ent)

            if not hasControl(ent) then
                util.toast("未能成功控制实体，请重试")
            end
        end
    end
end)

menu.divider(Mission_Assistant_Doomsday_Preps, "末日三: 末日将至")
menu.action(Mission_Assistant_Doomsday_Preps, "标记资金：包裹 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("pickup", true, -549235179)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            RequestControl(ent)
            TP_TO_ME(ent)

            if not hasControl(ent) then
                util.toast("未能成功控制实体，请重试")
            end
        end
    end
end)
menu.action(Mission_Assistant_Doomsday_Preps, "切尔诺伯格：载具 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, -692292317)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            RequestControl(ent)
            TP_VEHICLE_TO_ME(ent)

            if not hasControl(ent) then
                util.toast("未能成功控制实体，请重试")
            end
        end
    end
end)
menu.action(Mission_Assistant_Doomsday_Preps, "机载电脑：飞机 传送到我", {},
    "先杀死所有NPC(飞行员)", function()
        local entity_list = get_entities_by_hash("object", true, -82999846)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                if ENTITY.IS_ENTITY_ATTACHED(ent) then
                    local attached_ent = ENTITY.GET_ENTITY_ATTACHED_TO(ent)
                    RequestControl(attached_ent)
                    TP_TO_ME(attached_ent, 0.0, 10.0, 2.0)
                    SET_ENTITY_HEAD_TO_ENTITY(attached_ent, players.user_ped(), 180.0)

                    if not hasControl(attached_ent) then
                        util.toast("未能成功控制实体，请重试")
                    end
                end
            end
        end
    end)


--#endregion Doomsday Heist




----------------
menu.click_slider(Mission_options, "增加任务生命数", { "team_lives" }, "只有是战局主机时才会生效(?)",
    -1, 30000, 0, 1, function(value)
        if IS_SCRIPT_RUNNING("fm_mission_controller") then
            SET_INT_LOCAL("fm_mission_controller", Locals.MC_TLIVES, value)
        elseif IS_SCRIPT_RUNNING("fm_mission_controller_2020") then
            SET_INT_LOCAL("fm_mission_controller_2020", Locals.MC_TLIVES_2020, value)
        else
            util.toast("未进行任务")
        end
    end)
menu.action(Mission_options, "跳过破解", { "skip_hacking" }, "所有的破解、骇入、钻孔等等", function()
    local script = "fm_mission_controller_2020"
    if IS_SCRIPT_RUNNING(script) then
        -- Skip The Hacking Process
        if GET_INT_LOCAL(script, 22032) == 4 then
            SET_INT_LOCAL(script, 22032, 5)
        end
        -- Skip Cutting The Sewer Grill
        if GET_INT_LOCAL(script, 26746) == 4 then
            SET_INT_LOCAL(script, 26746, 6)
        end
        -- Skip Cutting The Glass
        SET_FLOAT_LOCAL(script, 27985 + 3, 100)

        SET_INT_LOCAL(script, 974 + 135, 3) -- For ULP Missions
    end

    script = "fm_mission_controller"
    if IS_SCRIPT_RUNNING(script) then
        -- For Fingerprint
        if GET_INT_LOCAL(script, 52962) ~= 1 then
            SET_INT_LOCAL(script, 52962, 5)
        end
        -- For Keypad
        if GET_INT_LOCAL(script, 54024) ~= 1 then
            SET_INT_LOCAL(script, 54024, 5)
        end
        -- Skip Drilling The Vault Door
        local Value = GET_INT_LOCAL(script, 10098 + 37)
        SET_INT_LOCAL(script, 10098 + 7, Value)

        -- Doomsday Heist
        SET_INT_LOCAL(script, 1508, 3)       -- For ACT I, Setup: Server Farm (Lester)
        SET_INT_LOCAL(script, 1539, 2)
        SET_INT_LOCAL(script, 1265 + 135, 3) -- For ACT III

        -- Fleeca Heist
        SET_INT_LOCAL(script, 11757 + 24, 7)     -- Skip The Hacking Process
        SET_FLOAT_LOCAL(script, 10058 + 11, 100) -- Skip Drilling

        -- Pacific Standard Heist
        SET_LOCAL_BIT(script, 9764, 9) -- Skip The Hacking Process
    end
end)
menu.toggle_loop(Mission_options, "Voltage Hack", { "voltage_hack" }, "", function()
    local script = "fm_mission_controller_2020"
    if IS_SCRIPT_RUNNING(script) then
        -- Infinite Voltage Timer
        local Value = GET_INT_LOCAL(script, 1718)
        SET_INT_LOCAL(script, 1717, Value)
    end
end)
