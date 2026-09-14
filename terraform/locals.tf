locals {
  org_name   = var.github_organization
  managed_by = "terraform"

  teams = {
    maintainers = {
      description = "Core maintainers for the organization."
      privacy     = "closed"
    }

    contributors = {
      description = "Active contributors with triage access."
      privacy     = "closed"
    }
  }

  team_memberships = {}

  team_repository_access = {}

  repositories = {

    github-config = {
      description = "GitHub organization configuration and governance."
      visibility  = "public"
      topics = [
        local.managed_by,
        "terraform",
        "github",
        "infrastructure-as-code",
        "open-source",
      ]

      settings = {
        allow_squash_merge          = true
        allow_merge_commit          = false
        allow_rebase_merge          = false
        squash_merge_commit_title   = "PR_TITLE"
        squash_merge_commit_message = "PR_BODY"
        delete_branch_on_merge      = true
        has_issues                  = true
        has_wiki                    = false
        has_projects                = false
        has_discussions             = false
        vulnerability_alerts        = true
      }

      ruleset = {
        required_approving_review_count   = 0
        dismiss_stale_reviews_on_push     = true
        require_code_owner_review         = false
        require_last_push_approval        = false
        required_review_thread_resolution = true
        required_linear_history           = true
      }
    }
  }
}
