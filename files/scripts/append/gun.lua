local VALUES = dofile_once("mods/mystery-spells-and-perks/files/scripts/variables.lua")
local original_play_action = play_action
-- ACTION_TYPE_PROJECTILE	= 0
-- ACTION_TYPE_STATIC_PROJECTILE = 1
-- ACTION_TYPE_MODIFIER	= 2
-- ACTION_TYPE_DRAW_MANY	= 3
-- ACTION_TYPE_MATERIAL	= 4
-- ACTION_TYPE_OTHER		= 5
-- ACTION_TYPE_UTILITY		= 6
-- ACTION_TYPE_PASSIVE		= 7

function play_action(action)
  original_play_action(action)

  local automatic_memo_projectile = ModSettingGet(
    'mystery_spells_and_perks.automatic_memo_projectile') or false
  local automatic_memo_static_projectile = ModSettingGet(
    'mystery_spells_and_perks.automatic_memo_static_projectile') or false
  local automatic_memo_modifier = ModSettingGet('mystery_spells_and_perks.automatic_memo_modifier') or
      false
  local automatic_memo_draw_many = ModSettingGet('mystery_spells_and_perks.automatic_memo_draw_many') or
      false
  local automatic_memo_material = ModSettingGet('mystery_spells_and_perks.automatic_memo_material') or
      false
  local automatic_memo_other = ModSettingGet('mystery_spells_and_perks.automatic_memo_other') or
      false
  local automatic_memo_utility = ModSettingGet('mystery_spells_and_perks.automatic_memo_utility') or
      false
  local automatic_memo_passive = ModSettingGet('mystery_spells_and_perks.automatic_memo_passive') or
      false

  local need_automatic_memo_list = {
    automatic_memo_projectile,
    automatic_memo_static_projectile,
    automatic_memo_modifier,
    automatic_memo_draw_many,
    automatic_memo_material,
    automatic_memo_other,
    automatic_memo_utility,
    automatic_memo_passive,
  }

  for i = 1, #need_automatic_memo_list, 1 do
    local action_type_num = i - 1
    if action_type_num == action.type and need_automatic_memo_list[i] then
      GlobalsSetValue(VALUES.GLOBAL_WAND_FIREED_SPELL_PREFIX_KEY .. action.id, "true")
    end
    if action_type_num == action.type and need_automatic_memo_list[i] then
      GlobalsSetValue(VALUES.GLOBAL_WAND_FIREED_SPELL_PREFIX_KEY .. action.id, "true")
    end
    if action_type_num == action.type and need_automatic_memo_list[i] then
      GlobalsSetValue(VALUES.GLOBAL_WAND_FIREED_SPELL_PREFIX_KEY .. action.id, "true")
    end
    if action_type_num == action.type and need_automatic_memo_list[i] then
      GlobalsSetValue(VALUES.GLOBAL_WAND_FIREED_SPELL_PREFIX_KEY .. action.id, "true")
    end
    if action_type_num == action.type and need_automatic_memo_list[i] then
      GlobalsSetValue(VALUES.GLOBAL_WAND_FIREED_SPELL_PREFIX_KEY .. action.id, "true")
    end
    if action_type_num == action.type and need_automatic_memo_list[i] then
      GlobalsSetValue(VALUES.GLOBAL_WAND_FIREED_SPELL_PREFIX_KEY .. action.id, "true")
    end
    if action_type_num == action.type and need_automatic_memo_list[i] then
      GlobalsSetValue(VALUES.GLOBAL_WAND_FIREED_SPELL_PREFIX_KEY .. action.id, "true")
    end
    if action_type_num == action.type and need_automatic_memo_list[i] then
      GlobalsSetValue(VALUES.GLOBAL_WAND_FIREED_SPELL_PREFIX_KEY .. action.id, "true")
    end
  end
end
