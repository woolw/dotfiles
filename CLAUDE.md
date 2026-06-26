# System Configuration

## Quick Reference

### NixOS (x86_64-linux)
| To modify... | Edit this file |
|--------------|----------------|
| System packages, services | `hosts/nixos/configuration.nix` |
| User packages, git, SSH | `home/woolw/home.nix` |
| Hyprland WM | `hypr/hyprland.conf` → sources `hypr/hyprland/*.conf` |
| Desktop shell (AGS) | `ags/app.ts`, `ags/widget/*.tsx`, `ags/style.scss` |
| Gaming (Steam, etc.) | `modules/gaming.nix` |
| GPU power management | `modules/amd-gpu.nix` |
| Digital art apps, tablet | `modules/digital-art.nix` |

### macOS / nix-darwin (aarch64-darwin)
| To modify... | Edit this file |
|--------------|----------------|
| System settings, Homebrew | `hosts/darwin/configuration.nix` |
| User packages, git, SSH | `home/woolw-darwin/home.nix` |

Rebuild macOS: `darwin-rebuild switch --flake ~/dotfiles#darwin`

### Cross-platform
| To modify... | Edit this file |
|--------------|----------------|
| Terminal (WezTerm) | `wezterm/wezterm.lua` |
| Editor (Neovim) | `nvim/init.lua`, `nvim/lua/plugins/*.lua` |
| Shell (Zsh) | `zsh/zshrc` |
| Video player (mpv) | `mpv/mpv.conf` |
| Shared HM config (git, SSH, symlinks) | `home/shared/default.nix` |

**Theme**: macOS-inspired dark theme (semi-transparent, OneDark palette)
**Font**: JetBrainsMono Nerd Font (icons), SF Pro Text/Noto Sans (UI)
**Audio**: PipeWire

## System Info

**NixOS** (primary desktop): hostname `nixos`, `linuxPackages_latest` kernel, NixOS 26.05, Hyprland + AGS shell

**macOS** (laptop): hostname `darwin`, aarch64-darwin, nix-darwin + nix-homebrew, Determinate Nix (`nix.enable = false` — daemon managed externally)

Both: user `woolw`, shell Zsh

## Hardware
- **GPU**: AMD Radeon RX 7900 XT (20GB VRAM) — **CRITICAL**: requires forced high performance mode via udev rule (`KERNEL=="card[0-9]*"` in `modules/amd-gpu.nix`) to prevent display artifacts at 144Hz
- **Monitor**: MSI MAG 321CUPDE (4K@144Hz via DisplayPort, card1/DP-1)

## Commands

```bash
# Shell aliases (auto-detect OS)
nix-rebuild   # Rebuild and switch
nix-update    # Update flake inputs and rebuild
nix-gc        # Garbage collect and rebuild boot

# NixOS manual
sudo nixos-rebuild switch --flake ~/dotfiles#nixos
sudo nixos-rebuild build --flake ~/dotfiles#nixos  # dry-run

# macOS manual
darwin-rebuild switch --flake ~/dotfiles#darwin

# AGS restart (NixOS only)
pkill gjs; ags run -g 4
```

## Development Workflow

1. Edit the appropriate file (see Quick Reference)
2. Build to check: `sudo nixos-rebuild build --flake ~/dotfiles#nixos`
3. Switch: `sudo nixos-rebuild switch --flake ~/dotfiles#nixos`
4. Commit with descriptive message

Pre-commit hook auto-formats `.nix` files via `nixfmt`. CI (`.github/workflows/nixos-check.yml`) validates both NixOS and darwin builds, formatting (nixfmt), statix, and deadnix on every push.

## Cross-Platform Design

Pure config files (WezTerm, Neovim, Zsh, mpv) are symlinked via Home Manager — no Nix lock-in, same experience on NixOS and macOS. OS-specific modules stay separate. nix-darwin config lives in `hosts/darwin/`.

## Docs

Issues documented in `docs/hardware/` and `docs/software/`. See template at `docs/hardware/README.md`.
