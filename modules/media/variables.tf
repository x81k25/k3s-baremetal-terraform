variable "server_ip" {
  type = string
}

variable "media_sensitive" {
  type = object({
    plex_claim = string
  })
  sensitive = true
}

variable "ssh_config" {
  type = object({
    user = string
    private_key_path = string
  })
  sensitive = true
}