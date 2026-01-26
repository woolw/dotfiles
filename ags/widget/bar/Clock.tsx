import { Astal, Gtk, Gdk } from "ags/gtk4"
import app from "ags/gtk4/app"
import GLib from "gi://GLib"

// Create the calendar window (called from app.ts)
export function CalendarWindow() {
    const calBox = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 8 })
    calBox.add_css_class("calendar-box")

    const calendar = new Gtk.Calendar()
    calendar.add_css_class("calendar")

    calBox.append(calendar)

    // Panel container
    const panel = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL })
    panel.add_css_class("calendar-popover")
    panel.append(calBox)

    // Overlay for positioning
    const overlay = new Gtk.Overlay()

    // Transparent backdrop
    const backdrop = new Gtk.Button()
    backdrop.add_css_class("calendar-backdrop")
    backdrop.set_hexpand(true)
    backdrop.set_vexpand(true)
    overlay.set_child(backdrop)

    // Position the panel
    panel.set_halign(Gtk.Align.END)
    panel.set_valign(Gtk.Align.START)
    panel.set_margin_top(4)
    panel.set_margin_end(8)
    overlay.add_overlay(panel)

    const win = (
        <window
            name="calendar"
            cssClasses={["Calendar"]}
            application={app}
            visible={false}
            keymode={Astal.Keymode.ON_DEMAND}
            layer={Astal.Layer.TOP}
            anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.LEFT | Astal.WindowAnchor.RIGHT | Astal.WindowAnchor.BOTTOM}
        >
            {overlay}
        </window>
    ) as Astal.Window

    // Close on backdrop click
    backdrop.connect("clicked", () => app.toggle_window("calendar"))

    // Close on ESC
    const keyController = new Gtk.EventControllerKey()
    keyController.connect("key-pressed", (_: Gtk.EventControllerKey, keyval: number) => {
        if (keyval === Gdk.KEY_Escape) {
            app.toggle_window("calendar")
            return true
        }
        return false
    })
    win.add_controller(keyController)

    return win
}

// Bar button
export default function Clock() {
    const btn = new Gtk.Button()
    btn.add_css_class("clock")

    const clockLabel = new Gtk.Label({
        label: GLib.DateTime.new_now_local().format("%a %b %d  %H:%M")!,
    })
    btn.set_child(clockLabel)

    // Update clock every second
    GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 1, () => {
        clockLabel.label = GLib.DateTime.new_now_local().format("%a %b %d  %H:%M")!
        return true
    })

    btn.connect("clicked", () => app.toggle_window("calendar"))

    return btn
}
