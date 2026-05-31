variable "markdown_lint_enforcement" {
  description = <<-EOT
    Enforcement mode for the org-wide markdown-lint ruleset.

    Start at "evaluate" (dry-run): the ruleset reports results in the org
    Rulesets > Insights tab WITHOUT blocking any merges. This lets the rule roll
    out across every repo safely before the whole org's markdown is compliant.
    Flip to "active" once Insights shows the fleet is green.

    One of: disabled, evaluate, active.
  EOT
  type        = string
  default     = "evaluate"

  validation {
    condition     = contains(["disabled", "evaluate", "active"], var.markdown_lint_enforcement)
    error_message = "markdown_lint_enforcement must be one of: disabled, evaluate, active."
  }
}

variable "org_push_protection_enforcement" {
  description = <<-EOT
    Enforcement mode for the org-wide push-protection ruleset (native
    max_file_size + file_extension_restriction push rules). Applies to every
    repo, every ref; enforced at the git layer with no workflow runs.

    One of: disabled, evaluate, active. Defaults to "active" — new rulesets
    apply enabled directly per the convention; the variable exists so a
    misbehaving rule can be disabled with `-var` without a code change.
  EOT
  type        = string
  default     = "active"

  validation {
    condition     = contains(["disabled", "evaluate", "active"], var.org_push_protection_enforcement)
    error_message = "org_push_protection_enforcement must be one of: disabled, evaluate, active."
  }
}
