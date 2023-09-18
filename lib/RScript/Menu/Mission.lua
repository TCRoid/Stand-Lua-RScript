--------------------------------
------------ 任务选项 -----------
--------------------------------

local Mission_Options = menu.list(menu.my_root(), "任务选项", {}, "")


---------------------
-- 资产任务
---------------------
local Property_Mission = menu.list(Mission_Options, "资产任务", {}, "")

--#region Special Cargo

local Special_Cargo = menu.list(Property_Mission, "办公室拉货", {}, "")

--#region Special Cargo Tool

local Special_Cargo_Tool = menu.list(Special_Cargo, "工具", {}, "")

menu.divider(Special_Cargo_Tool, "移除冷却时间")
menu.toggle(Special_Cargo_Tool, "特种货物", { "nocd_specialcargo" }, "购买和出售", function(toggle)
    Globals.RemoveCooldown.SpecialCargo(toggle)
    Transition_Handler.Globals.Cooldown.SpecialCargo = toggle
end)
menu.toggle(Special_Cargo_Tool, "载具货物", { "nocd_vehcargo" }, "购买和出售", function(toggle)
    Globals.RemoveCooldown.VehicleCargo(toggle)
    Transition_Handler.Globals.Cooldown.VehicleCargo = toggle
end)

menu.divider(Special_Cargo_Tool, "任务助手")
menu.action(Special_Cargo_Tool, "购买货物 任务助手", {},
    "需要点击两次\n第一次点击会自动清空任务记录,只保留开启推荐的购买任务,禁用其它任务,打开电脑界面\n开启任务后,第二次点击就会将货物传送到我\n记得设置移除冷却时间",
    function()
        if IS_SCRIPT_RUNNING("gb_contraband_buy") then
            local entity_list = get_entities_by_hash("pickup", true, -265116550, 1688540826, -1143129136)
            if next(entity_list) ~= nil then
                OBJECT.SET_MAX_NUM_PORTABLE_PICKUPS_CARRIED_BY_PLAYER(ENTITY.GET_ENTITY_MODEL(entity_list[1]), 3)
                for k, ent in pairs(entity_list) do
                    TP_TO_ME(ent)
                end
            else
                util.toast("未找到货物")
            end
        else
            if players.get_org_type(players.user()) ~= 0 then
                menu.trigger_commands("ceostart")
                util.toast("已自动成为CEO")
            end

            Globals.SpecialCargo.ClearMissionHistory()
            for key, offset in pairs(Globals.SpecialCargo.Buy_Offsets) do
                if key == 1 then -- EXEC_DISABLE_BUY_AFTERMATH
                    SET_INT_GLOBAL(262145 + offset, 0)
                else
                    SET_INT_GLOBAL(262145 + offset, 1)
                end
            end
            menu.trigger_commands("appterrorbyte")
            PAD.SET_CURSOR_POSITION(0.718, 0.272)

            util.toast("请先开启任务")
        end
    end)
menu.action(Special_Cargo_Tool, "出售货物 任务助手", {}, "清空任务记录,只保留开启推荐的出售任务,禁用其它任务",
    function()
        Globals.SpecialCargo.ClearMissionHistory()
        for key, offset in pairs(Globals.SpecialCargo.Sell_Offsets) do
            if key == 10 then -- EXEC_DISABLE_SELL_NODAMAGE
                SET_INT_GLOBAL(262145 + offset, 0)
            else
                SET_INT_GLOBAL(262145 + offset, 1)
            end
        end
    end)

menu.divider(Special_Cargo_Tool, "禁用任务")

local special_cargo_missions = {
    buy = {},
    sell = {}
}

special_cargo_missions.menu_buy = menu.list(Special_Cargo_Tool, "禁用购买货物任务", {}, "", function()
    if not special_cargo_missions.buy.created then
        Transition_Handler.Globals.SpecialCargo.Buy = {}

        special_cargo_missions.buy.toggle_menus = {}
        menu.toggle(special_cargo_missions.menu_buy, "全部开/关", {}, "", function(toggle)
            for key, value in pairs(special_cargo_missions.buy.toggle_menus) do
                menu.set_value(value, toggle)
            end
        end)

        for key, offset in pairs(Globals.SpecialCargo.Buy_Offsets) do
            local name = Globals.SpecialCargo.Buy_Names[key][1]
            local help = Globals.SpecialCargo.Buy_Names[key][2]
            local global = 262145 + offset

            special_cargo_missions.buy.toggle_menus[global] = menu.toggle(special_cargo_missions.menu_buy, name, {}, help,
                function(toggle)
                    if toggle then
                        SET_INT_GLOBAL(global, 1)
                    else
                        SET_INT_GLOBAL(global, 0)
                    end
                    Transition_Handler.Globals.SpecialCargo.Buy[global] = toggle
                end)
        end

        special_cargo_missions.buy.created = true
    end
end)

special_cargo_missions.menu_sell = menu.list(Special_Cargo_Tool, "禁用出售货物任务", {}, "", function()
    if not special_cargo_missions.sell.created then
        Transition_Handler.Globals.SpecialCargo.Sell = {}

        special_cargo_missions.sell.toggle_menus = {}
        menu.toggle(special_cargo_missions.menu_sell, "全部开/关", {}, "", function(toggle)
            for key, value in pairs(special_cargo_missions.sell.toggle_menus) do
                menu.set_value(value, toggle)
            end
        end)

        for key, offset in pairs(Globals.SpecialCargo.Sell_Offsets) do
            local name = Globals.SpecialCargo.Sell_Names[key][1]
            local help = Globals.SpecialCargo.Sell_Names[key][2]
            local global = 262145 + offset

            special_cargo_missions.sell.toggle_menus[global] = menu.toggle(special_cargo_missions.menu_sell, name, {},
                help,
                function(toggle)
                    if toggle then
                        SET_INT_GLOBAL(global, 1)
                    else
                        SET_INT_GLOBAL(global, 0)
                    end
                    Transition_Handler.Globals.SpecialCargo.Sell[global] = toggle
                end)
        end

        special_cargo_missions.sell.created = true
    end
end)

menu.divider(Special_Cargo_Tool, "")
menu.toggle_loop(Special_Cargo_Tool, "清空任务记录", {}, "就可以重复做同一个任务了", function()
    Globals.SpecialCargo.ClearMissionHistory()
end)
menu.slider(Special_Cargo_Tool, "货物类型刷新时间", { "cargo_type_refresh_time" }, "",
    0, 2880, 2880, 100, function(value)
        SET_FLOAT_GLOBAL(Globals.SpecialCargo.EXEC_CONTRABAND_TYPE_REFRESH_TIME, value)
        Transition_Handler.Globals.SpecialCargo.Type_Refresh_Time = value
    end)
menu.slider_float(Special_Cargo_Tool, "特殊物品概率", { "special_item_chance" }, "",
    0, 100, 10, 10, function(value)
        value = value * 0.01
        SET_FLOAT_GLOBAL(Globals.SpecialCargo.EXEC_CONTRABAND_SPECIAL_ITEM_CHANCE, value)
        Transition_Handler.Globals.SpecialCargo.Special_Item_Chance = value
    end)

--#endregion

menu.action(Special_Cargo, "传送到 特种货物", { "tp_cargo" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(478)
    if HUD.DOES_BLIP_EXIST(blip) then
        local coords = HUD.GET_BLIP_COORDS(blip)
        TELEPORT(coords.x, coords.y, coords.z + 1.0)
    end
end)
menu.action(Special_Cargo, "特种货物 传送到我", { "tpme_cargo" }, "", function()
    local entity_list = get_entities_by_hash("pickup", true, -265116550, 1688540826, -1143129136) --货物
    if next(entity_list) ~= nil then
        OBJECT.SET_MAX_NUM_PORTABLE_PICKUPS_CARRIED_BY_PLAYER(ENTITY.GET_ENTITY_MODEL(entity_list[1]), 3)
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent)
        end
    else
        local blip = HUD.GET_NEXT_BLIP_INFO_ID(478)
        if HUD.DOES_BLIP_EXIST(blip) then
            local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
                TP_TO_ME(ent)

                if ENTITY.IS_ENTITY_A_VEHICLE(ent) then
                    TP_INTO_VEHICLE(ent, "delete", "delete")
                end
            else
                util.toast("目标不是实体，无法传送到我")
            end
        end
    end
end)
menu.action(Special_Cargo, "特种货物(载具) 传送到我", {}, "Trackify追踪的车", function()
    local entity_list = get_entities_by_hash("object", true, -1322183878, -2022916910) --车里的货物
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            if ENTITY.IS_ENTITY_ATTACHED(ent) then
                local attached_ent = ENTITY.GET_ENTITY_ATTACHED_TO(ent)
                if ENTITY.IS_ENTITY_A_VEHICLE(attached_ent) then
                    TP_VEHICLE_TO_ME(attached_ent, "delete", "delete")
                end
            end
        end
    end
end)

menu.divider(Special_Cargo, "")
menu.action(Special_Cargo, "传送到 仓库助理", { "tp_cargo_assistant" }, "让他去拉货", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(480)
    if HUD.DOES_BLIP_EXIST(blip) then
        local coords = HUD.GET_BLIP_COORDS(blip)
        TELEPORT(coords.x - 1.0, coords.y, coords.z)
    end
end)
local special_cargo_lupe_menu
local special_cargo_lupe_ent -- 实体列表
special_cargo_lupe_menu = menu.list_action(Special_Cargo, "卢佩: 传送到 水下货箱", {}, "",
    { "刷新货箱列表" }, function(value)
        -- Hash: -1235210928(object) 水下要炸的货箱
        if value == 1 then
            --货箱里面 要拾取的包裹
            local water_cargo_hash_list = { 388143302, -36934887, 319657375, 924741338, -1249748547 }

            special_cargo_lupe_ent = {}
            local list_item_data = { "刷新货箱列表" }
            local i = 1

            for k, ent in pairs(entities.get_all_objects_as_handles()) do
                if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
                    local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
                    if isInTable(water_cargo_hash_list, EntityHash) then
                        table.insert(special_cargo_lupe_ent, ent)
                        table.insert(list_item_data, "货箱 " .. i)
                        i = i + 1
                    end
                end
            end

            menu.set_list_action_options(special_cargo_lupe_menu, list_item_data)
            util.toast("已刷新，请重新打开该列表")
        else
            local ent = special_cargo_lupe_ent[value - 1]
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                if ENTITY.IS_ENTITY_ATTACHED(ent) then
                    local attached_ent = ENTITY.GET_ENTITY_ATTACHED_TO(ent)
                    TP_TO_ENTITY(attached_ent, 0.0, -2.5, 0.0)
                    SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), attached_ent)
                end
            end
        end
    end)
menu.action(Special_Cargo, "出货: 阻挡飞机生成点", {}, "任务开始前使用\n通过阻挡任务刷新点来避免触发该任务",
    function()
        local point_list = {
            -- x, y, z, heading
            { -1003.719543457,  -3407.0595703125, 14.677012443542, 61.844367980957 },
            { -1710.9633789062, -2776.2690429688, 15.974478721619, 214.03160095215 },
        }
        block_mission_generate_point(point_list, util.joaat("titan"))
    end)
menu.action(Special_Cargo, "出货: 阻挡船生成点", {}, "任务开始前使用\n通过阻挡任务刷新点来避免触发该任务",
    function()
        local point_list = {
            -- x, y, z, heading
            { 87.875244140625,  -2274.0803222656, 1.2261204719543,  93.840309143066 },
            { -570.71759033203, -2778.822265625,  1.0738935470581,  133.22221374512 },
            { 623.02789306641,  -3247.4519042969, 0.19836987555027, 185.60623168945 },
        }
        block_mission_generate_point(point_list, util.joaat("tug"))
    end)


menu.divider(Special_Cargo, "载具货物")
menu.action(Special_Cargo, "传送到 载具货物", { "tp_vehcargo" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(523)
    if HUD.DOES_BLIP_EXIST(blip) then
        local coords = HUD.GET_BLIP_COORDS(blip)
        TELEPORT(coords.x, coords.y, coords.z + 1.0)
    end
end)
menu.action(Special_Cargo, "载具货物 传送到我", { "tpme_vehcargo" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(523)
    if HUD.DOES_BLIP_EXIST(blip) then
        local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
            TP_TO_ME(ent, 0.0, 1.0, -0.5)

            if ENTITY.IS_ENTITY_A_VEHICLE(ent) then
                TP_INTO_VEHICLE(ent, "", "delete")
            end
        else
            util.toast("目标不是实体，无法传送到我")
        end
    end
end)

local vehicle_cargo_menu
local vehicle_cargo_ent -- 实体列表
vehicle_cargo_menu = menu.list_action(Special_Cargo, "任务载具列表", {}, "点击目标载具即可传送到我",
    { "刷新载具列表" }, function(value)
        if value == 1 then
            vehicle_cargo_ent = {}
            local list_item_data = { "刷新载具列表" }

            for k, veh in pairs(entities.get_all_vehicles_as_handles()) do
                if ENTITY.IS_ENTITY_A_MISSION_ENTITY(veh) then
                    table.insert(vehicle_cargo_ent, veh)
                    table.insert(list_item_data, get_vehicle_display_name(veh))
                end
            end

            menu.set_list_action_options(vehicle_cargo_menu, list_item_data)
            util.toast("已刷新，请重新打开该列表")
        else
            local ent = vehicle_cargo_ent[value - 1]
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                TP_VEHICLE_TO_ME(ent, "", "delete")
            end
        end
    end)

--#endregion


--#region Bunker

local Bunker = menu.list(Property_Mission, "地堡拉货", {}, "")

--#region Bunker Tool

local Bunker_Tool = menu.list(Bunker, "工具", {}, "")

menu.divider(Bunker_Tool, "补充原材料")
menu.slider(Bunker_Tool, "包裹原材料 补充进度", { "bk_resupply_package" }, "", 0, 100, 20, 5, function(value)
    SET_INT_GLOBAL(Globals.Bunker.GR_RESUPPLY_PACKAGE_VALUE, value)
    Transition_Handler.Globals.Bunker.Resupply_Package_Value = value
end)
menu.slider(Bunker_Tool, "载具原材料 补充进度", { "bk_resupply_vehicle" }, "", 0, 100, 40, 5, function(value)
    SET_INT_GLOBAL(Globals.Bunker.GR_RESUPPLY_VEHICLE_VALUE, value)
    Transition_Handler.Globals.Bunker.Resupply_Vehicle_Value = value
end)

menu.divider(Bunker_Tool, "任务助手")
menu.action(Bunker_Tool, "偷取原材料 任务助手", {},
    "需要点击两次\n第一次点击会自动清空任务记录,只保留开启推荐的购买任务,禁用其它任务,打开电脑界面\n开启任务后,第二次点击就会将货物传送到我",
    function()
        if IS_SCRIPT_RUNNING("gb_gunrunning") then
            local entity_list = get_entities_by_hash("vehicle", true, 1026149675)
            if next(entity_list) ~= nil then
                for k, ent in pairs(entity_list) do
                    TP_VEHICLE_TO_ME(ent)
                end
            else
                util.toast("未找到原材料")
            end
        else
            if players.get_org_type(players.user()) == -1 then
                menu.trigger_commands("ceostart")
                util.toast("已自动成为CEO")
            end

            Globals.Bunker.ClearMissionHistory()
            for key, offset in pairs(Globals.Bunker.Steal_Offsets) do
                if key == 1 then -- GR_STEAL_VAN_STEAL_VAN_WEIGHTING
                    SET_FLOAT_GLOBAL(262145 + offset, 1)
                else
                    SET_FLOAT_GLOBAL(262145 + offset, 0)
                end
            end
            menu.trigger_commands("appterrorbyte")
            PAD.SET_CURSOR_POSITION(0.501, 0.651)

            util.toast("请先开启任务")
        end
    end)
menu.action(Bunker_Tool, "出售货物 任务助手", {}, "清空任务记录,只保留开启推荐的出售任务,禁用其它任务",
    function()
        Globals.Bunker.ClearMissionHistory()
        for key, offset in pairs(Globals.Bunker.Sell_Offsets) do
            if key == 6 then -- GR_PHANTOM_PHANTOM_WEIGHTING
                SET_FLOAT_GLOBAL(262145 + offset, 1)
            else
                SET_FLOAT_GLOBAL(262145 + offset, 0)
            end
        end
    end)

menu.divider(Bunker_Tool, "禁用任务")

local bunker_missions = {
    steal = {},
    sell = {}
}

bunker_missions.menu_steal = menu.list(Bunker_Tool, "禁用偷取原材料任务", {}, "", function()
    if not bunker_missions.steal.created then
        Transition_Handler.Globals.Bunker.Steal = {}

        bunker_missions.steal.toggle_menus = {}
        menu.toggle(bunker_missions.menu_steal, "全部开/关", {}, "", function(toggle)
            for key, value in pairs(bunker_missions.steal.toggle_menus) do
                menu.set_value(value, toggle)
            end
        end)

        for key, offset in pairs(Globals.Bunker.Steal_Offsets) do
            local name = Globals.Bunker.Steal_Names[key][1]
            local help = Globals.Bunker.Steal_Names[key][2]
            local global = 262145 + offset

            bunker_missions.steal.toggle_menus[global] = menu.toggle(bunker_missions.menu_steal, name, {}, help,
                function(toggle)
                    if toggle then
                        SET_FLOAT_GLOBAL(global, 0)
                    else
                        SET_FLOAT_GLOBAL(global, 1)
                    end
                    Transition_Handler.Globals.Bunker.Steal[global] = toggle
                end)
        end

        bunker_missions.steal.created = true
    end
end)

bunker_missions.menu_sell = menu.list(Bunker_Tool, "禁用出售货物任务", {}, "", function()
    if not bunker_missions.sell.created then
        Transition_Handler.Globals.Bunker.Sell = {}

        bunker_missions.sell.toggle_menus = {}
        menu.toggle(bunker_missions.menu_sell, "全部开/关", {}, "", function(toggle)
            for key, value in pairs(bunker_missions.sell.toggle_menus) do
                menu.set_value(value, toggle)
            end
        end)

        for key, offset in pairs(Globals.Bunker.Sell_Offsets) do
            local name = Globals.Bunker.Sell_Names[key][1]
            local help = Globals.Bunker.Sell_Names[key][2]
            local global = 262145 + offset

            bunker_missions.sell.toggle_menus[global] = menu.toggle(bunker_missions.menu_sell, name, {}, help,
                function(toggle)
                    if toggle then
                        SET_FLOAT_GLOBAL(global, 0)
                    else
                        SET_FLOAT_GLOBAL(global, 1)
                    end
                    Transition_Handler.Globals.Bunker.Sell[global] = toggle
                end)
        end

        bunker_missions.sell.created = true
    end
end)

menu.divider(Bunker_Tool, "")
menu.toggle_loop(Bunker_Tool, "清空任务记录", {}, "就可以重复做同一个任务了", function()
    Globals.Bunker.ClearMissionHistory()
end)
menu.action(Bunker_Tool, "移除地堡武器零件冷却时间", {}, "STAT", function()
    STAT_SET_INT("BUNKER_CRATE_COOLDOWN", 0)
end)

--#endregion

menu.action(Bunker, "传送到 原材料", { "tp_bk_supply" }, "", function()
    local blip1 = HUD.GET_NEXT_BLIP_INFO_ID(556)
    local blip2 = HUD.GET_NEXT_BLIP_INFO_ID(561)
    local blip3 = HUD.GET_NEXT_BLIP_INFO_ID(477)

    if HUD.DOES_BLIP_EXIST(blip1) then
        local coords = HUD.GET_BLIP_COORDS(blip1)
        TELEPORT(coords.x, coords.y + 2.0, coords.z + 1.0)
    elseif HUD.DOES_BLIP_EXIST(blip2) then
        local coords = HUD.GET_BLIP_COORDS(blip2)
        TELEPORT(coords.x, coords.y, coords.z + 1.0)
    elseif HUD.DOES_BLIP_EXIST(blip3) then
        local coords = HUD.GET_BLIP_COORDS(blip3)
        TELEPORT(coords.x, coords.y, coords.z + 1.0)
    end
end)
menu.action(Bunker, "原材料 传送到我", { "tpme_bk_supply" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(556)
    if not HUD.DOES_BLIP_EXIST(blip) then
        local entity_list = get_entities_by_hash("pickup", true, -955159266)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ME(ent)
            end
        end
    else
        local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
            TP_TO_ME(ent)

            if ENTITY.IS_ENTITY_A_VEHICLE(ent) then
                TP_INTO_VEHICLE(ent, "delete", "delete")
            end
        else
            util.toast("目标不是实体，无法传送到我")
        end
    end
end)

menu.divider(Bunker, "")
menu.action(Bunker, "爆炸 所有敌对载具", {}, "", function()
    explode_hostile_vehicles()
end)
menu.action(Bunker, "爆炸 所有敌对物体", {}, "", function()
    explode_hostile_objects()
end)
menu.action(Bunker, "骇入飞机 传送到我", {}, "传送到头上并冻结", function()
    local entity_list = get_entities_by_hash("vehicle", true, -32878452)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            ENTITY.FREEZE_ENTITY_POSITION(ent, true)
            TP_TO_ME(ent, 0.0, 0.0, 10.0)
        end
    end
end)
menu.action(Bunker, "长鳍追飞机: 掉落货物 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("object", true, 91541528)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 0.0, 1.0)
        end
    end
end)
menu.action(Bunker, "长鳍追飞机: 炸掉长鳍", {},
    "不再等飞机慢慢地投放货物", function()
        local entity_list = get_entities_by_hash("vehicle", true, 1861786828) --长鳍
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                ENTITY.SET_ENTITY_INVINCIBLE(ent, false)
                local pos = ENTITY.GET_ENTITY_COORDS(ent)
                add_owned_explosion(players.user_ped(), pos)
            end
        end
    end)

--#endregion


--#region Air Freight

local Air_Freight = menu.list(Property_Mission, "机库拉货", {}, "")

--#region Air Freight Tool

local Air_Freight_Tool = menu.list(Air_Freight, "工具", {}, "")

menu.toggle(Air_Freight_Tool, "移除冷却时间", { "nocd_airfreight" }, "进货和出售\n任务开始前启用",
    function(toggle)
        Globals.RemoveCooldown.AirFreightCargo(toggle)
        Transition_Handler.Globals.Cooldown.AirFreightCargo = toggle
    end)

menu.divider(Air_Freight_Tool, "任务助手")
menu.action(Air_Freight_Tool, "偷取货物 航空任务助手", {},
    "需要点击两次\n第一次点击会自动清空任务记录,只保留开启推荐的购买任务,禁用其它任务,打开电脑界面\n开启任务后,第二次点击就会将货物传送到我\n记得设置移除冷却时间",
    function()
        if IS_SCRIPT_RUNNING("gb_smuggler") then
            local entity_list = get_entities_by_hash("pickup", true, -1270906188, -204239524, 2085196638, 886033073,
                1419829219, 1248987568, -2037094101, -49487954)
            if next(entity_list) ~= nil then
                for k, ent in pairs(entity_list) do
                    detach_product_entity(ent)
                    TP_TO_ME(ent)
                end
            else
                util.toast("未找到货物")
            end
        else
            if players.get_org_type(players.user()) == -1 then
                menu.trigger_commands("ceostart")
                util.toast("已自动成为CEO")
            end

            Globals.AirFreight.ClearMissionHistory()
            for key, offset in pairs(Globals.AirFreight.Steal_Offsets) do
                if key == 8 then -- SMUG_STEAL_BLACKBOX_WEIGHTING
                    SET_FLOAT_GLOBAL(262145 + offset, 1)
                else
                    SET_FLOAT_GLOBAL(262145 + offset, 0)
                end
            end
            menu.trigger_commands("apphangar")
            PAD.SET_CURSOR_POSITION(0.631, 0.0881)

            util.toast("请先开启任务")
        end
    end)

menu.divider(Air_Freight_Tool, "禁用任务")

local air_freight_missions = {
    steal = {},
    sell = {}
}

air_freight_missions.menu_steal = menu.list(Air_Freight_Tool, "禁用航空偷取货物任务", {}, "", function()
    if not air_freight_missions.steal.created then
        Transition_Handler.Globals.AirFreight.Steal = {}

        air_freight_missions.steal.toggle_menus = {}
        menu.toggle(air_freight_missions.menu_steal, "全部开/关", {}, "", function(toggle)
            for key, value in pairs(air_freight_missions.steal.toggle_menus) do
                menu.set_value(value, toggle)
            end
        end)

        for key, offset in pairs(Globals.AirFreight.Steal_Offsets) do
            local name = Globals.AirFreight.Steal_Names[key][1]
            local help = Globals.AirFreight.Steal_Names[key][2]
            local global = 262145 + offset

            air_freight_missions.steal.toggle_menus[global] = menu.toggle(air_freight_missions.menu_steal, name, {}, help,
                function(toggle)
                    if toggle then
                        SET_FLOAT_GLOBAL(global, 0)
                    else
                        SET_FLOAT_GLOBAL(global, 1)
                    end
                    Transition_Handler.Globals.AirFreight.Steal[global] = toggle
                end)
        end

        air_freight_missions.steal.created = true
    end
end)

air_freight_missions.menu_sell = menu.list(Air_Freight_Tool, "禁用航空出售货物任务", {}, "", function()
    if not air_freight_missions.sell.created then
        Transition_Handler.Globals.AirFreight.Sell = {}

        air_freight_missions.sell.toggle_menus = {}
        menu.toggle(air_freight_missions.menu_sell, "全部开/关", {}, "", function(toggle)
            for key, value in pairs(air_freight_missions.sell.toggle_menus) do
                menu.set_value(value, toggle)
            end
        end)

        for key, offset in pairs(Globals.AirFreight.Sell_Offsets) do
            local name = Globals.AirFreight.Sell_Names[key][1]
            local help = Globals.AirFreight.Sell_Names[key][2]
            local global = 262145 + offset

            air_freight_missions.sell.toggle_menus[global] = menu.toggle(air_freight_missions.menu_sell, name, {}, help,
                function(toggle)
                    if toggle then
                        SET_FLOAT_GLOBAL(global, 0)
                    else
                        SET_FLOAT_GLOBAL(global, 1)
                    end
                    Transition_Handler.Globals.AirFreight.Sell[global] = toggle
                end)
        end

        air_freight_missions.sell.created = true
    end
end)

menu.divider(Air_Freight_Tool, "")
menu.toggle_loop(Air_Freight_Tool, "清空任务记录", {}, "就可以重复做同一个任务了", function()
    Globals.AirFreight.ClearMissionHistory()
end)

--#endregion

menu.action(Air_Freight, "传送到 货物", { "tp_air_product" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(568)
    if HUD.DOES_BLIP_EXIST(blip) then
        local coords = HUD.GET_BLIP_COORDS(blip)
        TELEPORT(coords.x, coords.y, coords.z + 1.0)
    end
end)
menu.action(Air_Freight, "货物 传送到我", { "tpme_air_product" }, "", function()
    local entity_list = get_entities_by_hash("pickup", true, -1270906188, -204239524, 2085196638, 886033073, 1419829219,
        1248987568, -2037094101, -49487954)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            detach_product_entity(ent)
            TP_TO_ME(ent)
        end
    else
        local blip = HUD.GET_NEXT_BLIP_INFO_ID(568)
        if HUD.DOES_BLIP_EXIST(blip) then
            local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                TP_TO_ME(ent)
            else
                util.toast("目标不是实体，无法传送到我")
            end
        end
    end
end)

menu.divider(Air_Freight, "")
menu.action(Air_Freight, "陆地: 炸掉发电机", {}, "", function()
    local entity_list = get_entities_by_hash("object", true, 209668540)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            local coords = ENTITY.GET_ENTITY_COORDS(ent)
            coords.z = coords.z + 1.0
            add_owned_explosion(players.user_ped(), coords, 4)
        end
    end
end)
menu.action(Air_Freight, "陆地: 传送到 释放开关", {}, "", function()
    local entity_list = get_entities_by_hash("object", true, 162166615)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, -0.5, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ent)
        end
    end
end)
menu.action(Air_Freight, "陆地: 传送进 阿维萨", {}, "然后再传送到货物", function()
    local entity_list = get_entities_by_hash("vehicle", true, -1706603682)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            PED.SET_PED_INTO_VEHICLE(players.user_ped(), ent, -1)
        end
    end
end)
menu.action(Air_Freight, "陆地: 阻挡卡车生成点", {}, "任务开始前使用\n通过阻挡任务刷新点来避免触发该任务",
    function()
        local point_list = {
            -- x, y, z, heading
            { 1222.287109375,  3653.935546875,   32.6698837,      218.56228637695 },
            { 1138.6461181641, -3345.8781738281, 6.1329517364502, 269.39321899414 },
            { 932.59674072266, 6618.7387695312,  3.6754860877991, 204.03558349609 },
        }
        block_mission_generate_point(point_list)
    end)
menu.action(Air_Freight, "航空: 毁掉泰坦号", {}, "直接任务失败", function()
    local entity_list = get_entities_by_hash("vehicle", true, 1981688531)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 20.0, 100.0)
            util.yield(2000)
            entities.delete(ent)
        end
    end
end)

menu.action(Air_Freight, "爆炸 所有敌对载具", { "veh_hostile_explode" }, "", function()
    explode_hostile_vehicles()
end)
menu.action(Air_Freight, "爆炸 所有敌对NPC", { "ped_hostile_explode" }, "", function()
    for _, ped in pairs(entities.get_all_peds_as_handles()) do
        if IS_HOSTILE_ENTITY(ped) then
            local coords = ENTITY.GET_ENTITY_COORDS(ped)
            add_owned_explosion(players.user_ped(), coords, 4, { isAudible = false })
        end
    end
end)
menu.action(Air_Freight, "爆炸 所有敌对物体", { "obj_hostile_explode" }, "", function()
    explode_hostile_objects()
end)

menu.action(Air_Freight, "传送到 鲁斯特", {}, "让他去拉货", function()
    local entity_list = get_entities_by_hash("ped", true, 2086307585)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, 1.0, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ent, 180.0)
        end
    end
end)

--#endregion


--#region MC Factory

local MC_Factory = menu.list(Property_Mission, "摩托帮工厂", {}, "")

--#region MC Factory Tool

local MC_Factory_Tool = menu.list(MC_Factory, "工具", {}, "")

menu.divider(MC_Factory_Tool, "补充原材料")
menu.slider(MC_Factory_Tool, "包裹原材料 补充进度", { "mc_resupply_package" }, "", 0, 100, 20, 5,
    function(value)
        SET_INT_GLOBAL(Globals.Biker.BIKER_RESUPPLY_PACKAGE_VALUE, value)
        Transition_Handler.Globals.Biker.Resupply_Package_Value = value
    end)
menu.slider(MC_Factory_Tool, "载具原材料 补充进度", { "mc_resupply_vehicle" }, "", 0, 100, 40, 5,
    function(value)
        SET_INT_GLOBAL(Globals.Biker.BIKER_RESUPPLY_VEHICLE_VALUE, value)
        Transition_Handler.Globals.Biker.Resupply_Vehicle_Value = value
    end)

menu.divider(MC_Factory_Tool, "任务助手")
menu.action(MC_Factory_Tool, "偷取原材料 任务助手", {},
    "需要点击两次\n第一次点击会自动清空任务记录,只保留开启推荐的购买任务,禁用其它任务,打开电脑界面\n开启任务后,第二次点击就会将货物传送到我",
    function()
        if IS_SCRIPT_RUNNING("gb_illicit_goods_resupply") then
            local blip = HUD.GET_NEXT_BLIP_INFO_ID(501)
            if HUD.DOES_BLIP_EXIST(blip) then
                local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
                if ENTITY.DOES_ENTITY_EXIST(ent) then
                    TP_VEHICLE_TO_ME(ent, "", "delete")
                end
            else
                util.toast("未找到原材料")
            end
        else
            if players.get_org_type(players.user()) ~= 1 then
                menu.trigger_commands("mcstart")
                util.toast("已自动成为摩托帮首领")
            end

            Globals.Biker.ClearMissionHistory()
            for key, offset in pairs(Globals.Biker.Steal_Offsets) do
                if key == 12 then -- BIKER_RESUPPLY_STEAL_VEHICLE_WEIGHTING
                    SET_FLOAT_GLOBAL(262145 + offset, 1)
                else
                    SET_FLOAT_GLOBAL(262145 + offset, 0)
                end
            end
            menu.trigger_commands("appterrorbyte")
            PAD.SET_CURSOR_POSITION(0.724, 0.604)

            util.toast("请先开启任务")
        end
    end)
menu.action(MC_Factory_Tool, "出售货物 任务助手", {}, "清空任务记录,只保留开启推荐的出售任务,禁用其它任务",
    function()
        Globals.Biker.ClearMissionHistory()
        for key, offset in pairs(Globals.Biker.Sell_Offsets) do
            if key == 1 then -- BIKER_DISABLE_SELL_CONVOY
                SET_INT_GLOBAL(262145 + offset, 0)
            else
                SET_INT_GLOBAL(262145 + offset, 1)
            end
        end
        for i = 0, 9 do
            SET_INT_GLOBAL(Globals.Biker.BIKER_DISABLE_SELL_BORDER_PATROL_0 + i, 1)
        end
    end)

menu.divider(MC_Factory_Tool, "禁用任务")

local biker_missions = {
    steal = {},
    sell = {}
}

biker_missions.menu_steal = menu.list(MC_Factory_Tool, "禁用偷取原材料任务", {}, "", function()
    if not biker_missions.steal.created then
        Transition_Handler.Globals.Biker.Steal = {}

        biker_missions.steal.toggle_menus = {}
        menu.toggle(biker_missions.menu_steal, "全部开/关", {}, "", function(toggle)
            for key, value in pairs(biker_missions.steal.toggle_menus) do
                menu.set_value(value, toggle)
            end
        end)

        for key, offset in pairs(Globals.Biker.Steal_Offsets) do
            local name = Globals.Biker.Steal_Names[key][1]
            local help = Globals.Biker.Steal_Names[key][2]
            local global = 262145 + offset

            biker_missions.steal.toggle_menus[global] = menu.toggle(biker_missions.menu_steal, name, {}, help,
                function(toggle)
                    if toggle then
                        SET_FLOAT_GLOBAL(global, 0)
                    else
                        SET_FLOAT_GLOBAL(global, 1)
                    end
                    Transition_Handler.Globals.Biker.Steal[global] = toggle
                end)
        end

        biker_missions.steal.created = true
    end
end)

biker_missions.menu_sell = menu.list(MC_Factory_Tool, "禁用出售货物任务", {}, "", function()
    if not biker_missions.sell.created then
        Transition_Handler.Globals.Biker.Sell = {}

        biker_missions.sell.toggle_menus = {}
        menu.toggle(biker_missions.menu_sell, "全部开/关", {}, "", function(toggle)
            for key, value in pairs(biker_missions.sell.toggle_menus) do
                menu.set_value(value, toggle)
            end
        end)

        for key, offset in pairs(Globals.Biker.Sell_Offsets) do
            local name = Globals.Biker.Sell_Names[key][1]
            local help = Globals.Biker.Sell_Names[key][2]
            local global = 262145 + offset

            biker_missions.sell.toggle_menus[global] = menu.toggle(biker_missions.menu_sell, name, {}, help,
                function(toggle)
                    if toggle then
                        SET_INT_GLOBAL(global, 1)
                    else
                        SET_INT_GLOBAL(global, 0)
                    end
                    Transition_Handler.Globals.Biker.Sell[global] = toggle
                end)
        end

        biker_missions.sell.created = true
    end
end)

menu.divider(MC_Factory_Tool, "")
menu.toggle_loop(MC_Factory_Tool, "清空任务记录", {}, "就可以重复做同一个任务了", function()
    Globals.Biker.ClearMissionHistory()
end)

--#endregion

menu.action(MC_Factory, "传送到 货物", { "tp_mc_product" }, "", function()
    local blip1 = HUD.GET_NEXT_BLIP_INFO_ID(501)
    local blip2 = HUD.GET_NEXT_BLIP_INFO_ID(64)
    local blip3 = HUD.GET_NEXT_BLIP_INFO_ID(427)
    local blip4 = HUD.GET_NEXT_BLIP_INFO_ID(423)

    if HUD.DOES_BLIP_EXIST(blip1) then
        local coords = HUD.GET_BLIP_COORDS(blip1)
        TELEPORT(coords.x, coords.y - 1.5, coords.z) --MC Product
    elseif HUD.DOES_BLIP_EXIST(blip2) then
        local coords = HUD.GET_BLIP_COORDS(blip2)
        TELEPORT(coords.x, coords.y - 1.5, coords.z) --Heli
    elseif HUD.DOES_BLIP_EXIST(blip3) then
        local coords = HUD.GET_BLIP_COORDS(blip3)
        TELEPORT(coords.x, coords.y, coords.z + 1.0) --Boat
    elseif HUD.DOES_BLIP_EXIST(blip4) then
        local coords = HUD.GET_BLIP_COORDS(blip4)
        TELEPORT(coords.x, coords.y + 1.5, coords.z - 1.0) --Plane
    end
end)
menu.action(MC_Factory, "货物 传送到我", { "tpme_mc_product" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(501)
    if HUD.DOES_BLIP_EXIST(blip) then
        local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
            TP_TO_ME(ent)

            if ENTITY.IS_ENTITY_A_VEHICLE(ent) then
                TP_INTO_VEHICLE(ent, "delete", "delete")
            end
        else
            util.toast("目标不是实体，无法传送到我")
        end
    end
end)
menu.action(MC_Factory, "货物(载具) 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("object", true, 788248216)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            if ENTITY.IS_ENTITY_ATTACHED(ent) then
                local attached_ent = ENTITY.GET_ENTITY_ATTACHED_TO(ent)
                if ENTITY.IS_ENTITY_A_VEHICLE(attached_ent) then
                    TP_VEHICLE_TO_ME(attached_ent, "delete", "delete")
                end
            end
        end
    end
end)

--#endregion


--#region Acid Lab

local Acid_Lab = menu.list(Property_Mission, "致幻剂实验室", {}, "")

local Acid_Lab_Tool = menu.list(Acid_Lab, "工具", {}, "")

menu.slider(Acid_Lab_Tool, "原材料 补充进度", { "acid_resupply_crate" }, "", 0, 100, 25, 5, function(value)
    SET_INT_GLOBAL(Globals.AcidLab.ACID_LAB_RESUPPLY_CRATE_VALUE, value)
    Transition_Handler.Globals.AcidLab.Resupply_Crate_Value = value
end)


menu.action(Acid_Lab, "原材料 传送到我", {}, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(501)
    if HUD.DOES_BLIP_EXIST(blip) then
        local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
            TP_TO_ME(ent)
        else
            util.toast("目标不是实体，无法传送到我")
        end
    end
end)
menu.action(Acid_Lab, "传送到 致幻剂实验室", {}, "送达原材料时", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(840)
    if HUD.DOES_BLIP_EXIST(blip) then
        if HUD.GET_BLIP_COLOUR(blip) == 60 then
            TELEPORT2(HUD.GET_BLIP_COORDS(blip))
        end
    end
end)

-- Hash: 1714593198 (pickup) 化学品泄漏
menu.divider(Acid_Lab, "")
menu.action(Acid_Lab, "农场: 拖拉机 传送到 原材料", {}, "会将玩家传送进拖拉机并且与拖车连接\n需要下车来踩点",
    function()
        local trailer = 0
        local tractor = 0

        local entity_list = get_entities_by_hash("pickup", true, 1375611915)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                if ENTITY.IS_ENTITY_ATTACHED(ent) then
                    trailer = ENTITY.GET_ENTITY_ATTACHED_TO(ent)
                end
            end
        end

        entity_list = get_entities_by_hash("vehicle", true, -2076478498)
        if next(entity_list) ~= nil then
            tractor = entity_list[1]
        end

        if ENTITY.DOES_ENTITY_EXIST(trailer) and ENTITY.DOES_ENTITY_EXIST(tractor) then
            SET_ENTITY_HEAD_TO_ENTITY(tractor, trailer)
            TP_ENTITY_TO_ENTITY(tractor, trailer, 0.0, 5.5, 0.0)

            VEHICLE.SET_VEHICLE_ENGINE_ON(tractor, true, true, false)
            PED.SET_PED_INTO_VEHICLE(players.user_ped(), tractor, -1)
        end
    end)
menu.action(Acid_Lab, "仓库: 原材料 传送到 卡车", {}, "", function()
    if PLAYER_INTERIOR() == 289537 then
        local supply = 0
        local truck = 0

        local entity_list = get_entities_by_hash("object", true, 414057361)
        if next(entity_list) ~= nil then
            supply = entity_list[1]
        end

        entity_list = get_entities_by_hash("vehicle", true, 1945374990)
        if next(entity_list) ~= nil then
            truck = entity_list[1]
        end

        if ENTITY.DOES_ENTITY_EXIST(supply) and ENTITY.DOES_ENTITY_EXIST(truck) then
            TP_ENTITY_TO_ENTITY(supply, truck, 0.0, -3.0, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(supply, truck, 90.0)
        end
    end
end)
menu.action(Acid_Lab, "仓库: 传送进 卡车", {}, "", function()
    if PLAYER_INTERIOR() == 289537 then
        local entity_list = get_entities_by_hash("vehicle", true, 1945374990)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_INTO_VEHICLE(ent)
            end
        end
    end
end)
menu.action(Acid_Lab, "仓库: 叉车 传送到 卡车后面", {}, "如果没有提示登上卡车\n会将玩家传送进叉车",
    function()
        if PLAYER_INTERIOR() == 289537 then
            local forklift = 0
            local truck = 0

            local entity_list = get_entities_by_hash("vehicle", true, 1491375716)
            if next(entity_list) ~= nil then
                forklift = entity_list[1]
            end

            entity_list = get_entities_by_hash("vehicle", true, 1945374990)
            if next(entity_list) ~= nil then
                truck = entity_list[1]
            end

            if ENTITY.DOES_ENTITY_EXIST(forklift) and ENTITY.DOES_ENTITY_EXIST(truck) then
                VEHICLE.SET_FORKLIFT_FORK_HEIGHT(forklift, 1.0)

                SET_ENTITY_HEAD_TO_ENTITY(forklift, truck)
                TP_ENTITY_TO_ENTITY(forklift, truck, 0.0, -6.0, 0.0)

                VEHICLE.SET_VEHICLE_ENGINE_ON(forklift, true, true, false)
                PED.SET_PED_INTO_VEHICLE(players.user_ped(), forklift, -1)
            end
        end
    end)
menu.action(Acid_Lab, "敌痛息仓库: 传送到 时间表", {}, "", function()
    local entity_list = get_entities_by_hash("object", true, 623418081)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, 0.0, 0.5)
        end
    end
end)
menu.action(Acid_Lab, "敌痛息仓库: 厢形车 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("pickup", true, 331463704)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            if ENTITY.IS_ENTITY_ATTACHED(ent) then
                local veh = ENTITY.GET_ENTITY_ATTACHED_TO(ent)
                if ENTITY.IS_ENTITY_A_VEHICLE(veh) then
                    TP_VEHICLE_TO_ME(veh, "delete", "delete")
                end
            end
        end
    end
end)
menu.action(Acid_Lab, "空投地点: 原材料 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("object", true, -1367041250)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            add_owned_explosion(players.user_ped(), ENTITY.GET_ENTITY_COORDS(ent))
        end
        util.yield(500)
    end

    entity_list = get_entities_by_hash("pickup", true, 1195735753)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent)
        end
    end
end)

--#endregion



---------------------
-- 前置任务
---------------------
local Preparation_Mission = menu.list(Mission_Options, "前置任务", {}, "")

--#region Cayo Perico

local Cayo_Perico = menu.list(Preparation_Mission, "佩里科岛抢劫", {}, "")

menu.action(Cayo_Perico, "传送到虎鲸 任务面板", { "tpin_kosatka" },
    "需要提前叫出虎鲸", function()
        local blip = HUD.GET_NEXT_BLIP_INFO_ID(760)
        if not HUD.DOES_BLIP_EXIST(blip) then
            util.toast("未在地图上找到虎鲸")
        else
            TELEPORT(1561.2369, 385.8771, -49.689915, 175.0001)
        end
    end)
menu.action(Cayo_Perico, "传送到虎鲸 外面甲板", { "tpout_kosatka" },
    "需要提前叫出虎鲸", function()
        local blip = HUD.GET_NEXT_BLIP_INFO_ID(760)
        if not HUD.DOES_BLIP_EXIST(blip) then
            util.toast("未在地图上找到虎鲸")
        else
            local pos = HUD.GET_BLIP_COORDS(blip)
            local heading = HUD.GET_BLIP_ROTATION(blip)
            TELEPORT(pos.x - 5.25, pos.y + 30.84, pos.z + 3, heading + 180)
        end
    end)

menu.divider(Cayo_Perico, "侦查")
menu.action(Cayo_Perico, "传送进 美杜莎", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, 1077420264)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            set_entity_godmode(ent, true)
            VEHICLE.SET_VEHICLE_ENGINE_ON(ent, true, true, false)
            PED.SET_PED_INTO_VEHICLE(players.user_ped(), ent, -1)
        end
    end
end)
menu.action(Cayo_Perico, "传送到 信号塔", {}, "", function()
    local entity_list = get_entities_by_hash("object", true, 1981815996)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, -0.5, 0.5)
            SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ent)
        end
    end
end)

menu.divider(Cayo_Perico, "前置")
menu.action(Cayo_Perico, "长崎 传送到我并坐进尖锥魅影", {},
    "生成并坐进尖锥魅影 传送长崎到后面 会直接连接", function()
        local entity_list = get_entities_by_hash("vehicle", true, -1352468814)
        if next(entity_list) ~= nil then
            local modelHash = util.joaat("phantom2")
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0.0, 2.0, 0.0)
            local veh = Create_Network_Vehicle(modelHash, coords.x, coords.y, coords.z, PLAYER_HEADING())

            TP_INTO_VEHICLE(veh)

            for k, ent in pairs(entity_list) do
                TP_TO_ME(ent, 0.0, -10.0, 0.0)
                SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
            end
        end
    end)
menu.action(Cayo_Perico, "传送到 保险箱密码", {}, "赌场别墅内的保安队长", function()
    local entity_list = get_entities_by_hash("ped", true, -1109568186)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, 0.0, 0.5)
        end
    end
end)
menu.action(Cayo_Perico, "等离子切割枪包裹 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("pickup", true, -802406134)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent)
        end
    end
end)
menu.action(Cayo_Perico, "指纹复制器 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("pickup", true, 1506325614)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent)
        end
    end
end)
menu.action(Cayo_Perico, "传送到 割据", {}, "", function()
    local entity_list = get_entities_by_hash("pickup", true, 1871441709)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, 1.5, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ent, -180)
        end
    end
end)
menu.action(Cayo_Perico, "武器 传送到我", {}, "拾取后重新进入虎鲸，然后炸掉女武神", function()
    local entity_list = get_entities_by_hash("pickup", true, 1912600099)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent)
        end
    end
end)
menu.action(Cayo_Perico, "武器 炸掉女武神", {}, "不再等它慢慢的飞", function()
    local entity_list = get_entities_by_hash("vehicle", true, -1600252419)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            local pos = ENTITY.GET_ENTITY_COORDS(ent)
            add_owned_explosion(players.user_ped(), pos)
        end
    end
end)

menu.divider(Cayo_Perico, "")
local Cayo_Perico_Final = menu.list(Cayo_Perico, "终章", {}, "")

menu.divider(Cayo_Perico_Final, "豪宅外")
menu.action(Cayo_Perico_Final, "信号塔 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("object", false, 1981815996)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            RequestControl(ent)
            TP_TO_ME(ent, 0.0, 2.0, -1.0)
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
        end
    end
end)
menu.action(Cayo_Perico_Final, "发电站 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("object", false, 1650252819)
    if next(entity_list) ~= nil then
        local x = 0.0
        for k, ent in pairs(entity_list) do
            RequestControl(ent)
            TP_TO_ME(ent, x, 2.0, 0.5)
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
            x = x + 1.5
        end
    end
end)
menu.action(Cayo_Perico_Final, "保安服 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("object", false, -1141961823)
    if next(entity_list) ~= nil then
        local x = 0.0
        for k, ent in pairs(entity_list) do
            RequestControl(ent)
            TP_TO_ME(ent, x, 2.0, -0.5)
            x = x + 1.0
        end
    end
end)
menu.action(Cayo_Perico_Final, "螺旋切割器 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("pickup", false, -710382954)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            RequestControl(ent)
            TP_TO_ME(ent, 0.0, 2.0, -0.5)
        end
    end
end)
menu.action(Cayo_Perico_Final, "抓钩 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("pickup", false, -1789904450)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            RequestControl(ent)
            TP_TO_ME(ent, 0.0, 2.0, -0.5)
        end
    end
end)
menu.action(Cayo_Perico_Final, "运货卡车 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, 2014313426)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            RequestControl(ent)
            TP_VEHICLE_TO_ME(ent, "", "delete")
        end
    end
end)

menu.divider(Cayo_Perico_Final, "豪宅内")

local perico_gold_vault_menu
local perico_gold_vault_ent --实体列表
perico_gold_vault_menu = menu.list_action(Cayo_Perico_Final, "传送到 黄金", {}, "",
    { "刷新黄金列表" }, function(value)
        if value == 1 then
            perico_gold_vault_ent = {}
            local list_item_data = { "刷新黄金列表" }
            local i = 1

            for k, ent in pairs(entities.get_all_objects_as_handles()) do
                if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
                    local Hash = ENTITY.GET_ENTITY_MODEL(ent)
                    if Hash == -180074230 then
                        table.insert(perico_gold_vault_ent, ent)
                        table.insert(list_item_data, "黄金 " .. i)
                        i = i + 1
                    end
                end
            end

            menu.set_list_action_options(perico_gold_vault_menu, list_item_data)
            util.toast("已刷新，请重新打开该列表")
        else
            local ent = perico_gold_vault_ent[value - 1]
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                TP_TO_ENTITY(ent, 0.0, -1.0, 0.0)
                SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ent)
            end
        end
    end)

menu.action(Cayo_Perico_Final, "干掉主要目标玻璃柜、保险箱", {}, "会在豪宅外生成主要目标包裹",
    function()
        local entity_list = get_entities_by_hash("object", false, -1714533217, 1098122770) --玻璃柜、保险箱
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                RequestControl(ent)
                SET_ENTITY_HEALTH(ent, 0)
            end
        end
    end)
menu.action(Cayo_Perico_Final, "主要目标掉落包裹 传送到我", {}, "携带主要目标者死亡后掉落的包裹",
    function()
        -- Hash: -1851147549 (pickup) 包裹
        local blip = HUD.GET_NEXT_BLIP_INFO_ID(765)
        if HUD.DOES_BLIP_EXIST(blip) then
            local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                RequestControl(ent)
                TP_TO_ME(ent)
            end
        end
    end)
menu.action(Cayo_Perico_Final, "办公室保险箱 传送到我", {}, "保险箱门和里面的现金", function()
    local entity_list = get_entities_by_hash("object", false, 485111592) --保险箱
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            RequestControl(ent)
            TP_TO_ME(ent, -0.5, 1.0, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped(), 180.0)
        end
    end

    entity_list = get_entities_by_hash("pickup", false, -2143192170) --现金
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            RequestControl(ent)
            TP_TO_ME(ent, 0.0, 1.0, 0.0)
        end
    end
end)

--#endregion


--#region Diamond Casino

local Diamond_Casino = menu.list(Preparation_Mission, "赌场抢劫", {}, "")

menu.divider(Diamond_Casino, "侦查")
menu.action(Diamond_Casino, "保安 传送到我", {}, "会传送到空中然后摔死", function()
    local entity_list = get_entities_by_hash("ped", true, -1094177627)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, 10.0)
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
        end
    end
end)

local casion_invest = {
    num = 5,
    pos = {
        { 1131.7562, 278.7316,  -51.0408 },
        { 1146.7454, 243.3848,  -51.0408 },
        { 1138.2075, 239.8881,  -50.4408 },
        { 1105.9666, 259.99405, -51.0409 },
        { 1120.3631, 226.5128,  -50.0407 },
    },
}
menu.click_slider(Diamond_Casino, "赌场 传送到骇入位置", {}, "进入赌场后再传送",
    1, casion_invest.num, 1, 1, function(value)
        if PLAYER_INTERIOR() == 275201 then
            local pos = casion_invest.pos[value]
            TELEPORT(pos[1], pos[2], pos[3])
        end
    end)


menu.divider(Diamond_Casino, "前置")

--- 相同前置 ---
local Diamond_Casino_Preps = menu.list(Diamond_Casino, "相同前置", {}, "")

menu.action(Diamond_Casino_Preps, "武器 传送到我", {}, "杀死/爆炸所有NPC", function()
    local entity_list = get_entities_by_hash("pickup", true, 798951501, -1628917549)
    if next(entity_list) ~= nil then
        OBJECT.SET_MAX_NUM_PORTABLE_PICKUPS_CARRIED_BY_PLAYER(ENTITY.GET_ENTITY_MODEL(entity_list[1]), 2)
        for k, ent in pairs(entity_list) do
            detach_product_entity(ent)
            TP_TO_ME(ent)
        end
    end
end)
menu.action(Diamond_Casino_Preps, "载具: 天威 传送到我", {}, "天威 经典版", function()
    local entity_list = get_entities_by_hash("vehicle", true, 931280609)
    if next(entity_list) ~= nil then
        TP_VEHICLE_TO_ME(entity_list[1], "", "delete")
    end
end)
menu.action(Diamond_Casino_Preps, "骇入设备 传送到我", {}, "拿到门禁卡，踩到黄点后，再传送到我",
    function()
        local entity_list = get_entities_by_hash("pickup", true, -155327337)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ME(ent)
            end
        end
    end)

menu.action(Diamond_Casino_Preps, "金库门禁卡: 狱警 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("ped", true, 1456041926)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, -0.5)
        end
    end
end)
menu.action(Diamond_Casino_Preps, "金库门禁卡: 保安 传送到我", {}, "两个保安会传送到空中然后摔死，需要再补一枪\n直接搜查保安，不用管地图红标记点",
    function()
        local entity_list = get_entities_by_hash("ped", true, -1575488699, -1425378987)
        if next(entity_list) ~= nil then
            local x = 0.0
            for k, ent in pairs(entity_list) do
                TP_TO_ME(ent, x, 2.0, 10.0)
                x = x + 3.0
            end
        end
    end)
menu.action(Diamond_Casino_Preps, "巡逻路线: 车 传送到我", {}, "在车后备箱里", function()
    local entity_list = get_entities_by_hash("object", true, 1265214509)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            if ENTITY.IS_ENTITY_ATTACHED(ent) then
                local attached_ent = ENTITY.GET_ENTITY_ATTACHED_TO(ent)
                SET_ENTITY_HEAD_TO_ENTITY(attached_ent, players.user_ped())
                TP_TO_ME(attached_ent, 0.0, 4.0, -0.5)
            end
        end
    end
end)
menu.action(Diamond_Casino_Preps, "杜根货物 全部爆炸", {}, "一次性炸不完，多炸几次", function()
    local entity_list = get_entities_by_hash("vehicle", true, -1671539132, 1747439474, 1448677353)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            local pos = ENTITY.GET_ENTITY_COORDS(ent)
            add_owned_explosion(players.user_ped(), pos, 4, { isAudible = false })
        end
    end
end)
menu.textslider(Diamond_Casino_Preps, "传送到 电钻", {}, "", { "1", "2", "车" }, function(value)
    local entity_list = get_entities_by_hash("pickup", true, -12990308)
    if next(entity_list) ~= nil then
        if value == 1 then
            TP_TO_ENTITY(entity_list[1], 0.0, 0.0, 0.5)
        elseif value == 2 then
            TP_TO_ENTITY(entity_list[2], 0.0, 0.0, 0.5)
        elseif value == 3 then
            local ent = entity_list[1]
            if ENTITY.IS_ENTITY_ATTACHED(ent) then
                local attached_ent = ENTITY.GET_ENTITY_ATTACHED_TO(ent)
                if ENTITY.IS_ENTITY_A_VEHICLE(attached_ent) then
                    TP_INTO_VEHICLE(attached_ent, "delete", "delete")
                end
            end
        end
    end
end)
menu.action(Diamond_Casino_Preps, "二级保安证: 传送到 尸体", {}, "医院里的泊车员尸体", function()
    local entity_list = get_entities_by_hash("object", true, 771433594)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, -1.0, 0.0, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ent, -80.0)
        end
    end
end)
menu.action(Diamond_Casino_Preps, "二级保安证: 保安证 传送到我", {}, "找到那个NPC后才能传送",
    function()
        local entity_list = get_entities_by_hash("pickup", true, -2018799718)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ME(ent)
            end
        end
    end)


--- 隐迹潜踪 ---
local Diamond_Casino_Silent = menu.list(Diamond_Casino, "隐迹潜踪", {}, "")

menu.action(Diamond_Casino_Silent, "无人机零件 传送到我", {},
    "会先炸掉无人机，再传送掉落的零件", function()
        --Model Hash: 1657647215 纳米无人机 (object)
        --Model Hash: -1285013058 无人机炸毁后掉落的零件（pickup）
        local entity_list = get_entities_by_hash("object", true, 1657647215)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                local pos = ENTITY.GET_ENTITY_COORDS(ent)
                add_owned_explosion(players.user_ped(), pos)
            end
        end
        util.yield(1500)
        entity_list = get_entities_by_hash("pickup", true, -1285013058)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ME(ent)
            end
        end
    end)
menu.action(Diamond_Casino_Silent, "金库激光器 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("pickup", true, 1953119208)
    if next(entity_list) ~= nil then
        OBJECT.SET_MAX_NUM_PORTABLE_PICKUPS_CARRIED_BY_PLAYER(1953119208, 2)
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent)
        end
    end
end)
menu.action(Diamond_Casino_Silent, "电磁脉冲: 运兵直升机 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, 1621617168)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 0.0, 30.0)
            TP_INTO_VEHICLE(ent)
            ENTITY.SET_ENTITY_INVINCIBLE(ent, true)
            VEHICLE.SET_HELI_BLADES_FULL_SPEED(ent)
        end
    end
end)
menu.action(Diamond_Casino_Silent, "电磁脉冲 传送到直升机挂钩位置", {}, "运兵直升机提前放下吊钩",
    function()
        local entity_list = get_entities_by_hash("object", true, -1541347408)
        if next(entity_list) ~= nil then
            local veh = GET_VEHICLE_PED_IS_IN(players.user_ped())
            if veh ~= 0 and VEHICLE.DOES_CARGOBOB_HAVE_PICK_UP_ROPE(veh) then
                local pos = VEHICLE.GET_ATTACHED_PICK_UP_HOOK_POSITION(veh)
                for k, ent in pairs(entity_list) do
                    pos.z = pos.z + 1.0
                    SET_ENTITY_COORDS(ent, pos)
                end
            end
        end
    end)
menu.action(Diamond_Casino_Silent, "潜行套装 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("pickup", true, -1496506919)
    if next(entity_list) ~= nil then
        OBJECT.SET_MAX_NUM_PORTABLE_PICKUPS_CARRIED_BY_PLAYER(-1496506919, 2)
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent)
        end
    end
end)


--- 兵不厌诈 ---
local Diamond_Casino_BigCon = menu.list(Diamond_Casino, "兵不厌诈", {}, "")

menu.action(Diamond_Casino_BigCon, "古倍科技套装 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("pickup", true, 1425667258)
    if next(entity_list) ~= nil then
        OBJECT.SET_MAX_NUM_PORTABLE_PICKUPS_CARRIED_BY_PLAYER(1425667258, 2)
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent)
        end
    end
end)
menu.action(Diamond_Casino_BigCon, "金库钻孔机 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("pickup", true, 415149220)
    if next(entity_list) ~= nil then
        OBJECT.SET_MAX_NUM_PORTABLE_PICKUPS_CARRIED_BY_PLAYER(415149220, 2)
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent)
        end
    end
end)
menu.action(Diamond_Casino_BigCon, "国安局套装 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("pickup", true, -1713985235)
    if next(entity_list) ~= nil then
        OBJECT.SET_MAX_NUM_PORTABLE_PICKUPS_CARRIED_BY_PLAYER(-1713985235, 2)
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent)
        end
    end
end)


--- 气势汹汹 ---
local Diamond_Casino_Aggressive = menu.list(Diamond_Casino, "气势汹汹", {}, "")

menu.action(Diamond_Casino_Aggressive, "热能炸药 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("pickup", true, -2043162923)
    if next(entity_list) ~= nil then
        OBJECT.SET_MAX_NUM_PORTABLE_PICKUPS_CARRIED_BY_PLAYER(-2043162923, 2)
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent)
        end
    end
end)
menu.action(Diamond_Casino_Aggressive, "金库炸药 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("pickup", true, -681938663)
    if next(entity_list) ~= nil then
        OBJECT.SET_MAX_NUM_PORTABLE_PICKUPS_CARRIED_BY_PLAYER(-681938663, 2)
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent)
        end
    end
end)
menu.action(Diamond_Casino_Aggressive, "加固防弹衣 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("pickup", true, 1715697304)
    if next(entity_list) ~= nil then
        OBJECT.SET_MAX_NUM_PORTABLE_PICKUPS_CARRIED_BY_PLAYER(1715697304, 2)
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent)
        end
    end
end)
menu.action(Diamond_Casino_Aggressive, "加固防弹衣: 潜水套装 传送到我", {}, "人道实验室", function()
    local entity_list = get_entities_by_hash("object", true, 788248216)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent)
        end
    end
end)


--- 终章 ---
menu.divider(Diamond_Casino, "")
local Diamond_Casino_Final = menu.list(Diamond_Casino, "终章", {}, "")

menu.divider(Diamond_Casino_Final, "赌场内")
menu.action(Diamond_Casino_Final, "传送到 小金库", {}, "", function()
    if INTERIOR.IS_INTERIOR_SCENE() then
        TELEPORT(2520.8645, -286.30685, -58.723007)
    end
end)

local casino_vault_trolley_menu
local casino_vault_trolley_ent --实体列表
casino_vault_trolley_menu = menu.list_action(Diamond_Casino_Final, "金库内传送到 推车", {}, "",
    { "刷新推车列表" }, function(value)
        if value == 1 then
            casino_vault_trolley_ent = {}
            local list_item_data = { "刷新推车列表" }
            local i = 1

            for k, ent in pairs(entities.get_all_objects_as_handles()) do
                if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
                    local Hash = ENTITY.GET_ENTITY_MODEL(ent)
                    if Hash == 412463629 or Hash == 1171655821 or Hash == 1401432049 then
                        table.insert(casino_vault_trolley_ent, ent)
                        table.insert(list_item_data, "推车 " .. i)
                        i = i + 1
                    end
                end
            end

            menu.set_list_action_options(casino_vault_trolley_menu, list_item_data)
            util.toast("已刷新，请重新打开该列表")
        else
            local ent = casino_vault_trolley_ent[value - 1]
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                TP_TO_ENTITY(ent, 0.0, 0.0, 0.5)
            end
        end
    end)

--#endregion


--#region Contract Dre

local Contract_Dre = menu.list(Preparation_Mission, "别惹德瑞", {}, "")

menu.divider(Contract_Dre, "夜生活泄密")
menu.action(Contract_Dre, "夜总会: 传送到 录像带", {}, "", function()
    if PLAYER_INTERIOR() == 271617 then
        TELEPORT(-1617.9883, -3013.7363, -75.20509, 203.7907)
    end
end)
menu.action(Contract_Dre, "船坞: 传送到 船里", {}, "绿色的船", function()
    local entity_list = get_entities_by_hash("vehicle", true, 908897389)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_INTO_VEHICLE(ent)
        end
    end
end)
menu.action(Contract_Dre, "船坞: 传送到 证据", {}, "德瑞照片", function()
    local entity_list = get_entities_by_hash("object", true, -1702870637)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, 0.0, 0.5)
        end
    end
end)
menu.action(Contract_Dre, "夜生活泄密: 传送到 抢夺电脑", {}, "", function()
    if PLAYER_INTERIOR() == 274689 then
        TELEPORT(944.01764, 7.9015555, 116.1642, 279.8804)
    end
end)

menu.divider(Contract_Dre, "上流社会泄密")
menu.action(Contract_Dre, "乡村俱乐部: 炸掉礼车", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, -420911112)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            local pos = ENTITY.GET_ENTITY_COORDS(ent)
            add_owned_explosion(players.user_ped(), pos)
        end
    end
end)
menu.action(Contract_Dre, "乡村俱乐部: 门禁 传送到我", {}, "车内NPC", function()
    local entity_list = get_entities_by_hash("ped", true, -912318012)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, 0.0)
        end
    end
end)
menu.action(Contract_Dre, "宾客名单: 传送到 律师", {}, "同时设置和NPC关系为友好,避免被误杀",
    function()
        local entity_list = get_entities_by_hash("ped", true, 600300561)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ENTITY(ent, 0.0, 1.0, 0.0)
                PED.SET_PED_RELATIONSHIP_GROUP_HASH(ent, PED.GET_PED_RELATIONSHIP_GROUP_HASH(players.user_ped())) -- Like
            end
        end
    end)
menu.action(Contract_Dre, "上流社会泄密: 炸掉直升机", {}, "快速进入直升机坠落动画", function()
    local entity_list = get_entities_by_hash("vehicle", true, 1075432268)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ent, -1, false)
            if driver ~= 0 then
                entities.delete(driver)
            end

            local pos = ENTITY.GET_ENTITY_COORDS(ent)
            add_owned_explosion(players.user_ped(), pos)
        end
    end
end)

menu.divider(Contract_Dre, "南中心区泄密")
menu.action(Contract_Dre, "强化弗农", {}, "", function()
    local entity_list = get_entities_by_hash("ped", true, -843935326)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            local weaponHash = util.joaat("WEAPON_SPECIALCARBINE")
            WEAPON.GIVE_WEAPON_TO_PED(ent, weaponHash, -1, false, true)
            WEAPON.SET_CURRENT_PED_WEAPON(ent, weaponHash, false)
            increase_ped_combat_ability(ent, true, false)
            increase_ped_combat_attributes(ent)
            util.toast("完成！")
        end
    end
end)
menu.action(Contract_Dre, "戴维斯: 传送到高空", {}, "甩掉摩托帮\n提前坐进厢型车", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        ENTITY.FREEZE_ENTITY_POSITION(vehicle, true)

        local coords = ENTITY.GET_ENTITY_COORDS(vehicle)
        TELEPORT(coords.x, coords.y, 1600.0)
    end
end)
menu.action(Contract_Dre, "巴勒帮: P 无敌", {}, "避免被误杀", function()
    local entity_list = get_entities_by_hash("ped", true, -616450833)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            set_entity_godmode(ent, true)
            util.toast("完成！")
        end
    end
end)
menu.action(Contract_Dre, "南中心区泄密: 底盘车 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, -1013450936)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_VEHICLE_TO_ME(ent, "", "tp")
            set_entity_godmode(ent, true)
        end
    end
end)

--#endregion Contract Dre


--#region LS Robbery

local LS_Robbery = menu.list(Preparation_Mission, "改装铺合约", {}, "")

----- 联合储蓄 Union Depository -----
local LS_Robbery_UD = menu.list(LS_Robbery, "联合储蓄", {}, "")

menu.action(LS_Robbery_UD, "电梯钥匙: 传送到 腐败商人", {}, "", function()
    local entity_list = get_entities_by_hash("ped", true, 2093736314)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, 0.0, 0.5)
        end
    end
end)
menu.action(LS_Robbery_UD, "金库密码: 提示 目标载具(寻找时)", {}, "将载具传送到明显位置，并添加粒子效果",
    function()
        local entity_list = get_entities_by_hash("ped", true, -1868718465)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                local veh = PED.GET_VEHICLE_PED_IS_IN(ent, false)
                SET_ENTITY_COORDS(veh, v3(52.6033, -614.41308, 31.0284))
                ENTITY.SET_ENTITY_HEADING(veh, 247.0814)

                request_ptfx_asset("scr_rcbarry2")
                start_ptfx_on_entity("scr_exp_clown", ent)
            end
        end
    end)
menu.click_slider(LS_Robbery_UD, "金库密码: 目标载具 传送到目的地", {}, "玩家自己也会跟着传送过去",
    1, 2, 1, 1, function(value)
        local entity_list = get_entities_by_hash("ped", true, -1868718465)
        if next(entity_list) ~= nil then
            local data = {
                { coords = v3(-1326.9161, -1026.7085, 7.1590), heading = 263.5850 },
                { coords = v3(-59.6748, 350.2671, 111.7699),   heading = 20.9717 },
            }
            local coords = data[value].coords
            local heading = data[value].heading

            for k, ent in pairs(entity_list) do
                local veh = PED.GET_VEHICLE_PED_IS_IN(ent, false)
                SET_ENTITY_COORDS(veh, coords)
                ENTITY.SET_ENTITY_HEADING(veh, heading)

                TELEPORT(coords.x, coords.y, coords.z + 80.0)
                ENTITY.SET_ENTITY_HEADING(players.user_ped(), heading)
            end
        end
    end)


----- 大钞交易 The Superdollar Deal -----
local LS_Robbery_TSD = menu.list(LS_Robbery, "大钞交易", {}, "")

menu.action(LS_Robbery_TSD, "追踪设备: 传送到 机动作战中心", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, 1502869817)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            if not ENTITY.IS_ENTITY_ATTACHED(ent) then
                TP_TO_ENTITY(ent, 5.0, 0.0, -1.0)
                SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ent, 100)
            end
        end
    end
end)
menu.action(LS_Robbery_TSD, "病毒软件: 黑客 传送到我", {}, "会传送到空中然后摔死", function()
    local entity_list = get_entities_by_hash("ped", true, -2039163396)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, 10.0)
        end
    end
end)
menu.action(LS_Robbery_TSD, "病毒软件: 传送到 软件", {}, "", function()
    local entity_list = get_entities_by_hash("pickup", true, 1112175411)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, 0.0, 0.5)
        end
    end
end)

menu.divider(LS_Robbery_TSD, "终章")
menu.action(LS_Robbery_TSD, "运输载具 传送到我前面", {}, "前面要预留足够的位置\n提前杀死所有NPC",
    function()
        local blip = HUD.GET_NEXT_BLIP_INFO_ID(564)
        if HUD.DOES_BLIP_EXIST(blip) then
            local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
            TP_TO_ME(ent, 0.0, 13.0, 0.5)
        end
    end)


----- 银行合约 The Bank Contract -----
local LS_Robbery_TBC = menu.list(LS_Robbery, "银行合约", {}, "")

menu.textslider_stateful(LS_Robbery_TBC, "信号干扰器: 传送到", {}, "", {
    "A", "B", "C", "D", "E", "F"
}, function(value)
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(534 + value)
    if HUD.DOES_BLIP_EXIST(blip) then
        local coords = HUD.GET_BLIP_COORDS(blip)
        local heading = HUD.GET_BLIP_ROTATION(blip)
        TELEPORT(coords.x, coords.y, coords.z + 0.5, heading)
    end
end)

menu.divider(LS_Robbery_TBC, "终章")
local LS_Robbery_TBC_bank = 1
menu.list_select(LS_Robbery_TBC, "选择银行", {}, "先传送银行踩点后再传送到金库", {
    "A", "B", "C", "D", "E", "F"
}, 1, function(value)
    LS_Robbery_TBC_bank = value
end)
menu.action(LS_Robbery_TBC, "传送到 银行", {}, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(534 + LS_Robbery_TBC_bank)
    if HUD.DOES_BLIP_EXIST(blip) then
        local coords = HUD.GET_BLIP_COORDS(blip)
        local heading = HUD.GET_BLIP_ROTATION(blip)
        TELEPORT(coords.x, coords.y, coords.z + 0.5, heading)
    end
end)
menu.action(LS_Robbery_TBC, "传送到 银行金库", {}, "", function()
    local data = {
        { coords = { -2952.9719, 484.8367, 15.6689 },  heading = 87.5927 },
        { coords = { -1206.9482, -338.4858, 37.7515 }, heading = 29.5932 },
        { coords = { -352.5631, -59.3918, 49.0031 },   heading = 344.1930 },
        { coords = { 147.9883, -1050.1608, 29.3388 },  heading = 338.7930 },
        { coords = { 312.3861, -288.5477, 54.1316 },   heading = 341.3840 },
        { coords = { 1173.5954, 2716.3256, 38.0559 },  heading = 177.9919 },
    }
    local coords = data[LS_Robbery_TBC_bank].coords
    local heading = data[LS_Robbery_TBC_bank].heading
    TELEPORT(coords[1], coords[2], coords[3], heading)
end)
menu.action(LS_Robbery_TBC, "删除 银行金库铁门", {}, "", function()
    local entity_list = get_entities_by_hash("object", false, -1591004109)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            entities.delete(ent)
        end
    end
end)


----- 电控单元差事 The ECU Job -----
local LS_Robbery_TEJ = menu.list(LS_Robbery, "电控单元差事", {}, "")

menu.action(LS_Robbery_TEJ, "火车货运清单: 传送到 清单", {}, "", function()
    local entity_list = get_entities_by_hash("object", true, -1398142754)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, 0.0, 0.5)
        end
    end
end)
menu.action(LS_Robbery_TEJ, "火车货运清单: 传送到 切割锯", {}, "", function()
    local entity_list = get_entities_by_hash("pickup", true, 339736694)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, 0.0, 0.5)
        end
    end
end)

menu.divider(LS_Robbery_TEJ, "终章")
menu.action(LS_Robbery_TEJ, "爆炸 刹车气缸", {}, "", function()
    local entity_list = get_entities_by_hash("object", true, 897163609)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            local coords = ENTITY.GET_ENTITY_COORDS(ent)
            add_owned_explosion(players.user_ped(), coords, 4)
        end
    end
end)
menu.action(LS_Robbery_TEJ, "电控单元 传送到我", {}, "需要动一下来确保拾取到", function()
    local entity_list = get_entities_by_hash("pickup", true, 92049373)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent)
        end
    end
end)


----- 监狱合约 The Prison Contract -----
-- local LS_Robbery_TPC = menu.list(LS_Robbery, "监狱合约", {}, "")


----- IAA 交易 The Agency Deal -----
local LS_Robbery_TAD = menu.list(LS_Robbery, "IAA 交易", {}, "")

menu.action(LS_Robbery_TAD, "入口: 传送到 图纸", {}, "", function()
    local entity_list = get_entities_by_hash("object", true, 429364207)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, 0.0, 0.5)
        end
    end
end)

menu.divider(LS_Robbery_TAD, "终章")
menu.action(LS_Robbery_TAD, "传送到 配方", {}, "", function()
    local entity_list = get_entities_by_hash("object", true, -1862267709)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, 0.0, 0.5)
        end
    end
end)


----- 失落摩托帮合约 The Lost Contract -----
local LS_Robbery_TLC = menu.list(LS_Robbery, "失落摩托帮合约", {}, "")

menu.action(LS_Robbery_TLC, "实验室地点: 传送到 保险箱", {}, "", function()
    local entity_list = get_entities_by_hash("object", true, 1089807209)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, -1.0, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ent)
        end
    end
end)
menu.action(LS_Robbery_TLC, "实验室地点: 炸药 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("pickup", true, -957953964)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent)
        end
    end
end)

menu.divider(LS_Robbery_TLC, "终章")
menu.textslider_stateful(LS_Robbery_TLC, "传送到实验室", {}, "", {
    "好麦坞", "布罗高地", "塞诺拉大沙漠", "红木轻装赛道"
}, function(value)
    local data = {
        { coords = { 982.4954, -142.6833, 74.2364 },   heading = 253.8538 },
        { coords = { 1569.8601, -2130.2998, 78.3301 }, heading = 23.6202 },
        { coords = { 1219.1319, 1848.2427, 78.9553 },  heading = 46.3844 },
        { coords = { 839.2638, 2176.2578, 52.2899 },   heading = 337.6105 },
    }
    local coords = data[value].coords
    local heading = data[value].heading
    TELEPORT(coords[1], coords[2], coords[3], heading)
end)
menu.action(LS_Robbery_TLC, "传送进 卡车", {}, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(477)
    if HUD.DOES_BLIP_EXIST(blip) then
        local phantom = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip) -- hash: -2137348917
        TP_INTO_VEHICLE(phantom)
    end
end)
menu.action(LS_Robbery_TLC, "油罐车 传送到我后面", {}, "卡车后面要预留足够的位置", function()
    local blip = HUD.GET_CLOSEST_BLIP_INFO_ID(479)
    if HUD.DOES_BLIP_EXIST(blip) then
        local tanker = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip) -- hash: -730904777
        set_entity_godmode(tanker, true)
        SET_ENTITY_HEAD_TO_ENTITY(tanker, players.user_ped())
        TP_TO_ME(tanker, 0.0, -9.0, 0.5)
    end
end)


----- 数据合约 The Data Contract -----
local LS_Robbery_TDC = menu.list(LS_Robbery, "数据合约", {}, "")

menu.action(LS_Robbery_TDC, "藏身处地点: 传送进 直升机", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, 1044954915)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            PED.SET_PED_INTO_VEHICLE(players.user_ped(), ent, -2)
        end
    end
end)
menu.click_slider(LS_Robbery_TDC, "藏身处地点: 直升机 传送到目的地", {}, "提前传送进直升机",
    1, 3, 1, 1, function(value)
        local entity_list = get_entities_by_hash("vehicle", true, 1044954915)
        if next(entity_list) ~= nil then
            local coords_list = {
                v3(-401.5833, 4342.7768, 135.3380),
                v3(2122.8254, 3346.9553, 124.9741),
                v3(20.3088, 2935.2412, 136.0759),
            }

            for k, ent in pairs(entity_list) do
                SET_ENTITY_COORDS(ent, coords_list[value])
            end
        end
    end)
menu.action(LS_Robbery_TDC, "藏身处地点: 巴拉杰 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, -212993243)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_VEHICLE_TO_ME(ent, "delete", "delete")
        end
    end
end)
menu.action(LS_Robbery_TDC, "防御: 武器 传送到我", {}, "一个一个的传送", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(784)
    if HUD.DOES_BLIP_EXIST(blip) then
        local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
        if ENTITY.IS_ENTITY_A_VEHICLE(ent) then
            TP_VEHICLE_TO_ME(ent, "delete", "delete")
        end
    end
end)

menu.divider(LS_Robbery_TDC, "终章")
menu.action(LS_Robbery_TDC, "硬盘 传送到我", {}, "四个硬盘会堆在一起", function()
    local entity_list = get_entities_by_hash("object", true, 977288393)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped())
        end
    end
end)

--#endregion



---------------------
-- 自由模式任务
---------------------
local Freemode_Mission = menu.list(Mission_Options, "自由模式任务", {}, "")

--#region Franklin Payphone

local Franklin_Payphone = menu.list(Freemode_Mission, "富兰克林电话任务", {}, "")

local Franklin_Payphone_Tool = menu.list(Franklin_Payphone, "工具", {}, "")

menu.divider(Franklin_Payphone_Tool, "移除冷却时间")
menu.toggle(Franklin_Payphone_Tool, "电话暗杀和安保合约", { "nocd_agc" }, "任务开始前启用",
    function(toggle)
        Globals.RemoveCooldown.PayphoneHitAndContract(toggle)
        Transition_Handler.Globals.Cooldown.PayphoneHitAndContract = toggle
    end)
menu.click_slider(Franklin_Payphone_Tool, "安保合约刷新间隔时间", { "agcreftime" },
    "单位: 秒\n事务所电脑安保合约刷新间隔时间\n切换战局会失效", 0, 3600, 5, 1, function(value)
        SET_INT_GLOBAL(Globals.FIXER_SECURITY_CONTRACT_REFRESH_TIME, value * 1000)
    end)
menu.action(Franklin_Payphone_Tool, "移除电话暗杀冷却时间", {}, "STAT", function()
    STAT_SET_INT("PAYPHONE_HIT_CDTIMER", 0)
end)

menu.divider(Franklin_Payphone_Tool, "")

local franklin_payphone_missions = {
    hit = {},
}

franklin_payphone_missions.menu_hit = menu.list(Franklin_Payphone_Tool, "禁用电话暗杀任务", {}, "", function()
    if not franklin_payphone_missions.hit.created then
        Transition_Handler.Globals.Payphone.Hit = {}

        franklin_payphone_missions.hit.toggle_menus = {}
        menu.toggle(franklin_payphone_missions.menu_hit, "全部开/关", {}, "", function(toggle)
            for key, value in pairs(franklin_payphone_missions.hit.toggle_menus) do
                menu.set_value(value, toggle)
            end
        end)

        for key, offset in pairs(Globals.Payphone.Hit_Offsets) do
            local name = Globals.Payphone.Hit_Names[key]
            local global = 262145 + offset

            franklin_payphone_missions.hit.toggle_menus[global] = menu.toggle(franklin_payphone_missions.menu_hit,
                name, {}, "", function(toggle)
                    if toggle then
                        SET_FLOAT_GLOBAL(global, 0)
                    else
                        SET_FLOAT_GLOBAL(global, 1)
                    end
                    Transition_Handler.Globals.Payphone.Hit[global] = toggle
                end)
        end

        franklin_payphone_missions.hit.created = true
    end
end)


menu.action(Franklin_Payphone, "传送到 电话亭", { "tppayphone" }, "需要地图上出现电话亭标志",
    function()
        local blip = HUD.GET_NEXT_BLIP_INFO_ID(817)
        if not HUD.DOES_BLIP_EXIST(blip) then
            util.toast("No Vehicle Found")
        else
            local coords = HUD.GET_BLIP_COORDS(blip)
            TELEPORT(coords.x, coords.y, coords.z + 1.0)
        end
    end)

--#region Payphone Hit
local Payphone_Hit = menu.list(Franklin_Payphone, "电话暗杀", {}, "")

menu.divider(Payphone_Hit, "死宅散户")
menu.action(Payphone_Hit, "目标NPC 传送到我", {}, "", function()
    for _, ped in pairs(entities.get_all_peds_as_handles()) do
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ped) then
            local blip = HUD.GET_BLIP_FROM_ENTITY(ped)
            if HUD.DOES_BLIP_EXIST(blip) and HUD.GET_BLIP_SPRITE(blip) == 432 then
                TP_TO_ME(ped, 0.0, 2.0, 0.0)
                WEAPON.REMOVE_ALL_PED_WEAPONS(ped)
                ENTITY.SET_ENTITY_MAX_SPEED(ped, 0.0)

                util.yield(200)
            end
        end
    end
end)

menu.divider(Payphone_Hit, "流行歌星")
menu.action(Payphone_Hit, "目标载具 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, 2038480341)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            SET_ENTITY_HEAD_TO_ENTITY(ent, players.user_ped(), 180.0)
            TP_TO_ME(ent, 0.0, 5.0, 0.0)
            VEHICLE.SET_VEHICLE_FORWARD_SPEED(ent, 0.0)
            for i = 0, 5, 1 do
                VEHICLE.SET_VEHICLE_TYRE_BURST(ent, i, true, 1000.0)
            end
        end
    end
end)
menu.action(Payphone_Hit, "维戈斯帮改装车 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, -1013450936)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            local ent = entity_list[1]
            TP_VEHICLE_TO_ME(ent)
        end
    end
end)
menu.action(Payphone_Hit, "卡车车头 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, 569305213, -2137348917)
    if next(entity_list) ~= nil then
        local ent = entity_list[1]
        TP_VEHICLE_TO_ME(ent)
    end
end)
menu.action(Payphone_Hit, "警车 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, 1912215274)
    if next(entity_list) ~= nil then
        local ent = entity_list[1]
        TP_VEHICLE_TO_ME(ent)
    end
end)

menu.divider(Payphone_Hit, "科技企业家")
menu.action(Payphone_Hit, "出租车 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, -956048545)
    if next(entity_list) ~= nil then
        local ent = entity_list[1]
        TP_VEHICLE_TO_ME(ent)
    end
end)
menu.action(Payphone_Hit, "目标NPC 传送到我", {}, "然后按E叫他上车", function()
    for _, ped in pairs(entities.get_all_peds_as_handles()) do
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ped) then
            local blip = HUD.GET_BLIP_FROM_ENTITY(ped)
            if HUD.DOES_BLIP_EXIST(blip) and HUD.GET_BLIP_SPRITE(blip) == 432 then
                TP_TO_ME(ped, 2.0, 0.0, 0.0)
            end
        end
    end
end)

menu.divider(Payphone_Hit, "法官")
menu.action(Payphone_Hit, "传送到 高尔夫球场", {}, "领取高尔夫装备", function()
    TELEPORT(-1368.963, 56.357, 54.101, 278.422)
end)
menu.action(Payphone_Hit, "目标NPC 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("ped", true, 2111372120)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, 0.0)
            ENTITY.SET_ENTITY_MAX_SPEED(ent, 0.0)
        end
    end
end)

menu.divider(Payphone_Hit, "共同创办人")
menu.action(Payphone_Hit, "目标载具 最大速度为0", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, -2033222435)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            ENTITY.SET_ENTITY_MAX_SPEED(ent, 0.0)
            util.toast("完成！")
        end
    end
end)

menu.divider(Payphone_Hit, "工地总裁")
menu.action(Payphone_Hit, "传送到 装备", {}, "", function()
    local entity_list = get_entities_by_hash("object", true, -86518587)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, -1.0, 1.0)
            SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ent)
        end
    end
end)
menu.action(Payphone_Hit, "目标NPC 传送到集装箱附近", {}, "", function()
    local target_ped = 0
    local ent = 0

    local entity_list = get_entities_by_hash("ped", true, -973145378)
    if next(entity_list) ~= nil then
        target_ped = entity_list[1]
    end

    entity_list = get_entities_by_hash("object", true, 874602658)
    if next(entity_list) ~= nil then
        ent = entity_list[1]
    end

    if ENTITY.DOES_ENTITY_EXIST(target_ped) and ENTITY.DOES_ENTITY_EXIST(ent) then
        TP_ENTITY_TO_ENTITY(target_ped, ent, 0.0, 0.0, -3.0)
        ENTITY.SET_ENTITY_MAX_SPEED(target_ped, 0.0)
    end
end)
menu.action(Payphone_Hit, "目标NPC 传送到油罐附近", {}, "", function()
    local target_ped = 0
    local ent = 0

    local entity_list = get_entities_by_hash("ped", true, -973145378)
    if next(entity_list) ~= nil then
        target_ped = entity_list[1]
    end

    entity_list = get_entities_by_hash("object", true, -46303329)
    if next(entity_list) ~= nil then
        ent = entity_list[1]
    end

    if ENTITY.DOES_ENTITY_EXIST(target_ped) and ENTITY.DOES_ENTITY_EXIST(ent) then
        TP_ENTITY_TO_ENTITY(target_ped, ent, 2.0, 0.0, 1.0)
        ENTITY.SET_ENTITY_MAX_SPEED(target_ped, 0.0)
    end
end)
menu.action(Payphone_Hit, "目标NPC 传送到推土机附近", {}, "", function()
    local target_ped = 0
    local ent = 0

    local entity_list = get_entities_by_hash("ped", true, -973145378)
    if next(entity_list) ~= nil then
        target_ped = entity_list[1]
    end

    entity_list = get_entities_by_hash("vehicle", true, 1886712733)
    if next(entity_list) ~= nil then
        for _, veh in pairs(entity_list) do
            local ped = GET_PED_IN_VEHICLE_SEAT(veh, -1)
            if ped ~= 0 and not is_player_ped(ped) then
                ent = veh
            end
        end
    end

    if ENTITY.DOES_ENTITY_EXIST(target_ped) and ENTITY.DOES_ENTITY_EXIST(ent) then
        TP_ENTITY_TO_ENTITY(target_ped, ent, 0.0, 6.0, 1.0)
        ENTITY.SET_ENTITY_MAX_SPEED(target_ped, 0.0)
    end
end)

--#endregion


--#region Security Contract

local Security_Contract = menu.list(Franklin_Payphone, "安保合约", {}, "")

menu.divider(Security_Contract, "回收贵重物品")
menu.action(Security_Contract, "传送到 保险箱", {}, "", function()
    local entity_list = get_entities_by_hash("object", true, -798293264)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, -0.5, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ent)
        end
    end
end)
menu.action(Security_Contract, "传送到 保险箱密码", {}, "", function()
    local entity_list = get_entities_by_hash("object", true, 367638847)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, 0.0, 0.5)
        end
    end
end)

menu.divider(Security_Contract, "救援行动")
menu.action(Security_Contract, "传送到 客户", {}, "", function()
    local entity_list = get_entities_by_hash("ped", true, -2076336881, -1589423867, 826475330, 2093736314, -1109568186)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            ENTITY.SET_ENTITY_INVINCIBLE(ent, true)
            ENTITY.SET_ENTITY_PROOFS(ent, true, true, true, true, true, true, true, true)

            TP_TO_ENTITY(ent, 0.0, 0.5, 0.0)
        end
    end
end)

menu.divider(Security_Contract, "载具回收")
menu.action(Security_Contract, "机库: 传送到 载具位置", {}, "", function()
    TELEPORT(-1267.28808, -3017.8591, -47.2282, 9.00279)
end)
menu.action(Security_Contract, "机库: 传送到 门锁位置", {}, "", function()
    TELEPORT(-1249.1301, -2979.6404, -48.49219, 269.879)
end)
menu.action(Security_Contract, "人道实验室: 传送进 厢形车", {}, "人道实验室 失窃动物",
    function()
        local entity_list = get_entities_by_hash("object", true, 485150676)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                if ENTITY.IS_ENTITY_ATTACHED(ent) then
                    local attached_ent = ENTITY.GET_ENTITY_ATTACHED_TO(ent)
                    if ENTITY.IS_ENTITY_A_VEHICLE(attached_ent) then
                        TP_INTO_VEHICLE(attached_ent, "delete")
                    end
                end
            end
        end
    end)

menu.divider(Security_Contract, "变现资产")
local Security_Contract_RealizeAssets = {
    -- { { Coords }, Heading }
    car_destination = {
        -- 亚美尼亚帮
        { { -1105.5, -2011.2987, 12.7356 },    120.9303 },
        { { 1713.7562, -1561.0374, 112.1963 }, 72.7691 },
        { { -323.1641, -1410.3094, 30.3902 },  356.4996 },
        -- 梅利威瑟
        { { 850.0665, -2288.5673, 30.1085 },   173.7060 },
        { { 2854.8935, 1515.2998, 24.3381 },   165.2636 },
    },
    bike_destination = {
        -- 失落摩托帮
        { { 1125.8688, -458.5883, 65.8389 }, 349.5725 },
        { { 823.8280, -124.1025, 79.7727 },  59.5104 },
        { { 499.6284, -575.4199, 24.2311 },  27.1227 },
        -- 狗仔队
        { { -668.4118, -892.4926, 24.0101 }, 90.7521 },
        { { 573.7885, 119.1105, 97.5525 },   295.3565 },
        { { -90.2728, 210.1023, 95.1710 },   268.919 },
    },
    heli_destination = {
        { { -143.5477, -593.6083, 212.4510 }, 315.3837 },
        { { -913.9626, -377.3649, 138.5876 }, 85.2279 },
    },
}
menu.action(Security_Contract, "传送进 目标载具并加速", {}, "", function()
    for k, ped in pairs(entities.get_all_peds_as_handles()) do
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ped) then
            local blip = HUD.GET_BLIP_FROM_ENTITY(ped)
            if HUD.DOES_BLIP_EXIST(blip) then
                local sprite = HUD.GET_BLIP_SPRITE(blip) -- 255 Car, 64 Heli, 348 Bike
                if sprite == 225 or sprite == 64 or sprite == 348 then
                    local veh = PED.GET_VEHICLE_PED_IS_IN(ped)
                    if veh ~= 0 then
                        if VEHICLE.ARE_ANY_VEHICLE_SEATS_FREE(veh) then
                            PED.SET_PED_INTO_VEHICLE(players.user_ped(), veh, -2)

                            VEHICLE.MODIFY_VEHICLE_TOP_SPEED(veh, 500.0)
                            PED.SET_DRIVER_ABILITY(ped, 1.0)
                            PED.SET_DRIVER_AGGRESSIVENESS(ped, 1.0)
                            TASK.SET_DRIVE_TASK_DRIVING_STYLE(ped, 262144)
                        else
                            util.toast("目标载具没有空闲座位")
                        end
                    end
                end
            end
        end
    end
end)
menu.action(Security_Contract, "传送到 目标载具并加速", {}, "传送到目标载具头上并提高驾驶员驾驶技能"
, function()
    for k, ped in pairs(entities.get_all_peds_as_handles()) do
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ped) then
            local blip = HUD.GET_BLIP_FROM_ENTITY(ped)
            if HUD.DOES_BLIP_EXIST(blip) then
                local sprite = HUD.GET_BLIP_SPRITE(blip) -- 255 Car, 64 Heli, 348 Bike
                if sprite == 225 or sprite == 64 or sprite == 348 then
                    local veh = PED.GET_VEHICLE_PED_IS_IN(ped)
                    if veh ~= 0 then
                        TP_TO_ENTITY(veh, 0.0, 0.0, 2.0)
                        PLAYER_HEADING(ENTITY.GET_ENTITY_HEADING(veh))

                        VEHICLE.MODIFY_VEHICLE_TOP_SPEED(veh, 500.0)
                        PED.SET_DRIVER_ABILITY(ped, 1.0)
                        PED.SET_DRIVER_AGGRESSIVENESS(ped, 1.0)
                        TASK.SET_DRIVE_TASK_DRIVING_STYLE(ped, 262144)
                    end
                end
            end
        end
    end
end)
menu.list_action(Security_Contract, "目标汽车 传送到目的地", {}, "玩家自己也会跟着传送过去", {
    { "亚美尼亚帮 地点1" }, { "亚美尼亚帮 地点2" }, { "亚美尼亚帮 地点3" },
    { "梅利威瑟 地点1" }, { "梅利威瑟 地点2" },
}, function(value)
    local data = Security_Contract_RealizeAssets.car_destination[value]
    local coords = v3(data[1][1], data[1][2], data[1][3])
    local heading = data[2]

    for k, ped in pairs(entities.get_all_peds_as_handles()) do
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ped) then
            local blip = HUD.GET_BLIP_FROM_ENTITY(ped)
            if HUD.DOES_BLIP_EXIST(blip) then
                local sprite = HUD.GET_BLIP_SPRITE(blip) -- 255 Car
                if sprite == 225 then
                    local veh = PED.GET_VEHICLE_PED_IS_IN(ped)
                    if veh ~= 0 then
                        SET_ENTITY_COORDS(veh, coords)
                        ENTITY.SET_ENTITY_HEADING(veh, heading)

                        if not PED.IS_PED_IN_VEHICLE(players.user_ped(), veh, false) then
                            TP_TO_ENTITY(veh, 0.0, 0.0, 2.0)
                            PLAYER_HEADING(heading)
                        end
                    end
                end
            end
        end
    end
end)
menu.list_action(Security_Contract, "目标摩托车 传送到目的地", {}, "玩家自己也会跟着传送过去", {
    { "失落摩托帮 地点1" }, { "失落摩托帮 地点2" }, { "失落摩托帮 地点3" },
    { "狗仔队 地点1" }, { "狗仔队 地点2" }, { "狗仔队 地点3" },
}, function(value)
    local data = Security_Contract_RealizeAssets.bike_destination[value]
    local coords = v3(data[1][1], data[1][2], data[1][3])
    local heading = data[2]

    for k, ped in pairs(entities.get_all_peds_as_handles()) do
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ped) then
            local blip = HUD.GET_BLIP_FROM_ENTITY(ped)
            if HUD.DOES_BLIP_EXIST(blip) then
                local sprite = HUD.GET_BLIP_SPRITE(blip) -- 348 Bike
                if sprite == 348 then
                    local veh = PED.GET_VEHICLE_PED_IS_IN(ped)
                    if veh ~= 0 then
                        SET_ENTITY_COORDS(veh, coords)
                        ENTITY.SET_ENTITY_HEADING(veh, heading)

                        if not PED.IS_PED_IN_VEHICLE(players.user_ped(), veh, false) then
                            TP_TO_ENTITY(veh, 0.0, 0.0, 2.0)
                            PLAYER_HEADING(heading)
                        end
                    end
                end
            end
        end
    end
end)
menu.list_action(Security_Contract, "目标直升机 传送到目的地", {}, "玩家自己也会跟着传送过去", {
    { "地点1" }, { "地点2" }
}, function(value)
    local data = Security_Contract_RealizeAssets.heli_destination[value]
    local coords = v3(data[1][1], data[1][2], data[1][3])
    local heading = data[2]

    for k, ped in pairs(entities.get_all_peds_as_handles()) do
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ped) then
            local blip = HUD.GET_BLIP_FROM_ENTITY(ped)
            if HUD.DOES_BLIP_EXIST(blip) then
                local sprite = HUD.GET_BLIP_SPRITE(blip) -- 64 Heli
                if sprite == 64 then
                    local veh = PED.GET_VEHICLE_PED_IS_IN(ped)
                    if veh ~= 0 then
                        SET_ENTITY_COORDS(veh, coords)
                        ENTITY.SET_ENTITY_HEADING(veh, heading)

                        if not PED.IS_PED_IN_VEHICLE(players.user_ped(), veh, false) then
                            TP_TO_ENTITY(veh, 0.0, 0.0, 2.0)
                            PLAYER_HEADING(heading)
                        end
                    end
                end
            end
        end
    end
end)

menu.divider(Security_Contract, "资产保护")
menu.action(Security_Contract, "资产 无敌", {}, "", function()
    local entity_list = get_entities_by_hash("object", true, -1597216682, 1329706303, 1503555850, -534405572)
    if next(entity_list) ~= nil then
        local i = 0
        for k, ent in pairs(entity_list) do
            set_entity_godmode(ent, true)
            i = i + 1
        end
        util.toast("完成！\n数量: " .. i)
    end
end)
menu.action(Security_Contract, "保安 无敌强化", {}, "", function()
    local entity_list = get_entities_by_hash("ped", true, -1575488699, -634611634)
    if next(entity_list) ~= nil then
        local i = 0
        for k, ent in pairs(entity_list) do
            local weaponHash = util.joaat("WEAPON_SPECIALCARBINE")
            WEAPON.GIVE_WEAPON_TO_PED(ent, weaponHash, -1, false, true)
            WEAPON.SET_CURRENT_PED_WEAPON(ent, weaponHash, false)

            increase_ped_combat_ability(ent, true, false)
            increase_ped_combat_attributes(ent)
            i = i + 1
        end
        util.toast("完成！\n数量: " .. i)
    end
end)
menu.action(Security_Contract, "毁掉资产 任务失败", {}, "不再等待漫长的10分钟",
    function()
        local entity_list = get_entities_by_hash("object", true, -1597216682, 1329706303, 1503555850, -534405572)
        if next(entity_list) ~= nil then
            local i = 0
            for k, ent in pairs(entity_list) do
                SET_ENTITY_HEALTH(ent, 0)
                i = i + 1
            end
            util.toast("完成！\n数量: " .. i)
        end
    end)

--#endregion


--#endregion


--#region LSA Operations

local LSA_Operations = menu.list(Freemode_Mission, "LSA行动", {}, "")

----- 直接行动 -----
local LSA_Direct_Action = menu.list(LSA_Operations, "直接行动", {}, "")

menu.action(LSA_Direct_Action, "传送到 集装箱", {}, "有图拉尔多的集装箱", function()
    local entity_list = get_entities_by_hash("vehicle", true, 1455990255)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, 4.0, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ent, 180.0)
            set_entity_godmode(ent, true)
            VEHICLE.SET_VEHICLE_ENGINE_ON(ent, true, true, false)
        end
    end
end)
menu.divider(LSA_Direct_Action, "附加行动")
menu.action(LSA_Direct_Action, "传送进 雷兽", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, 239897677)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            set_entity_godmode(ent, true)
            TP_INTO_VEHICLE(ent)
        end
    end
end)
menu.action(LSA_Direct_Action, "爆炸 防空系统", {}, "", function()
    local entity_list = get_entities_by_hash("object", true, -888936273)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            local coords = ENTITY.GET_ENTITY_COORDS(ent)
            add_owned_explosion(players.user_ped(), coords, 4)
        end
    end
end)
menu.action(LSA_Direct_Action, "传送到 鲁斯特机库", {}, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(359)
    if HUD.DOES_BLIP_EXIST(blip) then
        TELEPORT(-1254.44189, -3355.82641, 15.155522, 150.995437)
    end
end)
local LSA_Direct_Action_box = {}
menu.textslider(LSA_Direct_Action, "传送到 梅利威瑟箱子", {}, "放置追踪器",
    { "获取", "1", "2", "3" }, function(value)
        if value == 1 then
            local entity_list = get_entities_by_hash("object", true, 238227635)
            if next(entity_list) ~= nil then
                LSA_Direct_Action_box = entity_list
                util.toast("完成！")
            end
        else
            local ent = LSA_Direct_Action_box[value - 1]
            if ent ~= nil and ENTITY.DOES_ENTITY_EXIST(ent) then
                TP_TO_ENTITY(ent, 1.5, 0.0, 0.0)
                SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ent, 90.0)
            end
        end
    end)

----- 外科手术式攻击 -----
local LSA_Surgical_Strike = menu.list(LSA_Operations, "外科手术式攻击", {}, "")
menu.action(LSA_Surgical_Strike, "走私犯 传送到我", {}, "会传送到空中然后摔死", function()
    local entity_list = get_entities_by_hash("ped", true, 664399832)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, 10.0)
        end
    end
end)
menu.action(LSA_Surgical_Strike, "信号弹标记货物", {}, "标记3个货物", function()
    local entity_list = get_entities_by_hash("object", true, -1297668303, 2104596125, -899949922)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            local pos = ENTITY.GET_ENTITY_COORDS(ent)
            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z + 0.2,
                pos.x, pos.y, pos.z,
                1000,
                false,
                1198879012, -- WEAPON_FLAREGUN
                players.user_ped(),
                true, true, 1000.0)
        end
    end
end)
menu.click_slider(LSA_Surgical_Strike, "传送到 货物", {}, "放置追踪器",
    1, 3, 1, 1, function(value)
        local data = {
            { hash = -1297668303, offset_y = -1.0, heading = 0 },
            { hash = 2104596125,  offset_y = 2.5,  heading = 180 },
            { hash = -899949922,  offset_y = 1.5,  heading = 180 },
        }

        local entity_list = get_entities_by_hash("object", true, data[value].hash)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                TP_TO_ENTITY(ent, 0.0, data[value].offset_y, 0.8)
                SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ent, data[value].heading)
            end
        end
    end)
menu.action(LSA_Surgical_Strike, "HVY威胁者 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, 2044532910)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_VEHICLE_TO_ME(ent, "", "delete")
        end
    end
end)
menu.divider(LSA_Surgical_Strike, "附加行动")
menu.action(LSA_Surgical_Strike, "夜鲨 传送到我", {}, "偷取梅利威瑟套装", function()
    local entity_list = get_entities_by_hash("vehicle", true, 433954513)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_VEHICLE_TO_ME(ent)
        end
    end
end)
menu.action(LSA_Surgical_Strike, "传送到 蓝图", {}, "", function()
    local entity_list = get_entities_by_hash("object", true, 705213476)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, 0.0, 0.5)
        end
    end
end)
menu.action(LSA_Surgical_Strike, "传送到 工艺品", {}, "", function()
    local entity_list = get_entities_by_hash("object", true, 1468594282)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, 0.0, 0.5)
        end
    end
end)

----- 告密者 -----
local LSA_Whistleblower = menu.list(LSA_Operations, "告密者", {}, "")

menu.action(LSA_Whistleblower, "传送进 运兵直升机", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, 1621617168)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            set_entity_godmode(ent, true)
            TP_INTO_VEHICLE(ent)
            VEHICLE.SET_HELI_BLADES_FULL_SPEED(ent)
        end
    end
end)
menu.action(LSA_Whistleblower, "电磁脉冲 传送到直升机挂钩位置", {}, "运兵直升机提前放下吊钩",
    function()
        local entity_list = get_entities_by_hash("object", true, 256023367)
        if next(entity_list) ~= nil then
            local veh = GET_VEHICLE_PED_IS_IN(players.user_ped())
            if veh ~= 0 and VEHICLE.DOES_CARGOBOB_HAVE_PICK_UP_ROPE(veh) then
                local pos = VEHICLE.GET_ATTACHED_PICK_UP_HOOK_POSITION(veh)
                for k, ent in pairs(entity_list) do
                    pos.z = pos.z + 1.0
                    SET_ENTITY_COORDS(ent, pos)
                end
            end
        end
    end)
menu.click_slider(LSA_Whistleblower, "传送到 硬盘", {}, "", 1, 3, 1, 1, function(value)
    if PLAYER_INTERIOR() == 270081 then
        local data = {
            { coords = { x = 2059.83105, y = 2992.87133, z = -67.701660 }, heading = 91.0812683 },
            { coords = { x = 2064.04785, y = 2998.16528, z = -67.701675 }, heading = 45.7618637 },
            { coords = { x = 2073.84204, y = 2991.28125, z = -67.701660 }, heading = 290.621582 },
        }
        TELEPORT2(data[value].coords, data[value].heading)
    end
end)
menu.divider(LSA_Whistleblower, "附加行动")
menu.action(LSA_Whistleblower, "爆炸 备用发电机", {}, "", function()
    local entity_list = get_entities_by_hash("object", true, 440559194)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            local coords = ENTITY.GET_ENTITY_COORDS(ent)
            add_owned_explosion(players.user_ped(), coords, 4)
        end
    end
end)
menu.action(LSA_Whistleblower, "传送到 服务器主机", {}, "上传病毒", function()
    local entity_list = get_entities_by_hash("object", true, -1449766933)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.8, -1.0, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ent)
        end
    end
end)
menu.action(LSA_Whistleblower, "传送到 案件卷宗", {}, "", function()
    local entity_list = get_entities_by_hash("object", true, -2135102209)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, 0.0, 0.5)
        end
    end
end)

--#endregion


--#region Dax Work

local Dax_Work = menu.list(Freemode_Mission, "达克斯工作", {}, "蠢人帮差事")

menu.action(Dax_Work, "移除冷却时间", {}, "请求工作前点击一次", function()
    STAT_SET_INT("XM22JUGGALOWORKCDTIMER", 0)
end)

menu.divider(Dax_Work, "摧毁大麻生产")
menu.action(Dax_Work, "传送进 洒药机", {}, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(251)
    if HUD.DOES_BLIP_EXIST(blip) then
        local vehicle = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
        TP_INTO_VEHICLE(vehicle)
    end
end)
menu.action(Dax_Work, "传送到 大麻种植场", {}, "会按顺序传送，同时会冻结飞机", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(496)
    if HUD.DOES_BLIP_EXIST(blip) then
        local vehicle = entities.get_user_vehicle_as_handle(false)
        ENTITY.FREEZE_ENTITY_POSITION(vehicle, true)
        SET_ENTITY_COORDS(vehicle, HUD.GET_BLIP_COORDS(blip))
    end
end)
menu.divider(Dax_Work, "回收货物")
menu.action(Dax_Work, "敌对老大 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("ped", true, 850468060)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ME(ent, 0.0, 2.0, 0.0)
        end
    end
end)
menu.action(Dax_Work, "货物 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, 1069929536)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_VEHICLE_TO_ME(ent)
        end
    end
end)
menu.divider(Dax_Work, "摧毁敌对生意")
menu.action(Dax_Work, "传送进 厢型车", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, -119658072)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_INTO_VEHICLE(ent)
        end
    end
end)
menu.action(Dax_Work, "传送到 改车王", {}, "", function()
    local blip = HUD.GET_CLOSEST_BLIP_INFO_ID(72)
    if HUD.DOES_BLIP_EXIST(blip) then
        TELEPORT2(HUD.GET_BLIP_COORDS(blip))
    end
end)
menu.action(Dax_Work, "传送到 油罐旁边", {}, "", function()
    local entity_list = get_entities_by_hash("object", true, 1890640474)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, -2.0, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ent, 90.0)
        end
    end
end)
menu.divider(Dax_Work, "污染大麻种植场")
menu.action(Dax_Work, "阻挡化学品卡车生成点", {},
    "请求工作前使用\n通过阻挡任务刷新点来避免触发该任务", function()
        local point_list = {
            -- x, y, z, heading
            { 953.78912353516,  -1510.8637695312, 30.565595626831, 150.2282409668 },
            { -807.35223388672, 5401.7709960938,  33.858123779297, 172.58210754395 },
            { 22.434871673584,  -368.89181518555, 38.845996856689, 348.0 },
        }
        block_mission_generate_point(point_list)
    end)

--#endregion


--#region MC Contracts

local MC_Contracts = menu.list(Freemode_Mission, "摩托帮会所合约", {}, "")

local MC_Contracts_Tool = menu.list(MC_Contracts, "工具", {}, "")

Transition_Handler.Globals.Biker.Contracts = {}
menu.toggle(MC_Contracts_Tool, "单人可进行所有任务", {}, "", function(toggle)
    Globals.Biker.Contracts.MinPlayer(toggle)
    Transition_Handler.Globals.Biker.Contracts.MinPlayer = toggle
end)


menu.divider(MC_Contracts, "屋顶作战")
menu.action(MC_Contracts, "传送到 割据", {}, "", function()
    local entity_list = get_entities_by_hash("object", true, 339736694)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, -0.8, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ent)
        end
    end
end)
menu.action(MC_Contracts, "传送到 暴君钥匙", {}, "", function()
    local entity_list = get_entities_by_hash("object", true, 2105669131)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, -0.8, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ent)
        end
    end
end)
menu.action(MC_Contracts, "传送到 货箱", {}, "有暴君的货箱", function()
    local entity_list = get_entities_by_hash("vehicle", true, 884483972)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            if ENTITY.IS_ENTITY_ATTACHED(ent) then
                local attached_ent = ENTITY.GET_ENTITY_ATTACHED_TO(ent)

                TP_TO_ENTITY(attached_ent, 0.0, -2.5, 0.0)
                SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), attached_ent)

                VEHICLE.SET_VEHICLE_ENGINE_ON(ent, true, true, false)
            end
        end
    end
end)

menu.divider(MC_Contracts, "直捣黄龙")
menu.action(MC_Contracts, "传送到 保险箱", {}, "", function()
    local entity_list = get_entities_by_hash("object", true, 1089807209)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, -1.0, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ent)
        end
    end
end)

--#endregion


--#region Contact Work

local Contact_Work = menu.list(Freemode_Mission, "联系人请求工作", {}, "")

local Contact_Work_Cooldown = menu.list(Contact_Work, "移除冷却时间", {}, "切换战局后会失效，需要重新操作")
menu.toggle(Contact_Work_Cooldown, "贝克女士 请求工作", {}, "", function(toggle)
    if toggle then
        SET_INT_GLOBAL(Globals.VC_WORK_REQUEST_COOLDOWN, 0)
    else
        SET_INT_GLOBAL(Globals.VC_WORK_REQUEST_COOLDOWN, 180000)
    end
end)
menu.toggle(Contact_Work_Cooldown, "尤汗 请求夜总会货物", {}, "", function(toggle)
    if toggle then
        SET_INT_GLOBAL(Globals.NC_GOODS_REQUEST_COOLDOWN, 0)
    else
        SET_INT_GLOBAL(Globals.NC_GOODS_REQUEST_COOLDOWN, 1200)
    end
end)
menu.toggle(Contact_Work_Cooldown, "14号探员 请求地堡研究", {}, "", function(toggle)
    if toggle then
        SET_INT_GLOBAL(Globals.BUNKER_RESEARCH_REQUEST_COOLDOWN, 0)
    else
        SET_INT_GLOBAL(Globals.BUNKER_RESEARCH_REQUEST_COOLDOWN, 1200)
    end
end)
menu.divider(Contact_Work_Cooldown, "Stat")
menu.action(Contact_Work_Cooldown, "尤汗 请求夜总会货物", {}, "", function()
    STAT_SET_INT("SOURCE_GOODS_CDTIMER", 0)
end)
menu.action(Contact_Work_Cooldown, "14号探员 请求地堡研究", {}, "", function()
    STAT_SET_INT("SOURCE_RESEARCH_CDTIMER", 0)
end)

menu.action(Contact_Work, "尤汗: 货物 传送到我", {}, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(478)
    if HUD.DOES_BLIP_EXIST(blip) then
        local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            detach_product_entity(ent)
            TP_TO_ME(ent)
        else
            util.toast("目标不是实体，无法传送到我")
        end
    end
end)

--#endregion


--#region Other

menu.divider(Freemode_Mission, "其它")

menu.action(Freemode_Mission, "传送到 电脑", { "tp_desk" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(521)
    if HUD.DOES_BLIP_EXIST(blip) then
        local coords = HUD.GET_BLIP_COORDS(blip)
        TELEPORT(coords.x - 1.0, coords.y + 1.0, coords.z)
    end
end)
menu.action(Freemode_Mission, "打开 恐霸屏幕", { "open_terrorbyte" }, "", function()
    if IS_IN_SESSION() then
        SET_INT_GLOBAL(Globals.IsUsingComputerScreen, 1)
        START_SCRIPT("appHackerTruck", 4592) -- arg count needed to properly start the script, possibly outdated
    end
end)
menu.action(Freemode_Mission, "传送到 夜总会VIP客户", { "tp_radar_vip" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(480)
    if HUD.DOES_BLIP_EXIST(blip) then
        local coords = HUD.GET_BLIP_COORDS(blip)
        TELEPORT(coords.x, coords.y, coords.z + 0.8)
    end
end)
menu.action(Freemode_Mission, "传送到 地图蓝点", { "tp_radar_blue" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(143)
    if HUD.DOES_BLIP_EXIST(blip) then
        local coords = HUD.GET_BLIP_COORDS(blip)
        TELEPORT(coords.x, coords.y, coords.z + 0.8)
    end
end)
menu.action(Freemode_Mission, "出口载具 传送到我", { "tpme_export_veh" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(143)
    if HUD.DOES_BLIP_EXIST(blip) then
        local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
        if ENTITY.IS_ENTITY_A_VEHICLE(ent) then
            TP_VEHICLE_TO_ME(ent)
        end
    end
end)
menu.action(Freemode_Mission, "传送到 载具出口码头", { "tp_radar_dock" }, "", function()
    TELEPORT(1171.784, -2974.434, 6.502)
end)
menu.action(Freemode_Mission, "传送到 出租车乘客", { "tp_taxi_passenger" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(280)
    if HUD.DOES_BLIP_EXIST(blip) then
        local ped = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
        if ENTITY.IS_ENTITY_A_PED(ped) then
            TP_TO_ENTITY(ped, 0.0, 3.0, 0.0)
            SET_ENTITY_HEAD_TO_ENTITY(players.user_ped(), ped, 90)
        end
    end
end)
menu.action(Freemode_Mission, "传送到 杰拉德包裹", { "tp_drug_pack" }, "进入范围内才能传送", function()
    local entity_list = get_entities_by_hash("object", true, 138777325, -1620734287, 765087784)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            TP_TO_ENTITY(ent, 0.0, 0.0, 0.5)
        end
    end
end)
menu.action(Freemode_Mission, "通知 藏匿屋密码", { "stash_house_code" }, "", function()
    if PLAYER_INTERIOR() == 289793 then
        local code_list = {
            -- hash, code
            { -73329357,   "01-23-45" }, -- xm3_prop_xm3_code_01_23_45
            { 1433270535,  "02-12-87" },
            { 944906360,   "05-02-91" },
            { -1248906748, "24-10-81" },
            { 1626709912,  "28-03-98" },
            { 921471402,   "28-11-97" },
            { -646417257,  "44-23-37" },
            { -158146725,  "72-68-83" },
            { 1083248297,  "73-27-38" },
            { 2104921722,  "77-79-73" },
        }
        for k, obj in pairs(entities.get_all_objects_as_handles()) do
            if ENTITY.IS_ENTITY_A_MISSION_ENTITY(obj) then
                local hash = ENTITY.GET_ENTITY_MODEL(obj)
                for _, data in pairs(code_list) do
                    if hash == data[1] then
                        THEFEED_POST.TEXT("藏匿屋密码: " .. data[2])
                    end
                end
            end
        end
    end
end)
menu.action(Freemode_Mission, "会所酒吧补给品 传送到我", { "tpme_biker_bar" }, "", function()
    -- Hash: 528555233 (pickup)
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(827)
    if HUD.DOES_BLIP_EXIST(blip) then
        local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            detach_product_entity(ent)
            TP_TO_ME(ent)
        else
            util.toast("目标不是实体，无法传送到我")
        end
    end
end)

--#endregion



---------------------
-- 多人抢劫任务
---------------------
local Multi_Heist_Mission = menu.list(Mission_Options, "多人抢劫任务", {}, "")

--#region Apartment Heist

menu.divider(Multi_Heist_Mission, "公寓抢劫")

--- 全福银行 The Fleeca Job ---
--- 越狱 The Prison Break ---
local Heist_Prison = menu.list(Multi_Heist_Mission, "越狱", {}, "")

menu.action(Heist_Prison, "飞机: 目的地 生成坦克", {}, "", function()
    local coords = { x = 2183.927, y = 4759.426, z = 41.676 }
    local heading = 73.373
    local hash = util.joaat("khanjali")
    local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, heading)
    if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        upgrade_vehicle(vehicle)
        set_entity_godmode(vehicle, true)
        strong_vehicle(vehicle)
        util.toast("完成！")
    end
end)
menu.action(Heist_Prison, "巴士: 传送到目的地", {}, "", function()
    local coords = { x = 2054.97119, y = 3179.5639, z = 45.43724 }
    local heading = 243.0095
    local entity_list = get_entities_by_hash("vehicle", true, -2007026063)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            local blip = HUD.GET_BLIP_FROM_ENTITY(ent)
            if HUD.DOES_BLIP_EXIST(blip) then
                local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ent, -1)
                if ped ~= 0 and not is_player_ped(ped) then
                    RequestControl(ped)
                    TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                    SET_ENTITY_HEALTH(ped, 0)
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
menu.divider(Heist_Prison, "终章")
menu.action(Heist_Prison, "(破坏)巴士 传送到目的地", {}, "", function()
    local coords = { x = 1679.619873, y = 3278.103759, z = 41.0774383 }
    local heading = 32.8253974
    local entity_list = get_entities_by_hash("vehicle", true, -2007026063)
    if next(entity_list) ~= nil then
        for k, ent in pairs(entity_list) do
            local blip = HUD.GET_BLIP_FROM_ENTITY(ent)
            if HUD.DOES_BLIP_EXIST(blip) then
                local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ent, -1)
                if ped ~= 0 and not is_player_ped(ped) then
                    RequestControl(ped)
                    TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                    SET_ENTITY_HEALTH(ped, 0)
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
menu.action(Heist_Prison, "监狱内 生成骷髅马", {}, "", function()
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
menu.action(Heist_Prison, "美杜莎 无敌", {}, "", function()
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
menu.action(Heist_Prison, "秃鹰直升机 无敌", {}, "", function()
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
menu.action(Heist_Prison, "敌对天煞 传送到海洋", {}, "", function()
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
menu.action(Heist_Prison, "敌对天煞 冻结", {}, "", function()
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
menu.action(Heist_Prison, "敌对天煞 禁用导弹", {}, "", function()
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
local Heist_Prison_rashcosvki = menu.list(Heist_Prison, "光头", {}, "")

menu.action(Heist_Prison_rashcosvki, "清除正在执行的任务", {}, "", function()
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
menu.action(Heist_Prison_rashcosvki, "无敌强化", {}, "", function()
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
local Heist_Prison_vehicle = 0
menu.action(Heist_Prison_rashcosvki, "跑去监狱外围的警车", {},
    "会在监狱外围生成一辆警车", function()
        local hash = util.joaat("police3")
        local coords = { x = 1571.585, y = 2605.450, z = 45.880 }
        local heading = 343.0217

        local entity_list = get_entities_by_hash("ped", true, 940330470)
        if next(entity_list) ~= nil then
            for k, ent in pairs(entity_list) do
                RequestControl(ent)

                if not ENTITY.DOES_ENTITY_EXIST(Heist_Prison_vehicle) then
                    local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, heading)
                    upgrade_vehicle(vehicle)
                    set_entity_godmode(vehicle, true)
                    strong_vehicle(vehicle)
                    VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(vehicle, 5.0)

                    Heist_Prison_vehicle = vehicle
                end

                TASK.TASK_GO_TO_ENTITY(ent, Heist_Prison_vehicle, -1, 5.0, 100, 0.0, 0)

                if hasControl(ent) then
                    util.toast("完成！")
                else
                    util.toast("未能成功控制实体")
                end
            end
        end
    end)

menu.divider(Heist_Prison_rashcosvki, "玩家")

local heist_prison = {
    select_menu,
    select_player = -1,
    player_list = {},
    team_list = {
        [-1] = "无",
        [0] = "囚犯",
        [1] = "飞行员",
        [2] = "狱警",
        [3] = "破坏"
    },
}
heist_prison.select_menu = menu.list_select(Heist_Prison_rashcosvki, "选择玩家", {}, "",
    { { "刷新列表", {}, "" } }, 1, function(value)
        if value == 1 then
            heist_prison.select_player = -1
            heist_prison.player_list = {}

            local list_item_data = { { "刷新列表", {}, "" } }
            for k, pid in pairs(players.list()) do
                local t = { "", {}, "" }

                local name = players.get_name(pid)
                local rank = players.get_rank(pid)
                local team = PLAYER.GET_PLAYER_TEAM(pid)
                local menu_name = heist_prison.team_list[team] .. ": " .. name .. " (" .. rank .. "级)"

                t[1] = menu_name

                table.insert(list_item_data, t)
                table.insert(heist_prison.player_list, pid)
            end

            menu.set_list_action_options(heist_prison.select_menu, list_item_data)
            util.toast("已刷新，请重新打开该列表")
        else
            local pid = heist_prison.player_list[value - 1]
            if players.exists(pid) then
                heist_prison.select_player = pid
            else
                util.toast("该玩家已不存在")
            end
        end
    end)
menu.action(Heist_Prison_rashcosvki, "传送到玩家/玩家载具", {}, "", function()
    if players.exists(heist_prison.select_player) then
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(heist_prison.select_player)
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
menu.action(Heist_Prison_rashcosvki, "进入到玩家载具", {}, "TASK_ENTER_VEHICLE", function()
    if players.exists(heist_prison.select_player) then
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(heist_prison.select_player)
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
menu.action(Heist_Prison_rashcosvki, "跟随玩家", {}, "TASK_FOLLOW_TO_OFFSET_OF_ENTITY", function()
    if players.exists(heist_prison.select_player) then
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(heist_prison.select_player)
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


--- 突袭人道实验室 The Humane Labs Raid ---
local Heist_Huamane = menu.list(Multi_Heist_Mission, "突袭人道实验室", {}, "")

menu.action(Heist_Huamane, "关键密码: 目的地 生成坦克", {}, "", function()
    local coords = { x = 142.122, y = -1061.271, z = 29.746 }
    local head = 69.686
    local hash = util.joaat("khanjali")
    local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, head)
    if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        upgrade_vehicle(vehicle)
        set_entity_godmode(vehicle, true)
        strong_vehicle(vehicle)
        util.toast("完成！")
    end
end)
menu.action(Heist_Huamane, "电磁装置: 九头蛇 无敌", {}, "", function()
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
menu.action(Heist_Huamane, "电磁装置: 天煞 无敌", {}, "没有玩家和NPC驾驶的天煞",
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
            util.toast("完成！\n数量: " .. i)
        end
    end)
menu.action(Heist_Huamane, "运送电磁装置: 叛乱分子 传送到目的地", {}, "", function()
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
menu.action(Heist_Huamane, "终章: 女武神 无敌", {}, "", function()
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


--- 首轮募资 Series A Funding ---
local Mission_Options_Series = menu.list(Multi_Heist_Mission, "首轮募资", {}, "")

menu.action(Mission_Options_Series, "可卡因: 直升机 无敌", {}, "", function()
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
menu.action(Mission_Options_Series, "窃取冰毒: 油罐车 无敌", {}, "", function()
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
menu.action(Mission_Options_Series, "窃取冰毒: 油罐车位置 生成尖锥魅影", {}, "", function()
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


--- 太平洋标准银行 The Pacific Standard ---
local Mission_Options_Pacific = menu.list(Multi_Heist_Mission, "太平洋标准银行", {}, "")

menu.action(Mission_Options_Pacific, "厢型车: 添加地图标记点", {}, "给车添加地图标记点ABCD",
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
menu.action(Mission_Options_Pacific, "厢型车: 司机 传送到天上并冻结", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, 444171386)
    if next(entity_list) ~= nil then
        local i = 0
        for k, ent in pairs(entity_list) do
            local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ent, -1)
            if ped ~= 0 and not is_player_ped(ped) then
                RequestControl(ped)

                TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                SET_ENTITY_MOVE(ped, 0.0, 0.0, 500.0)
                ENTITY.FREEZE_ENTITY_POSITION(ped, true)

                if hasControl(ped) then
                    i = i + 1
                end
            end
        end
        util.toast("完成！\n数量: " .. i)
    end
end)
menu.action(Mission_Options_Pacific, "厢型车: 传送到目的地", {}, "传送司机到天上，车传送到莱斯特工厂"
, function()
    local coords = { x = 760, y = -983, z = 30 }
    local head = 93.6973
    local entity_list = get_entities_by_hash("vehicle", true, 444171386)
    if next(entity_list) ~= nil then
        local ped_num, veh_num = 0, 0
        for k, ent in pairs(entity_list) do
            local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ent, -1)
            if ped ~= 0 and not is_player_ped(ped) then
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
            VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(ent, 5.0)
            coords.y = coords.y + 3.5

            if hasControl(ent) then
                veh_num = veh_num + 1
            end
        end
        util.toast("完成！\nNPC数量: " .. ped_num .. "\n载具数量: " .. veh_num)
    end
end)
menu.action(Mission_Options_Pacific, "信号: 岛上 生成直升机", {}, "撤离时", function()
    local coords = { x = -2188.197, y = 5128.990, z = 11.672 }
    local head = 314.255
    local hash = util.joaat("polmav")
    local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, head)
    if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        set_entity_godmode(vehicle, true)
        strong_vehicle(vehicle)
        VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(vehicle, 5.0)
        util.toast("完成！")
    end
end)
menu.action(Mission_Options_Pacific, "车队: 目的地 生成坦克", {}, "", function()
    local coords = { x = -196.452, y = 4221.374, z = 45.376 }
    local head = 313.298
    local hash = util.joaat("khanjali")
    local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, head)
    if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        upgrade_vehicle(vehicle)
        set_entity_godmode(vehicle, true)
        strong_vehicle(vehicle)
        util.toast("完成！")
    end
end)
menu.action(Mission_Options_Pacific, "车队: 卡车 无敌", {}, "", function()
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
menu.action(Mission_Options_Pacific, "摩托车: 雷克卓 升级无敌", {}, "", function()
    local entity_list = get_entities_by_hash("vehicle", true, 640818791)
    if next(entity_list) ~= nil then
        local i = 0
        for k, ent in pairs(entity_list) do
            RequestControl(ent, 2)

            set_entity_godmode(ent, true)
            upgrade_vehicle(ent)
            strong_vehicle(ent)

            if hasControl(ent) then
                i = i + 1
            end
        end
        util.toast("完成！\n数量: " .. i)
    end
end)
menu.action(Mission_Options_Pacific, "终章: 摩托车位置 生成骷髅马", {}, "", function()
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
menu.action(Mission_Options_Pacific, "终章: 摩托车位置 生成直升机", {}, "", function()
    local coords = { x = 52.549, y = 88.787, z = 78.683 }
    local head = 15.508
    local hash = util.joaat("polmav")
    local vehicle = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, head)
    if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        set_entity_godmode(vehicle, true)
        strong_vehicle(vehicle)
        VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(vehicle, 5.0)
        util.toast("完成！")
    end
end)

--#endregion


--#region Doomsday Heist

menu.divider(Multi_Heist_Mission, "末日豪劫")

local Doomsday_Preps = menu.list(Multi_Heist_Mission, "前置任务", {}, "")

menu.divider(Doomsday_Preps, "末日一: 数据泄露")
menu.action(Doomsday_Preps, "医疗装备: 救护车 传送到我", {}, "", function()
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
doomsday_preps_deluxo_menu = menu.list_action(Doomsday_Preps, "德罗索: 载具 传送到我",
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
menu.action(Doomsday_Preps, "德罗索: 当前载具 随机主色调", {},
    "无需去改车王改装\n基于Stand命令", function()
        if PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
            local colour = get_random_colour()
            menu.trigger_commands("vehprimaryred " .. colour.r)
            menu.trigger_commands("vehprimarygreen " .. colour.g)
            menu.trigger_commands("vehprimaryblue " .. colour.b)
        end
    end)
menu.action(Doomsday_Preps, "阿库拉: 载具 传送到我", {},
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

menu.divider(Doomsday_Preps, "末日二: 博格丹危机")
menu.action(Doomsday_Preps, "钥匙卡: 防暴车 传送到我", {}, "", function()
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
menu.action(Doomsday_Preps, "ULP情报: 包裹 传送到我", {},
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
doomsday_preps_stromberg_menu = menu.list_action(Doomsday_Preps, "斯特龙伯格: 卡车 传送到我",
    {}, "", { "刷新载具列表" }, function(value)
        if value == 1 then
            local entity_list = get_entities_by_hash("object", true, -6020377, -1690938994)
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
menu.action(Doomsday_Preps, "鱼雷电控单元: 包裹 传送到我", {}, "", function()
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

menu.divider(Doomsday_Preps, "末日三: 末日将至")
menu.action(Doomsday_Preps, "标记资金: 包裹 传送到我", {}, "", function()
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
menu.action(Doomsday_Preps, "切尔诺伯格: 载具 传送到我", {}, "", function()
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
menu.action(Doomsday_Preps, "机载电脑: 飞机 传送到我", {},
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

--#endregion




menu.divider(Mission_Options, "")

--#region Player Assistant

local Player_Assistant = menu.list(Mission_Options, "玩家助手", {}, "")

menu.toggle(Player_Assistant, "[TEST] Low Cop Level", {}, "", function(toggle)
    for _, pid in pairs(players.list()) do
        PLAYER.SET_POLICE_IGNORE_PLAYER(pid, toggle)
        PLAYER.SET_EVERYONE_IGNORE_PLAYER(pid, toggle)
        PLAYER.SET_DISPATCH_COPS_FOR_PLAYER(pid, not toggle)
        if toggle then
            PLAYER.SET_WANTED_LEVEL_DIFFICULTY(pid, 0.0)
        else
            PLAYER.RESET_WANTED_LEVEL_DIFFICULTY(pid)
        end
    end
end)
menu.action(Player_Assistant, "[TEST] Force Start Hidden Evasion", {}, "", function()
    for _, pid in pairs(players.list()) do
        PLAYER.FORCE_START_HIDDEN_EVASION(pid)
    end
end)


menu.divider(Player_Assistant, "")


local player_assistant = {
    menu_list = {},
}

function player_assistant.generate_menu(menu_parent, pid)
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

menu.toggle_loop(Player_Assistant, "显示玩家信息", {}, "", function()
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

menu.action(Player_Assistant, "刷新玩家列表", {}, "", function()
    rs_menu.delete_menu_list(player_assistant.menu_list)
    player_assistant.menu_list = {}
    ------
    for k, pid in pairs(players.list()) do
        local name = players.get_name(pid)
        local rank = players.get_rank(pid)
        local menu_name = name .. " (" .. rank .. "级)"

        local team = PLAYER.GET_PLAYER_TEAM(pid)
        local money = players.get_money(pid)
        local language = players.get_language(pid)
        local help_text = "Team: " .. team .. "\nMoney: " .. money .. "\nLanguage: " .. enum_LanguageType[language]

        local player_menu = menu.list(Player_Assistant, menu_name, {}, help_text)
        table.insert(player_assistant.menu_list, player_menu)

        player_assistant.generate_menu(player_menu, pid)
    end
end)
menu.divider(Player_Assistant, "玩家列表")

--#endregion


--#region Nearby Road

local Nearby_Road = menu.list(Mission_Options, "附近街道", {}, "")

local nearby_road = {
    nodeType = 0,
    random_radius = 100.0,
    godmode = true,
    strong = true,
    flash_blip = false,
    num = 1,
}

menu.divider(Nearby_Road, "生成载具")

menu.list_select(Nearby_Road, "生成地点", {}, "", {
    { "主要道路" }, { "任意地面" }, { "水 (船)" }, { "随机" },
}, 1, function(value)
    nearby_road.nodeType = value - 1
end)
menu.slider_float(Nearby_Road, "随机范围", { "nearby_road_random_radius" }, "",
    0, 50000, 10000, 500, function(value)
        nearby_road.random_radius = value * 0.01
    end)

menu.toggle(Nearby_Road, "生成载具: 无敌", {}, "", function(toggle)
    nearby_road.godmode = toggle
end, true)
menu.toggle(Nearby_Road, "生成载具: 强化", {}, "", function(toggle)
    nearby_road.strong = toggle
end, true)
menu.toggle(Nearby_Road, "生成载具: 闪烁标记点", {}, "", function(toggle)
    nearby_road.flash_blip = toggle
end)
menu.slider(Nearby_Road, "生成载具数量", { "nearby_road_random_num" }, "",
    1, 20, 1, 1, function(value)
        nearby_road.num = value
    end)

menu.divider(Nearby_Road, "载具列表")

for _, data in pairs(Vehicle_Common) do
    local name = "生成 " .. data.name
    local hash = util.joaat(data.model)
    menu.action(Nearby_Road, name, {}, data.help_text, function()
        local num = 0
        request_model(hash)

        for i = 1, nearby_road.num do
            local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
            local bool, coords, heading = false, pos, 0

            if nearby_road.nodeType == 3 then
                bool, coords = get_random_vehicle_node(pos, nearby_road.random_radius)
            else
                bool, coords, heading = get_closest_vehicle_node(pos, nearby_road.nodeType)
            end

            if bool then
                local vehicle = entities.create_vehicle(hash, coords, heading)
                if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
                    VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, false)
                    VEHICLE.SET_VEHICLE_DIRT_LEVEL(vehicle, 0.0)
                    VEHICLE.SET_VEHICLE_HAS_BEEN_OWNED_BY_PLAYER(vehicle, true)
                    VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(vehicle, 5.0)

                    upgrade_vehicle(vehicle)
                    set_entity_godmode(vehicle, nearby_road.godmode)
                    if nearby_road.strong then
                        strong_vehicle(vehicle)
                    end

                    if nearby_road.flash_blip then
                        SHOW_BLIP_TIMER(vehicle, 225, 27, 5000)
                    end

                    num = num + 1
                end
            end
        end

        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
        util.toast("完成！\n生成数量: " .. num)
    end)
end

--#endregion




menu.click_slider(Mission_Options, "增加任务生命数", { "team_lives" }, "只有是战局主机时才会生效(?)",
    -1, 30000, 0, 1, function(value)
        if IS_SCRIPT_RUNNING("fm_mission_controller") then
            SET_INT_LOCAL("fm_mission_controller", Locals.MC_TLIVES, value)
        elseif IS_SCRIPT_RUNNING("fm_mission_controller_2020") then
            SET_INT_LOCAL("fm_mission_controller_2020", Locals.MC_TLIVES_2020, value)
        else
            util.toast("未进行任务")
        end
    end)
menu.action(Mission_Options, "跳过破解", { "skip_hacking" }, "所有的破解、骇入、钻孔等等", function()
    local script = "fm_mission_controller_2020"
    if IS_SCRIPT_RUNNING(script) then
        -- Skip The Hacking Process
        if GET_INT_LOCAL(script, 23669) == 4 then
            SET_INT_LOCAL(script, 23669, 5)
        end
        -- Skip Cutting The Sewer Grill
        if GET_INT_LOCAL(script, 28446) == 4 then
            SET_INT_LOCAL(script, 28446, 6)
        end
        -- Skip Cutting The Glass
        SET_FLOAT_LOCAL(script, 29685 + 3, 100)

        SET_INT_LOCAL(script, 975 + 135, 3) -- For ULP Missions
    end

    script = "fm_mission_controller"
    if IS_SCRIPT_RUNNING(script) then
        -- For Fingerprint
        if GET_INT_LOCAL(script, 52964) ~= 1 then
            SET_INT_LOCAL(script, 52964, 5)
        end
        -- For Keypad
        if GET_INT_LOCAL(script, 54026) ~= 1 then
            SET_INT_LOCAL(script, 54026, 5)
        end
        -- Skip Drilling The Vault Door
        local Value = GET_INT_LOCAL(script, 10101 + 37)
        SET_INT_LOCAL(script, 10101 + 7, Value)

        -- Doomsday Heist
        SET_INT_LOCAL(script, 1509, 3)       -- For ACT I, Setup: Server Farm (Lester)
        SET_INT_LOCAL(script, 1540, 2)
        SET_INT_LOCAL(script, 1266 + 135, 3) -- For ACT III

        -- Fleeca Heist
        SET_INT_LOCAL(script, 11760 + 24, 7)     -- Skip The Hacking Process
        SET_FLOAT_LOCAL(script, 10061 + 11, 100) -- Skip Drilling

        -- Pacific Standard Heist
        SET_LOCAL_BIT(script, 9767, 9) -- Skip The Hacking Process
    end
end)
menu.toggle_loop(Mission_Options, "Voltage Hack", { "voltage_hack" }, "", function()
    local script = "fm_mission_controller_2020"
    if IS_SCRIPT_RUNNING(script) then
        -- Voltage Hack
        local Value = GET_INT_LOCAL(script, 1719)
        SET_INT_LOCAL(script, 1718, Value)
    end
end)
menu.action(Mission_Options, "警局楼顶 生成直升机", {}, "", function()
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

        SET_ENTITY_HEALTH(veh, 10000)
        ENTITY.SET_ENTITY_MAX_HEALTH(veh, 10000)
        strong_vehicle(veh)
    end

    util.toast("完成！")
end)

menu.click_slider(Mission_Options, "[TEST]增加任务生命数", {}, "会请求成为任务脚本主机",
    -1, 30000, 0, 1, function(value)
        local script = 0
        local addr = 0
        if IS_SCRIPT_RUNNING("fm_mission_controller") then
            script = "fm_mission_controller"
            addr = Locals.MC_TLIVES
        end
        if IS_SCRIPT_RUNNING("fm_mission_controller_2020") then
            script = "fm_mission_controller_2020"
            addr = Locals.MC_TLIVES_2020
        end
        if script == 0 then
            util.toast("未进行任务")
            return
        end

        util.request_script_host(script)
        SET_INT_LOCAL(script, addr, value)
        -- local host1 = NETWORK.NETWORK_GET_HOST_OF_SCRIPT(script, -1, 0)
        -- local host2 = NETWORK.NETWORK_GET_HOST_OF_SCRIPT(script, 0, 0)
    end)

Transition_Handler.traffic_density.sphere_id = -1
Transition_Handler.traffic_density.callback = function()
    Transition_Handler.traffic_density.sphere_id = MISC.ADD_POP_MULTIPLIER_SPHERE(1.1, 1.1, 1.1, 15000.0,
        0.0, 0.0, false, true)
    --MISC.CLEAR_AREA(1.1, 1.1, 1.1, 19999.9, true, false, false, true)
end
menu.toggle(Mission_Options, "清空交通人口密度", {}, "", function(toggle)
    Transition_Handler.traffic_density.toggle = toggle
    if toggle then
        Transition_Handler.traffic_density.callback()
    else
        MISC.REMOVE_POP_MULTIPLIER_SPHERE(Transition_Handler.traffic_density.sphere_id, false)
    end
end)



menu.divider(Mission_Options, "")

---------------------
-- 抢劫分红编辑
---------------------
local Heist_Cut_Editor = menu.list(Mission_Options, "抢劫分红编辑", {}, "")

local HeistCut = {
    ListItem = {
        { "佩里科岛" },
        { "赌场抢劫" },
        { "末日豪劫" },
    },
    ValueList = {
        1978495 + 825 + 56,
        1971696 + 2325,
        1967630 + 812 + 50,
    },
    NonHost = 2684820 + 6606,
}

local cut_global_base = HeistCut.ValueList[1]
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
menu.divider(Heist_Cut_Editor, "")
menu.click_slider(Heist_Cut_Editor, "自己 (非主机)", { "cutmyselfedit" }, "", 0, 300, 85, 5, function(value)
    SET_INT_GLOBAL(HeistCut.NonHost, value)
end)



--#region Heist Prep Editor

---------------------
-- 抢劫前置编辑
---------------------
local Heist_Prep_Editor = menu.list(Mission_Options, "抢劫前置编辑[TEST]", {}, "")

---------------
-- 赌场抢劫
---------------
local Casion_Heist = menu.list(Heist_Prep_Editor, "赌场抢劫", {}, "")

local casion_heist = {
    optional = {
        bitset0 = 0,
        menu_input = nil,
        menu_list = {},
    },
}

menu.divider(Casion_Heist, "第二面板")
local Casion_Heist_Optional = menu.list(Casion_Heist, "自定义可选任务", {}, "")

menu.action(Casion_Heist_Optional, "读取 H3OPT_BITSET0", {}, "", function()
    local value = STAT_GET_INT("H3OPT_BITSET0")
    menu.set_value(casion_heist.optional.menu_input, value)
    util.toast(value)
end)
casion_heist.optional.menu_input = menu.slider(Casion_Heist_Optional, "H3OPT_BITSET0", { "CH_H3OPT_BITSET0" }, "",
    0, 16777216, 0, 1, function(value)
        casion_heist.optional.bitset0 = value
    end)
menu.action(Casion_Heist_Optional, "解析 H3OPT_BITSET0", {}, "", function()
    local value = casion_heist.optional.bitset0

    for _, command in pairs(casion_heist.optional.menu_list) do
        menu.set_value(command, false)
    end

    for bit, bin in pairs(decimal_to_binary(value)) do
        bit = bit - 1
        if bin == 1 then
            local command = casion_heist.optional.menu_list[bit]
            if command ~= nil and menu.is_ref_valid(command) then
                menu.set_value(command, true)
            end
        end
    end
end)
menu.action(Casion_Heist_Optional, "写入 H3OPT_BITSET0", {}, "", function()
    STAT_SET_INT("H3OPT_BITSET0", casion_heist.optional.bitset0)
    util.toast("已将 H3OPT_BITSET0 修改为: " .. casion_heist.optional.bitset0)
end)

menu.divider(Casion_Heist_Optional, "任务列表")

local Casion_Heist_Optional_Preps_ListData = {
    { menu = "toggle", name = "Support Crew Selected [必选]", bit = 0, help_text = "" },
    { menu = "toggle", name = "巡逻路线", bit = 1, help_text = "" },
    { menu = "toggle", name = "杜根货物", bit = 2, help_text = "是否会显示对钩而已" },
    { menu = "toggle", name = "电钻", bit = 4, help_text = "" },
    { menu = "toggle", name = "枪手诱饵", bit = 6, help_text = "" },
    { menu = "toggle", name = "更换载具", bit = 7, help_text = "" },
    { menu = "divider", name = "隐迹潜踪" },
    { menu = "toggle", name = "潜入套装", bit = 3, help_text = "" },
    { menu = "toggle", name = "电磁脉冲设备", bit = 5, help_text = "" },
    { menu = "divider", name = "兵不厌诈" },
    { menu = "toggle", name = "进场: 除虫大师1", bit = 8, help_text = "" },
    { menu = "toggle", name = "进场: 除虫大师2", bit = 9, help_text = "" },
    { menu = "toggle", name = "进场: 维修工1", bit = 10, help_text = "" },
    { menu = "toggle", name = "进场: 维修工2", bit = 11, help_text = "" },
    { menu = "toggle", name = "进场: 古倍科技1", bit = 12, help_text = "" },
    { menu = "toggle", name = "进场: 古倍科技2", bit = 13, help_text = "" },
    { menu = "toggle", name = "进场: 名人1", bit = 14, help_text = "" },
    { menu = "toggle", name = "进场: 名人2", bit = 15, help_text = "" },
    { menu = "toggle", name = "离场: 国安局", bit = 16, help_text = "" },
    { menu = "toggle", name = "离场: 消防员", bit = 17, help_text = "" },
    { menu = "toggle", name = "离场: 豪赌客", bit = 18, help_text = "" },
    { menu = "divider", name = "气势汹汹" },
    { menu = "toggle", name = "镗床", bit = 19, help_text = "" },
    { menu = "toggle", name = "加固防弹衣", bit = 20, help_text = "" },
}
for k, item in pairs(Casion_Heist_Optional_Preps_ListData) do
    if item.menu == "toggle" then
        local menu_toggle = menu.toggle(Casion_Heist_Optional, item.name, {}, item.help_text,
            function(toggle, click_type)
                if click_type ~= CLICK_SCRIPTED then
                    local value = casion_heist.optional.bitset0
                    if toggle then
                        value = value + (1 << item.bit)
                    else
                        value = value - (1 << item.bit)
                    end
                    menu.set_value(casion_heist.optional.menu_input, value)
                end
            end)

        casion_heist.optional.menu_list[item.bit] = menu_toggle
    else
        menu.divider(Casion_Heist_Optional, item.name)
    end
end


---------------
-- 末日豪劫
---------------
local Doomsday_Heist = menu.list(Heist_Prep_Editor, "末日豪劫", {}, "")

local doomsday_heist = {
    prep = {
        gangops_fm = 0,
        menu_input = nil,
        menu_list = {},
        list_data = {
            { menu = "divider", name = "末日一: 数据泄露" },
            { menu = "toggle", name = "医疗装备", bit = 0, help_text = "" },
            { menu = "toggle", name = "德罗索", bit = 1, help_text = "" },
            { menu = "toggle", name = "阿库拉", bit = 2, help_text = "" },
            { menu = "divider", name = "末日二: 博格丹危机" },
            { menu = "toggle", name = "钥匙卡", bit = 3, help_text = "" },
            { menu = "toggle", name = "ULP情报", bit = 4, help_text = "" },
            { menu = "toggle", name = "防暴车", bit = 5, help_text = "" },
            { menu = "toggle", name = "斯特龙伯格", bit = 6, help_text = "" },
            { menu = "toggle", name = "鱼雷电控单元", bit = 7, help_text = "" },
            { menu = "divider", name = "末日三: 末日将至" },
            { menu = "toggle", name = "标记资金", bit = 8, help_text = "" },
            { menu = "toggle", name = "侦察", bit = 9, help_text = "" },
            { menu = "toggle", name = "切尔诺伯格", bit = 10, help_text = "" },
            { menu = "toggle", name = "飞行路线", bit = 11, help_text = "" },
            { menu = "toggle", name = "试验场情报", bit = 12, help_text = "" },
            { menu = "toggle", name = "机载电脑", bit = 13, help_text = "" },
        },
    },

    setup = {
        gangops_flow = 0,
        menu_input = nil,
        menu_list = {},
        list_data = {
            { menu = "divider", name = "末日一: 数据泄露" },
            { menu = "toggle", name = "亡命速递", bit = 0, help_text = "" },
            { menu = "toggle", name = "拦截信号", bit = 1, help_text = "" },
            { menu = "toggle", name = "服务器群组", bit = 2, help_text = "" },
            { menu = "divider", name = "末日二: 博格丹危机" },
            { menu = "toggle", name = "复仇者", bit = 4, help_text = "" },
            { menu = "toggle", name = "营救ULP", bit = 5, help_text = "" },
            { menu = "toggle", name = "抢救硬盘", bit = 6, help_text = "" },
            { menu = "toggle", name = "潜水艇侦察", bit = 7, help_text = "" },
            { menu = "divider", name = "末日三: 末日将至" },
            { menu = "toggle", name = "营救14号探员", bit = 9, help_text = "" },
            { menu = "toggle", name = "护送ULP探员", bit = 10, help_text = "" },
            { menu = "toggle", name = "巴拉杰", bit = 11, help_text = "" },
            { menu = "toggle", name = "可汗贾利", bit = 12, help_text = "" },
            { menu = "toggle", name = "空中防御", bit = 13, help_text = "" },
        },
    }
}

local Doomsday_Heist_Preps = menu.list(Doomsday_Heist, "前置任务", {}, "")

menu.action(Doomsday_Heist_Preps, "读取 GANGOPS_FM_MISSION_PROG", {}, "", function()
    local value = STAT_GET_INT("GANGOPS_FM_MISSION_PROG")
    menu.set_value(doomsday_heist.prep.menu_input, value)
    util.toast(value)
end)
doomsday_heist.prep.menu_input = menu.slider(Doomsday_Heist_Preps, "GANGOPS_FM 值", { "doomsday_heist_gangops_fm" }, "",
    0, 16777216, 0, 1, function(value)
        doomsday_heist.prep.gangops_fm = value
    end)
menu.action(Doomsday_Heist_Preps, "解析当前 GANGOPS_FM 值", {}, "", function()
    local value = doomsday_heist.prep.gangops_fm

    for _, command in pairs(doomsday_heist.prep.menu_list) do
        menu.set_value(command, false)
    end

    for bit, bin in pairs(decimal_to_binary(value)) do
        bit = bit - 1
        if bin == 1 then
            local command = doomsday_heist.prep.menu_list[bit]
            if command ~= nil and menu.is_ref_valid(command) then
                menu.set_value(command, true)
            end
        end
    end
end)
menu.action(Doomsday_Heist_Preps, "写入 GANGOPS_FM_MISSION_PROG", {}, "", function()
    STAT_SET_INT("GANGOPS_FM_MISSION_PROG", doomsday_heist.prep.gangops_fm)
    util.toast("已将 GANGOPS_FM_MISSION_PROG 修改为: " .. doomsday_heist.prep.gangops_fm)
end)

-- 任务列表
for k, item in pairs(doomsday_heist.prep.list_data) do
    if item.menu == "toggle" then
        local menu_toggle = menu.toggle(Doomsday_Heist_Preps, item.name, {}, item.help_text, function(toggle, click_type)
            if click_type ~= CLICK_SCRIPTED then
                local value = doomsday_heist.prep.gangops_fm
                if toggle then
                    value = value + (1 << item.bit)
                else
                    value = value - (1 << item.bit)
                end
                menu.set_value(doomsday_heist.prep.menu_input, value)
            end
        end)

        doomsday_heist.prep.menu_list[item.bit] = menu_toggle
    else
        menu.divider(Doomsday_Heist_Preps, item.name)
    end
end


local Doomsday_Heist_Setups = menu.list(Doomsday_Heist, "准备任务", {}, "")

menu.action(Doomsday_Heist_Setups, "读取 GANGOPS_FLOW_MISSION_PROG", {}, "", function()
    local value = STAT_GET_INT("GANGOPS_FLOW_MISSION_PROG")
    menu.set_value(doomsday_heist.setup.menu_input, value)
    util.toast(value)
end)
doomsday_heist.setup.menu_input = menu.slider(Doomsday_Heist_Setups, "GANGOPS_FLOW 值",
    { "doomsday_heist_gangops_flow" }, "", 0, 16777216, 0, 1, function(value)
        doomsday_heist.setup.gangops_flow = value
    end)
menu.action(Doomsday_Heist_Setups, "解析当前 GANGOPS_FM 值", {}, "", function()
    local value = doomsday_heist.setup.gangops_flow

    for _, command in pairs(doomsday_heist.setup.menu_list) do
        menu.set_value(command, false)
    end

    for bit, bin in pairs(decimal_to_binary(value)) do
        bit = bit - 1
        if bin == 1 then
            local command = doomsday_heist.setup.menu_list[bit]
            if command ~= nil and menu.is_ref_valid(command) then
                menu.set_value(command, true)
            end
        end
    end
end)
menu.action(Doomsday_Heist_Setups, "写入 GANGOPS_FLOW_MISSION_PROG", {}, "", function()
    STAT_SET_INT("GANGOPS_FLOW_MISSION_PROG", doomsday_heist.setup.gangops_flow)
    util.toast("已将 GANGOPS_FLOW_MISSION_PROG 修改为: " .. doomsday_heist.setup.gangops_flow)
end)

-- 任务列表
for k, item in pairs(doomsday_heist.setup.list_data) do
    if item.menu == "toggle" then
        local menu_toggle = menu.toggle(Doomsday_Heist_Setups, item.name, {}, item.help_text,
            function(toggle, click_type)
                if click_type ~= CLICK_SCRIPTED then
                    local value = doomsday_heist.setup.gangops_flow
                    if toggle then
                        value = value + (1 << item.bit)
                    else
                        value = value - (1 << item.bit)
                    end
                    menu.set_value(doomsday_heist.setup.menu_input, value)
                end
            end)

        doomsday_heist.setup.menu_list[item.bit] = menu_toggle
    else
        menu.divider(Doomsday_Heist_Setups, item.name)
    end
end

--#endregion
