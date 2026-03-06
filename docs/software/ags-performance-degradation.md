# AGS Desktop Shell - Progressive Performance Degradation

**Status**: SOLVED
**Date Documented**: 2026-03-06
**Affected System**: NixOS Desktop

---

## Problem

AGS becomes progressively slower the longer the system has been running. Actions that should be instant (opening the quick settings panel, launcher, or calendar) take 7+ seconds after several hours of uptime.

## Root Cause

Multiple `GLib.timeout_add()` polling loops were running continuously in the background, even when no AGS windows were visible. The worst offenders:

| Timer | Interval | What it did |
|-------|----------|-------------|
| QuickSettings vol/mic | 300ms | Update volume/mic labels |
| QuickSettings network/wifi/bt | 2000ms | **Rebuild ~50 GTK widgets from scratch** |
| QuickSettings eth + VPN | 5000ms | **Spawn `nmcli` bash subprocesses** |
| QuickSettings wifi scan | 10000ms | Trigger full WiFi scan |
| QuickSettings bar button | 1000ms | Redundant icon poll |
| Volume bar widget | 200ms | Poll WirePlumber |
| Microphone bar widget | 200ms | Poll WirePlumber |
| Network bar widget | 2000ms | Poll NetworkManager |
| Battery bar widget | 5000ms | Poll AstalBattery |

Two specific issues compound over time:

1. **Subprocess accumulation**: `updateEth()` and `updateVpnList()` each spawn a `bash -c "nmcli ..."` process every 5 seconds with no concurrency guard. If a call takes longer than 5 seconds (due to D-Bus congestion), subsequent calls stack up. Over hours, this fills the GLib event queue with pending async I/O callbacks.

2. **WiFi widget churn**: `updateWifiList()` was called every 2 seconds. Each call removes all children from the wifi list and creates ~50 new GTK widgets (buttons, labels, event listeners) for up to 10 access points — regardless of whether the QuickSettings panel was visible.

## Solution

Two-part fix in `ags/widget/bar/`:

### 1. QuickSettings window: gate all polling on window visibility

All four QuickSettings timers are now started only when the window opens and explicitly removed via `GLib.source_remove()` when it closes:

```typescript
let pollingTimers: number[] = []

const startPolling = () => {
    // Fresh state when opened
    updateVol(); updateMic(); updateNetRow(); updateWifi()
    updateWifiList(); updateEth(); updateBt(); updateVpnList()
    if (wifi) wifi.scan()
    pollingTimers.push(GLib.timeout_add(GLib.PRIORITY_DEFAULT, 300,   () => { updateVol(); updateMic(); return true }))
    pollingTimers.push(GLib.timeout_add(GLib.PRIORITY_DEFAULT, 2000,  () => { updateNetRow(); updateWifi(); updateWifiList(); updateBt(); return true }))
    pollingTimers.push(GLib.timeout_add(GLib.PRIORITY_DEFAULT, 5000,  () => { updateEth(); updateVpnList(); return true }))
    pollingTimers.push(GLib.timeout_add(GLib.PRIORITY_DEFAULT, 10000, () => { if (wifi && wifi.enabled) wifi.scan(); return true }))
}

const stopPolling = () => {
    pollingTimers.forEach(id => GLib.source_remove(id))
    pollingTimers = []
}

app.connect("window-toggled", (_, w) => {
    if (w.name !== "quicksettings") return
    if (w.visible) { startPolling() } else { stopPolling() }
})
```

### 2. Bar widgets: replace polling with GObject property signals

Instead of timers, connect to `notify::` signals on the underlying service objects. Updates are now instant and zero-cost when idle.

**Volume / Microphone** (`Volume.tsx`, `Microphone.tsx`):
```typescript
const connectSpeaker = () => {
    const speaker = wp.audio?.defaultSpeaker
    if (speaker) {
        speaker.connect("notify::volume", update)
        speaker.connect("notify::mute", update)
    }
    update()
}
connectSpeaker()
wp.audio?.connect("notify::default-speaker", connectSpeaker)
```

**Network** (`Network.tsx`):
```typescript
if (wifi) {
    wifi.connect("notify::ssid", update)
    wifi.connect("notify::strength", update)
    wifi.connect("notify::internet", update)
    wifi.connect("notify::enabled", update)
}
if (wired) {
    wired.connect("notify::internet", update)
}
```

**Battery** (`Battery.tsx`):
```typescript
if (battery) {
    battery.connect("notify::percentage", update)
    battery.connect("notify::charging", update)
    battery.connect("notify::is-present", update)
}
```

**QuickSettings bar button** (`QuickSettings.tsx`): same signal pattern for vol/net icons, removing the 1000ms poll.

## Notes

- The QuickSettings panel is typically open for < 30 seconds at a time, so moving its timers behind a visibility gate eliminates ~99% of the background work
- GObject signal-based updates are strictly better than polling: zero overhead when idle, instant response when state changes
- The WiFi list and subprocess spawning (`nmcli`) still poll while the panel is open — this is acceptable since the user is actively looking at that data
- Restarting AGS (`pkill gjs; ags run -g 4`) clears all accumulated state and is an effective temporary workaround

## Related Files

- `ags/widget/bar/QuickSettings.tsx` — window polling gates + bar button signals
- `ags/widget/bar/Volume.tsx` — WirePlumber signals
- `ags/widget/bar/Microphone.tsx` — WirePlumber signals
- `ags/widget/bar/Network.tsx` — AstalNetwork signals
- `ags/widget/bar/Battery.tsx` — AstalBattery signals
