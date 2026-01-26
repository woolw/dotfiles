import { Gtk } from "ags/gtk4"
import GLib from "gi://GLib"

export default function Clock() {
    const menuBtn = new Gtk.MenuButton()
    menuBtn.add_css_class("clock")

    const clockLabel = new Gtk.Label({
        label: GLib.DateTime.new_now_local().format("%a %b %d  %H:%M")!,
    })
    menuBtn.set_child(clockLabel)

    // Update clock every second
    GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 1, () => {
        clockLabel.label = GLib.DateTime.new_now_local().format("%a %b %d  %H:%M")!
        return true
    })

    // Calendar popover
    const popover = new Gtk.Popover()
    popover.add_css_class("calendar-popover")

    const calBox = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 8 })
    calBox.add_css_class("calendar-box")

    const calendar = new Gtk.Calendar()
    calendar.add_css_class("calendar")

    calBox.append(calendar)
    popover.set_child(calBox)
    menuBtn.set_popover(popover)

    return menuBtn
}
