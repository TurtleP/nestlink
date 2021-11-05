local server = require("server")
local stringx = require("batteries.stringx")

local commandline = { "port", "addresses" }

local version = "0.1.0"
local help_message = [[
nestlink server %s

nestlink [port] [addresses]

Options
  port      - port to listen on
  addresses - addresses to allow, separated by commas
]]
function love.load(arg)
    local serverConfig = {}

    if arg[1] == "help" then
        print(help_message:format(version))
        return love.event.quit()
    end

    if #arg == 1 then
        serverConfig.port = tonumber(arg[1])
    end

    if #arg == 2 then
        local addresses = stringx.split(arg[2], ",")
        serverConfig.addresses = addresses
    end

    server:config(serverConfig)
end

function love.update()
    server:update()
end
