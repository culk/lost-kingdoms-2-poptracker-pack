---@class Exit
Exit = {}
Exit.__index = Exit

---Creates a new Exit object
---@param name string
---@param icon string
---@param default_level_name string
---@return table
function Exit.New(name, icon, default_level_name)
    ---@class Exit
    local o = setmetatable({}, Exit)
    o.Name = name
    o.LocationRef = "@Connections/" .. name
    o.Icon = icon
    o.DefaultLevelName = default_level_name
    ---@type string
    o.RandomizedLevelName = nil
    ---@type Level
    o.Level = nil
    return o
end

---Returns whether the exit is selected.
---@return boolean
function Exit:IsSelected()
    return Exit.SelectedExit == self
end

---Update img_mods to indicate the new exit is currently selected.
---@param exit Exit?
function Exit.Select(exit)
    local previous_selected = Exit.SelectedExit
    Exit.SelectedExit = exit

    if previous_selected then
        previous_selected:UpdateIconMods()
    end

    if exit then
        exit:UpdateIconMods()
    end
end

---Connects the exit to the level, deselects both, and updates their appearance and location information.
---@param level Level?
---@param is_randomized boolean?
function Exit:Assign(level, is_randomized)
    is_randomized = is_randomized or false
    local previous_level = self.Level
    self.Level = level
    local new_level_name = "nil"
    if level then
        new_level_name = level.Name
        level.Exit = self
        if is_randomized then
            -- Only update the randomized level name when assigning a level from slot data or manually. Allows for toggling between default level mapping and randomized level mapping.
            self.RandomizedLevelName = level.Name
        end
    end
    if previous_level and previous_level ~= level then
        previous_level.Exit = nil
    end
    print(string.format("Exit.Assign: Connecting exit '%s' to '%s'", self.Name, new_level_name))

    Exit.Select(nil)
    Level.Select(nil)

    self:UpdateItem()
    if level then
        level:UpdateItem()
    end
    if previous_level and previous_level ~= level then
        previous_level:UpdateItem()
    end
end

---Returns the LuaItem for the exit.
---@return LuaItem?
function Exit:GetItem()
    return Tracker:FindObjectForCode(self.Name) --[[@as LuaItem]]
end

---Updates the LuaItem's state to save Level assignment information.
---@param item LuaItem?
function Exit:UpdateItemState(item)
    item = item or self:GetItem()
    if not item then
        return
    end

    if self.RandomizedLevelName then
        -- Update item state with randomized level so that loading a saved pack state preserves assignments.
        item.ItemState.RandomizedLevelName = self.RandomizedLevelName
    end
end

---Returns the img_mods to apply to the exit's hosted LuaItem to indicate if it is selected or assigned a Level.
---@return string
function Exit:GetIconMods()
    if self.Level then
        if self:IsSelected() then
            return "@disabled,overlay|images/items/cursor.png"
        else
            return "@disabled"
        end
    else
        if self:IsSelected() then
            return "brightness|1.5,overlay|images/items/cursor.png"
        else
            return "none"
        end
    end
end

---Updates the img_mods for the exit's hosted LuaItem.
---@param item LuaItem?
function Exit:UpdateIconMods(item)
    item = item or self:GetItem()
    if not item then
        return
    end
    local new_icon_mods = self:GetIconMods()
    if item.IconMods ~= new_icon_mods then
        item.IconMods = new_icon_mods
    end
end

---Updates the name and text overlay for the exit's hosted LuaItem.
---@param item LuaItem?
function Exit:UpdateNameAndOverlay(item)
    item = item or self:GetItem()
    if not item then
        return
    end
    local level = self.Level
    local new_name
    local new_text_overlay
    if level then
        new_name = self.Name .. " -> " .. level.Name
        new_text_overlay = "to " .. level.Name
    else
        new_name = "Left click to assign " .. self.Name .. " to a destination level"
        new_text_overlay = ""
    end
    --if item.Name ~= new_name then
    --    item.Name = new_name
    --end
    item:SetOverlay(new_text_overlay)
end

---Updates the visual parts of the exit's hosted LuaItem including its name, icon and text overlay.
---@param item LuaItem?
function Exit:UpdateItem(item)
    item = item or self:GetItem()
    self:UpdateItemState(item)
    self:UpdateIconMods(item)
    self:UpdateNameAndOverlay(item)
end

ICON_BY_EXIT = {
    ["Nobleman's Residence Exit 1"] = "images/items/exits/noblemans_residence_exit_1.png",
    ["Nobleman's Residence Exit 2"] = "images/items/exits/noblemans_residence_exit_2.png",
    ["Bhashea High Road Exit 1"] = "images/items/exits/bhashea_high_road_exit_1.png",
    ["Bhashea High Road Exit 2"] = "images/items/exits/bhashea_high_road_exit_2.png",
    ["Bhashea High Road Exit 3"] = "images/items/exits/bhashea_high_road_exit_3.png",
    ["Kadishu Exit 1"] = "images/items/exits/kadishu_exit_1.png",
    ["Kadishu Exit 2"] = "images/items/exits/kadishu_exit_2.png",
    ["Gromtull Desert Exit 1"] = "images/items/exits/gromtull_desert_exit_1.png",
    ["Kendarie Fortress Exit 1"] = "images/items/exits/kendarie_fortress_exit_1.png",
    ["Runestone Caverns - Upper Chambers Exit 1"] = "images/items/exits/runestone_caverns_upper_chambers_exit_1.png",
    ["Runestone Caverns - Lower Chambers Exit 1"] = "images/items/exits/runestone_caverns_lower_chambers_exit_1.png",
    ["Ruldo Forest Exit 1"] = "images/items/exits/ruldo_forest_exit_1.png",
    ["Ruldo Forest Exit 2"] = "images/items/exits/ruldo_forest_exit_2.png",
    ["Fossil Boneyard Exit 1"] = "images/items/exits/fossil_boneyard_exit_1.png",
    ["Sarvan Exit 1"] = "images/items/exits/sarvan_exit_1.png",
    ["Holzogh Town Exit 1"] = "images/items/exits/holzogh_town_exit_1.png",
    ["Holzogh Town Exit 2"] = "images/items/exits/holzogh_town_exit_2.png",
    ["Plains of Rowahl Exit 1"] = "images/items/exits/plains_of_rowahl_exit_1.png",
    ["Royal Tower - Lower Exit 1"] = "images/items/exits/royal_tower_lower_exit_1.png",
    ["Krasheen Mountains Exit 1"] = "images/items/exits/krasheen_mountains_exit_1.png",
    ["Grenfoel Cathedral Exit 1"] = "images/items/exits/grenfoel_cathedral_exit_1.png",
    ["Grenfoel Cathedral Exit 2"] = "images/items/exits/grenfoel_cathedral_exit_2.png",
}

DEFAULT_EXIT_MAPPING = {
    ["Nobleman's Residence Exit 1"] = "Bhashea High Road",
    ["Nobleman's Residence Exit 2"] = "Isamat Urbur",
    ["Bhashea High Road Exit 1"] = "Kadishu",
    ["Bhashea High Road Exit 2"] = "Kendarie Fortress",
    ["Bhashea High Road Exit 3"] = "Bhashea Castle",
    ["Kadishu Exit 1"] = "Kadishu Shop",
    ["Kadishu Exit 2"] = "Gromtull Desert",
    ["Gromtull Desert Exit 1"] = "Fairy House",
    ["Kendarie Fortress Exit 1"] = "Runestone Caverns - Upper Chambers",
    ["Runestone Caverns - Upper Chambers Exit 1"] = "Runestone Caverns - Lower Chambers",
    ["Runestone Caverns - Lower Chambers Exit 1"] = "Ruldo Forest",
    ["Ruldo Forest Exit 1"] = "Fossil Boneyard",
    ["Ruldo Forest Exit 2"] = "Sacred Battle Arena 1",
    ["Fossil Boneyard Exit 1"] = "Sarvan",
    ["Sarvan Exit 1"] = "Holzogh Town",
    ["Holzogh Town Exit 1"] = "Plains of Rowahl",
    ["Holzogh Town Exit 2"] = "Obenoix Gorge",
    ["Plains of Rowahl Exit 1"] = "Alanjeh Castle",
    ["Royal Tower - Lower Exit 1"] = "Krasheen Mountains",
    ["Krasheen Mountains Exit 1"] = "Grenfoel Cathedral",
    ["Grenfoel Cathedral Exit 1"] = "Temple of Sharacia",
    ["Grenfoel Cathedral Exit 2"] = "Grenfoel Cathedral Shop",
}

EXIT_BY_NAME = {}
for name, icon in pairs(ICON_BY_EXIT) do
    EXIT_BY_NAME[name] = Exit.New(name, icon, DEFAULT_EXIT_MAPPING[name])
end