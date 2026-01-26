import { Gtk } from "ags/gtk4"
import Hyprland from "gi://AstalHyprland"

const hypr = Hyprland.get_default()

export default function Workspaces() {
    const box = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL })
    box.add_css_class("workspaces")

    // Create 5 static workspace buttons with circle indicators
    const buttons: { btn: Gtk.Button; label: Gtk.Label }[] = []
    for (let i = 1; i <= 5; i++) {
        const btn = new Gtk.Button()
        btn.add_css_class("workspace")

        const label = new Gtk.Label({ label: "○" }) // Empty circle
        label.add_css_class("workspace-icon")
        btn.set_child(label)

        btn.connect("clicked", () => {
            hypr.dispatch("workspace", String(i))
        })

        buttons.push({ btn, label })
        box.append(btn)
    }

    const updateWorkspaces = () => {
        const focusedId = hypr.focused_workspace?.id || 1

        // Get workspace IDs that have windows
        const occupiedIds = new Set(
            hypr.workspaces
                .filter(ws => ws.id > 0 && ws.id <= 5)
                .map(ws => ws.id)
        )

        buttons.forEach(({ btn, label }, idx) => {
            const wsId = idx + 1
            const isActive = wsId === focusedId
            const isOccupied = occupiedIds.has(wsId)

            // Update circle icon
            if (isActive) {
                label.label = "●" // Filled circle for active
            } else if (isOccupied) {
                label.label = "◐" // Half-filled for occupied
            } else {
                label.label = "○" // Empty circle
            }

            // CSS classes
            if (isActive) {
                btn.add_css_class("active")
            } else {
                btn.remove_css_class("active")
            }

            if (isOccupied) {
                btn.add_css_class("occupied")
            } else {
                btn.remove_css_class("occupied")
            }
        })
    }

    // Initial update
    updateWorkspaces()

    // Update on workspace changes
    hypr.connect("notify::focused-workspace", updateWorkspaces)
    hypr.connect("notify::workspaces", updateWorkspaces)

    return box
}
