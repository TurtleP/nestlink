local server = require("server")
local config = require("config")

local version = "0.1.0"

local function showHelp()
    local message = love.filesystem.read("data/help.txt")
    local saveDirectory = love.filesystem.getSaveDirectory()

    print(message:format(version, saveDirectory))

    love.event.quit()
end

function love.load(args)
    if args[1] == "help" then
        return showHelp()
    elseif args[1] == "init_config" then
        return config:init()
    elseif #args == 0 and config:exists() then
        config:parse()
    else
        config:parse(args)
    end

    server:config(config:getData())
end

function love.update()
    server:update()
end
