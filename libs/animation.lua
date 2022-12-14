local COMMON = require "libs.common"

---@class AnimationConfig
---@field frames hash[]
---@field fps number
---@field loops number|nil nil - once.number - times. <= 0 infinity
---@field playback string

---@class Animation
local Anim = COMMON.class("Animation")
Anim.PLAYBACK = {
	FORWARD = "FORWARD",
	BACKWARD = "BACKWARD",
	PING_PONG = "PING_PONG",

}

local MOD_F = math.modf
local MAX = math.max
local CEIL = math.ceil
---@param config AnimationConfig
function Anim:initialize(config)
	self.loops = 0
	self.time = 0
	self.frames = {}
end

function Anim:set_config(config)
	assert(config)
	self.frames = assert(config.frames)
	self.frames_length = #self.frames
	assert(#config.frames > 0)
	self.fps = assert(config.fps)
	self.duration = #self.frames / self.fps
	self.playback = config.playback or Anim.PLAYBACK.FORWARD
	self.loops = math.ceil(config.loops or 1)
	if self.loops == 0 then self.loops = -1 end
	self.time = 0
	-- self.subject = COMMON.RX.BehaviorSubject.create()
	self.frame_idx = self.playback == Anim.PLAYBACK.BACKWARD and #self.frames or 1
	--  self.subject:onNext(self:get_frame())
end

function Anim:dispose()
	-- self.subject:onCompleted()
	self.loops = 0
	self.time = 0
end

function Anim:restart(loops)
	self.loops = loops or self.loops
	if self.loops == 0 then self.loops = 1 end
	self.time = 0
	self.frame_idx = 1
	--  self.subject:onNext(self:get_frame())
end

function Anim:is_finished() return self.loops == 0 end
function Anim:update(dt)
	if self:is_finished() then return end
	self.time = self.time + dt
	local a = self.time / self.duration
	if self.playback == Anim.PLAYBACK.PING_PONG then a = a / 2 end

	local full, part = math.modf(a)
	if self.playback == Anim.PLAYBACK.FORWARD then a = part
	elseif self.playback == Anim.PLAYBACK.BACKWARD then a = 1 - part
	elseif self.playback == Anim.PLAYBACK.PING_PONG then
		a = a * 2
		if a > 1 then
			a = 2 - a
		end
	end

	if full >= 1 then
		self.time = self.time - self.duration * full
		self.loops = self.loops - 1
	end

	--clamp last frame
	if self.loops == 0 then
		if self.playback == Anim.PLAYBACK.BACKWARD or self.playback == Anim.PLAYBACK.PING_PONG then
			a = 0
		elseif self.playback == Anim.PLAYBACK.FORWARD then
			a = 1
		end
	end
	self.frame_idx = math.max(1, math.ceil(#self.frames * a))
end

--for enemies
function Anim:fast_update(dt)
	if  self.loops == 0 then return end
	self.time = self.time + dt
	local a = self.time / self.duration
	local full, part =MOD_F(a)
	a = part


	if full >= 1 then
		self.time = self.time - self.duration * full
		self.loops = self.loops - 1
	end
	--clamp last frame
	if self.loops == 0 then
		a = 1
	end

	self.frame_idx = MAX(1,CEIL( self.frames_length * a))
end

function Anim:get_frame()
	return self.frames[self.frame_idx]
end

return Anim

