require("scripts/autotracking/item_mapping")
require("scripts/autotracking/location_mapping")
require("scripts/autotracking/setting_mapping")
require("scripts/autotracking/tab_mapping")
require("scripts/luaitems")

CUR_INDEX = -1

ALL_LOCATIONS = {}
SLOT_DATA = {}

if Highlight then
    HIGHLIGHT_LEVEL= {
        [0] = Highlight.Unspecified,
        [10] = Highlight.NoPriority,
        [20] = Highlight.Avoid,
        [30] = Highlight.Priority,
        [40] = Highlight.None,
        [100] = Highlight.Unspecified, -- Filler
        [101] = Highlight.Priority,    -- Progression
        [102] = Highlight.NoPriority,  -- Useful
        [103] = Highlight.Priority,    -- Prog + Useful
        [104] = Highlight.Avoid,       -- Trap
        [105] = Highlight.Priority,    -- Prog + Trap
        [106] = Highlight.NoPriority,  -- Useful + Trap
        [107] = Highlight.Priority,    -- Prog + Useful + Trap
    }
end

function dump_table(o, depth)
    if depth == nil then
        depth = 0
    end
    if type(o) == 'table' then
        local tabs = ('\t'):rep(depth)
        local tabs2 = ('\t'):rep(depth + 1)
        local s = '{\n'
        for k, v in pairs(o) do
            if type(k) ~= 'number' then
                k = '"' .. k .. '"'
            end
            s = s .. tabs2 .. '[' .. k .. '] = ' .. dump_table(v, depth + 1) .. ',\n'
        end
        return s .. tabs .. '}'
    else
        return tostring(o)
    end
end

function onClear(slot_data)
    SLOT_DATA = slot_data
    print(string.format("onClear: Reading slot data:\n%s", dump_table(SLOT_DATA)))
    CUR_INDEX = -1
    SAVED_STATE = Tracker:FindObjectForCode("saved_state").ItemState

    -- Reset locations.
    for _, location_array in pairs(LOCATION_MAPPING) do
        for _, location in pairs(location_array) do
            if location then
                local location_obj = Tracker:FindObjectForCode(location)
                if location_obj then
                    if location:sub(1, 1) == "@" then
                        location_obj.AvailableChestCount = location_obj.ChestCount
                        if Highlight then
                            location_obj.Highlight = Highlight.None
                        end
                    else
                        location_obj.Active = false
                    end
                else
                    print(string.format("onClear: could not find location for code %s", location))
                end
            end
        end
    end

    -- Reset items.
    for _, item_array in pairs(ITEM_MAPPING) do
        for _, item_pair in pairs(item_array) do
            item_code = item_pair[1]
            item_type = item_pair[2]
            local item_obj = Tracker:FindObjectForCode(item_code)
            if item_obj then
                if item_obj.Type == "toggle" then
                    item_obj.Active = false
                elseif item_obj.Type == "progressive" then
                    item_obj.CurrentStage = 0
                elseif item_obj.Type == "consumable" then
                    if item_obj.MinCount then
                        item_obj.AcquiredCount = item_obj.MinCount
                    else
                        item_obj.AcquiredCount = 0
                    end
                elseif item_obj.Type == "progressive_toggle" then
                    item_obj.CurrentStage = 0
                    item_obj.Active = false
                end
            else
                print(string.format("onClear: could not find item for code %s", item_code))
            end
        end
    end

    -- Read settings from slot data.
    for key, value in pairs(SLOT_DATA) do
        if SETTING_MAPPING[key] then
            local setting_obj = Tracker:FindObjectForCode(SETTING_MAPPING[key].code)
            if setting_obj then
                if setting_obj.Type == "toggle" then
                    setting_obj.Active = SETTING_MAPPING[key].mapping[value] --[[@as boolean]]
                elseif setting_obj.Type == "consumable" then
                    setting_obj.AcquiredCount = value
                elseif setting_obj.Type == "progressive" then
                    setting_obj.CurrentStage = SETTING_MAPPING[key].mapping[value] --[[@as integer]]
                end
            else
                print(string.format("onClear: could not find setting for code %s", SETTING_MAPPING[key].code))
            end
        end
    end

    -- Force update of connection assignments if required.
    if SLOT_DATA["randomize_levels"] == 0 then
        -- Levels are not randomized, reassign all connections with the default mapping.
        for _, exit in pairs(EXIT_BY_NAME) do
            exit:Assign(nil)
        end
        for exit_name, level_name in pairs(DEFAULT_EXIT_MAPPING) do
            local exit = EXIT_BY_NAME[exit_name]
            exit:Assign(LEVEL_BY_NAME[level_name])
        end
    elseif SLOT_DATA["randomize_levels"] == 1 and SLOT_DATA["level_randomization_mapping"] ~= nil then
        -- Levels are randomized, reassign all connections using the randomized mapping.
        for _, exit in pairs(EXIT_BY_NAME) do
            exit:Assign(nil)
        end
        for exit_name, level_name in pairs(SLOT_DATA["level_randomization_mapping"]) do
            local exit = EXIT_BY_NAME[string.gsub(exit_name, ", ", " - ")]
            exit:Assign(LEVEL_BY_NAME[level_name], true)
        end
    elseif SLOT_DATA["Seed"] ~= SAVED_STATE.SEED then
        -- Connected slot has a different seed, unassign all connections.
        SAVED_STATE.SEED = SLOT_DATA["Seed"]
        for _, exit in pairs(EXIT_BY_NAME) do
            exit:Assign(nil)
        end
    end

    -- Subscribe to data storage changes.
    PLAYER_ID = Archipelago.PlayerNumber or -1
    TEAM_NUMBER = Archipelago.TeamNumber or 0
    if Archipelago.PlayerNumber > -1 then
        HINTS_ID = "_read_hints_"..TEAM_NUMBER.."_"..PLAYER_ID
        CLIENT_STATUS_ID = "_read_client_status_"..TEAM_NUMBER.."_"..PLAYER_ID
        Archipelago:SetNotify({HINTS_ID, CLIENT_STATUS_ID})
        Archipelago:Get({HINTS_ID, CLIENT_STATUS_ID})
    end
end

function onItem(index, item_id, item_name, player_number)
    if index <= CUR_INDEX then
        return
    end
    local is_local = player_number == Archipelago.PlayerNumber
    CUR_INDEX = index;
    local item = ITEM_MAPPING[item_id]
    if not item or not item[1] then
        return
    end
    for _, item_pair in pairs(item) do
        item_code = item_pair[1]
        item_type = item_pair[2]
        local item_obj = Tracker:FindObjectForCode(item_code)
        if item_obj then
            if item_obj.Type == "toggle" then
                item_obj.Active = true
            elseif item_obj.Type == "progressive" then
                if item_obj.Active == true then
                    item_obj.CurrentStage = item_obj.CurrentStage + 1
                else
                    item_obj.Active = true
                end
            elseif item_obj.Type == "consumable" then
                item_obj.AcquiredCount = item_obj.AcquiredCount + item_obj.Increment * (tonumber(item_pair[3]) or 1)
            elseif item_obj.Type == "progressive_toggle" then
                if item_obj.Active then
                    item_obj.CurrentStage = item_obj.CurrentStage + 1
                else
                    item_obj.Active = true
                end
            end
        else
            print(string.format("onItem: could not find object for code %s", item_code))
        end
    end
end

--called when a location gets cleared
function onLocation(location_id, location_name)
    local location_array = LOCATION_MAPPING[location_id]
    if not location_array or not location_array[1] then
        print(string.format("onLocation: could not find location mapping for id %s", location_id))
        return
    end

    for _, location in pairs(location_array) do
        local location_obj = Tracker:FindObjectForCode(location)
        if location_obj then
            if location:sub(1, 1) == "@" then
                location_obj.AvailableChestCount = location_obj.AvailableChestCount - 1
            else
                location_obj.Active = true
            end
        else
            print(string.format("onLocation: could not find location_object for code %s", location))
        end
    end
end

function OnNotify(key, value, old_value)
    if value ~= old_value and key == HINTS_ID then
        for _, hint in ipairs(value) do
            if hint.finding_player == Archipelago.PlayerNumber then
                if hint.status == 0 then
                    UpdateHints(hint.location, 100+hint.item_flags)
                else
                    UpdateHints(hint.location, hint.status)
                end
            end
        end
    elseif key == CLIENT_STATUS_ID then
        UpdateStatus(value)
    end
end

function OnNotifyLaunch(key, value)
    if key == HINTS_ID then
        for _, hint in ipairs(value) do
            if hint.finding_player == Archipelago.PlayerNumber then
                if hint.status == 0 then
                    UpdateHints(hint.location, 100+hint.item_flags)
                else
                    UpdateHints(hint.location, hint.status)
                end
            end
        end
    elseif key == CLIENT_STATUS_ID then
        UpdateStatus(value)
    end
end

function UpdateHints(locationID, status) -->
    if Highlight then
        local location_table = LOCATION_MAPPING[locationID]
        for _, location in ipairs(location_table) do
            if location:sub(1, 1) == "@" then
                local obj = Tracker:FindObjectForCode(location)

                if obj then
                    obj.Highlight = HIGHLIGHT_LEVEL[status]
                else
                    print(string.format("UpdateHints: No object found for code: %s", location))
                end
            end
        end
    end
end

function UpdateStatus(status)
    if status == Archipelago.ClientStatus.GOAL then
        print("UpdateStatus: goal achieved")
        onLocation(100000, "Goal - Defeat the God of Harmony")
        onLocation(100001, "Goal - Defeat the Emperor")
        onLocation(100002, "Goal - Collect Red Fairies")
    end
end

function OnBounce(json)
    local auto_tab_map_obj = Tracker:FindObjectForCode("auto_tab_map")
    if auto_tab_map_obj and auto_tab_map_obj.CurrentStage == 1 then
        if json ~= nil and json["data"] ~= nil then
            local data = json["data"]
            UpdateMap(data["level_id"])
        end
    end
end

function UpdateMap(level_id)
    local tabs = TAB_MAPPING[tostring(level_id)]
    if not tabs then
        print(string.format('UpdateMap: no tabs found for level_id %d', level_id))
        return
    end
    if tabs[1] == "Combos" and not Tracker:FindObjectForCode("combosanity").Active then
        -- Combos tab is hidden, show the Overworld instead.
        tabs = {"Overworld"}
    end
    print(string.format('UpdateMap: activating tabs "%s" for level_id %d', table.concat(tabs, "/"), level_id))
    for _, tab in ipairs(tabs) do
        Tracker:UiHint("ActivateTab", tab)
    end
end

EXITS_STALE = true

function ToggleRandomizeLevels()
    EXITS_STALE = true
end

function UpdateExits()
    if EXITS_STALE then
        local randomize_levels_stage = Tracker:FindObjectForCode("randomize_levels").CurrentStage
        print(string.format("UpdateExits: Updating level exit assignments, stage: %d", randomize_levels_stage))

        -- Clear all current assignments.
        for _, exit in pairs(EXIT_BY_NAME) do
            exit:Assign(nil)
        end
        if randomize_levels_stage == 0 then
            -- Assign all exits using their default mapping.
            for exit_name, level_name in pairs(DEFAULT_EXIT_MAPPING) do
                local exit = EXIT_BY_NAME[exit_name]
                exit:Assign(LEVEL_BY_NAME[level_name])
            end
        else
            -- Assign all exits to their randomized levels.
            for _, exit in pairs(EXIT_BY_NAME) do
                local randomized_level_name = exit.RandomizedLevelName
                if randomized_level_name then
                    exit:Assign(LEVEL_BY_NAME[randomized_level_name], true)
                end
            end
        end

        EXITS_STALE = false
    end
end

LAYOUT_STALE = true

function ToggleItems()
    LAYOUT_STALE = true
end

function UpdateLayoutKeyItems(show_red_fairies)
    if show_red_fairies then
        Tracker:AddLayouts("layouts/key_items/red_fairies_show.json")
    else
        Tracker:AddLayouts("layouts/key_items/red_fairies_hide.json")
    end
end

function UpdateLayoutLevels(show_player_levels, show_attributes)
    if show_player_levels or show_attributes then
        Tracker:AddLayouts("layouts/levels/group_show.json")
        if show_player_levels then
            Tracker:AddLayouts("layouts/levels/player_levels_show.json")
        else
            Tracker:AddLayouts("layouts/levels/player_levels_hide.json")
        end
        if show_attributes then
            Tracker:AddLayouts("layouts/levels/attributes_show.json")
        else
            Tracker:AddLayouts("layouts/levels/attributes_hide.json")
        end
    else
        Tracker:AddLayouts("layouts/levels/group_hide.json")
    end
end

function UpdateLayoutLevelUnlocks(show_level_unlocks)
    if show_level_unlocks then
        Tracker:AddLayouts("layouts/level_unlocks/group_show.json")
    else
        Tracker:AddLayouts("layouts/level_unlocks/group_hide.json")
    end
end

function UpdateLayoutMapTabs(show_combosanity, show_connections)
    if show_combosanity and show_connections then
        Tracker:AddLayouts("layouts/tabs/show_all.json")
    elseif show_combosanity then
        Tracker:AddLayouts("layouts/tabs/show_combos.json")
    elseif show_connections then
        Tracker:AddLayouts("layouts/tabs/show_connections.json")
    else
        Tracker:AddLayouts("layouts/tabs/show_minimal.json")
    end
end

function UpdateLayout()
    if LAYOUT_STALE then
        local show_red_fairies = Tracker:FindObjectForCode("fairysanity").Active
        local show_player_levels = Tracker:FindObjectForCode("progressive_leveling").Active
        local show_attributes = Tracker:FindObjectForCode("progressive_attribute_proficiencies").Active
        local show_combosanity = Tracker:FindObjectForCode("combosanity").Active
        local show_level_unlocks = Tracker:FindObjectForCode("level_unlocks_as_items").Active
        local show_connections = (
            not show_level_unlocks
            and Tracker:FindObjectForCode("randomize_levels").CurrentStage == 2
        )

        UpdateLayoutKeyItems(show_red_fairies)
        UpdateLayoutLevels(show_player_levels, show_attributes)
        UpdateLayoutLevelUnlocks(show_level_unlocks)
        UpdateLayoutMapTabs(show_combosanity, show_connections)

        LAYOUT_STALE = false
    end
end