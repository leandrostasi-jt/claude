---
paths:
  - "**/*.rb"
  - "**/*.rake"
---
# Rails Patterns

> This file extends [common/patterns.md](../common/patterns.md) with Rails specific content.

## Service Objects

Keep controllers thin; push business logic into service objects:

```ruby
class CreateUser
  def initialize(params)
    @params = params
  end

  def call
    User.create!(@params)
  end
end
```

## Query Objects

Extract complex scopes into dedicated query objects instead of polluting models:

```ruby
class ActivePremiumUsersQuery
  def call
    User.where(active: true, plan: "premium")
  end
end
```

## Form Objects / DTOs

Use plain Ruby objects or `ActiveModel` to encapsulate multi-model forms:

```ruby
class RegistrationForm
  include ActiveModel::Model

  attr_accessor :name, :email, :password

  validates :name, :email, :password, presence: true
end
```

## Reference

See skill: `rails-patterns` for comprehensive patterns including concerns, decorators, and background jobs.
