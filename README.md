# Fabro Factory Demo

This repository is a small, readable example of a software factory built with
[Fabro](https://fabro.sh).

## Reference

A local snapshot of the official Fabro documentation is available at
[docs/reference/fabro](docs/reference/fabro/README.md).

## Implement spec

The `implement-spec` workflow reads the [Tetris specification](docs/spec.md),
writes `docs/plan.md`, and implements one validated plan step at a time.

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
bin/dev setup           # run the wizard, or exit quietly if already configured
bin/dev setup --force   # switch providers, or retry a failed sign-in
bin/dev status          # report which credentials are configured
```

Credentials are stored in the Fabro server vault under `~/.fabro`. Never commit
an API key to this repository.

Then run the workflow:

```sh
bin/dev run implement-spec
```

List available workflows or open the Fabro UI:

```sh
bin/dev run
bin/dev ui
```

`bin/dev` works both from the host with a local Dev Container and inside a
GitHub Codespace. In a Codespace, `bin/dev ui` prints the forwarded Codespaces
URL instead of a localhost URL.

Fabro can use a ChatGPT/Codex subscription through OpenAI OAuth. Its documented
Anthropic integration requires separately billed API credentials; a Claude
subscription alone is not sufficient.
