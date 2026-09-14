resource "github_team" "teams" {
  for_each = local.teams

  name        = each.key
  description = each.value.description
  privacy     = each.value.privacy
}

resource "github_team_membership" "memberships" {
  for_each = local.team_memberships

  team_id  = github_team.teams[each.value.team_key].id
  username = each.value.username
  role     = each.value.role
}

resource "github_team_repository" "access" {
  for_each = local.team_repository_access

  team_id    = github_team.teams[each.value.team_key].id
  repository = each.value.repo_key
  permission = each.value.permission
}
