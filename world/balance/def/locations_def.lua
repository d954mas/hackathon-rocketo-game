local CARDS_DEF = require "world.balance.def.cards_def"
local CARDS = CARDS_DEF.CARDS
local CARDS_BATTLE = CARDS.BATTLE
local CARDS_RES = CARDS.RESOURCES

local M = {}

M.WORLDS = {
	{ id = "FOREST", levels = {
		{ id = "FOREST_1",
		  config = { count = { min = 10, max = 12 },
					 cards = {
						 { def = CARDS_BATTLE.ZOMBIE_1, count = 15, min = 1, max = 20 },
						 { def = CARDS_RES.GEMS_1, count = 15, min = 2, max = 20 },
					 }
		  }
		},
		{ id = "FOREST_2", config = {} },
		{ id = "FOREST_3", config = {} },
	} },
	{ id = "CAVE", levels = {
		{ id = "CAVE_1", config = {} },
		{ id = "CAVE_2", config = {} },
		{ id = "CAVE_3", config = {} },
	} },
	{ id = "CAVE_DEEP", levels = {
		{ id = "CAVE_DEEP_1", config = {} },
		{ id = "CAVE_DEEP_2", config = {} },
		{ id = "CAVE_DEEP_3", config = {} },
	} }

}

M.LOCATION_BY_ID = {}

for i, world in ipairs(M.WORLDS) do
	for _, location in ipairs(world.levels) do
		assert(not M.LOCATION_BY_ID[location.id])
		M.LOCATION_BY_ID[location.id] = location
	end
end

return M