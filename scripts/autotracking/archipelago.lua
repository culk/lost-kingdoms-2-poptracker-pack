require("scripts/autotracking/item_mapping")
require("scripts/autotracking/location_mapping")
require("scripts/autotracking/setting_mapping")

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

function preOnClear()
    PLAYER_ID = Archipelago.PlayerNumber or -1
	TEAM_NUMBER = Archipelago.TeamNumber or 0
    if Archipelago.PlayerNumber > -1 then
        if #ALL_LOCATIONS > 0 then
            ALL_LOCATIONS = {}
        end
        for _, value in pairs(Archipelago.MissingLocations) do
            table.insert(ALL_LOCATIONS, #ALL_LOCATIONS + 1, value)
        end

        for _, value in pairs(Archipelago.CheckedLocations) do
            table.insert(ALL_LOCATIONS, #ALL_LOCATIONS + 1, value)
        end
        HINTS_ID = "_read_hints_"..TEAM_NUMBER.."_"..PLAYER_ID
        Archipelago:SetNotify({HINTS_ID})
        Archipelago:Get({HINTS_ID})
    end
end

function onClear(slot_data)
    preOnClear()

    SLOT_DATA = slot_data
    print(string.format("onClear: Reading slot data:\n%s", dump_table(SLOT_DATA)))
    CUR_INDEX = -1

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
                    setting_obj.Active = SETTING_MAPPING[key].mapping[value]
                elseif setting_obj.Type == "consumable" then
                    setting_obj.AcquiredCount = value
                elseif setting_obj.Type == "progressive" then
                    setting_obj.CurrentStage = SETTING_MAPPING[key].mapping[value]
                end
            else
                print(string.format("onClear: could not find setting for code %s", SETTING_MAPPING[key].code))
            end
        end
    end

    PLAYER_ID = Archipelago.PlayerNumber or -1
    TEAM_NUMBER = Archipelago.TeamNumber or 0
    if Archipelago.PlayerNumber > -1 then
        if #ALL_LOCATIONS > 0 then
            ALL_LOCATIONS = {}
        end
        for _, value in pairs(Archipelago.MissingLocations) do
            table.insert(ALL_LOCATIONS, #ALL_LOCATIONS + 1, value)
        end

        for _, value in pairs(Archipelago.CheckedLocations) do
            table.insert(ALL_LOCATIONS, #ALL_LOCATIONS + 1, value)
        end

        HINTS_ID = "_read_hints_"..TEAM_NUMBER.."_"..PLAYER_ID
        Archipelago:SetNotify({HINTS_ID})
        Archipelago:Get({HINTS_ID})
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
        --print(string.format("onItem: could not find item mapping for id %s", item_id))
        return
    end
    for _, item_pair in pairs(item) do
        item_code = item_pair[1]
        item_type = item_pair[2]
        local item_obj = Tracker:FindObjectForCode(item_code)
        if item_obj then
            if item_obj.Type == "toggle" then
                -- print("toggle")
                item_obj.Active = true
            elseif item_obj.Type == "progressive" then
                -- print("progressive")
                if item_obj.Active == true then
                    item_obj.CurrentStage = item_obj.CurrentStage + 1
                else
                    item_obj.Active = true
                end
            elseif item_obj.Type == "consumable" then
                -- print("consumable")
                item_obj.AcquiredCount = item_obj.AcquiredCount + item_obj.Increment * (tonumber(item_pair[3]) or 1)
            elseif item_obj.Type == "progressive_toggle" then
                -- print("progressive_toggle")
                if item_obj.Active then
                    item_obj.CurrentStage = item_obj.CurrentStage + 1
                else
                    item_obj.Active = true
                end
            end
        else
            print(string.format("onItem: could not find object for code %s", item_code[1]))
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
        -- print(location, location_obj)
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
    print("OnNotify", key, value, old_value)
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
    end
end

function UpdateHints(locationID, status) -->
    if Highlight then
        -- print(locationID, status)
        local location_table = LOCATION_MAPPING[locationID]
        for _, location in ipairs(location_table) do
            if location:sub(1, 1) == "@" then
                local obj = Tracker:FindObjectForCode(location)

                if obj then
                    obj.Highlight = HIGHLIGHT_LEVEL[status]
                else
                    print(string.format("No object found for code: %s", location))
                end
            end
        end
    end
end