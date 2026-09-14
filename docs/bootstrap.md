# Bootstrap Guide

How to go from zero to a working `terraform plan` against the
`wellthatsgaurav` GitHub organization.

---

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Terraform CLI | 1.16.2 | https://developer.hashicorp.com/terraform/install |
| git | any | system package manager |
| gh (optional) | any | https://cli.github.com |

---

## Step 1 — Clone the repository

```bash
git clone git@github.com:wellthatsgaurav/github-config.git
cd github-config
```

---

## Step 2 — Login to HCP Terraform

```bash
terraform login
```

This opens a browser. Approve the request. A credential token is stored at
`~/.terraform.d/credentials.tfrc.json` — this file is gitignored.

---

## Step 3 — Set workspace variables in HCP Terraform

Navigate to:
`app.terraform.io → wellthatsgaurav → github-config → Variables`

### Terraform variable

| Key | Value | Sensitive |
|-----|-------|-----------|
| `github_organization` | `wellthatsgaurav` | No |

### Environment variables (all sensitive)

| Key | Value |
|-----|-------|
| `GITHUB_APP_ID` | Numeric App ID from GitHub App settings page |
| `GITHUB_APP_INSTALLATION_ID` | Numeric ID from the URL after installing the App |
| `GITHUB_APP_PEM_FILE` | Full PEM content including header/footer lines |

For `GITHUB_APP_PEM_FILE`: paste the entire `.pem` file content.
HCP Terraform preserves newlines in multi-line sensitive variables.

---

## Step 4 — Initialize Terraform

```bash
cd terraform/
terraform init
```

Expected output includes:
- `Initializing HCP Terraform...`
- `Installed integrations/github v6.13.0`
- `HCP Terraform has been successfully initialized!`

---

## Step 5 — Run a plan

```bash
terraform plan
```

The plan runs remotely on HCP Terraform. First-time output will show
resources to create (teams, repositories). If it fails with an auth error,
double-check the environment variables in Step 3.

---

## Step 6 — Import the existing github-config repository

The `github-config` repository already exists on GitHub. Before applying,
import it into Terraform state so Terraform adopts it rather than tries to
create a duplicate.

```bash
terraform import \
  'module.repositories["github-config"].github_repository.repo' \
  wellthatsgaurav/github-config
```

Then run plan again — it should show only updates (not creates) for this repo.
Review each diff: they represent the difference between the existing repo
settings and the desired state in locals.tf.

---

## Step 7 — Apply

Go to HCP Terraform UI → `github-config` workspace → **Runs**.
Find the current run and click **Confirm & Apply**.

Do not run `terraform apply` from the CLI against HCP Terraform remote
execution — the UI apply is the correct path for VCS-driven workspaces.

---

## Day-to-day workflow

```text
1. Create a branch
2. Edit Terraform configuration
3. Run terraform fmt and terraform validate locally
4. Open a pull request
5. GitHub Actions runs non-privileged validation checks
6. Review the pull request
7. Merge to main
8. HCP Terraform creates a VCS-driven run
9. Review the Terraform plan
10. Click Confirm & Apply in HCP Terraform
```

---

## Adding a repository

Add an entry to `local.repositories` in `terraform/locals.tf`:

```hcl
my-project = {
  description = "My open-source project."
  visibility  = "public"
  topics      = [local.managed_by, "my-project"]
  settings    = {}  # all defaults
  ruleset     = {}  # all defaults
}
```

Open a PR → speculative plan → review → merge → apply.

---

## Importing an existing repository

```bash
# 1. Add the repo entry to local.repositories in locals.tf first.

# 2. Import into state.
terraform import \
  'module.repositories["<repo-name>"].github_repository.repo' \
  wellthatsgaurav/<repo-name>

# 3. Run plan. Review diffs carefully — each diff is a settings change.
terraform plan

# 4. Apply via HCP Terraform UI after reviewing.
```

Common diffs after import:
- `has_wiki = false` — Terraform will disable the wiki
- `allow_merge_commit = false` — Terraform will disable merge commits
- `delete_branch_on_merge = true` — Terraform will enable branch auto-delete

These are intentional — the module enforces org standards.
Override in the repo's `settings = {}` block if the repo legitimately differs.

---

## Rotating the GitHub App private key

1. Go to GitHub → org Settings → Developer settings → GitHub Apps
   → `wellthatsgaurav-terraform` → Edit
2. Scroll to **Private keys** → **Generate a private key**
   (do NOT delete the old key yet)
3. Download the new `.pem` file
4. Update `GITHUB_APP_PEM_FILE` in HCP Terraform workspace variables
5. Trigger a new plan to verify authentication works with the new key
6. Delete the old key from the GitHub App settings page

---

## Recovering from GitHub App credential loss

If the App private key is lost or the App is accidentally deleted:

1. Create a new GitHub App under the org with the same permissions
   (see Phase 3 of the setup documentation)
2. Install it into the org
3. Generate a new private key
4. Update all three env vars in HCP Terraform:
   `GITHUB_APP_ID`, `GITHUB_APP_INSTALLATION_ID`, `GITHUB_APP_PEM_FILE`
5. Run `terraform plan` — should show no changes if the new App has
   identical permissions
6. State is unaffected — the App is the auth mechanism, not a managed resource

---

## Upgrading Terraform or the GitHub provider

```bash
# 1. Update version pins in terraform/terraform.tf

# 2. Upgrade the lock file
cd terraform/
terraform init -upgrade

# 3. Review lock file diff — verify new provider SHA is expected
git diff .terraform.lock.hcl

# 4. Run plan to catch breaking changes
terraform plan

# 5. Commit the updated lock file in a PR
git add .terraform.lock.hcl
git commit -m "chore: upgrade github provider to X.Y.Z"
```

---

## Upgrading GitHub Actions in the PR workflow

Actions are pinned to full commit SHAs. To upgrade:

```bash
# Get the full SHA for a new version
git ls-remote https://github.com/<owner>/<action> refs/tags/<version>
# Use the SHA from the line ending in ^{} (dereferenced tag)

# Update the SHA and version comment in .github/workflows/terraform-pr.yml
# Open a PR with the lock file and workflow changes together
```
