------------------------------------------------
----------------   [[ Menu ]]   ----------------
------------------------------------------------

rs_menu = {}

-------- [[ 武器 ]] --------

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
--- @param action_name string
--- @param on_click function?
--- @param change_menu_name boolean? [default: false]
function rs_menu.current_weapon_action(weapon_menu_list, action_name, on_click, change_menu_name)
    local menu_name = menu.get_menu_name(weapon_menu_list)
    local menu_children = menu.get_children(weapon_menu_list)

    menu.attach_before(menu_children[1], menu.action(menu.shadow_root(), action_name, {}, "", function()
        if on_click then
            on_click()
        end

        if change_menu_name then
            menu.set_menu_name(weapon_menu_list, menu_name .. ": " .. action_name)
        end
        menu.focus(weapon_menu_list)
    end))

    if change_menu_name then
        menu.set_menu_name(weapon_menu_list, menu_name .. ": " .. action_name)
    end
end

-- local all_weapons = {}
-- local all_weapons_without_melee = {}
-- for key, item in pairs(util.get_weapons()) do
--     local menu_name = util.get_label_text(item.label_key)
--     local command_names = string.gsub(util.reverse_joaat(item.hash), "weapon_", "")

--     local list_item = { item.hash, menu_name, { command_names }, "", item.category }

--     table.insert(all_weapons, list_item)

--     if item.category_id ~= 0 then
--         table.insert(all_weapons_without_melee, list_item)
--     end
-- end



-- function rs_menu.all_weapons2(menu_parent, menu_name, command_names, help_text, on_click, change_menu_name)
--     local reference
--     reference = menu.list_action(menu_parent, menu_name, command_names, help_text,
--         all_weapons, function(weapon_hash, weapon_name, click_type)
--             if change_menu_name then
--                 local new_menu_name = string.format("%s: %s", menu_name, weapon_name)
--                 menu.set_menu_name(reference, new_menu_name)
--             end

--             if on_click then on_click(weapon_hash, weapon_name) end
--         end)

--     return reference
-- end

-- function rs_menu.all_weapons_without_melee2(menu_parent, menu_name, command_names, help_text, on_click, change_menu_name)
--     local reference
--     reference = menu.list_action(menu_parent, menu_name, command_names, help_text,
--         all_weapons_without_melee, function(weapon_hash, weapon_name, click_type)
--             if change_menu_name then
--                 local new_menu_name = string.format("%s: %s", menu_name, weapon_name)
--                 menu.set_menu_name(reference, new_menu_name)
--             end

--             if on_click then on_click(weapon_hash, weapon_name) end
--         end)

--     return reference
-- end






-------- [[ 载具武器 ]] --------

rs_menu.vehicle_weapon_list = {
    reference = 0,
    menu_name = "",
    command_names = {},
    help_text = "",
    on_click = nil,
    change_menu_name = false,
}
rs_menu.vehicle_weapon_list.__index = rs_menu.vehicle_weapon_list

function rs_menu.vehicle_weapon_list:create_class_list()
    local class_menu = {}
    local class_list = { 0, 1, 2, 4, 5, 6, 7, 8, 9, 11, 12, 14, 15, 16, 18, 19, 20 }

    for _, id in pairs(class_list) do
        local name = util.get_label_text("VEH_CLASS_" .. id)
        class_menu[id] = menu.list(self.reference, name, {}, "")
    end

    return class_menu
end

function rs_menu.vehicle_weapon_list:add_action(item)
    -- Vehicle List
    if self.vehicle_menu[item.vehicle_model] == nil then
        local menu_parent = self.class[item.class_id]
        local vehicle_name = util.get_label_text(item.display_name_label)

        local command_names = {}
        if next(self.command_names) ~= nil then
            command_names = { self.command_names[1] .. item.vehicle_model }
        end

        self.vehicle_menu[item.vehicle_model] = menu.list(menu_parent, vehicle_name, command_names, "")
    end
    local vehicle_menu = self.vehicle_menu[item.vehicle_model]

    -- Vehicle Weapon Action
    local weapon_name = ""
    if item.weapon_label ~= "" then
        weapon_name = util.get_label_text(item.weapon_label)
    else
        weapon_name = string.gsub(item.weapon_model, "VEHICLE_WEAPON_", "")
    end

    local command_names = {}
    if next(self.command_names) ~= nil then
        command_names = { self.command_names[1] .. weapon_name }
    end

    menu.action(vehicle_menu, weapon_name, command_names, "", function(click_type)
        if self.change_menu_name then
            local menu_new_name = string.format("%s: %s", self.menu_name, weapon_name)
            menu.set_menu_name(self.reference, menu_new_name)
        end

        if click_type == CLICK_MENU then menu.focus(self.reference) end

        local weapon_hash = util.joaat(item.weapon_model)
        if self.on_click then self.on_click(weapon_hash, item.weapon_model) end
    end)
end

--- Your on_click function will be called with hash and model.
--- @param menu_parent CommandRef
--- @param menu_name string
--- @param command_names table<any, string>
--- @param help_text string
--- @param on_click function?
--- @param change_menu_name boolean? [default: false]
--- @return CommandRef|CommandUniqPtr
function rs_menu.vehicle_weapons(menu_parent, menu_name, command_names, help_text, on_click, change_menu_name)
    local self = setmetatable({}, rs_menu.vehicle_weapon_list)

    self.menu_name = menu_name
    self.command_names = command_names
    self.help_text = help_text
    self.on_click = on_click
    self.change_menu_name = change_menu_name
    self.reference = menu.list(menu_parent, menu_name, command_names, help_text)
    self.class = self:create_class_list()
    self.vehicle_menu = {}

    for key, item in pairs(RS_T.VehicleWeapons) do
        self:add_action(item)
    end

    return self.reference
end

-------- [[ 其它 ]] --------

--- 删除 menu list (table)
--- @param menu_list table<int, CommandRef>
function rs_menu.delete_menu_list(menu_list)
    for _, command in pairs(menu_list) do
        if command ~= nil and menu.is_ref_valid(command) then
            menu.delete(command)
        end
    end
    menu.collect_garbage()
end

--- 删除 menu.list 下的所有子菜单
--- @param list CommandRef
function rs_menu.delete_menu_children(list)
    local children = menu.get_children(list)
    if #children == 0 then return end

    for _, command in pairs(children) do
        menu.delete(command)
    end
    menu.collect_garbage()
end

--------------------------------------------------
----------------   [[ Memory ]]   ----------------
--------------------------------------------------

rs_memory = {}

--- @param addr pointer
--- @return boolean
function rs_memory.is_entity_froze(addr)
    local m_base_flags = memory.read_uint(addr + 0x2C)
    -- IS_FIXED, IS_FIXED_BY_NETWORK
    return IS_ANY_BIT_SET(m_base_flags, 17, 18)
end

--- @param addr pointer
--- @return boolean
function rs_memory.is_mission_entity(addr)
    local m_dynamic_entity_flags = memory.read_ushort(addr + 0xDA)
    -- POPTYPE_MISSION, POPTYPE_PERMANENT
    return BITS_TEST(m_dynamic_entity_flags, 0, 1, 2) or BITS_TEST(m_dynamic_entity_flags, 1, 2)
end

--- @param addr pointer
--- @return float
function rs_memory.get_entity_health(addr)
    return memory.read_float(addr + 0x280)
end

--- @param addr pointer
--- @param value float
function rs_memory.set_entity_health(addr, value)
    memory.write_float(addr + 0x280, value)
end

--- Only applicable to peds.
--- @param addr pointer
--- @return pointer
function rs_memory.get_weapon_info(addr)
    local m_weapon_manager = memory.read_long(addr + 0x10B8)
    if m_weapon_manager == 0 then
        return 0
    end

    local m_equipped_weapon_info = memory.read_long(m_weapon_manager + 0x58 + 0x10)
    if m_equipped_weapon_info ~= 0 then
        return m_equipped_weapon_info
    end

    local m_equipped_vehicle_weapon_info = memory.read_long(m_weapon_manager + 0x58 + 0x18)
    if m_equipped_vehicle_weapon_info ~= 0 then
        return m_equipped_vehicle_weapon_info
    end

    return 0
end

--------------------------------------------------
--        Script Patch Function
--------------------------------------------------

ScriptPatch = {
    initialized = false,
    enabled = false,
    scan_failed = false,

    script = "",
    script_address = 0
}
ScriptPatch.__index = ScriptPatch

function ScriptPatch:Init()
    for key, data in pairs(self.patch_data) do
        local pattern = data.pattern
        local offset = data.offset
        local patch_bytes = data.patch_bytes

        local addr = self.ScanPattern(self.script, pattern)
        if not addr then
            self.scan_failed = true
            return false
        end

        addr = addr + offset

        local original_bytes = {}
        for i, patch_byte in pairs(patch_bytes) do
            local patch_addr = addr + i - 1

            table.insert(original_bytes, memory.read_ubyte(patch_addr))
            memory.write_ubyte(patch_addr, patch_byte)
        end

        self.patch_data[key].address = addr
        self.patch_data[key].original_bytes = original_bytes
    end

    self.script_address = memory.scan_script(self.script, "")
    self.initialized = true

    self.enabled = true
end

function ScriptPatch:Enable()
    if not IS_SCRIPT_RUNNING(self.script) then
        self.enabled = false
        return
    end

    if self.enabled or self.scan_failed then
        return
    end

    if not self.initialized then
        self:Init()
        return
    end

    if self:IsScriptReloaded() then
        self.initialized = false
        return
    end

    for key, data in pairs(self.patch_data) do
        local addr = data.address
        local patch_bytes = data.patch_bytes

        for i, patch_byte in pairs(patch_bytes) do
            local patch_addr = addr + i - 1
            memory.write_ubyte(patch_addr, patch_byte)
        end
    end

    self.enabled = true
end

function ScriptPatch:Disable()
    if self.scan_failed or not self.initialized then
        return
    end
    if self:IsScriptReloaded() then
        return
    end

    for key, data in pairs(self.patch_data) do
        local addr = data.address
        local original_bytes = data.original_bytes

        for i, original_byte in pairs(original_bytes) do
            local patch_addr = addr + i - 1
            memory.write_ubyte(patch_addr, original_byte)
        end
    end

    self.enabled = false
end

function ScriptPatch:IsScriptReloaded()
    return self.script_address ~= memory.scan_script(self.script, "")
end

--- @param script string
--- @param pattern string
--- @return boolean|integer
function ScriptPatch.ScanPattern(script, pattern)
    local addr = memory.scan_script(script, pattern)
    if not addr or addr == 0 then
        util.toast("Scan pattern failed!\n" .. script .. ": " .. pattern, TOAST_ALL)
        return false
    end
    return addr
end

--- @param script string
--- @param patch_data table
--- @return ScriptPatch
function ScriptPatch.New(script, patch_data)
    local self = setmetatable({}, ScriptPatch)

    self.script = script
    self.patch_data = patch_data

    return self
end

ScriptFunc = {}

--- @param bool boolean
--- @param arg_count integer Number of function arguments
--- @return table
function ScriptFunc.ReturnBool(bool, arg_count)
    if bool then
        return { 0x72, 0x2E, arg_count, 0x01 }
    end
    return { 0x71, 0x2E, arg_count, 0x01 }
end
