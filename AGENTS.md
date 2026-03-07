# Repository Guidelines

## Project Structure & Module Organization
- `flake.nix` defines the Neovim package, plugins, and runtime dependencies via Nix.
- `flake.lock` pins upstream inputs. Update only when intentionally upgrading.
- `vimrc` contains core Vimscript settings and keymaps and bootstraps Lua with `:lua require('init')`.
- `lua/init.lua` is the Lua entrypoint; `lua/plugins.lua` holds plugin setup, keymaps, and LSP configuration.
- `README.md` is a keymap cheat sheet, not a build guide.

## Build, Test, and Development Commands
- `nix run .` launches the packaged Neovim (uses `defaultApp`).
- `nix build .#nvim` builds the wrapped Neovim; run `./result/bin/nvim` to test the build artifact.
- `nix flake update` refreshes pinned inputs in `flake.lock`.

## Coding Style & Naming Conventions
- Indentation: 2 spaces for Lua and Vimscript (see `set shiftwidth=2` and `set expandtab` in `vimrc`).
- Keep Lua modules flat under `lua/` and use `require("...")` with matching filenames.
- Prefer small, descriptive function names for keymap helpers (e.g., `toggle_nav_focus`, `open_file`).

## Testing Guidelines
- There is no automated test suite. Use a manual smoke test:
- Run `nix run .` and verify startup, tree view (`<leader>t`), and LSP formatting on save.
- When changing plugins or LSP settings, confirm the relevant language server starts without errors.

## Commit & Pull Request Guidelines
- Commit messages are short, imperative, and lowercase. Examples: `add clangd`, `go to def`.
- Keep commits focused on one change category (plugin change, keymap change, or tooling update).
- PRs should include:
- A brief summary of the behavior change.
- The command(s) used to validate (`nix run .`, `nix build .#nvim`).
- Any user-facing keymap updates listed in `README.md`.

## Configuration Tips
- Adding a new plugin typically requires:
- Adding it to `packages.myPlugins.start` in `flake.nix`.
- Adding configuration in `lua/plugins.lua` and relevant keymaps.
- Avoid editing `flake.lock` by hand; use `nix flake update`.
