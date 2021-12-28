local helium = require("libraries.helium")
local theme  = require("gui.data.themes")

local tween = require("libraries.tween")

local elementCreator = helium(function(param, view)
    local width = param.width
    local height = param.height

    view.x = width  * 0.5
    view.y = height * 0.5
    view.w = 0
    view.h = 0

    local open_tween = tween.new(0.25, view, {x = 0, y = 0, w = width, h = height}, "inQuad")

    return function()
        local colors = theme:colors()
        open_tween:update(love.timer.getDelta())

        love.graphics.setColor(colors.shadow)
        love.graphics.rectangle("fill", view.x, view.y, view.w, view.h, 8, 8)

        love.graphics.setColor(colors.background)
        love.graphics.rectangle('fill', view.x + 2, view.y + 2, view.w - 4, view.h - 4, 8, 8)
    end
end)

return elementCreator
