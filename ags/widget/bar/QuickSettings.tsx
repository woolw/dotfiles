import { Astal, Gtk, Gdk } from "ags/gtk4"
import app from "ags/gtk4/app"
import GLib from "gi://GLib"
import Wp from "gi://AstalWp"
import AstalBluetooth from "gi://AstalBluetooth"
import AstalNetwork from "gi://AstalNetwork"
import Tray from "gi://AstalTray"

const wp = Wp.get_default()!
const bluetooth = AstalBluetooth.get_default()
const network = AstalNetwork.get_default()
const tray = Tray.get_default()

function getStrengthIcon(strength: number): string {
    if (strength > 75) return "󰤨"
    if (strength > 50) return "󰤥"
    if (strength > 25) return "󰤢"
    return "󰤟"
}

function getNetworkIcon(): string {
    const wifi = network.wifi
    const wired = network.wired
    if (wifi && wifi.enabled && wifi.ssid) {
        return getStrengthIcon(wifi.strength)
    } else if (wired && wired.internet === AstalNetwork.Internet.CONNECTED) {
        return "󰈁"
    } else if (wifi && !wifi.enabled) {
        return "󰤭"
    }
    return "󰤮"
}

function getNetworkStatus(): string {
    const wifi = network.wifi
    const wired = network.wired
    if (wifi && wifi.enabled && wifi.ssid) {
        return wifi.ssid
    } else if (wired && wired.internet === AstalNetwork.Internet.CONNECTED) {
        return "Ethernet"
    } else if (wifi && !wifi.enabled) {
        return "Wi-Fi Off"
    }
    return "Not connected"
}

// Shared state for bar icon updates
let barVolIcon: Gtk.Label | null = null
let barNetIcon: Gtk.Label | null = null

// Create the popup window (called from app.ts)
export function QuickSettingsWindow() {
    const stack = new Gtk.Stack()
    stack.set_transition_type(Gtk.StackTransitionType.SLIDE_LEFT_RIGHT)
    stack.set_transition_duration(200)

    // ========== MAIN PAGE ==========
    const mainPage = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 8 })
    mainPage.add_css_class("qs-content")

    // Volume slider
    const volRow = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, spacing: 12 })
    volRow.add_css_class("qs-row")
    const volBtn = new Gtk.Button()
    volBtn.add_css_class("qs-icon-btn")
    const volBtnIcon = new Gtk.Label({ label: "󰕾" })
    volBtnIcon.add_css_class("qs-icon")
    volBtn.set_child(volBtnIcon)
    const volSlider = new Gtk.Scale({ orientation: Gtk.Orientation.HORIZONTAL, hexpand: true, draw_value: false })
    volSlider.set_range(0, 100)
    volSlider.add_css_class("qs-slider")
    volRow.append(volBtn)
    volRow.append(volSlider)
    mainPage.append(volRow)

    // Mic slider
    const micRow = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, spacing: 12 })
    micRow.add_css_class("qs-row")
    const micBtn = new Gtk.Button()
    micBtn.add_css_class("qs-icon-btn")
    const micBtnIcon = new Gtk.Label({ label: "󰍬" })
    micBtnIcon.add_css_class("qs-icon")
    micBtn.set_child(micBtnIcon)
    const micSlider = new Gtk.Scale({ orientation: Gtk.Orientation.HORIZONTAL, hexpand: true, draw_value: false })
    micSlider.set_range(0, 100)
    micSlider.add_css_class("qs-slider")
    micRow.append(micBtn)
    micRow.append(micSlider)
    mainPage.append(micRow)

    const sep1 = new Gtk.Separator({ orientation: Gtk.Orientation.HORIZONTAL })
    sep1.add_css_class("qs-separator")
    mainPage.append(sep1)

    // Network row (click to go to network page)
    const netRow = new Gtk.Button()
    netRow.add_css_class("qs-row")
    netRow.add_css_class("qs-btn")
    const netRowBox = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, spacing: 12 })
    const netRowIcon = new Gtk.Label({ label: getNetworkIcon() })
    netRowIcon.add_css_class("qs-icon")
    const netRowLabels = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, hexpand: true })
    const netRowTitle = new Gtk.Label({ label: "Network", xalign: 0 })
    netRowTitle.add_css_class("qs-title")
    const netRowSubtitle = new Gtk.Label({ label: getNetworkStatus(), xalign: 0 })
    netRowSubtitle.add_css_class("qs-subtitle")
    netRowLabels.append(netRowTitle)
    netRowLabels.append(netRowSubtitle)
    const netRowArrow = new Gtk.Label({ label: "󰅂" })
    netRowArrow.add_css_class("qs-arrow")
    netRowBox.append(netRowIcon)
    netRowBox.append(netRowLabels)
    netRowBox.append(netRowArrow)
    netRow.set_child(netRowBox)
    mainPage.append(netRow)

    // Bluetooth row
    const btRow = new Gtk.Button()
    btRow.add_css_class("qs-row")
    btRow.add_css_class("qs-btn")
    const btRowBox = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, spacing: 12 })
    const btRowIcon = new Gtk.Label({ label: "󰂯" })
    btRowIcon.add_css_class("qs-icon")
    const btRowLabels = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, hexpand: true })
    const btRowTitle = new Gtk.Label({ label: "Bluetooth", xalign: 0 })
    btRowTitle.add_css_class("qs-title")
    const btRowSubtitle = new Gtk.Label({ label: "On", xalign: 0 })
    btRowSubtitle.add_css_class("qs-subtitle")
    btRowLabels.append(btRowTitle)
    btRowLabels.append(btRowSubtitle)
    const btRowArrow = new Gtk.Label({ label: "󰅂" })
    btRowArrow.add_css_class("qs-arrow")
    btRowBox.append(btRowIcon)
    btRowBox.append(btRowLabels)
    btRowBox.append(btRowArrow)
    btRow.set_child(btRowBox)
    mainPage.append(btRow)

    const sep2 = new Gtk.Separator({ orientation: Gtk.Orientation.HORIZONTAL })
    sep2.add_css_class("qs-separator")
    mainPage.append(sep2)

    // System tray
    const trayBox = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, spacing: 4 })
    trayBox.add_css_class("qs-tray")
    trayBox.set_halign(Gtk.Align.CENTER)
    const trayItems = new Map<string, Gtk.Widget>()

    const addTrayItem = (item: Tray.TrayItem) => {
        const trayBtn = new Gtk.MenuButton()
        trayBtn.add_css_class("qs-tray-item")
        const trayIcon = new Gtk.Image()
        trayIcon.add_css_class("qs-tray-icon")
        if (item.gicon) trayIcon.set_from_gicon(item.gicon)
        else if (item.iconName) trayIcon.iconName = item.iconName
        trayBtn.set_child(trayIcon)
        const trayPopover = Gtk.PopoverMenu.new_from_model(item.menuModel)
        trayPopover.set_has_arrow(false)
        trayPopover.set_cascade_popdown(true)
        trayBtn.set_popover(trayPopover)
        if (item.actionGroup) trayPopover.insert_action_group("dbusmenu", item.actionGroup)
        item.connect("notify::menu-model", () => trayPopover.set_menu_model(item.menuModel))
        item.connect("notify::action-group", () => {
            if (item.actionGroup) trayPopover.insert_action_group("dbusmenu", item.actionGroup)
        })
        item.connect("notify::gicon", () => { if (item.gicon) trayIcon.set_from_gicon(item.gicon) })
        item.connect("notify::icon-name", () => { if (item.iconName) trayIcon.iconName = item.iconName })
        trayItems.set(item.itemId, trayBtn)
        trayBox.append(trayBtn)
    }

    tray.get_items().forEach(addTrayItem)
    tray.connect("item-added", (_t, id: string) => { const item = tray.get_item(id); if (item) addTrayItem(item) })
    tray.connect("item-removed", (_t, id: string) => {
        const w = trayItems.get(id)
        if (w) { trayBox.remove(w); trayItems.delete(id) }
    })
    mainPage.append(trayBox)

    stack.add_named(mainPage, "main")

    // ========== NETWORK PAGE ==========
    const netPage = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 8 })
    netPage.add_css_class("qs-content")

    // Header with back button
    const netHeader = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, spacing: 8 })
    netHeader.add_css_class("qs-page-header")
    const backBtn = new Gtk.Button()
    backBtn.add_css_class("qs-back-btn")
    const backIcon = new Gtk.Label({ label: "󰅁" })
    backIcon.add_css_class("qs-icon")
    backBtn.set_child(backIcon)
    const netPageTitle = new Gtk.Label({ label: "Network", xalign: 0, hexpand: true })
    netPageTitle.add_css_class("qs-page-title")
    netHeader.append(backBtn)
    netHeader.append(netPageTitle)
    netPage.append(netHeader)

    const netSep1 = new Gtk.Separator({ orientation: Gtk.Orientation.HORIZONTAL })
    netSep1.add_css_class("qs-separator")
    netPage.append(netSep1)

    // WiFi section
    const wifiSection = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 4 })

    const wifiHeader = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, spacing: 12 })
    wifiHeader.add_css_class("qs-row")
    const wifiIcon = new Gtk.Label({ label: "󰤨" })
    wifiIcon.add_css_class("qs-icon")
    const wifiLabel = new Gtk.Label({ label: "Wi-Fi", xalign: 0, hexpand: true })
    wifiLabel.add_css_class("qs-title")
    const wifiToggle = new Gtk.Switch()
    wifiToggle.set_valign(Gtk.Align.CENTER)
    wifiHeader.append(wifiIcon)
    wifiHeader.append(wifiLabel)
    wifiHeader.append(wifiToggle)
    wifiSection.append(wifiHeader)

    // WiFi list
    const wifiScroll = new Gtk.ScrolledWindow({
        hscrollbar_policy: Gtk.PolicyType.NEVER,
        vscrollbar_policy: Gtk.PolicyType.AUTOMATIC,
        max_content_height: 180,
        propagate_natural_height: true,
    })
    wifiScroll.add_css_class("qs-network-list-scroll")
    const wifiList = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 2 })
    wifiList.add_css_class("qs-network-list")
    wifiScroll.set_child(wifiList)
    wifiSection.append(wifiScroll)

    // Password dialog (hidden)
    const pwdBox = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 8 })
    pwdBox.add_css_class("qs-password-box")
    pwdBox.visible = false
    const pwdLabel = new Gtk.Label({ label: "Enter password", xalign: 0 })
    pwdLabel.add_css_class("qs-password-label")
    const pwdEntry = new Gtk.PasswordEntry({ show_peek_icon: true, hexpand: true })
    pwdEntry.add_css_class("qs-password-entry")
    const pwdBtns = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, spacing: 8 })
    pwdBtns.set_halign(Gtk.Align.END)
    const pwdCancel = new Gtk.Button({ label: "Cancel" })
    pwdCancel.add_css_class("qs-password-btn")
    const pwdConnect = new Gtk.Button({ label: "Connect" })
    pwdConnect.add_css_class("qs-password-btn")
    pwdConnect.add_css_class("suggested-action")
    pwdBtns.append(pwdCancel)
    pwdBtns.append(pwdConnect)
    pwdBox.append(pwdLabel)
    pwdBox.append(pwdEntry)
    pwdBox.append(pwdBtns)
    wifiSection.append(pwdBox)

    netPage.append(wifiSection)

    const netSep2 = new Gtk.Separator({ orientation: Gtk.Orientation.HORIZONTAL })
    netSep2.add_css_class("qs-separator")
    netPage.append(netSep2)

    // Ethernet section
    const ethSection = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 4 })
    const ethHeader = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, spacing: 12 })
    ethHeader.add_css_class("qs-row")
    const ethIcon = new Gtk.Label({ label: "󰈁" })
    ethIcon.add_css_class("qs-icon")
    const ethLabel = new Gtk.Label({ label: "Ethernet", xalign: 0, hexpand: true })
    ethLabel.add_css_class("qs-title")
    const ethToggle = new Gtk.Switch()
    ethToggle.set_valign(Gtk.Align.CENTER)
    ethHeader.append(ethIcon)
    ethHeader.append(ethLabel)
    ethHeader.append(ethToggle)
    ethSection.append(ethHeader)
    const ethSubtitle = new Gtk.Label({ label: "Not connected", xalign: 0 })
    ethSubtitle.add_css_class("qs-subtitle")
    ethSubtitle.set_margin_start(36)
    ethSection.append(ethSubtitle)
    netPage.append(ethSection)

    const netSep3 = new Gtk.Separator({ orientation: Gtk.Orientation.HORIZONTAL })
    netSep3.add_css_class("qs-separator")
    netPage.append(netSep3)

    // VPN section
    const vpnSection = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 4 })
    const vpnHeader = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, spacing: 12 })
    vpnHeader.add_css_class("qs-row")
    const vpnIcon = new Gtk.Label({ label: "󰖂" })
    vpnIcon.add_css_class("qs-icon")
    const vpnLabel = new Gtk.Label({ label: "VPN", xalign: 0, hexpand: true })
    vpnLabel.add_css_class("qs-title")
    vpnHeader.append(vpnIcon)
    vpnHeader.append(vpnLabel)
    vpnSection.append(vpnHeader)

    // VPN list
    const vpnList = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 2 })
    vpnList.add_css_class("qs-network-list")
    vpnSection.append(vpnList)

    // Add VPN button
    const addVpnBtn = new Gtk.Button()
    addVpnBtn.add_css_class("qs-network-item")
    const addVpnBox = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, spacing: 8 })
    const addVpnIcon = new Gtk.Label({ label: "󰐕" })
    addVpnIcon.add_css_class("qs-network-item-icon")
    const addVpnLabel = new Gtk.Label({ label: "Add VPN...", xalign: 0, hexpand: true })
    addVpnLabel.add_css_class("qs-network-item-name")
    addVpnBox.append(addVpnIcon)
    addVpnBox.append(addVpnLabel)
    addVpnBtn.set_child(addVpnBox)
    vpnSection.append(addVpnBtn)

    netPage.append(vpnSection)

    stack.add_named(netPage, "network")

    // ========== WINDOW SETUP ==========
    // Panel that contains the actual content
    const panel = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL })
    panel.add_css_class("qs-popover")
    panel.append(stack)

    // Overlay to position panel at top-right
    const overlay = new Gtk.Overlay()

    // Transparent backdrop that catches clicks
    const backdrop = new Gtk.Button()
    backdrop.add_css_class("qs-backdrop")
    backdrop.set_hexpand(true)
    backdrop.set_vexpand(true)
    overlay.set_child(backdrop)

    // Position the panel
    panel.set_halign(Gtk.Align.END)
    panel.set_valign(Gtk.Align.START)
    panel.set_margin_top(4) // Just below the bar
    panel.set_margin_end(8)
    overlay.add_overlay(panel)

    const win = (
        <window
            name="quicksettings"
            cssClasses={["QuickSettings"]}
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
    backdrop.connect("clicked", () => app.toggle_window("quicksettings"))

    // Close on ESC
    const keyController = new Gtk.EventControllerKey()
    keyController.connect("key-pressed", (_: Gtk.EventControllerKey, keyval: number) => {
        if (keyval === Gdk.KEY_Escape) {
            app.toggle_window("quicksettings")
            return true
        }
        return false
    })
    win.add_controller(keyController)

    // Reset to main page when window closes
    app.connect("window-toggled", (_, w) => {
        if (w.name === "quicksettings" && !w.visible) {
            stack.set_visible_child_name("main")
            pwdBox.visible = false
            wifiScroll.visible = true
        }
    })

    // ========== LOGIC ==========
    let selectedAp: AstalNetwork.AccessPoint | null = null
    const wifi = network.wifi
    const wired = network.wired

    // Navigation
    netRow.connect("clicked", () => {
        stack.set_visible_child_name("network")
        if (wifi) wifi.scan()
    })
    backBtn.connect("clicked", () => stack.set_visible_child_name("main"))

    // Volume
    const updateVol = () => {
        const speaker = wp.audio?.defaultSpeaker
        if (!speaker) return
        const muted = speaker.mute
        const vol = speaker.volume
        volBtnIcon.label = muted || vol === 0 ? "󰖁" : vol < 0.33 ? "󰕿" : vol < 0.66 ? "󰖀" : "󰕾"
        volSlider.set_value(Math.round(vol * 100))
        if (barVolIcon) barVolIcon.label = volBtnIcon.label
        muted ? volBtn.add_css_class("muted") : volBtn.remove_css_class("muted")
    }
    volBtn.connect("clicked", () => { const s = wp.audio?.defaultSpeaker; if (s) s.mute = !s.mute })
    volSlider.connect("value-changed", () => { const s = wp.audio?.defaultSpeaker; if (s) s.volume = volSlider.get_value() / 100 })

    // Mic
    const updateMic = () => {
        const mic = wp.audio?.defaultMicrophone
        if (!mic) return
        const muted = mic.mute
        micBtnIcon.label = muted ? "󰍭" : "󰍬"
        micSlider.set_value(Math.round(mic.volume * 100))
        muted ? micBtn.add_css_class("muted") : micBtn.remove_css_class("muted")
    }
    micBtn.connect("clicked", () => { const m = wp.audio?.defaultMicrophone; if (m) m.mute = !m.mute })
    micSlider.connect("value-changed", () => { const m = wp.audio?.defaultMicrophone; if (m) m.volume = micSlider.get_value() / 100 })

    // Network main row
    const updateNetRow = () => {
        netRowIcon.label = getNetworkIcon()
        netRowSubtitle.label = getNetworkStatus()
        if (barNetIcon) barNetIcon.label = getNetworkIcon()
    }

    // WiFi toggle and list
    const updateWifi = () => {
        if (!wifi) return
        wifiToggle.active = wifi.enabled
        wifiIcon.label = wifi.enabled ? (wifi.ssid ? getStrengthIcon(wifi.strength) : "󰤯") : "󰤭"
        wifiScroll.visible = wifi.enabled && !pwdBox.visible
    }
    wifiToggle.connect("notify::active", () => { if (wifi) wifi.enabled = wifiToggle.active })

    const updateWifiList = () => {
        let child = wifiList.get_first_child()
        while (child) { const next = child.get_next_sibling(); wifiList.remove(child); child = next }
        if (!wifi || !wifi.enabled) return

        const aps = wifi.get_access_points().filter(ap => ap.ssid && ap.ssid.length > 0).sort((a, b) => b.strength - a.strength)
        const seen = new Set<string>()
        aps.filter(ap => { if (seen.has(ap.ssid)) return false; seen.add(ap.ssid); return true }).slice(0, 10).forEach(ap => {
            const row = new Gtk.Button()
            row.add_css_class("qs-network-item")
            const box = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, spacing: 8 })
            const icon = new Gtk.Label({ label: getStrengthIcon(ap.strength) })
            icon.add_css_class("qs-network-item-icon")
            const name = new Gtk.Label({ label: ap.ssid, xalign: 0, hexpand: true })
            name.add_css_class("qs-network-item-name")
            box.append(icon)
            box.append(name)
            const secured = ap.flags !== 0 || ap.wpaFlags !== 0 || ap.rsnFlags !== 0
            if (secured) {
                const lock = new Gtk.Label({ label: "󰌾" })
                lock.add_css_class("qs-network-item-lock")
                box.append(lock)
            }
            if (wifi.ssid === ap.ssid) {
                const check = new Gtk.Label({ label: "󰄬" })
                check.add_css_class("qs-network-item-connected")
                box.append(check)
                row.add_css_class("connected")
            }
            row.set_child(box)
            row.connect("clicked", () => {
                if (wifi.ssid === ap.ssid) {
                    GLib.spawn_command_line_async("nmcli device disconnect wlan0")
                } else if (secured) {
                    selectedAp = ap
                    pwdLabel.label = `Password for "${ap.ssid}"`
                    pwdEntry.set_text("")
                    pwdBox.visible = true
                    wifiScroll.visible = false
                    pwdEntry.grab_focus()
                } else {
                    GLib.spawn_command_line_async(`nmcli device wifi connect "${ap.ssid}"`)
                }
            })
            wifiList.append(row)
        })
    }

    pwdCancel.connect("clicked", () => { pwdBox.visible = false; wifiScroll.visible = true; selectedAp = null })
    pwdConnect.connect("clicked", () => {
        if (selectedAp && wifi) {
            GLib.spawn_command_line_async(`nmcli device wifi connect "${selectedAp.ssid}" password "${pwdEntry.get_text()}"`)
            pwdBox.visible = false
            wifiScroll.visible = true
            selectedAp = null
        }
    })
    pwdEntry.connect("activate", () => pwdConnect.emit("clicked"))

    // Ethernet toggle and status
    const updateEth = () => {
        if (wired) {
            const connected = wired.internet === AstalNetwork.Internet.CONNECTED
            ethIcon.label = connected ? "󰈁" : "󰈂"
            ethSubtitle.label = connected ? "Connected" : "Not connected"
            // Check if ethernet device is enabled via nmcli
            try {
                const [ok, out] = GLib.spawn_command_line_sync("nmcli -t -f DEVICE,STATE device")
                if (ok) {
                    const output = new TextDecoder().decode(out)
                    const ethLine = output.split('\n').find(l => l.startsWith('eth') || l.startsWith('enp'))
                    ethToggle.active = ethLine ? !ethLine.includes('disconnected') && !ethLine.includes('unavailable') : false
                }
            } catch (e) {
                ethToggle.active = connected
            }
        } else {
            ethIcon.label = "󰈂"
            ethSubtitle.label = "Not available"
            ethToggle.active = false
            ethToggle.sensitive = false
        }
    }
    ethToggle.connect("notify::active", () => {
        if (ethToggle.active) {
            GLib.spawn_command_line_async("nmcli device connect enp5s0")
        } else {
            GLib.spawn_command_line_async("nmcli device disconnect enp5s0")
        }
    })

    // VPN list management
    const updateVpnList = () => {
        let child = vpnList.get_first_child()
        while (child) { const next = child.get_next_sibling(); vpnList.remove(child); child = next }

        try {
            const [ok, out] = GLib.spawn_command_line_sync("nmcli -t -f NAME,TYPE,STATE connection show")
            if (ok) {
                const output = new TextDecoder().decode(out)
                const vpns = output.split('\n')
                    .filter(l => l.includes(':vpn:') || l.includes(':wireguard:'))
                    .map(l => {
                        const [name, type, state] = l.split(':')
                        return { name, type, active: state === 'activated' }
                    })

                vpns.forEach(vpn => {
                    const row = new Gtk.Button()
                    row.add_css_class("qs-network-item")
                    if (vpn.active) row.add_css_class("connected")
                    const box = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, spacing: 8 })
                    const icon = new Gtk.Label({ label: vpn.type === 'wireguard' ? "󰖂" : "󰦝" })
                    icon.add_css_class("qs-network-item-icon")
                    const name = new Gtk.Label({ label: vpn.name, xalign: 0, hexpand: true })
                    name.add_css_class("qs-network-item-name")
                    box.append(icon)
                    box.append(name)
                    if (vpn.active) {
                        const check = new Gtk.Label({ label: "󰄬" })
                        check.add_css_class("qs-network-item-connected")
                        box.append(check)
                    }
                    row.set_child(box)
                    row.connect("clicked", () => {
                        if (vpn.active) {
                            GLib.spawn_command_line_async(`nmcli connection down "${vpn.name}"`)
                        } else {
                            GLib.spawn_command_line_async(`nmcli connection up "${vpn.name}"`)
                        }
                        GLib.timeout_add(GLib.PRIORITY_DEFAULT, 1000, () => { updateVpnList(); return false })
                    })
                    vpnList.append(row)
                })
            }
        } catch (e) { /* ignore */ }
    }

    addVpnBtn.connect("clicked", () => {
        app.toggle_window("quicksettings")
        GLib.spawn_command_line_async("systemsettings kcm_networkmanagement")
    })

    // Bluetooth
    const updateBt = () => {
        const adapter = bluetooth.adapter
        if (!adapter || !adapter.powered) {
            btRowIcon.label = "󰂲"
            btRowSubtitle.label = "Off"
            return
        }
        const connected = bluetooth.get_devices().filter(d => d.connected)
        btRowIcon.label = connected.length > 0 ? "󰂱" : "󰂯"
        btRowSubtitle.label = connected.length > 0 ? (connected[0].name || "Connected") : "On"
    }
    btRow.connect("clicked", () => {
        app.toggle_window("quicksettings")
        GLib.spawn_command_line_async("systemsettings kcm_bluetooth")
    })

    // Initial updates
    updateVol(); updateMic(); updateNetRow(); updateWifi(); updateWifiList(); updateEth(); updateBt(); updateVpnList()
    if (wifi) wifi.scan()

    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 300, () => { updateVol(); updateMic(); return true })
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 2000, () => { updateNetRow(); updateWifi(); updateWifiList(); updateEth(); updateBt(); updateVpnList(); return true })
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 10000, () => { if (wifi && wifi.enabled) wifi.scan(); return true })

    return win
}

// Bar button that toggles the window
export default function QuickSettings() {
    const btn = new Gtk.Button()
    btn.add_css_class("quick-settings")

    const btnBox = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, spacing: 12 })
    const volIcon = new Gtk.Label({ label: "󰕾" })
    volIcon.add_css_class("qs-bar-icon")
    const netIcon = new Gtk.Label({ label: "󰤨" })
    netIcon.add_css_class("qs-bar-icon")
    btnBox.append(volIcon)
    btnBox.append(netIcon)
    btn.set_child(btnBox)

    // Store references for updates from the window
    barVolIcon = volIcon
    barNetIcon = netIcon

    // Update bar icons periodically
    const updateBarIcons = () => {
        const speaker = wp.audio?.defaultSpeaker
        if (speaker) {
            const muted = speaker.mute
            const vol = speaker.volume
            volIcon.label = muted || vol === 0 ? "󰖁" : vol < 0.33 ? "󰕿" : vol < 0.66 ? "󰖀" : "󰕾"
        }
        netIcon.label = getNetworkIcon()
    }
    updateBarIcons()
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 1000, () => { updateBarIcons(); return true })

    btn.connect("clicked", () => app.toggle_window("quicksettings"))

    return btn
}
