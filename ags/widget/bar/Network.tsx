import { Gtk, Gdk } from "ags/gtk4"
import GLib from "gi://GLib"
import AstalNetwork from "gi://AstalNetwork"

const network = AstalNetwork.get_default()

export default function Network() {
    const box = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL })
    box.add_css_class("network")

    const icon = new Gtk.Label()
    icon.add_css_class("network-icon")
    icon.label = "󰤨" // Default icon

    box.append(icon)

    const update = () => {
        const wifi = network.wifi
        const wired = network.wired

        // Prefer WiFi display if it has an active connection (SSID present)
        if (wifi && wifi.ssid) {
            const strength = wifi.strength
            if (wifi.internet === AstalNetwork.Internet.DISCONNECTED) {
                icon.label = "󰤭"
            } else if (strength > 75) {
                icon.label = "󰤨"
            } else if (strength > 50) {
                icon.label = "󰤥"
            } else if (strength > 25) {
                icon.label = "󰤢"
            } else {
                icon.label = "󰤟"
            }
        } else if (wired && wired.internet === AstalNetwork.Internet.CONNECTED) {
            icon.label = "󰈁"
        } else {
            icon.label = "󰤮"
        }
    }

    // Click to open network settings
    const click = new Gtk.GestureClick({ button: Gdk.BUTTON_PRIMARY })
    click.connect("pressed", () => {
        GLib.spawn_command_line_async("systemsettings kcm_networkmanagement")
    })
    box.add_controller(click)

    update()

    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 2000, () => {
        update()
        return true
    })

    return box
}
