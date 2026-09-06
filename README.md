# nvimc — Neovim in a container

A fully self-contained Neovim environment running in a Docker container. Everything is baked into the image at build time — plugins, LSP servers, language runtimes, and treesitter parsers. At runtime the container has no network access and only sees the directory you explicitly mount.

## Design

- **Base image**: `debian:bookworm-slim`
- **Plugins**: managed by [lazy.nvim](https://github.com/folke/lazy.nvim), each plugin is a git submodule under `plugins/` and referenced via local path — no network needed at runtime
- **Tool management**: [aqua](https://aquaproj.github.io/) manages editor tools and LSP servers declaratively via `aqua.yaml`; only minimal build tools (`gcc`, `make`) are installed via apt
- **LSP servers**: configured with the native nvim 0.11 `vim.lsp.config` / `vim.lsp.enable` API (no Mason)
- **Treesitter parsers**: each parser source is a git submodule under `parsers/`, compiled from C source at build time
- **C headers**: not embedded in the image — mount project-specific headers at runtime (see [C headers](#c-headers) below)
- **Clipboard**: kept separate from the host — use the terminal's native paste (`Ctrl+Shift+V`) to bring in host clipboard content
- **Network**: `--network=none` at runtime; the Go module cache is mounted read-only when opening a Go project

## Languages and LSPs

| Language | Runtime | LSP | Managed by |
|----------|---------|-----|------------|
| Go | `go` (go.dev) | `gopls` | `go install` |
| C / C++ | `gcc` / `g++` (apt) | `clangd` | aqua |
| Lua | — | `lua-language-server` | aqua |
| Zig | `zig` | `zls` | aqua |

## Setup

### Prerequisites

- Docker
- Git
- [task](https://taskfile.dev) (optional, for the Taskfile shortcuts)

### Clone

```sh
git clone --recurse-submodules --shallow-submodules https://github.com/hanapedia/nvimc.git
cd nvimc
```

`--recurse-submodules` pulls all plugin and parser sources. `--shallow-submodules` clones each submodule at depth 1 (the pinned commit only, no history), which significantly reduces download size.

### Build

```sh
task build
```

This automatically passes your current user's UID/GID as build arguments so files created inside the container are owned by you on the host.

Without task:

```sh
docker build \
  --build-arg DEV_UID=$(id -u) \
  --build-arg DEV_GID=$(id -g) \
  -t nvimc .
```

To pin a different tool version, pass the corresponding build argument:

```sh
docker build --build-arg GO_VERSION=1.23.0 -t nvimc .
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
- Mounts C headers when a `.dev-headers/` directory exists in the workspace, or when `-H` is passed
- Passes `TERM` and `COLORTERM` for correct true color rendering

For Go projects, run `go mod download` on the host first to populate the module cache before opening the project in the container.

### C headers

C headers are not embedded in the image. For projects that require them (eBPF, kernel modules, system libraries), provide a directory of headers at runtime.

**Explicit path** with `-H`:

```sh
nvimc -H /path/to/headers /path/to/project
```

**Auto-detection** — if a `.dev-headers/` directory exists at the project root, it is mounted automatically:

```sh
ls myproject/.dev-headers/
# bpf/  linux/  asm/

nvimc myproject/   # headers picked up without any flag
```

In both cases the headers directory is mounted read-only at `/usr/local/include` inside the container, which is searched by default by both `gcc` and `clangd`.

**Example: eBPF project using host headers**

Install the required packages on the host once, then point nvimc at the system include directory:

```sh
# Debian/Ubuntu
sudo apt install libbpf-dev linux-headers-$(uname -r)

nvimc -H /usr/include myproject/
```

**Example: self-contained project headers**

Copy only the headers your project needs into `.dev-headers/` so the setup works on any host:

```sh
mkdir -p myproject/.dev-headers

# Copy relevant headers from the host
cp -r /usr/include/bpf         myproject/.dev-headers/
cp -r /usr/include/linux       myproject/.dev-headers/
cp -r /usr/include/asm         myproject/.dev-headers/
cp -r /usr/include/asm-generic myproject/.dev-headers/

nvimc myproject/   # auto-detected, no flag needed
```

Add `.dev-headers/` to `.gitignore` if the headers are host-specific, or commit them for a fully reproducible checkout.

## Taskfile

| Task | Description |
|------|-------------|
| `task build` | Build the image with current user's UID/GID |
| `task build-no-cache` | Rebuild without Docker layer cache |
| `task update-checksums` | Regenerate `aqua-checksums.json` after editing `aqua.yaml` |
| `task submodules` | Initialize and update all git submodules to their pinned commits |

## Repository structure

```
nvimc/
├── Dockerfile
├── Taskfile.yaml
├── aqua.yaml              # aqua tool declarations
├── aqua-checksums.json    # aqua checksum verification
├── nvimc                  # run script
├── nvim/                  # neovim config
│   ├── init.lua
│   └── lua/
├── plugins/               # lazy.nvim + all plugins as git submodules
└── parsers/               # treesitter parser sources as git submodules
```

## Updating a plugin or parser

Check out the new commit inside the submodule, then commit the updated gitlink in the parent repo:

```sh
git -C plugins/gitsigns.nvim fetch && git -C plugins/gitsigns.nvim checkout <new-commit>
git add plugins/gitsigns.nvim
git commit -sS -m "chore: update gitsigns.nvim"
```

Then rebuild the image.

## Updating a tool

Edit the version in `aqua.yaml`, regenerate the checksums, and rebuild:

```sh
# 1. Edit aqua.yaml — bump the version of the relevant package
# 2. Regenerate checksums
task update-checksums
# 3. Rebuild
task build
```
