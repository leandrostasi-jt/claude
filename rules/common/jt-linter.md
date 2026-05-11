---
paths:
  - "**/*"
---
# JT Linter

JT Linter is the project's custom Rubocop wrapper. Always use it instead of plain `rubocop`.

## Usage

```bash
devkit exec <service_name> bundle exec jt-linter -A
```

The `-A` flag autocorrects all offenses (safe + unsafe). See `devkit.md` for service name conventions.

## Rules

- NEVER run `rubocop` directly — always use `jt-linter`.
- ALWAYS run via `devkit exec` (never on the host).
- Run after every Ruby change, before marking work complete.
