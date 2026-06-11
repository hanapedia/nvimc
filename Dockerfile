FROM alpine:3.23.4

RUN apk add --no-cache \
    neovim \
    git \
    gcc \
    g++ \
    make \
    musl-dev \
    ca-certificates \
    ripgrep \
    xz \
    libbpf-dev \
    elfutils-dev \
    zlib-dev \
    # linux-headers \
    clang-extra-tools \
    lua-language-server

# Create dev user (UID 1000, GID 100 = users group, which exists on Alpine by default)
RUN adduser -D -u 1000 -G users -h /home/dev dev

# Install Go from go.dev
ARG GO_VERSION=1.26.1
ARG TARGETARCH
RUN wget -qO /tmp/go.tar.gz \
      "https://go.dev/dl/go${GO_VERSION}.linux-${TARGETARCH}.tar.gz" && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz
ENV GOPATH=/home/dev/go
ENV PATH="/usr/local/go/bin:/home/dev/go/bin:${PATH}"

# Install gopls
ARG GOPLS_VERSION=v0.21.1
RUN HOME=/home/dev go install golang.org/x/tools/gopls@${GOPLS_VERSION}

# Install zig and zls via zvm
ARG ZVM_VERSION=v0.8.20
ARG ZIG_VERSION=0.16.0
RUN HOME=/home/dev go install github.com/tristanisham/zvm@${ZVM_VERSION} && \
    HOME=/home/dev zvm i --zls ${ZIG_VERSION} && \
    HOME=/home/dev zvm use ${ZIG_VERSION}
ENV PATH="/home/dev/.zvm/bin:${PATH}"

# Copy plugins, parsers, and nvim config
COPY plugins/ /plugins/
COPY parsers/ /parsers/
COPY nvim/ /home/dev/.config/nvim/

# Compile treesitter parsers
RUN <<'SCRIPT'
set -e
OUT=/home/dev/.local/share/nvim/site/parser
mkdir -p $OUT

compile() {
  name=$1
  src=/parsers/tree-sitter-${name}/src
  srcs="$src/parser.c"
  [ -f "$src/scanner.c" ] && srcs="$srcs $src/scanner.c"
  if [ -f "$src/scanner.cc" ]; then
    g++ -shared -fPIC -O2 -I"$src" $srcs "$src/scanner.cc" -o "$OUT/${name}.so"
  else
    gcc -shared -fPIC -O2 -I"$src" $srcs -o "$OUT/${name}.so"
  fi
}

for lang in go c lua zig vim query yaml json bash fish; do
  compile $lang
done

# markdown lives in two subdirs of the same repo
# args: <subdir> <output name>
compile_md() {
  subdir=$1
  outname=$2
  src=/parsers/tree-sitter-markdown/${subdir}/src
  srcs="$src/parser.c"
  [ -f "$src/scanner.c" ] && srcs="$srcs $src/scanner.c"
  gcc -shared -fPIC -O2 -I"$src" $srcs -o "$OUT/${outname}.so"
}
compile_md tree-sitter-markdown markdown
compile_md tree-sitter-markdown-inline markdown_inline
SCRIPT

RUN chown -R dev:users /home/dev

USER dev
WORKDIR /workspace
ENTRYPOINT ["nvim"]
