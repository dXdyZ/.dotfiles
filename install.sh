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
# STORAGE PARTITION (AUTOMOUNT)
# ============================================================
echo
echo "========== Mounting Storage partition =========="
echo

STORAGE_UUID="a7617e27-2817-4905-9898-1f99d919178b"
STORAGE_MOUNT="/home/another/Storage"
STORAGE_FSTYPE="ext4"

mkdir -p "$STORAGE_MOUNT"

if ! grep -q "$STORAGE_UUID" /etc/fstab; then
    echo "UUID=$STORAGE_UUID  $STORAGE_MOUNT  $STORAGE_FSTYPE  defaults,noatime  0  2" | sudo tee -a /etc/fstab
else
    echo "Запись для этого раздела уже есть в /etc/fstab, пропускаю."
fi

sudo mount -a

echo
echo "Storage примонтирован: $STORAGE_MOUNT"


# ============================================================

# PACKAGES

# ============================================================

PACKAGES=(
7zip
awww
bluetui
curl
htop
hyprshot
jdk17-openjdk
linux-headers
mpv
neovim
noto-fonts
noto-fonts-emoji
nvtop
pulsemixer
stow
telegram-desktop
tree
ttf-jetbrains-mono-nerd
unzip
yazi
zsh
base-devel
docker
docker-compose
wl-clipboard
nwg-look
qt6-5compat
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

# Yay programm download 

# ============================================================


# Download tofi happ-desktop
echo "Download tofi, happ"
yay -S --needed --noconfirm \
	tofi \
	happ-desktop-bin 


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
# YAZI AS DEFAULT FILE MANAGER
# ============================================================
echo 
echo "========== Remove dolphine =========="
echo 

# Remove dolphine 
sudo pacman -Rns --noconfirm dolphin
rm -rf ~/.config/dolphinrc ~/.local/share/dolphin/ ~/.cache/dolphin/


echo
echo "========== Installing yazi as the primary file manager =========="
echo

mkdir -p ~/.local/share/applications

cat > ~/.local/share/applications/yazi.desktop << 'EOF'
[Desktop Entry]
Name=Yazi
Comment=Fast terminal file manager
Exec=kitty -e yazi %F
Icon=utilities-terminal
Terminal=false
Type=Application
Categories=System;FileManager;
MimeType=inode/directory;
EOF

# Обновляем базу .desktop файлов, чтобы tofi/rofi и всё остальное его увидело
update-desktop-database ~/.local/share/applications

# Регистрируем yazi как дефолтный обработчик открытия папок
xdg-mime default yazi.desktop inode/directory

# Проверка
echo "Текущий дефолтный файловый менеджер для inode/directory:"
xdg-mime query default inode/directory	


# ============================================================
# LOCALE (RUSSIAN)
# ============================================================
echo
echo "========== SETTING SYSTEM LOCALE TO RUSSIAN =========="
echo

sudo sed -i 's/^#ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen
sudo sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sudo locale-gen

sudo localectl set-locale LANG=ru_RU.UTF-8

echo
echo "Локаль установлена: ru_RU.UTF-8"
echo "Изменения полностью применятся после перелогина."


# ============================================================
# DOCKER
# ============================================================
echo
echo "========== Configuring Docker =========="
echo

sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"

echo
echo "Пользователь $USER добавлен в группу docker."
echo "Изменения группы применятся после перелогина (или newgrp docker)."

# ============================================================
# STOW DOTFILES
# ============================================================
echo
echo "========== Linking dotfiles via stow =========="
echo

stow -t "$HOME" zsh nvim kitty hypr dunst tofi Wallpaper

echo
echo "Дотфайлы залинкованы:"
echo "  ~/.config -> ~/.dotfiles/.config"
echo "  ~/.zshrc  -> ~/.dotfiles/.zshrc"


# ============================================================
# OH MY ZSH
# ============================================================
echo
echo "========== Installing Oh My Zsh =========="
echo

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no KEEP_ZSHRC=yes CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "Oh My Zsh уже установлен."
fi

echo
echo "========== Installing zsh plugins =========="
echo

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git \
        "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
    echo "zsh-syntax-highlighting уже установлен."
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git \
        "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
    echo "zsh-autosuggestions уже установлен."
fi

echo
echo "Setting zsh as default shell..."
sudo chsh -s "$(which zsh)" "$USER"
echo "Дефолтный шелл изменён на zsh (применится после перелогина)."


# ============================================================
# NEOVIM (LAZY.NVIM)
# ============================================================
echo
echo "========== Installing lazy.nvim =========="
echo

# Удаляем старые остатки менеджера, если они были, чтобы избежать конфликтов git
rm -rf ~/.local/share/nvim/lazy/lazy.nvim

# Скачиваем именно менеджер плагинов в системную директорию данных nvim
git clone --depth=1 https://github.com/folke/lazy.nvim.git ~/.local/share/nvim/lazy/lazy.nvim

echo
echo "Installing plugins via lazy.nvim (headless)..."
# Запускаем nvim в фоне, чтобы он прочитал ваши дотфайлы и выкачал плагины
nvim --headless "+Lazy! sync" +qa

echo
echo "lazy.nvim и все ваши плагины установлены."


# ============================================================
# FIREFOX PROFILE (RESTORE FROM STORAGE)
# ============================================================
echo
echo "========== Configuring Firefox profile =========="
echo

FIREFOX_PROFILE_DIR="$HOME/Storage/firefox-profile"
FIREFOX_CONFIG_DIR="$HOME/.config/mozilla/firefox"
FIREFOX_INI="$FIREFOX_CONFIG_DIR/profiles.ini"

if [ -d "$FIREFOX_PROFILE_DIR" ]; then
    mkdir -p "$FIREFOX_CONFIG_DIR"

    cat > "$FIREFOX_INI" << EOF
[Profile0]
Name=default-release
IsRelative=0
Path=$FIREFOX_PROFILE_DIR
Default=1

[General]
StartWithLastProfile=1
Version=2
EOF

    echo "Firefox профиль подключен из $FIREFOX_PROFILE_DIR"

    # Первый холодный запуск в headless-режиме, чтобы Firefox
    # сам досоздал недостающие install-специфичные файлы
    # (installs.ini, [Install...] секцию) без диалога выбора профиля
    firefox --headless --first-startup-if-needed &
    FF_PID=$!
    sleep 5
    kill "$FF_PID" 2>/dev/null || true
    wait "$FF_PID" 2>/dev/null || true

    echo "Firefox инициализирован."
else
    echo "Профиль на Storage не найден — Firefox создаст новый при первом запуске."
fi



# ============================================================
# WALLPAPPER SET
# ============================================================

echo
echo "========== Wallpaper set =========="
echo

awww img ~/Wallpaper/arch-girl.jpg



# ============================================================
# SDDM THEME
# ============================================================
echo
echo "========== Installing SDDM theme =========="
echo

SDDM_THEME_DIR="/tmp/where-is-my-sddm-theme"
rm -rf "$SDDM_THEME_DIR"

git clone --depth=1 \
    https://github.com/stepanzubkov/where-is-my-sddm-theme.git \
    "$SDDM_THEME_DIR"

sudo cp -r "$SDDM_THEME_DIR/where_is_my_sddm_theme" /usr/share/sddm/themes/

sudo cp \
    /usr/share/sddm/themes/where_is_my_sddm_theme/example_configs/classic_nocursor.conf \
    /usr/share/sddm/themes/where_is_my_sddm_theme/theme.conf

sudo mkdir -p /etc/sddm.conf.d
sudo tee /etc/sddm.conf.d/theme.conf > /dev/null << 'EOF'
[Theme]
Current=where_is_my_sddm_theme
EOF

rm -rf "$SDDM_THEME_DIR"

echo
echo "SDDM тема установлена и активирована."


