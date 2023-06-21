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
menu.action(Request_Service, "清空倒计时", {}, "", function()
    SET_INT_GLOBAL(Globals.NCOPS.time, 0)
end)
menu.action(Request_Service, "警察无视犯罪", { "no_cops" }, "莱斯特电话请求", function()
    SET_INT_GLOBAL(Globals.NCOPS.type, 5)
    SET_INT_GLOBAL(Globals.NCOPS.flag, 1)
    SET_INT_GLOBAL(Globals.NCOPS.time, NETWORK.GET_NETWORK_TIME())
end)
menu.toggle_loop(Request_Service, "贿赂当局", {}, "CEO技能", function()
    SET_INT_GLOBAL(Globals.NCOPS.type, 81)
    SET_INT_GLOBAL(Globals.NCOPS.flag, 1)
    SET_INT_GLOBAL(Globals.NCOPS.time, NETWORK.GET_NETWORK_TIME())
    util.yield(5000)
end, function()
    SET_INT_GLOBAL(Globals.NCOPS.time, 0)
end)

menu.divider(Request_Service, "倒计时")
menu.click_slider(Request_Service, "贿赂当局 倒计时时间", {}, "单位: 分钟\n切换战局后会失效，需要重新操作",
    1, 60, 2, 1, function(value)
        SET_INT_GLOBAL(Globals.GB_BRIBE_AUTHORITIES_DURATION, value * 60 * 1000)
        util.toast("完成！")
    end)
menu.click_slider(Request_Service, "幽灵组织 倒计时时间", {}, "单位: 分钟\n切换战局后会失效，需要重新操作",
    1, 60, 3, 1, function(value)
        SET_INT_GLOBAL(Globals.GB_GHOST_ORG_DURATION, value * 60 * 1000)
        util.toast("完成！")
    end)




---------------------
-- 资产监视
---------------------
local Business_Monitor = menu.list(Online_options, "资产监视", { "business_monitor" }, "")

local Business = {
    Caps = {
        NightClub = {
            [0] = 50,  -- Cargo
            [1] = 100, -- Weapons
            [2] = 10,  -- Cocaine
            [3] = 20,  -- Meth
            [4] = 80,  -- Weed
            [5] = 60,  -- Forgery
            [6] = 40   -- Cash
        },
        MCBusiness = {
            [0] = 60, -- Forgery
            [1] = 80, -- Weed
            [2] = 40, -- Cash
            [3] = 20, -- Meth
            [4] = 10  -- Cocaine
        },
    },
}

function Business.GetNightclubValue(slot)
    return STAT_GET_INT("HUB_PROD_TOTAL_" .. slot)
end

function Business.GetBusinessSupplies(slot)
    return STAT_GET_INT("MATTOTALFORFACTORY" .. slot)
end

function Business.GetBusinessProduct(slot)
    return STAT_GET_INT("PRODTOTALFORFACTORY" .. slot)
end

Business.Menu = {
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
    safe_cash = {
        arcade,
        agency,
    },
    mc_business = {
        [0] = { name = "伪造证件", supplies, product },
        [1] = { name = "大麻", supplies, product },
        [2] = { name = "假钞", supplies, product },
        [3] = { name = "冰毒", supplies, product },
        [4] = { name = "可卡因", supplies, product },
    },
}

menu.action(Business_Monitor, "刷新状态", {}, "", function()
    if IS_IN_SESSION() then
        local text = ""
        local product = 0
        --- Bunker ---
        text = Business.GetBusinessSupplies(5) .. "%"
        menu.set_value(Business.Menu.bunker.supplies, text)

        product = Business.GetBusinessProduct(5)
        text = product .. "/100"
        if product == 100 then
            text = "[!] " .. text
        end
        menu.set_value(Business.Menu.bunker.product, text)

        text = STAT_GET_INT("RESEARCHTOTALFORFACTORY5")
        menu.set_value(Business.Menu.bunker.research, text)

        --- Nightclub ---
        text = math.floor(STAT_GET_INT('CLUB_POPULARITY') / 10) .. '%'
        menu.set_value(Business.Menu.nightclub.popularity, text)
        menu.set_value(Business.Menu.nightclub.safe_cash, STAT_GET_INT("CLUB_SAFE_CASH_VALUE"))

        for i = 0, 6 do
            product = Business.GetNightclubValue(i)
            text = product .. "/" .. Business.Caps.NightClub[i]
            if product == Business.Caps.NightClub[i] then
                text = "[!] " .. text
            end
            menu.set_value(Business.Menu.nightclub.product[i].menu, text)
        end

        --- Acid Lab ---
        text = Business.GetBusinessSupplies(6) .. "%"
        menu.set_value(Business.Menu.acid_lab.supplies, text)

        product = Business.GetBusinessProduct(6)
        text = product .. "/160"
        if product == 160 then
            text = "[!] " .. text
        end
        menu.set_value(Business.Menu.acid_lab.product, text)

        --- Safe Cash ---
        menu.set_value(Business.Menu.safe_cash.arcade, STAT_GET_INT("ARCADE_SAFE_CASH_VALUE"))
        menu.set_value(Business.Menu.safe_cash.agency, STAT_GET_INT("FIXER_SAFE_CASH_VALUE"))

        --- MCBusiness ---
        for i = 0, 4 do
            text = Business.GetBusinessSupplies(i) .. "%"
            menu.set_value(Business.Menu.mc_business[i].supplies, text)

            product = Business.GetBusinessProduct(i)
            text = product .. "/" .. Business.Caps.MCBusiness[i]
            if product == Business.Caps.MCBusiness[i] then
                text = "[!] " .. text
            end
            menu.set_value(Business.Menu.mc_business[i].product, text)
        end
    else
        util.toast("仅在线上模式战局内可用")
    end
end)

menu.divider(Business_Monitor, "地堡")
Business.Menu.bunker.supplies = menu.readonly(Business_Monitor, "原材料")
Business.Menu.bunker.product = menu.readonly(Business_Monitor, "产品")
Business.Menu.bunker.research = menu.readonly(Business_Monitor, "研究")

menu.divider(Business_Monitor, "夜总会")
Business.Menu.nightclub.popularity = menu.readonly(Business_Monitor, "夜总会人气")
Business.Menu.nightclub.safe_cash  = menu.readonly(Business_Monitor, "保险箱现金")
for i = 0, 6 do
    Business.Menu.nightclub.product[i].menu = menu.readonly(Business_Monitor,
        Business.Menu.nightclub.product[i].name)
end

menu.divider(Business_Monitor, "致幻剂实验室")
Business.Menu.acid_lab.supplies = menu.readonly(Business_Monitor, "原材料")
Business.Menu.acid_lab.product = menu.readonly(Business_Monitor, "产品")

menu.divider(Business_Monitor, "保险箱现金")
Business.Menu.safe_cash.arcade = menu.readonly(Business_Monitor, "游戏厅")
Business.Menu.safe_cash.agency = menu.readonly(Business_Monitor, "事务所")

menu.divider(Business_Monitor, "")
local Business_Monitor_MC = menu.list(Business_Monitor, "摩托帮工厂", {}, "")
for i = 0, 4 do
    menu.divider(Business_Monitor_MC, Business.Menu.mc_business[i].name)
    Business.Menu.mc_business[i].supplies = menu.readonly(Business_Monitor_MC, "原材料")
    Business.Menu.mc_business[i].product = menu.readonly(Business_Monitor_MC, "产品")
end



---------------------
-- 资产统计数据
---------------------
local Business_Stats = menu.list(Online_options, "资产统计数据", {}, "")

local BusinessStats = {
    Bunker = {
        [1] = { name = "总营收", stat = "LIFETIME_BKR_SELL_EARNINGS5", menu },
        [2] = { name = "送达原材料次数", stat = "LFETIME_BIKER_BUY_COMPLET5", menu },
        [3] = { name = "开启原材料任务次数", stat = "LFETIME_BIKER_BUY_UNDERTA5", menu },
        [4] = { name = "成功卖货次数", stat = "LFETIME_BIKER_SELL_COMPLET5", menu },
        [5] = { name = "开启卖货任务次数", stat = "LFETIME_BIKER_SELL_UNDERTA5", menu },
    },
    SpecialCargo = {
        [1] = { name = "总营收", stat = "LIFETIME_CONTRA_EARNINGS", menu },
        [2] = { name = "成功拉货次数", stat = "LIFETIME_BUY_COMPLETE", menu },
        [3] = { name = "开启拉货任务次数", stat = "LIFETIME_BUY_UNDERTAKEN", menu },
        [4] = { name = "成功卖货次数", stat = "LIFETIME_SELL_COMPLETE", menu },
        [5] = { name = "开启卖货任务次数", stat = "LIFETIME_SELL_UNDERTAKEN", menu },
    },
}

menu.action(Business_Stats, "刷新状态", {}, "", function()
    if IS_IN_SESSION() then
        for i = 1, 5 do
            local stat = BusinessStats.Bunker[i].stat
            local menu_ = BusinessStats.Bunker[i].menu
            menu.set_value(menu_, STAT_GET_INT(stat))

            stat = BusinessStats.SpecialCargo[i].stat
            menu_ = BusinessStats.SpecialCargo[i].menu
            menu.set_value(menu_, STAT_GET_INT(stat))
        end
    else
        util.toast("仅在线上模式战局内可用")
    end
end)

menu.divider(Business_Stats, "地堡")
for i = 1, 5 do
    BusinessStats.Bunker[i].menu = menu.readonly(Business_Stats, BusinessStats.Bunker[i].name)
end

menu.divider(Business_Stats, "特种货物")
for i = 1, 5 do
    BusinessStats.SpecialCargo[i].menu = menu.readonly(Business_Stats, BusinessStats.SpecialCargo[i].name)
end



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
}

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




----------
menu.toggle(Online_options, "战局雪天", { "turn_snow" }, "切换战局后会失效，需要重新操作",
    function(toggle)
        if toggle then
            SET_INT_GLOBAL(Globals.TURN_SNOW_ON_OFF, 1)
        else
            SET_INT_GLOBAL(Globals.TURN_SNOW_ON_OFF, 0)
        end
    end)
menu.click_slider_float(Online_options, "AI血量", { "ai_health" }, "切换战局后会失效，需要重新操作",
    0, 1000, 100, 10, function(value)
        SET_FLOAT_GLOBAL(Globals.AI_HEALTH, value * 0.01)
    end)

