local server = require("console")

server.load({wrapPrint = true})

function love.update(dt)
    server.update()
end

function love.keypressed(key)
    print(key .. " was pressed!")
end
