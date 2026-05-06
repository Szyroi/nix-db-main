{
  pkgs ? import <nixpkgs> {config.allowUnfree = true;},
  dbMainTarball ?
    pkgs.fetchurl {
      url = "https://projects.info.unamur.be/dbmain/files/dbm-1102-linux-amd64-setup.tar.gz";
      hash = "sha256-j2HmBpM33HNKxviGsiQynslDzU2vvYiGEb2AY3PLMpY=";
    },
  dbMainPath ? "$HOME/.local/share/db-main",
}: let
  commonLibs = with pkgs; [
    # GUI & X11
    gtk2
    libx11
    libxext
    libxtst
    libSM
    libICE
    pango
    cairo
    # image & font
    libpng
    gdk-pixbuf
    freetype
    fontconfig
    # OpenGL & other
    libGL
    libxcb
    # system & compression
    expat
    zlib
    # glib/gobject
    glib
    # C++ runtime
    stdenv.cc.cc.lib
    # Java
    jdk
  ];

  # Additional libraries
  extraLibs = with pkgs; [
    libjpeg_turbo
    libtiff
    libXinerama
    libXrandr
    libXi
    libXcursor
    libxshmfence
    libdrm
    mesa
  ];

  fhs = pkgs.buildFHSEnv {
    name = "db-main-fhs";
    targetPkgs = pkgs: commonLibs ++ extraLibs;
    runScript = "bash";
  };
in
  pkgs.writeShellScriptBin "db-main" ''
    set -euo pipefail
    export LC_ALL=C.UTF-8

    # Terminal colours (tput)
    if [ -t 1 ]; then
      BOLD="$(tput bold 2>/dev/null || true)"
      GREEN="$(tput setaf 2 2>/dev/null || true)"
      RED="$(tput setaf 1 2>/dev/null || true)"
      YELLOW="$(tput setaf 3 2>/dev/null || true)"
      CYAN="$(tput setaf 6 2>/dev/null || true)"
      RESET="$(tput sgr0 2>/dev/null || true)"
    else
      BOLD=""; GREEN=""; RED=""; YELLOW=""; CYAN=""; RESET=""
    fi
    CHECKMARK="$GREEN✓$RESET"
    CROSS="$RED✗$RESET"
    INFO="$CYANℹ$RESET"
    ARROW="$YELLOW➜$RESET"

    DB_MAIN_DIR="${dbMainPath}"
    DB_MAIN_BIN="$DB_MAIN_DIR/bin"

    # Spinner animation
    show_spinner() {
      local pid=$1
      local delay=0.5
      local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
      while kill -0 "$pid" 2>/dev/null; do
        for i in $(seq 0 9); do
            printf "\r$CYAN%s$RESET Please wait ..." "''${spinstr:$i:1}"
            sleep $delay
            printf "\r\033[2K"
        done
      done
    }

    if [ ! -x "$DB_MAIN_BIN/db_main" ]; then
      echo ""
      echo "$INFO $BOLD""DB-Main Wrapper$RESET: First-time setup"
      echo "$ARROW Target directory: $CYAN$DB_MAIN_DIR$RESET"

      rm -rf "$DB_MAIN_DIR"
      mkdir -p "$DB_MAIN_DIR"

      echo -n "$ARROW Extracting tarball ... "
      tar -xzf ${dbMainTarball} -C "$DB_MAIN_DIR" --strip-components=1 &
      tar_pid=$!
      show_spinner $tar_pid
      wait $tar_pid
      echo -e "\r$CHECKMARK Extraction complete."

      if [ ! -x "$DB_MAIN_BIN/db_main" ]; then
        echo "$CROSS $RED Error:$RESET Could not find db_main."
        exit 1
      fi
      echo "$CHECKMARK $GREEN""Installation finished!$RESET"
      echo ""
    fi

    mkdir -p "$HOME/.db_main"
    touch "$HOME/.db_main/db_main.ini"

    export DB_MAIN_BIN
    export LD_LIBRARY_PATH="$DB_MAIN_BIN:$DB_MAIN_BIN/../java/jre/lib/amd64/server"
    export PATH="$DB_MAIN_BIN:$PATH"

    echo "$ARROW $BOLD Starting DB-MAIN ...$RESET"
    exec ${fhs}/bin/db-main-fhs -c "exec \"$DB_MAIN_BIN/db_main\" \"\$@\""
  ''
