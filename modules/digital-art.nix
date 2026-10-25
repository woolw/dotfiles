{ pkgs, ... }:

{
  # XP-Pen tablet support (Deco Pro LW Gen 2, MT1172B and others)
  hardware.opentabletdriver.enable = true;
  hardware.opentabletdriver.daemon.enable = true;

  # Digital art applications
  environment.systemPackages = with pkgs; [
    krita
    gimp
    inkscape
    mypaint
  ];
}
