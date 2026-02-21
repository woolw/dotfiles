# Dotfiles

Personal Nix configurations with flakes and Home Manager.

## Platforms

- **NixOS** (Linux) - Full system configuration
- **nix-darwin** (macOS) - Apple Silicon (aarch64-darwin)

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

### macOS

```bash
git clone https://github.com/woolw/dotfiles ~/dotfiles

# 1. Install Nix (Determinate installer)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# 2. Bootstrap nix-darwin (first time only)
nix run nix-darwin -- switch --flake ~/dotfiles#darwin

# Subsequent rebuilds
nix-rebuild
```

## Structure

```
├── flake.nix                 # Main flake configuration
├── hosts/                    # Platform-specific system configs
│   ├── nixos/                # NixOS configuration
│   └── darwin/               # macOS configuration
├── modules/                  # NixOS modules
├── home/                     # Home Manager configs
│   ├── shared/               # Cross-platform (git, ssh, zsh, nvim, wezterm)
│   ├── woolw/                # NixOS-specific (AGS, GTK, Qt)
│   └── woolw-darwin/         # macOS-specific
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
