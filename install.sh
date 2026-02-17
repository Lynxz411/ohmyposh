#!/usr/bin/env bash

set -e

THEME_NAME="lynxz.omp.json"
SOURCE_THEME="./lynxz.omp.json"
TARGET_DIR="$HOME/.config/ohmyposh"
TARGET_THEME="$TARGET_DIR/$THEME_NAME"
FISH_CONFIG="$HOME/.config/fish/config.fish"

echo "======================================"
echo " Lynxz OhMyPosh Theme Installer"
echo "======================================"
echo ""

# -----------------------------
# Check Dependencies
# -----------------------------
if ! command -v oh-my-posh &> /dev/null; then
    echo "❌ Oh My Posh is not installed."
    echo "Install it first: https://ohmyposh.dev"
    exit 1
fi

if ! command -v fish &> /dev/null; then
    echo "❌ Fish shell is not installed."
    exit 1
fi

echo "✅ Dependencies OK"
echo ""

# -----------------------------
# Create Config Directory
# -----------------------------
mkdir -p "$TARGET_DIR"
mkdir -p "$(dirname "$FISH_CONFIG")"

# -----------------------------
# Backup Old Theme (if exists)
# -----------------------------
if [ -f "$TARGET_THEME" ]; then
    echo "⚠ Existing theme found. Creating backup..."
    mv "$TARGET_THEME" "$TARGET_THEME.bak.$(date +%s)"
fi

# -----------------------------
# Copy Theme
# -----------------------------
cp "$SOURCE_THEME" "$TARGET_THEME"
echo "✅ Theme copied to $TARGET_THEME"
echo ""

# -----------------------------
# Add to Fish Config (if not already added)
# -----------------------------
INIT_LINE="oh-my-posh init fish --config $TARGET_THEME | source"

if grep -Fxq "$INIT_LINE" "$FISH_CONFIG" 2>/dev/null; then
    echo "ℹ Fish config already configured."
else
    echo "" >> "$FISH_CONFIG"
    echo "# Lynxz OhMyPosh Theme" >> "$FISH_CONFIG"
    echo "$INIT_LINE" >> "$FISH_CONFIG"
    echo "✅ Added to Fish config."
fi

echo ""
echo "======================================"
echo " Installation Complete!"
echo " Restart your terminal."
echo "======================================"
