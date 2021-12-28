function love.conf(t)
    t.modules.audio = false
    t.modules.data = true
    t.modules.event = true
    t.modules.font = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = false
    t.modules.keyboard = false
    t.modules.math = true
    t.modules.mouse = false
    t.modules.physics = false
    t.modules.sound = false
    t.modules.system = false
    t.modules.thread = false
    t.modules.timer = true
    t.modules.touch = false
    t.modules.video = false
    t.modules.window = true

    t.console = true
    t.identity = "nestlink"

    t.window.width = 640
    t.window.height = 480
    t.window.title = "nëstlink"
end
