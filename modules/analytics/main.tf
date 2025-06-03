# ===================================================================
# ANALYTICS MODULE - BIGQUERY DATASET
# ===================================================================

# BigQuery dataset for analytics results
resource "google_bigquery_dataset" "sales_analytics" {
  dataset_id  = var.bigquery_dataset_id
  description = "Sales analytics data warehouse for ETL pipeline results"
  location    = var.bigquery_location

  delete_contents_on_destroy = var.enable_force_destroy

  access {
    role          = "roles/bigquery.dataOwner"
    user_by_email = var.composer_service_account_email
  }

  access {
    role          = "roles/bigquery.dataEditor"
    user_by_email = var.dataproc_service_account_email
  }

  access {
    role          = "roles/bigquery.dataViewer"
    special_group = "projectReaders"
  }

  labels = {
    environment = var.environment
    purpose     = "etl-analytics"
    managed_by  = "terraform"
  }
} 