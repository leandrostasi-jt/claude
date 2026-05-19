---
name: sdd-refine
description: Refine spec.md using research.md. Reconciles intent with repository evidence, updates EARS requirements, and marks the spec as refined. Does not plan or implement.
origin: user
---

# SDD Refine

Refine `spec.md` after repository research.

This skill turns `spec.md` v0 plus `research.md` into a repository-grounded `spec.md` v1.

It must not plan implementation.
It must not modify application code.
It must not create `delivery_artifacts/` or `plan.md`.

## Rules

Follow:

- `rules/sdd/workflow.md`

## When to Activate

Use this skill when:

- The user invokes `/sdd-refine <playbook-path>`
- `spec.md` and `research.md` both exist
- The user says "refine the spec with research"
- The user says "update spec.md based on research.md"

## Required Inputs

Read:

- `<playbook-path>/spec.md`
- `<playbook-path>/research.md`

If `spec.md` is missing, stop and ask the user to run `/sdd-start` first.

If `research.md` is missing, stop and ask the user to run `/sdd-research` first.

## Workflow

1. Read `spec.md`.
2. Read `research.md`.
3. Compare intent against repository evidence.
4. Replace unknown current behaviour with researched current behaviour.
5. Refine EARS requirements so they are precise, testable, and repository-aware.
6. Update acceptance scenarios if research clarifies real flows.
7. Add `Research Conflicts` if evidence contradicts the spec.
8. Keep unresolved decisions explicit.
9. Mark the spec as refined.

## Refinement Rules

You may:

- clarify requirements
- add requirements implied by the original intent and confirmed by research
- split vague requirements into multiple EARS requirements
- add constraints discovered during research
- update current behaviour with evidence
- add compatibility, observability, rollout, or risk details found in research
- remove research questions that were answered, moving answers into the relevant sections

You must not:

- silently change the product intent
- silently drop requirements
- invent implementation details not supported by research
- create implementation tasks
- create delivery artifacts
- create or modify code/tests/contracts/infrastructure

## Research Conflict Handling

If research contradicts the spec, add:

```md
## Research Conflicts

### Conflict 1: <short name>

Spec expectation:

- ...

Research evidence:

- ...

Impact:

- ...

Decision needed:

- [ ] ...
```

Do not resolve product or architecture conflicts without explicit user input.

## EARS Requirements Refinement

All behavioural requirements must use EARS.

Each requirement must:

- keep or receive a stable id: `REQ-001`, `REQ-002`, ...
- use `shall`
- be atomic
- be testable or verifiable
- avoid vague words unless quantified
- avoid implementation details unless they are required by the spec or research constraints

Allowed EARS patterns:

- Ubiquitous: `The system shall <response>.`
- Event-driven: `When <trigger>, the system shall <response>.`
- State-driven: `While <state>, the system shall <response>.`
- Optional: `Where <feature/condition>, the system shall <response>.`
- Unwanted behaviour: `If <unwanted event>, then the system shall <response>.`

If a v0 requirement is vague, refine it.

Example before:

```md
### REQ-002

The system shall expose useful metrics.
```

Example after:

```md
### REQ-002

When a provider output attempt is made, the system shall emit a counter metric grouped by delivery channel.
```

## Required spec.md Marker

After refinement, the top of `spec.md` must include:

```md
<!-- sdd: spec_version=v1 -->
<!-- sdd: refined=true -->
<!-- sdd: refined_from=research.md -->
```

If the spec already has SDD markers, update them.

## Required spec.md Structure

Preserve the existing spec structure when possible.

The refined spec should contain:

```md
<!-- sdd: spec_version=v1 -->
<!-- sdd: refined=true -->
<!-- sdd: refined_from=research.md -->

# Spec: <feature>

## Problem

## Goal

## Non-goals

## Users / Consumers

## Current Behaviour

Repository-grounded current behaviour.

## Desired Behaviour

## Requirements

### REQ-001

When <trigger>, the system shall <response>.

## Acceptance Scenarios

## Edge Cases

## Observability

## Compatibility

## Security / Privacy / Compliance

## Research Conflicts

Only if applicable.

## Open Questions

Only unresolved non-blocking or decision-needed questions.
```

## Output Rules

After updating `spec.md`, return only:

- path updated
- short summary of what changed
- conflicts found, if any
- open questions remaining
- next recommended command

Example:

```md
Updated:

- `doc/playbook/20260518_provider_output_observability/spec.md`

Changes:

- Replaced unknown current behaviour with repository evidence.
- Refined 5 EARS requirements.
- Added one compatibility constraint from research.

Conflicts:

- None

Open questions:

- 1 non-blocking question remains.

Next:

- Run `/sdd-delivery-artifacts doc/playbook/20260518_provider_output_observability`
```

