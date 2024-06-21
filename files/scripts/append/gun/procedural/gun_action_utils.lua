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

-- 杖に常時詠唱を追加する処理のHOOK
local OriginalAddGunActionPermanent = AddGunActionPermanent
function AddGunActionPermanent(entity_id, action_id)
  OriginalAddGunActionPermanent(entity_id, action_id)
  local card_entity_ids = EntityGetAllChildren(entity_id) or {}
  local added_card = card_entity_ids[#card_entity_ids]

  if EntityHasTag(added_card, "mystery-spells-and-perks-updated-spell") then
    return
  end
  update_spell(added_card)
  EntityAddTag(added_card, "mystery-spells-and-perks-updated-spell")
end

-- 杖に呪文を追加を追加する処理のHOOK
local OriginalAddGunAction = AddGunAction
function AddGunAction(entity_id, action_id)
  OriginalAddGunAction(entity_id, action_id)
  local card_entity_ids = EntityGetAllChildren(entity_id) or {}
  local added_card = card_entity_ids[#card_entity_ids]

  if EntityHasTag(added_card, "mystery-spells-and-perks-updated-spell") then
    return
  end
  update_spell(added_card)
  EntityAddTag(added_card, "mystery-spells-and-perks-updated-spell")
end
