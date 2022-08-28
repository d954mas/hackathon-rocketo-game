local COMMON = require "libs.common"
local DEFS = require "world.balance.def.defs"
local HEROES = require "world.balance.hero"
local ENUMS = require "world.enums.enums"

local Location = {}

local TAG = "LOCATION_B"

local function _add_card(state, card_id, cards_counter)
	local count = assert(cards_counter[card_id], card_id)
	if (count < 0) then return end

	table.insert(state.cards, card_id)
	cards_counter[card_id] = cards_counter[card_id] - 1
end

function Location:generate_state(world, location_def)
	COMMON.i("generate_state:" .. location_def.id, TAG)

	local config = location_def.config
	local state = { location = location_def.id }
	state.hero = {
		hp = HEROES:get_hp(world),
		equipment = {
			[ENUMS.HERO_EQUIPMENT.HELMET] = {hp = 0},
			[ENUMS.HERO_EQUIPMENT.ARMOR] = {hp = 0},
			[ENUMS.HERO_EQUIPMENT.PANTS] = {hp = 0},
			[ENUMS.HERO_EQUIPMENT.BOOTS] = {hp = 0},
		}
	}
	state.cards_total = math.random(config.count.min, config.count.max)
	state.cards = {}

	COMMON.i("cards total:" .. state.cards_total, TAG)

	local cards_pool = {}
	local cards_counter = {}

	for _, card in ipairs(config.cards) do
		cards_counter[card.def.id] = card.max or math.huge
		if (card.min) then
			for i = 1, card.min do
				_add_card(state, card.def.id, cards_counter)
			end
		end
		for i = 1, (card.count - (card.min or 0)) do
			table.insert(cards_pool, card.def.id)
		end
	end

	--shuffle pool
	cards_pool = COMMON.LUME.shuffle(cards_pool)

	COMMON.i("Pool.Count" .. #cards_pool, TAG)
	COMMON.i("Pool.Cards:" .. COMMON.LUME.serialize(cards_pool), TAG)

	while (#cards_pool > 0 and #state.cards < state.cards_total) do
		local card_id = table.remove(cards_pool)
		_add_card(state, card_id, cards_counter)
	end

	if (#state.cards < state.cards_total) then
		COMMON.w("generate less cards.Need:" .. state.cards_total .. " Get:" .. #state.cards)
		state.cards_total = #state.cards
	end

	state.cards = COMMON.LUME.shuffle(state.cards)

	COMMON.i("Cards.Count:" .. #state.cards, TAG)
	COMMON.i("Cards:" .. COMMON.LUME.serialize(state.cards), TAG)

	return state
end

return Location