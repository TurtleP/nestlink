local helium  = require("libraries.helium")
local theme   = require("gui.data.themes")

local elementCreator = helium(function(param, view)
    return function()
        local colors = theme:colors()

        love.graphics.setColor(colors.menubar)
        love.graphics.rectangle('fill', 0, 2, view.w, view.h - 2)

        love.graphics.setColor(colors.shadow)
        love.graphics.rectangle("fill", 0, 0, view.w, 2)
    end
end)

return elementCreator
