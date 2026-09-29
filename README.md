# Fabro Factory Demo

This repository is a small, readable example of a software factory built with
[Fabro](https://fabro.sh).

## Reference

A local snapshot of the official Fabro documentation is available at
[docs/reference/fabro](docs/reference/fabro/README.md).

## Implement spec

The `implement-spec` workflow reads the [Tetris specification](docs/spec.md),
writes `docs/plan.md`, and implements one validated plan step at a time.

Before implementation starts, three open-weight models on OpenRouter (Kimi K3,
DeepSeek V4 Pro and GLM 5.3) review the plan in parallel. Each returns its top
three suggestions, and a final step updates `docs/plan.md` with them. The
implementation step also runs on GPT-5.6 Luna through OpenRouter, and the
remaining steps use GLM 5.3 Flash, the server default. The workflow therefore
needs an OpenRouter API key. The setup wizard offers OpenRouter first and
enables it on the Fabro server for you. See the
[OpenRouter guide](docs/reference/fabro/integrations/openrouter.md).

## Getting started

This project runs inside a dev container, which provides the Fabro CLI, a local
Fabro server, and a setup wizard. Run the Fabro commands below from a terminal
inside the container.

### In a GitHub Codespace

Create a Codespace on this repository. The container and Fabro server start
automatically, and the setup wizard opens in the terminal.

Once setup is complete, check the server and run the workflow:

```sh
fabro-status
fabro server status
fabro run implement-spec --environment local
```

The `local` environment runs the workflow in the checked-out repository. Keep
this option in a Codespace: its dev container does not expose a Docker daemon,
which Fabro's default Docker environment requires.

To use the web UI, open port 32276 from the editor's PORTS panel. Use the
forwarded `*.app.github.dev` address rather than `localhost`. The UI asks for
the development token, which you can print from the Codespace terminal:

```sh
cat ~/.fabro/storage/server.dev-token
```

Open the port from the PORTS panel if the GitHub sign-in handshake stalls.
Forwarded ports are private to you by default.

### Running locally

You need Docker running on your host. You can use either:

- the [VS Code Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers):
  open the repository and choose *Reopen in Container*; or
- the [`devcontainer` CLI](https://github.com/devcontainers/cli): from the
  repository root, start the container and enter a shell with:

  ```sh
  devcontainer up
  devcontainer exec bash
  ```

VS Code opens the setup wizard automatically. The CLI does not open an editor,
so run the wizard yourself after entering the container:

```sh
bash .devcontainer/fabro-models.sh
fabro-setup
bash .devcontainer/fabro-bind.sh
```

The first command adds the GLM 5.3 models to the server's catalog (see
[Model catalog](#model-catalog)). The last makes the newly configured server
reachable through Docker's published port. Both are harmless to run again.

Then use the same Fabro commands as in a Codespace:

```sh
fabro-status
fabro server status
fabro run implement-spec --environment local
```

The local web UI is at <http://localhost:32276>. Print its development token
from inside the container:

```sh
cat ~/.fabro/storage/server.dev-token
```

VS Code's PORTS panel lists 32276 twice, once as *Dev Containers* and once as
*Statically Forwarded*. Both entries reach the same server; the duplicate is
expected.

### Connecting an LLM account

The [`fabro` dev container feature](https://github.com/lean-software-production/devcontainer-features/tree/main/src/fabro)
provides `fabro-setup`. The wizard asks which LLM account to use, offering
OpenRouter first because the workflow's reviewers run there. OpenRouter and
Anthropic prompt for an API key. Fabro ships OpenRouter disabled, so choosing
it also enables it in `~/.fabro/settings.toml` before signing in. Choosing
OpenAI signs you in with a ChatGPT or Codex subscription using an OAuth device
code.

If the wizard does not appear, or you want to change providers later, run:

```sh
fabro-setup           # configure Fabro if needed
fabro-setup --force   # switch providers or retry a failed sign-in
fabro-status          # report which credentials are configured
```

Credentials are stored in the Fabro server vault under `~/.fabro`, never in the
repository. Rebuilding the container discards them.

### Model catalog

Fabro's built-in OpenRouter catalog does not include GLM 5.3 or GLM 5.3 Flash.
[`.devcontainer/fabro-models.sh`](.devcontainer/fabro-models.sh) declares them
in `~/.fabro/settings.toml`; Fabro reads model definitions only from the
server's settings, not from `.fabro/project.toml`. The script runs when the
container starts and again before the setup wizard.

It also makes GLM 5.3 Flash OpenRouter's default model and the one
`fabro provider login` tests your API key against. Fabro's own choice,
Claude Sonnet 5, fails that test on keys whose OpenRouter guardrail blocks
Claude models. It also sends DeepSeek V4 Pro requests to the dated snapshot
`deepseek/deepseek-v4-pro-0813`, the version the demo's OpenRouter guardrail
approves.

The model catalog must exist before the wizard runs. If the wizard reports that
`glm-5.3-flash` is not in the catalog, run `bash .devcontainer/fabro-models.sh`
and then `fabro-setup --force`.

### Choosing a provider per run

The workflow pins the plan reviewers and the implementation step to OpenRouter
models; these always win over run options. The other steps (plan, collecting
reviews, refining the plan and validation) use the run's default model. The
setup wizard configures the server defaults: this dev container asks it for
OpenRouter with `glm-5.3-flash`. Override either for one run with Fabro's own
options:

```sh
fabro run implement-spec --environment local --provider openai --model gpt-5.4-mini
```

Fabro can use a ChatGPT or Codex subscription through OpenAI OAuth. Its
documented Anthropic integration requires separately billed API credentials; a
Claude subscription alone is not sufficient.
