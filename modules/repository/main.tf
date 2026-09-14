resource "github_repository" "repo" {
  name        = var.name
  description = var.description
  visibility  = var.visibility

  allow_squash_merge          = var.settings.allow_squash_merge
  allow_merge_commit          = var.settings.allow_merge_commit
  allow_rebase_merge          = var.settings.allow_rebase_merge
  squash_merge_commit_title   = var.settings.allow_squash_merge ? var.settings.squash_merge_commit_title : null
  squash_merge_commit_message = var.settings.allow_squash_merge ? var.settings.squash_merge_commit_message : null
  delete_branch_on_merge      = var.settings.delete_branch_on_merge

  has_issues      = var.settings.has_issues
  has_wiki        = var.settings.has_wiki
  has_projects    = var.settings.has_projects
  has_discussions = var.settings.has_discussions

  topics = [
    for topic in var.topics :
    lower(replace(trimspace(topic), "_", "-"))
    if trimspace(topic) != ""
  ]

  lifecycle {
    prevent_destroy = true

    ignore_changes = [auto_init, gitignore_template, license_template]
  }
}

resource "github_repository_ruleset" "default_branch" {
  name        = "default-branch-protection"
  repository  = github_repository.repo.name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  rules {
    deletion = true

    non_fast_forward = true

    required_linear_history = var.ruleset.required_linear_history

    pull_request {
      required_approving_review_count   = var.ruleset.required_approving_review_count
      dismiss_stale_reviews_on_push     = var.ruleset.dismiss_stale_reviews_on_push
      require_code_owner_review         = var.ruleset.require_code_owner_review
      require_last_push_approval        = var.ruleset.require_last_push_approval
      required_review_thread_resolution = var.ruleset.required_review_thread_resolution

      allowed_merge_methods = ["squash"]
    }
  }
}

resource "github_repository_vulnerability_alerts" "this" {
  repository = github_repository.repo.name
  enabled    = var.settings.vulnerability_alerts
}