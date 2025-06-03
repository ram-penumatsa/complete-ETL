# ===================================================================
# STORAGE MODULE - GCS BUCKETS
# ===================================================================

# Main data bucket for raw data and artifacts
resource "google_storage_bucket" "data_bucket" {
  name     = var.data_bucket_name
  location = var.data_region

  force_destroy = var.enable_force_destroy

  versioning {
    enabled = true
  }

  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
  }

  labels = {
    environment = var.environment
    purpose     = "etl-data-lake"
    managed_by  = "terraform"
  }
}

# Staging bucket for temporary data and Dataproc staging
resource "google_storage_bucket" "staging_bucket" {
  name     = "${var.data_bucket_name}-staging"
  location = var.data_region

  force_destroy = var.enable_force_destroy

  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = 7
    }
    action {
      type = "Delete"
    }
  }

  labels = {
    environment = var.environment
    purpose     = "dataproc-staging"
    managed_by  = "terraform"
  }
} 