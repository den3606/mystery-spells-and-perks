local mystify_spells = ModSettingGet('mystery_spells_and_perks.mystify_spells') or false
local VALUES = dofile_once("mods/mystery-spells-and-perks/files/scripts/variables.lua")

if not mystify_spells then
  return
end

SetRandomSeed(1, 2)

local custom_names = {}

local function get_custom_name()
  if next(custom_names) == nil then
    custom_names = dofile("mods/mystery-spells-and-perks/files/scripts/custom_spell_name.lua")
  end

  local index = Random(1, #custom_names)
  local random_name = custom_names[index]
  table.remove(custom_names, index)
  return random_name
end


-- debug
local custom_names_tmp = dofile("mods/mystery-spells-and-perks/files/scripts/custom_spell_name.lua")
function removeDuplicates(inputTable)
  local seen = {}
  local result = {}

  for _, value in ipairs(inputTable) do
    if not seen[value] then
      seen[value] = true
      table.insert(result, value)
    end
  end

  return result
end

local tmp = {}
for index, value in ipairs(custom_names_tmp) do
  local name1 = GameTextGetTranslatedOrNot(value)
  local count = 0
  for index, value2 in ipairs(custom_names_tmp) do
    local name2 = GameTextGetTranslatedOrNot(value2)
    if name1 == name2 then
      count = count + 1
    end
  end

  if count > 1 then
    table.insert(tmp, value)
  end
end
local tmp2 = removeDuplicates(tmp)
for index, value in ipairs(tmp2) do
  print(value)
end


local secret_spell = {
  id = "MYSTERY_SECRET_SPELL",
  description = "$actiondesc_mystery_secret_spell",
  sprite = "mods/mystery-spells-and-perks/files/ui_gfx/secret_spell_icon.png",
  sprite_unidentified = "mods/mystery-spells-and-perks/files/ui_gfx/secret_spell_icon.png",
  type = ACTION_TYPE_OTHER,
  spawn_level = "100",
  spawn_probability = "0",
  price = 0,
  mana = 0,
}

for i = 1, #actions do
  local original_sprite = actions[i].sprite
  local original_action = actions[i].action

  actions[i].original_action = original_action
  actions[i].original_sprite = original_sprite
  actions[i].sprite = secret_spell.sprite
  actions[i].name = get_custom_name()
  actions[i].description = secret_spell.description
  actions[i].action = function()
    if GameHasFlagRun(VALUES.IS_GAME_START) then
      actions[i].original_action()
    end
  end

  -- if not actions[i].custom_xml_file then
  --   actions[i].custom_xml_file =
  --   "data/entities/misc/custom_cards/action.xml"
  -- end

  -- TODO: Option
  -- NOTE:Typeも隠すと、杖生成のときにタイプで判断しているのでスペルが取得できなくなる
  -- actions[i].type = (function()
  --   if GameHasFlagRun(VALUES.IS_GAME_START) then
  --     return original_type
  --   else
  --     return secret_spell.type
  --   end
  -- end)()
  -- actions[i].mana = secret_spell.mana
end
