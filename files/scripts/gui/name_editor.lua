local VALUES = dofile_once("mods/mystery-spells-and-perks/files/scripts/variables.lua")
local drawer = dofile_once("mods/mystery-spells-and-perks/files/scripts/gui/drawer.lua")
local Json = dofile_once("mods/mystery-spells-and-perks/files/scripts/lib/jsonlua/json.lua")

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

-- title = title,
-- index = index,
-- action = action

local selected_owned_spell = nil
local is_selected_wand_spell = false
local is_selected_bag_spell = false
local show_name_editor = false

local function is_action_unlocked(action)
  if action then
    if action.spawn_requires_flag ~= nil then
      return HasFlagPersistent(action.spawn_requires_flag)
    end
  end
  return true
end

dofile_once("data/scripts/gun/gun_enums.lua")
dofile('data/scripts/gun/gun_actions.lua')
local original_actions_by_types = {}
for _, action in pairs(actions) do
  if is_action_unlocked(action) then
    original_actions_by_types[action.type] = original_actions_by_types[action.type] or {}
    table.insert(original_actions_by_types[action.type], action);
  end
end


local called_action = false
local secret_actions = {}
local function call_action_if_not_called()
  if called_action then
    return
  end
  dofile('data/scripts/gun/gun_actions.lua')
  called_action = true
  for _, secret_action in ipairs(actions) do
    local action_copy = {}
    for key, value in pairs(secret_action) do
      -- LUA: sprite / mods/mystery-spells-and-perks/files/ui_gfx/secret_spell_icon.png
      -- LUA: spawn_level / 0,1,2,3,4,5,6
      -- LUA: original_action / function: 0x1eb35ec0
      -- LUA: id / BOMB
      -- LUA: original_sprite / data/ui_gfx/gun_actions/bomb.png
      -- LUA: related_projectiles / table: 0x1eb58e18
      -- LUA: custom_xml_file / data/entities/misc/custom_cards/bomb.xml
      -- LUA: sprite_unidentified / data/ui_gfx/gun_actions/bomb_unidentified.png
      -- LUA: price / 200
      -- LUA: mana / 25
      -- LUA: spawn_probability / 1,1,1,1,0.5,0.5,0.1
      -- LUA: max_uses / 3
      -- LUA: type / 0
      -- LUA: action / function: 0x1ec55920
      -- LUA: name / $action_mystery_stormcloud_spell
      -- LUA: description / $actiondesc_mystery_secret_spell
      if type(value) ~= "function" then
        action_copy[key] = value
      end
    end
    table.insert(secret_actions, action_copy)
  end
  ModSettingSet(VALUES.SECRET_ACTIONS, Json.encode(secret_actions))
end

local function draw_spell_picker(gui)
  GuiBeginScrollContainer(gui, drawer.new_id('spell_picker'), 5, 5, 360, 250)
  GuiLayoutBeginVertical(gui, 0, 0)

  local before_type_name = nil
  local already_called_layout_end = false
  local count = 0
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

      if clicked and selected_owned_spell ~= nil and (is_selected_wand_spell or is_selected_bag_spell) then
        -- クリック時にSpellを仮当てする
        -- selected_owned_spell.action.name = action.name
        -- selected_owned_spell.action.sprite = action.sprite
        for i = 1, #secret_actions, 1 do
          if secret_actions[i].id == action.id then
            secret_actions[i].name = action.name
            secret_actions[i].sprite = action.sprite
            secret_actions[i].description = action.description
          end
        end


        -- ModSettingSet(VALUES.SECRET_ACTIONS, Json.encode(secret_actions))
        -- ModSettingSet(VALUES.OVERRIDE_SECRET_ACTION, true)
        -- dofile('data/scripts/gun/gun.lua')
        -- ModSettingSet(VALUES.OVERRIDE_SECRET_ACTION, false)
        -- local x, y = EntityGetTransform(GetPlayerEntity())
        -- local cards = EntityGetInRadiusWithTag(x, y, 50, "card_action")
        local cards = EntityGetWithTag("card_action")
        for i, card in ipairs(cards) do
          local sprite_comp = EntityGetFirstComponentIncludingDisabled(card, "SpriteComponent",
            "item_identified")
          if (sprite_comp ~= nil) then
            ComponentSetValue2(sprite_comp, "image_file", action.sprite)
          end
          local item_comp = EntityGetFirstComponentIncludingDisabled(card, "ItemComponent")
          if item_comp ~= nil then
            ComponentSetValue2(item_comp, "ui_sprite", action.sprite)
            ComponentSetValue2(item_comp, "item_name", action.name)
          end
        end
      end

      if ((i - 1) % 20 == 19) or i == #actions_by_type then
        already_called_layout_end = true
        GuiLayoutEnd(gui)
      end

      before_type_name = current_type_name
      count = count + 1
    end
    GuiLayoutAddVerticalSpacing(gui, 5)
  end

  GuiLayoutEnd(gui)
  GuiEndScrollContainer(gui)
end

local function draw_owned_spells(gui, wand_spells, inventry_spells)
  GuiBeginScrollContainer(gui, drawer.new_id('window_gui'), 5, 5, 100, 250)
  GuiLayoutBeginVertical(gui, 0, 0)

  call_action_if_not_called()

  local function draw_spells(title, spells)
    local is_selected = false
    GuiText(gui, 0, 0, title)
    for index, spell in ipairs(spells) do
      local item_action_component_id = EntityGetFirstComponentIncludingDisabled(
        spell, "ItemActionComponent"
      )
      local action_id = ComponentGetValue2(item_action_component_id, "action_id");

      local action = nil
      for _, value in ipairs(actions) do
        if action_id == value.id then
          action = value
        end
      end

      if action then
        GuiLayoutBeginHorizontal(gui, 0, 0)
        if selected_owned_spell ~= nil then
          if (
                selected_owned_spell.title == title and
                selected_owned_spell.index == index and
                selected_owned_spell.action.name == action.name
              ) then
            GuiImage(gui, drawer.new_id(
                title .. '_selected' .. index), 0, 0,
              "mods/mystery-spells-and-perks/files/ui_gfx/select_icon.png", 1, 1, 0
            )
            is_selected = true
          end
        end

        local clicked_taregt_spell = GuiImageButton(
          gui, drawer.new_id(title .. '_owned_spell_' .. index), 0, 0,
          GameTextGetTranslatedOrNot(action.name) or "", action.sprite
        )

        if clicked_taregt_spell then
          selected_owned_spell = {
            title = title,
            index = index,
            action = action
          }
        end

        GuiLayoutEnd(gui);
        GuiLayoutAddVerticalSpacing(gui, 1)
      end
    end
    return is_selected
  end

  is_selected_wand_spell = draw_spells("In Wands", wand_spells)
  is_selected_bag_spell = draw_spells("In Bag", inventry_spells)

  GuiLayoutEnd(gui)
  GuiEndScrollContainer(gui)
end

local function get_owned_spells(player_entity_id)
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


local function draw_editor(gui)
  local player_entity_id = GetPlayerEntity()
  if not player_entity_id then
    return
  end

  if GameIsInventoryOpen() then
    return
  end

  local wand_spells, inventry_spells = get_owned_spells(player_entity_id)

  GuiStartFrame(gui)
  local open_pressed = GuiImageButton(gui, drawer.new_id('tag_button'), 21, 42, "",
    "mods/mystery-spells-and-perks/files/ui_gfx/icon-16-brown.png")

  local open_tooltip = "Show Spell Tag Editor"
  if (show_name_editor) then
    open_tooltip = "Hide Spell Tag Editor"
  end

  GuiTooltip(gui, open_tooltip, "")

  if (open_pressed) then
    show_name_editor = not show_name_editor
  end

  if show_name_editor then
    GuiLayoutBeginHorizontal(gui, 5, 14)
    draw_owned_spells(gui, wand_spells, inventry_spells)
    draw_spell_picker(gui)
    GuiLayoutEnd(gui)
  end
end

return {
  draw = draw_editor
}
