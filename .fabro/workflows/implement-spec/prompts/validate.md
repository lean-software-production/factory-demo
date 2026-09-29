Read `docs/spec.md` and `docs/plan.md`. Do not change implementation files.

Validate the first unchecked plan step using appropriate tests and inspection.

- If it fails, leave it unchecked, report failure, route to `Continue`, and set
  `validation_feedback` to specific corrective instructions.
- If it passes, mark it checked. Route to `Continue` if unchecked steps remain,
  clearing `validation_feedback`.
- If no unchecked steps remain, validate the complete implementation against
  the specification. Route to `Done` on success; otherwise route to `Continue`
  with actionable `validation_feedback`.

Return only the routing object.
