util.keep_running()
util.require_natives("1681379138")

require "RScript.labels"
require "RScript.variables"
require "RScript.functions"
require "RScript.functions2"


local menu_root = menu.my_root()

menu.divider(menu_root, "RS Test")

menu.action(menu_root, "Restart RS Test", { "re_rs_test" }, "", function()
    util.restart_script()
end)





menu.action(menu_root, "TEST 1", { "test_1" }, "", function()
    toast("hello")
end)






----------------------
-- 伤害数值显示
----------------------
local Damage_Numbers = menu.list(menu_root, "伤害数值显示", {}, "")

local damage_number = {
    show_select = 1,

    eventData = memory.alloc(13 * 8),
    screenX = memory.alloc(8),
    screenY = memory.alloc(8),

    text_scale = 0.7,
    text_color = { r = 1.0, g = 0.0, b = 1.0, a = 1.0 },
}

function damage_number.draw_number(text, screen_x, screen_y)
    local show_time = 3
    local text_color = damage_number.text_color

    util.create_tick_handler(function()
        local delta_time = MISC.GET_FRAME_TIME()

        local alpha = math.min(1, show_time)
        directx.draw_text(screen_x, screen_y, text, ALIGN_CENTRE, damage_number.text_scale,
            { r = text_color.r, g = text_color.g, b = text_color.b, a = text_color.a * alpha }, false)

        screen_y = screen_y - 0.002

        show_time = show_time - delta_time * 2
        if show_time <= 0 then
            return false
        end
    end)
end

function damage_number.get_entity_screen_coords(entity)
    local x, y = 0, 0
    local random_offset = 1
    local coords = ENTITY.GET_ENTITY_COORDS(entity)
    coords.x = coords.x + (math.random() * random_offset - random_offset * 0.5)
    coords.y = coords.y + (math.random() * random_offset - random_offset * 0.5)

    if GRAPHICS.GET_SCREEN_COORD_FROM_WORLD_COORD(coords.x, coords.y, coords.z, damage_number.screenX, damage_number.screenY) then
        x = memory.read_float(damage_number.screenX)
        y = memory.read_float(damage_number.screenY)
    end
    return x, y
end

menu.toggle_loop(Damage_Numbers, "开启", {}, "仅线上模式有效", function()
    if util.is_session_started() and not util.is_session_transition_active() then
        for eventIndex = 0, SCRIPT.GET_NUMBER_OF_EVENTS(1) - 1 do
            local eventType = SCRIPT.GET_EVENT_AT_INDEX(1, eventIndex)
            if eventType == 186 then                                                             -- CEventNetworkEntityDamage
                if SCRIPT.GET_EVENT_DATA(1, eventIndex, damage_number.eventData, 13) then
                    local Victim = memory.read_int(damage_number.eventData)                      -- entity
                    local Attacker = memory.read_int(damage_number.eventData + 1 * 8)            -- entity
                    local Damage = memory.read_float(damage_number.eventData + 2 * 8)            -- float
                    local EnduranceDamage = memory.read_float(damage_number.eventData + 3 * 8)   -- float
                    local VictimIncapacitated = memory.read_int(damage_number.eventData + 4 * 8) -- bool
                    local VictimDestroyed = memory.read_int(damage_number.eventData + 5 * 8)     -- bool
                    -- local WeaponHash = memory.read_int(damage_number.eventData + 6 * 8)          -- int
                    -- local VictimSpeed = memory.read_float(damage_number.eventData + 7 * 8)             -- float
                    -- local AttackerSpeed = memory.read_float(damage_number.eventData + 8 * 8)           -- float
                    -- local IsResponsibleForCollision = memory.read_int(damage_number.eventData + 9 * 8) -- bool
                    -- local IsHeadShot = memory.read_int(damage_number.eventData + 10 * 8)               -- bool
                    -- local IsWithMeleeWeapon = memory.read_int(damage_number.eventData + 11 * 8)        -- bool
                    -- local HitMaterial = memory.read_int(damage_number.eventData + 12 * 8)              -- int

                    local is_match = false
                    if damage_number.show_select == 1 then
                        is_match = true
                    elseif damage_number.show_select == 2 and Attacker == players.user_ped() then
                        is_match = true
                    elseif damage_number.show_select == 3 and Victim == players.user_ped() then
                        is_match = true
                    end

                    if is_match then
                        local screen_x, screen_y = damage_number.get_entity_screen_coords(Victim)
                        damage_number.draw_number(round(Damage, 2), screen_x, screen_y)
                    end
                end
            end
        end
    end
end)

menu.list_select(Damage_Numbers, "显示类型", {}, "", {
    "两者", "玩家造成的伤害", "玩家受到的伤害"
}, 1, function(value)
    damage_number.show_select = value
end)



----------------------
-- 玩家受到伤害时
----------------------
local Player_Damage = menu.list(menu_root, "玩家受到伤害时", {}, "")

local player_damage = {
    eventData = memory.alloc(13 * 8),
    screenX = memory.alloc(8),
    screenY = memory.alloc(8),
    bonePtr = memory.alloc(4),

    notify = {
        enable = false,
    },

    number = {
        enable = false,


        duration = 3000, -- ms
        text_scale = 0.8,
        text_colour = Colors.red,
        -- 显示位置
        text_x = 0.5,
        text_y = 0.5,
        bone_pos = false,
    },

    attacker = {
        enable = false,

        toggle = {
            dead = false,
            explosion = false,
        },
    },
}

function player_damage.notify_info(eventData)
    local attacker = eventData.Attacker
    local damage = eventData.Damage
    local weaponHash = eventData.WeaponHash
    local text = ""

    local model_hash = ENTITY.GET_ENTITY_MODEL(attacker)
    local model_name = util.reverse_joaat(model_hash)
    local entity_type = GET_ENTITY_TYPE(attacker)

    text = "Model Name: " .. model_name ..
        "\nType: " .. entity_type ..
        "\nHealth: " .. ENTITY.GET_ENTITY_HEALTH(attacker) ..
        "\nDamage: " .. damage ..
        "\nWeapon: " .. util.reverse_joaat(weaponHash)

    THEFEED_POST.TEXT(text)
end

function player_damage.to_screen_coords(coords)
    local x, y = 0, 0

    if GRAPHICS.GET_SCREEN_COORD_FROM_WORLD_COORD(coords.x, coords.y, coords.z,
            player_damage.screenX, player_damage.screenY) then
        x = memory.read_float(player_damage.screenX)
        y = memory.read_float(player_damage.screenY)
    end

    return x, y
end

function player_damage.draw_damage_number(text, eventData)
    local duration = player_damage.number.duration / 1000
    local text_colour = player_damage.number.text_colour
    local scale = player_damage.number.text_scale

    local x, y = player_damage.number.text_x, player_damage.number.text_y
    if player_damage.number.bone_pos then
        if PED.GET_PED_LAST_DAMAGE_BONE(players.user_ped(), player_damage.bonePtr) then
            local boneId = memory.read_byte(player_damage.bonePtr)
            local bone_coords = PED.GET_PED_BONE_COORDS(players.user_ped(), boneId, 0.0, 0.0, 0.0)
            x, y = player_damage.to_screen_coords(bone_coords)
        end
    end

    util.create_tick_handler(function()
        local delta_time = MISC.GET_FRAME_TIME()

        local alpha = math.min(1, duration)
        directx.draw_text(x, y, text, ALIGN_CENTRE, scale,
            { r = text_colour.r, g = text_colour.g, b = text_colour.b, a = text_colour.a * alpha }, false)

        y = y - 0.002
        duration = duration - delta_time * 2
        if duration <= 0 then
            return false
        end
    end)
end

function player_damage.attacker_reaction(attacker, eventData)
    local toggle = player_damage.attacker.toggle

    if toggle.dead then
        ENTITY.SET_ENTITY_HEALTH(attacker, 0)
    end

    if toggle.explosion then
        local pos = ENTITY.GET_ENTITY_COORDS(attacker)
        add_explosion(pos, 4)
    end
end

menu.toggle_loop(Player_Damage, "开启", {}, "仅线上模式有效", function()
    if util.is_session_started() and not util.is_session_transition_active() then
        for eventIndex = 0, SCRIPT.GET_NUMBER_OF_EVENTS(1) - 1 do
            local eventType = SCRIPT.GET_EVENT_AT_INDEX(1, eventIndex)
            if eventType == 186 then -- CEventNetworkEntityDamage
                if SCRIPT.GET_EVENT_DATA(1, eventIndex, player_damage.eventData, 13) then
                    local eventData = {}
                    eventData.Victim = memory.read_int(player_damage.eventData)           -- entity
                    eventData.Attacker = memory.read_int(player_damage.eventData + 1 * 8) -- entity
                    eventData.Damage = memory.read_float(player_damage.eventData + 2 * 8) -- float
                    -- eventData.EnduranceDamage = memory.read_float(player_damage.eventData + 3 * 8)   -- float
                    -- eventData.VictimIncapacitated = memory.read_int(player_damage.eventData + 4 * 8) -- bool
                    eventData.VictimDestroyed = memory.read_int(player_damage.eventData + 5 * 8) -- bool
                    eventData.WeaponHash = memory.read_int(player_damage.eventData + 6 * 8)      -- int
                    -- eventData.VictimSpeed = memory.read_float(player_damage.eventData + 7 * 8)             -- float
                    -- eventData.AttackerSpeed = memory.read_float(player_damage.eventData + 8 * 8)           -- float
                    -- eventData.IsResponsibleForCollision = memory.read_int(player_damage.eventData + 9 * 8) -- bool
                    -- eventData.IsHeadShot = memory.read_int(player_damage.eventData + 10 * 8)               -- bool
                    -- eventData.IsWithMeleeWeapon = memory.read_int(player_damage.eventData + 11 * 8)        -- bool
                    -- eventData.HitMaterial = memory.read_int(player_damage.eventData + 12 * 8)              -- int


                    -- 受害者为玩家
                    if eventData.Victim == players.user_ped() then
                        -- 通知信息
                        if player_damage.notify.enable then
                            player_damage.notify_info(eventData)
                        end

                        -- 伤害数值显示
                        if player_damage.number.enable then
                            player_damage.draw_damage_number(round(eventData.Damage, 2), eventData)
                        end

                        -- 攻击者反应
                        if player_damage.attacker.enable and eventData.Attacker ~= players.user_ped() then
                            player_damage.attacker_reaction(eventData.Attacker, eventData)
                        end
                    end
                end
            end
        end
    end
end)

menu.divider(Player_Damage, "选项")

menu.toggle(Player_Damage, "通知信息", {}, "", function(toggle)
    player_damage.notify.enable = toggle
end)

----- 伤害数值显示  -----
menu.toggle(Player_Damage, "伤害数值显示", {}, "", function(toggle)
    player_damage.number.enable = toggle
end)

local Player_Damage_Number = menu.list(Player_Damage, "显示设置", {}, "")

menu.slider(Player_Damage_Number, "显示时长(毫秒)", { "player_damage_number_duration" }, "",
    500, 10000, 3000, 500, function(value)
        player_damage.number.duration = value
    end)
menu.slider_float(Player_Damage_Number, "文字大小", { "player_damage_number_text_scale" }, "",
    1, 1000, 70, 5, function(value)
        player_damage.number.text_scale = value * 0.01
    end)
menu.colour(Player_Damage_Number, "文字颜色", { "player_damage_number_text_colour" }, "",
    Colors.red, true, function(value)
        player_damage.number.text_colour = value
    end)

menu.divider(Player_Damage_Number, "固定位置")
menu.slider_float(Player_Damage_Number, "位置 X", { "player_damage_number_text_x" }, "",
    0, 100, 50, 1, function(value)
        player_damage.number.text_x = value * 0.01
    end)
menu.slider_float(Player_Damage_Number, "位置 Y", { "player_damage_number_text_y" }, "",
    0, 100, 50, 1, function(value)
        player_damage.number.text_y = value * 0.01
    end)

menu.divider(Player_Damage_Number, "受到伤害的位置")
menu.toggle(Player_Damage_Number, "开启", {}, "", function(toggle)
    player_damage.number.bone_pos = toggle
end, true)

menu.action(Player_Damage_Number, "测试效果", {}, "", function()
    player_damage.draw_damage_number(math.random(0, 100))
end)


----- 攻击者反应 -----
menu.toggle(Player_Damage, "攻击者反应", {}, "", function(toggle)
    player_damage.attacker.enable = toggle
end)

local Player_Damage_Attacker = menu.list(Player_Damage, "反应设置", {}, "")

menu.toggle(Player_Damage_Attacker, "死亡", {}, "", function(toggle)
    player_damage.attacker.toggle.dead = toggle
end)
menu.toggle(Player_Damage_Attacker, "匿名爆炸", {}, "", function(toggle)
    player_damage.attacker.toggle.explosion = toggle
end)
