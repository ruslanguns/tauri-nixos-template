# NixOS WSL Tauri Starter

Template for shipping Tauri 2 desktop apps from a Nix-powered WSL environment. It bundles a reproducible flake, direnv integration, and cross-compilation support so you can iterate on Linux and deliver Windows installers without leaving WSL.

## Features
- Nix flake dev shell with Rust (Linux + Windows targets), Node 22 + Bun, GTK/WebKit, MinGW, Wine, and NSIS tooling ready to go.
- Direnv watch hooks to auto-enter the shell when `flake.nix` changes.
- Custom NSIS template adapted for cross-builds (jump list cleanup disabled so `makensis` runs cleanly on Linux).

## Prerequisites
- WSL2 with a recent Nix installation (`nix` + flakes enabled) and `direnv`.
- `bun` installed (the flake provides it when entering the dev shell).

## Quick Start
1. Clone this repo and run `direnv allow` in the project root.
2. Install web dependencies with `bun install`.
3. Start the desktop app via `bun run tauri dev`.

## Builds
- Linux (host): `bun run tauri build`
- Windows (cross from WSL): `bun run tauri build --target x86_64-pc-windows-gnu`
  - Outputs land in `src-tauri/target/x86_64-pc-windows-gnu/release/bundle/nsis/`.

## Structure
- `src/` – Vite + TypeScript frontend entrypoint.
- `src-tauri/` – Rust backend, Tauri config, icons, and the custom NSIS template.
- `flake.nix` / `.envrc` – Dev environment definition and auto-loading direnv hook.
