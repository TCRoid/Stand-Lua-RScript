------------------------------------------
----------    Online Options    ----------
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
                    local name      = players.get_name(pid)
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

--#endregion


--#region Request Service

local Request_Service <const> = menu.list(Online_Options, "请求服务", {}, "")

local Request_Service_Cooldown <const> = menu.list(Request_Service, "移除冷却时间", {}, "")
menu.toggle(Request_Service_Cooldown, "CEO技能", {}, "", function(toggle)
    Globals.RemoveCooldown.CeoAbility(toggle)
    Loop_Handler.Tunables.Cooldown.CeoAbility = toggle
end)
menu.toggle(Request_Service_Cooldown, "CEO载具请求", {}, "", function(toggle)
    if toggle then
        SET_INT_GLOBAL(Globals.GB_CALL_VEHICLE_COOLDOWN, 0)
    else
        SET_INT_GLOBAL(Globals.GB_CALL_VEHICLE_COOLDOWN, 120000)
    end
    Loop_Handler.Tunables.Cooldown.CeoVehicle = toggle
end)
menu.toggle(Request_Service_Cooldown, "其它载具请求", {}, "", function(toggle)
    Globals.RemoveCooldown.OtherVehicle(toggle)
    Loop_Handler.Tunables.Cooldown.OtherVehicle = toggle
end)

local Request_Vehicle_Property <const> = menu.list(Request_Service, "请求载具资产", {}, "")
for _, item in pairs(Globals.Request.VehicleProperty) do
    menu.action(Request_Vehicle_Property, "请求 " .. item.name, { "req" .. item.command }, "", function()
        SET_INT_GLOBAL(item.global, 1)
        util.toast("已请求载具 " .. item.name)
    end)
end

menu.action(Request_Service, "请求重型装甲", { "ammo_drop" }, "请求弹道装甲和火神机枪",
    function()
        SET_INT_GLOBAL(Globals.BallisticArmor, 1)
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
menu.click_slider(Request_Service, "贿赂当局 倒计时时间", {}, "单位: 分钟\n切换战局后会失效,需要重新操作",
    1, 60, 2, 1, function(value)
        SET_INT_GLOBAL(Globals.GB_BRIBE_AUTHORITIES_DURATION, value * 60 * 1000)
        util.toast("完成！")
    end)
menu.click_slider(Request_Service, "幽灵组织 倒计时时间", {}, "单位: 分钟\n切换战局后会失效,需要重新操作",
    1, 60, 3, 1, function(value)
        SET_INT_GLOBAL(Globals.GB_GHOST_ORG_DURATION, value * 60 * 1000)
        util.toast("完成！")
    end)

--#endregion


--#region Business Monitor

local Business_Monitor <const> = menu.list(Online_Options, "资产监视", { "business_monitor" }, "")

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
        Bunker = 100,
        AcidLab = 160,
        Warehouse = {
            [1]  = 16,  -- "MP_WHOUSE_0",
            [2]  = 16,  -- "MP_WHOUSE_1",
            [3]  = 16,  -- "MP_WHOUSE_2",
            [4]  = 16,  -- "MP_WHOUSE_3",
            [5]  = 16,  -- "MP_WHOUSE_4",
            [6]  = 111, -- "MP_WHOUSE_5",
            [7]  = 42,  -- "MP_WHOUSE_6",
            [8]  = 111, -- "MP_WHOUSE_7",
            [9]  = 16,  -- "MP_WHOUSE_8",
            [10] = 42,  -- "MP_WHOUSE_9",
            [11] = 42,  -- "MP_WHOUSE_10",
            [12] = 42,  -- "MP_WHOUSE_11",
            [13] = 42,  -- "MP_WHOUSE_12",
            [14] = 42,  -- "MP_WHOUSE_13",
            [15] = 42,  -- "MP_WHOUSE_14",
            [16] = 111, -- "MP_WHOUSE_15",
            [17] = 111, -- "MP_WHOUSE_16",
            [18] = 111, -- "MP_WHOUSE_17",
            [19] = 111, -- "MP_WHOUSE_18",
            [20] = 111, -- "MP_WHOUSE_19",
            [21] = 42,  -- "MP_WHOUSE_20",
            [22] = 111, -- "MP_WHOUSE_21",
        }
    },
    SafeCash = {
        NightClub = 250000,
        Arcade = 100000,
        Agency = 250000,
    },
}

function Business.GetBusinessSupplies(slot)
    return STAT_GET_INT("MATTOTALFORFACTORY" .. slot)
end

function Business.GetBusinessProduct(slot)
    return STAT_GET_INT("PRODTOTALFORFACTORY" .. slot)
end

function Business.MCBusinessPropertyType(slot)
    local mapping  = {
        [0]  = -1,
        [1]  = 3,
        [2]  = 1,
        [3]  = 4,
        [4]  = 2,
        [5]  = 0,
        [6]  = 3,
        [7]  = 1,
        [8]  = 4,
        [9]  = 2,
        [10] = 0,
        [11] = 3,
        [12] = 1,
        [13] = 4,
        [14] = 2,
        [15] = 0,
        [16] = 3,
        [17] = 1,
        [18] = 4,
        [19] = 2,
        [20] = 0
    }
    local property = STAT_GET_INT("factoryslot" .. slot) -- returns a property ID number
    return mapping[property]
end

Business.Menu = {
    bunker = {},
    nightclub = {
        product = {
            [0] = { name = "运输货物" },
            [1] = { name = "体育用品" },
            [2] = { name = "南美进口货" },
            [3] = { name = "药学研究产品" },
            [4] = { name = "有机农产品" },
            [5] = { name = "印刷品" },
            [6] = { name = "印钞" },
        },
    },
    acid_lab = {},
    safe_cash = {},
    mc_business = {
        [0] = { name = "伪造证件" },
        [1] = { name = "大麻" },
        [2] = { name = "假钞" },
        [3] = { name = "冰毒" },
        [4] = { name = "可卡因" },
    },
    special_cargo = {}
}

menu.action(Business_Monitor, "刷新状态", {}, "", function()
    if IS_IN_SESSION() then
        local text = ""
        local product = 0
        --- Bunker ---
        text = Business.GetBusinessSupplies(5) .. "%"
        menu.set_value(Business.Menu.bunker.supplies, text)

        product = Business.GetBusinessProduct(5)
        text = product .. "/" .. Business.Caps.Bunker
        if product == Business.Caps.Bunker then
            text = "[!] " .. text
        end
        menu.set_value(Business.Menu.bunker.product, text)

        text = STAT_GET_INT("RESEARCHTOTALFORFACTORY5") .. "/60"
        menu.set_value(Business.Menu.bunker.research, text)

        --- Nightclub ---
        text = math.floor(STAT_GET_INT('CLUB_POPULARITY') / 10) .. '%'
        menu.set_value(Business.Menu.nightclub.popularity, text)

        text = STAT_GET_INT("CLUB_SAFE_CASH_VALUE")
        if text == Business.SafeCash.NightClub then
            text = "[!] " .. text
        end
        menu.set_value(Business.Menu.nightclub.safe_cash, text)

        for i = 0, 6 do
            product = STAT_GET_INT("HUB_PROD_TOTAL_" .. i)
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
        text = product .. "/" .. Business.Caps.AcidLab
        if product == Business.Caps.AcidLab then
            text = "[!] " .. text
        end
        menu.set_value(Business.Menu.acid_lab.product, text)

        --- Safe Cash ---
        text = STAT_GET_INT("ARCADE_SAFE_CASH_VALUE")
        if text == Business.SafeCash.Arcade then
            text = "[!] " .. text
        end
        menu.set_value(Business.Menu.safe_cash.arcade, text)

        text = STAT_GET_INT("FIXER_SAFE_CASH_VALUE")
        if text == Business.SafeCash.Agency then
            text = "[!] " .. text
        end
        menu.set_value(Business.Menu.safe_cash.agency, text)

        --- MC Business ---
        for i = 0, 4 do
            local type_number = Business.MCBusinessPropertyType(i)
            if type_number ~= -1 then
                text = Business.GetBusinessSupplies(i) .. "%"
                menu.set_value(Business.Menu.mc_business[type_number].supplies, text)

                product = Business.GetBusinessProduct(i)
                text = product .. "/" .. Business.Caps.MCBusiness[type_number]
                if product == Business.Caps.MCBusiness[type_number] then
                    text = "[!] " .. text
                end
                menu.set_value(Business.Menu.mc_business[type_number].product, text)
            end
        end

        --- Special Cargo ---
        for i = 0, 4 do
            local warehouse_slot = STAT_GET_INT("PROP_WHOUSE_SLOT" .. i) -- same stat: WARHOUSESLOT
            if warehouse_slot ~= 0 then
                local sp_crate = STAT_GET_INT("CONTOTALFORWHOUSE" .. i)
                local sp_item = STAT_GET_INT("SPCONTOTALFORWHOUSE" .. i)
                local warehouse_name = util.get_label_text("MP_WHOUSE_" .. warehouse_slot - 1)
                local warehouse_cap = Business.Caps.Warehouse[warehouse_slot]

                text = sp_crate .. "(" .. sp_item .. ")/" .. warehouse_cap
                if sp_crate == warehouse_cap then
                    text = "[!] " .. text
                end
                menu.set_value(Business.Menu.special_cargo[i], text)
                menu.set_menu_name(Business.Menu.special_cargo[i], warehouse_name)
            else
                menu.set_value(Business.Menu.special_cargo[i], "")
                menu.set_menu_name(Business.Menu.special_cargo[i], "无")
            end
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

local Business_Monitor_SpecialCargo = menu.list(Business_Monitor, "特种货物", {}, "括号里是特殊物品数量")
for i = 0, 4 do
    Business.Menu.special_cargo[i] = menu.readonly(Business_Monitor_SpecialCargo, "无")
end

--#endregion


--#region Business Stats

local Business_Stats <const> = menu.list(Online_Options, "资产统计数据", {}, "")

local BusinessStats = {
    Bunker = {
        [1] = { name = "总营收", stat = "LIFETIME_BKR_SELL_EARNINGS5" },
        [2] = { name = "送达原材料次数", stat = "LFETIME_BIKER_BUY_COMPLET5" },
        [3] = { name = "开启原材料任务次数", stat = "LFETIME_BIKER_BUY_UNDERTA5" },
        [4] = { name = "成功卖货次数", stat = "LFETIME_BIKER_SELL_COMPLET5" },
        [5] = { name = "开启卖货任务次数", stat = "LFETIME_BIKER_SELL_UNDERTA5" },
    },
    SpecialCargo = {
        [1] = { name = "总营收", stat = "LIFETIME_CONTRA_EARNINGS" },
        [2] = { name = "成功拉货次数", stat = "LIFETIME_BUY_COMPLETE" },
        [3] = { name = "开启拉货任务次数", stat = "LIFETIME_BUY_UNDERTAKEN" },
        [4] = { name = "成功卖货次数", stat = "LIFETIME_SELL_COMPLETE" },
        [5] = { name = "开启卖货任务次数", stat = "LIFETIME_SELL_UNDERTAKEN" },
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
}

for _, item in pairs(remote_computer_list) do
    menu.action(Remote_Computer, item.menu_name, { "app" .. item.command }, "", function()
        if IS_IN_SESSION() then
            -- SET_INT_GLOBAL(Globals.IsUsingComputerScreen, 1)
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
    },
    eventList = {
        { sprite = 430, name = "时间挑战赛", command = "timetrial" },
        { sprite = 673, name = "RC匪徒时间挑战赛", command = "rctimetrial" },
        { sprite = 842, name = "杰拉德包裹", command = "gcaches" },
        { sprite = 845, name = "藏匿屋", command = "stashhouse" },
        { sprite = 860, name = "拉机能量时间挑战赛", command = "junktimetrial" },
    },
}

menu.divider(Fast_Teleport, "载具资产")
menu.action(Fast_Teleport, "传送到 机动作战中心", { "ftp_moc" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(564)
    if HUD.DOES_BLIP_EXIST(blip) then
        if HUD.GET_BLIP_COLOUR(blip) == get_org_blip_colour(players.user()) then
            local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
            set_entity_heading_to_entity(players.user_ped(), ent)
            tp_to_entity(ent, 0.0, -9.0, -1.0)
        end
    else
        util.toast("未在地图上找到 机动作战中心")
    end
end)
menu.action(Fast_Teleport, "传送到 复仇者", { "ftp_avenger" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(589)
    if HUD.DOES_BLIP_EXIST(blip) then
        if HUD.GET_BLIP_COLOUR(blip) == get_org_blip_colour(players.user()) then
            local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
            set_entity_heading_to_entity(players.user_ped(), ent)
            tp_to_entity(ent, 0.0, -8.0, 0.0)
        end
    else
        util.toast("未在地图上找到 复仇者")
    end
end)
menu.action(Fast_Teleport, "传送到 恐霸", { "ftp_terrorbyte" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(632)
    if HUD.DOES_BLIP_EXIST(blip) then
        if HUD.GET_BLIP_COLOUR(blip) == get_org_blip_colour(players.user()) then
            local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
            set_entity_heading_to_entity(players.user_ped(), ent, 90)
            tp_to_entity(ent, 2.0, 0.0, 0.0)
        end
    else
        util.toast("未在地图上找到 恐霸")
    end
end)
menu.action(Fast_Teleport, "传送到 致幻剂实验室", { "ftp_acidlab" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(840)
    if HUD.DOES_BLIP_EXIST(blip) then
        if HUD.GET_BLIP_COLOUR(blip) == get_org_blip_colour(players.user()) then
            local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
            set_entity_heading_to_entity(players.user_ped(), ent)
            tp_to_entity(ent, 3.0, 0.0, 0.0)
        end
    else
        util.toast("未在地图上找到 致幻剂实验室")
    end
end)

menu.divider(Fast_Teleport, "资产")
for key, item in pairs(FastTP.propertyList) do
    menu.action(Fast_Teleport, "传送到 " .. item.name, { "ftp" .. item.command }, "", function()
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
    menu.action(Fast_Teleport, "传送到 " .. item.name, { "ftp" .. item.command }, "", function()
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


--#region Local Editor

local Local_Editor <const> = menu.list(Online_Options, "Local Editor", { "local_editor" }, "")

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

--#endregion


--#region Global Editor

local Global_Editor <const> = menu.list(Online_Options, "Global Editor", { "global_editor" }, "")

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

--#endregion




menu.list_select(Online_Options, "战局雪天", { "turn_snow" }, "", {
    { "不更改", { "default" }, "" },
    { "开启", { "on" }, "" },
    { "关闭", { "off" }, "" },
}, 1, function(value)
    if value == 2 then
        SET_INT_GLOBAL(Globals.TURN_SNOW_ON_OFF, 1)
    elseif value == 3 then
        SET_INT_GLOBAL(Globals.TURN_SNOW_ON_OFF, 0)
    end
    Loop_Handler.Tunables.TurnSnow = value
end)
menu.click_slider_float(Online_Options, "AI血量倍数", { "ai_health_multiplier" }, "",
    0, 1000, 100, 10, function(value)
        SET_FLOAT_GLOBAL(Globals.AI_HEALTH, value * 0.01)
        Loop_Handler.Tunables.AiHealth = value * 0.01
    end)
menu.toggle(Online_Options, "禁用产业劫货", {}, "", function(toggle)
    Globals.DisableBusinessRaid(toggle)
    Loop_Handler.Tunables.DisableBusinessRaid = toggle
end)
