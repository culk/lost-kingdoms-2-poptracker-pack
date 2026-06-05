require("scripts/levels/exit")
require("scripts/levels/level")

---Creates a LuaItem for the exit.
---@param exit Exit
function CreateExitItem(exit)
    local exit_item = ScriptHost:CreateLuaItem()
    exit_item.Name = exit.Name
    exit_item.Icon = ImageReference:FromPackRelativePath(exit.Icon)
    exit_item.ItemState = {AssignedLevelName = nil}
    exit_item:SetOverlayAlign("left")

    exit_item.CanProvideCodeFunc = function(self, code)
        return code == self.Name
    end

    exit_item.ProvidesCodeFunc = function(self, code)
        if self:CanProvideCodeFunc(code) and exit.Level then
            return true
        end
        return false
    end

    exit_item.OnLeftClickFunc = function(self)
        if exit.Level then
            -- Already assigned a destination Level, assignment can be cleared with right click.
            return
        elseif exit:IsSelected() then
            -- Deselect the exit because it was left clicked twice.
            Exit.Select(nil)
        else
            local level = Level.SelectedLevel
            if level then
                -- Assign the selected level to the left clicked exit.
                exit:Assign(level)
            else
                -- Select the left clicked exit.
                Exit.Select(exit)
            end
        end
    end

    exit_item.OnRightClickFunc = function(self)
        if exit.Level then
            -- Unassign the exit and its destination level.
            exit:Assign(nil)
        elseif exit:IsSelected() then
            -- Deselect the exit.
            Exit.Select(nil)
        end
    end

    exit_item.SaveFunc = function(self)
        return {AssignedLevelName = self.ItemState.AssignedLevelName}
    end

    exit_item.LoadFunc = function(self, data)
        if data.AssignedLevelName then
            print(string.format("ExitLuaItem.LoadFunc: loading exit '%s' with saved level '%s'", self.Name, data.AssignedLevelName))
            self.ItemState.AssignedLevelName = data.AssignedLevelName
            exit:Assign(LEVEL_BY_NAME[data.AssignedLevelName])
        end
    end

    return exit_item
end

---Creates a LuaItem for the level.
---@param level Level
function CreateLevelItem(level)
    local level_item = ScriptHost:CreateLuaItem()
    level_item.Name = level.Name
    level_item.Icon = ImageReference:FromPackRelativePath(level.Icon)
    level_item.ItemState = {}
    level_item:SetOverlayAlign("left")

    level_item.CanProvideCodeFunc = function(self, code)
        return code == self.Name
    end

    level_item.ProvidesCodeFunc = function(self, code)
        if self:CanProvideCodeFunc(code) and level.Exit then
            return true
        end
        return false
    end

    level_item.OnLeftClickFunc = function(self)
        if level.Exit then
            -- Already assigned an origin exit, assignment can be cleared with right click.
            return
        elseif level:IsSelected() then
            -- Deselect the level because it was left clicked twice.
            Level.Select(nil)
        else
            local exit = Exit.SelectedExit
            if exit then
                -- Assign the left clicked level to the selected exit.
                exit:Assign(level)
            else
                -- Select the left clicked level.
                Level.Select(level)
            end
        end
    end

    level_item.OnRightClickFunc = function(self)
        if level.Exit then
            -- Unassign the level and its origin exit.
            level.Exit:Assign(nil)
        elseif level:IsSelected() then
            -- Deselect the level.
            Level.Select(nil)
        end
    end

    return level_item
end

local function createLuaItems()
    for _, exit in pairs(EXIT_BY_NAME) do
        CreateExitItem(exit)
    end
    for _, level in pairs(LEVEL_BY_NAME) do
        CreateLevelItem(level)
    end
end

createLuaItems()