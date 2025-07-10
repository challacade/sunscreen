-- Love2D Screen Manager Library
local screen = {
    _LICENSE = "This software is distributed under the MIT license. View the LICENSE on GitHub for details.",
    _URL = "https://github.com/challacade/sunscreen",
    _VERSION = "1.0.0",
    _DESCRIPTION = "Screen scaling and positioning for Love2D games",
}

-- Default configuration
local DEFAULT_CONFIG = {
    gameWidth = 800,        -- Target game width
    gameHeight = 600,       -- Target game height
    mode = "fit",          -- Default scaling mode
    debug = false          -- Debug output
}

-- Current configuration
local config = {}

-- Current scaling values
screen.scale = 1
screen.offsetX = 0
screen.offsetY = 0

-- Current state
local currentMode = "fit"
local gameWidth = DEFAULT_CONFIG.gameWidth
local gameHeight = DEFAULT_CONFIG.gameHeight
local isTransformActive = false
local autoResetEnabled = false

-- Helper function to get current screen dimensions
local function getScreenDimensions()
    return love.graphics.getWidth(), love.graphics.getHeight()
end

-- Helper function to validate mode
local function isValidMode(mode)
    return mode == "fit" or mode == "fill" or mode == "stretch"
end

-- Debug helper function
local function debugLog(...)
    if config.debug then print("[screen]", ...) end
end

-- Helper functions for scale calculations
local function calculateScale(screenWidth, screenHeight, mode)
    -- Prevent division by zero
    if gameWidth <= 0 or gameHeight <= 0 then return 1, 1 end

    local scaleX = screenWidth / gameWidth
    local scaleY = screenHeight / gameHeight
    
    if mode == "fit" then
        return math.min(scaleX, scaleY)
    elseif mode == "fill" then
        return math.max(scaleX, scaleY)
    elseif mode == "stretch" then
        return scaleX, scaleY -- Return both for stretch mode
    end
end

local function calculateOffsets(screenWidth, screenHeight, scale)
    local scaledWidth = gameWidth * scale
    local scaledHeight = gameHeight * scale
    local offsetX = (screenWidth - scaledWidth) / 2
    local offsetY = (screenHeight - scaledHeight) / 2
    return offsetX, offsetY
end

-- Initialize the screen manager
function screen:init(userConfig)
    -- Merge user config with defaults
    config = {}
    for k, v in pairs(DEFAULT_CONFIG) do config[k] = v end
    if userConfig then
        for k, v in pairs(userConfig) do config[k] = v end
    end
    
    -- Set up initial values
    gameWidth = config.gameWidth
    gameHeight = config.gameHeight
    currentMode = config.mode
    
    -- Calculate initial scaling
    self:updateScale()
    
    -- Debug output
    debugLog("Initialized with config:", config.gameWidth .. "x" .. config.gameHeight, "mode:" .. config.mode)
    
    return self
end

-- Update scaling calculations
function screen:updateScale()
    local screenWidth, screenHeight = getScreenDimensions()
    
    if currentMode == "stretch" then
        self.scale = math.min(screenWidth / gameWidth, screenHeight / gameHeight)
        self.offsetX = 0
        self.offsetY = 0
    else
        self.scale = calculateScale(screenWidth, screenHeight, currentMode)
        self.offsetX, self.offsetY = calculateOffsets(screenWidth, screenHeight, self.scale)
    end
    
    -- Debug output
    debugLog("Scale updated:", self.scale, "Offset:", self.offsetX, self.offsetY)
end

-- Apply the screen transformation (call before drawing game content)
function screen:apply()
    -- If a transform is already active, reset it first
    if isTransformActive then
        love.graphics.pop()
        isTransformActive = false
    end
    
    love.graphics.push()
    isTransformActive = true
    
    -- Schedule automatic reset at the end of the frame
    if not autoResetEnabled then
        autoResetEnabled = true
        -- Hook into Love2D's present function to auto-reset
        local originalPresent = love.graphics.present
        love.graphics.present = function()
            if isTransformActive then
                love.graphics.pop()
                isTransformActive = false
            end
            originalPresent()
        end
    end
    
    -- Always get current screen dimensions to ensure accuracy
    local screenWidth, screenHeight = getScreenDimensions()
    
    if currentMode == "stretch" then
        -- Apply different scaling for X and Y axes
        local scaleX, scaleY = calculateScale(screenWidth, screenHeight, currentMode)
        love.graphics.scale(scaleX, scaleY)
    else
        -- Calculate scaling and offsets for fit/fill modes
        local scale = calculateScale(screenWidth, screenHeight, currentMode)
        local offsetX, offsetY = calculateOffsets(screenWidth, screenHeight, scale)
        
        love.graphics.translate(offsetX, offsetY)
        love.graphics.scale(scale, scale)
    end
end

-- Reset the screen transformation (optional - called automatically)
function screen:reset()
    if isTransformActive then
        love.graphics.pop()
        isTransformActive = false
    end
end

-- Convert screen coordinates to game coordinates
function screen:screenToGame(screenX, screenY)
    local screenWidth, screenHeight = getScreenDimensions()
    
    if currentMode == "stretch" then
        local gameX = screenX * gameWidth / screenWidth
        local gameY = screenY * gameHeight / screenHeight
        return gameX, gameY
    else
        -- Handle fit/fill modes (both use same calculation)
        local scale = calculateScale(screenWidth, screenHeight, currentMode)
        local offsetX, offsetY = calculateOffsets(screenWidth, screenHeight, scale)
        
        local gameX = (screenX - offsetX) / scale
        local gameY = (screenY - offsetY) / scale
        return gameX, gameY
    end
end

-- Getters
function screen:getGameWidth() return gameWidth end
function screen:getGameHeight() return gameHeight end
function screen:getMode() return currentMode end
function screen:getVersion() return screen._VERSION end

-- Setters
function screen:setMode(mode)
    if isValidMode(mode) then
        currentMode = mode
        self:updateScale()
        debugLog("Mode changed to:", mode)
        return true
    else
        debugLog("Invalid mode:", mode)
        return false
    end
end

function screen:setGameSize(width, height)
    if width <= 0 or height <= 0 then
        debugLog("Invalid game size:", width .. "x" .. height)
        return false
    end
    gameWidth = width
    gameHeight = height
    self:updateScale()
    debugLog("Game size changed to:", width .. "x" .. height)
    return true
end

-- Hook function for easy integration
function screen:onResize(w, h)
    self:updateScale()
    debugLog("Window resized to:", w .. "x" .. h)
end

return screen
