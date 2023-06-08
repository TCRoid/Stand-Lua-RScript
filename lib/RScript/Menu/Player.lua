--------------------------------
------------ 玩家选项 -----------
--------------------------------

local Player_options = function(pid)
    local player_menu_root = menu.list(menu.player_root(pid), "RScript", {}, "")

    menu.divider(player_menu_root, "RScript")





    --#region 恶搞选项

    ----------------------------
    ---------- 恶搞选项 ---------
    ----------------------------

    local Trolling_options = menu.list(player_menu_root, "恶搞选项", {}, "")

    menu.action(Trolling_options, "小查攻击", {}, "", function()
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
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

        increase_ped_combat_ability(g_ped, false, false)
        increase_ped_combat_attributes(g_ped)
    end)

    menu.action(Trolling_options, "载具内敌人攻击", {}, "", function()
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local vehicle = GET_VEHICLE_PED_IS_IN(player_ped)
        if vehicle ~= 0 then
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
            PED.SET_PED_CAN_BE_DRAGGED_OUT(g_ped, false)

            local weaponHash = util.joaat("WEAPON_MICROSMG")
            WEAPON.GIVE_WEAPON_TO_PED(g_ped, weaponHash, -1, false, true)
            WEAPON.SET_CURRENT_PED_WEAPON(g_ped, weaponHash, true)

            disable_ped_flee_attributes(g_ped)
            increase_ped_combat_ability(g_ped, false, false)
            increase_ped_combat_attributes(g_ped)
            PED.SET_PED_COMBAT_ATTRIBUTES(g_ped, 3, false) --CanLeaveVehicle
        else
            util.toast("未找到玩家的载具")
        end
    end)

    menu.action(Trolling_options, "生成敌人抢夺载具", {}, "", function()
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local vehicle = GET_VEHICLE_PED_IS_IN(player_ped)
        if vehicle ~= 0 then
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
            PED.SET_PED_CAN_BE_DRAGGED_OUT(g_ped, false)

            local weaponHash = util.joaat("WEAPON_MICROSMG")
            WEAPON.GIVE_WEAPON_TO_PED(g_ped, weaponHash, -1, false, true)
            WEAPON.SET_CURRENT_PED_WEAPON(g_ped, weaponHash, true)

            disable_ped_flee_attributes(g_ped)
            increase_ped_combat_ability(g_ped, false, false)
            increase_ped_combat_attributes(g_ped)

            TASK.TASK_ENTER_VEHICLE(g_ped, vehicle, -1, -1, 5.0, 16, 0)
            TASK.TASK_VEHICLE_DRIVE_TO_COORD(g_ped, vehicle, math.random(1000), math.random(1000), math.random(100),
                200, 1, ENTITY.GET_ENTITY_MODEL(vehicle), 786996, 5, 0)
        else
            util.toast("未找到玩家的载具")
        end
    end)

    menu.action(Trolling_options, "生成虎鲸", {}, "", function()
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local modelHash = util.joaat("kosatka")
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0.0, 0.0, 0.0)
        local heading = ENTITY.GET_ENTITY_HEADING(player_ped)

        local g_veh = create_vehicle(modelHash, coords, heading)
        
        set_entity_godmode(g_evh, true)
        entities.set_can_migrate(g_veh, false)
    end)


    -------------------
    -- 传送所有实体
    -------------------
    local Trolling_tp_entities = menu.list(Trolling_options, "传送所有实体", {}, "")

    local player_tp_entities = {
        delay = 100, -- ms
        is_running = false,
        exclude_mission = true,
    }
    local function tp_entities_to_player(entity_list, player_ped, Type)
        local i = 0
        for k, ent in pairs(entity_list) do
            if player_tp_entities.is_running then
                if player_tp_entities.exclude_mission and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
                else
                    if Type == "Ped" and ENTITY.IS_ENTITY_A_PED(ent) then
                        if not IS_PED_PLAYER(ent) then
                            RequestControl(ent)
                            TP_ENTITY_TO_ENTITY(ent, player_ped, 0.0, 0.0, 2.0)
                            i = i + 1
                        end
                    elseif Type == "Vehicle" and ENTITY.IS_ENTITY_A_VEHICLE(ent) then
                        if not IS_PLAYER_VEHICLE(ent) then
                            RequestControl(ent)
                            TP_ENTITY_TO_ENTITY(ent, player_ped, 0.0, 0.0, 2.0)
                            i = i + 1
                        end
                    elseif Type == "Object" and ENTITY.IS_ENTITY_AN_OBJECT(ent) then
                        RequestControl(ent)
                        TP_ENTITY_TO_ENTITY(ent, player_ped, 0.0, 0.0, 2.0)
                        i = i + 1
                    elseif Type == "Pickup" and IS_ENTITY_A_PICKUP(ent) then
                        RequestControl(ent)
                        TP_ENTITY_TO_ENTITY(ent, player_ped, 0.0, 0.0, 2.0)
                        i = i + 1
                    end
                end
                util.yield(player_tp_entities.delay)
            else
                -- 停止传送
                util.toast("完成!\n" .. Type .. " 数量: " .. i)
                return false
            end
        end
        -- 完成传送
        util.toast("完成!\n" .. Type .. " 数量: " .. i)
        player_tp_entities.is_running = false
        return true
    end

    menu.slider(Trolling_tp_entities, "传送延时", { "tp_entities_delay" }, "单位: ms", 0, 5000, 100, 100,
        function(value)
            player_tp_entities.delay = value
        end)
    menu.toggle(Trolling_tp_entities, "排除任务实体", {}, "", function()
        player_tp_entities.exclude_mission = value
    end, true)

    menu.action(Trolling_tp_entities, "传送所有 行人 到此玩家", {}, "", function()
        if player_tp_entities.is_running then
            util.toast("上次的还未传送完成呢")
        else
            player_tp_entities.is_running = true
            local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            tp_entities_to_player(entities.get_all_peds_as_handles(), player_ped, "Ped")
        end
    end)
    menu.action(Trolling_tp_entities, "传送所有 载具 到此玩家", {}, "", function()
        if player_tp_entities.is_running then
            util.toast("上次的还未传送完成呢")
        else
            player_tp_entities.is_running = true
            local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            tp_entities_to_player(entities.get_all_vehicles_as_handles(), player_ped, "Vehicle")
        end
    end)
    menu.action(Trolling_tp_entities, "传送所有 物体 到此玩家", {}, "", function()
        if player_tp_entities.is_running then
            util.toast("上次的还未传送完成呢")
        else
            player_tp_entities.is_running = true
            local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            tp_entities_to_player(entities.get_all_objects_as_handles(), player_ped, "Object")
        end
    end)
    menu.action(Trolling_tp_entities, "传送所有 拾取物 到此玩家", {}, "", function()
        if player_tp_entities.is_running then
            util.toast("上次的还未传送完成呢")
        else
            player_tp_entities.is_running = true
            local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            tp_entities_to_player(entities.get_all_pickups_as_handles(), player_ped, "Pickup")
        end
    end)
    menu.action(Trolling_tp_entities, "停止传送", {}, "", function()
        player_tp_entities.is_running = false
    end)


    --------------------
    -- 此玩家附近载具
    --------------------
    local Trolling_NearbyVehicle = menu.list(Trolling_options, "此玩家附近载具", {}, "需要在此玩家附近")

    local player_nearby_vehicle = {
        radius = 60,
        mission_type = 6,
    }

    menu.slider(Trolling_NearbyVehicle, "范围半径", { "nearby_veh_radius" }, "", 0, 1000, 60, 10,
        function(value)
            player_nearby_vehicle.radius = value
        end)

    menu.toggle_loop(Trolling_NearbyVehicle, "附近司机追赶此玩家", {}, "", function()
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        for _, vehicle in pairs(GET_NEARBY_VEHICLES(pid, player_nearby_vehicle.radius)) do
            local driver = GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
            if driver ~= 0 then
                if not IS_PED_PLAYER(driver) and not TASK.GET_IS_TASK_ACTIVE(driver, 363) then
                    RequestControl(driver)

                    PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(driver, true)
                    TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(driver, true)
                    PED.SET_PED_KEEP_TASK(driver, true)

                    disable_ped_flee_attributes(driver)

                    TASK.TASK_VEHICLE_CHASE(driver, player_ped)
                end
            end
        end
    end)

    menu.divider(Trolling_NearbyVehicle, "设置载具任务")
    menu.list_select(Trolling_NearbyVehicle, "任务类型", {}, "", Vehicle_MissionType.ListItem, 6,
        function(value)
            player_nearby_vehicle.mission_type = Vehicle_MissionType.ValueList[value]
        end)
    menu.toggle_loop(Trolling_NearbyVehicle, "给载具设置针对此玩家的任务", {}, "", function()
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        for _, vehicle in pairs(GET_NEARBY_VEHICLES(pid, player_nearby_vehicle.radius)) do
            local driver = GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
            if driver ~= 0 then
                if not IS_PED_PLAYER(driver) and TASK.GET_ACTIVE_VEHICLE_MISSION_TYPE(vehicle) ~= player_nearby_vehicle.mission_type then
                    RequestControl(driver)

                    PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(driver, true)
                    TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(driver, true)
                    PED.SET_PED_KEEP_TASK(driver, true)

                    disable_ped_flee_attributes(driver)

                    TASK.TASK_VEHICLE_MISSION_PED_TARGET(driver, vehicle, player_ped, player_nearby_vehicle.mission_type,
                        500.0, 0, 0.0,
                        0.0, true)
                end
            end
        end
    end)


    --------------------
    -- 此玩家附近行人
    --------------------
    local Trolling_NearbyPed = menu.list(Trolling_options, "此玩家附近行人", {}, "需要在此玩家附近")

    local player_nearby_ped = {
        radius = 60,
        combat = {
            weapon = util.joaat(Weapon_Common.ModelList[1]),
            is_enhance = false,
            is_drop_money = false,
            health_mult = 1,
        },
    }

    menu.slider(Trolling_NearbyPed, "范围半径", { "nearby_ped_radius" }, "", 0, 1000, 60, 10,
        function(value)
            player_nearby_ped.radius = value
        end)

    menu.toggle_loop(Trolling_NearbyPed, "附近行人逮捕此玩家", {}, "", function()
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        for _, ped in pairs(GET_NEARBY_PEDS(pid, player_nearby_ped.radius)) do
            if not IS_PED_PLAYER(ped) and not TASK.GET_IS_TASK_ACTIVE(ped, 62) then
                RequestControl(ped)

                PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
                TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
                PED.SET_PED_KEEP_TASK(ped, true)

                disable_ped_flee_attributes(ped)

                TASK.TASK_ARREST_PED(ped, player_ped)
            end
        end
    end)

    menu.divider(Trolling_NearbyPed, "附近行人敌对此玩家")
    menu.toggle_loop(Trolling_NearbyPed, "开启", {}, "", function()
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local weapon_smoke = util.joaat("WEAPON_SMOKEGRENADE")
        for _, ped in pairs(GET_NEARBY_PEDS(pid, player_nearby_ped.radius)) do
            if not IS_PED_PLAYER(ped) and not PED.IS_PED_IN_COMBAT(ped, player_ped) then
                RequestControl(ped)

                WEAPON.GIVE_WEAPON_TO_PED(ped, weapon_smoke, -1, false, false)
                WEAPON.GIVE_WEAPON_TO_PED(ped, player_nearby_ped.combatweapon, -1, false, true)
                WEAPON.SET_CURRENT_PED_WEAPON(ped, player_nearby_ped.combat.weapon, false)
                WEAPON.SET_PED_DROPS_WEAPONS_WHEN_DEAD(ped, false)

                local health = ENTITY.GET_ENTITY_MAX_HEALTH(ped)
                ENTITY.SET_ENTITY_HEALTH(ped, health * player_nearby_ped.combat.health_mult)

                PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
                TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)

                disable_ped_flee_attributes(ped)

                TASK.TASK_COMBAT_PED(ped, player_ped, 0, 16)
                PED.SET_PED_KEEP_TASK(ped, true)

                --强化作战能力
                if player_nearby_ped.combat.is_enhance then
                    increase_ped_combat_ability(ped)
                    increase_ped_combat_attributes(ped)
                end
                --掉落现金为2000
                if player_nearby_ped.combat.is_drop_money then
                    PED.SET_PED_MONEY(ped, 2000)
                end
            end
        end
    end)

    menu.list_select(Trolling_NearbyPed, "设置武器", {}, "", Weapon_Common.ListItem, 1,
        function(value)
            player_nearby_ped.combat.weapon = util.joaat(Weapon_Common.ModelList[value])
        end)
    menu.toggle(Trolling_NearbyPed, "强化作战能力", {}, "如果npc会逃跑的话，开启这个",
        function(toggle)
            player_nearby_ped.combat.is_enhance = toggle
        end)
    menu.slider(Trolling_NearbyPed, "血量加倍", { "nearbyped_health_mult" }, "", 1, 100, 1, 1,
        function(value)
            player_nearby_ped.combat.health_mult = value
        end)
    menu.toggle(Trolling_NearbyPed, "掉落现金为2000", {}, "当做击杀奖励", function(toggle)
        player_nearby_ped.combat.is_drop_money = toggle
    end)


    menu.toggle_loop(Trolling_options, "循环举报", { "rs_report" }, "", function()
        if pid ~= players.user() then
            local player_name = players.get_name(pid)
            menu.trigger_commands("reportvcannoying " .. player_name)
            menu.trigger_commands("reportvchate " .. player_name)
            menu.trigger_commands("reportannoying " .. player_name)
            menu.trigger_commands("reporthate " .. player_name)
            menu.trigger_commands("reportexploits " .. player_name)
            menu.trigger_commands("reportbugabuse " .. player_name)
        end
        util.yield(500)
    end)

    --#endregion





    --#region 友好选项

    ----------------------------
    ---------- 友好选项 ---------
    ----------------------------

    local Friendly_options = menu.list(player_menu_root, "友好选项", {}, "")


    local Friendly_Generete_Pickup = menu.list(Friendly_options, "生成拾取物", {}, "似乎无用，只有你能看见")
    menu.action(Friendly_Generete_Pickup, "生成医药包", {}, "", function()
        local modelHash = util.joaat("prop_ld_health_pack")
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0.0, 0.0, 0.0)
        local pickupHash = 2406513688
        Create_Network_Pickup(pickupHash, coords.x, coords.y, coords.z, modelHash, 100)
    end)
    menu.action(Friendly_Generete_Pickup, "生成护甲", {}, "", function()
        local modelHash = util.joaat("prop_armour_pickup")
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0.0, 0.0, 0.0)
        local pickupHash = 1274757841
        Create_Network_Pickup(pickupHash, coords.x, coords.y, coords.z, modelHash, 100)
    end)
    menu.action(Friendly_Generete_Pickup, "生成零食(PQ豆)", {}, "", function()
        local modelHash = util.joaat("PROP_CHOC_PQ")
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0.0, 0.0, 0.0)
        local pickupHash = 483577702
        Create_Network_Pickup(pickupHash, coords.x, coords.y, coords.z, modelHash, 30)
    end)
    menu.action(Friendly_Generete_Pickup, "生成降落伞", {}, "", function()
        local modelHash = util.joaat("p_parachute_s_shop")
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0.0, 0.0, 0.0)
        local pickupHash = 1735599485
        Create_Network_Pickup(pickupHash, coords.x, coords.y, coords.z, modelHash, 2)
    end)
    menu.action(Friendly_Generete_Pickup, "生成呼吸器", {}, "", function()
        local modelHash = util.joaat("PROP_LD_HEALTH_PACK")
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0.0, 0.0, 0.0)
        local pickupHash = 3889104844
        Create_Network_Pickup(pickupHash, coords.x, coords.y, coords.z, modelHash, 20)
    end)
    menu.action(Friendly_Generete_Pickup, "生成火神机枪", {}, "", function()
        local modelHash = util.joaat("W_MG_Minigun")
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0.0, 0.0, 0.0)
        local pickupHash = 792114228
        Create_Network_Pickup(pickupHash, coords.x, coords.y, coords.z, modelHash, 100)

        modelHash = util.joaat("prop_ld_ammo_pack_02")
        pickupHash = 4065984953
        Create_Network_Pickup(pickupHash, coords.x, coords.y, coords.z, modelHash, 9999)
    end)


    menu.toggle_loop(Friendly_options, "循环称赞", {}, "", function()
        if pid ~= players.user() then
            local player_name = players.get_name(pid)
            menu.trigger_commands("commendhelpful " .. player_name)
            menu.trigger_commands("commendfriendly " .. player_name)
        end
        util.yield(500)
    end)

    --#endregion





    ----------------------------
    ---- 自定义Model生成实体 -----
    ----------------------------

    local Custom_Generate_Entity = menu.list(player_menu_root, "自定义Model生成实体", {}, "")
    local custom_generate_entity_data = {
        hash = 0,
        type = 1,
        x = 0.0,
        y = 0.0,
        z = 0.0,
        -- setting
        is_invincible = false,
        is_freeze = false,
        is_invisible = false,
        cant_migrate = false,
        no_collision = false,
        -- saved hash
        is_select = false,
        select_hash = 0,
        select_type = 1,
    }

    menu.text_input(Custom_Generate_Entity, "Model Hash ", { "generate_custom_model" }, "",
        function(value)
            custom_generate_entity_data.hash = tonumber(value)
        end)
    menu.action(Custom_Generate_Entity, "转换复制内容", {}, "删除Model Hash: \n便于直接粘贴Ctrl+V",
        function()
            local text = util.get_clipboard_text()
            local num = string.gsub(text, "Model Hash: ", "")
            util.copy_to_clipboard(num, false)
            util.toast("Copied!\n" .. num)
        end)

    local EntityType_ListItem = {
        { "Ped" },     --1
        { "Vehicle" }, --2
        { "Object" },  --3
    }
    menu.list_select(Custom_Generate_Entity, "实体类型", {}, "", EntityType_ListItem, 1,
        function(index)
            custom_generate_entity_data.type = index
        end)
    menu.slider_float(Custom_Generate_Entity, "左/右", { "generate_custom_model_x" }, "", -10000, 10000, 0, 50,
        function(value)
            custom_generate_entity_data.x = value * 0.01
        end)
    menu.slider_float(Custom_Generate_Entity, "前/后", { "generate_custom_model_y" }, "", -10000, 10000, 0, 50,
        function(value)
            custom_generate_entity_data.y = value * 0.01
        end)
    menu.slider_float(Custom_Generate_Entity, "上/下", { "generate_custom_model_z" }, "", -10000, 10000, 0, 50,
        function(value)
            custom_generate_entity_data.z = value * 0.01
        end)

    local Custom_Generate_Entity_Setting = menu.list(Custom_Generate_Entity, "属性", {}, "")
    menu.toggle(Custom_Generate_Entity_Setting, "无敌", {}, "", function(toggle)
        custom_generate_entity_data.is_invincible = toggle
    end)
    menu.toggle(Custom_Generate_Entity_Setting, "冻结", {}, "", function(toggle)
        custom_generate_entity_data.is_freeze = toggle
    end)
    menu.toggle(Custom_Generate_Entity_Setting, "不可见", {}, "", function(toggle)
        custom_generate_entity_data.is_invisible = toggle
    end)
    menu.toggle(Custom_Generate_Entity_Setting, "不可控制", {}, "", function(toggle)
        custom_generate_entity_data.cant_migrate = toggle
    end)
    menu.toggle(Custom_Generate_Entity_Setting, "无碰撞", {}, "", function(toggle)
        custom_generate_entity_data.no_collision = toggle
    end)

    --menu.divider(Custom_Generate_Entity, "")
    Custom_Generate_Entity_Saved = menu.list_select(Custom_Generate_Entity, "保存的Hash", {}, "",
        Saved_Hash_List.get_list_item_data2(), 1, function(value)
            if value == 1 then
                --None
                custom_generate_entity_data.is_select = false
            elseif value == 2 then
                --Refresh List
                custom_generate_entity_data.is_select = false

                menu.set_list_action_options(Custom_Generate_Entity_Saved, Saved_Hash_List.get_list_item_data2())
                util.toast("已刷新，请重新打开该列表")
            else
                custom_generate_entity_data.is_select = true

                local Name = Saved_Hash_List.get_list()[value - 2]
                local Hash, Type = Saved_Hash_List.read(Name)
                custom_generate_entity_data.select_hash = Hash
                custom_generate_entity_data.select_type = GET_ENTITY_TYPE_INDEX(Type)
            end
        end)

    menu.action(Custom_Generate_Entity, "生成实体", {}, "", function()
        local hash = custom_generate_entity_data.hash
        local Type = custom_generate_entity_data.type
        if custom_generate_entity_data.is_select then
            hash = custom_generate_entity_data.select_hash
            Type = custom_generate_entity_data.select_type
        end

        hash = tonumber(hash)
        if hash ~= nil and STREAMING.IS_MODEL_VALID(hash) then
            local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, custom_generate_entity_data.x,
                custom_generate_entity_data.y, custom_generate_entity_data.z)
            local heading = ENTITY.GET_ENTITY_HEADING(player_ped)

            local ent = 0
            if Type == 1 then
                ent = Create_Network_Ped(26, hash, coords.x, coords.y, coords.z, heading)
            elseif Type == 2 then
                ent = Create_Network_Vehicle(hash, coords.x, coords.y, coords.z, heading)
            elseif Type == 3 then
                ent = Create_Network_Object(hash, coords.x, coords.y, coords.z)
            else
                util.toast("无法生成该类型实体")
            end

            if ent ~= 0 then
                ENTITY.SET_ENTITY_INVINCIBLE(ent, custom_generate_entity_data.is_invincible)
                ENTITY.FREEZE_ENTITY_POSITION(ent, custom_generate_entity_data.is_freeze)
                ENTITY.SET_ENTITY_VISIBLE(ent, not custom_generate_entity_data.is_invisible, 0)
                if custom_generate_entity_data.cant_migrate then
                    entities.set_can_migrate(ent, false)
                end
                if custom_generate_entity_data.no_collision then
                    ENTITY.SET_ENTITY_COLLISION(ent, false, false)
                end
            end
        else
            util.toast("错误的Hash值")
        end
    end)





    ----------------------------
    ------- 以此玩家的名义 -------
    ----------------------------

    local As_This_Player = menu.list(player_menu_root, "以此玩家的名义", {}, "")

    menu.action(As_This_Player, "爆头击杀全部NPC", {}, "", function()
        local weaponHash = util.joaat("WEAPON_APPISTOL")
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        for _, ped in pairs(entities.get_all_peds_as_handles()) do
            if not IS_PED_PLAYER(ped) and not ENTITY.IS_ENTITY_DEAD(ped) then
                local head_pos = PED.GET_PED_BONE_COORDS(ped, 0x322c, 0, 0, 0)
                local vector = ENTITY.GET_ENTITY_FORWARD_VECTOR(ped)
                local start_pos = {}
                start_pos.x = head_pos.x + vector.x
                start_pos.y = head_pos.y + vector.y
                start_pos.z = head_pos.z + vector.z

                local ped_veh = GET_VEHICLE_PED_IS_IN(ped)
                if ped_veh ~= 0 then
                    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(
                        start_pos.x, start_pos.y, start_pos.z,
                        head_pos.x, head_pos.y, head_pos.z,
                        1000, false, weaponHash, player_ped,
                        false, false, 1000, ped_veh)
                else
                    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(
                        start_pos.x, start_pos.y, start_pos.z,
                        head_pos.x, head_pos.y, head_pos.z,
                        1000, false, weaponHash, player_ped,
                        false, false, 1000)
                end
            end
        end
    end)
    menu.action(As_This_Player, "爆炸全部NPC", {}, "隐形无声的爆炸", function()
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        for _, ped in pairs(entities.get_all_peds_as_handles()) do
            if not IS_PED_PLAYER(ped) and not ENTITY.IS_ENTITY_DEAD(ped) then
                local coords = ENTITY.GET_ENTITY_COORDS(ped)
                add_owned_explosion(player_ped, coords, 4, { isAudible = false, isInvisible = true })
            end
        end
    end)







    ---------- END ----------
end






players.on_join(Player_options)
players.dispatch_on_join()
