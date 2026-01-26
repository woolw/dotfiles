import { Gtk, Gdk } from "ags/gtk4"
import GLib from "gi://GLib"
import AstalBattery from "gi://AstalBattery"

const battery = AstalBattery.get_default()

export default function Battery() {
    const box = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL })
    box.add_css_class("battery")

    const icon = new Gtk.Label()
    icon.add_css_class("battery-icon")

    const percentLabel = new Gtk.Label()
    percentLabel.add_css_class("battery-percent")

    box.append(icon)
    box.append(percentLabel)

    const update = () => {
        if (!battery || !battery.isPresent) {
            box.visible = false
            return
        }

        box.visible = true
        const percent = Math.round(battery.percentage * 100)
        const charging = battery.charging

        if (charging) {
            icon.label = "󰂄"
        } else if (percent > 90) {
            icon.label = "󰁹"
        } else if (percent > 70) {
            icon.label = "󰂁"
        } else if (percent > 50) {
            icon.label = "󰁿"
        } else if (percent > 30) {
            icon.label = "󰁽"
        } else if (percent > 10) {
            icon.label = "󰁻"
        } else {
            icon.label = "󰂃"
        }

        percentLabel.label = `${percent}%`

        if (percent <= 20 && !charging) {
            box.add_css_class("low")
        } else {
            box.remove_css_class("low")
        }
    }

    // Click to open power settings
    const click = new Gtk.GestureClick({ button: Gdk.BUTTON_PRIMARY })
    click.connect("pressed", () => {
        GLib.spawn_command_line_async("systemsettings kcm_powerdevilprofilesconfig")
    })
    box.add_controller(click)

    update()

    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 5000, () => {
        update()
        return true
    })

    return box
}
