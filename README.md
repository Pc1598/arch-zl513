1. Download Latest Artifact from Github Actions

2. Extract Artifact zip and open terminal in Extracted directory

3. Install kernel and pipewire-libcamera
```sh
sudo pacman -U linux*.pkg.tar.zst
sudo pacman -Syu pipewire-libcamera 
```

4. Firefox : go to “about:config” in Firefox, enable “media.webrtc.camera.allow-pipewire” and restart Firefox.
   Chromium: go to “chrome://flags” and enable “PipeWire Camera support“ and restart Chromium.
