------------------------------------------
--          Vehicle Options
------------------------------------------


local Vehicle_Options <const> = menu.list(Menu_Root, "载具选项", {}, "")

local MenuVehicle = {}


--#region Vehicle Upgrade

local Vehicle_Upgrade <const> = menu.list(Vehicle_Options, "载具升级强化", {}, "")

MenuVehicle.Upgrade = {
    performance = true,
    turbo = true,
    ---
    bulletproof_tyre = true,
    unbreakable_door = true,
    unbreakable_light = true,
    unbreak = true,
    ---
    max_health_multiplier = 1,
    health_multiplier = 1,
    damage_scale = 0.5,
    no_driver_explosion_damage = true,
    other_strong = true,
}

function MenuVehicle.Upgrade.upgrade(vehicle)
    -- 引擎、刹车、变速箱、防御
    if MenuVehicle.Upgrade.performance then
        for _, mod_type in pairs({ 11, 12, 13, 16 }) do
            local mod_num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, mod_type)
            VEHICLE.SET_VEHICLE_MOD(vehicle, mod_type, mod_num - 1, false)
        end
    end

    -- 涡轮增压
    if MenuVehicle.Upgrade.turbo then
        VEHICLE.TOGGLE_VEHICLE_MOD(vehicle, 18, true)
    end

    -- 防弹轮胎
    if MenuVehicle.Upgrade.bulletproof_tyre then
        if VEHICLE.GET_VEHICLE_TYRES_CAN_BURST(vehicle) then
            VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(vehicle, false)
        end
    end

    -- 车门不可损坏
    if MenuVehicle.Upgrade.unbreakable_door then
        for i = 0, 5 do
            if VEHICLE.GET_IS_DOOR_VALID(vehicle, i) then
                VEHICLE.SET_DOOR_ALLOWED_TO_BE_BROKEN_OFF(vehicle, i, false)
            end
        end
    end

    -- 车灯不可损坏
    if MenuVehicle.Upgrade.unbreakable_light then
        VEHICLE.SET_VEHICLE_HAS_UNBREAKABLE_LIGHTS(vehicle, true)
    end

    -- 部件不可分离
    if MenuVehicle.Upgrade.unbreakable_light then
        VEHICLE.SET_VEHICLE_CAN_BREAK(vehicle, false)
    end

    -- 实体最大血量倍数
    if MenuVehicle.Upgrade.max_health_multiplier > 1 then
        local max_health = ENTITY.GET_ENTITY_MAX_HEALTH(vehicle) * MenuVehicle.Upgrade.max_health_multiplier
        ENTITY.SET_ENTITY_MAX_HEALTH(vehicle, max_health)
        SET_ENTITY_HEALTH(vehicle, max_health)
    end

    -- 载具血量倍数
    if MenuVehicle.Upgrade.health_multiplier > 1 then
        local multiple_health = 1000 * MenuVehicle.Upgrade.health_multiplier
        VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, multiple_health)
        VEHICLE.SET_VEHICLE_BODY_HEALTH(vehicle, multiple_health)
        VEHICLE.SET_VEHICLE_PETROL_TANK_HEALTH(vehicle, multiple_health)
        VEHICLE.SET_HELI_MAIN_ROTOR_HEALTH(vehicle, multiple_health)
        VEHICLE.SET_HELI_TAIL_ROTOR_HEALTH(vehicle, multiple_health)
    end

    -- 受到伤害倍数
    VEHICLE.SET_VEHICLE_DAMAGE_SCALE(vehicle, MenuVehicle.Upgrade.damage_scale)
    VEHICLE.SET_VEHICLE_WEAPON_DAMAGE_SCALE(vehicle, MenuVehicle.Upgrade.damage_scale)

    -- 无视载具司机的爆炸
    if MenuVehicle.Upgrade.no_driver_explosion_damage then
        VEHICLE.SET_VEHICLE_NO_EXPLOSION_DAMAGE_FROM_DRIVER(vehicle, true)
    end

    -- 其它属性增强
    if MenuVehicle.Upgrade.other_strong then
        VEHICLE.SET_VEHICLE_WHEELS_CAN_BREAK(vehicle, false)

        VEHICLE.SET_VEHICLE_CAN_ENGINE_MISSFIRE(vehicle, false)
        VEHICLE.SET_VEHICLE_CAN_LEAK_OIL(vehicle, false)
        VEHICLE.SET_VEHICLE_CAN_LEAK_PETROL(vehicle, false)

        VEHICLE.SET_DISABLE_VEHICLE_ENGINE_FIRES(vehicle, true)
        VEHICLE.SET_DISABLE_VEHICLE_PETROL_TANK_FIRES(vehicle, true)
        VEHICLE.SET_DISABLE_VEHICLE_PETROL_TANK_DAMAGE(vehicle, true)

        VEHICLE.SET_VEHICLE_STRONG(vehicle, true)
        VEHICLE.SET_VEHICLE_HAS_STRONG_AXLES(vehicle, true)

        --Damage
        VEHICLE.VEHICLE_SET_RAMP_AND_RAMMING_CARS_TAKE_DAMAGE(vehicle, false)
        VEHICLE.SET_INCREASE_WHEEL_CRUSH_DAMAGE(vehicle, false)
        VEHICLE.SET_DISABLE_DAMAGE_WITH_PICKED_UP_ENTITY(vehicle, 1)
        VEHICLE.SET_VEHICLE_USES_MP_PLAYER_DAMAGE_MULTIPLIER(vehicle, 1)
        VEHICLE.SET_FORCE_VEHICLE_ENGINE_DAMAGE_BY_BULLET(vehicle, false)

        --Explode
        VEHICLE.SET_DISABLE_EXPLODE_FROM_BODY_DAMAGE_ON_COLLISION(vehicle, 1)
        VEHICLE.SET_VEHICLE_EXPLODES_ON_HIGH_EXPLOSION_DAMAGE(vehicle, false)
        VEHICLE.SET_VEHICLE_EXPLODES_ON_EXPLOSION_DAMAGE_AT_ZERO_BODY_HEALTH(vehicle, false)

        --Heli
        VEHICLE.SET_HELI_TAIL_BOOM_CAN_BREAK_OFF(vehicle, false)
        VEHICLE.SET_DISABLE_HELI_EXPLODE_FROM_BODY_DAMAGE(vehicle, 1)

        --MP Only
        VEHICLE.SET_PLANE_RESIST_TO_EXPLOSION(vehicle, true)
        VEHICLE.SET_HELI_RESIST_TO_EXPLOSION(vehicle, true)

        --Remove Check
        VEHICLE.REMOVE_VEHICLE_UPSIDEDOWN_CHECK(vehicle)
        VEHICLE.REMOVE_VEHICLE_STUCK_CHECK(vehicle)
    end
end

function MenuVehicle.Upgrade.remove(vehicle)
    for i = 0, 5 do
        if VEHICLE.GET_IS_DOOR_VALID(vehicle, i) then
            VEHICLE.SET_DOOR_ALLOWED_TO_BE_BROKEN_OFF(vehicle, i, true)
        end
    end
    VEHICLE.SET_VEHICLE_HAS_UNBREAKABLE_LIGHTS(vehicle, false)
    VEHICLE.SET_VEHICLE_CAN_BREAK(vehicle, true)

    ENTITY.SET_ENTITY_MAX_HEALTH(vehicle, 1000)
    SET_ENTITY_HEALTH(vehicle, 1000)

    VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, 1000)
    VEHICLE.SET_VEHICLE_BODY_HEALTH(vehicle, 1000)
    VEHICLE.SET_VEHICLE_PETROL_TANK_HEALTH(vehicle, 1000)
    VEHICLE.SET_HELI_MAIN_ROTOR_HEALTH(vehicle, 1000)
    VEHICLE.SET_HELI_TAIL_ROTOR_HEALTH(vehicle, 1000)

    VEHICLE.SET_VEHICLE_DAMAGE_SCALE(vehicle, 1.0)
    VEHICLE.SET_VEHICLE_WEAPON_DAMAGE_SCALE(vehicle, 1.0)

    VEHICLE.SET_VEHICLE_NO_EXPLOSION_DAMAGE_FROM_DRIVER(vehicle, false)

    VEHICLE.SET_VEHICLE_WHEELS_CAN_BREAK(vehicle, true)

    VEHICLE.SET_VEHICLE_CAN_ENGINE_MISSFIRE(vehicle, true)
    VEHICLE.SET_VEHICLE_CAN_LEAK_OIL(vehicle, true)
    VEHICLE.SET_VEHICLE_CAN_LEAK_PETROL(vehicle, true)

    VEHICLE.SET_DISABLE_VEHICLE_ENGINE_FIRES(vehicle, false)
    VEHICLE.SET_DISABLE_VEHICLE_PETROL_TANK_FIRES(vehicle, false)
    VEHICLE.SET_DISABLE_VEHICLE_PETROL_TANK_DAMAGE(vehicle, false)

    VEHICLE.SET_VEHICLE_STRONG(vehicle, false)
    VEHICLE.SET_VEHICLE_HAS_STRONG_AXLES(vehicle, false)

    VEHICLE.VEHICLE_SET_RAMP_AND_RAMMING_CARS_TAKE_DAMAGE(vehicle, true)
    VEHICLE.SET_INCREASE_WHEEL_CRUSH_DAMAGE(vehicle, true)
    VEHICLE.SET_DISABLE_DAMAGE_WITH_PICKED_UP_ENTITY(vehicle, 0)
    VEHICLE.SET_VEHICLE_USES_MP_PLAYER_DAMAGE_MULTIPLIER(vehicle, 0)
    VEHICLE.SET_FORCE_VEHICLE_ENGINE_DAMAGE_BY_BULLET(vehicle, true)

    VEHICLE.SET_DISABLE_EXPLODE_FROM_BODY_DAMAGE_ON_COLLISION(vehicle, 0)
    VEHICLE.SET_VEHICLE_EXPLODES_ON_HIGH_EXPLOSION_DAMAGE(vehicle, true)
    VEHICLE.SET_VEHICLE_EXPLODES_ON_EXPLOSION_DAMAGE_AT_ZERO_BODY_HEALTH(vehicle, true)

    VEHICLE.SET_HELI_TAIL_BOOM_CAN_BREAK_OFF(vehicle, true)
    VEHICLE.SET_DISABLE_HELI_EXPLODE_FROM_BODY_DAMAGE(vehicle, 0)

    VEHICLE.SET_PLANE_RESIST_TO_EXPLOSION(vehicle, false)
    VEHICLE.SET_HELI_RESIST_TO_EXPLOSION(vehicle, false)
end

menu.action(Vehicle_Upgrade, "升级强化载具", { "rsStrongVeh" }, "升级强化当前或上一辆载具",
    function()
        local vehicle = entities.get_user_vehicle_as_handle()
        if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
            MenuVehicle.Upgrade.upgrade(vehicle)
            util.toast("载具升级强化完成!")
        else
            util.toast("请先进入载具:)")
        end
    end)
menu.toggle_loop(Vehicle_Upgrade, "自动升级强化载具", {},
    "自动升级强化正在进入驾驶位的载具", function()
        local user_ped = players.user_ped()
        if PED.IS_PED_GETTING_INTO_A_VEHICLE(user_ped) then
            local veh = PED.GET_VEHICLE_PED_IS_TRYING_TO_ENTER(user_ped)
            if ENTITY.IS_ENTITY_A_VEHICLE(veh) and PED.GET_SEAT_PED_IS_TRYING_TO_ENTER(user_ped) == -1 then
                request_control(veh)
                MenuVehicle.Upgrade.upgrade(veh)

                -- 通知
                local veh_name = get_vehicle_display_name(veh)
                local text = "进入载具: " .. veh_name
                if has_control_entity(veh) then
                    THEFEED_POST.TEXT(text .. "\n升级强化完成!")
                else
                    THEFEED_POST.TEXT(text .. "\n升级强化未完成: 未能成功控制载具")
                end

                util.yield(50)
            end
        end
    end)

menu.action(Vehicle_Upgrade, "弱化载具属性", { "rsWeakVeh" }, "弱化当前或上一辆载具的属性", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        MenuVehicle.Upgrade.remove(vehicle)
        util.toast("载具弱化完成!")
    else
        util.toast("请先进入载具:)")
    end
end)

menu.divider(Vehicle_Upgrade, "载具性能")
menu.toggle(Vehicle_Upgrade, "主要性能", {}, "引擎、刹车、变速箱、防御", function(toggle)
    MenuVehicle.Upgrade.performance = toggle
end, true)
menu.toggle(Vehicle_Upgrade, "涡轮增压", {}, "", function(toggle)
    MenuVehicle.Upgrade.turbo = toggle
end, true)

menu.divider(Vehicle_Upgrade, "载具部件")
menu.toggle(Vehicle_Upgrade, "防弹轮胎", {}, "", function(toggle)
    MenuVehicle.Upgrade.bulletproof_tyre = toggle
end, true)
menu.toggle(Vehicle_Upgrade, "车门不可损坏", {}, "全部车门", function(toggle)
    MenuVehicle.Upgrade.unbreakable_door = toggle
end, true)
menu.toggle(Vehicle_Upgrade, "车灯不可损坏", {}, "", function(toggle)
    MenuVehicle.Upgrade.unbreakable_light = toggle
end, true)
menu.toggle(Vehicle_Upgrade, "部件不可分离", {}, "", function(toggle)
    MenuVehicle.Upgrade.unbreak = toggle
end, true)

menu.divider(Vehicle_Upgrade, "载具生命")
menu.slider(Vehicle_Upgrade, "实体最大血量倍数", {}, "",
    1, 20, 1, 1, function(value)
        MenuVehicle.Upgrade.max_health_multiplier = value
    end)
menu.slider(Vehicle_Upgrade, "载具血量倍数", {},
    "引擎血量，车身外观血量，油箱血量，直升机主旋翼和尾旋翼血量\n载具血量 = 1000 * multiplier",
    1, 20, 1, 1, function(value)
        MenuVehicle.Upgrade.health_multiplier = value
    end)
menu.slider_float(Vehicle_Upgrade, "受到伤害倍数", {}, "数值越低，受到的伤害就越低",
    0, 100, 50, 10, function(value)
        MenuVehicle.Upgrade.damage_scale = value * 0.01
    end)
menu.toggle(Vehicle_Upgrade, "无视载具司机的爆炸", {}, "司机投掷的炸弹不会对载具造成伤害",
    function(toggle)
        MenuVehicle.Upgrade.no_driver_explosion_damage = toggle
    end, true)
menu.toggle(Vehicle_Upgrade, "其它属性增强", {}, "其它属性的提高,可以提高防炸性等",
    function(toggle)
        MenuVehicle.Upgrade.other_strong = toggle
    end, true)

--#endregion


--#region Vehicle Weapon

local Vehicle_Weapon <const> = menu.list(Vehicle_Options, "载具武器", {}, "")

local VehicleWeapon = {
    delay = 500,
    direction = {
        [1] = true,  -- front
        [2] = false, -- rear
        [3] = false, -- left
        [4] = false, -- right
        [5] = false, -- up
        [6] = false, -- down
    },
    launchNum = 3,
    weaponHash = 4171469727,
    isOwned = false,
    damage = 1000,
    speed = 2000,
    createTraceVfx = true,
    allowRumble = true,
    perfectAccuracy = true,
    startOffset = {
        -- front
        [1] = { x = 0.0, y = 1.0, z = 0.0 },
        -- rear
        [2] = { x = 0.0, y = -1.0, z = 0.0 },
        -- left
        [3] = { x = -1.0, y = 0.0, z = 0.0 },
        -- right
        [4] = { x = 1.0, y = 0.0, z = 0.0 },
        -- up
        [5] = { x = 0.0, y = 0.0, z = 2.5 },
        -- down
        [6] = { x = 0.0, y = 0.0, z = -2.5 },
    },
    disableHorn = true,
}

function VehicleWeapon.GetOffsets(vehicle, direction)
    local min, max = v3.new(), v3.new()
    MISC.GET_MODEL_DIMENSIONS(ENTITY.GET_ENTITY_MODEL(vehicle), min, max)

    local offset_z = get_middle_num(min.z, max.z)
    local offsets = {}
    local startOffset, end_offset

    if direction == 1 then
        offsets[1] = v3.new(min.x, max.y, offset_z)
        offsets[2] = v3.new(get_middle_num(min.x, max.x), max.y, offset_z)
        offsets[3] = v3.new(max.x, max.y, offset_z)
        -- front
        end_offset = v3.new(0.0, 1.0, 0.0)
    elseif direction == 2 then
        offsets[1] = v3.new(min.x, min.y, offset_z)
        offsets[2] = v3.new(get_middle_num(min.x, max.x), min.y, offset_z)
        offsets[3] = v3.new(max.x, min.y, offset_z)
        -- rear
        end_offset = v3.new(0.0, -1.0, 0.0)
    elseif direction == 3 then
        offsets[1] = v3.new(min.x, max.y, offset_z)
        offsets[2] = v3.new(min.x, get_middle_num(min.y, max.y), offset_z)
        offsets[3] = v3.new(min.x, min.y, offset_z)
        -- left
        end_offset = v3.new(-1.0, 0.0, 0.0)
    elseif direction == 4 then
        offsets[1] = v3.new(max.x, max.y, offset_z)
        offsets[2] = v3.new(max.x, get_middle_num(min.y, max.y), offset_z)
        offsets[3] = v3.new(max.x, min.y, offset_z)
        -- right
        end_offset = v3.new(1.0, 0.0, 0.0)
    elseif direction == 5 then
        offsets[1] = v3.new(get_middle_num(min.x, max.x), max.y, offset_z)
        offsets[2] = v3.new(get_middle_num(min.x, max.x), get_middle_num(min.y, max.y), offset_z)
        offsets[3] = v3.new(get_middle_num(min.x, max.x), min.y, offset_z)
        -- up
        end_offset = v3.new(0.0, 0.0, 1.0)
    elseif direction == 6 then
        offsets[1] = v3.new(get_middle_num(min.x, max.x), max.y, offset_z)
        offsets[2] = v3.new(get_middle_num(min.x, max.x), get_middle_num(min.y, max.y), offset_z)
        offsets[3] = v3.new(get_middle_num(min.x, max.x), min.y, offset_z)
        -- down
        end_offset = v3.new(0.0, 0.0, -1.0)
    end

    start_offset = v3.new(VehicleWeapon.startOffset[direction])
    end_offset:mul(500.0) -- distance

    local launchNum = VehicleWeapon.launchNum
    if launchNum == 1 then
        offsets[1] = nil
        offsets[3] = nil
    elseif launchNum == 2 then
        offsets[2] = nil
    end

    return start_offset, end_offset, offsets
end

function VehicleWeapon.Shoot(vehicle)
    local user_ped = players.user_ped()

    local weaponHash = VehicleWeapon.weaponHash
    if weaponHash == "PLAYER_CURRENT_WEAPON" then
        weaponHash = WEAPON.GET_SELECTED_PED_WEAPON(players.user_ped())
    elseif weaponHash == "VEHICLE_CURRENT_WEAPON" then
        local ptr = memory.alloc_int()
        WEAPON.GET_CURRENT_PED_VEHICLE_WEAPON(user_ped, ptr)
        weaponHash = memory.read_int(ptr)
    end
    if not WEAPON.HAS_WEAPON_ASSET_LOADED(weaponHash) then
        request_weapon_asset(weaponHash)
    end

    local owner = 0
    if VehicleWeapon.isOwned then
        owner = user_ped
    end

    for dir, toggle in pairs(VehicleWeapon.direction) do
        if toggle then
            local start_offset, end_offset, offsets = VehicleWeapon.GetOffsets(vehicle, dir)
            local start_pos, end_pos
            for _, offset in pairs(offsets) do
                if offset ~= nil then
                    offset:add(start_offset)
                    start_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(vehicle, offset.x, offset.y, offset.z)

                    offset:add(end_offset)
                    end_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(vehicle, offset.x, offset.y, offset.z)

                    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(
                        start_pos.x, start_pos.y, start_pos.z,
                        end_pos.x, end_pos.y, end_pos.z,
                        VehicleWeapon.damage,
                        VehicleWeapon.perfectAccuracy,
                        weaponHash,
                        owner,
                        VehicleWeapon.createTraceVfx,
                        VehicleWeapon.allowRumble,
                        VehicleWeapon.speed,
                        vehicle,
                        0)
                end
            end
        end
    end
end

function VehicleWeapon.DrawLine(vehicle)
    for dir, toggle in pairs(VehicleWeapon.direction) do
        if toggle then
            local start_offset, end_offset, offsets = VehicleWeapon.GetOffsets(vehicle, dir)
            local start_pos, end_pos
            for _, offset in pairs(offsets) do
                if offset ~= nil then
                    offset:add(start_offset)
                    start_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(vehicle, offset.x, offset.y, offset.z)

                    offset:add(end_offset)
                    end_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(vehicle, offset.x, offset.y, offset.z)

                    DRAW_LINE(start_pos, end_pos)
                end
            end
        end
    end
end

menu.toggle_loop(Vehicle_Weapon, "载具武器[E键射击]", { "rsVehWeapon" }, "", function()
    local vehicle = entities.get_user_vehicle_as_handle(false)
    if vehicle ~= INVALID_GUID and PAD.IS_CONTROL_PRESSED(0, 51) then
        if VehicleWeapon.disableHorn then
            AUDIO.SET_HORN_ENABLED(vehicle, false)
        end

        VehicleWeapon.Shoot(vehicle)
        util.yield(VehicleWeapon.delay)
    end
end, function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        if VehicleWeapon.disableHorn then
            AUDIO.SET_HORN_ENABLED(vehicle, true)
        end
    end
end)

menu.toggle_loop(Vehicle_Weapon, "绘制射击连线", {}, "", function()
    local vehicle = entities.get_user_vehicle_as_handle(false)
    if vehicle ~= INVALID_GUID then
        VehicleWeapon.DrawLine(vehicle)
    end
end)

----------------
-- Setting
----------------

menu.divider(Vehicle_Weapon, "设置")
menu.slider(Vehicle_Weapon, "循环延迟", { "veh_weapon_delay" }, "单位: ms", 0, 5000, 500, 10,
    function(value)
        VehicleWeapon.delay = value
    end)

local Vehicle_Weapon_Direction <const> = menu.list(Vehicle_Weapon, "方向", {}, "")
for k, v in pairs({ "前", "后", "左", "右", "上", "下" }) do
    menu.toggle(Vehicle_Weapon_Direction, v, {}, "", function(toggle)
        VehicleWeapon.direction[k] = toggle
    end, VehicleWeapon.direction[k])
end

local Vehicle_Weapon_Select <const> = menu.list(Vehicle_Weapon, "武器", {}, "")
VehicleWeapon.Weapon_MenuReadonly = menu.readonly(Vehicle_Weapon_Select, "选择的武器", "VEHICLE_WEAPON_SPACE_ROCKET")

local Vehicle_Weapon_SelectPlayer = rs_menu.all_weapons_without_melee(Vehicle_Weapon_Select, "手持武器",
    {}, "", function(hash, name)
        VehicleWeapon.weaponHash = hash
        menu.set_value(VehicleWeapon.Weapon_MenuReadonly, name)
    end, false)
rs_menu.current_weapon_action(Vehicle_Weapon_SelectPlayer, "玩家当前使用的武器", function()
    VehicleWeapon.weaponHash = "PLAYER_CURRENT_WEAPON"
    menu.set_value(VehicleWeapon.Weapon_MenuReadonly, "PLAYER_CURRENT_WEAPON")
end, false)

local Vehicle_Weapon_SelecMenuVehicle = rs_menu.vehicle_weapons(Vehicle_Weapon_Select, "载具武器",
    {}, "", function(hash, model)
        VehicleWeapon.weaponHash = hash
        menu.set_value(VehicleWeapon.Weapon_MenuReadonly, model)
    end, false)
rs_menu.current_weapon_action(Vehicle_Weapon_SelecMenuVehicle, "载具当前使用的武器", function()
    VehicleWeapon.weaponHash = "VEHICLE_CURRENT_WEAPON"
    menu.set_value(VehicleWeapon.Weapon_MenuReadonly, "VEHICLE_CURRENT_WEAPON")
end, false)


menu.slider(Vehicle_Weapon, "发射数量", { "veh_weapon_launchNum" }, "", 1, 3, 3, 1, function(value)
    VehicleWeapon.launchNum = value
end)
menu.toggle(Vehicle_Weapon, "署名射击", {}, "以玩家名义", function(toggle)
    VehicleWeapon.isOwned = toggle
end)
menu.slider(Vehicle_Weapon, "伤害", { "veh_weapon_damage" }, "", 0, 10000, 1000, 100,
    function(value)
        VehicleWeapon.damage = value
    end)
menu.slider(Vehicle_Weapon, "速度", { "veh_weapon_speed" }, "", 0, 10000, 2000, 100,
    function(value)
        VehicleWeapon.speed = value
    end)


local Vehicle_Weapon_StartOffset <const> = menu.list(Vehicle_Weapon, "起始射击位置偏移", {}, "")
for k, v in pairs({ "前", "后", "左", "右", "上", "下" }) do
    local menu_list = menu.list(Vehicle_Weapon_StartOffset, v, {}, "")

    menu.slider_float(menu_list, "X", { "veh_weapon_dir" .. k .. "_x" }, "",
        -10000, 10000, VehicleWeapon.startOffset[k].x * 100, 10,
        function(value)
            value = value * 0.01
            VehicleWeapon.startOffset[k].x = value
        end)
    menu.slider_float(menu_list, "Y", { "veh_weapon_dir" .. k .. "_y" }, "",
        -10000, 10000, VehicleWeapon.startOffset[k].y * 100, 10,
        function(value)
            value = value * 0.01
            VehicleWeapon.startOffset[k].y = value
        end)
    menu.slider_float(menu_list, "Z", { "veh_weapon_dir" .. k .. "_z" }, "",
        -10000, 10000, VehicleWeapon.startOffset[k].z * 100, 10,
        function(value)
            value = value * 0.01
            VehicleWeapon.startOffset[k].z = value
        end)
end

menu.toggle(Vehicle_Weapon, "禁用载具喇叭", {}, "", function(toggle)
    VehicleWeapon.disableHorn = toggle
end, true)

--#endregion


--#region Vehicle Window

local Vehicle_Window <const> = menu.list(Vehicle_Options, "载具车窗", {}, "")

MenuVehicle.Window = {
    toggles = {},
    toggleMenus = {},
    windowList = {
        -- index, name
        { 0, "前左车窗" }, -- SC_WINDOW_FRONT_LEFT = 0
        { 1, "前右车窗" }, -- SC_WINDOW_FRONT_RIGHT = 1
        { 2, "后左车窗" }, -- SC_WINDOW_REAR_LEFT = 2
        { 3, "后右车窗" }, -- SC_WINDOW_REAR_RIGHT = 3
        { 4, "中间左车窗" }, -- SC_WINDOW_MIDDLE_LEFT = 4
        { 5, "中间右车窗" }, -- SC_WINDOW_MIDDLE_RIGHT = 5
        { 6, "前挡风车窗" }, -- SC_WINDSCREEN_FRONT = 6
        { 7, "后挡风车窗" }, -- SC_WINDSCREEN_REAR = 7
    },
}

local Vehicle_Window_Select <const> = menu.list(Vehicle_Window, "选择车窗", {}, "")

menu.toggle(Vehicle_Window_Select, "全部开/关", {}, "", function(toggle)
    for key, value in pairs(MenuVehicle.Window.toggleMenus) do
        if menu.is_ref_valid(value) then
            menu.set_value(value, toggle)
        end
    end
end, true)

for _, item in pairs(MenuVehicle.Window.windowList) do
    local index = item[1]
    local name = item[2]

    MenuVehicle.Window.toggles[index] = true
    MenuVehicle.Window.toggleMenus[index] = menu.toggle(Vehicle_Window_Select, name, {}, "", function(toggle)
        MenuVehicle.Window.toggles[index] = toggle
    end, true)
end

menu.toggle_loop(Vehicle_Window, "修复车窗", { "fixVehWindow" }, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        for index, toggle in pairs(MenuVehicle.Window.toggles) do
            if toggle then
                VEHICLE.FIX_VEHICLE_WINDOW(vehicle, index)
            end
        end
    end
end)
menu.toggle_loop(Vehicle_Window, "摇上车窗", { "rollUpVehWindow" }, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        for index, toggle in pairs(MenuVehicle.Window.toggles) do
            if toggle then
                VEHICLE.ROLL_UP_WINDOW(vehicle, index)
            end
        end
    end
end)
menu.toggle_loop(Vehicle_Window, "摇下车窗", { "rollDownVehWindow" }, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        for index, toggle in pairs(MenuVehicle.Window.toggles) do
            if toggle then
                VEHICLE.ROLL_DOWN_WINDOW(vehicle, index)
            end
        end
    end
end)
menu.toggle_loop(Vehicle_Window, "粉碎车窗", { "smashVehWindow" }, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        for index, toggle in pairs(MenuVehicle.Window.toggles) do
            if toggle then
                VEHICLE.SMASH_VEHICLE_WINDOW(vehicle, index)
            end
        end
    end
end)

--#endregion


--#region Vehicle Door

local Vehicle_Door <const> = menu.list(Vehicle_Options, "载具车门", {}, "")

MenuVehicle.Door = {
    toggles = {},
    toggleMenus = {},
    doorList = {
        -- index, name
        { 0, "左前门" }, -- VEH_EXT_DOOR_DSIDE_F = 0
        { 1, "右前门" }, -- VEH_EXT_DOOR_DSIDE_R = 1
        { 2, "左后门" }, -- VEH_EXT_DOOR_PSIDE_F = 2
        { 3, "右后门" }, -- VEH_EXT_DOOR_PSIDE_R = 3
        { 4, "引擎盖" }, -- VEH_EXT_BONNET = 4
        { 5, "后备箱" } -- VEH_EXT_BOOT = 5
    },
}

local Vehicle_Door_Select <const> = menu.list(Vehicle_Door, "选择车门", {}, "")

menu.toggle(Vehicle_Door_Select, "全部开/关", {}, "", function(toggle)
    for key, value in pairs(MenuVehicle.Door.toggleMenus) do
        if menu.is_ref_valid(value) then
            menu.set_value(value, toggle)
        end
    end
end, true)

for _, data in pairs(MenuVehicle.Door.doorList) do
    local index = data[1]
    local name = data[2]

    MenuVehicle.Door.toggles[index] = true
    MenuVehicle.Door.toggleMenus[index] = menu.toggle(Vehicle_Door_Select, name, {}, "", function(toggle)
        MenuVehicle.Door.toggles[index] = toggle
    end, true)
end

menu.toggle_loop(Vehicle_Door, "打开车门", { "openVehDoor" }, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        for index, toggle in pairs(MenuVehicle.Door.toggles) do
            if toggle then
                VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, index, false, false)
            end
        end
    end
end)
menu.action(Vehicle_Door, "关闭车门", { "closeVehDoor" }, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        for index, toggle in pairs(MenuVehicle.Door.toggles) do
            if toggle then
                VEHICLE.SET_VEHICLE_DOOR_SHUT(vehicle, index, false)
            end
        end
    end
end)
menu.toggle_loop(Vehicle_Door, "破坏车门", { "brokenVehDoor" }, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        for index, toggle in pairs(MenuVehicle.Door.toggles) do
            if toggle then
                VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, index, false)
            end
        end
    end
end)
menu.toggle_loop(Vehicle_Door, "删除车门", { "deleteVehDoor" }, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        for index, toggle in pairs(MenuVehicle.Door.toggles) do
            if toggle then
                VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, index, true)
            end
        end
    end
end)


menu.divider(Vehicle_Door, "锁门")

MenuVehicle.DoorLock = {
    ListItem = {
        { 1, "解锁", {}, "" }, -- VEHICLELOCK_UNLOCKED
        { 2, "上锁", {}, "" }, -- VEHICLELOCK_LOCKED
        { 3, "Lock Out Player Only", {}, "" }, -- VEHICLELOCK_LOCKOUT_PLAYER_ONLY
        { 4, "玩家锁定在里面", {}, "" }, -- VEHICLELOCK_LOCKED_PLAYER_INSIDE
        { 5, "Locked Initially", {}, "" }, -- VEHICLELOCK_LOCKED_INITIALLY
        { 6, "强制关闭车门", {}, "" }, -- VEHICLELOCK_FORCE_SHUT_DOORS
        { 7, "上锁但可被破坏", {}, "可以破开车窗开门" }, -- VEHICLELOCK_LOCKED_BUT_CAN_BE_DAMAGED
        { 8, "上锁但后备箱解锁", {}, "" }, -- VEHICLELOCK_LOCKED_BUT_BOOT_UNLOCKED
        { 9, "Locked No Passagers", {}, "" }, -- VEHICLELOCK_LOCKED_NO_PASSENGERS
        { 10, "不能进入", {}, "按F无上车动作" } -- VEHICLELOCK_CANNOT_ENTER
    }
}
menu.list_action(Vehicle_Door, "设置锁门类型", {}, "", MenuVehicle.DoorLock.ListItem, function(value)
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle, value)
    end
end)

menu.toggle(Vehicle_Door, "对所有玩家锁门", {}, "", function(toggle)
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(vehicle, toggle)
    end
end)
menu.toggle(Vehicle_Door, "对所有团队锁门", {}, "", function(toggle)
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_TEAMS(vehicle, toggle)
    end
end)

--#endregion


--#region Vehicle Radio

local Vehicle_Radio <const> = menu.list(Vehicle_Options, "载具电台", {}, "")

MenuVehicle.Radio = {
    station_select = 1,
}

menu.list_select(Vehicle_Radio, "选择电台", {}, "", Vehicle_T.RadioStation.ListItem, 0, function(value)
    MenuVehicle.Radio.station_select = value
end)
menu.toggle_loop(Vehicle_Radio, "自动更改电台", {}, "自动更改正在进入驾驶位的载具的电台",
    function()
        if PED.IS_PED_GETTING_INTO_A_VEHICLE(players.user_ped()) then
            local veh = PED.GET_VEHICLE_PED_IS_ENTERING(players.user_ped())
            if ENTITY.IS_ENTITY_A_VEHICLE(veh) and PED.GET_SEAT_PED_IS_TRYING_TO_ENTER(players.user_ped()) == -1 then
                local stationName = Vehicle_RadioStation.LabelList[MenuVehicle.Radio.station_select + 1]
                AUDIO.SET_VEH_RADIO_STATION(veh, stationName)
                AUDIO.SET_RADIO_TO_STATION_NAME(stationName)
            end
        end
    end)
menu.toggle_loop(Vehicle_Radio, "禁用载具电台", {}, "当前或上一辆载具将无法选择更改电台",
    function()
        local vehicle = entities.get_user_vehicle_as_handle()
        if vehicle ~= INVALID_GUID then
            AUDIO.SET_VEHICLE_RADIO_ENABLED(vehicle, false)
        end
    end, function()
        local vehicle = entities.get_user_vehicle_as_handle()
        if vehicle ~= INVALID_GUID then
            AUDIO.SET_VEHICLE_RADIO_ENABLED(vehicle, true)
        end
    end)
menu.toggle(Vehicle_Radio, "电台只播放音乐", { "radioOnlyMusic" }, "", function(toggle)
    for _, stationName in pairs(Vehicle_T.RadioStation.LabelList) do
        AUDIO.SET_RADIO_STATION_MUSIC_ONLY(stationName, toggle)
    end
end)

--#endregion


--#region Vehicle Info

local Vehicle_Info <const> = menu.list(Vehicle_Options, "载具信息显示", {}, "")

MenuVehicle.Info = {
    -- show setting --
    only_current_vehicle = true,
    x = 0.26,
    y = 0.80,
    scale = 0.65,
    color = Colors.white,
    -- show info --
    vehicle_name = true,
    entity_health = true,
    engine_health = true,
    body_health = false,
    petrol_tank_health = false,
    heli_health = false,
}

menu.toggle_loop(Vehicle_Info, "显示载具信息", { "rsVehInfo" }, "", function()
    if MenuVehicle.Info.only_current_vehicle and not PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
        return
    end

    local veh = entities.get_user_vehicle_as_handle()
    if veh ~= INVALID_GUID then
        local text = ""

        if MenuVehicle.Info.vehicle_name then
            text = text .. get_vehicle_display_name(veh) .. "\n"
        end
        if MenuVehicle.Info.entity_health then
            text = text .. "实体血量: " ..
                ENTITY.GET_ENTITY_HEALTH(veh) .. "/" .. ENTITY.GET_ENTITY_MAX_HEALTH(veh) .. "\n"
        end
        if MenuVehicle.Info.engine_health then
            text = text .. "引擎血量: " .. math.ceil(VEHICLE.GET_VEHICLE_ENGINE_HEALTH(veh)) .. "\n"
        end
        if MenuVehicle.Info.body_health then
            text = text .. "车身外观血量: " .. math.ceil(VEHICLE.GET_VEHICLE_BODY_HEALTH(veh)) .. "\n"
        end
        if MenuVehicle.Info.petrol_tank_health then
            text = text .. "油箱血量: " .. math.ceil(VEHICLE.GET_VEHICLE_PETROL_TANK_HEALTH(veh)) .. "\n"
        end
        if MenuVehicle.Info.heli_health and VEHICLE.IS_THIS_MODEL_A_HELI(ENTITY.GET_ENTITY_MODEL(veh)) then
            text = text .. "Heli Main Rotor Health: " .. math.ceil(VEHICLE.GET_HELI_MAIN_ROTOR_HEALTH(veh)) .. "\n"
            text = text .. "Heli Tail Rotor Health: " .. math.ceil(VEHICLE.GET_HELI_TAIL_ROTOR_HEALTH(veh)) .. "\n"
            text = text .. "Heli Boom Rotor Health: " .. math.ceil(VEHICLE.GET_HELI_TAIL_BOOM_HEALTH(veh)) .. "\n"
        end

        directx.draw_text(MenuVehicle.Info.x, MenuVehicle.Info.y,
            text,
            ALIGN_TOP_LEFT,
            MenuVehicle.Info.scale,
            MenuVehicle.Info.color)
    end
end)

local Vehicle_Info_ShowSetting <const> = menu.list(Vehicle_Info, "显示设置", {}, "")
menu.toggle(Vehicle_Info_ShowSetting, "只显示当前载具信息", {}, "", function(toggle)
    MenuVehicle.Info.only_current_vehicle = toggle
end, true)
menu.slider_float(Vehicle_Info_ShowSetting, "位置X", { "veh_info_x" }, "", 0, 100, 26, 1, function(value)
    MenuVehicle.Info.x = value * 0.01
end)
menu.slider_float(Vehicle_Info_ShowSetting, "位置Y", { "veh_info_y" }, "", 0, 100, 80, 1, function(value)
    MenuVehicle.Info.y = value * 0.01
end)
menu.slider_float(Vehicle_Info_ShowSetting, "文字大小", { "veh_info_scale" }, "",
    0, 1000, 65, 1, function(value)
        MenuVehicle.Info.scale = value * 0.01
    end)
menu.colour(Vehicle_Info_ShowSetting, "文字颜色", { "veh_info_colour" }, "", Colors.white, false,
    function(colour)
        MenuVehicle.Info.color = colour
    end)

menu.divider(Vehicle_Info, "显示的信息")
menu.toggle(Vehicle_Info, "载具名称", {}, "", function(toggle)
    MenuVehicle.Info.vehicle_name = toggle
end, true)
menu.toggle(Vehicle_Info, "实体血量", {}, "", function(toggle)
    MenuVehicle.Info.entity_health = toggle
end, true)
menu.toggle(Vehicle_Info, "引擎血量", {}, "", function(toggle)
    MenuVehicle.Info.engine_health = toggle
end, true)
menu.toggle(Vehicle_Info, "车身外观血量", {}, "", function(toggle)
    MenuVehicle.Info.body_health = toggle
end)
menu.toggle(Vehicle_Info, "油箱血量", {}, "", function(toggle)
    MenuVehicle.Info.petrol_tank_health = toggle
end)
menu.toggle(Vehicle_Info, "直升机螺旋桨血量", {}, "", function(toggle)
    MenuVehicle.Info.heli_health = toggle
end)

--#endregion


MenuVehicle.vehDirtLevel = 0.0
menu.slider_float(Vehicle_Options, "载具灰尘程度", { "vehDirtLevel" }, "载具全身灰尘程度",
    0, 1500, MenuVehicle.vehDirtLevel * 100, 100, function(value)
        MenuVehicle.vehDirtLevel = value * 0.01

        local vehicle = entities.get_user_vehicle_as_handle()
        if vehicle ~= INVALID_GUID then
            VEHICLE.SET_VEHICLE_DIRT_LEVEL(vehicle, MenuVehicle.vehDirtLevel)
        end
    end)
menu.toggle_loop(Vehicle_Options, "锁定载具灰尘程度", {}, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        if VEHICLE.GET_VEHICLE_DIRT_LEVEL(vehicle) ~= MenuVehicle.vehDirtLevel then
            VEHICLE.SET_VEHICLE_DIRT_LEVEL(vehicle, MenuVehicle.vehDirtLevel)
        end
    end
end)

menu.toggle_loop(Vehicle_Options, "自动开启载具引擎", {}, "自动开启正在进入驾驶位的载具的引擎",
    function()
        if PED.IS_PED_GETTING_INTO_A_VEHICLE(players.user_ped()) then
            local veh = PED.GET_VEHICLE_PED_IS_ENTERING(players.user_ped())
            if ENTITY.IS_ENTITY_A_VEHICLE(veh) and PED.GET_SEAT_PED_IS_TRYING_TO_ENTER(players.user_ped()) == -1 then
                VEHICLE.SET_VEHICLE_ENGINE_HEALTH(veh, 1000)
                VEHICLE.SET_VEHICLE_ENGINE_ON(veh, true, true, true)
            end
        end
    end)
menu.toggle_loop(Vehicle_Options, "自动解锁载具车门", {}, "自动解锁正在进入的载具的车门",
    function()
        local vehicle = 0
        if PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
            vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
        else
            vehicle = PED.GET_VEHICLE_PED_IS_TRYING_TO_ENTER(players.user_ped())
        end

        if vehicle ~= 0 then
            if request_control(vehicle) then
                unlock_vehicle_doors(vehicle)
                VEHICLE.SET_VEHICLE_UNDRIVEABLE(vehicle, false)
                ENTITY.FREEZE_ENTITY_POSITION(vehicle, false)
            else
                util.toast("请求控制失败，请重试")
            end
        end
    end)
menu.toggle_loop(Vehicle_Options, "无限动能回收加速", {}, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        if VEHICLE.GET_VEHICLE_HAS_KERS(vehicle) then
            local vehicle_ptr = entities.handle_to_pointer(vehicle)
            local kers_boost_max = memory.read_float(vehicle_ptr + 0x92c)
            memory.write_float(vehicle_ptr + 0x930, kers_boost_max) -- m_kers_boost
        end
    end
end)
menu.toggle_loop(Vehicle_Options, "无限载具跳跃", {}, "然而落地后才能继续跳跃", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        if VEHICLE.GET_CAR_HAS_JUMP(vehicle) then
            local vehicle_ptr = entities.handle_to_pointer(vehicle)
            memory.write_float(vehicle_ptr + 0x3a0, 5.0) -- m_jump_boost_charge
        end
    end
end)

MenuVehicle.vehHealthValue = 1000
menu.slider(Vehicle_Options, "载具血量", { "vehHealth" }, "实体血量、引擎血量、车身血量等",
    0, 100000, MenuVehicle.vehHealthValue, 1000, function(value)
        MenuVehicle.vehHealthValue = value

        local vehicle = entities.get_user_vehicle_as_handle()
        if vehicle ~= INVALID_GUID then
            SET_ENTITY_HEALTH(vehicle, value)
            VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, value)
            VEHICLE.SET_VEHICLE_BODY_HEALTH(vehicle, value)
            VEHICLE.SET_VEHICLE_PETROL_TANK_HEALTH(vehicle, value)
        end
    end)
menu.toggle_loop(Vehicle_Options, "锁定载具血量", {}, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        local value = MenuVehicle.vehHealthValue

        SET_ENTITY_HEALTH(vehicle, value)
        VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, value)
        VEHICLE.SET_VEHICLE_BODY_HEALTH(vehicle, value)
        VEHICLE.SET_VEHICLE_PETROL_TANK_HEALTH(vehicle, value)
    end
end)
