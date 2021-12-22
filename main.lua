local server = require("server")
local config = require("config")

local version = "0.2.1"

local function showHelp()
    local message = love.filesystem.read("data/help.txt")
    local saveDirectory = love.filesystem.getSaveDirectory()

    print(message:format(version, saveDirectory))
end

function love.load(args)
    if args[1] == "help" then
        showHelp()
        love.event.quit()
    elseif args[1] == "init_config" then
        config:init()
        love.event.quit()
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

function love.quit()
    server:close()
end
