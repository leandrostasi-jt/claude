---
paths:
  - "**/*"
---
# DevKit

All services are Dockerized. Use `devkit` to run any command inside the service container.

## Usage

```
devkit exec <service_name> <cmd>
```

The service name is the **name of the current directory**.

```bash
# Example: ~/Projects/communication-center/
devkit exec communication-center bundle exec rails test
devkit exec communication-center bundle exec rails console
devkit exec communication-center jt-linter
```

## Service detection

Determine `<service_name>` from the current project directory name unless the user specifies it explicitly.

Examples:
- `~/Projects/communication-center` → `communication-center`
- `~/Projects/farming` → `farming`

If the service name is ambiguous, state the assumption before running commands.

## Rules

- ALWAYS use `devkit exec <service_name> <cmd>` to run commands — never run them directly on the host.
- The service name is derived from `basename $PWD`.
- Exception: Kotlin/Java services do **NOT** use devkit.
