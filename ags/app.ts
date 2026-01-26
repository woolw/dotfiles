import app from "ags/gtk4/app"
import GLib from "gi://GLib"
import style from "./style.scss"
import Bar from "./widget/bar/index"
import Launcher from "./widget/Launcher"
import PowerMenu from "./widget/PowerMenu"
import { QuickSettingsWindow } from "./widget/bar/QuickSettings"
import { CalendarWindow } from "./widget/bar/Clock"

// Change to home directory so spawned apps start there
GLib.chdir(GLib.get_home_dir())

app.start({
    css: style,
    main() {
        Bar(0)
        Launcher()
        PowerMenu()
        QuickSettingsWindow()
        CalendarWindow()
    },
})
