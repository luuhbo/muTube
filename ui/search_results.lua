-- ui/search_results.lua
local Theme = require("ui.theme")
local SearchResultsUI = {}

function SearchResultsUI:load(screenWidth, screenHeight)
    self.x = screenWidth * 0.03
    self.y = screenHeight * 0.2
    self.width = screenWidth * 0.94
    self.height = screenHeight * 0.85

    self.cols = 3
    self.spacing = screenWidth * 0.02
    self.cellWidth = (self.width - (self.cols - 1) * self.spacing) / self.cols
    self.cellHeight = self.cellWidth * 0.6

    local fontSize = math.floor(self.cellHeight * 0.18)
    self.font = love.graphics.newFont(fontSize)
end

function SearchResultsUI:truncate(text, maxWidth)
    if self.font:getWidth(text) <= maxWidth then
        return text
    end

    local ellipsis = "..."
    local truncated = text

    while self.font:getWidth(truncated .. ellipsis) > maxWidth and #truncated > 0 do
        truncated = truncated:sub(1, -2)
    end

    return truncated .. ellipsis
end


function SearchResultsUI:draw(search)
    local results = search:getResults()
    local rowHeight = self.cellHeight + self.spacing
    local padding = self.cellWidth * 0.05

    love.graphics.setFont(self.font)

    for i, result in ipairs(results) do
        local col = (i - 1) % self.cols
        local row = math.floor((i - 1) / self.cols)

        local cellX = self.x + col * (self.cellWidth + self.spacing)
        local cellY = self.y + row * rowHeight

        -- Background
        if i == search.selected then
            Theme.withAlpha("glass_bg", 0.35)
        else
            Theme.withAlpha("glass_bg", 0.22)
        end

        love.graphics.rectangle(
            "fill",
            cellX,
            cellY,
            self.cellWidth,
            self.cellHeight,
            10,
            10
        )

        -- Border (accent if selected)
        if i == search.selected then
            Theme.withAlpha("accent", 0.7)
        else
            Theme.withAlpha("glass_border", 0.3)
        end

        love.graphics.rectangle(
            "line",
            cellX,
            cellY,
            self.cellWidth,
            self.cellHeight,
            10,
            10
        )

        -- Title text
        Theme.setColor("text_dark")

        local maxTextWidth = self.cellWidth - padding * 2
        local title = self:truncate(result.title, maxTextWidth)

        love.graphics.printf(
            title,
            cellX + padding,
            cellY + self.cellHeight - self.font:getHeight() - padding,
            maxTextWidth,
            "center"
        )
    end
end


return SearchResultsUI
