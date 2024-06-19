dofile_once("data/scripts/gun/gun_enums.lua")
local keycodes = dofile_once("mods/mystery-spells-and-perks/files/scripts/gui/keycodes.lua")
local VALUES = dofile_once("mods/mystery-spells-and-perks/files/scripts/variables.lua")
local drawer = dofile_once("mods/mystery-spells-and-perks/files/scripts/gui/drawer.lua")
local Json = dofile_once("mods/mystery-spells-and-perks/files/scripts/lib/jsonlua/json.lua")
local dummy_spells = dofile_once("mods/mystery-spells-and-perks/files/scripts/dummy_spells.lua")

local type_translate_text_keys = {
  [0] = "$inventory_actiontype_projectile",
  [1] = "$inventory_actiontype_staticprojectile",
  [2] = "$inventory_actiontype_modifier",
  [3] = "$inventory_actiontype_drawmany",
  [4] = "$inventory_actiontype_material",
  [5] = "$inventory_actiontype_other",
  [6] = "$inventory_actiontype_utility",
  [7] = "$inventory_actiontype_passive",
}

local customized_actions = {}
local original_actions_by_types = {}
local selected_owned_spell = nil
local show_name_editor = false
local is_selected_wand_spell = false
local is_selected_bag_spell = false
local is_selected_field_spell = false
local is_selected_field_wands_spell = false
local load_customized_action = false


local function is_action_unlocked(action)
  if action then
    if action.spawn_requires_flag ~= nil then
      return HasFlagPersistent(action.spawn_requires_flag)
    end
  end
  return true
end

local function __load_original_actions_by_types()
  dofile_once("data/scripts/gun/gun_enums.lua")
  dofile('data/scripts/gun/gun_actions.lua')
  for _, action in pairs(actions) do
    if is_action_unlocked(action) then
      original_actions_by_types[action.type] = original_actions_by_types[action.type] or {}
      table.insert(original_actions_by_types[action.type], action);
    end
  end
end
__load_original_actions_by_types()

local function __load_customized_actions_if_not_called()
  if load_customized_action then
    return
  end

  dofile('data/scripts/gun/gun_actions.lua')
  for _, secret_action in ipairs(actions) do
    -- 既にRunで登録されているかを確認する
    local json = GlobalsGetValue(
      VALUES.GLOBAL_SPELL_PREFIX_KEY .. secret_action.id, "{}")
    local customized_action = Json.decode(string.gsub(json, "'", '"'))

    if customized_action.id then
      table.insert(customized_actions, customized_action)
    else
      local action_copy = {}
      for key, value in pairs(secret_action) do
        if type(value) ~= "function" then
          action_copy[key] = value
        end
      end
      table.insert(customized_actions, action_copy)
    end
  end

  load_customized_action = true
end

local function update_card(target_action, override_action)
  -- カスタマイズリストを更新する
  for _, customized_action in ipairs(customized_actions) do
    if target_action.id == customized_action.id then
      customized_action.sprite = override_action.sprite
      customized_action.description = override_action.description
      GlobalsSetValue(VALUES.GLOBAL_SPELL_PREFIX_KEY .. customized_action.id,
        string.gsub(Json.encode(customized_action), '"', "'"))
    end
  end

  -- フィールドにあるEntity化されたカードを更新する
  local card_entity_ids = EntityGetWithTag("card_action")
  for _, card_entity_id in ipairs(card_entity_ids) do
    local item_action_component_id = EntityGetFirstComponentIncludingDisabled(
      card_entity_id, "ItemActionComponent"
    )
    local entity_action_id = ComponentGetValue2(item_action_component_id, "action_id")
    if target_action.id == entity_action_id then
      -- スプライト画像書き換え
      local sprite_component_id = EntityGetFirstComponentIncludingDisabled(card_entity_id,
        "SpriteComponent",
        "item_identified")
      if sprite_component_id then
        ComponentSetValue2(sprite_component_id, "image_file", override_action.sprite)
      end

      -- Item化時の画像書き換え
      local item_comp = EntityGetFirstComponentIncludingDisabled(
        card_entity_id, "ItemComponent"
      )
      if item_comp ~= nil then
        ComponentSetValue2(item_comp, "ui_sprite", override_action.sprite)
      end
    end
  end
end


local function draw_spell_picker(gui)
  GuiBeginScrollContainer(gui, drawer.new_id('spell_picker_gui'), 5, 5, 360, 250)
  GuiLayoutBeginVertical(gui, 0, 0)

  -- ダミー呪文を表示する
  GuiText(gui, 0, 0, GameTextGetTranslatedOrNot("$mystery_spells_and_perks.dummy_spell_title"))
  GuiLayoutAddVerticalSpacing(gui, -2)
  for i, dummy_spell in ipairs(dummy_spells) do
    if (i - 1) % 20 == 0 then
      GuiLayoutBeginHorizontal(gui, 0, 0)
    end

    local clicked = GuiImageButton(
      gui, drawer.new_id('sepll_' .. dummy_spell.id), 0, 0, "", dummy_spell.sprite
    )

    -- アイコンクリック時に、所持呪文が選択されている場合
    local is_selected_target_spell =
        is_selected_wand_spell or is_selected_bag_spell or is_selected_field_spell or is_selected_field_wands_spell
    if clicked and selected_owned_spell and is_selected_target_spell then
      update_card(selected_owned_spell.action, dummy_spell)
    end

    if ((i - 1) % 20 == 19) or i == #dummy_spells then
      GuiLayoutEnd(gui)
    end
  end


  -- バニラ呪文を表示する
  local before_type_name = nil
  local already_called_layout_end = false
  for action_type_num, actions_by_type in pairs(original_actions_by_types) do
    GuiText(gui, 0, 0, GameTextGetTranslatedOrNot(type_translate_text_keys[action_type_num]))
    GuiLayoutAddVerticalSpacing(gui, -2)
    for i, action in ipairs(actions_by_type) do
      local current_type_name = action.type

      if (before_type_name ~= current_type_name and before_type_name ~= nil and (not already_called_layout_end)) then
        already_called_layout_end = false
        GuiLayoutEnd(gui)
        GuiLayoutBeginHorizontal(gui, 0, 0)
      else
        if (i - 1) % 20 == 0 then
          GuiLayoutBeginHorizontal(gui, 0, 0)
        end
      end

      local clicked = GuiImageButton(
        gui, drawer.new_id('sepll_' .. action.id), 0, 0, "", action.sprite
      )

      -- アイコンクリック時に、所持呪文が選択されている場合
      local is_selected_target_spell =
          is_selected_wand_spell or is_selected_bag_spell or is_selected_field_spell or is_selected_field_wands_spell
      if clicked and selected_owned_spell and is_selected_target_spell then
        update_card(selected_owned_spell.action, action)
      end

      if ((i - 1) % 20 == 19) or i == #actions_by_type then
        already_called_layout_end = true
        GuiLayoutEnd(gui)
      end

      before_type_name = current_type_name
    end
    GuiLayoutAddVerticalSpacing(gui, 5)
  end

  GuiLayoutEnd(gui)
  GuiEndScrollContainer(gui)
end

local function draw_owned_spells(gui, wand_spell_entity_ids, inventry_spell_entity_ids)
  GuiBeginScrollContainer(gui, drawer.new_id('owned_spells_gui'), 5, 5, 95, 250)
  GuiLayoutBeginVertical(gui, 0, 0)

  local function draw_spells(title, spell_entity_ids)
    local is_selected = false
    GuiText(gui, 0, 0, title)
    for index, spell_entity_id in ipairs(spell_entity_ids) do
      local item_action_component_id = EntityGetFirstComponentIncludingDisabled(
        spell_entity_id, "ItemActionComponent"
      )

      if item_action_component_id then
        local action_id = ComponentGetValue2(item_action_component_id, "action_id");

        -- entityをcustomized_actionへ変換する
        local customized_action = (function()
          for _, value in ipairs(customized_actions) do
            if action_id == value.id then
              return value
            end
          end
          return nil
        end)()

        if customized_action then
          GuiLayoutBeginHorizontal(gui, 0, 0)
          if selected_owned_spell then
            if (
                  selected_owned_spell.title == title and
                  selected_owned_spell.index == index and
                  selected_owned_spell.action.name == customized_action.name
                ) then
              GuiImage(gui, drawer.new_id(
                  title .. '_selected' .. index), 0, 0,
                "mods/mystery-spells-and-perks/files/ui_gfx/select_icon.png", 1, 1, 0
              )
              is_selected = true
            end
          end

          local clicked_owned_spell = GuiImageButton(
            gui, drawer.new_id(title .. '_owned_spell_' .. index), 0, 0,
            GameTextGetTranslatedOrNot(customized_action.name) or "", customized_action.sprite
          )

          if clicked_owned_spell then
            selected_owned_spell = {
              title = title,
              index = index,
              action = customized_action
            }
          end

          GuiLayoutEnd(gui);
          GuiLayoutAddVerticalSpacing(gui, 1)
        end
      end
    end
    return is_selected
  end

  is_selected_wand_spell = draw_spells("In Wands", wand_spell_entity_ids)
  is_selected_bag_spell = draw_spells("In Bag", inventry_spell_entity_ids)

  GuiLayoutEnd(gui)
  GuiEndScrollContainer(gui)
end

local function draw_nearby_player_spells(gui, nearby_player_spell_entity_ids, nearby_player_spell_in_wands_entity_ids)
  GuiBeginScrollContainer(gui, drawer.new_id('nearby_player_spells_gui'), 5, 5, 95, 250)
  GuiLayoutBeginVertical(gui, 0, 0)

  local function draw_spells(title, spell_entity_ids)
    local is_selected = false
    GuiText(gui, 0, 0, title)
    for index, spell_entity_id in ipairs(spell_entity_ids) do
      local item_action_component_id = EntityGetFirstComponentIncludingDisabled(
        spell_entity_id, "ItemActionComponent"
      )

      if item_action_component_id then
        local action_id = ComponentGetValue2(item_action_component_id, "action_id");

        -- entityをcustomized_actionへ変換する
        local customized_action = (function()
          for _, value in ipairs(customized_actions) do
            if action_id == value.id then
              return value
            end
          end
          return nil
        end)()

        if customized_action then
          GuiLayoutBeginHorizontal(gui, 0, 0)
          if selected_owned_spell then
            if (
                  selected_owned_spell.title == title and
                  selected_owned_spell.index == index and
                  selected_owned_spell.action.name == customized_action.name
                ) then
              GuiImage(gui, drawer.new_id(
                  title .. '_selected' .. index), 0, 0,
                "mods/mystery-spells-and-perks/files/ui_gfx/select_icon.png", 1, 1, 0
              )
              is_selected = true
            end
          end

          local clicked_owned_spell = GuiImageButton(
            gui, drawer.new_id(title .. '_owned_spell_' .. index), 0, 0,
            GameTextGetTranslatedOrNot(customized_action.name) or "", customized_action.sprite
          )

          if clicked_owned_spell then
            selected_owned_spell = {
              title = title,
              index = index,
              action = customized_action
            }
          end

          GuiLayoutEnd(gui);
          GuiLayoutAddVerticalSpacing(gui, 1)
        end
      end
    end
    return is_selected
  end

  is_selected_field_spell = draw_spells("Nearby Player", nearby_player_spell_entity_ids)
  is_selected_field_wands_spell = draw_spells("Nearby Player In Wand", nearby_player_spell_in_wands_entity_ids)

  GuiLayoutEnd(gui)
  GuiEndScrollContainer(gui)
end

local function get_owned_spell_entity_ids(player_entity_id)
  local children = EntityGetAllChildren(player_entity_id)
  if children == nil then
    return {}, {}
  end

  local wand_spells = {};
  local inventry_spells = {};
  for _, child_id in ipairs(children) do
    if (EntityGetName(child_id) == "inventory_quick") then
      local wands = EntityGetAllChildren(child_id, "wand")
      if (wands ~= nil) then
        for _, wand_id in ipairs(wands) do
          local spells = EntityGetAllChildren(wand_id)
          if spells ~= nil then
            for _, spell in ipairs(spells) do
              table.insert(wand_spells, spell)
            end
          end
        end
      end
    end
    if (EntityGetName(child_id) == "inventory_full") then
      inventry_spells = EntityGetAllChildren(child_id) or {}
    end
  end

  return wand_spells, inventry_spells
end

local function get_nearby_player_spell_entity_ids(player_entity_id)
  local x, y = EntityGetTransform(player_entity_id)

  local nearby_player_spells = EntityGetInRadiusWithTag(x, y, 20, 'card_action') or {}
  local nearby_player_wands = EntityGetInRadiusWithTag(x, y, 20, 'wand') or {}
  if next(nearby_player_spells) == nil and next(nearby_player_wands) == nil then
    return {}, {}
  end

  local no_parent_entity_id = 0

  -- fieldにあるスペルのみ取得する
  for index = #nearby_player_spells, 1, -1 do
    local nearby_player_wand = nearby_player_spells[index]
    local parent_entity_id = EntityGetParent(nearby_player_wand)
    if parent_entity_id ~= no_parent_entity_id then
      table.remove(nearby_player_spells, index)
    end
  end

  -- フィールドにあるwandsのスペルを取得する
  local nearby_player_spells_in_wands = {}
  for index = #nearby_player_wands, 1, -1 do
    local nearby_player_wand = nearby_player_wands[index]
    local parent_entity_id = EntityGetParent(nearby_player_wand)
    if parent_entity_id == no_parent_entity_id then
      local spells = EntityGetAllChildren(nearby_player_wand, 'card_action') or {}
      for _, spell in ipairs(spells) do
        table.insert(nearby_player_spells_in_wands, spell)
      end
    end
  end

  return nearby_player_spells, nearby_player_spells_in_wands
end


local function update_card_by_wand_fire()
  for _, actions_by_type in pairs(original_actions_by_types) do
    for _, action in ipairs(actions_by_type) do
      if GlobalsGetValue(VALUES.GLOBAL_WAND_FIREED_SPELL_PREFIX_KEY .. action.id, "false") == "true" then
        for _, customized_action in ipairs(customized_actions) do
          if customized_action.id == action.id then
            update_card(customized_action, action)
            GlobalsSetValue(VALUES.GLOBAL_WAND_FIREED_SPELL_PREFIX_KEY .. action.id, "false")
          end
        end
      end
    end
  end
end

local function update_card_by_kolmi_kill()
  local need_force_update = ModSettingGet(
    "mystery_spells_and_perks.show_answers_when_the_game_is_cleared") or false
  if need_force_update and GlobalsGetValue(VALUES.CHECK_ANSWER_SPELLS, "false") == "true" then
    for _, actions_by_type in pairs(original_actions_by_types) do
      for _, action in ipairs(actions_by_type) do
        for _, customized_action in ipairs(customized_actions) do
          if customized_action.id == action.id then
            update_card(customized_action, action)
            GlobalsSetValue(VALUES.CHECK_ANSWER_SPELLS, "false")
          end
        end
      end
    end
  end
end

local function draw_editor(gui, editor_status)
  local player_entity_id = GetPlayerEntity()
  if not player_entity_id then
    return
  end

  __load_customized_actions_if_not_called()

  if GameIsInventoryOpen() then
    show_name_editor = false
    return
  end

  if editor_status.is_open_perk_editor then
    show_name_editor = false
  end

  local setting_keycode = keycodes[tostring(ModSettingGet('mystery_spells_and_perks.spell_editor_shortcut_key'))]
  if setting_keycode and InputIsKeyJustDown(setting_keycode) then
    show_name_editor = not show_name_editor
  end

  local open_pressed = GuiImageButton(gui, drawer.new_id('spell_editor_button'), 21, 42, "",
    "mods/mystery-spells-and-perks/files/ui_gfx/icon-16-sepll-button.png")
  local open_tooltip = "Show Spell Tag Editor"
  if (show_name_editor) then
    open_tooltip = "Hide Spell Tag Editor"
  end
  GuiTooltip(gui, open_tooltip, "")
  if (open_pressed) then
    show_name_editor = not show_name_editor
  end

  if show_name_editor then
    GuiLayoutBeginHorizontal(gui, 2, 17)

    local wand_spell_entity_ids, inventry_spell_entity_ids =
        get_owned_spell_entity_ids(player_entity_id)
    local nearby_spell_entity_ids, nearby_spell_entity_ids_in_wands =
        get_nearby_player_spell_entity_ids(player_entity_id)

    draw_nearby_player_spells(gui, nearby_spell_entity_ids, nearby_spell_entity_ids_in_wands)
    draw_owned_spells(gui, wand_spell_entity_ids, inventry_spell_entity_ids)
    draw_spell_picker(gui)

    GuiLayoutEnd(gui)
  end

  update_card_by_wand_fire()
  update_card_by_kolmi_kill()

  return show_name_editor
end

return {
  draw = draw_editor
}
