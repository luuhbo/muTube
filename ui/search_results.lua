-- ui/search_results.lua
local Theme = require("ui.theme")
local Logger = require("modules.logger")
local utf8 = require("utf8")

local SearchResultsUI = {}


function SearchResultsUI:load(screenWidth, screenHeight)
    self.screenWidth = screenWidth
    self.screenHeight = screenHeight

    self.x = screenWidth * 0.03
    self.y = screenHeight * 0.2
    self.width = screenWidth * 0.94
    self.height = screenHeight * 0.85

    local dpi = 1
    if love.window and love.window.getDPIScale then
        dpi = love.window.getDPIScale()
    end
    Logger.log(string.format("[SearchResultsUI] screen %dx%d dpi=%.2f", self.screenWidth, self.screenHeight, dpi))

    self.cols = 3
    self.spacing = screenWidth * 0.02
    self.cellWidth = (self.width - (self.cols - 1) * self.spacing) / self.cols
    self.cellHeight = self.cellWidth * 0.6

    local fontSize = math.floor(self.cellHeight * 0.18)
    self.font = love.graphics.newFont(fontSize)
end

local utf8 = require("utf8")

function SearchResultsUI:truncate(text, maxWidth)
    -- sanitize invalid UTF-8 bytes
    local clean = {}
    local i = 1
    while i <= #text do
        local b = text:byte(i)
        if b < 0x80 then
            table.insert(clean, string.char(b))
            i = i + 1
        elseif b >= 0xC2 and b <= 0xDF and i + 1 <= #text then
            local b2 = text:byte(i + 1)
            if b2 >= 0x80 and b2 <= 0xBF then
                table.insert(clean, text:sub(i, i + 1))
            end
            i = i + 2
        elseif b >= 0xE0 and b <= 0xEF and i + 2 <= #text then
            local b2, b3 = text:byte(i + 1, i + 2)
            if b2 >= 0x80 and b2 <= 0xBF and b3 >= 0x80 and b3 <= 0xBF then
                table.insert(clean, text:sub(i, i + 2))
            end
            i = i + 3
        elseif b >= 0xF0 and b <= 0xF4 and i + 3 <= #text then
            local b2, b3, b4 = text:byte(i + 1, i + 3)
            if b2 >= 0x80 and b2 <= 0xBF and b3 >= 0x80 and b3 <= 0xBF and b4 >= 0x80 and b4 <= 0xBF then
                table.insert(clean, text:sub(i, i + 3))
            end
            i = i + 4
        else
            -- skip invalid byte
            i = i + 1
        end
    end

    local utf8str = table.concat(clean)

    -- early return if it fits
    if self.font:getWidth(utf8str) <= maxWidth then
        return utf8str
    end

    -- truncate safely character by character
    local truncated = {}
    for p, c in utf8.codes(utf8str) do
        table.insert(truncated, utf8.char(c))
        local testStr = table.concat(truncated) .. "..."
        if self.font:getWidth(testStr) > maxWidth then
            table.remove(truncated) -- remove last character that overflowed
            break
        end
    end

    return table.concat(truncated) .. "..."
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
