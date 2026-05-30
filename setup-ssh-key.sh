#!/usr/bin/env bash
set -e

GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
BLUE="\033[1;34m"
RESET="\033[0m"

DEVICE="$(hostname -s)"
SSH_KEY_PATH="$HOME/.ssh/${DEVICE}_ed25519"
SSH_PUB_KEY_PATH="${SSH_KEY_PATH}.pub"

echo -e "${BLUE}╔════════════════════════════════════════╗${RESET}"
echo -e "${BLUE}║  SSH Key Setup                         ║${RESET}"
echo -e "${BLUE}╚════════════════════════════════════════╝${RESET}"
echo -e "Device: ${DEVICE}  →  key: ${SSH_KEY_PATH}"
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

    ssh-keygen -t ed25519 -f "$SSH_KEY_PATH" -C "git@woolw.dev" -N ""

    echo -e "${GREEN}==> SSH key generated successfully!${RESET}"
fi

# Ensure proper permissions
chmod 600 "$SSH_KEY_PATH"
chmod 644 "$SSH_PUB_KEY_PATH"

# Start SSH agent and add key (zshrc handles persistence)
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
if command -v pbcopy &> /dev/null; then
    cat "$SSH_PUB_KEY_PATH" | pbcopy
    echo -e "${GREEN}✓ Public key copied to clipboard!${RESET}"
elif command -v wl-copy &> /dev/null; then
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
echo -e "${YELLOW}║  Forgejo (git.woolw.dev/user/settings/keys):                   ║${RESET}"
echo -e "${YELLOW}║  1. Add Authentication Key titled '${DEVICE}'                  ║${RESET}"
echo -e "${YELLOW}║  2. Add Signing Key titled '${DEVICE} (signing)'               ║${RESET}"
echo -e "${YELLOW}╚════════════════════════════════════════════════════════════════╝${RESET}"
echo ""

# Wait for user to add key
echo -e "${GREEN}Press Enter after you've added the key to Forgejo...${RESET}"
read -r

# Test connection
echo -e "${GREEN}==> Testing Forgejo SSH connection...${RESET}"
if ssh -T git@git.woolw.dev 2>&1 | grep -q "successfully authenticated\|Welcome\|logged in"; then
    echo -e "${GREEN}✓ Forgejo SSH connection successful!${RESET}"
    CONNECTION_OK=true
else
    echo -e "${YELLOW}⚠ Forgejo test inconclusive. Try manually: ssh -T git@git.woolw.dev${RESET}"
    CONNECTION_OK=false
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
echo -e "  ✓ SSH config (via Home Manager) loads the key for git.woolw.dev automatically"
echo -e "  ✓ No manual ssh-add needed in new terminals"
echo ""

if [[ "$CONNECTION_OK" == true ]]; then
    echo -e "${GREEN}✓ You're all set! Forgejo SSH is ready to use.${RESET}"
else
    echo -e "${YELLOW}⚠ Verify connection with: ssh -T git@git.woolw.dev${RESET}"
fi
echo ""
