hl.monitor({
    output   = "",
    mode     = "3840x2160@144.00",
    position = "0x0",
    scale    = 1,
})

hl.config({
    general = {
        border_size = 3,
        gaps_in     = 6,
        gaps_out    = 6,
        col = {
            active_border   = "rgb(56b6c2)",
            inactive_border = "rgb(282c34)",
        },
        layout = "dwindle",
    },

    decoration = {
        rounding = 5,
        blur = {
            enabled        = true,
            size           = 5,
            passes         = 2,
            ignore_opacity = true,
        },
    },

    animations = {
        enabled = false,
    },

    input = {
        kb_layout      = "us",
        follow_mouse   = 1,
        natural_scroll = true,
        touchpad = {
            natural_scroll = true,
        },
    },

    cursor = {
        hide_on_key_press = true,
    },

    misc = {
        force_default_wallpaper  = 0,
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        vrr = 2,
    },

    debug = {
        vfr = true,
    },

    ecosystem = {
        no_update_news = true,
    },
})
