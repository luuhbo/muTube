-- main.lua

-- App states
local STATE = {
    SEARCH = "search",
    SEARCH_LOADING = "search_loading",
    RESULTS = "results",
    VIDEO_LOADING = "video_loading",
}

local appState = STATE.SEARCH

-- Modules
local Input = require("modules.input_handler")
local Search = require("modules.search")
local VideoPlayer = require("modules.video_player")

-- UI
local FooterUI = require("ui.footer")
local LoadingUI = require("ui.loading")
local SearchResultsUI = require("ui.search_results")
local SearchBarUI = require("ui.search_bar")
local Keyboard = require("ui.osk")  -- OSK
local Logger = require("modules.logger")

-- Search query
local searchQuery = "dog of wisdom"

-- ENV from mux_launch.sh
local screenWidth = os.getenv("SCREEN_WIDTH")
local screenHeight = os.getenv("SCREEN_HEIGHT")
local screenResolution = os.getenv("SREEN_RESOLUTION")

function love.load()
    local width = tonumber(screenWidth) or 1280
    local height = tonumber(screenHeight) or 720
    love.window.setMode(width, height)
    love.graphics.setFont(love.graphics.newFont(30))
    Input.load()
    Search:init()


    SearchBarUI:load(width, height)
    SearchResultsUI:load(width, height)
    FooterUI:load(width, height)


end

function love.update(dt)
    Input.update(dt)

    -- Update search loading
    if appState == STATE.SEARCH_LOADING then
        Search:update()   -- polls search thread
        LoadingUI:update(dt)  -- animate progress bar

        if not Search.loading then
            appState = STATE.RESULTS
        end
    end

    -- Update video loading
    if appState == STATE.VIDEO_LOADING then
        VideoPlayer:update()   -- poll video thread
        LoadingUI:update(dt)
    end


    Input.onEvent(function(event)
        -- Keyboard active consumes input first
        if Keyboard.active then
            Keyboard.handleEvent(event)
            searchQuery = Keyboard.text
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
                        appState = STATE.SEARCH_LOADING
                    end,
                    function() -- on cancel
                        print("Keyboard cancelled")
                    end,
                    love.graphics.getWidth(),
                    love.graphics.getHeight()
                )
            end
            return
        end

        -- State handling
        if appState == STATE.SEARCH then
            -- Add other navigation if needed
        elseif appState == STATE.RESULTS then
            if event == "up" then
                Search:moveUp()
            elseif event == "down" then
                Search:moveDown()
            elseif event == "left" then
                Search:moveLeft()
            elseif event == "right" then
                Search:moveRight()
            elseif event == "return" then
                local video = Search:getSelected()
                if video then
                    VideoPlayer:play(video.url, function()
                        LoadingUI:stop()
                        appState = STATE.RESULTS
                    end)
                    appState = STATE.VIDEO_LOADING
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
    -- If MPV is running and we've hidden the Love window, skip drawing to avoid flicker
    if VideoPlayer and VideoPlayer.mpv_running then
        return
    end

    love.graphics.clear(1, 1, 1)

    SearchBarUI:draw(searchQuery, appState == STATE.SEARCH)

    if appState == STATE.SEARCH_LOADING then
        LoadingUI:draw("Searching...")
    elseif appState == STATE.VIDEO_LOADING then
        LoadingUI:draw(VideoPlayer.status)
    else
        SearchResultsUI:draw(Search)
    end

    FooterUI:draw()

    if Keyboard.active then
        Keyboard.draw()
    end
end



function love.keypressed(key)
    -- Map keyboard keys to input events
    if key == "y" then
        Input.keypressed("search")       -- trigger search (OSK)
    elseif key == "x" then
        Input.keypressed("menu")
    elseif key == "return" then
        Input.keypressed("return")       -- select / confirm
    elseif key == "escape" then
        Input.keypressed("escape")       -- cancel / quit
    elseif key == "up" then
        Input.keypressed("up")           -- move cursor up
    elseif key == "down" then
        Input.keypressed("down")         -- move cursor down
    elseif key == "left" then
        Input.keypressed("left")         -- move cursor left
    elseif key == "right" then
        Input.keypressed("right")
            -- move cursor right
    else
        -- For letters and numbers, optionally send them directly to the OSK
        Input.keypressed(key)
    end
end
