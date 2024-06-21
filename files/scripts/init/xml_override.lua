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

local kolmi = ModTextFileGetContent("data/entities/animals/boss_centipede/boss_centipede.xml")
local xml_element_kolmi = nxml.parse(kolmi)

xml_element_kolmi:add_child(nxml.new_element("LuaComponent",
  {
    script_death = "mods/mystery-spells-and-perks/files/scripts/append/kolmi_death_check.lua",
    execute_every_n_frame = "-1",
  }))
ModTextFileSetContent("data/entities/animals/boss_centipede/boss_centipede.xml",
  tostring(xml_element_kolmi))
