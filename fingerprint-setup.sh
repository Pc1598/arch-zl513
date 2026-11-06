#!/usr/bin/env bash
# ==============================================================================
# Fingerprint setup for Infinix ZERO BOOK 13 (ZL513)
# Hardware: FocalTech FTE4800 / FT9368 SPI Capacitive Sensor
# Compatible with: GNOME, KDE Plasma 6, and Niri (swaylock/gtklock)
# Usage: ./fingerprint-setup.sh [--rebuild]
# ==============================================================================
set -euo pipefail

[[ $EUID -ne 0 ]] && exec sudo bash "$0" "$@"

USER_NAME="${SUDO_USER:?Run this from a normal user account via sudo}"
REPO="https://github.com/1bharath-yadav/focaltech-fte4800-linux-driver.git"
say() { echo "==> $*"; }

[[ -d /sys/bus/acpi/devices/FTE4800:00 ]] || say "WARNING: FTE4800:00 not found. Check SPI settings in UEFI."

# 1. Tools for building, plus headers for the running kernel (DKMS needs them
#    to compile the focal_spi module)
say "Installing build tools and kernel headers..."
KBASE="$(cat "/usr/lib/modules/$(uname -r)/pkgbase" 2>/dev/null || true)"
[[ -n $KBASE ]] || say "WARNING: could not detect kernel package; install its -headers package manually."
pacman -S --needed --noconfirm base-devel git dkms ${KBASE:+"$KBASE-headers"}

# 2. Driver: compile from source (the PKGBUILD downloads the vendor DLL at
#    build time, so a prebuilt package should not be redistributed)
if [[ "${1:-}" == "--rebuild" ]] || ! pacman -Q focaltech-fte4800 &>/dev/null; then
    say "Building driver from source..."
    BUILD="$(sudo -u "$USER_NAME" mktemp -d /tmp/fte4800-build.XXXXXX)"
    trap 'rm -rf "$BUILD"' EXIT
    sudo -u "$USER_NAME" git clone --depth 1 "$REPO" "$BUILD"
    PKGDIR="$BUILD/packaging/arch"

    # Install the PKGBUILD's own depends/makedepends as root, so makepkg does
    # not stop to ask for the user's sudo password
    mapfile -t DEPS < <(sudo -u "$USER_NAME" bash -c \
        'source "$1"; printf "%s\n" "${depends[@]}" "${makedepends[@]}"' _ "$PKGDIR/PKGBUILD")
    pacman -S --needed --noconfirm --asdeps "${DEPS[@]}"

    (cd "$PKGDIR" && sudo -u "$USER_NAME" makepkg -f --noconfirm)
    pacman -U --noconfirm "$PKGDIR"/focaltech-fte4800-*.pkg.tar.zst
else
    say "Driver already installed. (Pass --rebuild to force a recompile)"
fi

# 3. Kernel module (the package already installs the udev rule)
say "Loading kernel module..."
echo focal_spi > /etc/modules-load.d/focal_spi.conf
modprobe -r focal_spi 2>/dev/null || true
modprobe focal_spi
udevadm trigger

# 4. PAM: add pam_fprintd.so before the first auth line, only where needed.
#   - sudo, polkit-1: always (terminal and GUI password prompts)
#   - swaylock, gtklock: only if installed (Niri lockers use PAM)
#   - Skipped on purpose: GDM and KDE (kde-fingerprint) are preconfigured,
#     hyprlock uses D-Bus, and system-auth is shared by every login service
#     (including SSH), so patching it has side effects.
say "Configuring PAM..."
services=(sudo polkit-1)
for locker in swaylock gtklock; do
    command -v "$locker" >/dev/null && services+=("$locker")
done
for svc in "${services[@]}"; do
    f="/etc/pam.d/$svc"
    [[ -f $f ]] || { [[ -f /usr/lib/pam.d/$svc ]] && cp /usr/lib/pam.d/$svc "$f"; } || continue
    grep -q pam_fprintd.so "$f" && continue
    cp -f "$f" "$f.bak"
    sed -i '0,/^auth/s//auth      sufficient pam_fprintd.so\nauth/' "$f"
    say "Patched $f"
done

# 5. Restart service and check enrollment
systemctl restart fprintd

if [[ -z "$(ls -A "/var/lib/fprint/$USER_NAME" 2>/dev/null)" ]]; then
    echo "Done. Enroll a fingerprint with: fprintd-enroll"
else
    echo "Done. Test with: fprintd-verify"
fi
