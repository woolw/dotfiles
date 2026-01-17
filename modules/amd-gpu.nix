{ config, lib, pkgs, ... }:

{
  # AMD GPU Power Management Fix
  services.udev.extraRules = ''
    KERNEL=="card1", SUBSYSTEM=="drm", DRIVERS=="amdgpu", ATTR{device/power_dpm_force_performance_level}="high"
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