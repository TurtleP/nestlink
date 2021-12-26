local themes = {}

local theme_names   = {"light", "dark"}
local current_theme = theme_names[1]
local theme_toggle = false

local colors = require("gui.data.colors")

local tween = require("libraries.tween")
local theme_tween = nil

function themes:set(name)
    current_theme = name

    return current_theme
end

function themes:get()
    return current_theme
end

local current_colors = colors[current_theme]
local toggle = true

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
    theme_toggle = not theme_toggle
    current_theme = theme_names[theme_toggle and 2 or 1]

    if not theme_tween then
        theme_tween = tween.new(0.25, current_colors, colors[current_theme], "inQuad")
    else
        toggle = not toggle
    end

    return current_theme, theme_toggle
end

return themes
