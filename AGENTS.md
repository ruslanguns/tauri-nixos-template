# Repository Guidelines

## Project Structure & Module Organization
- `src/` houses the Vite/TypeScript frontend. `main.ts` bootstraps the UI, `styles.css` defines global styling, and reusable assets live under `src/assets/`.
- `src-tauri/` contains the Rust backend. `src/main.rs` wires application startup, `src/lib.rs` is the place for Tauri commands, and `tauri.conf.json` plus `capabilities/` declare desktop permissions.
- Root artifacts: `index.html` is the entry shell, `vite.config.ts` manages bundling, and `pnpm-lock.yaml` pins dependencies. Icons for packaging live in `src-tauri/icons/`.

## Build, Test, and Development Commands
- `pnpm install` — sync dependencies for both web and Tauri toolchains.
- `pnpm dev` — run the Vite dev server for rapid UI iteration in the browser.
- `pnpm tauri dev` — launch the full desktop app with the Rust sidecar in watch mode.
- `pnpm build` — type-check with `tsc` then create a production-ready web bundle. Pair with `pnpm tauri build` when producing desktop installers.
- `pnpm preview` — serve the built web bundle locally for smoke checks.

## Coding Style & Naming Conventions
- TypeScript and Rust files both use 2-space indentation; keep module-scoped constants in `SCREAMING_SNAKE_CASE`, functions in `camelCase`, and React-style components (if introduced) in `PascalCase`.
- Keep frontend logic modular by breaking features into focused helpers or hooks inside `src/`. Expose shared Tauri commands through `src-tauri/src/lib.rs`.
- Run `pnpm exec tsc --noEmit` before raising a PR to guarantee type safety; format rust code with `cargo fmt` and adhere to idiomatic TypeScript style (prefer const, explicit types on exports).

## Testing Guidelines
- No automated frontend harness ships with the template yet. When adding features, provide manual reproduction steps and, where feasible, include unit tests via `cargo test` for Rust modules or set up `vitest` under `src/__tests__/`.
- Ensure any new Tauri commands include either Rust-side tests or UI smoke verifications documented in the PR.

## Commit & Pull Request Guidelines
- Write imperative, descriptive commit messages (`feat: add window resize command`) and keep related changes squashed.
- Every PR should describe the change, note manual test results, and link to tracking issues. Include screenshots or screen recordings for UI-facing updates.
- Flag any capability or configuration changes to `tauri.conf.json` so reviewers can double-check security implications.

## Security & Configuration Tips
- Review `src-tauri/capabilities/` whenever enabling new permissions; default to least privilege.
- Never commit secrets. Environment-specific values belong in `.env` files kept out of version control.
