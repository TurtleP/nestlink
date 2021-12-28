local fonts = {}

-- GUI Fonts
fonts.small = love.graphics.newFont("graphics/RobotoRegular.ttf", 16)
fonts.console = love.graphics.newFont("graphics/CallingCode.ttf", 15)

-- Glyph Fonts
fonts.fontAwesomeRegular = love.graphics.newFont("graphics/FontAwesomeRegular.otf", 16)
fonts.fontAwesomeSolid   = love.graphics.newFont("graphics/FontAwesomeSolid.otf", 16)
fonts.fontAwesomeSolidSmall   = love.graphics.newFont("graphics/FontAwesomeSolid.otf", 8)

return fonts
