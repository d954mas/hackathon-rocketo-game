local ENUMS = require "world.enums.enums"
local EQUIPMENT = ENUMS.HERO_EQUIPMENT

local M = {}

M[EQUIPMENT.SWORD] = {
	{type = EQUIPMENT.SWORD, idx = 1,  id = "WOOD", power = 1, cost = 0, level = 1, image = hash("sword_wood") },
	{type = EQUIPMENT.SWORD, idx = 2,  id = "WOOD", power = 2, cost = 100, level = 2, image = hash("sword_wood") },
	{type = EQUIPMENT.SWORD, idx = 3,  id = "WOOD", power = 3, cost = 500, level = 3, image = hash("sword_wood") },
	{type = EQUIPMENT.SWORD, idx = 4,  id = "WOOD", power = 4, cost = 1000, level = 4, image = hash("sword_wood") },
	{type = EQUIPMENT.SWORD, idx = 5,  id = "WOOD", power = 5, cost = 5000, level = 5, image = hash("sword_wood") },
}

M[EQUIPMENT.PICKAXE] = {
	{type = EQUIPMENT.PICKAXE, idx = 1,  id = "WOOD", power = 1, cost = 0, level = 1, image = hash("pickaxe_wood") },
	{type = EQUIPMENT.PICKAXE, idx = 2,  id = "WOOD", power = 2, cost = 100, level = 2, image = hash("pickaxe_wood") },
	{type = EQUIPMENT.PICKAXE, idx = 3,  id = "WOOD", power = 3, cost = 500, level = 3, image = hash("pickaxe_wood") },
	{type = EQUIPMENT.PICKAXE, idx = 4,  id = "WOOD", power = 4, cost = 1000, level = 4, image = hash("pickaxe_wood") },
	{type = EQUIPMENT.PICKAXE, idx = 5,  id = "WOOD", power = 5, cost = 5000, level = 5, image = hash("pickaxe_wood") },
}

M[EQUIPMENT.HELMET] = {
	{type = EQUIPMENT.HELMET, idx = 1,  id = "LEATHER", hp = 1, cost = 100, level = 1, image = hash("helmet_leather") },
	{type = EQUIPMENT.HELMET, idx = 2,  id = "LEATHER", hp = 2, cost = 100, level = 2, image = hash("helmet_leather") },
	{type = EQUIPMENT.HELMET, idx = 3,  id = "LEATHER", hp = 3, cost = 500, level = 3, image = hash("helmet_leather") },
	{type = EQUIPMENT.HELMET, idx = 4,  id = "LEATHER", hp = 4, cost = 1000, level = 4, image = hash("helmet_leather") },
	{type = EQUIPMENT.HELMET, idx = 5,  id = "LEATHER", hp = 5, cost = 5000, level = 5, image = hash("helmet_leather") },
}

M[EQUIPMENT.ARMOR] = {
	{type = EQUIPMENT.ARMOR, idx = 1,  id = "LEATHER", hp = 1, cost = 100, level = 1, image = hash("armor_leather") },
	{type = EQUIPMENT.ARMOR, idx = 2,  id = "LEATHER", hp = 2, cost = 100, level = 2, image = hash("armor_leather") },
	{type = EQUIPMENT.ARMOR, idx = 3,  id = "LEATHER", hp = 3, cost = 500, level = 3, image = hash("armor_leather") },
	{type = EQUIPMENT.ARMOR, idx = 4,  id = "LEATHER", hp = 4, cost = 1000, level = 4, image = hash("armor_leather") },
	{type = EQUIPMENT.ARMOR, idx = 5,  id = "LEATHER", hp = 5, cost = 5000, level = 5, image = hash("armor_leather") },
}

M[EQUIPMENT.PANTS] = {
	{type = EQUIPMENT.PANTS, idx = 1,  id = "LEATHER", hp = 1, cost = 100, level = 1, image = hash("pants_leather") },
	{type = EQUIPMENT.PANTS, idx = 2,  id = "LEATHER", hp = 2, cost = 100, level = 2, image = hash("pants_leather") },
	{type = EQUIPMENT.PANTS, idx = 3,  id = "LEATHER", hp = 3, cost = 500, level = 3, image = hash("pants_leather") },
	{type = EQUIPMENT.PANTS, idx = 4,  id = "LEATHER", hp = 4, cost = 1000, level = 4, image = hash("pants_leather") },
	{type = EQUIPMENT.PANTS, idx = 5,  id = "LEATHER", hp = 5, cost = 5000, level = 5, image = hash("pants_leather") },
}

M[EQUIPMENT.BOOTS] = {
	{type = EQUIPMENT.BOOTS, idx = 1,  id = "LEATHER", hp = 1, cost = 100, level = 1, image = hash("boots_leather") },
	{type = EQUIPMENT.BOOTS, idx = 2,  id = "LEATHER", hp = 2, cost = 100, level = 2, image = hash("boots_leather") },
	{type = EQUIPMENT.BOOTS, idx = 3,  id = "LEATHER", hp = 3, cost = 500, level = 3, image = hash("boots_leather") },
	{type = EQUIPMENT.BOOTS, idx = 4,  id = "LEATHER", hp = 4, cost = 1000, level = 4, image = hash("boots_leather") },
	{type = EQUIPMENT.BOOTS, idx = 5,  id = "LEATHER", hp = 5, cost = 5000, level = 5, image = hash("boots_leather") },
}


return M