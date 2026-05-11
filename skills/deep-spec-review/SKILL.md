---
name: deep-spec-review
description: Orchestrate a parallel multi-agent spec review across security, cost, compliance, ops, and architecture dimensions. Produces consolidated clarifying questions asked one at a time. Never modifies specs until each decision is approved.
origin: user
---

# Deep Spec Review

Run five specialized reviewers in parallel against spec documents, collect findings, and drive a structured Q&A session before any edits.

## When to Activate

- User invokes `/deep-spec-review` with an optional path argument (default: current directory)
- User says "parallel spec review", "deep review the spec", or "multi-agent review"
- Spec documents exist under a known path and require structured analysis before implementation

## Workflow

### Step 1 — Locate Documents

Resolve the target directory from the skill argument or default to the current project. Find the following files (case-insensitive, any subdirectory):

- `spec*.md` / `spec_v*.md`
- `operations*.md` / `ops*.md`
- `security*.md`

Read all matched files before dispatching agents. If no documents are found, ask the user to provide paths before proceeding.

### Step 2 — Dispatch 5 Subagents IN PARALLEL

Use the Agent tool to launch all five subagents in a **single message** (parallel execution). Each subagent receives the full document contents in its prompt and must:

1. Perform its analysis
2. **Write its findings to `reviews/<role>.md`** using the Write tool
3. Return only a 5-bullet summary to chat — never dump full analysis

#### Subagent Roles

| Role | File | Focus |
|------|------|-------|
| `security-auditor` | `reviews/security-auditor.md` | KMS usage, encryption-at-rest, IAM scope, secret exposure |
| `cost-analyst` | `reviews/cost-analyst.md` | S3 PUT/GET pricing, KMS API calls, monthly $ estimate, cost surprises |
| `compliance-reviewer` | `reviews/compliance-reviewer.md` | GDPR retention periods, deletion timing, data residency |
| `ops-reviewer` | `reviews/ops-reviewer.md` | Failure modes, idempotency guarantees, Sidekiq retry semantics, runbooks |
| `architecture-critic` | `reviews/architecture-critic.md` | Repository access patterns, coupling risks, scalability concerns |

#### Subagent Prompt Template

```
You are a <ROLE> reviewing a spec. Your job is to find gaps, ambiguities, and risks in the documents below.

DOCUMENTS:
<paste full document contents>

Instructions:
1. Analyze thoroughly from your specialist perspective.
2. Write your complete findings to reviews/<role>.md using this structure:
   ## Findings
   - [finding with specific doc reference]
   ## Open Questions
   - [question the spec author must answer]
   ## Risks
   - [risk and its severity: low/medium/high]
3. Return ONLY a 5-bullet summary to chat. Do not reproduce your full analysis in chat.
```

### Step 3 — Consolidate

After all five subagents return, read all five `reviews/<role>.md` files. Then:

1. Deduplicate overlapping questions across roles
2. Prioritize by severity: **high risk → compliance → cost → ops → architecture**
3. Write `reviews/consolidated_questions.md` with this structure:

```markdown
# Consolidated Questions — <date>

## Critical (must resolve before implementation)
1. [question] — raised by: security-auditor, compliance-reviewer

## Important (resolve before first deploy)
2. [question] — raised by: cost-analyst

## Nice to Have (can defer)
3. [question] — raised by: architecture-critic
```

### Step 4 — Q&A Loop

Work through `reviews/consolidated_questions.md` top to bottom:

- Ask **ONE question at a time** using `AskUserQuestion` (or plain text if the tool is unavailable)
- Keep each turn under **900 tokens**
- Record the user's answer in `reviews/consolidated_questions.md` inline (mark as `✅ Resolved: <answer>`)
- Move to the next question only after the current one is answered
- Do not suggest spec edits mid-loop

### Step 5 — Apply Edits (only after all questions resolved)

Once the user confirms all questions are answered:

1. Present a summary of all decisions
2. Ask: "Ready to apply edits to the spec files?"
3. Apply changes **only after explicit approval**
4. Touch only spec/ops/security doc files — never application code

## Constraints

- **Never modify spec files during Steps 1–4**
- **Never modify code files at any step**
- Each subagent writes to its own file — no cross-agent file writes
- If a subagent fails, log the error in `reviews/<role>.md` and continue with remaining agents
- Maximum one clarifying question per turn in the Q&A loop
