local helium = require("libraries.helium")
local panel  = require("gui.panel")

local themes = require("gui.data.themes")
local fonts  = require("gui.data.fonts")
local colors = themes:colors()

local statusbar = require("gui.statusbar")
local textinput = require("gui.textinput")
local menubar   = require("gui.menubar")
local label     = require("gui.label")
local button    = require("gui.button")

local scene = {}

function scene:load()
    self.scene = helium.scene.new(false)
    self.scene:activate()

    local panel = panel({}, love.graphics.getDimensions())
    panel:draw(0, 0)

    local menu_bar = menubar(nil, love.graphics.getWidth(), 42)
    menu_bar:draw(0, 0)

    local host_label = label({text = "Host:"}, fonts.small:getWidth("Host:"), fonts.small:getHeight())
    host_label:draw(8, 12)

    local host_input = textinput({max = 15, exceptions = "([0-9%.])"}, 128, 24)
    host_input:draw(54, 8)

    local port_label = label({text = "Port:"}, fonts.small:getWidth("Port:"), fonts.small:getHeight())
    port_label:draw(190, 12)

    local port_input = textinput({max = 5, numeric = true}, 100, 24)
    port_input:draw(236, 8)

    local connect_button = button({text = "", font = fonts.fontAwesomeSolid, alignment = "center",
        event = function(state)
            if state.text ~= "" then
                state.text = ""
                return
            end
            state.text = state.initialText
        end
    }, 32, 32)
    connect_button:draw(8 + port_input.view.x + port_input.view.w, 4)

    local status_bar = statusbar(nil, love.graphics.getWidth(), 32)
    status_bar:draw(0, love.graphics.getHeight() - 32)

    local version_label = label({text = _NESTLINK_VERSION}, fonts.small:getWidth(_NESTLINK_VERSION), fonts.small:getHeight())
    version_label:draw(love.graphics.getWidth() - fonts.small:getWidth(_NESTLINK_VERSION) - 8, (love.graphics.getHeight() - 32) + ((32 - fonts.small:getHeight()) * 0.5) + 1)

    local theme_button = button({alignment = "center", text = "", font = fonts.fontAwesomeSolid, background = {0, 0, 0, 0},
        event = function(state)
            local _, toggle = themes:toggle()

            if toggle then
                state.text = ""
                return
            end
            state.text = state.initialText
        end
    }, 32, 32)
    theme_button:draw(love.graphics.getWidth() - 40, 4)

    local status_label = label({text = "Not Connected"}, fonts.small:getWidth("Not Connected"), fonts.small:getHeight())
    status_label:draw(8, (love.graphics.getHeight() - 32) + ((32 - fonts.small:getHeight()) * 0.5) + 1)
end

function scene:update(dt)
    self.scene:update(dt)
    themes:translateColors(dt)
end

function scene:draw()
    self.scene:draw()
end

return scene
