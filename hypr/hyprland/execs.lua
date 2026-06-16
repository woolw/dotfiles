hl.on("hyprland.start", function()
    -- KWallet init MUST run first (before nm-applet) - uses PAM to auto-unlock
    hl.exec_cmd("/run/current-system/sw/libexec/pam_kwallet_init")

    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("xdg-desktop-portal-gtk")
    hl.exec_cmd("sh -c 'until hyprctl monitors; do sleep 0.1; done && : > /tmp/ags.log; ags run --gtk 4 --log-file /tmp/ags.log'")
    hl.exec_cmd("swaync")

    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- must be AFTER kwallet init
    hl.exec_cmd("sh -c 'until hyprctl monitors; do sleep 0.1; done && nm-applet'")
    hl.exec_cmd("blueman-applet")
end)
