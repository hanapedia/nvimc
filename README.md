# nvimc — Neovim in a container

A fully self-contained Neovim environment running in a Docker container. Everything is baked into the image at build time — plugins, LSP servers, language runtimes, and treesitter parsers. At runtime the container has no network access and only sees the directory you explicitly mount.

## Design

- **Base image**: Alpine edge
- **Plugins**: managed by [lazy.nvim](https://github.com/folke/lazy.nvim), each plugin is a git submodule under `plugins/` and referenced via local path — no network needed at runtime
- **LSP servers**: installed via `apk` or `zvm` at build time, configured with the native nvim 0.11 `vim.lsp.config` / `vim.lsp.enable` API (no Mason)
- **Treesitter parsers**: each parser source is a git submodule under `parsers/`, compiled from C source at build time
- **Clipboard**: kept separate from the host — use the terminal's native paste (`Ctrl+Shift+V`) to bring in host clipboard content
- **Network**: `--network=none` at runtime; the Go module cache is mounted read-only when opening a Go project

## Languages and LSPs

| Language | Runtime | LSP |
|----------|---------|-----|
| Go | `go` (apk) | `gopls` (apk) |
| C / C++ | `gcc` / `g++` (apk) | `clangd` via `clang-extra-tools` (apk) |
| Lua | — | `lua-language-server` (apk) |
| Zig | `zig` (zvm) | `zls` (zvm) |

## Setup

### Prerequisites

- Docker
- Git

### Clone

```sh
git clone --recurse-submodules https://github.com/hanapedia/nvimc.git
cd nvimc
```

The `--recurse-submodules` flag is required to pull all plugin and parser sources.

### Build

```sh
docker build -t nvimc .
```

The image is architecture-agnostic — build it on any host and it produces a native image for that architecture (amd64 or arm64). To pin a different Zig version:

```sh
docker build --build-arg ZIG_VERSION=0.14.0 -t nvimc .
```

To cross-compile for a different architecture (requires a multi-platform buildx builder):

```sh
docker buildx build --platform linux/arm64 -t nvimc .
```

### Install the run script

Copy `nvimc` somewhere on your `$PATH`:

```sh
cp nvimc ~/.local/bin/nvimc
```

## Usage

```sh
# Open a directory
nvimc /path/to/project

# Open a specific file
nvimc /path/to/file.go

# Defaults to the current directory
nvimc
```

The script automatically:
- Mounts the target directory (or the file's parent directory) at `/workspace`
- Mounts `$GOMODCACHE` (default: `~/go/pkg/mod`) read-only when `go.mod` is present
- Passes `TERM` and `COLORTERM` for correct true color rendering

For Go projects, run `go mod download` on the host first to populate the module cache before opening the project in the container.

## Repository structure

```
nvimc/
├── Dockerfile
├── nvimc              # run script
├── nvim/              # neovim config
│   ├── init.lua
│   └── lua/
├── plugins/           # lazy.nvim + all plugins as git submodules
└── parsers/           # treesitter parser sources as git submodules
```

## Updating a plugin or parser

Check out the new commit inside the submodule, then commit the updated gitlink in the parent repo:

```sh
git -C plugins/gitsigns.nvim fetch && git -C plugins/gitsigns.nvim checkout <new-commit>
git add plugins/gitsigns.nvim
git commit -sS -m "chore: update gitsigns.nvim"
```

Then rebuild the image.
