local helium   = require("libraries.helium")
local input    = require('libraries.helium.core.input')
local state    = require('libraries.helium.hooks.state')
local callback = require("libraries.helium.hooks.callback")

local theme  = require("gui.data.themes")
local fonts = require("gui.data.fonts")

local tween = require("libraries.tween")

local elementCreator = helium(function(param, view)
    local hint = param.hint or ""
    local max_length = param.max or 12

    local is_numeric = param.numeric
    local exceptions = param.exceptions

    local on_focus = param.focused or function() end

    local read_only = param.read_only ~= nil and true or false

    local text = ""

    local old_width = love.graphics.getLineWidth()

    local bars = {}
    bars[1] = {x = view.w / 2, y = view.h - 2, width = 0, height = 1}
    bars[2] = {x = view.w / 2, y = view.h - 1, width = 0, height = 1}

    local tween_speed = 0.2
    local tween_type  = "outQuad"

    local bar_tweens = {
        tween.new(tween_speed, bars[1], {x = 0, width = view.w}, tween_type),
        tween.new(tween_speed, bars[2], {x = 1, width = view.w - 2}, tween_type)
    }

    local current_state = state({focused = false})

    local key_input = input("keypressed", function(key)
        if key == "backspace" then
            text = text:sub(1, -2)
        end
    end)

    callback("getText", function()
        return text
    end)

    callback("setText", function(newText)
        text = newText
    end)

    callback("setFocus", function(focus)
        current_state.focused = focus
    end)

    local text_input = input("textinput", function(value)
        if is_numeric and not tonumber(value) then
            return
        elseif exceptions and not value:match(exceptions) then
            return
        end

        if current_state.focused then
            if #text < max_length then
                text = text .. value
            end
        end
    end)

    callback("setReadOnly", function(readOnly)
        read_only = readOnly
        if readOnly then
            key_input:off()
            text_input:off()
            return
        end
        key_input:on()
        text_input:on()
    end)

    input("mousepressed_outside", function()
        for _, value in ipairs(bar_tweens) do
            value:reset()
        end
        current_state.focused = false

        key_input:off()
        text_input:off()
    end)

    local click = input("clicked", function()
        if read_only then
            return
        end

        current_state.focused = true

        key_input:on()
        text_input:on()

        on_focus()
    end)

    if read_only then
        click:off()
    end

    return function()
        local colors = theme:colors()

        love.graphics.setColor(colors.background)
        love.graphics.rectangle('fill', 0, 0, view.w, view.h, 4, 4)

        love.graphics.setColor(colors.shadow)
        love.graphics.rectangle("line", 0, 0, view.w, view.h, 4, 4)

        local color, display_text = colors.textHint, hint
        if text ~= "" then
            color, display_text = colors.text, text
        end

        if read_only then
            color = colors.textHint
        end

        love.graphics.setColor(color)
        love.graphics.print(display_text, fonts.small, 4, (view.h - fonts.small:getHeight()) * 0.5)

        if current_state.focused then
            for index = 1, #bar_tweens do
                local bar = bars[index]

                bar_tweens[index]:update(love.timer.getDelta())

                love.graphics.setColor(colors.accentColor)
                love.graphics.rectangle("fill", bar.x, bar.y, bar.width, bar.height)
            end

            local r, g, b, a = unpack(colors.text)
            love.graphics.setColor(r, g, b, (a or 1) * (1 - math.abs(math.sin(love.timer.getTime() * 3))))
            love.graphics.rectangle("fill", 4 + fonts.small:getWidth(text), 2, 2, fonts.small:getHeight())
        end
    end
end)

return elementCreator
