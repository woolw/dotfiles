import { Gtk } from "ags/gtk4"
import Hyprland from "gi://AstalHyprland"

const hypr = Hyprland.get_default()

export default function ActiveWindow() {
    const label = new Gtk.Label()
    label.add_css_class("active-window")

    const formatAppName = (className: string): string => {
        // Handle reverse-domain names (org.wezfurlong.wezterm -> wezterm)
        if (className.includes(".")) {
            const parts = className.split(".")
            return parts[parts.length - 1]
        }
        return className
    }

    const update = () => {
        const client = hypr.focused_client
        if (client && client.class) {
            label.label = formatAppName(client.class)
            label.visible = true
        } else {
            label.visible = false
        }
    }

    update()

    hypr.connect("notify::focused-client", update)

    return label
}
