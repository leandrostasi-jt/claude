# Planner SDD Addition

Add this section to `agents/planner.md`.

## SDD Planning

When planning work under `doc/playbook/<feature>/`, follow all of these rules:

- `rules/sdd/workflow.md`
- `rules/common/output-budget.md`
- `rules/sdd/output-budget.md`

The planner must treat those rules as mandatory execution constraints.

The output-budget rules are not formatting preferences. They control how the planner is allowed to read, create, update, and summarize planning artifacts.

## SDD Planning Responsibilities

The planner is responsible for converting approved SDD inputs into an executable implementation plan.

Planning is not implementation.

The planner must not modify production code, tests, CI files, gemspecs, migrations, dashboards, Terraform, or application files unless the user explicitly switches from planning to execution.

The planner must produce a plan that can be executed later by an implementation agent without requiring that agent to invent missing scope.

## SDD Planning Inputs

When the requested work is under `doc/playbook/<feature>/`, the planner must read the following before planning:

- `doc/playbook/<feature>/spec.md`
- `doc/playbook/<feature>/research.md`
- every markdown file under `doc/playbook/<feature>/delivery_artifacts/`
- any ADR explicitly referenced by the spec, research, or delivery artifacts
- relevant repository rules from `rules/`

If `research.md` is missing, stop and ask the user to run `/sdd-research` first.

If `delivery_artifacts/` is missing or contains no markdown files, stop and ask the user to run `/sdd-delivery-artifacts` first.

Do not assume fixed delivery artifact filenames.

Use the actual markdown files present under `delivery_artifacts/`.

Use:

- `spec.md` as the behavioural source of truth
- `research.md` as the repository-evidence source of truth
- `delivery_artifacts/` as the production-scope source of truth
- ADRs as architectural decision constraints
- repository rules as execution constraints

Do not plan from an unrefined `spec.md` if `research.md` exists and `sdd-refine` has not been run.

A refined spec must contain:

```md
<!-- sdd: refined=true -->
```

If that marker is missing, stop and ask the user to run `/sdd-refine` first.

## SDD Planning Output Structure

The planner must create this structure:

```text
doc/playbook/<feature>/
  plan.md
  plan/
    t1.md
    t2.md
    t3.md
    ...
```

`plan.md` is only the compact execution index.

`plan/tN.md` files are the detailed execution contracts.

The planner must not create a monolithic `plan.md`.

Every executable task listed in `plan.md` must have a matching child task file under `plan/`.

Valid examples:

- `plan/t1.md`
- `plan/t2.md`
- `plan/t3.md`

Invalid examples:

- all task details embedded only in `plan.md`
- vague checklist bullets without child task files
- task files that only repeat the checklist without implementation detail

## `plan.md` Contract

`plan.md` must stay compact.

It may include only:

- title
- goal
- scope summary
- global execution rules
- validation commands
- task index
- task checklist
- dependency order between tasks
- human gates, if any
- rollback summary, if relevant

`plan.md` must not contain detailed implementation instructions.

Detailed instructions belong in `plan/tN.md`.

The task index in `plan.md` must reference the child file for each task.

Example:

```md
| Task | Title | File | Delivers |
|------|-------|------|----------|
| T1 | Add OTel dependencies | `plan/t1.md` | `delivery_artifacts/01-dependencies.md` |
```

## Child Task File Contract

Each `plan/tN.md` file must be specific enough for an implementation agent to execute without guessing.

Each child task file must include:

- task id and title
- objective
- delivery artifact coverage
- traceability
- files allowed to change
- files not allowed to change
- exact implementation steps
- tests to add or update
- validation commands
- completion criteria
- rollback or safety notes when relevant
- out-of-scope changes

The implementation steps must be concrete.

Avoid vague instructions such as:

- “update instrumentation”
- “add tests”
- “wire OTel”
- “clean up code”
- “ensure compatibility”

Prefer concrete instructions such as:

- “Remove `ddtrace` from `jt-kafka.gemspec` runtime dependencies.”
- “Add `opentelemetry-api`, constrained to `~> 1.0`, as a runtime dependency.”
- “Add a test asserting existing Kafka headers remain present after propagation injection.”
- “Do not modify producer retry behaviour.”

## SDD Plan Coverage

Every concrete artifact listed under `delivery_artifacts/*.md` must be covered by at least one task in `plan.md`.

Each task must include a `Delivers` section referencing:

- the delivery artifact file
- the artifact heading
- the concrete output being produced

Tests are not delivery artifacts.

However, every implementation task must define the tests or validation required to prove the delivered artifact works.

Do not create implementation tasks that do not map to a delivery artifact unless they are explicitly marked as technical enabling work.

Technical enabling work must still include:

- why it is required
- which later delivery artifact it enables
- how it will be validated

## SDD Traceability

For each task, include a `Traceability` section referencing at least one of:

- an EARS requirement id from `spec.md`, such as `REQ-001`
- an acceptance scenario from `spec.md`
- a finding from `research.md`
- an ADR
- a delivery artifact
- a test, schema, API contract, dashboard, alert, migration, or validation requirement

Traceability must appear in the child task file.

`plan.md` may contain only a compact traceability summary.

## SDD Output Budget Requirements

Before creating or updating `plan.md` or any child task files, the planner must:

1. Read the applicable SDD workflow rules.
2. Read the common output-budget rules.
3. Read the SDD-specific output-budget rules.
4. Plan file creation incrementally.

The planner must obey the output-budget rules while creating planning artifacts.

When output budget is constrained, the planner must:

- write one file at a time
- write one section at a time when needed
- create only one child task file at a time
- avoid large `Write`, `Edit`, or Bash heredoc payloads
- avoid printing generated file contents in chat
- stop after a small write and summarize briefly

The planner must not do this:

1. read many files
2. synthesize a full detailed plan
3. write a large `plan.md`
4. write all child task files
5. summarize everything in one assistant turn

That pattern is output-budget unsafe.

## SDD Recovery Mode

If an output-limit failure occurs, the planner must enter Recovery Mode.

In Recovery Mode, the planner must not retry the same large write.

The next action must be smaller than the failed action.

Allowed Recovery Mode actions:

- create only the missing directory
- create only an empty `plan.md`
- append one short section to `plan.md`
- create one child task file
- append one short section to one child task file
- summarize in at most 20 visible words

Forbidden Recovery Mode actions:

- continue writing the full plan
- create multiple task files
- use subagents
- read more source files
- print generated file contents
- retry the same large `Write`, `Edit`, or heredoc

After Recovery Mode succeeds, continue incrementally.

## SDD Planning Completion Criteria

The planner is not done until all of the following are true:

- `plan.md` exists
- `plan/` directory exists
- every task listed in `plan.md` has a matching `plan/tN.md`
- every `plan/tN.md` has concrete implementation instructions
- every delivery artifact is covered by at least one task
- every implementation task defines tests or validation
- every task has traceability
- output-budget rules were followed
- no implementation files were changed

If any of these are missing, the planner must not claim that planning is complete.

## Example Child Task Shape

```md
# T2 — Add provider output instrumentation

## Objective

Add provider output instrumentation without changing delivery behaviour.

## Delivers

- `delivery_artifacts/02-observability.md` → `delivery.output.attempted`
  - Add counter metric grouped by `channel` and `outcome`.

## Traceability

- Requirement: `REQ-001`
- Requirement: `REQ-002`
- Research: `app/services/delivery/output_handler.rb` currently handles provider output without emitting a metric.

## Files Allowed to Change

- `app/services/delivery/output_handler.rb`
- `test/services/delivery/output_handler_test.rb`

## Files Not Allowed to Change

- Kafka consumers
- provider client implementations
- retry logic
- dashboards
- alerts

## Implementation Steps

1. Locate the successful provider output path.
2. Emit the metric after the provider call succeeds.
3. Include `channel` and `outcome` tags.
4. Do not emit the metric before the provider call.
5. Do not change retry or exception behaviour.

## Tests

- Add or update a targeted test proving the metric is emitted on success.
- Add or update a targeted test proving the metric is not emitted before the provider call completes.

## Validation

- Run the targeted test file.
- Run the linter.

## Completion Criteria

- Metric is emitted only on the intended path.
- Tests pass.
- Linter passes.
- No out-of-scope files changed.

## Rollback / Safety Notes

Removing the metric emission restores previous runtime behaviour.
```
