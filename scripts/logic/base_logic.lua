-- Boolean functions, all return a boolean.

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

function can_exit_noblemans_residence_2()
    return HAS("mysterious_key")
end

function can_exit_bhashea_high_road_3()
    return ANY(can_fly(), can_jump())
end

function can_exit_gromtull_desert_1()
    return HAS("black_liquid")
end

function can_exit_kendarie_fortress_1()
    return ALL("red_key", "blue_key")
end

function can_exit_runestone_caverns_upper_1()
    return HAS("stone_golem")
end

function can_exit_fossil_boneyard_1()
    return can_booster_jump()
end

function can_exit_plains_of_rowahl_1()
    return HAS("castle_gate_key")
end

function can_exit_krasheen_mountains_1()
    return can_fly()
end

-- TODO: update all below rules for randomized levels. Currently shows all levels accessible if randomized.
function can_enter_isamat_urbur()
    return ANY(can_exit_noblemans_residence_2(), "randomize_levels")
end

function can_enter_bhashea_castle()
    return ANY(can_exit_bhashea_high_road_3(), "randomize_levels")
end

function can_enter_fairy_house()
    return ANY(can_exit_gromtull_desert_1(), "randomize_levels")
end

function can_enter_runestone_caverns_upper()
    return ANY(can_exit_kendarie_fortress_1(), "randomize_levels")
end

function can_enter_runestone_caverns_lower()
    return ANY(ALL(can_exit_runestone_caverns_upper_1(), can_enter_runestone_caverns_upper()), "randomize_levels")
end

function can_enter_ruldo_forest()
    return ANY(ALL(can_exit_runestone_caverns_upper_1(), can_enter_runestone_caverns_upper()), "randomize_levels")
end

function can_enter_fossil_boneyard()
    return ANY(can_enter_ruldo_forest(), "randomize_levels")
end

function can_enter_sarvan()
    return ANY(ALL(can_exit_fossil_boneyard_1(), can_enter_fossil_boneyard()), "randomize_levels")
end

function can_enter_holzogh_town()
    return ANY(can_enter_sarvan(), "randomize_levels")
end

function can_enter_plains_of_rowahl()
    return ANY(can_enter_sarvan(), "randomize_levels")
end

function can_enter_alanjeh_castle()
    return ANY(ALL(can_exit_plains_of_rowahl_1(), can_enter_plains_of_rowahl()), "randomize_levels")
end

function can_enter_royal_tower_lower()
    return ANY(ALL(can_exit_plains_of_rowahl_1(), can_enter_plains_of_rowahl()), "randomize_levels")
end

function can_enter_royal_tower_middle()
    return ALL("god_of_destruction", can_enter_royal_tower_lower())
end

function can_enter_royal_tower_upper()
    return ALL("god_of_destruction", can_enter_royal_tower_lower())
end

function can_enter_sacred_battle_arena_1()
    return ANY(can_enter_ruldo_forest(), "randomize_levels")
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
    return ALL(can_enter_sacred_battle_arena_1(), has_attribute_proficiency)
end

function can_exit_holzogh_town_2()
    return can_enter_royal_tower_lower()
end

function can_enter_obenoix_gorge()
    return ANY(ALL(can_exit_holzogh_town_2(), can_enter_holzogh_town()), "randomize_levels")
end

function can_enter_krasheen_mountains()
    return ANY(can_enter_royal_tower_lower(), "randomize_levels")
end

function can_enter_grenfoel_cathedral()
    return ANY(ALL(can_exit_krasheen_mountains_1(), can_enter_krasheen_mountains()), "randomize_levels")
end

function can_enter_temple_of_sharacia()
    return ANY(can_enter_grenfoel_cathedral(), "randomize_levels")
end

function can_shop()
    return true
end

function has_goal_red_fairies()
    local required_amount = Tracker:FindObjectForCode("red_fairies_goal_amount").AcquiredCount
    return HAS("red_fairy", required_amount)
end