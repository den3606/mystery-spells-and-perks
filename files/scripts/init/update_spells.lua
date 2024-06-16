local VALUES = dofile_once("mods/mystery-spells-and-perks/files/scripts/variables.lua")
local Json = dofile_once("mods/mystery-spells-and-perks/files/scripts/lib/jsonlua/json.lua")

local function replace_spell_entity(entity_id, action_sprite)
  -- スプライト画像書き換え
  local sprite_component_id = EntityGetFirstComponentIncludingDisabled(entity_id,
    "SpriteComponent",
    "item_identified")
  if sprite_component_id then
    ComponentSetValue2(sprite_component_id, "image_file", action_sprite)
  end

  -- Item化時の画像/名前書き換え
  local item_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "ItemComponent")
  if item_comp ~= nil then
    ComponentSetValue2(item_comp, "ui_sprite", action_sprite)
  end

  EntityRemoveTag(entity_id, "mystery_spells_need_init")
end

local function update_spell_if_needed()
  local json = ModSettingGet(VALUES.NEED_UPDATE_SPELL_ENTITIES) or "{}"
  local card_entity_ids = Json.decode(json)

  for index, card_entity_id in ipairs(card_entity_ids) do
    local item_action_component_id = EntityGetFirstComponentIncludingDisabled(
      card_entity_id, "ItemActionComponent"
    )
    if item_action_component_id ~= nil then
      local action_id = ComponentGetValue2(item_action_component_id, "action_id")
      local customized_action_json = GlobalsGetValue(
        VALUES.GLOBAL_SPELL_PREFIX_KEY .. action_id, ""
      )

      if customized_action_json ~= nil and customized_action_json ~= "" then
        local customized_action = Json.decode(string.gsub(customized_action_json, "'", '"'))
        replace_spell_entity(card_entity_id, customized_action.sprite)
        table.remove(card_entity_ids, index)
        ModSettingSet(VALUES.NEED_UPDATE_SPELL_ENTITIES, Json.encode(card_entity_ids))
      end
    end
  end
end

return {
  update_if_needed = update_spell_if_needed
}
