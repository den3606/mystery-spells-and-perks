local VALUES = dofile_once("mods/mystery-spells-and-perks/files/scripts/variables.lua")

function death(damage_type_bit_field, damage_message, entity_thats_responsible, drop_items)
  local need_force_update = ModSettingGet(
    "mystery_spells_and_perks.show_answers_when_the_game_is_cleared") or false
  if need_force_update then
    GamePrintImportant("$mystery_spells_and_perks.opening_up_the_mystery")
    GlobalsSetValue(VALUES.CHECK_ANSWERS, 'true')
  end
end
