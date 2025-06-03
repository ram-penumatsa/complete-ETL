# ===================================================================
# ROOT MODULE - MODULAR ETL INFRASTRUCTURE
# ===================================================================

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
# FOUNDATION MODULE - API ENABLEMENT
# ===================================================================

module "foundation" {
  source = "./modules/foundation"

  project_id = var.project_id
}

# ===================================================================
# NETWORKING MODULE - VPC, SUBNETS, NAT, FIREWALL
# ===================================================================

module "networking" {
  source = "./modules/networking"

  environment          = var.environment
  orchestration_region = var.orchestration_region
  data_region          = var.data_region

  # Network CIDR Configuration
  public_subnet_cidr     = var.public_subnet_cidr
  private_subnet_cidr    = var.private_subnet_cidr
  composer_pods_cidr     = var.composer_pods_cidr
  composer_services_cidr = var.composer_services_cidr
  dataproc_pods_cidr     = var.dataproc_pods_cidr

  depends_on = [module.foundation]
}

# ===================================================================
# IAM MODULE - SERVICE ACCOUNTS AND ROLES
# ===================================================================

module "iam" {
  source = "./modules/iam"

  project_id                  = var.project_id
  composer_service_account_id = "composer-sa"
  dataproc_service_account_id = "dataproc-sa"

  depends_on = [module.foundation]
}

# ===================================================================
# SECURITY MODULE - SECRET MANAGER
# ===================================================================

module "security" {
  source = "./modules/security"

  environment                    = var.environment
  sql_user_password              = var.sql_user_password
  dataproc_service_account_email = module.iam.dataproc_service_account_email
  composer_service_account_email = module.iam.composer_service_account_email

  depends_on = [module.foundation, module.iam]
}

# ===================================================================
# STORAGE MODULE - GCS BUCKETS
# ===================================================================

module "storage" {
  source = "./modules/storage"

  data_bucket_name     = var.data_bucket_name
  data_region          = var.data_region
  environment          = var.environment
  enable_force_destroy = var.enable_force_destroy

  depends_on = [module.foundation]
}

# ===================================================================
# DATABASE MODULE - CLOUD SQL
# ===================================================================

module "database" {
  source = "./modules/database"

  sql_instance_name      = var.sql_instance_name
  data_region            = var.data_region
  sql_tier               = var.sql_tier
  sql_availability_type  = var.sql_availability_type
  sql_disk_size          = var.sql_disk_size
  sql_backup_enabled     = var.sql_backup_enabled
  vpc_id                 = module.networking.vpc_id
  private_vpc_connection = module.networking.private_vpc_connection
  sql_database_name      = var.sql_database_name
  sql_user_name          = var.sql_user_name
  sql_user_password      = var.sql_user_password

  depends_on = [module.foundation, module.networking]
}

# ===================================================================
# COMPUTE MODULE - DATAPROC
# ===================================================================

module "compute" {
  source = "./modules/compute"

  dataproc_cluster_name          = var.dataproc_cluster_name
  data_region                    = var.data_region
  staging_bucket_name            = module.storage.staging_bucket_name
  dataproc_master_nodes          = var.dataproc_master_nodes
  dataproc_master_machine_type   = var.dataproc_master_machine_type
  dataproc_master_disk_size      = var.dataproc_master_disk_size
  dataproc_worker_nodes          = var.dataproc_worker_nodes
  dataproc_worker_machine_type   = var.dataproc_worker_machine_type
  dataproc_worker_disk_size      = var.dataproc_worker_disk_size
  dataproc_preemptible_nodes     = var.dataproc_preemptible_nodes
  dataproc_image_version         = var.dataproc_image_version
  private_subnet_name            = module.networking.private_subnet_name
  dataproc_service_account_email = module.iam.dataproc_service_account_email
  environment                    = var.environment

  depends_on = [module.foundation, module.networking, module.iam, module.storage]
}

# ===================================================================
# ANALYTICS MODULE - BIGQUERY
# ===================================================================

module "analytics" {
  source = "./modules/analytics"

  bigquery_dataset_id            = var.bigquery_dataset_id
  bigquery_location              = var.bigquery_location
  enable_force_destroy           = var.enable_force_destroy
  composer_service_account_email = module.iam.composer_service_account_email
  dataproc_service_account_email = module.iam.dataproc_service_account_email
  environment                    = var.environment

  depends_on = [module.foundation, module.iam]
}

# ===================================================================
# ORCHESTRATION MODULE - CLOUD COMPOSER
# ===================================================================

module "orchestration" {
  source = "./modules/orchestration"

  composer_name                  = var.composer_name
  orchestration_region           = var.orchestration_region
  vpc_id                         = module.networking.vpc_id
  public_subnet_id               = module.networking.public_subnet_id
  composer_service_account_email = module.iam.composer_service_account_email
  environment                    = var.environment
  composer_image_version         = var.composer_image_version
  project_id                     = var.project_id
  data_region                    = var.data_region
  dataproc_cluster_name          = module.compute.dataproc_cluster_name
  data_bucket_name               = module.storage.data_bucket_name
  sql_connection_name            = module.database.sql_connection_name
  sql_private_ip                 = module.database.sql_private_ip
  sql_database_name              = module.database.sql_database_name
  sql_user_name                  = module.database.sql_user_name
  sql_password_secret_id         = module.security.sql_password_secret_id
  bigquery_dataset_id            = module.analytics.bigquery_dataset_id
  composer_scheduler_cpu         = var.composer_scheduler_cpu
  composer_scheduler_memory      = var.composer_scheduler_memory
  composer_scheduler_storage     = var.composer_scheduler_storage
  composer_webserver_cpu         = var.composer_webserver_cpu
  composer_webserver_memory      = var.composer_webserver_memory
  composer_webserver_storage     = var.composer_webserver_storage
  composer_worker_cpu            = var.composer_worker_cpu
  composer_worker_memory         = var.composer_worker_memory
  composer_worker_storage        = var.composer_worker_storage
  composer_worker_min_count      = var.composer_worker_min_count
  composer_worker_max_count      = var.composer_worker_max_count
  composer_environment_size      = var.composer_environment_size

  depends_on = [
    module.foundation,
    module.networking,
    module.iam,
    module.security,
    module.storage,
    module.database,
    module.compute,
    module.analytics
  ]
} 