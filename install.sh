#!/usr/bin/env bash

set -e

REPO_RAW_BASE="https://raw.githubusercontent.com/Lynxz411/ohmyposh/main"
THEME_NAME="lynxz.omp.json"
TARGET_DIR="$HOME/.config/ohmyposh"
TARGET_THEME="$TARGET_DIR/$THEME_NAME"

echo "======================================"
echo " Lynxz OhMyPosh Universal Installer"
echo "======================================"
echo ""

# -----------------------------
# Detect Shell
# -----------------------------
CURRENT_SHELL="$(basename "$SHELL")"

if [ -n "$ZSH_VERSION" ]; then
    CURRENT_SHELL="zsh"
elif [ -n "$BASH_VERSION" ]; then
    CURRENT_SHELL="bash"
elif [ -n "$FISH_VERSION" ]; then
    CURRENT_SHELL="fish"
fi

echo "Detected shell: $CURRENT_SHELL"
echo ""

# -----------------------------
# Check Oh My Posh
# -----------------------------
if ! command -v oh-my-posh &> /dev/null; then
    echo "❌ Oh My Posh is not installed."
    echo "Install from: https://ohmyposh.dev"
    exit 1
fi

# -----------------------------
# Create Config Directory
# -----------------------------
mkdir -p "$TARGET_DIR"

# -----------------------------
# Download Theme
# -----------------------------
echo "Downloading theme..."
curl -fsSL "$REPO_RAW_BASE/$THEME_NAME" -o "$TARGET_THEME"

echo "✅ Theme installed to $TARGET_THEME"
echo ""

# -----------------------------
# Inject Config
# -----------------------------
case "$CURRENT_SHELL" in
    fish)
        CONFIG_FILE="$HOME/.config/fish/config.fish"
        INIT_LINE="oh-my-posh init fish --config $TARGET_THEME | source"
        ;;
    bash)
        CONFIG_FILE="$HOME/.bashrc"
        INIT_LINE='eval "$(oh-my-posh init bash --config '"$TARGET_THEME"')"'
        ;;
    zsh)
        CONFIG_FILE="$HOME/.zshrc"
        INIT_LINE='eval "$(oh-my-posh init zsh --config '"$TARGET_THEME"')"'
        ;;
    *)
        echo "⚠ Unsupported shell. Add manually:"
        echo "oh-my-posh init SHELL --config $TARGET_THEME"
        exit 0
        ;;
esac

# Create config file if missing
touch "$CONFIG_FILE"

if grep -Fxq "$INIT_LINE" "$CONFIG_FILE"; then
    echo "ℹ Already configured."
else
    echo "" >> "$CONFIG_FILE"
    echo "# Lynxz OhMyPosh Theme" >> "$CONFIG_FILE"
    echo "$INIT_LINE" >> "$CONFIG_FILE"
    echo "✅ Config injected into $CONFIG_FILE"
fi

echo ""
echo "======================================"
echo " Installation Complete!"
echo " Restart your terminal."
echo "======================================"
