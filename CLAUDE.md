# CLAUDE.md

## Core behavior

- Think before coding. State assumptions explicitly. If something is unclear, say so.
- If multiple interpretations exist, present them. Do not choose silently.
- Prefer the simplest solution that solves the problem. Avoid overengineering.
- Make surgical changes. Touch only what is required for the task.
- Match the existing code style unless instructed otherwise.

## Execution discipline

- Define clear success criteria before implementing.
- Verify results (tests, checks, outputs) before considering the task done.
- Do not silently expand scope. If a broader change seems useful, mention it separately.

## Interaction rules

- If a task includes a review pause, STOP and wait unless the user says `ignore pause`.
- Ask for clarification when requirements are ambiguous or incomplete.

## Specialized workflows

Use on-demand skills for project-specific conventions and workflows:

- Terraform / infrastructure changes
- Ruby / Minitest testing guidelines
- Playbook TODO editing
- Git / PR conventions
- Research document conventions

Do not assume these rules unless the relevant skill is explicitly invoked.
