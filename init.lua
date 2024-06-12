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
  -- for _, action in ipairs(actions) do
  -- TODO:全ての呪文にoriginalのcustom_cardを付ける仕様に変更する
  -- →それならbaseのxmlをいじった方が良い？
  -- 検証：全てのcardEntityにはbase_custom_cardがついているのか？
  -- ついていない場合は、独自定義してcustom_cardに埋め込む。
  dofile_once('data/scripts/gun/gun_actions.lua')
  -- for index, action in ipairs(actions) do
  --   if action.custom_xml_file then
  --     local xml = ModTextFileGetContent(action.custom_xml_file)
  --     local xml_element = nxml.parse(xml)

  --     xml_element:add_child(nxml.new_element("LuaComponent",
  --       {
  --         script_source_file = "mods/mystery-spells-and-perks/files/scripts/rename_card.lua",
  --         execute_on_added = "1",
  --         execute_every_n_frame = "5",
  --         execute_times = "20"
  --       }))
  --     ModTextFileSetContent(action.custom_xml_file, tostring(xml_element))
  --   end
  -- end


  -- FIXME: BaseにLuaComponentをセットしても、スポーン時にキックはされるがBaseの状態なのでaction_idが取れない
  -- また、BaseはあくまでもBaseなので、利用される側に上書きされる仕組み上、LuaComponentも抹消されてしまう。
  -- local normal_card = ModTextFileGetContent("data/entities/misc/custom_cards/action.xml")
  -- local custom_card = ModTextFileGetContent("data/entities/base_custom_card.xml")

  -- local xml_element_normal = nxml.parse(normal_card)
  -- local xml_element_custom = nxml.parse(custom_card)

  -- local attr_normal = xml_element_normal.attr
  -- local tags_normal = attr_normal.tags .. ", mystery_spells_need_init"
  -- xml_element_normal.attr["tags"] = tags_normal

  -- local attr_custom = xml_element_custom.attr
  -- local tags_custom = attr_custom.tags .. ", mystery_spells_need_init"
  -- xml_element_custom.attr["tags"] = tags_custom

  -- ModTextFileSetContent("data/entities/misc/custom_cards/action.xml", tostring(xml_element_normal))
  -- ModTextFileSetContent("data/entities/base_custom_card.xml", tostring(xml_element_custom))



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

local function rename_spell_entity(entity_id, action_name, action_sprite)
  -- 物理判定があるスペルの名称上書き
  local ability_component_id = EntityGetFirstComponentIncludingDisabled(
    entity_id, "AbilityComponent"
  )
  if ability_component_id then
    ComponentSetValue2(ability_component_id, "ui_name", action_name)
  end

  -- スプライト画像書き換え
  local sprite_component_id = EntityGetFirstComponentIncludingDisabled(entity_id,
    "SpriteComponent",
    "item_identified")
  if sprite_component_id then
    ComponentSetValue2(sprite_component_id, "image_file", action_sprite)
  end

  -- Item化時の画像/名前書き換え
  -- FIXME:これはカード初期化時に必ず呼び出して初期化する必要があるため、rename_card.luaで実装する!!!!
  local item_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "ItemComponent")
  if item_comp ~= nil then
    ComponentSetValue2(item_comp, "ui_sprite", action_sprite)
    ComponentSetValue2(item_comp, "item_name", action_name)
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
          local customized_action = Json.decode(customized_action_json)
          rename_spell_entity(card_entity_id, customized_action.name, customized_action.sprite)
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
