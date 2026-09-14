variable "name" {
  type        = string
  description = "Repository name. Must be unique within the organization."

  validation {
    condition     = trimspace(var.name) != "" && can(regex("^[A-Za-z0-9._-]+$", var.name))
    error_message = "Repository name may only contain alphanumeric characters, hyphens, underscores, and dots."
  }
}

variable "description" {
  type        = string
  description = "Repository description shown on the GitHub repo page."
  default     = ""
}

variable "visibility" {
  type        = string
  description = "Repository visibility: 'public' or 'private'."
  default     = "public"

  validation {
    condition     = contains(["public", "private"], var.visibility)
    error_message = "Visibility must be 'public' or 'private'."
  }
}

variable "topics" {
  type        = list(string)
  description = "Repository topics. GitHub enforces lowercase and hyphens — normalization applied in main.tf."
  default     = []
}

variable "settings" {
  type = object({
    allow_squash_merge          = optional(bool, true)
    allow_merge_commit          = optional(bool, false)
    allow_rebase_merge          = optional(bool, false)
    squash_merge_commit_title   = optional(string, "PR_TITLE")
    squash_merge_commit_message = optional(string, "PR_BODY")
    delete_branch_on_merge      = optional(bool, true)
    has_issues                  = optional(bool, true)
    has_wiki                    = optional(bool, false)
    has_projects                = optional(bool, false)
    has_discussions             = optional(bool, false)
    vulnerability_alerts        = optional(bool, true)
  })
  description = "Repository feature and merge strategy settings. All fields optional — omit to use secure defaults."
  default     = {}
}

variable "ruleset" {
  type = object({
    required_approving_review_count   = optional(number, 0)
    dismiss_stale_reviews_on_push     = optional(bool, true)
    require_code_owner_review         = optional(bool, false)
    require_last_push_approval        = optional(bool, false)
    required_review_thread_resolution = optional(bool, true)
    required_linear_history           = optional(bool, true)
  })
  description = "Default-branch ruleset settings. All fields optional — omit to use secure defaults."
  default     = {}
}
