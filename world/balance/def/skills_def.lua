local M = {
	{ id = "line_1", -- first line
	  skills = {
		  { id = "heavy_hand_1", icon = hash("empty"), cost = 1 },
		  { id = "heavy_hand_2", icon = hash("empty"), cost = 1 },
		  { id = "heavy_hand_3", icon = hash("empty"), cost = 2 },
		  { id = "heavy_hand_4", icon = hash("empty"), cost = 2 },
		  { id = "heavy_hand_5", icon = hash("empty"), cost = 3 },
		  { id = "heavy_hand_6", icon = hash("empty"), cost = 3 },
	  }
	},

	{ id = "line_2",
	  skills = {
		  { id = "line_2_1", icon = hash("empty"), cost = 1 },
		  { id = "line_2_2", icon = hash("empty"), cost = 2 },
		  { id = "line_2_3", icon = hash("empty"), cost = 3 },
		  { id = "line_2_4", icon = hash("empty"), cost = 4 },
		  { id = "line_2_5", icon = hash("empty"), cost = 5 },
		  { id = "line_2_6", icon = hash("empty"), cost = 6 },
	  }
	},

	{ id = "line_3",
	  skills = {
		  { id = "line_3_1", icon = hash("empty"), cost = 2 },
		  { id = "line_3_2", icon = hash("empty"), cost = 2 },
		  { id = "line_3_3", icon = hash("empty"), cost = 2 },
		  { id = "line_3_4", icon = hash("empty"), cost = 2 },
		  { id = "line_3_5", icon = hash("empty"), cost = 2 },
		  { id = "line_3_6", icon = hash("empty"), cost = 2 },
	  }
	},

	{ id = "line_4",
	  skills = {
		  { id = "line_4_1", icon = hash("empty"), cost = 1 },
		  { id = "line_4_2", icon = hash("empty"), cost = 2 },
		  { id = "line_4_3", icon = hash("empty"), cost = 1 },
		  { id = "line_4_4", icon = hash("empty"), cost = 2 },
		  { id = "line_4_5", icon = hash("empty"), cost = 1 },
		  { id = "line_4_6", icon = hash("empty"), cost = 2 },
	  }
	},
}

M.skill_by_id = {}
M.line_by_id = {}

for _, line in ipairs(M) do
	assert(not M.line_by_id[line.id], "line:" .. line.id .. " already exist")
	M.line_by_id[line.id] = line
	for idx, skill in ipairs(line.skills) do
		skill.line = line
		skill.idx = idx
		assert(not M.skill_by_id[skill.id], "skill:" .. skill.id .. " already exist")
		M.skill_by_id[skill.id] = skill
	end
end

return M