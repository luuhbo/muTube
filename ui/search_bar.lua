local SearchBarUI = {}

-- Layout config
SearchBarUI.x = 40
SearchBarUI.y = 30
SearchBarUI.width = 720
SearchBarUI.height = 40

function SearchBarUI:draw(query, focused)
    --Background
    if focused then
        love.graphics.setColor(0.25, 0.25, 0.25)
    else
        love.graphics.setColor(0.15, 0.15, 0.15)
    end

    love.graphics.rectangle(
        "fill",
        self.x,
        self.y,
        self.width,
        self.height,
        6, 6
    )

    -- Border
    if focused then
        love.graphics.setColor(0.3, 0.3, 0.3)
    else
        love.graphics.setColor(0.4, 0.4, 0.4)
    end

    love.graphics.rectangle(
        "line",
        self.x,
        self.y,
        self.width,
        self.height,
        6, 6
    )

    -- Text
    love.graphics.setColor(1, 1, 1)

    local text = query ~= "" and query or "Search muTube..."
    love.graphics.print(text, self.x + 12, self.y + 10)
end

return SearchBarUI
