-- Love2D Screen Scaling Demo
-- Universal demo that works on desktop and mobile

local screen = require("sunscreen")

-- Configure Love2D
function love.conf(t)
    t.window.title = "Sunscreen - Love2D Screen Scaling Demo"
    t.window.width = 800
    t.window.height = 600
    t.window.resizable = true
    t.window.highdpi = true
end

function love.load()
    -- Ensure window is resizable
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    love.window.setMode(w, h, { resizable = true })
    
    -- Initialize screen manager with your desired game dimensions
    screen:init({
        gameWidth = 800,   -- Your game's target width
        gameHeight = 600,  -- Your game's target height
        mode = "fit"       -- Default scaling mode
    })
    
    -- Cache fonts for better performance
    fonts = {
        title = love.graphics.newFont(24),
        info = love.graphics.newFont(18),
        instructions = love.graphics.newFont(20)
    }
    
    -- Game state
    gameState = {
        circles = {},
        touchPoints = {}
    }
    
    -- Create demo circles with better spacing
    for i = 1, 6 do
        table.insert(gameState.circles, {
            x = (i - 1) * (screen:getGameWidth() / 8) + (screen:getGameWidth() / 16) + 60 + 30,
            y = screen:getGameHeight() * 0.3 + (i % 2) * 80,
            size = 60
        })
    end
end

function love.update(dt)
    -- Fade out touch points
    for i = #gameState.touchPoints, 1, -1 do
        gameState.touchPoints[i].alpha = gameState.touchPoints[i].alpha - dt * 2
        if gameState.touchPoints[i].alpha <= 0 then
            table.remove(gameState.touchPoints, i)
        end
    end
end

function love.draw()
    screen:apply() -- Apply scaling and translation
    
    -- Background (deep night sky blue)
    love.graphics.clear(0.05, 0.1, 0.2)
    
    -- Set larger font for better readability
    love.graphics.setFont(fonts.title)
    
    -- Title
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("sunscreen.lua - Love2D Screen Scaling Demo", 0, 30, screen:getGameWidth(), "center")
    
    -- Screen info
    love.graphics.setFont(fonts.info)
    local infoText = string.format("Window: %dx%d | Game: %dx%d | Scale: %.2f | Mode: %s",
        love.graphics.getWidth(), love.graphics.getHeight(),
        screen:getGameWidth(), screen:getGameHeight(),
        screen.scale, screen:getMode():upper())
    love.graphics.printf(infoText, 0, 80, screen:getGameWidth(), "center")
    
    -- Demo circles (yellow)
    love.graphics.setColor(1, 1, 0)  -- Bright yellow
    for _, circle in ipairs(gameState.circles) do
        love.graphics.circle("fill", circle.x, circle.y, circle.size / 2)
    end
    
    -- Touch points
    for _, touch in ipairs(gameState.touchPoints) do
        love.graphics.setColor(1, 1, 1, touch.alpha)
        love.graphics.circle("fill", touch.x, touch.y, 15)
    end
    
    -- Game area border
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("line", 0, 0, screen:getGameWidth(), screen:getGameHeight())
    
    -- Corner debug rectangles (inside game area)
    love.graphics.setColor(1, 0, 0, 0.8)
    local s = 20
    love.graphics.rectangle("fill", 0, 0, s, s)
    love.graphics.rectangle("fill", screen:getGameWidth() - s, 0, s, s)
    love.graphics.rectangle("fill", 0, screen:getGameHeight() - s, s, s)
    love.graphics.rectangle("fill", screen:getGameWidth() - s, screen:getGameHeight() - s, s, s)
    
    -- Instructions
    love.graphics.setFont(fonts.instructions)
    love.graphics.setColor(1, 1, 1, 0.7)
    love.graphics.printf("Touch/Click anywhere | Keys: 1=Fit, 2=Fill, 3=Stretch",
        0, screen:getGameHeight() - 40, screen:getGameWidth(), "center")
    
    -- Note: screen:reset() is called automatically
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    local gameX, gameY = screen:screenToGame(x, y)
    if gameX >= 0 and gameX <= screen:getGameWidth() and 
       gameY >= 0 and gameY <= screen:getGameHeight() then
        table.insert(gameState.touchPoints, {x = gameX, y = gameY, alpha = 1})
    end
end

function love.mousepressed(x, y, button)
    -- Mouse input works the same as touch input
    love.touchpressed(1, x, y, 0, 0, 1)
end

function love.resize(w, h)
    screen:onResize(w, h)
end

function love.keypressed(key)
    if key == "1" then
        screen:setMode("fit")
    elseif key == "2" then
        screen:setMode("fill")
    elseif key == "3" then
        screen:setMode("stretch")
    elseif key == "escape" then
        love.event.quit()
    end
end
