local COMMON = require "libs.common"
local StoragePart = require "world.storage.storage_part_base"

---@class ResourcePartOptions:StoragePartBase
local Storage = COMMON.class("ResourcePartOptions", StoragePart)

function Storage:initialize(...)
	StoragePart.initialize(self, ...)
	self.resource = self.storage.data.resource
end

function Storage:gems_add(v)
	checks("?", "number")
	assert(v > 0)
	self.resource.gems = math.max(self.resource.gems + v, 0)
	self:save_and_changed()
end

function Storage:gems_can_spend(v)
	checks("?", "number")
	assert(v >= 0)
	return v <= self.resource.gems
end

function Storage:gems_get()
	return self.resource.gems
end

function Storage:gems_spend(v)
	checks("?", "number")
	assert(v > 0)
	assert(v <= self.resource.gems, "not enough gems")
	self.resource.gems = self.resource.gems - v
	self:save_and_changed()
end

function Storage:food_get()
	return self.resource.food
end

function Storage:food_spend(v)
	checks("?", "number")
	assert(v > 0)
	assert(v <= self:food_get(), "not enough food")
	self.resource.food = self.resource.food - v
	self:save_and_changed()
end

function Storage:food_add(v)
	checks("?", "number")
	self.resource.food = COMMON.LUME.clamp(self.resource.food + v, 0, 5)
	self:save_and_changed()
end

return Storage