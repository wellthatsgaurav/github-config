module "repositories" {
  source   = "../modules/repository"
  for_each = local.repositories

  name        = each.key
  description = lookup(each.value, "description", "")
  visibility  = lookup(each.value, "visibility", "public")
  topics      = lookup(each.value, "topics", [local.managed_by])
  settings    = lookup(each.value, "settings", {})
  ruleset     = lookup(each.value, "ruleset", {})
}
