#!/usr/bin/env bash
# Adds the OpenRouter models the implement-spec workflow needs that Fabro's
# built-in catalog lacks or routes wrongly.
#
# Runs from postStartCommand and, after `fabro-setup`, from the VS Code setup
# task. The fabro Feature's own `model` option covers the server default,
# glm-5.3-flash; this covers the models the workflow pins:
#
#   glm-5.3          the GLM plan reviewer, missing from the catalog
#   deepseek-v4-pro  the DeepSeek plan reviewer, sent as the dated snapshot
#                    deepseek/deepseek-v4-pro-0813, the version the demo's
#                    OpenRouter guardrail approves
#
# Model catalog entries are server settings: Fabro reads [llm] only from
# ~/.fabro/settings.toml, not from .fabro/project.toml. The entries are inert
# until `fabro-setup` enables OpenRouter.
set -uo pipefail

settings="${HOME}/.fabro/settings.toml"

# No settings means neither the Feature nor `fabro-setup` has created them yet.
# The setup task runs this again; CLI users do the same as documented in README.
[[ -f "${settings}" ]] || exit 0

block="$(cat <<'EOF'
[llm.providers.openrouter.models."glm-5.3"]
display_name = "GLM 5.3"
api_id = "z-ai/glm-5.3"
family = "glm-5"
limits = { context_window = 1310720, max_output = 131072 }
features = { tools = true, vision = false, reasoning = true, reasoning_effort = "levels" }
controls = { reasoning_effort = ["high", "xhigh"] }
costs = { input_cost_per_mtok = 1.4, output_cost_per_mtok = 4.4 }

[llm.providers.openrouter.models.deepseek-v4-pro]
api_id = "deepseek/deepseek-v4-pro-0813"
EOF
)"

# Drop any earlier copy of these tables, then append the current ones. TOML
# rejects a table defined twice, and the server keeps its previous config
# rather than load a broken one. Table names compare with quotes removed, as
# the Feature's own settings edits do.
tmp="$(mktemp "${settings}.tmp.XXXXXX")" || exit 1
awk '
    function norm(s) { gsub(/[][" \t]/, "", s); return s }
    /^\[/ {
        name = norm($0)
        drop = (name == "llm.providers.openrouter.models.glm-5.3" \
             || name == "llm.providers.openrouter.models.deepseek-v4-pro")
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
# so a run started straight afterwards finds glm-5.3. Skip this while
# OpenRouter is disabled: its models are not listed until it is enabled.
models() { fabro model list --provider openrouter --json 2>/dev/null; }
models | grep -q '"id"' || exit 0
for ((i = 0; i < 15; i++)); do
    models | grep -q '"glm-5.3"' && exit 0
    sleep 1
done
exit 0
