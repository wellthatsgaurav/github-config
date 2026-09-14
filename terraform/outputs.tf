output "repository_names" {
  type        = list(string)
  description = "Terraform-managed repository names."
  value       = keys(module.repositories)
}

output "repository_html_urls" {
  type        = map(string)
  description = "Map of repository name to GitHub URL."
  value = {
    for k, r in module.repositories : k => r.html_url
  }
}
