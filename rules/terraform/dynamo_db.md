# Terraform — DynamoDB Tables

Guidelines for adding or modifying DynamoDB tables using Terraform.

## Core principle

When adding a new DynamoDB table, ensure that BOTH infrastructure definition and permissions are updated.

## Required changes

1. Define the table in Terraform:
   - Typically in a `dynamodb` or infrastructure module
   - Ensure naming follows environment conventions (e.g. `<service>-<env>-<table>`)

2. Update IAM permissions:
   - Add the table ARN to the relevant IAM policy or variable (e.g. `*_records_arn`)
   - Ensure the service has access to:
     - read/write operations as required
     - indexes if used

## Environments

Always apply changes consistently across environments:
- staging
- production

Avoid adding resources to only one environment unless explicitly required.

## Validation checklist

Before finishing:

- Table is defined in Terraform
- Table name follows conventions
- ARN is added to IAM configuration
- Permissions match expected usage
- Plan shows expected changes only

## Common failure

Forgetting to update IAM permissions:
→ results in runtime failures even if the table exists
