local mod = "SUPER"

hl.bind(mod .. " + Space",         hl.dsp.exec_cmd("ags toggle launcher"))

hl.bind(mod .. " + H",             hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + L",             hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + K",             hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + J",             hl.dsp.focus({ direction = "down" }))

hl.bind(mod .. " + SHIFT + H",     hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + L",     hl.dsp.window.move({ direction = "right" }))
hl.bind(mod .. " + SHIFT + K",     hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + J",     hl.dsp.window.move({ direction = "down" }))

hl.bind(mod .. " + mouse:272",     hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273",     hl.dsp.window.resize(), { mouse = true })

hl.bind(mod .. " + Q",             hl.dsp.window.close())
hl.bind(mod .. " + SHIFT + Q",     hl.dsp.exit())

hl.bind(mod .. " + MINUS",         hl.dsp.layout("splitratio -0.1"), { repeating = true })
hl.bind(mod .. " + EQUAL",         hl.dsp.layout("splitratio 0.1"),  { repeating = true })

hl.bind(mod .. " + ALT + Space",   hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + F",             hl.dsp.window.fullscreen(0))
hl.bind(mod .. " + D",             hl.dsp.window.fullscreen(1))

for i = 1, 5 do
    hl.bind(mod .. " + " .. i,         hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

hl.bind("XF86AudioRaiseVolume",    hl.dsp.exec_cmd("pamixer -i 5"))
hl.bind("XF86AudioLowerVolume",    hl.dsp.exec_cmd("pamixer -d 5"))
hl.bind("XF86AudioMute",           hl.dsp.exec_cmd("pamixer -t"))

hl.bind(mod .. " + ALT + L",       hl.dsp.exec_cmd("hyprlock"))

hl.bind("F1",                      hl.dsp.exec_cmd("systemctl suspend"),  { locked = true })
hl.bind("F2",                      hl.dsp.exec_cmd("systemctl reboot"),   { locked = true })
hl.bind("F3",                      hl.dsp.exec_cmd("systemctl poweroff"), { locked = true })

hl.bind(mod .. " + V",             hl.dsp.exec_cmd("cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"))

hl.bind("Print",                   hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))
hl.bind("SHIFT + Print",           hl.dsp.exec_cmd("hyprshot -m region -o ~/Pictures/Screenshots"))
hl.bind(mod .. " + Print",         hl.dsp.exec_cmd("hyprshot -m window --clipboard-only"))
hl.bind(mod .. " + SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m output -o ~/Pictures/Screenshots"))

hl.bind(mod .. " + C",             hl.dsp.exec_cmd("codium"))
