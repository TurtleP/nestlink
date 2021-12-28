local helium = require("libraries.helium")
local theme  = require("gui.data.themes")

local fonts = require("gui.data.fonts")

local callback = require("libraries.helium.hooks.callback")

local elementCreator = helium(function(param, view)
    local text = param.text
    local font = param.font or fonts.small

    callback("setText", function(newText)
        text = newText
    end)

    return function()
        local colors = theme:colors()

        love.graphics.setColor(colors.text)
        love.graphics.print(text, font, 0, 0)
    end
end)

return elementCreator
