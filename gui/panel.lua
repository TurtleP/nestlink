local helium = require("libraries.helium")
local theme  = require("gui.data.themes")

local elementCreator = helium(function(param, view)
    local corner_radius = param.cornerRadius or {x = 0, y = 0}

    return function()
        local colors = theme:colors()

        love.graphics.setColor(colors.background)
        love.graphics.rectangle('fill', 0, 0, view.w, view.h, corner_radius.x, corner_radius.y)
    end
end)

return elementCreator
