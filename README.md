# sunscreen.lua - Love2D Screen-Scaling Library

A minimal, universal screen scaling library for Love2D games that works on any platform and orientation. No configuration needed - just set your target game dimensions and go! Great for mobile projects that need to adapt to a variety of screen-sizes.

## 🚀 Quick Start

Copy `sunscreen.lua` to your project and use:

```lua
screen = require("sunscreen")

function love.load()
    screen:init({
        gameWidth = 800,   -- Your target game width
        gameHeight = 600,  -- Your target game height
        mode = "fit"       -- "fit", "fill", or "stretch"
    })
end

function love.draw()
    screen:apply()
    -- Put your game-drawing code here
end

function love.touchpressed(id, x, y)
    local gameX, gameY = screen:screenToGame(x, y)
    -- Handle touch at game coordinates
end

function love.resize(w, h)
    screen:onResize(w, h)
end
```

## 📁 Files

- `sunscreen.lua` - The complete, standalone library (copy this to your project)
- `main.lua` - Interactive demo (Love2D game) showing all features

## Features

- **Universal**: Works on desktop, mobile, and any screen size/orientation
- **Single File**: Just copy `sunscreen.lua` - no dependencies
- **Zero Config**: Sensible defaults, but fully customizable
- **Multiple Scaling Modes**: Fit, Fill, and Stretch options
- **High Performance**: Efficient transformation-based scaling
- **Complete Input Handling**: Touch and mouse coordinate conversion

## API Reference

### Configuration
```lua
screen:init({
    gameWidth = 800,      -- Target game width (default: 800)
    gameHeight = 600,     -- Target game height (default: 600)
    mode = "fit",         -- Scaling mode (default: "fit")
    debug = false         -- Enable debug output (default: false)
})
```

### Core Functions
```lua
screen:apply()           -- Apply scaling transformation
screen:reset()           -- Reset transformation (optional, called automatically)
screen:screenToGame(x, y)  -- Convert screen coordinates to game coordinates
screen:getGameWidth()    -- Get game width
screen:getGameHeight()   -- Get game height
screen:getMode()         -- Get current scaling mode
screen:setMode(mode)     -- Change scaling mode
screen:setGameSize(w, h) -- Change game dimensions
screen:onResize(w, h)    -- Handle window resize
```

### Scaling Modes
- **`"fit"`** - Letterbox scaling (maintains aspect ratio, may show black bars)
- **`"fill"`** - Crop scaling (maintains aspect ratio, no black bars, may crop content)  
- **`"stretch"`** - Stretch scaling (fills entire screen, may distort content)

## License

MIT License - Feel free to use in your projects!