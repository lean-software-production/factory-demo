# Fabro Factory Demo

This repository is a small, readable example of a software factory built with
[Fabro](https://fabro.sh).

## Reference

A local snapshot of the official Fabro documentation is available at
[docs/reference/fabro](docs/reference/fabro/README.md).

## Implement spec

The `implement-spec` workflow reads the [Tetris specification](docs/spec.md),
writes `docs/plan.md`, and implements one validated plan step at a time.

## Getting started

This project runs inside a dev container, so the Fabro CLI, a local Fabro
server, and the setup wizard all come with it. There are two ways to open it.

### In a GitHub Codespace

Create a Codespace on this repository. Everything is installed for you, and the
Fabro server starts automatically on port 32276.

Run the commands in the Codespace's own terminal:

```sh
bin/dev status              # provider and server status
bin/dev ui                  # web UI URL and development token
bin/dev run implement-spec  # run a workflow
```

To open the web UI, use the URL from `bin/dev ui` -- the forwarded
`*.app.github.dev` address, not `localhost`. Open it from the editor's PORTS
panel if the GitHub sign-in handshake stalls. The UI asks for the development
token that `bin/dev ui` prints.

Forwarded ports are private to you by default.

`bin/dev up` and `bin/dev down` are for a local Dev Container only.

### Running locally via VS Code

Open the repository in VS Code and reopen in the container, or start and stop it from your host with:

```sh
bin/dev up      # devcontainer up --workspace-folder .
bin/dev down    # stop the container
```

You can then work either from inside the container, exactly as in a Codespace above, or drive it from your host with the same commands:

```sh
bin/dev status              # runs `docker exec` against the running container
bin/dev ui                  # prints http://localhost:32276 and the token
bin/dev run implement-spec
```

`bin/dev` detects which side it is on: inside the container it runs the Fabro CLI directly, and on the host it finds the container by its `devcontainer.local_folder` label and uses `docker exec`. From the host the container must be running.

### Connecting an LLM account

The [`fabro` dev container feature](https://github.com/lean-software-production/devcontainer-features/tree/main/src/fabro)
opens a setup wizard the first time you open the project. It asks which LLM
account to use. Choosing OpenAI signs you in with a ChatGPT or Codex
subscription over an OAuth device code -- it prints a URL and a short code, and
you enter the code in a browser. Because nothing calls back to `localhost`, the
same flow works in a browser-based Codespace, in VS Code Desktop, and over SSH.
Anthropic and OpenRouter prompt for an API key instead.

If the wizard does not appear, or you want to change providers later:

```sh
bin/dev setup         # run the wizard, then restart the server
fabro-setup --force   # switch providers, or retry a failed sign-in
fabro-status          # report which credentials are configured
```

Credentials are stored in the Fabro server vault under `~/.fabro`. A rebuild
discards them and the wizard runs again. Never commit an API key to this
repository.

### Choosing a provider per run

The workflow does not pin a provider, so it uses whichever one the wizard
configured, with that provider's default model. Override either per run:

```sh
fabro run implement-spec --provider openai --model gpt-5.4-mini
```

Fabro can use a ChatGPT/Codex subscription through OpenAI OAuth. Its documented
Anthropic integration requires separately billed API credentials; a Claude
subscription alone is not sufficient.
