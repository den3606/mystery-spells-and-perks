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

  local auto_setting = ModSettingGet('mystery_spells_and_perks.automatic_memo_type')
  if auto_setting == "only_spells" then
    if action.type == ACTION_TYPE_PROJECTILE then
      GlobalsSetValue(VALUES.GLOBAL_WAND_FIREED_SPELL_PREFIX_KEY .. action.id, "true")
      return
    end
  end

  if auto_setting == "all" then
    GlobalsSetValue(VALUES.GLOBAL_WAND_FIREED_SPELL_PREFIX_KEY .. action.id, "true")
  end
end
