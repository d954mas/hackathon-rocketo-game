local COMMON = require "libs.common"
local RichText = require "richtext.richtext"

local base = {
    fonts = {
        Base = {
            regular = hash("game_font"),
            italic = hash("game_font"),
            bold = hash("game_font"),
            bold_italic = hash("game_font"),
        },
    },
    align = RichText.ALIGN_CENTER,
    width = 400,
    color = vmath.vector4(1, 1, 1, 1.0),
    outline = vmath.vector4(0, 0, 0, 0.0),
    shadow = vmath.vector4(0, 0, 0, 0.0),
    position = vmath.vector3(0, 0, 0)
}

local GAME = {
    fonts = {
        Base = {
            regular = hash("game_font_world"),
            italic = hash("game_font_world"),
            bold = hash("game_font_world"),
            bold_italic = hash("game_font_world"),
        },
    },
    align = RichText.ALIGN_CENTER,
    width = 400,
    color = vmath.vector4(0, 0, 0, 0.8),
    outline = vmath.vector4(0, 0, 0, 0),
    shadow = vmath.vector4(0, 0, 0, 0.0),
    position = vmath.vector3(0, 0, 0),
    layers = {
        fonts = {
            [hash("game_font_world_bg")] = "text"
        }
    }
}

local GAME_BG = {
    fonts = {
        Base = {
            regular = hash("game_font_world_bg"),
            italic = hash("game_font_world_bg"),
            bold = hash("game_font_world_bg"),
            bold_italic = hash("game_font_world_bg"),
        },
    },
    align = RichText.ALIGN_CENTER,
    width = 400,
    color = vmath.vector4(0, 0, 0, 0.8),
    outline = vmath.vector4(0, 0, 0, 0),
    shadow = vmath.vector4(0, 0, 0, 0.0),
    position = vmath.vector3(0, 0, 0),
    layers = {
        fonts = {
            [hash("game_font_world_bg")] = "text"
        }
    }
}

local GAME_NUMBER = {
    fonts = {
        Base = {
            regular = hash("game_font_numbers"),
            italic = hash("game_font_numbers"),
            bold = hash("game_font_numbers"),
            bold_italic = hash("game_font_numbers"),
        },
    },
    align = RichText.ALIGN_CENTER,
    width = 400,
    color = vmath.vector4(1, 1, 1, 1),
    outline = vmath.vector4(0, 0, 0, 0),
    shadow = vmath.vector4(0, 0, 0, 0.0),
    position = vmath.vector3(0, 0, 0),
    layers = {
        fonts = {
            [hash("game_font_numbers")] = "text"
        }
    }
}

local base_left = COMMON.LUME.clone_deep(base)
base_left.align = RichText.ALIGN_LEFT

local M = {}

function M.make_copy(root, vars)
    local c = COMMON.LUME.clone_deep(root)
    COMMON.LUME.merge_table(c, vars)
    return c
end

M.BASE_CENTER = base
M.BASE_LEFT = base_left

M.GAME_CENTER = GAME
M.GAME_BG_CENTER = GAME_BG

M.GAME_NUMBER_CENTER = GAME_NUMBER

function M.base_center(vars)
    return M.make_copy(M.BASE_CENTER, vars)
end

function M.base_left(vars)
    return M.make_copy(M.BASE_LEFT, vars)
end

return M