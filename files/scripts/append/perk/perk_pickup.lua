dofile_once("mods/mystery-spells-and-perks/files/scripts/lib/utilities.lua")
local Json = dofile_once("mods/mystery-spells-and-perks/files/scripts/lib/jsonlua/json.lua")
local VALUES = dofile_once("mods/mystery-spells-and-perks/files/scripts/variables.lua")

-- NOTE:PERK_IDを起点に元のパークとの照らし合わせをするため、
-- PerkのEntityにPERK_IDを入れる
local original_perk_pickup = perk_pickup
function perk_pickup(entity_item, entity_who_picked, item_name, do_cosmetic_fx, kill_other_perks,
                     no_perk_entity_)
  original_perk_pickup(entity_item, entity_who_picked, item_name, do_cosmetic_fx, kill_other_perks,
    no_perk_entity_)

  local perk_id = ""
  if no_perk_entity then
    perk_id = item_name
  else
    edit_component(entity_item, "VariableStorageComponent", function(comp, vars)
      perk_id = ComponentGetValue(comp, "value_string")
    end)
  end

  local perk_entity_ids = EntityGetAllChildren(entity_who_picked)
  if perk_entity_ids == nil then
    return
  end

  local newer_perk_entity_id = perk_entity_ids[#perk_entity_ids]

  local ui_icon_compoennt_id = EntityGetFirstComponentIncludingDisabled(newer_perk_entity_id, "UIIconComponent")

  if ui_icon_compoennt_id then
    -- 所持するパークにperk_idを付与する
    AddNewInternalVariable(newer_perk_entity_id, "perk_id", "value_string", perk_id)

    EntityAddTag(newer_perk_entity_id, "mystery-spells-and-perks.perk_icon_entity")

    -- 所持するパークを最新状態に上書きする
    local json = GlobalsGetValue(VALUES.GLOBAL_PERK_PREFIX_KEY .. perk_id, "")

    if json == "" or json == nil then
      return
    end

    local customized_perk = Json.decode(string.gsub(json, "'", '"'))

    if customized_perk then
      ComponentSetValue2(ui_icon_compoennt_id, "description", customized_perk.ui_description)
      ComponentSetValue2(ui_icon_compoennt_id, "icon_sprite_file", customized_perk.ui_icon)
    end
  else
    print_error("ERROR: " .. perk_id .. " icon information couldn't be retrieved.")
  end
end
