#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMP_DIR="/tmp/dotfiles-install"

cleanup() {
rm -rf "$TEMP_DIR"
}

trap cleanup EXIT

echo
echo "=========================================="
echo " Arch Linux dotfiles installation"
echo "=========================================="
echo

# ============================================================

# CHECKS

# ============================================================

if [[ $EUID -eq 0 ]]; then
echo "ERROR: Do not run this script as root."
echo "Run: ./install.sh"
exit 1
fi

if ! command -v pacman >/dev/null 2>&1; then
echo "ERROR: pacman not found."
echo "This script is for Arch Linux."
exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
echo "ERROR: sudo is required."
exit 1
fi

if ! command -v git >/dev/null 2>&1; then
echo "ERROR: git is not installed."
echo
echo "Install git during Arch Linux installation first."
exit 1
fi

# ============================================================

# PACKAGES

# ============================================================

PACKAGES=(
7zip
awww
bluetui
bluez
bluez-utils
curl
htop
hyprshot
jdk17-openjdk
linux-headers
mpv
neovim
noto-fonts
noto-fonts-cjk
noto-fonts-emoji
nvtop
polkit-kde-agent
pulsemixer
reflector
stow
telegram-desktop
tree
ttf-jetbrains-mono-nerd
unzip
vim
xdg-utils
yazi
zsh
)

echo
echo "========== INSTALLING PACKAGES =========="
echo

sudo pacman -Syu --needed --noconfirm "${PACKAGES[@]}"

# ============================================================

# YAY

# ============================================================

echo
echo "========== INSTALLING YAY =========="
echo

if command -v yay >/dev/null 2>&1; then
echo "yay is already installed."
else
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"


echo "Cloning yay..."

git clone --depth=1 \
    https://aur.archlinux.org/yay.git \
    "$TEMP_DIR/yay"

cd "$TEMP_DIR/yay"

echo "Building and installing yay..."

makepkg -si --noconfirm

cd "$DOTFILES_DIR"

rm -rf "$TEMP_DIR"

echo "yay installed."
echo "Temporary yay build directory removed."


fi

# ============================================================

# NVIDIA 580xx

# ============================================================

echo
echo "========== NVIDIA 580xx =========="
echo

STANDARD_NVIDIA_PACKAGES=(
nvidia
nvidia-dkms
nvidia-utils
nvidia-settings
lib32-nvidia-utils
)

INSTALLED_STANDARD_NVIDIA=()

for pkg in "${STANDARD_NVIDIA_PACKAGES[@]}"; do
if pacman -Q "$pkg" >/dev/null 2>&1; then
INSTALLED_STANDARD_NVIDIA+=("$pkg")
fi
done

if (( ${#INSTALLED_STANDARD_NVIDIA[@]} > 0 )); then
echo "Standard NVIDIA packages detected:"
printf '  %s\n' "${INSTALLED_STANDARD_NVIDIA[@]}"


echo
echo "Removing standard NVIDIA packages..."
echo

sudo pacman -Rns --noconfirm "${INSTALLED_STANDARD_NVIDIA[@]}" || true


else
echo "No standard NVIDIA packages found."
fi

echo
echo "Installing NVIDIA 580xx packages from AUR..."
echo

yay -S --needed --noconfirm \
libxnvctrl-580xx \
nvidia-580xx-dkms \
nvidia-580xx-settings \
nvidia-580xx-utils 

# ============================================================

# OH MY ZSH

# ============================================================

echo
echo "========== OH MY ZSH =========="
echo

if [[ -d "$HOME/.oh-my-zsh" ]]; then
echo "Oh My Zsh already installed."
else
echo "Installing Oh My Zsh..."

export RUNZSH=no
export CHSH=no
export KEEP_ZSHRC=yes

sh -c "$(curl -fsSL \
    https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Oh My Zsh installed."

fi

# ============================================================

# ZSH PLUGINS

# ============================================================

echo
echo "========== ZSH PLUGINS =========="
echo

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

mkdir -p "$ZSH_CUSTOM/plugins"

# ------------------------------------------------------------

# zsh-autosuggestions

# ------------------------------------------------------------

if [[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
echo "zsh-autosuggestions already installed."
else
echo "Installing zsh-autosuggestions..."

git clone --depth=1 \
    https://github.com/zsh-users/zsh-autosuggestions.git \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

fi

# ------------------------------------------------------------

# zsh-syntax-highlighting

# ------------------------------------------------------------

if [[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
echo "zsh-syntax-highlighting already installed."
else
echo "Installing zsh-syntax-highlighting..."

git clone --depth=1 \
    https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

fi

# ============================================================

# GRAPHITE GTK THEME

# ============================================================

echo
echo "========== GRAPHITE GTK THEME =========="
echo

rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

echo "Installing Graphite build dependencies..."

# Ставим официальные пакеты через pacman
sudo pacman -S --needed --noconfirm sassc gnome-themes-extra

# Ставим движок темы из AUR через yay
yay -S --needed --noconfirm gtk-engine-murrine

echo
echo "Cloning Graphite GTK theme..."
echo

git clone --depth=1 \
    https://github.com/vinceliuice/Graphite-gtk-theme.git \
    "$TEMP_DIR/Graphite-gtk-theme"

cd "$TEMP_DIR/Graphite-gtk-theme"

echo
echo "Installing Graphite GTK theme..."
echo

./install.sh

cd "$DOTFILES_DIR"

rm -rf "$TEMP_DIR"

echo
echo "Graphite source directory removed."

# ============================================================

# STOW DOTFILES

# ============================================================

echo
echo "========== STOW DOTFILES =========="
echo

cd "$DOTFILES_DIR"

# Указываем stow целевую директорию ($HOME) с помощью флага -t
if [[ -d "$DOTFILES_DIR/.config" ]]; then
echo "Stowing .config..."
stow --restow -t "$HOME" .config
else
echo "WARNING: .config directory not found."
fi

if [[ -d "$DOTFILES_DIR/.local" ]]; then
echo "Stowing .local..."
stow --restow -t "$HOME" .local
else
echo "WARNING: .local directory not found."
fi

if [[ -f "$DOTFILES_DIR/.zshrc" ]]; then
echo "Stowing .zshrc..."
# Stow не работает с одиночными файлами напрямую, поэтому создаем ссылку через ln
ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
else
echo "WARNING: .zshrc not found."
fi

# ============================================================

# DEFAULT SHELL

# ============================================================

echo
echo "========== DEFAULT SHELL =========="
echo

ZSH_PATH="$(command -v zsh)"

# chsh может запросить ваш пароль пользователя
if [[ "$SHELL" != "$ZSH_PATH" ]]; then
echo "Changing default shell to zsh..."
sudo chsh -s "$ZSH_PATH" "$USER"
else
echo "zsh is already the default shell."
fi

# ============================================================

# FINAL CLEANUP

# ============================================================

echo
echo "========== CLEANUP =========="
echo

rm -rf "$TEMP_DIR"

echo "Temporary installation files removed."

# ============================================================

# FINISH

# ============================================================

echo
echo "=========================================="
echo " Installation completed successfully"
echo "=========================================="
echo

echo "Installed packages:"
printf '  %s\n' "${PACKAGES[@]}"

echo
echo "Additional components:"
echo "  yay"
echo "  NVIDIA 580xx"
echo "  Oh My Zsh"
echo "  zsh-autosuggestions"
echo "  zsh-syntax-highlighting"
echo "  Graphite GTK theme"

echo
echo "Dotfiles:"
echo "  ~/.config  <- .config"
echo "  ~/.local   <- .local"
echo "  ~/.zshrc   <- .zshrc"

echo
echo "Temporary Git/build directories were removed."

echo
echo "Reboot or restart your session after installation."
echo

