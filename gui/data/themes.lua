local themes = {}

local theme_names   = {"light", "dark"}
local current_theme = theme_names[1]
local theme_toggle = false

local colors = require("gui.data.colors")

function themes:set(name)
    current_theme = name

    return current_theme
end

function themes:get()
    return current_theme
end

function themes:colors()
    return colors[current_theme]
end

function themes:toggle()
    theme_toggle = not theme_toggle
    current_theme = theme_names[theme_toggle and 2 or 1]

    return current_theme, theme_toggle
end

return themes
