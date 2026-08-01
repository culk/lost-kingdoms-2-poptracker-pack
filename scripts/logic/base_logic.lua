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
    return ANY("hell_hound", "unicorn")
end

function can_jump()
    return ANY(can_high_jump(), "cerberus", "centaur")
end

function can_booster_jump()
    return ALL("magic_boosters", ANY("hell_hound", "cerberus", "centaur"))
end

function can_wall_break()
    return ALL(
        "magic_boosters",
        ANY(
            "stone_golem",
            ALL(AccessibilityLevel.SequenceBreak, "chariobot")
        )
    )
end

function can_ice_break()
    return ALL("magic_boosters", "stone_golem")
end

function can_reach_kendarie_mechapult()
    return ANY("blue_key", can_fly(), can_jump())
end

function can_reach_ruldo_flight_chest()
    return ANY(
        can_fly(),
        ALL(
            AccessibilityLevel.SequenceBreak,
            ANY("cerberus", "centaur", "unicorn")
        )
    )
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

function can_enter_proving_grounds()
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

local stationary_seal_activator_cards = {
    "mandragora",
    "vampire_bush",
    "catoblepas",
    "maelstrom",
    "great_turtle",
    "treant",
    "king_mandragora",
    --"will_o_wisp", -- short lifespan
    "evil_eye",
    "siren",
    "kitty_trap",
    --"rheebus", -- short lifespan
    "decoy_pillar",
    "earth_elemental",
    "water_elemental",
    "fire_elemental",
    "wood_elemental",
    "super_pumper",
    "global_bust",
    "myconid",
    "acidbot",
    "dark_treant",
    "coal_treant",
    --"gravity_pillar", -- short lifespan
    "mechapult",
    "matador",
    "claws-r-us",
    "fire_moray",
}

function can_reach_puzzle_chest()
    local count = 0
    for _, card in ipairs(stationary_seal_activator_cards) do
        if Tracker:FindObjectForCode(card).Active then
            count = count + 1
            if count > 2 then
                return AccessibilityLevel.Normal
            end
        end
    end
    if count > 0 and can_shop() then
        return AccessibilityLevel.SequenceBreak
    end
    return AccessibilityLevel.None
end

function has_goal_red_fairies()
    local required_amount = Tracker:FindObjectForCode("red_fairies_goal_amount").AcquiredCount
    return HAS("red_fairy", required_amount)
end

-- Boolean visibility functions for either/or checks.

function is_help_valkyrie_unchecked()
    return Tracker:FindObjectForCode("@Temple of Sharacia/Help Ashura/").AvailableChestCount ~= 0
end

function is_help_ashura_unchecked()
    return Tracker:FindObjectForCode("@Temple of Sharacia/Help Valkyrie/").AvailableChestCount ~= 0
end

function is_caged_chest_1_unchecked()
    return Tracker:FindObjectForCode("@Sarvan/Caged Chest 1/").AvailableChestCount ~= 0
end

function is_caged_chest_2_unchecked()
    return Tracker:FindObjectForCode("@Sarvan/Caged Chest 2/").AvailableChestCount ~= 0
end