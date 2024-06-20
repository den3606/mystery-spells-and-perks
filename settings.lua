dofile("data/scripts/lib/mod_settings.lua") -- see this file for documentation on some of the features.

local mod_id = "mystery_spells_and_perks"   -- This should match the name of your mod's folder.
mod_settings_version = 5                    -- This is a magic global that can be used to migrate settings to new mod versions. call mod_settings_get_version() before mod_settings_update() to get the old value.

local function language()
  local current_language = GameTextGet("$current_language")
  if current_language == "English" then
    return 'en'
  end
  if current_language == "русский" then
    return 'ru'
  end
  if current_language == "Português (Brasil)" then
    return 'pt-br'
  end
  if current_language == "Español" then
    return 'es-es'
  end
  if current_language == "Deutsch" then
    return 'de'
  end
  if current_language == "Français" then
    return 'fr-fr'
  end
  if current_language == "Italiano" then
    return 'it'
  end
  if current_language == "Polska" then
    return 'pl'
  end
  if current_language == "简体中文" then
    return 'zh-cn'
  end
  if current_language == "日本語" then
    return 'ja'
  end
  if current_language == "한국어" then
    return 'ko'
  end

  return 'en'
end

local settings_text = {
  spell_editor_shortcut_key = {
    ui_name = {
      en = "Spell Editor Shortcut Key",
      ja = "呪文エディタショートカットキー",

    },
    ui_description = {
      en = "Input shortcut key(a-z0-9)",
      ja = "ショートカットキーを入力してください(a-z0-9)",
    },
  },
  perk_editor_shortcut_key = {
    ui_name = {
      en = "Perk Editor Shortcut Key",
      ja = "呪文エディタショートカットキー",
    },
    ui_description = {
      en = "Input shortcut key(a-z0-9)",
      ja = "ショートカットキーを入力してください(a-z0-9)",
    },
  },
  show_answers_when_the_game_is_cleared = {
    ui_name = {
      en = "The answer will be given when the game is completed",
      ja = "ゲームクリア時に答え合わせをする",
    },
    ui_description = {
      en = "Hidden spells/perks are forced to be displayed",
      ja = "隠された呪文と特典が表示されます",
    },
  },
  mystify_spells = {
    ui_name = {
      en = "Spell will be made into a mystery",
      ja = "呪文をシークレットにする",
    },
    ui_description = {
      en = "Mystify the Spells",
      ja = "呪文のシークレット化",
    },
  },
  mystify_perks = {
    ui_name = {
      en = "Park will be made into a mystery",
      ja = "特典をシークレットにする",
    },
    ui_description = {
      en = "Mystify the Parks",
      ja = "特典のシークレット化",
    },
  },
  automatics = {
    ui_name = {
      en = "Automatic memo",
      ja = "呪文の登録自動化",
    },
    ui_description = {
      en = "Automatically memos when a spell is triggered",
      ja = "呪文発射時に呪文の登録を行います",
    },
  },
  automatic_memo_projectile = {
    ui_name = {
      en = "Automatic Memo Projectile",
      ja = "放射物を自動登録する",
    },
  },
  automatic_memo_static_projectile = {
    ui_name = {
      en = "Automatic Memo Static Projectile",
      ja = "静電放射物を自動登録する",
    },
  },
  automatic_memo_modifier = {
    ui_name = {
      en = "Automatic Memo Modifier",
      ja = "調整盤を自動登録する",
    },
  },
  automatic_memo_draw_many = {
    ui_name = {
      en = "Automatic Memo Draw many",
      ja = "マルチキャストを自動登録する",
    },
  },
  automatic_memo_material = {
    ui_name = {
      en = "Automatic Memo Material",
      ja = "資材を自動登録する",
    },
  },
  automatic_memo_other = {
    ui_name = {
      en = "Automatic Memo Other",
      ja = "その他を自動登録する",
    },
  },
  automatic_memo_utility = {
    ui_name = {
      en = "Automatic Memo Utility",
      ja = "ユーティリティーを自動登録する",
    },
  },
  automatic_memo_passive = {
    ui_name = {
      en = "Automatic Memo Passive",
      ja = "受け身を自動登録する",
    },
  },
  automatic_memo_recommended =
  {
    ui_name = {
      en = "==Recommended Setting==\n" ..
          "Automatic Memo Projectile => On\n" ..
          "Automatic Memo Static Projectile => On\n" ..
          "Automatic Memo Modifier => Off\n" ..
          "Automatic Memo Draw many => Off\n" ..
          "Automatic Memo Material => Off\n" ..
          "Automatic Memo Other => Off\n" ..
          "Automatic Memo Utility => Off\n" ..
          "Automatic Memo Passive => On\n",
      ja = "==おすすめの設定==\n" ..
          "放射物を自動登録するか => オン\n" ..
          "静電放射物を自動登録するか => オン\n" ..
          "調整盤を自動登録するか => オフ\n" ..
          "マルチキャストを自動登録するか => オフ\n" ..
          "資材を自動登録するか => オフ\n" ..
          "その他を自動登録するか => オフ\n" ..
          "ユーティリティを自動登録するか => オフ\n" ..
          "受け身を自動登録するか => オン\n",
    }
  },
}


mod_settings = {
  {
    id = "spell_editor_shortcut_key",
    ui_name = settings_text.spell_editor_shortcut_key.ui_name[language()],
    ui_description = settings_text.spell_editor_shortcut_key.ui_description[language()],
    value_default = "",
    text_max_length = 1,
    allowed_characters = "abcdefghijklmnopqrstuvwxyz0123456789",
    scope = MOD_SETTING_SCOPE_RUNTIME,
  },
  {
    id = "perk_editor_shortcut_key",
    ui_name = settings_text.perk_editor_shortcut_key.ui_name[language()],
    ui_description = settings_text.perk_editor_shortcut_key.ui_description[language()],
    value_default = "",
    text_max_length = 1,
    allowed_characters = "abcdefghijklmnopqrstuvwxyz0123456789",
    scope = MOD_SETTING_SCOPE_RUNTIME,
  },
  {
    id = "show_answers_when_the_game_is_cleared",
    ui_name = settings_text.show_answers_when_the_game_is_cleared.ui_name[language()],
    ui_description = settings_text.show_answers_when_the_game_is_cleared.ui_description[language()],
    value_default = true,
    scope = MOD_SETTING_SCOPE_RUNTIME,
  },
  {
    id = "mystify_spells",
    ui_name = settings_text.mystify_spells.ui_name[language()],
    ui_description = settings_text.mystify_spells.ui_description[language()],
    value_default = true,
    scope = MOD_SETTING_SCOPE_RUNTIME,
  },
  {
    id = "mystify_perks",
    ui_name = settings_text.mystify_perks.ui_name[language()],
    ui_description = settings_text.mystify_perks.ui_description[language()],
    value_default = true,
    scope = MOD_SETTING_SCOPE_RUNTIME,
  },
  {
    category_id = "automatics",
    ui_name = settings_text.automatics.ui_name[language()],
    ui_description = settings_text.automatics.ui_description[language()],
    foldable = true,
    _folded = false,
    settings =
    {
      {
        id = "automatic_memo_projectile",
        ui_name = settings_text.automatic_memo_projectile.ui_name[language()],
        value_default = true,
        scope = MOD_SETTING_SCOPE_RUNTIME,
      },
      {
        id = "automatic_memo_static_projectile",
        ui_name = settings_text.automatic_memo_static_projectile.ui_name[language()],
        value_default = true,
        scope = MOD_SETTING_SCOPE_RUNTIME,
      },
      {
        id = "automatic_memo_modifier",
        ui_name = settings_text.automatic_memo_modifier.ui_name[language()],
        value_default = false,
        scope = MOD_SETTING_SCOPE_RUNTIME,
      },
      {
        id = "automatic_memo_draw_many",
        ui_name = settings_text.automatic_memo_draw_many.ui_name[language()],
        value_default = false,
        scope = MOD_SETTING_SCOPE_RUNTIME,
      },
      {
        id = "automatic_memo_material",
        ui_name = settings_text.automatic_memo_material.ui_name[language()],
        value_default = false,
        scope = MOD_SETTING_SCOPE_RUNTIME,
      },
      {
        id = "automatic_memo_other",
        ui_name = settings_text.automatic_memo_other.ui_name[language()],
        value_default = false,
        scope = MOD_SETTING_SCOPE_RUNTIME,
      },
      {
        id = "automatic_memo_utility",
        ui_name = settings_text.automatic_memo_utility.ui_name[language()],
        value_default = false,
        scope = MOD_SETTING_SCOPE_RUNTIME,
      },
      {
        id = "automatic_memo_passive",
        ui_name = settings_text.automatic_memo_passive.ui_name[language()],
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
        ui_name = settings_text.automatic_memo_recommended.ui_name[language()],
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
