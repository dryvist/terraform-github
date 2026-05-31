# Structured defaults consumed by org rulesets live in config/*.yml; this
# file decodes them into named locals so rulesets.tf reads them as terraform
# values, not raw file reads scattered through resource bodies.
locals {
  push_protection_defaults = yamldecode(file("${path.module}/config/rulesets-defaults.yml")).push_protection
}
