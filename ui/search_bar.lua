local Theme = require("ui.theme")

local SearchBarUI = {}
SearchBarUI.__index = SearchBarUI

-- Default layout (fallback)
SearchBarUI.x = 40
SearchBarUI.y = 30
SearchBarUI.width = 720
SearchBarUI.height = 40

function SearchBarUI:load(screenWidth, screenHeight)
    self.x = screenWidth * 0.03
    self.y = screenHeight * 0.03
    self.width  = screenWidth * 0.94
    self.height = screenHeight * 0.10

    -- Create font ONCE
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
