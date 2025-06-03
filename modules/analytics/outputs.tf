# ===================================================================
# ANALYTICS MODULE OUTPUTS
# ===================================================================

output "bigquery_dataset_id" {
  description = "BigQuery dataset ID"
  value       = google_bigquery_dataset.sales_analytics.dataset_id
}

output "bigquery_dataset_location" {
  description = "BigQuery dataset location"
  value       = google_bigquery_dataset.sales_analytics.location
}

output "bigquery_dataset_friendly_name" {
  description = "BigQuery dataset friendly name"
  value       = google_bigquery_dataset.sales_analytics.friendly_name
}

output "bigquery_dataset_url" {
  description = "BigQuery dataset URL"
  value       = "https://console.cloud.google.com/bigquery?p=${google_bigquery_dataset.sales_analytics.project}&d=${google_bigquery_dataset.sales_analytics.dataset_id}"
} 