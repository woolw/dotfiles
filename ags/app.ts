import app from "ags/gtk4/app"
import GLib from "gi://GLib"
import style from "./style.scss"
import Bar from "./widget/Bar"
import Launcher from "./widget/Launcher"
import PowerMenu from "./widget/PowerMenu"

// Change to home directory so spawned apps start there
GLib.chdir(GLib.get_home_dir())

app.start({
    css: style,
    main() {
        Bar(0)
        Launcher()
        PowerMenu()
    },
})
