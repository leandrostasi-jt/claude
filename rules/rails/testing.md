---
paths:
  - "**/*.rb"
  - "**/*.rake"
---
# Rails Testing

> This file extends [common/testing.md](../common/testing.md) with Rails specific content.

## Framework

- Use **Minitest** + **FactoryBot** + **Shoulda Matchers** for all tests.
- Use **RSpec** + **FactoryBot** + **Shoulda Matchers** **ONLY** for controller E2E tests.

## Test Organization

```ruby
# Unit: test/models/, test/services/, test/lib/
class CreateUserTest < ActiveSupport::TestCase
  test "creates a user with valid params" do
    result = CreateUser.new(name: "Alex", email: "a@b.com").call
    assert result.persisted?
  end
end

# Integration: test/controllers/ or test/requests/
class UsersControllerTest < ActionDispatch::IntegrationTest
  test "POST /users returns 201" do
    post users_url, params: { name: "Alex", email: "a@b.com" }
    assert_response :created
  end
end

# E2E controller tests (RSpec only): spec/requests/
RSpec.describe "POST /users", type: :request do
  it "returns 201" do
    post "/users", params: { name: "Alex", email: "a@b.com" }
    expect(response).to have_http_status(:created)
  end
end

# System: test/system/ (Capybara)
```

## Reference

See skill: `rails-testing` for detailed patterns, shared examples, and database cleaner setup.
