local ch_in  = love.thread.getChannel("search_in")
local ch_out = love.thread.getChannel("search_out")

print("[THREAD] search_thread started")

while true do
    print("[THREAD] Waiting for job...")
    local job = ch_in:demand()

    if job == "quit" then
        print("[THREAD] Quit signal received")
        break
    end

    print("[THREAD] Job received")

    local query_string = job.query
    print("[THREAD] Query:", query_string)

    local results = {}

    local ytdlp_path = job.ytdlp_path or "yt-dlp"
    local node_path  = job.node_path

    print("[THREAD] yt-dlp path:", ytdlp_path)
    print("[THREAD] node path:", node_path or "(none)")

    local js_flag = ""
    if node_path and node_path ~= "" then
        js_flag = string.format('--js-runtimes node:%s', node_path)
        print("[THREAD] Using JS runtime flag:", js_flag)
    else
        print("[THREAD] No JS runtime flag")
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

    print("[THREAD] Command:")
    print(command)

    print("[THREAD] Executing yt-dlp...")
    local handle = io.popen(command)

    if not handle then
        print("[THREAD] ❌ io.popen failed")
        ch_out:push({
            ok = false,
            error = "io.popen failed"
        })
    else
        print("[THREAD] yt-dlp running...")

        local output = handle:read("*a")
        handle:close()

        print("[THREAD] yt-dlp finished")
        print("[THREAD] Raw output length:", #output)

        if #output == 0 then
            print("[THREAD] ⚠️ No output from yt-dlp")
        end

        local lines = {}
        for line in output:gmatch("[^\r\n]+") do
            lines[#lines + 1] = line
        end

        print("[THREAD] Lines parsed:", #lines)

        for i = 1, #lines, 2 do
            if lines[i + 1] then
                results[#results + 1] = {
                    title = lines[i],
                    url   = lines[i + 1]
                }
            end
        end

        print("[THREAD] Results built:", #results)

        ch_out:push({
            ok = true,
            results = results
        })

        print("[THREAD] Results pushed to channel")
    end
end

print("[THREAD] search_thread exiting")
