#!/bin/bash

# Exit immediately if a command fails
set -e

# Configuration (Change these to your actual GitHub details)
USERNAME="ahnafalsadid"
REPO="bijoy-bayanno-for-linux"

echo "============================================="
echo " Starting Bijoy Bayanno & Fonts Installation "
echo "============================================="

# 1. Install dependencies
echo "Updating package list and installing system tools..."
sudo apt update && sudo apt install -y m17n-db ibus-m17n git fontconfig

# 2. Create a temporary folder to download the repository files
TEMP_DIR=$(mktemp -d)
echo "Downloading repository files into temporary workspace..."
git clone --depth 1 "https://github.com/$USERNAME/$REPO.git" "$TEMP_DIR"

cd "$TEMP_DIR"

# 3. Copy keyboard layout files safely
echo "Installing keyboard layouts..."
sudo cp bn-bijoyClassic.mim /usr/share/m17n/
sudo cp bn-bijoyUnicode.mim /usr/share/m17n/
sudo cp bn-bijoyClassic.png /usr/share/m17n/icons/
sudo cp bn-bijoyUnicode.png /usr/share/m17n/icons/

# 4. Register layouts in the m17n database file
FILE="/var/lib/dpkg/info/m17n-db.list"
if [ -f "$FILE" ]; then
    echo "Registering layout files in system database..."
    for path in "/usr/share/m17n/icons/bn-bijoyClassic.png" "/usr/share/m17n/bn-bijoyClassic.mim" "/usr/share/m17n/icons/bn-bijoyUnicode.png" "/usr/share/m17n/bn-bijoyUnicode.mim"; do
        if ! grep -qF "$path" "$FILE"; then
            echo "$path" | sudo tee -a "$FILE" > /dev/null
        fi
    done
fi

# 5. Install the 4 fonts globally
echo "Installing default Bijoy fonts..."
FONT_DIR="/usr/local/share/fonts/bijoy-fonts"
sudo mkdir -p "$FONT_DIR"

# Copy all font files from the fonts folder directly to the system fonts directory
sudo cp fonts/*.[to]tf "$FONT_DIR/" 2>/dev/null || sudo cp fonts/*.TTF "$FONT_DIR/" 2>/dev/null || true

# Refresh the system's global font cache so applications instantly recognize them
echo "Rebuilding system font cache..."
sudo fc-cache -f -v > /dev/null

# 6. Cleanup temporary workspace files
echo "Cleaning up installer files..."
rm -rf "$TEMP_DIR"

echo "--------------------------------------------------"
echo " SUCCESS! Layouts and 92 fonts installed."
echo " Please run 'ibus restart' or restart your system."
echo " Then enable Bijoy layout from your system settings."
echo "--------------------------------------------------"
