{
  description = "Fully automated DB-Main wrapper for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Optional:You can pin a specific version for reproducibility
    # flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    # Support multiple architectures
    systems = ["x86_64-linux" "aarch64-linux"];
    forAllSystems = f:
      nixpkgs.lib.genAttrs systems (system:
        f {
          inherit system;
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        });
  in {
    # Default package per system
    packages = forAllSystems ({
      pkgs,
      system,
    }: {
      default = pkgs.callPackage ./default.nix {};
    });

    # Default app per system (nix run)
    apps = forAllSystems ({
      pkgs,
      system,
    }: {
      default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/db-main";
      };
    });

    # Development shell (for hacking on the wrapper)
    devShells = forAllSystems ({
      pkgs,
      system,
    }: {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nixfmt # format nix code
          nixd # nix language server
        ];
        shellHook = ''
          echo "DB-Main wrapper development shell"
          echo "Build: nix build .#"
          echo "Run:   nix run .#"
        '';
      };
    });

    # Formatter (nix fmt)
    formatter = forAllSystems ({
      pkgs,
      system,
    }:
      pkgs.nixfmt);

    # Simple check to verify if the build works
    checks = forAllSystems ({
      pkgs,
      system,
    }: {
      build = self.packages.${system}.default;
    });
  };
}
