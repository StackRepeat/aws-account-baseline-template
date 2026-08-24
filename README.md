# AWS account baseline template

Use this repository as the starting point for the AWS account baseline attached
to a platform. The template is intentionally empty: it contains the runtime
scaffolding and validation checks, but it does not create, update, or delete any
AWS resources.

Create a repository from this template for each platform that needs its own
baseline. Keeping platform baselines separate makes their change history,
reviews, and rollout independent.

## Get started

1. Select **Use this template** on GitHub and create a repository for your
   platform, for example `production-account-baseline`.
2. Clone the new repository.
3. Add Terraform resources to `terraform/`.
4. If Terraform cannot perform a required operation, add an API helper under
   `api_helpers/`.
5. Open a pull request. The included GitHub Actions workflow formats and
   validates the baseline on a public `ubuntu-latest` runner without using AWS
   credentials.
6. After review, merge the pull request and follow your platform's normal
   baseline rollout process.

## Repository structure

| Path | Purpose |
| --- | --- |
| `terraform/` | Terraform resources, data sources, variables, locals, and outputs that form the baseline. |
| `terraform/versions.tf` | Supported Terraform and AWS provider versions. Add other required providers here. |
| `terraform/.terraform.lock.hcl` | Reproducible provider selections. Commit changes to this file when providers are upgraded. |
| `terraform/backend.jinja` | Runtime-rendered state backend. Keep credentials and concrete backend values out of the repository. |
| `terraform/stack-repeat-providers.jinja` | Runtime-rendered AWS provider and target-account role. |
| `api_helpers/pre-api-helpers.sh` | Optional commands that run before Terraform. It is a no-op by default. |
| `api_helpers/post-api-helpers.sh` | Optional commands that run after Terraform. It is a no-op by default. |
| `api_helpers/python/requirements.txt` | Optional Python packages used by API helpers. |
| `.github/workflows/checks.yml` | Credential-free pull-request and `main` branch validation on GitHub-hosted runners. |

The two Jinja files are part of the platform runtime contract. Add normal `.tf`
files alongside them; do not replace the generated backend or provider with
hard-coded account details.

## Add Terraform resources

Organize resources by responsibility rather than putting the entire baseline in
one file. A growing baseline might use names such as:

```text
terraform/
├── versions.tf
├── data.tf
├── iam.tf
├── logging.tf
├── security.tf
├── variables.tf
└── outputs.tf
```

Before opening a pull request:

```bash
make test
```

This command runs `terraform fmt`, initializes providers without the runtime
backend, validates the Terraform configuration, and checks the shell helper
syntax. It does not contact an AWS account or run `terraform plan` or
`terraform apply`.

When adding resources:

- Give each resource a stable Terraform address and a clear name. Renaming a
  resource block can cause replacement unless its state is moved explicitly.
- Prefer inputs, data sources, and runtime-provided identity over hard-coded
  account IDs, regions, role ARNs, or environment names.
- Pin new providers in `versions.tf`, run `terraform init -upgrade`, and commit
  the updated lock file.
- Never commit credentials, state files, plans, or populated `.tfvars` files.
- Keep changes small enough to review and roll out safely across every account
  attached to the platform.

## Add API helpers

Use API helpers only when the operation cannot be modeled safely in Terraform.
Add Python files below `api_helpers/python/`, list third-party packages in
`requirements.txt`, and invoke the helper from the pre- or post-Terraform shell
script as appropriate.

Helper scripts should be idempotent: running the same revision twice should
produce the same result. Keep `set -euo pipefail` in the shell entry points so a
failed helper stops the baseline run. Do not embed credentials; use the runtime
AWS identity.

## Pull-request checks

The `Baseline checks` workflow runs for pull requests, pushes to `main`, and
manual dispatches. It uses read-only repository permissions and public GitHub
runners. The checks deliberately stop at static Terraform validation because a
template cannot know a user's AWS accounts or credentials.

After creating a repository from this template, you can make the `Validate`
check required in the new repository's branch protection rules.

## License

This template is available under the [Mozilla Public License 2.0](LICENSE).
