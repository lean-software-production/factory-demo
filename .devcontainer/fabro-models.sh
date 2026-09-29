#!/usr/bin/env bash
# Adds the OpenRouter models this demo uses that Fabro's built-in catalog lacks.
#
# Runs from postStartCommand and from the VS Code setup task, before
# `fabro-setup`. The wizard only pins a default model the catalog serves, so
# glm-5.3-flash must be declared first.
#
# Model catalog entries are server settings: Fabro reads [llm] only from
# ~/.fabro/settings.toml, not from .fabro/project.toml. The entries are inert
# until `fabro-setup` enables OpenRouter.
#
# glm-5.3-flash also becomes OpenRouter's default and probe model, the one
# `fabro provider login` tests the API key against. The built-in default,
# claude-sonnet-5, fails that test on keys whose guardrail blocks Claude.
#
# deepseek-v4-pro is sent as the dated snapshot deepseek/deepseek-v4-pro-0813,
# the version the demo's OpenRouter guardrail approves.
set -uo pipefail

settings="${HOME}/.fabro/settings.toml"

# No settings means neither the Feature nor `fabro-setup` has created them yet.
# The setup task runs this again; CLI users do the same as documented in README.
[[ -f "${settings}" ]] || exit 0

prefix="llm.providers.openrouter.models"
block="$(cat <<'EOF'
[llm.providers.openrouter.models.claude-sonnet-5]
default = false

[llm.providers.openrouter.models."glm-5.3-flash"]
display_name = "GLM 5.3 Flash"
api_id = "z-ai/glm-5.3-flash"
family = "glm-5"
default = true
probe = true
limits = { context_window = 1310720, max_output = 131072 }
features = { tools = true, vision = false, reasoning = true, reasoning_effort = "levels" }
controls = { reasoning_effort = ["high", "xhigh"] }
costs = { input_cost_per_mtok = 0.15, output_cost_per_mtok = 0.5 }

[llm.providers.openrouter.models.deepseek-v4-pro]
api_id = "deepseek/deepseek-v4-pro-0813"

[llm.providers.openrouter.models."glm-5.3"]
display_name = "GLM 5.3"
api_id = "z-ai/glm-5.3"
family = "glm-5"
limits = { context_window = 1310720, max_output = 131072 }
features = { tools = true, vision = false, reasoning = true, reasoning_effort = "levels" }
controls = { reasoning_effort = ["high", "xhigh"] }
costs = { input_cost_per_mtok = 1.4, output_cost_per_mtok = 4.4 }
EOF
)"

# Drop any earlier copy of these tables, then append the current ones. TOML
# rejects a table defined twice, and the server keeps its previous config
# rather than load a broken one.
tmp="$(mktemp "${settings}.tmp.XXXXXX")" || exit 1
awk -v prefix="[${prefix}." '
    /^\[/ {
        drop = ($0 == prefix "claude-sonnet-5]" \
             || $0 == prefix "\"glm-5.3-flash\"]" \
             || $0 == prefix "\"glm-5.3\"]" \
             || $0 == prefix "deepseek-v4-pro]")
    }
    !drop { print }
' "${settings}" | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}' > "${tmp}"
printf '\n%s\n' "${block}" >> "${tmp}"

if cmp -s "${tmp}" "${settings}"; then
    rm -f "${tmp}"
    exit 0
fi
mv "${tmp}" "${settings}"

# A running server reloads settings.toml a few seconds after it changes. Wait,
# so a `fabro-setup` that follows finds these models in the catalog. Skip this
# while OpenRouter is disabled: its models are not listed until it is enabled.
models() { fabro model list --provider openrouter --json 2>/dev/null; }
models | grep -q '"id"' || exit 0
for ((i = 0; i < 15; i++)); do
    m="$(models)"
    grep -q '"glm-5.3-flash"' <<<"${m}" && grep -q '"glm-5.3"' <<<"${m}" && exit 0
    sleep 1
done
exit 0
