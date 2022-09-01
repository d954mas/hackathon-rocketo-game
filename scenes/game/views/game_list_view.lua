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
		btn_change_list_lbl = gui.get_node(self.root_name .. "/btn_change_list/label")
	}

	self.views = {
		btn_change_list = GUI.ButtonScale(self.root_name .. "/btn_change_list")
	}
end

function View:update_game_cell(list,item,info)
	local lbl_oponnent = assert(item.nodes[COMMON.HASHES.hash(list.id .. "/listitem/oponnent")])
	if(info.first_player == roketo.get_account_id())then
		gui.set_text(lbl_oponnent,info.second_player)
	else
		gui.set_text(lbl_oponnent,info.first_player)
	end
end
function View:init_gui()
	Base.init_gui(self)
	self.list_current = 1
	self.lists = {
		{ id = "active", data = WORLD.games_receiver.games_active_list, root = gui.get_node(self.root_name .. "/game_list_active/bg"),
		  list_id = self.root_name .. "/game_list_active", stencil_id = self.root_name .. "/game_list_active/stencil",
		  item_id = self.root_name .. "/game_list_active/listitem/root"
		},
		{ id = "all", data = WORLD.games_receiver.games_all_list, root = gui.get_node(self.root_name .. "/game_list_all/bg"),
		  list_id = self.root_name .. "/game_list_all", stencil_id = self.root_name .. "/game_list_all/stencil",
		  item_id = self.root_name .. "/game_list_all/listitem/root"
		},
	}
	local scale_start = vmath.vector3(1)
	local scale_pressed = vmath.vector3(0.9)
	self.listitem_update = function(list, item)
		gui.set_scale(item.root, scale_start)
		if item.index == list.selected_item then

		end

		if item.index == list.pressed_item then
			gui.set_scale(item.root, scale_pressed)
		elseif item.index == list.over_item_now then
			--gui.set_scale(item.root, scale_start)
		elseif item.index == list.out_item_now then
			--gui.set_scale(item.root, scale_start)
		elseif item.index ~= list.over_item then
			--gui.set_scale(item.root, scale_start)
		else
			gui.set_scale(item.root, scale_start)
		end
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
						self:update_game_cell(list,item,info)
					end
				end
			end
		end
	end
	self.listitem_clicked = function(a)
		local data = a.data[a.selected_item]
	end
	self:list_changed()
	self.views.btn_change_list:set_input_listener(function()
		self.list_current = self.list_current + 1
		if (self.list_current > #self.lists) then
			self.list_current = 1
		end
		self:list_changed()
	end)
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
		for _,list in ipairs(self.lists)do
			for _,item in ipairs(list.list.items)do
				if(item.data==info.idx)then
					self:update_game_cell(list.list,item,info.game)
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
	if (self.views.btn_change_list:on_input(action_id, action)) then return true end
end

function View:list_changed()
	local list = self.lists[self.list_current]
	for _, l in ipairs(self.lists) do
		gui.set_enabled(l.root, false)
	end
	gui.set_enabled(list.root, true)
	gui.set_text(self.vh.btn_change_list_lbl, string.upper(list.id))
end

return View