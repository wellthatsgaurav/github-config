variable "github_organization" {
  description = "The GitHub organization managed by this configuration."
  type        = string

  validation {
    condition     = trimspace(var.github_organization) != ""
    error_message = "github_organization must not be empty."
  }
}

variable "github_app_id" {
  description = "GitHub App ID used by Terraform to manage the organization."
  type        = string
  sensitive   = true

  validation {
    condition     = can(tonumber(var.github_app_id)) && tonumber(var.github_app_id) > 0
    error_message = "github_app_id must be a positive numeric GitHub App ID."
  }
}

variable "github_app_installation_id" {
  description = "GitHub App installation ID for the wellthatsgaurav organization."
  type        = string
  sensitive   = true

  validation {
    condition     = can(tonumber(var.github_app_installation_id)) && tonumber(var.github_app_installation_id) > 0
    error_message = "github_app_installation_id must be a positive numeric installation ID."
  }
}

variable "github_app_pem_file" {
  description = "GitHub App private key PEM content used to authenticate Terraform."
  type        = string
  sensitive   = true

  validation {
    condition = (
      strcontains(var.github_app_pem_file, "-----BEGIN PRIVATE KEY-----") ||
      strcontains(var.github_app_pem_file, "-----BEGIN RSA PRIVATE KEY-----")
    )
    error_message = "github_app_pem_file must contain a valid PEM private-key header."
  }
}