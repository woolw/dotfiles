import { Astal, Gtk, Gdk } from "ags/gtk4"
import app from "ags/gtk4/app"
import GLib from "gi://GLib"

type MenuEntry = { type: "item"; icon: string; label: string; action: () => void } | { type: "separator" }

const menuItems: MenuEntry[] = [
    {
        type: "item",
        icon: "󰒓",
        label: "System Settings...",
        action: () => GLib.spawn_command_line_async("systemsettings"),
    },
    { type: "separator" },
    {
        type: "item",
        icon: "󰤄",
        label: "Sleep",
        action: () => GLib.spawn_command_line_async("systemctl suspend"),
    },
    {
        type: "item",
        icon: "󰜉",
        label: "Restart...",
        action: () => GLib.spawn_command_line_async("systemctl reboot"),
    },
    {
        type: "item",
        icon: "󰐥",
        label: "Shut Down...",
        action: () => GLib.spawn_command_line_async("systemctl poweroff"),
    },
    { type: "separator" },
    {
        type: "item",
        icon: "󰌾",
        label: "Lock Screen",
        action: () => GLib.spawn_command_line_async("hyprlock"),
    },
    {
        type: "item",
        icon: "󰍃",
        label: "Log Out...",
        action: () => GLib.spawn_command_line_async("hyprctl dispatch exit"),
    },
]

function MenuItem({ icon, label, action }: { icon: string; label: string; action: () => void }) {
    return (
        <button
            cssClasses={["menu-item"]}
            onClicked={() => {
                app.toggle_window("powermenu")
                action()
            }}
        >
            <box>
                <label cssClasses={["menu-icon"]} label={icon} />
                <label cssClasses={["menu-label"]} label={label} />
            </box>
        </button>
    )
}

function Separator() {
    return <box cssClasses={["menu-separator"]} />
}

export default function PowerMenu() {
    const win = (
        <window
            name="powermenu"
            cssClasses={["PowerMenu"]}
            application={app}
            visible={false}
            keymode={Astal.Keymode.ON_DEMAND}
            layer={Astal.Layer.TOP}
            anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.LEFT}
            marginTop={0}
            marginLeft={4}
        >
            <box orientation={Gtk.Orientation.VERTICAL} cssClasses={["powermenu-container"]}>
                {menuItems.map(entry =>
                    entry.type === "separator"
                        ? <Separator />
                        : <MenuItem icon={entry.icon} label={entry.label} action={entry.action} />
                )}
            </box>
        </window>
    ) as Astal.Window

    // Add key controller for ESC
    const keyController = new Gtk.EventControllerKey()
    keyController.connect("key-pressed", (_: Gtk.EventControllerKey, keyval: number) => {
        if (keyval === Gdk.KEY_Escape) {
            app.toggle_window("powermenu")
            return true
        }
        return false
    })
    win.add_controller(keyController)

    return win
}
