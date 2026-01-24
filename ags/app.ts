import app from "ags/gtk4/app"
import style from "./style.scss"
import Bar from "./widget/Bar"
import Launcher from "./widget/Launcher"
import PowerMenu from "./widget/PowerMenu"

app.start({
    css: style,
    main() {
        Bar(0)
        Launcher()
        PowerMenu()
    },
})
