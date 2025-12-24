-- Modules
local Input = require("modules.input_handler")
local Search = require("modules.search")

-- UI
local SearchResultsUI = require("ui.search_results")

function love.load()
    love.graphics.setFont(love.graphics.newFont(10))
    Input.load()

    -- TEMP: hardcoded search until keyboard exists
    Search:query("lofi hip hop")
end

function love.update(dt)
    Input.update(dt)

    Input.onEvent(function(event)
        if event == "down" then
            Search:next()

        elseif event == "up" then 
            Search:prev()
        
        elseif event == "return" then
            local video = Search:getSelected()
            if video then
                VideoPlayer:plau(video.url)
            end
        
        elseif event == "escape" then
            love.event.quit()
        end
    end)
end

function love.draw()
    love.graphics.clear(0.1, 0.1, 0.1)

    SearchResultsUI:draw(Search)
end

function love.keypressed(key)
    Input.keypressed(key)
end
