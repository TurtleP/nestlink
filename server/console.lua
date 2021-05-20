--[[
    NOTE:

    This server code is heavily based on lovebird (https://github.com/rxi/lovebird)
    Most (if not all) functionality and code does come from there. Credits to rxi.
    Figuring out how it worked was honestly the most annoying part of it all.

    It is supposed to be a stripped down version that runs purely on a command line interface.
    The server-side Lua code will be put inside of LÖVE Potion and enabled when the console flag
    in conf.lua is active. The nim client (exe/app/linux exec) will be ran on the desktop. The idea
    is to not tax the console with running both client and server for this. Also coroutines don't work
    too well on 3DS, I suppose, but either way this should work™ when I test it on hardware.

    Hopefully I can make it less of lovebird's codebase and more of mine, as I do feel bad about re-using a
    majority of it. Though if it can't be helped, so be it since there's only so many ways to do some stuff.
--]]

local socket = require("socket")
io.stdout:setvbuf("no")

local server = {}

server.init = false

server.socket = nil
server.client = nil

server.history     = {}

server.hostname = {"*", 8000}
server.maxLines = 200

server.buffer = {}

server.timeStamp = false
server.wrapPrint = true

function server.print(...)
    local t = {}

    for i = 1, select("#", ...) do
      table.insert(t, tostring(select(i, ...)))
    end

    local str = table.concat(t, " ")
    local last = server.history[#server.history]

    if last and str == last.str then
        -- Update last line if this line is a duplicate of it
        last.time = os.time()
        last.count = last.count + 1
        server.recalculateBuffer()
    else
        -- Create new line
        server.pushline({ type = "output", str = str })
    end
end

function server.load(flags)
    server.socket = assert(socket.bind(unpack(server.hostname)))
    server.settimeout(0)

    if not flags then
        flags = {}
    end

    server.origPrint = print
    server.wrapPrint = flags.wrapPrint or true

    if server.wrapPrint then
        local oldPrint = print
        print = function(...)
            oldPrint(...)
            server.print(...)
        end
    end

    server.origPrint("STARTING LOVENEST")
    server.init = true
end

function server.update()
    if not server.init then
        server.load()
    end

    while true do
        local client = server.accept()

        if not client then
            break
        end

        server.onConnect(client)
    end

    -- poll data on the client socket
    if server.client then
        local status = server.receive(server.client, "*l")

        -- no status, kill it
        if not status then
            server.onDisconnect(server.client)
        end
    end
end

function server.map(t, func)
    local result = {}
    for key, value in pairs(t) do
        result[key] = func(value)
    end

    return result
end

function server.trace(...)
    local args = {...}

    local str = "[lovenest] " .. table.concat(server.map(args, tostring), " ")
    print(str)
end

function server.eval(str, params)
    -- finds the parameters of a function
    params = params and ("," .. params) or ""

    local f = function(x)
        -- calls the local echo function below
        return string.format(" echo(%q)", x)
    end

    -- wraps whatever text from input str to be echoed
    str = ("?>"..str.."<?lua"):gsub("%?>(.-)<%?lua", f)

    -- creates a lua code string to execute from data above
    -- something like `local echo (, arg1, arg2, ...) = ... echo(str)
    -- this allows loadstring to evaluate the data
    str = "local echo " .. params .. " = ..." .. str

    local func = assert(loadstring(str))

    return function(...)
        local output = {}
        local echo = function(str)
            table.insert(output, str)
        end

        func(echo, ...)
        return table.concat(server.map(output, tostring))
    end
end

-- actual magical stuff -- format the lines
-- based on their type and then re-map to the buffer table
-- ideally we just want to push this to the client socket
-- with whatever this line would be to not waste time
function server.recalculateBuffer()
    local function parseLine(line)
        local str = line.str

        if line.type == "error" then
            str = string.format("⚠ %s", str)
        end

        if line.count > 1 then
            str = string.format("(%d) ", line.count) .. str
        end

        if server.timeStamp then
            str = string.format("-> %s %s", os.date("%H:%M:%S", line.time), str)
        else
            str = string.format("-> %s", str)
        end

        return str
    end

    server.buffer = server.map(server.history, parseLine)
    server.send(server.client, server.buffer[#server.buffer])
end

-- called whenever server.print is called
-- pushes a line of type to the history
-- recalculates the buffer afterwards
function server.pushline(line)
    line.time = os.time()
    line.count = 1

    table.insert(server.history, line)
    if #server.history > server.maxLines then
        table.remove(server.history, 1)
    end
    server.recalculateBuffer()
end

-- send data to a client
-- eval is a string or function to call
-- if it's a function, xpcall it and send the newest buffer data
function server.send(client, eval)
    local res = eval

    if type(res) == "function" then
        local str = eval()

        if str:find("^=") then
            str = "print(" .. str:sub(2) .. ")"
        end

        xpcall(function()
            assert(loadstring(str, "input"))()
        end, server.onError)
        return
    end

    client:send(tostring(res) .. "\n")
end

-- receive data from a client
-- as long as we aren't finding it's closed
-- we just keep checking for data and return true
function server.receive(client, pattern)
    while true do
        local data, message = client:receive(pattern)

        -- If no data found, only return false
        -- when the message isn't "timeout" (aka "closed")
        if not data then
            if message ~= "timeout" then
                return false
            end
            return true
        else
            -- Whatever we got from data, parse the command
            -- case: globals -> send all global variables
            -- case: anything else -> parse Lua
            if data == "globals" then
                for name, value in pairs(_G) do
                    server.send(client, "global;" .. name .. ";" .. tostring(value))
                end
            else
                server.send(client, server.eval(data))
            end
            return true
        end
    end
end

-- when a client connects, add it to our
-- connections listings
function server.onConnect(client)
    local address = client:getsockname()
    client:settimeout(0)

    server.origPrint("Client Connected: " .. address)
    if not server.client then
        server.client = client
    end
end

function server.onDisconnect(client)
    local address = client:getsockname()
    server.origPrint("Client Disconnected: " .. address)

    if server.client then
        server.client:close()
    end
    server.client = nil
end

-- when there's an error in the lua parsing
-- this will push an error line to the buffer
function server.onError(error)
    server.pushline({ type = "error", str = error })
    if server.wrapPrint then
        server.origPrint("[lovenest] ERROR: " .. error)
    end
end

-- shorthand accept method
-- returns the client object (or nil)
function server.accept()
    return server.socket:accept()
end

function server.settimeout(time)
    return server.socket:settimeout(time)
end

return server
