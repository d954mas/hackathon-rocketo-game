local COMMON = require "libs.common"
local ENUMS = require "world.enums.enums"

---@class LevelCreator
local Creator = COMMON.class("LevelCreator")

---@param world World
function Creator:initialize(world)
	self.world = world
	self.level = world.game.level
	self.ecs = world.game.ecs_game
	self.entities = world.game.ecs_game.entities
	---@type EntityGame
	self.player = nil
end

function Creator:create()
	self.ecs:refresh()
end



return Creator