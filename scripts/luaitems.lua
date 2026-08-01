require("scripts/levels/exit")
require("scripts/levels/level")

---Creates a LuaItem for the exit.
---@param exit Exit
---@return LuaItem
function CreateExitItem(exit)
    local exit_item = ScriptHost:CreateLuaItem()
    exit_item.Name = exit.Name
    exit_item.Icon = ImageReference:FromPackRelativePath(exit.Icon)
    exit_item.ItemState = {
        DefaultLevelName = exit.DefaultLevelName,
        RandomizedLevelName = nil,
    }
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
                exit:Assign(level, true)
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
        return {
            DefaultLevelName = self.ItemState.DefaultLevelName,
            RandomizedLevelName = self.ItemState.RandomizedLevelName,
        }
    end

    exit_item.LoadFunc = function(self, data)
        if data.DefaultLevelName then
            self.ItemState.DefaultLevelName = data.DefaultLevelName
            exit.DefaultLevelName = data.DefaultLevelName
        end
        if data.RandomizedLevelName then
            self.ItemState.RandomizedLevelName = data.RandomizedLevelName
            exit.RandomizedLevelName = data.RandomizedLevelName
        end
        if Tracker:FindObjectForCode("randomize_levels").CurrentStage == 0 then
            print(string.format("ExitLuaItem.LoadFunc: loading exit '%s' with default level '%s'", self.Name, exit.DefaultLevelName))
            exit:Assign(LEVEL_BY_NAME[exit.DefaultLevelName])
        elseif data.RandomizedLevelName then
            print(string.format("ExitLuaItem.LoadFunc: loading exit '%s' with saved level '%s'", self.Name, data.RandomizedLevelName))
            exit:Assign(LEVEL_BY_NAME[data.RandomizedLevelName])
        end
    end

    return exit_item
end

---Creates a LuaItem for the level.
---@param level Level
---@return LuaItem
function CreateLevelItem(level)
    local level_item = ScriptHost:CreateLuaItem()
    level_item.Name = level.Name
    level_item.Icon = ImageReference:FromPackRelativePath(level.Icon)
    level_item.ItemState = {} -- State is tracked by Exit LuaItems.
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
                exit:Assign(level, true)
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

---Creates a LuaItem to store pack state information that is useful when reloading the pack.
---@return LuaItem
function CreateSavedStateItem()
    local item = ScriptHost:CreateLuaItem()
    item.Name = "saved_state"
    item.ItemState = {SEED = 0}

    item.CanProvideCodeFunc = function(self, code)
        return code == self.Name
    end

    item.SaveFunc = function(self)
        return {SEED = self.ItemState.SEED}
    end

    item.LoadFunc = function(self, data)
        if data then
            self.ItemState.SEED = data.SEED
        end
    end

    return item
end

local function createLuaItems()
    CreateSavedStateItem()
    for _, exit in pairs(EXIT_BY_NAME) do
        CreateExitItem(exit)
    end
    for _, level in pairs(LEVEL_BY_NAME) do
        CreateLevelItem(level)
    end
end

createLuaItems()