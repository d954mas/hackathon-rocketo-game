local COMMON = require "libs.common"
local DEBUG_INFO = require "debug.debug_info"

local TABLE_REMOVE = table.remove
local TABLE_INSERT = table.insert
local GO_DELETE = go.delete

local TAG = "Entities"

---@class MoveCurveConfig
---@field curve Curve
---@field a number position in curve [0,1]
---@field speed number
---@field deviation number
---@field position_descriptor number

---@class MoveData
---@field active boolean
---@field state string
---@field pos_d vector3
---@field speed_max number
---@field speed_max_a number
---@field direction number 1 or -1
---@field polygon boolean
---@field wait_delay number


---@class InputInfo
---@field action_id hash
---@field action table

---@class Size
---@field w number
---@field h number


---@class bbox
---@field w number
---@field h number

---@class Tile
---@field tile_id number

---@class EntityGame
---@field _in_world boolean is entity in world
---@field tag string tag can search entity by tag
---@field position vector3
---@field move_curve_config MoveCurveConfig
---@field input_info InputInfo
---@field auto_destroy_delay number
---@field auto_destroy boolean
---@field actions Action[]
---@field visible boolean
---@field visible_bbox bbox

local TEMP_V = vmath.vector3(0, 0, 0)

---@class ENTITIES
local Entities = COMMON.class("Entities")

---@param world World
function Entities:initialize(world)
	self.world = world
	self.pool_input = {}
end



--region ecs callbacks
---@param e EntityGame
function Entities:on_entity_removed(e)
	DEBUG_INFO.game_entities = DEBUG_INFO.game_entities - 1
	e._in_world = false
	if (e.input_info) then
		TABLE_INSERT(self.pool_input, e)
	end

end

---@param e EntityGame
function Entities:on_entity_added(e)
	DEBUG_INFO.game_entities = DEBUG_INFO.game_entities + 1
	e._in_world = true
end

---@param e EntityGame
function Entities:on_entity_updated(e)

end
--endregion


--region Entities

---@return EntityGame
function Entities:create_input(action_id, action)
	local input = TABLE_REMOVE(self.pool_input)
	if (not input) then
		input = { input_info = {}, auto_destroy = true }
	end
	input.input_info.action_id = action_id
	input.input_info.action = action
	return input
end

return Entities




