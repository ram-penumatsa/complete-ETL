# ===================================================================
# ORCHESTRATION MODULE OUTPUTS
# ===================================================================

output "composer_environment_name" {
  description = "Cloud Composer environment name"
  value       = google_composer_environment.etl_composer.name
}

output "composer_environment_uri" {
  description = "Cloud Composer environment URI"
  value       = google_composer_environment.etl_composer.config[0].airflow_uri
}

output "composer_gcs_bucket" {
  description = "Cloud Composer GCS bucket"
  value       = google_composer_environment.etl_composer.config[0].dag_gcs_prefix
}

output "composer_service_account" {
  description = "Cloud Composer service account"
  value       = google_composer_environment.etl_composer.config[0].node_config[0].service_account
} 