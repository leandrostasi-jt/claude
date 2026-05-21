---
name: execute-plan
description: Read plan.md and execute every unchecked task autonomously using a TDD loop: write failing tests, implement, verify with devkit exec, mark complete. Runs disjoint tasks in parallel.
origin: user
---

# Execute Plan

Read `plan.md` and drive every unchecked task to completion autonomously using a test-first loop.

## When to Activate

- User invokes `/execute-plan` with an optional path argument
- User says "execute plan", "run the plan", "execute all pending tasks", "implement everything in plan.md"
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

```txt
Write failing tests for the following task. Scope your tests strictly to these files: <files>.
Do not modify any application code. Do not touch friendly_id slug behavior.
Task: <task description>
```

Wait for the agent to return before proceeding.

#### 2b — Implement

Invoke the **implementer** agent:

```txt
Make the following failing tests pass.
Constraints:
- Do not modify code outside the files listed below.
- Do not touch friendly_id slug behavior.
- Do not add features beyond what the tests require.
Files: <files>
Tests: <test file paths from 2a>
```

#### 2c — Verify

Run the task validation using the applicable project rules.

Use the validation commands defined by:

- the task file
- `plan.md`
- repository-specific rules
- common rules
- stack-specific rules

Do not invent command conventions.

Do not run commands directly on the host if project rules require a wrapper.

Do not bypass project rules with raw tooling.

If validation fails, fix the immediate error and retry once.

If validation still fails after the second attempt, stop the entire loop and output a failure summary of ≤ 400 tokens:

- which task failed
- the error output
- what was attempted
- what help is needed

**Pass:** update tracking immediately, then continue.

For every verified task:

1. Mark the task complete in `plan.md` (`- [ ]` → `- [x]`).
2. If the task has a corresponding `plan/tN.md`, mark completed `Done When` items as `[x]`.
3. If the task delivers items from `delivery_artifacts/*.md`, mark only the produced artifacts as `[x]`.
4. If the task implements facts from `facts/*.md`, mark them as complete only if their executable checks exist and passed.
5. If a fact file uses status markers, set a fact to `@implemented` only when its executable check exists and passed.

Update these files one by one in small chunks following `rules/common/output-budget.md`.

Do not batch tracking updates at the end of the whole plan.

**Fail:** fix the immediate error and retry once. If they still fail after the second attempt, stop the entire loop and output a failure summary of ≤ 400 tokens: which task failed, the error output, and what was attempted.

## Constraints

- Run validation using the applicable project, stack, and common rules.
- Do not invent command conventions.
- Do not bypass project rules with raw tooling.
- If the applicable rules cannot complete the task, stop and ask the user for help using `AskUserQuestionTool`.
- Never rewrite tests to make them pass artificially.
- Never ask the user anything unless completely blocked with no path forward.
- Update SDD tracking files immediately after each task is verified — do not batch tracking updates.
- At minimum, mark the task as `[x]` in `plan.md`.
- When applicable, also update `plan/tN.md`, `delivery_artifacts/*.md`, and `facts/*.md`.
- Do not mark delivery artifacts or facts complete unless they were actually produced and verified.
- Parallel tasks must be launched in a **single** Agent tool call.

## SDD Guardrails

Before execution, if the plan lives under `doc/playbook/<feature>/`:

- Verify `spec.md` exists
- Verify `research.md` exists
- Verify every unchecked task points to a task file or contains explicit file scope
- Refuse to execute if the plan requires architectural decisions not captured in an ADR or explicitly approved in the plan

## SDD Tracking

For plans under `doc/playbook/<feature>/`, completing implementation is not enough.

A task is complete only when relevant tracking state is updated.

After each verified task, update the applicable files:

- `plan.md`
- `plan/tN.md`
- `delivery_artifacts/*.md`
- `facts/*.md`

Rules:

- Mark only actually completed items.
- Keep incomplete items unchecked.
- Set facts to `@implemented` only when executable checks exist and pass.
- Keep facts as `@spec` if implementation exists but verification has not passed.
- Use `@deferred` only when explicitly approved.
- Follow `rules/common/output-budget.md`: update files one by one in small chunks.

Do not return `done`, `completed`, or `waiting for review` until applicable tracking files have been updated.

If tracking cannot be updated safely, stop and explain the blocker.

## Done Criteria

A task is done only when:

- failing tests were written when applicable
- implementation is complete
- required validation passed
- SDD tracking files are updated when applicable
- no out-of-scope files were modified
