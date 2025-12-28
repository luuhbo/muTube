-- VideoPlayer.lua
local VideoPlayer = {
    loading = false,
    status = "",
    progress = 0,
}

local config = {
    mpv_path   = os.getenv("MUTUBE_MPV")   or "/mnt/mmc/MUOS/application/muTube/bin/mpv",
    ytdlp_path = os.getenv("MUTUBE_YTDLP") or "/mnt/mmc/MUOS/application/muTube/bin/yt-dlp",
    node_path  = os.getenv("MUTUBE_NODE")  or "/usr/bin/node",
    bindir     = os.getenv("MUTUBE_BIN")   or "/mnt/mmc/MUOS/application/muTube/bin",
    gptk_core  = os.getenv("GPTK_CORE")    or "ext-mpv-general",
    func_sh    = os.getenv("FUNC_SCRIPT")  or "/opt/muos/script/var/func.sh",
}

local thread = nil
local ch_in  = love.thread.getChannel("video_in")
local ch_out = love.thread.getChannel("video_out")

VideoPlayer.loading = false
VideoPlayer.status = ""

function VideoPlayer:play(url, onReady)
    if not url or url == "" then return end

    if thread then thread:release() end
    thread = love.thread.newThread("threads/video_thread.lua")
    thread:start()

    ch_in:push({
        url        = url,
        ytdlp_path = config.ytdlp_path,
        node_path  = config.node_path,
        mpv_path   = config.mpv_path,
        func_sh    = config.func_sh,
        bindir     = config.bindir,
        gptk_core  = config.gptk_core
    })

    self.loading = true
    self.status  = "Initializing..."
    self.progress = 0
    self.onReady = onReady  -- store callback
end

function VideoPlayer:update()
    if not self.loading then return end

    while true do
        local msg = ch_out:pop()
        if not msg then break end

        if msg.type == "status" then
            self.status = msg.msg
            print("[VIDEO THREAD]", msg.msg)

        elseif msg.type == "progress" then
            self.progress = msg.value or 0
            print(string.format("[VIDEO THREAD] progress: %.2f", self.progress))

        elseif msg.type == "error" then
            self.status = "Error: " .. msg.msg
            self.loading = false
            print("[VIDEO THREAD]", self.status)
        elseif msg.type == "stream" then
            -- Stream URL received from worker thread: launch MPV from main thread (blocking)
            local stream_url = msg.url
            self.status = "Launching MPV..."
            print("[VIDEO THREAD]", self.status)

            -- Call main.lua callback to hide LoadingUI / restore state
            if self.onReady then
                self.onReady()
                self.onReady = nil
            end

            -- Hide Love window (best-effort) and mark mpv running
            if love and love.window and love.window.setVisible then
                pcall(function() love.window.setVisible(false) end)
            end
            self.mpv_running = true

            -- Build mpv command and run it blocking on the main thread so the app stops rendering
            local mpv_opts = "--no-config --fullscreen --keepaspect=yes --video-zoom=0 --video-align-x=0 --video-align-y=0"
            local mpv_cmd = string.format('%s %s "%s"', config.mpv_path, mpv_opts, stream_url)
            os.execute(mpv_cmd)

            -- After MPV exits, restore window and update status
            if love and love.window and love.window.setVisible then
                pcall(function() love.window.setVisible(true) end)
            end
            self.mpv_running = false
            self.status = "MPV exited"
            print("[VIDEO THREAD]", self.status)
        end
    end
end

return VideoPlayer

