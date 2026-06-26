import { Gtk } from "ags/gtk4"
import GLib from "gi://GLib"

function findCpuTempPath(): string | null {
    for (let i = 0; i < 10; i++) {
        const namePath = `/sys/class/hwmon/hwmon${i}/name`
        try {
            const [ok, contents] = GLib.file_get_contents(namePath)
            if (ok) {
                const name = new TextDecoder().decode(contents).trim()
                if (name === "k10temp" || name === "zenpower") {
                    return `/sys/class/hwmon/hwmon${i}/temp1_input`
                }
            }
        } catch (_) {}
    }
    return null
}

function readTemp(path: string): number | null {
    try {
        const [ok, contents] = GLib.file_get_contents(path)
        if (ok) {
            return Math.round(parseInt(new TextDecoder().decode(contents).trim()) / 1000)
        }
    } catch (_) {}
    return null
}

export default function CpuTemp() {
    const box = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL })
    box.add_css_class("cpu-temp")

    const icon = new Gtk.Label()
    icon.label = "󱃂"
    icon.add_css_class("cpu-temp-icon")

    const tempLabel = new Gtk.Label()
    tempLabel.add_css_class("cpu-temp-value")

    box.append(icon)
    box.append(tempLabel)

    const tempPath = findCpuTempPath()

    if (!tempPath) {
        box.visible = false
        return box
    }

    const update = () => {
        const temp = readTemp(tempPath)
        if (temp === null) {
            box.visible = false
            return
        }
        box.visible = true
        tempLabel.label = `${temp}°C`

        box.remove_css_class("warm")
        box.remove_css_class("hot")
        if (temp >= 80) {
            box.add_css_class("hot")
        } else if (temp >= 60) {
            box.add_css_class("warm")
        }
    }

    update()
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 3000, () => {
        update()
        return GLib.SOURCE_CONTINUE
    })

    return box
}
