local VALUES = dofile_once("mods/mystery-spells-and-perks/files/scripts/variables.lua")
local Json = dofile_once("mods/mystery-spells-and-perks/files/scripts/lib/jsonlua/json.lua")

local json = ModSettingGet(VALUES.NEED_UPDATE_SPELL_ENTITIES) or "{}"
local entities = Json.decode(json)
local entity_id = GetUpdatedEntityID()
table.insert(entities, entity_id)
ModSettingSet(VALUES.NEED_UPDATE_SPELL_ENTITIES, Json.encode(entities))
