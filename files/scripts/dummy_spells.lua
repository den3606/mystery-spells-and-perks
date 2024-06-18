local secret_spell = {
  id = "MYSTERY_SECRET_SPELL",
  description = "$actiondesc_mystery_secret_spell",
  sprite = "mods/mystery-spells-and-perks/files/ui_gfx/secret_spell_icon.png",
  sprite_unidentified = "mods/mystery-spells-and-perks/files/ui_gfx/secret_spell_icon.png",
  type = -1,
  spawn_level = "100",
  spawn_probability = "0",
  price = 0,
  mana = 0,
}

local dummy_spell_icon_names = {
  'secret_spell_icon.png', 'secret_spell_icon_blue.png', 'secret_spell_icon_emerald.png', 'secret_spell_icon_green.png',
  'secret_spell_icon_light_blue.png', 'secret_spell_icon_orange.png', 'secret_spell_icon_perple.png', 'secret_spell_icon_pink.png',
  'secret_spell_icon_red.png'
}

local dummy_spells = {}

for index, name in ipairs(dummy_spell_icon_names) do
  local copy_secret_spell = {}
  for key, value in pairs(secret_spell) do
    copy_secret_spell[key] = value
  end

  copy_secret_spell['id'] = copy_secret_spell['id'] .. '_' .. index
  copy_secret_spell['sprite'] = "mods/mystery-spells-and-perks/files/ui_gfx/" .. name
  copy_secret_spell['sprite_unidentified'] = "mods/mystery-spells-and-perks/files/ui_gfx/" .. name

  table.insert(dummy_spells, copy_secret_spell)
end

return dummy_spells
