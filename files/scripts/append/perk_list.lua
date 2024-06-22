local mystify_perks = ModSettingGet('mystery_spells_and_perks.mystify_perks') or false

if not mystify_perks then
  return
end

SetRandomSeed(1, 2)

local custom_names = {}

local function get_custom_name()
  if next(custom_names) == nil then
    custom_names = dofile("mods/mystery-spells-and-perks/files/scripts/custom_perk_name.lua")
  end

  local index = Random(1, #custom_names)
  local random_name = custom_names[index]
  table.remove(custom_names, index)
  return random_name
end


local function get_dummy_description_key(key)
  local custom_description_names = dofile("mods/mystery-spells-and-perks/files/scripts/custom_perk_description_name.lua")

  local target_index = Random(1, #custom_description_names)
  if custom_description_names[target_index] == key then
    if target_index >= #custom_description_names then
      target_index = target_index - 1
    else
      target_index = target_index + 1
    end
  end

  return custom_description_names[target_index]
end

-- NOTE:
-- 正しい特典説明文を7割の確率で表示させるための処理
-- 既存の翻訳ファイルから取得してくる場合を実装していたが、NoitaがBootする前にcsvを埋め込む必要があった。
-- Seed依存のRandom関数を使えないため、再起動でテキストが変更されるという問題があることから、固定のdescription群から取得してくる方法に変更した
local function pick_maybe_correct_perk_description(key)
  if Random(1, 10) >= 8 then
    return get_dummy_description_key(key)
  end

  return key
end

local secret_perk = {
  id = "MYSTERY_SECRET_PERK",
  ui_name = "$perk_mystery_secret_perk",
  ui_description = "$perkdesc_mystery_secret_perk",
  ui_icon = "mods/mystery-spells-and-perks/files/ui_gfx/secret_perk_icon.png",
  perk_icon = "mods/mystery-spells-and-perks/files/ui_gfx/secret_perk_icon.png",
  stackable = STACKABLE_NO,
  stackable_maximum = 0,
  max_in_perk_pool = 2,
  stackable_is_rare = false,
  usable_by_enemies = false,
}

for i = 1, #perk_list do
  local original_func = perk_list[i].func

  local custom_perk_description_key = '$mystery_spells_and_perks' .. string.gsub(perk_list[i].ui_description, '%$', ".")

  perk_list[i].func = original_func
  perk_list[i].ui_name = get_custom_name()
  perk_list[i].ui_icon = secret_perk.ui_icon
  perk_list[i].ui_description = pick_maybe_correct_perk_description(custom_perk_description_key)
  perk_list[i].perk_icon = secret_perk.perk_icon
end
