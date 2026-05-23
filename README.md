# Neovim in a container

- Build a container with nvim and all the dependencies installed at build time.
    - nvim plugins
        - each imported into this repo as git submodule and referenced locally via Lazy.
    - lsp servers
    - treesitter for common languages
- Run as rootless and network isolated container with volume mounts.


1. Base image — What OS/distro? (Alpine for small size, Ubuntu/Debian for compatibility, Arch for latest packages?)
 -> alpine to keep everything small.

2. Neovim version — Pre-built binary, build from source, or package manager?
 -> let's use package manager. it should be available on apk

3. Plugin management — You mention git submodules + Lazy's local path spec. How do you want the submodule structure organized? One flat directory like plugins/ with all repos?
 -> One flat directory sounds nice. just copy them when building.
4. LSP servers — Which language servers to include? Installed via Mason at build time, or manually?
 -> let's go with manual install. I only work with limited sets of LSPs. I was thinking about removing Mason dependency entirely, especially with recent improvements around lsps in nvim 0.11.
5. Volume mounts — What gets mounted at runtime? Just your workspace files, or also parts of the config (for live editing)?
 -> config must be in the container. I don't really get your point. Configs are not meant to edited in the container as well. So mount just the files/dirs I want to open in nvim.
6. Network isolation — --network=none at runtime? Or a custom network with limited access?
 -> no internet access is ideal.
7. Rootless — Podman or Docker with --user? User namespace remapping?
 -> anything without host root access is fine.
