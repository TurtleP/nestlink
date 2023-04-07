local socket = require("socket")

---@class server
local server = {}
server.socket = nil
server.separator = "␟"
server.logs = {}
server._port = 25545
server._whitelist = { "127.0.0.1" }
server._version = "0.2.0"

local function split(line, delimiters)
    local result = {}
    local regex = ("([^%s]+)"):format(delimiters)

    for part in line:gmatch(regex) do
        table.insert(result, part)
    end

    return result
end

local function check_ip(ip_address)
    if #server._whitelist or #server._whitelist == 0 then
        return true
    end

    for _, address in ipairs(server._whitelist) do
        local pattern = "^" .. address:gsub("%.", "%%.")
        pattern = pattern:gsub("%*", "%%d*") .. "$"

        if ip_address:match(pattern) then
            return true
        end
    end
    return false
end

local function handle_client(client)
    client:settimeout(0)

    local address, port = client:getsockname()
    local ip_port = ("%s:%d"):format(address, port)

    if not check_ip(address) then
        server.log(("Got non-whitelisted connection %s"):format(ip_port))
        return client:close()
    else
        server.log(("Client connected at %s"):format(ip_port))
    end

    while true do
        local line, error_message = client:receive("*l")

        -- server closed the connection
        if error_message == "closed" then
            server.log("Client disconnected.")
            break
        elseif error_message and error_message ~= "timeout" then
            server.log("Receiving error: %s", error_message)
            break
        end

        if line then
            local args = split(line, server.separator)
            server.log(table.concat(args, " "))
        end
    end

    client:close()
end

function server.log(message, ...)
    local time = os.date("%Y-%m-%d %H:%M:%S")
    local log_info = ("[%s]: %s"):format(time, message:format(...))

    print(log_info)
end

function server.getWhitelist()
    return server._whitelist
end

function server.getPort()
    return server._port
end

function server.getVersion()
    return server._version
end

function server.init(port, whitelist)
    assert(not whitelist or #whitelist == 0 or type(whitelist) == "table", "Whitelist is invalid")
    server._whitelist = whitelist

    assert(port and type(port) == "number", "Port is invalid")
    server._port = port

    server.socket = socket.tcp()

    server.socket:setoption("reuseaddr", true)
    server.socket:settimeout(0)

    local success, _ = server.socket:bind("localhost", port)

    if not success then
        return
    end

    server.socket:listen()
    server.log("Starting nestlink on *:" .. port)
end

function server.accept_connections()
    local client = server.socket:accept()

    if not client then
        return
    end

    coroutine.wrap(handle_client)(client)
end

return server
