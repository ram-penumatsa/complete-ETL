# ===================================================================
# ORCHESTRATION MODULE - CLOUD COMPOSER
# ===================================================================

# Cloud Composer environment for workflow orchestration
resource "google_composer_environment" "etl_composer" {
  name   = var.composer_name
  region = var.orchestration_region

  config {
    node_config {
      network         = var.vpc_id
      subnetwork      = var.public_subnet_id
      service_account = var.composer_service_account_email

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
        DATAPROC_CLUSTER   = var.dataproc_cluster_name
        DATA_BUCKET        = var.data_bucket_name

        # Database configuration
        CLOUDSQL_INSTANCE = var.sql_connection_name
        CLOUDSQL_IP       = var.sql_private_ip
        DATABASE_NAME     = var.sql_database_name
        DATABASE_USER     = var.sql_user_name

        # Secret Manager configuration
        SQL_PASSWORD_SECRET = var.sql_password_secret_id

        # BigQuery configuration
        BIGQUERY_DATASET = var.bigquery_dataset_id

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
} 