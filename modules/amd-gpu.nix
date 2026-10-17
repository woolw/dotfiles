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

  # Pin MSI MAG321UP EDID and force DP-1 connected
  # Monitor sits behind a KVM switch; switching away (or powering off / booting
  # with it off) drops DP hotplug, which makes KWin tear down the whole layout.
  # With a firmware EDID + forced-on connector the output never "disappears".
  # The EDID file is captured automatically by the nix-* zsh aliases when missing
  # (delete it to re-capture after a monitor swap); skipped entirely if absent.
  hardware.display = lib.mkIf (builtins.pathExists ./edid/mag321up.bin) {
    edid.packages = [
      (pkgs.runCommand "edid-mag321up" { } ''
        install -Dm644 ${./edid/mag321up.bin} $out/lib/firmware/edid/mag321up.bin
      '')
    ];
    outputs."DP-1" = {
      edid = "mag321up.bin";
      mode = "e";
    };
  };

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
