------------------------------------------
--          Other Options
------------------------------------------


local Other_Options <const> = menu.list(Menu_Root, "其它选项", {}, "")


Dev_Options = menu.list(Other_Options, "开发者选项", {}, "")


--#region Local Editor

local Local_Editor <const> = menu.list(Other_Options, "Local Editor", { "LocalEditor" }, "")

local LocalEditor = {
    Menu = {},

    script = "",
    address1 = 0,
    address2 = 0,

    type = "int",
    write = "",

    Lock = {},
}

function LocalEditor.checkScript(script)
    if script == "" then
        util.toast("请先选择脚本")
        return false
    end

    if not IS_SCRIPT_RUNNING(script) then
        util.toast("该脚本未运行")
        return false
    end

    return true
end

LocalEditor.Menu.SelectScript = menu.list(Local_Editor, "选择脚本: 未选择", {}, "")

menu.text_input(LocalEditor.Menu.SelectScript, "输入脚本名称", { "LocalScriptName" }, "",
    function(value, click_type)
        if value == "" then
            LocalEditor.script = ""
            menu.set_menu_name(LocalEditor.Menu.SelectScript, "选择脚本: 未选择")
            return
        end

        if not SCRIPT.DOES_SCRIPT_EXIST(value) then
            util.toast("不存在该脚本")
            return
        end

        LocalEditor.script = value
        menu.set_menu_name(LocalEditor.Menu.SelectScript, "选择脚本: " .. LocalEditor.script)
    end)
menu.list_action(LocalEditor.Menu.SelectScript, "常用脚本列表", {}, "", {
    { 1, "fm_mission_controller" },
    { 2, "fm_mission_controller_2020" },
    { 3, "freemode" },
}, function(index, name)
    menu.trigger_commands("LocalScriptName " .. name)
end)


menu.slider(Local_Editor, "地址1", { "LocalAddr1" }, "",
    0, HIGHEST_INT, 0, 1, function(value)
        LocalEditor.address1 = value
    end)
menu.slider(Local_Editor, "地址2", { "LocalAddr2" }, "",
    0, HIGHEST_INT, 0, 1, function(value)
        LocalEditor.address2 = value
    end)
menu.list_select(Local_Editor, "数值类型", {}, "", {
    { 1, "INT" },
    { 2, "FLOAT" }
}, 1, function(value, name)
    LocalEditor.type = string.lower(name)
end)


menu.divider(Local_Editor, "读")
menu.action(Local_Editor, "读取", {}, "", function()
    local script = LocalEditor.script
    local address = LocalEditor.address1 + LocalEditor.address2
    local dataType = LocalEditor.type

    if not LocalEditor.checkScript(script) then
        return
    end

    local value
    if dataType == "int" then
        value = LOCAL_GET_INT(script, address)
    elseif dataType == "float" then
        value = LOCAL_GET_FLOAT(script, address)
    end

    if value ~= nil then
        menu.set_value(LocalEditor.Menu.Value, value)
    else
        menu.set_value(LocalEditor.Menu.Value, "NULL")
    end
end)
LocalEditor.Menu.Value = menu.readonly(Local_Editor, "值")

menu.divider(Local_Editor, "写")
menu.text_input(Local_Editor, "要写入的值", { "LocalWriteValue" }, "务必注意int类型和float类型的格式", function(value, click_type)
    if click_type == CLICK_BULK then return end

    value = tonumber(value)
    if value == nil then
        util.toast("数值格式错误")
        return
    end
    LocalEditor.write = value
end)
menu.action(Local_Editor, "写入", {}, "", function()
    local script = LocalEditor.script
    local address = LocalEditor.address1 + LocalEditor.address2
    local dataType = LocalEditor.type
    local value = tonumber(LocalEditor.write)

    if value == nil then
        util.toast("请输入要写入的值")
        return
    end

    if not LocalEditor.checkScript(script) then
        return
    end

    if dataType == "int" then
        LOCAL_SET_INT(script, address, value)
    elseif dataType == "float" then
        LOCAL_SET_FLOAT(script, address, value)
    end
end)


menu.divider(Local_Editor, "锁定")
menu.action(Local_Editor, "锁定写入", {}, "", function()
    local script = LocalEditor.script
    local address = LocalEditor.address1 + LocalEditor.address2
    local dataType = LocalEditor.type
    local value = tonumber(LocalEditor.write)

    if value == nil then
        util.toast("请输入要写入的值")
        return
    end

    if not LocalEditor.checkScript(script) then
        return
    end

    local menu_name = string.format("Local_%s = %s (%s)", address, value, script)
    local help_name = string.format("Script: %s\nType: %s", script, dataType)
    local menu_toggle_loop = menu.toggle_loop(LocalEditor.Menu.Lock, menu_name, {}, help_name, function()
        if not IS_SCRIPT_RUNNING(script) then
            return
        end

        if dataType == "int" then
            LOCAL_SET_INT(script, address, value)
        elseif dataType == "float" then
            LOCAL_SET_FLOAT(script, address, value)
        end
    end)
    menu.set_value(menu_toggle_loop, true)

    table.insert(LocalEditor.Lock, menu_toggle_loop)
    util.toast("已添加到锁定写入列表")
end)
LocalEditor.Menu.Lock = menu.list(Local_Editor, "锁定写入列表", {}, "")
menu.action(LocalEditor.Menu.Lock, "清空列表", {}, "", function()
    for _, command in pairs(LocalEditor.Lock) do
        menu.default_and_delete(command)
    end
    menu.collect_garbage()
    LocalEditor.Lock = {}
end)

--#endregion



--#region Global Editor

local Global_Editor <const> = menu.list(Other_Options, "Global Editor", { "GlobalEditor" }, "")

local GlobalEditor = {
    Menu = {},

    address1 = 262145,
    address2 = 0,

    type = "int",
    write = "",

    Lock = {},
}

menu.slider(Global_Editor, "地址1", { "GlobalAddr1" }, "",
    0, HIGHEST_INT, 262145, 1, function(value)
        GlobalEditor.address1 = value
    end)
menu.slider(Global_Editor, "地址2", { "GlobalAddr2" }, "",
    0, HIGHEST_INT, 0, 1, function(value)
        GlobalEditor.address2 = value
    end)
menu.list_select(Global_Editor, "数值类型", {}, "", {
    { 1, "INT" }, { 2, "FLOAT" }
}, 1, function(value, name)
    GlobalEditor.type = string.lower(name)
end)

menu.divider(Global_Editor, "读")
menu.action(Global_Editor, "读取", {}, "", function()
    local address = GlobalEditor.address1 + GlobalEditor.address2
    local dataType = GlobalEditor.type

    local value
    if dataType == "int" then
        value = GLOBAL_GET_INT(address)
    elseif dataType == "float" then
        value = GLOBAL_GET_FLOAT(address)
    end

    if value ~= nil then
        menu.set_value(GlobalEditor.Menu.Value, value)
    else
        menu.set_value(GlobalEditor.Menu.Value, "NULL")
    end
end)
GlobalEditor.Menu.Value = menu.readonly(Global_Editor, "值")

menu.divider(Global_Editor, "写")
menu.text_input(Global_Editor, "要写入的值", { "GlobalWriteValue" }, "务必注意int类型和float类型的格式", function(value, click_type)
    if click_type == CLICK_BULK then return end

    value = tonumber(value)
    if value == nil then
        util.toast("数值格式错误")
        return
    end
    GlobalEditor.write = value
end)
menu.action(Global_Editor, "写入", {}, "", function()
    local address = GlobalEditor.address1 + GlobalEditor.address2
    local dataType = GlobalEditor.type
    local value = tonumber(GlobalEditor.write)

    if value == nil then
        util.toast("请输入要写入的值")
        return
    end

    if dataType == "int" then
        GLOBAL_SET_INT(address, value)
    elseif dataType == "float" then
        GLOBAL_SET_FLOAT(address, value)
    end
end)


menu.divider(Global_Editor, "锁定")
menu.action(Global_Editor, "锁定写入", {}, "", function()
    local address = GlobalEditor.address1 + GlobalEditor.address2
    local dataType = GlobalEditor.type
    local value = tonumber(GlobalEditor.write)

    if value == nil then
        util.toast("请输入要写入的值")
        return
    end

    local menu_name = string.format("Global_%s = %s", address, value)
    local menu_toggle_loop = menu.toggle_loop(GlobalEditor.Menu.Lock, menu_name, {}, "", function()
        if dataType == "int" then
            GLOBAL_SET_INT(address, value)
        elseif dataType == "float" then
            GLOBAL_SET_FLOAT(address, value)
        end
    end)
    menu.set_value(menu_toggle_loop, true)

    table.insert(GlobalEditor.Lock, menu_toggle_loop)
    util.toast("已添加到锁定写入列表")
end)
GlobalEditor.Menu.Lock = menu.list(Global_Editor, "锁定写入列表", {}, "")
menu.action(GlobalEditor.Menu.Lock, "清空列表", {}, "", function()
    for _, command in pairs(GlobalEditor.Lock) do
        menu.default_and_delete(command)
    end
    menu.collect_garbage()
    GlobalEditor.Lock = {}
end)

--#endregion




local nophonespam = menu.ref_by_path("Game>Disables>Straight To Voicemail", 55)
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
menu.toggle_loop(Other_Options, "跳到下一条对话", { "skipTalk" }, "快速跳过对话", function()
    if AUDIO.IS_SCRIPTED_CONVERSATION_ONGOING() then
        AUDIO.SKIP_TO_NEXT_SCRIPTED_CONVERSATION_LINE()
    end
end)
menu.toggle_loop(Other_Options, "停止对话", { "stopTalk" }, "快速跳过对话", function()
    if AUDIO.IS_SCRIPTED_CONVERSATION_ONGOING() then
        AUDIO.STOP_SCRIPTED_CONVERSATION(false)
    end
end)
menu.toggle_loop(Other_Options, "自动收集财物", { "autoCollect" }, "模拟鼠标左键点击,用于拿取目标财物时", function()
    if TASK.GET_IS_TASK_ACTIVE(players.user_ped(), 135) then
        PAD.SET_CONTROL_VALUE_NEXT_FRAME(0, 237, 1)
        util.yield(30)
    end
end)
menu.toggle_loop(Other_Options, "步行时第一/三人称快捷切换", { "footCamView" }, "步行时第一人称视角和第三人称近距离视角快捷切换", function()
    if CAM.IS_FOLLOW_PED_CAM_ACTIVE() then
        if CAM.GET_FOLLOW_PED_CAM_VIEW_MODE() == 1 or CAM.GET_FOLLOW_PED_CAM_VIEW_MODE() == 2 then
            CAM.SET_FOLLOW_PED_CAM_VIEW_MODE(4)
        end
    end
end)
menu.action(Other_Options, "清除帮助文本信息", { "clsHelpMsg" }, "", function()
    HUD.CLEAR_ALL_HELP_MESSAGES()
end)


menu.action(Other_Options, "EXPLODE_VEHICLE_IN_CUTSCENE", { "cutExplodeVeh" }, "", function()
    for _, vehicle in pairs(entities.get_all_vehicles_as_handles()) do
        if vehicle ~= entities.get_user_personal_vehicle_as_handle() then
            request_control(vehicle, 500)
            VEHICLE.EXPLODE_VEHICLE_IN_CUTSCENE(vehicle, false)
        end
    end
end)

