local VALUES = dofile_once("mods/mystery-spells-and-perks/files/scripts/variables.lua")
dofile_once("mods/mystery-spells-and-perks/files/scripts/lib/utilities.lua")

print("mystery-spells-and-perks load")

ModLuaFileAppend("data/scripts/gun/gun_actions.lua",
  "mods/mystery-spells-and-perks/files/scripts/append/gun_actions.lua")
ModLuaFileAppend("data/scripts/perks/perk_list.lua",
  "mods/mystery-spells-and-perks/files/scripts/append/perk_list.lua")

function OnModPreInit()
end

function OnModInit()
end

function OnModPostInit()
end

function OnWorldInitialized()
  GameAddFlagRun(VALUES.IS_GAME_START)
end

function OnPlayerSpawned(player_entity)
end

function OnWorldPreUpdate()
end

function OnWorldPostUpdate() -- This is called every time the game has finished updating the world
end

function OnMagicNumbersAndWorldSeedInitialized()
end

local content = ModTextFileGetContent("data/translations/common.csv")
local mystery_spells_and_perks_content = ModTextFileGetContent(
  "mods/mystery-spells-and-perks/files/translations/common.csv")
ModTextFileSetContent("data/translations/common.csv", content .. mystery_spells_and_perks_content)

print("mystery-spells-and-perks loaded")
