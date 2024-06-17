local mystify_perks = ModSettingGet('mystery_spells_and_perks.mystify_perks') or false

if not mystify_perks then
  return
end

SetRandomSeed(1, 2)

local custom_names = {}

local function get_custom_name()
  if next(custom_names) == nil then
    custom_names = dofile("mods/mystery-spells-and-perks/files/scripts/custom_perk_name.lua")
  end

  local index = Random(1, #custom_names)
  local random_name = custom_names[index]
  table.remove(custom_names, index)
  return random_name
end

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
  perk_list[i].ui_name = get_custom_name()
  perk_list[i].ui_description = secret_perk.ui_description
  perk_list[i].ui_icon = secret_perk.ui_icon
  perk_list[i].perk_icon = secret_perk.perk_icon
end
