local VideoPlayer = {}

-- TESTING CONFIGS
local config = {
    mpv_path   = os.getenv("MUTUBE_MPV")   or "./bin/mpv",
    ytdlp_path = os.getenv("MUTUBE_YTDLP") or "./yt-dlp",
    format     = os.getenv("MUTUBE_FORMAT") or "worst",
}

print("[VideoPlayer] MUTUBE_YTDLP:", os.getenv("MUTUBE_YTDLP"))


function VideoPlayer:play(url)
    if not url or url == "" then return end

    local ytdlp_cmd = string.format(
        '%s -f %s -g "%s"',
        config.ytdlp_path,
        config.format,
        url
    )

    local handle = io.popen(ytdlp_cmd)
    if not handle then
        print("[VideoPlayer] yt-dlp failed")
        return
    end

    local stream_url = handle:read("*a")
    handle:close()
    stream_url = stream_url:gsub("%s+$", "")

    if stream_url == "" then return end

    local mpv_cmd = string.format(
        '%s "%s"',
        config.mpv_path,
        stream_url
    )

    os.execute(mpv_cmd)
end

return VideoPlayer
