#!/bin/bash
# setup.sh — Run once on a fresh Raspberry Pi to install the two-screen kiosk.
# Usage: bash setup.sh

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Installing packages..."
sudo apt-get update -q
sudo apt-get install -y \
    xserver-xorg-legacy \
    xinit \
    openbox \
    chromium \
    unclutter \
    nginx \
    fonts-noto-extra \
    fonts-noto-color-emoji \
    gh \
    git

echo "==> Copying system files..."
sudo cp "$REPO_DIR/system/kiosk.service" /etc/systemd/system/kiosk.service
sudo cp "$REPO_DIR/system/nginx-softsystems.conf" /etc/nginx/sites-available/softsystems
sudo cp "$REPO_DIR/system/Xwrapper.config" /etc/X11/Xwrapper.config

# Enable nginx site
sudo ln -sf /etc/nginx/sites-available/softsystems /etc/nginx/sites-enabled/softsystems
sudo rm -f /etc/nginx/sites-enabled/default
sudo systemctl restart nginx

echo "==> Installing fonts..."
sudo mkdir -p /usr/local/share/fonts/apple
sudo cp "$REPO_DIR/fonts/"*.ttf "$REPO_DIR/fonts/"*.ttc /usr/local/share/fonts/apple/
sudo mkdir -p /usr/local/share/fonts/noto
sudo cp "$REPO_DIR/fonts/NotoSansEgyptianHieroglyphs-Regular.ttf" /usr/local/share/fonts/noto/
sudo cp "$REPO_DIR/system/fontconfig/01-apple-color-emoji.conf" /etc/fonts/conf.d/
sudo fc-cache -f

echo "==> Copying kiosk scripts..."
cp "$REPO_DIR/kiosk-start.sh" ~/kiosk-start.sh
cp "$REPO_DIR/kiosk-update.sh" ~/kiosk-update.sh
cp "$REPO_DIR/kiosk.conf" ~/kiosk.conf
chmod +x ~/kiosk-start.sh ~/kiosk-update.sh
chmod o+x ~  # allow nginx (www-data) to traverse the home directory to serve ~/softsystems

echo "==> Regenerating SSH host keys..."
sudo rm -f /etc/ssh/ssh_host_*
sudo dpkg-reconfigure openssh-server

echo "==> Enabling services..."
sudo systemctl daemon-reload
sudo systemctl enable nginx
sudo systemctl enable kiosk

echo "==> Authenticating with GitHub to clone softsystems..."
gh auth status 2>/dev/null || gh auth login

echo "==> Cloning softsystems repo..."
if [ ! -d ~/softsystems ]; then
    gh repo clone shewolfe/softsystems ~/softsystems
else
    echo "    ~/softsystems already exists, skipping clone."
fi

echo ""
echo "==> Done! Next steps:"
echo "    1. Edit ~/kiosk.conf to set which sites show on each screen"
echo "    2. Set hostname: sudo hostnamectl set-hostname <name>"
echo "    3. Reboot: sudo reboot"
