sudo pacman -U linux*.pkg.tar.zst

sudo pacman -Syu pipewire-libcamera

# Firefox : go to “about:config” in Firefox, disable “media.webrtc.camera.allow-pipewire” and restart Firefox.
# Chromium: To switch back from PipeWire to v4l2 you have to go to “chrome://flags” and disable “PipeWire Camera support“, but you already know that since you had to enable it yourself before :).


