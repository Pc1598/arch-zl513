1. Download Latest Artifact from Github Actions

2. Extract Artifact zip and open terminal in Extracted directory

3. Install kernel and pipewire-libcamera
```sh
sudo pacman -U linux*.pkg.tar.zst
sudo pacman -Syu pipewire-libcamera 
```

4. Firefox : go to “about:config” in Firefox, enable “media.webrtc.camera.allow-pipewire” and restart Firefox.
   Chromium: go to “chrome://flags” and enable “PipeWire Camera support“ and restart Chromium.

5. Fingerprint Scanner Setup (FocalTech FTE4800 / FT9368):
```sh
./fingerprint-setup.sh
```
If you haven't enrolled your fingerprint yet:
```sh
fprintd-enroll
```
*(Tip: Lift finger completely between prompts, press flat and firmly, and shift finger angles slightly to cover all 12 stages).*

