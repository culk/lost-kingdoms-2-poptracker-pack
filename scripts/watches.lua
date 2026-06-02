Archipelago:AddClearHandler("clear handler", onClear)
Archipelago:AddItemHandler("item handler", onItem)
Archipelago:AddLocationHandler("location handler", onLocation)

Archipelago:AddSetReplyHandler("notify handler", OnNotify)
Archipelago:AddRetrievedHandler("notify launch handler", OnNotifyLaunch)

-- Code watches for settings to show/hide portions of the item tracker layout
ScriptHost:AddWatchForCode("fairysanity", "fairysanity", ToggleItems)
ScriptHost:AddWatchForCode("progressive_leveling", "progressive_leveling", ToggleItems)
ScriptHost:AddWatchForCode("progressive_attribute_proficiencies", "progressive_attribute_proficiencies", ToggleItems)

ScriptHost:AddOnFrameHandler("tracker_layout_update", UpdateLayout)