---
name: sdd-research
description: Inspect the repository against an existing spec.md and produce research.md with concrete code evidence. Never plans or implements.
origin: user
---

# SDD Research

Research the existing implementation before planning.

This skill answers the repository questions raised by `spec.md`.

It must not plan implementation.
It must not modify application code.
It must not create `delivery_artifacts/` or `plan.md`.

## Rules

Follow:

- `rules/sdd/workflow.md`

## When to Activate

Use this skill when:

- The user invokes `/sdd-research <playbook-path>`
- A `spec.md` exists and the user wants implementation context
- The user says "research this spec"
- The user says "inspect the repo for this feature"

## Required Inputs

Read:

- `<playbook-path>/spec.md`

If `spec.md` is missing, stop and ask the user to run `/sdd-start` first.

## Workflow

1. Read `spec.md`.
2. Identify all research questions.
3. Inspect relevant code, tests, config, schemas, dashboards, jobs, consumers, docs, and infrastructure.
4. Record concrete evidence in `research.md`.
5. Separate facts from assumptions.
6. Do not design the solution.
7. Do not create implementation tasks.

## Research Scope

Inspect only what is relevant to the spec.

Prefer targeted investigation over broad repository reading.

Look for:

- existing domain flows
- controllers/endpoints
- jobs/consumers/workers
- service objects
- models/entities
- event producers/consumers
- metrics/logging/instrumentation
- dashboards/alerts/runbooks
- schemas/contracts/OpenAPI/AsyncAPI/JSON Schema
- migrations/data dependencies
- tests describing current behaviour
- ADRs or internal docs that constrain the feature

## research.md Structure

Write:

`<playbook-path>/research.md`

Use this structure:

```md
# Research: <feature>

## Spec Input

- Spec path: `<playbook-path>/spec.md`
- Spec version: v0 or current marker

## Summary

Briefly summarize what was discovered.

## Relevant Files

### `<path>`

Why it matters:

- ...

Evidence:

- ...

## Current Flow

Describe what happens today using concrete repository evidence.

## Existing Tests

### `<path>`

Covered behaviour:

- ...

Gaps:

- ...

## Contracts / External Interfaces

HTTP, Kafka, RabbitMQ, DB, OpenSearch, DynamoDB, dashboards, alerts, or other external surfaces.

## Observability Findings

Metrics, logs, dashboards, alerts, labels, cardinality risks, no-data behaviour.

## Constraints

Repository constraints the spec must respect.

## Risks

Implementation, compatibility, operational, security, privacy, or rollout risks discovered during research.

## Research Questions Answered

Map each research question from `spec.md` to an answer.

### Question

Answer:

Evidence:

- `<path>`

## Unknowns

Questions still unresolved after repository inspection.

## Planning Inputs

Concrete facts the planner must use later.
```

## Evidence Rules

Every important claim must cite concrete evidence:

- file path
- class/module/function name
- test file
- config file
- dashboard/alert path
- schema/contract path
- ADR/doc path

Do not write unsupported claims like:

- "probably"
- "seems"
- "likely"
- "should be easy"

If unsure, write it under `Unknowns`.

## Non-Goals

Do not:

- update `spec.md`
- create `delivery_artifacts/`
- create `plan.md`
- implement code
- add tests
- modify contracts
- make architecture decisions

## Output Rules

After writing `research.md`, return only:

- path written
- number of files inspected
- blocking unknowns, if any
- next recommended command

Example:

```md
Created:

- `doc/playbook/20260518_provider_output_observability/research.md`

Inspected:

- 12 files

Blocking unknowns:

- None

Next:

- Run `/sdd-refine doc/playbook/20260518_provider_output_observability`
```

