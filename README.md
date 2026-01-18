# Dotfiles

Personal Nix configurations with flakes and Home Manager.

## Platforms

- **NixOS** (Linux) - Full system configuration
- **nix-darwin** (macOS) - Coming soon

## Features

- Flake-based configuration
- Home Manager for user-level configs
- Cross-platform shell, editor, and terminal configs
- **One Dark Pro** theme

## Quick Start

### NixOS

```bash
git clone https://github.com/woolw/dotfiles ~/dotfiles
cd ~/dotfiles
sudo nixos-rebuild switch --flake .#nixos
```

### macOS (future)

```bash
darwin-rebuild switch --flake ~/dotfiles#darwin
```

## Structure

```
├── flake.nix                 # Main flake configuration
├── hosts/                    # Platform-specific system configs
│   ├── nixos/                # NixOS configuration
│   └── darwin/               # macOS configuration (planned)
├── modules/                  # NixOS modules
├── home/                     # Home Manager configs
│
├── wezterm/                  # Terminal (cross-platform)
├── helix/                    # Editor (cross-platform)
├── zsh/                      # Shell (cross-platform)
│
├── hypr/                     # Hyprland (Linux only)
├── waybar/                   # Status bar (Linux only)
├── swaync/                   # Notifications (Linux only)
└── fuzzel/                   # App launcher (Linux only)
```

## Shell Aliases

```bash
rebuild    # Rebuild and switch (works on both platforms)
update     # Update flake inputs and rebuild
```

## License

MIT
