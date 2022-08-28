local LOCATIONS_DEF = require "world.balance.def.locations_def"
local HERO_DEF = require "world.balance.def.hero_def"
local EQUIPMENTS_DEF = require "world.balance.def.equipments_def"
local SKILLS_DEF = require "world.balance.def.skills_def"
local CARDS_DEF = require "world.balance.def.cards_def"

local M = {}
M.LOCATIONS = LOCATIONS_DEF
M.HERO = HERO_DEF
M.EQUIPMENTS = EQUIPMENTS_DEF
M.SKILLS = SKILLS_DEF
M.CARDS = CARDS_DEF

return M