#!/usr/bin/env bash

THEME_NAME="lynxz.omp.json"
TARGET_THEME="$HOME/.config/ohmyposh/$THEME_NAME"

echo "======================================"
echo " Lynxz OhMyPosh Uninstaller"
echo "======================================"
echo ""

# Remove theme file
if [ -f "$TARGET_THEME" ]; then
    rm "$TARGET_THEME"
    echo "✅ Theme removed."
else
    echo "ℹ Theme file not found."
fi

# Remove injected lines
for FILE in "$HOME/.config/fish/config.fish" "$HOME/.bashrc" "$HOME/.zshrc"
do
    if [ -f "$FILE" ]; then
        sed -i '/# Lynxz OhMyPosh Theme/d' "$FILE"
        sed -i '/oh-my-posh init .*lynxz.omp.json/d' "$FILE"
    fi
done

echo "✅ Shell configuration cleaned."
echo ""
echo "Uninstall complete. Restart terminal."
