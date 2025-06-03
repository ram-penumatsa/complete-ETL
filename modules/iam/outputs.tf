# ===================================================================
# IAM MODULE OUTPUTS
# ===================================================================

output "composer_service_account_email" {
  description = "Cloud Composer service account email"
  value       = data.google_service_account.composer_sa.email
}

output "dataproc_service_account_email" {
  description = "Dataproc service account email"
  value       = data.google_service_account.dataproc_sa.email
}

output "composer_service_account_id" {
  description = "Cloud Composer service account ID"
  value       = data.google_service_account.composer_sa.account_id
}

output "dataproc_service_account_id" {
  description = "Dataproc service account ID"
  value       = data.google_service_account.dataproc_sa.account_id
} 