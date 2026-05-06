# DB‑Main Nix Wrapper

Run the proprietary [DB‑Main](https://www.db-main.eu) modeling tool on NixOS with zero manual setup the Nix way.

## ✨ Features

- **One‑command install** – `nix run github:szyroi/nix-db-main`
- **Automatic download** – fetches the official Linux tarball
- **Self‑contained** – extracts to `~/.local/share/db-main` on first run
- **All dependencies included** – provides GTK2, wxWidgets, X11, GLib, image libraries, etc.
- **Flake‑ready** – works with `nix run`, `nix profile add`, or as a flake input

## 📋 Prerequisites

- NixOS with flakes enabled (or any Linux distribution with Nix and `nix-command`).
- Unfree packages must be allowed (DB‑Main is proprietary).  
  Set in `configuration.nix`:  
```nix 
nixpkgs.config.allowUnfree = true;
```

## 🚀 Installation & usage
Run directly (without installing)
```bash
nix run github:szyroi/nix-db-main
```

Install globally
```bash
nix profile add github:szyroi/db-main-nix
```
Afterwards, just type `db-main` in the terminal.

## 🔧 Troubleshooting

### Missing libraries

If you see an error like libXYZ.so: cannot open shared object file, the wrapper already includes a comprehensive set of libraries. Please open an issue with the exact error message and I will add the missing package.

### Tarball download fails

The official URL is https://projects.info.unamur.be/dbmain/files/dbm-1102-linux-amd64-setup.tar.gz.
If that changes, update the hash in default.nix using:
```bash
nix-prefetch-url --unpack <new-url>
```

### GUI doesn't appear
  Are you running under X11? DB‑Main expects a working X server.
  On Wayland, try:
  ```bash
export GDK_BACKEND=x11
db-main
```
