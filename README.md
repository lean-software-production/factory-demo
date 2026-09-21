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

You need Docker running on your host, and then either:

- the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers),
  to open the folder and choose *Reopen in Container*, or
- the [`devcontainer` CLI](https://github.com/devcontainers/cli), to start and
  stop the container from a host shell:

```sh
bin/dev up      # devcontainer up --workspace-folder .
bin/dev down    # stop the container
```

`bin/dev up` calls `devcontainer` directly, so without that CLI it fails with
`devcontainer: command not found`.

You can then run the commands from inside the container, as in a Codespace, or
drive it from your host:

```sh
bin/dev status              # runs `docker exec` against the running container
bin/dev ui                  # prints http://localhost:32276 and the token
bin/dev run implement-spec
```

The web UI is at `http://localhost:32276` here -- the address `bin/dev ui`
prints, and unlike a Codespace, plain `localhost` is correct. The PORTS panel
lists 32276 twice, once as *Dev Containers* (from `forwardPorts`) and once as
*Statically Forwarded* (from `appPort`). Both reach the same server, so the
duplicate row is expected rather than a misconfiguration.

`bin/dev` detects which side it is on: inside the container it runs the Fabro
CLI directly, and on the host it finds the container by its
`devcontainer.local_folder` label and uses `docker exec`. From the host the
container must be running.

### Connecting an LLM account

The [`fabro` dev container feature](https://github.com/lean-software-production/devcontainer-features/tree/main/src/fabro)
ships a setup wizard, which `.vscode/tasks.json` runs whenever VS Code opens the
folder -- in a Codespace and a local Dev Container alike. Starting the container
from a host shell with `bin/dev up` opens no editor, so run `bin/dev setup`
yourself in that case.

The wizard asks which LLM account to use. Choosing OpenAI signs you in with a
ChatGPT or Codex subscription over an OAuth device code -- it prints a URL and a
short code, and you enter the code in a browser. Because nothing calls back to
`localhost`, the same flow works in a browser-based Codespace, in VS Code
Desktop, and over SSH. Anthropic and OpenRouter prompt for an API key instead.

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

The workflow pins neither provider nor model, so a run uses what the wizard
wrote to `[run.model]` in `~/.fabro/settings.toml`. For OpenAI that is a
specific model, `gpt-5.6-luna`, rather than the provider's own default. Override
either per run:

```sh
bin/dev run implement-spec --provider openai --model gpt-5.4-mini
```

Fabro can use a ChatGPT/Codex subscription through OpenAI OAuth. Its documented
Anthropic integration requires separately billed API credentials; a Claude
subscription alone is not sufficient.
