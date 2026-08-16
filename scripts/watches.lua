Archipelago:AddClearHandler("clear handler", onClear)
Archipelago:AddItemHandler("item handler", onItem)
Archipelago:AddLocationHandler("location handler", onLocation)

Archipelago:AddSetReplyHandler("notify handler", OnNotify)
Archipelago:AddRetrievedHandler("notify launch handler", OnNotifyLaunch)
Archipelago:AddBouncedHandler("bounce handler", OnBounce)

-- Code watch for toggling randomized level connections
ScriptHost:AddWatchForCode("randomize_levels_assignments", "randomize_levels", ToggleRandomizeLevels)

ScriptHost:AddOnFrameHandler("tracker_exits_update", UpdateExits)

-- Code watches for settings to show/hide portions of the item tracker layout
ScriptHost:AddWatchForCode("fairysanity", "fairysanity", ToggleItems)
ScriptHost:AddWatchForCode("progressive_leveling", "progressive_leveling", ToggleItems)
ScriptHost:AddWatchForCode("progressive_attribute_proficiencies", "progressive_attribute_proficiencies", ToggleItems)
ScriptHost:AddWatchForCode("combosanity", "combosanity", ToggleItems)
ScriptHost:AddWatchForCode("randomize_levels", "randomize_levels", ToggleItems)
ScriptHost:AddWatchForCode("level_unlocks_as_items", "level_unlocks_as_items", ToggleItems)

ScriptHost:AddOnFrameHandler("tracker_layout_update", UpdateLayout)