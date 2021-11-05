--[[
- @file server.lua
- @brief This is the server file that the client connects to
--]]

local server = {}

assert = require("batteries.assert")
local socket = require("socket")

server.inited = false

server.clients = {}

server.host = "*"
server.port = 8000

server.allowedAddresses = { "127.0.0.1" }

local __NULL__FUNC__ = function() end

function server:log(format, ...)
    local dateTime = os.date("%m/%d/%Y %H:%M:%S")
    print("[" .. dateTime .. "] " .. string.format(format, ...))
end

--[[
- @brief Initialize the server protocol.
--]]
function server:init()
    assert:equal(self.inited, false)

    self.socket = socket.bind(self.host, self.port)
    assert:some(self.socket, "socket failed to be created")

    self.socket:settimeout(0)

    local _, port = self.socket:getsockname()
    self:log("Server initialized on port %d", port)

    self.inited = true
end

--[[
- @brief Configure the server settings.
- @param `config` -> table of { port = `number`, addresses = { `address1`, `address2`, `...` } }
--]]
function server:config(config)
    if config then
        if config.port then
            self.port = assert:type(config.port, "number")
        end

        if config.addresses then
            if type(config.addresses) ~= "nil" then
                self.allowedAddresses = assert:type(config.addresses, "table")
                return
            end
            self.allowedAddresses = nil
        end
    end
end

--[[
- @brief Handle receiving of data per line.
- @param client -> Client object that was accepted in `client:update()`.
- @note If there's no data and the Client timed out, we want to wait for more data.
- @note If there's no data and we get any other message, close the Client connection
- @note If there's data, we want to return it to the main server to log that we got it
--]]
function server:receive(client)
    while true do
        local data, message = client:receive("*l")

        if not data then
            if message == "timeout" then
                coroutine.yield(true)
            else
                coroutine.yield(nil)
            end
        else
            return data
        end
    end
end

--[[
- @brief Handle when we get a Client to connect.
- @param client -> Client object from `server:update()`
- @note This function also handls receiving data from the Client.
- @note The server expects already-parsed Lua data from the Client's end.
--]]
function server:onConnect(client)
    local ip, _ = client:getsockname()
    assert:some(ip, "failed to retrieve sockname for client")

    while true do
        local line, _ = self:receive(client)

        if not line or #line == 0 then
            break
        end

        local dataLog = line:gsub("%[?%]?", "")
        self:log(dataLog:gsub(",", ", "))
    end

    client:close()
end

--[[
- @brief Check if an IP address is allowed to connect.
- @param `hostname` -> Address to check.
- @note `server.allowedAddresses` handles this, so add IP addresses that you trust.
- @note However, setting the table to either nil or "*" can allow any connection.
--]]
function server:checkAddressAllowed(hostname)
    if self.allowedAddresses == nil then
        return true
    end

    for _, address in ipairs(self.allowedAddresses) do
        local pattern = "^" .. address:gsub("%.", "%%."):gsub("%*", "%%d*") .. "$"
        if hostname:match(pattern) then
            return true
        end
    end

    return false
end

--[[
- @brief Update the server protocol.
- @note Waits and accepts clients to be useable for data reception.
- @note Once a Client is accepted, it is checked against `server.allowedAddresses`.
- @note It is then kept alive until the server has been told that the Client disconnects.
--]]
function server:update()
    if not self.inited then
        self:init()
    end

    while true do
        local client = self.socket:accept()

        if not client then
            break
        end

        client:settimeout(0)

        local ip, port = client:getpeername()

        if self:checkAddressAllowed(ip) then
            local connection = coroutine.wrap(function()
                xpcall(self:onConnect(client), __NULL__FUNC__)
            end)

            self.clients[connection] = { ip = ip, port = port }
            self:log("Client Connection: %s:%d", ip, port)
        else
            self:log("Got non-allowed connection from %s:%d", ip, port)
            client:close()
        end
    end

    for connection, _ in pairs(self.clients) do
        local status = connection()
        if status == nil then
            local v = self.clients[connection]
            self:log("Client Disconnected: %s:%d", v.ip, v.port)
            self.clients[connection] = nil
        end
    end
end

function server:close()
    self.socket:shutdown()
    self.socket:close()
end

return server
