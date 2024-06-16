-- TODO:敵がパークを取ったときに、現状の特典リストの状態で上書きする
-- NOTE:Nightmareではdirector_helpers.luaに対して、敵にパークを付与する処理が追加されているが、
-- デフォルトのNoitaではgame_helper.lua内に同じ処理が書かれているため(利用はされていない)、どちらも上書きしている。
local original_give_perk_to_enemy = give_perk_to_enemy
function give_perk_to_enemy(perk_data, entity_who_picked, entity_item)
  original_give_perk_to_enemy(perk_data, entity_who_picked, entity_item)
end
