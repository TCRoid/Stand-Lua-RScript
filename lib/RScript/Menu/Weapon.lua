------------------------------------------
--          Weapon Options
------------------------------------------


local Weapon_Options <const> = menu.list(Menu_Root, "武器选项", {}, "")

local MenuWeapon = {}



--#region Weapon Attributes

local Weapon_Attributes <const> = menu.list(Weapon_Options, "武器属性修改", {}, "修改武器属性，应用修改后会一直生效")

local WeaponAttribute = {
    BaseInfo = {
        ["anim_reload_time"] = { offset = 0x134, type = "float" },
        ["vehicle_reload_time"] = { offset = 0x130, type = "float" },
        ["time_between_shots"] = { offset = 0x13c, type = "float" },
        ["alternate_wait_time"] = { offset = 0x150, type = "float" },
        ["reload_time_mp"] = { offset = 0x128, type = "float" },
        ["reload_time_sp"] = { offset = 0x12c, type = "float" },
        ["lock_on_range"] = { offset = 0x288, type = "float" },
        ["weapon_range"] = { offset = 0x28c, type = "float" },
    },
    RocketInfo = {
        ["lifetime"] = { offset = 0x44, type = "float" },
        ["launch_speed"] = { offset = 0x58, type = "float" },
        ["forward_drag_coeff"] = { offset = 0x170, type = "float" },
        ["side_drag_coeff"] = { offset = 0x174, type = "float" },
        ["time_before_homing"] = { offset = 0x178, type = "float" },
        ["pitch_change_rate"] = { offset = 0x188, type = "float" },
        ["yaw_change_rate"] = { offset = 0x18c, type = "float" },
        ["roll_change_rate"] = { offset = 0x190, type = "float" },
        ["max_roll_angle_sin"] = { offset = 0x194, type = "float" },
    },
    HomingParam = {
        ["should_use_homing_params_from_info"] = { offset = 0x0, type = "byte" },
        ["time_before_starting_homing"] = { offset = 0x4, type = "float" },
        ["time_before_homing_angle_break"] = { offset = 0x8, type = "float" },
        ["turn_rate_modifier"] = { offset = 0xc, type = "float" },
        ["pitch_yaw_roll_clamp"] = { offset = 0x10, type = "float" },
        ["default_homing_rocket_break_lock_angle"] = { offset = 0x14, type = "float" },
        ["default_homing_rocket_break_lock_angle_close"] = { offset = 0x18, type = "float" },
        ["default_homing_rocket_break_lock_close_distance"] = { offset = 0x1c, type = "float" },
    },
    Persets = {
        ItemList = {
            {
                menu_name = "载具导弹 无限快速连发",
                help_text = "",
                weapon_type = 2,
                data_list = {
                    { "time_between_shots",  0.2, true },
                    { "alternate_wait_time", 0.2, true },
                    { "reload_time_mp",      0,   true },
                    { "reload_time_sp",      0,   true },
                }
            },
            {
                menu_name = "载具机枪 快速射击",
                help_text = "",
                weapon_type = 2,
                data_list = {
                    { "time_between_shots",  0, true },
                    { "alternate_wait_time", 0, true },
                    { "reload_time_mp",      0, true },
                    { "reload_time_sp",      0, true },
                }
            },
            {
                menu_name = "手持武器 通用设置",
                help_text = "换弹动作速度+0.2, 载具内换弹时间=0, 射击间隔时间-0.02",
                weapon_type = 1,
                data_list = {
                    { "anim_reload_time",    0.2,   false },
                    { "vehicle_reload_time", 0,     true },
                    { "time_between_shots",  -0.02, false },

                }
            },
            {
                menu_name = "制导导弹 增强锁定能力",
                help_text = "",
                weapon_type = 3,
                data_list = {
                    { "lifetime",                                        10.0,  true },
                    { "side_drag_coeff",                                 10.0,  true },
                    { "pitch_change_rate",                               100.0, true },
                    { "yaw_change_rate",                                 100.0, true },
                    { "roll_change_rate",                                100.0, true },
                    { "should_use_homing_params_from_info",              1,     true },
                    { "time_before_starting_homing",                     0.15,  true },
                    { "turn_rate_modifier",                              100.0, true },
                    { "pitch_yaw_roll_clamp",                            8.5,   true },
                    { "default_homing_rocket_break_lock_angle",          0.2,   true },
                    { "default_homing_rocket_break_lock_angle_close",    0.6,   true },
                    { "default_homing_rocket_break_lock_close_distance", 20.0,  true },
                }
            },
        }
    },
    Backups = {},
    Menus = {},
    Index = 0,
}

function WeaponAttribute.CWeaponInfo()
    local ped_ptr = entities.handle_to_pointer(players.user_ped())
    local weapon_manager = entities.get_weapon_manager(ped_ptr)
    local m_weapon_info = weapon_manager + 0x20
    local m_vehicle_weapon_info = weapon_manager + 0x70

    local CWeaponInfo = memory.read_long(m_weapon_info)
    if CWeaponInfo ~= 0 and WEAPON.IS_PED_ARMED(players.user_ped(), 4) then
        return CWeaponInfo
    end

    local CVehicleWeaponInfo = memory.read_long(m_vehicle_weapon_info)
    if CVehicleWeaponInfo ~= 0 then
        return CVehicleWeaponInfo
    end

    return 0
end

function WeaponAttribute.CAmmoInfo(CWeaponInfo)
    if CWeaponInfo == 0 then return 0 end
    if not WeaponAttribute.IsRocket(CWeaponInfo) then
        return 0
    end

    return memory.read_long(CWeaponInfo + 0x60) -- m_ammo_info
end

function WeaponAttribute.CHomingRocketParams(CAmmoInfo)
    if CAmmoInfo == 0 then return 0 end

    return CAmmoInfo + 0x19c -- m_homing_rocket_params
end

function WeaponAttribute.IsRocket(CWeaponInfo)
    local m_damage_type = CWeaponInfo + 0x20
    local m_fire_type = CWeaponInfo + 0x54
    return memory.read_int(m_damage_type) == 5 and memory.read_int(m_fire_type) == 4
end

function WeaponAttribute.GeMenuWeaponName(weaponHash)
    local weaponName = get_weapon_name_by_hash(weaponHash)
    if weaponName == "" then
        weaponName = util.reverse_joaat(weaponHash)
        weaponName = string.gsub(weaponName, "VEHICLE_WEAPON_", "")
    end
    if weaponName == "" then
        weaponName = tostring(weaponHash)
    end

    return weaponName
end

function WeaponAttribute.GetAttributes(CWeaponInfo, weaponName)
    local text = "武器: " .. weaponName
    local attr_value = 0

    for name, item in pairs(WeaponAttribute.BaseInfo) do
        attr_value = memory.read_float(CWeaponInfo + item.offset)

        text = text .. "\n" .. name .. ": " .. attr_value
    end

    local CAmmoInfo = WeaponAttribute.CAmmoInfo(CWeaponInfo)
    if CAmmoInfo ~= 0 then
        for name, item in pairs(WeaponAttribute.RocketInfo) do
            attr_value = memory.read_float(CAmmoInfo + item.offset)

            text = text .. "\n" .. name .. ": " .. attr_value
        end
    end

    local CHomingRocketParams = WeaponAttribute.CHomingRocketParams(CAmmoInfo)
    if CHomingRocketParams ~= 0 then
        for name, item in pairs(WeaponAttribute.HomingParam) do
            if item.type == "float" then
                attr_value = memory.read_float(CHomingRocketParams + item.offset)
            elseif item.type == "byte" then
                attr_value = memory.read_byte(CHomingRocketParams + item.offset)
            end
            text = text .. "\n" .. name .. ": " .. attr_value
        end
    end

    return text
end

function WeaponAttribute.SetAttribute(addr, value, Type, isAddition)
    if addr == 0 then return end

    local get_value = memory.read_float
    local set_value = memory.write_float
    if Type == "byte" then
        get_value = memory.read_byte
        set_value = memory.write_byte
    end

    local default_value = get_value(addr)
    if default_value < -1 then return end
    if default_value > 65536 then return end

    if isAddition then
        value = default_value + value
    end

    set_value(addr, value)
end

function WeaponAttribute.StoreBackup(CWeaponInfo, weaponHash)
    if WeaponAttribute.Backups[weaponHash] then return end

    local t = {}
    local attr_value = 0

    for name, item in pairs(WeaponAttribute.BaseInfo) do
        local addr = CWeaponInfo + item.offset

        attr_value = memory.read_float(addr)

        t[name] = { value = attr_value, type = item.type, addr = addr }
    end

    local CAmmoInfo = WeaponAttribute.CAmmoInfo(CWeaponInfo)
    if CAmmoInfo ~= 0 then
        for name, item in pairs(WeaponAttribute.RocketInfo) do
            local addr = CAmmoInfo + item.offset

            attr_value = memory.read_float(addr)

            t[name] = { value = attr_value, type = item.type, addr = addr }
        end
    end

    local CHomingRocketParams = WeaponAttribute.CHomingRocketParams(CAmmoInfo)
    if CHomingRocketParams ~= 0 then
        for name, item in pairs(WeaponAttribute.HomingParam) do
            local addr = CHomingRocketParams + item.offset
            if item.type == "float" then
                attr_value = memory.read_float(addr)
            elseif item.type == "byte" then
                attr_value = memory.read_byte(addr)
            end
            t[name] = { value = attr_value, type = item.type, addr = addr }
        end
    end

    WeaponAttribute.Backups[weaponHash] = t

    WeaponAttribute.GenerateMenu(CWeaponInfo, weaponHash)
end

function WeaponAttribute.ClearListData()
    for _, value in pairs(WeaponAttribute.Menus) do
        if value then
            return false
        end
    end
    WeaponAttribute.Menus = {}
    WeaponAttribute.Index = 0
end

function WeaponAttribute.GenerateMenu(CWeaponInfo, weaponHash)
    if WeaponAttribute.Menus[weaponHash] then return end
    local weapon_name = WeaponAttribute.GeMenuWeaponName(weaponHash)
    local menu_parent = Weapon_Attributes

    -- menu.list 存进表内
    local menu_list = menu.list(menu_parent, weapon_name, {}, "")
    WeaponAttribute.Menus[weaponHash] = menu_list


    menu.textslider_stateful(menu_list, "读取武器属性", {}, "", {
        "仅通知", "通知并保存到日志"
    }, function(value)
        local text = WeaponAttribute.GetAttributes(CWeaponInfo, weapon_name)

        util.toast(text)
        if value == 2 then
            util.log("\n" .. text)
        end
    end)
    menu.action(menu_list, "恢复默认属性", {}, "", function()
        for key, item in pairs(WeaponAttribute.Backups[weaponHash]) do
            if item.type == "float" then
                memory.write_float(item.addr, item.value)
            elseif item.type == "byte" then
                memory.write_byte(item.addr, item.value)
            end
        end
        util.toast("已恢复默认属性")
    end)
    menu.action(menu_list, "删除此条记录", {}, "会保存默认属性", function()
        menu.delete(menu_list)
        WeaponAttribute.Menus[weaponHash] = nil
        WeaponAttribute.ClearListData()
    end)

    menu.divider(menu_list, "属性列表")

    for name, item in pairs(WeaponAttribute.BaseInfo) do
        local addr = CWeaponInfo + item.offset
        local default_value = memory.read_float(addr)
        menu.text_input(menu_list, name,
            { "weapon_attr" .. WeaponAttribute.Index .. name },
            "", function(value, click_type)
                if click_type ~= CLICK_SCRIPTED then
                    value = tonumber(value)
                    if value then
                        memory.write_float(addr, value)
                    end
                end
            end, default_value)
    end

    local CAmmoInfo = WeaponAttribute.CAmmoInfo(CWeaponInfo)
    if CAmmoInfo ~= 0 then
        menu.divider(menu_list, "RocketInfo")

        for name, item in pairs(WeaponAttribute.RocketInfo) do
            local addr = CAmmoInfo + item.offset
            local default_value = memory.read_float(addr)
            menu.text_input(menu_list, name,
                { "weapon_attr" .. WeaponAttribute.Index .. name },
                "", function(value, click_type)
                    if click_type ~= CLICK_SCRIPTED then
                        value = tonumber(value)
                        if value then
                            memory.write_float(addr, value)
                        end
                    end
                end, default_value)
        end
    end

    local CHomingRocketParams = WeaponAttribute.CHomingRocketParams(CAmmoInfo)
    if CHomingRocketParams ~= 0 then
        menu.divider(menu_list, "HomingRocketParams")

        for name, item in pairs(WeaponAttribute.HomingParam) do
            local addr = CHomingRocketParams + item.offset
            local default_value = 0
            if item.type == "float" then
                default_value = memory.read_float(addr)
            elseif item.type == "byte" then
                default_value = memory.read_byte(addr)
            end
            menu.text_input(menu_list, name,
                { "weapon_attr" .. WeaponAttribute.Index .. name },
                "", function(value, click_type)
                    if click_type ~= CLICK_SCRIPTED then
                        value = tonumber(value)
                        if value then
                            if item.type == "float" then
                                memory.write_float(addr, value)
                            elseif item.type == "byte" then
                                memory.write_byte(addr, value)
                            end
                        end
                    end
                end, default_value)
        end
    end


    -- Index
    WeaponAttribute.Index = WeaponAttribute.Index + 1
end

function WeaponAttribute.Persets.Apply(CWeaponInfo, dataList)
    if CWeaponInfo == 0 then return false end
    local CAmmoInfo = WeaponAttribute.CAmmoInfo(CWeaponInfo)
    local CHomingRocketParams = WeaponAttribute.CHomingRocketParams(CAmmoInfo)

    for _, item in pairs(dataList) do
        local name = item[1]
        local value = item[2]
        local is_override = item[3]

        local info = WeaponAttribute.BaseInfo[name]
        if info then
            WeaponAttribute.SetAttribute(CWeaponInfo + info.offset, value, info.type, not is_override)
            goto continue
        end

        if CAmmoInfo == 0 then
            goto continue
        end
        info = WeaponAttribute.RocketInfo[name]
        if info then
            WeaponAttribute.SetAttribute(CAmmoInfo + info.offset, value, info.type, not is_override)
            goto continue
        end

        if CHomingRocketParams == 0 then
            goto continue
        end
        info = WeaponAttribute.HomingParam[name]
        if info then
            WeaponAttribute.SetAttribute(CHomingRocketParams + info.offset, value, info.type, not is_override)
            goto continue
        end

        ::continue::
    end
end

menu.textslider_stateful(Weapon_Attributes, "读取当前武器属性", {}, "", {
    "仅通知", "通知并保存到日志"
}, function(value)
    local CWeaponInfo = WeaponAttribute.CWeaponInfo()
    if CWeaponInfo ~= 0 then
        local weaponHash = get_ped_current_weapon(players.user_ped())
        local weaponName = WeaponAttribute.GeMenuWeaponName(weaponHash)
        local text = WeaponAttribute.GetAttributes(CWeaponInfo, weaponName)

        util.toast(text)
        if value == 2 then
            util.log("\n" .. text)
        end
    else
        util.toast("不支持近战武器")
    end
end)

menu.action(Weapon_Attributes, "编辑当前武器属性", {}, "", function()
    local CWeaponInfo = WeaponAttribute.CWeaponInfo()
    if CWeaponInfo ~= 0 then
        local weapon_hash = get_ped_current_weapon(players.user_ped())
        WeaponAttribute.StoreBackup(CWeaponInfo, weapon_hash)
    else
        util.toast("不支持近战武器")
    end
end)

menu.divider(Weapon_Attributes, "预设属性")
for _, item in pairs(WeaponAttribute.Persets.ItemList) do
    menu.action(Weapon_Attributes, item.menu_name, {}, item.help_text, function()
        local CWeaponInfo = WeaponAttribute.CWeaponInfo()
        if CWeaponInfo ~= 0 then
            local weapon_hash, weapon_type = get_ped_current_weapon(players.user_ped())
            if item.weapon_type == 3 or weapon_type == item.weapon_type then
                WeaponAttribute.StoreBackup(CWeaponInfo, weapon_hash)
                if WeaponAttribute.Persets.Apply(CWeaponInfo, item.data_list) then
                    local weapon_name = WeaponAttribute.GeMenuWeaponName(weapon_hash)
                    util.toast("武器: " .. weapon_name .. "\n预设属性修改完成")
                end
            end
        end
    end)
end


menu.divider(Weapon_Attributes, "保存的武器列表")

--#endregion



------------------------
-- Cam Gun
------------------------

local Weapon_CamGun <const> = menu.list(Weapon_Options, "视野工具枪", {}, "玩家镜头中心的位置")

local CamGun = {
    select = 1,
}

menu.toggle_loop(Weapon_CamGun, "开启[按住E键]", { "camGun" }, "", function()
    LoopHandler.drawCentredPoint(true)
    if PAD.IS_CONTROL_PRESSED(0, 51) then
        if CamGun.select == 1 then
            CamGun.Shoot()
        elseif CamGun.select == 2 then
            CamGun.Explosion()
        elseif CamGun.select == 3 then
            CamGun.Fire()
        end
    end
end, function()
    LoopHandler.drawCentredPoint(false)
end)

menu.list_select(Weapon_CamGun, "选择操作", { "cam_gun_select" }, "", {
    { 1, "射击", { "shoot" }, "" },
    { 2, "爆炸", { "explosion" }, "" },
    { 3, "燃烧", { "fire" }, "" },
}, 1, function(value)
    CamGun.select = value
end)


menu.divider(Weapon_CamGun, "设置")

--#region Cam Gun Shoot

----------------
-- Shoot
----------------

local CamGun_ShootSetting <const> = menu.list(Weapon_CamGun, "射击", {}, "")

CamGun.ShootSetting = {
    shootMethod = 1,
    delay = 100,
    weaponSelect = 1,
    weaponHash = "PLAYER_CURRENT_WEAPON",
    vehicleWeaponHash = "VEHICLE_CURRENT_WEAPON",
    isOwned = false,
    damage = 1000,
    speed = 2000,
    perfectAccuracy = true,
    createTraceVfx = true,
    allowRumble = true,
    startFromPlayer = false,
    offset = v3(0, 0, 2.0),
}

function CamGun.ShootPos(pos, action)
    local user_ped = players.user_ped()

    local start_pos = v3.new()
    if CamGun.ShootSetting.startFromPlayer then
        local player_pos = ENTITY.GET_ENTITY_COORDS(user_ped)
        start_pos = v3.add(player_pos, CamGun.ShootSetting.offset)
    else
        start_pos = v3.add(pos, CamGun.ShootSetting.offset)
    end

    if action == "drawline" then
        DRAW_LINE(start_pos, pos)
    else
        local weaponHash = CamGun.ShootSetting.weaponHash
        if CamGun.ShootSetting.weaponSelect == 2 then
            weaponHash = CamGun.ShootSetting.vehicleWeaponHash
        end

        if weaponHash == "PLAYER_CURRENT_WEAPON" then
            weaponHash = WEAPON.GET_SELECTED_PED_WEAPON(user_ped)
        elseif weaponHash == "VEHICLE_CURRENT_WEAPON" then
            local pWeapon = memory.alloc_int()
            WEAPON.GET_CURRENT_PED_VEHICLE_WEAPON(user_ped, pWeapon)
            weaponHash = memory.read_int(pWeapon)
        end
        if not WEAPON.HAS_WEAPON_ASSET_LOADED(weaponHash) then
            request_weapon_asset(weaponHash)
        end

        local owner = 0
        if CamGun.ShootSetting.isOwned then
            owner = user_ped
        end

        local ignoreEntity = entities.get_user_vehicle_as_handle(false)
        if ignoreEntity == INVALID_GUID then
            ignoreEntity = user_ped
        end

        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(
            start_pos.x, start_pos.y, start_pos.z,
            pos.x, pos.y, pos.z,
            CamGun.ShootSetting.damage,
            CamGun.ShootSetting.perfectAccuracy,
            weaponHash,
            owner,
            CamGun.ShootSetting.createTraceVfx,
            CamGun.ShootSetting.allowRumble,
            CamGun.ShootSetting.speed,
            ignoreEntity,
            0)
    end
end

function CamGun.Shoot()
    local cam_pos
    if CamGun.ShootSetting.shootMethod == 1 then
        local result = get_raycast_result(1500, -1)
        if result.didHit then
            cam_pos = result.endCoords
        end
    elseif CamGun.ShootSetting.shootMethod == 2 then
        cam_pos = get_offset_from_cam(1500)
    end

    if cam_pos ~= nil then
        CamGun.ShootPos(cam_pos)
        util.yield(CamGun.ShootSetting.delay)
    end
end

menu.toggle_loop(CamGun_ShootSetting, "绘制射击连线", {}, "", function()
    LoopHandler.drawCentredPoint(true)

    local cam_pos
    if CamGun.ShootSetting.shootMethod == 1 then
        local result = get_raycast_result(1500, -1)
        if result.didHit then
            cam_pos = result.endCoords
        end
    elseif CamGun.ShootSetting.shootMethod == 2 then
        cam_pos = get_offset_from_cam(1500)
    end

    if cam_pos ~= nil then
        CamGun.ShootPos(cam_pos, "drawline")
    end
end, function()
    LoopHandler.drawCentredPoint(false)
end)

menu.list_select(CamGun_ShootSetting, "射击方式", {}, "", {
    { 1, "方式1", {}, "射击的坐标更加准确，只能向实体或地面射击" },
    { 2, "方式2", {}, "射击的坐标不是很准确，但可以向空中射击" }
}, 1, function(value)
    CamGun.ShootSetting.shootMethod = value
end)
menu.slider(CamGun_ShootSetting, "循环延迟", { "cam_gun_shoot_delay" }, "单位: ms", 0, 5000, 100, 10,
    function(value)
        CamGun.ShootSetting.delay = value
    end)

local CamGun_ShootSetting_Weapon <const> = menu.list(CamGun_ShootSetting, "武器", {}, "")

menu.list_select(CamGun_ShootSetting_Weapon, "武器类型", {}, "",
    { { 1, "手持武器" }, { 2, "载具武器" } }, 1, function(value)
        CamGun.ShootSetting.weaponSelect = value
    end)
local CamGun_ShootSetting_PlayerWeapon = rs_menu.all_weapons_without_melee(CamGun_ShootSetting_Weapon, "手持武器",
    {}, "", function(hash)
        CamGun.ShootSetting.weaponHash = hash
    end, true)
rs_menu.current_weapon_action(CamGun_ShootSetting_PlayerWeapon, "玩家当前使用的武器", function()
    CamGun.ShootSetting.weaponHash = "PLAYER_CURRENT_WEAPON"
end, true)

local CamGun_ShootSetting_VehicleWeapon = rs_menu.vehicle_weapons(CamGun_ShootSetting_Weapon, "载具武器", {}, "",
    function(hash)
        CamGun.ShootSetting.vehicleWeaponHash = hash
    end, true)
rs_menu.current_weapon_action(CamGun_ShootSetting_VehicleWeapon, "载具当前使用的武器", function()
    CamGun.ShootSetting.vehicleWeaponHash = "VEHICLE_CURRENT_WEAPON"
end, true)


menu.toggle(CamGun_ShootSetting, "署名射击", {}, "以玩家名义", function(toggle)
    CamGun.ShootSetting.isOwned = toggle
end)
menu.slider(CamGun_ShootSetting, "伤害", { "cam_gun_shoot_damage" }, "", 0, 10000, 1000, 100,
    function(value)
        CamGun.ShootSetting.damage = value
    end)
menu.slider(CamGun_ShootSetting, "速度", { "cam_gun_shoot_speed" }, "", 0, 10000, 2000, 100,
    function(value)
        CamGun.ShootSetting.speed = value
    end)

menu.divider(CamGun_ShootSetting, "起始射击位置偏移")
menu.toggle(CamGun_ShootSetting, "从玩家位置起始射击", {},
    "如果关闭,则起始位置为目标位置+偏移\n如果开启,建议偏移Z>1.0", function(toggle)
        CamGun.ShootSetting.startFromPlayer = toggle
    end)
menu.slider_float(CamGun_ShootSetting, "X", { "cam_gun_shoot_x" }, "", -10000, 10000, 0, 10,
    function(value)
        CamGun.ShootSetting.offset.x = value * 0.01
    end)
menu.slider_float(CamGun_ShootSetting, "Y", { "cam_gun_shoot_y" }, "", -10000, 10000, 0, 10,
    function(value)
        CamGun.ShootSetting.offset.y = value * 0.01
    end)
menu.slider_float(CamGun_ShootSetting, "Z", { "cam_gun_shoot_z" }, "", -10000, 10000, 200, 10,
    function(value)
        CamGun.ShootSetting.offset.z = value * 0.01
    end)

--#endregion Cam Gun Shoot


--#region Cam Gun Explosion

----------------
-- Explosion
----------------

local CamGun_ExplosionSetting <const> = menu.list(Weapon_CamGun, "爆炸", {}, "")

CamGun.ExplosionSetting = {
    delay = 100,
    explosionType = 2,
    isOwned = false,
    damage = 1000,
    isAudible = true,
    isInvisible = false,
    cameraShake = 0,
}

function CamGun.Explosion()
    local result = get_raycast_result(1500, -1)
    local cam_pos = result.endCoords
    if result.didHit and cam_pos ~= nil then
        if CamGun.ExplosionSetting.isOwned then
            FIRE.ADD_OWNED_EXPLOSION(players.user_ped(),
                cam_pos.x, cam_pos.y, cam_pos.z,
                CamGun.ExplosionSetting.explosionType,
                CamGun.ExplosionSetting.damage,
                CamGun.ExplosionSetting.isAudible,
                CamGun.ExplosionSetting.isInvisible,
                CamGun.ExplosionSetting.cameraShake)
        else
            FIRE.ADD_EXPLOSION(
                cam_pos.x, cam_pos.y, cam_pos.z,
                CamGun.ExplosionSetting.explosionType,
                CamGun.ExplosionSetting.damage,
                CamGun.ExplosionSetting.isAudible,
                CamGun.ExplosionSetting.isInvisible,
                CamGun.ExplosionSetting.cameraShake,
                false)
        end
        util.yield(CamGun.ExplosionSetting.delay)
    end
end

menu.slider(CamGun_ExplosionSetting, "循环延迟", { "cam_gun_explosion_delay" }, "单位: ms", 0, 5000, 100, 10,
    function(value)
        CamGun.ExplosionSetting.delay = value
    end)
menu.list_select(CamGun_ExplosionSetting, "爆炸类型", {}, "", Misc_T.ExplosionType, 4, function(value)
    CamGun.ExplosionSetting.explosionType = value
end)
menu.toggle(CamGun_ExplosionSetting, "署名爆炸", {}, "以玩家名义", function(toggle)
    CamGun.ExplosionSetting.isOwned = toggle
end)
menu.slider(CamGun_ExplosionSetting, "伤害", { "cam_gun_explosion_damage" }, "", 0, 10000, 1000, 100,
    function(value)
        CamGun.ExplosionSetting.damage = value
    end)
menu.toggle(CamGun_ExplosionSetting, "可听见", {}, "", function(toggle)
    CamGun.ExplosionSetting.isAudible = toggle
end, true)
menu.toggle(CamGun_ExplosionSetting, "不可见", {}, "", function(toggle)
    CamGun.ExplosionSetting.isInvisible = toggle
end)

--#endregion Cam Gun Explosion


--#region Cam Gun Fire

----------------
-- Fire
----------------

local CamGun_FireSetting <const> = menu.list(Weapon_CamGun, "燃烧", {}, "有火焰数量生成限制")

CamGun.FireSetting = {
    fireIds = {},
    maxChildren = 25,
    isGasFire = false,
}

function CamGun.Fire()
    local result = get_raycast_result(1500, -1)
    local cam_pos = result.endCoords
    if result.didHit and cam_pos ~= nil then
        local fire_id = FIRE.START_SCRIPT_FIRE(
            cam_pos.x, cam_pos.y, cam_pos.z,
            CamGun.FireSetting.maxChildren,
            CamGun.FireSetting.isGasFire)
        table.insert(CamGun.FireSetting.fireIds, fire_id)
    end
end

menu.slider(CamGun_FireSetting, "max Children", { "cam_gun_fire_maxChildren" },
    "The max amount of times a fire can spread to other objects.", 0, 25, 25, 1, function(value)
        CamGun.FireSetting.maxChildren = value
    end)
menu.toggle(CamGun_FireSetting, "is Gas Fire", {}, "Whether or not the fire is powered by gasoline.", function(toggle)
    CamGun.FireSetting.isGasFire = toggle
end)
menu.action(CamGun_FireSetting, "移除生成的火焰", {}, "", function()
    if next(CamGun.FireSetting.fireIds) ~= nil then
        for k, v in pairs(CamGun.FireSetting.fireIds) do
            FIRE.REMOVE_SCRIPT_FIRE(v)
        end
        CamGun.FireSetting.fireIds = {}
    end
end)

--#endregion Cam Gun Fire





MenuWeapon.SpecialAmmo = {
    specialTypeList = {
        { 0, "无", { "none" }, "No Special Ammo" },
        { 1, "穿甲子弹", { "ap" }, "Armor Piercing Ammo" },
        { 2, "爆炸子弹", { "explosive" }, "Explosive Ammo" },
        { 3, "全金属外壳子弹", { "fmj" }, "Full Metal Jacket Ammo" },
        { 4, "中空子弹", { "hp" }, "Hollow Point Ammo" },
        { 5, "燃烧子弹", { "fire" }, "Incendiary Ammo" },
        { 6, "曳光子弹", { "tracer" }, "Tracer Ammo" }
    }
}
menu.list_action(Weapon_Options, "武器特殊弹药类型", { "specialAmmo" }, "对已经配备特殊弹药的武器无效",
    MenuWeapon.SpecialAmmo.specialTypeList, function(value)
        if not WEAPON.IS_PED_ARMED(players.user_ped(), 4) then
            return
        end

        local weapon_manager = entities.get_weapon_manager(entities.handle_to_pointer(players.user_ped()))
        local m_weapon_info = weapon_manager + 0x20

        local CWeaponInfo = memory.read_long(m_weapon_info)
        if CWeaponInfo ~= 0 then
            local CAmmoInfo = memory.read_long(CWeaponInfo + 0x60)
            if CAmmoInfo ~= 0 then
                local m_ammo_special_type = CAmmoInfo + 0x3c
                memory.write_int(m_ammo_special_type, value)

                local weaponHash = get_ped_weapon(players.user_ped())
                local weaponName = get_weapon_name_by_hash(weaponHash)
                util.toast("武器: " .. weaponName .. "\n弹药类型已修改")
            end
        end
    end)

menu.toggle_loop(Weapon_Options, "无限弹夹", { "infClip" }, "锁定弹夹，无需换弹", function()
    WEAPON.SET_PED_INFINITE_AMMO_CLIP(players.user_ped(), true)
end, function()
    WEAPON.SET_PED_INFINITE_AMMO_CLIP(players.user_ped(), false)
end)
menu.toggle_loop(Weapon_Options, "锁定最大弹药", { "lockAmmo" }, "射击时锁定当前武器为最大弹药",
    function()
        if PED.IS_PED_SHOOTING(players.user_ped()) then
            local weaponHash = WEAPON.GET_SELECTED_PED_WEAPON(players.user_ped())
            if weaponHash ~= 0 then
                -- WEAPON.SET_PED_AMMO(players.user_ped(), weaponHash, 9999)
                WEAPON.ADD_AMMO_TO_PED(players.user_ped(), weaponHash, 9999)
            end
        end
    end)
menu.toggle_loop(Weapon_Options, "无限载具武器弹药", { "infVehAmmo" }, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        if VEHICLE.DOES_VEHICLE_HAVE_WEAPONS(vehicle) then
            for i = 0, 3 do
                local ammo = VEHICLE.GET_VEHICLE_WEAPON_RESTRICTED_AMMO(vehicle, i)
                if ammo ~= -1 then
                    VEHICLE.SET_VEHICLE_WEAPON_RESTRICTED_AMMO(vehicle, i, -1)
                end
            end
        end
    end
end)
menu.toggle_loop(Weapon_Options, "翻滚时自动换弹夹", {}, "做翻滚动作时自动更换弹夹", function()
    if TASK.GET_IS_TASK_ACTIVE(players.user_ped(), 4) and PAD.IS_CONTROL_PRESSED(2, 22) and
        not PED.IS_PED_SHOOTING(players.user_ped()) then
        --checking if player is rolling
        util.yield(900)
        WEAPON.REFILL_AMMO_INSTANTLY(players.user_ped())
    end
end)
menu.action(Weapon_Options, "移除黏弹和感应地雷", { "removeProjectiles" }, "用来清理扔错地方但又不能炸掉的投掷武器",
    function()
        local weaponHash = util.joaat("WEAPON_PROXMINE")
        WEAPON.REMOVE_ALL_PROJECTILES_OF_TYPE(weaponHash, false)
        weaponHash = util.joaat("WEAPON_STICKYBOMB")
        WEAPON.REMOVE_ALL_PROJECTILES_OF_TYPE(weaponHash, false)
    end)


MenuWeapon.ReloadInVehicle = {
    modified_addr = 0,
    modified_default = 0,
}
menu.toggle_loop(Weapon_Options, "无载具内换弹时间", {}, "", function()
    if WEAPON.IS_PED_ARMED(players.user_ped(), 4) then
        local weapon_manager = entities.get_weapon_manager(entities.handle_to_pointer(players.user_ped()))
        local weapon_info = memory.read_long(weapon_manager + 0x20)
        if weapon_info ~= 0 then
            local addr = weapon_info + 0x130

            -- 更换了武器
            if addr ~= MenuWeapon.ReloadInVehicle.modified_addr then
                -- 恢复上一个武器的属性
                if MenuWeapon.ReloadInVehicle.modified_addr ~= 0 then
                    memory.write_float(MenuWeapon.ReloadInVehicle.modified_addr,
                        MenuWeapon.ReloadInVehicle.modified_default)
                end

                -- 备份当前武器的属性
                MenuWeapon.ReloadInVehicle.modified_addr = addr
                MenuWeapon.ReloadInVehicle.modified_default = memory.read_float(addr)
            end

            -- 修改武器属性
            memory.write_float(addr, 0)
        end
    end
end, function()
    -- 恢复上一个武器的属性
    if MenuWeapon.ReloadInVehicle.modified_addr ~= 0 then
        memory.write_float(MenuWeapon.ReloadInVehicle.modified_addr, MenuWeapon.ReloadInVehicle.modified_default)
    end
end)




menu.divider(Weapon_Options, "")

local WeaponSpecialAmmo = {
    { weapon = "WEAPON_APPISTOL",           type = 3 },
    { weapon = "WEAPON_SPECIALCARBINE_MK2", type = 3 },
    { weapon = "WEAPON_TECPISTOL",          type = 3 },
    { weapon = "WEAPON_COMBATMG_MK2",       type = 5 },
    { weapon = "WEAPON_ASSAULTSHOTGUN",     type = 4 },
}

menu.action(Weapon_Options, "一键设置武器特殊弹药类型", {}, "", function()
    for _, item in pairs(WeaponSpecialAmmo) do
        local weapon_hash = util.joaat(item.weapon)

        if WEAPON.HAS_PED_GOT_WEAPON(players.user_ped(), weapon_hash, false) then
            WEAPON.SET_CURRENT_PED_WEAPON(players.user_ped(), weapon_hash, false)

            local weapon_manager = entities.get_weapon_manager(entities.handle_to_pointer(players.user_ped()))

            local m_weapon_info = weapon_manager + 0x20
            local CWeaponInfo = memory.read_long(m_weapon_info)
            if CWeaponInfo ~= 0 then
                local CAmmoInfo = memory.read_long(CWeaponInfo + 0x60)
                if CAmmoInfo ~= 0 then
                    local m_ammo_special_type = CAmmoInfo + 0x3c
                    memory.write_int(m_ammo_special_type, item.type)
                end
            end
        end
    end
    util.toast("完成！")
end)
