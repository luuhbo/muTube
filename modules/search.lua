local Search = {}

Search.results = {}
Search.selected = 1

-- Run a YouTube search
function Search:query(query_string)
    self.results = {}
    self.selected = 1

    local command = string.format(
        'yt-dlp "ytsearch5:%s" --get-title --get-url',
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
        table.insert(lines, line)
    end

    for i = 1, #lines, 2 do
        if lines[i+1] then
            table.insert(self.results, {
                title = lines[i],
                url = lines[i+1]
            })
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
