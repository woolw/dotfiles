import { Gtk } from "ags/gtk4"
import GLib from "gi://GLib"

interface CpuStats {
    idle: number
    total: number
}

function readCpuStats(): CpuStats | null {
    try {
        const [ok, contents] = GLib.file_get_contents("/proc/stat")
        if (!ok) return null
        const line = new TextDecoder().decode(contents).split("\n")[0]
        // cpu user nice system idle iowait irq softirq steal ...
        const parts = line.trim().split(/\s+/).slice(1).map(Number)
        const idle = parts[3] + (parts[4] ?? 0) // idle + iowait
        const total = parts.reduce((a, b) => a + b, 0)
        return { idle, total }
    } catch (_) {}
    return null
}

export default function CpuUsage() {
    const box = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL })
    box.add_css_class("cpu-usage")

    const icon = new Gtk.Label()
    icon.label = "󰻠"
    icon.add_css_class("cpu-usage-icon")

    const usageLabel = new Gtk.Label()
    usageLabel.label = "0%"
    usageLabel.add_css_class("cpu-usage-value")

    box.append(icon)
    box.append(usageLabel)

    let prev = readCpuStats()
    if (!prev) {
        box.visible = false
        return box
    }

    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 2000, () => {
        const curr = readCpuStats()
        if (!curr) return GLib.SOURCE_CONTINUE

        const idleDelta = curr.idle - prev!.idle
        const totalDelta = curr.total - prev!.total
        prev = curr

        if (totalDelta === 0) return GLib.SOURCE_CONTINUE

        const usage = Math.round((1 - idleDelta / totalDelta) * 100)
        usageLabel.label = `${usage}%`

        box.remove_css_class("high")
        if (usage >= 80) box.add_css_class("high")

        return GLib.SOURCE_CONTINUE
    })

    return box
}
