--[[
-- This is the server file that the client connects to
--]]

local server = {}

assert = require("assert")
local socket = require("socket")

server.inited = false

server.clients = {}
server.magic_str = "nestlink"

server.host = "*"
server.port = 8000

server.allowed = { "127.0.0.1" }

local __NULL__FUNC__ = function() end

function server:log(format, ...)
    local dateTime = os.date("%Y-%m-%d/%H:%M:%S")
    print("[" .. dateTime .. "] " .. string.format(format, ...))
end

--[[
-- Initialize the server
--]]
function server:init()
    self.socket = socket.bind(self.host, self.port)
    assert:some(self.socket, "socket failed to be created")

    self.socket:settimeout(0)
    self.inited = true

    self:log("Server Initialized")
end

--[[
-- Handle receiving of data per line
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
-- The server expects already-parsed Lua data
-- So we're just gonna print whatever we get
--]]
function server:onConnect(client)
    local ip, _ = client:getsockname()
    assert:some(ip, "failed to retrieve sockname for client")

    while true do
        local line, _ = self:receive(client)

        if not line or #line == 0 then
            break
        end

        print(line)
    end

    client:close()
end

--[[
-- Update the server
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

        local ip, port = client:getsockname()

        local connection = coroutine.wrap(function()
            xpcall(self:onConnect(client), __NULL__FUNC__)
        end)

        self.clients[connection] = { ip = ip, port = port }
        self:log("Client Connection: %s:%d", ip, port)
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
    self.socket:close()
end

return server
