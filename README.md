# DB‑Main Nix Wrapper

Run the proprietary [DB‑Main](https://www.db-main.eu) modeling tool on NixOS with zero manual setup the Nix way.

## ⚠️ Important - License acceptance

By downloading and using this wrapper (which automatically fetches DB‑Main from the official site), you agree to the following clauses provided by the University of Namur:

> - DB‑MAIN can not be redistributed to third parties.
> - The University of Namur declines any responsibility for the installation, use or uninstallation of DB‑Main.
> - The University of Namur is the exclusive owner of the DB‑Main software.

This wrapper **does not redistribute** DB‑Main. It only downloads the official tarball from the university’s server. You must accept the license terms of DB‑Main itself.


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

### Clone the repository locally and install from the local path
```bash
git clone https://github.com/szyroi/nix-db-main
cd nix-db-main
nix profile add .
```

### Install globally
```bash
nix profile add github:szyroi/nix-db-main --no-write-lock-file
```

### Run directly (without installing)
```bash
nix run github:szyroi/nix-db-main --no-write-lock-file
```

Afterwards, just type `db-main` in the terminal.

## 🔧 Troubleshooting

### Missing libraries

If you see an error like `libXYZ.so: cannot open shared object file`, the wrapper already includes a comprehensive set of libraries. Please open an issue with the exact error message and I will add the missing package.

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

### No such file or directory
```bash
/init: line 11: /home/szyroi/db-main/bin/db_main: No such file or directory
```
Just add the nix profile.
```bash
nix profile add github:szyroi/nix-db-main --no-write-lock-file
```
With `nix profile list` you can see all installed nix profiles.

To remove the profile use `nix profile remove nix-db-main`.

## 📄 License
Wrapper code: MIT.

DB‑Main: proprietary software - by using this wrapper you agree to the license terms of the University of Namur (see above). This wrapper does not redistribute DB‑Main. it only automates downloading from the official source.
