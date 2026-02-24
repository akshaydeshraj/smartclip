#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="${HOME}/.local/bin"

echo "Installing smartclip..."

# Ensure install directory exists
mkdir -p "$INSTALL_DIR"

# Symlink the main script
ln -sf "${SCRIPT_DIR}/smartclip" "${INSTALL_DIR}/smartclip"
echo "  Linked: ${INSTALL_DIR}/smartclip"

# Detect shell and show integration instructions
echo ""
echo "Add one of these to your shell config:"
echo ""
echo "  # zsh (~/.zshrc)"
echo "  source ${SCRIPT_DIR}/integrations/smartclip.zsh"
echo ""
echo "  # bash (~/.bashrc)"
echo "  source ${SCRIPT_DIR}/integrations/smartclip.bash"
echo ""
echo "  # fish (~/.config/fish/config.fish)"
echo "  source ${SCRIPT_DIR}/integrations/smartclip.fish"
echo ""
echo "Or use standalone: pbpaste | smartclip | pbcopy"
echo ""
echo "Done."
