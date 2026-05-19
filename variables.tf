variable "github_backend_repo" {
  description = "URL du dépôt GitHub du backend"
  type        = string
}


variable "github_frontend_repo" {
  description = "URL du dépôt GitHub du frontend (sans https://)"
  type        = string
}

variable "github_token" {
  description = "Token GitHub (optionnel, sinon clone public)"
  type        = string
  default     = "" # optionnel → pas obligatoire
}
variable "key_pair_name" {
  description = "Nom de la clé SSH EC2"
  type        = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}
variable "db_name" {
  type = string
}