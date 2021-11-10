--[[
- @file config.lua
- @brief Handles the configuration setup for nestlink.
--]]

local config = {}
config.filepath = "data/config.txt"

local stringx = require("batteries.stringx")

--[[
- @brief Initialize a new configuration file.
--]]
function config:init()
    if not self:exists() then
        local buffer = love.filesystem.read(self.filepath)
        love.filesystem.write("config.txt", buffer)
    end
end

--[[
- @brief Check if the config file exists.
- @return `boolean`
]]
function config:exists()
    return love.filesystem.getInfo("config.txt")
end

--[[
- @brief Parse the command line args *or* the config file.
- @param `args` The command line args from `love.load`.
--]]
function config:parse(args)
    if not args then
        local buffer = love.filesystem.read("config.txt")
        local data = assert(loadstring("return { " .. buffer .. " }"))()

        self.port = data.port
        self.addresses = data.addresses
    else
        if #args >= 1 then
            self.port = tonumber(args[1])
        end

        if #args == 2 then
            local addresses = stringx.split(args[2], ",")
            self.addresses = addresses
        end
    end
end

--[[
- @brief Get the data we need to run the server.
- @return `table` { port = `number`, addresses = { `string`, `string`, ... } }
--]]
function config:getData()
    return {port = self.port, addresses = self.addresses}
end

return config
