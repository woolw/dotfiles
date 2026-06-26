import { Gtk } from "ags/gtk4"
import GLib from "gi://GLib"

function readAvgMHz(): number | null {
    try {
        const [ok, contents] = GLib.file_get_contents("/proc/cpuinfo")
        if (!ok) return null
        const text = new TextDecoder().decode(contents)
        const matches = [...text.matchAll(/^cpu MHz\s*:\s*([\d.]+)/gm)]
        if (matches.length === 0) return null
        const sum = matches.reduce((a, m) => a + parseFloat(m[1]), 0)
        return sum / matches.length
    } catch (_) {}
    return null
}

export default function CpuClock() {
    const box = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL })
    box.add_css_class("cpu-clock")

    const icon = new Gtk.Label()
    icon.label = "󰍛"
    icon.add_css_class("cpu-clock-icon")

    const clockLabel = new Gtk.Label()
    clockLabel.add_css_class("cpu-clock-value")

    box.append(icon)
    box.append(clockLabel)

    const update = () => {
        const mhz = readAvgMHz()
        if (mhz === null) {
            box.visible = false
            return
        }
        box.visible = true
        clockLabel.label = `${(mhz / 1000).toFixed(1)}GHz`
    }

    update()
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 2000, () => {
        update()
        return GLib.SOURCE_CONTINUE
    })

    return box
}
