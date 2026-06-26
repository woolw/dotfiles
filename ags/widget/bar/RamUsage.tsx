import { Gtk } from "ags/gtk4"
import GLib from "gi://GLib"

function readRam(): { used: number; total: number } | null {
    try {
        const [ok, contents] = GLib.file_get_contents("/proc/meminfo")
        if (!ok) return null
        const text = new TextDecoder().decode(contents)
        const totalMatch = text.match(/^MemTotal:\s+(\d+)/m)
        const availMatch = text.match(/^MemAvailable:\s+(\d+)/m)
        if (!totalMatch || !availMatch) return null
        const totalKB = parseInt(totalMatch[1])
        const usedKB = totalKB - parseInt(availMatch[1])
        return { used: usedKB / 1048576, total: totalKB / 1048576 }
    } catch (_) {}
    return null
}

export default function RamUsage() {
    const box = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL })
    box.add_css_class("ram-usage")

    const icon = new Gtk.Label()
    icon.label = "󰑭"
    icon.add_css_class("ram-usage-icon")

    const ramLabel = new Gtk.Label()
    ramLabel.add_css_class("ram-usage-value")

    box.append(icon)
    box.append(ramLabel)

    const update = () => {
        const info = readRam()
        if (!info) {
            box.visible = false
            return
        }
        box.visible = true
        ramLabel.label = `${info.used.toFixed(1)}GiB`

        box.remove_css_class("high")
        if (info.used / info.total >= 0.85) box.add_css_class("high")
    }

    update()
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 3000, () => {
        update()
        return GLib.SOURCE_CONTINUE
    })

    return box
}
