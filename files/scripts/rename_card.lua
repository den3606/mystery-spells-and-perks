-- カード生成時にカード情報を書き換える

local entity_id = GetUpdatedEntityID()

local item_action_component_id = EntityGetFirstComponentIncludingDisabled(
  entity_id, "ItemActionComponent"
)
if not item_action_component_id then
  return
end

local action_id = ComponentGetValue2(item_action_component_id, "action_id")

if action_id == nil or action_id == "" then
  return
end

local function rename_spell_entity(entity_id, action_name, action_sprite)
  -- 物理判定があるスペルの名称上書き
  local ability_component_id = EntityGetFirstComponentIncludingDisabled(
    entity_id, "AbilityComponent"
  )
  if ability_component_id then
    ComponentSetValue2(ability_component_id, "ui_name", action_name)
  end
end


dofile_once('data/scripts/gun/gun_actions.lua')
for _, action in ipairs(actions) do
  if action.name then
    if action_id == action.id then
      rename_spell_entity(entity_id, action.name, action.sprite)
    end
  end
end
