dofile_once("mods/mystery-spells-and-perks/files/scripts/lib/utilities.lua")
local VALUES = dofile_once("mods/mystery-spells-and-perks/files/scripts/variables.lua")
local spells = dofile_once("mods/mystery-spells-and-perks/files/scripts/init/update_spells.lua")

print("mystery-spells-and-perks load")

local gui = gui or GuiCreate()
local editor_status = {
  is_open_spell_editor = false,
  is_open_perk_editor = false,
}
local spell_name_editor = dofile_once(
  "mods/mystery-spells-and-perks/files/scripts/gui/spell_name_editor.lua"
)
local perk_name_editor = dofile_once(
  "mods/mystery-spells-and-perks/files/scripts/gui/perk_name_editor.lua"
)

-- 設定初期化
ModSettingSet(VALUES.GLOBAL_GUI_ID, 0)

function OnModPostInit()
  dofile_once("mods/mystery-spells-and-perks/files/scripts/init/xml_override.lua")
end

function OnWorldInitialized()
  GameAddFlagRun(VALUES.IS_GAME_START)
end

function OnWorldPreUpdate()
end

function OnWorldPostUpdate()
  if GameGetFrameNum() % 30 == 0 then
    spells.update_if_needed()
  end

  GuiStartFrame(gui)

  editor_status.is_open_spell_editor = spell_name_editor.draw(gui, editor_status)
  editor_status.is_open_perk_editor = perk_name_editor.draw(gui, editor_status)
end

local content = ModTextFileGetContent("data/translations/common.csv")
local mystery_spells_and_perks_content = ModTextFileGetContent(
  "mods/mystery-spells-and-perks/files/translations/common.csv")
ModTextFileSetContent("data/translations/common.csv", content .. mystery_spells_and_perks_content)

print("mystery-spells-and-perks loaded")
