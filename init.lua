local VALUES = dofile_once("mods/mystery-spells-and-perks/files/scripts/variables.lua")
dofile_once("mods/mystery-spells-and-perks/files/scripts/lib/utilities.lua")

print("mystery-spells-and-perks load")

local gui = gui or GuiCreate()
local name_editor = dofile_once(
  "mods/mystery-spells-and-perks/files/scripts/gui/name_editor.lua"
)

-- 設定初期化
ModSettingSet(VALUES.GLOBAL_GUI_ID, 0)

function OnModPostInit()
  local nxml = dofile_once("mods/mystery-spells-and-perks/files/scripts/lib/luanxml/nxml.lua")
  dofile_once('data/scripts/gun/gun_actions.lua')
  -- for _, action in ipairs(actions) do
  -- TODO:全ての呪文にoriginalのcustom_cardを付ける仕様に変更する
  -- →それならbaseのxmlをいじった方が良い？
  -- 検証：全てのcardEntityにはbase_custom_cardがついているのか？
  -- ついていない場合は、独自定義してcustom_cardに埋め込む。
  -- if action.custom_xml_file then
  --   local xml = ModTextFileGetContent(action.custom_xml_file)
  --   local xml_element = nxml.parse(xml)

  --   xml_element:add_child(nxml.new_element("LuaComponent",
  --     {
  --       script_source_file = "mods/mystery-spells-and-perks/files/scripts/rename_custom_card.lua",
  --       execute_on_added = "1",
  --       execute_every_n_frame = "-1",
  --       execute_times = "1"
  --     }))
  --   ModTextFileSetContent(action.custom_xml_file, tostring(xml_element))
  -- else
  local normal_card = ModTextFileGetContent("data/entities/misc/custom_cards/action.xml")
  local custom_card = ModTextFileGetContent("data/entities/base_custom_card.xml")

  local xml_element_normal = nxml.parse(normal_card)
  local xml_element_custom = nxml.parse(custom_card)

  xml_element_normal:add_child(nxml.new_element("LuaComponent",
    {
      script_source_file = "mods/mystery-spells-and-perks/files/scripts/rename_card.lua",
      execute_on_added = "1",
      execute_every_n_frame = "-1",
      execute_times = "1"
    }))
  xml_element_custom:add_child(nxml.new_element("LuaComponent",
    {
      script_source_file = "mods/mystery-spells-and-perks/files/scripts/rename_card.lua",
      execute_on_added = "1",
      execute_every_n_frame = "-1",
      execute_times = "1"
    }))
  ModTextFileSetContent("data/entities/misc/custom_cards/action.xml", tostring(xml_element_normal))
  ModTextFileSetContent("data/entities/base_custom_card.xml", tostring(xml_element_custom))
  -- end

  ModLuaFileAppend("data/scripts/gun/gun_actions.lua",
    "mods/mystery-spells-and-perks/files/scripts/append/gun_actions.lua")
  ModLuaFileAppend("data/scripts/perks/perk_list.lua",
    "mods/mystery-spells-and-perks/files/scripts/append/perk_list.lua")
end

function OnWorldInitialized()
  GameAddFlagRun(VALUES.IS_GAME_START)
end

function OnWorldPreUpdate()
end

function OnWorldPostUpdate()
  name_editor.draw(gui)
end

local content = ModTextFileGetContent("data/translations/common.csv")
local mystery_spells_and_perks_content = ModTextFileGetContent(
  "mods/mystery-spells-and-perks/files/translations/common.csv")
ModTextFileSetContent("data/translations/common.csv", content .. mystery_spells_and_perks_content)

print("mystery-spells-and-perks loaded")
