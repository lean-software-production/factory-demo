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

Open this repository in a GitHub Codespace or a local Dev Container. The
[`fabro` dev container feature](https://github.com/lean-software-production/devcontainer-features/tree/main/src/fabro)
installs the CLI, starts a local Fabro server, and opens a setup wizard the
first time you open the project.

The wizard asks which LLM account to use. Choosing OpenAI signs you in with a
ChatGPT or Codex subscription over an OAuth device code -- it prints a URL and a
short code, and you enter the code in a browser. Because nothing calls back to
`localhost`, the same flow works in a browser-based Codespace, in VS Code
Desktop, and over SSH. Anthropic and OpenRouter prompt for an API key instead.

If the wizard does not appear, or you want to change providers later:

```sh
fabro-setup           # run the wizard, or exit quietly if already configured
fabro-setup --force   # switch providers, or retry a failed sign-in
fabro-status          # report which credentials are configured
```

Credentials are stored in the Fabro server vault under `~/.fabro`. Never commit
an API key to this repository.

Then run the factory:

```sh
fabro run factory
```

The workflow does not pin a provider, so it uses whichever one the wizard
configured, with that provider's default model. Override either per run:

```sh
fabro run factory --provider openai --model gpt-5.4-mini
```

Fabro can use a ChatGPT/Codex subscription through OpenAI OAuth. Its documented
Anthropic integration requires separately billed API credentials; a Claude
subscription alone is not sufficient.
