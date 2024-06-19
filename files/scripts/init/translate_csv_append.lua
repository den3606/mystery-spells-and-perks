local content = ModTextFileGetContent("data/translations/common.csv")

-- NOTE:
-- 日付をSeedにするので、再起動を繰り返した場合Seedも変更される
local year, month, day, hour, minute, second = GameGetDateAndTimeUTC()
local date = tonumber(tostring(year) ..
  tostring(month) .. tostring(day) .. tostring(hour) .. tostring(minute) .. tostring(second))
math.randomseed(date)

local function split(line, delimiter)
  local fields = {}
  local field = ""
  local inQuotes = false
  delimiter = delimiter or ','

  for i = 1, #line do
    local char = line:sub(i, i)
    if char == '"' then
      if line:sub(i + 1, i + 1) == '"' then
        field = field .. line:sub(i, i + 1)
        i = i + 1
      else
        inQuotes = not inQuotes
      end
    elseif char == delimiter and not inQuotes then
      table.insert(fields, field)
      field = ""
    else
      field = field .. char
    end
  end
  table.insert(fields, field)

  return fields
end

local perk_desc_lines = {}
for line in content:gmatch("[^\r\n]+") do
  if line:find("^perkdesc_") then
    table.insert(perk_desc_lines, line)
  end
end

local append_translations = {}
for i, perk_desc in ipairs(perk_desc_lines) do
  -- NOTE:
  -- 正しい特典説明文を8割の確率で表示させるための処理
  -- 2割で別のパークの翻訳行を取得してくる
  local target_index = math.random(1, #perk_desc_lines)
  if target_index == i then
    if target_index >= #perk_desc_lines then
      target_index = target_index - 1
    else
      target_index = target_index + 1
    end
  end

  local maybe_correct_perk_desc = ""
  if math.random(1, 10) <= 8 then
    maybe_correct_perk_desc = perk_desc_lines[i]
  else
    maybe_correct_perk_desc = perk_desc_lines[target_index]
  end


  local splited_translate_keys       = split(perk_desc, ",")
  local maybe_correct_translate_keys = split(maybe_correct_perk_desc, ",")
  local key                          = 'mystery_spells_and_perks' .. '.' .. splited_translate_keys[1]
  local append_en_text               = '==This perk might possibly be something like the following=='
  local append_jp_text               = '==この特典はおそらく以下の説明文のようなものです=='

  local en_text                      = '"' .. append_en_text .. '\\n' .. maybe_correct_translate_keys[2] .. '"'
  local jp_text                      = '"' .. append_jp_text .. '\\n' .. maybe_correct_translate_keys[11] .. '"'
  local result                       = key .. ',' .. en_text .. ',,,,,,,,,' .. jp_text .. ',,,,,,,,,,,,,,' .. '\n'
  table.insert(append_translations, result)
end

local append_text = table.concat(append_translations, '')

local mystery_spells_and_perks_content = ModTextFileGetContent(
  "mods/mystery-spells-and-perks/files/translations/common.csv")

ModTextFileSetContent("data/translations/common.csv", content .. append_text .. mystery_spells_and_perks_content)
