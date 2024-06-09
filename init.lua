local VALUES = dofile_once("mods/mystery-spells-and-perks/files/scripts/variables.lua")
dofile_once("mods/mystery-spells-and-perks/files/scripts/lib/utilities.lua")

print("mystery-spells-and-perks load")

function OnModPreInit()
end

function OnModInit()
end

function OnModPostInit()
  local nxml = dofile_once("mods/mystery-spells-and-perks/files/scripts/lib/luanxml/nxml.lua")
  dofile_once('data/scripts/gun/gun_actions.lua')
  for index, action in ipairs(actions) do
    if action.custom_xml_file then
      local xml = ModTextFileGetContent(action.custom_xml_file)
      local xml_element = nxml.parse(xml)

      xml_element:add_child(nxml.new_element("LuaComponent",
        {
          script_source_file = "mods/mystery-spells-and-perks/files/scripts/rename_custom_card.lua",
          execute_on_added = "1",
          execute_every_n_frame = "-1",
          execute_times = "1"
        }))
      ModTextFileSetContent(action.custom_xml_file, tostring(xml_element))
    end
  end

  ModLuaFileAppend("data/scripts/gun/gun_actions.lua",
    "mods/mystery-spells-and-perks/files/scripts/append/gun_actions.lua")
  ModLuaFileAppend("data/scripts/perks/perk_list.lua",
    "mods/mystery-spells-and-perks/files/scripts/append/perk_list.lua")
end

function OnWorldInitialized()
  GameAddFlagRun(VALUES.IS_GAME_START)
end

function OnPlayerSpawned(player_entity)
end

function OnWorldPreUpdate()
end

function OnWorldPostUpdate() -- This is called every time the game has finished updating the world
end

function OnMagicNumbersAndWorldSeedInitialized()
end

local content = ModTextFileGetContent("data/translations/common.csv")
local mystery_spells_and_perks_content = ModTextFileGetContent(
  "mods/mystery-spells-and-perks/files/translations/common.csv")
ModTextFileSetContent("data/translations/common.csv", content .. mystery_spells_and_perks_content)

print("mystery-spells-and-perks loaded")
