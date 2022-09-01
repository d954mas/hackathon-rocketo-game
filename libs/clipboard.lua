local COMMON = require "libs.common"
local M = {}

M.CLIPBOARD_PASTE = "ClipboardPaste"

function M.init()
	if (html5) then
		clipboard.init()
		COMMON.EVENT_BUS:subscribe(COMMON.EVENTS.JSTODEF):subscribe(function(message_id, message)
			if (message_id == M.CLIPBOARD_PASTE) then
				for _, listener in pairs(M.listeners) do
					listener(message_id, message)
				end
			end
		end)
	end
	M.listeners = {}
end

function M.add_listener(listener)
	M.listeners[listener] = listener
end

function M.remove_listener(listener)
	self.listeners[listener] = nil
end

return M