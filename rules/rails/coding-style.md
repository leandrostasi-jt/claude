---
paths:
  - "**/*.rb"
  - "**/*.rake"
  - "**/Gemfile"
---
# Rails Coding Style

> This file extends [common/coding-style.md](../common/coding-style.md) with Rails specific content.

## Standards

- Follow **Ruby Style Guide** conventions
- Use **frozen_string_literal: true** at the top of every file

## Immutability

Prefer value objects and avoid mutating state in models:

```ruby
# frozen_string_literal: true

UserResult = Data.define(:name, :email)

result = UserResult.new(name: "Alex", email: "a@example.com")
```

## Formatting

- **jt-linter** for linting and style enforcement
- **rubocop-rails** for Rails-specific cops
- **rubocop-rspec** if using RSpec

## Reference

See skill: `rails-patterns` for comprehensive Rails idioms and patterns.
