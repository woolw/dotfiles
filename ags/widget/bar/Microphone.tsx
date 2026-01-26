import { Gtk, Gdk } from "ags/gtk4"
import GLib from "gi://GLib"
import Wp from "gi://AstalWp"

const wp = Wp.get_default()!

export default function Microphone() {
    const box = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL })
    box.add_css_class("microphone")

    const icon = new Gtk.Label()
    icon.add_css_class("mic-icon")

    const percentLabel = new Gtk.Label()
    percentLabel.add_css_class("mic-percent")

    box.append(icon)
    box.append(percentLabel)

    const getMic = () => wp.audio?.defaultMicrophone

    const update = () => {
        const mic = getMic()
        if (!mic) {
            icon.label = "󰍭"
            percentLabel.label = ""
            return
        }

        const muted = mic.mute
        const percent = Math.round(mic.volume * 100)
        icon.label = muted ? "󰍭" : "󰍬"
        percentLabel.label = muted ? "mute" : `${percent}%`
    }

    // Click to toggle mute
    const click = new Gtk.GestureClick({ button: Gdk.BUTTON_PRIMARY })
    click.connect("pressed", () => {
        const mic = getMic()
        if (mic) {
            mic.mute = !mic.mute
        }
    })
    box.add_controller(click)

    // Scroll to change input volume
    const scroll = new Gtk.EventControllerScroll({ flags: Gtk.EventControllerScrollFlags.VERTICAL })
    scroll.connect("scroll", (_ctrl, _dx, dy) => {
        const mic = getMic()
        if (mic) {
            const step = 0.05
            mic.volume = Math.max(0, Math.min(1.5, mic.volume - dy * step))
        }
        return true
    })
    box.add_controller(scroll)

    update()

    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 200, () => {
        update()
        return true
    })

    return box
}
