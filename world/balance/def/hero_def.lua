local M = {}

M.LEVELS = {
	{ exp = 0, hp = 15, attack = 1, energy = 1, skill_points = 0 }, -- first level
	{ exp = 10, hp = 20, attack = 2, energy = 1, skill_points = 1 },
	{ exp = 15, hp = 25, attack = 2, energy = 2, skill_points = 2 },
	{ exp = 20, hp = 30, attack = 2, energy = 2, skill_points = 3 },
	{ exp = 25, hp = 35, attack = 2, energy = 2, skill_points = 4 }, --5
	{ exp = 30, hp = 40, attack = 2, energy = 2, skill_points = 5 },
	{ exp = 35, hp = 45, attack = 2, energy = 2, skill_points = 6 },
	{ exp = 40, hp = 50, attack = 2, energy = 2, skill_points = 7 },
	{ exp = 45, hp = 55, attack = 2, energy = 2, skill_points = 8 },
	{ exp = 100, hp = 60, attack = 2, energy = 2, skill_points = 9 }, --10
}

return M