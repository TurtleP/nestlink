
local server = require("server")

local argparse = require("libraries.argparse")

local arguments =
{
    port =      { "-p --port",      "The port to start the server on",             server.getPort()      },
    whitelist = { "-w --whitelist", "The list of allowed IP addresses to connect", server.getWhitelist() }
}

function love.load(args)
    local parser = argparse("nestlink", "LOVE Potion remote debugger")

    parser:option(unpack(arguments.port))
    parser:option(unpack(arguments.whitelist)):args("*")
    parser:flag("-v --version")

    local parsed = parser:parse(args)

    if parsed.version then
        print(("nestlink %s"):format(server.getVersion()))
        love.event.quit()
    end

    server.accept_connection(parsed.port, parsed.whitelist)
end
