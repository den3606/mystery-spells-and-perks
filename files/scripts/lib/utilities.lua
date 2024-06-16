function Split(str, sep)
  if sep == nil then
    return {}
  end

  local t = {}

  local i = 1
  for s in string.gmatch(str, "([^" .. sep .. "]+)") do
    t[i] = s
    i = i + 1
  end

  return t
end

function ShuffleArray(array)
  local shuffled = {}
  for i = 1, #array do
    shuffled[i] = array[i]
  end

  SetRandomSeed(GameGetFrameNum(), GameGetFrameNum())

  for i = #shuffled, 2, -1 do
    local j = Random(1, i)
    shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
  end

  return shuffled
end

dofile_once("mods/mystery-spells-and-perks/files/scripts/lib/utils/variable_storage.lua")
dofile_once("mods/mystery-spells-and-perks/files/scripts/lib/utils/player.lua")
dofile_once("mods/mystery-spells-and-perks/files/scripts/lib/utils/calculate.lua")
dofile_once("mods/mystery-spells-and-perks/files/scripts/lib/utils/extend_xml.lua")

-- has dependent
dofile_once("mods/mystery-spells-and-perks/files/scripts/lib/utils/wait_frame.lua")
dofile_once("mods/mystery-spells-and-perks/files/scripts/lib/utils/sound_player.lua")
