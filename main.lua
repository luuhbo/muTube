-- main.lua

-- App states
local STATE = {
    SEARCH = "search",
    RESULTS = "results",
}

local appState = STATE.SEARCH

-- Modules
local Input = require("modules.input_handler")
local Search = require("modules.search")
local VideoPlayer = require("modules.video_player")

-- UI
local SearchResultsUI = require("ui.search_results")
local SearchBarUI = require("ui.search_bar")
local Keyboard = require("ui.osk")  -- OSK

-- Search query
local searchQuery = "lofi hip hop"

function love.load()
    love.graphics.setFont(love.graphics.newFont(14))
    Input.load()
end

function love.update(dt)
    Input.update(dt)

    Input.onEvent(function(event)

        -- Keyboard active consumes input first
        if Keyboard.active then
            Keyboard.handleEvent(event)
            return
        end

        -- Trigger search keyboard
        if event == "search" then
            if appState == STATE.SEARCH and not Keyboard.active then
                Keyboard.open(
                    searchQuery,
                    function(text) -- on submit
                        searchQuery = text
                        Search:query(searchQuery) -- trigger search
                        appState = STATE.RESULTS
                    end,
                    function() -- on cancel
                        print("Keyboard cancelled")
                    end
                )
            end
            return
        end

        -- State handling
        if appState == STATE.SEARCH then
            -- Add other navigation if needed
        elseif appState == STATE.RESULTS then
            if event == "up" then
                if Search.selected == 1 then
                    appState = STATE.SEARCH
                else
                    Search:prev()
                end
            elseif event == "down" then
                Search:next()
            elseif event == "return" then
                local video = Search:getSelected()
                if video then
                    VideoPlayer:play(video.url)
                end
            end
        end

        -- ESC quits
        if event == "escape" then
            love.event.quit()
        end
    end)
end

function love.draw()
    love.graphics.clear(0.1, 0.1, 0.1)

    -- Draw search bar (focused if in SEARCH state)
    SearchBarUI:draw(searchQuery, appState == STATE.SEARCH)

    -- Draw search results
    SearchResultsUI:draw(Search)

    -- Draw on-screen keyboard if active
    if Keyboard.active then
        Keyboard.draw()
    end
end

function love.keypressed(key)
    -- Map keyboard keys to input events
    if key == "y" then
        Input.keypressed("search")
    elseif key == "escape" then
        Input.keypressed("escape")
    elseif key == "up" then
        Input.keypressed("up")
    elseif key == "down" then
        Input.keypressed("down")
    elseif key == "left" then
        Input.keypressed("left")
    elseif key == "right" then
        Input.keypressed("right")
    elseif key == "return" then
        Input.keypressed("return")
    else
        -- Pass other keys directly (optional)
        Input.keypressed(key)
    end
end
