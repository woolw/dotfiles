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
    # ROCm build so Cycles can render on the RX 7900 XT via HIP
    pkgsRocm.blender
    material-maker # procedural PBR materials

    # Game asset pipeline (CLI, scriptable)
    imagemagick # resize/tile/convert/channel-pack textures
    f3d # render a model file to PNG for quick inspection
    assimp # mesh format conversion and info
    ktx-tools # KTX2/Basis texture compression
    oxipng # lossless PNG optimisation
  ];
}
