local COMMON = require "libs.common"
local SKILLS_DEF = require "world.balance.def.skills_def"
local SKILLS = require "world.balance.skills"
local ENUMS = require "world.enums.enums"
local StoragePart = require "world.storage.storage_part_base"

---@class UpgradesPartOptions:StoragePartBase
local Storage = COMMON.class("SkillsPartOptions", StoragePart)

function Storage:initialize(...)
	StoragePart.initialize(self, ...)
	self.skills = self.storage.data.skills

end

function Storage:get_state_by_id(id)
	local def = assert(SKILLS_DEF.skill_by_id[id])
	local line_def = assert(def.line)
	local storage_line = assert(self.skills[line_def.id])
	assert(storage_line)

	if (storage_line.skills >= def.idx) then return ENUMS.SKILL_STATE.BOUGHT
	elseif (storage_line.skills == def.idx - 1) then return ENUMS.SKILL_STATE.AVAILABLE end

	return ENUMS.SKILL_STATE.LOCKED
end

function Storage:unlock_by_id(id)
	local def = assert(SKILLS_DEF.skill_by_id[id])
	local state = self:get_state_by_id(id)
	local line_def = assert(def.line)
	local storage_line = assert(self.skills[line_def.id])

	if (state == ENUMS.SKILL_STATE.AVAILABLE) then
		local cost = def.cost
		if (cost <= SKILLS:get_points(self.world)) then
			storage_line.skills = storage_line.skills + 1

			self:save_and_changed()
		end

	end
end

function Storage:reset()
	for _, line in pairs(self.skills) do
		line.skills = 0
	end
	self:save_and_changed()
end

return Storage