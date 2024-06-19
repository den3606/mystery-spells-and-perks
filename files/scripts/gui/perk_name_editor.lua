dofile_once("data/scripts/gun/gun_enums.lua")
dofile_once("mods/mystery-spells-and-perks/files/scripts/lib/utilities.lua")
local keycodes = dofile_once("mods/mystery-spells-and-perks/files/scripts/gui/keycodes.lua")
local VALUES = dofile_once("mods/mystery-spells-and-perks/files/scripts/variables.lua")
local drawer = dofile_once("mods/mystery-spells-and-perks/files/scripts/gui/drawer.lua")
local Json = dofile_once("mods/mystery-spells-and-perks/files/scripts/lib/jsonlua/json.lua")
local dummy_perks = dofile_once("mods/mystery-spells-and-perks/files/scripts/dummy_perks.lua")

local customized_perks = {}
local sorted_customized_perks = {}
local original_perks = {}
local selected_owned_perk = nil
local show_name_editor = false
local is_selected_owned_perk = false
local is_selected_all_mystery_perk = false
local load_customized_perk = false

local function __load_original_perks()
  dofile('data/scripts/perks/perk_list.lua')
  for _, perk in pairs(perk_list) do
    table.insert(original_perks, perk);
  end
end
__load_original_perks()

local function __load_customized_perks_if_not_called()
  if load_customized_perk then
    return
  end

  dofile('data/scripts/perks/perk_list.lua')
  for _, secret_perk in ipairs(perk_list) do
    -- 既にRunで登録されているかを確認する
    local json = GlobalsGetValue(
      VALUES.GLOBAL_PERK_PREFIX_KEY .. secret_perk.id, "{}")
    local customized_perk = Json.decode(string.gsub(json, "'", '"'))

    if customized_perk.id then
      table.insert(customized_perks, customized_perk)
    else
      local perk_copy = {}
      for key, value in pairs(secret_perk) do
        if type(value) ~= "function" then
          perk_copy[key] = value
        end
      end
      table.insert(customized_perks, perk_copy)
    end
  end

  -- 複製処理
  for i = 1, #customized_perks do
    sorted_customized_perks[i] = customized_perks[i]
  end
  -- ソート
  table.sort(sorted_customized_perks, function(a, b)
    return GameTextGetTranslatedOrNot(a.ui_name) < GameTextGetTranslatedOrNot(b.ui_name)
  end)

  load_customized_perk = true
end

local function update_perk(target_perk, override_perk)
  -- カスタマイズリストを更新する
  for _, customized_perk in ipairs(customized_perks) do
    if target_perk.id == customized_perk.id then
      customized_perk.ui_icon = override_perk.ui_icon
      customized_perk.perk_icon = override_perk.perk_icon
      GlobalsSetValue(VALUES.GLOBAL_PERK_PREFIX_KEY .. customized_perk.id,
        string.gsub(Json.encode(customized_perk), '"', "'"))
    end
  end

  -- ソートカスタマイズリストも更新する
  for _, sorted_customized_perk in ipairs(sorted_customized_perks) do
    if target_perk.id == sorted_customized_perk.id then
      sorted_customized_perk.ui_icon = override_perk.ui_icon
      sorted_customized_perk.perk_icon = override_perk.perk_icon
    end
  end

  -- プレイヤー、敵キャラクター等で保持されているパークを書き換える
  for _, perk_entity_id in ipairs(EntityGetWithTag("perk_entity" or {})) do
    local ui_icon_compoennt_id = EntityGetFirstComponentIncludingDisabled(perk_entity_id,
      "UIIconComponent")

    local perk_entity_perk_id = GetInternalVariableValue(perk_entity_id, "perk_id", "value_string")
    if ui_icon_compoennt_id and target_perk.id == perk_entity_perk_id then
      ComponentSetValue2(ui_icon_compoennt_id, "description", override_perk.ui_description)
      ComponentSetValue2(ui_icon_compoennt_id, "icon_sprite_file", override_perk.ui_icon)
    end
  end

  -- フィールドにあるEntity化された特典を書き換える
  local item_perk_entity_ids = EntityGetWithTag("item_perk")
  for _, item_perk_entity_id in ipairs(item_perk_entity_ids) do
    local item_perk_id = GetInternalVariableValue(item_perk_entity_id, "perk_id", "value_string")
    if target_perk.id == item_perk_id then
      -- スプライト画像書き換え
      local sprite_component_id = EntityGetFirstComponentIncludingDisabled(
        item_perk_entity_id, "SpriteComponent"
      )
      if sprite_component_id then
        ComponentSetValue2(sprite_component_id, "image_file", override_perk.perk_icon)
      end
    end
  end
end


local function draw_perk_picker(gui)
  GuiBeginScrollContainer(gui, drawer.new_id('perk_picker_gui'), 5, 5, 160, 250)
  GuiLayoutBeginVertical(gui, 0, 0)

  -- ダミー特典を表示する
  GuiText(gui, 0, 0, GameTextGetTranslatedOrNot("$mystery_spells_and_perks.dummy_perk_title"))
  for i, dummy_perk in pairs(dummy_perks) do
    if (i - 1) % 9 == 0 then
      GuiLayoutBeginHorizontal(gui, 0, 0)
    end

    local clicked = GuiImageButton(
      gui, drawer.new_id('perk_' .. dummy_perk.id), 0, 0, "", dummy_perk.perk_icon
    )

    -- アイコンクリック時に、取得している特典が選択されている場合
    if clicked and selected_owned_perk and (is_selected_owned_perk or is_selected_all_mystery_perk) then
      update_perk(selected_owned_perk.perk, dummy_perk)
    end

    if (i - 1) % 9 == 8 then
      GuiLayoutEnd(gui)
      GuiLayoutAddVerticalSpacing(gui, 2)
    end
  end


  -- バニラ特典を表示する
  GuiText(gui, 0, 0, GameTextGetTranslatedOrNot("$progress_perks"))
  for i, perk in pairs(original_perks) do
    if (i - 1) % 9 == 0 then
      GuiLayoutBeginHorizontal(gui, 0, 0)
    end

    local clicked = GuiImageButton(
      gui, drawer.new_id('perk_' .. perk.id), 0, 0, "", perk.perk_icon
    )

    -- アイコンクリック時に、取得している特典が選択されている場合
    if clicked and selected_owned_perk and (is_selected_owned_perk or is_selected_all_mystery_perk) then
      update_perk(selected_owned_perk.perk, perk)
    end

    if (i - 1) % 9 == 8 then
      GuiLayoutEnd(gui)
      GuiLayoutAddVerticalSpacing(gui, 2)
    end
  end

  GuiLayoutEnd(gui)
  GuiEndScrollContainer(gui)
end

local function draw_all_perks(gui)
  GuiBeginScrollContainer(gui, drawer.new_id('all_mystery_perks_gui'), 5, 5, 95, 250)
  GuiLayoutBeginVertical(gui, 0, 0)

  local function draw_perks(title)
    local is_selected = false
    GuiText(gui, 0, 0, title)

    for index, customized_perk in ipairs(sorted_customized_perks) do
      if customized_perk then
        GuiLayoutBeginHorizontal(gui, 0, 0)
        if selected_owned_perk then
          if (
                selected_owned_perk.title == title and
                selected_owned_perk.index == index and
                selected_owned_perk.perk.ui_name == customized_perk.ui_name
              ) then
            GuiImage(gui, drawer.new_id(
                title .. '_selected' .. index), 0, 0,
              "mods/mystery-spells-and-perks/files/ui_gfx/select_icon.png", 1, 1, 0
            )
            is_selected = true
          end
        end

        local clicked_owned_perk = GuiImageButton(
          gui, drawer.new_id(title .. '_owned_perk_' .. index), 0, 0,
          GameTextGetTranslatedOrNot(customized_perk.ui_name) or "", customized_perk.perk_icon
        )

        if clicked_owned_perk then
          selected_owned_perk = {
            title = title,
            index = index,
            perk = customized_perk
          }
        end

        GuiLayoutEnd(gui);
        GuiLayoutAddVerticalSpacing(gui, 1)
      end
    end
    return is_selected
  end

  is_selected_all_mystery_perk = draw_perks("All Mytery Perks")

  GuiLayoutEnd(gui)
  GuiEndScrollContainer(gui)
end

local function draw_target_perks(title, perk_entity_ids)
  local is_selected = false
  GuiText(gui, 0, 0, title)
  for index, perk_entity_id in ipairs(perk_entity_ids) do
    local perk_id = GetInternalVariableValue(perk_entity_id, "perk_id", "value_string")
    if perk_id then
      -- entityをcustomized_actionへ変換する
      local customized_perk = (function()
        for _, value in ipairs(customized_perks) do
          if perk_id == value.id then
            return value
          end
        end
        return nil
      end)()

      if customized_perk then
        GuiLayoutBeginHorizontal(gui, 0, 0)
        if selected_owned_perk then
          if (
                selected_owned_perk.title == title and
                selected_owned_perk.index == index and
                selected_owned_perk.perk.ui_name == customized_perk.ui_name
              ) then
            GuiImage(gui, drawer.new_id(
                title .. '_selected' .. index), 0, 0,
              "mods/mystery-spells-and-perks/files/ui_gfx/select_icon.png", 1, 1, 0
            )
            is_selected = true
          end
        end

        local clicked_owned_perk = GuiImageButton(
          gui, drawer.new_id(title .. '_owned_perk_' .. index), 0, 0,
          GameTextGetTranslatedOrNot(customized_perk.ui_name) or "", customized_perk.perk_icon
        )

        if clicked_owned_perk then
          selected_owned_perk = {
            title = title,
            index = index,
            perk = customized_perk
          }
        end

        GuiLayoutEnd(gui);
        GuiLayoutAddVerticalSpacing(gui, 1)
      end
    end
  end
  return is_selected
end

local function draw_owned_perks(gui, perk_entity_ids)
  GuiBeginScrollContainer(gui, drawer.new_id('owned_perks_gui'), 5, 5, 95, 250)
  GuiLayoutBeginVertical(gui, 0, 0)

  is_selected_owned_perk = draw_target_perks("Picked Perks", perk_entity_ids)

  GuiLayoutEnd(gui)
  GuiEndScrollContainer(gui)
end

local function get_owned_perk_entity_ids(player_entity_id)
  local perk_entity_ids = {}

  for _, perk_entity_id in ipairs(EntityGetAllChildren(player_entity_id, "perk_entity") or {}) do
    local ui_icon_compoennt_id = EntityGetFirstComponentIncludingDisabled(perk_entity_id,
      "UIIconComponent")
    if ui_icon_compoennt_id then
      table.insert(perk_entity_ids, perk_entity_id)
    end
  end

  return perk_entity_ids
end

local function update_card_by_kolmi_kill()
  local need_force_update = ModSettingGet(
    "mystery_spells_and_perks.show_answers_when_the_game_is_cleared") or false
  if need_force_update and GlobalsGetValue(VALUES.CHECK_ANSWER_PERKS, "false") == "true" then
    for _, perk in ipairs(original_perks) do
      for _, customized_perk in ipairs(customized_perks) do
        if customized_perk.id == perk.id then
          update_perk(customized_perk, perk)
          GlobalsSetValue(VALUES.CHECK_ANSWER_PERKS, "false")
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

  __load_customized_perks_if_not_called()

  if GameIsInventoryOpen() then
    show_name_editor = false
    return
  end

  if editor_status.is_open_spell_editor then
    show_name_editor = false
  end

  local setting_keycode = keycodes[tostring(ModSettingGet('mystery_spells_and_perks.perk_editor_shortcut_key'))]
  if setting_keycode and InputIsKeyJustDown(setting_keycode) then
    show_name_editor = not show_name_editor
  end

  local open_pressed = GuiImageButton(gui, drawer.new_id('perk_editor_button'), 40, 42, "",
    "mods/mystery-spells-and-perks/files/ui_gfx/icon-16-perk-button.png")
  local open_tooltip = "Show Perk Tag Editor"
  if (show_name_editor) then
    open_tooltip = "Hide Perk Tag Editor"
  end
  GuiTooltip(gui, open_tooltip, "")
  if (open_pressed) then
    show_name_editor = not show_name_editor
  end

  if show_name_editor then
    GuiLayoutBeginHorizontal(gui, 2, 17)
    local perk_entities = get_owned_perk_entity_ids(player_entity_id)
    draw_all_perks(gui)
    draw_owned_perks(gui, perk_entities)
    draw_perk_picker(gui)
    GuiLayoutEnd(gui)
  end

  update_card_by_kolmi_kill()

  return show_name_editor
end

return {
  draw = draw_editor
}
