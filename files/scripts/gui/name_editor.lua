local drawer = dofile_once("mods/mystery-spells-and-perks/files/scripts/gui/drawer.lua")

local button_gui = drawer.new_id()
local window_gui = drawer.new_id()
local spell_picker = drawer.new_id()
local icon_gui = drawer.new_id()
local icon_gui2 = drawer.new_id()
local icon_gui3 = drawer.new_id()
local show_name_editor = false

local function is_action_unlocked(action)
  if action then
    if action.spawn_requires_flag ~= nil then
      return HasFlagPersistent(action.spawn_requires_flag)
    end
  end
  return true
end

local function get_actions_by_types()
  dofile_once("data/scripts/gun/gun_enums.lua")
  dofile('data/scripts/gun/gun_actions.lua')

  local actions_by_types = {}
  for _, action in pairs(actions) do
    if is_action_unlocked(action) then
      actions_by_types[action.type] = actions_by_types[action.type] or {}
      table.insert(actions_by_types[action.type], action);
    end
  end

  return actions_by_types
end

local actions_by_types = get_actions_by_types()

local function draw_spell_picker(gui)
  GuiBeginScrollContainer(gui, spell_picker, 5, 5, 360, 200)
  GuiLayoutBeginVertical(gui, 0, 0)

  -- print(tostring(action.type))
  -- print(tostring(action.original_sprite))
  -- print(tostring(action.spawn_requires_flag))


  local before_type_name = nil
  local already_called_layout_end = false
  local count = 0
  for index, actions_by_type in pairs(actions_by_types) do
    for i = 0, #actions_by_type - 1 do
      local current_type_name = actions_by_type[i + 1].type

      if (before_type_name ~= current_type_name and before_type_name ~= nil and (not already_called_layout_end)) then
        already_called_layout_end = false
        GuiLayoutEnd(gui)
        GuiLayoutBeginHorizontal(gui, 0, 0)
      else
        if i % 20 == 0 then
          GuiLayoutBeginHorizontal(gui, 0, 0)
        end
      end

      GuiImageButton(gui, 342423235435 + count, 0, 0, "", actions_by_type[i + 1].sprite)

      if (i % 20 == 19) or i == #actions_by_type - 1 then
        already_called_layout_end = true
        GuiLayoutEnd(gui)
      end

      before_type_name = actions_by_type[i + 1].type
      count = count + 1
    end
  end

  GuiLayoutEnd(gui)
  GuiEndScrollContainer(gui)
end

local function draw_spells_owned(gui)
  GuiBeginScrollContainer(gui, window_gui, 5, 5, 100, 250)
  GuiLayoutBeginVertical(gui, 0, 0)

  -- GuiLayoutBeginHorizontal(gui, 0, 0)
  GuiText(gui, 0, 0, "In Bag")
  -- GuiLayoutEnd(gui);

  GuiLayoutBeginHorizontal(gui, 0, 0)
  GuiImage(gui, 21422314, 0, 0, "mods/mystery-spells-and-perks/files/ui_gfx/select_icon.png", 1,
    1, 0)
  GuiImageButton(gui, icon_gui, 0, 0, "呪文名",
    "mods/mystery-spells-and-perks/files/ui_gfx/secret_spell_icon.png")
  GuiLayoutEnd(gui);

  GuiLayoutAddVerticalSpacing(gui, 1)

  -- GuiLayoutBeginHorizontal(gui, 0, 0)
  GuiImageButton(gui, icon_gui2, 0, 0, "呪文名",
    "mods/mystery-spells-and-perks/files/ui_gfx/secret_spell_icon.png")
  -- GuiLayoutEnd(gui);

  GuiLayoutAddVerticalSpacing(gui, 1)

  -- GuiLayoutBeginHorizontal(gui, 0, 0)
  GuiImageButton(gui, icon_gui3, 0, 0, "呪文名2",
    "mods/mystery-spells-and-perks/files/ui_gfx/secret_spell_icon.png")
  -- GuiLayoutEnd(gui);

  GuiLayoutEnd(gui)
  GuiEndScrollContainer(gui)
end



local function draw_editor(gui)
  if GameIsInventoryOpen() then
    return
  end

  GuiStartFrame(gui)
  local open_pressed = GuiImageButton(gui, button_gui, 21, 42, "",
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
    draw_spells_owned(gui)
    draw_spell_picker(gui)
    GuiLayoutEnd(gui)
  end
end

return {
  draw = draw_editor
}
