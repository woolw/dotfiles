# NixOS System Configuration

## Current System Info
- **Hostname**: nixos
- **Kernel**: 6.18.1 (linuxPackages_latest)
- **NixOS**: 25.11 (Xantusia)
- **Desktop**: KDE Plasma 6 on Wayland
- **User**: woolw
- **Shell**: Zsh

## Hardware
- **GPU**: AMD Radeon RX 7900 XT (20GB VRAM)
  - Device: 0000:03:00.0
  - Driver: amdgpu (Mesa 25.2.6, LLVM 21.1.2, DRM 3.64)
  - **CRITICAL**: Requires forced high performance mode to prevent display artifacts
- **Monitor**: MSI MAG 321CUPDE (4K@144Hz via DisplayPort)
  - Model: DC5A154300037
  - Currently connected to card1 (DP-1)

## Known Issues & Fixes

### AMD GPU Display Artifacts (SOLVED)
**Problem**: White rectangles appearing at high refresh rates (120Hz+), worse in fullscreen apps.

**Root Cause**: Aggressive power management keeping memory clocks too low (96MHz idle),
causing timing instabilities with high-bandwidth 4K@144Hz signal.

**Solution**: Force high performance power state via udev rule in `modules/amd-gpu.nix`:
```nix
services.udev.extraRules = ''
  KERNEL=="card1", SUBSYSTEM=="drm", DRIVERS=="amdgpu",
  ATTR{device/power_dpm_force_performance_level}="high"
'';
```

**Verification**:
```bash
# Should show "high"
cat /sys/class/drm/card1/device/power_dpm_force_performance_level

# Memory clock should be at state 3 (1249MHz) with asterisk
cat /sys/class/drm/card1/device/pp_dpm_mclk
```

**Notes**:
- Do NOT use `amdgpu.ppfeaturemask` kernel parameter - udev rule is sufficient
- KVM switches can exacerbate signal integrity issues, but direct connection still had artifacts
- The fix works through KVM as well once power management is corrected

## Project Structure
```
~/dotfiles/
├── flake.nix              # Main flake configuration
├── flake.lock             # Locked dependency versions
├── CLAUDE.md              # This file (project context for Claude)
├── README.md              # Human-readable docs
├── setup-github-ssh.sh    # GitHub SSH setup script
│
├── .github/               # GitHub Actions workflows
│   └── workflows/
│       └── nixos-check.yml  # CI/CD config validation
│
├── docs/                  # Documentation
│   └── hardware/          # Hardware issue documentation
│       ├── README.md      # Template and index
│       └── *.md           # Individual hardware issue reports
│
├── hosts/                 # Platform-specific system configs
│   └── nixos/             # NixOS desktop configuration
│       ├── configuration.nix  # Main system config
│       └── hardware-configuration.nix  # Hardware-specific (auto-generated)
│
├── modules/               # NixOS-specific modules
│   ├── amd-gpu.nix       # AMD GPU power management fix
│   └── gaming.nix        # Steam, gaming tools
│
├── home/                  # Platform-specific Home Manager configs
│   └── woolw/
│       └── home.nix      # NixOS user-level config (symlinks to cross-platform configs)
│
└── [CROSS-PLATFORM CONFIGS - Pure config files, no Nix]
    ├── wezterm/          # Terminal emulator
    │   └── wezterm.lua   # Pure Lua config
    ├── helix/            # Text editor
    │   ├── config.toml
    │   ├── languages.toml
    │   └── themes/
    │       └── everforest.toml
    └── zsh/              # Shell
        └── zshrc         # Pure shell config with OS-aware aliases

[LEGACY - Archived Arch Linux configs]
├── hypr/                 # Hyprland compositor (not used on NixOS)
├── waybar/               # Status bar (not used on NixOS)
├── fuzzel/               # App launcher (not used on NixOS)
├── mako/                 # Notifications (not used on NixOS)
├── wallpapers/           # Wallpapers
└── install               # Old Arch install script (archived)
```

## Quick Start Commands

### System Management (via shell aliases)
```bash
rebuild    # Rebuild and switch to new configuration
update     # Update flake inputs and rebuild
```

These aliases work cross-platform:
- **NixOS**: Uses `nixos-rebuild`
- **macOS**: Will use `darwin-rebuild` (when nix-darwin is set up)

### Manual Rebuild Commands
```bash
# Rebuild system from dotfiles
sudo nixos-rebuild switch --flake ~/dotfiles#nixos

# Update flake inputs (nixpkgs, home-manager, etc.)
cd ~/dotfiles && sudo nix flake update

# Update and rebuild in one command
cd ~/dotfiles && sudo nix flake update && sudo nixos-rebuild switch --flake .#nixos

# Check what would change (dry-run)
sudo nixos-rebuild build --flake ~/dotfiles#nixos
```

## GitHub SSH Setup

SSH authentication and commit signing are configured via Home Manager.

**Key Location**: `~/.ssh/github_ed25519`

**To set up on a new machine**:
```bash
./setup-github-ssh.sh
```

The script will:
1. Generate SSH key (or use existing)
2. Configure SSH for GitHub
3. Display public key and copy to clipboard
4. Guide you through adding to GitHub
5. Test the connection
6. Optionally enable SSH commit signing

**Current Configuration**:
- ✅ SSH authentication configured
- ✅ SSH commit signing enabled
- ✅ Auto-loads key via ssh-agent (managed by zshrc)

## Cross-Platform Strategy

This dotfiles repo supports both **NixOS** (Linux) and **nix-darwin** (macOS).

### Design Principles
1. **Pure config files** for cross-platform apps (WezTerm, Helix, Zsh) - no Nix code
2. **Platform-specific** Home Manager configs reference these pure configs via symlinks
3. **OS-specific modules** stay separate (e.g., `modules/amd-gpu.nix` only for NixOS)
4. **Shell aliases detect OS** via `$OSTYPE` to use correct rebuild commands

### Current State
- ✅ NixOS system configuration fully functional
- ✅ Cross-platform configs symlinked via Home Manager
- ✅ WezTerm config: `~/.config/wezterm/wezterm.lua` → `dotfiles/wezterm/wezterm.lua`
- ✅ Helix config: `~/.config/helix/` → `dotfiles/helix/`
- ✅ Zsh config: Sources `dotfiles/zsh/zshrc` on shell init
- ✅ GitHub SSH configured with commit signing
- ✅ Zsh as default shell

### Future nix-darwin Setup
When setting up macOS:
1. Add `hosts/darwin/` with macOS-specific system config
2. Add `home/woolw-darwin/home.nix` for macOS user config
3. Both NixOS and darwin Home Manager configs will reference the same:
   - `wezterm/wezterm.lua`
   - `helix/` configs
   - `zsh/zshrc`
4. Shell aliases will automatically use `darwin-rebuild` on macOS

### Why Keep Configs "Pure"?
- Same terminal/editor/shell experience across Linux and macOS
- Edit once, works everywhere
- No Nix lock-in for application configs
- Easy to test configs without rebuilding system

## NixOS Development Guidelines

### Code Style
- Use modules for logical separation (GPU, gaming, development, etc.)
- Keep hardware-specific configs in `hardware-configuration.nix`
- Use Home Manager for user-level dotfiles and configs
- Prefer declarative package installation over `nix-env`

### When Making Changes
1. Edit the appropriate module or config file
2. Build to check for errors: `sudo nixos-rebuild build --flake ~/dotfiles#nixos`
3. If build succeeds, switch: `sudo nixos-rebuild switch --flake ~/dotfiles#nixos`
4. Test the change
5. Commit to git with descriptive message

### Git Workflow
- Commit frequently with clear messages
- Test major changes in a VM first if possible
- Keep `flake.lock` in version control
- Use branches for experimental features

## Important Notes

### AMD GPU
- The udev rule MUST apply on boot for stable display
- Without it, you'll see artifacts every few seconds at 144Hz
- Even at 60Hz, fullscreen apps (like mpv) will have constant artifacts
- This is a hardware/driver power management issue, not a cable or monitor problem

### Flakes
- `flake.lock` pins exact versions - this is good for reproducibility
- Run `nix flake update` periodically to get security updates
- After updating, test thoroughly before committing

### Home Manager
- User-level configs go in `home/woolw/`
- Changes require rebuild to take effect
- Manages symlinks to cross-platform configs
- Handles SSH, git, and shell configuration

### Shell Aliases
The `zshrc` includes OS-aware aliases that work on both NixOS and macOS:
- `rebuild` - Quick rebuild and switch
- `update` - Update flake inputs and rebuild
- Plus standard aliases: `ll`, `gs`, `gl`, `gc`, `v` (helix)

## Hardware Issue Documentation

Hardware-specific issues and their solutions are documented in **`docs/hardware/`**.

**Current documented issues:**
- [AMD RX 7900 XT Display Artifacts](./docs/hardware/amd-rx7900xt-display-artifacts.md) - ✅ SOLVED

**To document a new hardware issue:**
1. See the template in [`docs/hardware/README.md`](./docs/hardware/README.md)
2. Create a new `.md` file in `docs/hardware/` following the template
3. Update the issue list in `docs/hardware/README.md`

This keeps hardware documentation organized and separate from system configuration docs.

## CI/CD

GitHub Actions automatically validates configuration on every push and pull request.

**What's checked**:
- ✅ Flake evaluation (syntax and structure)
- ✅ NixOS configuration build (dry-run)
- ✅ Code formatting (nixfmt)
- ✅ Static analysis (statix)
- ✅ Dead code detection (deadnix)

**Workflow file**: `.github/workflows/nixos-check.yml`

**To run checks locally**:
```bash
# Check flake
nix flake check

# Build configuration (dry-run)
nix build .#nixosConfigurations.nixos.config.system.build.toplevel --dry-run

# Format Nix files
nix fmt

# Run statix linter
nix run nixpkgs#statix -- check .

# Find dead code
nix run nixpkgs#deadnix -- .
```

## Completed Setup Checklist
- [x] NixOS flake-based configuration
- [x] Home Manager integration
- [x] AMD GPU power management fix
- [x] Gaming setup (Steam, protonup-qt, GameMode, MangoHud, Gamescope)
- [x] Cross-platform configs symlinked (WezTerm, Helix, Zsh)
- [x] GitHub SSH authentication
- [x] SSH commit signing
- [x] Zsh as default shell
- [x] OS-aware rebuild aliases
- [x] CI/CD for config validation
- [x] Hardware documentation template

## Future Enhancements
- [ ] Set up nix-darwin configuration for macOS
- [ ] Add development module with language-specific tools
- [ ] Consider migrating Hyprland config to NixOS (optional alternative to KDE)
- [ ] Set up automatic backup/sync strategy

## Useful Resources
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [NixOS Wiki](https://wiki.nixos.org/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Package Search](https://search.nixos.org/packages)
- [nix-darwin](https://github.com/LnL7/nix-darwin) (for future macOS setup)
