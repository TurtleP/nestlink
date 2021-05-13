local server = require("server")

server.init({wrapPrint = true})

function love.update(dt)
    server.update()
end

function love.keypressed(key)
    print(key .. " was pressed!")
end
