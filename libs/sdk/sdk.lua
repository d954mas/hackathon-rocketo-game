local COMMON = require "libs.common"
local VK = require "libs.vkminibridge.vkminibridge"
local INPUT = require "libs.input_receiver"
local ENUMS = require "world.enums.enums"
local YA = require "libs.yagames.yagames"
local SCENE_ENUMS = require "libs.sm.enums"
local VkSdk = require "libs.sdk.vk_sdk"
local CrazyGamesSdk = require "libs.sdk.crazygames_sdk"
local GameDistributionSdk = require "libs.sdk.gamedistribution_sdk"
local TAG = "SDK"

---@class Sdks
local Sdk = COMMON.class("Sdk")

---@param world World
function Sdk:initialize(world)
    checks("?", "class:World")
    self.world = world
end

function Sdk:init(cb)
    self.poki = {
        gameplay_start = false
    }
    self.yagames = {
        interstial_delay = 0, --delay before first ad
        interstial_delay_duration =0
    }
    self.vk = VkSdk(self.world)
    self.crazygames = CrazyGamesSdk(self.world,self)
    self.gamedistribution = GameDistributionSdk(self.world,self)
    if (COMMON.CONSTANTS.TARGET_IS_VK_GAMES) then
        self.vk:init()
    end
    if(COMMON.CONSTANTS.TARGET_IS_CRAZY_GAMES)then
        self.crazygames:init()
    end
    if(COMMON.CONSTANTS.TARGET_IS_GAME_DISTRIBUTION)then
        self.gamedistribution:init()
    end
    if (COMMON.CONSTANTS.TARGET_IS_YANDEX_GAMES) then
        YA.init(function(...)
            self.yagames.init = true
            --localization
            local locale = YA.environment().i18n.lang
            COMMON.LOCALIZATION:set_locale(locale)
            cb(...)
        end)
    else
        cb()
    end
end

function Sdk:update(dt)
    self.yagames.interstial_delay = self.yagames.interstial_delay - dt
end

-- luacheck: push ignore
function Sdk:sitelock()
    if poki_sdk then

    end
end
-- luacheck: pop

function Sdk:share(text)
    COMMON.i("share:" .. text, TAG)
    if (COMMON.CONSTANTS.TARGET_IS_VK_GAMES) then
        self.vk:share({ message = text, attachments = "https://vk.com/app8178773" })
    end
end

function Sdk:gameplay_start()
    print("gameplay_start")
    if (COMMON.CONSTANTS.TARGET_IS_POKI) then
        if (not self.poki.gameplay_start) then
            poki_sdk.gameplay_start()
            self.poki.gameplay_start = true
        end
    elseif (COMMON.CONSTANTS.TARGET_IS_CRAZY_GAMES) then
        self.crazygames:gameplay_start()
    end
end

function Sdk:gameplay_stop()
    print("gameplay_stop")
    if (COMMON.CONSTANTS.TARGET_IS_POKI) then
        if (self.poki.gameplay_start) then
            poki_sdk.gameplay_stop()
            self.poki.gameplay_start = false
        end
    elseif (COMMON.CONSTANTS.TARGET_IS_CRAZY_GAMES) then
        self.crazygames:gameplay_stop()
    end
end

function Sdk:__ads_start()
    self.world.sounds:pause()
    INPUT.IGNORE = true
    local SM = reqf "libs_project.sm"
    local scene = SM:get_top()
    if (scene and scene._state == SCENE_ENUMS.STATES.RUNNING) then
        scene:pause()
    end
end

function Sdk:__ads_stop()
    self.world.sounds:resume()
    INPUT.IGNORE = false
    local SM = reqf "libs_project.sm"
    local scene = SM:get_top()
    if (scene and scene._state == SCENE_ENUMS.STATES.PAUSED) then
        scene:resume()
    end
end

function Sdk:ads_rewarded(cb)
    print("ads_rewarded")
    if (COMMON.CONSTANTS.TARGET_IS_POKI) then
        self.world.sounds:pause()
        INPUT.IGNORE = true
        local pause_game = false
        poki_sdk.rewarded_break(function(_, success)
            print("ads_rewarded success:" .. tostring(success))
            INPUT.IGNORE = false
            self.world.sounds:resume()
            if (pause_game) then
                self.world.game:game_resume()
            end
            if (cb) then cb(success) end
        end)
    elseif (COMMON.CONSTANTS.TARGET_IS_YANDEX_GAMES) then
        YA.adv_show_rewarded_video({
            open = function()
                self:__ads_start()
            end
        , rewarded = function()
                self:__ads_stop()
                cb(true)
            end, close = function()
                self:__ads_stop()
                cb(false)
            end, error = function()
                self:__ads_stop()
                cb(false)
            end })
    elseif COMMON.CONSTANTS.TARGET_IS_CRAZY_GAMES then
        self.crazygames:show_rewarded_ad(cb)
    elseif COMMON.CONSTANTS.TARGET_IS_GAME_DISTRIBUTION then
        self.gamedistribution:show_rewarded_ad(cb)
    else
        if (cb) then
            cb(true) end
    end
end

function Sdk:ads_commercial(cb)
    print("ads_commercial")
    if (COMMON.CONSTANTS.TARGET_IS_POKI) then
        self.world.sounds:pause()
        INPUT.IGNORE = true
        local pause_game = false
        if (self.world.game.level) then
            if (self.world.game.state.state == ENUMS.GAME_STATE.RUN) then
                pause_game = true
                self.world.game:game_pause()
            end
        end

        poki_sdk.commercial_break(function(_)
            INPUT.IGNORE = false
            self.world.sounds:resume()
            if (pause_game) then
                self.world.game:game_resume()
            end
            if (cb) then cb() end
        end)
    elseif (COMMON.CONSTANTS.TARGET_IS_YANDEX_GAMES) then
        if (self.yagames.interstial_delay > 0) then
            if (cb) then cb() end
        else
            self.yagames.interstial_delay = self.yagames.interstial_delay_duration
            YA.adv_show_fullscreen_adv({
                open = function()
                    self:__ads_start()
                end,
                close = function(wasShown)
                    self:__ads_stop()
                    cb(wasShown)
                end,
                error = function()
                    self:__ads_stop()
                    cb(false)
                end,
                offline = function()
                    self:__ads_stop()
                    cb(false)
                end })
        end
    elseif COMMON.CONSTANTS.TARGET_IS_CRAZY_GAMES then
        self.crazygames:show_interstitial_ad(cb)
    elseif COMMON.CONSTANTS.TARGET_IS_GAME_DISTRIBUTION then
        self.gamedistribution:show_interstitial_ad(cb)
    elseif (COMMON.CONSTANTS.TARGET_IS_VK_GAMES) then
        self.vk:show_interstitial_ad(cb)
    else
        if (cb) then cb() end
    end
end

function Sdk:happy_time(value)
    checks("?", "number")
    --print("happy_time:" .. tostring(value))
    if (COMMON.CONSTANTS.TARGET_IS_POKI) then
      --  poki_sdk.happy_time(value)
    elseif (COMMON.CONSTANTS.TARGET_IS_CRAZY_GAMES) then
        if(value == 1)then
            self.crazygames:happy_time()
        end
    end
end

return Sdk
