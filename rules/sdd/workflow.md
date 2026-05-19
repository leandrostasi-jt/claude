# Spec-Driven Development Workflow

Use this workflow for non-trivial feature work.

The goal is to avoid jumping from a rough requirement directly into implementation.

## Required Sequence

For non-trivial feature work, follow this sequence:

1. `/sdd-start`
   - Produces `spec.md` v0.
   - Captures intent, scope, non-goals, EARS requirements, acceptance scenarios, and research questions.
   - Uses `AskUserQuestionTool` to resolve blocking ambiguities before writing `spec.md`.
   - Must not inspect or claim repository facts unless provided by the user.

2. `/sdd-research`
   - Produces `research.md`.
   - Inspects the repository and records concrete evidence.
   - Must not plan or implement.

3. `/sdd-refine`
   - Updates `spec.md` into the refined version.
   - Reconciles user intent with repository evidence.
   - Must surface conflicts instead of silently changing the intent.

4. `/sdd-delivery-artifacts`
   - Produces `delivery_artifacts/*.md`.
   - Lists what must be produced or modified.
   - Must not include tests as delivery artifacts.
   - Must not create an implementation plan.

5. `planner`
   - Produces `plan.md` and `plan/tN.md`.
   - Plans from the refined `spec.md`, `research.md`, and `delivery_artifacts/*.md`.
   - Must not plan from `spec.md` v0 if `research.md` exists and refinement has not happened.

6. `/execute-plan`
   - Executes one or more approved tasks.
   - Must modify only files allowed by the plan.
   - Must validate through project commands.

7. `reviewer`
   - Reviews the diff against `spec.md`, `research.md`, `delivery_artifacts/*.md`, and `plan.md`.

## Source of Truth

- `spec.md` is the behavioural source of truth.
- `research.md` is the repository-evidence source of truth.
- `delivery_artifacts/*.md` is the production-scope source of truth.
- `plan.md` is the execution source of truth.
- `plan/tN.md` files are the atomic task instructions.
- Tests, contracts, schemas, ADRs, dashboards, alerts, and code are the permanent artifacts.

## Repository Knowledge Boundary

Before `/sdd-research`, do not claim facts about the current codebase unless the user explicitly provided them.

If current behaviour depends on repository inspection, write:

> Unknown. Must be discovered during `/sdd-research`.

## Requirements Syntax Rule

Specs must express behavioural requirements using EARS.

Use:

- stable requirement ids: `REQ-001`, `REQ-002`, ...
- `shall` for mandatory behaviour
- one requirement per statement
- testable/verifiable wording

Preferred EARS patterns:

- Ubiquitous: `The system shall <response>.`
- Event-driven: `When <trigger>, the system shall <response>.`
- State-driven: `While <state>, the system shall <response>.`
- Optional: `Where <feature/condition>, the system shall <response>.`
- Unwanted behaviour: `If <unwanted event>, then the system shall <response>.`

Acceptance scenarios may use Given/When/Then, but they do not replace EARS requirements.

## Refinement Rule

After `research.md` exists, the spec must be refined before planning.

The planner must not use an unrefined `spec.md` if repository research has produced new evidence.

`sdd-refine` may clarify requirements using repository evidence, but it must not change product intent silently.

If research contradicts the spec, add a `Research Conflicts` section and leave blocking decisions explicit.

## Delivery Artifacts Rule

`delivery_artifacts/` is a variable, feature-specific map of what must be produced.

Do not assume fixed filenames.

Examples of valid delivery artifact files:

- `01-api-contracts.md`
- `02-domain-model.md`
- `03-jobs-consumers.md`
- `04-observability.md`
- `01-grafana-dashboard.md`
- `02-terraform-alerts.md`
- `01-cli-command.md`

The actual files must be inferred from the feature.

## Tests Rule

Tests are not delivery artifacts.

Tests belong in:

- `plan.md`
- `plan/tN.md`
- validation sections
- implementation requirements

Every implementation task must define how the delivered artifact will be validated.

## Planning Rule

When planning under `doc/playbook/<feature>/`, the planner must read:

- `spec.md`
- `research.md`
- every markdown file under `delivery_artifacts/`
- referenced ADRs
- relevant rules

Every concrete artifact listed under `delivery_artifacts/*.md` must be covered by at least one task in `plan.md`.

Each task must include a `Delivers` section referencing:

- the delivery artifact file
- the artifact heading
- the concrete output being produced

## No Shortcut Rule

Do not skip directly from rough requirement to implementation.

Allowed shortcut only for explicitly trivial changes, such as:

- typo fixes
- small copy changes
- obvious one-line config changes
- mechanical renames with no behavioural impact

If in doubt, use the SDD workflow.
