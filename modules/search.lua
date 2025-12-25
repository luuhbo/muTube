local Search = {}

Search.results = {}
Search.selected = 1

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

-- Move selection down
function Search:next()
    if #self.results == 0 then return end
    self.selected = math.min(self.selected + 1, #self.results)
end

-- Move selection up
function Search:prev()
    if #self.results == 0 then return end
    self.selected = math.max(self.selected - 1, 1)
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
