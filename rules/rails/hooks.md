---
paths:
  - "**/*.rb"
  - "**/*.rake"
---
# Rails Hooks

> This file extends [common/hooks.md](../common/hooks.md) with Rails specific content.

## PostToolUse Hooks

Configure in `~/.claude/settings.json`:

- **jt-linter**: Auto-lint `.rb` files after edit (`jt-linter -A`)
- **brakeman**: Run security scan after editing app code

## Warnings

- Warn about `puts` / `p` statements in edited files (use `Rails.logger` instead)
- Warn about missing `before_action` auth guards in new controller actions
