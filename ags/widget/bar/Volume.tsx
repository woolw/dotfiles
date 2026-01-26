import { Gtk, Gdk } from "ags/gtk4"
import GLib from "gi://GLib"
import Wp from "gi://AstalWp"

const wp = Wp.get_default()!

export default function Volume() {
    const box = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL })
    box.add_css_class("volume")

    const icon = new Gtk.Label()
    icon.add_css_class("volume-icon")

    const percentLabel = new Gtk.Label()
    percentLabel.add_css_class("volume-percent")

    box.append(icon)
    box.append(percentLabel)

    const getSpeaker = () => wp.audio?.defaultSpeaker

    const update = () => {
        const speaker = getSpeaker()
        if (!speaker) {
            icon.label = "󰖁"
            percentLabel.label = ""
            return
        }

        const vol = speaker.volume
        const muted = speaker.mute
        const percent = Math.round(vol * 100)

        if (muted || vol === 0) {
            icon.label = "󰖁"
        } else if (vol < 0.33) {
            icon.label = "󰕿"
        } else if (vol < 0.66) {
            icon.label = "󰖀"
        } else {
            icon.label = "󰕾"
        }

        percentLabel.label = muted ? "mute" : `${percent}%`
    }

    // Click to toggle mute
    const click = new Gtk.GestureClick({ button: Gdk.BUTTON_PRIMARY })
    click.connect("pressed", () => {
        const speaker = getSpeaker()
        if (speaker) {
            speaker.mute = !speaker.mute
        }
    })
    box.add_controller(click)

    // Scroll to change volume
    const scroll = new Gtk.EventControllerScroll({ flags: Gtk.EventControllerScrollFlags.VERTICAL })
    scroll.connect("scroll", (_ctrl, _dx, dy) => {
        const speaker = getSpeaker()
        if (speaker) {
            const step = 0.05
            speaker.volume = Math.max(0, Math.min(1.5, speaker.volume - dy * step))
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
