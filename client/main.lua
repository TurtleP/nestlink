--[[
-- This is the client file that connects to the server
--]]

local client = {}

-- max amount of retries
local MAX_RETRIES = 3
client.retries = 0

-- max time until timeout
local MAX_TIMEOUT = 3
client.timeout = 0

local socket = require("socket")
local timer = require("love.timer")

function client:log(format, ...)
    local dateTime = os.date("%Y-%m-%d/%H:%M:%S")
    print("[" .. dateTime .. "] " .. string.format(format, ...))
end

function client:init(host)
    self.socket = socket.tcp()


    while self.retries < MAX_RETRIES do
        local success = self.socket:connect(host, 8000)

        if success then
            break
        end

        while self.timeout < MAX_TIMEOUT do
            self.timeout = self.timeout + timer.getDelta()
            love.timer.sleep(love.timer.getDelta())
        end
5
        if self.timeout >= MAX_TIMEOUT then
            self.timeout = self.timeout - MAX_TIMEOUT
            self.retries = self.retries + 1
            self:log("Connection to Remote timed out, retrying: %d/%d", self.retries, MAX_RETRIES)
        end
    end

    if self.retries == MAX_RETRIES then
        print("f in the chat")
    end
end

client:init()
