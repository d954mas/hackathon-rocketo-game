local WORLD = require "world.world"
local SM_ENUMS = require "libs.sm.enums"
local BaseScene = require "libs.sm.scene"
local ENUMS = require "world.enums.enums"
local COMMON = require "libs.common"

---@class GameScene:Scene
local Scene = BaseScene:subclass("Game")
function Scene:initialize()
    BaseScene.initialize(self, "GameScene", "/game_scene#collectionproxy")
end

function Scene:transition(transition)
    if (transition == SM_ENUMS.TRANSITIONS.ON_HIDE) then

    elseif (transition == SM_ENUMS.TRANSITIONS.ON_SHOW) then

    end
end


function Scene:update(dt)
    BaseScene.update(self,dt)
end

function Scene:resume()
    BaseScene.resume(self)
end

function Scene:pause()
    BaseScene.pause(self)
end

function Scene:pause_done()
    WORLD.sdk:gameplay_stop()
end

function Scene:resume_done()
    if (WORLD.game.state.state == ENUMS.GAME_STATE.RUN) then
        WORLD.sdk:gameplay_start()
    end
end

function Scene:show_done()
    if (WORLD.sounds.current_music ~= WORLD.sounds.music.game) then
        WORLD.sounds:play_music(WORLD.sounds.music.game)
    end
end

function Scene:load_done()
    self._input = self._input or {}
end

return Scene