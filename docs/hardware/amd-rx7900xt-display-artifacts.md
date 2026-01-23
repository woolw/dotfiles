# AMD Radeon RX 7900 XT - Display Artifacts at High Refresh Rates

**Status**: SOLVED
**Date Documented**: 2026-01-17
**Last Updated**: 2026-01-19
**Affected System**: NixOS Desktop

---

## Problem

White rectangles appearing intermittently on screen at high refresh rates (120Hz+), with symptoms worsening significantly in fullscreen applications like video players and games.

## Root Cause

Aggressive power management in the amdgpu driver keeps memory clocks too low during idle/light load (96MHz), causing timing instabilities when transmitting high-bandwidth 4K@144Hz DisplayPort signals. The memory controller cannot ramp up clocks fast enough when content changes, resulting in visual corruption.

## Solution

Force high performance power state via udev rule and resume hook in `modules/amd-gpu.nix`:

```nix
# Udev rule applies on boot when device is detected
services.udev.extraRules = ''
  KERNEL=="card1", SUBSYSTEM=="drm", DRIVERS=="amdgpu",
  ATTR{device/power_dpm_force_performance_level}="high"
'';

# Re-apply after resume from suspend/hibernation
# Toggle to "auto" first to force driver to re-apply "high" state
powerManagement.resumeCommands = ''
  sleep 1
  echo auto > /sys/class/drm/card1/device/power_dpm_force_performance_level
  sleep 0.5
  echo high > /sys/class/drm/card1/device/power_dpm_force_performance_level
'';
```

### Why the resume hook?

The udev rule only triggers when the device is detected at boot. After hibernation/suspend resume, the driver's internal power state can desync from the sysfs value - even if it still reads "high", the driver may not be enforcing it. Toggling through "auto" forces the driver to re-apply the setting.

## Verification

```bash
# Should show "high" (not "auto")
cat /sys/class/drm/card1/device/power_dpm_force_performance_level

# Memory clock should be at state 3 (1249MHz) with asterisk
cat /sys/class/drm/card1/device/pp_dpm_mclk
```

**Expected output:**
```
0: 96Mhz
1: 408Mhz
2: 1000Mhz
3: 1249Mhz *
```

## Notes

- **DO NOT** use `amdgpu.ppfeaturemask` kernel parameter - the udev rule is sufficient and more targeted
- KVM switches can exacerbate signal integrity issues, but artifacts occur even with direct connection
- The fix works reliably through KVM switches once power management is corrected
- Issue is specific to high-bandwidth scenarios (4K@120Hz+, 1440p@240Hz+)
- At 60Hz the artifacts are less frequent but still present in fullscreen apps (like mpv)
- This is a driver power management issue, not a cable, monitor, or hardware defect

## Hardware Details

- **Device**: `0000:03:00.0` AMD Radeon RX 7900 XT (20GB VRAM, Navi 31)
- **Driver**: amdgpu (Mesa 25.2.6, LLVM 21.1.2, DRM 3.64)
- **Kernel**: 6.18.1 (linuxPackages_latest)
- **Monitor**: MSI MAG 321CUPDE (4K@144Hz via DisplayPort)
- **Connection**: DP-1 on card1

## Related Links

- NixOS Module: `modules/amd-gpu.nix`
- [AMDGPU Power Management Documentation](https://wiki.archlinux.org/title/AMDGPU#Power_management)
