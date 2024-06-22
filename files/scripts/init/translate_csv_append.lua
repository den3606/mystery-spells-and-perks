local function append_to_translate_csv()
  local original_content = ModTextFileGetContent("data/translations/common.csv")

  local mystery_spells_and_perks_content = ModTextFileGetContent(
    "mods/mystery-spells-and-perks/files/translations/common.csv")

  local mystery_spells_and_perks_perk_descriptions = ModTextFileGetContent(
    "mods/mystery-spells-and-perks/files/translations/dummy_description.csv")

  ModTextFileSetContent("data/translations/common.csv",
    original_content .. mystery_spells_and_perks_content .. mystery_spells_and_perks_perk_descriptions)
end

append_to_translate_csv()
