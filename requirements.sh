#!/bin/bash

# Define the list of packages to install
packages = ("picom" "i3" "ranger" "discord" "firefox" "sy)

# Update the package database
sudo pacman -Sy

# Install the specified packages
sudo pacman -S --noconfirm "${packages[@]}"


# everything for synth-shell
# git clone --recursive https://github.com/andresgongora/synth-shell.git
# cd synth-shell
# ./setup.sh

