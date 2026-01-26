import { Astal, Gtk } from "ags/gtk4"
import app from "ags/gtk4/app"
import GLib from "gi://GLib"

import Volume from "./Volume"
import Microphone from "./Microphone"
import Battery from "./Battery"
import Bluetooth from "./Bluetooth"
import Network from "./Network"
import SystemTray from "./SystemTray"
import Clock from "./Clock"
import Workspaces from "./Workspaces"
import ActiveWindow from "./ActiveWindow"

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
                <Bluetooth />
                <Network />
                <Microphone />
                <Volume />
                <Battery />
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
