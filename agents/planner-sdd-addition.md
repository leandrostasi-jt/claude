# Planner SDD Addition

Add this to `agents/planner.md`.

## SDD

When planning work under `doc/playbook/<feature>/`, follow:

- `rules/sdd/workflow.md`
- `rules/sdd/facts.md`

SDD is framework-agnostic.

Do not derive framework-specific commands, runners, wrappers, or build tools from SDD rules.

Use applicable project, stack, or repository rules for command selection.

## SDD Planning Inputs

When the requested work is under `doc/playbook/<feature>/`, you MUST read before planning:

- `doc/playbook/<feature>/spec.md`
- `doc/playbook/<feature>/research.md`
- every markdown file under `doc/playbook/<feature>/delivery_artifacts/`
- every markdown file under `doc/playbook/<feature>/facts/`
- any ADR explicitly referenced by the spec, research, delivery artifacts, or facts
- relevant repository, stack, and common rules

If `research.md` is missing, stop and ask the user to run `/sdd-research` first.

If `spec.md` is not refined and `research.md` exists, stop and ask the user to run `/sdd-refine` first.

If `delivery_artifacts/` is missing or contains no markdown files, stop and ask the user to run `/sdd-delivery-artifacts` first.

If the SDD rigor level is `L1+` or `L2` and `facts/` is missing or empty, stop and ask the user to run `/sdd-facts` first.

Do not infer implementation context from memory.

Use:

- `spec.md` as the behavioural source of truth
- `research.md` as the repository-evidence source of truth
- `delivery_artifacts/` as the production-scope source of truth
- `facts/` as the executable-verification source of truth

## SDD Plan Format

When planning under `doc/playbook/<feature>/`, `plan.md` must start with:

1. `Task Checklist`
2. `Delivery Checklist`
3. `Facts Checklist`
4. `Validation`

Each task must have a stable id:

- `T1`
- `T2`
- `T3`

Use `[P]` in the task id/title to mark tasks that can be executed in parallel.

Example:

```md
## Task Checklist

- [ ] T1: Add instrumentation event
- [ ] T2 [P]: Update dashboard panel
- [ ] T3 [P]: Update runbook documentation
- [ ] T4: Final validation
```

## Parallelizable Tasks

A task may be marked `[P]` only when:

- it modifies disjoint files from other `[P]` tasks
- it does not depend on another `[P]` task
- it does not create merge-conflict risk
- it can be validated independently

Do not create a separate parallelization section.

If a task is sequential, do not add `[P]`.

If in doubt, leave the task sequential.

## Delivery Checklist

Every concrete artifact from `delivery_artifacts/*.md` must appear in the `Delivery Checklist` with `[ ]`.

Example:

```md
## Delivery Checklist

- [ ] `delivery_artifacts/01-observability.md` -> `<artifact heading>`
- [ ] `delivery_artifacts/02-documentation.md` -> `<artifact heading>`
```

## Facts Checklist

Every `@spec` fact from `facts/*.md` must appear in the `Facts Checklist` with `[ ]`.

Example:

```md
## Facts Checklist

- [ ] `facts/01-observability-facts.md` -> `FACT-001`
- [ ] `facts/01-observability-facts.md` -> `FACT-002`
```

## Validation

Resolve validation using applicable project, stack, or repository rules.

Do not invent stack-specific commands from SDD rules.

If no project rule defines how to run validation, write:

```md
Command: TODO - resolve from project rules
```

and do not guess.

Validation entries should say what must be verified, and may include concrete commands only when those commands are defined by relevant project rules.

Example:

```md
## Validation

- Check type: unit/integration/contract/schema/static/smoke/other
- Scope: <what must be verified>
- Command: resolved from applicable project rules
```

## Task Format

Each task must include:

```md
### T1: <task title>

Delivers:

- `delivery_artifacts/<file>.md` -> `<artifact heading>`

Implements Facts:

- `facts/<file>.md` -> `FACT-001`

Allowed Files:

- `path/to/file`
- `path/to/other_file`

Validation:

- Check type: <type>
- Scope: <what must be verified>
- Command: <resolved command or TODO>

Done When:

- [ ] ...
```

For task files, use the same task title:

```md
# T2 [P]: Update dashboard panel
```

## SDD Plan Coverage

Every concrete artifact listed under `delivery_artifacts/*.md` must be covered by at least one task in `plan.md`.

Every `@spec` fact listed under `facts/*.md` must be implemented by at least one task or explicitly deferred.

Each task must include a `Delivers` section referencing:

- the delivery artifact file
- the artifact heading
- the concrete output being produced

Each task must include an `Implements Facts` section referencing:

- the facts file
- the fact id

Do not create implementation tasks that do not map to a delivery artifact or fact, unless explicitly marked as technical enabling work.

## Traceability

For L1+ and L2 work, maintain lightweight traceability:

```txt
REQ -> FACT -> TASK
```

The planner does not need to create a heavy traceability matrix.

It is enough that tasks reference facts, and facts reference requirements.

## No Unapproved Scope

Do not add tasks outside the refined spec, delivery artifacts, or facts unless clearly marked as technical enabling work.

Technical enabling work must explain why it is necessary.
