local secret_perk = {
  id = "MYSTERY_SECRET_PERK",
  ui_name = "$perk_mystery_secret_perk",
  ui_description = "$perkdesc_mystery_secret_perk",
  ui_icon = "mods/mystery-spells-and-perks/files/ui_gfx/secret_perk_icon.png",
  perk_icon = "mods/mystery-spells-and-perks/files/ui_gfx/secret_perk_icon.png",
  stackable = STACKABLE_NO,
  stackable_maximum = 0,
  max_in_perk_pool = 2,
  stackable_is_rare = false,
  usable_by_enemies = false,
}

local dummy_perk_icon_names = {
  'secret_perk_icon.png', 'secret_perk_icon_blue.png', 'secret_perk_icon_emerald.png', 'secret_perk_icon_green.png',
  'secret_perk_icon_light_blue.png', 'secret_perk_icon_orange.png', 'secret_perk_icon_perple.png', 'secret_perk_icon_pink.png',
  'secret_perk_icon_red.png'
}

local dummy_perks = {}

for index, name in ipairs(dummy_perk_icon_names) do
  local copy_secret_perk = {}
  for key, value in pairs(secret_perk) do
    copy_secret_perk[key] = value
  end

  copy_secret_perk['id'] = copy_secret_perk['id'] .. '_' .. index
  copy_secret_perk['ui_icon'] = "mods/mystery-spells-and-perks/files/ui_gfx/" .. name
  copy_secret_perk['perk_icon'] = "mods/mystery-spells-and-perks/files/ui_gfx/" .. name

  table.insert(dummy_perks, copy_secret_perk)
end

return dummy_perks
