# Git Hooks

This directory contains Git hooks for the dotfiles repository.

## Pre-commit Hook

The pre-commit hook automatically formats Nix files before committing.

### Installation

The hook should be symlinked into `.git/hooks/`:

```bash
ln -sf ../../hooks/pre-commit .git/hooks/pre-commit
```

### What it does

- Detects staged `.nix` files
- Formats them using `nixfmt`
- Re-stages the formatted files
- Ensures all committed Nix code is properly formatted

### Manual formatting

You can also format files manually:

```bash
nix fmt                    # Format all Nix files
nix fmt -- file.nix       # Format specific file
```
