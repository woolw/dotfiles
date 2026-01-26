import { Astal, Gtk, Gdk } from "ags/gtk4"
import app from "ags/gtk4/app"
import GLib from "gi://GLib"
import Hyprland from "gi://AstalHyprland"
import Tray from "gi://AstalTray"
import Wp from "gi://AstalWp"
import Battery from "gi://AstalBattery"
import Bluetooth from "gi://AstalBluetooth"
import Network from "gi://AstalNetwork"

const hypr = Hyprland.get_default()
const tray = Tray.get_default()
const wp = Wp.get_default()!
const battery = Battery.get_default()
const bluetooth = Bluetooth.get_default()
const network = Network.get_default()

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

function BatteryWidget() {
    const box = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL })
    box.add_css_class("battery")

    const icon = new Gtk.Label()
    icon.add_css_class("battery-icon")

    const percentLabel = new Gtk.Label()
    percentLabel.add_css_class("battery-percent")

    box.append(icon)
    box.append(percentLabel)

    const update = () => {
        if (!battery || !battery.isPresent) {
            box.visible = false
            return
        }

        box.visible = true
        const percent = Math.round(battery.percentage * 100)
        const charging = battery.charging

        if (charging) {
            icon.label = "󰂄"
        } else if (percent > 90) {
            icon.label = "󰁹"
        } else if (percent > 70) {
            icon.label = "󰂁"
        } else if (percent > 50) {
            icon.label = "󰁿"
        } else if (percent > 30) {
            icon.label = "󰁽"
        } else if (percent > 10) {
            icon.label = "󰁻"
        } else {
            icon.label = "󰂃"
        }

        percentLabel.label = `${percent}%`

        // Add warning class if low
        if (percent <= 20 && !charging) {
            box.add_css_class("low")
        } else {
            box.remove_css_class("low")
        }
    }

    // Click to open power settings
    const click = new Gtk.GestureClick({ button: Gdk.BUTTON_PRIMARY })
    click.connect("pressed", () => {
        GLib.spawn_command_line_async("systemsettings kcm_powerdevilprofilesconfig")
    })
    box.add_controller(click)

    update()

    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 5000, () => {
        update()
        return true
    })

    return box
}

function BluetoothWidget() {
    const box = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL })
    box.add_css_class("bluetooth")

    const icon = new Gtk.Label()
    icon.add_css_class("bluetooth-icon")

    box.append(icon)

    const update = () => {
        const adapter = bluetooth.adapter
        if (!adapter || !adapter.powered) {
            icon.label = "󰂲" // Bluetooth off
            box.remove_css_class("connected")
            return
        }

        const devices = bluetooth.get_devices()
        const connected = devices.filter(d => d.connected)

        if (connected.length > 0) {
            icon.label = "󰂱" // Bluetooth connected
            box.add_css_class("connected")
        } else {
            icon.label = "󰂯" // Bluetooth on
            box.remove_css_class("connected")
        }
    }

    // Click to open bluetooth settings
    const click = new Gtk.GestureClick({ button: Gdk.BUTTON_PRIMARY })
    click.connect("pressed", () => {
        GLib.spawn_command_line_async("systemsettings kcm_bluetooth")
    })
    box.add_controller(click)

    update()

    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 2000, () => {
        update()
        return true
    })

    return box
}

function NetworkWidget() {
    const box = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL })
    box.add_css_class("network")

    const icon = new Gtk.Label()
    icon.add_css_class("network-icon")
    icon.label = "󰤨" // Default icon

    box.append(icon)

    const update = () => {
        const wifi = network.wifi
        const wired = network.wired

        // Prefer WiFi display if it has an active connection (SSID present)
        if (wifi && wifi.ssid) {
            const strength = wifi.strength
            if (wifi.internet === Network.Internet.DISCONNECTED) {
                icon.label = "󰤭"
            } else if (strength > 75) {
                icon.label = "󰤨"
            } else if (strength > 50) {
                icon.label = "󰤥"
            } else if (strength > 25) {
                icon.label = "󰤢"
            } else {
                icon.label = "󰤟"
            }
        } else if (wired && wired.internet === Network.Internet.CONNECTED) {
            icon.label = "󰈁"
        } else {
            icon.label = "󰤮"
        }
    }

    // Click to open network settings
    const click = new Gtk.GestureClick({ button: Gdk.BUTTON_PRIMARY })
    click.connect("pressed", () => {
        GLib.spawn_command_line_async("systemsettings kcm_networkmanagement")
    })
    box.add_controller(click)

    update()

    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 2000, () => {
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

function Clock() {
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

function Workspaces() {
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

function ActiveWindow() {
    const label = new Gtk.Label()
    label.add_css_class("active-window")

    const formatAppName = (className: string): string => {
        // Handle reverse-domain names (org.wezfurlong.wezterm -> wezterm)
        if (className.includes(".")) {
            const parts = className.split(".")
            return parts[parts.length - 1]
        }
        return className
    }

    const update = () => {
        const client = hypr.focused_client
        if (client && client.class) {
            label.label = formatAppName(client.class)
            label.visible = true
        } else {
            label.visible = false
        }
    }

    update()

    hypr.connect("notify::focused-client", update)

    return label
}

export default function Bar(monitor: number) {
    const anchor = Astal.WindowAnchor.TOP
        | Astal.WindowAnchor.LEFT
        | Astal.WindowAnchor.RIGHT

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
                <ActiveWindow />
                <box hexpand />
                <SystemTray />
                <BluetoothWidget />
                <NetworkWidget />
                <Microphone />
                <Volume />
                <BatteryWidget />
                <button
                    cssClasses={["notification-btn"]}
                    onClicked={() => GLib.spawn_command_line_async("swaync-client -t")}
                >
                    <label cssClasses={["notification-icon"]} label="󰂚" />
                </button>
                <Clock />
            </box>
        </window>
    )
}
