local VideoPlayer = {}

local config = {
    mpv_path   = os.getenv("MUTUBE_MPV")   or "/mnt/mmc/MUOS/application/muTube/bin/mpv",
    ytdlp_path = os.getenv("MUTUBE_YTDLP") or "/mnt/mmc/MUOS/application/muTube/bin/yt-dlp",
    node_path  = os.getenv("MUTUBE_NODE")  or "/usr/bin/node",  -- Node.js path
    bindir     = os.getenv("MUTUBE_BIN")   or "/mnt/mmc/MUOS/application/muTube/bin",
    gptk_core  = os.getenv("GPTK_CORE")    or "ext-mpv-general",
    func_sh    = os.getenv("FUNC_SCRIPT")  or "/opt/muos/script/var/func.sh",
}

-- Escape shell arguments safely
local function shell_escape(s)
    return "'" .. s:gsub("'", "'\\''") .. "'"
end

function VideoPlayer:play(url)
    if not url or url == "" then return end

    -- 1️⃣ Setup environment and GPTOKEYB (fixed: MPV_BIN + CORE)
    local setup_cmd = string.format([[
        . %s &&
        SETUP_SDL_ENVIRONMENT &&
        export LD_LIBRARY_PATH='%s/libs.aarch64:$LD_LIBRARY_PATH' &&
        SET_VAR 'system' 'foreground_process' '%s' &&
        GPTOKEYB '%s' '%s'
    ]],
        shell_escape(config.func_sh),
        config.bindir,
        shell_escape(config.mpv_path),
        shell_escape(config.mpv_path),  -- MPV binary path
        shell_escape(config.gptk_core)  -- GPTOKEYB core
    )
    os.execute(setup_cmd)

    -- 2️⃣ Extract direct stream URL via yt-dlp using Node.js
    local js_flag = ""
    if config.node_path and config.node_path ~= "" then
        js_flag = "--js-runtimes node:" .. config.node_path
    end

    local ytdlp_cmd = string.format(
        "%s %s -f 'best[ext=mp4]' -g %s",
        shell_escape(config.ytdlp_path),
        js_flag,
        shell_escape(url)
    )

    local handle = io.popen(ytdlp_cmd)
    if not handle then
        print("Failed to extract stream URL")
        return
    end
    local stream_url = handle:read("*a"):gsub("%s+$", "")
    handle:close()

    if stream_url == "" then
        print("No stream URL extracted")
        return
    end

    -- 3️⃣ Launch MPV with options
    local mpv_opts = "--no-config --fullscreen --keepaspect=yes --video-zoom=0 --video-align-x=0 --video-align-y=0"
    local mpv_cmd = string.format("%s %s %s", shell_escape(config.mpv_path), mpv_opts, shell_escape(stream_url))

    os.execute(mpv_cmd)
end

return VideoPlayer
