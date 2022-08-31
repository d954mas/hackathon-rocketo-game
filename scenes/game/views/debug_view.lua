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
		btn_get_games_list = GUI.ButtonScale(self.root_name .. "/btn_get_games_list"),
		btn_get_games_active_list = GUI.ButtonScale(self.root_name .. "/btn_get_games_active_list"),
		btn_stream_timestamp = GUI.ButtonScale(self.root_name .. "/btn_stream_timestamp"),
		btn_stream_is_premium = GUI.ButtonScale(self.root_name .. "/btn_stream_is_premium"),
		btn_stream_buy = GUI.ButtonScale(self.root_name .. "/btn_stream_buy"),
	}
end
function View:init_gui()
	Base.init_gui(self)
	self.views.btn_get_game:set_input_listener(function()
		roketo.contract_get_game(0)
	end)
	self.views.btn_create_game:set_input_listener(function()
		roketo.contract_create_game(roketo.get_account_id(),"d954mas2.testnet",5)
	end)
	self.views.btn_get_games_list:set_input_listener(function()
		roketo.contract_get_games_list(roketo.get_account_id())
	end)
	self.views.btn_get_games_active_list:set_input_listener(function()
		roketo.contract_get_games_active_list(roketo.get_account_id())
	end)

	self.views.btn_stream_timestamp:set_input_listener(function()
		roketo.stream_calculate_end_timestamp()
	end)

	self.views.btn_stream_is_premium:set_input_listener(function()
		roketo.stream_is_premium()
	end)

	self.views.btn_stream_buy:set_input_listener(function()
		roketo.stream_buy_premium()
	end)
end

function View:update(dt)
	Base.update(self, dt)
end

function View:on_input(action_id, action)
	if (self.ignore_input) then return false end
	if (self.views.btn_create_game:on_input(action_id, action)) then return true end
	if (self.views.btn_get_game:on_input(action_id, action)) then return true end
	if (self.views.btn_get_games_list:on_input(action_id, action)) then return true end
	if (self.views.btn_get_games_active_list:on_input(action_id, action)) then return true end
	if (self.views.btn_stream_timestamp:on_input(action_id, action)) then return true end
	if (self.views.btn_stream_is_premium:on_input(action_id, action)) then return true end
	if (self.views.btn_stream_buy:on_input(action_id, action)) then return true end
end

return View