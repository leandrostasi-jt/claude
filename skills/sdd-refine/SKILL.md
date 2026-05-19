---
name: sdd-refine
description: Refine spec.md using research.md. Reconciles intent with repository evidence, adds Change Set, updates EARS requirements, and marks the spec as refined. Does not plan or implement.
origin: user
---

# SDD Refine

Refine the intent-level `spec.md` using repository evidence from `research.md`.

This skill turns `spec.md` v0 into `spec.md` v1.

It must not plan implementation.
It must not modify application code.
It must not create `delivery_artifacts/`, `facts/`, or `plan.md`.

This skill is framework-agnostic.

It must not assume Rails, Elixir, Kotlin, Terraform, devkit, Docker, CI, or any specific command runner.

## Rules

Follow:

- `rules/sdd/workflow.md`

## When to Activate

Use this skill when:

- The user invokes `/sdd-refine <playbook-path>`
- `spec.md` and `research.md` exist
- The user says "refine the spec with research"
- The user wants to reconcile intent with repository findings

## Required Inputs

Read:

- `<playbook-path>/spec.md`
- `<playbook-path>/research.md`

If `spec.md` is missing, stop and ask the user to run `/sdd-start` first.

If `research.md` is missing, stop and ask the user to run `/sdd-research` first.

## Workflow

1. Read `spec.md`
2. Read `research.md`
3. Replace unknown current behaviour with researched current behaviour
4. Update or clarify EARS requirements
5. Add or update the Change Set
6. Surface conflicts between intent and repo reality
7. Keep unresolved questions as checkboxes
8. Mark the spec as refined

## Refinement Rules

You may clarify requirements using repository evidence.

You must not silently change user intent.

If research contradicts the original intent, add a `Research Conflicts` section.

Use this format:

```md
## Research Conflicts

- Conflict: <what conflicts>
  - Spec intent: <original intent>
  - Research finding: <repo evidence>
  - Resolution: <resolved / open question / requires user decision>
```

If the conflict requires user input, use `AskUserQuestionTool`.

## Required Changes to spec.md

After refinement, `spec.md` must include:

```md
<!-- sdd: refined=true -->
<!-- refined_from: research.md -->
```

It must also include:

```md
## Change Set

### Added

### Modified

### Removed

### Unchanged
```

## Change Set Rules

Use the Change Set to describe the feature delta for a brownfield repository.

### Added

New behaviours, artifacts, contracts, metrics, jobs, endpoints, docs, dashboards, alerts.

### Modified

Existing behaviours, files, flows, interfaces, contracts, dashboards, alerts.

### Removed

Behaviours, files, configs, flags, contracts, or docs that should disappear.

### Unchanged

Important behaviours or interfaces that must remain untouched.

Use `Unchanged` aggressively to prevent scope creep.

## EARS Rules

Maintain stable requirement ids where possible.

If a requirement is split, preserve traceability:

```md
Split from: `REQ-002`
```

If a requirement is removed, explain why.

Requirements must remain:

- atomic
- verifiable
- behaviour-focused
- expressed with `shall`

## Output Rules

After updating `spec.md`, return only:

- path updated
- whether conflicts remain
- number of requirements
- number of open questions
- next recommended command
