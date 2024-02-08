#!/bin/bash

# Define the list of packages to install
packages = ("picom" "i3" "ranger" "discord" "firefox")

# Update the package database
sudo pacman -Sy

# Install the specified packages
sudo pacman -S --noconfirm "${packages[@]}"

