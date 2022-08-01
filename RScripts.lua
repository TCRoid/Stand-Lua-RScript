-- Author: Rostal
-- Last edit date: 2022/8/1

util.require_natives("natives-1651208000")
util.require_natives("natives-1640181023")

--- --- --- Functions --- --- ---

-- 请求模型
-- 1) requests all the given models
-- 2) waits till all of them have been loaded
function requestModels(...)
    local arg = { ... }
    for _, model in ipairs(arg) do
        if not STREAMING.IS_MODEL_VALID(model) then
            error("tried to request an invalid model")
        end
        STREAMING.REQUEST_MODEL(model)
        while not STREAMING.HAS_MODEL_LOADED(model) do
            util.yield()
        end
    end
end

function IS_PED_PLAYER(Ped)
    if PED.GET_PED_TYPE(Ped) >= 4 then
        return false
    else
        return true
    end
end

function TELEPORT(X, Y, Z)
    local Me = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PLAYER.PLAYER_ID())
    if PED.GET_VEHICLE_PED_IS_IN(Me, false) == 0 then
        ENTITY.SET_ENTITY_COORDS(Me, X, Y, Z)
    else
        ENTITY.SET_ENTITY_COORDS(PED.GET_VEHICLE_PED_IS_IN(Me, false), X, Y, Z)
    end
end

vect = {
    ['new'] = function(x, y, z)
        return { ['x'] = x, ['y'] = y, ['z'] = z }
    end,
    ['subtract'] = function(a, b)
        return vect.new(a.x - b.x, a.y - b.y, a.z - b.z)
    end,
    ['add'] = function(a, b)
        return vect.new(a.x + b.x, a.y + b.y, a.z + b.z)
    end,
    ['mag'] = function(a)
        return math.sqrt(a.x ^ 2 + a.y ^ 2 + a.z ^ 2)
    end,
    ['norm'] = function(a)
        local mag = vect.mag(a)
        return vect.div(a, mag)
    end,
    ['mult'] = function(a, b)
        return vect.new(a.x * b, a.y * b, a.z * b)
    end,
    ['div'] = function(a, b)
        return vect.new(a.x / b, a.y / b, a.z / b)
    end,
    ['dist'] = function(a, b)
        --returns the distance between two vectors
        return vect.mag(vect.subtract(a, b))
    end
}

--returns a list of nearby vehicles given player Id
function GET_NEARBY_VEHICLES(pid, radius)
    local vehicles = {}
    local p = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
    local pos = ENTITY.GET_ENTITY_COORDS(p)
    local v = PED.GET_VEHICLE_PED_IS_IN(p, false)
    for k, vehicle in pairs(entities.get_all_vehicles_as_handles()) do
        local veh_pos = ENTITY.GET_ENTITY_COORDS(vehicle)
        if vehicle ~= v and vect.dist(pos, veh_pos) <= radius then
            table.insert(vehicles, vehicle)
        end
    end
    return vehicles
end

--returns a list of nearby peds given player Id
function GET_NEARBY_PEDS(pid, radius)
    local peds = {}
    local p = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
    local pos = ENTITY.GET_ENTITY_COORDS(p)
    for k, ped in pairs(entities.get_all_peds_as_handles()) do
        if ped ~= p then
            local ped_pos = ENTITY.GET_ENTITY_COORDS(ped)
            if vect.dist(pos, ped_pos) <= radius then
                table.insert(peds, ped)
            end
        end
    end
    return peds
end

--返回瞄准的实体
local GetEntity_PlayerIsAimingAt = function(p)
    local ent = NULL
    if PLAYER.IS_PLAYER_FREE_AIMING(p) then
        local ptr = memory.alloc_int()
        if PLAYER.GET_ENTITY_PLAYER_IS_FREE_AIMING_AT(p, ptr) then
            ent = memory.read_int(ptr)
        end
        memory.free(ptr)
        if ENTITY.IS_ENTITY_A_PED(ent) and PED.IS_PED_IN_ANY_VEHICLE(ent) then
            local vehicle = PED.GET_VEHICLE_PED_IS_IN(ent, false)
            ent = vehicle
        end
    end
    return ent
end

--为实体添加小地图标记
function addBlipForEntity(entity, blipSprite, colour)
    local blip = HUD.ADD_BLIP_FOR_ENTITY(entity)
    HUD.SET_BLIP_SPRITE(blip, blipSprite)
    HUD.SET_BLIP_COLOUR(blip, colour)
    HUD.SHOW_HEIGHT_ON_BLIP(blip, false)
    HUD.SET_BLIP_ROTATION(blip, SYSTEM.CEIL(ENTITY.GET_ENTITY_HEADING(entity)))
    NETWORK.SET_NETWORK_ID_CAN_MIGRATE(entity, false)
    util.create_thread(function()
        while not ENTITY.IS_ENTITY_DEAD(entity) do
            local heading = ENTITY.GET_ENTITY_HEADING(entity)
            HUD.SET_BLIP_ROTATION(blip, SYSTEM.CEIL(heading))
            util.yield()
        end
        util.remove_blip(blip)
    end)
    return blip
end

--- STAT Functions ---
function MP_INDEX()
    return "MP" .. util.get_char_slot() .. "_"
end

function IS_MPPLY(Stat)
    if string.find(Stat, "MPPLY_") or string.find(Stat, "MP_") then
        return true
    else
        return false
    end
end

function STAT_SET_INT(Stat, Value)
    if IS_MPPLY(Stat) then
        STATS.STAT_SET_INT(util.joaat(Stat), Value, true)
    else
        STATS.STAT_SET_INT(util.joaat(MP_INDEX() .. Stat), Value, true)
    end
end

function STAT_SET_FLOAT(Stat, Value)
    if string.find(Stat, "MPPLY_") or string.find(Stat, "MP_") then
        STATS.STAT_SET_FLOAT(util.joaat(Stat), Value, true)
    else
        STATS.STAT_SET_FLOAT(util.joaat(MP_INDEX() .. Stat), Value, true)
    end
end

function STAT_SET_BOOL(Stat, Value)
    if string.find(Stat, "MPPLY_") or string.find(Stat, "MP_") then
        STATS.STAT_SET_BOOL(util.joaat(Stat), Value, true)
    else
        STATS.STAT_SET_BOOL(util.joaat(MP_INDEX() .. Stat), Value, true)
    end
end

function STAT_SET_INCREMENT(Stat, Value)
    if string.find(Stat, "MPPLY_") or string.find(Stat, "MP_") then
        STATS.STAT_INCREMENT(util.joaat(Stat), Value, true)
    else
        STATS.STAT_INCREMENT(util.joaat(MP_INDEX() .. Stat), Value, true)
    end
end

function STAT_GET_INT(Stat)
    local IntPTR = memory.alloc(4)

    if string.find(Stat, "MPPLY_") or string.find(Stat, "MP_") then
        STATS.STAT_GET_INT(util.joaat(Stat), IntPTR, -1)
    else
        STATS.STAT_GET_INT(util.joaat(MP_INDEX() .. Stat), IntPTR, -1)
    end

    return memory.read_int(IntPTR)
end

function STAT_GET_FLOAT(Stat)
    local FloatPTR = memory.alloc(4)

    if string.find(Stat, "MPPLY_") or string.find(Stat, "MP_") then
        STATS.STAT_GET_FLOAT(util.joaat(Stat), FloatPTR, -1)
    else
        STATS.STAT_GET_FLOAT(util.joaat(MP_INDEX() .. Stat), FloatPTR, -1)
    end

    return tonumber(string.format("%.3f", memory.read_float(FloatPTR)))
end

function STAT_GET_BOOL(Stat)
    local BoolPTR = memory.alloc(1)

    if string.find(Stat, "MPPLY_") or string.find(Stat, "MP_") then
        STATS.STAT_GET_BOOL(util.joaat(Stat), BoolPTR, -1)
    else
        STATS.STAT_GET_BOOL(util.joaat(MP_INDEX() .. Stat), BoolPTR, -1)
    end

    if memory.read_byte(BoolPTR) == 1 then
        return "true"
    else
        return "false"
    end
end

--- GLOBAL Functions ---
function SET_INT_GLOBAL(Global, Value)
    memory.write_int(memory.script_global(Global), Value)
end

function SET_FLOAT_GLOBAL(Global, Value)
    memory.write_float(memory.script_global(Global), Value)
end

-- GET
function GET_INT_GLOBAL(Global)
    return memory.read_int(memory.script_global(Global))
end

function SET_PACKED_INT_GLOBAL(StartGlobal, EndGlobal, Value)
    for i = StartGlobal, EndGlobal do
        SET_INT_GLOBAL(262145 + i, Value)
    end
end

function SET_INT_LOCAL(Script, Local, Value)
    if memory.script_local(Script, Local) ~= 0 then
        memory.write_int(memory.script_local(Script, Local), Value)
    end
end

function SET_FLOAT_LOCAL(Script, Local, Value)
    if memory.script_local(Script, Local) ~= 0 then
        memory.write_float(memory.script_local(Script, Local), Value)
    end
end

-- GET
function GET_INT_LOCAL(Script, Local)
    if memory.script_local(Script, Local) ~= 0 then
        return memory.read_int(memory.script_local(Script, Local))
    end
end

---
util.keep_running()

menu.divider(menu.my_root(), "RScript")

----------------------------
---------- 自我选项 ----------
----------------------------

local self_options = menu.list(menu.my_root(), "自我选项", {}, "")

local self_options_CUSTOM = menu.list(self_options, "自定义血量护甲", {}, "")

-- -- -- 自定义最大生命值 -- -- --
menu.divider(self_options_CUSTOM, "Health")

local defaultHealth = ENTITY.GET_ENTITY_MAX_HEALTH(PLAYER.PLAYER_PED_ID())
local moddedHealth = defaultHealth
local moddedHealthSlider

menu.toggle(self_options_CUSTOM, "自定义最大生命值", {}, "改变你的最大生命值。一些菜单会将你标记为作弊者。当它被禁用时，它会返回到默认的最大生命值。", function(toggle)
    UsingModHealth = toggle

    local localPed = PLAYER.PLAYER_PED_ID()
    if UsingModHealth then
        PED.SET_PED_MAX_HEALTH(localPed, moddedHealth)
        ENTITY.SET_ENTITY_HEALTH(localPed, moddedHealth)
    else
        PED.SET_PED_MAX_HEALTH(localPed, defaultHealth)
        menu.trigger_command(moddedHealthSlider, defaultHealth) -- just if you want the slider to go to default value when mod health is off
        if ENTITY.GET_ENTITY_HEALTH(localPed) > defaultHealth then
            ENTITY.SET_ENTITY_HEALTH(localPed, defaultHealth)
        end
    end
    util.create_tick_handler(function()
        if PED.GET_PED_MAX_HEALTH(PLAYER.PLAYER_PED_ID()) ~= moddedHealth then
            PED.SET_PED_MAX_HEALTH(PLAYER.PLAYER_PED_ID(), moddedHealth)
            ENTITY.SET_ENTITY_HEALTH(PLAYER.PLAYER_PED_ID(), moddedHealth)
        end
        return UsingModHealth
    end)
end)

moddedHealthSlider = menu.slider(self_options_CUSTOM, "最大生命值", { "rsetmaxhealth" }, "生命值将被修改为指定的数值", 50, 30000, defaultHealth, 50, function(value)
    moddedHealth = value
end)


-- -- -- 自定义最大护甲 -- -- --
menu.divider(self_options_CUSTOM, "Armour")

local defaultArmour = PLAYER.GET_PLAYER_MAX_ARMOUR(PLAYER.PLAYER_ID())
local moddedArmour = defaultArmour
local moddedArmourSlider

menu.toggle(self_options_CUSTOM, "自定义最大护甲值", {}, "改变你的最大护甲值。一些菜单会将你标记为作弊者。当它被禁用时，它会返回到默认的最大护甲值。", function(toggle)
    UsingModArmour = toggle

    if UsingModArmour then
        PLAYER.SET_PLAYER_MAX_ARMOUR(PLAYER.PLAYER_ID(), moddedArmour)
    else
        PLAYER.SET_PLAYER_MAX_ARMOUR(PLAYER.PLAYER_ID(), defaultArmour)
        menu.trigger_command(moddedArmourSlider, defaultArmour) -- just if you want the slider to go to default value when mod Armour is off
    end
    util.create_tick_handler(function()
        if PLAYER.GET_PLAYER_MAX_ARMOUR(PLAYER.PLAYER_ID()) ~= moddedArmour then
            PLAYER.SET_PLAYER_MAX_ARMOUR(PLAYER.PLAYER_ID(), moddedArmour)
        end
        return UsingModArmour
    end)
end)

moddedArmourSlider = menu.slider(self_options_CUSTOM, "最大护甲值", { "rsetmaxarmour" }, "护甲将被修改为指定的数值", 50, 30000, defaultArmour, 50, function(value)
    moddedArmour = value
end)

-----
local self_options_CUSTOM_refill = menu.list(self_options, "自定义生命恢复", {}, "")

local function set_health_refill_limit_and_mult(limit, mult)
    PLAYER._SET_PLAYER_HEALTH_RECHARGE_LIMIT(PLAYER.PLAYER_ID(), limit)
    PLAYER.SET_PLAYER_HEALTH_RECHARGE_MULTIPLIER(PLAYER.PLAYER_ID(), mult)
end

-- 正常状态
menu.divider(self_options_CUSTOM_refill, "站立不动状态")

local normal_refill_limit = 0.25
local normal_refill_mult = 1.0
local isCustomRefill_Normal

menu.toggle(self_options_CUSTOM_refill, "功能开启", {}, "", function(toggle)
    isCustomRefill_Normal = toggle

    while isCustomRefill_Normal do
        set_health_refill_limit_and_mult(normal_refill_limit, normal_refill_mult)
        util.yield(300)
    end

    if not isCustomRefill_Normal then
        set_health_refill_limit_and_mult(0.25, 1.0)
    end
end)

menu.slider(self_options_CUSTOM_refill, "恢复程度", { "normal_refill_limit" }, "恢复到血量的多少，单位%\n默认：25%", 1, 100, 25, 10, function(value)
    normal_refill_limit = value * 0.01
end)

menu.slider(self_options_CUSTOM_refill, "恢复速度", { "normal_refill_mult" }, "恢复速度\n默认：1.0", 1.0, 100.0, 1.0, 1.0, function(value)
    normal_refill_mult = value
end)

-- 掩体状态
menu.divider(self_options_CUSTOM_refill, "掩体状态")

local cover_refill_limit = 0.25
local cover_refill_mult = 1.0
local isCustomRefill_Cover

menu.toggle(self_options_CUSTOM_refill, "功能开启", {}, "", function(toggle)
    isCustomRefill_Cover = toggle

    while isCustomRefill_Cover do
        if PED.IS_PED_IN_COVER(PLAYER.PLAYER_PED_ID()) then
            set_health_refill_limit_and_mult(cover_refill_limit, cover_refill_mult)
        end
        util.yield(300)
    end

    if not isCustomRefill_Cover then
        set_health_refill_limit_and_mult(0.25, 1.0)
    end
end)

menu.slider(self_options_CUSTOM_refill, "恢复程度", { "cover_refill_limit" }, "恢复到血量的多少，单位%\n默认：25%", 1, 100, 25, 10, function(value)
    cover_refill_limit = value * 0.01
end)

menu.slider(self_options_CUSTOM_refill, "恢复速度", { "cover_refill_mult" }, "恢复速度\n默认：1.0", 1.0, 100.0, 1.0, 1.0, function(value)
    cover_refill_mult = value
end)

------
menu.divider(self_options, "恢复")

menu.action(self_options, "恢复生命", {}, "恢复到最大血量 MAX_HEALTH", function()
    ENTITY.SET_ENTITY_HEALTH(PLAYER.PLAYER_PED_ID(), PED.GET_PED_MAX_HEALTH(PLAYER.PLAYER_PED_ID()))
end)

menu.action(self_options, "恢复护甲", {}, "标准恢复护甲 50&100", function()
    if util.is_session_started() then
        PED.SET_PED_ARMOUR(PLAYER.PLAYER_PED_ID(), 50)
    else
        PED.SET_PED_ARMOUR(PLAYER.PLAYER_PED_ID(), 100)
    end
end)

menu.action(self_options, "恢复护甲(满)", {}, "恢复到最大护甲 MAX_ARMOUR", function()
    PED.SET_PED_ARMOUR(PLAYER.PLAYER_PED_ID(), PLAYER.GET_PLAYER_MAX_ARMOUR(PLAYER.PLAYER_ID()))
end)

local function set_health_recharge_limit_and_mult(limit, mult)
    PLAYER._SET_PLAYER_HEALTH_RECHARGE_LIMIT(PLAYER.PLAYER_ID(), limit)
    PLAYER.SET_PLAYER_HEALTH_RECHARGE_MULTIPLIER(PLAYER.PLAYER_ID(), mult)
end

menu.toggle(self_options, "掩体内快速恢复生命", {}, "", function(toggle)
    UsingRefillInCover = toggle

    while UsingRefillInCover do
        if PED.IS_PED_IN_COVER(PLAYER.PLAYER_PED_ID()) then
            set_health_recharge_limit_and_mult(1, 15)
        else
            set_health_recharge_limit_and_mult(0.5, 1.0)
        end
        util.yield(300)
    end

    if not UsingRefillInCover then
        set_health_recharge_limit_and_mult(0.25, 1.0)
    end
end)

---
local toLockHealth = defaultHealth * 0.5

menu.toggle(self_options, "当血量过低时锁定", {}, "当你的血量低于你设置的值后，锁定你的血量，以免死亡", function(toggle)
    islockHealth = toggle
    local localPed = PLAYER.PLAYER_PED_ID()
    local currentHealth

    util.create_tick_handler(function()
        if islockHealth then
            currentHealth = ENTITY.GET_ENTITY_HEALTH(localPed)
            if currentHealth < toLockHealth then
                ENTITY.SET_ENTITY_HEALTH(localPed, toLockHealth)
            end
        end
    end)
end)

lockHealthSlider = menu.slider(self_options, "低于多少%血量", { "rlockhealth" }, "锁定前到达的最低血量，单位%", 10, 100, 50, 10, function(value)
    local maxHealth = ENTITY.GET_ENTITY_MAX_HEALTH(PLAYER.PLAYER_PED_ID())
    toLockHealth = maxHealth * value / 100
end)

------
menu.divider(self_options, "通知")

menu.action(self_options, "通知当前血量和最大血量", {}, "", function()
    local player_maxhealth = PED.GET_PED_MAX_HEALTH(PLAYER.PLAYER_PED_ID())
    local player_currenthealth = ENTITY.GET_ENTITY_HEALTH(PLAYER.PLAYER_PED_ID())
    util.toast("当前血量：" .. player_currenthealth .. "\n最大血量：" .. player_maxhealth)
end)

menu.action(self_options, "通知当前护甲和最大护甲", {}, "", function()
    local player_currentarmour = PED.GET_PED_ARMOUR(PLAYER.PLAYER_PED_ID())
    local player_maxarmour = PLAYER.GET_PLAYER_MAX_ARMOUR(PLAYER.PLAYER_ID())
    util.toast("当前护甲：" .. player_currentarmour .. "\n最大护甲：" .. player_maxarmour)
end)

------
menu.divider(self_options, "")

menu.toggle_loop(self_options, "警察无视", {}, "", function(toggle)
    PLAYER.SET_POLICE_IGNORE_PLAYER(PLAYER.PLAYER_ID(), toggle)
end)

menu.toggle_loop(self_options, "所有人无视", {}, "", function(toggle)
    PLAYER.SET_EVERYONE_IGNORE_PLAYER(PLAYER.PLAYER_ID(), toggle)
end)

menu.toggle_loop(self_options, "行动无声", {}, "", function()
    PLAYER.SET_PLAYER_NOISE_MULTIPLIER(PLAYER.PLAYER_ID(), 0.0)
end)


----------------------------
---------- 武器选项 ----------
----------------------------

local weapon_options = menu.list(menu.my_root(), "武器选项", {}, "")

menu.toggle(weapon_options, "可以射击队友", {}, '使你在游戏中能够射击队友', function(toggle)
    PED.SET_CAN_ATTACK_FRIENDLY(PLAYER.PLAYER_PED_ID(), toggle, false)
end)

menu.toggle_loop(weapon_options, '翻滚时自动换弹夹', {}, '当你做翻滚动作时更换弹夹', function()
    if TASK.GET_IS_TASK_ACTIVE(PLAYER.PLAYER_PED_ID(), 4) and PAD.IS_CONTROL_PRESSED(2, 22) and not PED.IS_PED_SHOOTING(PLAYER.PLAYER_PED_ID()) then
        --checking if player is rolling
        util.yield(900)
        WEAPON.REFILL_AMMO_INSTANTLY(PLAYER.PLAYER_PED_ID())
    end
end)

menu.toggle(weapon_options, "无限弹药", { "inf_ammo" }, '可以避免子弹过多的检测', function(toggle)
    isInfiniteAmmo = toggle

    while isInfiniteAmmo do
        WEAPON.SET_PED_INFINITE_AMMO_CLIP(PLAYER.PLAYER_PED_ID(), true)
        util.yield()
    end

    if not isInfiniteAmmo then
        WEAPON.SET_PED_INFINITE_AMMO_CLIP(PLAYER.PLAYER_PED_ID(), false)
    end
end)

menu.toggle_loop(weapon_options, "锁定弹药", { "lock_ammo" }, "锁定当前武器为最大弹药", function()
    local curWeaponMem = memory.alloc()
    local junk = WEAPON.GET_CURRENT_PED_WEAPON(PLAYER.PLAYER_PED_ID(), curWeaponMem, 1)
    local curWeapon = memory.read_int(curWeaponMem)
    memory.free(curWeaponMem)

    local curAmmoMem = memory.alloc()
    junk = WEAPON.GET_MAX_AMMO(PLAYER.PLAYER_PED_ID(), curWeapon, curAmmoMem)
    local curAmmoMax = memory.read_int(curAmmoMem)
    memory.free(curAmmoMem)

    if curAmmoMax then
        WEAPON.SET_PED_AMMO(PLAYER.PLAYER_PED_ID(), curWeapon, curAmmoMax)
    end
end)

------- 实体控制枪 -------
local entity_control = menu.list(weapon_options, "实体控制枪", {}, "控制你所瞄准的实体")

-- 遍历数组 判断某值是否在表中
function isInTable(tbl, value)
    for k, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

-- 根据值清空对应的元素（非删除操作）
function clearTableValue(t, value)
    for k, v in pairs(t) do
        if v == value then
            t[k] = nil
        end
    end
end

--- all entity type functions ---
function entity_control_all(menu_parent, ent)
    menu.action(menu_parent, "检测该实体是否存在", {}, "", function()
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            util.toast("实体存在")
        else
            util.toast("该实体已经不存在，请删除此条实体记录！")
        end
    end)
    menu.action(menu_parent, "删除此条实体记录", {}, "", function()
        menu.delete(menu_parent)
        clearTableValue(control_ent_menu_list, menu_parent)
        clearTableValue(control_ent_list, ent)
    end)
    --- ---
    menu.divider(menu_parent, "Entity")

    menu.toggle(menu_parent, "无敌", {}, "", function(toggle)
        ENTITY.SET_ENTITY_INVINCIBLE(ent, toggle)
        ENTITY.SET_ENTITY_PROOFS(ent, toggle, toggle, toggle, toggle, toggle, toggle, toggle, toggle)
    end)
    menu.toggle(menu_parent, "冻结", {}, "", function(toggle)
        ENTITY.FREEZE_ENTITY_POSITION(ent, toggle)
    end)
    --- ---
    menu.divider(menu_parent, "血量")
    menu.action(menu_parent, "获取当前血量", {}, "", function()
        util.toast("当前血量: " .. ENTITY.GET_ENTITY_HEALTH(ent))
    end)
    local control_ent_health = 1000
    menu.slider(menu_parent, "血量", { "control_ent_health" }, "", 0, 30000, 1000, 100, function(value)
        control_ent_health = value
    end)
    menu.action(menu_parent, "设置血量", {}, "", function()
        ENTITY.SET_ENTITY_HEALTH(ent, control_ent_health)
    end)
    --- ---
    menu.divider(menu_parent, "移动")
    menu.click_slider(menu_parent, "前/后移动", {}, "", -100, 100, 0, 1, function(value)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, 0.0, value, 0.0)
        ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
    end)

    menu.click_slider(menu_parent, "左/右移动", {}, "", -100, 100, 0, 1, function(value)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, value, 0.0, 0.0)
        ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
    end)

    menu.click_slider(menu_parent, "上/下移动", {}, "", -100, 100, 0, 1, function(value)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, 0.0, 0.0, value)
        ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
    end)

    menu.click_slider(menu_parent, "朝向", {}, "", -360, 360, 0, 10, function(value)
        local head = ENTITY.GET_ENTITY_HEADING(ent)
        ENTITY.SET_ENTITY_HEADING(ent, head + value)
    end)
    --- ---
    menu.divider(menu_parent, "传送")
    menu.click_slider(menu_parent, "传送到我面前", {}, "", -10, 10, 2, 1, function(value)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0.0, value, 0.0)
        ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
    end)

    menu.toggle_loop(menu_parent, "锁定传送在我头上", {}, "", function()
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0.0, 0.0, 2.0)
        ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
    end)

    menu.action(menu_parent, "离我的距离", {}, "", function()
        local my_pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        local ent_pos = ENTITY.GET_ENTITY_COORDS(ent)
        util.toast(vect.dist(my_pos, ent_pos))
    end)

    menu.click_slider(menu_parent, "最大速度", { "control_ent_max_speed" }, "", 0.0, 1000.0, 30.0, 10.0, function(value)
        ENTITY.SET_ENTITY_MAX_SPEED(ent, value)
    end)

end

--- PED entity type functions ---
function entity_control_ped(menu_parent, ped)
    menu.divider(menu_parent, "Ped")

    menu.action(menu_parent, "传送到我的载具", {}, "", function()
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
        if vehicle then
            if VEHICLE.ARE_ANY_VEHICLE_SEATS_FREE(vehicle) then
                PED.SET_PED_INTO_VEHICLE(ped, vehicle, -2)
            end
        end
    end)

    menu.action(menu_parent, "移除全部武器", {}, "", function()
        WEAPON.REMOVE_ALL_PED_WEAPONS(ped)
    end)

    local weapon_list = {
        "微型冲锋枪", "特质卡宾步枪", "突击霰弹枪", "火神机枪", "火箭筒", "电磁步枪"
    }
    local weapon_list_model = {
        "WEAPON_MICROSMG", "WEAPON_SPECIALCARBINE", "WEAPON_ASSAULTSHOTGUN", "WEAPON_MINIGUN", "WEAPON_RPG", "WEAPON_RAILGUN"
    }
    menu.action_slider(menu_parent, "给予武器", {}, "", weapon_list, function(value)
        local weaponHash = util.joaat(weapon_list_model[value])
        WEAPON.GIVE_WEAPON_TO_PED(ped, weaponHash, -1, false, true)
        WEAPON.SET_CURRENT_PED_WEAPON(ped, weaponHash, false)
    end)

    menu.action(menu_parent, "一键无敌强化NPC", {}, "适用于友方NPC", function()
        ENTITY.SET_ENTITY_INVINCIBLE(ped, true)
        ENTITY.SET_ENTITY_PROOFS(ped, true, true, true, true, true, true, true, true)
        PED.SET_PED_CAN_RAGDOLL(ped, false)

        PED.SET_PED_HIGHLY_PERCEPTIVE(ped, true)
        PED.SET_PED_VISUAL_FIELD_PERIPHERAL_RANGE(ped, 500.0)
        PED.SET_PED_SEEING_RANGE(ped, 500.0)
        PED.SET_PED_HEARING_RANGE(ped, 500.0)

        WEAPON.SET_PED_INFINITE_AMMO_CLIP(ped, true)
        PED.SET_PED_SHOOT_RATE(ped, 1000.0)
        PED.SET_PED_ACCURACY(ped, 100.0)
        PED.SET_PED_CAN_BE_SHOT_IN_VEHICLE(ped, true)

        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 5, true) --AlwaysFight
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 12, true) --BlindFireWhenInCover
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 27, true) --PerfectAccuracy
        PED.SET_PED_COMBAT_MOVEMENT(ped, 2)
        PED.SET_PED_COMBAT_ABILITY(ped, 2)
        PED.SET_PED_COMBAT_RANGE(ped, 2)
        PED.SET_PED_TARGET_LOSS_RESPONSE(ped, 1)
        PED.SET_COMBAT_FLOAT(ped, 10, 500.0)
        util.toast("Done")
    end)

end

--- VEHICLE entity type functions ---
function entity_control_vehicle(menu_parent, vehicle)
    menu.divider(menu_parent, "Vehicle")

    menu.action(menu_parent, "踢出载具内NPC", {}, "", function()
        local seats = VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(vehicle)
        for k = -1, seats do
            local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, k)
            if ped > 0 then
                PED.SET_PED_CAN_BE_KNOCKED_OFF_VEHICLE(ped, KNOCKOFFVEHICLE_EASY)
                PED.KNOCK_PED_OFF_VEHICLE(ped)
            end
        end
    end)

    menu.action(menu_parent, "拆下车门", {}, "", function()
        for i = 0, 3 do
            VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, i, false)
        end
    end)

    menu.toggle(menu_parent, "车门开关", {}, "", function(toggle)
        if toggle then
            for i = 0, 3 do
                VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, i, false, false)
            end
        else
            VEHICLE.SET_VEHICLE_DOORS_SHUT(vehicle, false)
        end
    end)

    menu.toggle(menu_parent, "车门锁", {}, "", function(toggle)
        if toggle then
            VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle, 2)
        else
            VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle, 1)
            VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_PLAYER(vehicle, players.user(), false)
        end
    end)

    menu.click_slider(menu_parent, "向前的速度", { "control_veh_forward_speed" }, "", 0.0, 1000.0, 30.0, 10.0, function(value)
        VEHICLE.SET_VEHICLE_FORWARD_SPEED(vehicle, value)
    end)

    menu.action(menu_parent, "修复载具", {}, "", function()
        VEHICLE.SET_VEHICLE_FIXED(vehicle)
        VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, 1000.0)
    end)

end


-- 所有控制的实体
control_ent_list = {}
-- 所有控制实体的menu.list
control_ent_menu_list = {}

menu.toggle_loop(entity_control, "开启", {}, "", function()
    local ent = GetEntity_PlayerIsAimingAt(players.user())
    if ent ~= NULL and ENTITY.DOES_ENTITY_EXIST(ent) then
        if not isInTable(control_ent_list, ent) then
            table.insert(control_ent_list, ent)
            ---
            local modelHash = ENTITY.GET_ENTITY_MODEL(ent)
            local entity_types = { "No entity", "Ped", "Vehicle", "Object" }
            local entity_type = entity_types[ENTITY.GET_ENTITY_TYPE(ent) + 1]
            if ENTITY.GET_ENTITY_TYPE(ent) == 3 then
                if OBJECT.IS_OBJECT_A_PICKUP(ent) or OBJECT.IS_OBJECT_A_PORTABLE_PICKUP(ent) then
                    entity_type = "Pickup"
                end
            end
            local entity_info = "Hash: " .. modelHash .. " (" .. entity_type .. ")"
            util.toast(entity_info)
            ---
            menu_control_entity = menu.list(entity_control, entity_info, {}, "")
            entity_control_all(menu_control_entity, ent)
            -- ped
            if ENTITY.GET_ENTITY_TYPE(ent) == 1 then
                entity_control_ped(menu_control_entity, ent)
            end
            -- vehicle
            if ENTITY.GET_ENTITY_TYPE(ent) == 2 then
                entity_control_vehicle(menu_control_entity, ent)
            end

            table.insert(control_ent_menu_list, menu_control_entity)
        end

    end
end)

menu.action(entity_control, "清除记录的实体", {}, "", function()
    for k, v in pairs(control_ent_menu_list) do
        if v ~= nil then
            menu.delete(v)
        end
    end
    -- 所有控制的实体
    control_ent_list = {}
    -- 所有控制实体的menu.list
    control_ent_menu_list = {}
end)

menu.divider(entity_control, "实体控制")


----------------------------
---------- 载具选项 ----------
----------------------------

local vehicle_options = menu.list(menu.my_root(), "载具选项", {}, "")

menu.action(vehicle_options, "修复载具无法移动", {}, "尝试而已", function()
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
    if vehicle then
        VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, 1000)
        VEHICLE.SET_VEHICLE_PETROL_TANK_HEALTH(vehicle, 1000)
        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(vehicle)
        ENTITY.FREEZE_ENTITY_POSITION(vehicle, false)
    end
end)

local dirt_level = 0.0
menu.slider(vehicle_options, "载具灰尘程度", {}, "载具全身灰尘程度", 0.0, 15.0, 0.0, 1.0, function(value)
    dirt_level = value
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
    if vehicle then
        VEHICLE.SET_VEHICLE_DIRT_LEVEL(vehicle, dirt_level)
    end
end)

menu.toggle_loop(vehicle_options, "锁定载具灰尘程度", {}, "", function()
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
    if vehicle then
        VEHICLE.SET_VEHICLE_DIRT_LEVEL(vehicle, dirt_level)
    end
end)

menu.toggle_loop(vehicle_options, "防弹轮胎", {}, "", function()
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
    if vehicle then
        VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(vehicle, false)
    end
end)
---
menu.divider(vehicle_options, "解锁载具")
menu.toggle_loop(vehicle_options, "载具引擎快速开启", {}, "减少载具启动引擎时间", function()
    local localped = PLAYER.PLAYER_PED_ID()
    if PED.IS_PED_GETTING_INTO_A_VEHICLE(localped) then
        local veh = PED.GET_VEHICLE_PED_IS_ENTERING(localped)
        if not VEHICLE.GET_IS_VEHICLE_ENGINE_RUNNING(veh) then
            VEHICLE.SET_VEHICLE_ENGINE_HEALTH(veh, 1000)
            VEHICLE.SET_VEHICLE_ENGINE_ON(veh, true, true, false)
        end
        if VEHICLE.GET_VEHICLE_CLASS(veh) == 15 then
            --15 is heli
            VEHICLE.SET_HELI_BLADES_FULL_SPEED(veh)
        end
    end
end)

-- 解锁正在进入的载具
function UnlockVehicleGetIn()
    :: start ::
    local localPed = PLAYER.PLAYER_PED_ID()
    local veh = PED.GET_VEHICLE_PED_IS_TRYING_TO_ENTER(localPed)
    if PED.IS_PED_IN_ANY_VEHICLE(localPed, false) then
        local v = PED.GET_VEHICLE_PED_IS_IN(localPed, false)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED(v, 1)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(v, false)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_PLAYER(v, players.user(), false)
        ENTITY.FREEZE_ENTITY_POSITION(vehicle, false)
        util.yield()
    else
        if veh ~= 0 then
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh)
            if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(veh) then
                for i = 1, 20 do
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh)
                    util.yield(100)
                end
            end
            if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(veh) then
                util.toast("Waited 2 secs, couldn't get control!")
                goto start
            else
                util.toast("Has control.")
            end
            VEHICLE.SET_VEHICLE_DOORS_LOCKED(veh, 1)
            VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(veh, false)
            VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_PLAYER(veh, players.user(), false)
            VEHICLE.SET_VEHICLE_HAS_BEEN_OWNED_BY_PLAYER(veh, false)
        end
    end
end

menu.toggle_loop(vehicle_options, "解锁正在进入的载具", {}, "解锁你正在进入的载具。对于锁住的玩家载具也有效果。", function()
    UnlockVehicleGetIn()
end)
-------

menu.divider(vehicle_options, "载具车窗")
menu.toggle_loop(vehicle_options, "自动修复前车窗", {}, "", function()
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
    if vehicle then
        VEHICLE.FIX_VEHICLE_WINDOW(vehicle, 6)
    end
end)

menu.toggle_loop(vehicle_options, "自动修复后车窗", {}, "", function()
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
    if vehicle then
        VEHICLE.FIX_VEHICLE_WINDOW(vehicle, 7)
    end
end)
---
menu.divider(vehicle_options, "载具自动门")
menu.toggle_loop(vehicle_options, "拆下左前门", {}, "", function()
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
    if vehicle then
        VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, 0, false)
    end
end)

menu.toggle_loop(vehicle_options, "拆下右前门", {}, "", function()
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
    if vehicle then
        VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, 1, false)
    end
end)

menu.toggle_loop(vehicle_options, "拆下全部门", {}, "", function()
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
    if vehicle then
        VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, 0, false)
        VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, 1, false)
        VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, 2, false)
        VEHICLE.SET_VEHICLE_DOOR_BROKEN(vehicle, 3, false)
    end
end)
---
menu.divider(vehicle_options, "个人载具")
menu.action(vehicle_options, "打开引擎和左车门", {}, "", function()
    local vehicle = entities.get_user_personal_vehicle_as_handle()
    if vehicle then
        VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, false)
        VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, 0, false, false)
    end
end)

menu.action(vehicle_options, "开启载具引擎", {}, "", function()
    local vehicle = entities.get_user_personal_vehicle_as_handle()
    if vehicle then
        VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, false)
    end
end)

menu.action(vehicle_options, "打开左车门", {}, "", function()
    local vehicle = entities.get_user_personal_vehicle_as_handle()
    if vehicle then
        VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, 0, false, false)
    end
end)

menu.action(vehicle_options, "打开左右车门", {}, "", function()
    local vehicle = entities.get_user_personal_vehicle_as_handle()
    if vehicle then
        VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, 0, false, false)
        VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, 1, false, false)
    end
end)


-------------------------------
---------- 周围实体选项 ----------
-------------------------------

local entity_options = menu.list(menu.my_root(), "周围实体选项", {}, "")

local NEAR_PED_CAM = menu.list(entity_options, "管理附近的NPC和摄像头", {}, "来自Heist Control")

menu.divider(NEAR_PED_CAM, "设置")

local HostilePed = false
menu.toggle(NEAR_PED_CAM, "只对怀有敌意的NPC有效", {}, "启用：只对怀有敌意的NPC生效" .. "\n" .. "禁用：对所有NPC生效", function(Toggle)
    HostilePedToggle = Toggle

    if HostilePedToggle then
        HostilePed = true
    else
        HostilePed = false
    end
end)

-----
menu.divider(NEAR_PED_CAM, "NPC选项")

menu.action(NEAR_PED_CAM, "移除NPC武器", {}, "", function()
    for k, ent in pairs(entities.get_all_peds_as_handles()) do
        if not IS_PED_PLAYER(ent) then
            if HostilePed then
                if PED.IS_PED_IN_COMBAT(ent, PLAYER.PLAYER_ID()) then
                    WEAPON.REMOVE_ALL_PED_WEAPONS(ent, true)
                end
            else
                WEAPON.REMOVE_ALL_PED_WEAPONS(ent, true)
            end
        end
    end
end)

menu.action(NEAR_PED_CAM, "删除所有NPC", {}, "", function()
    for k, ent in pairs(entities.get_all_peds_as_handles()) do
        if not IS_PED_PLAYER(ent) then
            if HostilePed then
                if PED.IS_PED_IN_COMBAT(ent, PLAYER.PLAYER_ID()) then
                    entities.delete_by_handle(ent)
                end
            else
                entities.delete_by_handle(ent)
            end
        end
    end
end)

menu.action(NEAR_PED_CAM, "杀死所有NPC", {}, "", function()
    for k, ent in pairs(entities.get_all_peds_as_handles()) do
        if not IS_PED_PLAYER(ent) then
            if HostilePed then
                if PED.IS_PED_IN_COMBAT(ent, PLAYER.PLAYER_ID()) then
                    ENTITY.SET_ENTITY_HEALTH(ent, 0.0)
                end
            else
                ENTITY.SET_ENTITY_HEALTH(ent, 0.0)
            end
        end
    end
end)

-----
menu.divider(NEAR_PED_CAM, "摄像头选项")

menu.action(NEAR_PED_CAM, "删除摄像头", {}, "几乎可以删除全部摄像头了", function()
    -- Credit goes to Leif.Erickson
    for k, ent in pairs(entities.get_all_objects_as_handles()) do
        local EntityModel = ENTITY.GET_ENTITY_MODEL(ent)
        local Cams = {
            -1233322078,
            168901740,
            -1095296451,
            -173206916,
            -1159421424,
            548760764,
            -1340405475,
            1449155105,
            -354221800,
            -1884701657,
            2090203758,
            -1007354661,
            -1842407088,
            289451089,
            3061645218
        }

        for i = 1, #Cams do
            if EntityModel == Cams[i] then
                entities.delete_by_handle(ent)
            end
        end
    end
end)

menu.action(NEAR_PED_CAM, "摄像头上天", {}, "上天了就拍不到你了", function()
    -- Credit goes to Leif.Erickson
    for k, ent in pairs(entities.get_all_objects_as_handles()) do
        local EntityModel = ENTITY.GET_ENTITY_MODEL(ent)
        local Cams = {
            -1233322078,
            168901740,
            -1095296451,
            -173206916,
            -1159421424,
            548760764,
            -1340405475,
            1449155105,
            -354221800,
            -1884701657,
            2090203758,
            -1007354661,
            -1842407088,
            289451089,
            3061645218
        }

        for i = 1, #Cams do
            if EntityModel == Cams[i] then
                local pos = ENTITY.GET_ENTITY_COORDS(ent)
                ENTITY.SET_ENTITY_COORDS(ent, pos.x, pos.y, pos.z + 20.0, true, false, false, false)
            end
        end
    end
end)

-- -- 附近载具
local NEARBY_VEHICLE = menu.list(entity_options, "管理附近载具", {}, "")

local radius_nearby_vehicle = 30
menu.slider(NEARBY_VEHICLE, "范围半径", { "radius_nearby_vehicle" }, "", 0, 1000, 30, 10, function(value)
    radius_nearby_vehicle = value
end)

menu.action(NEARBY_VEHICLE, "爆炸附近载具", {}, "", function()
    for k, vehicle in pairs(GET_NEARBY_VEHICLES(players.user(), radius_nearby_vehicle)) do
        VEHICLE.EXPLODE_VEHICLE(vehicle, true, true)
    end
end)

menu.divider(NEARBY_VEHICLE, "载具上天")

local launch_vehicle_height = 20
menu.slider(NEARBY_VEHICLE, "上天高度", { "launch_vehicle_height" }, "", 0, 1000, 20, 10, function(value)
    launch_vehicle_height = value
end)

local launch_vehicle_freeze = false
menu.toggle(NEARBY_VEHICLE, "冻结载具", {}, "", function(toggle)
    launch_vehicle_freeze = toggle
end)

menu.action(NEARBY_VEHICLE, "发射上天", {}, "", function()
    for k, vehicle in ipairs(GET_NEARBY_VEHICLES(players.user(), radius_nearby_vehicle)) do
        if vehicle ~= entities.get_user_vehicle_as_handle() then
            if launch_vehicle_freeze then
                ENTITY.FREEZE_ENTITY_POSITION(vehicle, true)
            end
            local pos = ENTITY.GET_ENTITY_COORDS(vehicle)
            ENTITY.SET_ENTITY_COORDS(vehicle, pos.x, pos.y, pos.z + launch_vehicle_height, false, false, false, false)
        end
    end
end)

-- -- 附近NPC
local NEARBY_PED = menu.list(entity_options, "管理附近NPC", {}, "")

local radius_nearby_ped = 30
menu.slider(NEARBY_PED, "范围半径", { "radius_nearby_ped" }, "", 0, 1000, 30, 10, function(value)
    radius_nearby_ped = value
end)

menu.divider(NEARBY_PED, "NPC上天")

local launch_ped_height = 20
menu.slider(NEARBY_PED, "上天高度", { "launch_ped_height" }, "", 0, 1000, 20, 10, function(value)
    launch_ped_height = value
end)

local launch_ped_freeze = false
menu.toggle(NEARBY_PED, "冻结NPC", {}, "", function(toggle)
    launch_ped_freeze = toggle
end)

menu.action(NEARBY_PED, "发射上天", {}, "", function()
    for k, ped in ipairs(GET_NEARBY_PEDS(players.user(), radius_nearby_ped)) do
        if not IS_PED_PLAYER(ped) then
            if launch_ped_freeze then
                ENTITY.FREEZE_ENTITY_POSITION(ped, true)
            end
            local pos = ENTITY.GET_ENTITY_COORDS(ped)
            ENTITY.SET_ENTITY_COORDS(ped, pos.x, pos.y, pos.z + launch_ped_height, false, false, false, false)
        end
    end
end)

---
menu.divider(NEARBY_PED, "NPC侦查视野")

local see_range = 0.0
menu.slider(NEARBY_PED, "视力范围", { "see_range" }, "", 0.0, 20.0, 0.0, 1.0, function(value)
    see_range = value
end)

local hear_range = 0.0
menu.slider(NEARBY_PED, "听力范围", { "hear_range" }, "", 0.0, 20.0, 0.0, 1.0, function(value)
    hear_range = value
end)

local peripheral_range = 0.0
menu.slider(NEARBY_PED, "锥形视野范围", { "peripheral_range" }, "", 0.0, 20.0, 0.0, 1.0, function(value)
    peripheral_range = value
end)

local highly_perceptive = false
menu.toggle(NEARBY_PED, "高度警觉性", {}, "", function(toggle)
    highly_perceptive = toggle
end)

menu.action(NEARBY_PED, "设置", {}, "直接是全部范围", function()
    for k, ped in ipairs(entities.get_all_peds_as_handles()) do
        if not IS_PED_PLAYER(ped) then
            PED.SET_PED_SEEING_RANGE(ped, see_range)
            PED.SET_PED_HEARING_RANGE(ped, hear_range)
            PED.SET_PED_VISUAL_FIELD_PERIPHERAL_RANGE(ped, peripheral_range)
            PED.SET_PED_HIGHLY_PERCEPTIVE(ped, highly_perceptive)
        end
    end
end)

-- -- 任务实体
local MISSION_ENTITY = menu.list(entity_options, "管理任务实体", {}, "")

local MISSION_ENTITY_custom = menu.list(MISSION_ENTITY, "自定义 Model Hash", {}, "")

local custom_model_hash
menu.text_input(MISSION_ENTITY_custom, "输入 Model Hash ", { "custom_model_hash" }, "", function(value)
    custom_model_hash = tonumber(value)
end)

local custom_all_entity = entities.get_all_peds_as_handles()
menu.slider_text(MISSION_ENTITY_custom, "实体类型", {}, "点击应用修改", { "Ped", "Vehicle", "Object", "Pickup" }, function(value)
    if value == 1 then
        custom_all_entity = entities.get_all_peds_as_handles()
        util.toast("Ped")
    elseif value == 2 then
        custom_all_entity = entities.get_all_vehicles_as_handles()
        util.toast("Vehicle")
    elseif value == 3 then
        custom_all_entity = entities.get_all_objects_as_handles()
        util.toast("Object")
    elseif value == 4 then
        custom_all_entity = entities.get_all_pickups_as_handles()
        util.toast("Pickup")
    end
end)

local custom_isMission_entity = true
menu.toggle(MISSION_ENTITY_custom, "IS A MISSION ENTITY", {}, "是否为任务实体", function(toggle)
    custom_isMission_entity = toggle
end, true)

menu.divider(MISSION_ENTITY_custom, "传送到我")

local custom_entity_tpme_x = 0.0
menu.slider(MISSION_ENTITY_custom, "离我左/右的距离", { "custom_entity_tpme_x" }, "", -100.0, 100.0, 0.0, 1.0, function(value)
    custom_entity_tpme_x = value
end)

local custom_entity_tpme_y = 2.0
menu.slider(MISSION_ENTITY_custom, "离我前/后的距离", { "custom_entity_tpme_y" }, "", -100.0, 100.0, 2.0, 1.0, function(value)
    custom_entity_tpme_y = value
end)

local custom_entity_tpme_z = 0.0
menu.slider(MISSION_ENTITY_custom, "离我上/下的高度", { "custom_entity_tpme_z" }, "", -100.0, 100.0, 0.0, 1.0, function(value)
    custom_entity_tpme_z = value
end)

local custom_entity_tpme_head = 0.0
menu.slider(MISSION_ENTITY_custom, "head朝向", { "custom_entity_tpme_head" }, "Not use", -360.0, 360.0, 0.0, 10.0, function(value)
    custom_entity_tpme_head = value
end)

menu.action(MISSION_ENTITY_custom, "传送到我", {}, "", function()
    local flag = false
    if custom_model_hash then
        for k, ent in pairs(custom_all_entity) do
            local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
            if EntityHash == custom_model_hash then
                flag = true
                if custom_isMission_entity then
                    if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
                        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), custom_entity_tpme_x, custom_entity_tpme_y, custom_entity_tpme_z)
                        ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
                    end
                else
                    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), custom_entity_tpme_x, custom_entity_tpme_y, custom_entity_tpme_z)
                    ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
                end
            end
        end

        if not flag then
            util.toast("No this entity !")
        end

    else
        util.toast("Wrong model hash !")
    end
end)

--- ---
local MISSION_ENTITY_cargo = menu.list(MISSION_ENTITY, "CEO拉货", {}, "")

menu.action(MISSION_ENTITY_cargo, "散货板条箱 传送到我", {}, "飞机空投\nModel Hash: -265116550", function()
    local entity_model_hash = -265116550
    for k, ent in pairs(entities.get_all_pickups_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 2.0, -1.0)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
        end
    end
end)

menu.action(MISSION_ENTITY_cargo, "散货板条箱 传送到我", {}, "被飞机抢走\nModel Hash: 1688540826", function()
    local entity_model_hash = 1688540826
    for k, ent in pairs(entities.get_all_pickups_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 2.0, -1.0)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
        end
    end
end)

menu.action(MISSION_ENTITY_cargo, "散货板条箱 传送到我", {}, "被窃贼抢走\n沉船打捞\nModel Hash: -1143129136", function()
    local entity_model_hash = -1143129136
    for k, ent in pairs(entities.get_all_pickups_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 2.0, -1.0)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
        end
    end
end)

menu.action(MISSION_ENTITY_cargo, "追踪的车 传送到我", {}, "Trackify 在车后备箱里\nModel Hash: -1322183878", function()
    local entity_model_hash = -1322183878
    for k, ent in pairs(entities.get_all_objects_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            if ENTITY.IS_ENTITY_ATTACHED(ent) then
                local attached_ent = ENTITY.GET_ENTITY_ATTACHED_TO(ent)
                local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 2.0, -1.0)
                ENTITY.SET_ENTITY_COORDS(attached_ent, coords.x, coords.y, coords.z, true, false, false, false)

                local pHead = ENTITY.GET_ENTITY_HEADING(PLAYER.PLAYER_PED_ID())
                ENTITY.SET_ENTITY_HEADING(attached_ent, pHead + 90.0)
            end
        end
    end
end)

menu.action(MISSION_ENTITY_cargo, "TP to Special Cargo", { "scargo" }, "Teleport to Special Cargo pickup", function()
    local cPickup = HUD.GET_BLIP_COORDS(HUD.GET_NEXT_BLIP_INFO_ID(478))
    HUD.GET_BLIP_COORDS(HUD.GET_NEXT_BLIP_INFO_ID(478))
    if cPickup.x == 0 and cPickup.y == 0 and cPickup.z == 0 then
        util.toast("No Cargo Found")
    else
        ENTITY.SET_ENTITY_COORDS(players.user_ped(), cPickup.x, cPickup.y, cPickup.z, false, false, false, false)
    end
end)

menu.action(MISSION_ENTITY_cargo, "TP to Vehicle Cargo", { "vcargo" }, "Teleport to Vehicle Cargo pickup", function()
    local vPickup = HUD.GET_BLIP_COORDS(HUD.GET_NEXT_BLIP_INFO_ID(523))
    HUD.GET_BLIP_COORDS(HUD.GET_NEXT_BLIP_INFO_ID(523))
    if vPickup.x == 0 and vPickup.y == 0 and vPickup.z == 0 then
        util.toast("No Vehicle Found")
    else
        ENTITY.SET_ENTITY_COORDS(players.user_ped(), vPickup.x, vPickup.y, vPickup.z, false, false, false, false)
    end
end)

--- ---
local MISSION_ENTITY_perico = menu.list(MISSION_ENTITY, "佩里科岛", {}, "")

menu.action(MISSION_ENTITY_perico, "佩里科岛：信号塔 传送到我", {}, "\nModel Hash: 1981815996", function()
    local entity_model_hash = 1981815996
    for k, ent in pairs(entities.get_all_objects_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 2.0, -1.0)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)

            local pHead = ENTITY.GET_ENTITY_HEADING(PLAYER.PLAYER_PED_ID())
            ENTITY.SET_ENTITY_HEADING(ent, pHead)
        end
    end
end)

menu.action(MISSION_ENTITY_perico, "佩里科岛：发电站 传送到我", {}, "\nModel Hash: 1650252819", function()
    local entity_model_hash = 1650252819
    for k, ent in pairs(entities.get_all_objects_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 2.0, 1.0)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)

            local pHead = ENTITY.GET_ENTITY_HEADING(PLAYER.PLAYER_PED_ID())
            ENTITY.SET_ENTITY_HEADING(ent, pHead)
        end
    end
end)

menu.action(MISSION_ENTITY_perico, "佩里科岛：保安服 传送到我", {}, "\nModel Hash: -1141961823", function()
    local entity_model_hash = -1141961823
    for k, ent in pairs(entities.get_all_objects_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 2.0, -1.0)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
        end
    end
end)

menu.action(MISSION_ENTITY_perico, "佩里科岛：螺旋切割器 传送到我", {}, "\nModel Hash: -710382954", function()
    local entity_model_hash = -710382954
    for k, ent in pairs(entities.get_all_pickups_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 2.0, -1.0)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
        end
    end
end)

menu.action(MISSION_ENTITY_perico, "佩里科岛：抓钩 传送到我", {}, "\nModel Hash: -1789904450", function()
    local entity_model_hash = -1789904450
    for k, ent in pairs(entities.get_all_pickups_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 2.0, -1.0)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
        end
    end
end)

menu.action(MISSION_ENTITY_perico, "佩里科岛：运货卡车 传送到我", {}, "自动删除npc卡车司机\nModel Hash: 2014313426", function()
    local entity_model_hash = 2014313426
    for k, ent in pairs(entities.get_all_vehicles_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ent, -1)
            if ped > 0 then
                -- has npc in truck
                if not IS_PED_PLAYER(ped) then
                    entity.delete_entity(ped)
                end
            end

            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 3.0, 0.0)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)

            local pHead = ENTITY.GET_ENTITY_HEADING(PLAYER.PLAYER_PED_ID())
            ENTITY.SET_ENTITY_HEADING(ent, pHead + 90.0)
        end
    end
end)

--

menu.divider(MISSION_ENTITY_perico, "")

menu.action(MISSION_ENTITY_perico, "前置：长崎 传送到我", {}, "\nModel Hash: -1352468814", function()
    local entity_model_hash = -1352468814
    for k, ent in pairs(entities.get_all_vehicles_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 7.0, -1.0)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)

            local pHead = ENTITY.GET_ENTITY_HEADING(PLAYER.PLAYER_PED_ID())
            ENTITY.SET_ENTITY_HEADING(ent, pHead + 180.0)
        end
    end
end)

menu.action(MISSION_ENTITY_perico, "前置：保险箱密码 传送到那里", {}, "赌场 保安队长\nModel Hash: -1109568186", function()
    local entity_model_hash = -1109568186
    for k, ent in pairs(entities.get_all_peds_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, 0.0, 0.0, 0.5)
            ENTITY.SET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), coords.x, coords.y, coords.z, true, false, false, false)
        end
    end
end)

menu.action(MISSION_ENTITY_perico, "前置：等离子切割枪包裹 传送到我", {}, "\nModel Hash: -802406134", function()
    local entity_model_hash = -802406134
    for k, ent in pairs(entities.get_all_pickups_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 0.0, 2.0)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
        end
    end
end)

menu.action(MISSION_ENTITY_perico, "前置：指纹复制器 传送到我", {}, "地下车库\nModel Hash: 1506325614", function()
    local entity_model_hash = 1506325614
    for k, ent in pairs(entities.get_all_pickups_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 0.0, 2.0)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
        end
    end
end)

menu.action(MISSION_ENTITY_perico, "前置：割据 传送到那里", {}, "工地\nModel Hash: 1871441709", function()
    local entity_model_hash = 1871441709
    for k, ent in pairs(entities.get_all_pickups_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, 0.0, 0.0, 0.5)
            ENTITY.SET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), coords.x, coords.y, coords.z, true, false, false, false)
        end
    end
end)

menu.action(MISSION_ENTITY_perico, "前置：武器 炸掉女武神", {}, "\nModel Hash: -1600252419", function()
    local entity_model_hash = -1600252419
    for k, ent in pairs(entities.get_all_vehicles_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local pos = ENTITY.GET_ENTITY_COORDS(ent)
            FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, EXP_TAG_STICKYBOMB, 3.0, true, false, 0, false)
        end
    end
end)

--- ---
local MISSION_ENTITY_casion = menu.list(MISSION_ENTITY, "赌场抢劫", {}, "")

menu.action(MISSION_ENTITY_casion, "前置：保安 传送到我", {}, "侦查前置\nModel Hash: -1094177627", function()
    local entity_model_hash = -1094177627
    for k, ent in pairs(entities.get_all_peds_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 2.0, 10.0)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
            --ENTITY.SET_ENTITY_HEALTH(ent, 0.0)

            local pHead = ENTITY.GET_ENTITY_HEADING(PLAYER.PLAYER_PED_ID())
            ENTITY.SET_ENTITY_HEADING(ent, pHead)
        end
    end
end)

menu.action(MISSION_ENTITY_casion, "前置：武器(车) 传送到我", {}, "国安局面包车 武器在防暴车内\nModel Hash: 1885839156", function()
    local entity_model_hash = 1885839156
    for k, ent in pairs(entities.get_all_objects_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            if ENTITY.IS_ENTITY_ATTACHED(ent) then
                local attached_ent = ENTITY.GET_ENTITY_ATTACHED_TO(ent)
                local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 2.0, -1.0)
                ENTITY.SET_ENTITY_COORDS(attached_ent, coords.x, coords.y, coords.z, true, false, false, false)

                local pHead = ENTITY.GET_ENTITY_HEADING(PLAYER.PLAYER_PED_ID())
                ENTITY.SET_ENTITY_HEADING(attached_ent, pHead + 90.0)
            end
        end
    end
end)

menu.action(MISSION_ENTITY_casion, "前置：武器 传送到我", {}, "摩托车帮 长方形板条\nModel Hash: 798951501", function()
    local entity_model_hash = 798951501
    for k, ent in pairs(entities.get_all_pickups_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 2.0, -1.0)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
        end
    end
end)

menu.action(MISSION_ENTITY_casion, "前置：武器(飞机) 传送到我", {}, "走私犯 水上飞机\nModel Hash: 1043222410", function()
    --Model Hash: -1628917549 (PICKUP) 炸毁飞机掉落的货物
    local entity_model_hash = 1043222410
    for k, ent in pairs(entities.get_all_vehicles_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 5.0, -1.0)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
        end
    end
end)

menu.action(MISSION_ENTITY_casion, "前置：载具 传送到我", {}, "天威 经典版\nModel Hash: 931280609", function()
    local entity_model_hash = 931280609
    for k, ent in pairs(entities.get_all_vehicles_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 2.0, -1.0)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)

            local pHead = ENTITY.GET_ENTITY_HEADING(PLAYER.PLAYER_PED_ID())
            ENTITY.SET_ENTITY_HEADING(attached_ent, pHead + 90.0)
        end
    end
end)

menu.action(MISSION_ENTITY_casion, "前置：骇入装置 传送到我", {}, "FIB大楼 电脑旁边 提箱\n或者 国安局总部 服务器或桌子旁边\nModel Hash: -155327337", function()
    local entity_model_hash = -155327337
    for k, ent in pairs(entities.get_all_pickups_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 2.0, -1.0)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
        end
    end
end)

menu.action(MISSION_ENTITY_casion, "前置：金库门禁卡(狱警) 传送到我", {}, "监狱巴士 监狱 狱警\nModel Hash: 1456041926", function()
    local entity_model_hash = 1456041926
    for k, ent in pairs(entities.get_all_peds_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 2.0, -1.0)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
        end
    end
end)

menu.action(MISSION_ENTITY_casion, "前置：巡逻路线(车) 传送到我", {}, "某辆车后备箱里的箱子\nModel Hash: 1265214509", function()
    local entity_model_hash = 1265214509
    for k, ent in pairs(entities.get_all_objects_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            if ENTITY.IS_ENTITY_ATTACHED(ent) then
                local attached_ent = ENTITY.GET_ENTITY_ATTACHED_TO(ent)
                local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 4.0, -1.0)
                ENTITY.SET_ENTITY_COORDS(attached_ent, coords.x, coords.y, coords.z, true, false, false, false)

                local pHead = ENTITY.GET_ENTITY_HEADING(PLAYER.PLAYER_PED_ID())
                ENTITY.SET_ENTITY_HEADING(attached_ent, pHead)
            end
        end
    end
end)

menu.action(MISSION_ENTITY_casion, "前置：杜根货物 全部爆炸", {}, "直升机 车 船\n一次性好像炸不完\nModel Hash: -1671539132 1747439474 1448677353", function()
    for k, ent in pairs(entities.get_all_vehicles_as_handles()) do
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
            if EntityHash == -1671539132 or EntityHash == 1747439474 or EntityHash == 1448677353 then
                local pos = ENTITY.GET_ENTITY_COORDS(ent)
                FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, EXP_TAG_STICKYBOMB, 3.0, true, false, 0, false)
            end
        end
    end
end)

menu.action(MISSION_ENTITY_casion, "前置：电钻 传送到那里", {}, "工地 找箱子里的电钻\nModel Hash: -12990308", function()
    local entity_model_hash = -12990308
    for k, ent in pairs(entities.get_all_pickups_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, 0.0, 0.0, 0.5)
            ENTITY.SET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), coords.x, coords.y, coords.z, true, false, false, false)
        end
    end
end)

menu.action(MISSION_ENTITY_casion, "前置：二级保安证(尸体) 传送到那里", {}, "灵车 医院 泊车员尸体\nModel Hash: 771433594", function()
    local entity_model_hash = 771433594
    for k, ent in pairs(entities.get_all_objects_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, 0.0, 0.0, 0.5)
            ENTITY.SET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), coords.x, coords.y, coords.z, true, false, false, false)
        end
    end
end)

menu.divider(MISSION_ENTITY_casion, "隐迹潜踪")

menu.action(MISSION_ENTITY_casion, "前置：无人机 传送到我", {}, "纳米无人机\nModel Hash: 1657647215", function()
    -- -1285013058 无人机炸毁后掉落的零件（pickup）
    local entity_model_hash = 1657647215
    for k, ent in pairs(entities.get_all_objects_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 2.0, 0.0)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
        end
    end
end)

menu.action(MISSION_ENTITY_casion, "前置：金库激光器 传送到我", {}, "\nModel Hash: 1953119208", function()
    local entity_model_hash = 1953119208
    for k, ent in pairs(entities.get_all_pickups_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 2.0, -1.0)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
        end
    end
end)

menu.divider(MISSION_ENTITY_casion, "兵不厌诈")

menu.action(MISSION_ENTITY_casion, "前置：古倍科技套装 传送到我", {}, "\nModel Hash: 1425667258", function()
    local entity_model_hash = 1425667258
    for k, ent in pairs(entities.get_all_pickups_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 2.0, -1.0)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
        end
    end
end)

menu.action(MISSION_ENTITY_casion, "前置：金库钻孔机 传送到我", {}, "全福银行\nModel Hash: 415149220", function()
    local entity_model_hash = 415149220
    for k, ent in pairs(entities.get_all_pickups_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 2.0, -1.0)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
        end
    end
end)

menu.action(MISSION_ENTITY_casion, "前置：国安局套装 传送到我", {}, "警察局\nModel Hash: -1713985235", function()
    local entity_model_hash = -1713985235
    for k, ent in pairs(entities.get_all_pickups_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 2.0, -1.0)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
        end
    end
end)

menu.divider(MISSION_ENTITY_casion, "气势汹汹")

menu.action(MISSION_ENTITY_casion, "前置：热能炸药 传送到我", {}, "\nModel Hash: -2043162923", function()
    local entity_model_hash = -2043162923
    for k, ent in pairs(entities.get_all_pickups_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 2.0, -1.0)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
        end
    end
end)

menu.action(MISSION_ENTITY_casion, "前置：金库炸药 传送到我", {}, "要潜水下去 难找恶心\nModel Hash: -681938663", function()
    local entity_model_hash = -681938663
    for k, ent in pairs(entities.get_all_pickups_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 2.0, -1.0)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
        end
    end
end)

menu.action(MISSION_ENTITY_casion, "前置：加固防弹衣 传送到我", {}, "地堡 箱子\nModel Hash: 1715697304", function()
    local entity_model_hash = 1715697304
    for k, ent in pairs(entities.get_all_pickups_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 2.0, 0.0)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
        end
    end
end)

menu.divider(MISSION_ENTITY_casion, "")

menu.action(MISSION_ENTITY_casion, "赌场：小金库手推车 传送到我", {}, "\nModel Hash: 1736112330", function()
    local entity_model_hash = 1736112330
    for k, ent in pairs(entities.get_all_objects_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 2.0, -0.5)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
        end
    end
end)

menu.action(MISSION_ENTITY_casion, "赌场：获取金库内手推车数量", {}, "先获取手推车数量才能传送\nModel Hash: 412463629, 1171655821, 1401432049", function()
    -- 手推车 实体list
    vault_trolley = {}
    local num = 0
    for k, ent in pairs(entities.get_all_objects_as_handles()) do
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
            if EntityHash == 412463629 then
                num = num + 1
                table.insert(vault_trolley, ent)
            elseif EntityHash == 1171655821 then
                num = num + 1
                table.insert(vault_trolley, ent)
            elseif EntityHash == 1401432049 then
                num = num + 1
                table.insert(vault_trolley, ent)
            end
        end
    end
    util.toast("Number: " .. num)
    menu.set_max_value(menu_Vault_Trolley_TP, num)
end)

menu_Vault_Trolley_TP = menu.click_slider(MISSION_ENTITY_casion, "赌场：金库内手推车 传送到我", {}, "", 0, 0, 0, 1, function(value)
    if value > 0 then
        local ent = vault_trolley[value]
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 2.0, -0.5)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)

            local pHead = ENTITY.GET_ENTITY_HEADING(PLAYER.PLAYER_PED_ID())
            ENTITY.SET_ENTITY_HEADING(ent, pHead + 180.0)
        else
            util.toast("实体不存在")
        end
    end
end)

-------- All Type Mission Entities --------
menu.divider(MISSION_ENTITY, "所有任务实体")

--- all entity type functions ---
function mission_entity_all(menu_parent, ent)
    menu.action(menu_parent, "检测该实体是否存在", {}, "", function()
        if ENTITY.DOES_ENTITY_EXIST(ent) then
            util.toast("实体存在")
        else
            util.toast("该实体已经不存在")
        end
    end)

    menu.toggle(menu_parent, "冻结实体", {}, "", function(toggle)
        ENTITY.FREEZE_ENTITY_POSITION(ent, toggle)
    end)

    menu.toggle_loop(menu_parent, "检测实体信息", {}, "", function(toggle)
        local modelHash = ENTITY.GET_ENTITY_MODEL(ent)
        local entity_info = "Hash: " .. modelHash .. "\nHealth: " .. ENTITY.GET_ENTITY_HEALTH(ent)

        local pos = ENTITY.GET_ENTITY_COORDS(ent)
        entity_info = entity_info .. "\nX : " .. pos.x .. "\nY : " .. pos.y .. "\nZ : " .. pos.z

        local my_pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        entity_info = entity_info .. "\n距离: " .. vect.dist(my_pos, pos)

        directx.draw_text(0.5, 0.0, entity_info, ALIGN_TOP_LEFT, 0.7, 1, 0.8, 0, 1, true)
    end)

    menu.toggle(menu_parent, "添加地图标记 (Entity)", {}, "", function(toggle)
        if toggle then
            local blip = HUD.GET_BLIP_FROM_ENTITY(ent)
            if blip > 0 then
                HUD.SET_BLIP_DISPLAY(blip, 2)
            else
                blip = HUD.ADD_BLIP_FOR_ENTITY(ent)
                HUD.SET_BLIP_COLOUR(blip, 27)
                --
                if ENTITY.IS_ENTITY_A_PED(ent) then
                    if PED.IS_PED_IN_COMBAT(ent, players.user_ped()) then
                        HUD.SET_BLIP_COLOUR(blip, 1)
                    end
                end
                --
                if ENTITY.IS_ENTITY_A_VEHICLE(ent) then
                    local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ent, -1)
                    if ped then
                        if PED.IS_PED_IN_COMBAT(ped, players.user_ped()) then
                            HUD.SET_BLIP_COLOUR(blip, 1)
                        end
                    end
                end
            end
        else
            local blip = HUD.GET_BLIP_FROM_ENTITY(ent)
            if blip > 0 then
                HUD.SET_BLIP_DISPLAY(blip, 0)
            end
        end
    end)

    --menu.action(menu_parent, "添加地图标记 (Pickup)", {}, "", function()
    --    HUD.ADD_BLIP_FOR_PICKUP(ent)
    --end)
    --- ---
    menu.divider(menu_parent, "传送")
    menu.click_slider(menu_parent, "传送到我面前", {}, "", -10, 10, 2, 1, function(value)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0.0, value, 0.0)
        ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
    end)

    menu.action(menu_parent, "传送到实体", {}, "", function()
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, 0.0, 0.0, 0.0)
        ENTITY.SET_ENTITY_COORDS(players.user_ped(), coords.x, coords.y, coords.z, true, false, false, false)
    end)
    --- ---
    menu.divider(menu_parent, "移动")
    menu.click_slider(menu_parent, "前/后移动", {}, "", -100, 100, 0, 1, function(value)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, 0.0, value, 0.0)
        ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
    end)

    menu.click_slider(menu_parent, "左/右移动", {}, "", -100, 100, 0, 1, function(value)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, value, 0.0, 0.0)
        ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
    end)

    menu.click_slider(menu_parent, "上/下移动", {}, "", -100, 100, 0, 1, function(value)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, 0.0, 0.0, value)
        ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
    end)

    menu.click_slider(menu_parent, "朝向", {}, "", -360, 360, 0, 10, function(value)
        local head = ENTITY.GET_ENTITY_HEADING(ent)
        ENTITY.SET_ENTITY_HEADING(ent, head + value)
    end)
end

----- NPC -----
local MISSION_ENTITY_all_npc = menu.list(MISSION_ENTITY, "所有任务NPC", {}, "")
menu.action(MISSION_ENTITY_all_npc, "所有任务NPC数量", {}, "", function()
    local mission_entity_num = 0
    for k, ent in pairs(entities.get_all_peds_as_handles()) do
        if not IS_PED_PLAYER(ent) and ent ~= PLAYER.PLAYER_PED_ID() then
            if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
                mission_entity_num = mission_entity_num + 1
            end
        end
    end
    util.toast("Number :" .. mission_entity_num)
end)

menu.click_slider(MISSION_ENTITY_all_npc, "所有传送到我面前", {}, "", -10, 10, 2, 1, function(value)
    for k, ent in pairs(entities.get_all_peds_as_handles()) do
        if not IS_PED_PLAYER(ent) and ent ~= PLAYER.PLAYER_PED_ID() then
            if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
                local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, value, 1.0)
                ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
                util.yield(1500) -- wait 1.5s
            end
        end
    end
end)

-- 所有任务实体
mission_ent_npc_list = {}
-- 所有任务实体的menu.list
mission_ent_npc_menu_list = {}

function Clear_mission_npc_list()
    for k, v in pairs(mission_ent_npc_menu_list) do
        if v ~= nil then
            menu.delete(v)
        end
    end
    -- 所有任务实体
    mission_ent_npc_list = {}
    -- 所有任务实体的menu.list
    mission_ent_npc_menu_list = {}
end

menu.action(MISSION_ENTITY_all_npc, "获取所有任务NPC列表", {}, "", function()
    Clear_mission_npc_list()
    for k, ent in pairs(entities.get_all_peds_as_handles()) do
        if not IS_PED_PLAYER(ent) and ent ~= PLAYER.PLAYER_PED_ID() then
            if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
                table.insert(mission_ent_npc_list, ent)
                local modelHash = ENTITY.GET_ENTITY_MODEL(ent)
                local entity_info = "Hash: " .. modelHash
                if PED.IS_PED_IN_COMBAT(ent, PLAYER.PLAYER_ID()) then
                    entity_info = entity_info .. " (敌对)"
                end
                local text = "index: " .. k
                ---
                menu_mission_entity_npc = menu.list(MISSION_ENTITY_all_npc, entity_info, {}, text)
                mission_entity_all(menu_mission_entity_npc, ent)
                table.insert(mission_ent_npc_menu_list, menu_mission_entity_npc)
            end
        end
    end
end)

menu.action(MISSION_ENTITY_all_npc, "清空列表", {}, "", function()
    Clear_mission_npc_list()
end)

menu.divider(MISSION_ENTITY_all_npc, "任务NPC列表")

----- VEHICLE -----
local MISSION_ENTITY_all_vehicle = menu.list(MISSION_ENTITY, "所有任务载具", {}, "")
menu.action(MISSION_ENTITY_all_vehicle, "所有任务载具数量", {}, "", function()
    local mission_entity_num = 0
    for k, ent in pairs(entities.get_all_vehicles_as_handles()) do
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            mission_entity_num = mission_entity_num + 1
        end
    end
    util.toast("Number :" .. mission_entity_num)
end)

menu.click_slider(MISSION_ENTITY_all_vehicle, "所有传送到我面前", {}, "", -10, 10, 2, 1, function(value)
    for k, ent in pairs(entities.get_all_vehicles_as_handles()) do
        if not IS_PED_PLAYER(ent) and ent ~= PLAYER.PLAYER_PED_ID() then
            if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
                local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, value, 0.0)
                ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
                util.yield(1500) -- wait 1.5s
            end
        end
    end
end)

-- 所有任务实体
mission_ent_vehicle_list = {}
-- 所有任务实体的menu.list
mission_ent_vehicle_menu_list = {}

function Clear_mission_vehicle_list()
    for k, v in pairs(mission_ent_vehicle_menu_list) do
        if v ~= nil then
            menu.delete(v)
        end
    end
    -- 所有任务实体
    mission_ent_vehicle_list = {}
    -- 所有任务实体的menu.list
    mission_ent_vehicle_menu_list = {}
end

menu.action(MISSION_ENTITY_all_vehicle, "获取所有任务载具列表", {}, "", function()
    Clear_mission_vehicle_list()
    for k, ent in pairs(entities.get_all_vehicles_as_handles()) do
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            table.insert(mission_ent_vehicle_list, ent)
            local modelHash = ENTITY.GET_ENTITY_MODEL(ent)
            local entity_info = "Hash: " .. modelHash
            local text = "index: " .. k
            ---
            menu_mission_entity_vehicle = menu.list(MISSION_ENTITY_all_vehicle, entity_info, {}, text)
            mission_entity_all(menu_mission_entity_vehicle, ent)
            table.insert(mission_ent_vehicle_menu_list, menu_mission_entity_vehicle)
        end
    end
end)

menu.action(MISSION_ENTITY_all_vehicle, "清空列表", {}, "", function()
    Clear_mission_vehicle_list()
end)

menu.divider(MISSION_ENTITY_all_vehicle, "任务载具列表")

----- OBJECT -----
local MISSION_ENTITY_all_object = menu.list(MISSION_ENTITY, "所有任务物体", {}, "")
menu.action(MISSION_ENTITY_all_object, "所有任务物体数量", {}, "", function()
    local mission_entity_num = 0
    for k, ent in pairs(entities.get_all_objects_as_handles()) do
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            mission_entity_num = mission_entity_num + 1
        end
    end
    util.toast("Number :" .. mission_entity_num)
end)

menu.click_slider(MISSION_ENTITY_all_object, "所有传送到我面前", {}, "", -10, 10, 2, 1, function(value)
    for k, ent in pairs(entities.get_all_objects_as_handles()) do
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, value, 0.0)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
            util.yield(1500) -- wait 1.5s
        end
    end
end)

-- 所有任务实体
mission_ent_object_list = {}
-- 所有任务实体的menu.list
mission_ent_object_menu_list = {}

function Clear_mission_object_list()
    for k, v in pairs(mission_ent_object_menu_list) do
        if v ~= nil then
            menu.delete(v)
        end
    end
    -- 所有任务实体
    mission_ent_object_list = {}
    -- 所有任务实体的menu.list
    mission_ent_object_menu_list = {}
end

menu.action(MISSION_ENTITY_all_object, "获取所有任务物体列表", {}, "", function()
    Clear_mission_object_list()
    for k, ent in pairs(entities.get_all_objects_as_handles()) do
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            table.insert(mission_ent_object_list, ent)
            local modelHash = ENTITY.GET_ENTITY_MODEL(ent)
            local entity_info = "Hash: " .. modelHash
            local text = "index: " .. k
            ---
            menu_mission_entity_object = menu.list(MISSION_ENTITY_all_object, entity_info, {}, text)
            mission_entity_all(menu_mission_entity_object, ent)
            table.insert(mission_ent_object_menu_list, menu_mission_entity_object)
        end
    end
end)

menu.action(MISSION_ENTITY_all_object, "清空列表", {}, "", function()
    Clear_mission_object_list()
end)

menu.divider(MISSION_ENTITY_all_object, "任务物体列表")

----- PICKUP -----
local MISSION_ENTITY_all_pickup = menu.list(MISSION_ENTITY, "所有任务拾取物", {}, "")
menu.action(MISSION_ENTITY_all_pickup, "所有任务拾取物数量", {}, "", function()
    local mission_entity_num = 0
    for k, ent in pairs(entities.get_all_pickups_as_handles()) do
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            mission_entity_num = mission_entity_num + 1
        end
    end
    util.toast("Number :" .. mission_entity_num)
end)

menu.click_slider(MISSION_ENTITY_all_pickup, "所有传送到我面前", {}, "", -10, 10, 2, 1, function(value)
    for k, ent in pairs(entities.get_all_pickups_as_handles()) do
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, value, 0.0)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
            util.yield(1500) -- wait 1.5s
        end
    end
end)

-- 所有任务实体
mission_ent_pickup_list = {}
-- 所有任务实体的menu.list
mission_ent_pickup_menu_list = {}

function Clear_mission_pickup_list()
    for k, v in pairs(mission_ent_pickup_menu_list) do
        if v ~= nil then
            menu.delete(v)
        end
    end
    -- 所有任务实体
    mission_ent_pickup_list = {}
    -- 所有任务实体的menu.list
    mission_ent_pickup_menu_list = {}
end

menu.action(MISSION_ENTITY_all_pickup, "获取所有任务拾取物列表", {}, "", function()
    Clear_mission_pickup_list()
    for k, ent in pairs(entities.get_all_pickups_as_handles()) do
        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            table.insert(mission_ent_pickup_list, ent)
            local modelHash = ENTITY.GET_ENTITY_MODEL(ent)
            local entity_info = "Hash: " .. modelHash
            local text = "index: " .. k
            ---
            menu_mission_entity_pickup = menu.list(MISSION_ENTITY_all_pickup, entity_info, {}, text)
            mission_entity_all(menu_mission_entity_pickup, ent)
            table.insert(mission_ent_pickup_menu_list, menu_mission_entity_pickup)
        end
    end
end)

menu.action(MISSION_ENTITY_all_pickup, "清空列表", {}, "", function()
    Clear_mission_pickup_list()
end)

menu.divider(MISSION_ENTITY_all_pickup, "任务拾取物列表")

---

menu.divider(entity_options, "")

----- 实体信息枪 -----
local isLog_entity_info = false
menu.toggle_loop(entity_options, "实体信息枪", {}, "显示瞄准射击的实体信息", function()
    local ent = GetEntity_PlayerIsAimingAt(players.user())
    if ent ~= NULL and ENTITY.DOES_ENTITY_EXIST(ent) then
        local entity_info = ""
        local modelHash = ENTITY.GET_ENTITY_MODEL(ent)
        entity_info = entity_info .. "Model Hash: " .. modelHash

        if ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            entity_info = entity_info .. "\nIS A MISSION ENTITY"
        end

        local entity_types = { "No entity", "Ped", "Vehicle", "Object" }
        local entity_type = ENTITY.GET_ENTITY_TYPE(ent)
        entity_info = entity_info .. "\nEntity Type: " .. entity_types[entity_type + 1]

        local entity_pop_types = {
            "POPTYPE_UNKNOWN",
            "POPTYPE_RANDOM_PERMANENT",
            "POPTYPE_RANDOM_PARKED",
            "POPTYPE_RANDOM_PATROL",
            "POPTYPE_RANDOM_SCENARIO",
            "POPTYPE_RANDOM_AMBIENT",
            "POPTYPE_PERMANENT",
            "POPTYPE_MISSION",
            "POPTYPE_REPLAY",
            "POPTYPE_CACHE",
            "POPTYPE_TOOL" }
        local entity_pop_type = ENTITY.GET_ENTITY_POPULATION_TYPE(ent)
        entity_info = entity_info .. "\nEntity Population Type: " .. entity_pop_types[entity_pop_type + 1]

        entity_info = entity_info .. "\nEntity Health: " .. ENTITY.GET_ENTITY_HEALTH(ent)

        -- object
        if entity_type == 3 then
            if OBJECT.IS_OBJECT_A_PICKUP(ent) then
                entity_info = entity_info .. "\n\nIS A PICKUP"
            end
            if OBJECT.IS_OBJECT_A_PORTABLE_PICKUP(ent) then
                entity_info = entity_info .. "\nIS A PORTABLE PICKUP"
            end
        end

        if ENTITY.IS_ENTITY_ATTACHED(ent) then
            entity_info = entity_info .. "\n\nIS ENTITY ATTACHED"

            local attached_entity = ENTITY.GET_ENTITY_ATTACHED_TO(ent)
            entity_info = entity_info .. "\nAttached Entity Model Hash :" .. ENTITY.GET_ENTITY_MODEL(attached_entity)
        end

        entity_info = entity_info .. "\n\nEntity Heading: " .. ENTITY.GET_ENTITY_HEADING(ent)
        local pos = ENTITY.GET_ENTITY_COORDS(ent)
        entity_info = entity_info .. "\nX : " .. pos.x .. "\nY : " .. pos.y .. "\nZ : " .. pos.z

        directx.draw_text(0.5, 0.0, entity_info, ALIGN_TOP_LEFT, 0.7, 1, 0.8, 0, 1, true)
        --util.toast(entity_info)
        -- 记录到日志
        if isLog_entity_info then
            util.log(entity_info)
        end
    end
end)

menu.toggle(entity_options, "记录到日志", {}, "", function(toggle)
    isLog_entity_info = toggle
end)


----------------------------
---------- 保镖选项 ----------
----------------------------

local bodyguard_options = menu.list(menu.my_root(), "保镖选项", {}, "")

--- Relationship Functions ---
local function addRelationshipGroup(name)
    local ptr = memory.alloc_int()
    PED.ADD_RELATIONSHIP_GROUP(name, ptr)
    local rel = memory.read_int(ptr)
    memory.free(ptr)
    return rel
end

relationship = {}
function relationship:friendly(ped)
    if not PED._DOES_RELATIONSHIP_GROUP_EXIST(self.friendly_group) then
        self.friendly_group = addRelationshipGroup("friendly_group")
        PED.SET_RELATIONSHIP_BETWEEN_GROUPS(0, self.friendly_group, self.friendly_group)
    end
    PED.SET_PED_RELATIONSHIP_GROUP_HASH(ped, self.friendly_group)
end

----- 保镖直升机 -----
local bodyguard_heli_options = menu.list(bodyguard_options, "保镖直升机", {}, "")

local heli_list = {} --生成的直升机
local heli_ped_list = {} --直升机内的保镖

local bodyguard_heli = {
    name = "buzzard",
    heli_godmode = false,
    ped_godmode = false
}

local sel_heli_name_list = { "秃鹰", "女武神", "猎杀者", "野蛮人" }
local sel_heli_model_list = { "buzzard", "valkyrie", "hunter", "savage" }
menu.slider_text(bodyguard_heli_options, "直升机类型", {}, "", sel_heli_name_list, function(value)
    bodyguard_heli.name = sel_heli_model_list[value]
end)

menu.toggle(bodyguard_heli_options, "直升机无敌", {}, "", function(toggle)
    bodyguard_heli.heli_godmode = toggle
end)

menu.action(bodyguard_heli_options, "生成保镖直升机", {}, "", function()
    local heli_hash = util.joaat(bodyguard_heli.name)
    local ped_hash = util.joaat("s_m_y_blackops_01")
    local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    pos.x = pos.x + math.random(-10, 10)
    pos.y = pos.y + math.random(-10, 10)
    pos.z = pos.z + 30

    requestModels(ped_hash, heli_hash)
    relationship:friendly(players.user_ped())
    local heli = entities.create_vehicle(heli_hash, pos, CAM.GET_GAMEPLAY_CAM_ROT(0).z)

    if not ENTITY.DOES_ENTITY_EXIST(heli) then
        util.toast("Failed to create vehicle. Please try again")
        return
    else
        local heliNetId = NETWORK.VEH_TO_NET(heli)
        if NETWORK.NETWORK_GET_ENTITY_IS_NETWORKED(NETWORK.NET_TO_PED(heliNetId)) then
            NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(heliNetId, true)
        end
        NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(heliNetId, players.user(), true)
        VEHICLE.SET_VEHICLE_ENGINE_ON(heli, true, true, true)
        VEHICLE.SET_HELI_BLADES_FULL_SPEED(heli)
        VEHICLE.SET_VEHICLE_SEARCHLIGHT(heli, true, true)
        addBlipForEntity(heli, 422, 26)
        --health
        ENTITY.SET_ENTITY_INVINCIBLE(heli, bodyguard_heli.heli_godmode)
        ENTITY.SET_ENTITY_MAX_HEALTH(heli, 10000)
        ENTITY.SET_ENTITY_HEALTH(heli, 10000)

        table.insert(heli_list, heli)
    end

    local pilot = entities.create_ped(29, ped_hash, pos, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
    PED.SET_PED_INTO_VEHICLE(pilot, heli, -1)
    PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(pilot, true)
    TASK.TASK_HELI_MISSION(pilot, heli, 0, players.user_ped(), 0.0, 0.0, 0.0, 23, 80.0, 50.0, -1.0, 0, 10, -1.0, 0)
    PED.SET_PED_KEEP_TASK(pilot, true)
    --health
    PED.SET_PED_MAX_HEALTH(pilot, 1000)
    ENTITY.SET_ENTITY_HEALTH(pilot, 1000)
    ENTITY.SET_ENTITY_INVINCIBLE(pilot, bodyguard_heli.ped_godmode)

    table.insert(heli_ped_list, pilot)

    --local seats = VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(heli)
    for seat = 0, 2 do
        local ped = entities.create_ped(29, ped_hash, pos, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
        local pedNetId = NETWORK.PED_TO_NET(ped)
        if NETWORK.NETWORK_GET_ENTITY_IS_NETWORKED(ped) then
            NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(pedNetId, true)
        end
        NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(pedNetId, players.user(), true)
        PED.SET_PED_INTO_VEHICLE(ped, heli, seat)
        --fight
        WEAPON.GIVE_WEAPON_TO_PED(ped, util.joaat("weapon_mg"), -1, false, true)
        WEAPON.SET_PED_INFINITE_AMMO_CLIP(ped, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 5, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 3, false)
        PED.SET_PED_COMBAT_MOVEMENT(ped, 2)
        PED.SET_PED_COMBAT_ABILITY(ped, 2)
        PED.SET_PED_COMBAT_RANGE(ped, 2)
        PED.SET_PED_SEEING_RANGE(ped, 500.0)
        PED.SET_PED_HEARING_RANGE(ped, 500.0)
        PED.SET_PED_TARGET_LOSS_RESPONSE(ped, 1)
        PED.SET_PED_HIGHLY_PERCEPTIVE(ped, true)
        PED.SET_PED_VISUAL_FIELD_PERIPHERAL_RANGE(ped, 500.0)
        PED.SET_COMBAT_FLOAT(ped, 10, 500.0)
        PED.SET_PED_SHOOT_RATE(ped, 1000.0)
        PED.SET_PED_ACCURACY(ped, 100.0)
        PED.SET_PED_CAN_BE_SHOT_IN_VEHICLE(ped, true)
        --health
        PED.SET_PED_MAX_HEALTH(ped, 1000)
        ENTITY.SET_ENTITY_HEALTH(ped, 1000)
        ENTITY.SET_ENTITY_INVINCIBLE(ped, bodyguard_heli.ped_godmode)

        relationship:friendly(ped)

        table.insert(heli_ped_list, ped)
    end

    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(heli_hash)
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(ped_hash)
end)

menu.action(bodyguard_heli_options, "删除所有保镖直升机", {}, "", function()
    for k, ent in pairs(heli_ped_list) do
        entities.delete_by_handle(ent)
    end
    for k, ent in pairs(heli_list) do
        entities.delete_by_handle(ent)
    end
end)


----------------------------
---------- 保护选项 ----------
----------------------------

local protect_options = menu.list(menu.my_root(), "保护选项", {}, "")

menu.toggle_loop(protect_options, "移除爆炸", {}, "", function()
    local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
    FIRE.STOP_FIRE_IN_RANGE(pos.x, pos.y, pos.z, 5)
end)

menu.toggle_loop(protect_options, "移除粒子效果", {}, "", function()
    local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
    GRAPHICS.REMOVE_PARTICLE_FX_IN_RANGE(pos.x, pos.y, pos.z, 5)
end)


----------------------------
---------- 任务选项 ----------
----------------------------

local task_options = menu.list(menu.my_root(), "任务选项", {}, "")

local Perico_Heist_Fast = menu.list(task_options, "佩里科岛 快速完成", {}, "2分钟完成 到账248万")

menu.action(Perico_Heist_Fast, "传送到虎鲸任务面板[提前呼出虎鲸]", {}, "需要提前呼叫出虎鲸，否则会出现问题", function()
    if STAT_GET_INT("IH_SUB_OWNED") ~= 0 then
        TELEPORT(1561.236, 385.8863, -49.685352)
        ENTITY.SET_ENTITY_HEADING(players.user_ped(), 175)
    else
        util.toast("你都没有虎鲸，请先购买")
    end
end)

menu.divider(Perico_Heist_Fast, "-")

menu.action(Perico_Heist_Fast, "一键跳过前置", {}, "先进入虎鲸购买开启任务，然后离开虎鲸，再点击本选项跳过前置\n\n任务设置：猎豹雕像、困难模式、长鳍、正门进入、135%分红\n可到账248万", function()
    -- 解锁所有入侵点、逃离点
    STAT_SET_INT("H4CNF_BS_ENTR", 63)
    STAT_SET_INT("H4CNF_APPROACH", 0xFFFFFFF)
    -- 难度
    STAT_SET_INT("H4_PROGRESS", 131055)
    -- 主要目标
    STAT_SET_INT("H4CNF_TARGET", 5)
    -- 接近载具
    STAT_SET_INT("H4_MISSIONS", 65345)
    -- 武器
    STAT_SET_INT("H4CNF_WEAPONS", 1)
    -- 次要目标
    STAT_SET_INT("H4LOOT_CASH_I", 0)
    STAT_SET_INT("H4LOOT_CASH_C", 0)
    STAT_SET_INT("H4LOOT_CASH_V", 0)
    STAT_SET_INT("H4LOOT_WEED_I", 0)
    STAT_SET_INT("H4LOOT_WEED_C", 0)
    STAT_SET_INT("H4LOOT_WEED_V", 0)
    STAT_SET_INT("H4LOOT_COKE_I", 0)
    STAT_SET_INT("H4LOOT_COKE_C", 0)
    STAT_SET_INT("H4LOOT_COKE_V", 0)
    STAT_SET_INT("H4LOOT_GOLD_I", 0)
    STAT_SET_INT("H4LOOT_GOLD_C", 0)
    STAT_SET_INT("H4LOOT_GOLD_V", 0)
    STAT_SET_INT("H4LOOT_PAINT", 0)
    STAT_SET_INT("H4LOOT_PAINT_V", 0)
    STAT_SET_INT("H4LOOT_CASH_I_SCOPED", 0)
    STAT_SET_INT("H4LOOT_CASH_C_SCOPED", 0)
    STAT_SET_INT("H4LOOT_WEED_I_SCOPED", 0)
    STAT_SET_INT("H4LOOT_WEED_C_SCOPED", 0)
    STAT_SET_INT("H4LOOT_COKE_I_SCOPED", 0)
    STAT_SET_INT("H4LOOT_COKE_C_SCOPED", 0)
    STAT_SET_INT("H4LOOT_GOLD_I_SCOPED", 0)
    STAT_SET_INT("H4LOOT_GOLD_C_SCOPED", 0)
    STAT_SET_INT("H4LOOT_PAINT_SCOPED", 0)
    -- Fixed the final Cutscene
    STAT_SET_INT("H4_PLAYTHROUGH_STATUS", 10)
    util.toast("前置跳过完成！请返回虎鲸任务面板查看")
end)

--- 分红设置
local CP_All_Cut = 135

menu.slider(Perico_Heist_Fast, "分红", {}, "(%)", 0, 300, 135, 5, function(Value)
    CP_All_Cut = Value
end)

menu.action(Perico_Heist_Fast, "一键设置所有人分红", {}, "实际收入=主要目标*分红*0.88", function()
    SET_INT_GLOBAL(1973321 + 823 + 56 + 1, CP_All_Cut)
    SET_INT_GLOBAL(1973321 + 823 + 56 + 2, CP_All_Cut)
    SET_INT_GLOBAL(1973321 + 823 + 56 + 3, CP_All_Cut)
    SET_INT_GLOBAL(1973321 + 823 + 56 + 4, CP_All_Cut)
end)

menu.divider(Perico_Heist_Fast, "-")

menu.action(Perico_Heist_Fast, "杀死队友", {}, "炸不死队友就让他们关无敌自杀", function()
    local all_players = players.list(true, true, true)
    for k, pId in pairs(all_players) do
        if pId ~= players.user() then
            local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId))
            FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z - 1.0, EXP_TAG_STICKYBOMB, 1.0, true, false, 0, false)
        end
    end
end)

menu.action(Perico_Heist_Fast, "传送到雕像位置", {}, "", function()
    TELEPORT(5006.6343, -5756.2056, 15.48444)
end)

menu.action(Perico_Heist_Fast, "一键完成割玻璃", {}, "", function()
    SET_FLOAT_LOCAL("fm_mission_controller_2020", 28736 + 3, 100.0)
end)

menu.action(Perico_Heist_Fast, "传送到正门", {}, "", function()
    TELEPORT(4990.0386, -5717.6895, 19.880217)
end)

menu.action(Perico_Heist_Fast, "传送到海洋逃离点", {}, "", function()
    TELEPORT(4771.479, -6165.737, -39.079613)
end)

menu.divider(Perico_Heist_Fast, "其他")

menu.action(Perico_Heist_Fast, "重置任务面板", {}, "会重置所有内容，包括入侵点、逃离点", function()
    STAT_SET_INT("H4_MISSIONS", 0)
    STAT_SET_INT("H4_PROGRESS", 0)
    STAT_SET_INT("H4_PLAYTHROUGH_STATUS", 0)
    STAT_SET_INT("H4CNF_BS_ENTR", 0)
    STAT_SET_INT("H4CNF_APPROACH", 0)
    STAT_SET_INT("H4CNF_BS_GEN", 0)
end)

menu.action(Perico_Heist_Fast, "重置任务冷却时间", {}, "", function()
    STAT_SET_INT("H4_COOLDOWN", 0)
    STAT_SET_INT("H4_COOLDOWN_HARD", 0)
end)

--
local Casion_Heist = menu.list(task_options, "赌场抢劫", {}, "Use for Heist Control")

menu.divider(Casion_Heist, "第二面板")

local bitset0 = 0 --可选任务

local Casion_Heist_Custom = menu.list(Casion_Heist, "自定义可选任务", {}, "")

local bitset0_add1 = 0
menu.toggle(Casion_Heist_Custom, "巡逻路线", {}, "", function(toggle)
    if toggle then
        bitset0_add1 = 2
    else
        bitset0_add1 = 0
    end
end)

local bitset0_add2 = 0
menu.toggle(Casion_Heist_Custom, "杜根货物", {}, "是否会显示对钩而已", function(toggle)
    if toggle then
        bitset0_add2 = 4
    else
        bitset0_add2 = 0
    end
end)

local bitset0_add3 = 0
menu.toggle(Casion_Heist_Custom, "电钻", {}, "", function(toggle)
    if toggle then
        bitset0_add3 = 16
    else
        bitset0_add3 = 0
    end
end)

local bitset0_add4 = 0
menu.toggle(Casion_Heist_Custom, "枪手诱饵", {}, "", function(toggle)
    if toggle then
        bitset0_add4 = 64
    else
        bitset0_add4 = 0
    end
end)

local bitset0_add5 = 0
menu.toggle(Casion_Heist_Custom, "更换载具", {}, "", function(toggle)
    if toggle then
        bitset0_add5 = 128
    else
        bitset0_add5 = 0
    end
end)

menu.divider(Casion_Heist_Custom, "隐迹潜踪")

local bitset0_add6 = 0
menu.toggle(Casion_Heist_Custom, "潜入套装", {}, "", function(toggle)
    if toggle then
        bitset0_add6 = 8
    else
        bitset0_add6 = 0
    end
end)

local bitset0_add7 = 0
menu.toggle(Casion_Heist_Custom, "电磁脉冲设备", {}, "", function(toggle)
    if toggle then
        bitset0_add7 = 32
    else
        bitset0_add7 = 0
    end
end)

menu.divider(Casion_Heist_Custom, "兵不厌诈")

local bitset0_add8 = 0
menu.toggle(Casion_Heist_Custom, "进场：除虫大师", {}, "", function(toggle)
    if toggle then
        bitset0_add8 = 256 + 512
    else
        bitset0_add8 = 0
    end
end)

local bitset0_add9 = 0
menu.toggle(Casion_Heist_Custom, "进场：维修工", {}, "", function(toggle)
    if toggle then
        bitset0_add9 = 1024 + 2048
    else
        bitset0_add9 = 0
    end
end)

local bitset0_add10 = 0
menu.toggle(Casion_Heist_Custom, "进场：古倍科技", {}, "", function(toggle)
    if toggle then
        bitset0_add10 = 4096 + 8192
    else
        bitset0_add10 = 0
    end
end)

local bitset0_add11 = 0
menu.toggle(Casion_Heist_Custom, "进场：名人", {}, "", function(toggle)
    if toggle then
        bitset0_add11 = 16384 + 32768
    else
        bitset0_add11 = 0
    end
end)

local bitset0_add12 = 0
menu.toggle(Casion_Heist_Custom, "离场：国安局", {}, "", function(toggle)
    if toggle then
        bitset0_add12 = 65536
    else
        bitset0_add12 = 0
    end
end)

local bitset0_add13 = 0
menu.toggle(Casion_Heist_Custom, "离场：消防员", {}, "", function(toggle)
    if toggle then
        bitset0_add13 = 131072
    else
        bitset0_add13 = 0
    end
end)

local bitset0_add14 = 0
menu.toggle(Casion_Heist_Custom, "离场：豪赌客", {}, "", function(toggle)
    if toggle then
        bitset0_add14 = 262144
    else
        bitset0_add14 = 0
    end
end)

menu.divider(Casion_Heist_Custom, "气势汹汹")

local bitset0_add15 = 0
menu.toggle(Casion_Heist_Custom, "加固防弹衣", {}, "", function(toggle)
    if toggle then
        bitset0_add15 = 1048576
    else
        bitset0_add15 = 0
    end
end)

local bitset0_add16 = 0
menu.toggle(Casion_Heist_Custom, "镗床", {}, "", function(toggle)
    if toggle then
        bitset0_add16 = 2621440
    else
        bitset0_add16 = 0
    end
end)

menu.divider(Casion_Heist_Custom, " ")

menu.action(Casion_Heist_Custom, "添加至BITSET0", {}, "", function()
    bitset0 = bitset0_add1 + bitset0_add2 + bitset0_add3 + bitset0_add4 + bitset0_add5 + bitset0_add6 + bitset0_add7 + bitset0_add8 + bitset0_add9 + bitset0_add10 + bitset0_add11 + bitset0_add12 + bitset0_add13 + bitset0_add14 + bitset0_add15 + bitset0_add16
    util.toast("添加完成，当前值为： " .. bitset0)
end)

menu.divider(Casion_Heist, "BITSET0设置")

menu.action(Casion_Heist, "读取当前BITSET0变量值", {}, "", function()
    util.toast(bitset0)
end)

menu.text_input(Casion_Heist, "自定义BITSET0变量值", { "bitset0" }, "", function(value)
    bitset0 = value
    util.toast("已修改为: " .. bitset0)
end)

menu.divider(Casion_Heist, " ")

menu.action(Casion_Heist, "写入BITSET0变量值", {}, "写入到 H3OPT_BITSET0", function()
    STAT_SET_INT("H3OPT_BITSET0", bitset0)
    util.toast("已将 H3OPT_BITSET0 修改为: " .. bitset0)
end)

---
local Team_Lives = menu.list(task_options, "改变生命数", {}, "")

menu.divider(Team_Lives, "佩里科岛")

menu.action(Team_Lives, "获取当前生命数", {}, "", function()
    local value = GET_INT_LOCAL("fm_mission_controller_2020", 43059 + 865 + 1)
    util.toast(value)
end)

local team_live_cayo = 0
menu.click_slider(Team_Lives, "修改生命数", { "tlive_perico" }, "fm_mission_controller_2020", 0, 30000, 0, 1, function(value)
    team_live_cayo = value
    SET_INT_LOCAL("fm_mission_controller_2020", 43059 + 865 + 1, team_live_cayo)
end)

menu.divider(Team_Lives, "赌场抢劫")

menu.action(Team_Lives, "获取当前生命数", {}, "", function()
    local value = GET_INT_LOCAL("fm_mission_controller", 26077 + 1322 + 1)
    util.toast(value)
end)

local team_live_casino = 0
menu.click_slider(Team_Lives, "修改生命数", { "tlive_casino" }, "fm_mission_controller", 0, 30000, 0, 1, function(value)
    team_live_casino = value
    SET_INT_LOCAL("fm_mission_controller", 26077 + 1322 + 1, team_live_casino)
end)

---
local mission_control = menu.list(task_options, "任务脚本 Local Editor", {}, "")

local mission_script = "fm_mission_controller"
menu.list_select(mission_control, "选择脚本", {}, "", {
    { "fm_mission_controller" },
    { "fm_mission_controller_2020" }
}, 1, function(index)
    if index == 1 then
        mission_script = "fm_mission_controller"
    elseif index == 2 then
        mission_script = "fm_mission_controller_2020"
    end
end)

local local_address
menu.text_input(mission_control, "Local 地址", { "local_address" }, "输入计算总和", function(value)
    local_address = value
end)

menu.action(mission_control, "读取 Local", {}, "INT", function()
    if local_address then
        local value = GET_INT_LOCAL(mission_script, local_address)
        util.toast(value)
    end
end)

local local_write
menu.text_input(mission_control, "要写入的值", { "local_write" }, "", function(value)
    local_write = value
end)

menu.action(mission_control, "写入 Local", {}, "INT", function()
    if local_address and local_write then
        SET_INT_LOCAL(mission_script, local_address, local_write)
    end
end)

menu.action(mission_control, "PARTICIPANT_ID_TO_INT", {}, "", function()
    util.toast(NETWORK.PARTICIPANT_ID_TO_INT())
end)

menu.action(mission_control, "NETWORK_GET_PLAYER_INDEX", {}, "", function()
    util.toast(NETWORK.NETWORK_GET_PLAYER_INDEX(PLAYER.PLAYER_ID()))
end)

menu.action(mission_control, "PLAYER_ID", {}, "", function()
    util.toast(PLAYER.PLAYER_ID())
end)

menu.action(mission_control, "NETWORK_TIME", {}, "", function()
    util.toast(NETWORK.GET_NETWORK_TIME())
end)

---
local global_editor = menu.list(task_options, "Global Editor", {}, "")

local global_address = 0
menu.slider(global_editor, "Global 地址", { "global_address" }, "输入计算总和", 0, 16777216, 0, 1, function(value)
    global_address = value
end)

menu.action(global_editor, "读取 Global", {}, "INT", function()
    if global_address then
        local value = GET_INT_GLOBAL(global_address)
        util.toast(value)
    end
end)

local global_write
menu.text_input(global_editor, "要写入的值", { "global_write" }, "", function(value)
    global_write = value
end)

menu.action(global_editor, "写入 Global", {}, "INT", function()
    if global_address and global_write then
        SET_INT_GLOBAL(global_address, global_write)
    end
end)


----------------------------
---------- 其它选项 ----------
----------------------------

local other_options = menu.list(menu.my_root(), "其它选项", {}, "")

local other_options_SnackArmour = menu.list(other_options, "零食护甲编辑", {}, "")

menu.action(other_options_SnackArmour, "补满全部零食", {}, "", function()
    STAT_SET_INT("NO_BOUGHT_YUM_SNACKS", 30)
    STAT_SET_INT("NO_BOUGHT_HEALTH_SNACKS", 15)
    STAT_SET_INT("NO_BOUGHT_EPIC_SNACKS", 5)
    STAT_SET_INT("NUMBER_OF_ORANGE_BOUGHT", 10)
    STAT_SET_INT("NUMBER_OF_BOURGE_BOUGHT", 10)
    STAT_SET_INT("NUMBER_OF_CHAMP_BOUGHT", 5)
    STAT_SET_INT("CIGARETTES_BOUGHT", 20)
    util.toast("完成！")
end)

menu.action(other_options_SnackArmour, "补满全部护甲", {}, "", function()
    STAT_SET_INT("MP_CHAR_ARMOUR_1_COUNT", 10)
    STAT_SET_INT("MP_CHAR_ARMOUR_2_COUNT", 10)
    STAT_SET_INT("MP_CHAR_ARMOUR_3_COUNT", 10)
    STAT_SET_INT("MP_CHAR_ARMOUR_4_COUNT", 10)
    STAT_SET_INT("MP_CHAR_ARMOUR_5_COUNT", 10)
    util.toast("完成！")
end)

menu.action(other_options_SnackArmour, "补满呼吸器", {}, "", function()
    STAT_SET_INT("BREATHING_APPAR_BOUGHT", 20)
    util.toast("完成！")
end)

menu.divider(other_options_SnackArmour, "零食")
menu.click_slider(other_options_SnackArmour, "PQ豆", {}, "+15 Health", 0, 99, 30, 1, function(value)
    STAT_SET_INT("NO_BOUGHT_YUM_SNACKS", value)
    util.toast("完成！")
end)
menu.click_slider(other_options_SnackArmour, "宝力旺", {}, "+45 Health", 0, 99, 15, 1, function(value)
    STAT_SET_INT("NO_BOUGHT_HEALTH_SNACKS", value)
    util.toast("完成！")
end)
menu.click_slider(other_options_SnackArmour, "麦提来", {}, "+30 Health", 0, 99, 5, 1, function(value)
    STAT_SET_INT("NO_BOUGHT_EPIC_SNACKS", value)
    util.toast("完成！")
end)
menu.click_slider(other_options_SnackArmour, "易可乐", {}, "+36 Health", 0, 99, 10, 1, function(value)
    STAT_SET_INT("NUMBER_OF_ORANGE_BOUGHT", value)
    util.toast("完成！")
end)
menu.click_slider(other_options_SnackArmour, "尿汤啤", {}, "", 0, 99, 10, 1, function(value)
    STAT_SET_INT("NUMBER_OF_BOURGE_BOUGHT", value)
    util.toast("完成！")
end)
menu.click_slider(other_options_SnackArmour, "蓝醉香槟", {}, "", 0, 99, 5, 1, function(value)
    STAT_SET_INT("NUMBER_OF_CHAMP_BOUGHT", value)
    util.toast("完成！")
end)
menu.click_slider(other_options_SnackArmour, "香烟", {}, "-5 Health", 0, 99, 20, 1, function(value)
    STAT_SET_INT("CIGARETTES_BOUGHT", value)
    util.toast("完成！")
end)

-----
menu.toggle_loop(other_options, "跳到下一条对话", {}, "", function()
    if AUDIO.IS_SCRIPTED_CONVERSATION_ONGOING() then
        AUDIO.SKIP_TO_NEXT_SCRIPTED_CONVERSATION_LINE()
    end
end)

menu.action(other_options, "请求重型装甲", {}, "请求弹道装甲和火神机枪", function()
    SET_INT_GLOBAL(2815059 + 884, 1)
end)

menu.action(other_options, "重型装甲包裹 传送到我", {}, "\nModel Hash: 1688540826", function()
    local entity_model_hash = 1688540826
    for k, ent in pairs(entities.get_all_pickups_as_handles()) do
        local EntityHash = ENTITY.GET_ENTITY_MODEL(ent)
        if EntityHash == entity_model_hash and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 2.0, 0.0)
            ENTITY.SET_ENTITY_COORDS(ent, coords.x, coords.y, coords.z, true, false, false, false)
        end
    end
end)

menu.divider(other_options, "无视犯罪")

menu.action(other_options, "警察无视犯罪", { "no_cops" }, "莱斯特", function()
    SET_INT_GLOBAL(2815059 + 4624, 5)
    SET_INT_GLOBAL(2815059 + 4625, 1)
    SET_INT_GLOBAL(2815059 + 4627, NETWORK.GET_NETWORK_TIME())
end)

menu.action(other_options, "贿赂当局", {}, "CEO技能", function()
    SET_INT_GLOBAL(2815059 + 4624, 81)
    SET_INT_GLOBAL(2815059 + 4625, 1)
    SET_INT_GLOBAL(2815059 + 4627, NETWORK.GET_NETWORK_TIME())
end)

menu.toggle_loop(other_options, "锁定倒计时", {}, "无视犯罪的倒计时", function()
    SET_INT_GLOBAL(2815059 + 4627, NETWORK.GET_NETWORK_TIME())
end)


------


--------------------------------
---------- 玩家列表选项 ----------
--------------------------------

GenerateFeatures = function(pId)
    local Player_MainMenu = menu.list(menu.player_root(pId), "RScript", {}, "")

    ----------生成选项----------
    local generate_options = menu.list(Player_MainMenu, "生成选项", {}, "")

    local function g_cage(pId)
        local p = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        local pos = ENTITY.GET_ENTITY_COORDS(p)
        local objHash = util.joaat("prop_gold_cont_01")
        requestModels(objHash)
        local obj = OBJECT.CREATE_OBJECT(objHash, pos.x, pos.y, pos.z - 1.0, true, false, false)
        ENTITY.FREEZE_ENTITY_POSITION(obj, true)
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(objHash)
    end

    menu.action(generate_options, "小笼子", {}, "", function()
        local p = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        TASK.CLEAR_PED_TASKS_IMMEDIATELY(p)
        if PED.IS_PED_IN_ANY_VEHICLE(p) then
            return
        end
        g_cage(pId)
    end)

    menu.action(generate_options, "生成小查攻击", {}, "", function()
        local p = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(p, 0.0, -1.0, 0.0)
        local objHash = util.joaat("A_C_Chop")
        requestModels(objHash)
        local g_ped = PED.CREATE_PED(PED_TYPE_CIVMALE, objHash, coords.x, coords.y, coords.z, 0, true, false)

        ENTITY.SET_ENTITY_HEADING(g_ped, ENTITY.GET_ENTITY_HEADING(p))
        PED.SET_PED_MONEY(g_ped, 2000)
        PED.SET_PED_MAX_HEALTH(g_ped, 10000)
        ENTITY.SET_ENTITY_HEALTH(g_ped, 10000)
        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(g_ped, true)
        TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(g_ped, true)
        TASK.TASK_COMBAT_PED(g_ped, p, 0, 16)
        PED.SET_PED_COMBAT_ATTRIBUTES(g_ped, 46, 1)
        PED.SET_PED_AS_ENEMY(g_ped, true)

        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(objHash)
    end)

    local generate_options_kosatka = menu.list(generate_options, "生成虎鲸", {}, "")

    local ge_kosatka_x = 0.0
    menu.slider(generate_options_kosatka, "左/右", { "ge_kosatka_x" }, "", -100.0, 100.0, 0.0, 1.0, function(value)
        ge_kosatka_x = value
    end)

    local ge_kosatka_y = 0.0
    menu.slider(generate_options_kosatka, "前/后", { "ge_kosatka_y" }, "", -100.0, 100.0, 0.0, 1.0, function(value)
        ge_kosatka_y = value
    end)

    local ge_kosatka_z = 0.0
    menu.slider(generate_options_kosatka, "上/下", { "ge_kosatka_z" }, "高度", -100.0, 100.0, 0.0, 1.0, function(value)
        ge_kosatka_z = value
    end)

    menu.action(generate_options_kosatka, "生成虎鲸", {}, "", function()
        local p = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(p, ge_kosatka_x, ge_kosatka_y, ge_kosatka_z)
        local objHash = util.joaat("kosatka")
        requestModels(objHash)
        local g_kosatka = VEHICLE.CREATE_VEHICLE(objHash, coords.x, coords.y, coords.z, ENTITY.GET_ENTITY_HEADING(p), true, false, true)
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(objHash)
    end)

    ---------- 友好选项 ----------
    local nice_options = menu.list(Player_MainMenu, "友好选项", {}, "")

    menu.action(nice_options, "掉落医药包", {}, "", function()
        local p = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        local pos = ENTITY.GET_ENTITY_COORDS(p)
        local objHash = util.joaat("prop_ld_health_pack")
        requestModels(objHash)
        local pickupHash = 2406513688
        local pickup = OBJECT.CREATE_PICKUP(pickupHash, pos.x, pos.y + 1.0, pos.z, 1, 100, false, objHash)
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(objHash)
    end)

    menu.action(nice_options, "掉落护甲", {}, "", function()
        local p = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        local pos = ENTITY.GET_ENTITY_COORDS(p)
        local objHash = util.joaat("prop_armour_pickup")
        requestModels(objHash)
        local pickupHash = 1274757841
        local pickup = OBJECT.CREATE_PICKUP(pickupHash, pos.x, pos.y + 1.0, pos.z, 1, 100, false, objHash)
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(objHash)
    end)

    ---------- 恢复选项 ----------
    local recovery_options = menu.list(Player_MainMenu, "恢复选项", {}, "")

    menu.toggle_loop(recovery_options, "掉落金钱", {}, "$2000\nCREATE_MONEY_PICKUPS", function()
        local p = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        if p ~= PLAYER.PLAYER_PED_ID() then
            local pos = ENTITY.GET_ENTITY_COORDS(p)
            local objHash = util.joaat("prop_cash_pile_01")
            requestModels(objHash)
            OBJECT.CREATE_MONEY_PICKUPS(pos.x, pos.y, pos.z + 1.0, 2000, 1, objHash)
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(objHash)
        end
        util.yield(500)
    end)

    menu.toggle_loop(recovery_options, "掉落金钱", {}, "$2000\nCREATE_PICKUP", function()
        local p = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
        if p ~= PLAYER.PLAYER_PED_ID() then
            local pos = ENTITY.GET_ENTITY_COORDS(p)
            local objHash = util.joaat("prop_cash_pile_01")
            requestModels(objHash)
            local pickupHash = 4263048111
            OBJECT.CREATE_PICKUP(pickupHash, pos.x, pos.y, pos.z + 1.0, 1, 2000, false, objHash)
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(objHash)
        end
        util.yield(500)
    end)



    ---
    ---
end

-------玩家列表-------
local InitialPlayersList = players.list(true, true, true)
for i = 1, #InitialPlayersList do
    GenerateFeatures(InitialPlayersList[i])
end

players.on_join(GenerateFeatures)

