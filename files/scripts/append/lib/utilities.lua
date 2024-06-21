local VALUES = dofile_once("mods/mystery-spells-and-perks/files/scripts/variables.lua")
local Json = dofile_once("mods/mystery-spells-and-perks/files/scripts/lib/jsonlua/json.lua")

local function replace_spell_entity_component(entity_id, action_sprite)
  -- スプライト画像書き換え
  local sprite_component_id = EntityGetFirstComponentIncludingDisabled(entity_id, "SpriteComponent", "item_identified")
  if sprite_component_id then
    ComponentSetValue2(sprite_component_id, "image_file", action_sprite)
  end

  -- Item化時の画像/名前書き換え
  local item_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "ItemComponent")
  if item_comp ~= nil then
    ComponentSetValue2(item_comp, "ui_sprite", action_sprite)
  end
end

local function update_spell(card_entity_id)
  EntityAddTag(card_entity_id, "mystery-spells-and-perks-updated-spell")
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
      replace_spell_entity_component(card_entity_id, customized_action.sprite)
    end
  end
end

-- 大抵の処理ではutilitiesを読んでいるので、utilitiesでカード作成のオーバーライドを行う
-- 杖にカードを入れる処理でも以下の処理を挟み込んでいるため、判定を行うためにtagを利用している
local OriginalCreateItemActionEntity = CreateItemActionEntity
function CreateItemActionEntity(action_id, x, y)
  local entity_id = OriginalCreateItemActionEntity(action_id, x, y)

  if EntityHasTag(entity_id, "mystery-spells-and-perks-updated-spell") then
    return entity_id
  end

  update_spell(entity_id)
  EntityAddTag(entity_id, "mystery-spells-and-perks-updated-spell")

  return entity_id
end
