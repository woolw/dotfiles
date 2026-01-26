# NixOS System Configuration

## Quick Reference

| To modify... | Edit this file |
|--------------|----------------|
| System packages, services | `hosts/nixos/configuration.nix` |
| User packages, git, SSH | `home/woolw/home.nix` |
| Terminal (WezTerm) | `wezterm/wezterm.lua` |
| Editor (Neovim) | `nvim/init.lua`, `nvim/lua/plugins/*.lua` |
| Shell (Zsh) | `zsh/zshrc` |
| Hyprland WM | `hypr/hyprland.conf` → sources `hypr/hyprland/*.conf` |
| Desktop shell (AGS) | `ags/app.ts`, `ags/widget/*.tsx`, `ags/style.scss` |
| Gaming (Steam, etc.) | `modules/gaming.nix` |
| GPU power management | `modules/amd-gpu.nix` |

**Theme**: macOS-inspired dark theme (`rgba(28, 28, 28, 0.85)` bg, semi-transparent)
**Font**: JetBrainsMono Nerd Font (icons), SF Pro Text/Noto Sans (UI)
**Audio**: PipeWire (replaces PulseAudio)

## Current System Info
- **Hostname**: nixos
- **Kernel**: 6.18.1 (linuxPackages_latest)
- **NixOS**: 25.11 (Xantusia)
- **Desktop**: Hyprland (Wayland) with AGS shell, KDE Plasma 6 available
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
├── flake.nix              # Main flake configuration (includes AGS flake input)
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
├── hooks/                 # Git hooks
│   ├── README.md          # Hook documentation
│   └── pre-commit         # Auto-format Nix files before commit
│
├── hosts/                 # Platform-specific system configs
│   └── nixos/             # NixOS desktop configuration
│       ├── configuration.nix  # Main system config
│       └── hardware-configuration.nix  # Hardware-specific (auto-generated)
│
├── modules/               # NixOS-specific modules
│   ├── amd-gpu.nix       # AMD GPU power management fix
│   ├── gaming.nix        # Steam, gaming tools
│   └── hyprland.nix      # Hyprland compositor setup
│
├── home/                  # Home Manager configs
│   ├── shared/
│   │   └── default.nix   # Cross-platform config (git, ssh, zsh, wezterm, nvim)
│   └── woolw/
│       └── home.nix      # NixOS-specific config (imports shared, adds AGS, GTK, etc.)
│
├── [CROSS-PLATFORM CONFIGS - Pure config files, no Nix]
│   ├── wezterm/          # Terminal emulator
│   │   └── wezterm.lua   # Pure Lua config
│   ├── nvim/             # Neovim editor (lazy.nvim)
│   │   ├── init.lua      # Entry point
│   │   └── lua/
│   │       ├── config/   # Core settings, keymaps, lazy bootstrap
│   │       └── plugins/  # Plugin specs (LSP, treesitter, telescope, etc.)
│   └── zsh/              # Shell
│       └── zshrc         # Pure shell config with OS-aware aliases
│
├── [HYPRLAND ECOSYSTEM - Linux only, macOS-inspired theme]
│   ├── hypr/             # Hyprland compositor configs
│   ├── ags/              # AGS (Aylur's GTK Shell) - unified desktop shell
│   │   ├── app.ts        # Entry point
│   │   ├── style.scss    # Global styles
│   │   └── widget/       # UI components
│   │       ├── Bar.tsx       # Top bar (workspaces, tray, volume, clock)
│   │       ├── Launcher.tsx  # Spotlight-style app launcher
│   │       └── PowerMenu.tsx # macOS-style Apple menu dropdown
│   ├── swaync/           # Notification center
│   └── wallpapers/       # Wallpapers
```

## Quick Start Commands

### System Management (via shell aliases)
```bash
nix-rebuild  # Rebuild and switch to new configuration
nix-update   # Update flake inputs and rebuild
nix-gc       # Garbage collect and rebuild boot
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

## AGS Desktop Shell

AGS (Aylur's GTK Shell) provides a unified, macOS-inspired desktop experience replacing waybar, anyrun, and fuzzel.

### Components
- **Bar** (`ags/widget/Bar.tsx`): Top menu bar with:
  - NixOS logo (opens power menu)
  - Workspace indicators (circles: ○ empty, ◐ occupied, ● active)
  - Active window app name
  - System tray
  - Bluetooth (click for settings)
  - Network/WiFi (click for settings)
  - Microphone (click to mute, scroll to adjust)
  - Volume (click to mute, scroll to adjust)
  - Battery (if present)
  - Notifications button
  - Clock with calendar popup
- **Launcher** (`ags/widget/Launcher.tsx`): Spotlight-style app launcher (Super+Space)
  - Type to search apps
  - Prefix with `?` for web search (Brave Search)
  - Arrow keys/Tab to navigate, Enter to launch, Escape to close
- **PowerMenu** (`ags/widget/PowerMenu.tsx`): macOS-style dropdown from NixOS logo
  - About This PC (fastfetch)
  - System Settings
  - Sleep, Restart, Shut Down
  - Lock Screen, Log Out

### Styling
- Semi-transparent dark backgrounds (`rgba(28, 28, 28, 0.85)`)
- Pill-shaped launcher with 28px border radius
- SF Pro Text / Noto Sans for UI text
- JetBrainsMono Nerd Font for icons

### Restarting AGS
```bash
pkill gjs; ags run -g 4
```

## Neovim Configuration

Neovim is configured with lazy.nvim and One Dark theme, matching the system's dark aesthetic.

### Plugin Stack
- **Package manager**: lazy.nvim
- **Theme**: One Dark Pro
- **LSP**: mason.nvim + nvim-lspconfig (auto-installs language servers)
- **Completion**: nvim-cmp with LuaSnip
- **Fuzzy finder**: Telescope
- **Syntax**: Tree-sitter
- **Git**: gitsigns.nvim
- **Formatting**: conform.nvim (format on save)

### Key Bindings (Space as leader)
| Key | Action |
|-----|--------|
| `Space+Space` | Find files |
| `Space+fg` | Live grep |
| `Space+fb` | Buffers |
| `Space+fs` | Document symbols |
| `Space+/` | Search in buffer |
| `gd` | Go to definition |
| `gr` | References |
| `K` | Hover docs |
| `Space+ca` | Code action |
| `Space+rn` | Rename |
| `Space+f` | Format |
| `Space+e` | Show diagnostic |
| `]d` / `[d` | Next/prev diagnostic |
| `]h` / `[h` | Next/prev git hunk |

### LSP Servers (auto-installed via Mason)
- lua_ls, nil_ls (Nix), ts_ls, html, cssls, jsonls, omnisharp (C#)

## Dark Theme Configuration

All apps use dark themes via Home Manager configuration in `home/woolw/home.nix`:

### GTK Apps
- Theme: Breeze-Dark (from KDE)
- Icons: breeze-dark
- Cursor: breeze_cursors (24px)
- Font: Noto Sans 10

### Qt/KDE Apps
- Platform theme: kde (reads kdeglobals)
- Style: breeze
- Color scheme: BreezeDark (set in `~/.config/kdeglobals`)

**Note**: Qt apps require `QT_QPA_PLATFORMTHEME=kde` environment variable. This is set after rebuild, but requires logout/login to take effect for running session.

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
- SSH authentication configured
- SSH commit signing enabled
- Auto-loads key via ssh-agent (managed by zshrc)

## Cross-Platform Strategy

This dotfiles repo supports both **NixOS** (Linux) and **nix-darwin** (macOS).

### Design Principles
1. **Pure config files** for cross-platform apps (WezTerm, Neovim, Zsh) - no Nix code
2. **Platform-specific** Home Manager configs reference these pure configs via symlinks
3. **OS-specific modules** stay separate (e.g., `modules/amd-gpu.nix` only for NixOS)
4. **Shell aliases detect OS** via `$OSTYPE` to use correct rebuild commands

### Current State
- NixOS system configuration fully functional
- Cross-platform configs symlinked via Home Manager
- WezTerm config: `~/.config/wezterm/wezterm.lua` → `dotfiles/wezterm/wezterm.lua`
- Neovim config: `~/.config/nvim/` → `dotfiles/nvim/`
- Zsh config: Sources `dotfiles/zsh/zshrc` on shell init
- AGS config: `~/.config/ags/` → `dotfiles/ags/`
- GitHub SSH configured with commit signing
- Zsh as default shell

### Future nix-darwin Setup
When setting up macOS:
1. Add `hosts/darwin/` with macOS-specific system config
2. Add `home/woolw-darwin/home.nix` for macOS user config that imports `../shared`
3. The shared module (`home/shared/default.nix`) provides:
   - Git config with SSH signing
   - SSH config for GitHub
   - Zsh (sources `zsh/zshrc`)
   - WezTerm symlink
   - Neovim symlink + packages (neovim, ripgrep, fd)
   - Note: Build tools (gcc/make) are platform-specific (NixOS: nixpkgs, macOS: Xcode CLT)
4. Darwin-specific home.nix adds macOS-specific settings (different theming, etc.)
5. Shell aliases will automatically use `darwin-rebuild` on macOS

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
- Handles SSH, git, shell, GTK/Qt theming configuration

### Shell Aliases
The `zshrc` includes OS-aware aliases that work on both NixOS and macOS:
- `nix-rebuild` - Quick rebuild and switch
- `nix-update` - Update flake inputs and rebuild
- `nix-gc` - Garbage collect and rebuild boot
- Plus standard aliases: `ll`, `gs`, `gl`, `gc`, `v` (nvim)

### Hyprland Keybinds
Key bindings defined in `hypr/hyprland/keybinds.conf`:
- `Super+Space` - AGS Launcher (Spotlight-style)
- `Super+Return` - WezTerm terminal
- `Super+Q` - Close window
- `Super+HJKL` - Focus window (Vim-style)
- `Super+Shift+HJKL` - Move window
- `Super+1-5` - Switch workspace
- `Super+Shift+1-5` - Move window to workspace
- `Super+Alt+L` - Lock screen (hyprlock)
- `Super+V` - Clipboard history (cliphist)
- `Print` - Screenshot (hyprshot)
- Audio keys - Volume/mute control

## Hardware Issue Documentation

Hardware-specific issues and their solutions are documented in **`docs/hardware/`**.

**Current documented issues:**
- [AMD RX 7900 XT Display Artifacts](./docs/hardware/amd-rx7900xt-display-artifacts.md) - SOLVED

**To document a new hardware issue:**
1. See the template in [`docs/hardware/README.md`](./docs/hardware/README.md)
2. Create a new `.md` file in `docs/hardware/` following the template
3. Update the issue list in `docs/hardware/README.md`

This keeps hardware documentation organized and separate from system configuration docs.

## CI/CD

GitHub Actions automatically validates configuration on every push and pull request.

**What's checked**:
- Flake evaluation (syntax and structure)
- NixOS configuration build (dry-run)
- Code formatting (nixfmt)
- Static analysis (statix)
- Dead code detection (deadnix)

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

### Pre-commit Hook

A Git pre-commit hook automatically formats Nix files before committing.

**Installation** (already done for this repo):
```bash
ln -sf ../../hooks/pre-commit .git/hooks/pre-commit
```

**What it does**:
- Detects staged `.nix` files
- Formats them using `nixfmt`
- Re-stages the formatted files
- Ensures all committed code is properly formatted

**Note**: The CI formatting check is set to `continue-on-error: true`, so it won't block merges if someone bypasses the hook. It will still warn about formatting issues.

## Completed Setup Checklist
- [x] NixOS flake-based configuration
- [x] Home Manager integration
- [x] AMD GPU power management fix
- [x] Gaming setup (Steam, protonup-qt, GameMode, MangoHud, Gamescope)
- [x] Cross-platform configs symlinked (WezTerm, Neovim, Zsh)
- [x] GitHub SSH authentication
- [x] SSH commit signing
- [x] Zsh as default shell
- [x] OS-aware rebuild aliases (nix-rebuild, nix-update, nix-gc)
- [x] CI/CD for config validation
- [x] Hardware documentation template
- [x] Hyprland as alternative to KDE Plasma
- [x] AGS desktop shell (macOS-inspired bar, launcher, power menu)
- [x] Dark theme for GTK and Qt apps (Breeze-Dark)
- [x] Development tooling (direnv, nix-direnv)

## Future Enhancements
- [ ] Set up nix-darwin configuration for macOS

## Useful Resources
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [NixOS Wiki](https://wiki.nixos.org/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Package Search](https://search.nixos.org/packages)
- [AGS Documentation](https://aylur.github.io/ags/)
- [nix-darwin](https://github.com/LnL7/nix-darwin) (for future macOS setup)
