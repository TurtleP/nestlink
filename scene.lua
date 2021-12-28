local helium = require("libraries.helium")
local hook   = require("libraries.hook")

local themes = require("gui.data.themes")
local fonts  = require("gui.data.fonts")
local colors = nil

local panel  = require("gui.panel")
local statusbar = require("gui.statusbar")
local textinput = require("gui.textinput")
local combobox  = require("gui.combobox")
local menubar   = require("gui.menubar")
local label     = require("gui.label")
local button    = require("gui.button")
local scrollbar = require("gui.scrollbar")

local savedata = require("libraries.savedata")
local server   = require("server")

local scene = {}

local scroll_bar
function scene:load()
    savedata:load()
    colors = themes:colors()

    self.scene = helium.scene.new(false)
    self.scene:activate()

    -- local background = panel({}, love.graphics.getDimensions())
    -- background:draw(0, 0)

    local menu_bar = menubar(nil, love.graphics.getWidth(), 42)
    menu_bar:draw(0, 0)

    local host_label = label({text = "Host:"}, fonts.small:getWidth("Host:"), fonts.small:getHeight())
    host_label:draw(8, 12)

    local host_input = combobox({max = 15, exceptions = "([0-9%.])", items = savedata:get("hosts"), height = 24}, 160, 24)
    host_input:draw(54, 8)

    local port_label = label({text = "Port:"}, fonts.small:getWidth("Port:"), fonts.small:getHeight())
    port_label:draw(host_input.view.x + host_input.view.w + 8, 12)

    local port_input = textinput({max = 5, numeric = true}, 100, 24)
    port_input:draw(port_label.view.x + port_label.view.w + 8, 8)

    local connect_button = button({text = "", font = fonts.fontAwesomeSolid, alignment = "center",
        event = function(state)
            if state.text ~= "" then
                host_input.setReadOnly(true)
                port_input.setReadOnly(true)

                server:config({port = port_input.getText(), addresses = {host_input.getText()}})
                server:init()

                state.text = ""
                return
            end
            state.text = state.initialText

            host_input.setReadOnly(false)
            port_input.setReadOnly(false)

            server:close()
        end
    }, 32, 32)
    connect_button:draw(8 + port_input.view.x + port_input.view.w, 4)

    local save_button = button({text = "", font = fonts.fontAwesomeSolid, alignment = "center",
        event = function(state)
            host_input.addItem(host_input.getText())
            savedata:addValueToField("hosts", host_input.getText(), true)
        end
    }, 32, 32)
    save_button:draw(4 + connect_button.view.x + connect_button.view.w, 4)

    local theme_button = button({alignment = "center", text = "", font = fonts.fontAwesomeSolid, background = {0, 0, 0, 0},
        event = function(state)
            local theme_name, toggle = themes:toggle()
            savedata:updateField("theme", theme_name, true)

            if toggle then
                state.text = ""
                return
            end
            state.text = state.initialText
        end
    }, 32, 32)
    theme_button:draw(love.graphics.getWidth() - 40, 4)

    local status_bar = statusbar(nil, love.graphics.getWidth(), 32)
    status_bar:draw(0, love.graphics.getHeight() - 32)

    local version_label = label({text = _NESTLINK_VERSION}, fonts.small:getWidth(_NESTLINK_VERSION), fonts.small:getHeight())
    version_label:draw(love.graphics.getWidth() - fonts.small:getWidth(_NESTLINK_VERSION) - 8, (love.graphics.getHeight() - 32) + ((32 - fonts.small:getHeight()) * 0.5) + 1)

    local status_label = label({text = "Not Connected"}, fonts.small:getWidth("Not Connected"), fonts.small:getHeight())
    status_label:draw(8, (love.graphics.getHeight() - 32) + ((32 - fonts.small:getHeight()) * 0.5) + 1)

    scroll_bar = scrollbar({range = 0, height = status_bar.view.y - (menu_bar.view.y + menu_bar.view.h)}, 4, status_bar.view.y - (menu_bar.view.y + menu_bar.view.h))
    scroll_bar:draw(love.graphics.getWidth() - 8, menu_bar.view.y + menu_bar.view.h)

    onLogHistoryChanged = hook.add(onLogHistoryChanged, function()
        local len = #server:getLogs()

        if scroll_bar.getHeight then
            local height = scroll_bar.getHeight()

            if len > 23 then
                scroll_bar.updateHeight(height - 23)
                scroll_bar.updateRange(len)
            end
        end
    end)

    self.smoothScroll = 0
end

local scroll_rate = 24
function scene:update(dt)
    self.scene:update(dt)
    themes:translateColors(dt)
end

function scene:keypressed(key)
    if key == "a" then
        server:log("Random Value: " .. love.math.random())
    end
end

function scene:wheelmoved(x, y)
    scroll_bar.scroll(y)
end

function scene:draw()
    love.graphics.setColor(colors.background)
    love.graphics.rectangle("fill", 0, 42, love.graphics.getWidth(), love.graphics.getHeight() - 74)

    love.graphics.setColor(1, 1, 1)

    self:drawHistory()

    self.scene:draw()

    if server:initialized() then
        server:update()
    end
end

function scene:drawHistory()
    love.graphics.setScissor(0, 42, love.graphics.getWidth(), love.graphics.getHeight() - 74)
    local log_history = server:getLogs()

    local y = (love.graphics.getHeight() - 32)
    local height = fonts.console:getHeight()

    local row_count = math.floor((y - 42) / fonts.console:getHeight())
    for row = 1, row_count do
        local highlight = nil
        if (row % 2) == 0 then
            highlight = colors.hover
        end

        if highlight then
            love.graphics.setColor(highlight)
            love.graphics.rectangle("fill", 0, y - (row_count - row + 1) * height, love.graphics.getWidth(), height)
        end
    end

    love.graphics.push()

    if scroll_bar.getValue then
        love.graphics.translate(0, (scroll_bar.getValue() * scroll_rate) * (#log_history / 23))
    end

    for index = 1, #log_history do
        local value = log_history[index]

        love.graphics.setColor(colors.text)
        love.graphics.print(value, fonts.console, 4, y - (#log_history - index + 1) * height)
    end

    love.graphics.pop()

    love.graphics.setScissor()
end

return scene
