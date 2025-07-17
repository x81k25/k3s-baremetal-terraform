variable "ng_github_secrets" {
  description = "ng github credentials"
  type = object({
    username = string
    token_packages_read = string
  })
  sensitive = true
}