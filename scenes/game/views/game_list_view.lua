local COMMON = require "libs.common"
local GUI = require "libs_project.gui.gui"
local GOOEY = require "gooey.gooey"
local WORLD = require "world.world"

local Base = require "scenes.game.views.base_view"

---@class GameListView:BaseView
local View = COMMON.class("GameListView", Base)

function View:init(root_name)
	Base.init(self, root_name)
end

function View:bind_vh()
	self.vh = {
		tabs = {
			active = { root = gui.get_node("game_list_view/tab_active"), lbl = gui.get_node("game_list_view/tab_active/text") },
			all = { root = gui.get_node("game_list_view/tab_all"), lbl = gui.get_node("game_list_view/tab_all/text") }
		}
	}

	self.views = {

	}
end

function View:update_game_cell(list, item, info)
	local lbl_oponnent = assert(item.nodes[COMMON.HASHES.hash(list.id .. "/listitem/oponnent")])
	local oponnent_name = ""
	local is_first = info.first_player == roketo.get_account_id()
	if (is_first) then
		oponnent_name = info.second_player
	else
		oponnent_name = info.first_player
	end
	gui.set_text(lbl_oponnent, oponnent_name)
	local metrics = resource.get_text_metrics(gui.get_font_resource(gui.get_font(lbl_oponnent)),
			oponnent_name)
	if (metrics.width > gui.get_size(lbl_oponnent).x) then
		local scale = 0.5 * gui.get_size(lbl_oponnent).x / metrics.width
		gui.set_scale(lbl_oponnent, vmath.vector3(scale))
	else
		gui.set_scale(lbl_oponnent, vmath.vector3(0.5))
	end
	gui.play_flipbook(item.nodes[COMMON.HASHES.hash(list.id .. "/listitem/hex")],
			COMMON.HASHES.hash(is_first and "hex_red" or "hex_blue"))
	local first_turn = info.turn % 2 == 0
	local is_my_turn = first_turn == is_first
	local is_win = info.is_finished and (not is_my_turn)
	local is_lose = info.is_finished and (is_my_turn)

	if (info.is_finished and info.give_up > 0) then
		is_win = (is_first and info.give_up == 2) or (not is_first and info.give_up == 1)
		is_lose = (is_first and info.give_up == 1) or (not is_first and info.give_up == 2)
	end
	local lbl_status =  assert(item.nodes[COMMON.HASHES.hash(list.id .. "/listitem/status")])
	if(is_win)then
		gui.set_text(lbl_status,info.give_up>0 and "WIN (GIVE UP)" or "WIN")
	elseif(is_lose)then
		gui.set_text(lbl_status,info.give_up>0 and "LOSE (GIVE UP)" or "LOSE")
	elseif(is_my_turn)then
		gui.set_text(lbl_status,"YOU TURN")
	else
		gui.set_text(lbl_status,"WAIT TURN")
	end
end
function View:init_gui()
	Base.init_gui(self)
	self.list_current = 1
	self.lists = {
		{ id = "active", data = WORLD.games_receiver.games_active_list, root = gui.get_node(self.root_name .. "/game_list_active/bg"),
		  list_id = self.root_name .. "/game_list_active", stencil_id = self.root_name .. "/game_list_active/stencil",
		  item_id = self.root_name .. "/game_list_active/listitem/root", tab = self.vh.tabs.active
		},
		{ id = "all", data = WORLD.games_receiver.games_all_list, root = gui.get_node(self.root_name .. "/game_list_all/bg"),
		  list_id = self.root_name .. "/game_list_all", stencil_id = self.root_name .. "/game_list_all/stencil",
		  item_id = self.root_name .. "/game_list_all/listitem/root", tab = self.vh.tabs.all
		},
	}
	local scale_start = vmath.vector3(1)
	local scale_pressed = vmath.vector3(0.9)
	self.listitem_update = function(list, item)
		gui.set_scale(item.root, scale_start)
		if (not list.have_scrolled) then
			if item == list.pressed_item then
				gui.set_scale(item.root, scale_pressed)
			end
		end

		if item == list.selected_item then

		end

		--[[if item == list.pressed_item then
			gui.set_scale(item.root, scale_pressed)
		elseif item == list.over_item_now then
			--gui.set_scale(item.root, scale_start)
		elseif item == list.out_item_now then
			--gui.set_scale(item.root, scale_start)
		elseif item ~= list.over_item then
			--gui.set_scale(item.root, scale_start)
		else
			gui.set_scale(item.root, scale_start)
		end--]]
	end
	self.listitem_refresh = function(list)
		for _, item in ipairs(list.items) do
			self.listitem_update(list, item)
			if (item.data and item.data ~= "") then
				if (item.__prev_data ~= item.data) then
					item.__prev_data = item.data
					gui.set_text(item.nodes[COMMON.HASHES.hash(list.id .. "/listitem/id")], tostring(item.data or "-"))
					local info = WORLD.games_receiver:get_game_info(item.data)
					if (info) then
						self:update_game_cell(list, item, info)
					end
				end
			end
		end
	end
	self.listitem_clicked = function(a)
		local data = a.data[a.selected_item.index]
		if (WORLD.games_receiver.games_info[data]) then
			local ctx = COMMON.CONTEXT:set_context_top_game_gui()
			ctx.data.views.game_view:set_game(WORLD.games_receiver.games_info[data], data)
			ctx:remove()
		end
	end
	self:list_changed()
	self.lists[1].list = GOOEY.dynamic_list(self.lists[1].list_id, self.lists[1].stencil_id, self.lists[1].item_id, self.lists[1].data, nil, nil, {},
			self.listitem_clicked, self.listitem_refresh)
	self.lists[2].list = GOOEY.dynamic_list(self.lists[2].list_id, self.lists[2].stencil_id, self.lists[2].item_id, self.lists[2].data, nil, nil, {},
			self.listitem_clicked, self.listitem_refresh)

	WORLD.games_receiver:add_cb_game_active_list_changed(function()
		local ctx = COMMON.CONTEXT:set_context_top_game_gui()
		self.listitem_refresh(assert(self.lists[1].list))
		GOOEY.dynamic_list(self.lists[1].list_id, self.lists[1].stencil_id, self.lists[1].item_id, self.lists[1].data, nil, nil, {},
				self.listitem_clicked, self.listitem_refresh)
		ctx:remove()
	end)

	WORLD.games_receiver:add_cb_game_list_changed(function()
		local ctx = COMMON.CONTEXT:set_context_top_game_gui()
		self.listitem_refresh(assert(self.lists[2].list))
		GOOEY.dynamic_list(self.lists[2].list_id, self.lists[2].stencil_id, self.lists[2].item_id, self.lists[2].data, nil, nil, {},
				self.listitem_clicked, self.listitem_refresh)
		ctx:remove()
	end)

	WORLD.games_receiver:add_cb_game_info_changed(function(info)
		local ctx = COMMON.CONTEXT:set_context_top_game_gui()
		for _, list in ipairs(self.lists) do
			for _, item in ipairs(list.list.items) do
				if (item.data == info.idx) then
					self:update_game_cell(list.list, item, info.game)
				end
			end
		end
		ctx:remove()
	end)
end

function View:update(dt)
	Base.update(self, dt)
end

function View:on_input(action_id, action)
	if (self.ignore_input) then return false end
	GOOEY.dynamic_list(self.lists[1].list_id, self.lists[1].stencil_id, self.lists[1].item_id, self.lists[1].data, action_id, action, {},
			self.listitem_clicked, self.listitem_refresh)
	GOOEY.dynamic_list(self.lists[2].list_id, self.lists[2].stencil_id, self.lists[2].item_id, self.lists[2].data, action_id, action, {},
			self.listitem_clicked, self.listitem_refresh)
	if (action_id == COMMON.HASHES.INPUT.TOUCH and action.pressed) then
		for idx, list in ipairs(self.lists) do
			if (gui.pick_node(list.tab.root, action.x, action.y)) then
				self.list_current = idx
				self:list_changed()
				return true
			end
		end
	end
end

function View:list_changed()
	local list = self.lists[self.list_current]
	for _, tab in pairs(self.vh.tabs) do
		gui.play_flipbook(tab.root, COMMON.HASHES.hash("tab_normal"))
		gui.set_color(tab.lbl, vmath.vector3(89 / 255, 89 / 255, 89 / 255))
	end
	for _, l in ipairs(self.lists) do
		gui.set_enabled(l.root, false)
	end
	gui.set_enabled(list.root, true)

	gui.play_flipbook(list.tab.root, COMMON.HASHES.hash("tab_selected"))
	gui.set_color(list.tab.lbl, vmath.vector3(1, 1, 1))
end

return View