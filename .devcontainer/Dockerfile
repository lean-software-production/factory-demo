FROM mcr.microsoft.com/devcontainers/javascript-node:1-22-bookworm

ARG FABRO_VERSION=0.254.0
ARG TARGETARCH

RUN set -eu; \
    case "${TARGETARCH}" in \
        amd64) target="x86_64-unknown-linux-musl" ;; \
        arm64) target="aarch64-unknown-linux-musl" ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    archive="fabro-${target}.tar.gz"; \
    url="https://github.com/fabro-sh/fabro/releases/download/v${FABRO_VERSION}"; \
    curl -fsSLO "${url}/${archive}"; \
    curl -fsSLO "${url}/${archive}.sha256"; \
    sha256sum --check "${archive}.sha256"; \
    tar -xzf "${archive}"; \
    install -m 0755 "fabro-${target}/fabro" /usr/local/bin/fabro; \
    rm -rf "${archive}" "${archive}.sha256" "fabro-${target}"; \
    fabro --version
