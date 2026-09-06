Read `docs/spec.md` and `docs/plan.md`. Do not change implementation files.

If the plan has an unchecked step, validate the first one using appropriate
tests and direct inspection.

If that step fails, leave it unchecked and return:

```json
{"outcome":"failed","preferred_next_label":"Continue","failure_reason":"concise reason","context_updates":{"validation_feedback":"specific instructions for fixing the step"}}
```

If that step passes, mark it checked in `docs/plan.md`. If another unchecked
step remains, return:

```json
{"outcome":"succeeded","preferred_next_label":"Continue","context_updates":{"validation_feedback":""}}
```

When no unchecked steps remain, validate the entire implementation against
`docs/spec.md`.

If final validation fails, return:

```json
{"outcome":"failed","preferred_next_label":"Continue","failure_reason":"concise reason","context_updates":{"validation_feedback":"specific instructions for fixing the complete implementation"}}
```

If final validation passes, return:

```json
{"outcome":"succeeded","preferred_next_label":"Done","context_updates":{"validation_feedback":""}}
```

Your final response must contain only the applicable JSON object. Use
`validation_feedback` only for actionable corrective guidance; do not put test
logs or general commentary in it.
