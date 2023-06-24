rs_menu = {}

rs_menu.weapon_list = {
    reference = 0,
    menu_name = "",
    command_names = {},
    help_text = "",
    on_click = nil,
    -- selected = {},
    change_menu_name = false,

    category_list = {
        [0] = "近战武器",
        [1] = "投掷式武器",
        [2] = "手枪",
        [3] = "机枪",
        [4] = "步枪",
        [5] = "霰弹枪",
        [6] = "狙击步枪",
        [7] = "重型武器"
    },
}
rs_menu.weapon_list.__index = rs_menu.weapon_list

function rs_menu.weapon_list:create_category()
    local category_menu = {}
    for category_id, category_name in pairs(self.category_list) do
        category_menu[category_id] = menu.list(self.reference, category_name, {}, "")
    end
    return category_menu
end

function rs_menu.weapon_list:add_action(item)
    local weapon_name = util.get_label_text(item.label_key)
    local menu_parent = self.category[item.category_id]

    local command_names = {}
    if next(self.command_names) ~= nil then
        command_names = { self.command_names[1] .. " " .. item.label_key }
    end

    menu.action(menu_parent, weapon_name, command_names, "", function(click_type)
        if self.change_menu_name then
            local menu_new_name = string.format("%s: %s", self.menu_name, weapon_name)
            menu.set_menu_name(self.reference, menu_new_name)
        end

        -- self.selected = { hash = item.hash, name = weapon_name }
        if click_type == CLICK_MENU then menu.focus(self.reference) end

        if self.on_click then self.on_click(item.hash, weapon_name) end
    end)
end

--- Your on_click function will be called with hash and name.
--- @param menu_parent CommandRef
--- @param menu_name string
--- @param command_names table<any, string>
--- @param help_text string
--- @param on_click function?
--- @param change_menu_name boolean? [default: false]
--- @return CommandRef|CommandUniqPtr
function rs_menu.all_weapons(menu_parent, menu_name, command_names, help_text, on_click, change_menu_name)
    local self = setmetatable({}, rs_menu.weapon_list)

    self.menu_name = menu_name
    self.command_names = command_names
    self.help_text = help_text
    self.on_click = on_click
    self.change_menu_name = change_menu_name
    self.reference = menu.list(menu_parent, menu_name, command_names, help_text)
    self.category = self:create_category()

    for key, item in pairs(util.get_weapons()) do
        self:add_action(item)
    end

    return self.reference
end

--- Your on_click function will be called with hash and name.
--- @param menu_parent CommandRef
--- @param menu_name string
--- @param command_names table<any, string>
--- @param help_text string
--- @param on_click function?
--- @param change_menu_name boolean? [default: false]
--- @return CommandRef|CommandUniqPtr
function rs_menu.all_weapons_without_melee(menu_parent, menu_name, command_names, help_text, on_click, change_menu_name)
    local self = setmetatable({}, rs_menu.weapon_list)

    self.menu_name = menu_name
    self.command_names = command_names
    self.help_text = help_text
    self.on_click = on_click
    self.change_menu_name = change_menu_name
    self.reference = menu.list(menu_parent, menu_name, command_names, help_text)
    self.category = self:create_category()

    menu.delete(self.category[0])

    for key, item in pairs(util.get_weapons()) do
        if item.category_id ~= 0 then
            self:add_action(item)
        end
    end

    return self.reference
end

--- @param weapon_menu_list CommandRef
--- @param on_click function?
--- @param change_menu_name boolean? [default: false]
function rs_menu.current_weapon_action(weapon_menu_list, on_click, change_menu_name)
    local weapon_menu_name = menu.get_menu_name(weapon_menu_list)

    menu.action(weapon_menu_list, "玩家当前使用的武器", {}, "", function()
        if on_click then
            on_click()
        end

        if change_menu_name then
            menu.set_menu_name(weapon_menu_list, weapon_menu_name .. ": 玩家当前使用的武器")
        end
        menu.focus(weapon_menu_list)
    end)

    if change_menu_name then
        menu.set_menu_name(weapon_menu_list, weapon_menu_name .. ": 玩家当前使用的武器")
    end
end

--- 删除 menu list (table)
--- @param menu_list table<int, CommandRef>
function rs_menu.delete_menu_list(menu_list)
    for k, command in pairs(menu_list) do
        if command ~= nil and menu.is_ref_valid(command) then
            menu.delete(command)
        end
    end
end

memory_utils = {}

--- @param blip Blip
--- @return float, float
function memory_utils.get_blip_scale_2d(blip)
    local ptr = util.blip_handle_to_pointer(blip)
    local m_scale_x = ptr + 0x50
    local m_scale_y = ptr + 0x54
    return memory.read_float(m_scale_x), memory.read_float(m_scale_y)
end

--- @param blip Blip
--- @param scale_x float
--- @param scale_y float
function memory_utils.set_blip_scale_2d(blip, scale_x, scale_y)
    local ptr = util.blip_handle_to_pointer(blip)
    local m_scale_x = ptr + 0x50
    local m_scale_y = ptr + 0x54
    memory.write_float(m_scale_x, scale_x)
    memory.write_float(m_scale_y, scale_y)
end
