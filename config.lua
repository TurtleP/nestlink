--[[
- @module config
- @brief Handles the configuration setup for nestlink.
--]]

local config = {}
config.filepath = "data/config.txt"

local stringx = require("libraries.batteries.stringx")
local version = "0.1.0"

--[[
- @brief Initialize a new configuration file.
--]]
function config:initFile()
    if not self:exists() then
        local buffer = love.filesystem.read(self.filepath)
        love.filesystem.write("config.txt", buffer)
    end
    love.event.quit()
end

function config:init(appVersion)
    version = appVersion

    return self
end

function config:help()
    local message = love.filesystem.read("data/help.txt")
    local saveDirectory = love.filesystem.getSaveDirectory()

    print(message:format(version, saveDirectory))
    love.event.quit()
end

--[[
- @brief Check if the config file exists.
- @return `boolean`.
]]
function config:exists()
    return love.filesystem.getInfo("config.txt")
end

--[[
- @brief Check if the address is valid.
- @param `string` Address value to check.
- @return `boolean`.
--]]
function config:isIPAddress(address)
    return address:match("^(%d+)%.(%d+)%.(%d+)%.(%d+)$")
end

--[[
- @brief Check if a list of IP addresses are valid.
- @param `table` List of IP addresses.
- @return `boolean`.
--]]
function config:checkIPAddresses(addresses)
    local result = {}

    for index = 1, #addresses do
        if self:isIPAddress(addresses[index]) then
            table.insert(result, addresses[index])
        else
            local message = "Address '%s' is not valid. Skipping."
            print(message:format(addresses[index]))
        end
    end

    return result
end

--[[
- @brief Parse the command line args *or* the config file.
- @param `table` The command line args from `love.load`.
--]]
function config:parse(args)
    if not args then
        local buffer = love.filesystem.read("config.txt")
        local data = assert:some(loadstring("return { " .. buffer .. " }"))()

        self.port = data.port
        self.addresses = self:checkIPAddresses(data.addresses)
    else
        if args[1] == "help" then
            return self:help()
        elseif args[1] == "init" then
            return self:initFile()
        end

        if #args >= 1 then
            if tonumber(args[1]) then
                self.port = tonumber(args[1])
            else
                local addresses = stringx.split(args[1], ",")
                self.addresses = self:checkIPAddresses(addresses)
            end
        end

        if #args == 2 then
            local addresses = stringx.split(args[2], ",")
            self.addresses = addresses
        end
    end
end

--[[
- @brief Get the data we need to run the server.
- @return `table` Configuration as { port = `number`, addresses = { `string`, `string`, ... } }.
--]]
function config:getData()
    return {port = self.port, addresses = self.addresses}
end

return config
