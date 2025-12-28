local Search = {}

Search.results = {}
Search.selected = 1
Search.cols = 3  -- must match your UI columns

local ch_in = love.thread.getChannel("search_in")
local ch_out = love.thread.getChannel("search_out")

local thread

function Search:init()
    if not thread then
        thread = love.thread.newThread("threads/search_thread.lua")
        thread:start()
    end
end

-- Run a YouTube search
function Search:query(query_string)
    self.results = {}
    self.selected = 1
    self.loading = true

    ch_in:clear()
    ch_out:clear()

    ch_in:push({
        query       =   query_string,
        ytdlp_path  =   os.getenv("MUTUBE_YTDLP"),
        node_path   =   os.getenv("MUTUBE_NODE") 
    })
end

function Search:update()
    if not self.loading then return end

    local msg = ch_out:pop()
    if not msg then return end

    self.loading = false

    if msg.ok then
        self.results = msg.results or {}
    else
        print("Search error:", msg.error)
    end
end


-- Grid navigation functions
function Search:moveUp()
    if self.selected > self.cols then
        self.selected = self.selected - self.cols
    end
end

function Search:moveDown()
    if self.selected + self.cols <= #self.results then
        self.selected = self.selected + self.cols
    end
end

function Search:moveLeft()
    if (self.selected - 1) % self.cols ~= 0 then
        self.selected = self.selected - 1
    end
end

function Search:moveRight()
    if (self.selected % self.cols) ~= 0 and (self.selected + 1) <= #self.results then
        self.selected = self.selected + 1
    end
end

-- Get currently selected result
function Search:getSelected()
    return self.results[self.selected]
end

-- Get all results
function Search:getResults()
    return self.results
end

return Search
