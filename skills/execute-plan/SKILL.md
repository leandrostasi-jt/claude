---
name: execute-plan
description: Read plan.md and execute every unchecked task autonomously using a TDD loop: write failing tests, implement, verify with devkit exec, mark complete. Runs disjoint tasks in parallel.
origin: user
---

# Execute Plan

Read `plan.md` and drive every unchecked task to completion autonomously using a test-first loop.

## When to Activate

- User invokes `/execute-plan` with an optional path argument
- User says "ejecuta el plan", "run the plan", "execute all pending tasks", "implement everything in plan.md"
- A `plan.md` exists in the project and the user asks to start, continue, or resume implementation

## Workflow

### Step 0 — Locate plan.md

If `$ARGUMENTS` provides a path, use it. Otherwise search the project for `plan.md` (prefer `doc/playbook/*/plan.md`). Read the file fully before proceeding.

### Step 1 — Parallelism analysis

Scan all unchecked tasks and group them by the files they touch. Tasks whose file scopes do not overlap are **disjoint** and may be launched in parallel via the Task tool in a **single Agent call**. Tasks that share files must run sequentially.

### Step 2 — Execution loop

For each unchecked task (or parallel batch of disjoint tasks):

#### 2a — Write failing tests

Invoke the **tdd-guide** agent:

```
Write failing tests for the following task. Scope your tests strictly to these files: <files>.
Do not modify any application code. Do not touch friendly_id slug behavior.
Task: <task description>
```

Wait for the agent to return before proceeding.

#### 2b — Implement

Invoke the **implementer** agent:

```
Make the following failing tests pass.
Constraints:
- Do not modify code outside the files listed below.
- Do not touch friendly_id slug behavior.
- Do not add features beyond what the tests require.
Files: <files>
Tests: <test file paths from 2a>
```

#### 2c — Verify

Run tests and linter using `devkit exec` — **never bare `bundle exec`**:

```
devkit exec bundle exec rails test <test file paths>
devkit exec bundle exec jt-linter
```

**Pass:** mark the task complete in `plan.md` (`- [ ]` → `- [x]`) immediately, then continue.

**Fail:** fix the immediate error and retry once. If they still fail after the second attempt, stop the entire loop and output a failure summary of ≤ 400 tokens: which task failed, the error output, and what was attempted.

## Constraints

- `devkit exec bundle exec rails test <file>` only — never `bundle exec` directly.
- Never rewrite tests to make them pass artificially.
- Never ask the user anything unless completely blocked with no path forward.
- Write `- [x]` to `plan.md` immediately after each task is verified — do not batch writes.
- Parallel tasks must be launched in a **single** Agent tool call.
