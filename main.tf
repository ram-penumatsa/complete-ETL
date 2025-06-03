terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.default_region
}

# ===================================================================
# API ENABLEMENT
# ===================================================================

resource "google_project_service" "required_apis" {
  for_each = toset([
    "compute.googleapis.com",
    "storage.googleapis.com",
    "bigquery.googleapis.com",
    "dataproc.googleapis.com",
    "composer.googleapis.com",
    "sqladmin.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "servicenetworking.googleapis.com",
    "secretmanager.googleapis.com"
  ])

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false

  timeouts {
    create = "30m"
    update = "40m"
  }
}

# ===================================================================
# NETWORKING LAYER (VPC, SUBNETS, NAT)
# ===================================================================

# Custom VPC for ETL infrastructure
resource "google_compute_network" "etl_vpc" {
  name                    = "${var.environment}-etl-vpc"
  description             = "Custom VPC for ETL infrastructure"
  auto_create_subnetworks = false
  mtu                     = 1460

  depends_on = [google_project_service.required_apis]
}

# Public subnet for Cloud Composer (orchestration region)
resource "google_compute_subnetwork" "public_subnet" {
  name          = "${var.environment}-public-subnet"
  ip_cidr_range = var.public_subnet_cidr
  region        = var.orchestration_region
  network       = google_compute_network.etl_vpc.id
  description   = "Public subnet for Cloud Composer and external-facing services"

  # Enable private Google access for this subnet
  private_ip_google_access = true

  # Secondary IP ranges for services if needed
  secondary_ip_range {
    range_name    = "composer-pods"
    ip_cidr_range = var.composer_pods_cidr
  }

  secondary_ip_range {
    range_name    = "composer-services"
    ip_cidr_range = var.composer_services_cidr
  }
}

# Private subnet for data processing services (data region)
resource "google_compute_subnetwork" "private_subnet" {
  name          = "${var.environment}-private-subnet"
  ip_cidr_range = var.private_subnet_cidr
  region        = var.data_region
  network       = google_compute_network.etl_vpc.id
  description   = "Private subnet for Dataproc, Cloud SQL, and data processing services"

  # Enable private Google access for this subnet
  private_ip_google_access = true

  # Secondary IP ranges for Dataproc
  secondary_ip_range {
    range_name    = "dataproc-pods"
    ip_cidr_range = var.dataproc_pods_cidr
  }
}

# Cloud Router for NAT Gateway
resource "google_compute_router" "nat_router" {
  name    = "${var.environment}-nat-router"
  region  = var.data_region
  network = google_compute_network.etl_vpc.id

  bgp {
    asn = 64514
  }
}

# NAT Gateway for private subnet internet access
resource "google_compute_router_nat" "nat_gateway" {
  name                               = "${var.environment}-nat-gateway"
  router                             = google_compute_router.nat_router.name
  region                             = var.data_region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.private_subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Firewall rule: Allow internal communication within VPC
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.environment}-allow-internal"
  network = google_compute_network.etl_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [
    var.public_subnet_cidr,
    var.private_subnet_cidr,
    var.composer_pods_cidr,
    var.composer_services_cidr,
    var.dataproc_pods_cidr
  ]

  description = "Allow internal communication between all subnets in VPC"
}

# Firewall rule: Allow SSH access to compute instances (for troubleshooting)
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.environment}-allow-ssh"
  network = google_compute_network.etl_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"] # Restrict this to your IP range in production
  target_tags   = ["ssh-access"]

  description = "Allow SSH access to compute instances with ssh-access tag"
}

# Firewall rule: Allow Cloud Composer access
resource "google_compute_firewall" "allow_composer" {
  name    = "${var.environment}-allow-composer"
  network = google_compute_network.etl_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["443", "80"]
  }

  source_ranges = ["0.0.0.0/0"] # Composer needs external access
  target_tags   = ["composer-access"]

  description = "Allow HTTPS access to Cloud Composer web interface"
}

# Firewall rule: Allow Cloud SQL access from private subnet
resource "google_compute_firewall" "allow_cloudsql" {
  name    = "${var.environment}-allow-cloudsql"
  network = google_compute_network.etl_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["5432", "3306"] # PostgreSQL and MySQL ports
  }

  source_ranges = [var.private_subnet_cidr]
  target_tags   = ["cloudsql-access"]

  description = "Allow database access from private subnet to Cloud SQL"
}

# Firewall rule: Allow Dataproc cluster communication
resource "google_compute_firewall" "allow_dataproc" {
  name    = "${var.environment}-allow-dataproc"
  network = google_compute_network.etl_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["8088", "9870", "8080", "18080", "4040"] # Hadoop/Spark ports
  }

  source_ranges = [var.private_subnet_cidr, var.public_subnet_cidr]
  target_tags   = ["dataproc-cluster"]

  description = "Allow Dataproc cluster communication and web interfaces"
}

# Private Service Connection for Cloud SQL
resource "google_compute_global_address" "private_ip_address" {
  name          = "${var.environment}-private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.etl_vpc.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.etl_vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]

  depends_on = [google_project_service.required_apis]
}

# ===================================================================
# IAM AND SERVICE ACCOUNTS
# ===================================================================

# Reference existing Service Account for Cloud Composer
data "google_service_account" "composer_sa" {
  account_id = "composer-sa"

  depends_on = [google_project_service.required_apis]
}

# Reference existing Service Account for Dataproc
data "google_service_account" "dataproc_sa" {
  account_id = "dataproc-sa"

  depends_on = [google_project_service.required_apis]
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

  depends_on = [data.google_service_account.composer_sa]
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

  depends_on = [data.google_service_account.dataproc_sa]
}

# Cloud Composer v2 service agent IAM binding
data "google_project" "project" {
  project_id = var.project_id
}

resource "google_project_iam_member" "composer_service_agent" {
  project = var.project_id
  role    = "roles/composer.ServiceAgentV2Ext"
  member  = "serviceAccount:service-${data.google_project.project.number}@cloudcomposer-accounts.iam.gserviceaccount.com"

  depends_on = [data.google_service_account.composer_sa]
}

# ===================================================================
# SECRET MANAGEMENT (GOOGLE SECRET MANAGER)
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

  depends_on = [google_project_service.required_apis]
}

# Create secret version with the password
resource "google_secret_manager_secret_version" "sql_password_version" {
  secret      = google_secret_manager_secret.sql_password.id
  secret_data = var.sql_user_password

  depends_on = [google_secret_manager_secret.sql_password]
}

# IAM binding for Dataproc service account to access secret
resource "google_secret_manager_secret_iam_member" "dataproc_secret_access" {
  secret_id = google_secret_manager_secret.sql_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_service_account.dataproc_sa.email}"

  depends_on = [
    google_secret_manager_secret.sql_password,
    data.google_service_account.dataproc_sa
  ]
}

# IAM binding for Composer service account to access secret
resource "google_secret_manager_secret_iam_member" "composer_secret_access" {
  secret_id = google_secret_manager_secret.sql_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_service_account.composer_sa.email}"

  depends_on = [
    google_secret_manager_secret.sql_password,
    data.google_service_account.composer_sa
  ]
}

# ===================================================================
# STORAGE LAYER (GCS BUCKETS)
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

  depends_on = [google_project_service.required_apis]
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

  depends_on = [google_project_service.required_apis]
}

# ===================================================================
# DATABASE LAYER (CLOUD SQL POSTGRESQL)
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
      private_network                               = google_compute_network.etl_vpc.id
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

  depends_on = [
    google_project_service.required_apis,
    google_service_networking_connection.private_vpc_connection
  ]
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

# ===================================================================
# COMPUTE LAYER (DATAPROC CLUSTER)
# ===================================================================

# Dataproc cluster for PySpark processing
resource "google_dataproc_cluster" "etl_cluster" {
  name   = var.dataproc_cluster_name
  region = var.data_region

  cluster_config {
    staging_bucket = google_storage_bucket.staging_bucket.name

    master_config {
      num_instances = var.dataproc_master_nodes
      machine_type  = var.dataproc_master_machine_type
      disk_config {
        boot_disk_type    = "pd-standard"
        boot_disk_size_gb = var.dataproc_master_disk_size
      }
    }

    worker_config {
      num_instances = var.dataproc_worker_nodes
      machine_type  = var.dataproc_worker_machine_type
      disk_config {
        boot_disk_type    = "pd-standard"
        boot_disk_size_gb = var.dataproc_worker_disk_size
      }
    }

    preemptible_worker_config {
      num_instances = var.dataproc_preemptible_nodes
    }

    software_config {
      image_version = var.dataproc_image_version
    }

    gce_cluster_config {
      subnetwork       = google_compute_subnetwork.private_subnet.name
      internal_ip_only = true # Use private IPs only

      service_account = data.google_service_account.dataproc_sa.email
      service_account_scopes = [
        "https://www.googleapis.com/auth/cloud-platform"
      ]

      tags = ["dataproc-cluster", var.environment, "ssh-access"]
    }
  }

  labels = {
    environment = var.environment
    purpose     = "etl-processing"
    managed_by  = "terraform"
  }

  depends_on = [
    google_storage_bucket.staging_bucket,
    data.google_service_account.dataproc_sa,
    google_project_iam_member.dataproc_roles,
    google_compute_subnetwork.private_subnet
  ]
}

# ===================================================================
# ANALYTICS LAYER (BIGQUERY)
# ===================================================================

# BigQuery dataset for analytics results
resource "google_bigquery_dataset" "sales_analytics" {
  dataset_id  = var.bigquery_dataset_id
  description = "Sales analytics data warehouse for ETL pipeline results"
  location    = var.bigquery_location

  delete_contents_on_destroy = var.enable_force_destroy

  access {
    role          = "roles/bigquery.dataOwner"
    user_by_email = data.google_service_account.composer_sa.email
  }

  access {
    role          = "roles/bigquery.dataEditor"
    user_by_email = data.google_service_account.dataproc_sa.email
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

  depends_on = [google_project_service.required_apis]
}

# ===================================================================
# ORCHESTRATION LAYER (CLOUD COMPOSER)
# ===================================================================

# Cloud Composer environment for workflow orchestration
resource "google_composer_environment" "etl_composer" {
  name   = var.composer_name
  region = var.orchestration_region

  config {
    node_config {
      network         = google_compute_network.etl_vpc.id
      subnetwork      = google_compute_subnetwork.public_subnet.id
      service_account = data.google_service_account.composer_sa.email

      tags = ["composer-access", var.environment]

      ip_allocation_policy {
        cluster_secondary_range_name  = "composer-pods"
        services_secondary_range_name = "composer-services"
      }
    }

    software_config {
      image_version = var.composer_image_version

      env_variables = {
        # Infrastructure configuration
        PYSPARK_PROJECT_ID = var.project_id
        REGION             = var.data_region
        DATAPROC_CLUSTER   = google_dataproc_cluster.etl_cluster.name
        DATA_BUCKET        = google_storage_bucket.data_bucket.name

        # Database configuration
        CLOUDSQL_INSTANCE = google_sql_database_instance.postgres.connection_name
        CLOUDSQL_IP       = google_sql_database_instance.postgres.private_ip_address
        DATABASE_NAME     = google_sql_database.etl_database.name
        DATABASE_USER     = google_sql_user.etl_user.name

        # Secret Manager configuration
        SQL_PASSWORD_SECRET = google_secret_manager_secret.sql_password.secret_id

        # BigQuery configuration
        BIGQUERY_DATASET = google_bigquery_dataset.sales_analytics.dataset_id

        # File paths (after upload to GCS)
        SALES_DATA_PATH    = "sales_data/sales_data.csv"
        PRODUCTS_DATA_PATH = "reference_data/products.csv"
        STORES_DATA_PATH   = "reference_data/stores.csv"
        PYSPARK_JOB_PATH   = "pyspark-jobs/sales_analytics_direct.py"

        # JAR file paths
        BIGQUERY_JAR_PATH = "jars/spark-bigquery-with-dependencies_2.12-0.25.2.jar"
        POSTGRES_JAR_PATH = "jars/postgresql-42.7.1.jar"

        # Environment
        ENVIRONMENT = var.environment
      }
    }

    workloads_config {
      scheduler {
        cpu        = var.composer_scheduler_cpu
        memory_gb  = var.composer_scheduler_memory
        storage_gb = var.composer_scheduler_storage
        count      = 1
      }
      web_server {
        cpu        = var.composer_webserver_cpu
        memory_gb  = var.composer_webserver_memory
        storage_gb = var.composer_webserver_storage
      }
      worker {
        cpu        = var.composer_worker_cpu
        memory_gb  = var.composer_worker_memory
        storage_gb = var.composer_worker_storage
        min_count  = var.composer_worker_min_count
        max_count  = var.composer_worker_max_count
      }
    }

    environment_size = var.composer_environment_size
  }

  labels = {
    environment = var.environment
    purpose     = "etl-orchestration"
    managed_by  = "terraform"
  }

  depends_on = [
    google_project_service.required_apis,
    data.google_service_account.composer_sa,
    google_project_iam_member.composer_roles,
    google_project_iam_member.composer_service_agent,
    google_dataproc_cluster.etl_cluster,
    google_bigquery_dataset.sales_analytics,
    google_storage_bucket.data_bucket,
    google_compute_subnetwork.public_subnet
  ]
} 