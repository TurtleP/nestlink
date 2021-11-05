require("client")
love.console:init("127.0.0.1", 25545)

function love.load()
    print("Hello World!")
    print(true)
    print(nil)

    local test = {"woah"}
    print(test)

    local test2 = {"aaaa", "bbbb"}
    print(unpack(test2))

    print(love.system.getOS)
    print(love.system.getProcessorCount())
    print(function()
        return "yeet", "yote", "delet"
    end)
end
