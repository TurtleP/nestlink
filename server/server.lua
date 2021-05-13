local socket = require("socket")
io.stdout:setvbuf("no")

local server = {}

server.socket  = nil

server.history     = {}
server.connections = {}

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

function server.init(flags)
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
end

function server.update()
    while true do
        local client = server.accept()

        if not client then
            break
        end

        server.onConnect(client)
    end

    for address, client in pairs(server.connections) do
        local status = server.receive(client, "*l")

        if not status then
            server.origPrint("Client " .. address .. " disconnected!")
            server.connections[address] = nil
        end

        if server.bufferChanged then
            server.send(client, server.buffer[#server.buffer])
            server.bufferChanged = false
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
    params = params and ("," .. params) or ""
    local f = function(x)
        return string.format(" echo(%q)", x)
    end

    str = ("?>"..str.."<?lua"):gsub("%?>(.-)<%?lua", f)
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

server.bufferChanged = false
function server.recalculateBuffer()
    local forceChange = false
    local function parseLine(line)
        local str = line.str

        if line.type == "error" then
            str = string.format("⚠ %s", str)
        end

        if line.count > 1 then
            str = string.format("(%d) ", line.count) .. str
            forceChange = true
        end

        if server.timeStamp then
            str = string.format("-> %s %s", os.date("%H:%M:%S", line.time), str)
        else
            str = string.format("-> %s", str)
        end

        return str
    end

    local newBuffer = server.map(server.history, parseLine)

    if #server.buffer ~= #newBuffer or forceChange then
        server.buffer = newBuffer
        server.bufferChanged = true
        return
    end
end

function server.pushline(line)
    line.time = os.time()
    line.count = 1

    table.insert(server.history, line)
    if #server.history > server.maxLines then
        table.remove(server.history, 1)
    end
    server.recalculateBuffer()
end

function server.receive(client, pattern)
    while true do
        local data, message = client:receive(pattern)

        if not data then
            if message ~= "timeout" then
                return false
            end
            return true
        else
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

    client:close()
end

function server.onConnect(client)
    local address = client:getsockname()
    client:settimeout(0)

    server.origPrint("Client Connected: " .. address)
    if not server.connections[address] then
        server.connections[address] = client
    end
end

function server.onError(error)
    server.pushline({ type = "error", str = error })
    if server.wrapPrint then
        server.origPrint("[lovenest] ERROR: " .. error)
    end
end

function server.accept()
    return server.socket:accept()
end

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

        return client:send(server.buffer[#server.buffer] .. "\n")
    end
    client:send(tostring(res) .. "\n")
end

function server.settimeout(time)
    return server.socket:settimeout(time)
end

return server
