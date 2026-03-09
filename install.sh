#!/usr/bin/env bash

set -e

REPO_RAW_BASE="https://raw.githubusercontent.com/Lynxz411/Lynxz-ohmyposh/main"
THEME_NAME="lynxz.omp.json"
TARGET_DIR="$HOME/.config/ohmyposh"
TARGET_THEME="$TARGET_DIR/$THEME_NAME"

echo "======================================"
echo " Lynxz OhMyPosh Universal Installer"
echo "======================================"
echo ""

# -----------------------------
# Detect Environment & Distro
# -----------------------------
# check termux
if [[ -n "$PREFIX" && "$PREFIX" == *"/com.termux"* ]]; then
    DISTRO="termux"
    IS_TERMUX=true
    echo "📱 Termux environment detected."
elif [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
    IS_TERMUX=false
    echo "Detected distro: $DISTRO"
else
    echo "❌ Cannot detect Linux distro or Termux."
    exit 1
fi

# -----------------------------
# Install dependencies
# -----------------------------
install_deps() {
    case "$DISTRO" in
        termux)
            pkg update -y
            pkg install -y curl unzip fontconfig
        ;;
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
# BUG FIX: Bagian 'exit 1' dihapus agar script bisa lanjut ke proses install
if ! command -v oh-my-posh &> /dev/null; then
    echo "⚠ oh-my-posh not found. Auto installing now..."
    
    install_deps

    case "$DISTRO" in
        termux)
            pkg install -y oh-my-posh
        ;;
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
if [ "$IS_TERMUX" = true ]; then
    # Logika font khusus Termux
    if [ ! -f "$HOME/.termux/font.ttf" ]; then
        echo "⚠ JetBrainsMono Nerd Font not found. Installing for Termux..."
        mkdir -p "$HOME/.termux"
        echo "Downloading font..."
        curl -fLo "$HOME/.termux/font.ttf" \
            "https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/JetBrainsMono/Ligatures/Regular/JetBrainsMonoNerdFont-Regular.ttf"
        
        termux-reload-settings 2>/dev/null || true
        echo "✅ JetBrainsMono Nerd Font installed for Termux."
    else
        echo "✅ JetBrainsMono Nerd Font already installed in Termux."
    fi
else
    # Logika font Linux biasa
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
