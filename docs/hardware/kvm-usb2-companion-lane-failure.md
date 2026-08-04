# KVM Switch - USB 2.0 Companion Lane Silently Dies on One Port

**Status**: WORKAROUND
**Date Documented**: 2026-08-04
**Affected System**: NixOS Desktop

---

## Problem

All USB devices routed through the KVM switch (keyboard, mouse, webcam, audio
interface, serial adapters) stop working simultaneously. Display passthrough
via the same KVM is unaffected. The keyboard's LEDs flash briefly on connect
(power-on self-test) but the device never appears to the OS. Plugging the
same keyboard directly into the PC (bypassing the KVM) works fine.

## Root Cause

A USB 3.x hub — including the one inside the KVM switch — enumerates twice on
the host: once on the SuperSpeed bus, once on the separate Hi/Full/Low-Speed
"companion" bus, because SuperSpeed and USB 2.0 signals use physically
distinct pin pairs even within one USB-C connector. Keyboards, mice, webcams,
and most audio interfaces are not SuperSpeed devices, so they can only be
reached over the companion (USB 2.0) lane.

On this system, the companion lane for the KVM's motherboard port silently
died — the SuperSpeed personality of the same hub kept enumerating fine (and
a SuperSpeed-only device, a USB-Ethernet adapter on the same hub, kept
working), but the companion personality stopped appearing at all. The kernel
never logged an error: the xHCI controller (`0000:12:00.4`) initialized
identically and cleanly across every boot, including ones where the fault was
present. There was no over-current, AER, or resume/reinit event at the time
of failure — the host simply never saw an attach attempt on that lane.

Confirmed not software: no relevant NixOS/kernel config changed between the
last known-good session and the failure, kernel version was unaffected
either way, and the same cable in a different motherboard port worked
immediately. This points to a physical fault isolated to that one port's
USB 2.0 signal path (e.g. a cracked solder joint, or the per-port
ESD-protection/redriver IC that boards typically place inline on the D+/D-
pair, separate from the SuperSpeed path) — not the cable, not the KVM unit,
and not anything in this repo's configuration.

## Solution

No true fix — moved the KVM's upstream cable to a different USB port on the
motherboard. Same cable, different port, worked immediately.

## Verification

Compare the device tree under the KVM's hub across boots/attempts:

```bash
# List every USB device (and its parent hub port) seen this boot
journalctl -k -b 0 --no-pager | grep "New USB device found"

# Compare against a known-good boot (see indices from list-boots)
journalctl --list-boots
journalctl -k -b <good-boot-index> --no-pager | grep "New USB device found"
```

**Symptom signature**: the hub's SuperSpeed personality (e.g. `6-1`,
`idProduct` starting `08xx`/`0822`) is present, but its Hi-Speed/companion
personality (e.g. `5-1`, `idProduct` starting `28xx`/`2822`) — and everything
that would hang off it — is entirely absent. No corresponding kernel error is
logged; the port that died just goes quiet.

```bash
# Confirm the controller itself still inits cleanly (rules out driver/firmware fault)
journalctl -k -b 0 --no-pager | grep "0000:12:00.4"
```

## Notes

- A full cold shutdown (not just reboot) was tried first, in case it was a
  wedged xHCI companion-port state rather than a physical fault — did not
  help, which is further evidence this is a hardware failure and not
  something the OS can clear.
- Live-tested by watching `journalctl -k -f` while physically plugging the
  KVM's cable in/out — confirmed zero kernel activity at all while connected
  via the dead port, versus instant full enumeration when plugged directly
  into the PC.
- If this recurs on the replacement port, suspect the KVM unit itself rather
  than the motherboard.

## Hardware Details

- **Device**: `0000:12:00.4` (`1022:15b7`) — AMD xHCI USB controller, exposes
  bus 5 (Hi/Full/Low-Speed) and bus 6 (SuperSpeed) for the same physical
  ports
- **KVM hub chain**: VIA Labs hub (`2109:2822` USB2 / `2109:0822` USB3
  personality) at port `X-1`, with nested VIA/Terminus sub-hubs for each
  downstream device
- **Affected downstream devices**: ZSA Voyager keyboard (`3297:1977`),
  Razer device (`1532:00b0`), Focusrite audio interface (`1235:8210`),
  Logitech webcam (`046d:082d`), 2x WCH serial adapters (`1a86:e229`,
  `1a86:7523`)
- **Unaffected (SuperSpeed-only) device on the same hub**: Realtek
  USB-Ethernet adapter (`0bda:8153`)
- **Kernel**: 7.1.5 → 7.1.6 (issue present on both; kernel version not a
  factor)

## Related Links

- None — physical/hardware fault, no upstream bug applicable
