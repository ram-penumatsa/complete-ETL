# ===================================================================
# SECURITY MODULE - SECRET MANAGER
# ===================================================================

# Create secret for PostgreSQL password
resource "google_secret_manager_secret" "sql_password" {
  secret_id = "${var.environment}-sql-password"

  labels = {
    environment = var.environment
    purpose     = "cloudsql-auth"
    managed_by  = "terraform"
  }

  replication {
    auto {
    }
  }
}

# Create secret version with the password
resource "google_secret_manager_secret_version" "sql_password_version" {
  secret      = google_secret_manager_secret.sql_password.id
  secret_data = var.sql_user_password
}

# IAM binding for Dataproc service account to access secret
resource "google_secret_manager_secret_iam_member" "dataproc_secret_access" {
  secret_id = google_secret_manager_secret.sql_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.dataproc_service_account_email}"
}

# IAM binding for Composer service account to access secret
resource "google_secret_manager_secret_iam_member" "composer_secret_access" {
  secret_id = google_secret_manager_secret.sql_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.composer_service_account_email}"
} 