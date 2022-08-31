local COMMON = require "libs.common"
local ACTIONS = require "libs.actions.actions"

local Receiver = COMMON.class("GamesReceiver")

---@param world World
function Receiver:initialize(world)
	self.world = assert(world)
	self.games_all_list = {}
	self.games_active_list = {}
	self.scheduler = COMMON.RX.CooperativeScheduler.create()
	self.subscriptions = COMMON.RX.SubscriptionsStorage()
	self.subscriptions:add(COMMON.EVENT_BUS:subscribe(COMMON.EVENTS.NEAR):subscribe(function(data)
		self:on_near_event(data)
	end))

	self.callbacks = {
		GAME_LIST_CHANGED = {},
		GAME_ACTIVE_LIST_CHANGED = {},
		GAME_INFO_CHANGED = {},
	}

	self.action_get_game_info = ACTIONS.Parallel()
	self.action_get_game_info.drop_empty = false

	self.action_update = ACTIONS.Function({
		fun = function()
			while (not roketo.is_logged_in() or not roketo.is_ready()) do
				coroutine.yield()
			end
			while (true) do
				if (roketo.is_logged_in()) then
					self:update_lists()
				end
				COMMON.coroutine_wait(10)
			end
		end
	})
end

function Receiver:add_cb_game_list_changed(cb)
	table.insert(self.callbacks.GAME_LIST_CHANGED, cb)
end

function Receiver:add_cb_game_active_list_changed(cb)
	table.insert(self.callbacks.GAME_ACTIVE_LIST_CHANGED, cb)
end

function Receiver:add_cb_game_info_changed(cb)
	table.insert(self.callbacks.GAME_INFO_CHANGED, cb)
end

function Receiver:cb_call(callbacks, data)
	for _, cb in ipairs(callbacks) do
		cb(data)
	end
end

function Receiver:on_near_event(data)
	----init near. Show start login UI or start game ui
	if (data.message_id == "NearContractGetGamesActiveList") then
		COMMON.LUME.cleari(self.games_active_list)
		for i=#data.message.list,1,-1 do
			table.insert(self.games_active_list, data.message.list[i])
		end
		self:cb_call(self.callbacks.GAME_ACTIVE_LIST_CHANGED)
	elseif (data.message_id == "NearContractGetGamesList") then
		COMMON.LUME.cleari(self.games_all_list)
		for i=#data.message.list,1,-1 do
			table.insert(self.games_all_list,  data.message.list[i])
		end
		self:cb_call(self.callbacks.GAME_LIST_CHANGED)
	end
end

function Receiver:update_lists()
	if (roketo.is_logged_in()) then
		roketo.contract_get_games_list(roketo.get_account_id())
		roketo.contract_get_games_active_list(roketo.get_account_id())
	end
end

function Receiver:get_game_info(game_id, cb)

end

function Receiver:update(dt)
	self.action_update:update(dt)
	self.scheduler:update(dt)
end

return Receiver