---
paths:
  - "**/*.rb"
  - "**/*.rake"
  - "**/Gemfile"
---
# Rails Security

> This file extends [common/security.md](../common/security.md) with Rails specific content.

## Secret Management

```ruby
# config/application.rb — never hardcode values
api_key = Rails.application.credentials.some_api_key!
# or via ENV
api_key = ENV.fetch("SOME_API_KEY")
```

Never commit `config/master.key` or `config/credentials.yml.enc` decrypted values.

## Security Scanning

- Use **brakeman** for static security analysis:
  ```bash
  brakeman --no-pager
  ```
- Use **bundler-audit** to check for vulnerable gems:
  ```bash
  bundle audit check --update
  ```

## Rails-specific Checks

- Always use `strong_parameters` (`permit`) — never pass raw `params` to models
- Scope all queries to the current user to prevent IDOR
- Set `config.force_ssl = true` in production
- Keep `protect_from_forgery` enabled (default)

## Reference

See skill: `rails-security` for Rails-specific security guidelines.
