local nxml = dofile_once("mods/mystery-spells-and-perks/files/scripts/lib/luanxml/nxml.lua")
dofile_once('data/scripts/gun/gun_actions.lua')
for _, action in ipairs(actions) do
  if action.custom_xml_file then
    local xml = ModTextFileGetContent(action.custom_xml_file)
    local xml_element = nxml.parse(xml)

    xml_element:add_child(nxml.new_element("LuaComponent",
      {
        script_source_file = "mods/mystery-spells-and-perks/files/scripts/rename_card.lua",
        execute_on_added = "1",
        execute_every_n_frame = "5",
        execute_times = "20"
      }))
    ModTextFileSetContent(action.custom_xml_file, tostring(xml_element))
  end
end

local normal_card = ModTextFileGetContent("data/entities/misc/custom_cards/action.xml")
local custom_card = ModTextFileGetContent("data/entities/base_custom_card.xml")

local xml_element_normal = nxml.parse(normal_card)
local xml_element_custom = nxml.parse(custom_card)

xml_element_normal:add_child(nxml.new_element("LuaComponent",
  {
    script_source_file = "mods/mystery-spells-and-perks/files/scripts/init/rename_card_emitter.lua",
    execute_on_added = "1",
    execute_every_n_frame = "1",
    execute_times = "1"
  }))
xml_element_custom:add_child(nxml.new_element("LuaComponent",
  {
    script_source_file = "mods/mystery-spells-and-perks/files/scripts/init/rename_card_emitter.lua",
    execute_on_added = "1",
    execute_every_n_frame = "1",
    execute_times = "1"
  }))
ModTextFileSetContent("data/entities/misc/custom_cards/action.xml", tostring(xml_element_normal))
ModTextFileSetContent("data/entities/base_custom_card.xml", tostring(xml_element_custom))

local kolmi = ModTextFileGetContent("data/entities/animals/boss_centipede/boss_centipede.xml")
local xml_element_kolmi = nxml.parse(kolmi)

xml_element_kolmi:add_child(nxml.new_element("LuaComponent",
  {
    script_death = "mods/mystery-spells-and-perks/files/scripts/append/kolmi_death_check.lua",
    execute_every_n_frame = "-1",
  }))
ModTextFileSetContent("data/entities/animals/boss_centipede/boss_centipede.xml",
  tostring(xml_element_kolmi))

ModLuaFileAppend("data/scripts/gun/gun_actions.lua",
  "mods/mystery-spells-and-perks/files/scripts/append/gun_actions.lua")
ModLuaFileAppend("data/scripts/perks/perk_list.lua",
  "mods/mystery-spells-and-perks/files/scripts/append/perk_list.lua")
ModLuaFileAppend("data/scripts/gun/gun.lua",
  "mods/mystery-spells-and-perks/files/scripts/append/gun.lua")
ModLuaFileAppend("data/scripts/perks/perk.lua",
  "mods/mystery-spells-and-perks/files/scripts/append/perk/perk_pickup.lua")
ModLuaFileAppend("data/scripts/perks/perk.lua",
  "mods/mystery-spells-and-perks/files/scripts/append/perk/perk_spawn.lua")
ModLuaFileAppend("data/scripts/director_helpers.lua", "mods/mystery-spells-and-perks/files/scripts/append/director_helpers.lua")
ModLuaFileAppend("data/scripts/game_helpers.lua", "mods/mystery-spells-and-perks/files/scripts/append/game_helpers.lua")
