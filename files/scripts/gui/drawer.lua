local VALUES = dofile_once("mods/mystery-spells-and-perks/files/scripts/variables.lua")

local function string_to_number(str)
  local num = 0
  for i = 1, #str do
    local char = string.sub(str, i, i)
    num = num + string.byte(char)
  end
  return num
end


local keys = {}
-- TODO: USE GuiIdPush
local function new_id(key)
  if keys[key] ~= nil then
    return keys[key]
  end

  local global_gui_id = tonumber(ModSettingGet(VALUES.GLOBAL_GUI_ID)) or 0
  if global_gui_id == 0 then
    global_gui_id = string_to_number(VALUES.MOD_NAME) + 5000
  end

  keys[key] = global_gui_id
  global_gui_id = global_gui_id + 1

  ModSettingSet(VALUES.GLOBAL_GUI_ID, tostring(global_gui_id))

  return global_gui_id
end

return {
  string_to_number = string_to_number,
  new_id = new_id
}
