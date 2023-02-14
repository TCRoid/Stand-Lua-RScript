--------------------------------
------------ 任务选项 -----------
--------------------------------

local Mission_options = menu.list(menu.my_root(), "任务选项", {}, "")


----- 分红编辑 -----
local Heist_Cut_Editor = menu.list(Mission_options, "分红编辑", {}, "")

local cut_global_base = 1977693 + 823 + 56
local Heist_Cut_Editor_ListItem = {
    [1977693 + 823 + 56] = { "佩里科岛" },
    [1970895 + 2325] = { "赌场抢劫" },
    [1966831 + 812 + 50] = { "末日豪劫" },
}
menu.list_select(Heist_Cut_Editor, "当前抢劫", {}, "", Heist_Cut_Editor_ListItem, cut_global_base, function(value)
    cut_global_base = value
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


----- 赌场抢劫 -----
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



----- 资产监视 -----
local Business_Monitor = menu.list(Mission_options, "资产监视", { "business_monitor" }, "")

Business = {}
function Business.GetOrgOffset()
    return (1892703 + 1 + (players.user() * 599) + 10)
end

function Business.GetOnlineWorkOffset()
    return (1853910 + 1 + (players.user() * 862) + 267)
end

function Business.GetBusinessSupplies(slot)
    return STAT_GET_INT("MATTOTALFORFACTORY" .. slot)
end

function Business.GetBusinessProduct(slot)
    return STAT_GET_INT("PRODTOTALFORFACTORY" .. slot)
end

function Business.GetNightclubValue(slot)
    local offset = Business.GetOnlineWorkOffset() + 310 + 8 + 1 + slot
    return GET_INT_GLOBAL(offset)
end

Business.Globals = {
    Bunker = { Cap = 262145 + 21531 }, -- 2092556011
    NightClub = {
        [0] = { name = "Cargo", Cap = 262145 + 24394 }, -- -1168716160
        [1] = { name = "Weapons", Cap = 262145 + 24388 }, -- -1318722703
        [2] = { name = "Cocaine", Cap = 262145 + 24389 }, -- -2136290534
        [3] = { name = "Meth", Cap = 262145 + 24390 }, -- 1069721135
        [4] = { name = "Weed", Cap = 262145 + 24391 }, -- -8586474
        [5] = { name = "Forgery", Cap = 262145 + 24392 }, -- -358911902
        [6] = { name = "Cash", Cap = 262145 + 24393 } -- -879486246
    },
}

local Business_Monitor_Menu = {
    bunker_supplies,
    bunker_product,
    bunker_research,
    nightclub_safe_cash,
    nightclub_popularity,
    nightclub = {
        [0] = { name = "运输货物", menu },
        [1] = { name = "体育用品", menu },
        [2] = { name = "南美进口货", menu },
        [3] = { name = "药学研究产品", menu },
        [4] = { name = "有机农产品", menu },
        [5] = { name = "印刷品", menu },
        [6] = { name = "印钞", menu }
    },
    drug_supplies,
    drug_product,
    arcade_safe_cash,
    agency_safe_cash,
}
menu.action(Business_Monitor, "刷新状态", {}, "", function()
    if util.is_session_started() and not util.is_session_transition_active() then
        --- Bunker ---
        local slot = 5
        local text = ""
        text = Business.GetBusinessSupplies(slot) .. "%"
        menu.set_value(Business_Monitor_Menu.bunker_supplies, text)

        text = Business.GetBusinessProduct(slot) .. "/" .. GET_INT_GLOBAL(Business.Globals.Bunker.Cap)
        menu.set_value(Business_Monitor_Menu.bunker_product, text)

        text = STAT_GET_INT("RESEARCHTOTALFORFACTORY5")
        menu.set_value(Business_Monitor_Menu.bunker_research, text)

        --- Nightclub ---
        text = math.floor(STAT_GET_INT('CLUB_POPULARITY') / 10) .. '%'
        menu.set_value(Business_Monitor_Menu.nightclub_popularity, text)
        menu.set_value(Business_Monitor_Menu.nightclub_safe_cash, STAT_GET_INT("CLUB_SAFE_CASH_VALUE"))

        for i = 0, 6 do
            local t = Business.GetNightclubValue(i) .. "/" .. GET_INT_GLOBAL(Business.Globals.NightClub[i].Cap)
            menu.set_value(Business_Monitor_Menu.nightclub[i].menu, t)
        end

        --- Other ---
        menu.set_value(Business_Monitor_Menu.arcade_safe_cash, STAT_GET_INT("ARCADE_SAFE_CASH_VALUE"))
        menu.set_value(Business_Monitor_Menu.agency_safe_cash, STAT_GET_INT("FIXER_SAFE_CASH_VALUE"))

        --- Drug War ---
        slot = 6
        text = Business.GetBusinessSupplies(slot) .. "%"
        menu.set_value(Business_Monitor_Menu.drug_supplies, text)

        text = Business.GetBusinessProduct(slot) .. "/160"
        menu.set_value(Business_Monitor_Menu.drug_product, text)
    else
        util.toast("仅在线上模式战局内可用")
    end
end)

menu.divider(Business_Monitor, "地堡")
Business_Monitor_Menu.bunker_supplies = menu.readonly(Business_Monitor, "原材料")
Business_Monitor_Menu.bunker_product = menu.readonly(Business_Monitor, "产品")
Business_Monitor_Menu.bunker_research = menu.readonly(Business_Monitor, "研究")

menu.divider(Business_Monitor, "夜总会")
Business_Monitor_Menu.nightclub_popularity = menu.readonly(Business_Monitor, "夜总会人气")
Business_Monitor_Menu.nightclub_safe_cash  = menu.readonly(Business_Monitor, "保险箱现金")
for i = 0, 6 do
    Business_Monitor_Menu.nightclub[i].menu = menu.readonly(Business_Monitor, Business_Monitor_Menu.nightclub[i].name)
end

menu.divider(Business_Monitor, "其它")
Business_Monitor_Menu.arcade_safe_cash = menu.readonly(Business_Monitor, "游戏厅保险箱现金")
Business_Monitor_Menu.agency_safe_cash = menu.readonly(Business_Monitor, "事务所保险箱现金")

menu.divider(Business_Monitor, "致幻剂实验室")
Business_Monitor_Menu.drug_supplies = menu.readonly(Business_Monitor, "原材料")
Business_Monitor_Menu.drug_product = menu.readonly(Business_Monitor, "产品")



----- Local Editor -----
local Local_Editor = menu.list(Mission_options, "Local Editor", { "local_editor" }, "")

local mission_script = "fm_mission_controller"
menu.list_select(Local_Editor, "选择脚本", {}, "", {
    { "fm_mission_controller" },
    { "fm_mission_controller_2020" }
}, 1, function(index)
    if index == 1 then
        mission_script = "fm_mission_controller"
    elseif index == 2 then
        mission_script = "fm_mission_controller_2020"
    end
end)

local local_address = 0
menu.slider(Local_Editor, "Local 地址", { "local_address" }, "输入计算总和", 0, 16777216, 0, 1,
    function(value)
        local_address = value
    end)
local local_type = "int"
menu.list_select(Local_Editor, "数据类型", {}, "", { { "INT" }, { "FLOAT" } }, 1, function(value)
    if value == 1 then
        local_type = "int"
    elseif value == 2 then
        local_type = "float"
    end
end)
menu.action(Local_Editor, "读取 Local", {}, "", function()
    if local_address > 0 then
        if SCRIPT.HAS_SCRIPT_LOADED(mission_script) then
            local value
            if local_type == "int" then
                value = GET_INT_LOCAL(mission_script, local_address)
            elseif local_type == "float" then
                value = GET_FLOAT_LOCAL(mission_script, local_address)
            end

            if value ~= nil then
                util.toast(value)
            else
                util.toast("No Data")
            end
        else
            util.toast("This Script Has Not Loaded")
        end
    end
end)

menu.divider(Local_Editor, "写入")
local local_write = 0
menu.text_input(Local_Editor, "要写入的值", { "local_write" }, "务必注意int类型和float类型的格式",
    function(value)
        local_write = value
    end)
menu.action(Local_Editor, "写入 Local", {}, "", function()
    if local_address > 0 and tonumber(local_write) ~= nil then
        if SCRIPT.HAS_SCRIPT_LOADED(mission_script) then
            if local_type == "int" then
                SET_INT_LOCAL(mission_script, local_address, local_write)
            elseif local_type == "float" then
                SET_FLOAT_LOCAL(mission_script, local_address, local_write)
            end
        else
            util.toast("This Script Has Not Loaded")
        end
    end
end)
menu.toggle_loop(Local_Editor, "锁定写入 Local", {}, "", function()
    if local_address > 0 and tonumber(local_write) ~= nil then
        if SCRIPT.HAS_SCRIPT_LOADED(mission_script) then
            if local_type == "int" then
                SET_INT_LOCAL(mission_script, local_address, local_write)
            elseif local_type == "float" then
                SET_FLOAT_LOCAL(mission_script, local_address, local_write)
            end
        else
            util.toast("This Script Has Not Loaded")
            return
        end
    end
end)


----- Global Editor -----
local Global_Editor = menu.list(Mission_options, "Global Editor", { "global_editor" }, "")

local global_address = 0
menu.slider(Global_Editor, "Global 地址", { "global_address" }, "输入计算总和", 0, 16777216, 0, 1,
    function(value)
        global_address = value
    end)
local global_type = "int"
menu.list_select(Global_Editor, "数据类型", {}, "", { { "INT" }, { "FLOAT" } }, 1,
    function(value)
        if value == 1 then
            global_type = "int"
        elseif value == 2 then
            global_type = "float"
        end
    end)
menu.action(Global_Editor, "读取 Global", {}, "", function()
    if global_address > 0 then
        local value
        if global_type == "int" then
            value = GET_INT_GLOBAL(global_address)
        elseif global_type == "float" then
            value = GET_FLOAT_GLOBAL(global_address)
        end

        if value ~= nil then
            util.toast(value)
        else
            util.toast("No Data")
        end
    end
end)

menu.divider(Global_Editor, "写入")
local global_write = 0
menu.text_input(Global_Editor, "要写入的值", { "global_write" }, "务必注意int类型和float类型的格式",
    function(value)
        global_write = value
    end)
menu.action(Global_Editor, "写入 Global", {}, "", function()
    if global_address > 0 and tonumber(global_write) ~= nil then
        if global_type == "int" then
            SET_INT_GLOBAL(global_address, global_write)
        elseif global_type == "float" then
            SET_FLOAT_GLOBAL(global_address, global_write)
        end
    end
end)
menu.toggle_loop(Global_Editor, "锁定写入 Global", {}, "", function()
    if global_address > 0 and tonumber(global_write) ~= nil then
        if global_type == "int" then
            SET_INT_GLOBAL(global_address, global_write)
        elseif global_type == "float" then
            SET_FLOAT_GLOBAL(global_address, global_write)
        end
    end
end)


----- Stat Editor -----
local Stat_Editor = menu.list(Mission_options, "Stat Editor", { "stat_editor" }, "")
-----
local Stat_Playtime = menu.list(Stat_Editor, "游玩时间", {}, "")

local Stat_Playtime_Method = menu.list_select(Stat_Playtime, "选择方式", {}, "", {
        { "覆盖", {}, "会将时间修改成所设置的时间\n最大24.8天" },
        { "增加", {}, "会在当前时间的基础上增加设置的时间\n最大50000天" }
    }, 1, function()
    end)
menu.divider(Stat_Playtime, "设置时间")
local Stat_Playtime_Year = menu.slider(Stat_Playtime, "年", { "stat_playtime_year" }, "", 0, 100, 0, 1, function()
    end)
local Stat_Playtime_Day = menu.slider(Stat_Playtime, "天", { "stat_playtime_day" }, "", 0, 50000, 0, 1, function()
    end)
local Stat_Playtime_Hour = menu.slider(Stat_Playtime, "小时", { "stat_playtime_hour" }, "", 0, 50000, 0, 1,
        function()
        end)
local Stat_Playtime_Min = menu.slider(Stat_Playtime, "分钟", { "stat_playtime_min" }, "", 0, 50000, 0, 1,
        function()
        end)

menu.divider(Stat_Playtime, "")
local Stat_Playtime_ListItem_Stat = {
    { "GTA在线模式中花费的时间",          {}, "MP_PLAYING_TIME" },
    { "以第一人称视角进行游戏的时间", {}, "MP_FIRST_PERSON_CAM_TIME" },
    { "第三人称视角游戏时间",             {}, "TOTAL_PLAYING_TIME" },
    { "死斗游戏中花费的时间",             {}, "MPPLY_TOTAL_TIME_SPENT_DEATHMAT" },
    { "竞速中花费的时间",                   {}, "MPPLY_TOTAL_TIME_SPENT_RACES" },
    { "制作器中花费的时间",                {}, "MPPLY_TOTAL_TIME_MISSION_CREATO" },
    { "持续时间最长单人战局",             {}, "LONGEST_PLAYING_TIME" },
    { "每场战局平均用时",                   {}, "AVERAGE_TIME_PER_SESSON" },
    { "游泳时间",                               {}, "TIME_SWIMMING" },
    { "潜水时间",                               {}, "TIME_UNDERWATER" },
    { "步行时间",                               {}, "TIME_WALKING" },
    { "掩体躲藏时间",                         {}, "TIME_IN_COVER" },
    { "摩托车骑行时间",                      {}, "TIME_DRIVING_BIKE" },
    { "直升机飞行时间",                      {}, "TIME_DRIVING_HELI" },
    { "飞机飞行时间",                         {}, "TIME_DRIVING_PLANE" },
    { "船只航行时间",                         {}, "TIME_DRIVING_BOAT" },
    { "沙滩车驾驶时间",                      {}, "TIME_DRIVING_QUADBIKE" },
    { "自行车骑行时间",                      {}, "TIME_DRIVING_BICYCLE" },
    { "被通缉持续时间",                      {}, "TOTAL_CHASE_TIME" },
    { "上一次通缉等级持续时间",          {}, "LAST_CHASE_TIME" },
    { "最长通缉等级持续时间",             {}, "LONGEST_CHASE_TIME" },
    { "五星通缉等级持续时间",             {}, "TOTAL_TIME_MAX_STARS" },
    { "Total time spent in Lobby",                  {}, "MPPLY_TOTAL_TIME_IN_LOBBY" },
    { "Total time spent in Freemode",               {}, "MPPLY_TOTAL_TIME_SPENT_FREEMODE" },
    { "Total Playing time in multiplayer",          {}, "LEADERBOARD_PLAYING_TIME" },
    { "GTA在线模式中花费的时间_New",      {}, "MP_PLAYING_TIME_NEW" },
    { "Total time spent in Loading screen",         {}, "MPPLY_TOTAL_TIME_LOAD_SCREEN" },
    { "Average time spent on missions",             {}, "CHAR_TOTAL_TIME_MISSION" },
    { "Total Time spent in Start Menu",             {}, "TOTAL_STARTMENU_TIME" },
    { "Total Time spent shopping",                  {}, "TOTAL_SHOP_TIME" },
}
local Stat_Playtime_Select = menu.list_select(Stat_Playtime, "Stat", {}, "", Stat_Playtime_ListItem_Stat, 1,
        function()
        end)
menu.action(Stat_Playtime, "设置", {}, "", function()
    local stat = Stat_Playtime_ListItem_Stat[menu.get_value(Stat_Playtime_Select)][3]
    local year = menu.get_value(Stat_Playtime_Year) * 365 * 24 * 60 * 60 * 1000
    local day = menu.get_value(Stat_Playtime_Day) * 24 * 60 * 60 * 1000
    local hour = menu.get_value(Stat_Playtime_Hour) * 60 * 60 * 1000
    local min = menu.get_value(Stat_Playtime_Min) * 60 * 1000

    if menu.get_value(Stat_Playtime_Method) == 1 then
        STAT_SET_INT(stat, year + day + hour + min)
    else
        STAT_SET_INCREMENT(stat, year + day + hour + min)
    end

    util.toast("设置完成!\n请等待云保存完成!")
    menu.trigger_commands("forcecloudsave")
end)
menu.action(Stat_Playtime, "读取", {}, "", function()
    local stat = Stat_Playtime_ListItem_Stat[menu.get_value(Stat_Playtime_Select)][3]
    local value = STAT_GET_INT(stat)
    util.toast(value)
end)

-----
local Stat_Date = menu.list(Stat_Editor, "日期", {}, "")

menu.divider(Stat_Date, "设置日期")
local Stat_Date_Year = menu.slider(Stat_Date, "年", { "stat_date_year" }, "", 2013, os.date("%Y"), 2013, 1,
        function()
        end)
local Stat_Date_Month = menu.slider(Stat_Date, "月", { "stat_date_month" }, "", 1, 12, 1, 1, function()
    end)
local Stat_Date_Day = menu.slider(Stat_Date, "日", { "stat_date_day" }, "", 1, 31, 1, 1, function()
    end)
local Stat_Date_Hour = menu.slider(Stat_Date, "时", { "stat_date_hour" }, "", 0, 24, 0, 1, function()
    end)
local Stat_Date_Min = menu.slider(Stat_Date, "分", { "stat_date_min" }, "", 0, 60, 0, 1, function()
    end)

menu.divider(Stat_Date, "")
local Stat_Date_ListItem_Stat = {
    { "制作的角色时间",    {}, "CHAR_DATE_CREATED" },
    { "最后一次升级时间", {}, "CHAR_DATE_RANKUP" },

    { "MPPLY_STARTED_MP",         {}, "MPPLY_STARTED_MP" },
    { "MPPLY_NON_CHEATER_CASH",   {}, "MPPLY_NON_CHEATER_CASH" },
    { "CHAR_LAST_PLAY_TIME",      {}, "CHAR_LAST_PLAY_TIME" },
    { "CLOUD_TIME_CHAR_CREATED",  {}, "CLOUD_TIME_CHAR_CREATED" },
    { "PS_TIME_CHAR_CREATED",     {}, "PS_TIME_CHAR_CREATED" },
}
local Stat_Date_Select = menu.list_select(Stat_Date, "Stat", {}, "", Stat_Date_ListItem_Stat, 1, function()
    end)
menu.action(Stat_Date, "设置", {}, "", function()
    local stat = Stat_Date_ListItem_Stat[menu.get_value(Stat_Date_Select)][3]
    local year = menu.get_value(Stat_Date_Year)
    local month = menu.get_value(Stat_Date_Month)
    local day = menu.get_value(Stat_Date_Day)
    local hour = menu.get_value(Stat_Date_Hour)
    local min = menu.get_value(Stat_Date_Min)
    STAT_SET_DATE(stat, year, month, day, hour, min)
    util.toast("设置完成!\n请等待云保存完成!")
    menu.trigger_commands("forcecloudsave")
end)
menu.action(Stat_Date, "读取", {}, "", function()
    local stat = Stat_Date_ListItem_Stat[menu.get_value(Stat_Date_Select)][3]
    util.toast(STAT_GET_DATE(stat, "Year") ..
    "年" ..
    STAT_GET_DATE(stat, "Month") ..
    "月" .. STAT_GET_DATE(stat, "Day") .. "日" .. STAT_GET_DATE(stat, "Hour") ..
    "时" .. STAT_GET_DATE(stat, "Min") .. "分")
end)

-----
local Stat_Skill = menu.list(Stat_Editor, "属性技能", {}, "")

local Stat_Skill_ListItem_Stat = {
    { "体力",    {}, "SCRIPT_INCREASE_STAM" },
    { "射击",    {}, "SCRIPT_INCREASE_SHO" },
    { "力量",    {}, "SCRIPT_INCREASE_STRN" },
    { "潜行",    {}, "SCRIPT_INCREASE_STL" },
    { "飞行",    {}, "SCRIPT_INCREASE_FLY" },
    { "驾驶",    {}, "SCRIPT_INCREASE_DRIV" },
    { "肺活量", {}, "SCRIPT_INCREASE_LUNG" }
}
local Stat_Skill_Select = menu.list_select(Stat_Skill, "技能", {}, "", Stat_Skill_ListItem_Stat, 1, function()
    end)
menu.action(Stat_Skill, "读取", {}, "", function()
    local stat = Stat_Skill_ListItem_Stat[menu.get_value(Stat_Skill_Select)][3]
    util.toast(STAT_GET_INT(stat))
end)
menu.divider(Stat_Skill, "")
local Stat_Skill_INT = menu.slider(Stat_Skill, "值", { "stat_skill_int" }, "", 0, 100, 100, 1, function()
    end)
menu.action(Stat_Skill, "设置", {}, "", function()
    local stat = Stat_Skill_ListItem_Stat[menu.get_value(Stat_Skill_Select)][3]
    STAT_SET_INT(stat, menu.get_value(Stat_Skill_INT))
    util.toast("设置完成!\n请等待云保存完成!")
    menu.trigger_commands("forcecloudsave")
end)



------ 任务助手 ------
local Mission_Assistant = menu.list(Mission_options, "任务助手", {}, "")

--- 附近街道 ---
local Mission_Assistant_Nearby_Road = menu.list(Mission_Assistant, "附近街道", {}, "")

menu.divider(Mission_Assistant_Nearby_Road, "生成载具")
local mission_assistant_neayby_road_toggle = true
menu.toggle(Mission_Assistant_Nearby_Road, "生成载具为无敌", {}, "", function(toggle)
    mission_assistant_neayby_road_toggle = toggle
end, true)
local mission_assistant_neayby_road_toggle_enhance = true
menu.toggle(Mission_Assistant_Nearby_Road, "生成载具强化", {}, "", function(toggle)
    mission_assistant_neayby_road_toggle_enhance = toggle
end, true)

local Nearby_Road_ListItem = {
    --name, model, help_text
    { "警车",    "police3",    "可用于越狱警察局任务" },
    { "坦克",    "khanjali",   "可汗贾利" },
    { "骷髅马", "kuruma2",    "" },
    { "直升机", "polmav",     "警用直升机" },
    { "子弹",    "bullet",     "大街上随处可见的超级跑车" },
    { "摩托车", "bati",       "801" },
    { "暴君MK2", "oppressor2", "" },
}
for k, data in pairs(Nearby_Road_ListItem) do
    local name = "生成" .. data[1]
    local model = data[2]
    menu.action(Mission_Assistant_Nearby_Road, name, {}, data[3], function()
        local hash = util.joaat(model)
        local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        local bool, coords, heading = Get_Closest_Vehicle_Node(pos, 0)
        if bool then
            local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, heading)
            if vehicle ~= 0 then
                Upgrade_Vehicle(vehicle)
                ENTITY.SET_ENTITY_INVINCIBLE(vehicle, mission_assistant_neayby_road_toggle)
                if mission_assistant_neayby_road_toggle_enhance then
                    Enhance_Vehicle(vehicle)
                end
                util.toast("Done!")
                SHOW_BLIP_TIMER(vehicle, 225, 27, 5000)
            end
        end
    end)
end


----- 玩家助手 -----
local Mission_Player_Assistant = menu.list(Mission_Assistant, "玩家助手", {}, "")

local function generate_MPA_player_commands(menu_parent, pid)
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
    local nearby_veh_godmod = menu.toggle(neayby_veh, "生成载具为无敌", {}, "", function(toggle)
        end, true)
    for k, data in pairs(Nearby_Road_ListItem) do
        local name = "生成" .. data[1]
        local model = data[2]
        menu.action(neayby_veh, name, {}, data[3], function()
            local hash = util.joaat(model)
            local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
            local bool, coords, heading = Get_Closest_Vehicle_Node(pos, 1)
            if bool then
                local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, heading)
                if vehicle ~= 0 then
                    Upgrade_Vehicle(vehicle)
                    ENTITY.SET_ENTITY_INVINCIBLE(vehicle, menu.get_value(nearby_veh_godmod))
                    util.toast("Done!")
                    SHOW_BLIP_TIMER(vehicle, 225, 27, 5000)
                end
            end
        end)
    end
end

local MPA_menu_list = {}

menu.action(Mission_Player_Assistant, "刷新玩家列表", {}, "", function()
    for k, v in pairs(MPA_menu_list) do
        if v ~= nil and menu.is_ref_valid(v) then
            menu.delete(v)
        end
    end
    MPA_menu_list = {}
    ------
    for k, pid in pairs(players.list()) do
        local name = players.get_name(pid)
        local rank = players.get_rank(pid)
        local menu_name = name .. " (" .. rank .. "级)"

        local team = PLAYER.GET_PLAYER_TEAM(pid)
        local money = players.get_money(pid)
        local language = players.get_language(pid)
        local help_text = "Team: " .. team .. "\nMoney: " .. money .. "\nLanguage: " .. enum_LanguageType[language + 2]

        local player_menu = menu.list(Mission_Player_Assistant, menu_name, {}, help_text)
        table.insert(MPA_menu_list, player_menu)

        generate_MPA_player_commands(player_menu, pid)
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

        ENTITY.SET_ENTITY_HEALTH(veh, 5000)
        ENTITY.SET_ENTITY_MAX_HEALTH(veh, 5000)
        Enhance_Vehicle(veh)
    end

    util.toast("Done!")
end)
menu.toggle_loop(Mission_Assistant, "秃鹰直升机 NPC禁用武器", {},
    "禁止NPC使用秃鹰攻击直升机的机枪和导弹", function()
    for k, vehicle in pairs(entities.get_all_vehicles_as_handles()) do
        if ENTITY.GET_ENTITY_MODEL(vehicle) == 788747387 then
            local ped = GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
            if ped ~= 0 and not IS_PED_PLAYER(ped) then
                if not VEHICLE.IS_VEHICLE_WEAPON_DISABLED(251255724, vehicle, ped) then
                    RequestControl(vehicle)
                    VEHICLE.DISABLE_VEHICLE_WEAPON(true, 251255724, vehicle, ped) --VEHICLE_WEAPON_PLAYER_BUZZARD
                    VEHICLE.DISABLE_VEHICLE_WEAPON(true, 3313697558, vehicle, ped) --VEHICLE_WEAPON_SPACE_ROCKET
                end
            end
        end
    end
end)



------ 公寓抢劫 ------
menu.divider(Mission_Assistant, "公寓抢劫")

local Mission_Assistant_Prison = menu.list(Mission_Assistant, "越狱", {}, "")
menu.action(Mission_Assistant_Prison, "飞机：目的地 生成坦克", {}, "", function()
    local coords = {
        x = 2183.927, y = 4759.426, z = 41.676
    }
    local heading = 73.373
    local hash = util.joaat("khanjali")
    local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, heading)
    if vehicle ~= 0 then
        Upgrade_Vehicle(vehicle)
        ENTITY.SET_ENTITY_INVINCIBLE(vehicle, true)
        util.toast("Done!")
    end
end)
menu.action(Mission_Assistant_Prison, "终章：监狱内 生成骷髅马", {}, "", function()
    local coords = {
        x = 1722.397, y = 2514.426, z = 45.305
    }
    local heading = 116.175
    local hash = util.joaat("kuruma2")
    local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, heading)
    if vehicle ~= 0 then
        Upgrade_Vehicle(vehicle)
        ENTITY.SET_ENTITY_INVINCIBLE(vehicle, true)
        util.toast("Done!")
    end
end)
menu.action(Mission_Assistant_Prison, "终章：美杜莎 无敌", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, 1077420264)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            if RequestControl(ent) then
                ENTITY.SET_ENTITY_INVINCIBLE(ent, true)
                util.toast("Done!")
            end
        end
    end
end)
menu.action(Mission_Assistant_Prison, "终章：秃鹰直升机 无敌", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, 788747387)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            if RequestControl(ent) then
                ENTITY.SET_ENTITY_INVINCIBLE(ent, true)
                util.toast("Done!")
            end
        end
    end
end)
menu.action(Mission_Assistant_Prison, "终章：敌对天煞 传送到海洋并冻结", {}, "", function()
    local coords = {
        x = 4912, y = -4910, z = 20
    }
    local entity_list = get_entities_by_hash("vehicle", true, -1281684762)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            if RequestControl(ent) then
                SET_ENTITY_COORDS(ent, coords)
                ENTITY.FREEZE_ENTITY_POSITION(ent, true)
                util.toast("Done!")
            end
        end
    end
end)
menu.action(Mission_Assistant_Prison, "终章：敌对天煞 禁用导弹", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, -1281684762)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            if RequestControl(ent) then
                local ped = GET_PED_IN_VEHICLE_SEAT(ent, -1)
                VEHICLE.DISABLE_VEHICLE_WEAPON(true, 3313697558, ent, ped) --VEHICLE_WEAPON_PLANE_ROCKET
                util.toast("Done!")
            end
        end
    end
end)


-- Model Name: ig_rashcosvki, Hash: 940330470
local Mission_Assistant_Prison_rashcosvki = menu.list(Mission_Assistant_Prison, "终章：光头", {}, "")

menu.action(Mission_Assistant_Prison_rashcosvki, "清除正在执行的任务", {}, "", function()
    local entity_list = get_entities_by_hash("ped", true, 940330470)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            if RequestControl(ent) then
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(ent)

                util.toast("Done!")
            end
        end
    end
end)
menu.action(Mission_Assistant_Prison_rashcosvki, "无敌强化", {}, "", function()
    local entity_list = get_entities_by_hash("ped", true, 940330470)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            if RequestControl(ent) then
                local weaponHash = util.joaat("WEAPON_APPISTOL")
                WEAPON.GIVE_WEAPON_TO_PED(ent, weaponHash, -1, false, true)
                WEAPON.SET_CURRENT_PED_WEAPON(ent, weaponHash, false)

                ENTITY.SET_ENTITY_INVINCIBLE(ped, true)
                ENTITY.SET_ENTITY_PROOFS(ped, true, true, true, true, true, true, true, true)

                PED.SET_PED_HIGHLY_PERCEPTIVE(ped, true)
                PED.SET_PED_SEEING_RANGE(ped, 500.0)
                PED.SET_PED_HEARING_RANGE(ped, 500.0)

                WEAPON.SET_PED_INFINITE_AMMO_CLIP(ped, true)
                PED.SET_PED_SHOOT_RATE(ped, 1000)
                PED.SET_PED_ACCURACY(ped, 100)

                PED.SET_PED_COMBAT_ATTRIBUTES(ped, 5, true) --AlwaysFight
                PED.SET_PED_COMBAT_ATTRIBUTES(ped, 27, true) --PerfectAccuracy

                PED.SET_PED_COMBAT_ABILITY(ped, 2) --Professional
                PED.SET_PED_COMBAT_RANGE(ped, 2) --Far
                PED.SET_PED_TARGET_LOSS_RESPONSE(ped, 1) --NeverLoseTarget

                util.toast("Done!")
            end
        end
    end
end)
local Mission_Assistant_Prison_vehicle = 0
menu.action(Mission_Assistant_Prison_rashcosvki, "跑去监狱外围的警车", {}, "会在监狱外围生成一辆警车"
    , function()
    local entity_list = get_entities_by_hash("ped", true, 940330470)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            if RequestControl(ent) then
                if not ENTITY.DOES_ENTITY_EXIST(Mission_Assistant_Prison_vehicle) then
                    local hash = util.joaat("police3")
                    local coords = { x = 1571.585, y = 2605.450, z = 45.880 }
                    local heading = 343.0217
                    local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, heading)
                    if vehicle ~= 0 then
                        Upgrade_Vehicle(vehicle)
                        ENTITY.SET_ENTITY_INVINCIBLE(vehicle, true)

                        Mission_Assistant_Prison_vehicle = vehicle
                        TASK.TASK_GO_TO_ENTITY(ent, Mission_Assistant_Prison_vehicle, -1, 5.0, 100, 0.0, 0)
                        util.toast("Done!")
                    end
                else
                    TASK.TASK_GO_TO_ENTITY(ent, Mission_Assistant_Prison_vehicle, -1, 5.0, 100, 0.0, 0)
                    util.toast("Done!")
                end
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
                    if RequestControl(ent) then
                        PED.SET_PED_INTO_VEHICLE(ent, veh, -2)
                        util.toast("Done!")
                    end
                end
            end
        else
            -- 传送到玩家
            local entity_list = get_entities_by_hash("ped", true, 940330470)
            if next(entity_list) ~= nil then
                for k, ent in pairs(entity_list) do
                    if RequestControl(ent) then
                        TP_ENTITY_TO_ENTITY(ent, player_ped)
                        util.toast("Done!")
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
                    if RequestControl(ent) then
                        TASK.TASK_ENTER_VEHICLE(ent, veh, -1, -2, 2.0, 1, 0)
                        util.toast("Done!")
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
                if RequestControl(ent) then
                    TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(ent, player_ped, 0.0, -1.0, 0.0, 20.0, -1, 100.0, true)
                    util.toast("Done!")
                end
            end
        end
    end
end)


local Mission_Assistant_Huamane = menu.list(Mission_Assistant, "突袭人道实验室", {}, "")
menu.action(Mission_Assistant_Huamane, "关键密码：目的地 生成坦克", {}, "", function()
    local coords = {
        x = 142.122, y = -1061.271, z = 29.746
    }
    local head = 69.686
    local hash = util.joaat("khanjali")
    local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, head)
    if vehicle ~= 0 then
        Upgrade_Vehicle(vehicle)
        ENTITY.SET_ENTITY_INVINCIBLE(vehicle, true)
        util.toast("Done!")
    end
end)
menu.action(Mission_Assistant_Huamane, "电磁装置：九头蛇 无敌", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, 970385471)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            if RequestControl(ent) then
                ENTITY.SET_ENTITY_INVINCIBLE(ent, true)
                util.toast("Done!")
            end
        end
    end
end)
menu.action(Mission_Assistant_Huamane, "运送电磁装置：叛乱分子 传送到目的地", {}, "", function()
    local coords = {
        x = 3339.7307, y = 3670.7246, z = 43.8973
    }
    local head = 312.5133
    local entity_list = get_entities_by_hash("vehicle", true, 2071877360)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            local blip = HUD.GET_BLIP_FROM_ENTITY(ent)
            if blip > 0 then
                if RequestControl(ent) then
                    SET_ENTITY_COORDS(ent, coords)
                    ENTITY.SET_ENTITY_HEADING(ent, head)
                    util.toast("Done!")
                end
            end
        end
    end
end)
menu.action(Mission_Assistant_Huamane, "终章：女武神 无敌", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, -1600252419)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            if RequestControl(ent) then
                ENTITY.SET_ENTITY_INVINCIBLE(ent, true)
                util.toast("Done!")
            end
        end
    end
end)

local Mission_Assistant_Series = menu.list(Mission_Assistant, "首轮募资", {}, "")
menu.action(Mission_Assistant_Series, "可卡因：直升机 无敌", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, 744705981)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            if RequestControl(ent) then
                ENTITY.SET_ENTITY_INVINCIBLE(ent, true)
                util.toast("Done!")
            end
        end
    end
end)
menu.action(Mission_Assistant_Series, "窃取冰毒：油罐车 无敌", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, 1956216962)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            if RequestControl(ent) then
                ENTITY.SET_ENTITY_INVINCIBLE(ent, true)
                util.toast("Done!")
            end
        end
    end
end)
menu.action(Mission_Assistant_Series, "窃取冰毒：油罐车位置 生成尖锥魅影", {}, "", function()
    local coords = {
        x = 2416.0986, y = 5012.4545, z = 46.6019
    }
    local heading = 132.7993
    local hash = util.joaat("phantom2")
    local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, heading)
    if vehicle ~= 0 then
        Upgrade_Vehicle(vehicle)
        ENTITY.SET_ENTITY_INVINCIBLE(vehicle, true)
        util.toast("Done!")
    end
end)

local Mission_Assistant_Pacific = menu.list(Mission_Assistant, "太平洋标准银行", {}, "")
menu.action(Mission_Assistant_Pacific, "厢型车：司机 传送到海洋并冻结", {}, "", function()
    local coords = {
        x = 4912, y = -4910, z = 20
    }
    local entity_list = get_entities_by_hash("vehicle", true, 444171386)
    if next(entity_list) ~= nil then
        local i = 0
        for k, ent in pairs(entity_list) do
            local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ent, -1)
            if ped and not IS_PED_PLAYER(ped) then
                if RequestControl(ped) then
                    TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                    SET_ENTITY_COORDS(ped, coords)
                    ENTITY.FREEZE_ENTITY_POSITION(ped, true)
                    coords.x = coords.x + 3
                    coords.y = coords.y + 3
                    i = i + 1
                end
            end
        end
        util.toast("Done!\nNumber: " .. i)
    end
end)
menu.action(Mission_Assistant_Pacific, "厢型车：传送到目的地", {}, "传送司机到海洋，车传送到莱斯特工厂"
    , function()
    local coords = {
        x = 4912, y = -4910, z = 20
    }
    local coords2 = {
        x = 760, y = -983, z = 26
    }
    local head = 93.6973
    local entity_list = get_entities_by_hash("vehicle", true, 444171386)
    if next(entity_list) ~= nil then
        local i = 0
        for k, ent in pairs(entity_list) do
            local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ent, -1)
            if ped and not IS_PED_PLAYER(ped) then
                if RequestControl(ped) then
                    TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                    SET_ENTITY_COORDS(ped, coords)
                    ENTITY.FREEZE_ENTITY_POSITION(ped, true)
                    coords.x = coords.x + 3
                end
            end
            if RequestControl(ent) then
                SET_ENTITY_COORDS(ent, coords2)
                ENTITY.SET_ENTITY_HEADING(ent, head)
                coords2.y = coords2.y + 3.5
                i = i + 1
            end
        end
        util.toast("Done!\nNumber: " .. i)
    end
end)
menu.action(Mission_Assistant_Pacific, "信号：岛上 生成直升机", {}, "撤离时", function()
    local coords = {
        x = -2188.197, y = 5128.990, z = 11.672
    }
    local head = 314.255
    local hash = util.joaat("polmav")
    local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, head)
    if vehicle ~= 0 then
        Upgrade_Vehicle(vehicle)
        ENTITY.SET_ENTITY_INVINCIBLE(vehicle, true)
        util.toast("Done!")
    end
end)
menu.action(Mission_Assistant_Pacific, "车队：目的地 生成坦克", {}, "", function()
    local coords = {
        x = -196.452, y = 4221.374, z = 45.376
    }
    local head = 313.298
    local hash = util.joaat("khanjali")
    local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, head)
    if vehicle ~= 0 then
        Upgrade_Vehicle(vehicle)
        ENTITY.SET_ENTITY_INVINCIBLE(vehicle, true)
        util.toast("Done!")
    end
end)
menu.action(Mission_Assistant_Pacific, "车队：卡车 无敌", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, 630371791)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            if RequestControl(ent) then
                ENTITY.SET_ENTITY_INVINCIBLE(ent, true)
                util.toast("Done!")
            end
        end
    end
end)
menu.action(Mission_Assistant_Pacific, "摩托车：雷克卓 升级无敌", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, 640818791)
    if next(entity_list) ~= nil then
        local i = 0
        for k, ent in pairs(entity_list) do
            if RequestControl(ent) then
                ENTITY.SET_ENTITY_INVINCIBLE(ent, true)
                Upgrade_Vehicle(ent)
                i = i + 1
            end
        end
        util.toast("Done!\nNumber: " .. i)
    end
end)
menu.action(Mission_Assistant_Pacific, "终章：摩托车位置 生成骷髅马", {}, "", function()
    local coords = {
        x = 36.002, y = 94.153, z = 78.751
    }
    local head = 249.426
    local hash = util.joaat("kuruma2")
    local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, head)
    if vehicle ~= 0 then
        Upgrade_Vehicle(vehicle)
        ENTITY.SET_ENTITY_INVINCIBLE(vehicle, true)
        util.toast("Done!")
    end
end)
menu.action(Mission_Assistant_Pacific, "终章：摩托车位置 生成直升机", {}, "", function()
    local coords = {
        x = 52.549, y = 88.787, z = 78.683
    }
    local head = 15.508
    local hash = util.joaat("polmav")
    local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, head)
    if vehicle ~= 0 then
        Upgrade_Vehicle(vehicle)
        ENTITY.SET_ENTITY_INVINCIBLE(vehicle, true)
        util.toast("Done!")
    end
end)



-----
menu.click_slider(Mission_options, "增加任务生命数", { "team_lives" }, "只有是战局主机时才会生效？",
    -1, 30000, 0, 1, function(value)
    if SCRIPT.HAS_SCRIPT_LOADED("fm_mission_controller") then
        SET_INT_LOCAL("fm_mission_controller", Locals.MC_TLIVES, value)
    elseif SCRIPT.HAS_SCRIPT_LOADED("fm_mission_controller_2020") then
        SET_INT_LOCAL("fm_mission_controller_2020", Locals.MC_TLIVES_2020, value)
    else
        util.toast("未进行任务")
    end
end)
menu.action(Mission_options, "跳过破解", { "skip_hacking" }, "所有的破解、骇入、钻孔等等", function()
    local script = "fm_mission_controller_2020"
    if SCRIPT.HAS_SCRIPT_LOADED(script) then
        -- Fingerprint Clone
        if GET_INT_LOCAL(script, 22032) == 4 then
            SET_INT_LOCAL(script, 22032, 5)
        end
        -- Sewer Fence Scene
        if GET_INT_LOCAL(script, 26746) == 4 then
            SET_INT_LOCAL(script, 26746, 6)
        end

        SET_FLOAT_LOCAL(script, 27985 + 3, 100) -- Glass Cutter
        SET_INT_LOCAL(script, 974 + 135, 3) -- For ULP Missions
    end

    script = "fm_mission_controller"
    if SCRIPT.HAS_SCRIPT_LOADED(script) then
        -- For Fingerprint
        if GET_INT_LOCAL(script, 52962) ~= 1 then
            SET_INT_LOCAL(script, 52962, 5)
        end
        -- For Keypad
        if GET_INT_LOCAL(script, 54024) ~= 1 then
            SET_INT_LOCAL(script, 54024, 5)
        end
        -- Instant Vault Door Laser
        local Value = GET_INT_LOCAL(script, 10098 + 37)
        SET_INT_LOCAL(script, 10098 + 7, Value)

        -- Doomsday Heist
        SET_INT_LOCAL(script, 1265 + 135, 3) -- For ACT III - Beam Puzzle
        SET_INT_LOCAL(script, 1510, 2) -- For ACT I, Setup: Server Farm (Lester)

        -- Fleeca Heist
        SET_INT_LOCAL(script, 11757 + 24, 7) -- VLSI Circuit Breaker 2.0
        SET_FLOAT_LOCAL(script, 10042 + 11, 100) -- vaultDrillHoleDepth Skip Drilling
    end
end)
menu.toggle_loop(Mission_options, "Voltage Hack", { "voltage_hack" }, "", function()
    local script = "fm_mission_controller_2020"
    if SCRIPT.HAS_SCRIPT_LOADED(script) then
        -- Infinite Voltage Timer
        local Value = GET_INT_LOCAL(script, 1718)
        SET_INT_LOCAL(script, 1717, Value)
    end
end)
