# ===================================================================
# IAM MODULE VARIABLES
# ===================================================================

variable "project_id" {
  description = "GCP Project ID for infrastructure deployment"
  type        = string
}

variable "composer_service_account_id" {
  description = "Service account ID for Cloud Composer"
  type        = string
  default     = "composer-sa"
}

variable "dataproc_service_account_id" {
  description = "Service account ID for Dataproc"
  type        = string
  default     = "dataproc-sa"
} 