local DEFS = require "world.balance.def.defs"
local SKILLS_DEF = require "world.balance.def.skills_def"
local ENUMS = require "world.enums.enums"

local Skills = {}

function Skills:get_points_all(world)
	local level = world.storage.hero:level_get()
	local points = 0
	for i = 1, level do
		points =  DEFS.HERO.LEVELS[i].skill_points
	end

	return points
end

---@param world World
function Skills:get_points(world)
	local points = self:get_points_all(world)
	for line_id, line in pairs(world.storage.data.skills) do
		local def = SKILLS_DEF.line_by_id[line_id]
		if (def) then
			for i = 1, line.skills do
				points = points - def.skills[i].cost
			end
		end
	end
	return points
end

return Skills