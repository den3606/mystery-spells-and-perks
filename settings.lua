dofile("data/scripts/lib/mod_settings.lua") -- see this file for documentation on some of the features.

local mod_id = "mystery_spells_and_perks"   -- This should match the name of your mod's folder.
mod_settings_version = 2                    -- This is a magic global that can be used to migrate settings to new mod versions. call mod_settings_get_version() before mod_settings_update() to get the old value.

mod_settings = {
  {
    id = "show_answers_when_the_game_is_cleared",
    ui_name = "The answer will be given when the game is completed(Only Spells)",
    ui_description = "Hidden items are forced to be displayed",
    value_default = true,
    scope = MOD_SETTING_SCOPE_RUNTIME,
  },
  {
    id = "mystify_perks",
    ui_name = "Park will be made into a mystery",
    ui_description = "Mystify the Parks",
    value_default = false,
    scope = MOD_SETTING_SCOPE_RUNTIME,
  },
  {
    category_id = "automatics",
    ui_name = "Automatic memo",
    ui_description = "Automatically memos when a spell is triggered",
    foldable = true,
    _folded = false,
    settings =
    {
      {
        id = "automatic_memo_projectile",
        ui_name = "Automatic Memo Projectile",
        value_default = true,
        scope = MOD_SETTING_SCOPE_RUNTIME,
      },
      {
        id = "automatic_memo_static_projectile",
        ui_name = "Automatic Memo Static Projectile",
        value_default = true,
        scope = MOD_SETTING_SCOPE_RUNTIME,
      },
      {
        id = "automatic_memo_modifier",
        ui_name = "Automatic Memo Modifier",
        value_default = false,
        scope = MOD_SETTING_SCOPE_RUNTIME,
      },
      {
        id = "automatic_memo_draw_many",
        ui_name = "Automatic Memo Draw many",
        value_default = false,
        scope = MOD_SETTING_SCOPE_RUNTIME,
      },
      {
        id = "automatic_memo_material",
        ui_name = "Automatic Memo Material",
        value_default = false,
        scope = MOD_SETTING_SCOPE_RUNTIME,
      },
      {
        id = "automatic_memo_other",
        ui_name = "Automatic Memo Other",
        value_default = false,
        scope = MOD_SETTING_SCOPE_RUNTIME,
      },
      {
        id = "automatic_memo_utility",
        ui_name = "Automatic Memo Utility",
        value_default = false,
        scope = MOD_SETTING_SCOPE_RUNTIME,
      },
      {
        id = "automatic_memo_passive",
        ui_name = "Automatic Memo Passive",
        value_default = true,
        scope = MOD_SETTING_SCOPE_RUNTIME,
      },
      {
        id = "space_summy",
        ui_name = " ",
        not_setting = true,
      },
      {
        id = "automatic_memo_recommended",
        ui_name = "Recommended setting is...\n" ..
            "Automatic Memo Projectile => On\n" ..
            "Automatic Memo Static Projectile => On\n" ..
            "Automatic Memo Modifier => Off\n" ..
            "Automatic Memo Draw many => Off\n" ..
            "Automatic Memo Material => Off\n" ..
            "Automatic Memo Other => Off\n" ..
            "Automatic Memo Utility => Off\n" ..
            "Automatic Memo Passive => On\n",
        not_setting = true,
      },
    }
  }
}

function ModSettingsUpdate(init_scope)
  local old_version = mod_settings_get_version(mod_id)
  mod_settings_update(mod_id, mod_settings, init_scope)
end

function ModSettingsGuiCount()
  return mod_settings_gui_count(mod_id, mod_settings)
end

function ModSettingsGui(gui, in_main_menu)
  mod_settings_gui(mod_id, mod_settings, gui, in_main_menu)
end
