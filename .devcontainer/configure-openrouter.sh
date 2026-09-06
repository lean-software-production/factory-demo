#!/bin/sh
set -eu

settings="${HOME}/.fabro/settings.toml"

if [ ! -f "${settings}" ]; then
    echo "Run 'fabro install' first." >&2
    exit 1
fi

if ! grep -q '^\[llm\.providers\.openrouter\]$' "${settings}"; then
    printf '\n[llm.providers.openrouter]\nenabled = true\n' >> "${settings}"
fi

fabro server start
fabro provider login --provider openrouter
