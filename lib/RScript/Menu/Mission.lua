------------------------------------------
--          Mission Options
------------------------------------------


local Mission_Options <const> = menu.list(Menu_Root, "任务选项", {}, "")


----------------------------------
--      Property Mission
----------------------------------

local Property_Mission <const> = menu.list(Mission_Options, "资产任务", {}, "")


--------------------------
--  Special Cargo
--------------------------

local Special_Cargo <const> = menu.list(Property_Mission, "特种货物", {}, "")


--#region Special Cargo Tool

local Special_Cargo_Tool <const> = menu.list(Special_Cargo, "工具", {}, "")

--#endregion


menu.action(Special_Cargo, "传送到 特种货物", { "tp_cargo" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(478)
    if HUD.DOES_BLIP_EXIST(blip) then
        local coords = HUD.GET_BLIP_COORDS(blip)
        teleport2(coords.x, coords.y, coords.z + 1.0)
    end
end)
menu.action(Special_Cargo, "特种货物 传送到我", { "tpme_cargo" }, "", function()
    local entity_list = get_mission_pickups("gb_contraband_buy")
    if next(entity_list) ~= nil then
        OBJECT.SET_MAX_NUM_PORTABLE_PICKUPS_CARRIED_BY_PLAYER(ENTITY.GET_ENTITY_MODEL(entity_list[1]), 3)
        for _, ent in pairs(entity_list) do
            tp_pickup_to_me(ent)
        end
    else
        local blip = HUD.GET_NEXT_BLIP_INFO_ID(478)
        if HUD.DOES_BLIP_EXIST(blip) then
            local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                set_entity_heading_to_entity(ent, players.user_ped())
                tp_entity_to_me(ent)

                if ENTITY.IS_ENTITY_A_VEHICLE(ent) then
                    tp_into_vehicle(ent, "delete", "delete")
                end
            else
                util.toast("目标不是实体，无法传送到我")
            end
        end
    end
end)
menu.action(Special_Cargo, "特种货物(载具) 传送到我", {}, "Trackify追踪的车", function()
    local entity_list = get_mission_entities_by_hash(ENTITY_OBJECT, "gb_contraband_buy", -1322183878, -2022916910) -- 车里的货物
    if next(entity_list) == nil then
        return
    end

    for _, ent in pairs(entity_list) do
        if ENTITY.IS_ENTITY_ATTACHED(ent) then
            local attached_ent = ENTITY.GET_ENTITY_ATTACHED_TO(ent)
            if ENTITY.IS_ENTITY_A_VEHICLE(attached_ent) then
                tp_vehicle_to_me(attached_ent, "delete", "delete")
            end
        end
    end
end)

menu.divider(Special_Cargo, "")

menu.action(Special_Cargo, "传送到 仓库助理", { "tp_cargo_assistant" }, "让他去拉货", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(480)
    if HUD.DOES_BLIP_EXIST(blip) then
        local coords = HUD.GET_BLIP_COORDS(blip)
        teleport2(coords.x - 1.0, coords.y, coords.z)
    end
end)

local special_cargo_lupe_menu
special_cargo_lupe_menu = menu.list_action(Special_Cargo, "卢佩: 传送到 水下货箱", {}, "",
    { { -1, "刷新货箱列表" } }, function(value)
        -- Hash: -1235210928(object) 水下要炸的货箱
        if value == -1 then
            --货箱里面 要拾取的包裹
            local water_cargo_hash_list = { 388143302, -36934887, 319657375, 924741338, -1249748547 }
            local list_item_data = { { -1, "刷新货箱列表" } }
            local i = 1

            for k, ent in pairs(entities.get_all_objects_as_handles()) do
                if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
                    local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
                    if table.contains(water_cargo_hash_list, EntityHash) then
                        table.insert(list_item_data, { ent, "货箱 " .. i })
                        i = i + 1
                    end
                end
            end

            menu.set_list_action_options(special_cargo_lupe_menu, list_item_data)
            util.toast("已刷新，请重新打开该列表")
        else
            local ent = value
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                if ENTITY.IS_ENTITY_ATTACHED(ent) then
                    local attached_ent = ENTITY.GET_ENTITY_ATTACHED_TO(ent)
                    tp_to_entity(attached_ent, 0.0, -2.5, 0.0)
                    set_entity_heading_to_entity(players.user_ped(), attached_ent)
                end
            end
        end
    end)



--------------------------
--  Bunker
--------------------------

local Bunker <const> = menu.list(Property_Mission, "地堡拉货", {}, "")


--#region Bunker Tool

local Bunker_Tool <const> = menu.list(Bunker, "工具", {}, "")


--#endregion


menu.action(Bunker, "传送到 原材料", { "tp_bk_supply" }, "", function()
    local blip1 = HUD.GET_NEXT_BLIP_INFO_ID(556)
    local blip2 = HUD.GET_NEXT_BLIP_INFO_ID(561)
    local blip3 = HUD.GET_NEXT_BLIP_INFO_ID(477)

    if HUD.DOES_BLIP_EXIST(blip1) then
        local coords = HUD.GET_BLIP_COORDS(blip1)
        teleport2(coords.x, coords.y + 2.0, coords.z + 1.0)
    elseif HUD.DOES_BLIP_EXIST(blip2) then
        local coords = HUD.GET_BLIP_COORDS(blip2)
        teleport2(coords.x, coords.y, coords.z + 1.0)
    elseif HUD.DOES_BLIP_EXIST(blip3) then
        local coords = HUD.GET_BLIP_COORDS(blip3)
        teleport2(coords.x, coords.y, coords.z + 1.0)
    end
end)
menu.action(Bunker, "原材料 传送到我", { "tpme_bk_supply" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(556)
    if not HUD.DOES_BLIP_EXIST(blip) then
        local entity_list = get_entities_by_hash(ENTITY_PICKUP, true, -955159266)
        if next(entity_list) ~= nil then
            for _, ent in pairs(entity_list) do
                tp_entity_to_me(ent)
            end
        end
    else
        local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            set_entity_heading_to_entity(ent, players.user_ped())
            tp_entity_to_me(ent)

            if ENTITY.IS_ENTITY_A_VEHICLE(ent) then
                tp_into_vehicle(ent, "delete", "delete")
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
    local entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, -32878452)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            ENTITY.FREEZE_ENTITY_POSITION(ent, true)
            tp_entity_to_me(ent, 0.0, 0.0, 10.0)
        end
    end
end)
menu.action(Bunker, "长鳍追飞机: 掉落货物 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, 91541528)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_entity_to_me(ent, 0.0, 0.0, 1.0)
        end
    end
end)
menu.action(Bunker, "长鳍追飞机: 炸掉长鳍", {},
    "不再等飞机慢慢地投放货物", function()
        local entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, 1861786828) --长鳍
        if next(entity_list) ~= nil then
            for _, ent in pairs(entity_list) do
                ENTITY.SET_ENTITY_INVINCIBLE(ent, false)
                local pos = ENTITY.GET_ENTITY_COORDS(ent)
                add_owned_explosion(players.user_ped(), pos)
            end
        end
    end)




--------------------------
--  Air Freight
--------------------------

local Air_Freight <const> = menu.list(Property_Mission, "机库拉货", {}, "")


--#region Air Freight Tool

local Air_Freight_Tool <const> = menu.list(Air_Freight, "工具", {}, "")

--#endregion


menu.action(Air_Freight, "传送到 货物", { "tp_air_product" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(568)
    if HUD.DOES_BLIP_EXIST(blip) then
        local coords = HUD.GET_BLIP_COORDS(blip)
        teleport2(coords.x, coords.y, coords.z + 1.0)
    end
end)
menu.action(Air_Freight, "货物 传送到我", { "tpme_air_product" },
    "提示已取得货物后就可以直接去机库送达货物", function()
        -- Pickup Hash: -1270906188, -204239524, 2085196638, 886033073, 1419829219, 1248987568, -2037094101, -49487954
        for _, ent in pairs(entities.get_all_pickups_as_handles()) do
            if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
                local entity_script = GET_ENTITY_SCRIPT(ent)
                if entity_script == "gb_smuggler" or entity_script == "fm_content_smuggler_resupply" then
                    tp_pickup_to_me(ent)
                end
            end
        end
    end)
menu.action(Air_Freight, "结束任务", {},
    "进入机库提示货物已送达后就可以直接结束任务", function()
        local script_list = {
            "gb_smuggler", "fm_content_smuggler_resupply"
        }
        for _, script_name in pairs(script_list) do
            SPOOF_SCRIPT(script_name, function(script)
                LOCAL_SET_INT(script, Locals[script].stModeTimer, 0)
            end)
        end
    end)

menu.divider(Air_Freight, "")
menu.action(Air_Freight, "陆地: 炸掉发电机", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, 209668540)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            local coords = ENTITY.GET_ENTITY_COORDS(ent)
            coords.z = coords.z + 1.0
            add_owned_explosion(players.user_ped(), coords, 4)
        end
    end
end)
menu.action(Air_Freight, "陆地: 传送到 释放开关", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, 162166615)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_to_entity(ent, 0.0, -0.5, 0.0)
            set_entity_heading_to_entity(players.user_ped(), ent)
        end
    end
end)
menu.action(Air_Freight, "陆地: 传送进 阿维萨", {}, "然后再传送到货物", function()
    local entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, -1706603682)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            PED.SET_PED_INTO_VEHICLE(players.user_ped(), ent, -1)
        end
    end
end)

menu.action(Air_Freight, "爆炸 所有敌对载具", {}, "", function()
    explode_hostile_vehicles()
end)
menu.action(Air_Freight, "爆炸 所有敌对NPC", {}, "", function()
    explode_hostile_peds()
end)
menu.action(Air_Freight, "爆炸 所有敌对物体", {}, "", function()
    explode_hostile_objects()
end)

menu.divider(Air_Freight, "")
menu.action(Air_Freight, "传送到 鲁斯特", {}, "让他去拉货", function()
    local entity_list = get_entities_by_hash(ENTITY_PED, true, 2086307585)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_to_entity(ent, 0.0, 1.0, 0.0)
            set_entity_heading_to_entity(players.user_ped(), ent, 180.0)
        end
    end
end)




--------------------------
--  Biker Factory
--------------------------

local Biker_Factory <const> = menu.list(Property_Mission, "摩托帮工厂", {}, "")


--#region Biker Factory Tool

local Biker_Factory_Tool <const> = menu.list(Biker_Factory, "工具", {}, "")

--#endregion


menu.action(Biker_Factory, "传送到 货物", { "tp_mc_product" }, "", function()
    local blip1 = HUD.GET_NEXT_BLIP_INFO_ID(501)
    local blip2 = HUD.GET_NEXT_BLIP_INFO_ID(64)
    local blip3 = HUD.GET_NEXT_BLIP_INFO_ID(427)
    local blip4 = HUD.GET_NEXT_BLIP_INFO_ID(423)

    if HUD.DOES_BLIP_EXIST(blip1) then
        local coords = HUD.GET_BLIP_COORDS(blip1)
        teleport2(coords.x, coords.y - 1.5, coords.z) --MC Product
    elseif HUD.DOES_BLIP_EXIST(blip2) then
        local coords = HUD.GET_BLIP_COORDS(blip2)
        teleport2(coords.x, coords.y - 1.5, coords.z) --Heli
    elseif HUD.DOES_BLIP_EXIST(blip3) then
        local coords = HUD.GET_BLIP_COORDS(blip3)
        teleport2(coords.x, coords.y, coords.z + 1.0) --Boat
    elseif HUD.DOES_BLIP_EXIST(blip4) then
        local coords = HUD.GET_BLIP_COORDS(blip4)
        teleport2(coords.x, coords.y + 1.5, coords.z - 1.0) --Plane
    end
end)
menu.action(Biker_Factory, "货物 传送到我", { "tpme_mc_product" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(501)
    if HUD.DOES_BLIP_EXIST(blip) then
        local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            set_entity_heading_to_entity(ent, players.user_ped())
            tp_entity_to_me(ent)

            if ENTITY.IS_ENTITY_A_VEHICLE(ent) then
                tp_into_vehicle(ent, "delete", "delete")
            end
        else
            util.toast("目标不是实体，无法传送到我")
        end
    end
end)
menu.action(Biker_Factory, "货物(载具) 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, 788248216)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            if ENTITY.IS_ENTITY_ATTACHED(ent) then
                local attached_ent = ENTITY.GET_ENTITY_ATTACHED_TO(ent)
                if ENTITY.IS_ENTITY_A_VEHICLE(attached_ent) then
                    tp_vehicle_to_me(attached_ent, "delete", "delete")
                end
            end
        end
    end
end)



--------------------------
--  Acid Lab
--------------------------

local Acid_Lab <const> = menu.list(Property_Mission, "致幻剂实验室", {}, "")


--#region Acid Lab Tool

local Acid_Lab_Tool <const> = menu.list(Acid_Lab, "工具", {}, "")

--#endregion


menu.action(Acid_Lab, "原材料 传送到我", {}, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(501)
    if HUD.DOES_BLIP_EXIST(blip) then
        local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            set_entity_heading_to_entity(ent, players.user_ped())
            tp_entity_to_me(ent)
        else
            util.toast("目标不是实体，无法传送到我")
        end
    end
end)
menu.action(Acid_Lab, "传送到 致幻剂实验室", {}, "送达原材料时", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(840)
    if HUD.DOES_BLIP_EXIST(blip) then
        if HUD.GET_BLIP_COLOUR(blip) == 60 then
            teleport(HUD.GET_BLIP_COORDS(blip))
        end
    end
end)

-- Hash: 1714593198 (pickup) 化学品泄漏
menu.divider(Acid_Lab, "")
menu.action(Acid_Lab, "农场: 拖拉机 传送到 原材料", {}, "会将玩家传送进拖拉机并且与拖车连接\n需要下车来踩点",
    function()
        local trailer = 0
        local tractor = 0

        local entity_list = get_entities_by_hash(ENTITY_PICKUP, true, 1375611915)
        if next(entity_list) ~= nil then
            for _, ent in pairs(entity_list) do
                if ENTITY.IS_ENTITY_ATTACHED(ent) then
                    trailer = ENTITY.GET_ENTITY_ATTACHED_TO(ent)
                end
            end
        end

        entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, -2076478498)
        if next(entity_list) ~= nil then
            tractor = entity_list[1]
        end

        if ENTITY.DOES_ENTITY_EXIST(trailer) and ENTITY.DOES_ENTITY_EXIST(tractor) then
            set_entity_heading_to_entity(tractor, trailer)
            tp_entity_to_entity(tractor, trailer, 0.0, 5.5, 0.0)

            SET_VEHICLE_ENGINE_ON(tractor, true)
            PED.SET_PED_INTO_VEHICLE(players.user_ped(), tractor, -1)
        end
    end)
menu.action(Acid_Lab, "仓库: 原材料 传送到 卡车", {}, "", function()
    if user_interior() == 289537 then
        local supply = 0
        local truck = 0

        local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, 414057361)
        if next(entity_list) ~= nil then
            supply = entity_list[1]
        end

        entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, 1945374990)
        if next(entity_list) ~= nil then
            truck = entity_list[1]
        end

        if ENTITY.DOES_ENTITY_EXIST(supply) and ENTITY.DOES_ENTITY_EXIST(truck) then
            tp_entity_to_entity(supply, truck, 0.0, -3.0, 0.0)
            set_entity_heading_to_entity(supply, truck, 90.0)
        end
    end
end)
menu.action(Acid_Lab, "仓库: 传送进 卡车", {}, "", function()
    if user_interior() == 289537 then
        local entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, 1945374990)
        if next(entity_list) ~= nil then
            for _, ent in pairs(entity_list) do
                tp_into_vehicle(ent)
            end
        end
    end
end)
menu.action(Acid_Lab, "仓库: 叉车 传送到 卡车后面", {}, "如果没有提示登上卡车\n会将玩家传送进叉车",
    function()
        if user_interior() == 289537 then
            local forklift = 0
            local truck = 0

            local entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, 1491375716)
            if next(entity_list) ~= nil then
                forklift = entity_list[1]
            end

            entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, 1945374990)
            if next(entity_list) ~= nil then
                truck = entity_list[1]
            end

            if ENTITY.DOES_ENTITY_EXIST(forklift) and ENTITY.DOES_ENTITY_EXIST(truck) then
                VEHICLE.SET_FORKLIFT_FORK_HEIGHT(forklift, 1.0)

                set_entity_heading_to_entity(forklift, truck)
                tp_entity_to_entity(forklift, truck, 0.0, -6.0, 0.0)

                SET_VEHICLE_ENGINE_ON(forklift, true)
                PED.SET_PED_INTO_VEHICLE(players.user_ped(), forklift, -1)
            end
        end
    end)
menu.action(Acid_Lab, "敌痛息仓库: 传送到 时间表", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, 623418081)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_to_entity(ent, 0.0, 0.0, 0.5)
        end
    end
end)
menu.action(Acid_Lab, "敌痛息仓库: 厢型车 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_PICKUP, true, 331463704)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            if ENTITY.IS_ENTITY_ATTACHED(ent) then
                local veh = ENTITY.GET_ENTITY_ATTACHED_TO(ent)
                if ENTITY.IS_ENTITY_A_VEHICLE(veh) then
                    tp_vehicle_to_me(veh, "delete", "delete")
                end
            end
        end
    end
end)
menu.action(Acid_Lab, "空投地点: 原材料 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, -1367041250)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            add_owned_explosion(players.user_ped(), ENTITY.GET_ENTITY_COORDS(ent))
        end
        util.yield(500)
    end

    entity_list = get_entities_by_hash(ENTITY_PICKUP, true, 1195735753)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_entity_to_me(ent)
        end
    end
end)

menu.divider(Acid_Lab, "出售货物")
menu.action(Acid_Lab, "致幻剂包裹 投进箱子", {}, "", function()
    local blip = HUD.GET_CLOSEST_BLIP_INFO_ID(1)
    if HUD.DOES_BLIP_EXIST(blip) then
        local coords = HUD.GET_BLIP_COORDS(blip)
        shoot_single_bullet(coords, coords,
            { weaponHash = 4159824478, owner = players.user_ped() })
    end
end)




----------------------------------
--    Preparation Mission
----------------------------------

local Preparation_Mission <const> = menu.list(Mission_Options, "前置任务", {}, "")

--#region Cayo Perico

local Cayo_Perico <const> = menu.list(Preparation_Mission, "佩里科岛抢劫", {}, "")

menu.action(Cayo_Perico, "传送到虎鲸 任务面板", { "tpinKosatka" },
    "需要提前叫出虎鲸", function()
        local blip = HUD.GET_NEXT_BLIP_INFO_ID(760)
        if user_interior() == 281345 or HUD.DOES_BLIP_EXIST(blip) then
            teleport2(1561.2369, 385.8771, -49.689915, 175.0001)
        else
            util.toast("未在地图上找到虎鲸")
        end
    end)
menu.action(Cayo_Perico, "传送到虎鲸 外面甲板", { "tpoutKosatka" },
    "需要提前叫出虎鲸", function()
        local blip = HUD.GET_NEXT_BLIP_INFO_ID(760)
        if HUD.DOES_BLIP_EXIST(blip) then
            local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
            tp_to_entity(ent, 0.0, 31.0, 4.0)
            set_entity_heading_to_entity(players.user_ped(), ent, 180)
        else
            util.toast("未在地图上找到虎鲸")
        end
    end)

menu.divider(Cayo_Perico, "侦查")
menu.action(Cayo_Perico, "传送进 梅杜莎", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, 1077420264)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            set_entity_godmode(ent, true)
            SET_VEHICLE_ENGINE_ON(ent, true)
            PED.SET_PED_INTO_VEHICLE(players.user_ped(), ent, -1)
        end
    end
end)
menu.action(Cayo_Perico, "传送到 信号塔", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, 1981815996)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_to_entity(ent, 0.0, -0.5, 0.5)
            set_entity_heading_to_entity(players.user_ped(), ent)
        end
    end
end)

menu.divider(Cayo_Perico, "前置")
menu.action(Cayo_Perico, "长鳍 传送到目的地", {}, "先传送到警局踩点\n获取包裹,传送到目的地并坐进卡车",
    function()
        local entity_list = get_entities_by_hash(ENTITY_PICKUP, true, 528555233)
        if next(entity_list) ~= nil then
            for _, ent in pairs(entity_list) do
                tp_pickup_to_me(ent, true)
            end
        end

        entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, -1649536104)
        if next(entity_list) ~= nil then
            local ent = entity_list[1]
            TP_ENTITY(ent, v3(-154.88900756836, -2663.2165527344, 5.9994849128723), 0)
            PED.SET_PED_INTO_VEHICLE(players.user_ped(), ent, -1)
        end
    end)
menu.action(Cayo_Perico, "传送到 保险箱密码", {}, "赌场别墅内的保安队长", function()
    local entity_list = get_entities_by_hash(ENTITY_PED, true, -1109568186)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_to_entity(ent, 0.0, 0.0, 0.5)
        end
    end
end)
menu.action(Cayo_Perico, "等离子切割枪 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_PICKUP, true, -802406134)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_entity_to_me(ent)
        end
    end
end)
menu.action(Cayo_Perico, "指纹复制器 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_PICKUP, true, 1506325614)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_entity_to_me(ent)
        end
    end
end)
menu.action(Cayo_Perico, "传送到 割据", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_PICKUP, true, 1871441709)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_to_entity(ent, 0.0, 1.5, 0.0)
            set_entity_heading_to_entity(players.user_ped(), ent, -180)
        end
    end
end)
menu.action(Cayo_Perico, "武器 传送到我", {}, "拾取后重新进入虎鲸，然后炸掉女武神", function()
    local entity_list = get_entities_by_hash(ENTITY_PICKUP, true, 1912600099)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_entity_to_me(ent)
        end
    end
end)
menu.action(Cayo_Perico, "武器 炸掉女武神", {}, "不再等它慢慢的飞", function()
    local entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, -1600252419)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            local pos = ENTITY.GET_ENTITY_COORDS(ent)
            add_owned_explosion(players.user_ped(), pos)
        end
    end
end)

menu.divider(Cayo_Perico, "")

menu.textslider(Cayo_Perico, "前置任务助手", {},
    "前置任务: 爆破弹,等离子切割枪,指纹复制器,武器(梅利威瑟)\n传送到我后重新进入虎鲸,会提示已送达前置装备\n然后结束任务,会提示任务已完成",
    { "传送到我", "结束任务" }, function(value)
        local script = "fm_content_island_heist"
        if not IS_SCRIPT_RUNNING(script) then
            return
        end

        if value == 1 then
            for _, pickup in pairs(get_mission_pickups(script)) do
                tp_pickup_to_me(pickup)
            end
        elseif value == 2 then
            SPOOF_SCRIPT(script, function()
                LOCAL_SET_INT(script, Locals[script].stModeTimer, 0)
            end)
        end
    end)

local Cayo_Perico_Preps <const> = menu.list(Cayo_Perico, "其它前置", {}, "")
menu.divider(Cayo_Perico_Preps, "载具: 虎鲸")
menu.action(Cayo_Perico_Preps, "传送到 潜水艇", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, -1428975160)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_to_entity(ent, -8.0, 0.0, 9.0)
        end
    end
end)
menu.action(Cayo_Perico_Preps, "传送到 声呐干扰器", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_PICKUP, true, -1106317414)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_to_entity(ent, 0.0, -0.5, 0.0)
            set_entity_heading_to_entity(players.user_ped(), ent)
        end
    end
end)

menu.divider(Cayo_Perico_Preps, "载具: 阿尔科诺斯特")
menu.action(Cayo_Perico_Preps, "传送到 笔记本电脑", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, 281564928)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_to_entity(ent, 0.0, -0.5, 0.0)
            set_entity_heading_to_entity(players.user_ped(), ent)
        end
    end
end)
menu.action(Cayo_Perico_Preps, "传送进 阿尔科诺斯特", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, -365873403)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_into_vehicle(ent)
        end
    end
end)

menu.divider(Cayo_Perico_Preps, "载具: 巡逻艇")
menu.action(Cayo_Perico_Preps, "传送进 巡逻艇", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, -276744698)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_into_vehicle(ent, "", "delete")
        end
    end
end)

local Cayo_Perico_Final <const> = menu.list(Cayo_Perico, "终章", {}, "")

menu.divider(Cayo_Perico_Final, "豪宅外")
menu.action(Cayo_Perico_Final, "信号塔 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, false, 1981815996)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            request_control(ent)
            tp_entity_to_me(ent, 0.0, 2.0, -1.0)
            set_entity_heading_to_entity(ent, players.user_ped())
        end
    end
end)
menu.action(Cayo_Perico_Final, "发电站 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, false, 1650252819)
    if next(entity_list) ~= nil then
        local x = 0.0
        for _, ent in pairs(entity_list) do
            request_control(ent)
            tp_entity_to_me(ent, x, 2.0, 0.5)
            set_entity_heading_to_entity(ent, players.user_ped())
            x = x + 1.5
        end
    end
end)
menu.action(Cayo_Perico_Final, "保安服 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, false, -1141961823)
    if next(entity_list) ~= nil then
        local x = 0.0
        for _, ent in pairs(entity_list) do
            request_control(ent)
            tp_entity_to_me(ent, x, 2.0, -0.5)
            x = x + 1.0
        end
    end
end)
menu.action(Cayo_Perico_Final, "螺旋切割器 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_PICKUP, false, -710382954)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            request_control(ent)
            tp_entity_to_me(ent, 0.0, 2.0, -0.5)
        end
    end
end)
menu.action(Cayo_Perico_Final, "抓钩 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_PICKUP, false, -1789904450)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            request_control(ent)
            tp_entity_to_me(ent, 0.0, 2.0, -0.5)
        end
    end
end)
menu.action(Cayo_Perico_Final, "运货卡车 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, 2014313426)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            request_control(ent)
            tp_vehicle_to_me(ent, "", "delete")
        end
    end
end)

menu.divider(Cayo_Perico_Final, "豪宅内")

local perico_gold_vault_menu
perico_gold_vault_menu = menu.list_action(Cayo_Perico_Final, "传送到 黄金", {}, "",
    { { -1, "刷新黄金列表" } }, function(value)
        if value == -1 then
            local list_item_data = { { -1, "刷新黄金列表" } }
            local i = 1

            for k, ent in pairs(entities.get_all_objects_as_handles()) do
                if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
                    local Hash = ENTITY.GET_ENTITY_MODEL(ent)
                    if Hash == -180074230 then
                        table.insert(list_item_data, { ent, "黄金 " .. i })
                        i = i + 1
                    end
                end
            end

            menu.set_list_action_options(perico_gold_vault_menu, list_item_data)
            util.toast("已刷新，请重新打开该列表")
        else
            local ent = value
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                tp_to_entity(ent, 0.0, -1.0, 0.0)
                set_entity_heading_to_entity(players.user_ped(), ent)
            end
        end
    end)

menu.action(Cayo_Perico_Final, "干掉主要目标玻璃柜、保险箱", {}, "会在豪宅外生成主要目标包裹",
    function()
        local entity_list = get_entities_by_hash(ENTITY_OBJECT, false, -1714533217, 1098122770) --玻璃柜、保险箱
        if next(entity_list) ~= nil then
            for _, ent in pairs(entity_list) do
                request_control(ent)
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
                request_control(ent)
                tp_entity_to_me(ent)
            end
        end
    end)
menu.action(Cayo_Perico_Final, "办公室保险箱 传送到我", {}, "保险箱门和里面的现金", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, false, 485111592) --保险箱
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            request_control(ent)
            tp_entity_to_me(ent, -0.5, 1.0, 0.0)
            set_entity_heading_to_entity(ent, players.user_ped(), 180.0)
        end
    end

    entity_list = get_entities_by_hash(ENTITY_PICKUP, false, -2143192170) --现金
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            request_control(ent)
            tp_entity_to_me(ent, 0.0, 1.0, 0.0)
        end
    end
end)

--#endregion


--#region Diamond Casino

local Diamond_Casino <const> = menu.list(Preparation_Mission, "赌场抢劫", {}, "")

menu.divider(Diamond_Casino, "侦查")
menu.action(Diamond_Casino, "保安 传送到我", {}, "骇入手机会直接完成", function()
    local script = "gb_casino_heist"
    if not IS_SCRIPT_RUNNING(script) then
        return
    end

    local entity_list = get_entities_by_hash(ENTITY_PED, true, -1094177627)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_entity_to_me(ent, 0.0, 2.0, 0.0)
        end

        LOCAL_SET_INT(script, Locals[script].iRangeHackingTime, 100000)
    end
end)
menu.textslider(Diamond_Casino, "赌场 传送到骇入位置", {}, "进入赌场后再传送", {
    "自动", "1", "2", "3", "4", "5"
}, function(value)
    local script = "gb_casino_heist"
    if not IS_SCRIPT_RUNNING(script) then
        return
    end
    if user_interior() ~= 275201 then
        return
    end

    local data = {
        [0] = { 1120.23, 226.79, -50.84 },
        [1] = { 1131.72, 280.61, -52.04 },
        [2] = { 1106.95, 261.03, -51.84 },
        [3] = { 1140.38, 240.97, -51.44 },
        [4] = { 1148.7, 242.61, -52.04 },
    }

    if value == 1 then
        value = LOCAL_GET_INT(script, Locals[script].iRandomModeInt1)
        if value then
            local pos = data[value]
            if pos then
                teleport2(pos[1], pos[2], pos[3])
            else
                util.toast("自动传送位置失败")
            end
        end
    else
        local pos = data[value - 2]
        teleport2(pos[1], pos[2], pos[3])
    end
end)

menu.divider(Diamond_Casino, "前置")

------------------------
-- 相同前置
------------------------

local Diamond_Casino_Preps <const> = menu.list(Diamond_Casino, "相同前置", {}, "")

menu.action(Diamond_Casino_Preps, "武器 传送到我", {}, "杀死/爆炸所有NPC", function()
    local entity_list = get_entities_by_hash(ENTITY_PICKUP, true, 798951501, -1628917549)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_pickup_to_me(ent)
        end
    end
end)
menu.action(Diamond_Casino_Preps, "载具: 天威 传送到我", {}, "天威 经典版", function()
    local entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, 931280609)
    if next(entity_list) ~= nil then
        tp_vehicle_to_me(entity_list[1], "", "delete")
    end
end)
menu.action(Diamond_Casino_Preps, "骇入设备: 门禁卡 传送到我", {}, "探员\n提前杀死所有NPC", function()
    local entity_list = get_entities_by_hash(ENTITY_PED, true, 1650288984, 2072724299)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_entity_to_me(ent, 0.0, 2.0, 0.0)
        end
    end
end)
menu.action(Diamond_Casino_Preps, "骇入设备 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_PICKUP, true, -155327337)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_entity_to_me(ent)
        end
    end
end)
menu.action(Diamond_Casino_Preps, "金库门禁卡: 狱警 传送到我", {}, "提前杀死所有NPC", function()
    local entity_list = get_entities_by_hash(ENTITY_PED, true, 1456041926)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_entity_to_me(ent, 0.0, 2.0, -0.5)
        end
    end
end)
menu.action(Diamond_Casino_Preps, "金库门禁卡: 保安 传送到我", {}, "提前杀死所有NPC\n直接搜查保安尸体，不用管地图红色标记点",
    function()
        local entity_list = get_entities_by_hash(ENTITY_PED, true, -1575488699, -1425378987)
        if next(entity_list) ~= nil then
            local x = 0.0
            for _, ent in pairs(entity_list) do
                tp_entity_to_me(ent, x, 2.0, 0.0)
                x = x + 1.0
            end
        end
    end)
menu.divider(Diamond_Casino_Preps, "可选任务")
menu.action(Diamond_Casino_Preps, "巡逻路线: 车 传送到我", {}, "在车后备箱里", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, 1265214509)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            if ENTITY.IS_ENTITY_ATTACHED(ent) then
                local attached_ent = ENTITY.GET_ENTITY_ATTACHED_TO(ent)
                set_entity_heading_to_entity(attached_ent, players.user_ped())
                tp_entity_to_me(attached_ent, 0.0, 4.0, -0.5)
            end
        end
    end
end)
menu.action(Diamond_Casino_Preps, "杜根货物 全部摧毁", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, -1671539132, 1747439474, 1448677353)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            VEHICLE.SET_VEHICLE_ENGINE_HEALTH(ent, -4000.0)
        end
    end
end)
menu.textslider(Diamond_Casino_Preps, "传送到 电钻", {}, "", { "1", "2", "车" }, function(value)
    local entity_list = get_entities_by_hash(ENTITY_PICKUP, true, -12990308)
    if next(entity_list) ~= nil then
        if value == 1 then
            tp_to_entity(entity_list[1], 0.0, 0.0, 0.5)
        elseif value == 2 then
            tp_to_entity(entity_list[2], 0.0, 0.0, 0.5)
        elseif value == 3 then
            local ent = entity_list[1]
            if ENTITY.IS_ENTITY_ATTACHED(ent) then
                local attached_ent = ENTITY.GET_ENTITY_ATTACHED_TO(ent)
                if ENTITY.IS_ENTITY_A_VEHICLE(attached_ent) then
                    tp_into_vehicle(attached_ent, "delete", "delete")
                end
            end
        end
    end
end)
menu.action(Diamond_Casino_Preps, "二级保安证: 传送到 尸体", {}, "医院里的泊车员尸体", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, 771433594)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_to_entity(ent, -1.0, 0.0, 0.0)
            set_entity_heading_to_entity(players.user_ped(), ent, -80.0)
        end
    end
end)
menu.action(Diamond_Casino_Preps, "二级保安证: 保安证 传送到我", {}, "找到那个NPC后才能传送\n一般是喝醉躺着的那个",
    function()
        local entity_list = get_entities_by_hash(ENTITY_PICKUP, true, -2018799718)
        if next(entity_list) ~= nil then
            for _, ent in pairs(entity_list) do
                tp_entity_to_me(ent)
            end
        end
    end)

------------------------
-- Silent & Sneaky
------------------------

local Diamond_Casino_Silent <const> = menu.list(Diamond_Casino, "隐迹潜踪", {}, "")

menu.action(Diamond_Casino_Silent, "无人机零件 传送到我", {}, "会先炸掉无人机，再传送掉落的零件",
    function()
        --Model Hash: 1657647215 纳米无人机 (object)
        --Model Hash: -1285013058 无人机炸毁后掉落的零件（pickup）
        local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, 1657647215)
        if next(entity_list) ~= nil then
            for _, ent in pairs(entity_list) do
                local pos = ENTITY.GET_ENTITY_COORDS(ent)
                add_owned_explosion(players.user_ped(), pos)
            end
        end
        util.yield(1500)
        entity_list = get_entities_by_hash(ENTITY_PICKUP, true, -1285013058)
        if next(entity_list) ~= nil then
            for _, ent in pairs(entity_list) do
                tp_entity_to_me(ent)
            end
        end
    end)
menu.action(Diamond_Casino_Silent, "金库激光器 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_PICKUP, true, 1953119208)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_entity_to_me(ent)
        end
    end
end)
menu.action(Diamond_Casino_Silent, "电磁脉冲: 运兵直升机 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, 1621617168)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_entity_to_me(ent, 0.0, 0.0, 30.0)
            tp_into_vehicle(ent)
            ENTITY.SET_ENTITY_INVINCIBLE(ent, true)
            VEHICLE.SET_HELI_BLADES_FULL_SPEED(ent)
        end
    end
end)
menu.action(Diamond_Casino_Silent, "电磁脉冲 传送到直升机挂钩位置", {}, "运兵直升机提前放下吊钩",
    function()
        local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, -1541347408)
        if next(entity_list) ~= nil then
            local veh = GET_VEHICLE_PED_IS_IN(players.user_ped())
            if veh ~= 0 and VEHICLE.DOES_CARGOBOB_HAVE_PICK_UP_ROPE(veh) then
                local pos = VEHICLE.GET_ATTACHED_PICK_UP_HOOK_POSITION(veh)
                for _, ent in pairs(entity_list) do
                    pos.z = pos.z + 1.0
                    TP_ENTITY(ent, pos)
                end
            end
        end
    end)
menu.action(Diamond_Casino_Silent, "潜行套装 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_PICKUP, true, -1496506919)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_entity_to_me(ent)
        end
    end
end)

------------------------
-- The Big Con
------------------------

local Diamond_Casino_BigCon <const> = menu.list(Diamond_Casino, "兵不厌诈", {}, "")

menu.action(Diamond_Casino_BigCon, "古倍科技套装 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_PICKUP, true, 1425667258)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_entity_to_me(ent)
        end
    end
end)
menu.action(Diamond_Casino_BigCon, "金库钻孔机 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_PICKUP, true, 415149220)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_entity_to_me(ent)
        end
    end
end)
menu.action(Diamond_Casino_BigCon, "国安局套装 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_PICKUP, true, -1713985235)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_entity_to_me(ent)
        end
    end
end)

------------------------
-- Aggressive
------------------------

local Diamond_Casino_Aggressive <const> = menu.list(Diamond_Casino, "气势汹汹", {}, "")

menu.action(Diamond_Casino_Aggressive, "热能炸药 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_PICKUP, true, -2043162923)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_entity_to_me(ent)
        end
    end
end)
menu.action(Diamond_Casino_Aggressive, "金库炸药 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_PICKUP, true, -681938663)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_entity_to_me(ent)
        end
    end
end)
menu.action(Diamond_Casino_Aggressive, "加固防弹衣 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_PICKUP, true, 1715697304)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_entity_to_me(ent)
        end
    end
end)
menu.action(Diamond_Casino_Aggressive, "加固防弹衣: 潜水套装 传送到我", {}, "人道实验室", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, 788248216)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_entity_to_me(ent)
        end
    end
end)


----------------
-- 终章
----------------

menu.divider(Diamond_Casino, "")
local Diamond_Casino_Final <const> = menu.list(Diamond_Casino, "终章", {}, "")

menu.divider(Diamond_Casino_Final, "赌场内")
menu.action(Diamond_Casino_Final, "传送到 小金库", {}, "", function()
    if INTERIOR.IS_INTERIOR_SCENE() then
        teleport2(2520.8645, -286.30685, -58.723007)
    end
end)

local casino_vault_trolley_menu
casino_vault_trolley_menu = menu.list_action(Diamond_Casino_Final, "金库内传送到 推车", {}, "",
    { { -1, "刷新推车列表" } }, function(value)
        if value == -1 then
            local list_item_data = { { -1, "刷新推车列表" } }
            local i = 1

            for k, ent in pairs(entities.get_all_objects_as_handles()) do
                if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
                    local Hash = ENTITY.GET_ENTITY_MODEL(ent)
                    if Hash == 412463629 or Hash == 1171655821 or Hash == 1401432049 then
                        table.insert(list_item_data, { ent, "推车 " .. i })
                        i = i + 1
                    end
                end
            end

            menu.set_list_action_options(casino_vault_trolley_menu, list_item_data)
            util.toast("已刷新，请重新打开该列表")
        else
            local ent = value
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                tp_to_entity(ent, 0.0, 0.0, 0.5)
            end
        end
    end)

--#endregion


--#region Contract Dre

local Contract_Dre <const> = menu.list(Preparation_Mission, "别惹德瑞", {}, "")

------------------------
-- Nightlife Leak
------------------------

menu.divider(Contract_Dre, "夜生活泄密")
menu.action(Contract_Dre, "夜总会: 传送到 录像带", {}, "", function()
    if user_interior() == 271617 then
        teleport2(-1617.9883, -3013.7363, -75.20509, 203.7907)
    end
end)
menu.action(Contract_Dre, "船坞: 传送到 游艇", {}, "不用去开船", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, 1321190118)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_to_entity(ent, 0.0, -2.0, 0.0)
        end
    end
end)
menu.action(Contract_Dre, "船坞: 传送到 证据", {}, "德瑞照片", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, -1702870637)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_to_entity(ent, 0.0, 0.0, 0.5)
        end
    end
end)
menu.action(Contract_Dre, "夜生活泄密: 传送到 抢夺电脑", {}, "", function()
    if user_interior() == 274689 then
        teleport2(944.01764, 7.9015555, 116.1642, 279.8804)
    end
end)

------------------------
-- High Society Leak
------------------------

menu.divider(Contract_Dre, "上流社会泄密")
menu.action(Contract_Dre, "乡村俱乐部: 门禁 传送到我", {}, "会先炸掉礼车,然后将车内NPC传送到我",
    function()
        local entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, -420911112)
        if next(entity_list) ~= nil then
            for _, ent in pairs(entity_list) do
                local pos = ENTITY.GET_ENTITY_COORDS(ent)
                add_owned_explosion(players.user_ped(), pos)
            end
        end
        util.yield(500)
        entity_list = get_entities_by_hash(ENTITY_PED, true, -912318012)
        if next(entity_list) ~= nil then
            for _, ent in pairs(entity_list) do
                tp_entity_to_me(ent, 0.0, 2.0, 0.0)
            end
        end
    end)
menu.action(Contract_Dre, "宾客名单: 传送到 律师", {}, "同时设置和NPC关系为友好,避免被误杀",
    function()
        local entity_list = get_entities_by_hash(ENTITY_PED, true, 600300561)
        if next(entity_list) ~= nil then
            for _, ent in pairs(entity_list) do
                tp_to_entity(ent, 0.0, 1.0, 0.0)
                PED.SET_PED_RELATIONSHIP_GROUP_HASH(ent, PED.GET_PED_RELATIONSHIP_GROUP_HASH(players.user_ped())) -- Like
            end
        end
    end)
menu.action(Contract_Dre, "上流社会泄密: 摧毁直升机", {}, "快速进入直升机坠落动画",
    function()
        local entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, 1075432268)
        if next(entity_list) ~= nil then
            for _, ent in pairs(entity_list) do
                VEHICLE.SET_VEHICLE_ENGINE_HEALTH(ent, -1000)

                local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ent, -1, false)
                if driver ~= 0 then
                    entities.delete(driver)
                end
            end
        end
    end)

------------------------
-- South Central Leak
------------------------

menu.divider(Contract_Dre, "南中心区泄密")
menu.action(Contract_Dre, "强化弗农", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_PED, true, -843935326)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            local weaponHash = util.joaat("WEAPON_SPECIALCARBINE")
            WEAPON.GIVE_WEAPON_TO_PED(ent, weaponHash, -1, false, true)
            WEAPON.SET_CURRENT_PED_WEAPON(ent, weaponHash, false)
            increase_ped_combat_ability(ent, true, false)
            increase_ped_combat_attributes(ent)
            util.toast("完成！")
        end
    end
end)
menu.action(Contract_Dre, "戴维斯: 传送到高空", {}, "用来甩掉摩托帮\n提前坐进厢型车,会冻结载具",
    function()
        local vehicle = entities.get_user_vehicle_as_handle()
        if vehicle ~= INVALID_GUID then
            ENTITY.FREEZE_ENTITY_POSITION(vehicle, true)

            local coords = ENTITY.GET_ENTITY_COORDS(vehicle)
            teleport2(coords.x, coords.y, 1600.0)
        end
    end)
menu.action(Contract_Dre, "巴勒帮: P 无敌", {}, "避免被误杀", function()
    local entity_list = get_entities_by_hash(ENTITY_PED, true, -616450833)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            set_entity_godmode(ent, true)
            util.toast("完成！")
        end
    end
end)
menu.action(Contract_Dre, "南中心区泄密: 底盘车 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, -1013450936)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_vehicle_to_me(ent, "", "tp")
            set_entity_godmode(ent, true)
        end
    end
end)

--#endregion Contract Dre


--#region LS Robbery

local LS_Robbery <const> = menu.list(Preparation_Mission, "改装铺合约", {}, "")

------------------------
-- Union Depository
------------------------

local LS_Robbery_UD <const> = menu.list(LS_Robbery, "联合储蓄", {}, "")

menu.divider(LS_Robbery_UD, "电梯钥匙")
menu.action(LS_Robbery_UD, "传送到 腐败商人", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_PED, true, 2093736314)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_to_entity(ent, 0.0, 0.0, 0.5)
        end
    end
end)
menu.divider(LS_Robbery_UD, "金库密码")
menu.action(LS_Robbery_UD, "坐进直升机并传送到目标载具上空", {},
    "会将目标载具传送到明显位置,设置外观为紫色", function()
        local heli, target_ped = 0, 0
        local entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, 353883353)
        if next(entity_list) ~= nil then
            heli = entity_list[1]
        end

        entity_list = get_entities_by_hash(ENTITY_PED, true, -1868718465)
        if next(entity_list) ~= nil then
            target_ped = entity_list[1]
        end

        if ENTITY.DOES_ENTITY_EXIST(heli) and ENTITY.DOES_ENTITY_EXIST(target_ped) then
            tp_into_vehicle(heli)
            VEHICLE.SET_HELI_BLADES_FULL_SPEED(heli)

            util.yield(500)

            local veh = PED.GET_VEHICLE_PED_IS_IN(target_ped, false)
            TP_ENTITY(veh, v3(52.6033, -614.41308, 31.0284), 247.0814)

            VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(veh, 255, 0, 255)
            VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(veh, 255, 0, 255)

            tp_to_entity(veh, 0.0, 0.0, 80.0)
        end
    end)
menu.click_slider(LS_Robbery_UD, "目标载具 传送到目的地", {}, "玩家自己也会跟着传送过去",
    1, 2, 1, 1, function(value)
        local entity_list = get_entities_by_hash(ENTITY_PED, true, -1868718465)
        if next(entity_list) ~= nil then
            local data = {
                { coords = v3(-1326.9161, -1026.7085, 7.1590), heading = 263.5850 },
                { coords = v3(-59.6748, 350.2671, 111.7699),   heading = 20.9717 },
            }
            local coords = data[value].coords
            local heading = data[value].heading

            for _, ent in pairs(entity_list) do
                local veh = PED.GET_VEHICLE_PED_IS_IN(ent, false)
                TP_ENTITY(veh, coords, heading)

                teleport2(coords.x, coords.y, coords.z + 80.0, heading)
            end
        end
    end)
menu.toggle_loop(LS_Robbery_UD, "指示 目标NPC位置", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_PED, true, -1868718465)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            draw_line_to_entity(ent)
        end
    end
end)

----------------------------
-- The Superdollar Deal
----------------------------

local LS_Robbery_TSD <const> = menu.list(LS_Robbery, "大钞交易", {}, "")

menu.divider(LS_Robbery_TSD, "追踪设备")
menu.action(LS_Robbery_TSD, "传送到 机动作战中心", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, 1502869817)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            if not ENTITY.IS_ENTITY_ATTACHED(ent) then
                tp_to_entity(ent, 5.0, 0.0, -1.0)
                set_entity_heading_to_entity(players.user_ped(), ent, 100)
            end
        end
    end
end)
menu.divider(LS_Robbery_TSD, "病毒软件")
menu.action(LS_Robbery_TSD, "黑客 传送到我", {}, "会传送到空中然后摔死", function()
    local entity_list = get_entities_by_hash(ENTITY_PED, true, -2039163396)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_entity_to_me(ent, 0.0, 2.0, 10.0)
        end
    end
end)
menu.action(LS_Robbery_TSD, "传送到 病毒软件", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_PICKUP, true, 1112175411)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_to_entity(ent, 0.0, 0.0, 0.5)
        end
    end
end)
menu.divider(LS_Robbery_TSD, "终章")
menu.action(LS_Robbery_TSD, "运输载具 传送到我前面", {}, "前面要预留足够的位置\n提前杀死所有NPC",
    function()
        local ent = get_entity_from_blip(HUD.GET_NEXT_BLIP_INFO_ID(564))
        if ent ~= 0 then
            set_entity_heading_to_entity(ent, players.user_ped())
            tp_entity_to_me(ent, 0.0, 14.0, 0.5)
        end
    end)
menu.action(LS_Robbery_TSD, "军备箱 传送到我", {}, "会堆在一起", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, -680801934)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            set_entity_heading_to_entity(ent, players.user_ped(), 0.0)
            tp_entity_to_me(ent, 0.0, 2.0, -0.5)
        end
    end
end)

------------------------
-- The Bank Contract
------------------------

local LS_Robbery_TBC <const> = menu.list(LS_Robbery, "银行合约", {}, "")

menu.divider(LS_Robbery_TBC, "信号干扰器")
menu.textslider_stateful(LS_Robbery_TBC, "传送到", {}, "", {
    "A", "B", "C", "D", "E", "F"
}, function(value)
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(534 + value)
    if HUD.DOES_BLIP_EXIST(blip) then
        local coords = HUD.GET_BLIP_COORDS(blip)
        local heading = HUD.GET_BLIP_ROTATION(blip)
        teleport2(coords.x, coords.y, coords.z + 0.5, heading)
    end
end)
menu.divider(LS_Robbery_TBC, "终章")
local LS_Robbery_TBC_bank = 1
menu.list_select(LS_Robbery_TBC, "选择银行", {}, "先传送银行踩点后再传送到金库", {
    { 1, "A" }, { 2, "B" }, { 3, "C" }, { 4, "D" }, { 5, "E" }, { 6, "F" }
}, 1, function(value)
    LS_Robbery_TBC_bank = value
end)
menu.action(LS_Robbery_TBC, "传送到 银行", {}, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(534 + LS_Robbery_TBC_bank)
    if HUD.DOES_BLIP_EXIST(blip) then
        local coords = HUD.GET_BLIP_COORDS(blip)
        local heading = HUD.GET_BLIP_ROTATION(blip)
        teleport2(coords.x, coords.y, coords.z + 0.5, heading)
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
    teleport2(coords[1], coords[2], coords[3], heading)
end)
menu.action(LS_Robbery_TBC, "删除 银行金库铁门", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, false, -1591004109)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            entities.delete(ent)
        end
    end
end)

------------------------
-- The ECU Job
------------------------

local LS_Robbery_TEJ <const> = menu.list(LS_Robbery, "电控单元差事", {}, "")

menu.divider(LS_Robbery_TEJ, "火车货运清单")
menu.action(LS_Robbery_TEJ, "传送到 集装箱清单", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, -1398142754)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_to_entity(ent, 0.0, 0.0, 0.5)
        end
    end
end)
menu.action(LS_Robbery_TEJ, "传送到 切割锯", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_PICKUP, true, 339736694)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_to_entity(ent, 0.0, 0.0, 0.5)
        end
    end
end)
menu.divider(LS_Robbery_TEJ, "终章")
menu.action(LS_Robbery_TEJ, "爆炸 刹车气缸", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, 897163609)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            local coords = ENTITY.GET_ENTITY_COORDS(ent)
            add_owned_explosion(players.user_ped(), coords, 4)
        end
    end
end)
menu.action(LS_Robbery_TEJ, "电控单元 传送到我", {}, "需要动一下来确保拾取到", function()
    local entity_list = get_entities_by_hash(ENTITY_PICKUP, true, 92049373)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_entity_to_me(ent)
        end
    end
end)

--------------------------
-- The Prison Contract
--------------------------

local LS_Robbery_TPC <const> = menu.list(LS_Robbery, "监狱合约", {}, "")

menu.divider(LS_Robbery_TPC, "卧底")
menu.action(LS_Robbery_TPC, "传送到 警局", {}, "直接让他自首,然后回改装铺", function()
    teleport2(408.9833374, -983.469726, 28.99933374, 359.554412)
end)
menu.divider(LS_Robbery_TPC, "入口")
menu.action(LS_Robbery_TPC, "传送到 拖车", {}, "坐进卡车并连接拖车", function()
    local entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, 1518533038)
    if next(entity_list) ~= nil then
        local hauler = entity_list[1]
        TP_ENTITY(hauler, v3(-1079.2828369141, -482.62564086914, 36.821292877197), 178.14994812012)

        tp_into_vehicle(hauler)
    end
end)
menu.divider(LS_Robbery_TPC, "终章")
menu.action(LS_Robbery_TPC, "小迪 传送到我", {}, "会传送进正在使用的载具", function()
    local entity_list = get_entities_by_hash(ENTITY_PED, true, -938608286)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            local veh = entities.get_user_vehicle_as_handle(false)
            if veh ~= INVALID_GUID then
                PED.SET_PED_INTO_VEHICLE(ent, veh, -2)
            else
                tp_entity_to_me(ent, 0.0, 0.0, 2.0)
            end
        end
    end
end)

------------------------
-- The Agency Deal
------------------------

local LS_Robbery_TAD <const> = menu.list(LS_Robbery, "IAA 交易", {}, "")

menu.divider(LS_Robbery_TAD, "入口")
menu.action(LS_Robbery_TAD, "传送到 图纸", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, 429364207)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_to_entity(ent, 0.0, 0.0, 0.5)
        end
    end
end)
menu.action(LS_Robbery_TAD, "传送到 地下入口", {}, "", function()
    teleport2(139.130081, -608.175415, 17.6501865, 263.53543)
end)
menu.divider(LS_Robbery_TAD, "终章")
menu.action(LS_Robbery_TAD, "传送到 配方", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, -1862267709, 188023466)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_to_entity(ent, 0.0, 0.0, 0.5)
        end
    end
end)

------------------------
-- The Lost Contract
------------------------

local LS_Robbery_TLC <const> = menu.list(LS_Robbery, "失落摩托帮合约", {}, "")

menu.divider(LS_Robbery_TLC, "实验室地点")
menu.action(LS_Robbery_TLC, "传送到 保险箱", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, 1089807209)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_to_entity(ent, 0.0, -1.0, 0.0)
            set_entity_heading_to_entity(players.user_ped(), ent)
        end
    end
end)
menu.action(LS_Robbery_TLC, "炸药 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_PICKUP, true, -957953964)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_entity_to_me(ent)
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
    teleport2(coords[1], coords[2], coords[3], heading)
end)
menu.action(LS_Robbery_TLC, "传送进 卡车", {}, "", function()
    -- phantom, hash: -2137348917
    local ent = get_entity_from_blip(HUD.GET_NEXT_BLIP_INFO_ID(477))
    if ent ~= 0 then
        tp_into_vehicle(ent)
    end
end)
menu.action(LS_Robbery_TLC, "油罐车 传送到我后面", {}, "卡车后面要预留足够的位置", function()
    -- tanker, hash: -730904777
    local ent = get_entity_from_blip(HUD.GET_NEXT_BLIP_INFO_ID(479))
    if ent ~= 0 then
        set_entity_godmode(ent, true)
        set_entity_heading_to_entity(ent, players.user_ped())
        tp_entity_to_me(ent, 0.0, -9.0, 0.5)
    end
end)

------------------------
-- The Data Contract
------------------------

local LS_Robbery_TDC <const> = menu.list(LS_Robbery, "数据合约", {}, "")

menu.divider(LS_Robbery_TDC, "藏身处地点")
menu.action(LS_Robbery_TDC, "传送进 直升机", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, 1044954915)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            PED.SET_PED_INTO_VEHICLE(players.user_ped(), ent, -2)
        end
    end
end)
menu.click_slider(LS_Robbery_TDC, "直升机 传送到目的地", {}, "提前传送进直升机",
    1, 3, 1, 1, function(value)
        local entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, 1044954915)
        if next(entity_list) ~= nil then
            local coords_list = {
                v3(-401.5833, 4342.7768, 135.3380),
                v3(2122.8254, 3346.9553, 124.9741),
                v3(20.3088, 2935.2412, 136.0759),
            }

            for _, ent in pairs(entity_list) do
                TP_ENTITY(ent, coords_list[value])
            end
        end
    end)
menu.action(LS_Robbery_TDC, "巴拉杰 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, -212993243)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_vehicle_to_me(ent, "delete", "delete")
        end
    end
end)
menu.divider(LS_Robbery_TDC, "防御")
menu.action(LS_Robbery_TDC, "武器 传送到我", {}, "会一个一个的传送", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(784)
    if HUD.DOES_BLIP_EXIST(blip) then
        local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
        if ENTITY.IS_ENTITY_A_VEHICLE(ent) then
            tp_vehicle_to_me(ent, "delete", "delete")
        end
    end
end)
menu.divider(LS_Robbery_TDC, "终章")
menu.action(LS_Robbery_TDC, "硬盘 传送到我", {}, "四个硬盘会堆在一起", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, 977288393)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_entity_to_me(ent, 0.0, 2.0, 0.0)
            set_entity_heading_to_entity(ent, players.user_ped())
        end
    end
end)

--#endregion




----------------------------------
--    Freemode Mission
----------------------------------

local Freemode_Mission <const> = menu.list(Mission_Options, "自由模式任务", {}, "")

--#region Franklin Payphone

local Franklin_Payphone <const> = menu.list(Freemode_Mission, "富兰克林电话任务", {}, "")


local Franklin_Payphone_Tool <const> = menu.list(Franklin_Payphone, "工具", {}, "")


menu.action(Franklin_Payphone, "传送到 电话亭", { "rstpPayphone" }, "需要地图上出现电话亭标志", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(817)
    if HUD.DOES_BLIP_EXIST(blip) then
        local coords = HUD.GET_BLIP_COORDS(blip)
        teleport2(coords.x, coords.y, coords.z + 1.0)
    end
end)


--#region Payphone Hit
local Payphone_Hit <const> = menu.list(Franklin_Payphone, "电话暗杀", {}, "")

menu.divider(Payphone_Hit, "死宅散户")
menu.action(Payphone_Hit, "目标NPC 传送到我", {}, "", function()
    for _, ped in pairs(entities.get_all_peds_as_handles()) do
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ped) then
            local blip = HUD.GET_BLIP_FROM_ENTITY(ped)
            if HUD.DOES_BLIP_EXIST(blip) and HUD.GET_BLIP_SPRITE(blip) == 432 then
                tp_entity_to_me(ped, 0.0, 2.0, 0.0)
                WEAPON.REMOVE_ALL_PED_WEAPONS(ped)
                ENTITY.SET_ENTITY_MAX_SPEED(ped, 0.0)

                util.yield(200)
            end
        end
    end
end)

menu.divider(Payphone_Hit, "流行歌星")
menu.action(Payphone_Hit, "目标载具 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, 2038480341)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            set_entity_heading_to_entity(ent, players.user_ped(), 180.0)
            tp_entity_to_me(ent, 0.0, 5.0, 0.0)
            VEHICLE.SET_VEHICLE_FORWARD_SPEED(ent, 0.0)
            for i = 0, 5, 1 do
                VEHICLE.SET_VEHICLE_TYRE_BURST(ent, i, true, 1000.0)
            end
        end
    end
end)
menu.action(Payphone_Hit, "任务要求载具 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, -1013450936, 569305213, -2137348917, 1912215274)
    if next(entity_list) ~= nil then
        local ent = entity_list[1]
        tp_vehicle_to_me(ent)
    end
end)

menu.divider(Payphone_Hit, "科技企业家")
menu.action(Payphone_Hit, "出租车 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, -956048545)
    if next(entity_list) ~= nil then
        local ent = entity_list[1]
        tp_vehicle_to_me(ent)
    end
end)
menu.action(Payphone_Hit, "目标NPC 传送到我", {}, "然后按E叫他上车", function()
    local ent = get_entity_from_blip(HUD.GET_CLOSEST_BLIP_INFO_ID(432))
    if ent ~= 0 then
        tp_entity_to_me(ped, 2.0, 0.0, 0.0)
    end
end)

menu.divider(Payphone_Hit, "法官")
menu.action(Payphone_Hit, "传送到 高尔夫球场", {}, "领取高尔夫装备", function()
    teleport2(-1368.963, 56.357, 54.101, 278.422)
end)
menu.action(Payphone_Hit, "目标NPC 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_PED, true, 2111372120)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_entity_to_me(ent, 0.0, 2.0, 0.0)
            ENTITY.SET_ENTITY_MAX_SPEED(ent, 0.0)
        end
    end
end)

menu.divider(Payphone_Hit, "共同创办人")
menu.action(Payphone_Hit, "目标载具 最大速度为0", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, -2033222435)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            ENTITY.SET_ENTITY_MAX_SPEED(ent, 0.0)
            util.toast("完成！")
        end
    end
end)

menu.divider(Payphone_Hit, "工地总裁")
menu.action(Payphone_Hit, "传送到 装备", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, -86518587)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_to_entity(ent, 0.0, -1.0, 1.0)
            set_entity_heading_to_entity(players.user_ped(), ent)
        end
    end
end)
menu.action(Payphone_Hit, "目标NPC 传送到集装箱附近", {}, "", function()
    local target_ped = 0
    local ent = 0

    local entity_list = get_entities_by_hash(ENTITY_PED, true, -973145378)
    if next(entity_list) ~= nil then
        target_ped = entity_list[1]
    end

    entity_list = get_entities_by_hash(ENTITY_OBJECT, true, 874602658)
    if next(entity_list) ~= nil then
        ent = entity_list[1]
    end

    if ENTITY.DOES_ENTITY_EXIST(target_ped) and ENTITY.DOES_ENTITY_EXIST(ent) then
        tp_entity_to_entity(target_ped, ent, 0.0, 0.0, -3.0)
        ENTITY.SET_ENTITY_MAX_SPEED(target_ped, 0.0)
    end
end)
menu.action(Payphone_Hit, "目标NPC 传送到油罐附近", {}, "", function()
    local target_ped = 0
    local ent = 0

    local entity_list = get_entities_by_hash(ENTITY_PED, true, -973145378)
    if next(entity_list) ~= nil then
        target_ped = entity_list[1]
    end

    entity_list = get_entities_by_hash(ENTITY_OBJECT, true, -46303329)
    if next(entity_list) ~= nil then
        ent = entity_list[1]
    end

    if ENTITY.DOES_ENTITY_EXIST(target_ped) and ENTITY.DOES_ENTITY_EXIST(ent) then
        tp_entity_to_entity(target_ped, ent, 2.0, 0.0, 1.0)
        ENTITY.SET_ENTITY_MAX_SPEED(target_ped, 0.0)
    end
end)
menu.action(Payphone_Hit, "目标NPC 传送到推土机附近", {}, "", function()
    local target_ped = 0
    local ent = 0

    local entity_list = get_entities_by_hash(ENTITY_PED, true, -973145378)
    if next(entity_list) ~= nil then
        target_ped = entity_list[1]
    end

    entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, 1886712733)
    if next(entity_list) ~= nil then
        for _, veh in pairs(entity_list) do
            local ped = GET_PED_IN_VEHICLE_SEAT(veh, -1)
            if ped ~= 0 and not is_player_ped(ped) then
                ent = veh
            end
        end
    end

    if ENTITY.DOES_ENTITY_EXIST(target_ped) and ENTITY.DOES_ENTITY_EXIST(ent) then
        tp_entity_to_entity(target_ped, ent, 0.0, 6.0, 1.0)
        ENTITY.SET_ENTITY_MAX_SPEED(target_ped, 0.0)
    end
end)

--#endregion


--#region Security Contract

local Security_Contract <const> = menu.list(Franklin_Payphone, "安保合约", {}, "")

menu.divider(Security_Contract, "回收贵重物品")
menu.action(Security_Contract, "传送到 保险箱", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, -798293264)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_to_entity(ent, 0.0, -0.5, 0.0)
            set_entity_heading_to_entity(players.user_ped(), ent)
        end
    end
end)
menu.action(Security_Contract, "传送到 保险箱密码", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, 367638847)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_to_entity(ent, 0.0, 0.0, 0.5)
        end
    end
end)

menu.divider(Security_Contract, "救援行动")
menu.action(Security_Contract, "传送到 客户", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_PED, true, -2076336881, -1109568186, 2093736314, 826475330,
        -1589423867)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            set_entity_godmode(ent, true)
            tp_to_entity(ent, 0.0, 0.5, 0.0)
        end
    end
end)
menu.action(Security_Contract, "客户 传送到我", {}, "先传送到客户", function()
    local entity_list = get_entities_by_hash(ENTITY_PED, true, -2076336881, -1109568186, 2093736314, 826475330,
        -1589423867)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            local vehicle = entities.get_user_vehicle_as_handle(false)
            if vehicle ~= INVALID_GUID then
                PED.SET_PED_INTO_VEHICLE(ent, vehicle, -2)
            else
                tp_entity_to_me(ent, 0.0, 2.0, 0.0)
            end
        end
    end
end)

menu.divider(Security_Contract, "载具回收")
menu.action(Security_Contract, "机库: 传送进 载具", {}, "", function()
    if user_interior() == 260353 then
        local coords = v3(-1266.6036376953, -3015.2463378906, -47.7700614929)
        local vehicle = get_closest_entity(ENTITY_VEHICLE, coords, true, 1.0)
        if vehicle ~= 0 then
            tp_into_vehicle(vehicle)
        end
    end
end)
menu.action(Security_Contract, "机库: 传送到 门锁位置", {}, "", function()
    if user_interior() == 260353 then
        teleport2(-1249.1301, -2979.6404, -48.49219, 269.879)
    end
end)
menu.action(Security_Contract, "人道实验室: 传送进 厢型车", {}, "人道实验室 失窃动物",
    function()
        local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, 485150676)
        if next(entity_list) ~= nil then
            for _, ent in pairs(entity_list) do
                if ENTITY.IS_ENTITY_ATTACHED(ent) then
                    local attached_ent = ENTITY.GET_ENTITY_ATTACHED_TO(ent)
                    if ENTITY.IS_ENTITY_A_VEHICLE(attached_ent) then
                        tp_into_vehicle(attached_ent, "delete")
                    end
                end
            end
        end
    end)

menu.divider(Security_Contract, "变现资产")
menu.action(Security_Contract, "传送进 目标载具", {}, "", function()
    for _, ped in pairs(entities.get_all_peds_as_handles()) do
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ped) then
            local blip = HUD.GET_BLIP_FROM_ENTITY(ped)
            if HUD.DOES_BLIP_EXIST(blip) then
                local sprite = HUD.GET_BLIP_SPRITE(blip) -- 255 Car, 64 Heli, 348 Bike
                if sprite == 225 or sprite == 64 or sprite == 348 then
                    local veh = PED.GET_VEHICLE_PED_IS_IN(ped)
                    if veh ~= 0 then
                        if VEHICLE.ARE_ANY_VEHICLE_SEATS_FREE(veh) then
                            PED.SET_PED_INTO_VEHICLE(players.user_ped(), veh, -2)
                        else
                            util.toast("目标载具没有空闲座位")
                            tp_to_entity(veh, 0.0, 0.0, 2.0)
                        end
                    end
                end
            end
        end
    end
end)
menu.action(Security_Contract, "目标载具 传送到目的地", {}, "玩家自己也会跟着传送过去", function()
    local script = "fm_content_security_contract"
    if not IS_SCRIPT_RUNNING(script) then
        return
    end

    local data = {
        [20] = {
            [0] = { -673.1484, -890.0181, 23.4991 },
            [1] = { 576.9205, 126.7736, 97.0415 },
            [2] = { -91.4267, 213.6509, 95.0227 },
        },
        [21] = {
            [0] = { 845.5256, -2300.246, 29.3377 },
            [1] = { 728.2814, -652.1812, 27.0876 },
            [2] = { 2856.3801, 1511.4125, 23.5675 },
        },
        [22] = {
            [0] = { -75.0603, -818.7043, 325.1753 },
            [1] = { -144.6775, -593.2349, 210.7752 },
            [2] = { -913.4681, -377.9982, 136.9108 },
        },
        [23] = {
            [0] = { 1712.2587, -1560.2041, 111.6302 },
            [1] = { -319.2573, -1408.4926, 30.0283 },
            [2] = { -1115.8154, -2018.3884, 12.2121 },
        },
        [24] = {
            [0] = { 815.2939, -116.7617, 79.3937 },
            [1] = { 1120.0077, -470.9561, 65.4901 },
            [2] = { 496.6785, -580.8812, 23.732 },
        }
    }

    local mission_type = LOCAL_GET_INT(script, Locals[script].eMissionSubvariation)
    local destination = LOCAL_GET_INT(script, Locals[script].iGenericSet)
    if not (mission_type >= 20 and mission_type <= 24) then
        return
    end
    if not (destination >= 0 and destination <= 2) then
        return
    end
    local coords = data[mission_type][destination]
    coords = v3(table.unpack(coords))

    for _, ped in pairs(entities.get_all_peds_as_handles()) do
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ped) then
            local blip = HUD.GET_BLIP_FROM_ENTITY(ped)
            if HUD.DOES_BLIP_EXIST(blip) then
                local sprite = HUD.GET_BLIP_SPRITE(blip) -- 255 Car, 64 Heli, 348 Bike
                if sprite == 225 or sprite == 64 or sprite == 348 then
                    local veh = PED.GET_VEHICLE_PED_IS_IN(ped)
                    if veh ~= 0 then
                        TP_ENTITY(veh, coords)

                        if not PED.IS_PED_IN_VEHICLE(players.user_ped(), veh, false) then
                            tp_to_entity(veh, 0.0, 0.0, 2.0)
                        end
                    end
                end
            end
        end
    end
end)

menu.divider(Security_Contract, "资产保护")
menu.action(Security_Contract, "资产 无敌", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, -1597216682, 1329706303, 1503555850, -534405572)
    if next(entity_list) ~= nil then
        local i = 0
        for _, ent in pairs(entity_list) do
            set_entity_godmode(ent, true)
            i = i + 1
        end
        util.toast("完成！\n数量: " .. i)
    end
end)
menu.action(Security_Contract, "保安 无敌强化", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_PED, true, -1575488699, -634611634)
    if next(entity_list) ~= nil then
        local i = 0
        for _, ent in pairs(entity_list) do
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
menu.action(Security_Contract, "跳过倒计时", {},
    "不再等待漫长的10分钟\n其它任务使用此选项会直接任务失败", function()
        SPOOF_SCRIPT("fm_content_security_contract", function(script)
            LOCAL_SET_INT(script, Locals[script].stModeTimer, 0)
        end)
    end)

--#endregion


--#endregion


--#region LSA Operations

local LSA_Operations <const> = menu.list(Freemode_Mission, "LSA行动", {}, "")

----- 直接行动 -----
local LSA_DirectAction <const> = menu.list(LSA_Operations, "直接行动", {}, "")

menu.action(LSA_DirectAction, "传送到 集装箱", {}, "有图拉尔多的集装箱", function()
    local entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, 1455990255)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_to_entity(ent, 0.0, 4.0, 0.0)
            set_entity_heading_to_entity(players.user_ped(), ent, 180.0)
            set_entity_godmode(ent, true)
            SET_VEHICLE_ENGINE_ON(ent, true)
        end
    end
end)
menu.divider(LSA_DirectAction, "附加行动")
menu.action(LSA_DirectAction, "传送进 雷兽", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, 239897677)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            set_entity_godmode(ent, true)
            tp_into_vehicle(ent)
        end
    end
end)
menu.action(LSA_DirectAction, "爆炸 防空系统", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, -888936273)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            local coords = ENTITY.GET_ENTITY_COORDS(ent)
            add_owned_explosion(players.user_ped(), coords, 4)
        end
    end
end)
menu.action(LSA_DirectAction, "传送到 鲁斯特机库", {}, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(359)
    if HUD.DOES_BLIP_EXIST(blip) then
        teleport2(-1254.44189, -3355.82641, 15.155522, 150.995437)
    end
end)
local LSA_DirectAction_box = {}
menu.textslider(LSA_DirectAction, "传送到 梅利威瑟箱子", {}, "放置追踪器",
    { "获取", "1", "2", "3" }, function(value)
        if value == 1 then
            local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, 238227635)
            if next(entity_list) ~= nil then
                LSA_DirectAction_box = entity_list
                util.toast("完成！")
            end
        else
            local ent = LSA_DirectAction_box[value - 1]
            if ent ~= nil and ENTITY.DOES_ENTITY_EXIST(ent) then
                tp_to_entity(ent, 1.5, 0.0, 0.0)
                set_entity_heading_to_entity(players.user_ped(), ent, 90.0)
            end
        end
    end)

----- 外科手术式攻击 -----
local LSA_SurgicalStrike <const> = menu.list(LSA_Operations, "外科手术式攻击", {}, "")
menu.action(LSA_SurgicalStrike, "走私犯 传送到我", {}, "会传送到空中然后摔死", function()
    local entity_list = get_entities_by_hash(ENTITY_PED, true, 664399832)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_entity_to_me(ent, 0.0, 2.0, 10.0)
        end
    end
end)
menu.action(LSA_SurgicalStrike, "信号弹标记货物", {}, "标记3个货物", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, -1297668303, 2104596125, -899949922)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
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
menu.click_slider(LSA_SurgicalStrike, "传送到 货物", {}, "放置追踪器",
    1, 3, 1, 1, function(value)
        local data = {
            { hash = -1297668303, offset_y = -1.0, heading = 0 },
            { hash = 2104596125,  offset_y = 2.5,  heading = 180 },
            { hash = -899949922,  offset_y = 1.5,  heading = 180 },
        }

        local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, data[value].hash)
        if next(entity_list) ~= nil then
            for _, ent in pairs(entity_list) do
                tp_to_entity(ent, 0.0, data[value].offset_y, 0.8)
                set_entity_heading_to_entity(players.user_ped(), ent, data[value].heading)
            end
        end
    end)
menu.action(LSA_SurgicalStrike, "HVY威胁者 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, 2044532910)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_vehicle_to_me(ent, "", "delete")
        end
    end
end)
menu.divider(LSA_SurgicalStrike, "附加行动")
menu.action(LSA_SurgicalStrike, "夜鲨 传送到我", {}, "偷取梅利威瑟套装", function()
    local entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, 433954513)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_vehicle_to_me(ent)
        end
    end
end)
menu.action(LSA_SurgicalStrike, "传送到 蓝图", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, 705213476)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_to_entity(ent, 0.0, 0.0, 0.5)
        end
    end
end)
menu.action(LSA_SurgicalStrike, "传送到 工艺品", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, 1468594282)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_to_entity(ent, 0.0, 0.0, 0.5)
        end
    end
end)

----- 告密者 -----
local LSA_Whistleblower <const> = menu.list(LSA_Operations, "告密者", {}, "")

menu.action(LSA_Whistleblower, "传送进 运兵直升机", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, 1621617168)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            set_entity_godmode(ent, true)
            tp_into_vehicle(ent)
        end
    end
end)
menu.action(LSA_Whistleblower, "电磁脉冲 传送到直升机挂钩位置", {}, "运兵直升机提前放下吊钩",
    function()
        local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, 256023367)
        if next(entity_list) ~= nil then
            local veh = GET_VEHICLE_PED_IS_IN(players.user_ped())
            if veh ~= 0 and VEHICLE.DOES_CARGOBOB_HAVE_PICK_UP_ROPE(veh) then
                local pos = VEHICLE.GET_ATTACHED_PICK_UP_HOOK_POSITION(veh)
                for _, ent in pairs(entity_list) do
                    pos.z = pos.z + 1.0
                    TP_ENTITY(ent, pos)
                end
            end
        end
    end)
menu.click_slider(LSA_Whistleblower, "传送到 硬盘", {}, "", 1, 3, 1, 1, function(value)
    if user_interior() == 270081 then
        local data = {
            { coords = { x = 2059.83105, y = 2992.87133, z = -67.701660 }, heading = 91.0812683 },
            { coords = { x = 2064.04785, y = 2998.16528, z = -67.701675 }, heading = 45.7618637 },
            { coords = { x = 2073.84204, y = 2991.28125, z = -67.701660 }, heading = 290.621582 },
        }
        teleport(data[value].coords, data[value].heading)
    end
end)
menu.divider(LSA_Whistleblower, "附加行动")
menu.action(LSA_Whistleblower, "爆炸 备用发电机", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, 440559194)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            local coords = ENTITY.GET_ENTITY_COORDS(ent)
            add_owned_explosion(players.user_ped(), coords, 4)
        end
    end
end)
menu.action(LSA_Whistleblower, "传送到 服务器主机", {}, "上传病毒", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, -1449766933)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_to_entity(ent, 0.8, -1.0, 0.0)
            set_entity_heading_to_entity(players.user_ped(), ent)
        end
    end
end)
menu.action(LSA_Whistleblower, "传送到 案件卷宗", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, -2135102209)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_to_entity(ent, 0.0, 0.0, 0.5)
        end
    end
end)

--#endregion


--#region Dax Work

local Dax_Work <const> = menu.list(Freemode_Mission, "达克斯工作", {}, "蠢人帮差事")

menu.action(Dax_Work, "移除冷却时间", {}, "请求工作前点击一次", function()
    STAT_SET_INT("XM22JUGGALOWORKCDTIMER", 0)
end)

menu.divider(Dax_Work, "摧毁大麻生产")
menu.action(Dax_Work, "传送进 洒药机", {}, "", function()
    local ent = get_entity_from_blip(HUD.GET_NEXT_BLIP_INFO_ID(251))
    if ent ~= 0 then
        tp_into_vehicle(ent)
    end
end)
menu.action(Dax_Work, "传送到 大麻种植场", {}, "会按顺序传送，同时会冻结飞机", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(496)
    if HUD.DOES_BLIP_EXIST(blip) then
        local vehicle = entities.get_user_vehicle_as_handle(false)
        ENTITY.FREEZE_ENTITY_POSITION(vehicle, true)
        TP_ENTITY(vehicle, HUD.GET_BLIP_COORDS(blip))
    end
end)
menu.divider(Dax_Work, "回收货物")
menu.action(Dax_Work, "敌对老大 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_PED, true, 850468060)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_entity_to_me(ent, 0.0, 2.0, 0.0)
        end
    end
end)
menu.action(Dax_Work, "货物 传送到我", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, 1069929536)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_vehicle_to_me(ent)
        end
    end
end)
menu.divider(Dax_Work, "摧毁敌对生意")
menu.action(Dax_Work, "传送进 厢型车", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, -119658072)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_into_vehicle(ent)
        end
    end
end)
menu.action(Dax_Work, "传送到 改车王", {}, "", function()
    local blip = HUD.GET_CLOSEST_BLIP_INFO_ID(72)
    if HUD.DOES_BLIP_EXIST(blip) then
        teleport(HUD.GET_BLIP_COORDS(blip))
    end
end)
menu.action(Dax_Work, "传送到 油罐旁边", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, 1890640474)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_to_entity(ent, 0.0, -2.0, 0.0)
            set_entity_heading_to_entity(players.user_ped(), ent, 90.0)
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

local MC_Contracts <const> = menu.list(Freemode_Mission, "摩托帮会所合约", {}, "")

local MC_Contracts_Tool <const> = menu.list(MC_Contracts, "工具", {}, "")

menu.toggle(MC_Contracts_Tool, "单人可进行所有任务", {}, "", function(toggle)
    Globals.Biker.Contracts.MinPlayer(toggle)
end)


menu.divider(MC_Contracts, "屋顶作战")
menu.action(MC_Contracts, "传送到 割据", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, 339736694)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_to_entity(ent, 0.0, -0.8, 0.0)
            set_entity_heading_to_entity(players.user_ped(), ent)
        end
    end
end)
menu.action(MC_Contracts, "传送到 暴君钥匙", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, 2105669131)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_to_entity(ent, 0.0, -0.8, 0.0)
            set_entity_heading_to_entity(players.user_ped(), ent)
        end
    end
end)
menu.action(MC_Contracts, "传送到 货箱", {}, "有暴君的货箱", function()
    local entity_list = get_entities_by_hash(ENTITY_VEHICLE, true, 884483972)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            if ENTITY.IS_ENTITY_ATTACHED(ent) then
                local attached_ent = ENTITY.GET_ENTITY_ATTACHED_TO(ent)

                tp_to_entity(attached_ent, 0.0, -2.5, 0.0)
                set_entity_heading_to_entity(players.user_ped(), attached_ent)

                SET_VEHICLE_ENGINE_ON(ent, true)
            end
        end
    end
end)

menu.divider(MC_Contracts, "直捣黄龙")
menu.action(MC_Contracts, "传送到 保险箱", {}, "", function()
    local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, 1089807209)
    if next(entity_list) ~= nil then
        for _, ent in pairs(entity_list) do
            tp_to_entity(ent, 0.0, -1.0, 0.0)
            set_entity_heading_to_entity(players.user_ped(), ent)
        end
    end
end)

--#endregion


--#region Contact Work

local Contact_Work <const> = menu.list(Freemode_Mission, "联系人请求工作", {}, "")

menu.action(Contact_Work, "尤汗: 货物 传送到我", {}, "", function()
    local ent = get_entity_from_blip(HUD.GET_NEXT_BLIP_INFO_ID(478))
    if ent ~= 0 then
        tp_pickup_to_me(ent, true)
    end
end)

--#endregion


--#region Other

menu.divider(Freemode_Mission, "其它")

menu.action(Freemode_Mission, "传送到 电脑", { "rstpDesk" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(521)
    if HUD.DOES_BLIP_EXIST(blip) then
        local coords = HUD.GET_BLIP_COORDS(blip)
        teleport2(coords.x - 1.0, coords.y + 1.0, coords.z)
    end
end)
menu.action(Freemode_Mission, "打开 恐霸屏幕", { "openTerrorbyte" }, "", function()
    if IS_IN_SESSION() then
        GLOBAL_SET_INT(Globals.IsUsingComputerScreen, 1)
        START_SCRIPT("appHackerTruck", 4592) -- arg count needed to properly start the script, possibly outdated
    end
end)
menu.action(Freemode_Mission, "传送到 夜总会VIP客户", { "rstpVip" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(480)
    if HUD.DOES_BLIP_EXIST(blip) then
        local coords = HUD.GET_BLIP_COORDS(blip)
        teleport2(coords.x, coords.y, coords.z + 0.8)
    end
end)
menu.action(Freemode_Mission, "传送到 地图蓝点", { "rstpBlue" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(143)
    if HUD.DOES_BLIP_EXIST(blip) then
        local coords = HUD.GET_BLIP_COORDS(blip)
        teleport2(coords.x, coords.y, coords.z + 0.8)
    end
end)
menu.action(Freemode_Mission, "出口载具 传送到我", { "tpmeExportVeh" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(143)
    if HUD.DOES_BLIP_EXIST(blip) then
        local ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
        if ENTITY.IS_ENTITY_A_VEHICLE(ent) then
            tp_vehicle_to_me(ent)
        end
    end
end)
menu.action(Freemode_Mission, "传送到 载具出口码头", { "rstpDock" }, "", function()
    teleport2(1171.784, -2974.434, 6.502)
end)
menu.action(Freemode_Mission, "传送到 出租车乘客", { "rstpTaxiPassenger" }, "", function()
    local blip = HUD.GET_NEXT_BLIP_INFO_ID(280)
    if HUD.DOES_BLIP_EXIST(blip) then
        local ped = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
        if ENTITY.IS_ENTITY_A_PED(ped) then
            tp_to_entity(ped, 0.0, 3.0, 0.0)
            set_entity_heading_to_entity(players.user_ped(), ped, 90)
        end
    end
end)
menu.action(Freemode_Mission, "传送到 杰拉德包裹", { "rstpDeadDrop" }, "", function()
    -- local entity_list = get_entities_by_hash(ENTITY_OBJECT, true, 138777325, -1620734287, 765087784)
    -- if next(entity_list) ~= nil then
    --     for _, ent in pairs(entity_list) do
    --         tp_to_entity(ent, 0.0, 0.0, 0.5)
    --     end
    -- end
    local area = GET_PACKED_STAT_INT_CODE(PackedStats.DAILYCOLLECT_DEAD_DROP_AREA_0)
    local location = GET_PACKED_STAT_INT_CODE(PackedStats.DAILYCOLLECT_DEAD_DROP_LOCATION_0)

    local coords = Misc_T.DeadDropCoords[area]
    if not coords then
        return
    end

    coords = coords[location]
    if not coords then
        return
    end

    teleport2(coords[1], coords[2], coords[3] + 0.5)
end)
menu.action(Freemode_Mission, "会所酒吧补给品 传送到我", { "tpmeBikerBar" }, "", function()
    -- Hash: 528555233 (pickup)
    local ent = get_entity_from_blip(HUD.GET_NEXT_BLIP_INFO_ID(827))
    if ent ~= 0 then
        tp_pickup_to_me(ent, true)
    end
end)



--#endregion




----------------------------------
--    Heist Mission
----------------------------------

local Heist_Mission <const> = menu.list(Mission_Options, "多人抢劫任务", {}, "")


menu.divider(Heist_Mission, "公寓抢劫")


--#region Apartment Heist

--------------------------------
-- The Fleeca Job
--------------------------------

--------------------------------
-- The Prison Break
--------------------------------

local Heist_Prison <const> = menu.list(Heist_Mission, "越狱", {}, "")

menu.action(Heist_Prison, "飞机: 目的地 生成坦克", {}, "", function()
    local coords = { x = 2183.927, y = 4759.426, z = 41.676 }
    local heading = 73.373
    local hash = util.joaat("khanjali")
    local vehicle = create_vehicle(hash, coords, heading)
    if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        upgrade_vehicle(vehicle)
        set_entity_godmode(vehicle, true)
        strong_vehicle(vehicle)
        util.toast("完成！")
    end
end)
menu.action(Heist_Prison, "巴士: 传送到目的地", {}, "", function()
    local entity_list = get_mission_entities_by_hash(ENTITY_VEHICLE, "fm_mission_controller", -2007026063)
    if next(entity_list) == nil then
        return
    end

    local coords = { x = 2054.97119, y = 3179.5639, z = 45.43724 }
    local heading = 243.0095

    for _, ent in pairs(entity_list) do
        local blip = HUD.GET_BLIP_FROM_ENTITY(ent)
        if HUD.DOES_BLIP_EXIST(blip) then
            local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ent, -1)
            if ped ~= 0 and not is_player_ped(ped) then
                request_control(ped)
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                SET_ENTITY_HEALTH(ped, 0)
            end

            if request_control2(ent) then
                TP_ENTITY(ent, coords, heading)

                clear_vehicle_wanted(ent)

                util.toast("完成！")
            end
        end
    end
end)
menu.divider(Heist_Prison, "终章")
menu.action(Heist_Prison, "(破坏)巴士 传送到目的地", {}, "", function()
    local entity_list = get_mission_entities_by_hash(ENTITY_VEHICLE, "fm_mission_controller", -2007026063)
    if next(entity_list) == nil then
        return
    end

    local coords = { x = 1679.619873, y = 3278.103759, z = 41.0774383 }
    local heading = 32.8253974

    for _, ent in pairs(entity_list) do
        local blip = HUD.GET_BLIP_FROM_ENTITY(ent)
        if HUD.DOES_BLIP_EXIST(blip) then
            local ped = GET_PED_IN_VEHICLE_SEAT(ent, -1)
            if ped ~= 0 and not is_player_ped(ped) then
                request_control(ped)
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                SET_ENTITY_HEALTH(ped, 0)
            end

            if request_control2(ent) then
                TP_ENTITY(ent, coords, heading)
                SET_VEHICLE_ENGINE_ON(ent, true)
                VEHICLE.SET_VEHICLE_DOOR_BROKEN(ent, 0, true)
                VEHICLE.SET_VEHICLE_DOOR_BROKEN(ent, 1, true)

                util.toast("完成！")
            end
        end
    end
end)
menu.action(Heist_Prison, "监狱内 生成骷髅马", {}, "", function()
    local coords = { x = 1722.397, y = 2514.426, z = 45.305 }
    local heading = 116.175
    local hash = util.joaat("kuruma2")
    local vehicle = create_vehicle(hash, coords, heading)
    if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        upgrade_vehicle(vehicle)
        strong_vehicle(vehicle)
        set_entity_godmode(vehicle, true)
        SET_VEHICLE_ON_GROUND_PROPERLY(vehicle)
        util.toast("完成！")
    end
end)
menu.action(Heist_Prison, "梅杜莎飞机 无敌", {}, "", function()
    local entity_list = get_mission_entities_by_hash(ENTITY_VEHICLE, "fm_mission_controller", 1077420264)
    if next(entity_list) == nil then
        return
    end

    for _, ent in pairs(entity_list) do
        if request_control2(ent) then
            set_entity_godmode(ent, true)
            strong_vehicle(ent)

            util.toast("完成！")
        end
    end
end)
menu.action(Heist_Prison, "秃鹰直升机 无敌", {}, "", function()
    local entity_list = get_mission_entities_by_hash(ENTITY_VEHICLE, "fm_mission_controller", 788747387)
    if next(entity_list) == nil then
        return
    end

    for _, ent in pairs(entity_list) do
        if request_control2(ent) then
            set_entity_godmode(ent, true)
            strong_vehicle(ent)

            util.toast("完成！")
        end
    end
end)
menu.list_action(Heist_Prison, "敌对天煞", {}, "", {
    { 1, "传送到海洋" },
    { 2, "冻结" },
    { 3, "禁用导弹" }
}, function(value)
    local entity_list = get_mission_entities_by_hash(ENTITY_VEHICLE, "fm_mission_controller", -1281684762)
    if next(entity_list) == nil then
        return
    end

    for _, ent in pairs(entity_list) do
        if request_control2(ent) then
            if value == 1 then
                TP_ENTITY(ent, { x = 4912, y = -4910, z = 20 })
            elseif value == 2 then
                ENTITY.FREEZE_ENTITY_POSITION(ent, true)
            elseif value == 3 then
                local ped = GET_PED_IN_VEHICLE_SEAT(ent, -1)
                if ped ~= 0 and not is_player_ped(ped) then
                    if request_control2(ped) then
                        -- VEHICLE_WEAPON_PLANE_ROCKET
                        VEHICLE.DISABLE_VEHICLE_WEAPON(true, 3313697558, ent, ped)
                    end
                end
            end
            util.toast("完成！")
        end
    end
end)

local Heist_Prison_rashcosvki = menu.list(Heist_Prison, "光头", {}, "")
-- Model Name: ig_rashcosvki, Model Hash: 940330470

menu.action(Heist_Prison_rashcosvki, "无敌强化", {}, "", function()
    local entity_list = get_mission_entities_by_hash(ENTITY_PED, "fm_mission_controller", 940330470)
    if next(entity_list) == nil then
        return
    end

    local weaponHash = util.joaat("WEAPON_APPISTOL")

    for _, ent in pairs(entity_list) do
        if request_control2(ent) then
            WEAPON.GIVE_WEAPON_TO_PED(ent, weaponHash, -1, false, true)
            WEAPON.SET_CURRENT_PED_WEAPON(ent, weaponHash, false)

            increase_ped_combat_ability(ent, true)

            util.toast("完成！")
        end
    end
end)
menu.action(Heist_Prison_rashcosvki, "传送进 梅杜莎", {}, "", function()
    local entity_list = get_mission_entities_by_hash(ENTITY_VEHICLE, "fm_mission_controller", 1077420264)
    if next(entity_list) == nil then
        return
    end

    local velum2 = entity_list[1]
    if not ENTITY.DOES_ENTITY_EXIST(velum2) then
        return
    end

    entity_list = get_mission_entities_by_hash(ENTITY_PED, "fm_mission_controller", 940330470)
    if next(entity_list) == nil then
        return
    end

    for _, ent in pairs(entity_list) do
        if request_control2(ent) then
            PED.SET_PED_INTO_VEHICLE(ent, velum2, 0)

            util.toast("完成！")
        end
    end
end)

local Heist_Prison_vehicle = 0
menu.action(Heist_Prison_rashcosvki, "[TEST]跑去监狱外围的警车", {}, "会在监狱外围生成一辆警车", function()
    local entity_list = get_mission_entities_by_hash(ENTITY_PED, "fm_mission_controller", 940330470)
    if next(entity_list) == nil then
        return
    end

    local hash = util.joaat("police3")
    local coords = { x = 1571.585, y = 2605.450, z = 45.880 }
    local heading = 343.0217

    for _, ent in pairs(entity_list) do
        if request_control2(ent) then
            if not ENTITY.DOES_ENTITY_EXIST(Heist_Prison_vehicle) then
                local vehicle = create_vehicle(hash, coords, heading)
                upgrade_vehicle(vehicle)
                set_entity_godmode(vehicle, true)
                strong_vehicle(vehicle)
                SET_VEHICLE_ON_GROUND_PROPERLY(vehicle)

                Heist_Prison_vehicle = vehicle
            end

            TASK.TASK_GO_TO_ENTITY(ent, Heist_Prison_vehicle, -1, 5.0, 100, 0.0, 0)

            util.toast("完成！")
        end
    end
end)

menu.divider(Heist_Prison_rashcosvki, "玩家")

local heist_prison = {
    selected_player = -1,
    team_list = {
        [-1] = "无",
        [0] = "囚犯",
        [1] = "飞行员",
        [2] = "狱警",
        [3] = "破坏"
    },
}
heist_prison.select_menu = menu.list_select(Heist_Prison_rashcosvki, "选择玩家", {}, "",
    { { -1, "刷新列表", {}, "" } }, -1, function(value)
        if value == -1 then
            heist_prison.selected_player = -1

            local list_item_data = { { -1, "刷新列表", {}, "" } }
            for k, pid in pairs(players.list()) do
                local name = players.get_name(pid)
                local rank = players.get_rank(pid)
                local team = PLAYER.GET_PLAYER_TEAM(pid)
                local menu_name = "[" .. heist_prison.team_list[team] .. "] " .. name .. " (" .. rank .. "级)"

                table.insert(list_item_data, { pid, menu_name, {}, "" })
            end

            menu.set_list_action_options(heist_prison.select_menu, list_item_data)
            util.toast("已刷新，请重新打开该列表")
        else
            local pid = value
            if players.exists(pid) then
                heist_prison.selected_player = pid
            else
                util.toast("该玩家已不存在")
            end
        end
    end)
menu.action(Heist_Prison_rashcosvki, "传送到玩家/玩家载具", {}, "", function()
    local selected_player = heist_prison.selected_player
    if not players.exists(selected_player) then
        return
    end

    local entity_list = get_mission_entities_by_hash(ENTITY_PED, "fm_mission_controller", 940330470)
    if next(entity_list) == nil then
        return
    end

    for _, ent in pairs(entity_list) do
        if request_control2(ent) then
            local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(selected_player)
            local veh = GET_VEHICLE_PED_IS_IN(player_ped)
            if veh ~= 0 then
                PED.SET_PED_INTO_VEHICLE(ent, veh, -2)
            else
                tp_entity_to_entity(ent, player_ped)
            end

            util.toast("完成！")
        end
    end
end)


----------------------------------------
-- The Humane Labs Raid
----------------------------------------

local Heist_Huamane <const> = menu.list(Heist_Mission, "突袭人道实验室", {}, "")

menu.action(Heist_Huamane, "关键密码: 目的地 生成坦克", {}, "", function()
    local coords = { x = 142.122, y = -1061.271, z = 29.746 }
    local heading = 69.686
    local hash = util.joaat("khanjali")
    local vehicle = create_vehicle(hash, coords, heading)
    if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        upgrade_vehicle(vehicle)
        set_entity_godmode(vehicle, true)
        strong_vehicle(vehicle)
        util.toast("完成！")
    end
end)
menu.action(Heist_Huamane, "电磁装置: 九头蛇 无敌", {}, "", function()
    local entity_list = get_mission_entities_by_hash(ENTITY_VEHICLE, "fm_mission_controller", 970385471)
    if next(entity_list) == nil then
        return
    end

    for _, ent in pairs(entity_list) do
        if request_control2(ent) then
            set_entity_godmode(ent, true)
            strong_vehicle(ent)

            util.toast("完成！")
        end
    end
end)
menu.action(Heist_Huamane, "电磁装置: 天煞 无敌", {}, "没有玩家和NPC驾驶的天煞", function()
    local entity_list = get_mission_entities_by_hash(ENTITY_VEHICLE, "fm_mission_controller", -1281684762)
    if next(entity_list) == nil then
        return
    end

    local i = 0
    for _, ent in pairs(entity_list) do
        if VEHICLE.IS_VEHICLE_SEAT_FREE(ent, -1, true) then
            request_control(ent)
            set_entity_godmode(ent, true)
            strong_vehicle(ent)

            if has_control_entity(ent) then
                i = i + 1
            end
        end
    end
    util.toast("完成！\n数量: " .. i)
end)
menu.action(Heist_Huamane, "运送电磁装置: 叛乱分子 传送到目的地", {}, "", function()
    local entity_list = get_mission_entities_by_hash(ENTITY_VEHICLE, "fm_mission_controller", 2071877360)
    if next(entity_list) == nil then
        return
    end

    local coords = { x = 3339.7307, y = 3670.7246, z = 43.8973 }
    local heading = 312.5133

    for _, ent in pairs(entity_list) do
        local blip = HUD.GET_BLIP_FROM_ENTITY(ent)
        if HUD.DOES_BLIP_EXIST(blip) then
            if request_control2(ent) then
                TP_ENTITY(ent, coords, heading)

                util.toast("完成！")
            end
        end
    end
end)
menu.action(Heist_Huamane, "终章: 女武神 无敌", {}, "", function()
    local entity_list = get_mission_entities_by_hash(ENTITY_VEHICLE, "fm_mission_controller", -1600252419)
    if next(entity_list) == nil then
        return
    end

    for _, ent in pairs(entity_list) do
        if request_control2(ent) then
            set_entity_godmode(ent, true)
            strong_vehicle(ent)

            util.toast("完成！")
        end
    end
end)


--------------------------------
-- Series A Funding
--------------------------------

local Heist_Series <const> = menu.list(Heist_Mission, "首轮募资", {}, "")

menu.action(Heist_Series, "可卡因: 直升机 无敌", {}, "", function()
    local entity_list = get_mission_entities_by_hash(ENTITY_VEHICLE, "fm_mission_controller", 744705981)
    if next(entity_list) == nil then
        return
    end

    for _, ent in pairs(entity_list) do
        if request_control2(ent) then
            set_entity_godmode(ent, true)
            strong_vehicle(ent)

            util.toast("完成！")
        end
    end
end)
menu.action(Heist_Series, "窃取冰毒: 油罐车 无敌", {}, "", function()
    local entity_list = get_mission_entities_by_hash(ENTITY_VEHICLE, "fm_mission_controller", 1956216962)
    if next(entity_list) == nil then
        return
    end

    for _, ent in pairs(entity_list) do
        if request_control2(ent) then
            set_entity_godmode(ent, true)
            strong_vehicle(ent)

            util.toast("完成！")
        end
    end
end)
menu.action(Heist_Series, "窃取冰毒: 油罐车位置 生成尖锥魅影", {}, "", function()
    local coords = { x = 2416.0986, y = 5012.4545, z = 46.6019 }
    local heading = 132.7993
    local hash = util.joaat("phantom2")
    local vehicle = create_vehicle(hash, coords, heading)
    if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        upgrade_vehicle(vehicle)
        set_entity_godmode(vehicle, true)
        strong_vehicle(vehicle)
        SET_VEHICLE_ON_GROUND_PROPERLY(vehicle)
        util.toast("完成！")
    end
end)


----------------------------------------
-- The Pacific Standard
----------------------------------------

local Heist_Pacific <const> = menu.list(Heist_Mission, "太平洋标准银行差事", {}, "")

menu.action(Heist_Pacific, "厢型车: 添加地图标记点", {}, "给车添加地图标记点ABCD", function()
    local entity_list = get_mission_entities_by_hash(ENTITY_VEHICLE, "fm_mission_controller", 444171386)
    if next(entity_list) == nil then
        return
    end

    local blip_sprite = 535 -- radar_target_a
    for _, ent in pairs(entity_list) do
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
end)
menu.action(Heist_Pacific, "厢型车: 司机 传送到天上并冻结", {}, "", function()
    local entity_list = get_mission_entities_by_hash(ENTITY_VEHICLE, "fm_mission_controller", 444171386)
    if next(entity_list) == nil then
        return
    end

    local i = 0
    for _, ent in pairs(entity_list) do
        local ped = GET_PED_IN_VEHICLE_SEAT(ent, -1)
        if ped ~= 0 and not is_player_ped(ped) then
            request_control(ped)

            TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
            set_entity_move(ped, 0.0, 0.0, 500.0)
            ENTITY.FREEZE_ENTITY_POSITION(ped, true)

            if has_control_entity(ped) then
                i = i + 1
            end
        end
    end
    util.toast("完成！\n数量: " .. i)
end)
menu.action(Heist_Pacific, "厢型车: 传送到目的地", {}, "", function()
    local entity_list = get_mission_entities_by_hash(ENTITY_VEHICLE, "fm_mission_controller", 444171386)
    if next(entity_list) == nil then
        return
    end

    local coords = { x = 760, y = -983, z = 32 }
    local heading = 93.6973

    local ped_num, veh_num = 0, 0
    for _, ent in pairs(entity_list) do
        local ped = GET_PED_IN_VEHICLE_SEAT(ent, -1)
        if ped ~= 0 and not is_player_ped(ped) then
            request_control(ped)

            TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
            set_entity_move(ped, 0.0, 0.0, 500.0)
            ENTITY.FREEZE_ENTITY_POSITION(ped, true)

            if has_control_entity(ped) then
                ped_num = ped_num + 1
            end
        end

        request_control(ent)
        TP_ENTITY(ent, coords, heading)
        SET_VEHICLE_ON_GROUND_PROPERLY(ent)
        coords.y = coords.y + 3.5

        if has_control_entity(ent) then
            veh_num = veh_num + 1
        end
    end
    util.toast("完成！\nNPC数量: " .. ped_num .. "\n载具数量: " .. veh_num)
end)
menu.action(Heist_Pacific, "信号: 岛上 生成直升机", {}, "撤离时", function()
    local coords = { x = -2188.197, y = 5128.990, z = 11.672 }
    local heading = 314.255
    local hash = util.joaat("polmav")
    local vehicle = create_vehicle(hash, coords, heading)
    if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        set_entity_godmode(vehicle, true)
        strong_vehicle(vehicle)
        SET_VEHICLE_ON_GROUND_PROPERLY(vehicle)
        util.toast("完成！")
    end
end)
menu.action(Heist_Pacific, "车队: 目的地 生成坦克", {}, "", function()
    local coords = { x = -196.452, y = 4221.374, z = 45.376 }
    local heading = 313.298
    local hash = util.joaat("khanjali")
    local vehicle = create_vehicle(hash, coords, heading)
    if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        upgrade_vehicle(vehicle)
        set_entity_godmode(vehicle, true)
        strong_vehicle(vehicle)
        util.toast("完成！")
    end
end)
menu.action(Heist_Pacific, "车队: 卡车 无敌", {}, "", function()
    local entity_list = get_mission_entities_by_hash(ENTITY_VEHICLE, "fm_mission_controller", 630371791)
    if next(entity_list) == nil then
        return
    end

    for _, ent in pairs(entity_list) do
        if request_control2(ent) then
            set_entity_godmode(ent, true)
            strong_vehicle(ent)

            util.toast("完成！")
        end
    end
end)
menu.action(Heist_Pacific, "摩托车: 雷克卓 升级无敌", {}, "", function()
    local entity_list = get_mission_entities_by_hash(ENTITY_VEHICLE, "fm_mission_controller", 640818791)
    if next(entity_list) == nil then
        return
    end

    local i = 0
    for _, ent in pairs(entity_list) do
        request_control(ent, 500)

        set_entity_godmode(ent, true)
        upgrade_vehicle(ent)
        strong_vehicle(ent)

        if has_control_entity(ent) then
            i = i + 1
        end
    end
    util.toast("完成！\n数量: " .. i)
end)
menu.divider(Heist_Pacific, "终章")
menu.action(Heist_Pacific, "摩托车位置 生成骷髅马", {}, "", function()
    local coords = { x = 36.002, y = 94.153, z = 78.751 }
    local heading = 249.426
    local hash = util.joaat("kuruma2")
    local vehicle = create_vehicle(hash, coords, heading)
    if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        upgrade_vehicle(vehicle)
        set_entity_godmode(vehicle, true)
        strong_vehicle(vehicle)
        SET_VEHICLE_ON_GROUND_PROPERLY(vehicle)
        util.toast("完成！")
    end
end)
menu.action(Heist_Pacific, "摩托车位置 生成直升机", {}, "", function()
    local coords = { x = 52.549, y = 88.787, z = 78.683 }
    local heading = 15.508
    local hash = util.joaat("polmav")
    local vehicle = create_vehicle(hash, coords, heading)
    if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        set_entity_godmode(vehicle, true)
        strong_vehicle(vehicle)
        SET_VEHICLE_ON_GROUND_PROPERLY(vehicle)
        util.toast("完成！")
    end
end)

--#endregion



menu.divider(Heist_Mission, "末日豪劫")


--#region Doomsday Heist Prep

local Doomsday_Preps <const> = menu.list(Heist_Mission, "前置任务", {}, "")

------------------------------------
-- Act I: The Data Breaches
------------------------------------

menu.divider(Doomsday_Preps, "末日一：数据泄露")
menu.action(Doomsday_Preps, "医疗装备: 救护车 传送到我", {}, "", function()
    local entity_list = get_mission_entities_by_hash(ENTITY_VEHICLE, "gb_gangops", 1171614426)
    if next(entity_list) == nil then
        return
    end

    for _, ent in pairs(entity_list) do
        if request_control2(ent) then
            tp_vehicle_to_me(ent)
        end
    end
end)
local doomsday_preps_deluxo_menu
doomsday_preps_deluxo_menu = menu.list_action(Doomsday_Preps, "德罗索: 载具 传送到我", {}, "",
    { { -1, "刷新载具列表" } }, function(value)
        if value == -1 then
            local entity_list = get_mission_entities_by_hash(ENTITY_VEHICLE, "gb_gangops", 1483171323)
            if next(entity_list) == nil then
                return
            end

            local list_item_data = { { -1, "刷新载具列表" } }
            local i = 1

            for _, ent in pairs(entity_list) do
                table.insert(list_item_data, { ent, "德罗索 " .. i })
                i = i + 1
            end

            menu.set_list_action_options(doomsday_preps_deluxo_menu, list_item_data)
            util.toast("已刷新，请重新打开该列表")
        else
            local ent = value
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                if request_control2(ent) then
                    tp_vehicle_to_me(ent)
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
        local entity_list = get_mission_entities_by_hash(ENTITY_VEHICLE, "gb_gangops", 1181327175)
        if next(entity_list) == nil then
            return
        end

        for _, ent in pairs(entity_list) do
            if request_control2(ent) then
                tp_vehicle_to_me(ent, "", "delete")
                set_entity_godmode(ent, true)
            end
        end
    end)

------------------------------------
-- Act II: The Bogdan Problem
------------------------------------

menu.divider(Doomsday_Preps, "末日二：博格丹危机")
menu.action(Doomsday_Preps, "钥匙卡: 防暴车 传送到我", {}, "", function()
    local entity_list = get_mission_entities_by_hash(ENTITY_VEHICLE, "gb_gangops", -1205689942)
    if next(entity_list) == nil then
        return
    end

    for _, ent in pairs(entity_list) do
        if request_control2(ent) then
            tp_vehicle_to_me(ent)
        end
    end
end)
menu.action(Doomsday_Preps, "ULP情报: 包裹 传送到我", {},
    "先干掉毒贩，下方提示进入公寓后传送", function()
        local entity_list = get_mission_pickups("gb_gangops")
        for _, ent in pairs(entity_list) do
            if request_control2(ent) then
                tp_pickup_to_me(ent)
            end
        end
    end)
local doomsday_preps_stromberg_menu
doomsday_preps_stromberg_menu = menu.list_action(Doomsday_Preps, "斯特龙伯格: 卡车 传送到我", {}, "",
    { { -1, "刷新载具列表" } }, function(value)
        if value == -1 then
            local entity_list = get_mission_entities_by_hash(ENTITY_OBJECT, "gb_gangops", -6020377, -1690938994)
            if next(entity_list) == nil then
                return
            end

            local list_item_data = { { -1, "刷新载具列表" } }
            local i = 1

            for _, ent in pairs(entity_list) do
                if ENTITY.IS_ENTITY_ATTACHED(ent) then
                    local attached_ent = ENTITY.GET_ENTITY_ATTACHED_TO(ent)
                    table.insert(list_item_data, { attached_ent, "卡车 " .. i })
                    i = i + 1
                end
            end

            menu.set_list_action_options(doomsday_preps_stromberg_menu, list_item_data)
            util.toast("已刷新，请重新打开该列表")
        else
            local ent = value
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                if request_control2(ent) then
                    tp_vehicle_to_me(ent, "", "delete")
                    set_entity_godmode(ent, true)
                end
            end
        end
    end)
menu.action(Doomsday_Preps, "鱼雷电控单元: 包裹 传送到我", {}, "", function()
    local entity_list = get_mission_pickups("gb_gangops")
    for _, ent in pairs(entity_list) do
        if request_control2(ent) then
            tp_pickup_to_me(ent)
        end
    end
end)

------------------------------------
-- Act III: The Doomsday Scenario
------------------------------------

menu.divider(Doomsday_Preps, "末日三：末日将至")
menu.action(Doomsday_Preps, "标记资金: 包裹 传送到我", {}, "", function()
    local entity_list = get_mission_pickups("gb_gangops")
    for _, ent in pairs(entity_list) do
        if request_control2(ent) then
            tp_pickup_to_me(ent)
        end
    end
end)
menu.action(Doomsday_Preps, "切尔诺伯格: 载具 传送到我", {}, "", function()
    local entity_list = get_mission_entities_by_hash(ENTITY_VEHICLE, "gb_gangops", -692292317)
    if next(entity_list) == nil then
        return
    end

    for _, ent in pairs(entity_list) do
        if request_control2(ent) then
            tp_vehicle_to_me(ent)
        end
    end
end)
menu.action(Doomsday_Preps, "机载电脑: 飞机 传送到我", {},
    "先杀死所有NPC(飞行员)", function()
        local entity_list = get_mission_entities_by_hash(ENTITY_OBJECT, "gb_gangops", -82999846)
        if next(entity_list) == nil then
            return
        end

        for _, ent in pairs(entity_list) do
            if ENTITY.IS_ENTITY_ATTACHED(ent) then
                local attached_ent = ENTITY.GET_ENTITY_ATTACHED_TO(ent)
                if request_control2(attached_ent) then
                    tp_entity_to_me(attached_ent, 0.0, 10.0, 2.0)
                    set_entity_heading_to_entity(attached_ent, players.user_ped(), 180.0)
                end
            end
        end
    end)

--#endregion


--#region Doomsday Heist

------------------------------------
-- Act I: The Data Breaches
------------------------------------

local Doomsday_IAA <const> = menu.list(Heist_Mission, "末日一：数据泄露", {}, "")

menu.divider(Doomsday_IAA, "拦截信号")
menu.action(Doomsday_IAA, "德罗索 升级无敌", {}, "", function()
    local entity_list = get_mission_entities_by_hash(ENTITY_VEHICLE, "fm_mission_controller", 1483171323)
    if next(entity_list) == nil then
        return
    end

    local i = 0
    for _, ent in pairs(entity_list) do
        request_control(ent, 500)

        set_entity_godmode(ent, true)
        upgrade_vehicle(ent)
        strong_vehicle(ent)

        if has_control_entity(ent) then
            i = i + 1
        end
    end
    util.toast("完成！\n数量: " .. i)
end)
menu.action(Doomsday_IAA, "移除敌对NPC武器", {}, "", function()
    local i = 0
    for _, ped in pairs(entities.get_all_peds_as_handles()) do
        if is_hostile_ped(ped) then
            WEAPON.REMOVE_ALL_PED_WEAPONS(ped)

            if has_control_entity(ped) then
                i = i + 1
            end
        end
    end
    util.toast("完成！\n数量: " .. i)
end)

------------------------------------
-- Act II: The Bogdan Problem
------------------------------------

local Doomsday_SUBMARINE <const> = menu.list(Heist_Mission, "末日二：博格丹危机", {}, "")

------------------------------------
-- Act III: The Doomsday Scenario
------------------------------------

local Doomsday_MISSILE_SILO <const> = menu.list(Heist_Mission, "末日三：末日将至", {}, "")

menu.divider(Doomsday_MISSILE_SILO, "营救14号探员")
menu.action(Doomsday_MISSILE_SILO, "14号探员 无敌强化", {}, "", function()
    local entity_list = get_mission_entities_by_hash(ENTITY_PED, "fm_mission_controller", -67533719)
    if next(entity_list) == nil then
        return
    end

    local weaponHash = util.joaat("WEAPON_SPECIALCARBINE")

    for _, ent in pairs(entity_list) do
        if request_control2(ent) then
            give_weapon_to_ped(ent, weaponHash)
            increase_ped_combat_ability(ent, true)

            util.toast("完成！")
        end
    end
end)

menu.divider(Doomsday_MISSILE_SILO, "护送ULP")
menu.action(Doomsday_MISSILE_SILO, "直升机 无敌", {}, "", function()
    local entity_list = get_mission_entities_by_hash(ENTITY_VEHICLE, "fm_mission_controller", -1984275979)
    if next(entity_list) == nil then
        return
    end

    for _, ent in pairs(entity_list) do
        if request_control2(ent) then
            set_entity_godmode(ent, true)
            strong_vehicle(ent)

            util.toast("完成！")
        end
    end
end)
menu.click_slider(Doomsday_MISSILE_SILO, "直升机 向前加速", {}, "",
    0, 1000, 100, 50, function(value)
        local entity_list = get_mission_entities_by_hash(ENTITY_VEHICLE, "fm_mission_controller", -1984275979)
        if next(entity_list) == nil then
            return
        end

        for _, ent in pairs(entity_list) do
            if request_control2(ent) then
                VEHICLE.SET_VEHICLE_FORWARD_SPEED_XY(ent, value)

                util.toast("完成！")
            end
        end
    end)


--#endregion




--------------------------------
--  Options
--------------------------------

menu.divider(Mission_Options, "")


menu.action(Mission_Options, "警局楼顶 生成直升机", {}, "", function()
    local data_list = {
        { coords = { x = 578.9077, y = 10.7298, z = 103.6283 },  heading = 181.9320 },
        { coords = { x = 448.8357, y = -980.8952, z = 44.0863 }, heading = 93.0307 },
    }
    local hash = 353883353
    local num = 0

    for _, data in pairs(data_list) do
        local coords = v3(data.coords)
        local veh = get_closest_entity(ENTITY_VEHICLE, coords, false, 5.0)
        if not ENTITY.DOES_ENTITY_EXIST(veh) then
            veh = create_vehicle(hash, coords, data.heading)
        end

        SET_VEHICLE_ENGINE_ON(veh, true)
        SET_VEHICLE_ON_GROUND_PROPERLY(veh)
        VEHICLE.SET_VEHICLE_HAS_BEEN_OWNED_BY_PLAYER(veh, true)
        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(veh, true, false)

        ENTITY.SET_ENTITY_MAX_HEALTH(veh, 10000)
        SET_ENTITY_HEALTH(veh, 10000)
        strong_vehicle(veh)

        if has_control_entity(veh) then
            num = num + 1
        end
    end

    util.toast("完成! 数量: " .. num)
end)


local traffic_density_sphere_id = -1
menu.textslider_stateful(Mission_Options, "交通人口密度", {}, "",
    { "清空", "清空(立即)", "恢复" }, function(value)
        if value == 1 then
            traffic_density_sphere_id = MISC.ADD_POP_MULTIPLIER_SPHERE(1.1, 1.1, 1.1, 15000.0,
                0.0, 0.0, false, true)
        elseif value == 2 then
            traffic_density_sphere_id = MISC.ADD_POP_MULTIPLIER_SPHERE(1.1, 1.1, 1.1, 15000.0,
                0.0, 0.0, false, true)
            MISC.CLEAR_AREA(1.1, 1.1, 1.1, 19999.9, true, false, false, true)
        else
            MISC.REMOVE_POP_MULTIPLIER_SPHERE(traffic_density_sphere_id, false)
        end
    end)

menu.list_action(Mission_Options, "镜头锁定", { "camLock" }, "", {
    { 0, "无", { "none" } },
    { 1, "第一人称", { "first" } },
    { 2, "第三人称", { "third" } },
}, function(value)
    GLOBAL_SET_INT(g_FMMC_STRUCT.iFixedCamera, value)
end)




local HeistMissionVehicle = {
    replaceVehicles = {
        { util.joaat("oppressor2"), util.get_label_text("oppressor2") },

        { util.joaat("kuruma2"),    util.get_label_text("kuruma2") },
        { util.joaat("toreador"),   util.get_label_text("toreador") },
        { util.joaat("insurgent3"), util.get_label_text("insurgent3") },
        { util.joaat("deluxo"),     util.get_label_text("deluxo") },
        { util.joaat("vigilante"),  util.get_label_text("vigilante") },

        { util.joaat("krieger"),    util.get_label_text("krieger") },
        { util.joaat("t20"),        util.get_label_text("t20") },

        { util.joaat("Lazer"),      util.get_label_text("Lazer") },
        { util.joaat("hydra"),      util.get_label_text("hydra") },
        { util.joaat("raiju"),      util.get_label_text("raiju") },
        { util.joaat("buzzard"),    util.get_label_text("buzzard") },

        { util.joaat("khanjali"),   util.get_label_text("khanjali") },
        { util.joaat("phantom2"),   util.get_label_text("phantom2") },
    }
}

function HeistMissionVehicle.getDriverName(vehicle)
    local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1, false)

    if entities.is_player_ped(driver) then
        return players.get_name(get_player_from_ped(driver))
    end

    local driver_hash = ENTITY.GET_ENTITY_MODEL(driver)
    local driver_model = util.reverse_joaat(driver_hash)
    if driver_model == "" then
        return driver_hash .. " [NPC]"
    end
    return driver_model .. " [NPC]"
end

function HeistMissionVehicle.getNetIdAddr(vehicle, script)
    local netId = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(vehicle)
    if not NETWORK.NETWORK_DOES_NETWORK_ID_EXIST(netId) then
        return 0
    end

    for i = 0, 31, 1 do
        local addr = Locals[script].sFMMC_SBD.niVehicle + i
        if LOCAL_GET_INT(script, addr) == netId then
            return addr
        end
    end

    return 0
end

function HeistMissionVehicle.replaceVehicle(vehicle, hash)
    local coords = ENTITY.GET_ENTITY_COORDS(vehicle)
    local heading = ENTITY.GET_ENTITY_HEADING(vehicle)

    -- 生成替换载具，先放到天上
    local replace_veh = VEHICLE.CREATE_VEHICLE(hash, coords.x, coords.y, coords.z + 2000, heading, true, true, false)
    ENTITY.FREEZE_ENTITY_POSITION(replace_veh, true)

    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(replace_veh, true, false)

    NETWORK.NETWORK_REGISTER_ENTITY_AS_NETWORKED(replace_veh)
    local netId = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(replace_veh)
    if not NETWORK.NETWORK_DOES_NETWORK_ID_EXIST(netId) then
        -- 没有成功获得 net id
        entities.delete(replace_veh)
        return 0
    end

    NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(netId, true)
    NETWORK.SET_NETWORK_ID_CAN_MIGRATE(netId, true)
    for _, pid in pairs(players.list()) do
        NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(netId, pid, true)
    end

    strong_vehicle(replace_veh)
    upgrade_vehicle(replace_veh)

    -- 传送原载具到其它地方
    ENTITY.DETACH_ENTITY(vehicle, false, false)
    ENTITY.FREEZE_ENTITY_POSITION(vehicle, true)
    ENTITY.SET_ENTITY_COLLISION(vehicle, false, false)
    TP_ENTITY(vehicle, v3(7000, 7000, -100))
    -- 传送原载具内NPC到替换载具内
    -- local seats = VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(vehicle)
    -- for i = -1, seats - 1 do
    --     if not VEHICLE.IS_VEHICLE_SEAT_FREE(vehicle, i, false) then
    --         util.create_thread(function()
    --             local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, i)
    --             request_control(ped)
    --             PED.SET_PED_INTO_VEHICLE(ped, replace_veh, i)
    --         end)
    --     end
    -- end

    -- 传送替换载具到原载具位置
    TP_ENTITY(replace_veh, coords)
    ENTITY.FREEZE_ENTITY_POSITION(replace_veh, false)

    return netId
end

function HeistMissionVehicle.generateMenuActions(menu_parent, vehicle, script)
    menu.list_action(menu_parent, "传送", {}, "", {
        { 1, "传送到 我并驾驶" },
        { 2, "传送进 驾驶位" },
        { 3, "传送进 空座位" },
    }, function(value)
        if value == 1 then
            tp_vehicle_to_me(vehicle)
        elseif value == 2 then
            tp_into_vehicle(vehicle)
        elseif value == 3 then
            tp_into_vehicle(vehicle, "", "", -2)
        end
    end)

    menu.action(menu_parent, "无敌强化", {}, "", function()
        if request_control2(vehicle) then
            set_entity_godmode(vehicle, true)
            strong_vehicle(vehicle)

            util.toast("完成！")
        end
    end)

    menu.action(menu_parent, "载具升级", {}, "", function()
        if request_control2(vehicle) then
            upgrade_vehicle(vehicle)

            util.toast("完成！")
        end
    end)

    menu.list_action(menu_parent, "替换载具", {}, "", HeistMissionVehicle.replaceVehicles, function(value)
        if NETWORK.NETWORK_GET_HOST_OF_SCRIPT(script, 0, 0) ~= players.user() then
            if not util.request_script_host(script) then
                util.toast("成为脚本主机失败，请重试")
                return
            end

            util.yield() -- 如果不加 yield 下面的 spoof_script 会有问题
        end

        if not request_control(vehicle) then
            util.toast("请求控制载具失败，请重试")
            return
        end

        util.yield()

        local hash = value
        util.request_model(hash)
        if not STREAMING.HAS_MODEL_LOADED(hash) then
            return
        end

        util.spoof_script(script, function()
            local netIdAddr = HeistMissionVehicle.getNetIdAddr(vehicle, script)
            if netIdAddr == 0 then
                return
            end

            local netId = HeistMissionVehicle.replaceVehicle(vehicle, hash)
            if netId == 0 then
                return
            end

            LOCAL_SET_INT(script, netIdAddr, netId)
            util.toast("完成！")
        end)

        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
    end)


    local temp = menu.divider(menu_parent, "")
    menu.set_visible(temp, false)
    menu.on_tick_in_viewport(temp, function()
        draw_line_to_entity(vehicle)
    end)
end

local Heist_Mission_Vehicle
Heist_Mission_Vehicle = menu.list(Mission_Options, "管理任务载具", {}, "", function()
    rs_menu.delete_menu_children(Heist_Mission_Vehicle)

    local script = GET_RUNNING_MISSION_CONTROLLER_SCRIPT()
    if script == nil then return end

    for _, vehicle in pairs(entities.get_all_vehicles_as_handles()) do
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(vehicle) then
            if GET_ENTITY_SCRIPT(vehicle) == script then
                local menu_name = get_vehicle_display_name(vehicle)
                local help_text = ""

                if not VEHICLE.IS_VEHICLE_SEAT_FREE(vehicle, -1, false) then
                    help_text = help_text .. "司机: " .. HeistMissionVehicle.getDriverName(vehicle) .. "\n"
                end

                local blip = HUD.GET_BLIP_FROM_ENTITY(vehicle)
                if HUD.DOES_BLIP_EXIST(blip) then
                    local blip_sprite = HUD.GET_BLIP_SPRITE(blip)
                    if blip_sprite == 1 then
                        menu_name = menu_name .. " [目标点]"
                    else
                        menu_name = menu_name .. " [标记点]"
                    end

                    local blip_colour = HUD.GET_BLIP_COLOUR(blip)
                    if blip_colour == 54 then
                        help_text = help_text .. "BLIP_COLOUR_BLUEDARK" .. "\n"
                    end
                end

                if vehicle == PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false) then
                    if PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
                        menu_name = menu_name .. " [当前载具]"
                    else
                        menu_name = menu_name .. " [上一辆载具]"
                    end
                end

                help_text = help_text .. "控制权: " .. get_entity_owner_name(vehicle) .. "\n"
                help_text = help_text .. "乘客数: " .. VEHICLE.GET_VEHICLE_NUMBER_OF_PASSENGERS(vehicle, false, false)


                local menu_list = menu.list(Heist_Mission_Vehicle, menu_name, {}, help_text)
                HeistMissionVehicle.generateMenuActions(menu_list, vehicle, script)
            end
        end
    end
end)
