local helium = require("libraries.helium")
local input  = require('libraries.helium.core.input')
local state  = require('libraries.helium.hooks.state')

local theme = require("gui.data.themes")

local callback = require("libraries.helium.hooks.callback")

local elementCreator = helium(function(param, view)
    local font = param.font
    local text = param.text
    local alignment =  param.alignment

    local background_color = param.background or {0, 0, 0, 0}
    local hover_color = param.hover_background or {0, 0, 0, 0}

    local current_color = background_color

    local event = param.event or function() end
    local outsideEvent = param.eventOutside or function() end

    local limit = view.w

    local current_state = state({hovered = false, initialText = text, text = text})

    local enabled = param.enabled ~= nil and false
    if not param.enabled then
        enabled = true
    end

    input("hover", function()
        if not enabled then
            return
        end

        local colors = theme:colors()

        current_state.hovered =  true
        current_color = colors.hover

        return function()
            current_state.hovered = false
            current_color = background_color
        end
    end)

    input("clicked", function()
        if current_state.hovered then
            event(current_state)

            local colors = theme:colors()
            current_color = colors.hover
        end
    end)

    input("mousepressed_outside", function()
        if outsideEvent then
            outsideEvent(current_state)
        end
    end)

    callback("setEnabled", function(isEnabled)
        enabled = isEnabled
    end)

    callback("background", function(color)
        background_color = color
    end)

    return function()
        local colors = theme:colors()

        love.graphics.setColor(current_color)
        love.graphics.rectangle("fill", 0, 0, view.w, view.h, 4, 4)

        love.graphics.setColor(colors.text)
        love.graphics.printf(current_state.text, font, 0, (view.h - font:getHeight()) * 0.5, limit, alignment)
    end
end)

return elementCreator
