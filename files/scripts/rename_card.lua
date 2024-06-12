local VALUES = dofile_once("mods/mystery-spells-and-perks/files/scripts/variables.lua")
local Json = dofile_once("mods/mystery-spells-and-perks/files/scripts/lib/jsonlua/json.lua")
-- カード生成時にカード情報を書き換える

local entity_id = GetUpdatedEntityID()

local item_action_component_id = EntityGetFirstComponentIncludingDisabled(
  entity_id, "ItemActionComponent"
)
if not item_action_component_id then
  print('return')
  return
end

local action_id = ComponentGetValue2(item_action_component_id, "action_id")

if action_id == nil or action_id == "" then
  print('return (action_id is empty)')
  return
end

local function rename_spell_entity(action_name, action_sprite)
  print('rename to: ' .. action_name)
  print('action_sprite to: ' .. action_sprite)
  -- 物理判定があるスペルの名称上書き
  local ability_component_id = EntityGetFirstComponentIncludingDisabled(
    entity_id, "AbilityComponent"
  )
  if ability_component_id then
    ComponentSetValue2(ability_component_id, "ui_name", action_name)
  end

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
    ComponentSetValue2(item_comp, "item_name", action_name)
  end
end

print(VALUES.GLOBAL_SPELL_PREFIX_KEY .. action_id)
local customized_action_json = GlobalsGetValue(
  VALUES.GLOBAL_SPELL_PREFIX_KEY .. action_id, ""
)
print(customized_action_json)
if customized_action_json == "" then
  dofile_once('data/scripts/gun/gun_actions.lua')
  for _, action in ipairs(actions) do
    if action.name then
      if action_id == action.id then
        rename_spell_entity(action.name, action.sprite)
      end
    end
  end
else
  local customized_action_json = GlobalsGetValue(
    VALUES.GLOBAL_SPELL_PREFIX_KEY .. action_id, ""
  )
  local customized_action = Json.decode(customized_action_json)
  if action_id == customized_action.id then
    rename_spell_entity(customized_action.name, customized_action.sprite)
  end
end
