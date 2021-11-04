local server = require("server")
local stringx = require("batteries.stringx")

local commands = {}
commands.port      = { long = "--port",      short = "-p", seen = false }
commands.addresses = { long = "--addresses", short = "-a", seen = false }

function love.load(arg)
    local serverConfig = {}

    for key, value in pairs(commands) do
        for index = 1, #arg do
            local v = stringx.split(arg[index], "=")
            if key == "port" then
                if value.long == v[1] or value.short == v[1] then
                    serverConfig.port = tonumber(v[2])
                end
            elseif key == "addresses" then
                if value.long == v[1] or value.short == v[1] then
                    local addresses = stringx.split(v[2], ",")
                    serverConfig.addresses = addresses
                end
            end
        end
    end

    server:config(serverConfig)
end

function love.update(dt)
    server:update()
end
