local Theme = require("ui.theme")
local Logger = require("modules.logger")

local SearchBarUI = {}
SearchBarUI.__index = SearchBarUI

-- Default layout (fallback)
SearchBarUI.heightRatio = 0.10   -- 10% of screen height
SearchBarUI.widthRatio  = 0.94   -- 94% of screen width
SearchBarUI.xRatio      = 0.03   -- 3% margin from left
SearchBarUI.yRatio      = 0.03   -- 3% margin from top


function SearchBarUI:load(screenWidth, screenHeight)
    self.screenWidth  = screenWidth or love.graphics.getWidth()
    self.screenHeight = screenHeight or love.graphics.getHeight()

    local dpi = 1
    if love.window and love.window.getDPIScale then
        dpi = love.window.getDPIScale()
    end
    Logger.log(string.format("[SearchBarUI] screen %dx%d dpi=%.2f", self.screenWidth, self.screenHeight, dpi))

    -- Compute actual position & size
    self.width  = screenWidth * self.widthRatio
    self.height = screenHeight * self.heightRatio
    self.x      = screenWidth * self.xRatio
    self.y      = screenHeight * self.yRatio

    -- Create font once
    self.font = love.graphics.newFont(math.floor(self.height * 0.5))
end

function SearchBarUI:draw(query, focused)
    local cornerRadius = self.height * 0.35

    -- =====================
    -- Glass Background
    -- =====================
    if focused then
        Theme.withAlpha("glass_bg", 0.25)
    else
        Theme.withAlpha("glass_bg", 0.18)
    end

    love.graphics.rectangle(
        "fill",
        self.x, self.y,
        self.width, self.height,
        cornerRadius, cornerRadius
    )

    -- =====================
    -- Glass Highlight (top shine)
    -- =====================
    Theme.withAlpha("glass_highlight", focused and 0.12 or 0.08)
    love.graphics.rectangle(
        "fill",
        self.x + 3,
        self.y + 3,
        self.width - 6,
        self.height * 0.45,
        cornerRadius, cornerRadius
    )

    -- =====================
    -- Border
    -- =====================
    if focused then
        Theme.setColor("accent_soft")
    else
        Theme.withAlpha("glass_border", 0.4)
    end

    love.graphics.rectangle(
        "line",
        self.x, self.y,
        self.width, self.height,
        cornerRadius, cornerRadius
    )

    -- =====================
    -- Text
    -- =====================
    love.graphics.setFont(self.font)

    local paddingX = self.width * 0.03
    local textY = self.y + (self.height - self.font:getHeight()) / 2

    if query ~= "" then
        Theme.setColor("text_dark")
        love.graphics.print(query, self.x + paddingX, textY)
    else
        Theme.setColor("text_hint")
        love.graphics.print("Search muTube...", self.x + paddingX, textY)
    end
end

return SearchBarUI
