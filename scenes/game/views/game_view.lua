local COMMON = require "libs.common"
local GUI = require "libs_project.gui.gui"
local GOOEY = require "gooey.gooey"
local WORLD = require "world.world"

local TEST_GAME = {
	idx = 2,
	game = { --[[0x1067240]]
		first_player = "d954mas.testnet",
		is_finished = false,
		turn = 0,
		give_up = 0,
		board = { --[[0x106c328]]
			". . . . . . .",
			" . . . . . . .",
			"  . . . . . . .",
			"   . . . . . . .",
			"    . . . . . . .",
			"     . . . . . . .",
			"      . . . . . . ."
		},
		second_player = "d954mas2.testnet",
		history = { },
		current_block_height = 99108360,
		prev_block_height = 0
	}
}

local Base = require "scenes.game.views.base_view"

---@class GameView:BaseView
local View = COMMON.class("GameView", Base)

View.TEST_GAME = TEST_GAME

View.HEX_SIZE = {
	w = 42,
	h = math.sqrt(3) * 42
}

function View:init(root_name)
	Base.init(self, root_name)
end

function View:bind_vh()
	self.vh = {
		hex_empty = gui.get_node("hex_empty"),
		hex_fill = gui.get_node("hex_fill"),
		center = gui.get_node(self.root_name .. "/center"),
		bg = {

		},
		hexes = {

		}
	}

	self.views = {

	}
end

function View:init_gui()
	Base.init_gui(self)
end

function View:update(dt)
	Base.update(self, dt)
end

function View:select_node(node, idx)
	if (self.selected_node ~= node) then
		if(self.selected_node) then
			gui.play_flipbook(self.selected_node, COMMON.HASHES.hash("hex_empty"))
		end

		self.selected_node = node
		self.selected_node_idx = idx
		if(self.selected_node)then
			gui.play_flipbook(self.selected_node, COMMON.HASHES.hash("hex_blue"))
		end
	end
end

function View:on_input(action_id, action)
	if (self.ignore_input) then return false end
	if (not action_id) then
		local selected_node, idx = self:find_over_node(action)
		self:select_node(selected_node, idx)
	end
	if(action_id == COMMON.HASHES.INPUT.TOUCH)then
		local selected_node, idx = self:find_over_node(action)
		self:select_node(selected_node, idx)
		if(self.selected_node_idx)then
			local idx_0 = self.selected_node_idx-1
			local y = math.floor(idx_0/self.board_size)
			local x = idx_0-y*self.board_size
			roketo.contract_make_move(self.game_id,"PLACE",x,y)
		end
	end
end

--TODO
function View:find_over_node(action)
	local possible_nodes = {}
	for idx, node in ipairs(self.vh.bg) do
		if (gui.pick_node(node, action.x, action.y)) then
			table.insert(possible_nodes, { node = node, idx = idx })
		end
	end
	local result_node = nil
	local dist = math.huge
	for _, node in ipairs(possible_nodes) do
		local coords = gui.get_screen_position(node.node)
		coords.x = coords.x - action.screen_x
		coords.y = coords.y - action.screen_y
		local cell_dist = vmath.length(coords)
		if (cell_dist < dist) then
			dist = cell_dist
			result_node = node
		end
	end
	if (result_node) then
		return result_node.node, result_node.idx
	end
end

function View:set_game(game,game_id)
	if (self.game) then
		self:clear()
	end
	self.game = assert(game)
	self.game_id = assert(game_id)
	self.board_size = #self.game.board

	local full_dx = (self.board_size - 1) + (self.board_size - 1) * 2
	self.view_size = vmath.vector3(full_dx * View.HEX_SIZE.w / 2,
			self.board_size * View.HEX_SIZE.h / 2 + View.HEX_SIZE.h / 2, 0)
	gui.set_position(self.vh.center, vmath.vector3(-self.view_size.x / 2, self.view_size.y / 2, 0))
	local position = vmath.vector3()
	for y = 1, self.board_size do
		position.y = -(y - 1) * View.HEX_SIZE.h / 2 - View.HEX_SIZE.h / 2
		for x = 1, self.board_size do
			local dx = (y - 1) + (x - 1) * 2
			position.x = dx * View.HEX_SIZE.w / 2
			local node = self.game.board[y]:sub(1 + dx, 1 + dx)
			--	print("x:" .. x .. " y:" .. y .. "node:" .. tostring(node))
			local bg_node = gui.clone(self.vh.hex_empty)
			gui.set_parent(bg_node, self.vh.center)
			gui.set_enabled(bg_node, true)
			gui.set_position(bg_node, position)
			table.insert(self.vh.bg, bg_node)

			--local hex_node = gui.clone(self.vh.hex_node)
			--gui.set_parent(hex_node, self.root_node)
			--gui.set_enabled(hex_node, false)

		end
	end

end

function View:clear()
	for _, node in ipairs(self.vh.bg) do
		gui.delete_node(node)
	end
	self.vh.bg = {}

	for _, node in ipairs(self.vh.hexes) do
		gui.delete_node(node)
	end
	self.vh.hexes = {}
end

return View