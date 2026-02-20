{
  config,
  lib,
  pkgs,
  ...
}:

{
  # AMD GPU Power Management Fix
  # Udev rule applies on boot when device is detected
  services.udev.extraRules = ''
    KERNEL=="card[0-9]*", SUBSYSTEM=="drm", DRIVERS=="amdgpu", ATTR{device/power_dpm_force_performance_level}="high"
  '';

  # Re-apply power settings after resume from suspend/hibernation
  # Toggle to "auto" first to force driver to re-apply "high" state
  # Uses glob to handle card number changing between boots
  powerManagement.resumeCommands = ''
    sleep 1
    for card in /sys/class/drm/card*/device; do
      if [ -d "$card/driver/module/drivers/pci:amdgpu" ]; then
        echo auto > "$card/power_dpm_force_performance_level"
        sleep 0.5
        echo high > "$card/power_dpm_force_performance_level"
      fi
    done
  '';

  # Optional: Additional AMD GPU optimizations
  boot.kernelParams = [
    # Uncomment if needed for better performance
    # "amdgpu.ppfeaturemask=0xffffffff"
  ];

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
