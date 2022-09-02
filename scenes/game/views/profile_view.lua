local COMMON = require "libs.common"
local GUI = require "libs_project.gui.gui"
local GOOEY = require "gooey.gooey"
local ACTION = require "libs.actions.actions"
local WORLD = require "world.world"

local Base = require "scenes.game.views.base_view"

---@class ProfileView:BaseView
local View = COMMON.class("NewGameView", Base)

function View:init(root_name)
	Base.init(self, root_name)
end

function View:bind_vh()
	self.vh = {
		premium_status = gui.get_node(self.root_name .. "/premium_status"),
		lbl_name = gui.get_node(self.root_name .. "/name")
	}

	self.views = {
		btn_logout = GUI.ButtonScale(self.root_name .. "/btn_logout"),
		btn_buy = GUI.ButtonScale(self.root_name .. "/btn_buy"),
	}
end
function View:init_gui()
	Base.init_gui(self)
	self.subscription:add(COMMON.EVENT_BUS:subscribe(COMMON.EVENTS.NEAR):subscribe(function(data)
		if (data.message_id == "NearStreamCalculateEndTimestamp") then
			self.timestamp_value = data.message.timestamp/1000 --lua use seconds
		end
	end))

	self.action_update_timestamp = ACTION.Function { fun = function()
		while (true) do
			local delta = self.timestamp_value - os.time()
			if (delta > 0) then
				gui.set_text(self.vh.premium_status, COMMON.LUME.get_human_time(delta))
			else
				gui.set_text(self.vh.premium_status, "DISABLED")
			end
			COMMON.coroutine_wait(1)
		end
	end }
	self.timestamp_value = 0 --roketo.stream_calculate_end_timestamp()

	self.action_update_timestamp_value = ACTION.Function { fun = function()
		while (not roketo.is_logged_in() or not roketo.is_ready()) do coroutine.yield() end
		while (true) do
			roketo.stream_calculate_end_timestamp()
			COMMON.coroutine_wait(30)
		end
	end }

	self.action_update_login_name = ACTION.Function { fun = function()
		while (not roketo.is_logged_in() or not roketo.is_ready()) do coroutine.yield() end
		gui.set_text(self.vh.lbl_name, roketo.get_account_id())
		local metrics = resource.get_text_metrics(gui.get_font_resource(gui.get_font(self.vh.lbl_name)),
				roketo.get_account_id())
		if (metrics.width > gui.get_size(self.vh.lbl_name).x) then
			local scale = 0.7 * gui.get_size(self.vh.lbl_name).x / metrics.width
			gui.set_scale(self.vh.lbl_name, vmath.vector3(scale))
		else
			gui.set_scale(self.vh.lbl_name, vmath.vector3(0.7))
		end
	end }

	self.views.btn_logout:set_input_listener(function()
		WORLD.storage:reset()
		roketo.logout()
		--sys.reboot()
		if(html5)then
			html5.run("window.location.reload()")
		end
	end)

	self.views.btn_buy:set_input_listener(function()
		roketo.stream_buy_premium()
	end)

	gui.set_text(self.vh.lbl_name, roketo.get_account_id())
	local metrics = resource.get_text_metrics(gui.get_font_resource(gui.get_font(self.vh.lbl_name)),
			roketo.get_account_id())
	if (metrics.width > gui.get_size(self.vh.lbl_name).x) then
		local scale = 0.7 * gui.get_size(self.vh.lbl_name).x / metrics.width
		gui.set_scale(self.vh.lbl_name, vmath.vector3(scale))
	else
		gui.set_scale(self.vh.lbl_name, vmath.vector3(0.7))
	end

end

function View:update(dt)
	Base.update(self, dt)
	self.action_update_timestamp:update(dt)
	self.action_update_timestamp_value:update(dt)
	self.action_update_login_name:update(dt)
end

function View:on_input(action_id, action)
	if (self.ignore_input) then return false end
	if (self.views.btn_buy:on_input(action_id, action)) then return true end
	if (self.views.btn_logout:on_input(action_id, action)) then return true end
end

return View