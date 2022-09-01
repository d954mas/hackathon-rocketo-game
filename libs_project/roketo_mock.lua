local COMMON = require "libs.common"
local ACTIONS = require "libs.actions.actions"

-----@class Roketo
local Roketo = {
	parallel = ACTIONS.Parallel(),
	data = {
		id = "fake.user",
		inited = false,
		login = true
	}
}
Roketo.parallel.drop_empty = false

function Roketo.init_near()
	Roketo.parallel:add_action(function()
		if (Roketo.inited) then
			COMMON.EVENT_BUS:event(COMMON.EVENTS.NEAR, { message_id = "NearInitLoginError", message = { error = "NearAlreadyInited" } })
		else
			COMMON.coroutine_wait(0)
			COMMON.EVENT_BUS:event(COMMON.EVENTS.NEAR, { message_id = "NearInitSuccess" })
			COMMON.EVENT_BUS:event(COMMON.EVENTS.NEAR, { message_id = "NearInitWalletSuccess" })
			COMMON.coroutine_wait(0)
			COMMON.EVENT_BUS:event(COMMON.EVENTS.NEAR, { message_id = "NearInitRoketoApiControlSuccess" })
		end
	end)
end

function Roketo.get_account_id()
	return Roketo.data.id
end

function Roketo.is_logged_in()
	return Roketo.data.login
end
function Roketo.is_ready()
	return Roketo.data.login
end
function Roketo.contract_get_games_list()

end

function Roketo.contract_get_games_active_list()

end

function Roketo.contract_get_game()

end

function Roketo.login()
	Roketo.parallel:add_action(function()
		COMMON.coroutine_wait(1)
		COMMON.EVENT_BUS:event(COMMON.EVENTS.NEAR, { message_id = "NearLoginSuccess" })
	end)
end

function Roketo.update(dt)
	Roketo.parallel:update(dt)
end

return Roketo