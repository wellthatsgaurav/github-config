output "name" {
  type        = string
  description = "Repository name."
  value       = github_repository.repo.name
}

output "full_name" {
  type        = string
  description = "Full repository name including org prefix (org/repo)."
  value       = github_repository.repo.full_name
}

output "html_url" {
  type        = string
  description = "GitHub web URL of the repository."
  value       = github_repository.repo.html_url
}
