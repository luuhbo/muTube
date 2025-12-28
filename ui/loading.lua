local Theme = require("ui.theme")

local LoadingUI = {
    progress = 0,
    speed = 1.2,
}

function LoadingUI:update(dt)
    -- indeterminate animation (ping-pong)
    self.progress = (self.progress + dt * self.speed) % 2
end

function LoadingUI:draw(text)
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    -- overlay
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, w, h)

    -- label
    Theme.setColor("text_light")
    love.graphics.printf(
        text or "Loading…",
        0,
        h * 0.45,
        w,
        "center"
    )

    -- progress bar
    local barW = w * 0.5
    local barH = 14
    local x = (w - barW) / 2
    local y = h * 0.52

    -- background
    Theme.withAlpha("glass_bg", 0.4)
    love.graphics.rectangle("fill", x, y, barW, barH, 8, 8)

    -- animated fill
    local t = self.progress
    local fillW = barW * 0.35
    local fx = x + (barW - fillW) * math.abs(t - 1)

    Theme.withAlpha("accent", 0.8)
    love.graphics.rectangle("fill", fx, y, fillW, barH, 8, 8)
end

return LoadingUI
