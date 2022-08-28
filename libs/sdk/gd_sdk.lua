local COMMON = require "libs.common"

local TAG = "GD_SDK"

local Sdk = COMMON.class("GdSdk")

---@param world World
---@param sdk PlatformsSdk
function Sdk:initialize(world, sdk)
    self.world = assert(world)
    self.callback = nil
    self.context = nil
    self.platform_sdk = assert(sdk)
    self.subscription = COMMON.RX.SubscriptionsStorage()
end

function Sdk:on_event(event, message)
    if event == gdsdk.SDK_GAME_PAUSE then
        self:pause()
    elseif event == gdsdk.SDK_GAME_START then
        self:resume()
        if (self.callback) then
            self:callback_execute()
        end
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

function Sdk:pause()
    self.platform_sdk:__ads_start()
end
function Sdk:resume()
    self.platform_sdk:__ads_stop()

end

function Sdk:init()
    assert(gdsdk)
    COMMON.i("gdsdk init ", TAG)
    gdsdk.set_listener(function(_, event, message)
        print(event)
        COMMON.i("event:" .. tostring(event), TAG)
        self:on_event(event,message)
    end)
end

function Sdk:show_interstitial_ad(cb)
    COMMON.i("interstitial_ad show", TAG)
    if (self.callback) then
        COMMON.w("can't show already have callback")
        return
    else
        self:callback_save(cb)
    end
    gdsdk.show_interstitial_ad()
end

function Sdk:show_rewarded_ad(cb)
    COMMON.i("rewarded_ad show", TAG)
    if (self.callback) then
        COMMON.w("can't show already have callback")
        if (cb) then cb(false, "callback exist") end
        return
    else
        self:callback_save(cb)
    end
    gdsdk.show_rewarded_ad()
end

return Sdk