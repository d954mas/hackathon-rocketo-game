local COMMON = require "libs.common"
local ACTIONS = require "libs.actions.actions"

-----@class Roketo
local Roketo = {
	parallel = ACTIONS.Parallel(),
	data = {
		inited = false
	}
}
Roketo.parallel.drop_empty = false

function Roketo.init_near()
	Roketo.parallel:add_action(function()
		if (Roketo.inited) then
			COMMON.EVENT_BUS:event(COMMON.EVENTS.NEAR, { message_id = "NearInitError", message = { error = "NearAlreadyInited" } })
		else
			COMMON.coroutine_wait(2)
			COMMON.EVENT_BUS:event(COMMON.EVENTS.NEAR, { message_id = "NearInitSuccess" })
			COMMON.EVENT_BUS:event(COMMON.EVENTS.NEAR, { message_id = "NearInitWalletSuccess" })
		end
	end)
end

function Roketo.update(dt)
	Roketo.parallel:update(dt)
end

return Roketo