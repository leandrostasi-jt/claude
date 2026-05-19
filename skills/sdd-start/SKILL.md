---
name: sdd-start
description: Create an intent-level spec.md v0 for a feature before repository research. Uses AskUserQuestionTool to resolve blocking ambiguities. Does not inspect code, plan, or implement.
origin: user
---

# SDD Start

Create the initial intent-level spec for a feature from a rough requirement.

This skill turns an unclear idea into a clear `spec.md` v0 that can guide repository research.

It must not plan implementation.
It must not inspect repository code.
It must not modify application code.
It must not create `research.md`, `delivery_artifacts/`, or `plan.md`.

## Rules

Follow:

- `rules/sdd/workflow.md`

## When to Activate

Use this skill when:

- The user invokes `/sdd-start <feature-name>`
- The user says "create a spec"
- The user says "start SDD"
- The user says "turn this into a spec"
- The user provides a rough feature requirement and wants to begin feature work

## Inputs

The user may provide:

- A rough idea
- A product requirement
- A technical requirement
- A bug/change request
- A feature name
- A target playbook path

If the playbook path is not explicit, infer a reasonable path:

`doc/playbook/<YYYYMMDD>_<feature_slug>/`

Use a lowercase snake_case slug.

## Repository Knowledge Boundary

This skill must not claim facts about the current codebase unless they are provided by the user.

If current behaviour depends on repository inspection, write:

> Unknown. Must be discovered during `/sdd-research`.

Add concrete research questions that `/sdd-research` must answer.

## Workflow

### 1. Understand the rough requirement

Extract:

- problem
- goal
- users/consumers
- current behaviour, only if user-provided
- desired behaviour
- non-goals
- EARS requirements
- acceptance scenarios
- edge cases
- observability impact
- compatibility impact
- research questions
- open questions

### 2. Identify ambiguities

Classify ambiguities as blocking or non-blocking.

#### Blocking ambiguities

Questions that materially affect:

- scope
- behaviour
- EARS requirements
- acceptance scenarios
- data model
- external contracts
- compatibility
- rollout
- observability
- security/privacy/compliance
- operational risk

#### Non-blocking ambiguities

Questions that can safely remain as open questions in `spec.md`.

### 3. Ask the user before writing the spec

If blocking ambiguities exist, use `AskUserQuestionTool`.

Do not write `spec.md` until blocking ambiguities are resolved.

Ask grouped, concrete questions.
Prefer multiple-choice questions when possible.
Avoid asking more than 7 questions in one round unless the requirement is highly ambiguous.
Do not ask questions whose answer can be safely discovered later during `/sdd-research`.
Do not ask questions that only affect implementation details.

### 4. Incorporate answers

After receiving answers:

- update your understanding
- resolve the relevant ambiguities
- keep unresolved non-blocking questions in the `Open Questions` section
- do not silently discard user constraints

### 5. Write `spec.md`

Create:

`<playbook-path>/spec.md`

Do not create:

- `research.md`
- `delivery_artifacts/`
- `plan.md`
- application code
- tests
- infrastructure files

## AskUserQuestionTool Rules

Use `AskUserQuestionTool` when:

- the requested behaviour is ambiguous
- the target users/consumers are unclear
- there are conflicting interpretations
- EARS requirements cannot be written confidently
- acceptance criteria cannot be written confidently
- there is a risk of over-scoping
- there is a possible compatibility/security/operational concern
- the user has not specified what is explicitly out of scope

Do not use `AskUserQuestionTool` for:

- implementation details that `/sdd-research` should discover
- codebase facts that can be inspected later
- minor naming preferences
- questions that do not affect the spec

## Question Format

When using `AskUserQuestionTool`, ask questions in this style:

```md
I need to resolve these before writing `spec.md`:

1. **Scope**
   Should this feature affect:
   - A) only the API
   - B) API + async jobs
   - C) API + async jobs + dashboards/alerts

2. **Consumer**
   Who is the primary consumer?
   - A) internal backend service
   - B) frontend/client app
   - C) operations/support
   - D) external customer/integration

3. **Rollout**
   Should this be:
   - A) released directly
   - B) behind a feature flag
   - C) dark-launched first
```

Prefer clear options, but allow free-text answers.

## Requirements Syntax

Use EARS for all behavioural requirements.

Each requirement must:

- have a stable id: `REQ-001`, `REQ-002`, ...
- use `shall`
- be atomic
- be testable or verifiable
- avoid implementation details unless explicitly required
- avoid vague words like “properly”, “fast”, “easy”, or “robust” unless quantified

Allowed EARS patterns:

- Ubiquitous: `The system shall <response>.`
- Event-driven: `When <trigger>, the system shall <response>.`
- State-driven: `While <state>, the system shall <response>.`
- Optional: `Where <feature/condition>, the system shall <response>.`
- Unwanted behaviour: `If <unwanted event>, then the system shall <response>.`

## spec.md Structure

Write the spec using this structure:

```md
<!-- sdd: spec_version=v0 -->
<!-- sdd: refined=false -->

# Spec: <feature>

## Problem

Describe the problem being solved.

## Goal

Describe what should be true after this feature exists.

## Non-goals

List what is explicitly out of scope.

## Users / Consumers

List who consumes or depends on this behaviour.

## Current Behaviour

Describe what happens today, based only on user-provided information.

If current behaviour must be researched later, say:

Unknown. Must be discovered during `/sdd-research`.

## Desired Behaviour

Describe the target behaviour.

## Requirements

### REQ-001

When <trigger>, the system shall <response>.

### REQ-002

The system shall <response>.

### REQ-003

If <unwanted event>, then the system shall <response>.

## Acceptance Scenarios

Use Given / When / Then.

### Scenario 1: <name>

Given ...
When ...
Then ...

### Scenario 2: <name>

Given ...
When ...
Then ...

## Edge Cases

List relevant edge cases.

## Observability

Describe expected metrics, logs, dashboards, alerts, or operational visibility.

Keep this behavioural, not implementation-specific.

## Compatibility

Mention APIs, DB, Kafka, background jobs, clients, migrations, backwards compatibility, or rollout concerns.

## Security / Privacy / Compliance

Mention only if relevant.

## Research Questions

List codebase questions that must be answered before planning.

- [ ] Where does the current flow live?
- [ ] Which files/components are likely impacted?
- [ ] Which existing contracts, dashboards, jobs, or consumers constrain the change?

## Open Questions

Use checkboxes for non-blocking questions.

- [ ] ...
```

## Assumption Policy

The skill may make safe assumptions only when:

- the assumption does not affect scope
- the assumption does not affect external behaviour
- the assumption can be corrected during `/sdd-research`
- the assumption is explicitly written in `Open Questions`

The skill must not make assumptions about:

- business rules
- acceptance criteria
- consumers
- rollout strategy
- backwards compatibility
- security/privacy requirements
- operational expectations

## Quality Bar

The generated spec must be:

- behaviour-focused
- implementation-light
- explicit about non-goals
- expressed with EARS requirements
- clear enough for `/sdd-research`
- clear enough to later derive `delivery_artifacts/`
- not dependent on hidden assumptions

## Output Rules

After writing `spec.md`, return only:

- path created
- short summary of the spec
- number of open questions
- next recommended command

Example:

```md
Created:

- `doc/playbook/20260518_provider_output_observability/spec.md`

Summary:

- Defines provider output observability by channel and notification group.
- Keeps implementation details deferred to `/sdd-research`.

Open questions:

- 2 non-blocking questions remain.

Next:

- Run `/sdd-research doc/playbook/20260518_provider_output_observability`
```

