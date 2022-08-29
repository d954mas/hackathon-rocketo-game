local COMMON = require "libs.common"
local GUI = require "libs_project.gui.gui"

local Base = require "scenes.game.views.base_view"

---@class LoginView:BaseView
local View = COMMON.class("LoginView", Base)

function View:init(root_name)
	Base.init(self, root_name)
end

function View:bind_vh()
	self.vh = {

	}

	self.views = {
		btn_login = GUI.ButtonScale(self.root_name .. "/btn_login"),
	}
end
function View:init_gui()
	Base.init_gui(self)
	self.views.btn_login:set_input_listener(function()
		roketo.login()
	end)
end

function View:update(dt)
	Base.update(self, dt)
end

function View:on_input(action_id, action)
	if (self.ignore_input) then return false end
	if (self.views.btn_login:on_input(action_id, action)) then return true end
end

return View