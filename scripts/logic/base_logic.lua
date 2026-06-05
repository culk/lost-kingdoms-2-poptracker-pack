-- Boolean functions, all return a boolean.

function TRUE()
    return true
end

function can_level_attributes()
    return Tracker:ProviderCountForCode("progressive_attribute_proficiencies") == 0
end

local code_for_attribute = {
    earth = "progressive_attribute_proficiency_earth",
    water = "progressive_attribute_proficiency_water",
    fire = "progressive_attribute_proficiency_fire",
    wood = "progressive_attribute_proficiency_wood",
    neutral = "progressive_attribute_proficiency_neutral",
    mech = "progressive_attribute_proficiency_mech"
}

function has_attribute(attribute)
    if can_level_attributes() then
        return 8
    end
    return Tracker:ProviderCountForCode(code_for_attribute[attribute])
end

-- Access functions, all return an AccessibilityLevel.

function can_fly()
    return ANY("baba_yaga", "birdman", "garuda", "wyvern", "pazuzu")
end

function can_high_jump()
    local unicorn_out_of_logic = AccessibilityLevel.None
    if Tracker:ProviderCountForCode("unicorn") > 0 then
        unicorn_out_of_logic = AccessibilityLevel.SequenceBreak
    end
    return ANY("hell_hound", unicorn_out_of_logic)
end

function can_long_jump()
    return ANY("cerberus", "centaur")
end

function can_jump()
    return ANY(can_high_jump(), can_long_jump())
end

function can_booster_jump()
    return ALL("magic_boosters", ANY("hell_hound", "cerberus", "centaur"))
end

function can_wall_break()
    local chariobot_out_of_logic = AccessibilityLevel.None
    if Tracker:ProviderCountForCode("chariobot") > 0 then
        chariobot_out_of_logic = AccessibilityLevel.SequenceBreak
    end
    return ALL("magic_boosters", ANY("stone_golem", chariobot_out_of_logic))
end

function can_ice_break()
    return ALL("magic_boosters", "stone_golem")
end

function can_reach_kendarie_green_door_chest()
    return ALL("green_key", ANY(can_fly(), "blue_key"))
end

function can_enter_level(level_name)
    local previous_exit = LEVEL_BY_NAME[level_name].Exit
    if not previous_exit then
        return AccessibilityLevel.None
    end

    local location = Tracker:FindObjectForCode(previous_exit.LocationRef)
    if not location then
        print("can_enter_level: failed to find location for ref", previous_exit.LocationRef)
        return AccessibilityLevel.None
    end

    return ALL(level_name, location.AccessibilityLevel)
end

function can_enter_royal_tower_lower()
    return can_enter_level("Alanjeh Castle")
end

function can_enter_royal_tower_middle()
    return ALL("god_of_destruction", can_enter_level("Alanjeh Castle"))
end

function can_enter_royal_tower_upper()
    return ALL("god_of_destruction", can_enter_level("Alanjeh Castle"))
end

function can_enter_sacred_battle_arena_1()
    return can_enter_level("Sacred Battle Arena 1")
end

function can_enter_sacred_battle_arena_2()
    local has_attribute_proficiency = AccessibilityLevel.Normal
    if Tracker:ProviderCountForCode("progressive_attribute_proficiencies") > 0 then
        has_attribute_proficiency = ALL(
            HAS("progressive_attribute_proficiency_earth", 6),
            HAS("progressive_attribute_proficiency_water", 6),
            HAS("progressive_attribute_proficiency_fire", 6),
            HAS("progressive_attribute_proficiency_wood", 6)
        )
    end
    return ALL(can_enter_level("Sacred Battle Arena 1"), has_attribute_proficiency)
end

function can_shop()
    return ANY(can_enter_level("Kadishu Shop"), can_enter_level("Grenfoel Cathedral Shop"))
end

function has_goal_red_fairies()
    local required_amount = Tracker:FindObjectForCode("red_fairies_goal_amount").AcquiredCount
    return HAS("red_fairy", required_amount)
end