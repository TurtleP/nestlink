local helium = require("libraries.helium")
local input  = require('libraries.helium.core.input')
local callback = require("libraries.helium.hooks.callback")
local state    = require('libraries.helium.hooks.state')
local size     = require("libraries.helium.hooks.setSize")

local fonts = require("gui.data.fonts")
local theme = require("gui.data.themes")

local textinput = require("gui.textinput")
local button    = require("gui.button")

local elementCreator = helium(function(param, view)
    local read_only = param.read_only ~= nil and true or false

    local max_length = param.max
    local exceptions = param.exceptions

    local items = param.items or {}
    local buttons = {}

    if read_only then
        max_length = 0
    end

    local current_state = state({open = false})

    local height = param.height
    local drop_button = nil

    local textfield = textinput({max = max_length, exceptions = exceptions, focused = function()
        current_state.open = false
    end}, view.w, height)

    local button_config =
    {
        text = "",
        font = fonts.small,
        background = {0, 0, 0, 0},
        event = function(state)
            textfield.setText(state.initialText)
            current_state.open = false
        end
    }

    local configs = {}

    local function copy(t, src)
        if not t then
            t = {}
        end

        for key, value in pairs(src) do
            t[key] = value
        end

        return t
    end

    drop_button = button({alignment = "center", text = "", font = fonts.fontAwesomeSolid, background = {0,0 ,0, 0},
        event = function(_state)
            current_state.open = not current_state.open

            if current_state.open then
                for index = 1, #items do
                    configs[index] = copy({}, button_config)
                    configs[index].text = items[index]

                    buttons[index] = button(configs[index], view.w, fonts.small:getHeight() + 4)
                end

                view.h = view.h + ((#items + 1) * fonts.small:getHeight())
                return
            end
            view.h = height
        end
    }, 24, 16)

    input("mousepressed_outside", function()
        textfield.setFocus(false)
        current_state.open = false
    end)

    callback("addItem", function(value)
        table.insert(items, tostring(value))
    end)

    callback("getText", function()
        return textfield.getText()
    end)

    callback("setReadOnly", function(readOnly)
        textfield.setReadOnly(readOnly)
        drop_button.setEnabled(not readOnly)
    end)

    callback("setItems", function(...)
        local values = {...}
        if type(...) == "table" then
            values = ...
        end

        for index = 1, #values do
            table.insert(items, tostring(values[index]))
        end
    end)

    local function forceButtonColors(color)
        for index = 1, #buttons do
            if buttons[index].background then
                buttons[index].background(color)
            end
        end
    end

    return function()
        local colors = theme:colors()

        textfield:draw(0, 0)

        drop_button:draw(view.w - 28, (height - drop_button.view.h) * 0.5)

        if current_state.open then
            for index = 1, #buttons do
                buttons[index]:draw(0, height + (index - 1) * buttons[index].view.h)
            end
        end

        love.graphics.setColor(1, 1, 1, 0.25)
        love.graphics.rectangle("fill", 0, 0, view.w, view.h)
    end
end)

return elementCreator
