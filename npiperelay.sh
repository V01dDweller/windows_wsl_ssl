#!/bin/env bash

# This script is intended for WSL2 Linux instances only. It downloads
# the npiperelay Windows binary into the Windows host

# Credit: https://code.mendhak.com/wsl2-keepassxc-ssh/

WINDOWS_USER=$(powershell.exe -c echo '$env:UserName' | sed 's///')
WINDOWS_BIN=/mnt/c/Users/$WINDOWS_USER/.local/bin
ZIP_FILE=npiperelay_windows_amd64.zip

# Creating %USERPROFILE%/.local/bin
if [ ! -d "$WINDOWS_BIN" ]; then
  echo "Creating $WINDOWS_BIN"
  mkdir -pv "$WINDOWS_BIN"
fi

# Downloading and extracting npiperelay.exe
if [ ! -f "$WINDOWS_BIN/npiperelay.exe" ]; then
  wget -O /tmp/$ZIP_FILE https://github.com/jstarks/npiperelay/releases/latest/download/$ZIP_FILE
  unzip -d "$WINDOWS_BIN" /tmp/$ZIP_FILE npiperelay.exe
  rm -f /tmp/$ZIP_FILE
fi

# Installing socat

if [ ! command -v socat]; then
  sudo apt -y install socat
fi
