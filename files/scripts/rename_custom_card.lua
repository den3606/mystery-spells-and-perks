local entity_id = GetUpdatedEntityID()

local item_action_component_id = EntityGetFirstComponentIncludingDisabled(
  entity_id, "ItemActionComponent"
)
if not item_action_component_id then
  return
end

local action_id = ComponentGetValue2(item_action_component_id, "action_id")
if not action_id then
  return
end

dofile_once('data/scripts/gun/gun_actions.lua')
for index, action in ipairs(actions) do
  if action.name then
    if action.id == action_id then
      local ability_component_id = EntityGetFirstComponentIncludingDisabled(
        entity_id, "AbilityComponent"
      )
      if ability_component_id then
        ComponentSetValue2(ability_component_id, "ui_name", action.name)
      end
    end
  end
end
