local helium = require("libraries.helium")
local input  = require('libraries.helium.core.input')
local state  = require('libraries.helium.hooks.state')

local theme = require("gui.data.themes")

local callback = require("libraries.helium.hooks.callback")

local elementCreator = helium(function(param, view)
    local bar_height = param.height or 64
    local position = 0

    local step = param.step or 0.2
    local range = param.range or 0

    local xrange = 0
    local yrange = 0

    if view.h > view.w then
        yrange = range - view.h
    else
        xrange = range - view.w
    end

    local current_state = state({clicked = false, hovered = false})

    callback("updateHeight", function(height)
        bar_height = math.max(height, 32)
    end)

    callback("updateRange", function(limit)
        range = limit

        if view.h > view.w then
            yrange = view.h - range
        else
            xrange = range - view.w
        end
    end)

    callback("getValue", function()
        return position
    end)

    callback("getHeight", function()
        return bar_height
    end)

    callback("scroll", function(dir)
        if bar_height >= view.h then
            return
        end

        if dir > 0 then
            position = math.max(0, position - step)
        elseif dir < 0 then
            position = math.min(1, position + step)
        end
    end)

    return function ()
        local colors = theme:colors()

        love.graphics.setColor(colors.unfocused)
        love.graphics.rectangle("fill", 0, 2 + (yrange * position), view.w, bar_height - 2)
    end
end)

return elementCreator
