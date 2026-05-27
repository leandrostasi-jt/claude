# Create SDD Plan

Generate or repair an SDD implementation plan for work under `doc/playbook/<feature>/`.

Arguments: `$ARGUMENTS` — must identify the playbook path or enough context to locate it.

Examples:

- `doc/playbook/20260525_jt_kafka_otel_migration`
- `create plan for playbook doc/playbook/20260525_jt_kafka_otel_migration`
- `PA-5153 migrate jt-kafka-rb from Datadog to OpenTelemetry`

## Purpose

This command is an entrypoint for SDD planning.

It must not behave like an old standalone planning prompt.

It must delegate planning behavior to the planner agent instructions and the SDD workflow rules.

## Mandatory Rule Loading

Before planning, read and apply (`~/.claude/`):

- `agents/planner.md`
- `rules/sdd/workflow.md`
- `rules/common/output-budget.md`
- `rules/sdd/output-budget.md`

These files are mandatory.

If `agents/planner.md` is missing, stop and report:

```text
Missing required planner agent: agents/planner.md
```

If any required rule file is missing, stop and report the missing file.

The planner agent instructions are the source of truth for planning behavior.

The output-budget rules are hard execution constraints, not formatting preferences.

## Argument Parsing

Extract from `$ARGUMENTS`:

- playbook path, if explicitly provided
- ticket ID, if present
- task description, if present
- extra constraints, if present

If a playbook path is provided, use it directly.

If no playbook path is provided, locate the matching playbook under:

```text
doc/playbook/
```

Do not create a new playbook path if an existing playbook is clearly requested.

If no matching playbook can be identified, ask the user for the playbook path.

## SDD Preconditions

Before creating or updating a plan, verify the playbook contains the required SDD inputs defined by `agents/planner.md`.

At minimum, planning requires:

- `spec.md`
- `research.md`
- `delivery_artifacts/` containing at least one markdown file

If `research.md` is missing, stop and ask the user to run `/sdd-research` first.

If `delivery_artifacts/` is missing or contains no markdown files, stop and ask the user to run `/sdd-delivery-artifacts` first.

If `research.md` exists but `spec.md` is not refined, stop and ask the user to run `/sdd-refine` first.

A refined spec must contain:

```md
<!-- sdd: refined=true -->
```

## Planning Inputs

Read planning inputs according to `agents/planner.md` and the output-budget rules.

Do not bulk-read everything in one step.

Read files one by one.

Required planning inputs:

- `doc/playbook/<feature>/spec.md`
- `doc/playbook/<feature>/research.md`
- every markdown file under `doc/playbook/<feature>/delivery_artifacts/`
- any ADR explicitly referenced by the spec, research, or delivery artifacts
- relevant repository rules from `rules/`

Use:

- `spec.md` as the behavioural source of truth
- `research.md` as the repository-evidence source of truth
- `delivery_artifacts/` as the production-scope source of truth
- ADRs as architectural decision constraints
- repository rules as execution constraints

Do not explore the codebase freely during planning unless `agents/planner.md` or `research.md` identifies a specific missing fact that must be verified.

Planning should be based on existing SDD artifacts, not a fresh ad hoc codebase investigation.

## Required Output Structure

Create or repair this structure:

```text
doc/playbook/<feature>/
  plan.md
  plan/
    t1.md
    t2.md
    t3.md
    ...
```

`plan.md` is a compact execution index.

`plan/tN.md` files are detailed execution contracts.

Do not create a monolithic `plan.md`.

Every executable task listed in `plan.md` must have a matching child task file under `plan/`.

Implementation agents must execute from `plan/tN.md`, not from vague checklist bullets inside `plan.md`.

## `plan.md` Contract

`plan.md` must stay compact.

It may include only:

- title
- ticket ID, if known
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

## Delivery Artifact Coverage

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

## Traceability

For each task, include a `Traceability` section referencing at least one of:

- an EARS requirement id from `spec.md`, such as `REQ-001`
- an acceptance scenario from `spec.md`
- a finding from `research.md`
- an ADR
- a delivery artifact
- a test, schema, API contract, dashboard, alert, migration, or validation requirement

Traceability must appear in the child task file.

`plan.md` may contain only a compact traceability summary.

## Output Budget Requirements

Follow:

- `rules/common/output-budget.md`
- `rules/sdd/output-budget.md`

When output budget is constrained:

- write one file at a time
- write one section at a time when needed
- create only one child task file at a time
- avoid large `Write`, `Edit`, or Bash heredoc payloads
- avoid printing generated file contents in chat
- stop after a small write and summarize briefly

Do not do this:

1. read many files
2. synthesize a full detailed plan
3. write a large `plan.md`
4. write all child task files
5. summarize everything in one assistant turn

That pattern is output-budget unsafe.

## Recovery Mode

If an output-limit failure occurs, enter Recovery Mode.

In Recovery Mode:

- do not retry the same large write
- do not continue writing the full plan
- do not create multiple task files
- do not use subagents
- do not read more source files
- do not print generated file contents
- do not retry the same large `Write`, `Edit`, or heredoc

The next action must be smaller than the failed action.

Allowed Recovery Mode actions:

- create only the missing directory
- create only an empty `plan.md`
- append one short section to `plan.md`
- create one child task file
- append one short section to one child task file
- summarize in at most 20 visible words

After Recovery Mode succeeds, continue incrementally.

## Forbidden Behavior

Do not:

- generate a standalone old-style `plan.md`
- create `[EXEC:PR-N]` sections with all task details embedded only in `plan.md`
- rely only on plain checkbox tasks
- skip child task files
- claim planning is complete while child files are missing
- modify production code
- modify tests
- modify CI files
- modify gemspecs
- modify migrations
- modify dashboards
- modify Terraform
- commit changes
- push branches
- open PRs

Planning is not implementation.

## Planning Completion Gate

Before saying planning is complete, verify:

- `plan.md` exists
- `plan/` directory exists
- every executable task listed in `plan.md` has a matching `plan/tN.md`
- every `plan/tN.md` contains detailed execution instructions
- every delivery artifact is covered by at least one task
- every task has traceability
- every implementation task defines tests or validation
- no implementation files were changed
- output-budget rules were followed

If any check fails, planning is incomplete.

Do not say the plan is complete.

Continue incrementally while following the output-budget rules.

## Final Response

After creating or updating planning files, respond only with:

- files created or updated
- short summary
- next recommended step

Do not print the full contents of `plan.md` or any `plan/tN.md` file unless the user explicitly asks.
