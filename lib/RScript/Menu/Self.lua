------------------------------------------
--          Self Options
------------------------------------------


local Self_Options <const> = menu.list(Menu_Root, "自我选项", {}, "")


local MenuSelf = {}


--#region Health & Armour

local Self_HealthArmour <const> = menu.list(Self_Options, "生命与护甲选项", {}, "")

local HealthArmour = {
    defaultHealth = 328,
    defaultArmour = 50,
}

menu.toggle_loop(Self_HealthArmour, "信息显示 生命和护甲", { "rsInfoHealth" }, "信息显示位置", function()
    local current_health = ENTITY.GET_ENTITY_HEALTH(players.user_ped())
    local max_health = PED.GET_PED_MAX_HEALTH(players.user_ped())
    local current_armour = PED.GET_PED_ARMOUR(players.user_ped())
    local max_armour = PLAYER.GET_PLAYER_MAX_ARMOUR(players.user())

    local text = string.format("生命: %d/%d\n护甲: %d/%d", current_health, max_health, current_armour, max_armour)
    util.draw_debug_text(text)
end)

menu.toggle(Self_HealthArmour, "切换战局自动补满护甲", {}, "", function(toggle)
    TransitionData.Self.refillArmour = toggle
end)


menu.divider(Self_HealthArmour, "")
menu.slider(Self_HealthArmour, "设置当前生命值", { "rsSetHealth" }, "",
    0, 100000, HealthArmour.defaultHealth, 50, function(value)
        SET_ENTITY_HEALTH(players.user_ped(), value)
    end)
menu.slider(Self_HealthArmour, "设置当前护甲值", { "rsSetArmour" }, "",
    0, 100000, HealthArmour.defaultArmour, 50, function(value)
        PED.SET_PED_ARMOUR(players.user_ped(), value)
    end)

--#endregion


--#region Health Recharge

local Self_HealthRecharge <const> = menu.list(Self_Options, "生命恢复选项", {}, "")

local HealthRecharge = {
    maxPercent = 1.0,
    multiplier = 20.0,
}

menu.slider_float(Self_HealthRecharge, "恢复程度", { "selfRechargePercent" }, "",
    1, 100, HealthRecharge.maxPercent * 100, 10, function(value)
        HealthRecharge.maxPercent = value * 0.01
    end)
menu.slider_float(Self_HealthRecharge, "恢复速度", { "selfRechargeMulti" }, "",
    1, 10000, HealthRecharge.multiplier * 100, 100, function(value)
        HealthRecharge.multiplier = value * 0.01
    end)

menu.toggle_loop(Self_HealthRecharge, "设置生命恢复", { "rsHealthRecharge" }, "", function()
    if PLAYER.GET_PLAYER_HEALTH_RECHARGE_MAX_PERCENT(players.user()) ~= HealthRecharge.maxPercent then
        PLAYER.SET_PLAYER_HEALTH_RECHARGE_MAX_PERCENT(players.user(), HealthRecharge.maxPercent)
    end
    PLAYER.SET_PLAYER_HEALTH_RECHARGE_MULTIPLIER(players.user(), HealthRecharge.multiplier)
end, function()
    PLAYER.SET_PLAYER_HEALTH_RECHARGE_MAX_PERCENT(players.user(), 0.5)
    PLAYER.SET_PLAYER_HEALTH_RECHARGE_MULTIPLIER(players.user(), 1.0)
end)

--#endregion


--#region Wanted

local Self_Wanted <const> = menu.list(Self_Options, "通缉选项", {}, "")

menu.toggle_loop(Self_Wanted, "禁止为玩家调度警察", { "noDispatchCops" },
    "不会一直刷出新的警察，最好在被通缉前开启", function()
        PLAYER.SET_DISPATCH_COPS_FOR_PLAYER(players.user(), false)
    end, function()
        PLAYER.SET_DISPATCH_COPS_FOR_PLAYER(players.user(), true)
    end)
menu.action(Self_Wanted, "强制进入躲避区域", {}, "警星开始闪烁，警察使用锥形视野搜寻", function()
    PLAYER.FORCE_START_HIDDEN_EVASION(players.user())
end)
menu.action(Self_Wanted, "移除当前载具通缉状态", {}, "", function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle ~= INVALID_GUID then
        clear_vehicle_wanted(vehicle)
    end
end)
menu.toggle_loop(Self_Wanted, "降低通缉难度", {}, "", function()
    PLAYER.SET_WANTED_LEVEL_MULTIPLIER(0.0)
    PLAYER.SET_WANTED_LEVEL_DIFFICULTY(players.user(), 0.0)
end, function()
    PLAYER.SET_WANTED_LEVEL_MULTIPLIER(1.0)
    PLAYER.RESET_WANTED_LEVEL_DIFFICULTY(players.user())
end)

--#endregion


--#region Fall

local Self_Fall <const> = menu.list(Self_Options, "跌落选项", {}, "")

local SelfFall = {
    height = 8.0
}

menu.toggle_loop(Self_Fall, "禁止高处跌落直接死亡", { "noHighFallDeath" }, "如果血量过低仍然会直接摔死",
    function()
        PED.SET_DISABLE_HIGH_FALL_DEATH(players.user_ped(), true)
    end, function()
        PED.SET_DISABLE_HIGH_FALL_DEATH(players.user_ped(), false)
    end)

menu.slider_float(Self_Fall, "触发跌落动作高度", { "selfFallHeight" }, "",
    0, 10000, SelfFall.height * 100, 100, function(value)
        SelfFall.height = value * 0.01
    end)
menu.toggle_loop(Self_Fall, "设置触发跌落动作高度", {}, "", function()
    PLAYER.SET_PLAYER_FALL_DISTANCE_TO_TRIGGER_RAGDOLL_OVERRIDE(players.user(), SelfFall.height)
end)

--#endregion Fall


menu.toggle_loop(Self_Options, "警察无视", {}, "", function()
    PLAYER.SET_POLICE_IGNORE_PLAYER(players.user(), true)
end, function()
    PLAYER.SET_POLICE_IGNORE_PLAYER(players.user(), false)
end)
menu.toggle_loop(Self_Options, "所有人无视", {}, "", function()
    PLAYER.SET_EVERYONE_IGNORE_PLAYER(players.user(), true)
end, function()
    PLAYER.SET_EVERYONE_IGNORE_PLAYER(players.user(), false)
end)
menu.toggle_loop(Self_Options, "行动无声", {}, "", function()
    PLAYER.SET_PLAYER_NOISE_MULTIPLIER(players.user(), 0.0)
    PLAYER.SET_PLAYER_SNEAKING_NOISE_MULTIPLIER(players.user(), 0.0)
end)
menu.toggle_loop(Self_Options, "禁止被帮派骚扰", {}, "", function()
    PLAYER.SET_PLAYER_CAN_BE_HASSLED_BY_GANGS(players.user(), false)
end, function()
    PLAYER.SET_PLAYER_CAN_BE_HASSLED_BY_GANGS(players.user(), true)
end)
menu.toggle_loop(Self_Options, "载具内不可被射击", {}, "在载具内不会受伤", function()
    PED.SET_PED_CAN_BE_SHOT_IN_VEHICLE(players.user_ped(), false)
end, function()
    PED.SET_PED_CAN_BE_SHOT_IN_VEHICLE(players.user_ped(), true)
end)
menu.toggle_loop(Self_Options, "禁用NPC伤害", {}, "似乎只在单人战局内有效", function()
    PED.SET_AI_WEAPON_DAMAGE_MODIFIER(0.0)
    PED.SET_AI_MELEE_WEAPON_DAMAGE_MODIFIER(0.0)
end, function()
    PED.RESET_AI_WEAPON_DAMAGE_MODIFIER()
    PED.RESET_AI_MELEE_WEAPON_DAMAGE_MODIFIER()
end)
menu.toggle_loop(Self_Options, "只能被玩家伤害", {}, "不会被NPC伤害", function()
    ENTITY.SET_ENTITY_ONLY_DAMAGED_BY_PLAYER(players.user_ped(), true)
end, function()
    ENTITY.SET_ENTITY_ONLY_DAMAGED_BY_PLAYER(players.user_ped(), false)
end)
menu.toggle_loop(Self_Options, "禁止被爆头一枪击杀", {}, "", function()
    PED.SET_PED_SUFFERS_CRITICAL_HITS(players.user_ped(), false)
end, function()
    PED.SET_PED_SUFFERS_CRITICAL_HITS(players.user_ped(), true)
end)

MenuSelf.defenseModifier = 0.5
menu.slider_float(Self_Options, "设置受伤倍数", { "selfDefenseMultiplier" },
    "数值越低，受到的伤害就越低", 10, 100, MenuSelf.defenseModifier * 100, 10, function(value)
        MenuSelf.defenseModifier = value * 0.01
    end)
menu.toggle_loop(Self_Options, "受伤倍数修改", { "defenseMultiplier" }, "", function()
    local value = MenuSelf.defenseModifier
    PLAYER.SET_PLAYER_WEAPON_DEFENSE_MODIFIER(players.user(), value)
    PLAYER.SET_PLAYER_WEAPON_MINIGUN_DEFENSE_MODIFIER(players.user(), value)
    PLAYER.SET_PLAYER_MELEE_WEAPON_DEFENSE_MODIFIER(players.user(), value)
    PLAYER.SET_PLAYER_VEHICLE_DEFENSE_MODIFIER(players.user(), value)
    PLAYER.SET_PLAYER_WEAPON_TAKEDOWN_DEFENSE_MODIFIER(players.user(), value)
end, function()
    local value = 1.0
    PLAYER.SET_PLAYER_WEAPON_DEFENSE_MODIFIER(players.user(), value)
    PLAYER.SET_PLAYER_WEAPON_MINIGUN_DEFENSE_MODIFIER(players.user(), value)
    PLAYER.SET_PLAYER_MELEE_WEAPON_DEFENSE_MODIFIER(players.user(), value)
    PLAYER.SET_PLAYER_VEHICLE_DEFENSE_MODIFIER(players.user(), value)
    PLAYER.SET_PLAYER_WEAPON_TAKEDOWN_DEFENSE_MODIFIER(players.user(), value)
end)
