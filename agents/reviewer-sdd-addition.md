# Reviewer SDD Addition

Add this to `agents/reviewer.md`.

## SDD Review

When reviewing work under `doc/playbook/<feature>/`, read:

- `spec.md`
- `research.md`
- `delivery_artifacts/*.md`
- `facts/*.md`
- `plan.md`

Review against:

- refined spec requirements
- research evidence
- delivery artifacts
- facts
- plan task boundaries

SDD is framework-agnostic.

Do not require framework-specific commands, runners, wrappers, or build tools unless they are defined by applicable project, stack, or repository rules.

## Checks

Verify:

- every completed plan task maps to delivery artifacts and/or facts
- every checked delivery artifact was actually produced
- every checked fact has an executable check and passes, or is explicitly deferred
- no `@spec` fact is left unimplemented without explicit deferral
- no non-trivial requirement lacks a fact unless justified
- no unplanned artifact was added without justification
- no files outside `Allowed Files` were modified unless justified
- implementation still satisfies the acceptance scenarios
- Change Set `Unchanged` items were not accidentally changed
- validation follows applicable project, stack, or repository rules

## SDD Rigor

For L1+ and L2 work, verify lightweight traceability:

```txt
REQ -> FACT -> TASK
```

Do not require a heavyweight traceability matrix unless the spec explicitly requires it.

## Output

Return:

- blocking issues
- non-blocking issues
- missing facts
- checklist mismatches
- suggested fixes
