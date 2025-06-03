# ===================================================================
# ANALYTICS MODULE VARIABLES
# ===================================================================

variable "bigquery_dataset_id" {
  description = "BigQuery dataset ID for analytics"
  type        = string
}

variable "bigquery_location" {
  description = "BigQuery dataset location"
  type        = string
}

variable "enable_force_destroy" {
  description = "Enable force destroy for demo cleanup"
  type        = bool
}

variable "composer_service_account_email" {
  description = "Composer service account email"
  type        = string
}

variable "dataproc_service_account_email" {
  description = "Dataproc service account email"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
} 