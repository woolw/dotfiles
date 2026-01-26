import { Astal, Gtk } from "ags/gtk4"
import app from "ags/gtk4/app"
import GLib from "gi://GLib"

import Battery from "./Battery"
import Clock from "./Clock"
import Workspaces from "./Workspaces"
import ActiveWindow from "./ActiveWindow"
import QuickSettings from "./QuickSettings"

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
                <QuickSettings />
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
