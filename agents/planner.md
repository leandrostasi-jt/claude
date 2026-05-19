# Planner SDD Addition

Add this section to `agents/planner.md`.

## SDD Planning

When planning work under `doc/playbook/<feature>/`, follow:

- `rules/sdd/workflow.md`

## SDD Planning Inputs

When the requested work is under `doc/playbook/<feature>/`, you MUST read before planning:

- `doc/playbook/<feature>/spec.md`
- `doc/playbook/<feature>/research.md`
- every markdown file under `doc/playbook/<feature>/delivery_artifacts/`
- any ADR explicitly referenced by the spec, research, or delivery artifacts
- relevant repository rules from `rules/`

If `research.md` is missing, stop and ask the user to run `/sdd-research` first.

If `delivery_artifacts/` is missing or contains no markdown files, stop and ask the user to run `/sdd-delivery-artifacts` first.

Do not assume fixed delivery artifact filenames.
Use the actual files present under `delivery_artifacts/`.

Use `spec.md` as the behavioural source of truth.
Use `research.md` as the repository-evidence source of truth.
Use `delivery_artifacts/` as the production-scope source of truth.

Do not plan from an unrefined `spec.md` if `research.md` exists and `sdd-refine` has not been run.
A refined spec should contain:

```md
<!-- sdd: refined=true -->
```

## SDD Plan Coverage

Every concrete artifact listed under `delivery_artifacts/*.md` must be covered by at least one task in `plan.md`.

Each task must include a `Delivers` section referencing:

- the delivery artifact file
- the artifact heading
- the concrete output being produced

Tests are not delivery artifacts.
However, every implementation task must define the tests or validation required to prove the delivered artifact works.

Do not create implementation tasks that do not map to a delivery artifact, unless explicitly marked as technical enabling work.

## SDD Traceability

For each task in `plan.md`, include a short `Traceability` section referencing at least one of:

- an EARS requirement id from `spec.md`, such as `REQ-001`
- an acceptance scenario from `spec.md`
- a finding from `research.md`
- an ADR
- a test, schema, API contract, dashboard, alert, migration, or validation requirement

Example:

```md
## T2: Add provider output instrumentation

Delivers:

- `delivery_artifacts/02-observability.md` → `delivery.output.attempted`
  - Add counter metric grouped by `channel` and `outcome`

Traceability:

- Requirement: `REQ-001`
- Requirement: `REQ-002`
- Research: `app/services/delivery/output_handler.rb` currently handles provider output without emitting a metric

Validation:

- Add/update targeted test for metric emission.
- Run targeted test file.
- Run linter.
```

