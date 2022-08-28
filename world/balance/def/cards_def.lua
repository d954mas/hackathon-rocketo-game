local ENUMS = require "world.enums.enums"

local TYPE = ENUMS.CARD_TYPE
local RES = ENUMS.RESOURCES

local M = {}

M.CARDS = {
	BATTLE = {
		ZOMBIE_1 = { id = "ZOMBIE_1", type = TYPE.BATTLE, icon = hash("empty"),
					 config = { attack = 5, hp = 5, exp = 2 }
		}
	},
	RESOURCES = {
		GEMS_1 = { id = "GEMS_1", type = TYPE.RESOURCES, icon = hash("empty"),
				   config = { resources = { { type = RES.GEMS, min = 10, max = 15 } } }
		}
	}
}

M.BY_ID = {

}

for _,set in pairs(M.CARDS)do
	for card_id,card in pairs(set)do
		assert(card_id == card.id , "bad id".. card_id)
		assert(not M.BY_ID[card_id], "card:" .. card_id .. " already exist")
		M.BY_ID[card_id] = card
	end
end

return M