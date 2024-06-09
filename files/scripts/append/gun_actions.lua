local VALUES = dofile_once("mods/mystery-spells-and-perks/files/scripts/variables.lua")
local custom_name = dofile_once("mods/mystery-spells-and-perks/files/scripts/custom_spell_name.lua")

local secret_spell = {
  id = "MYSTERY_SECRET_SPELL",
  description = "$actiondesc_mystery_secret_spell",
  sprite = "mods/mystery-spells-and-perks/files/ui_gfx/secret_spell_icon.png",
  sprite_unidentified = "mods/mystery-spells-and-perks/files/ui_gfx/secret_spell_icon.png",
  type = ACTION_TYPE_OTHER,
  spawn_level = "100",
  spawn_probability = "0",
  price = 0,
  mana = 0,
}

for i = 1, #actions do
  local original_sprite = actions[i].sprite

  actions[i].original_sprite = original_sprite
  actions[i].sprite = secret_spell.sprite
  actions[i].name = custom_name.get()
  actions[i].description = secret_spell.description
  -- NOTE:Typeも隠すと、杖生成のときにタイプで判断しているのでスペルが取得できなくなる
  -- actions[i].type = (function()
  --   if GameHasFlagRun(VALUES.IS_GAME_START) then
  --     return original_type
  --   else
  --     return secret_spell.type
  --   end
  -- end)()
  actions[i].action = function()
    if GameHasFlagRun(VALUES.IS_GAME_START) then
      actions[i].original_action()
    end
  end
  -- TODO: Option
  -- actions[i].mana = secret_spell.mana
end
