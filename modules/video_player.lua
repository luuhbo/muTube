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

function VideoPlayer:play(url)
    if not url or url == "" then return end

    -- Release old thread if exists
    if thread then thread:release() end

    -- Start new thread
    thread = love.thread.newThread("threads/video_thread.lua")
    thread:start()

    -- Push job to thread
    ch_in:push({
        url        = url,
        ytdlp_path = config.ytdlp_path,
        node_path  = config.node_path,
        mpv_path   = config.mpv_path,
        func_sh    = config.func_sh,
        bindir     = config.bindir,
        gptk_core  = config.gptk_core
    })

    VideoPlayer.loading = true
    VideoPlayer.status  = "Initializing..."
    self.progress = 0
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

        elseif msg.type == "done" then
            self.status = "Video launched"
            self.progress = 1
            self.loading = false
            print("[VIDEO THREAD]", self.status)
        end
    end
end


return VideoPlayer
