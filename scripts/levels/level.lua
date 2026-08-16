---@class Level
Level = {}
Level.__index = Level

---Creates a new Level object
---@param name string
---@param icon string
---@return table
function Level.New(name, icon)
    ---@class Level
    local o = setmetatable({}, Level)
    o.Name = name
    o.LocationRef = "@Connections/" .. name
    o.Icon = icon
    ---@type Exit
    o.Exit = nil
    return o
end

---Returns whether the level is selected.
---@return boolean
function Level:IsSelected()
    return Level.SelectedLevel == self
end

---Update img_mods to indicate the new level is currently selected.
---@param level Level?
function Level.Select(level)
    local previous_selected = Level.SelectedLevel
    Level.SelectedLevel = level

    if previous_selected then
        previous_selected:UpdateIconMods()
    end

    if level then
        level:UpdateIconMods()
    end
end

---Returns the LuaItem for the level.
---@return LuaItem?
function Level:GetItem()
    return Tracker:FindObjectForCode(self.Name) --[[@as LuaItem]]
end

---Returns the img_mods to apply to the level's hosted LuaItem to indicate if it is selected or assigned an Exit.
---@return string
function Level:GetIconMods()
    if self.Exit then
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

---Updates the img_mods for the level's hosted LuaItem.
---@param item LuaItem?
function Level:UpdateIconMods(item)
    item = item or self:GetItem()
    if not item then
        return
    end
    local new_icon_mods = self:GetIconMods()
    if item.IconMods ~= new_icon_mods then
        item.IconMods = new_icon_mods
    end
end

---Updates the name and text overlay for the level's hosted LuaItem.
---@param item LuaItem?
function Level:UpdateNameAndOverlay(item)
    item = item or self:GetItem()
    if not item then
        return
    end
    local exit = self.Exit
    local new_name
    local new_text_overlay
    if exit then
        new_name = exit.Name .. " -> " .. self.Name
        new_text_overlay = "from " .. exit.Name
    else
        new_name = "Left click to assign " .. self.Name .. " to an exit"
        new_text_overlay = ""
    end
    --if item.Name ~= new_name then
    --    item.Name = new_name
    --end
    item:SetOverlay(new_text_overlay)
end

---Updates the visual parts of the level's hosted LuaItem including its name, icon and text overlay.
---@param item LuaItem?
function Level:UpdateItem(item)
    item = item or self:GetItem()
    self:UpdateIconMods(item)
    self:UpdateNameAndOverlay(item)
end

ICON_BY_LEVEL = {
    ["Bhashea High Road"] = "images/items/levels/bhashea_high_road.png",
    ["Isamat Urbur"] = "images/items/levels/isamat_urbur.png",
    ["Kendarie Fortress"] = "images/items/levels/kendarie_fortress.png",
    ["Kadishu"] = "images/items/levels/kadishu_overworld.png",
    ["Bhashea Castle"] = "images/items/levels/bhashea_castle.png",
    ["Kadishu Shop"] = "images/items/levels/kadishu_shop.png",
    ["Fairy House"] = "images/items/levels/fairy_house.png",
    ["Gromtull Desert"] = "images/items/levels/gromtull_desert.png",
    ["Runestone Caverns - Upper Chambers"] = "images/items/levels/runestone_caverns_upper_chambers.png",
    ["Runestone Caverns - Lower Chambers"] = "images/items/levels/runestone_caverns_lower_chambers.png",
    ["Ruldo Forest"] = "images/items/levels/ruldo_forest.png",
    ["Sacred Battle Arena 1"] = "images/items/levels/sacred_battle_arena_overworld.png",
    ["Fossil Boneyard"] = "images/items/levels/fossil_boneyard.png",
    ["Sarvan"] = "images/items/levels/sarvan.png",
    ["Holzogh Town"] = "images/items/levels/holzogh_town.png",
    ["Plains of Rowahl"] = "images/items/levels/plains_of_rowahl.png",
    ["Alanjeh Castle"] = "images/items/levels/alanjeh_castle_overworld.png",
    ["Krasheen Mountains"] = "images/items/levels/krasheen_mountains.png",
    ["Grenfoel Cathedral"] = "images/items/levels/grenfoel_cathedral.png",
    ["Temple of Sharacia"] = "images/items/levels/temple_of_sharacia.png",
    ["Grenfoel Cathedral Shop"] = "images/items/levels/grenfoel_card_shop.png",
    ["Obenoix Gorge"] = "images/items/levels/obenoix_gorge.png",
}

LEVEL_BY_NAME = {}
for name, icon in pairs(ICON_BY_LEVEL) do
    LEVEL_BY_NAME[name] = Level.New(name, icon)
end