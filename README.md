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
- AGS desktop shell (macOS-inspired)

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
│   ├── shared/               # Cross-platform (git, ssh, zsh, nvim, wezterm)
│   └── woolw/                # NixOS-specific (AGS, GTK, Qt)
│
├── nvim/                     # Neovim (cross-platform, lazy.nvim)
├── wezterm/                  # Terminal (cross-platform)
├── zsh/                      # Shell (cross-platform)
│
├── ags/                      # AGS desktop shell (Linux only)
├── hypr/                     # Hyprland (Linux only)
└── swaync/                   # Notifications (Linux only)
```

## Shell Aliases

```bash
nix-rebuild  # Rebuild and switch (works on both platforms)
nix-update   # Update flake inputs and rebuild
nix-gc       # Garbage collect
v            # Open nvim
```

## License

MIT
