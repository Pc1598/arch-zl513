#!/bin/bash
sudo pacman-key --recv-keys F3B607488DB35A47 --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key F3B607488DB35A47

# Backup the original file
cp /etc/pacman.conf /etc/pacman.conf.bak

# Install mirrorlist and keyring
sudo pacman -U 'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-mirrorlist-18-1-any.pkg.tar.zst' \
    'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-v3-mirrorlist-18-1-any.pkg.tar.zst' \
    'https://f.alhp.dev/alhp-keyring/alhp-keyring-20240426.tar.gz' \
    'https://somegit.dev/ALHP/alhp-mirrorlist/archive/20241215.tar.gz'
# replace pacman.conf
cp pacman.conf /etc/pacman.conf
