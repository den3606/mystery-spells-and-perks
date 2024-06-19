dofile_once("mods/mystery-spells-and-perks/files/scripts/lib/utilities.lua")
local VALUES = dofile_once("mods/mystery-spells-and-perks/files/scripts/variables.lua")
local Json = dofile_once("mods/mystery-spells-and-perks/files/scripts/lib/jsonlua/json.lua")

local function find_customized_perk_or_not(perk_id)
  local json = GlobalsGetValue(VALUES.GLOBAL_PERK_PREFIX_KEY .. perk_id, "")
  if json == "" or json == nil then
    return nil
  end
  local customized_perk = Json.decode(string.gsub(json, "'", '"'))

  if customized_perk then
    return customized_perk
  end

  return nil
end

-- NOTE:生物に直接特典が付与されるケースは[director_helpers.lua / game_helpers.lua]の場所に記載してある
local original_perk_spawn = perk_spawn
function perk_spawn(x, y, perk_id, dont_remove_other_perks_)
  local perk_entity_id = original_perk_spawn(x, y, perk_id, dont_remove_other_perks_)

  if perk_entity_id == nil then
    return perk_entity_id
  end

  local customized_perk = find_customized_perk_or_not(perk_id)

  if customized_perk then
    -- スプライト画像書き換え
    local sprite_component_id = EntityGetFirstComponentIncludingDisabled(
      perk_entity_id, "SpriteComponent"
    )
    if sprite_component_id then
      ComponentSetValue2(sprite_component_id, "image_file", customized_perk.perk_icon)
    end
  end

  return perk_entity_id
end
