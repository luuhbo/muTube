local Theme = {}

-- ===== Base Colors (RGBA 0–1) =====
Theme.colors = {
    -- Backgrounds
    window_bg      = {0.12, 0.14, 0.18, 1.0},
    panel_bg       = {0.18, 0.22, 0.28, 0.85}, -- semi-transparent
    panel_focus    = {0.22, 0.28, 0.36, 0.9},

    -- Glass / Aero style
    glass_bg       = {0.75, 0.85, 1.0, 0.18},
    glass_border   = {0.85, 0.92, 1.0, 0.45},
    glass_highlight= {1.0, 1.0, 1.0, 0.08},

    -- Text
    text_primary     = {1.0, 1.0, 1.0, 1.0},  -- for dark backgrounds
    text_secondary   = {0.8, 0.85, 0.9, 1.0},
    text_hint        = {0.6, 0.7, 0.8, 1.0},

    text_dark        = {0.1, 0.12, 0.15, 1.0}, -- for glass/light panels
    text_dark_soft   = {0.25, 0.3, 0.35, 1.0},

    -- Accent (Wii-like blue)
    accent         = {0.35, 0.65, 1.0, 1.0},
    accent_soft    = {0.35, 0.65, 1.0, 0.4},
}

-- ===== Helpers =====
function Theme.setColor(name)
    local c = Theme.colors[name]
    if c then
        love.graphics.setColor(c)
    end
end

function Theme.withAlpha(name, a)
    local c = Theme.colors[name]
    if c then
        love.graphics.setColor(c[1], c[2], c[3], a)
    end
end

return Theme
