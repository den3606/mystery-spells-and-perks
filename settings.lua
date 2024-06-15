dofile("data/scripts/lib/mod_settings.lua") -- see this file for documentation on some of the features.

local mod_id = "mystery_spells_and_perks"   -- This should match the name of your mod's folder.
mod_settings_version = 1                    -- This is a magic global that can be used to migrate settings to new mod versions. call mod_settings_get_version() before mod_settings_update() to get the old value.
mod_settings = {
  {
    id = "mystify_perks",
    ui_name = "Park will be made into a mystery",
    ui_description = "Mystify the Parks",
    value_default = false,
    scope = MOD_SETTING_SCOPE_NEW_GAME,
  },
  {
    category_id = "automatics",
    ui_name = "Automatic memo",
    ui_description = "Automatically memos when a spell is triggered",
    foldable = true,
    _folded = false,
    settings = {
      {
        id = "automatic_memo_type",
        ui_name = "Memo type",
        value_default = "only_spells",
        values = { { "none", "none" }, { "only_spells", "Only Spells" }, { "all", "All" } },
        scope = MOD_SETTING_SCOPE_RUNTIME,
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
