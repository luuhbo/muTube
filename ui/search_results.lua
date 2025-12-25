local SearchResultsUI = {}

local screenWidth = os.getenv("SCREEN_WIDTH")
local screenHeight = os.getenv("SCREEN_HEIGHT")
local screenResolution = os.getenv("SREEN_RESOLUTION")

SearchResultsUI.x = 40
SearchResultsUI.y = 100
SearchResultsUI.line_height = 60
SearchResultsUI.max_visible = 8

function SearchResultsUI:draw(search)
    local results = search:getResults()
    local selected = search.selected

    if #results == 0 then
        love.graphics.setColor(0.7, 0.7, 0.7)
        love.graphics.print("No results", self.x, self.y)
        return
    end

    local start = math.max(1, selected - self.max_visible + 1)
    local finish = math.min(#results, start + self.max_visible - 1)

    for i = start, finish do
        local y = self.y + (i - start) * self.line_height

        if i == selected then
            love.graphics.setColor(0.2, 0.6, 0.2)
            love.graphics.rectangle("fill", self.x - 10, y, 700, self.line_height)
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.setColor(1, 1, 1)
        end

        love.graphics.print(results[i].title, self.x, y + 5)
    end
end

return SearchResultsUI
