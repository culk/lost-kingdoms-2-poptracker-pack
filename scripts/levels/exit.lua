---@class Exit
Exit = {}
Exit.__index = Exit

---Creates a new Exit object
---@param name string
---@return table
function Exit.New(name)
    ---@class Exit
    local o = setmetatable({}, Exit)
    o.Name = name
    o.LocationSectionRef = "@Connections/" .. name .. "/Cleared                                                                                             "
    o.LocationRef = "@Connections/" .. name
    o.Icon = "images/items/exit.png"
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
function Exit:Assign(level)
    local previous_level = self.Level
    self.Level = level
    local new_level_name = "nil"
    if level then
        new_level_name = level.Name
        level.Exit = self
    end
    if previous_level then
        previous_level.Exit = nil
    end
    print(string.format("Exit.Assign: Connecting exit '%s' to '%s'", self.Name, new_level_name))

    Exit.Select(nil)
    Level.Select(nil)

    self:UpdateItem()
    if level then
        level:UpdateItem()
    end
    if previous_level then
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

    local level = self.Level
    local assigned_level_name = nil
    if level then
        assigned_level_name = level.Name
    end
    item.ItemState.AssignedLevelName = assigned_level_name
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
            return "overlay|images/items/cursor.png"
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

EXIT_NAMES = {
    "Nobleman's Residence Exit 1",
    "Nobleman's Residence Exit 2",
    "Bhashea High Road Exit 1",
    "Bhashea High Road Exit 2",
    "Bhashea High Road Exit 3",
    "Kadishu Exit 1",
    "Kadishu Exit 2",
    "Gromtull Desert Exit 1",
    "Kendarie Fortress Exit 1",
    "Runestone Caverns - Upper Chambers Exit 1",
    "Runestone Caverns - Lower Chambers Exit 1",
    "Ruldo Forest Exit 1",
    "Ruldo Forest Exit 2",
    "Fossil Boneyard Exit 1",
    "Sarvan Exit 1",
    "Holzogh Town Exit 1",
    "Holzogh Town Exit 2",
    "Plains of Rowahl Exit 1",
    "Royal Tower - Lower Exit 1",
    "Krasheen Mountains Exit 1",
    "Grenfoel Cathedral Exit 1",
    "Grenfoel Cathedral Exit 2",
}

EXIT_BY_NAME = {}
for _, name in ipairs(EXIT_NAMES) do
    EXIT_BY_NAME[name] = Exit.New(name)
end

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