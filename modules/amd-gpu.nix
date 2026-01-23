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
    KERNEL=="card1", SUBSYSTEM=="drm", DRIVERS=="amdgpu", ATTR{device/power_dpm_force_performance_level}="high"
  '';

  # Re-apply power settings after resume from suspend/hibernation
  # Toggle to "auto" first to force driver to re-apply "high" state
  powerManagement.resumeCommands = ''
    sleep 1
    echo auto > /sys/class/drm/card1/device/power_dpm_force_performance_level
    sleep 0.5
    echo high > /sys/class/drm/card1/device/power_dpm_force_performance_level
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
