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

-- NOTE:
-- 既存の翻訳ファイルから取得してくる場合、処理が重すぎたので事前に抽出する方法に変更した
-- 既存のNoita翻訳(Epilogue2)以降に追加されたものをチェックして取得する
local function create_dummy_description(content)
  local perk_desc_lines = {}
  for line in content:gmatch("[^\r\n]+") do
    if line:find("^perkdesc_") then
      table.insert(perk_desc_lines, line)
    end
  end

  return perk_desc_lines
end

-- NOTE:
-- 正しい特典説明文を7割の確率で表示させるための処理
local function pick_maybe_correct_perk_description(index, perk_desc_lines)
  local target_index = math.random(1, #perk_desc_lines)
  if target_index == index then
    if target_index >= #perk_desc_lines then
      target_index = target_index - 1
    else
      target_index = target_index + 1
    end
  end

  if math.random(1, 10) <= 7 then
    return perk_desc_lines[index]
  else
    return perk_desc_lines[target_index]
  end
end

local function append_to_translate_csv()
  -- NOTE:
  -- 日付をSeedにするので、再起動を繰り返した場合Seedも変更される
  local year, month, day, hour, minute, second = GameGetDateAndTimeUTC()
  local date = tonumber(tostring(year) ..
    tostring(month) .. tostring(day) .. tostring(hour) .. tostring(minute) .. tostring(second))
  math.randomseed(date)

  local content = ModTextFileGetContent("data/translations/common.csv")
  local perk_desc_lines = create_dummy_description(content)

  local append_translations = {}
  for index, perk_desc in ipairs(perk_desc_lines) do
    print(perk_desc)
    local maybe_correct_perk_desc      = pick_maybe_correct_perk_description(index, perk_desc_lines)
    local splited_translate_keys       = split(perk_desc, ",")
    local maybe_correct_translate_keys = split(maybe_correct_perk_desc, ",")
    local key                          = 'mystery_spells_and_perks' .. '.' .. splited_translate_keys[1]
    local append_en_text               = '==This perk might possibly be something like the following=='
    local append_jp_text               = '==この特典はおそらく以下の説明文のようなものです=='
    local jp_description               = maybe_correct_translate_keys[11] or maybe_correct_translate_keys[2]
    local en_text                      = '"' .. append_en_text .. '\\n' .. maybe_correct_translate_keys[2] .. '"'
    local jp_text                      = '"' .. append_jp_text .. '\\n' .. jp_description .. '"'
    local result                       = key .. ',' .. en_text .. ',,,,,,,,,' .. jp_text .. ',,,,,,,,,,,,,,' .. '\n'
    table.insert(append_translations, result)
  end

  local append_text = table.concat(append_translations, '')

  local mystery_spells_and_perks_content = ModTextFileGetContent(
    "mods/mystery-spells-and-perks/files/translations/common.csv")

  ModTextFileSetContent("data/translations/common.csv", content .. append_text .. mystery_spells_and_perks_content)
end

append_to_translate_csv()
