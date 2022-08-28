local COMMON = require "libs.common"
local ACTIONS = require "libs.actions.actions"
local WORLD = require "world.world"

local M = {}

M.STATES = {
    OPENED = "OPENED",
    CLOSED = "CLOSED",
    IN_PROGRESS = "IN_PROGRESS"
}

M.config = {
    top = {
        position_closed = vmath.vector3(0, 143, 0),
        position_open = vmath.vector3(0, 143 + 320, 0),
    },
    bottom = {
        position_closed = vmath.vector3(0, -143, 0),
        position_open = vmath.vector3(0, -143 - 320, 0),
    },
    speed = 2000,
    delay = 0.01,
}

function M:init()
    self.commands_queue = ACTIONS.Sequence()
    self.commands_queue.drop_empty = false
    self.state = M.STATES.CLOSED
end

function M:update(dt)
    self.commands_queue:update(dt)
end

function M:command_open(add)
    local cmd = ACTIONS.Sequence()
    local ctx = COMMON.CONTEXT:set_context_top_curtains_gui()

    local open_parallel = ACTIONS.Parallel()
    local dy_top = self.config.top.position_open.y - self.config.top.position_closed.y
    local time_top = dy_top / self.config.speed
    local dy_bottom = self.config.bottom.position_closed.y - self.config.bottom.position_open.y
    local time_bottom = dy_bottom / self.config.speed
    open_parallel:add_action(ACTIONS.TweenGui { object = ctx.data.vh.curtain_top, property = "position", v3 = true,
                                                to = vmath.vector3(self.config.top.position_open), time = time_top })
    open_parallel:add_action(ACTIONS.TweenGui { object = ctx.data.vh.curtain_bottom, property = "position", v3 = true,
                                                to = vmath.vector3(self.config.bottom.position_open), time = time_bottom })

    cmd:add_action(function()
        local ctx_f = COMMON.CONTEXT:set_context_top_curtains_gui()
        self.state = M.STATES.IN_PROGRESS
        ctx_f.data:curtains_closed()
        ctx_f:remove()
--        WORLD.sounds:play_sound(WORLD.sounds.sounds.gate_open)
    end)
    cmd:add_action(open_parallel)
    cmd:add_action(function()
        local ctx_f = COMMON.CONTEXT:set_context_top_curtains_gui()
        self.state = M.STATES.OPENED
        ctx_f.data:curtains_opened()
        ctx_f:remove()
    end)

    ctx:remove()

    if (add) then
        cmd:update(0)
        self.commands_queue:add_action(cmd)
    end

    return cmd
end

function M:command_closed(add)
    local cmd = ACTIONS.Sequence()
    local ctx = COMMON.CONTEXT:set_context_top_curtains_gui()

    local close_parallel = ACTIONS.Parallel()
    local dy_top = self.config.top.position_open.y - self.config.top.position_closed.y
    local time_top = dy_top / self.config.speed
    local dy_bottom = self.config.bottom.position_closed.y - self.config.bottom.position_open.y
    local time_bottom = dy_bottom / self.config.speed
    close_parallel:add_action(ACTIONS.TweenGui { object = ctx.data.vh.curtain_top, property = "position", v3 = true,
                                                 to = vmath.vector3(self.config.top.position_closed), time = time_top })
    close_parallel:add_action(ACTIONS.TweenGui { object = ctx.data.vh.curtain_bottom, property = "position", v3 = true,
                                                 to = vmath.vector3(self.config.bottom.position_closed), time = time_bottom })

    cmd:add_action(function()
        local ctx_f = COMMON.CONTEXT:set_context_top_curtains_gui()
        self.state = M.STATES.IN_PROGRESS
        ctx_f.data:curtains_opened()
        ctx_f.data:curtains_enabled()
        ctx_f:remove()
      --  WORLD.sounds:play_sound(WORLD.sounds.sounds.gate_close)
    end)
    cmd:add_action(close_parallel)
    cmd:add_action(function()
        COMMON.coroutine_wait(self.config.delay)--wait in full closed
        local ctx_f = COMMON.CONTEXT:set_context_top_curtains_gui()
        self.state = M.STATES.CLOSED
        ctx_f.data:curtains_closed()
        ctx_f:remove()

    end)

    ctx:remove()

    if (add) then
        cmd:update(0)
        self.commands_queue:add_action(cmd)
    end

    return cmd
end

M:init()

return M