local COMMON = require "libs.common"
local GUI = require "libs_project.gui.gui"

local Base = require "scenes.game.views.base_view"

---@class DebugView:BaseView
local View = COMMON.class("DebugView", Base)

function View:init(root_name)
	Base.init(self, root_name)
end

function View:bind_vh()
	self.vh = {

	}

	self.views = {
		btn_get_game = GUI.ButtonScale(self.root_name .. "/btn_get_game"),
		btn_create_game = GUI.ButtonScale(self.root_name .. "/btn_create_game"),
	}
end
function View:init_gui()
	Base.init_gui(self)
	self.views.btn_get_game:set_input_listener(function()
		roketo.contract_get_game(0)
	end)
	self.views.btn_create_game:set_input_listener(function()
		roketo.contract_create_game(roketo.get_account_id(),1,5)
	end)
end

function View:update(dt)
	Base.update(self, dt)
end

function View:on_input(action_id, action)
	if (self.ignore_input) then return false end
	if (self.views.btn_create_game:on_input(action_id, action)) then return true end
	if (self.views.btn_get_game:on_input(action_id, action)) then return true end
end

return View