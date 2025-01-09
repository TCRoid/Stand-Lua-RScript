------------------------------------------
--          Online Options
------------------------------------------


local Online_Options <const> = menu.list(Menu_Root, "线上选项", {}, "")


--#region Player Language

local Player_Language <const> = menu.list(Online_Options, "玩家游戏语言", {}, "")

local player_lang = {
    language = {
        [-1] = "未定义",
        [0] = "英语",
        [1] = "法语",
        [2] = "德语",
        [3] = "意大利语",
        [4] = "西班牙语",
        [5] = "葡萄牙语",
        [6] = "波兰语",
        [7] = "俄语",
        [8] = "韩语",
        [9] = "繁体中文",
        [10] = "日语",
        [11] = "墨西哥语",
        [12] = "简体中文"
    },

    info = {
        max = 4,
        except_user = true,
    },

    menu_list = {},
    notify = true,
}

local Player_Language_Info = menu.list(Player_Language, "信息显示", {}, "")

menu.toggle_loop(Player_Language_Info, "开启", {}, "", function()
    local player_list = players.list()
    if #player_list > 1 and #player_list <= player_lang.info.max then
        local text = ""
        for key, pid in pairs(player_list) do
            if player_lang.info.except_user and pid == players.user() then
            else
                local lang = players.get_language(pid)
                if lang ~= -1 then
                    local name = players.get_name(pid)
                    local lang_text = player_lang.language[lang]

                    if text ~= "" then
                        text = text .. "\n"
                    end
                    text = text .. name .. ": " .. lang_text
                end
            end
        end
        util.draw_debug_text(text)
    end
end)
menu.slider(Player_Language_Info, "战局内最大玩家数量", {}, "超过最大数量则不显示",
    2, 8, 4, 1, function(value)
        player_lang.info.max = value
    end)
menu.toggle(Player_Language_Info, "排除自己", {}, "", function(toggle)
    player_lang.info.except_user = toggle
end, true)


menu.divider(Player_Language, "")
menu.action(Player_Language, "获取玩家语言列表", { "player_language" }, "", function()
    rs_menu.delete_menu_list(player_lang.menu_list)
    player_lang.menu_list = {}

    local text = ""
    for k, pid in pairs(players.list()) do
        local name = players.get_name(pid)
        local rank = players.get_rank(pid)
        local lang = players.get_language(pid)
        local lang_text = player_lang.language[lang]
        local title = name .. " (" .. rank .. "级)"

        player_lang.menu_list[pid] = menu.readonly(Player_Language, title, lang_text)

        if text ~= "" then
            text = text .. "\n"
        end
        text = text .. title .. "     " .. lang_text
    end

    if player_lang.notify then
        util.toast(text)
    end
end)
menu.toggle(Player_Language, "通知", {}, "", function(toggle)
    player_lang.notify = toggle
end, true)

menu.divider(Player_Language, "列表")

--#endregion


--#region Entity Owner

local Entity_Owner <const> = menu.list(Online_Options, "实体控制权", {}, "")

local entity_owner = {
    screen_pos = memory.alloc(8),
    range = 100.0,
    text_size = 0.5,
}

menu.toggle_loop(Entity_Owner, "显示载具控制权", { "DisplayEntityOwner" }, "", function()
    local player_pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())

    for _, vehicle in pairs(entities.get_all_vehicles_as_handles()) do
        if ENTITY.IS_ENTITY_ON_SCREEN(vehicle) and ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(vehicle, players.user_ped(), 17) then
            local ent_pos = ENTITY.GET_ENTITY_COORDS(vehicle)
            if v3.distance(player_pos, ent_pos) <= entity_owner.range then
                if util.get_screen_coord_from_world_coord_no_adjustment(ent_pos.x, ent_pos.y, ent_pos.z, entity_owner.screen_pos, entity_owner.screen_pos + 4) then
                    local screen_x, screen_y = memory.read_float(entity_owner.screen_pos),
                        memory.read_float(entity_owner.screen_pos + 4)

                    local vehicle_name = get_vehicle_display_name(vehicle)
                    local owner = entities.get_owner(vehicle)
                    local screen_text = string.format("%s (%s)", vehicle_name, players.get_name(owner))

                    local text_color = Colors.purple
                    if owner == players.user() then
                        text_color = Colors.green
                    end

                    directx.draw_text(screen_x, screen_y, screen_text, ALIGN_TOP_LEFT, entity_owner.text_size, text_color)
                end
            end
        end
    end
end)

local Entity_Owner_Setting <const> = menu.list(Entity_Owner, "显示设置", {}, "")

menu.slider_float(Entity_Owner_Setting, "范围", { "EntityOwnerRange" }, "",
    0, 1000000, entity_owner.range * 100, 5000, function(value)
        entity_owner.range = value * 0.01
    end)
menu.slider_float(Entity_Owner_Setting, "文字大小", { "EntityOwnerTextSize" }, "",
    10, 500, entity_owner.text_size * 100, 10, function(value)
        entity_owner.text_size = value * 0.01
    end)


menu.divider(Entity_Owner, "当前载具")

menu.toggle_loop(Entity_Owner, "信息显示 当前载具控制权", { "rsInfoVehOwner" }, "", function()
    local vehicle = entities.get_user_vehicle_as_pointer(false)
    if vehicle ~= 0 then
        local owner = get_entity_owner_name(vehicle)
        util.draw_debug_text("当前载具控制权拥有者: " .. owner)
    end
end)

menu.click_slider(Entity_Owner, "请求控制当前载具", { "vehControl" }, "超时时间，单位毫秒",
    500, 5000, 2000, 500, function(value)
        local vehicle = entities.get_user_vehicle_as_pointer(false)
        if vehicle == 0 then
            return
        end

        if entities.request_control(vehicle, value) then
            util.toast("成功")
        else
            local owner = get_entity_owner_name(vehicle)
            util.toast("请求控制当前载具失败\n当前控制权拥有者: " .. owner)
        end
    end)
menu.action(Entity_Owner, "当前载具控制权 给 当前司机", { "vehDriverControl" }, "", function()
    local vehicle = entities.get_user_vehicle_as_handle(false)
    if vehicle == INVALID_GUID then
        return
    end

    local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1, false)
    if driver == players.user_ped() or not has_control_entity(vehicle) then
        return
    end

    if not is_player_ped(driver) then
        return
    end

    entities.give_control(vehicle, get_player_from_ped(driver))
end)


menu.action(Entity_Owner, "所有载具控制权 给 对应司机", {}, "只作用于控制权是自己的载具", function()
    for _, vehicle in pairs(entities.get_all_vehicles_as_handles()) do
        if not VEHICLE.IS_VEHICLE_SEAT_FREE(vehicle, -1, false) and has_control_entity(vehicle) then
            local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1, false)
            if driver ~= players.user_ped() and is_player_ped(driver) then
                entities.give_control(vehicle, get_player_from_ped(driver))
            end
        end
    end
end)


--#endregion


--#region Request Service

local Request_Service <const> = menu.list(Online_Options, "请求服务", {}, "")


local Request_Vehicle_Property <const> = menu.list(Request_Service, "请求服务载具", {}, "")

local VehiclePropertyList = {
    { offset = "bLaunchVehicleDropTruck",           command = "moc",          name = "PIM_TRTV",      help = "PIM_HRTV0" },      -- Request Mobile Operations Center
    { offset = "bLaunchVehicleDropAvenger",         command = "avenger",      name = "PIM_ASRQ",      help = "PIM_AVEN0" },      -- Request Avenger
    { offset = "bLaunchVehicleDropHackerTruck",     command = "terrorbyte",   name = "PIM_HSRQ",      help = "PIM_HTTV0" },      -- Request Terrorbyte
    { offset = "bLaunchVehicleDropSubmarine",       command = "kosatka",      name = "PIM_SUBREQ",    help = "PIMD_SUBREQ" },    -- Request Kosatka
    { offset = "bLaunchVehicleDropSubmarineDinghy", command = "dinghy",       name = "PIM_DINGHYREQ", help = "PIMD_DINGHYREQ" }, -- Request Dinghy
    { offset = "bLaunchVehicleDropAcidLab",         command = "acidLab",      name = "PIM_ALRQB",     help = "PIMD_ALRQ0" },     -- Request Acid Lab
    { offset = "bLaunchVehicleDropSupportBike",     command = "deliveryBike", name = "PIM_ALRQ_PV",   help = "PIMD_ALRQPV0" },   -- Request Delivery Bike
}

for _, item in pairs(VehiclePropertyList) do
    menu.action(Request_Vehicle_Property, util.get_label_text(item.name),
        { "req" .. item.command }, util.get_label_text(item.help), function()
            GLOBAL_SET_BOOL(MPGlobalsAmbience[item.offset], true)
            util.toast("已请求服务载具")
        end)
end


menu.list_action(Request_Service, "重型防弹装甲服务", { "BallisticArmor" }, "", {
    { MPGlobalsAmbience.bLaunchVehicleDropAcidLab, "请求", { "request" } },
    { MPGlobalsAmbience.bEquipBallisticsDrop, "装备", { "equip" } },
    { MPGlobalsAmbience.bRemoveBallisticsDrop, "移除", { "remove" } },
    -- joaat("ex_prop_adv_case_sm")
}, function(value)
    GLOBAL_SET_BOOL(value, true)
end)

menu.divider(Request_Service, "遥控载具")
menu.toggle(Request_Service, "RC 坦克", {}, "", function(toggle)
    GLOBAL_SET_BOOL(MPGlobalsAmbience.bLaunchRCTank, toggle)
end)
menu.toggle(Request_Service, "RC 匪徒", {}, "", function(toggle)
    GLOBAL_SET_BOOL(MPGlobalsAmbience.bLaunchRCBandito, toggle)
end)

menu.divider(Request_Service, "无视犯罪")
menu.toggle_loop(Request_Service, "锁定倒计时", {}, "无视犯罪的倒计时", function()
    GLOBAL_SET_INT(MPGlobalsAmbience.timeCopsDisabled, NETWORK.GET_NETWORK_TIME())
    util.yield(5000)
end)
menu.action(Request_Service, "清空倒计时", {}, "", function()
    GLOBAL_SET_INT(MPGlobalsAmbience.timeCopsDisabled, 0)
end)
menu.action(Request_Service, "警察无视犯罪", { "noCops" }, "莱斯特电话请求", function()
    -- biNoCops_Activated, biNoCops_Personal
    GLOBAL_SET_INT(MPGlobalsAmbience.iLesterDisableCopsBitset, 5)
    GLOBAL_SET_INT(MPGlobalsAmbience.iLesterDisableCopsProg, 0)
    GLOBAL_SET_INT(MPGlobalsAmbience.timeCopsDisabled, NETWORK.GET_NETWORK_TIME())
end)
menu.action(Request_Service, "贿赂当局", {}, "CEO技能", function()
    -- biNoCops_Activated, biNoCops_Gang
    GLOBAL_SET_INT(MPGlobalsAmbience.iLesterDisableCopsBitset, 17)
    GLOBAL_SET_INT(MPGlobalsAmbience.iLesterDisableCopsProg, 0)
    GLOBAL_SET_INT(MPGlobalsAmbience.timeCopsDisabled, NETWORK.GET_NETWORK_TIME())
end)

menu.divider(Request_Service, "倒计时")
menu.click_slider(Request_Service, "贿赂当局 倒计时时间", {}, "单位: 分钟\n切换战局后会失效,需要重新操作",
    1, 60, 2, 1, function(value)
        Tunables.SetInt("GB_BRIBE_AUTHORITIES_DURATION", value * 60 * 1000)
        util.toast("完成！")
    end)
menu.click_slider(Request_Service, "幽灵组织 倒计时时间", {}, "单位: 分钟\n切换战局后会失效,需要重新操作",
    1, 60, 3, 1, function(value)
        Tunables.SetInt("GB_GHOST_ORG_DURATION", value * 60 * 1000)
        util.toast("完成！")
    end)

--#endregion


--#region Remote Computer

local Remote_Computer <const> = menu.list(Online_Options, "远程电脑", {}, "")

local remote_computer_list = {
    { menu_name = "地堡电脑", script = "appbunkerbusiness", command = "bunker" },
    { menu_name = "机库电脑", script = "appsmuggler", command = "hangar" },
    { menu_name = "夜总会电脑", script = "appbusinesshub", command = "nightclub" },
    { menu_name = "摩托帮会所电脑", script = "appbikerbusiness", command = "biker" },
    { menu_name = "游戏厅主控制终端", script = "apparcadebusinesshub", command = "arcade" },
    { menu_name = "恐霸电脑", script = "apphackertruck", command = "terrorbyte" },
    { menu_name = "事务所电脑", script = "appfixersecurity", command = "agency" },
    { menu_name = "复仇者操作终端", script = "appavengeroperations", command = "avenger" },
    -- { menu_name = "办公室电脑", script = "appsecuroserv", command = "office" },
    -- { menu_name = "机动作战指挥中心", script = "appcovertops", command = "moc"  },
    { menu_name = "保金办公室电脑", script = "appbailoffice", command = "bailOffice" },
}

for _, item in pairs(remote_computer_list) do
    menu.action(Remote_Computer, item.menu_name, { "app" .. item.command }, "", function()
        if IS_IN_SESSION() then
            -- GLOBAL_SET_INT(Globals.IsUsingComputerScreen, 1)
            START_SCRIPT(item.script, 5000)
        end
    end)
end

--#endregion


--#region Fast Teleport

local Fast_Teleport <const> = menu.list(Online_Options, "快捷传送", {}, "")

local FastTP = {
    propertyList = {
        { sprite = 557, name = "地堡", command = "bunker" },
        { sprite = 569, name = "机库", command = "hangar" },
        { sprite = 590, name = "设施", command = "facility" },
        { sprite = 614, name = "夜总会", command = "nightclub" },
        { sprite = 740, name = "游戏厅", command = "arcade" },
        { sprite = 779, name = "改装铺", command = "autoshop" },
        { sprite = 826, name = "事务所", command = "agency" },
        { sprite = 475, name = "办公室", command = "office" },
        { sprite = 492, name = "摩托帮会所", command = "biker" },
        { sprite = 867, name = "回收站", command = "salvageYard" },
        { sprite = 893, name = "保金办公室", command = "bailOffice" },
    },
    eventList = {
        { sprite = 430, name = "时间挑战赛", command = "timetrial" },
        { sprite = 673, name = "RC匪徒时间挑战赛", command = "rctimetrial" },
        { sprite = 842, name = "杰拉德包裹", command = "gcaches" },
        { sprite = 845, name = "藏匿屋", command = "stashhouse" },
        { sprite = 860, name = "拉机能量时间挑战赛", command = "junktimetrial" },
        { sprite = 886, name = "玛德拉索雇凶", command = "madrazoHits" },
    },
}

--- @param decoratorName string
--- @return Vehicle
local function get_personal_vehicle_by_decorator(decoratorName)
    local playerHash = NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(players.user())

    for _, vehicle in pairs(entities.get_all_vehicles_as_handles()) do
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(vehicle) then
            if DECORATOR.DECOR_EXIST_ON(vehicle, decoratorName) then
                if DECORATOR.DECOR_GET_INT(vehicle, decoratorName) == playerHash then
                    return vehicle
                end
            end
        end
    end
    return 0
end

menu.divider(Fast_Teleport, "载具资产")
menu.action(Fast_Teleport, "传送到 机动作战中心", { "rstpMoc" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(564)
    if not HUD.DOES_BLIP_EXIST(blip) then
        util.toast("未在地图上找到 机动作战中心")
    end

    local ent = 0
    if HUD.GET_BLIP_COLOUR(blip) == get_org_blip_colour(players.user()) then
        ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
    else
        ent = get_personal_vehicle_by_decorator("Player_Truck")
    end

    if ENTITY.DOES_ENTITY_EXIST(ent) then
        set_entity_heading_to_entity(players.user_ped(), ent)
        tp_to_entity(ent, 0.0, -9.0, -1.0)
    else
        util.toast("未找到 机动作战中心")
    end
end)
menu.action(Fast_Teleport, "传送到 复仇者", { "rstpAvenger" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(589)
    if not HUD.DOES_BLIP_EXIST(blip) then
        util.toast("未在地图上找到 复仇者")
    end

    local ent = 0
    if HUD.GET_BLIP_COLOUR(blip) == get_org_blip_colour(players.user()) then
        ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
    else
        ent = get_personal_vehicle_by_decorator("Player_Avenger")
    end

    if ENTITY.DOES_ENTITY_EXIST(ent) then
        set_entity_heading_to_entity(players.user_ped(), ent)
        tp_to_entity(ent, 0.0, -8.0, 0.0)
    else
        util.toast("未找到 复仇者")
    end
end)
menu.action(Fast_Teleport, "传送到 恐霸", { "rstpTerrorbyte" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(632)
    if not HUD.DOES_BLIP_EXIST(blip) then
        util.toast("未在地图上找到 恐霸")
    end

    local ent = 0
    if HUD.GET_BLIP_COLOUR(blip) == get_org_blip_colour(players.user()) then
        ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
    else
        ent = get_personal_vehicle_by_decorator("Player_Hacker_Truck")
    end

    if ENTITY.DOES_ENTITY_EXIST(ent) then
        set_entity_heading_to_entity(players.user_ped(), ent, 90)
        tp_to_entity(ent, 2.0, 0.0, 0.0)
    else
        util.toast("未找到 恐霸")
    end
end)
menu.action(Fast_Teleport, "传送到 致幻剂实验室", { "rstpAcidlab" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(840)
    if not HUD.DOES_BLIP_EXIST(blip) then
        util.toast("未在地图上找到 致幻剂实验室")
    end

    local ent = 0
    if HUD.GET_BLIP_COLOUR(blip) == get_org_blip_colour(players.user()) then
        ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
    else
        ent = get_personal_vehicle_by_decorator("Player_Acid_Lab")
    end

    if ENTITY.DOES_ENTITY_EXIST(ent) then
        set_entity_heading_to_entity(players.user_ped(), ent)
        tp_to_entity(ent, 3.0, 0.0, 0.0)
    else
        util.toast("未找到 致幻剂实验室")
    end
end)

menu.divider(Fast_Teleport, "资产")
for key, item in pairs(FastTP.propertyList) do
    menu.action(Fast_Teleport, "传送到 " .. item.name, { "rstp" .. item.command }, "", function()
        local blip = HUD.GET_NEXT_BLIP_INFO_ID(item.sprite)
        if HUD.DOES_BLIP_EXIST(blip) then
            if HUD.GET_BLIP_COLOUR(blip) == get_org_blip_colour(players.user()) then
                local coords = HUD.GET_BLIP_COORDS(blip)
                teleport(coords)
            end
        else
            util.toast("未在地图上找到 " .. item.name)
        end
    end)
end

menu.divider(Fast_Teleport, "活动")
for key, item in pairs(FastTP.eventList) do
    menu.action(Fast_Teleport, "传送到 " .. item.name, { "rstp" .. item.command }, "", function()
        local blip = HUD.GET_NEXT_BLIP_INFO_ID(item.sprite)
        if HUD.DOES_BLIP_EXIST(blip) then
            local coords = HUD.GET_BLIP_COORDS(blip)
            teleport(coords)
        else
            util.toast("未在地图上找到 " .. item.name)
        end
    end)
end

--#endregion


--#region Snack Armour

local Snack_Armour <const> = menu.list(Online_Options, "零食和护甲", {}, "")

menu.action(Snack_Armour, "补满全部零食", {}, "", function()
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
menu.action(Snack_Armour, "补满全部护甲", {}, "", function()
    STAT_SET_INT("MP_CHAR_ARMOUR_1_COUNT", 10)
    STAT_SET_INT("MP_CHAR_ARMOUR_2_COUNT", 10)
    STAT_SET_INT("MP_CHAR_ARMOUR_3_COUNT", 10)
    STAT_SET_INT("MP_CHAR_ARMOUR_4_COUNT", 10)
    STAT_SET_INT("MP_CHAR_ARMOUR_5_COUNT", 10)
    util.toast("完成！")
end)
menu.action(Snack_Armour, "补满呼吸器", {}, "", function()
    STAT_SET_INT("BREATHING_APPAR_BOUGHT", 20)
    util.toast("完成！")
end)

local Snack_Editor <const> = menu.list(Snack_Armour, "零食编辑", {}, "")

local Snack_List_Data = {
    { stat = "NO_BOUGHT_YUM_SNACKS", name = "PQ豆", command = "yum", help = "+15 Health", default = 30 },
    { stat = "NO_BOUGHT_HEALTH_SNACKS", name = "宝力旺", command = "health", help = "+45 Health", default = 15 },
    { stat = "NO_BOUGHT_EPIC_SNACKS", name = "麦提来", command = "epic", help = "+30 Health", default = 5 },
    { stat = "NUMBER_OF_ORANGE_BOUGHT", name = "易可乐", command = "orange", help = "+36 Health", default = 10 },
    { stat = "NUMBER_OF_BOURGE_BOUGHT", name = "尿汤啤", command = "bourge", help = "", default = 10 },
    { stat = "NUMBER_OF_CHAMP_BOUGHT", name = "蓝醉香槟", command = "champ", help = "", default = 5 },
    { stat = "CIGARETTES_BOUGHT", name = "香烟", command = "cigarettes", help = "-5 Health", default = 20 },
    { stat = "NUMBER_OF_SPRUNK_BOUGHT", name = "霜碧", command = "sprunk", help = "+36 Health", default = 10 },
}
for _, item in pairs(Snack_List_Data) do
    menu.click_slider(Snack_Editor, item.name, { "snack" .. item.command }, item.help,
        0, 999, item.default, 1, function(value)
            STAT_SET_INT(item.stat, value)
            util.toast("完成！")
        end)
end

local Armour_Editor <const> = menu.list(Snack_Armour, "护甲编辑", {}, "")

local Armour_List_Data = {
    { stat = "MP_CHAR_ARMOUR_1_COUNT", name = "超轻型防弹衣", command = "1", help = "+10 Armour" },
    { stat = "MP_CHAR_ARMOUR_2_COUNT", name = "轻型防弹衣", command = "2", help = "+20 Armour" },
    { stat = "MP_CHAR_ARMOUR_3_COUNT", name = "标准防弹衣", command = "3", help = "+30 Armour" },
    { stat = "MP_CHAR_ARMOUR_4_COUNT", name = "重型防弹衣", command = "4", help = "+40 Armour" },
    { stat = "MP_CHAR_ARMOUR_5_COUNT", name = "超重型防弹衣", command = "5", help = "+50 Armour" },
}
for _, item in pairs(Armour_List_Data) do
    menu.click_slider(Armour_Editor, item.name, { "armour" .. item.command }, item.help,
        0, 999, 10, 1, function(value)
            STAT_SET_INT(item.stat, value)
            util.toast("完成！")
        end)
end


menu.divider(Snack_Armour, "")
menu.click_slider(Snack_Armour, "自定义全部零食数量", { "snackAll" }, "",
    0, 9999, 999, 50, function(value)
        STAT_SET_INT("NO_BOUGHT_YUM_SNACKS", value)
        STAT_SET_INT("NO_BOUGHT_HEALTH_SNACKS", value)
        STAT_SET_INT("NO_BOUGHT_EPIC_SNACKS", value)
        STAT_SET_INT("NUMBER_OF_ORANGE_BOUGHT", value)
        STAT_SET_INT("NUMBER_OF_BOURGE_BOUGHT", value)
        STAT_SET_INT("NUMBER_OF_CHAMP_BOUGHT", value)
        STAT_SET_INT("CIGARETTES_BOUGHT", value)
        STAT_SET_INT("NUMBER_OF_SPRUNK_BOUGHT", value)
        util.toast("完成！")
    end)
menu.click_slider(Snack_Armour, "自定义全部护甲数量", { "armourAll" }, "",
    0, 9999, 999, 50, function(value)
        STAT_SET_INT("MP_CHAR_ARMOUR_1_COUNT", value)
        STAT_SET_INT("MP_CHAR_ARMOUR_2_COUNT", value)
        STAT_SET_INT("MP_CHAR_ARMOUR_3_COUNT", value)
        STAT_SET_INT("MP_CHAR_ARMOUR_4_COUNT", value)
        STAT_SET_INT("MP_CHAR_ARMOUR_5_COUNT", value)
        util.toast("完成！")
    end)

menu.toggle(Snack_Armour, "禁用最大携带量限制", {}, "", function(toggle)
    TunableService.RegisterToggle("DISABLE_STAT_CAP_CHECK", toggle)
end)

--#endregion


--#region Gun Van

local Gun_Van <const> = menu.list(Online_Options, "枪支厢型车", {}, "")


local Gun_Van_List <const> = menu.list(Gun_Van, "厢型车武器列表", {}, "")

for index = 1, 10 do
    local addr = 262145 + TunablesI["XM22_GUN_VAN_SLOT_WEAPON_TYPE_0"] + index
    local weapon_hash = GLOBAL_GET_INT(addr)

    menu.list_select(Gun_Van_List, "Slot " .. index, { "GunVanSlot" .. index }, "",
        Weapon_T.AllWeapons, weapon_hash, function(value)
            GLOBAL_SET_INT(addr, value)
        end)
end

menu.action(Gun_Van, "传送到 枪支厢型车", { "rstpGunVan" }, "", function()
    local location = GLOBAL_GET_INT(Globals.GunVanLocation)
    local pos = Coords_T.GunVan[location]
    if pos then
        teleport2(pos[1], pos[2], pos[3] + 2.0)
    end
end)
menu.action(Gun_Van, "附近生成厢型车", {}, "", function()
    local player_pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    local bool, coords, heading = get_closest_vehicle_node(player_pos, 1)
    if bool then
        local addr = memory.script_global(Globals.GunVanSpawnCoords)
        memory.write_vector3(addr, coords)
        util.toast("完成！")
    end
end)
menu.action(Gun_Van, "重置厢型车位置", {}, "", function()
    local addr = memory.script_global(Globals.GunVanSpawnCoords)
    memory.write_vector3(addr, v3(0, 0, 0))
end)

--#endregion


--#region Street Dealer

local Street_Dealer <const> = menu.list(Online_Options, "街头毒贩", {}, "")

menu.click_slider(Street_Dealer, "传送到 街头毒贩", {}, "", 1, 3, 1, 1, function(value)
    local location = GLOBAL_GET_INT(MPGlobalsAmbience.sStreetDealers.iActiveLocations + 1 + (value - 1) * 7)

    local pos = Coords_T.StreetDealers[location]
    if pos then
        teleport2(pos[1], pos[2], pos[3])
    end
end)
menu.click_slider(Street_Dealer, "可出售货物数量", {}, "需要远离后才可以刷新",
    0, 100, 10, 1, function(value)
        for i = 0, 3, 1 do
            SET_PACKED_STAT_INT_CODE(PackedStats.STREET_DEALER_0_SELL_PRODUCT_TOTAL_COUNT + i, value)
            SET_PACKED_STAT_INT_CODE(PackedStats.STREET_DEALER_1_SELL_PRODUCT_TOTAL_COUNT + i, value)
            SET_PACKED_STAT_INT_CODE(PackedStats.STREET_DEALER_2_SELL_PRODUCT_TOTAL_COUNT + i, value)
        end
    end)

--#endregion


menu.list_select(Online_Options, "战局雪天", { "turnSnow" }, "", {
    { -1, "不更改", { "default" }, "" },
    { 1, "开启", { "on" }, "" },
    { 0, "关闭", { "off" }, "" },
}, -1, function(value)
    if value ~= -1 then
        TunableService.RegisterInt("TURN_SNOW_ON_OFF", value)
    else
        TunableService.RemoveInt("TURN_SNOW_ON_OFF")
    end
end)



local patch_GUNCLUB_UNLOCK_WEAPON = ScriptPatch.New("gunclub_shop", {
    ["IS_GUNSHOP_WEAPON_UNLOCKED"] = {
        pattern = "2D 03 2E 00 00 2C 01 02 82 2A 56",
        offset = 5,
        patch_bytes = ScriptFunc.ReturnBool(true, 3)
    },
    ["IS_GUNSHOP_WEAPON_COMP_UNLOCKED"] = {
        pattern = "2D 02 2E 00 00 38 00 71 58 35 05 2C",
        offset = 5,
        patch_bytes = ScriptFunc.ReturnBool(true, 2)
    },
    ["DOES_GUNSHOP_SUPPORT_MK2_WEAPONS"] = {
        pattern = "2D 01 03 00 00 38 00 65 0A 2E 00 00",
        offset = 5,
        patch_bytes = ScriptFunc.ReturnBool(true, 1)
    }
})

menu.toggle_loop(Online_Options, "解锁武器改装", {}, "", function()
    patch_GUNCLUB_UNLOCK_WEAPON:Enable()
end, function()
    patch_GUNCLUB_UNLOCK_WEAPON:Disable()
end)
