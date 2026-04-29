# Ruby Testing Guidelines

## Core rules (unit tests)

- Use Minitest for unit tests
- NEVER add AAA comments (ARRANGE / ACT / ASSERT)
- Always test the public interface only
- DO NOT use `send` to access private methods
- DO NOT duplicate tests already covered by parent classes or modules

## Testing philosophy

- One concept per test
- Tests must be independent
- Prefer simple, readable tests over clever ones

## Structure

- Use clear English descriptions in test names
- Use consistent helper naming:
  - `fixture_` for static data
  - `build_` for object builders
  - `mock_` for mocks

## Controller / endpoint testing

When implementing or modifying an endpoint:

You MUST write BOTH:

1. Unit tests (Minitest)
   - Cover internal logic (services, actions, validations)
   - Test public interfaces only

2. E2E tests (RSpec)
   - Exercise the full HTTP request/response flow
   - Cover:
     - happy path
     - validation errors
     - relevant edge cases

## General principle

- Minitest → internal correctness
- RSpec → real system behavior
