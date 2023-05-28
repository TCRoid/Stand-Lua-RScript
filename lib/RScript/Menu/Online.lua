--------------------------------
------------ 线上选项 -----------
--------------------------------

local Online_options = menu.list(menu.my_root(), "线上选项", {}, "")



---------------------
-- 请求服务
---------------------
local Request_Service = menu.list(Online_options, "请求服务", {}, "")

local Request_Service_Remove = menu.list(Request_Service, "移除冷却时间和费用", {}, "切换战局后会失效，需要重新操作")
menu.toggle(Request_Service_Remove, "CEO技能冷却时间", {}, "", function(toggle)
    if toggle then
        for k, v in pairs(Globals.CEO_Ability.Cooldown) do
            local addr = 262145 + v[1]
            SET_INT_GLOBAL(addr, 0)
        end
    else
        for k, v in pairs(Globals.CEO_Ability.Cooldown) do
            local addr = 262145 + v[1]
            SET_INT_GLOBAL(addr, v[2])
        end
    end
end)
menu.toggle(Request_Service_Remove, "CEO技能费用", {}, "", function(toggle)
    if toggle then
        for k, v in pairs(Globals.CEO_Ability.Cost) do
            local addr = 262145 + v[1]
            SET_INT_GLOBAL(addr, 0)
        end
    else
        for k, v in pairs(Globals.CEO_Ability.Cost) do
            local addr = 262145 + v[1]
            SET_INT_GLOBAL(addr, v[2])
        end
    end
end)
menu.toggle(Request_Service_Remove, "CEO载具请求冷却时间", {}, "", function(toggle)
    if toggle then
        SET_INT_GLOBAL(Globals.GB_CALL_VEHICLE_COOLDOWN, 0)
    else
        SET_INT_GLOBAL(Globals.GB_CALL_VEHICLE_COOLDOWN, 120000)
    end
end)
menu.toggle(Request_Service_Remove, "CEO载具请求费用", {}, "", function(toggle)
    if toggle then
        for k, v in pairs(Globals.CEO_Vehicle_Request_Cost) do
            local addr = 262145 + v[1]
            SET_INT_GLOBAL(addr, 0)
        end
    else
        for k, v in pairs(Globals.CEO_Vehicle_Request_Cost) do
            local addr = 262145 + v[1]
            SET_INT_GLOBAL(addr, v[2])
        end
    end
end)

menu.action(Request_Service, "请求重型装甲", { "ammo_drop" }, "请求弹道装甲和火神机枪",
    function()
        SET_INT_GLOBAL(Globals.Ballistic_Armor, 1)
    end)
menu.action(Request_Service, "重型装甲包裹 传送到我", {}, "", function()
    local entity_model_hash = 1688540826
    for k, ent in pairs(entities.get_all_pickups_as_handles()) do
        local hash = ENTITY.GET_ENTITY_MODEL(ent)
        if hash == entity_model_hash and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            TP_TO_ME(ent, 0.0, 1.0, 0.0)
        end
    end
end)
menu.toggle(Request_Service, "请求RC坦克", {}, "", function(toggle)
    if toggle then
        SET_INT_GLOBAL(Globals.RC_Tank, 1)
    else
        SET_INT_GLOBAL(Globals.RC_Tank, 0)
    end
end)
menu.toggle(Request_Service, "请求RC匪徒", {}, "", function(toggle)
    if toggle then
        SET_INT_GLOBAL(Globals.RC_Bandito, 1)
    else
        SET_INT_GLOBAL(Globals.RC_Bandito, 0)
    end
end)

menu.divider(Request_Service, "无视犯罪")
menu.toggle_loop(Request_Service, "锁定倒计时", {}, "无视犯罪的倒计时", function()
    SET_INT_GLOBAL(Globals.NCOPS.time, NETWORK.GET_NETWORK_TIME())
    util.yield(5000)
end)
menu.action(Request_Service, "警察无视犯罪", { "no_cops" }, "莱斯特电话请求", function()
    SET_INT_GLOBAL(Globals.NCOPS.type, 5)
    SET_INT_GLOBAL(Globals.NCOPS.flag, 1)
    SET_INT_GLOBAL(Globals.NCOPS.time, NETWORK.GET_NETWORK_TIME())
end)
menu.click_slider(Request_Service, "贿赂当局 倒计时时间", {}, "单位:分钟", 1, 60, 2, 1,
    function(value)
        SET_INT_GLOBAL(Globals.GB_BRIBE_AUTHORITIES_DURATION, value * 60 * 1000)
        util.toast("完成！")
    end)
menu.toggle(Request_Service, "贿赂当局", {}, "CEO技能", function(toggle)
    if toggle then
        SET_INT_GLOBAL(Globals.NCOPS.type, 81)
        SET_INT_GLOBAL(Globals.NCOPS.flag, 1)
        SET_INT_GLOBAL(Globals.NCOPS.time, NETWORK.GET_NETWORK_TIME())
    else
        SET_INT_GLOBAL(Globals.NCOPS.time, 0)
    end
end)

menu.divider(Request_Service, "幽灵组织")
menu.click_slider(Request_Service, "倒计时时间", {}, "单位:分钟", 1, 60, 3, 1,
    function(value)
        SET_INT_GLOBAL(Globals.GB_GHOST_ORG_DURATION, value * 60 * 1000)
        util.toast("完成！")
    end)




---------------------
-- 请求载具
---------------------
local Request_Vehicle = menu.list(Online_options, "请求载具", {}, "")

for _, item in pairs(Globals.RequestVehicle) do
    menu.action(Request_Vehicle, item.name, {}, "", function()
        if IS_IN_SESSION() then
            SET_INT_GLOBAL(item.global, 1)
            util.toast("已经请求载具，请等待")
        end
    end)
end




---------------------
-- 资产监视
---------------------
local Business_Monitor = menu.list(Online_options, "资产监视", { "business_monitor" }, "")

local Business = {}

function Business.GetOrgOffset()
    return (1892703 + 1 + (players.user() * 599) + 10)
end

function Business.GetOnlineWorkOffset()
    return (1853910 + 1 + (players.user() * 862) + 267)
end

function Business.GetNightclubValue(slot)
    local offset = Business.GetOnlineWorkOffset() + 310 + 8 + 1 + slot
    return GET_INT_GLOBAL(offset)
end

function Business.GetBusinessSupplies(slot)
    return STAT_GET_INT("MATTOTALFORFACTORY" .. slot)
end

function Business.GetBusinessProduct(slot)
    return STAT_GET_INT("PRODTOTALFORFACTORY" .. slot)
end

Business.Caps = {
    NightClub = {
        [0] = 50,  -- Cargo
        [1] = 100, -- Weapons
        [2] = 10,  -- Cocaine
        [3] = 20,  -- Meth
        [4] = 80,  -- Weed
        [5] = 60,  -- Forgery
        [6] = 40   -- Cash
    },
}

local Business_Monitor_Menu = {
    bunker = {
        supplies,
        product,
        research,
    },
    nightclub = {
        safe_cash,
        popularity,
        product = {
            [0] = { name = "运输货物", menu },
            [1] = { name = "体育用品", menu },
            [2] = { name = "南美进口货", menu },
            [3] = { name = "药学研究产品", menu },
            [4] = { name = "有机农产品", menu },
            [5] = { name = "印刷品", menu },
            [6] = { name = "印钞", menu },
        },
    },
    acid_lab = {
        supplies,
        product,
    },
    arcade_safe_cash,
    agency_safe_cash,
}

menu.action(Business_Monitor, "刷新状态", {}, "", function()
    if IS_IN_SESSION() then
        --- Bunker ---
        local slot = 5
        local text = ""
        text = Business.GetBusinessSupplies(slot) .. "%"
        menu.set_value(Business_Monitor_Menu.bunker.supplies, text)

        text = Business.GetBusinessProduct(slot) .. "/100"
        menu.set_value(Business_Monitor_Menu.bunker.product, text)

        text = STAT_GET_INT("RESEARCHTOTALFORFACTORY5")
        menu.set_value(Business_Monitor_Menu.bunker.research, text)

        --- Nightclub ---
        text = math.floor(STAT_GET_INT('CLUB_POPULARITY') / 10) .. '%'
        menu.set_value(Business_Monitor_Menu.nightclub.popularity, text)
        menu.set_value(Business_Monitor_Menu.nightclub.safe_cash, STAT_GET_INT("CLUB_SAFE_CASH_VALUE"))

        for i = 0, 6 do
            local t = Business.GetNightclubValue(i) .. "/" .. Business.Caps.NightClub[i]
            menu.set_value(Business_Monitor_Menu.nightclub.product[i].menu, t)
        end

        --- Acid Lab ---
        slot = 6
        text = Business.GetBusinessSupplies(slot) .. "%"
        menu.set_value(Business_Monitor_Menu.acid_lab.supplies, text)

        text = Business.GetBusinessProduct(slot) .. "/160"
        menu.set_value(Business_Monitor_Menu.acid_lab.product, text)

        --- Other ---
        menu.set_value(Business_Monitor_Menu.arcade_safe_cash, STAT_GET_INT("ARCADE_SAFE_CASH_VALUE"))
        menu.set_value(Business_Monitor_Menu.agency_safe_cash, STAT_GET_INT("FIXER_SAFE_CASH_VALUE"))
    else
        util.toast("仅在线上模式战局内可用")
    end
end)

menu.divider(Business_Monitor, "地堡")
Business_Monitor_Menu.bunker.supplies = menu.readonly(Business_Monitor, "原材料")
Business_Monitor_Menu.bunker.product = menu.readonly(Business_Monitor, "产品")
Business_Monitor_Menu.bunker.research = menu.readonly(Business_Monitor, "研究")

menu.divider(Business_Monitor, "夜总会")
Business_Monitor_Menu.nightclub.popularity = menu.readonly(Business_Monitor, "夜总会人气")
Business_Monitor_Menu.nightclub.safe_cash  = menu.readonly(Business_Monitor, "保险箱现金")
for i = 0, 6 do
    Business_Monitor_Menu.nightclub.product[i].menu = menu.readonly(Business_Monitor,
        Business_Monitor_Menu.nightclub.product[i].name)
end

menu.divider(Business_Monitor, "致幻剂实验室")
Business_Monitor_Menu.acid_lab.supplies = menu.readonly(Business_Monitor, "原材料")
Business_Monitor_Menu.acid_lab.product = menu.readonly(Business_Monitor, "产品")

menu.divider(Business_Monitor, "其它")
Business_Monitor_Menu.arcade_safe_cash = menu.readonly(Business_Monitor, "游戏厅保险箱现金")
Business_Monitor_Menu.agency_safe_cash = menu.readonly(Business_Monitor, "事务所保险箱现金")




---------------------
-- 远程电脑
---------------------
local Remote_Computer = menu.list(Online_options, "远程电脑", {}, "")

local remote_computer_list = {
    { menu_name = "地堡电脑",             script = "appbunkerbusiness" },
    { menu_name = "机库电脑",             script = "appsmuggler" },
    { menu_name = "夜总会电脑",          script = "appbusinesshub" },
    { menu_name = "摩托帮电脑",          script = "appbikerbusiness" },
    { menu_name = "游戏厅主控制终端", script = "apparcadebusinesshub" },
    { menu_name = "恐霸电脑",             script = "apphackertruck" },
}

for _, item in pairs(remote_computer_list) do
    menu.action(Remote_Computer, item.menu_name, {}, "", function()
        if IS_IN_SESSION() then
            START_SCRIPT(item.script, 5000)
        end
    end)
end




---------------------
-- 玩家语言
---------------------
local Player_Language = menu.list(Online_options, "玩家游戏语言", {}, "")

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

    menu_list = {},
    notify = true,

    session = {
        max_player = 4,
        exclude_sc = true,
    },
}

local Player_Language_Session = menu.list(Player_Language, "进入战局后自动通知", {}, "当玩家进入一个战局后进行通知")

menu.toggle_loop(Player_Language_Session, "开启", {}, "", function()
    util.on_transition_finished(function()
        local player_num = 0
        local text = ""
        for _, pid in pairs(players.list()) do
            local lang = players.get_language(pid)
            if player_lang.session.exclude_sc and lang == 12 then
            else
                local lang_text = player_lang.language[lang]
                local name      = players.get_name(pid)
                local rank      = players.get_rank(pid)
                local title     = name .. " (" .. rank .. "级)"

                if text ~= "" then
                    text = text .. "\n"
                end
                text       = text .. title .. "     " .. lang_text .. "\n"
                player_num = player_num + 1
            end
        end

        if player_num <= player_lang.session.max_player then
            util.toast(text)
        end
    end)
end)
menu.slider(Player_Language_Session, "玩家最多人数", {}, "战局内玩家人数少于等于指定人数时才进行通知",
    2, 32, 4, 1, function(value)
        player_lang.session.max_player = value
    end)
menu.toggle(Player_Language_Session, "排除 简体中文", {}, "", function(toggle)
    player_lang.session.exclude_sc = toggle
end, true)


menu.action(Player_Language, "获取玩家语言列表", { "player_language" }, "", function()
    for k, v in pairs(player_lang.menu_list) do
        if menu.is_ref_valid(v) then
            menu.delete(v)
        end
    end
    player_lang.menu_list = {}

    local text = ""
    for k, pid in pairs(players.list()) do
        local name                 = players.get_name(pid)
        local rank                 = players.get_rank(pid)
        local lang                 = players.get_language(pid)
        local lang_text            = player_lang.language[lang]
        local title                = name .. " (" .. rank .. "级)"

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
