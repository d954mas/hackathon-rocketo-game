local COMMON = require "libs.common"
local GUI = require "libs_project.gui.gui"

local Base = require "scenes.game.views.base_view"

---@class InitializingView:BaseView
local View = COMMON.class("InitializingView", Base)

function View:init(root_name)
	Base.init(self, root_name)
end

function View:bind_vh()
	self.vh = {

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

function View:on_input(action_id, action)
	if (self.ignore_input) then return false end
end

return View