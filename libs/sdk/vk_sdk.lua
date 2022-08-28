local COMMON = require "libs.common"
local VK = require "libs.vkminibridge.vkminibridge"

local TAG = "VK_SDK"

local Sdk = COMMON.class("vk")

---@param world World
function Sdk:initialize(world)
    self.world = assert(world)
    self.callback = nil
    self.context = nil
    self.subscription = COMMON.RX.SubscriptionsStorage()
    self.subscription:add(COMMON.EVENT_BUS:subscribe(COMMON.EVENTS.JSTODEF):subscribe(function(event)
        self:on_event(event)
    end))
end


function Sdk:on_event(event)
    local message_id = event.message_id
    --local message = event.message
    print("ADS EVENT. message_id:" .. message_id)
    if(message_id == "AdsResult")then
        self:callback_execute()
    end
end

function Sdk:callback_save(cb)
    assert(not self.callback)
    self.callback = cb
    self.context = lua_script_instance.Get()
end

function Sdk:callback_execute()
    if (self.callback) then
        local ctx_id = COMMON.CONTEXT:set_context_top_by_instance(self.context)
        self.callback(true)
        COMMON.CONTEXT:remove_context_top(ctx_id)
        self.context = nil
        self.callback = nil
    else
        COMMON.w("no callback to execute", TAG)
    end
end

function Sdk:init()
    COMMON.i("vk games init start", TAG)
    VK.init(nil, function()
        COMMON.i("vk games init", TAG)
        -- Sends event to client
        VK.send('VKWebAppInit', {})
    end)
end

function Sdk:show_interstitial_ad(cb)
    COMMON.i("interstitial_ad show vk", TAG)
    if (self.callback) then
        COMMON.w("can't show already have callback")
        return
    else
        if (VK.is_initialized) then
            if(VK.supports("VKWebAppShowNativeAds"))then
                self:callback_save(cb)
                VK.interstitial_native()
            else
                COMMON.w("not supported")
                if (cb) then cb(false, "not supported") end
            end
        else
            if (cb) then cb(false, "not inited") end
        end

    end
end

function Sdk:share(params)
    VK.send("VKWebAppShowWallPostBox",params )
end
return Sdk