local themes = {}

local colors = require("gui.data.colors")

local tween = require("libraries.tween")
local mathx = require("libraries.batteries.mathx")

local theme_tween = nil

local theme_names   = {"light", "dark"}
local current_theme  = 1
local current_colors = colors[current_theme]

local toggle = true

function themes:set(mode)
    current_colors = colors[mode]
    current_theme = mode
end

function themes:get()
    return current_theme
end

function themes:colors()
    return current_colors
end

function themes:translateColors(dt)
    if theme_tween then
        if not toggle then
            dt = -dt
        end
        theme_tween:update(dt)
    end
end

function themes:toggle()
    current_theme = mathx.wrap(current_theme + 1, 1, 3)

    if not theme_tween then
        theme_tween = tween.new(0.25, current_colors, colors[current_theme], "inQuad")
    else
        toggle = not toggle
    end

    return current_theme, toggle
end

return themes
