------------------------------------------
----------    Entity Options    ----------
------------------------------------------

local Entity_Options <const> = menu.list(Menu_Root, "实体选项", {}, "")


--#region Entity NPC Options

local Entity_NPC_Options <const> = menu.list(Entity_Options, "NPC选项", {}, "")

local tNPC = {
    ped_select = 1,
}

function tNPC.checkPed(ped, pedTypeSelect)
    if is_player_ped(ped) then
        return false
    end

    if pedTypeSelect == 1 and not is_friendly_ped(ped) then
        return true
    end

    if pedTypeSelect == 2 and is_hostile_ped(ped) then
        return true
    end

    if pedTypeSelect == 3 then
        return true
    end

    return false
end

menu.divider(Entity_NPC_Options, "全部NPC")
menu.list_select(Entity_NPC_Options, "NPC类型", {}, "", Misc_T.PedType, 1, function(value)
    tNPC.ped_select = value
end)

menu.action(Entity_NPC_Options, "删除", { "del_ped" }, "", function()
    for _, ped in pairs(entities.get_all_peds_as_handles()) do
        if tNPC.checkPed(ped, tNPC.ped_select) then
            entities.delete(ped)
        end
    end
end)
menu.action(Entity_NPC_Options, "死亡", { "dead_ped" }, "", function()
    for _, ped in pairs(entities.get_all_peds_as_handles()) do
        if not ENTITY.IS_ENTITY_DEAD(ped) and tNPC.checkPed(ped, tNPC.ped_select) then
            SET_ENTITY_HEALTH(ped, 0)
        end
    end
end)
menu.action(Entity_NPC_Options, "爆头击杀", { "kill_ped" }, "", function()
    local weaponHash = util.joaat("WEAPON_APPISTOL")
    for _, ped in pairs(entities.get_all_peds_as_handles()) do
        if not ENTITY.IS_ENTITY_DEAD(ped) and tNPC.checkPed(ped, tNPC.ped_select) then
            shoot_ped_head(ped, weaponHash, players.user_ped())
        end
    end
end)

menu.divider(Entity_NPC_Options, "警察和特警")
menu.toggle_loop(Entity_NPC_Options, "删除", { "del_cop" }, "", function()
    for _, ped_ptr in pairs(entities.get_all_peds_as_pointers()) do
        local hash = entities.get_model_hash(ped_ptr)
        if hash == 1581098148 or hash == -1320879687 or hash == -1920001264 then
            entities.delete(ped_ptr)
        end
    end
end)
menu.toggle_loop(Entity_NPC_Options, "死亡", { "dead_cop" }, "", function()
    for _, ped_ptr in pairs(entities.get_all_peds_as_pointers()) do
        local hash = entities.get_model_hash(ped_ptr)
        if hash == 1581098148 or hash == -1320879687 or hash == -1920001264 then
            rs_memory.set_entity_health(ped_ptr, 0)
        end
    end
end)

menu.divider(Entity_NPC_Options, "友方NPC")
menu.action(Entity_NPC_Options, "无敌强化", { "strong_friendly_ped" }, "", function()
    for _, ent in pairs(entities.get_all_peds_as_handles()) do
        if not ENTITY.IS_ENTITY_DEAD(ent) and not is_player_ped(ent) then
            local rel = PED.GET_RELATIONSHIP_BETWEEN_PEDS(ent, players.user_ped())
            if rel == 0 or rel == 1 then -- Respect or Like
                increase_ped_combat_ability(ent, true)
                increase_ped_combat_attributes(ent)
            end
        end
    end
end)
menu.list_action(Entity_NPC_Options, "给予武器", {}, "", RS_T.CommonWeapons, function(value)
    local weaponHash = value

    for _, ent in pairs(entities.get_all_peds_as_handles()) do
        if not ENTITY.IS_ENTITY_DEAD(ent) and not is_player_ped(ent) then
            local rel = PED.GET_RELATIONSHIP_BETWEEN_PEDS(ent, players.user_ped())
            if rel == 0 or rel == 1 then -- Respect or Like
                WEAPON.GIVE_WEAPON_TO_PED(ent, weaponHash, 9999, false, true)
                WEAPON.SET_CURRENT_PED_WEAPON(ent, weaponHash, false)
            end
        end
    end
end)

--#endregion


--#region NPC Weak Options

local NPC_Weak_Options <const> = menu.list(Entity_Options, "弱化NPC选项", {}, "")

tNPC.Weak = {
    ped_select = 1,
    time_delay = 2000,
    toggle = {
        health = false,
        weapon_damage = true,
        vehicle_weapon = false,
    },
}

menu.list_select(NPC_Weak_Options, "NPC类型", {}, "", Misc_T.PedType, 1, function(value)
    tNPC.Weak.ped_select = value
end)

menu.toggle_loop(NPC_Weak_Options, "弱化", { "weak_ped" }, "", function()
    local weak_health = 100
    local weak_weapon_damage = 0.01

    for _, ped in pairs(entities.get_all_peds_as_handles()) do
        if not ENTITY.IS_ENTITY_DEAD(ped) and tNPC.checkPed(ped, tNPC.Weak.ped_select) then
            if tNPC.Weak.toggle.health then
                if ENTITY.GET_ENTITY_HEALTH(ped) > weak_health then
                    SET_ENTITY_HEALTH(ped, weak_health)
                end
            end

            if tNPC.Weak.toggle.weapon_damage then
                PED.SET_COMBAT_FLOAT(ped, 29, weak_weapon_damage) -- WEAPON_DAMAGE_MODIFIER
            end

            PED.SET_PED_SHOOT_RATE(ped, 0)
            PED.SET_PED_ACCURACY(ped, 0)
            PED.SET_COMBAT_FLOAT(ped, 6, 0.0) -- WEAPON_ACCURACY
            PED.SET_PED_COMBAT_ABILITY(ped, 0)

            PED.STOP_PED_WEAPON_FIRING_WHEN_DROPPED(ped)
            PED.DISABLE_PED_INJURED_ON_GROUND_BEHAVIOUR(ped)

            if tNPC.Weak.toggle.vehicle_weapon then
                if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
                    local ped_veh = PED.GET_VEHICLE_PED_IS_IN(ped, false)
                    if VEHICLE.DOES_VEHICLE_HAVE_WEAPONS(ped_veh) then
                        local veh_weapon_hash = get_ped_vehicle_weapon(ped)
                        if veh_weapon_hash ~= 0 then
                            VEHICLE.DISABLE_VEHICLE_WEAPON(true, veh_weapon_hash, ped_veh, ped)
                        end
                    end
                end
            end
        end
    end

    util.yield(tNPC.Weak.time_delay)
end)

menu.divider(NPC_Weak_Options, "设置")

menu.toggle(NPC_Weak_Options, "弱化血量", {}, "修改血量为: 100", function(toggle)
    tNPC.Weak.toggle.health = toggle
end)
menu.toggle(NPC_Weak_Options, "弱化武器伤害", {}, "修改武器伤害为: 0.01", function(toggle)
    tNPC.Weak.toggle.weapon_damage = toggle
end, true)
menu.toggle(NPC_Weak_Options, "禁用载具武器", {}, "", function(toggle)
    tNPC.Weak.toggle.vehicle_weapon = toggle
end)
menu.slider(NPC_Weak_Options, "循环间隔", { "setting_weak_ped_time_delay" }, "单位: 毫秒",
    0, 5000, 2000, 100, function(value)
        tNPC.Weak.time_delay = value
    end)

menu.divider(NPC_Weak_Options, "其它(默认设置)")
menu.readonly(NPC_Weak_Options, "射击频率", "0")
menu.readonly(NPC_Weak_Options, "精准度", "0")
menu.readonly(NPC_Weak_Options, "作战技能", "弱")
menu.readonly(NPC_Weak_Options, "禁止武器掉落时走火", "是")
menu.readonly(NPC_Weak_Options, "禁止受伤倒地时的行为", "是")

--#endregion


--#region Entity Hostile Options

local Entity_Hostile_Options <const> = menu.list(Entity_Options, "敌对实体选项", {}, "")

menu.action(Entity_Hostile_Options, "爆炸敌对NPC", { "h_ped_explode" }, "", function()
    explode_hostile_peds()
end)
menu.action(Entity_Hostile_Options, "爆炸敌对载具", { "h_veh_explode" }, "", function()
    explode_hostile_vehicles()
end)
menu.action(Entity_Hostile_Options, "爆炸敌对物体", { "h_obj_explode" }, "", function()
    explode_hostile_objects()
end)

menu.divider(Entity_Hostile_Options, "")
menu.action(Entity_Hostile_Options, "破坏敌对载具引擎", { "h_veh_kill_engine" }, "", function()
    for _, vehicle in pairs(entities.get_all_vehicles_as_handles()) do
        if is_hostile_entity(vehicle) then
            VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, -4000.0)
        end
    end
end)
menu.action(Entity_Hostile_Options, "杀死敌对物体", { "h_obj_kill" }, "", function()
    for _, object in pairs(entities.get_all_objects_as_handles()) do
        if is_hostile_entity(object) then
            SET_ENTITY_HEALTH(object, 0)
        end
    end
end)

--#endregion


--#region Entity Vehicle Options

local Entity_Vehicle_Options <const> = menu.list(Entity_Options, "载具选项", {}, "")

local tEntityVehicle = {
    exceptPlayer = true,
}

function tEntityVehicle.checkVehicle(vehicle)
    if tEntityVehicle.exceptPlayer and is_player_vehicle(vehicle) then
        return false
    end

    return true
end

menu.divider(Entity_Vehicle_Options, "全部载具")

menu.action(Entity_Vehicle_Options, "解锁车门和打开引擎", { "unlock_vehs_door" }, "", function()
    for _, vehicle in pairs(entities.get_all_vehicles_as_handles()) do
        if tEntityVehicle.checkVehicle(vehicle) then
            unlock_vehicle_doors(vehicle)

            VEHICLE.SET_VEHICLE_IS_CONSIDERED_BY_PLAYER(vehicle, true)
            VEHICLE.SET_VEHICLE_UNDRIVEABLE(vehicle, false)
            VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, false)

            VEHICLE.SET_VEHICLE_IS_WANTED(vehicle, false)
            VEHICLE.SET_VEHICLE_INFLUENCES_WANTED_LEVEL(vehicle, false)
            VEHICLE.SET_VEHICLE_HAS_BEEN_OWNED_BY_PLAYER(vehicle, true)
            VEHICLE.SET_VEHICLE_IS_STOLEN(vehicle, false)
            VEHICLE.SET_POLICE_FOCUS_WILL_TRACK_VEHICLE(vehicle, false)

            ENTITY.FREEZE_ENTITY_POSITION(vehicle, false)
        end
    end
end)
menu.action(Entity_Vehicle_Options, "打开左右车门和引擎", { "open_vehs_door" }, "", function()
    for _, vehicle in pairs(entities.get_all_vehicles_as_handles()) do
        if tEntityVehicle.checkVehicle(vehicle) then
            VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, false)
            VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, 0, false, false)
            VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, 1, false, false)
        end
    end
end)
menu.action(Entity_Vehicle_Options, "拆下左右车门和打开引擎", { "broken_vehs_door" }, "", function()
    for _, vehicle in pairs(entities.get_all_vehicles_as_handles()) do
        if tEntityVehicle.checkVehicle(vehicle) then
            VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, false)
            VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, 0, false)
            VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, 1, false)
        end
    end
end)

menu.divider(Entity_Vehicle_Options, "设置")
menu.toggle(Entity_Vehicle_Options, "排除 玩家载具", {}, "", function(toggle)
    tEntityVehicle.exceptPlayer = toggle
end, true)

--#endregion


--#region Entity Pickup Options

local Entity_Pickup_Options <const> = menu.list(Entity_Options, "拾取物选项", {}, "")

local tEntityPickup = {
    mission = true,
}

menu.toggle(Entity_Pickup_Options, "任务拾取物", {}, "", function(toggle)
    tEntityPickup.mission = toggle
end, true)

menu.action(Entity_Pickup_Options, "全部传送到我", {}, "", function()
    for _, pickup in pairs(entities.get_all_pickups_as_handles()) do
        if tEntityPickup.mission and not ENTITY.IS_ENTITY_A_MISSION_ENTITY(pickup) then
            goto continue
        end

        OBJECT.SET_PICKUP_OBJECT_COLLECTABLE_IN_VEHICLE(pickup)
        tp_entity_to_me(pickup)

        ::continue::
    end
end)

--#endregion


--#region Entity Object Options

local Entity_Object_Options <const> = menu.list(Entity_Options, "摄像头和门", {}, "")

menu.divider(Entity_Object_Options, "摄像头")
local Cams = {
    548760764,   --prop_cctv_cam_01a
    -354221800,  --prop_cctv_cam_01b
    -1159421424, --prop_cctv_cam_02a
    1449155105,  --prop_cctv_cam_03a
    -1095296451, --prop_cctv_cam_04a
    -1884701657, --prop_cctv_cam_04c
    -173206916,  --prop_cctv_cam_05a
    168901740,   --prop_cctv_cam_06a
    -1340405475, --prop_cctv_cam_07a
    2090203758,  --prop_cs_cctv
    289451089,   --p_cctv_s
    -1007354661, --hei_prop_bank_cctv_01
    -1842407088, --hei_prop_bank_cctv_02
    -1233322078, --ch_prop_ch_cctv_cam_02a
    -247409812,  --xm_prop_x17_server_farm_cctv_01
    2135655372   --prop_cctv_pole_04
}
local Cams2 = {
    1919058329, --prop_cctv_cam_04b
    1849991131  --prop_snow_cam_03a
}
menu.action(Entity_Object_Options, "删除", { "del_cam" }, "", function()
    for _, obj_ptr in pairs(entities.get_all_objects_as_pointers()) do
        local hash = entities.get_model_hash(obj_ptr)
        for i = 1, #Cams do
            if hash == Cams[i] then
                entities.delete(obj_ptr)
            end
        end
    end
end)
menu.click_slider(Entity_Object_Options, "上下移动", { "move_cam" }, "易导致bug",
    -30, 30, 0, 1, function(value)
        for _, ent in pairs(entities.get_all_objects_as_handles()) do
            local EntityModel = ENTITY.GET_ENTITY_MODEL(ent)
            for i = 1, #Cams do
                if EntityModel == Cams[i] then
                    set_entity_move(ent, 0.0, 0.0, value)
                end
            end
        end
    end)

menu.divider(Entity_Object_Options, "佩里科岛的门（本地有效）")
local Perico_Doors = {
    -- 豪宅内 各种铁门
    -1052729812,                 -- h4_prop_h4_gate_l_01a
    1866987242,                  -- h4_prop_h4_gate_r_01a
    -1360938964,                 -- h4_prop_h4_gate_02a
    -2058786200,                 -- h4_prop_h4_gate_03a
    -630812075,                  -- h4_prop_h4_gate_05a
    -- 豪宅内 电梯门
    -1240156945,                 -- v_ilev_garageliftdoor
    -576022807,                  -- h4_prop_office_elevator_door_01
    -- 豪宅大门
    -1574151574,                 -- h4_prop_h4_gate_r_03a
    1215477734,                  -- h4_prop_h4_gate_l_03a
    -- 豪宅外 铁门
    227019171,                   -- prop_fnclink_02gate6_r
    1526539404,                  -- prop_fnclink_02gate6_l
    141297241,                   -- h4_prop_h4_garage_door_01a
    -1156020871                  -- prop_fnclink_03gate5
}
local Perico_Doors2 = -607013269 -- h4_prop_h4_door_01a 豪宅内的库房门

menu.action(Entity_Object_Options, "删除门", { "delete_perico_door" }, "", function()
    for _, ent in pairs(entities.get_all_objects_as_handles()) do
        local EntityModel = ENTITY.GET_ENTITY_MODEL(ent)
        for i = 1, #Perico_Doors do
            if EntityModel == Perico_Doors[i] then
                entities.delete(ent)
            end
        end
    end
end)
menu.action(Entity_Object_Options, "开启无碰撞", {}, "可以直接穿过门，包括库房门", function()
    for _, ent in pairs(entities.get_all_objects_as_handles()) do
        local EntityModel = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityModel == Perico_Doors2 then
            ENTITY.SET_ENTITY_COLLISION(ent, false, true)
        else
            for i = 1, #Perico_Doors do
                if EntityModel == Perico_Doors[i] then
                    ENTITY.SET_ENTITY_COLLISION(ent, false, true)
                end
            end
        end
    end
end)
menu.action(Entity_Object_Options, "关闭无碰撞", {}, "", function()
    for _, ent in pairs(entities.get_all_objects_as_handles()) do
        local EntityModel = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityModel == Perico_Doors2 then
            ENTITY.SET_ENTITY_COLLISION(ent, true, true)
        else
            for i = 1, #Perico_Doors do
                if EntityModel == Perico_Doors[i] then
                    ENTITY.SET_ENTITY_COLLISION(ent, true, true)
                end
            end
        end
    end
end)

--#endregion


--#region Nearby Area Options

local Nearby_Area_Options <const> = menu.list(Entity_Options, "附近区域选项", {}, "")

local NearbyArea = {
    radius = 100.0,
    target = {
        ped = 2,
        vehicle = 1,
        object = 1,
    },
    except = {
        dead = true,
        mission = false,
    },
}

function NearbyArea.CheckDistance(entity, playerPos)
    local radius = NearbyArea.radius

    if radius <= 0 then
        return true
    end

    if v3.distance(ENTITY.GET_ENTITY_COORDS(entity), playerPos) <= radius then
        return true
    end

    return false
end

function NearbyArea.CheckExcept(entity)
    if NearbyArea.except.dead and ENTITY.IS_ENTITY_DEAD(entity) then
        return false
    end
    if NearbyArea.except.mission and ENTITY.IS_ENTITY_A_MISSION_ENTITY(entity) then
        return false
    end

    return true
end

function NearbyArea.CheckPed(ped)
    if not NearbyArea.CheckExcept(ped) then
        return false
    end

    if is_player_ped(ped) then
        return false
    end

    local target_select = NearbyArea.target.ped
    if target_select == 2 and not is_friendly_ped(ped) then
        return true
    end
    if target_select == 3 and is_hostile_ped(ped) then
        return true
    end
    if target_select == 4 and not PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
        return true
    end
    if target_select == 5 and PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
        return true
    end
    if target_select == 6 then
        return true
    end

    return false
end

function NearbyArea.CheckVehicle(vehicle)
    if not NearbyArea.CheckExcept(vehicle) then
        return false
    end

    if is_player_vehicle(vehicle) then
        return false
    end

    local target_select = NearbyArea.target.vehicle
    if target_select == 2 then
        return true
    end
    if target_select == 3 and is_hostile_entity(vehicle) then
        return true
    end
    if target_select == 4 and not VEHICLE.IS_VEHICLE_SEAT_FREE(vehicle, -1, false) then
        return true
    end
    if target_select == 5 and VEHICLE.IS_VEHICLE_SEAT_FREE(vehicle, -1, false) then
        return true
    end

    return false
end

function NearbyArea.CheckObject(object)
    if not NearbyArea.CheckExcept(object) then
        return false
    end

    local target_select = NearbyArea.target.object

    if target_select == 4 and ENTITY.IS_ENTITY_A_MISSION_ENTITY(object) then
        return true
    end

    local blip = HUD.GET_BLIP_FROM_ENTITY(object)
    if not HUD.DOES_BLIP_EXIST(blip) then
        return false
    end

    if target_select == 2 and is_hostile_entity(object) then
        return true
    end
    if target_select == 3 then
        return true
    end

    return false
end

function NearbyArea.GetEntities()
    local entity_list = {}

    local player_pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())

    if NearbyArea.target.ped > 1 then
        for _, ent in pairs(entities.get_all_peds_as_handles()) do
            if NearbyArea.CheckDistance(ent, player_pos) then
                if NearbyArea.CheckPed(ent) then
                    table.insert(entity_list, ent)
                end
            end
        end
    end

    if NearbyArea.target.vehicle > 1 then
        for _, ent in pairs(entities.get_all_vehicles_as_handles()) do
            if NearbyArea.CheckDistance(ent, player_pos) then
                if NearbyArea.CheckVehicle(ent) then
                    table.insert(entity_list, ent)
                end
            end
        end
    end

    if NearbyArea.target.object > 1 then
        for _, ent in pairs(entities.get_all_objects_as_handles()) do
            if NearbyArea.CheckDistance(ent, player_pos) then
                if NearbyArea.CheckObject(ent) then
                    table.insert(entity_list, ent)
                end
            end
        end
    end

    return entity_list
end

----------------
-- Setting
----------------
menu.slider_float(Nearby_Area_Options, "范围半径", { "radius_nearby_area" }, "",
    0, 100000, 10000, 1000, function(value)
        NearbyArea.radius = value * 0.01
    end)
menu.toggle_loop(Nearby_Area_Options, "绘制范围", {}, "", function()
    local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    DRAW_MARKER_SPHERE(coords, NearbyArea.radius)
end)

local Nearby_Area_Setting <const> = menu.list(Nearby_Area_Options, "设置", {}, "")

menu.divider(Nearby_Area_Setting, "目标")
menu.list_select(Nearby_Area_Setting, "NPC", {}, "", {
    { 1, "关闭", },
    { 2, "全部NPC (排除友好)", },
    { 3, "敌对NPC", },
    { 4, "步行NPC", },
    { 5, "载具内NPC", },
    { 6, "全部NPC", },
}, 2, function(value)
    NearbyArea.target.ped = value
end)
menu.list_select(Nearby_Area_Setting, "载具", {}, "默认排除玩家载具", {
    { 1, "关闭", },
    { 2, "全部载具", {}, "" },
    { 3, "敌对载具", {}, "敌对NPC驾驶或者有敌对地图标识的载具" },
    { 4, "NPC载具", {}, "有NPC作为司机驾驶的载具" },
    { 5, "空载具", {}, "没有任何NPC驾驶的载具" },
}, 1, function(value)
    NearbyArea.target.vehicle = value
end)
menu.list_select(Nearby_Area_Setting, "物体", {}, "", {
    { 1, "关闭" },
    { 2, "敌对物体", {}, "有敌对地图标记点的物体" },
    { 3, "标记点物体", {}, "有地图标记点的物体" },
    { 4, "任务物体", {}, "" },
}, 1, function(value)
    NearbyArea.target.object = value
end)

menu.divider(Nearby_Area_Setting, "排除")
menu.toggle(Nearby_Area_Setting, "排除 死亡实体", {}, "", function(toggle)
    NearbyArea.except.dead = toggle
end, true)
menu.toggle(Nearby_Area_Setting, "排除 任务实体", {}, "", function(toggle)
    NearbyArea.except.mission = toggle
end)

menu.divider(Nearby_Area_Options, "")

--#region Nearby Area Shoot

local Nearby_Area_Shoot <const> = menu.list(Nearby_Area_Options, "射击区域", {}, "若半径是0,则为全部范围")

local NearbyAreaShoot = {
    shootPedHead = true,
    weaponHash = "PLAYER_CURRENT_WEAPON",
    isOwned = true,
    damage = 1000,
    speed = 2000,
    perfectAccuracy = true,
    createTraceVfx = true,
    allowRumble = true,
    startFromPlayer = false,
    offset = v3(0, 0, 0.1),
    delay = 1000,
}

function NearbyAreaShoot.Shoot(startPos, endPos, weaponHash, targetEntity)
    local owner = 0
    if NearbyAreaShoot.isOwned then
        owner = players.user_ped()
    end

    local ignoreEntity = entities.get_user_vehicle_as_handle(false)
    if ignoreEntity == INVALID_GUID then
        ignoreEntity = players.user_ped()
    end

    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(
        startPos.x, startPos.y, startPos.z,
        endPos.x, endPos.y, endPos.z,
        NearbyAreaShoot.damage,
        NearbyAreaShoot.perfectAccuracy,
        weaponHash,
        owner,
        NearbyAreaShoot.createTraceVfx,
        NearbyAreaShoot.allowRumble,
        NearbyAreaShoot.speed,
        ignoreEntity,
        targetEntity)
end

function NearbyAreaShoot.Handle(action)
    local user_ped = players.user_ped()

    local weaponHash = NearbyAreaShoot.weaponHash
    if weaponHash == "PLAYER_CURRENT_WEAPON" then
        weaponHash = WEAPON.GET_SELECTED_PED_WEAPON(user_ped)
    end
    if not WEAPON.HAS_WEAPON_ASSET_LOADED(weaponHash) then
        request_weapon_asset(weaponHash)
    end

    local player_pos = ENTITY.GET_ENTITY_COORDS(user_ped)
    local offset = NearbyAreaShoot.offset
    local start_pos, ent_pos

    for _, ent in pairs(NearbyArea.GetEntities()) do
        ent_pos = ENTITY.GET_ENTITY_COORDS(ent)
        if ENTITY.IS_ENTITY_A_PED(ent) and NearbyAreaShoot.shootPedHead then
            ent_pos = PED.GET_PED_BONE_COORDS(ent, 0x322c, 0, 0, 0)
        end

        if NearbyAreaShoot.startFromPlayer then
            start_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(user_ped, offset.x, offset.y, offset.z)
        elseif ENTITY.IS_ENTITY_A_PED(ent) and NearbyAreaShoot.shootPedHead then
            -- offsetX: up/down, offsetY: forward/backward, offsetZ: left/right
            start_pos = PED.GET_PED_BONE_COORDS(ent, 0x322c, offset.z, offset.y, offset.x)
        else
            start_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, offset.x, offset.y, offset.z)
        end

        if action == "drawline" then
            DRAW_LINE(start_pos, ent_pos)
        else
            NearbyAreaShoot.Shoot(start_pos, ent_pos, weaponHash, ent)
        end
    end
end

----------------
-- Setting
----------------

local Nearby_Area_ShootSetting <const> = menu.list(Nearby_Area_Shoot, "设置", {}, "")

menu.toggle(Nearby_Area_ShootSetting, "射击NPC头部", {}, "", function(toggle)
    NearbyAreaShoot.shootPedHead = toggle
end, true)

local Nearby_Area_ShootWeapon <const> = rs_menu.all_weapons_without_melee(Nearby_Area_ShootSetting, "武器", {}, "",
    function(hash)
        NearbyAreaShoot.weaponHash = hash
    end, true)
rs_menu.current_weapon_action(Nearby_Area_ShootWeapon, "玩家当前使用的武器", function()
    NearbyAreaShoot.weaponHash = "PLAYER_CURRENT_WEAPON"
end, true)

menu.toggle(Nearby_Area_ShootSetting, "署名射击", {}, "以玩家名义", function(toggle)
    NearbyAreaShoot.isOwned = toggle
end, true)
menu.slider(Nearby_Area_ShootSetting, "伤害", { "nearby_area_shoot_damage" }, "", 0, 10000, 1000, 100,
    function(value)
        NearbyAreaShoot.damage = value
    end)
menu.slider(Nearby_Area_ShootSetting, "速度", { "nearby_area_shoot_speed" }, "", 0, 10000, 2000, 100,
    function(value)
        NearbyAreaShoot.speed = value
    end)

menu.divider(Nearby_Area_ShootSetting, "起始射击位置偏移")
menu.toggle(Nearby_Area_ShootSetting, "从玩家位置起始射击", {},
    "如果关闭,则起始位置为目标位置+偏移\n如果开启,建议偏移Z>1.0", function(toggle)
        NearbyAreaShoot.startFromPlayer = toggle
    end)
menu.slider_float(Nearby_Area_ShootSetting, "左/右", { "nearby_area_shoot_x" }, "", -10000, 10000, 0, 10,
    function(value)
        NearbyAreaShoot.offset.x = value * 0.01
    end)
menu.slider_float(Nearby_Area_ShootSetting, "前/后", { "nearby_area_shoot_y" }, "", -10000, 10000, 0, 10,
    function(value)
        NearbyAreaShoot.offset.y = value * 0.01
    end)
menu.slider_float(Nearby_Area_ShootSetting, "上/下", { "nearby_area_shoot_z" }, "", -10000, 10000, 10, 10,
    function(value)
        NearbyAreaShoot.offset.z = value * 0.01
    end)

----------------
-- Main
----------------

menu.toggle_loop(Nearby_Area_Shoot, "绘制模拟射击连线", {}, "", function()
    NearbyAreaShoot.Handle("drawline")
end)
menu.divider(Nearby_Area_Shoot, "")
menu.action(Nearby_Area_Shoot, "射击", { "shoot_nearby_area" }, "", function()
    NearbyAreaShoot.Handle()
end)
menu.slider(Nearby_Area_Shoot, "循环延迟", { "nearby_area_shoot_delay" }, "单位: ms",
    0, 5000, 1000, 100, function(value)
        NearbyAreaShoot.delay = value
    end)
menu.toggle_loop(Nearby_Area_Shoot, "循环射击", {}, "", function()
    NearbyAreaShoot.Handle()
    util.yield(NearbyAreaShoot.delay)
end)

--#endregion Nearby Area Shoot


--#region Nearby Area Explosion

local Nearby_Area_Explosion <const> = menu.list(Nearby_Area_Options, "爆炸区域", {}, "若半径是0,则为全部范围")

local NearbyAreaExplosion = {
    explosionType = 2,
    isOwned = true,
    damage = 1000,
    isAudible = true,
    isInvisible = false,
    cameraShake = 0,
    offset = v3(0, 0, 0),
    delay = 1000,
}

function NearbyAreaExplosion.Explosion(pos)
    if NearbyAreaExplosion.isOwned then
        FIRE.ADD_OWNED_EXPLOSION(players.user_ped(),
            pos.x, pos.y, pos.z,
            NearbyAreaExplosion.explosionType,
            NearbyAreaExplosion.damage,
            NearbyAreaExplosion.isAudible,
            NearbyAreaExplosion.isInvisible,
            NearbyAreaExplosion.cameraShake)
    else
        FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z,
            NearbyAreaExplosion.explosionType,
            NearbyAreaExplosion.damage,
            NearbyAreaExplosion.isAudible,
            NearbyAreaExplosion.isInvisible,
            NearbyAreaExplosion.cameraShake,
            false)
    end
end

function NearbyAreaExplosion.Handle(action)
    local player_pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    local offset = NearbyAreaExplosion.offset

    for _, ent in pairs(NearbyArea.GetEntities()) do
        local ent_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, offset.x, offset.y, offset.z)

        if action == "drawline" then
            DRAW_LINE(player_pos, ent_pos)
        else
            NearbyAreaExplosion.Explosion(ent_pos)
        end
    end
end

----------------
-- Setting
----------------

local Nearby_Area_ExplosionSetting <const> = menu.list(Nearby_Area_Explosion, "设置", {}, "")

menu.list_select(Nearby_Area_ExplosionSetting, "爆炸类型", {}, "", Misc_T.ExplosionType, 4, function(value)
    NearbyAreaExplosion.explosionType = value
end)
menu.toggle(Nearby_Area_ExplosionSetting, "署名爆炸", {}, "以玩家名义", function(toggle)
    NearbyAreaExplosion.isOwned = toggle
end, true)
menu.slider(Nearby_Area_ExplosionSetting, "伤害", { "nearby_area_explosion_damage" }, "", 0, 10000, 1000, 100,
    function(value)
        NearbyAreaExplosion.damage = value
    end)
menu.toggle(Nearby_Area_ExplosionSetting, "可听见", {}, "", function(toggle)
    NearbyAreaExplosion.isAudible = toggle
end, true)
menu.toggle(Nearby_Area_ExplosionSetting, "不可见", {}, "", function(toggle)
    NearbyAreaExplosion.isInvisible = toggle
end)

menu.divider(Nearby_Area_ExplosionSetting, "位置偏移")
menu.slider_float(Nearby_Area_ExplosionSetting, "左/右", { "nearby_area_explosion_x" }, "",
    -10000, 10000, 0, 10, function(value)
        NearbyAreaExplosion.offset.x = value * 0.01
    end)
menu.slider_float(Nearby_Area_ExplosionSetting, "前/后", { "nearby_area_explosion_y" }, "",
    -10000, 10000, 0, 10, function(value)
        NearbyAreaExplosion.offset.y = value * 0.01
    end)
menu.slider_float(Nearby_Area_ExplosionSetting, "上/下", { "nearby_area_explosion_z" }, "",
    -10000, 10000, 0, 10, function(value)
        NearbyAreaExplosion.offset.z = value * 0.01
    end)


----------------
-- Main
----------------

menu.toggle_loop(Nearby_Area_Explosion, "连线指示实体", {}, "", function()
    NearbyAreaExplosion.Handle("drawline")
end)
menu.divider(Nearby_Area_Explosion, "")
menu.action(Nearby_Area_Explosion, "爆炸", { "explosion_nearby_area" }, "", function()
    NearbyAreaExplosion.Handle()
end)
menu.slider(Nearby_Area_Explosion, "循环延迟", { "nearby_area_explosion_delay" }, "单位: ms",
    0, 5000, 1000, 100, function(value)
        NearbyAreaExplosion.delay = value
    end)
menu.toggle_loop(Nearby_Area_Explosion, "循环爆炸", {}, "", function()
    NearbyAreaExplosion.Handle()
    util.yield(NearbyAreaExplosion.delay)
end)

--#endregion Nearby Area Explosion


menu.action(Nearby_Area_Options, "击杀区域", { "kill_nearby_area" }, "", function()
    for _, ent in pairs(NearbyArea.GetEntities()) do
        SET_ENTITY_HEALTH(ent, 0)
        if ENTITY.IS_ENTITY_A_VEHICLE(ent) then
            VEHICLE.SET_VEHICLE_ENGINE_HEALTH(ent, -4000.0)
        end
    end
end)


--#endregion Nearby Area Options









menu.divider(Entity_Options, "")


Entity_Info = {}

function Entity_Info.GetEntityInfo(entity)
    if not ENTITY.DOES_ENTITY_EXIST(entity) then
        return nil
    end

    local all_info = {}

    all_info.entity = Entity_Info.EntityInfo(entity)

    if ENTITY.IS_ENTITY_A_PED(entity) then
        all_info.ped = Entity_Info.PedInfo(entity)
    end

    if ENTITY.IS_ENTITY_A_VEHICLE(entity) then
        all_info.vehicle = Entity_Info.VehicleInfo(entity)
    end

    return all_info
end

function Entity_Info.EntityInfo(entity)
    local entity_info = {
        main = {}
    }

    local info = {} -- name, value
    local t = ""

    local model_hash = ENTITY.GET_ENTITY_MODEL(entity)

    -- Model Name
    local model_name = util.reverse_joaat(model_hash)
    if model_name ~= "" then
        info = { "Model Name", model_name }
        table.insert(entity_info.main, info)
    end

    -- Model Hash
    info = { "Model Hash", model_hash }
    table.insert(entity_info.main, info)

    -- Entity Type
    local entity_type = get_entity_type(entity)
    info = { "Entity Type", entity_type }
    table.insert(entity_info.main, info)

    -- Mission Entity
    t = bool_to_string(ENTITY.IS_ENTITY_A_MISSION_ENTITY(entity), "True", "False")
    info = { "Mission Entity", t }
    table.insert(entity_info.main, info)

    -- Health
    t = ENTITY.GET_ENTITY_HEALTH(entity) .. "/" .. ENTITY.GET_ENTITY_MAX_HEALTH(entity)
    info = { "Health", t }
    table.insert(entity_info.main, info)

    -- Dead
    if ENTITY.IS_ENTITY_DEAD(entity) then
        info = { "Dead", "True" }
        table.insert(entity_info.main, info)
    end

    -- Position
    local ent_pos = ENTITY.GET_ENTITY_COORDS(entity)
    t = round(ent_pos.x, 4) .. ", " ..
        round(ent_pos.y, 4) .. ", " ..
        round(ent_pos.z, 4)
    info = { "Coords", t }
    table.insert(entity_info.main, info)

    local my_pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())

    -- Heading
    t = round(ENTITY.GET_ENTITY_HEADING(entity), 4)
    info = { "Entity Heading", t }
    table.insert(entity_info.main, info)

    t = round(ENTITY.GET_ENTITY_HEADING(players.user_ped()), 4)
    info = { "Player Heading", t }
    table.insert(entity_info.main, info)

    -- Distance
    local distance = Vector.dist(my_pos, ent_pos)
    info = { "Distance", round(distance, 4) }
    table.insert(entity_info.main, info)

    -- Subtract with player position
    local pos_sub = Vector.subtract(my_pos, ent_pos)
    t = round(pos_sub.x, 2) .. ", " ..
        round(pos_sub.y, 2) .. ", " ..
        round(pos_sub.z, 2)
    info = { "Subtract Coords", t }
    table.insert(entity_info.main, info)

    -- Speed
    local speed = ENTITY.GET_ENTITY_SPEED(entity)
    info = { "Speed", round(speed, 2) }
    table.insert(entity_info.main, info)

    -- Networked Entity
    t = bool_to_string(NETWORK.NETWORK_GET_ENTITY_IS_NETWORKED(entity), "Networked", "Local")
    info = { "Networked Entity", t }
    table.insert(entity_info.main, info)

    -- Owner
    local owner = entities.get_owner(entity)
    info = { "Owner", players.get_name(owner) }
    table.insert(entity_info.main, info)

    -- Script
    local entity_script = GET_ENTITY_SCRIPT(entity)
    if entity_script ~= nil then
        info = { "Script", entity_script }
        table.insert(entity_info.main, info)
    end


    --------    Blip    --------

    local blip = HUD.GET_BLIP_FROM_ENTITY(entity)
    if HUD.DOES_BLIP_EXIST(blip) then
        entity_info.blip = {}

        -- Blip Sprite
        local blip_sprite = HUD.GET_BLIP_SPRITE(blip)
        info = { "Blip Sprite", blip_sprite }
        table.insert(entity_info.blip, info)

        -- Blip Colour
        local blip_colour = HUD.GET_BLIP_COLOUR(blip)
        info = { "Blip Colour", blip_colour }
        table.insert(entity_info.blip, info)

        -- Blip HUD Colour
        local blip_hud_colour = HUD.GET_BLIP_HUD_COLOUR(blip)
        info = { "Blip HUD Colour", blip_hud_colour }
        table.insert(entity_info.blip, info)

        -- Blip Alpha
        local blip_alpha = HUD.GET_BLIP_ALPHA(blip)
        info = { "Blip Alpha", blip_alpha }
        table.insert(entity_info.blip, info)

        -- Blip Rotation
        local blip_rotation = HUD.GET_BLIP_ROTATION(blip)
        info = { "Blip Rotation", blip_rotation }
        table.insert(entity_info.blip, info)

        -- Blip Is Short Range
        info = { "Short Range", bool_to_string(HUD.IS_BLIP_SHORT_RANGE(blip), "True", "False") }
        table.insert(entity_info.blip, info)

        -- Blip Scale
        local ptr = util.blip_handle_to_pointer(blip)
        local blip_scale_x = memory.read_float(ptr + 0x50)
        local blip_scale_y = memory.read_float(ptr + 0x54)
        info = { "Blip Scale X", blip_scale_x }
        table.insert(entity_info.blip, info)

        info = { "Blip Scale Y", blip_scale_y }
        table.insert(entity_info.blip, info)
    end


    --------    Attached    --------

    if ENTITY.IS_ENTITY_ATTACHED(entity) then
        entity_info.attached = {}

        local attached_entity = ENTITY.GET_ENTITY_ATTACHED_TO(entity)
        local attached_hash = ENTITY.GET_ENTITY_MODEL(attached_entity)

        -- Model Name
        local attached_model_name = util.reverse_joaat(attached_hash)
        if attached_model_name ~= "" then
            info = { "Model Name", attached_model_name }
            table.insert(entity_info.attached, info)
        end

        -- Model Hash
        info = { "Model Hash", attached_hash }
        table.insert(entity_info.attached, info)

        -- Entity Type
        info = { "Entity Type", get_entity_type(attached_entity) }
        table.insert(entity_info.attached, info)
    end


    --------    Other    --------

    entity_info.other = {}

    -- Alpha
    local alpha = ENTITY.GET_ENTITY_ALPHA(entity)
    info = { "Alpha", round(alpha, 4) }
    table.insert(entity_info.other, info)

    -- Pitch
    local pitch = ENTITY.GET_ENTITY_PITCH(entity)
    info = { "Pitch", round(pitch, 4) }
    table.insert(entity_info.other, info)

    -- Roll
    local roll = ENTITY.GET_ENTITY_ROLL(entity)
    info = { "Roll", round(roll, 4) }
    table.insert(entity_info.other, info)

    -- Upright Value
    local upright_value = ENTITY.GET_ENTITY_UPRIGHT_VALUE(entity)
    info = { "Upright Value", round(upright_value, 4) }
    table.insert(entity_info.other, info)

    -- Height Above Ground
    local height_above_ground = ENTITY.GET_ENTITY_HEIGHT_ABOVE_GROUND(entity)
    info = { "Height Above Ground", round(height_above_ground, 4) }
    table.insert(entity_info.other, info)


    return entity_info
end

function Entity_Info.PedInfo(ped)
    local ped_info = {
        main = {}
    }

    local info = {} -- name, value
    local t = ""

    local model_hash = ENTITY.GET_ENTITY_MODEL(ped)

    -- Director Name
    local director_name = Ped_T.DirectorName[model_hash]
    if director_name ~= nil then
        info = { "Director Name", util.get_label_text(director_name) }
        table.insert(ped_info.main, info)
    end

    -- Ped Type
    local ped_type = PED.GET_PED_TYPE(ped)
    info = { "Ped Type", Ped_T.Type[ped_type] }
    table.insert(ped_info.main, info)

    -- Vehicle
    if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(ped, false)
        info = { "Vehicle", get_vehicle_display_name(vehicle) }
        table.insert(ped_info.main, info)
    end

    -- Money
    info = { "Money", PED.GET_PED_MONEY(ped) }
    table.insert(ped_info.main, info)

    -- Alertness
    local alertness = PED.GET_PED_ALERTNESS(ped)
    info = { "Alertness", Ped_T.Alertness[alertness] }
    table.insert(ped_info.main, info)


    --------    Dead    --------
    if PED.IS_PED_DEAD_OR_DYING(ped, 1) then
        ped_info.dead = {}

        local cause_model_hash = PED.GET_PED_CAUSE_OF_DEATH(ped)

        -- Cause of Death Model
        local cause_model_name = util.reverse_joaat(cause_model_hash)
        if cause_model_name ~= "" then
            info = { "Cause of Death Model", cause_model_name }
            table.insert(ped_info.dead, info)
        end

        -- Cause of Death Hash
        info = { "Cause of Death Hash", cause_model_hash }
        table.insert(ped_info.dead, info)

        -- Death Time
        info = { "Death Time", PED.GET_PED_TIME_OF_DEATH(ped) }
        table.insert(ped_info.dead, info)
    end


    --------    Relationship & Group    --------

    ped_info.rel_group = {}

    -- Relationship
    local rel = PED.GET_RELATIONSHIP_BETWEEN_PEDS(ped, players.user_ped())
    info = { "Relationship", Ped_T.RelationshipType[rel] }
    table.insert(ped_info.rel_group, info)

    -- Relationship Group Hash
    local rel_group_hash = PED.GET_PED_RELATIONSHIP_GROUP_HASH(ped)
    info = { "Relationship Group Hash", rel_group_hash }
    table.insert(ped_info.rel_group, info)

    -- Player Relationship Group Hash
    local my_rel_group_hash = PED.GET_PED_RELATIONSHIP_GROUP_HASH(players.user_ped())
    info = { "Player Relationship Group Hash", my_rel_group_hash }
    table.insert(ped_info.rel_group, info)

    -- Group Relationship
    local group_rel = PED.GET_RELATIONSHIP_BETWEEN_GROUPS(rel_group_hash, my_rel_group_hash)
    info = { "Group Relationship", Ped_T.RelationshipType[group_rel] }
    table.insert(ped_info.rel_group, info)

    -- Group
    if PED.IS_PED_IN_GROUP(ped) then
        local group_id = PED.GET_PED_GROUP_INDEX(ped)
        info = { "Group Index", group_id }
        table.insert(ped_info.rel_group, info)

        local follow_player = PED.GET_PLAYER_PED_IS_FOLLOWING(ped)
        if players.exists(follow_player) then
            info = { "Following Player", players.get_name(follow_player) }
            table.insert(ped_info.rel_group, info)
        end
    end


    --------    Combat    --------

    ped_info.combat = Entity_Info.PedCombatInfo(ped)


    return ped_info
end

function Entity_Info.PedCombatInfo(ped)
    local ped_combat_info = {}

    local info = {} -- name, value

    -- Accuracy
    info = { "Accuracy", PED.GET_PED_ACCURACY(ped) }
    table.insert(ped_combat_info, info)

    -- Combat Movement
    local combat_movement = PED.GET_PED_COMBAT_MOVEMENT(ped)
    info = { "Combat Movement", Ped_T.CombatMovement[combat_movement] }
    table.insert(ped_combat_info, info)

    -- Combat Range
    local combat_range = PED.GET_PED_COMBAT_RANGE(ped)
    info = { "Combat Range", Ped_T.CombatRange[combat_range] }
    table.insert(ped_combat_info, info)


    --------    Combat Float    --------

    for index, value in pairs(Ped_T.CombatFloat.List) do
        local name = value[1]
        local id = Ped_T.CombatFloat.ValueList[index]
        -- local comment = value[2]

        info = { name, PED.GET_COMBAT_FLOAT(ped, id) }
        table.insert(ped_combat_info, info)
    end


    return ped_combat_info
end

function Entity_Info.VehicleInfo(vehicle)
    local vehicle_info = {
        main = {}
    }

    local info = {} -- name, value
    local t = ""

    local model_hash = ENTITY.GET_ENTITY_MODEL(vehicle)

    -- Display Name
    local display_name = util.get_label_text(VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(model_hash))
    if display_name ~= "NULL" then
        info = { "Display Name", display_name }
        table.insert(vehicle_info.main, info)
    end

    -- Vehicle Class
    local vehicle_class = util.get_label_text("VEH_CLASS_" .. VEHICLE.GET_VEHICLE_CLASS(vehicle))
    info = { "Vehicle Class", vehicle_class }
    table.insert(vehicle_info.main, info)

    -- Door Lock Status
    local door_lock_status = VEHICLE.GET_VEHICLE_DOOR_LOCK_STATUS(vehicle)
    info = { "Door Lock Status", Vehicle_T.DoorLockStatus[door_lock_status] }
    table.insert(vehicle_info.main, info)

    -- Engine Health
    info = { "Engine Health", VEHICLE.GET_VEHICLE_ENGINE_HEALTH(vehicle) }
    table.insert(vehicle_info.main, info)

    -- Body Health
    info = { "Body Health", VEHICLE.GET_VEHICLE_BODY_HEALTH(vehicle) }
    table.insert(vehicle_info.main, info)

    -- Petrol Tank Health
    info = { "Petrol Tank Health", VEHICLE.GET_VEHICLE_PETROL_TANK_HEALTH(vehicle) }
    table.insert(vehicle_info.main, info)

    -- Driver
    local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1, false)
    if driver ~= 0 then
        local driver_hash = ENTITY.GET_ENTITY_MODEL(driver)
        local driver_model = util.reverse_joaat(driver_hash)

        info = { "Driver", driver_hash }
        if driver_model ~= "" then
            info = { "Driver", driver_model }
        end
        table.insert(vehicle_info.main, info)
    end

    -- Passengers
    local passengers = VEHICLE.GET_VEHICLE_NUMBER_OF_PASSENGERS(vehicle, false, true)
    if passengers > 0 then
        info = { "Passengers", passengers }
        table.insert(vehicle_info.main, info)
    end

    -- Max Passengers
    info = { "Max Passengers", VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(vehicle) }
    table.insert(vehicle_info.main, info)

    -- Seats Number
    info = { "Seats Number", VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(model_hash) }
    table.insert(vehicle_info.main, info)


    --------    Heli    --------

    if VEHICLE.IS_THIS_MODEL_A_HELI(model_hash) then
        vehicle_info.heli = {}

        -- Main Rotor Health
        info = { "Heli Main Rotor Health", VEHICLE.GET_HELI_MAIN_ROTOR_HEALTH(vehicle) }
        table.insert(vehicle_info.heli, info)

        -- Tail Rotor Health
        info = { "Heli Tail Rotor Health", VEHICLE.GET_HELI_TAIL_ROTOR_HEALTH(vehicle) }
        table.insert(vehicle_info.heli, info)

        -- Boom Rotor Health
        info = { "Heli Boom Rotor Health", VEHICLE.GET_HELI_TAIL_BOOM_HEALTH(vehicle) }
        table.insert(vehicle_info.heli, info)
    end


    return vehicle_info
end

function Entity_Info.GetBaseInfo(entity)
    if not ENTITY.DOES_ENTITY_EXIST(entity) then
        return nil
    end

    local base_info = {
        entity = {}
    }

    local t = ""
    local info = {} -- { name, value }


    local model_hash = ENTITY.GET_ENTITY_MODEL(entity)

    -- Model Name
    local model_name = util.reverse_joaat(model_hash)
    if model_name ~= "" then
        info = { "Model Name", model_name }
        table.insert(base_info.entity, info)
    end

    -- Model Hash
    info = { "Model Hash", model_hash }
    table.insert(base_info.entity, info)

    -- Entity Type
    local entity_type = get_entity_type(entity)
    info = { "Entity Type", entity_type }
    table.insert(base_info.entity, info)

    -- Mission Entity
    t = bool_to_string(ENTITY.IS_ENTITY_A_MISSION_ENTITY(entity), "True", "False")
    info = { "Mission Entity", t }
    table.insert(base_info.entity, info)

    -- Health
    t = ENTITY.GET_ENTITY_HEALTH(entity) .. "/" .. ENTITY.GET_ENTITY_MAX_HEALTH(entity)
    info = { "Health", t }
    table.insert(base_info.entity, info)

    -- Dead
    if ENTITY.IS_ENTITY_DEAD(entity) then
        info = { "Dead", "True" }
        table.insert(base_info.entity, info)
    end

    -- Position
    local ent_pos = ENTITY.GET_ENTITY_COORDS(entity)
    t = round(ent_pos.x, 4) .. ", " ..
        round(ent_pos.y, 4) .. ", " ..
        round(ent_pos.z, 4)
    info = { "Coords", t }
    table.insert(base_info.entity, info)

    local my_pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())

    -- Heading
    t = round(ENTITY.GET_ENTITY_HEADING(entity), 4)
    info = { "Entity Heading", t }
    table.insert(base_info.entity, info)

    t = round(ENTITY.GET_ENTITY_HEADING(players.user_ped()), 4)
    info = { "Player Heading", t }
    table.insert(base_info.entity, info)

    -- Distance
    local distance = Vector.dist(my_pos, ent_pos)
    info = { "Distance", round(distance, 4) }
    table.insert(base_info.entity, info)

    -- Subtract with player position
    local pos_sub = Vector.subtract(my_pos, ent_pos)
    t = round(pos_sub.x, 2) .. ", " ..
        round(pos_sub.y, 2) .. ", " ..
        round(pos_sub.z, 2)
    info = { "Subtract Coords", t }
    table.insert(base_info.entity, info)

    -- Speed
    local speed = ENTITY.GET_ENTITY_SPEED(entity)
    info = { "Speed", round(speed, 2) }
    table.insert(base_info.entity, info)

    -- Networked Entity
    t = bool_to_string(NETWORK.NETWORK_GET_ENTITY_IS_NETWORKED(entity), "Networked", "Local")
    info = { "Networked Entity", t }
    table.insert(base_info.entity, info)

    -- Owner
    local owner = entities.get_owner(entity)
    info = { "Owner", players.get_name(owner) }
    table.insert(base_info.entity, info)

    -- Script
    local entity_script = GET_ENTITY_SCRIPT(entity)
    if entity_script ~= nil then
        info = { "Script", entity_script }
        table.insert(base_info.entity, info)
    end


    --------    Blip    --------

    local blip = HUD.GET_BLIP_FROM_ENTITY(entity)
    if HUD.DOES_BLIP_EXIST(blip) then
        -- Blip Sprite
        local blip_sprite = HUD.GET_BLIP_SPRITE(blip)
        info = { "Blip Sprite", blip_sprite }
        table.insert(base_info.entity, info)

        -- Blip Colour
        local blip_colour = HUD.GET_BLIP_COLOUR(blip)
        info = { "Blip Colour", blip_colour }
        table.insert(base_info.entity, info)

        -- Blip HUD Colour
        local blip_hud_colour = HUD.GET_BLIP_HUD_COLOUR(blip)
        info = { "Blip HUD Colour", blip_hud_colour }
        table.insert(base_info.entity, info)
    end

    --------    Attached    --------

    if ENTITY.IS_ENTITY_ATTACHED(entity) then
        local attached_entity = ENTITY.GET_ENTITY_ATTACHED_TO(entity)
        local attached_hash = ENTITY.GET_ENTITY_MODEL(attached_entity)

        -- Model Name
        local attached_model_name = util.reverse_joaat(attached_hash)
        if attached_model_name ~= "" then
            info = { "Attached Model Name", attached_model_name }
            table.insert(base_info.entity, info)
        end

        -- Model Hash
        info = { "Attached Model Hash", attached_hash }
        table.insert(base_info.entity, info)

        -- Entity Type
        info = { "Attached Entity Type", get_entity_type(attached_entity) }
        table.insert(base_info.entity, info)
    end


    --------    Ped    --------

    if ENTITY.IS_ENTITY_A_PED(entity) then
        base_info.ped = {}

        -- Director Name
        local director_name = Ped_T.DirectorName[model_hash]
        if director_name ~= nil then
            director_name = util.get_label_text(director_name)
            if director_name ~= "NULL" then
                info = { "Director Name", director_name }
                table.insert(base_info.ped, info)
            end
        end

        -- Ped Type
        local ped_type = PED.GET_PED_TYPE(entity)
        info = { "Ped Type", Ped_T.Type[ped_type] }
        table.insert(base_info.ped, info)

        -- Vehicle
        if PED.IS_PED_IN_ANY_VEHICLE(entity, false) then
            local vehicle = PED.GET_VEHICLE_PED_IS_IN(entity, false)
            info = { "Vehicle", get_vehicle_display_name(vehicle) }
            table.insert(base_info.ped, info)
        end
    end


    --------    Vehicle    --------

    if ENTITY.IS_ENTITY_A_VEHICLE(entity) then
        base_info.vehicle = {}

        -- Display Name
        local display_name = util.get_label_text(VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(model_hash))
        if display_name ~= "NULL" then
            info = { "Display Name", display_name }
            table.insert(base_info.vehicle, info)
        end

        -- Vehicle Class
        local vehicle_class = util.get_label_text("VEH_CLASS_" .. VEHICLE.GET_VEHICLE_CLASS(entity))
        info = { "Vehicle Class", vehicle_class }
        table.insert(base_info.vehicle, info)

        -- Door Lock Status
        local door_lock_status = VEHICLE.GET_VEHICLE_DOOR_LOCK_STATUS(entity)
        info = { "Door Lock Status", Vehicle_T.DoorLockStatus[door_lock_status] }
        table.insert(base_info.vehicle, info)

        -- Engine Health
        info = { "Engine Health", VEHICLE.GET_VEHICLE_ENGINE_HEALTH(entity) }
        table.insert(base_info.vehicle, info)

        -- Body Health
        info = { "Body Health", VEHICLE.GET_VEHICLE_BODY_HEALTH(entity) }
        table.insert(base_info.vehicle, info)

        -- Driver
        local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(entity, -1, false)
        if driver ~= 0 then
            local driver_hash = ENTITY.GET_ENTITY_MODEL(driver)
            local driver_model = util.reverse_joaat(driver_hash)

            info = { "Driver", driver_hash }
            if driver_model ~= "" then
                info = { "Driver", driver_model }
            end
            table.insert(base_info.vehicle, info)
        end
    end

    return base_info
end

function Entity_Info.GetBaseInfoText(entity)
    local ent_info = Entity_Info.GetBaseInfo(entity)
    if ent_info == nil then
        return ""
    end

    local text = ""

    for key, item in pairs(ent_info.entity) do
        local line = item[1] .. ": " .. tostring(item[2])
        text = text .. line .. "\n"
    end

    if ent_info.ped then
        text = text .. "\n--------   Ped   --------\n"

        for key, item in pairs(ent_info.ped) do
            local line = item[1] .. ": " .. tostring(item[2])
            text = text .. line .. "\n"
        end
    end

    if ent_info.vehicle then
        text = text .. "\n--------   Vehicle   --------\n"

        for key, item in pairs(ent_info.vehicle) do
            local line = item[1] .. ": " .. tostring(item[2])
            text = text .. line .. "\n"
        end
    end

    return text
end

function Entity_Info.GetBaseInfoListItem(entity)
    local ent_info = Entity_Info.GetBaseInfo(entity)
    if ent_info == nil then
        return nil
    end

    local list_item = {}
    local t = { "" }

    for key, item in pairs(ent_info.entity) do
        t = { item[1] .. ": " .. item[2] }
        table.insert(list_item, t)
    end

    if ent_info.ped then
        table.insert(list_item, { "---   Ped   ---" })

        for key, item in pairs(ent_info.ped) do
            t = { item[1] .. ": " .. item[2] }
            table.insert(list_item, t)
        end
    end

    if ent_info.vehicle then
        table.insert(list_item, { "---   Vehicle   ---" })

        for key, item in pairs(ent_info.vehicle) do
            t = { item[1] .. ": " .. item[2] }
            table.insert(list_item, t)
        end
    end

    return list_item
end

--

--#region Entity Info

local Entity_Info_Options <const> = menu.list(Entity_Options, "实体信息", {}, "")

local tEntityInfo = {
    targetEntity = 0,
    infoText = "",


    entityType = "All",
    showToggles = {
        base = true,
        entity = false,
        ped = false,
        vehicle = false,
    },
}

function tEntityInfo.drawText(text, x, y, scale, margin, text_colour, background_colour)
    x = x or 0.5
    y = y or 0.0
    scale = scale or 0.5
    margin = margin or 0.01
    text_colour = text_colour or { r = 1.0, g = 1.0, b = 1.0, a = 1.0 }
    background_colour = background_colour or { r = 0.0, g = 0.0, b = 0.0, a = 0.6 }

    local text_width, text_height = directx.get_text_size(text, scale)

    directx.draw_rect(x - margin, y, text_width + margin * 2, text_height + margin * 2, background_colour)
    directx.draw_text(x, y + margin, text, ALIGN_TOP_LEFT, scale, text_colour)
end

function tEntityInfo.addText(tbl, text)
    if tbl then
        for key, item in pairs(tbl) do
            local line = item[1] .. ": " .. tostring(item[2])
            text = text .. line .. "\n"
        end
    end
    return text
end

function tEntityInfo.generateMenuActions(menu_parent, tbl)
    if tbl then
        for key, item in pairs(tbl) do
            local menu_name = item[1] .. ": " .. item[2]
            menu.action(menu_parent, menu_name, {}, "", function()
                util.copy_to_clipboard(menu_name, false)
                util.toast("已复制到剪贴板:\n" .. menu_name)
            end)
        end
    end
end

function tEntityInfo.generateMenus()
    if tEntityInfo.targetEntity == 0 then return end

    local ent_info = Entity_Info.GetEntityInfo(tEntityInfo.targetEntity)
    if ent_info == nil then
        util.toast("实体已经不存在")
        return
    end

    local menu_parent = tEntityInfo.menuList

    -- Clear Old Menus
    local children = menu.get_children(menu_parent)
    for key, value in pairs(children) do
        menu.delete(value)
    end


    if tEntityInfo.showToggles.base then
        local menu_base_info = menu.list(menu_parent, "通用基本 信息", {}, "")

        local base_info = Entity_Info.GetBaseInfo(tEntityInfo.targetEntity)

        tEntityInfo.generateMenuActions(menu_base_info, base_info.entity)

        if base_info.ped then
            menu.divider(menu_base_info, "Ped")
            tEntityInfo.generateMenuActions(menu_base_info, base_info.ped)
        end
        if base_info.vehicle then
            menu.divider(menu_base_info, "Vehicle")
            tEntityInfo.generateMenuActions(menu_base_info, base_info.vehicle)
        end
    end

    if tEntityInfo.showToggles.entity and ent_info.entity then
        local menu_entity_info = menu.list(menu_parent, "Entity 信息", {}, "")

        tEntityInfo.generateMenuActions(menu_entity_info, ent_info.entity.main)

        if ent_info.entity.blip then
            menu.divider(menu_entity_info, "Blip")
            tEntityInfo.generateMenuActions(menu_entity_info, ent_info.entity.blip)
        end
        if ent_info.entity.attached then
            menu.divider(menu_entity_info, "Attached")
            tEntityInfo.generateMenuActions(menu_entity_info, ent_info.entity.attached)
        end
        if ent_info.entity.other then
            menu.divider(menu_entity_info, "Other")
            tEntityInfo.generateMenuActions(menu_entity_info, ent_info.entity.other)
        end
    end

    if tEntityInfo.showToggles.ped and ent_info.ped then
        local menu_ped_info = menu.list(menu_parent, "Ped 信息", {}, "")

        tEntityInfo.generateMenuActions(menu_ped_info, ent_info.ped.main)

        if ent_info.ped.dead then
            menu.divider(menu_ped_info, "Dead")
            tEntityInfo.generateMenuActions(menu_ped_info, ent_info.ped.dead)
        end
        if ent_info.ped.rel_group then
            menu.divider(menu_ped_info, "Relationship & Group")
            tEntityInfo.generateMenuActions(menu_ped_info, ent_info.ped.rel_group)
        end
        if ent_info.ped.combat then
            menu.divider(menu_ped_info, "Combat")
            tEntityInfo.generateMenuActions(menu_ped_info, ent_info.ped.combat)
        end
    end

    if tEntityInfo.showToggles.vehicle and ent_info.vehicle then
        local menu_vehicle_info = menu.list(menu_parent, "Vehicle 信息", {}, "")

        tEntityInfo.generateMenuActions(menu_vehicle_info, ent_info.vehicle.main)

        if ent_info.vehicle.heli then
            menu.divider(menu_vehicle_info, "Heli")
            tEntityInfo.generateMenuActions(menu_vehicle_info, ent_info.vehicle.heli)
        end
    end
end

menu.toggle_loop(Entity_Info_Options, "获取目标实体信息[E键]", {}, "", function()
    Loop_Handler.draw_centred_point(true)

    local result = get_raycast_result(1500, -1)
    if result.didHit then
        local player_pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        local draw_line_colour = { r = 255, g = 0, b = 255, a = 255 }

        local ent = result.hitEntity
        local ent_type = get_entity_type(ent)
        if ent_type ~= "No Entity" then
            draw_line_colour = { r = 0, g = 255, b = 0, a = 255 }
        end
        DRAW_LINE(player_pos, result.endCoords, draw_line_colour)


        if PAD.IS_CONTROL_PRESSED(0, 51) then
            if ent_type ~= "No Entity" then
                if tEntityInfo.entityType ~= "All" and tEntityInfo.entityType ~= ent_type then
                    tEntityInfo.targetEntity = 0
                    return
                end
                tEntityInfo.targetEntity = ent
            end
        end
    end

    if tEntityInfo.targetEntity ~= 0 then
        local ent_info = Entity_Info.GetEntityInfo(tEntityInfo.targetEntity)
        if ent_info == nil then
            util.toast("实体已经不存在")
            tEntityInfo.targetEntity = 0
            return
        end

        local text = ""

        if tEntityInfo.showToggles.base then
            local base_info = Entity_Info.GetBaseInfo(tEntityInfo.targetEntity)
            text = tEntityInfo.addText(base_info.entity, text)
            text = tEntityInfo.addText(base_info.ped, text)
            text = tEntityInfo.addText(base_info.vehicle, text)
        end

        if tEntityInfo.showToggles.entity and ent_info.entity then
            text = tEntityInfo.addText(ent_info.entity.main, text)
            text = tEntityInfo.addText(ent_info.entity.blip, text)
            text = tEntityInfo.addText(ent_info.entity.attached, text)
            text = tEntityInfo.addText(ent_info.entity.other, text)
        end

        if tEntityInfo.showToggles.ped and ent_info.ped then
            text = tEntityInfo.addText(ent_info.ped.main, text)
            text = tEntityInfo.addText(ent_info.ped.dead, text)
            text = tEntityInfo.addText(ent_info.ped.rel_group, text)
            text = tEntityInfo.addText(ent_info.ped.combat, text)
        end

        if tEntityInfo.showToggles.vehicle and ent_info.vehicle then
            text = tEntityInfo.addText(ent_info.vehicle.main, text)
            text = tEntityInfo.addText(ent_info.vehicle.heli, text)
        end

        if text ~= "" then
            tEntityInfo.drawText(text)
            tEntityInfo.infoText = text
        end
    end
end, function()
    Loop_Handler.draw_centred_point(false)
    tEntityInfo.targetEntity = 0
end)

menu.list_select(Entity_Info_Options, "实体类型", {}, "", Misc_T.EntityTypeAll, 1, function(index, name)
    tEntityInfo.entityType = name
end)


tEntityInfo.menuList = menu.list(Entity_Info_Options, "查看实体信息", {}, "重新打开列表来刷新信息",
    function()
        tEntityInfo.generateMenus()
    end)

menu.textslider_stateful(Entity_Info_Options, "复制实体信息", {}, "", {
    "仅复制", "输出到日志"
}, function(value)
    util.copy_to_clipboard(tEntityInfo.infoText, false)
    if value == 2 then
        util.log(tEntityInfo.infoText)
    end
    util.toast("完成")
end)


menu.divider(Entity_Info_Options, "显示内容")
menu.toggle(Entity_Info_Options, "通用基本 信息", {}, "", function(toggle)
    tEntityInfo.showToggles.base = toggle
end, true)
menu.toggle(Entity_Info_Options, "Entity 信息", {}, "", function(toggle)
    tEntityInfo.showToggles.entity = toggle
end)
menu.toggle(Entity_Info_Options, "Ped 信息", {}, "", function(toggle)
    tEntityInfo.showToggles.ped = toggle
end)
menu.toggle(Entity_Info_Options, "Vehicle 信息", {}, "", function(toggle)
    tEntityInfo.showToggles.vehicle = toggle
end)

--#endregion Entity Info


--#region Entity Control

local Entity_Control_Options <const> = menu.list(Entity_Options, "实体控制", {}, "")

local tEntityControl = {
    entityType = "All",
}

function tEntityControl.GenerateMenuHead(menu_parent, entity)
    menu.action(menu_parent, "检测该实体是否存在", {}, "", function()
        if ENTITY.DOES_ENTITY_EXIST(entity) then
            util.toast("实体存在")
        else
            util.toast("该实体已经不存在，请删除此条实体记录！")
        end
    end)

    menu.action(menu_parent, "删除此条实体记录", {}, "", function()
        tEntityControl.entity_menu_list[entity] = nil
        tEntityControl.entity_list[entity] = nil

        tEntityControl.entity_count = tEntityControl.entity_count - 1
        if tEntityControl.entity_count <= 0 then
            tEntityControl.ClearListData()
        else
            menu.set_menu_name(tEntityControl.count_divider,
                "实体列表 (" .. tEntityControl.entity_count .. ")")
        end

        menu.delete(menu_parent)
    end)
end

-- 初始化数据
function tEntityControl.InitListData()
    -- 实体 list
    tEntityControl.entity_list = {}
    -- 实体的 menu.list()
    tEntityControl.entity_menu_list = {}
    -- 实体索引
    tEntityControl.entity_index = 1
    -- 实体数量
    tEntityControl.entity_count = 0
end

tEntityControl.InitListData()

-- 清理并初始化数据
function tEntityControl.ClearListData()
    -- 实体的 menu.list()
    for k, v in pairs(tEntityControl.entity_menu_list) do
        if v ~= nil and menu.is_ref_valid(v) then
            menu.delete(v)
        end
    end
    -- 初始化
    tEntityControl.InitListData()
    menu.set_menu_name(tEntityControl.count_divider, "实体列表")
end

menu.toggle_loop(Entity_Control_Options, "控制目标实体[E键]", {}, "", function()
    Loop_Handler.draw_centred_point(true)

    local result = get_raycast_result(1500, -1)
    if result.didHit then
        local player_pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        local draw_line_colour = { r = 255, g = 0, b = 255, a = 255 }

        local ent = result.hitEntity
        local ent_type = get_entity_type(ent)
        if ent_type ~= "No Entity" then
            draw_line_colour = { r = 0, g = 255, b = 0, a = 255 }
        end
        DRAW_LINE(player_pos, result.endCoords, draw_line_colour)


        if PAD.IS_CONTROL_PRESSED(0, 51) then
            if ent_type ~= "No Entity" then
                if tEntityControl.entityType ~= "All" and tEntityControl.entityType ~= ent_type then
                    return
                end

                if tEntityControl.entity_list[ent] == nil then
                    -- 添加到实体列表
                    tEntityControl.entity_list[ent] = ent

                    local menu_name, help_text = Entity_Control.GetMenuInfo(ent, tEntityControl.entity_index)
                    util.toast(menu_name .. "\n" .. help_text)

                    -- 实体的 menu.list()
                    local menu_list = menu.list(Entity_Control_Options, menu_name, {}, help_text)
                    tEntityControl.entity_menu_list[ent] = menu_list

                    -- 创建对应实体的menu操作
                    tEntityControl.GenerateMenuHead(menu_list, ent)
                    Entity_Control.GenerateMenu(menu_list, ent, tEntityControl.entity_index)

                    tEntityControl.entity_index = tEntityControl.entity_index + 1 -- 实体索引

                    -- 实体数量
                    tEntityControl.entity_count = tEntityControl.entity_count + 1
                    if tEntityControl.entity_count == 0 then
                        menu.set_menu_name(tEntityControl.count_divider, "实体列表")
                    else
                        menu.set_menu_name(tEntityControl.count_divider,
                            "实体列表 (" .. tEntityControl.entity_count .. ")")
                    end
                end
            end
        end
    end
end, function()
    Loop_Handler.draw_centred_point(false)
end)

menu.list_select(Entity_Control_Options, "实体类型", {}, "", Misc_T.EntityTypeAll, 1, function(index, name)
    tEntityControl.entityType = name
end)

menu.action(Entity_Control_Options, "清空列表", {}, "", function()
    tEntityControl.ClearListData()
    Loop_Handler.Entity.ClearToggles()
end)

tEntityControl.count_divider = menu.divider(Entity_Control_Options, "实体列表")

--#endregion


--#region Manage All Entity

local Manage_All_Entity <const> = menu.list(Entity_Options, "管理全部实体", { "manage_all_entity" }, "")

local All_Entity = {
    -- 实体类型
    entityType = "Ped",

    -- 筛选设置
    filter = {
        mission = 2,
        distance = 0,
        blip = 1,
        move = 1,
        attached = 1,
        ped = {
            except_player = true,
            combat = 1,
            relationship = 1,
            state = 1,
            armed = 1,
        },
        vehicle = {
            driver = 1,
            type = 1,
        },
        hash = {
            toggle = false,
            value = "",
        }
    },

    -- 排序方式
    sortMethod = 1,
}

menu.list_select(Manage_All_Entity, "实体类型", {}, "", Misc_T.EntityType, 1, function(value, name)
    All_Entity.entityType = name
end)


----------------
-- 筛选设置
----------------
local Manage_All_Entity_Filter <const> = menu.list(Manage_All_Entity, "筛选设置", {}, "")

menu.list_select(Manage_All_Entity_Filter, "任务实体", {}, "",
    { { 1, "关闭" }, { 2, "是" }, { 3, "否" } }, 2, function(value)
        All_Entity.filter.mission = value
    end)
menu.slider_float(Manage_All_Entity_Filter, "范围", { "all_entity_distance" }, "和玩家之间的距离是否在范围之内\n0表示全部范围",
    0, 100000, 0, 100, function(value)
        All_Entity.filter.distance = value * 0.01
    end)
menu.list_select(Manage_All_Entity_Filter, "地图标记点", {}, "",
    { { 1, "关闭" }, { 2, "有" }, { 3, "没有" } }, 1, function(value)
        All_Entity.filter.blip = value
    end)
menu.list_select(Manage_All_Entity_Filter, "移动状态", {}, "",
    { { 1, "关闭" }, { 2, "静止" }, { 3, "正在移动" } }, 1, function(value)
        All_Entity.filter.move = value
    end)
menu.list_select(Manage_All_Entity_Filter, "Attached", {}, "",
    { { 1, "关闭" }, { 2, "是" }, { 3, "否" } }, 1, function(value)
        All_Entity.filter.attached = value
    end)

menu.divider(Manage_All_Entity_Filter, "Ped")
menu.toggle(Manage_All_Entity_Filter, "排除玩家", {}, "", function(toggle)
    All_Entity.filter.ped.except_player = toggle
end, true)
menu.list_select(Manage_All_Entity_Filter, "与玩家敌对", {}, "",
    { { 1, "关闭" }, { 2, "是" }, { 3, "否" } }, 1, function(value)
        All_Entity.filter.ped.combat = value
    end)
menu.list_select(Manage_All_Entity_Filter, "关系", {}, "",
    { { 1, "关闭" }, { 2, "尊重/喜欢" }, { 3, "忽略" }, { 4, "不喜欢/讨厌" }, { 5, "通缉" }, { 6, "无" } }, 1,
    function(value)
        All_Entity.filter.ped.relationship = value
    end)
menu.list_select(Manage_All_Entity_Filter, "状态", {}, "",
    { { 1, "关闭" }, { 2, "步行" }, { 3, "载具内" }, { 4, "已死亡" }, { 5, "正在射击" } }, 1, function(value)
        All_Entity.filter.ped.state = value
    end)
menu.list_select(Manage_All_Entity_Filter, "装备武器", {}, "",
    { { 1, "关闭" }, { 2, "是" }, { 3, "否" } }, 1, function(value)
        All_Entity.filter.ped.armed = value
    end)

menu.divider(Manage_All_Entity_Filter, "Vehicle")
menu.list_select(Manage_All_Entity_Filter, "司机", {}, "",
    { { 1, "关闭" }, { 2, "没有" }, { 3, "NPC" }, { 4, "玩家" } }, 1, function(value)
        All_Entity.filter.vehicle.driver = value
    end)
menu.list_select(Manage_All_Entity_Filter, "类型", {}, "",
    { { 1, "关闭" }, { 2, "Car" }, { 3, "Bike" }, { 4, "Bicycle" }, { 5, "Heli" }, { 6, "Plane" }, { 7, "Boat" } },
    1, function(value)
        All_Entity.filter.vehicle.type = value
    end)

menu.divider(Manage_All_Entity_Filter, "Hash")
menu.toggle(Manage_All_Entity_Filter, "筛选 Hash", {}, "", function(toggle)
    All_Entity.filter.hash.toggle = toggle
end)
menu.text_input(Manage_All_Entity_Filter, "Hash", { "all_entity_hash" }, "Input Hash(integer) or Model(string)",
    function(value)
        All_Entity.filter.hash.value = value
    end)


----------------
-- 排序方式
----------------
menu.list_select(Manage_All_Entity, "排序方式", {}, "", {
    { 1, "无" }, { 2, "距离 (近 -> 远)" }, { 3, "速度 (快 -> 慢)" }
}, 1, function(value)
    All_Entity.sortMethod = value
end)



-- 检查筛选设置输入的Hash
function All_Entity.CheckHashInput()
    if not All_Entity.filter.hash.toggle then
        return true
    end

    local hash_value = All_Entity.filter.hash.value

    if hash_value == "" then
        return false
    end

    if tonumber(hash_value) == nil then
        hash_value = util.joaat(hash_value)
    end

    if not STREAMING.IS_MODEL_VALID(hash_value) then
        return false
    end

    All_Entity.filter.hash.value = tonumber(hash_value)
    return true
end

-- 检查是否符合筛选条件
function All_Entity.CheckFilter(ent)
    local hash = ENTITY.GET_ENTITY_MODEL(ent)

    -- 筛选Hash
    if All_Entity.filter.hash.toggle then
        if All_Entity.filter.hash.value ~= hash then
            return false
        end
    end

    -- 任务实体
    if All_Entity.filter.mission > 1 then
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            if All_Entity.filter.mission ~= 2 then
                return false
            end
        else
            if All_Entity.filter.mission ~= 3 then
                return false
            end
        end
    end
    -- 范围
    if All_Entity.filter.distance > 0 then
        local my_pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        local ent_pos = ENTITY.GET_ENTITY_COORDS(ent)
        if v3.distance(my_pos, ent_pos) > All_Entity.filter.distance then
            return false
        end
    end
    -- 地图标记点
    if All_Entity.filter.blip > 1 then
        if HUD.DOES_BLIP_EXIST(HUD.GET_BLIP_FROM_ENTITY(ent)) then
            if All_Entity.filter.blip ~= 2 then
                return false
            end
        else
            if All_Entity.filter.blip ~= 3 then
                return false
            end
        end
    end
    -- 移动状态
    if All_Entity.filter.move > 1 then
        if ENTITY.GET_ENTITY_SPEED(ent) == 0 then
            if All_Entity.filter.move ~= 2 then
                return false
            end
        else
            if All_Entity.filter.move ~= 3 then
                return false
            end
        end
    end
    -- Attached
    if All_Entity.filter.attached > 1 then
        if ENTITY.IS_ENTITY_ATTACHED(ent) then
            if All_Entity.filter.attached ~= 2 then
                return false
            end
        else
            if All_Entity.filter.attached ~= 3 then
                return false
            end
        end
    end

    ------ Ped ------
    if ENTITY.IS_ENTITY_A_PED(ent) then
        -- 排除玩家
        if All_Entity.filter.ped.except_player and is_player_ped(ent) then
            return false
        end
        -- 与玩家敌对
        if All_Entity.filter.ped.combat > 1 then
            if is_hostile_ped(ent) then
                if All_Entity.filter.ped.combat ~= 2 then
                    return false
                end
            else
                if All_Entity.filter.ped.combat ~= 3 then
                    return false
                end
            end
        end
        -- 关系
        if All_Entity.filter.ped.relationship > 1 then
            local rel = PED.GET_RELATIONSHIP_BETWEEN_PEDS(ent, players.user_ped())
            if All_Entity.filter.ped.relationship == 2 and (rel == 0 or rel == 1) then
            elseif All_Entity.filter.ped.relationship == 3 and rel == 2 then
            elseif All_Entity.filter.ped.relationship == 4 and (rel == 3 or rel == 5) then
            elseif All_Entity.filter.ped.relationship == 5 and rel == 4 then
            elseif All_Entity.filter.ped.relationship == 6 and rel == 255 then
            else
                return false
            end
        end
        -- 状态
        if All_Entity.filter.ped.state > 1 then
            if All_Entity.filter.ped.state == 2 and PED.IS_PED_ON_FOOT(ent) then
            elseif All_Entity.filter.ped.state == 3 and PED.IS_PED_IN_ANY_VEHICLE(ent, false) then
            elseif All_Entity.filter.ped.state == 4 and ENTITY.IS_ENTITY_DEAD(ent) then
            elseif All_Entity.filter.ped.state == 5 and PED.IS_PED_SHOOTING(ent) then
            else
                return false
            end
        end
        -- 装备武器
        if All_Entity.filter.ped.armed > 1 then
            if WEAPON.IS_PED_ARMED(ent, 7) then
                if All_Entity.filter.ped.armed ~= 2 then
                    return false
                end
            else
                if All_Entity.filter.ped.armed ~= 3 then
                    return false
                end
            end
        end
    end

    ------ Vehicle ------
    if ENTITY.IS_ENTITY_A_VEHICLE(ent) then
        -- 司机
        if All_Entity.filter.vehicle.driver > 1 then
            if All_Entity.filter.vehicle.driver == 2 and VEHICLE.IS_VEHICLE_SEAT_FREE(ent, -1, false) then
            elseif not VEHICLE.IS_VEHICLE_SEAT_FREE(ent, -1, false) then
                local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ent, -1)
                if All_Entity.filter.vehicle.driver == 3 and not is_player_ped(driver) then
                elseif All_Entity.filter.vehicle.driver == 4 and is_player_ped(driver) then
                else
                    return false
                end
            else
                return false
            end
        end
        -- 类型
        if All_Entity.filter.vehicle.type > 1 then
            if All_Entity.filter.vehicle.type == 2 and VEHICLE.IS_THIS_MODEL_A_CAR(hash) then
            elseif All_Entity.filter.vehicle.type == 3 and VEHICLE.IS_THIS_MODEL_A_BIKE(hash) then
            elseif All_Entity.filter.vehicle.type == 4 and VEHICLE.IS_THIS_MODEL_A_BICYCLE(hash) then
            elseif All_Entity.filter.vehicle.type == 5 and VEHICLE.IS_THIS_MODEL_A_HELI(hash) then
            elseif All_Entity.filter.vehicle.type == 6 and VEHICLE.IS_THIS_MODEL_A_PLANE(hash) then
            elseif All_Entity.filter.vehicle.type == 7 and VEHICLE.IS_THIS_MODEL_A_BOAT(hash) then
            else
                return false
            end
        end
    end

    return true
end

-- 排序
function All_Entity.Sort(ent_list, method)
    -- 距离: 近 -> 远
    if method == 2 then
        table.sort(ent_list, function(a, b)
            local player_pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
            local distance_a = v3.distance(ENTITY.GET_ENTITY_COORDS(a), player_pos)
            local distance_b = v3.distance(ENTITY.GET_ENTITY_COORDS(b), player_pos)
            return distance_a < distance_b
        end)
        -- 速度: 快 -> 慢
    elseif method == 3 then
        table.sort(ent_list, function(a, b)
            local speed_a = ENTITY.GET_ENTITY_SPEED(a)
            local speed_b = ENTITY.GET_ENTITY_SPEED(b)
            return speed_a > speed_b
        end)
    end
end

-- 初始化数据
function All_Entity.InitListData()
    -- 实体 list
    All_Entity.entity_list = {}
    -- 实体的 menu.list()
    All_Entity.entity_menu_list = {}
    -- 操作全部实体的 menu.list()
    All_Entity.all_entities_menu_list = {}
    -- 实体数量
    All_Entity.entity_count = 0
end

All_Entity.InitListData()

-- 清理并初始化数据
function All_Entity.ClearListData()
    -- 操作全部实体的 menu.list()
    if next(All_Entity.all_entities_menu_list) ~= nil then
        for i = 1, 2 do
            local v = All_Entity.all_entities_menu_list[i]
            if menu.is_ref_valid(v) then
                menu.delete(v)
            end
        end
    end
    -- 实体的 menu.list()
    for k, v in pairs(All_Entity.entity_menu_list) do
        if v ~= nil and menu.is_ref_valid(v) then
            menu.delete(v)
        end
    end
    -- 初始化
    All_Entity.InitListData()
    menu.set_menu_name(All_Entity.count_divider, "实体列表")
end

menu.action(Manage_All_Entity, "获取实体列表", {}, "", function()
    if not All_Entity.CheckHashInput() then
        util.toast("筛选设置中输入的的Hash为无效值!")
        return
    end

    All_Entity.ClearListData()
    local all_ent = get_all_entities(All_Entity.entityType)

    for _, ent in pairs(all_ent) do
        if All_Entity.CheckFilter(ent) then
            table.insert(All_Entity.entity_list, ent) -- 实体 list
        end
    end

    if next(All_Entity.entity_list) ~= nil then
        -- 排序
        if All_Entity.sortMethod > 1 then
            All_Entity.Sort(All_Entity.entity_list, All_Entity.sortMethod)
        end

        for k, ent in pairs(All_Entity.entity_list) do
            local menu_name, help_text = Entity_Control.GetMenuInfo(ent, k)

            -- 实体的 menu.list()
            local menu_list = menu.list(Manage_All_Entity, menu_name, {}, help_text, function()
                if not ENTITY.DOES_ENTITY_EXIST(ent) then
                    util.toast("该实体已经不存在")
                end
            end)
            table.insert(All_Entity.entity_menu_list, menu_list)

            -- 创建对应实体的menu操作
            local index = "a" .. k
            Entity_Control.GenerateMenu(menu_list, ent, index)

            -- 实体数量
            All_Entity.entity_count = All_Entity.entity_count + 1
        end
    end

    -- 全部实体
    if All_Entity.entity_count == 0 then
        menu.set_menu_name(All_Entity.count_divider, "实体列表")
    else
        menu.set_menu_name(All_Entity.count_divider, "实体列表 (" .. All_Entity.entity_count .. ")")

        All_Entity.all_entities_menu_list[1] = menu.divider(Manage_All_Entity, "")
        All_Entity.all_entities_menu_list[2] = menu.list(Manage_All_Entity, "全部实体管理", {}, "")
        Entity_Control.Entities(All_Entity.all_entities_menu_list[2], All_Entity.entity_list)
    end
end)

menu.action(Manage_All_Entity, "清空列表", {}, "", function()
    All_Entity.ClearListData()
    Loop_Handler.Entity.ClearToggles()
end)
All_Entity.count_divider = menu.divider(Manage_All_Entity, "实体列表")

--#endregion Manage All Entity
