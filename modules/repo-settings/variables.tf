variable "name" {
  description = "Repo name without owner. The owner is supplied by the calling module's GitHub provider, so it never appears here."
  type        = string
}

variable "description" {
  description = "Repo description (1-line, shown on GitHub)."
  type        = string
}

variable "topics" {
  description = "GitHub topic tags."
  type        = list(string)
  default     = []
}

variable "visibility" {
  description = <<-EOT
    Repo visibility: "public" or "private". Drives the secret-scanning cost
    gate. Secret scanning and push protection require GitHub Advanced Security
    on private repos (paid: Secret Protection) but are free on public repos, so
    the module only sets the security_and_analysis block when this is "public".
    A private repo therefore never has a paid feature enabled by an apply.
  EOT
  type        = string

  validation {
    condition     = contains(["public", "private"], var.visibility)
    error_message = "visibility must be one of: public, private."
  }
}
