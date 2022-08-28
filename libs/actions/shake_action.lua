local COMMON = require "libs.common"
local PERLIN = require "libs.perlin"
local Action = require "libs.actions.action"

local CHECKS_CONFIG = {
	trauma = "number",
	trauma_speed = "number",
	x = "number",
	y = "number",
	perlin_power = "number",
	object = "userdata"
}

---@class ShakeAction:Action
local ShakeAction = COMMON.class("ShakeAction", Action)

function ShakeAction:config_check(config)
	checks("?", CHECKS_CONFIG)
end

function ShakeAction:initialize(config)
	Action.initialize(self, config)
	self.perlin_seeds = { math.random(256), math.random(256), math.random(256) }
	self.trauma = self.config.trauma
	self.position = go.get_position(self.config.object)
	self.time = 0
end

function ShakeAction:set_property()
	local position = vmath.vector3(self.position)

	local shake = self.trauma * self.trauma
	local lposition_x = self.config.x * shake * (PERLIN.noise(self.time * self.config.perlin_power, 0, self.perlin_seeds[1]))
	local lposition_y = self.config.y * shake * (PERLIN.noise(self.time * self.config.perlin_power, 0, self.perlin_seeds[2]))
	position.x = position.x + lposition_x
	position.y = position.y + lposition_y
	go.set_position(position, self.config.object)

end

function ShakeAction:act(dt)
	if self.config.delay then
		COMMON.coroutine_wait(self.config.delay)
	end
	while (self.trauma>0) do
		self.time = self.time + dt
		self:set_property()
		dt = coroutine.yield()
		self.trauma = self.trauma - dt*self.config.trauma_speed
	end

	go.set_position(self.position, self.config.object)
end

return ShakeAction