local helium = require("libraries.helium")
local theme  = require("gui.data.themes")

local fonts = require("gui.data.fonts")

local elementCreator = helium(function(param, view)
    local text = param.text

    return function()
        local colors = theme:colors()

        love.graphics.setColor(colors.text)
        love.graphics.print(text, fonts.small, 0, 0)
    end
end)

return elementCreator
