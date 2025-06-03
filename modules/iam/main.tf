# ===================================================================
# IAM MODULE - SERVICE ACCOUNTS AND ROLE ASSIGNMENTS
# ===================================================================

# Reference existing Service Account for Cloud Composer
data "google_service_account" "composer_sa" {
  account_id = var.composer_service_account_id
}

# Reference existing Service Account for Dataproc
data "google_service_account" "dataproc_sa" {
  account_id = var.dataproc_service_account_id
}

# IAM roles for Composer service account
resource "google_project_iam_member" "composer_roles" {
  for_each = toset([
    "roles/composer.worker",
    "roles/dataproc.editor",
    "roles/storage.admin",
    "roles/bigquery.admin",
    "roles/cloudsql.client"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${data.google_service_account.composer_sa.email}"
}

# IAM roles for Dataproc service account
resource "google_project_iam_member" "dataproc_roles" {
  for_each = toset([
    "roles/dataproc.worker",
    "roles/storage.admin",
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser",
    "roles/cloudsql.client"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${data.google_service_account.dataproc_sa.email}"
}

# Cloud Composer v2 service agent IAM binding
data "google_project" "project" {
  project_id = var.project_id
}

resource "google_project_iam_member" "composer_service_agent" {
  project = var.project_id
  role    = "roles/composer.ServiceAgentV2Ext"
  member  = "serviceAccount:service-${data.google_project.project.number}@cloudcomposer-accounts.iam.gserviceaccount.com"
} 