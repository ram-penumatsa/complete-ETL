# ===================================================================
# SECURITY MODULE - SECRET MANAGER
# ===================================================================

# Option 1: Create secret without initial password (manual setup required)
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

# Option 2: Create secret version only if password is provided
resource "google_secret_manager_secret_version" "sql_password_version" {
  count       = var.sql_user_password != "" ? 1 : 0
  secret      = google_secret_manager_secret.sql_password.id
  secret_data = var.sql_user_password
}

# Option 3: Reference existing secret version (no variable dependency)
data "google_secret_manager_secret_version" "sql_password_latest" {
  secret  = google_secret_manager_secret.sql_password.id
  version = "latest"
  
  depends_on = [google_secret_manager_secret_version.sql_password_version]
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