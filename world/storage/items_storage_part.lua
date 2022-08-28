local COMMON = require "libs.common"
local EQUIPMENTS_DEF = require "world.balance.def.equipments_def"
local ENUMS = require "world.enums.enums"
local StoragePart = require "world.storage.storage_part_base"

local ENUM_TO_KEY = {
	[ENUMS.HERO_EQUIPMENT.ARMOR] = "armor",
	[ENUMS.HERO_EQUIPMENT.HELMET] = "helmet",
	[ENUMS.HERO_EQUIPMENT.PANTS] = "pants",
	[ENUMS.HERO_EQUIPMENT.BOOTS] = "boots",
	[ENUMS.HERO_EQUIPMENT.SWORD] = "sword",
	[ENUMS.HERO_EQUIPMENT.PICKAXE] = "pickaxe",
}

---@class ItemsPartOptions:StoragePartBase
local Storage = COMMON.class("ItemsPartOptions", StoragePart)

function Storage:initialize(...)
	StoragePart.initialize(self, ...)
	self.items = self.storage.data.items
end

function Storage:__enum_to_key(item)
	assert(item)
	assert(ENUMS.HERO_EQUIPMENT[item])
	return assert(ENUM_TO_KEY[item])

end

function Storage:item_get_level(item)
	local key = self:__enum_to_key(item)
	return self.items[key]
end

function Storage:item_is_max(item)
	return self:item_get_level(item) >= #EQUIPMENTS_DEF[item]
end

function Storage:item_get_cost(item)
	local level = self:item_get_level(item) + 1
	if self:item_is_max(item) then return math.huge end

	return assert(EQUIPMENTS_DEF[item][level]).cost
end

function Storage:item_upgrade(item)
	local key = self:__enum_to_key(item)
	local cost = self:item_get_cost(item)
	local level = self:item_get_level(item)
	if (self.storage.resource:gems_can_spend(cost) and EQUIPMENTS_DEF[item][level + 1]) then
		self.storage.resource:gems_spend(cost)
		self.items[key] = self.items[key] + 1
		self:save_and_changed()
	end
end

return Storage