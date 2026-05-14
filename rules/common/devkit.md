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

## Rebuilding the container

Rebuild when any of these root-level files change, because they are baked into the image (not volume-mounted):

- `Gemfile` — triggers a fresh `bundle install`, generating a new `Gemfile.lock`
- `KafkaConsumersList`
- `Messagebusfile`
- `Procfile.consumers`

Steps:

```bash
devkit stop <service_name>
devkit build <service_name>
devkit up -d <service_name>
```

After rebuilding, copy any generated files back to the host with `docker cp`:

```bash
# Example: sync the new Gemfile.lock after a Gemfile change
docker cp <service_name>:/usr/local/jtservice/Gemfile.lock ./Gemfile.lock
```

## Rules

- ALWAYS use `devkit exec <service_name> <cmd>` to run commands — never run them directly on the host.
- The service name is derived from `basename $PWD`.
- Exception: Kotlin/Java services do **NOT** use devkit.
