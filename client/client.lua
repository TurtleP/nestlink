--[[
-- This is the client file that connects to the server
--]]

local client = {}

-- max amount of retries
local MAX_RETRIES = 3
client.retries = 0

client.port = 8000

-- max time until timeout
local MAX_TIMEOUT = 3

local socket = require("socket")

local _print = print

--[[
- @brief Logs messages with date and time.
- @param `format` -> Message format, see https://www.lua.org/pil/20.2.html.
- @param `...` -> Variadic args for `format`.
--]]
function client:log(format, ...)
    local dateTime = os.date("%Y-%m-%d/%H:%M:%S")
    _print("[" .. dateTime .. "] " .. string.format(format, ...))
end

--[[
- @brief `print` overriding function.
- @param args: `...` -> variadic args to print.
- @note Passing `nil` works, but it's stupid because I had to make a workaround.
- @note Without `nil` being a string, it would just break the server connection.
--]]
function print(...)
    local arg, results = ..., nil
    local length = select("#", ...)

    if type(arg) == "function" then
        results = { pcall(arg) }
    elseif length > 1 then
        results = table.concat({...}, ", ")
        return client:send(results)
    elseif type(arg) == "nil" then
        results = { "nil" }
    else
        results = { ... }
    end

    local sending = ""
    for index = 1, #results do
        local add = ""
        if index < #results then
            add = ", "
        end
        sending = sending .. tostring(results[index]) .. add
    end
    client:send(sending)
end

--[[
- @brief Attempt to connect to `host`:8000 server.
- @param `host` -> The IP address from the `love.conf` console field.
- @return `success` -> boolean.
--]]
function client:tryConnection(host)
    local success = self.socket:connect(host, 8000)

    return success
end

--[[
- @brief Initialize the client protocol.
- @param `host` -> The IP address from the `love.conf` console field.
--]]
function client:init(host)
    self.socket = socket.tcp()
    self.socket:settimeout(MAX_TIMEOUT)

    while self.retries < MAX_RETRIES do
        local success = self:tryConnection(host)

        if not success then
            self.retries = self.retries + 1
            self:log("Connection to Remote timed out, retrying: %d/%d", self.retries, MAX_RETRIES)
        else
            break
        end
    end

    if self.retries == MAX_RETRIES then
        self:log("Failed to connect to Remote %s:%d", host, self.port)
    end
end

--[[
- @brief Send a string of data to the server.
- @param `data` -> Datagram message to send.
--]]
function client:send(data)
    self.socket:send(data .. "\n")
    self:log("Sending '%s' to server", data)
end
