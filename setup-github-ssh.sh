#!/usr/bin/env bash
set -e

GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
BLUE="\033[1;34m"
RESET="\033[0m"

SSH_KEY_PATH="$HOME/.ssh/github_ed25519"
SSH_PUB_KEY_PATH="${SSH_KEY_PATH}.pub"

echo -e "${BLUE}╔════════════════════════════════════════╗${RESET}"
echo -e "${BLUE}║  GitHub SSH Setup for NixOS           ║${RESET}"
echo -e "${BLUE}╚════════════════════════════════════════╝${RESET}"
echo ""

# Check if SSH key already exists
if [[ -f "$SSH_KEY_PATH" ]]; then
    echo -e "${YELLOW}==> SSH key already exists at $SSH_KEY_PATH${RESET}"
    echo -e "${YELLOW}==> Do you want to use the existing key? (y/n)${RESET}"
    read -r use_existing

    if [[ "$use_existing" != "y" && "$use_existing" != "Y" ]]; then
        echo -e "${RED}==> Creating a backup of existing key...${RESET}"
        mv "$SSH_KEY_PATH" "${SSH_KEY_PATH}.backup.$(date +%s)"
        mv "$SSH_PUB_KEY_PATH" "${SSH_PUB_KEY_PATH}.backup.$(date +%s)"
        GENERATE_NEW=true
    else
        GENERATE_NEW=false
    fi
else
    GENERATE_NEW=true
fi

# Generate new SSH key if needed
if [[ "$GENERATE_NEW" == true ]]; then
    echo -e "${GREEN}==> Generating new ed25519 SSH key...${RESET}"
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh

    ssh-keygen -t ed25519 -f "$SSH_KEY_PATH" -C "gh@woolw.dev" -N ""

    echo -e "${GREEN}==> SSH key generated successfully!${RESET}"
fi

# Ensure proper permissions
chmod 600 "$SSH_KEY_PATH"
chmod 644 "$SSH_PUB_KEY_PATH"

# Configure SSH for GitHub
echo -e "${GREEN}==> Configuring SSH for GitHub...${RESET}"

SSH_CONFIG="$HOME/.ssh/config"
if [[ ! -f "$SSH_CONFIG" ]] || ! grep -q "Host github.com" "$SSH_CONFIG"; then
    cat >> "$SSH_CONFIG" << EOF

# GitHub
Host github.com
    HostName github.com
    User git
    IdentityFile $SSH_KEY_PATH
    IdentitiesOnly yes
    AddKeysToAgent yes
EOF
    chmod 600 "$SSH_CONFIG"
    echo -e "${GREEN}==> SSH config updated${RESET}"
else
    echo -e "${YELLOW}==> GitHub SSH config already exists, skipping...${RESET}"
fi

# Start SSH agent and add key (your zshrc handles persistence)
echo -e "${GREEN}==> Adding SSH key to ssh-agent...${RESET}"
eval "$(ssh-agent -s)" >/dev/null
ssh-add "$SSH_KEY_PATH" 2>/dev/null || true

# Display public key
echo ""
echo -e "${BLUE}╔════════════════════════════════════════╗${RESET}"
echo -e "${BLUE}║  Your GitHub SSH Public Key            ║${RESET}"
echo -e "${BLUE}╚════════════════════════════════════════╝${RESET}"
echo ""
cat "$SSH_PUB_KEY_PATH"
echo ""

# Copy to clipboard if available
if command -v wl-copy &> /dev/null; then
    cat "$SSH_PUB_KEY_PATH" | wl-copy
    echo -e "${GREEN}✓ Public key copied to clipboard!${RESET}"
elif command -v xclip &> /dev/null; then
    cat "$SSH_PUB_KEY_PATH" | xclip -selection clipboard
    echo -e "${GREEN}✓ Public key copied to clipboard!${RESET}"
fi

# Instructions
echo -e "${YELLOW}╔════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${YELLOW}║  Next Steps:                                                   ║${RESET}"
echo -e "${YELLOW}╠════════════════════════════════════════════════════════════════╣${RESET}"
echo -e "${YELLOW}║  1. Go to: ${BLUE}https://github.com/settings/keys${YELLOW}                 ║${RESET}"
echo -e "${YELLOW}║  2. Click 'New SSH key'                                        ║${RESET}"
echo -e "${YELLOW}║  3. Title: 'NixOS Desktop'                                     ║${RESET}"
echo -e "${YELLOW}║  4. Key type: 'Authentication Key'                             ║${RESET}"
echo -e "${YELLOW}║  5. Paste the key above (already in clipboard)                 ║${RESET}"
echo -e "${YELLOW}║  6. Click 'Add SSH key'                                        ║${RESET}"
echo -e "${YELLOW}║                                                                ║${RESET}"
echo -e "${YELLOW}║  For commit signing (optional but recommended):                ║${RESET}"
echo -e "${YELLOW}║  7. Click 'New SSH key' again                                  ║${RESET}"
echo -e "${YELLOW}║  8. Title: 'NixOS Desktop (Signing)'                           ║${RESET}"
echo -e "${YELLOW}║  9. Key type: 'Signing Key'                                    ║${RESET}"
echo -e "${YELLOW}║  10. Paste the SAME key                                        ║${RESET}"
echo -e "${YELLOW}║  11. Click 'Add SSH key'                                       ║${RESET}"
echo -e "${YELLOW}╚════════════════════════════════════════════════════════════════╝${RESET}"
echo ""

# Wait for user to add key to GitHub
echo -e "${GREEN}Press Enter after you've added the key to GitHub...${RESET}"
read -r

# Test connection
echo -e "${GREEN}==> Testing GitHub SSH connection...${RESET}"
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo -e "${GREEN}✓ GitHub SSH connection successful!${RESET}"
    CONNECTION_OK=true
else
    echo -e "${YELLOW}⚠ Connection test inconclusive. Try manually: ssh -T git@github.com${RESET}"
    CONNECTION_OK=false
fi

# Ask about enabling SSH commit signing
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BLUE}║  Enable SSH Commit Signing?                                    ║${RESET}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${RESET}"
echo -e "${YELLOW}This will modify your Home Manager config to sign commits with SSH.${RESET}"
echo -e "${YELLOW}Do you want to enable SSH commit signing? (y/n)${RESET}"
read -r enable_signing

if [[ "$enable_signing" == "y" || "$enable_signing" == "Y" ]]; then
    HOME_NIX="$HOME/dotfiles/home/woolw/home.nix"

    if [[ -f "$HOME_NIX" ]]; then
        # Check if the lines are commented
        if grep -q "# gpg.format = \"ssh\";" "$HOME_NIX"; then
            echo -e "${GREEN}==> Enabling SSH commit signing in Home Manager...${RESET}"

            # Uncomment the SSH signing lines
            sed -i 's/# gpg\.format = "ssh";/gpg.format = "ssh";/' "$HOME_NIX"
            sed -i 's|# user\.signingkey = "~/.ssh/github_ed25519\.pub";|user.signingkey = "~/.ssh/github_ed25519.pub";|' "$HOME_NIX"
            sed -i 's/# commit\.gpgsign = true;/commit.gpgsign = true;/' "$HOME_NIX"

            echo -e "${GREEN}✓ SSH commit signing enabled in home.nix${RESET}"
            echo -e "${YELLOW}⚠ Run 'sudo nixos-rebuild switch --flake ~/dotfiles#nixos' to apply${RESET}"
        else
            echo -e "${YELLOW}==> SSH signing might already be enabled or config format changed${RESET}"
        fi
    fi
else
    echo -e "${YELLOW}==> Skipping SSH commit signing setup${RESET}"
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}║  Setup Complete!                       ║${RESET}"
echo -e "${GREEN}╚════════════════════════════════════════╝${RESET}"
echo ""
echo -e "${BLUE}SSH Key Location:${RESET}"
echo -e "  Private: ${SSH_KEY_PATH}"
echo -e "  Public:  ${SSH_PUB_KEY_PATH}"
echo ""
echo -e "${BLUE}SSH Agent Persistence:${RESET}"
echo -e "  ✓ Your zshrc already handles SSH agent persistence"
echo -e "  ✓ Keys auto-load via AddKeysToAgent in SSH config"
echo -e "  ✓ No manual ssh-add needed in new terminals"
echo ""

if [[ "$CONNECTION_OK" == true ]]; then
    echo -e "${GREEN}✓ You're all set! GitHub SSH is ready to use.${RESET}"
else
    echo -e "${YELLOW}⚠ Verify connection with: ssh -T git@github.com${RESET}"
fi
echo ""
