---
name: sdd-delivery-artifacts
description: Generate delivery_artifacts/*.md from refined spec.md and research.md. Lists concrete files/modules/configuration/docs that must be produced or modified before planning. Does not include tests, plan, or implementation.
origin: user
---

# SDD Delivery Artifacts

Generate the delivery artifact map for a feature.

This skill creates a variable, feature-specific map of what must be produced or modified before planning.

It must not plan implementation.
It must not modify application code.
It must not create tests.
It must not create `plan.md`.

## Rules

Follow:

- `rules/sdd/workflow.md`

## When to Activate

Use this skill when:

- The user invokes `/sdd-delivery-artifacts <playbook-path>`
- The user asks "what do we need to produce?"
- The user asks to prepare deliverables before planning
- `spec.md` has been refined with `research.md`

## Required Inputs

Read:

- `<playbook-path>/spec.md`
- `<playbook-path>/research.md`

If `spec.md` is missing, stop and ask the user to run `/sdd-start` first.

If `research.md` is missing, stop and ask the user to run `/sdd-research` first.

If `spec.md` is not marked as refined, stop and ask the user to run `/sdd-refine` first.

A refined spec should contain:

```md
<!-- sdd: refined=true -->
```

## Output

Create:

`<playbook-path>/delivery_artifacts/`

Inside it, create one or more numbered markdown files grouped by the natural delivery areas of this feature.

Do not use a fixed category list.
Infer the area names from:

- `spec.md`
- `research.md`
- impacted files
- impacted runtime components
- impacted external contracts
- impacted operational surfaces

Examples of possible area names:

- `01-domain-model.md`
- `02-api-contracts.md`
- `03-jobs-consumers.md`
- `04-observability.md`
- `05-rollout.md`
- `01-grafana-dashboard.md`
- `02-terraform-alerts.md`
- `01-cli-command.md`
- `02-configuration.md`

Use only the files that make sense for the current feature.

## Grouping Rules

- Group by delivery area, not by implementation task.
- Prefer 2–6 files.
- Avoid creating one file per source file.
- Avoid generic buckets like `misc.md`.
- Avoid forcing categories that do not apply.
- Use stable numbering only to define reading order, not implementation order.

## Tests Rule

Tests are not delivery artifacts.

Do not include:

- test files as artifacts
- validation commands
- linter execution
- test execution
- QA checklist items

Tests and validation belong in:

- `plan.md`
- `plan/tN.md`
- task validation sections

## File Format

Each delivery artifact file must use this structure:

```md
# <Area Name>

## Purpose

Briefly explain what this area must deliver for this feature.

## Artifacts

### `<path-or-component-name>`

Produce:

- Concrete output/change to produce.
- Concrete output/change to produce.

Constraints:

- Constraint or non-change.
- Compatibility or safety constraint.

Source:

- `spec.md`: `REQ-001`, `REQ-002`, scenario, requirement, or section
- `research.md`: file, flow, risk, or finding
```

## Artifact Rules

Each artifact must include:

- concrete file path when known
- component name when exact path is unknown
- concrete output/change to produce
- constraints and expected non-changes when relevant
- source references to EARS requirements and research findings

Prefer concrete artifacts:

- `app/services/delivery/output_handler.rb`
- `ProviderDeliveryAttempted` event
- `grafana/dashboards/provider-output.json`
- `terraform/.../alerts.tf`
- `openapi/communication-center.yaml`

Avoid vague artifacts:

- "update code"
- "improve logic"
- "add tests"
- "make dashboard better"

## Expected Non-Changes

Use explicit non-changes when they prevent unnecessary work.

Example:

```md
### `app/consumers/communication_requested_consumer.rb`

Produce:

- No code change expected.
- Confirm current payload already contains required `notification_group_id`.

Constraints:

- Do not modify consumer retry semantics.

Source:

- `spec.md`: `REQ-003`
- `research.md`: current consumer passes notification group id downstream
```

## Coverage Rules

Every behavioural requirement in `spec.md` should be represented by at least one delivery artifact, unless the requirement is purely non-functional or validation-only.

Every concrete artifact should reference at least one of:

- EARS requirement id
- acceptance scenario
- research finding
- ADR
- explicit user requirement

If a requirement requires no production artifact, explain why in a small section:

```md
## Requirements With No Production Artifact

- `REQ-004`: already satisfied by current implementation according to `research.md`.
```

## Non-Goals

Do not create or modify:

- `plan.md`
- `plan/tN.md`
- application code
- tests
- contracts
- infrastructure files
- dashboards
- alerts
- documentation outside `delivery_artifacts/`

## Output Rules

After writing `delivery_artifacts/*.md`, return only:

- directory created
- files created
- number of artifacts
- requirements not mapped, if any
- blocking open questions, if any
- next recommended command

Example:

```md
Created:

- `doc/playbook/20260518_provider_output_observability/delivery_artifacts/01-app-core.md`
- `doc/playbook/20260518_provider_output_observability/delivery_artifacts/02-observability.md`

Artifacts:

- 6 concrete artifacts

Unmapped requirements:

- None

Blocking questions:

- None

Next:

- Run `@planner doc/playbook/20260518_provider_output_observability`
```
