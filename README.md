# Claude Code Configuration

A set of agents, skills, and rules for disciplined AI-assisted development with [Claude Code](https://claude.ai/code).

## What's in here

### `CLAUDE.md`

The main instruction file loaded by Claude Code in every session. Defines core behavioral constraints:

- Think before coding — state assumptions explicitly, surface ambiguities
- Simplicity first — minimum code that solves the problem
- Surgical changes — touch only what the task requires
- Goal-driven execution — define success criteria, verify results

### `agents/`

Custom subagent definitions. Each agent has a narrow, well-defined role:

| Agent | Role |
|-------|------|
| `planner` | Converts a task description into a deterministic `plan.md` |
| `implementer` | Executes an approved `plan.md` with minimal changes |
| `reviewer` | Code review focused on critical issues, warnings, and suggestions |
| `tdd-guide` | Enforces test-first workflow (red → green → refactor) |
| `tech-lead` | Research and planning only — never modifies code |

### `skills/`

Slash commands that orchestrate multi-step workflows:

| Skill | Command | What it does |
|-------|---------|--------------|
| `execute-plan` | `/execute-plan` | Reads `plan.md` and drives every task to completion using a TDD loop, parallelizing disjoint tasks |
| `deep-spec-review` | `/deep-spec-review` | Runs 5 specialist reviewers in parallel (security, cost, compliance, ops, architecture) and conducts a structured Q&A before any edits |
| `architecture-decision-records` | `/architecture-decision-records` | Captures architectural decisions as structured ADR documents in `docs/adr/` |
| `spec-review` | `/spec-review` | Lightweight spec review |

### `rules/`

Domain-specific coding standards loaded on demand:

```
rules/
├── common/       # Coding style, testing, security, patterns, hooks, devkit, jt-linter
├── rails/        # Rails-specific style, testing, security, patterns, hooks
└── terraform/    # DynamoDB table provisioning and IAM permissions
```

### `settings.json`

Claude Code project configuration — permissions allowlist, model selection (`sonnet`), and token limits.

## How it works

The typical workflow for a feature or bug fix:

1. **Plan** — invoke the `planner` agent with a task description → produces `plan.md`
2. **Execute** — run `/execute-plan` → agents write failing tests, implement, verify, and mark tasks complete
3. **Review** — the `reviewer` agent checks the diff before marking work done

For specs or architectural decisions, use `/deep-spec-review` or `/architecture-decision-records` respectively.

## Based on

Forked and adapted from:
- [Karpathy's Claude.md](https://github.com/forrestchang/andrej-karpathy-skills/blob/main/CLAUDE.md)
- [Everything-Claude-Code](https://github.com/affaan-m/everything-claude-code).
