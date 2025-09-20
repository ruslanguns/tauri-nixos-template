{
  description = "Development environment for the tauri-app project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      rust-overlay,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
          config.allowUnfree = true;
        };

        webkitgtk = if pkgs ? webkitgtk_4_1 then pkgs.webkitgtk_4_1 else pkgs.webkitgtk;
        libsoup = if pkgs ? libsoup_3 then pkgs.libsoup_3 else pkgs.libsoup;
        nodejs = if pkgs ? nodejs_22 then pkgs.nodejs_22 else pkgs.nodejs_20;
        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          targets = [
            "x86_64-unknown-linux-gnu"
            "x86_64-pc-windows-gnu"
          ];
        };
        mingwBuildPackages = with pkgs.pkgsCross.mingwW64.buildPackages; [
          gcc
          binutils
        ];
        mingwRuntimePackages = with pkgs.pkgsCross.mingwW64.windows; [
          mingw_w64_pthreads
          pthreads
        ];
        nsisWindows = pkgs.fetchzip {
          url = "https://downloads.sourceforge.net/project/nsis/NSIS%203/3.10/nsis-3.10.zip";
          hash = "sha256-t3JH6Lu1S793nlMTXHqxPy07VBwpDQGPJKyeDHB6ECE=";
          stripRoot = false;
        };

        devShell = pkgs.mkShell {
          packages =
            [
              rustToolchain
              webkitgtk
              libsoup
              nodejs
            ]
            ++ mingwBuildPackages
            ++ mingwRuntimePackages
            ++ (with pkgs; [
              rust-analyzer
              pkg-config
              clang
              cmake
              ninja
              python3
              glib
              gtk3
              gdk-pixbuf
              pango
              cairo
              openssl
              dbus
              alsa-lib
              fontconfig
              pnpm
              git
              nsis
              wineWowPackages.staging
            ]);

          CARGO_TARGET_X86_64_PC_WINDOWS_GNU_LINKER = "x86_64-w64-mingw32-gcc";
          CC_x86_64_pc_windows_gnu = "x86_64-w64-mingw32-gcc";
          CXX_x86_64_pc_windows_gnu = "x86_64-w64-mingw32-g++";
          TAURI_NSIS_WINDOWS_HOME = "${nsisWindows}";

          shellHook = ''
                        echo "Loaded Tauri dev shell. Run 'pnpm install' followed by 'pnpm tauri dev'."
                        export WINEPREFIX="''${HOME}/.wine-tauri"
                        mkdir -p "$WINEPREFIX"
                        if ! [ -d "$WINEPREFIX/drive_c" ]; then
                          wineboot --init >/dev/null 2>&1 || true
                        fi
                        export NSIS_WINDOWS_HOME="${nsisWindows}"
                        export TAURI_CLI_MAKENSIS_PATH="$NSIS_WINDOWS_HOME"
                        wine_bin="$(command -v wine)"
                        if [ -n "$XDG_CACHE_HOME" ]; then
                          wrapper_dir="$XDG_CACHE_HOME/tauri-nsis"
                        else
                          wrapper_dir="$HOME/.cache/tauri-nsis"
                        fi
                        mkdir -p "$wrapper_dir"
                        cat > "$wrapper_dir/makensis.exe" <<EOF
            #!/usr/bin/env bash
            set -euo pipefail
            exec "$wine_bin" "${nsisWindows}/makensis.exe" "\$@"
            EOF
                        chmod +x "$wrapper_dir/makensis.exe"
                        export PATH="$wrapper_dir:$PATH"
          '';
        };
      in
      {
        devShells.default = devShell;
        packages.default = devShell;
      }
    );
}
