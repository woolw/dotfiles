import { Gtk, Gdk } from "ags/gtk4"
import GLib from "gi://GLib"
import AstalBluetooth from "gi://AstalBluetooth"

const bluetooth = AstalBluetooth.get_default()

export default function Bluetooth() {
    const box = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL })
    box.add_css_class("bluetooth")

    const icon = new Gtk.Label()
    icon.add_css_class("bluetooth-icon")

    box.append(icon)

    const update = () => {
        const adapter = bluetooth.adapter
        if (!adapter || !adapter.powered) {
            icon.label = "󰂲" // Bluetooth off
            box.remove_css_class("connected")
            return
        }

        const devices = bluetooth.get_devices()
        const connected = devices.filter(d => d.connected)

        if (connected.length > 0) {
            icon.label = "󰂱" // Bluetooth connected
            box.add_css_class("connected")
        } else {
            icon.label = "󰂯" // Bluetooth on
            box.remove_css_class("connected")
        }
    }

    // Click to open bluetooth settings
    const click = new Gtk.GestureClick({ button: Gdk.BUTTON_PRIMARY })
    click.connect("pressed", () => {
        GLib.spawn_command_line_async("systemsettings kcm_bluetooth")
    })
    box.add_controller(click)

    update()

    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 2000, () => {
        update()
        return true
    })

    return box
}
