local server = require("server")
local config = require("config")
local scene  = require("scene")

_NESTLINK_VERSION = "0.3.0"


function love.load(args)
    config:init(_NESTLINK_VERSION):parse(args)
    server:config(config:getData())

    scene:load()
end

function love.update(dt)
    scene:update(dt)
end

function love.draw()
    scene:draw()
end

function love.quit()
    server:close()
end
