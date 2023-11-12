-------------------------------------------
-----------    Player Options    ----------
-------------------------------------------


players.add_command_hook(function(pid, player_root)
    local Player_Options <const> = menu.list(player_root, "RScript", {}, "")

    menu.divider(Player_Options, "RScript")



    -------------------------------
    --------    恶搞选项    --------
    -------------------------------

    local Trolling_Options <const> = menu.list(Player_Options, "恶搞选项", {}, "")

    menu.action(Trolling_Options, "小查攻击", {}, "", function()
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local modelHash = util.joaat("A_C_Chop")
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0.0, -1.0, 0.0)
        local heading = ENTITY.GET_ENTITY_HEADING(player_ped)

        local g_ped = create_ped(28, modelHash, coords, heading)

        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(g_ped, true)
        TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(g_ped, true)
        TASK.TASK_COMBAT_PED(g_ped, player_ped, 0, 16)
        PED.SET_PED_KEEP_TASK(g_ped, true)

        PED.SET_PED_MONEY(g_ped, 2000)
        ENTITY.SET_ENTITY_MAX_HEALTH(g_ped, 30000)
        SET_ENTITY_HEALTH(g_ped, 30000)

        increase_ped_combat_ability(g_ped, false, false)
        increase_ped_combat_attributes(g_ped)
    end)



    --------------------
    -- 虎鲸恶搞
    --------------------

    local Trolling_Kosatka = menu.list(Trolling_Options, "虎鲸恶搞", {}, "")

    --#region

    local spawned_kosatkas = {}

    menu.action(Trolling_Kosatka, "生成虎鲸", {}, "", function()
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local modelHash = util.joaat("kosatka")
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0.0, 0.0, 0.0)
        local heading = ENTITY.GET_ENTITY_HEADING(player_ped)

        local g_veh = create_vehicle(modelHash, coords, heading)

        set_entity_godmode(g_veh, true)
        entities.set_can_migrate(g_veh, false)

        table.insert(spawned_kosatkas, g_veh)
    end)

    local trace_kosatka = 0
    menu.toggle_loop(Trolling_Kosatka, "追踪生成虎鲸", {}, "", function()
        if players.exists(pid) then
            local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0.0, 0.0, 0.0)
            local heading = ENTITY.GET_ENTITY_HEADING(player_ped)

            if ENTITY.DOES_ENTITY_EXIST(trace_kosatka) then
                TP_ENTITY(trace_kosatka, coords)
            else
                trace_kosatka = create_vehicle(util.joaat("kosatka"), coords, heading)
                set_entity_godmode(trace_kosatka, true)
                entities.set_can_migrate(trace_kosatka, false)
            end
        end
    end, function()
        if ENTITY.DOES_ENTITY_EXIST(trace_kosatka) then
            entities.delete(trace_kosatka)
        end
    end)

    menu.divider(Trolling_Kosatka, "")
    menu.action(Trolling_Kosatka, "删除生成的虎鲸", {}, "", function()
        for _, ent in pairs(spawned_kosatkas) do
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                entities.delete(ent)
            end
        end
        spawned_kosatkas = {}
    end)

    --#endregion


    --------------------
    -- 传送实体到此玩家
    --------------------

    local TP_Entities = menu.list(Trolling_Options, "传送实体到此玩家", {}, "")

    --#region

    local tp_entities_data = {
        running = false,

        type_select = 1,
        exclude_mission = true,
        delay = 100,
        offset_x = 0.0,
        offset_y = 0.0,
        offset_z = 0.0,
    }

    menu.list_select(TP_Entities, "实体类型", {}, "", {
        "NPC", "载具", "物体", "拾取物"
    }, 1, function(value)
        tp_entities_data.type_select = value
    end)

    menu.action(TP_Entities, "传送实体到此玩家", {}, "附近实体", function()
        if tp_entities_data.running then
            util.toast("上次的还未传送完成呢")
        else
            if players.exists(pid) then
                tp_entities_data.running = true
                local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)

                local type_text = "NPC"
                local entity_list = entities.get_all_peds_as_handles()
                if tp_entities_data.type_select == 2 then
                    type_text = "载具"
                    entity_list = entities.get_all_vehicles_as_handles()
                elseif tp_entities_data.type_select == 3 then
                    type_text = "物体"
                    entity_list = entities.get_all_objects_as_handles()
                elseif tp_entities_data.type_select == 4 then
                    type_text = "拾取物"
                    entity_list = entities.get_all_pickups_as_handles()
                end

                local tp_num = 0
                for _, ent in pairs(entity_list) do
                    if tp_entities_data.running then
                        if tp_entities_data.exclude_mission and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
                        elseif ENTITY.IS_ENTITY_A_PED(ent) and is_player_ped(ent) then
                        elseif ENTITY.IS_ENTITY_A_VEHICLE(ent) and is_player_vehicle(ent) then
                        else
                            request_control(ent)
                            tp_entity_to_entity(ent, player_ped,
                                tp_entities_data.offset_x, tp_entities_data.offset_y, tp_entities_data.offset_z)

                            if has_control_entity(ent) then
                                tp_num = tp_num + 1
                            end
                        end
                        util.yield(tp_entities_data.delay)
                    else
                        break
                    end
                end

                util.toast("传送实体到玩家 " .. players.get_name(pid) ..
                    " 完成\n" .. type_text .. " 成功传送数量: " .. tp_num)
                tp_entities_data.running = false
            end
        end
    end)
    menu.action(TP_Entities, "停止传送", {}, "", function()
        tp_entities_data.running = false
    end)

    menu.divider(TP_Entities, "设置")
    menu.toggle(TP_Entities, "排除任务实体", {}, "", function()
        tp_entities_data.exclude_mission = value
    end, true)
    menu.slider(TP_Entities, "传送延时", { "tp_entities_delay" }, "单位: ms",
        0, 5000, 100, 100, function(value)
            tp_entities_data.delay = value
        end)
    menu.divider(TP_Entities, "偏移")
    menu.slider_float(TP_Entities, "前/后", { "tp_entities_offset_y" }, "",
        -10000, 1000, 0, 50, function(value)
            tp_entities_data.offset_y = value * 0.01
        end)
    menu.slider_float(TP_Entities, "左/右", { "tp_entities_offset_x" }, "",
        -10000, 1000, 0, 50, function(value)
            tp_entities_data.offset_x = value * 0.01
        end)
    menu.slider_float(TP_Entities, "上/下", { "tp_entities_offset_z" }, "",
        -10000, 1000, 0, 50, function(value)
            tp_entities_data.offset_z = value * 0.01
        end)

    --#endregion



    menu.toggle_loop(Trolling_Options, "循环举报", { "rs_report" }, "", function()
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




    -------------------------------
    --------    友好选项    --------
    -------------------------------

    local Friendly_Options <const> = menu.list(Player_Options, "友好选项", {}, "")

    menu.toggle_loop(Friendly_Options, "循环称赞", {}, "", function()
        if pid ~= players.user() then
            local player_name = players.get_name(pid)
            menu.trigger_commands("commendhelpful " .. player_name)
            menu.trigger_commands("commendfriendly " .. player_name)
        end
        util.yield(500)
    end)





    ------------------------------------
    --------    以此玩家的名义    --------
    ------------------------------------

    local As_This_Player = menu.list(Player_Options, "以此玩家的名义", {}, "")

    menu.action(As_This_Player, "爆头击杀全部NPC", {}, "", function()
        local weaponHash = util.joaat("WEAPON_APPISTOL")
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        for _, ped in pairs(entities.get_all_peds_as_handles()) do
            if not ENTITY.IS_ENTITY_DEAD(ped) and not is_player_ped(ped) then
                shoot_ped_head(ped, weaponHash, player_ped)
            end
        end
    end)
    menu.action(As_This_Player, "爆炸全部NPC", {}, "隐形无声的爆炸", function()
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        for _, ped in pairs(entities.get_all_peds_as_handles()) do
            if not ENTITY.IS_ENTITY_DEAD(ped) and not is_player_ped(ped) then
                local coords = ENTITY.GET_ENTITY_COORDS(ped)
                add_owned_explosion(player_ped, coords, 4, { isAudible = false, isInvisible = true })
            end
        end
    end)


    --
end)
