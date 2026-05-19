# Claude Code Configuration

A set of agents, skills, and rules for disciplined AI-assisted development with [Claude Code](https://claude.ai/code).

## What's in here

### `CLAUDE.md`

The main instruction file loaded by Claude Code in every session.

It should stay small and define only the core behavioural constraints:

- Think before coding — state assumptions explicitly and surface ambiguities.
- Simplicity first — write the minimum code that solves the problem.
- Surgical changes — touch only what the task requires.
- Goal-driven execution — define success criteria and verify results.

Workflow-specific guidance should live in `rules/` and `skills/`, not directly in `CLAUDE.md`.

### `agents/`

Custom subagent definitions. Each agent has a narrow, well-defined role:

| Agent | Role |
|-------|------|
| `planner` | Converts an approved task/spec into a deterministic `plan.md` |
| `implementer` | Executes an approved `plan.md` with minimal changes |
| `reviewer` | Reviews code changes against the plan, spec, and delivery artifacts |
| `tdd-guide` | Enforces test-first workflow: red → green → refactor |
| `tech-lead` | Research and planning only — never modifies code |

### `skills/`

Slash commands that orchestrate multi-step workflows:

| Skill | Command | What it does |
|-------|---------|--------------|
| `sdd-start` | `/sdd-start` | Creates an intent-level `spec.md` v0 from a rough requirement, using `AskUserQuestionTool` to resolve blocking ambiguities |
| `sdd-research` | `/sdd-research` | Inspects the repository against `spec.md` and writes `research.md` with concrete code evidence |
| `sdd-refine` | `/sdd-refine` | Refines `spec.md` using `research.md`, producing the planning-ready version |
| `sdd-delivery-artifacts` | `/sdd-delivery-artifacts` | Creates `delivery_artifacts/*.md`, a feature-specific map of what must be produced or modified |
| `execute-plan` | `/execute-plan` | Reads `plan.md` and drives every task to completion using a TDD loop, parallelizing disjoint tasks when safe |
| `deep-spec-review` | `/deep-spec-review` | Runs specialist reviewers in parallel — security, cost, compliance, ops, architecture — and conducts structured Q&A before edits |
| `architecture-decision-records` | `/architecture-decision-records` | Captures architectural decisions as structured ADR documents in `docs/adr/` |
| `spec-review` | `/spec-review` | Lightweight spec review |

### `rules/`

Domain-specific standards and workflow rules loaded on demand:

```text
rules/
├── common/       # Coding style, testing, security, patterns, hooks, devkit, jt-linter
├── rails/        # Rails-specific style, testing, security, patterns, hooks
├── terraform/    # Terraform, DynamoDB, IAM and infrastructure rules
└── sdd/          # Spec-Driven Development workflow and artifact rules
```

### `settings.json`

Claude Code project configuration — permissions allowlist, model selection, and token limits.

## How it works

There are two main operating modes.

### Lightweight mode

Use this for trivial or mechanical work:

1. **Plan** — invoke the `planner` agent with a task description.
2. **Execute** — run `/execute-plan`.
3. **Review** — invoke the `reviewer` agent.

This mode is appropriate for:

- typo fixes
- small copy changes
- obvious one-line configuration changes
- mechanical renames with no behavioural impact

### Spec-Driven Development mode

Use SDD for non-trivial feature work, ambiguous requirements, behaviour changes, API changes, background jobs, observability changes, infrastructure changes, or anything where implementation should not start from a vague prompt.

The SDD workflow is:

```text
/sdd-start
  → spec.md v0

/sdd-research
  → research.md

/sdd-refine
  → spec.md v1

/sdd-delivery-artifacts
  → delivery_artifacts/*.md

planner
  → plan.md + plan/tN.md

/execute-plan
  → code changes + validation

reviewer
  → final review against spec, research, delivery artifacts, and plan
```

The goal is to avoid jumping from a rough requirement directly into implementation.

## How to use SDD

Create a playbook directory for the feature:

```text
doc/playbook/<YYYYMMDD>_<feature_slug>/
```

Example:

```text
doc/playbook/20260519_provider_output_observability/
```

### 1. Start from intent

Run:

```text
/sdd-start doc/playbook/<feature>
```

This creates:

```text
spec.md
```

At this stage, `spec.md` is an intent-level spec. It should describe:

- problem
- goal
- non-goals
- users or consumers
- desired behaviour
- EARS requirements
- acceptance scenarios
- observability expectations
- compatibility concerns
- research questions

`sdd-start` must not claim facts about the current codebase unless the user explicitly provided them.

If current behaviour depends on repository inspection, the spec should say:

```text
Unknown. Must be discovered during /sdd-research.
```

### 2. Research the repository

Run:

```text
/sdd-research doc/playbook/<feature>
```

This creates:

```text
research.md
```

`research.md` is the source of truth for repository evidence. It should record:

- relevant files
- current flows
- existing tests
- contracts and external interfaces
- operational surfaces
- risks
- unknowns
- planning inputs

It must not create a plan or modify code.

### 3. Refine the spec

Run:

```text
/sdd-refine doc/playbook/<feature>
```

This updates `spec.md` using the evidence from `research.md`.

After this step, `spec.md` becomes the planning-ready version.

The refined spec should reconcile:

```text
user intent + repository evidence
```

If research conflicts with the original intent, the conflict must be surfaced explicitly. The spec must not silently change product intent just because the current code makes something easier.

### 4. Generate delivery artifacts

Run:

```text
/sdd-delivery-artifacts doc/playbook/<feature>
```

This creates:

```text
delivery_artifacts/*.md
```

`delivery_artifacts/` is a variable, feature-specific map of what must be produced or modified.

It is not a fixed category list.

Examples of valid delivery artifact files:

```text
delivery_artifacts/
├── 01-api-contracts.md
├── 02-domain-model.md
├── 03-jobs-consumers.md
└── 04-observability.md
```

or:

```text
delivery_artifacts/
├── 01-grafana-dashboard.md
├── 02-terraform-alerts.md
└── 03-runbook.md
```

The actual files must be inferred from the feature.

Tests are not delivery artifacts. Tests belong in the plan and task validation sections.

### 5. Plan from the refined inputs

Invoke the `planner` agent only after these exist:

```text
spec.md
research.md
delivery_artifacts/*.md
```

The planner must read:

- `spec.md`
- `research.md`
- every markdown file under `delivery_artifacts/`
- referenced ADRs
- relevant rules

The planner produces:

```text
plan.md
plan/t1.md
plan/t2.md
...
```

The plan must cover every concrete artifact listed under `delivery_artifacts/*.md`.

Each task should include:

- `Delivers`
- allowed files
- implementation notes
- validation/tests
- done criteria

### 6. Execute the approved plan

Run:

```text
/execute-plan doc/playbook/<feature>
```

Execution must follow the approved plan and modify only files allowed by the relevant task.

Validation must use the project-specific commands, normally through `devkit`.

### 7. Review the result

Invoke the `reviewer` agent.

The review should check the diff against:

- refined `spec.md`
- `research.md`
- `delivery_artifacts/*.md`
- `plan.md`
- completed `plan/tN.md` tasks

The reviewer should verify that all delivery artifacts were produced or explicitly deferred.

## EARS requirements in specs

Specs should use EARS for behavioural requirements.

Each important requirement should:

- have a stable id: `REQ-001`, `REQ-002`, ...
- use `shall`
- be atomic
- be testable or verifiable
- avoid vague words like "properly", "easy", "fast", or "robust" unless quantified

Preferred EARS patterns:

```text
The system shall <response>.
When <trigger>, the system shall <response>.
While <state>, the system shall <response>.
Where <feature or condition>, the system shall <response>.
If <unwanted event>, then the system shall <response>.
```

Example:

```text
REQ-001:
When a provider output attempt is made, the system shall record the attempt grouped by channel.

REQ-002:
When recording provider output metrics, the system shall not include user-level identifiers as metric labels.

REQ-003:
If the provider output attempt fails, then the system shall preserve the existing retry behaviour.
```

Acceptance scenarios may use Given/When/Then, but they do not replace EARS requirements.

## SDD artifact responsibilities

| Artifact | Responsibility |
|----------|----------------|
| `spec.md` | Behavioural source of truth |
| `research.md` | Repository-evidence source of truth |
| `delivery_artifacts/*.md` | Production-scope source of truth |
| `plan.md` | Execution source of truth |
| `plan/tN.md` | Atomic task instructions |
| tests/contracts/schemas/ADRs/dashboards/alerts/code | Permanent artifacts |

## Based on

Forked and adapted from:

- [Karpathy's Claude.md](https://github.com/forrestchang/andrej-karpathy-skills/blob/main/CLAUDE.md)
- [Everything-Claude-Code](https://github.com/affaan-m/everything-claude-code)

