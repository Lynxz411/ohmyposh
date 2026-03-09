#!/usr/bin/env bash

set -e

REPO_RAW_BASE="https://raw.githubusercontent.com/Lynxz411/Lynxz-ohmyposh/main"
THEME_NAME="lynxz.omp.json"
TARGET_DIR="$HOME/.config/ohmyposh"
TARGET_THEME="$TARGET_DIR/$THEME_NAME"

echo "========================="
echo " Lynxz OhMyPosh Installer"
echo "========================="
echo ""

# -----------------------------
# Detect Distro
# -----------------------------
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
    echo "Detected distro: $DISTRO"
else
    echo "❌ Cannot detect Linux distro."
    exit 1
fi

# -----------------------------
# Install dependencies
# -----------------------------
install_deps() {
    case "$DISTRO" in
        arch|cachyos|manjaro)
            sudo pacman -Sy --needed curl unzip fontconfig
        ;;
        ubuntu|debian)
            sudo apt update
            sudo apt install -y curl unzip fontconfig
        ;;
        fedora)
            sudo dnf install -y curl unzip fontconfig
        ;;
        *)
            echo "⚠ Unsupported distro for auto-deps. Install curl unzip fontconfig manually."
        ;;
    esac
}

# -----------------------------
# Detect Shell 
# -----------------------------
CURRENT_SHELL="$(basename "$SHELL")"

echo "Detected shell: $CURRENT_SHELL"
echo ""

# -----------------------------
# Check & Auto Install Oh My Posh
# -----------------------------
if ! command -v oh-my-posh &> /dev/null; then
    echo "⚠ oh-my-posh not found. Auto installing now..."
    
    install_deps

    case "$DISTRO" in
        arch|cachyos|manjaro)
            sudo pacman -S --needed oh-my-posh
        ;;
        ubuntu|debian)
            curl -s https://ohmyposh.dev/install.sh | bash
        ;;
        fedora)
            sudo dnf install -y oh-my-posh
        ;;
        *)
            curl -s https://ohmyposh.dev/install.sh | bash
        ;;
    esac

    echo "✅ oh-my-posh installed"
else
    echo "✅ oh-my-posh already installed"
fi

echo ""

# -----------------------------
# Install JetBrainsMono Nerd Font (if missing)
# -----------------------------
if fc-list | grep -qi "JetBrainsMono Nerd"; then
    echo "✅ JetBrainsMono Nerd Font already installed."
else
    echo "⚠ JetBrainsMono Nerd Font not found. Installing..."

    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"

    TEMP_DIR="$(mktemp -d)"
    cd "$TEMP_DIR"

    echo "Downloading font..."
    curl -fsSL -o JetBrainsMono.zip \
        https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip

    unzip -q JetBrainsMono.zip -d JetBrainsMono
    cp JetBrainsMono/*.ttf "$FONT_DIR"

    cd -
    rm -rf "$TEMP_DIR"

    fc-cache -fv

    echo "✅ JetBrainsMono Nerd Font installed."
fi

echo ""

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
if [ "$CURRENT_SHELL" = "bash" ]; then
    CONFIG_FILE="$HOME/.bashrc"
    INIT_LINE='eval "$(oh-my-posh init bash --config '"$TARGET_THEME"')"'
elif [ "$CURRENT_SHELL" = "zsh" ]; then
    CONFIG_FILE="$HOME/.zshrc"
    INIT_LINE='eval "$(oh-my-posh init zsh --config '"$TARGET_THEME"')"'
elif [ "$CURRENT_SHELL" = "fish" ]; then
    CONFIG_FILE="$HOME/.config/fish/config.fish"
    INIT_LINE="oh-my-posh init fish --config $TARGET_THEME | source"
    mkdir -p "$HOME/.config/fish"
else
    echo "⚠ Unsupported shell. Add manually:"
    echo "oh-my-posh init SHELL --config $TARGET_THEME"
    exit 0
fi

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
echo " Restart your terminal or run: source $CONFIG_FILE"
echo "======================================"
