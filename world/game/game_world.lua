local COMMON = require "libs.common"
local EcsGame = require "world.game.ecs.game_ecs"
local CommandExecutor = require "world.commands.command_executor"
local ENUMS = require "world.enums.enums"
local CAMERAS = require "libs_project.cameras"
local DEBUG_INFO = require "debug.debug_info"
local ACTIONS = require "libs.actions.actions"
local DEFS = require "world.balance.def.defs"
local LOCATION_BALANCE = require "world.balance.location"
local YA = require "libs.yagames.yagames"
local TWEEN = require "libs.tween"
local COMMANDS = require "world.game.command.commands"
local LevelCreator = require "world.game.levels.level_creator"

local TAG = "GAME_WORLD"

---@class GameWorld
local GameWorld = COMMON.class("GameWorld")

---@param world World
function GameWorld:initialize(world)
	self.world = assert(world)
	self.ecs_game = EcsGame(self.world)
	self.command_executor = CommandExecutor()
	self.event_bus = COMMON.EventBus()
	self.input = {
		type = ENUMS.GAME_INPUT.NONE,
		start_time = socket.gettime(),
		move_delta = 0,
		handle_long_tap = false,
		---@type vector3 screen coords
		touch_pos = nil,
		touch_pos_2 = nil,
		touch_pos_dx = nil,
		touch_pos_dy = nil,
		t1_pressed = nil,
		t2_pressed = nil,
		zoom_point = nil,
		zoom_line_len = nil,
		zoom_initial = nil,
		drag = {
			valid = false,
			movable = false
		}
	}
	self.input.drag = nil
	self.camera_config = {
		borders = {
			x_min = 0, x_max = 0,
			y_min = 0, y_max = 0,
		},
		zoom = {
			current = 1,
			max = 5, min = 0.5
		}
	}
	self:reset_state()
	self:on_resize()
end

function GameWorld:reset_state()
	self.actions = ACTIONS.Parallel()
	self.actions.drop_empty = false
	self.state = {
		time = 0,
		state = ENUMS.GAME_STATE.RUN,
		explore_state = ENUMS.EXPLORE_STATE.MENU,
		location = nil
	}
end

function GameWorld:game_loaded()
	DEBUG_INFO.game_reset()
	self.ecs_game:add_systems()

	self.level_creator = LevelCreator(self.world)
	self.level_creator:create()

	self:camera_reset()

end

function GameWorld:camera_reset()
	local zoom = 1
	self.camera_config.zoom.current = zoom
	CAMERAS.game_camera:set_zoom(zoom, 0, 0)
end

function GameWorld:camera_set_zoom(zoom)
	self.camera_config.zoom.current = zoom
	CAMERAS.game_camera:set_zoom(zoom, 0, 0)
end

function GameWorld:update(dt)
	if (self.state.state == ENUMS.GAME_STATE.RUN) then
		DEBUG_INFO.ecs_update_dt = socket.gettime()
		self.command_executor:act(dt)
		self.ecs_game:update(dt)
		DEBUG_INFO.update_ecs_dt(socket.gettime() - DEBUG_INFO.ecs_update_dt)
		self.state.time = self.state.time + dt
		if (self.actions) then self.actions:update(dt) end
	else
		--or not drawing? wtf
		self.ecs_game:update(0)
	end
end

function GameWorld:final()
	self:reset_state()
	self.ecs_game:clear()
end

function GameWorld:on_resize()
end

function GameWorld:on_input(action_id, action)
end

function GameWorld:game_pause()
	if (self.state.state == ENUMS.GAME_STATE.RUN) then
		self.state.state = ENUMS.GAME_STATE.PAUSE
		self.world.sdk:gameplay_stop()
	end
end
function GameWorld:game_resume()
	if (self.state.state == ENUMS.GAME_STATE.PAUSE) then
		self.state.state = ENUMS.GAME_STATE.RUN
		self.world.sdk:gameplay_start()
	end
end

function GameWorld:explore_location(location)
	assert(location)
	assert(DEFS.LOCATIONS.LOCATION_BY_ID[location.id], "unknown location:" .. tostring(location.id))

	--FOR DEBUG USE ONLY FIRST LEVEL
	location = DEFS.LOCATIONS.WORLDS[1].levels[1]

	self.command_executor:command_add(COMMANDS.LocationStart({ location = location }))
end

function GameWorld:location_leave_popup()

	self:location_leave()
end

function GameWorld:location_leave()
	assert(self.state.explore_state == ENUMS.EXPLORE_STATE.EXPLORE)
	self.state.explore_state = ENUMS.EXPLORE_STATE.MENU

	self.state.location = nil

	local ctx = COMMON.CONTEXT:set_context_top_game_gui()
	ctx.data:set_tab(ctx.data.tabs.location)
	ctx:remove()

	local ctx_tabs_panel = COMMON.CONTEXT:set_context_top_game_tabs_gui()
	ctx_tabs_panel.data:select_panel(ctx_tabs_panel.data.panels.menu)
	ctx_tabs_panel:remove()
end

return GameWorld



