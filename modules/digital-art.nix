{
  config,
  lib,
  pkgs,
  ...
}:

{
  # XP-Pen tablet support (MT1172B and others)
  hardware.opentabletdriver.enable = true;

  # Digital art applications
  environment.systemPackages = with pkgs; [
    krita
    gimp
    inkscape
    mypaint
  ];
}
