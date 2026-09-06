FROM debian:bookworm-slim

ARG TARGETARCH
ARG AQUA_VERSION=2.41.0
ARG GO_VERSION=1.26.3
ARG GOPLS_VERSION=v0.21.1
ARG DEV_UID=1000
ARG DEV_GID=100

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    wget \
    gcc \
    g++ \
    make \
    libc6-dev \
    clangd \
    && rm -rf /var/lib/apt/lists/*

# Create dev user
RUN groupadd -g $DEV_GID dev 2>/dev/null || true && \
    useradd -m -u $DEV_UID -g $DEV_GID -d /home/dev -s /bin/sh dev

# Install aqua
RUN AQUA_ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "arm64" || echo "amd64") && \
    wget -qO /tmp/aqua.tar.gz \
      "https://github.com/aquaproj/aqua/releases/download/v${AQUA_VERSION}/aqua_linux_${AQUA_ARCH}.tar.gz" && \
    tar -xzf /tmp/aqua.tar.gz -C /usr/local/bin aqua && \
    rm /tmp/aqua.tar.gz
ENV AQUA_ROOT_DIR=/usr/local/share/aquaproj-aqua
ENV AQUA_GLOBAL_CONFIG=/aqua.yaml

# Install tools via aqua, then link real binaries into PATH directly so the
# aqua proxy is never invoked at runtime (avoids interference from project-level aqua.yaml)
COPY aqua.yaml aqua-checksums.json /
RUN aqua install --all && \
    for tool in nvim rg lua-language-server zig zls; do \
      real="$(aqua which "$tool" 2>/dev/null)" && \
      [ -f "$real" ] && ln -sf "$real" "/usr/local/bin/$tool" || true; \
    done

# Install Go from go.dev
RUN wget -qO /tmp/go.tar.gz \
      "https://go.dev/dl/go${GO_VERSION}.linux-${TARGETARCH}.tar.gz" && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz
ENV GOPATH=/home/dev/go
ENV PATH="/usr/local/go/bin:/home/dev/go/bin:${PATH}"

# Install gopls
RUN HOME=/home/dev go install golang.org/x/tools/gopls@${GOPLS_VERSION}

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

RUN chown -R $DEV_UID:$DEV_GID /home/dev

USER dev
WORKDIR /workspace
ENTRYPOINT ["nvim"]
