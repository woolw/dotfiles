import { Astal, Gtk, Gdk } from "ags/gtk4"
import app from "ags/gtk4/app"
import GLib from "gi://GLib"
import Hyprland from "gi://AstalHyprland"
import Tray from "gi://AstalTray"
import Wp from "gi://AstalWp"

const hypr = Hyprland.get_default()
const tray = Tray.get_default()
const wp = Wp.get_default()!

function Volume() {
    const box = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL })
    box.add_css_class("volume")

    const icon = new Gtk.Label()
    icon.add_css_class("volume-icon")

    const percentLabel = new Gtk.Label()
    percentLabel.add_css_class("volume-percent")

    box.append(icon)
    box.append(percentLabel)

    const getSpeaker = () => wp.audio?.defaultSpeaker

    const update = () => {
        const speaker = getSpeaker()
        if (!speaker) {
            icon.label = "󰖁"
            percentLabel.label = ""
            return
        }

        const vol = speaker.volume
        const muted = speaker.mute
        const percent = Math.round(vol * 100)

        if (muted || vol === 0) {
            icon.label = "󰖁"
        } else if (vol < 0.33) {
            icon.label = "󰕿"
        } else if (vol < 0.66) {
            icon.label = "󰖀"
        } else {
            icon.label = "󰕾"
        }

        percentLabel.label = muted ? "mute" : `${percent}%`
    }

    // Click to toggle mute
    const click = new Gtk.GestureClick({ button: Gdk.BUTTON_PRIMARY })
    click.connect("pressed", () => {
        const speaker = getSpeaker()
        if (speaker) {
            speaker.mute = !speaker.mute
        }
    })
    box.add_controller(click)

    // Scroll to change volume
    const scroll = new Gtk.EventControllerScroll({ flags: Gtk.EventControllerScrollFlags.VERTICAL })
    scroll.connect("scroll", (_ctrl, _dx, dy) => {
        const speaker = getSpeaker()
        if (speaker) {
            const step = 0.05
            speaker.volume = Math.max(0, Math.min(1.5, speaker.volume - dy * step))
        }
        return true
    })
    box.add_controller(scroll)

    update()

    // Update on changes
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 200, () => {
        update()
        return true
    })

    return box
}

function Microphone() {
    const box = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL })
    box.add_css_class("microphone")

    const icon = new Gtk.Label()
    icon.add_css_class("mic-icon")

    const percentLabel = new Gtk.Label()
    percentLabel.add_css_class("mic-percent")

    box.append(icon)
    box.append(percentLabel)

    const getMic = () => wp.audio?.defaultMicrophone

    const update = () => {
        const mic = getMic()
        if (!mic) {
            icon.label = "󰍭"
            percentLabel.label = ""
            return
        }

        const muted = mic.mute
        const percent = Math.round(mic.volume * 100)
        icon.label = muted ? "󰍭" : "󰍬"
        percentLabel.label = muted ? "mute" : `${percent}%`
    }

    // Click to toggle mute
    const click = new Gtk.GestureClick({ button: Gdk.BUTTON_PRIMARY })
    click.connect("pressed", () => {
        const mic = getMic()
        if (mic) {
            mic.mute = !mic.mute
        }
    })
    box.add_controller(click)

    // Scroll to change input volume
    const scroll = new Gtk.EventControllerScroll({ flags: Gtk.EventControllerScrollFlags.VERTICAL })
    scroll.connect("scroll", (_ctrl, _dx, dy) => {
        const mic = getMic()
        if (mic) {
            const step = 0.05
            mic.volume = Math.max(0, Math.min(1.5, mic.volume - dy * step))
        }
        return true
    })
    box.add_controller(scroll)

    update()

    // Update on changes
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 200, () => {
        update()
        return true
    })

    return box
}

function SystemTray() {
    const box = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL })
    box.add_css_class("tray")

    const items = new Map<string, Gtk.Widget>()

    const addItem = (item: Tray.TrayItem) => {
        // Use MenuButton for proper menu integration
        const menuBtn = new Gtk.MenuButton()
        menuBtn.add_css_class("tray-item")

        const icon = new Gtk.Image()
        icon.add_css_class("tray-icon")

        // Set icon from gicon or icon-name
        if (item.gicon) {
            icon.set_from_gicon(item.gicon)
        } else if (item.iconName) {
            icon.iconName = item.iconName
        }

        menuBtn.set_child(icon)

        // Create popover with item's menu
        const popover = Gtk.PopoverMenu.new_from_model(item.menuModel)
        menuBtn.set_popover(popover)

        // Insert action group for menu actions to work
        if (item.actionGroup) {
            popover.insert_action_group("dbusmenu", item.actionGroup)
        }

        // Update when menu/actions change
        item.connect("notify::menu-model", () => {
            popover.set_menu_model(item.menuModel)
        })
        item.connect("notify::action-group", () => {
            if (item.actionGroup) {
                popover.insert_action_group("dbusmenu", item.actionGroup)
            }
        })

        items.set(item.itemId, menuBtn)
        box.append(menuBtn)

        // Update icon when it changes
        item.connect("notify::gicon", () => {
            if (item.gicon) {
                icon.set_from_gicon(item.gicon)
            }
        })
        item.connect("notify::icon-name", () => {
            if (item.iconName) {
                icon.iconName = item.iconName
            }
        })
    }

    const removeItem = (itemId: string) => {
        const widget = items.get(itemId)
        if (widget) {
            box.remove(widget)
            items.delete(itemId)
        }
    }

    // Add existing items
    tray.get_items().forEach(addItem)

    // Handle new/removed items
    tray.connect("item-added", (_tray, itemId: string) => {
        const item = tray.get_item(itemId)
        if (item) addItem(item)
    })
    tray.connect("item-removed", (_tray, itemId: string) => {
        removeItem(itemId)
    })

    return box
}

function Workspaces() {
    const box = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL })
    box.add_css_class("workspaces")

    const updateWorkspaces = () => {
        // Clear existing
        let child = box.get_first_child()
        while (child) {
            const next = child.get_next_sibling()
            box.remove(child)
            child = next
        }

        // Get workspaces with windows, sorted by id
        const workspaces = hypr.workspaces
            .filter(ws => ws.id > 0)
            .sort((a, b) => a.id - b.id)

        const focusedId = hypr.focused_workspace?.id || 1

        workspaces.forEach(ws => {
            const btn = new Gtk.Button()
            btn.add_css_class("workspace")
            if (ws.id === focusedId) {
                btn.add_css_class("active")
            }

            const label = new Gtk.Label({ label: String(ws.id) })
            btn.set_child(label)

            btn.connect("clicked", () => {
                ws.focus()
            })

            box.append(btn)
        })
    }

    // Initial update
    updateWorkspaces()

    // Update on workspace changes
    hypr.connect("notify::focused-workspace", updateWorkspaces)
    hypr.connect("notify::workspaces", updateWorkspaces)

    return box
}

export default function Bar(monitor: number) {
    const anchor = Astal.WindowAnchor.TOP
        | Astal.WindowAnchor.LEFT
        | Astal.WindowAnchor.RIGHT

    // Clock label - updates every second
    const clockLabel = new Gtk.Label({
        label: GLib.DateTime.new_now_local().format("%a %b %d  %H:%M")!,
    })
    clockLabel.add_css_class("clock")

    GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 1, () => {
        clockLabel.label = GLib.DateTime.new_now_local().format("%a %b %d  %H:%M")!
        return true
    })

    return (
        <window
            name={`bar-${monitor}`}
            cssClasses={["Bar"]}
            gdkmonitor={app.get_monitors()[monitor]}
            exclusivity={Astal.Exclusivity.EXCLUSIVE}
            anchor={anchor}
            visible={true}
        >
            <box>
                <button
                    cssClasses={["logo"]}
                    onClicked={() => app.toggle_window("powermenu")}
                >
                    <label label="󱄅" />
                </button>
                <Workspaces />
                <box hexpand />
                <SystemTray />
                <Microphone />
                <Volume />
                <button
                    cssClasses={["notification-btn"]}
                    onClicked={() => GLib.spawn_command_line_async("swaync-client -t")}
                >
                    <label cssClasses={["notification-icon"]} label="󰂚" />
                </button>
                {clockLabel}
            </box>
        </window>
    )
}
