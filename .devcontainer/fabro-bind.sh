#!/usr/bin/env bash
# Binds the Fabro server to the interface this container is actually reached on.
#
# Runs from postStartCommand, after the Fabro Feature's own autostart hook.
#
# The Feature starts the server on the address in ~/.fabro/settings.toml, which
# `fabro install` writes as 127.0.0.1 -- the container's loopback. That is right
# for a Codespace, where GitHub forwards the port from inside the container.
#
# It is wrong for a local Dev Container. There the browser arrives through the
# `appPort` publish in devcontainer.json, and Docker forwards that to the
# container's eth0 address, never to its loopback. A loopback-only server leaves
# docker-proxy with nothing to connect to, so it accepts the connection and then
# tears it down: ERR_CONNECTION_RESET in the browser.
#
# `fabro server --bind` does not persist, so patch the setting the Feature reads
# rather than only restarting -- otherwise this reverts on the next start.
set -uo pipefail

port=32276
settings="${HOME}/.fabro/settings.toml"

# A Codespace is already correct, and loopback is the smaller exposure.
if [[ "${CODESPACES:-}" == "true" || -n "${CODESPACE_NAME:-}" ]]; then
  exit 0
fi

# No settings means `fabro-setup` has not run yet; it will start the server, and
# the next start picks this up.
[[ -f "${settings}" ]] || exit 0

bind="0.0.0.0:${port}"

# Rewrite `address` only within the [server.listen] table.
if ! grep -q "^address[[:space:]]*=[[:space:]]*\"${bind}\"" "${settings}"; then
  tmp="$(mktemp)"
  awk -v bind="${bind}" '
    /^\[/ { in_listen = ($0 == "[server.listen]") }
    in_listen && /^address[[:space:]]*=/ { printf "address = \"%s\"\n", bind; next }
    { print }
  ' "${settings}" > "${tmp}" && mv "${tmp}" "${settings}"
fi

# Restart only when the running server is on the wrong address; `fabro server
# status` reports the bind it came up with -- on stderr, not stdout.
if fabro server status 2>&1 | grep -qF "on ${bind}"; then
  exit 0
fi

fabro server restart --bind "${bind}" >/dev/null 2>&1 || true
exit 0
