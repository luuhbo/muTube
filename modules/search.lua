local Search = {}

Search.results = {}
Search.selected = 1
Search.cols = 3  -- must match your UI columns

-- Run a YouTube search
function Search:query(query_string)
    self.results = {}
    self.selected = 1

    local ytdlp_path = os.getenv("MUTUBE_YTDLP") or "yt-dlp"
    local node_path = os.getenv("MUTUBE_NODE")

    local js_flag = ""
    if node_path and node_path ~= "" then
        js_flag = string.format('--js-runtimes node:%s', node_path)
    end

    local command = string.format(
        '%s %s "ytsearch5:%s" ' ..
        '--flat-playlist --no-playlist --skip-download ' ..
        '--ignore-errors --no-warnings ' ..
        '--print "%%(title)s" --print "%%(url)s"',
        ytdlp_path,
        js_flag,
        query_string
    )

    local handle = io.popen(command)
    if not handle then
        print("Search failed")
        return
    end

    local output = handle:read("*a")
    handle:close()

    local lines = {}
    for line in output:gmatch("[^\r\n]+") do
        lines[#lines + 1] = line
    end

    for i = 1, #lines, 2 do
        if lines[i + 1] then
            self.results[#self.results + 1] = {
                title = lines[i],
                url = lines[i + 1]
            }
        end
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
