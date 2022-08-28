local COMMON = require "libs.common"
local GUI = require "libs_project.gui.gui"
local WORLD = require "world.world"

---@class SoundMusicGuiScriptBase
local Script = COMMON.new_n28s()

function Script:bind_vh()
    self.vh = {}
    self.views = {
        btn_sound = GUI.ButtonScale("btn_sound"),
        btn_music = GUI.ButtonScale("btn_music"),
    }
    self.views.btn_sound.vh.icon = gui.get_node("btn_sound/icon")
    self.views.btn_sound.vh.disabled = gui.get_node("btn_sound/disabled")
    self.views.btn_music.vh.icon = gui.get_node("btn_music/icon")
    self.views.btn_music.vh.disabled = gui.get_node("btn_music/disabled")
end

function Script:init_gui()
    self.views.btn_music:set_input_listener(function()
        WORLD.sounds:play_sound(WORLD.sounds.sounds.menu_button)
        WORLD.storage.options:music_set(not WORLD.storage.options:music_get())
    end)
    self.views.btn_sound:set_input_listener(function()
        WORLD.sounds:play_sound(WORLD.sounds.sounds.menu_button)
        WORLD.storage.options:sound_set(not WORLD.storage.options:sound_get())
    end)
end

function Script:on_storage_changed()
    gui.set_enabled(self.views.btn_sound.vh.disabled, not WORLD.storage.options:sound_get() )
    gui.set_enabled(self.views.btn_music.vh.disabled, not WORLD.storage.options:music_get() )
end

function Script:init()
    self:bind_vh()
    self.subscription = COMMON.RX.SubscriptionsStorage()
    self.scheduler = COMMON.RX.CooperativeScheduler.create()
    self.subscription:add(COMMON.EVENT_BUS:subscribe(COMMON.EVENTS.STORAGE_CHANGED):go_distinct(self.scheduler):subscribe(function()
        self:on_storage_changed()
    end))
    self:init_gui()
    self:on_storage_changed()
    COMMON.input_acquire()
    timer.delay(1,true,function()
        --fixed sound/music touches go to game
        COMMON.input_acquire()
    end)
end

function Script:on_input(action_id, action)
  --  local action_new = COMMON.LUME.clone_deep(action)
   -- local world_coord = CAMERAS.game_camera:screen_to_world_2d(action.screen_x, action.screen_y)
  --  action_new.x = world_coord.x *  COMMON.RENDER.config_size.w/CAMERAS.game_camera.screen_size.w
   -- action_new.y = world_coord.y *  COMMON.RENDER.config_size.h/CAMERAS.game_camera.screen_size.h
    if (self.views.btn_music:on_input(action_id, action)) then return true end
    if (self.views.btn_sound:on_input(action_id, action)) then return true end
end

function Script:update(dt)
    self.scheduler:update(dt)


end

function Script:final()
    self.subscription:unsubscribe()
end


return Script