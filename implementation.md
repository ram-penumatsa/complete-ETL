# ETL Infrastructure Implementation

## Implementation Overview

This document describes how the design principles and architectural decisions from `design.md` are implemented in the Terraform code (`main.tf`). It provides a mapping between design concepts and actual infrastructure code, demonstrating how theoretical architecture translates into working cloud infrastructure.

## Code Structure and Organization

### Terraform Configuration Structure

```
main.tf Organization:
├── Provider and Version Configuration (lines 1-11)
├── API Enablement (lines 18-40)
├── Networking Layer (lines 45-195)
├── IAM and Service Accounts (lines 200-257)
├── Secret Management (lines 262-314)
├── Storage Layer (lines 319-373)
├── Database Layer (lines 378-426)
├── Compute Layer (lines 431-489)
├── Analytics Layer (lines 494-522)
└── Orchestration Layer (lines 527-700)
```

## Implementation Mapping

### 1. **Infrastructure as Code Principles**

#### **Terraform Configuration (Lines 1-11)**
```terraform
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
```

**Implementation Details:**
- **Version Pinning**: Ensures reproducible deployments across environments
- **Provider Management**: Explicit provider versions prevent breaking changes
- **Dependency Management**: Clear dependency declaration for infrastructure components

#### **Variable-Driven Configuration**
```terraform
provider "google" {
  project = var.project_id
  region  = var.default_region
}
```

**Implementation Features:**
- All configuration driven through variables
- Environment-agnostic code structure
- Parameterized resource sizing and naming

### 2. **API Enablement Implementation (Lines 18-40)**

```terraform
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
```

**Implementation Features:**
- **Declarative API Management**: All required APIs explicitly enabled
- **Dependency Foundation**: Ensures all services are available before resource creation
- **Timeout Management**: Extended timeouts for reliable API enablement
- **Preservation**: APIs remain enabled on infrastructure destruction

### 3. **Networking Layer Implementation (Lines 45-195)**

#### **VPC and Subnet Architecture**

```terraform
# Custom VPC Implementation
resource "google_compute_network" "etl_vpc" {
  name                    = "${var.environment}-etl-vpc"
  description             = "Custom VPC for ETL infrastructure"
  auto_create_subnetworks = false
  mtu                     = 1460
  depends_on = [google_project_service.required_apis]
}
```

**Design Implementation:**
- **Custom VPC**: Complete network isolation from default networks
- **Manual Subnet Control**: Disabled auto-creation for precise subnet design
- **Environment Naming**: Dynamic naming based on environment variables
- **Dependency Management**: Explicit dependency on API enablement

#### **Subnet Segmentation**

```terraform
# Public Subnet for Orchestration
resource "google_compute_subnetwork" "public_subnet" {
  name          = "${var.environment}-public-subnet"
  ip_cidr_range = var.public_subnet_cidr
  region        = var.orchestration_region
  network       = google_compute_network.etl_vpc.id
  
  private_ip_google_access = true
  
  secondary_ip_range {
    range_name    = "composer-pods"
    ip_cidr_range = var.composer_pods_cidr
  }
  secondary_ip_range {
    range_name    = "composer-services"
    ip_cidr_range = var.composer_services_cidr
  }
}

# Private Subnet for Data Processing
resource "google_compute_subnetwork" "private_subnet" {
  name          = "${var.environment}-private-subnet"
  ip_cidr_range = var.private_subnet_cidr
  region        = var.data_region
  network       = google_compute_network.etl_vpc.id
  
  private_ip_google_access = true
  
  secondary_ip_range {
    range_name    = "dataproc-pods"
    ip_cidr_range = var.dataproc_pods_cidr
  }
}
```

**Implementation Features:**
- **Workload Segregation**: Separate subnets for orchestration and processing
- **Regional Distribution**: Multi-region deployment capability
- **Secondary IP Ranges**: Support for containerized workloads
- **Private Google Access**: Secure communication with Google APIs

#### **NAT Gateway Implementation**

```terraform
resource "google_compute_router" "nat_router" {
  name    = "${var.environment}-nat-router"
  region  = var.data_region
  network = google_compute_network.etl_vpc.id
  bgp {
    asn = 64514
  }
}

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
```

**Implementation Features:**
- **Controlled Internet Access**: NAT for private subnet outbound connectivity
- **Automatic IP Management**: Dynamic IP allocation for cost optimization
- **Selective Application**: Only private subnet uses NAT gateway
- **Logging Integration**: Error logging for troubleshooting

#### **Firewall Rules Implementation**

```terraform
# Internal Communication
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
}
```

**Security Implementation:**
- **Principle of Least Privilege**: Specific rules for each service type
- **Network Segmentation**: Source-based access control
- **Service-Specific Rules**: Targeted firewall rules for each component
- **Tag-Based Targeting**: Infrastructure tags for flexible rule application

### 4. **IAM and Security Implementation (Lines 200-257)**

#### **Service Account Strategy**

```terraform
# Reference Existing Service Accounts
data "google_service_account" "composer_sa" {
  account_id = "composer-sa"
  depends_on = [google_project_service.required_apis]
}

data "google_service_account" "dataproc_sa" {
  account_id = "dataproc-sa"
  depends_on = [google_project_service.required_apis]
}
```

**Implementation Approach:**
- **External Service Account Management**: References pre-created service accounts
- **Separation of Concerns**: IAM management separate from infrastructure
- **Dependency Control**: Ensures APIs are enabled before account lookup

#### **Role Assignment Implementation**

```terraform
# Composer Service Account Roles
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

# Dataproc Service Account Roles
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
```

**Security Implementation:**
- **Minimal Permissions**: Each service account gets only necessary roles
- **Iterative Role Assignment**: for_each loop for maintainable role management
- **Service-Specific Roles**: Tailored permissions for each workload type

### 5. **Secrets Management Implementation (Lines 262-314)**

```terraform
# Secret Creation
resource "google_secret_manager_secret" "sql_password" {
  secret_id = "${var.environment}-sql-password"

  labels = {
    environment = var.environment
    purpose     = "cloudsql-auth"
    managed_by  = "terraform"
  }

  replication {
    auto {}
  }
}

# Secret Version Management
resource "google_secret_manager_secret_version" "sql_password_version" {
  secret      = google_secret_manager_secret.sql_password.id
  secret_data = var.sql_user_password
}

# Access Control
resource "google_secret_manager_secret_iam_member" "dataproc_secret_access" {
  secret_id = google_secret_manager_secret.sql_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_service_account.dataproc_sa.email}"
}
```

**Implementation Features:**
- **Centralized Secret Storage**: All credentials in Secret Manager
- **Environment Labeling**: Consistent labeling for resource management
- **Access Control**: Granular permissions for secret access
- **Automatic Replication**: Global availability for secrets

### 6. **Storage Layer Implementation (Lines 319-373)**

#### **Data Lake Implementation**

```terraform
# Main Data Bucket
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

# Staging Bucket
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
}
```

**Implementation Features:**
- **Automated Lifecycle Management**: Cost optimization through storage class transitions
- **Versioning**: Data lineage and recovery capabilities
- **Uniform Access Control**: Simplified permission management
- **Environment-Specific Configuration**: Configurable bucket settings
- **Staging Cleanup**: Automatic cleanup of temporary files

### 7. **Database Layer Implementation (Lines 378-426)**

#### **Cloud SQL Implementation**

```terraform
# PostgreSQL Instance
resource "google_sql_database_instance" "postgres" {
  name             = var.sql_instance_name
  region           = var.data_region
  database_version = "POSTGRES_13"

  deletion_protection = false

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
      ipv4_enabled                                  = false
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
```

**Implementation Features:**
- **Private Networking**: No public IP, VPC-only access
- **Configurable Sizing**: Variable-driven instance configuration
- **Automatic Scaling**: Disk auto-resize for growth
- **Backup Strategy**: Scheduled backups with configurable retention
- **Enhanced Logging**: Database-level logging for audit trails
- **Dependency Management**: Ensures VPC peering before instance creation

#### **Database and User Creation**

```terraform
# Database Creation
resource "google_sql_database" "etl_database" {
  name     = var.sql_database_name
  instance = google_sql_database_instance.postgres.name
}

# User Management
resource "google_sql_user" "etl_user" {
  name     = var.sql_user_name
  instance = google_sql_database_instance.postgres.name
  password = var.sql_user_password
}
```

**Implementation Features:**
- **Separation of Concerns**: Separate resources for instance, database, and users
- **Variable-Driven Configuration**: All names and credentials configurable
- **Resource Dependencies**: Proper dependency chain for creation order

### 8. **Compute Layer Implementation (Lines 431-489)**

#### **Dataproc Cluster Configuration**

```terraform
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
      internal_ip_only = true

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
}
```

**Implementation Features:**
- **Multi-Tier Architecture**: Master, worker, and preemptible worker nodes
- **Private Networking**: Internal IP only for security
- **Cost Optimization**: Preemptible instances for batch workloads
- **Service Account Integration**: Dedicated service account with minimal permissions
- **Network Tags**: For firewall rule targeting
- **Configurable Sizing**: All node counts and machine types variable-driven

### 9. **Analytics Layer Implementation (Lines 494-522)**

#### **BigQuery Dataset Configuration**

```terraform
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
}
```

**Implementation Features:**
- **Role-Based Access Control**: Granular permissions for different service accounts
- **Data Governance**: Structured access control for data warehouse
- **Environment Configuration**: Location and settings based on variables
- **Cleanup Configuration**: Configurable data retention policy

### 10. **Orchestration Layer Implementation (Lines 527-700)**

#### **Cloud Composer Environment**

```terraform
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

        # File paths
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
}
```

**Implementation Features:**
- **Infrastructure Integration**: Environment variables connect all infrastructure components
- **Network Configuration**: Uses secondary IP ranges for pod and service networking
- **Resource Configuration**: Granular control over Airflow component sizing
- **Auto-scaling**: Configurable worker node scaling
- **Service Account Integration**: Dedicated service account for orchestration
- **Comprehensive Configuration**: All infrastructure endpoints and credentials available to DAGs

## Configuration Management Implementation

### Variable-Driven Architecture

**Variable Categories:**
- **Global Configuration**: Project ID, regions, environment
- **Network Configuration**: CIDR blocks, subnet configurations
- **Resource Sizing**: Machine types, disk sizes, node counts
- **Feature Flags**: Enable/disable features like backups, force destroy
- **Credentials**: Database passwords, service account names

### Environment Isolation

**Implementation Pattern:**
```terraform
resource "example_resource" "resource_name" {
  name = "${var.environment}-resource-name"
  # ... other configuration
}
```

**Benefits:**
- **Environment Separation**: No resource name conflicts between environments
- **Consistent Naming**: Predictable resource naming patterns
- **Easy Identification**: Environment clearly identified in resource names

## Dependency Management Implementation

### Explicit Dependencies

```terraform
depends_on = [
  google_project_service.required_apis,
  google_service_networking_connection.private_vpc_connection
]
```

**Implementation Strategy:**
- **API Dependencies**: All resources depend on required APIs being enabled
- **Network Dependencies**: Resources requiring VPC depend on network creation
- **Service Dependencies**: Higher-level services depend on lower-level infrastructure

### Implicit Dependencies

```terraform
network = google_compute_network.etl_vpc.id
subnetwork = google_compute_subnetwork.private_subnet.name
```

**Terraform Features:**
- **Resource References**: Automatic dependency detection through resource attributes
- **Dependency Graph**: Terraform builds dependency graph for proper creation order
- **Parallel Execution**: Independent resources created in parallel

## Security Implementation Details

### Network Security

**Private Networking Implementation:**
- All compute resources use private IP addresses only
- NAT gateway provides controlled internet access
- VPC peering enables private database connections
- Firewall rules implement network segmentation

### Identity and Access Management

**Service Account Strategy:**
- Separate service accounts for different workload types
- Minimal permission sets for each service account
- External service account management for security isolation

### Secrets Management

**Secret Manager Integration:**
- All sensitive data stored in Secret Manager
- Service account-based access control
- Automatic secret rotation support
- Audit logging for secret access

## Performance and Scalability Implementation

### Auto-scaling Implementation

**Dataproc Scaling:**
```terraform
preemptible_worker_config {
  num_instances = var.dataproc_preemptible_nodes
}
```

**Composer Scaling:**
```terraform
worker {
  min_count  = var.composer_worker_min_count
  max_count  = var.composer_worker_max_count
}
```

### Cost Optimization Implementation

**Storage Lifecycle:**
- Automatic tier transitions (Standard → Nearline → Coldline)
- Staging bucket cleanup (7-day deletion)
- Versioning for data protection

**Compute Optimization:**
- Preemptible instances for batch workloads
- Configurable resource sizing
- Auto-scaling based on workload

## Monitoring and Observability Implementation

### Logging Configuration

**NAT Gateway Logging:**
```terraform
log_config {
  enable = true
  filter = "ERRORS_ONLY"
}
```

**Database Logging:**
```terraform
database_flags {
  name  = "log_statement"
  value = "all"
}
```

### Resource Labeling

**Consistent Labeling Pattern:**
```terraform
labels = {
  environment = var.environment
  purpose     = "etl-processing"
  managed_by  = "terraform"
}
```

**Benefits:**
- **Resource Organization**: Easy filtering and grouping
- **Cost Tracking**: Environment and purpose-based cost allocation
- **Automation**: Labels enable automated resource management

## Error Handling and Resilience

### Timeout Configuration

```terraform
timeouts {
  create = "30m"
  update = "40m"
}
```

### Force Destroy Protection

```terraform
force_destroy = var.enable_force_destroy
deletion_protection = false # Configurable for production
```

### Backup Implementation

```terraform
backup_configuration {
  enabled                        = var.sql_backup_enabled
  start_time                     = "03:00"
  point_in_time_recovery_enabled = false
}
```

## Integration Points

### Service Integration

**Environment Variables for DAGs:**
- All infrastructure endpoints exposed as environment variables
- Database connection information
- Storage bucket locations
- Service account configurations

**Cross-Service References:**
- Composer environment references Dataproc cluster
- Dataproc cluster uses staging bucket
- All services use shared VPC and subnets

## Deployment Implementation

### State Management

**Remote State (Implied):**
- Terraform state should be stored in Cloud Storage
- State locking for concurrent access protection
- Environment-specific state files

### Variable Management

**Environment-Specific Variables:**
- Separate tfvars files for each environment
- Variable validation (where applicable)
- Sensitive variable handling

## Implementation Best Practices Demonstrated

### 1. **Resource Organization**
- Logical grouping of resources by function
- Consistent naming conventions
- Proper dependency management

### 2. **Security Implementation**
- Private networking by default
- Minimal IAM permissions
- Centralized secrets management

### 3. **Operational Excellence**
- Comprehensive labeling strategy
- Configurable backup and retention policies
- Monitoring and logging integration

### 4. **Cost Management**
- Storage lifecycle policies
- Preemptible instance usage
- Resource sizing based on environment

### 5. **Scalability Design**
- Auto-scaling configurations
- Multi-region deployment support
- Performance optimization settings

This implementation demonstrates a production-ready ETL infrastructure that translates design principles into working cloud infrastructure, with emphasis on security, scalability, and operational excellence. 