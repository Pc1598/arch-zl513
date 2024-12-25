wget 'https://github.com/Pc1598/arch-kernel-OVTI02C1/releases/download/6.12.6-arch/linux-6.12.6.arch1-1-x86_64.pkg.tar.zst' 'https://github.com/Pc1598/arch-kernel-OVTI02C1/releases/download/6.12.6-arch/linux-headers-6.12.6.arch1-1-x86_64.pkg.tar.zst'
sudo pacman -U linux*.pkg.tar.zst

sudo pacman -Syu libcamera pipewire-libcamera  libcamera-ipa  gst-plugin-libcamera wireplumber

mkdir -p ~/.config/wireplumber/wireplumber.conf.d/
cp 99-libcamera.conf ~/.config/wireplumber/wireplumber.conf.d/
systemctl --user restart pipewire wireplumber

# Firefox : go to “about:config” in Firefox, disable “media.webrtc.camera.allow-pipewire” and restart Firefox.
# Chromium: To switch back from PipeWire to v4l2 you have to go to “chrome://flags” and disable “PipeWire Camera support“, but you already know that since you had to enable it yourself before :).


