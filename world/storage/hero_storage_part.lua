local COMMON = require "libs.common"
local DEFS = require "world.balance.def.defs"
local StoragePart = require "world.storage.storage_part_base"

---@class ResourcePartHero:StoragePartBase
local Storage = COMMON.class("ResourcePartHero", StoragePart)

function Storage:initialize(...)
	StoragePart.initialize(self, ...)
	self.hero = self.storage.data.hero
end

function Storage:level_get()
	return self.hero.level
end

function Storage:level_is_max()
	return self.hero.level == self:level_max_get()
end

function Storage:level_max_get()
	return #DEFS.HERO.LEVELS
end

function Storage:exp_get()
	return self.hero.exp
end

function Storage:exp_add(v)
	checks("?", "number")
	assert(v > 0)
	self.hero.exp = self.hero.exp + v
	self:level_up()
	self:save_and_changed()
end

function Storage:exp_next_get()
	if (self:level_is_max()) then
		return math.huge
	else
		return DEFS.HERO.LEVELS[self:level_get() + 1].exp
	end
end

function Storage:level_up()
	local current = self:exp_get()
	local next = self:exp_next_get()
	local level_before = self:level_get()
	while (current >= next) do
		self.hero.exp = current - next
		self.hero.level = self.hero.level + 1

		current = self:exp_get()
		next = self:exp_next_get()
	end
	if (level_before ~= self:level_get()) then
		self:save_and_changed()
	end
end
return Storage