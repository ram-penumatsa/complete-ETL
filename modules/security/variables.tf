variable "environment" {
  description = "Environment name (dev/staging/prod)"
  type        = string
}

variable "sql_user_password" {
  description = "PostgreSQL user password"
  type        = string
  sensitive   = true
  default     = ""  # Empty default - allows destroy without prompts
}

variable "dataproc_service_account_email" {
  description = "Dataproc service account email"
  type        = string
}

variable "composer_service_account_email" {
  description = "Composer service account email"
  type        = string
} 