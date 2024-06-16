-- TODO:敵がパークを取ったときに、現状の特典リストの状態で上書きする
function give_perk_to_enemy(perk_data, entity_who_picked, entity_item)
  -- fetch perk info ---------------------------------------------------

  local pos_x, pos_y = EntityGetTransform(entity_who_picked)

  local perk_id = perk_data.id

  -- add game effect
  if perk_data.game_effect ~= nil then
    local game_effect_comp = GetGameEffectLoadTo(entity_who_picked, perk_data.game_effect, true)
    if game_effect_comp ~= nil then
      ComponentSetValue(game_effect_comp, "frames", "-1")
    end
  end

  if perk_data.func_enemy ~= nil then
    perk_data.func_enemy(entity_item, entity_who_picked)
  elseif perk_data.func ~= nil then
    perk_data.func(entity_item, entity_who_picked)
  end

  -- add ui icon etc
  local entity_icon = EntityLoad("data/entities/misc/perks/enemy_icon.xml", pos_x, pos_y)
  edit_component(entity_icon, "SpriteComponent", function(comp, vars)
    ComponentSetValue(comp, "image_file", perk_data.ui_icon)
  end)
  EntityAddChild(entity_who_picked, entity_icon)
end
