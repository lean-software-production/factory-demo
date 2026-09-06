# Fabro Factory Demo

This repository is a small, readable example of a software factory built with
[Fabro](https://fabro.sh).

## Reference

A local snapshot of the official Fabro documentation is available at
[docs/reference/fabro](docs/reference/fabro/README.md).

## Factory

The factory reads the [Tetris specification](docs/spec.md), writes
`docs/plan.md`, and implements one validated plan step at a time.

## Run in a dev container

Open this repository in a GitHub Codespace or a Dev Container. Node.js and a
pinned version of Fabro are already installed.

On first use, configure a local Fabro server and connect it to OpenRouter. You
can skip LLM setup when `fabro install` prompts for it.

```sh
fabro install
.devcontainer/configure-openrouter.sh
```

The second command prompts for an OpenRouter API key and stores it in Fabro's
server vault. Never commit an API key to this repository.

Run it with:

```sh
fabro run factory
```

The workflow uses `claude-sonnet-4-6` through OpenRouter by default. To use a
direct provider instead, authenticate with it and override the defaults:

```sh
# ChatGPT/Codex subscription (OpenAI OAuth) or OpenAI API
fabro provider login --provider openai
fabro run factory --provider openai --model gpt-5.4-mini

# Anthropic API
fabro provider login --provider anthropic
fabro run factory --provider anthropic --model claude-sonnet-4-6
```

Fabro can use a ChatGPT/Codex subscription through OpenAI OAuth. Its documented
Anthropic integration requires separately billed API credentials; a Claude
subscription alone is not sufficient.
