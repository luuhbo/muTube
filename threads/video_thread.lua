-- video_thread.lua
local ch_in  = love.thread.getChannel("video_in")
local ch_out = love.thread.getChannel("video_out")

while true do
    local job = ch_in:demand()
    if job == "quit" then break end

    local url        = job.url
    local ytdlp_path = job.ytdlp_path
    local node_path  = job.node_path
    local mpv_path   = job.mpv_path
    local func_sh    = job.func_sh
    local bindir     = job.bindir
    local gptk_core  = job.gptk_core

    ch_out:push({ type="status", msg="Setting up environment..." })

    -- Setup environment if func.sh exists
    if func_sh and func_sh ~= "" then
        local setup_cmd = string.format([[
            . %s &&
            SETUP_SDL_ENVIRONMENT &&
            export LD_LIBRARY_PATH='%s/libs.aarch64:$LD_LIBRARY_PATH' &&
            SET_VAR 'system' 'foreground_process' '%s' &&
            GPTOKEYB '%s' '%s'
        ]],
            func_sh,
            bindir,
            mpv_path,
            mpv_path,
            gptk_core
        )
        os.execute(setup_cmd)
    end

    ch_out:push({ type="status", msg="Environment ready, extracting stream..." })

    -- Extract direct stream URL via yt-dlp
    local js_flag = ""
    if node_path and node_path ~= "" then
        js_flag = "--js-runtimes node:" .. node_path
    end

    local ytdlp_cmd = string.format(
        '%s %s -f "best[ext=mp4]" -g "%s"',
        ytdlp_path, js_flag, url
    )

    ch_out:push({ type="status", msg="Running yt-dlp..." })
    local handle = io.popen(ytdlp_cmd)
    if not handle then
        ch_out:push({ type="error", msg="Failed to run yt-dlp" })
    else
        local stream_url = handle:read("*a"):gsub("%s+$", "")
        handle:close()

        if stream_url == "" then
            ch_out:push({ type="error", msg="No stream URL extracted" })
        else
            -- Signal UI that stream URL is ready; main thread will launch MPV (blocks)
            ch_out:push({ type="status", msg="Stream URL extracted" })
            ch_out:push({ type="stream", url=stream_url })
            -- Once main thread launches MPV and it exits, the thread simply waits for next job
        end
    end
end
