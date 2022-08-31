local COMMON = require "libs.common"
local GUI = require "libs_project.gui.gui"
local GOOEY = require "gooey.gooey"

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
function View:init_gui()
	Base.init_gui(self)
	self.list_current = 1
	self.lists = {
		{ id = "active", data = { 1, 2, 3, 4, 5 }, root = gui.get_node(self.root_name .. "/game_list_active/bg"),
		  list_id = self.root_name .. "/game_list_active", stencil_id = self.root_name .. "/game_list_active/stencil",
		  item_id = self.root_name .. "/game_list_active/listitem/root"
		},
		{ id = "all", data = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, root = gui.get_node(self.root_name .. "/game_list_all/bg"),
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
			gui.set_text(item.nodes[COMMON.HASHES.hash(list.id .. "/listitem/text")], tostring(item.data or "-"))
		end
	end
	self.listitem_clicked = function(a)
		local data = a.data[a.selected_item]
		pprint(data)
	end
	self:list_changed()
	self.views.btn_change_list:set_input_listener(function()
		self.list_current = self.list_current + 1
		if (self.list_current > #self.lists) then
			self.list_current = 1
		end
		self:list_changed()
	end)
	--touch to create initial lists
	self:on_input(COMMON.HASHES.INPUT.TOUCH, { screen_x = 0, screen_y = 0, x = 0, y = 0 })
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