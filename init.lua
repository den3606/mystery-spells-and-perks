local VALUES = dofile_once("mods/mystery-spells-and-perks/files/scripts/variables.lua")
local Json = dofile_once("mods/mystery-spells-and-perks/files/scripts/lib/jsonlua/json.lua")
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
      script_source_file = "mods/mystery-spells-and-perks/files/scripts/rename_card_emitter.lua",
      execute_on_added = "1",
      execute_every_n_frame = "1",
      execute_times = "1"
    }))
  xml_element_custom:add_child(nxml.new_element("LuaComponent",
    {
      script_source_file = "mods/mystery-spells-and-perks/files/scripts/rename_card_emitter.lua",
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
end

function OnWorldInitialized()
  GameAddFlagRun(VALUES.IS_GAME_START)
end

function OnWorldPreUpdate()
end

local function replace_spell_entity(entity_id, action_sprite)
  -- スプライト画像書き換え
  local sprite_component_id = EntityGetFirstComponentIncludingDisabled(entity_id,
    "SpriteComponent",
    "item_identified")
  if sprite_component_id then
    ComponentSetValue2(sprite_component_id, "image_file", action_sprite)
  end

  -- Item化時の画像/名前書き換え
  local item_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "ItemComponent")
  if item_comp ~= nil then
    ComponentSetValue2(item_comp, "ui_sprite", action_sprite)
  end

  EntityRemoveTag(entity_id, "mystery_spells_need_init")
end

function OnWorldPostUpdate()
  if GameGetFrameNum() % 30 == 0 then
    local json = ModSettingGet(VALUES.NEED_UPDATE_SPELL_ENTITIES) or "{}"
    local card_entity_ids = Json.decode(json)

    for index, card_entity_id in ipairs(card_entity_ids) do
      local item_action_component_id = EntityGetFirstComponentIncludingDisabled(
        card_entity_id, "ItemActionComponent"
      )
      if item_action_component_id ~= nil then
        local action_id = ComponentGetValue2(item_action_component_id, "action_id")
        local customized_action_json = GlobalsGetValue(
          VALUES.GLOBAL_SPELL_PREFIX_KEY .. action_id, ""
        )

        if customized_action_json ~= nil and customized_action_json ~= "" then
          local customized_action = Json.decode(string.gsub(customized_action_json, "'", '"'))
          replace_spell_entity(card_entity_id, customized_action.sprite)
          table.remove(card_entity_ids, index)
          ModSettingSet(VALUES.NEED_UPDATE_SPELL_ENTITIES, Json.encode(card_entity_ids))
        end
      end
    end
  end

  name_editor.draw(gui)
end

local content = ModTextFileGetContent("data/translations/common.csv")
local mystery_spells_and_perks_content = ModTextFileGetContent(
  "mods/mystery-spells-and-perks/files/translations/common.csv")
ModTextFileSetContent("data/translations/common.csv", content .. mystery_spells_and_perks_content)

print("mystery-spells-and-perks loaded")
