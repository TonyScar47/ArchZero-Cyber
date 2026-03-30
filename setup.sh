#!/bin/bash

# Arch Linux Setup for CTF/CyberChallenge
# This script automates the provisioning of a cybersecurity laboratory.

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Set up logging: save the log in the current directory
LOG_FILE="$(pwd)/setup_error.log"
exec > >(tee -a "$LOG_FILE") 2>&1

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

# Cleanup function executed on script exit
cleanup() {
    EXIT_CODE=$?
    # Remove temporary sudoers file if it exists
    [ -f /etc/sudoers.d/yay_temp ] && rm -f /etc/sudoers.d/yay_temp
    
    if [ $EXIT_CODE -ne 0 ]; then
        echo -e "\n${RED}[!] Error. Check log: ${LOG_FILE}${NC}\n"
    else
        # If the script finishes without errors (EXIT_CODE 0), delete the log file
        [ -f "$LOG_FILE" ] && rm -f "$LOG_FILE"
    fi
}
trap cleanup EXIT

echo -e "${BLUE}--- STARTING SETUP ---${NC}"

# Check execution context to ensure it's run via sudo
if [ "$USER" = "root" ] && [ -z "${SUDO_USER:-}" ]; then
    echo -e "${RED}[!] Run via 'sudo ./setup.sh'${NC}"
    exit 1
fi

# Determine the real user and their home directory
REAL_USER=${SUDO_USER:-$USER}
HOME_DIR=$(getent passwd "$REAL_USER" | cut -d: -f6)

# Define the workspace directory
CURRENT_DIR=$(pwd)
if [[ "$CURRENT_DIR" == *"ArchZero-Cyber"* ]]; then
    LAB_DIR="$CURRENT_DIR"
else
    LAB_DIR="$HOME_DIR/ArchZero-Cyber"
    mkdir -p "$LAB_DIR"
fi

# Grant temporary passwordless sudo privileges for yay installation
echo "$REAL_USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/yay_temp
chmod 0440 /etc/sudoers.d/yay_temp

# System Optimization & Base Packages
echo -e "${GREEN}[*] Configuring Mirrors and installing base packages...${NC}"
# Enable parallel downloads for faster pacman operations
sed -i 's/^#ParallelDownloads.*/ParallelDownloads = 10/' /etc/pacman.conf

# Install base dependencies required for AUR compilation (git, base-devel) and mirror management
pacman -Sy --needed --noconfirm archlinux-keyring reflector git base-devel

# Update mirrorlist: fetches the 20 fastest HTTPS mirrors globally with a 15s timeout
reflector --latest 20 --protocol https --sort rate --connection-timeout 20 --download-timeout 20 --save /etc/pacman.d/mirrorlist || true
pacman -Syu --noconfirm

# AUR Helper (yay) & BlackArch Repository Integration
if ! command -v yay &> /dev/null; then
    echo -e "${GREEN}[*] Installing yay...${NC}"
    BUILD_DIR=$(mktemp -d -p /tmp)
    chmod 777 "$BUILD_DIR"
    # Clone and build yay as the real user
    sudo -u "$REAL_USER" git clone https://aur.archlinux.org/yay-bin.git "$BUILD_DIR/yay-bin"
    cd "$BUILD_DIR/yay-bin"
    sudo -u "$REAL_USER" makepkg -si --noconfirm
    cd - > /dev/null && rm -rf "$BUILD_DIR"
fi

if ! grep -q "\[blackarch\]" /etc/pacman.conf; then
    echo -e "${GREEN}[*] Integrating BlackArch...${NC}"
    curl -O https://blackarch.org/strap.sh
    chmod +x strap.sh && ./strap.sh
    rm strap.sh
    pacman -Sy
fi

# Toolchain Installation
echo -e "${GREEN}[*] Installing Tools...${NC}"
# Define the list of tools (including Firefox)
ALL_TOOLS=(
    firefox python python-pip fastfetch 
    virtualbox-guest-utils docker docker-compose cmake curl tmux zip unzip
    man-db man-pages sqlmap seclists jq burpsuite nmap
    wireshark-qt tcpdump bind-tools john hashcat gdb strace 
    ltrace radare2 binwalk minicom flashrom php
)
pacman -S --needed --noconfirm "${ALL_TOOLS[@]}"

# Install tools from AUR using yay
sudo -u "$REAL_USER" yay -S --needed --noconfirm ngrok visual-studio-code-bin

# Environment Setup & Permissions
echo -e "${GREEN}[*] Setting up environment and permissions...${NC}"
systemctl enable --now docker.service
groupadd -f wireshark
usermod -aG docker,wireshark "$REAL_USER"

# Configure Wireshark capabilities for non-root execution
chgrp wireshark /usr/bin/dumpcap
chmod 750 /usr/bin/dumpcap
setcap cap_net_raw,cap_net_admin=eip /usr/bin/dumpcap || echo "setcap failed"

# Fix workspace ownership
chown -R "$REAL_USER":"$REAL_USER" "$LAB_DIR"

# Python Virtual Environment
echo -e "${GREEN}[*] Configuring Python venv...${NC}"
cd "$LAB_DIR"
if [ ! -d "venv" ]; then
    sudo -u "$REAL_USER" python -m venv venv
    sudo -u "$REAL_USER" ./venv/bin/pip install --upgrade pip
    sudo -u "$REAL_USER" ./venv/bin/pip install exrex rstr requests scapy pwntools pycryptodome arjun beautifulsoup4 dirsearch
fi

# Cleanup operations
pacman -Sc --noconfirm
rm -f /etc/sudoers.d/yay_temp

# Final Output
echo -e "\n${BLUE}============================================================${NC}"
echo -e "${GREEN}[!] DONE. Workspace: $LAB_DIR${NC}"
echo -e "${RED}[!] REBOOT or LOG OUT to apply group changes.${NC}"
echo -e "============================================================${NC}\n"
