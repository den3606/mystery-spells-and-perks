local custom_name = dofile_once("mods/mystery-spells-and-perks/files/scripts/custom_perk_name.lua")

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

for i = 1, #perk_list do
  local original_func = perk_list[i].func

  perk_list[i].func = original_func
  perk_list[i].ui_name = custom_name.get()
  perk_list[i].ui_description = secret_perk.ui_description
  perk_list[i].ui_icon = secret_perk.ui_icon
  perk_list[i].perk_icon = secret_perk.perk_icon
end
