# ===================================================================
# DATABASE MODULE - CLOUD SQL POSTGRESQL
# ===================================================================

# Cloud SQL PostgreSQL instance
resource "google_sql_database_instance" "postgres" {
  name             = var.sql_instance_name
  region           = var.data_region
  database_version = "POSTGRES_13"

  deletion_protection = false # Set to true for production

  settings {
    tier = var.sql_tier

    availability_type     = var.sql_availability_type
    disk_size             = var.sql_disk_size
    disk_type             = "PD_SSD"
    disk_autoresize       = true
    disk_autoresize_limit = 100

    backup_configuration {
      enabled                        = var.sql_backup_enabled
      start_time                     = "03:00"
      point_in_time_recovery_enabled = false
    }

    ip_configuration {
      ipv4_enabled                                  = false # Disable public IP
      private_network                               = var.vpc_id
      enable_private_path_for_google_cloud_services = true
    }

    database_flags {
      name  = "log_checkpoints"
      value = "on"
    }

    database_flags {
      name  = "log_statement"
      value = "all"
    }
  }

  depends_on = [var.private_vpc_connection]
}

# Create database
resource "google_sql_database" "etl_database" {
  name     = var.sql_database_name
  instance = google_sql_database_instance.postgres.name
}

# Create user
resource "google_sql_user" "etl_user" {
  name     = var.sql_user_name
  instance = google_sql_database_instance.postgres.name
  password = var.sql_user_password
} 