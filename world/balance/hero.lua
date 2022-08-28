local DEFS = require "world.balance.def.defs"

local Hero = {}

function Hero:get_attack(world)
	local level = world.storage.hero:level_get()
	local hero_def = DEFS.HERO.LEVELS[level]

	return hero_def.attack
end

function Hero:get_hp(world)
	local level = world.storage.hero:level_get()
	local hero_def = DEFS.HERO.LEVELS[level]

	return hero_def.hp
end

function Hero:get_energy(world)
	local level = world.storage.hero:level_get()
	local hero_def = DEFS.HERO.LEVELS[level]

	return hero_def.energy
end

return Hero