import { Gtk } from "ags/gtk4"
import GLib from "gi://GLib"

// ── helpers ────────────────────────────────────────────────────────────────

function readText(path: string): string | null {
    try {
        const [ok, data] = GLib.file_get_contents(path)
        if (ok) return new TextDecoder().decode(data).trim()
    } catch (_) {}
    return null
}

function findHwmon(driver: string): string | null {
    for (let i = 0; i < 15; i++) {
        if (readText(`/sys/class/hwmon/hwmon${i}/name`) === driver)
            return `/sys/class/hwmon/hwmon${i}`
    }
    return null
}

function hwmonTemp(dir: string, slot = 1): number | null {
    const v = readText(`${dir}/temp${slot}_input`)
    return v ? Math.round(parseInt(v) / 1000) : null
}

// ── CPU ────────────────────────────────────────────────────────────────────

interface Ticks { idle: number; total: number }

function cpuTicks(): Ticks | null {
    const line = readText("/proc/stat")?.split("\n")[0]
    if (!line) return null
    const p = line.trim().split(/\s+/).slice(1).map(Number)
    return { idle: p[3] + (p[4] ?? 0), total: p.reduce((a, b) => a + b, 0) }
}

function cpuMHz(): number | null {
    const text = readText("/proc/cpuinfo")
    if (!text) return null
    const m = [...text.matchAll(/^cpu MHz\s*:\s*([\d.]+)/gm)]
    if (!m.length) return null
    return m.reduce((a, x) => a + parseFloat(x[1]), 0) / m.length
}

// ── GPU ────────────────────────────────────────────────────────────────────

function gpuBusyPct(): number | null {
    const v = readText("/sys/class/drm/card1/device/gpu_busy_percent")
    return v !== null ? parseInt(v) : null
}

// ── RAM ────────────────────────────────────────────────────────────────────

function ramInfo(): { used: number; total: number } | null {
    const text = readText("/proc/meminfo")
    if (!text) return null
    const total = parseInt(text.match(/^MemTotal:\s+(\d+)/m)?.[1] ?? "0")
    const avail = parseInt(text.match(/^MemAvailable:\s+(\d+)/m)?.[1] ?? "0")
    if (!total) return null
    return { used: (total - avail) / 1048576, total: total / 1048576 }
}

function ramClockMHz(): number | null {
    // Written at boot by the dmi-memspeed systemd service (dmidecode needs root)
    const v = readText("/run/dmi-memspeed")
    if (!v) return null
    const mhz = parseInt(v)
    return mhz > 0 ? mhz : null
}

// ── Widget ─────────────────────────────────────────────────────────────────

function group(icon: string, cls: string): [Gtk.Box, Gtk.Label[]] {
    const box = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL })
    box.add_css_class("stat-group")
    box.add_css_class(cls)

    const iconLabel = new Gtk.Label()
    iconLabel.label = icon
    iconLabel.add_css_class("stat-icon")
    box.append(iconLabel)

    const vals: Gtk.Label[] = []
    const addVal = () => {
        const l = new Gtk.Label()
        l.add_css_class("stat-val")
        box.append(l)
        vals.push(l)
        return l
    }

    return [box, vals, addVal] as any
}

export default function SystemStats() {
    const cpuHwmon = findHwmon("k10temp") ?? findHwmon("zenpower")
    const gpuHwmon = findHwmon("amdgpu")

    // ── CPU group
    const cpuBox = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL })
    cpuBox.add_css_class("stat-group")
    const cpuIcon = new Gtk.Label()
    cpuIcon.label = "󰻠"
    cpuIcon.add_css_class("stat-icon")
    const cpuUsage = new Gtk.Label()
    cpuUsage.add_css_class("stat-val")
    cpuUsage.add_css_class("cpu-usage-val")
    const cpuClock = new Gtk.Label()
    cpuClock.add_css_class("stat-val")
    cpuClock.add_css_class("cpu-clock-val")
    const cpuTemp = new Gtk.Label()
    cpuTemp.add_css_class("stat-val")
    cpuTemp.add_css_class("cpu-temp-val")
    cpuTemp.visible = cpuHwmon !== null
    cpuBox.append(cpuIcon)
    cpuBox.append(cpuUsage)
    cpuBox.append(cpuClock)
    cpuBox.append(cpuTemp)

    // ── GPU group
    const gpuBox = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL })
    gpuBox.add_css_class("stat-group")
    const gpuIcon = new Gtk.Label()
    gpuIcon.label = "󰍹"
    gpuIcon.add_css_class("stat-icon")
    const gpuUsage = new Gtk.Label()
    gpuUsage.add_css_class("stat-val")
    gpuUsage.add_css_class("gpu-usage-val")
    const gpuTemp = new Gtk.Label()
    gpuTemp.add_css_class("stat-val")
    gpuTemp.add_css_class("gpu-temp-val")
    gpuTemp.visible = gpuHwmon !== null
    gpuBox.append(gpuIcon)
    gpuBox.append(gpuUsage)
    gpuBox.append(gpuTemp)

    // ── RAM group
    const ramBox = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL })
    ramBox.add_css_class("stat-group")
    const ramIcon = new Gtk.Label()
    ramIcon.label = "󰑭"
    ramIcon.add_css_class("stat-icon")
    const ramUsed = new Gtk.Label()
    ramUsed.add_css_class("stat-val")
    ramUsed.add_css_class("ram-used-val")
    const ramClock = new Gtk.Label()
    ramClock.add_css_class("stat-val")
    ramClock.add_css_class("ram-clock-val")
    ramBox.append(ramIcon)
    ramBox.append(ramUsed)
    ramBox.append(ramClock)

    // RAM clock is static — read once
    const ramHz = ramClockMHz()
    if (ramHz) ramClock.label = `${ramHz}MT/s`
    else ramClock.visible = false

    const outer = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL })
    outer.add_css_class("system-stats")
    outer.append(cpuBox)
    outer.append(gpuBox)
    outer.append(ramBox)

    let prevTicks = cpuTicks()

    const update = () => {
        // CPU usage
        const curr = cpuTicks()
        if (curr && prevTicks) {
            const di = curr.idle - prevTicks.idle
            const dt = curr.total - prevTicks.total
            if (dt > 0) {
                const pct = Math.round((1 - di / dt) * 100)
                cpuUsage.label = `${pct}%`
            }
        }
        prevTicks = curr

        // CPU clock
        const mhz = cpuMHz()
        if (mhz) cpuClock.label = `${(mhz / 1000).toFixed(1)}GHz`

        // CPU temp
        if (cpuHwmon) {
            const t = hwmonTemp(cpuHwmon)
            if (t !== null) {
                cpuTemp.label = `${t}°C`
                cpuBox.remove_css_class("warm")
                cpuBox.remove_css_class("hot")
                if (t >= 80) cpuBox.add_css_class("hot")
                else if (t >= 60) cpuBox.add_css_class("warm")
            }
        }

        // GPU usage
        const gpuPct = gpuBusyPct()
        if (gpuPct !== null) {
            gpuUsage.label = `${gpuPct}%`
            gpuBox.remove_css_class("high")
            if (gpuPct >= 80) gpuBox.add_css_class("high")
        }

        // GPU temp (junction = slot 2, fallback to edge = slot 1)
        if (gpuHwmon) {
            const t = hwmonTemp(gpuHwmon, 2) ?? hwmonTemp(gpuHwmon, 1)
            if (t !== null) {
                gpuTemp.label = `${t}°C`
                gpuBox.remove_css_class("warm")
                gpuBox.remove_css_class("hot")
                if (t >= 95) gpuBox.add_css_class("hot")
                else if (t >= 75) gpuBox.add_css_class("warm")
            }
        }

        // RAM
        const ram = ramInfo()
        if (ram) {
            ramUsed.label = `${ram.used.toFixed(1)}GiB`
            ramBox.remove_css_class("high")
            if (ram.used / ram.total >= 0.85) ramBox.add_css_class("high")
        }
    }

    update()
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 2000, () => {
        update()
        return GLib.SOURCE_CONTINUE
    })

    return outer
}
