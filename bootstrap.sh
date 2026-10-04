#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

DOTFILES_DIR="$HOME/.dotfiles"

echo "Bootstrapping dotfiles..."

# Check if stow is installed
if ! command -v stow >/dev/null 2>&1; then
    echo "GNU Stow is not installed."
    echo "Please install it first (e.g., 'sudo pacman -S stow' or 'sudo apt install stow')."
    exit 1
fi

cd "$DOTFILES_DIR"

echo "Stowing packages..."
# We use stow */ to stow all directories and ignore files in the root (like README.md)
# --adopt is used to safely handle existing default files in the system, taking them into the dotfiles
stow --adopt -v */

echo "Done! Restart your shell for changes to take effect."
