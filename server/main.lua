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

    for index = 1, #commandline do
        local v = commandline[index]
        for argindex = 1, #arg do
            if v == "port" then
                serverConfig.port = arg[argindex]
            elseif v == "addresses" then
                local addresses = stringx.split(arg[argindex], ",")
                serverConfig.addresses = addresses
            end
        end
    end

    server:config(serverConfig)
end

function love.update(dt)
    server:update()
end
