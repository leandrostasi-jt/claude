# Testing Requirements

## Minimum Test Coverage: 80%

Test Types (ALL required):
1. **Unit Tests** - Models, services, plain Ruby/Elixir objects
2. **Integration Tests** - API endpoints, database operations, controllers
3. **E2E / System Tests** - Critical user flows (Capybara for Rails, Wallaby for Elixir)

## Test-Driven Development

MANDATORY workflow:
1. Write test first (RED)
2. Run test — it should FAIL
3. Write minimal implementation (GREEN)
4. Run test — it should PASS
5. Refactor (IMPROVE)
6. Verify coverage (80%+)

## Troubleshooting Test Failures

1. Use **tdd-guide** agent
2. Check test isolation (database cleanup, shared state)
3. Verify factories/fixtures are correct
4. Fix implementation, not tests (unless tests are wrong)

## Agent Support

- **tdd-guide** - Use PROACTIVELY for new features, enforces write-tests-first

## Test Structure (AAA Pattern)

Prefer Arrange-Act-Assert structure for tests (don't include AAA comments):

```ruby
class OrderServiceTest < ActiveSupport::TestCase
  test "applies discount when user is premium" do
    # Arrange
    user = users(:premium)
    items = [order_items(:shirt), order_items(:pants)]

    # Act
    total = OrderService.new(user, items).calculate_total

    # Assert
    assert_equal 160, total
  end
end
```

### Test Naming

Use descriptive names that explain the behavior under test:

```ruby
test "returns empty array when no markets match query"
test "throws error when API key is missing'"
test "falls back to substring search when Redis is unavailable"
```
