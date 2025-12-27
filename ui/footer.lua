local Theme = require("ui.theme")

local FooterUI = {}

function FooterUI:load(screenWidth, screenHeight)
    self.screenWidth = screenWidth
    self.height = screenHeight * 0.08
    self.y = screenHeight - self.height
    self.padding = screenWidth * 0.03

    self.controls = {
        { key = "Y", action = "Search" },
        { key = "↑↓", action = "Navigate" },
        { key = "Enter", action = "Play" },
        { key = "Esc", action = "Back" },
    }

    local fontSize = math.floor(self.height * 0.4)
    self.font = love.graphics.newFont(fontSize)
end


function FooterUI:draw()
    -- Glass background
    Theme.setColor("glass_bg")
    love.graphics.rectangle("fill", 0, self.y, self.screenWidth, self.height)

    Theme.withAlpha("accent", 0.6)
    love.graphics.rectangle("line", 0, self.y, self.screenWidth, self.height)

    -- Text
    love.graphics.setFont(self.font)
    Theme.setColor("text_dark_soft")

    local x = self.padding
    local y = self.y + (self.height - self.font:getHeight()) / 2

    for _, ctrl in ipairs(self.controls) do
        local text = string.format("[%s] %s", ctrl.key, ctrl.action)
        love.graphics.print(text, x, y)
        x = x + self.font:getWidth(text) + self.padding
    end
end


return FooterUI