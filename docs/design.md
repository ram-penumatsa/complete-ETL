# ETL Infrastructure Design Document

## Project Vision and Business Context

This document outlines the technical design for a **complete, production-ready ETL (Extract, Transform, Load) pipeline** on Google Cloud Platform. The design translates business requirements for sales analytics processing into a robust, scalable, and secure cloud-native architecture that follows Infrastructure as Code principles using a **fully modular Terraform architecture**.

## Business Objective Alignment

The architecture is designed to support key business objectives:

- **Sales Analytics Processing**: End-to-end pipeline for sales data, product information, and store analytics
- **Scalable Data Processing**: Handle growing data volumes with distributed computing capabilities  
- **Business Intelligence Support**: Enable advanced analytics, reporting, and data science workflows
- **Multi-Environment Operations**: Support development, staging, and production deployments
- **Cost Optimization**: Implement intelligent resource management and lifecycle policies
- **Security & Compliance**: Enterprise-grade security with private networking and access controls

## System Architecture Overview

The design follows cloud-native principles with emphasis on security, scalability, and maintainability, implementing a complete data lake to data warehouse pipeline using a **modular Terraform architecture** for enhanced maintainability and reusability.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        ORCHESTRATION LAYER                      │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │           Cloud Composer v3 (Apache Airflow 2.10.5)        │ │
│  │  - Manual Workflow Management - Job Scheduling              │ │
│  │  - ETL Coordination - Error Handling - Zero Retry Policy    │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                                    │
┌─────────────────────────────────────────────────────────────────┐
│                       PROCESSING LAYER                          │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │              Dataproc Cluster (Apache Spark)                │ │
│  │  - PySpark Jobs  - Data Transformation  - Sales Analytics   │ │
│  │  - Data Enrichment - Quality Validation - Performance Tuning│ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                                    │
┌─────────────────────────────────────────────────────────────────┐
│                        STORAGE LAYER                            │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │   Cloud Storage │  │   Cloud SQL     │  │   BigQuery      │  │
│  │   (Data Lake)   │  │  (PostgreSQL)   │  │ (Data Warehouse)│  │
│  │  - Raw Data     │  │ - Reference Data│  │ - Analytics     │ │
│  │  - Staging      │  │ - Metadata      │  │ - Reporting     │ │
│  │  - Archives     │  │ - Transactions  │  │ - BI Integration│ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                                    │
┌─────────────────────────────────────────────────────────────────┐
│                   SECURITY & NETWORKING LAYER                   │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                     Custom VPC                              │ │
│  │  - Private Subnets  - Public Subnets  - NAT Gateway        │ │
│  │  - Firewall Rules  - Service Networking - Secret Manager   │ │
│  │  - IAM Integration - VPC Peering      - Private Google API │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## Modular Architecture Design

### **Infrastructure Modules Overview**

The infrastructure is organized into 9 specialized Terraform modules, each responsible for a specific aspect of the pipeline:

```
Root Module (main.tf)
├── Foundation Module        # API enablement and project setup
├── Networking Module        # VPC, subnets, NAT, firewall
├── IAM Module              # Service accounts and permissions
├── Security Module         # Secret Manager and credentials
├── Storage Module          # GCS buckets and lifecycle policies
├── Database Module         # Cloud SQL PostgreSQL
├── Compute Module          # Dataproc cluster configuration
├── Analytics Module        # BigQuery dataset and access
└── Orchestration Module    # Cloud Composer environment
```

### **Module Dependency Graph**

```
Foundation Module (APIs)
    ↓
┌─→ Networking Module ←─┐
│   ↓                   │
│   IAM Module          │
│   ↓                   │
│   Security Module     │
│   ↓                   │
├─→ Storage Module      │
│   ↓                   │
├─→ Database Module ────┘
│   ↓
├─→ Compute Module
│   ↓
├─→ Analytics Module
│   ↓
└─→ Orchestration Module (depends on all)
```

### **Provider Configuration**

```terraform
terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"    # Updated from 4.0 to resolve provider crashes
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}
```

**Key Updates:**
- **Google Provider v5.45.2**: Upgraded from v4.85.0 to resolve segmentation fault crashes during Cloud Composer creation
- **Terraform 1.0+**: Modern Terraform version support
- **Lock File Management**: Proper provider version pinning for reproducible deployments

## Design Principles

### 1. **Production-Ready Architecture**
- **High Availability**: Multi-zone deployments with failover capabilities
- **Disaster Recovery**: Automated backups and cross-region replication
- **Performance Optimization**: Distributed processing with auto-scaling
- **Monitoring Integration**: Comprehensive observability and alerting

### 2. **Security by Design**
- **Zero Trust Network Model**: All components communicate through private networks
- **Principle of Least Privilege**: IAM roles with minimal required permissions
- **Defense in Depth**: Multiple layers of security controls
- **Secrets Management**: Centralized credential storage using Secret Manager
- **Network Isolation**: VPC-native architecture with controlled internet access

### 3. **Cloud-Native Architecture**
- **Managed Services**: Leveraging Google Cloud managed services for reduced operational overhead
- **Serverless Where Possible**: Auto-scaling and pay-per-use components
- **Infrastructure as Code**: Complete infrastructure defined in modular Terraform
- **Immutable Infrastructure**: Infrastructure changes through code versions
- **Container Support**: Secondary IP ranges for containerized workloads

### 4. **Modular Design Excellence**
- **Separation of Concerns**: Each module handles a specific infrastructure domain
- **Reusability**: Modules can be reused across different environments
- **Maintainability**: Individual modules can be updated independently
- **Testing**: Isolated testing of individual components
- **Collaboration**: Multiple teams can work on different modules simultaneously

### 5. **Operational Control**
- **Manual Execution**: Zero automatic scheduling for controlled operations
- **Fail-Fast Approach**: Zero retry policy for immediate error detection
- **Single Active Run**: Prevents concurrent DAG executions
- **Comprehensive Logging**: Built-in logging across all components

## Component Design

### Data Pipeline Architecture

The complete ETL pipeline implements a modern data lake to data warehouse pattern with manual execution control:

#### **Extract Phase**
- **Data Sources**: Sales transactions, product catalogs, store information
- **Ingestion Methods**: Batch file uploads to Cloud Storage
- **Data Validation**: Schema validation and quality checks
- **Metadata Capture**: Automatic data lineage and cataloging

#### **Transform Phase**
- **Distributed Processing**: Apache Spark on Dataproc for large-scale transformations
- **Data Enrichment**: Joining sales data with reference information
- **Business Logic**: Sales analytics calculations and aggregations
- **Quality Assurance**: Data validation and cleansing operations

#### **Load Phase**
- **Data Warehouse**: BigQuery for analytical workloads
- **Table Design**: Partitioned and clustered tables for performance
- **Access Patterns**: Optimized for business intelligence queries
- **Manual Execution**: Controlled data loading with validation

### Networking Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Custom VPC                              │
│                    (Multi-Region Capable)                       │
│                                                                 │
│  ┌─────────────────────┐    ┌─────────────────────────────────┐  │
│  │   Public Subnet     │    │      Private Subnet             │  │
│  │  (10.1.0.0/24)      │    │    (10.2.0.0/24)               │  │
│  │                     │    │                                 │  │
│  │ ┌─────────────────┐ │    │ ┌─────────────────────────────┐ │  │
│  │ │ Cloud Composer  │ │    │ │      Dataproc Cluster      │ │  │
│  │ │   Environment   │ │    │ │   - Master Nodes            │ │  │
│  │ │ - DAG Management│ │    │ │   - Worker Nodes            │ │  │
│  │ │ - UI/API Access │ │    │ │   - Preemptible Workers     │ │  │
│  │ └─────────────────┘ │    │ └─────────────────────────────┘ │  │
│  │                     │    │                                 │  │
│  │ Secondary IP Ranges:│    │ ┌─────────────────────────────┐ │  │
│  │ - Composer Pods     │    │ │       Cloud SQL             │ │  │
│  │   (10.3.0.0/16)     │    │ │     (Private IP Only)       │ │  │
│  │ - Composer Services │    │ │ - PostgreSQL Database       │ │  │
│  │   (10.4.0.0/16)     │    │ │ - Automated Backups         │ │  │
│  └─────────────────────┘    │ └─────────────────────────────┘ │  │
│                              │                                 │  │
│                              │ Secondary IP Ranges:            │  │
│                              │ - Dataproc Pods (10.5.0.0/16) │  │
│                              └─────────────────────────────────┘  │
│                                           │                     │
│                                    ┌─────────────┐               │
│                                    │ NAT Gateway │               │
│                                    │ - Auto IPs  │               │
│                                    │ - Logging   │               │
│                                    └─────────────┘               │
└─────────────────────────────────────────────────────────────────┘
```

**Design Rationale:**
- **Workload Isolation**: Separate subnets for orchestration and data processing
- **Security Zones**: Public subnet for management, private for sensitive operations
- **Controlled Access**: NAT gateway for controlled outbound internet access
- **Private Google Access**: Direct communication with Google APIs without internet
- **Service Networking**: VPC peering for private database connections
- **Container Support**: Secondary IP ranges for Kubernetes-style workloads

### Data Storage Architecture

#### **1. Data Lake (Cloud Storage) - Enterprise Design**
```
Production Data Bucket Structure:
├── sample_data/                    # Sample data for testing
│   ├── sales_data/
│   │   └── sales_data.csv         # Transaction records (schema-validated)
│   ├── reference_data/
│   │   ├── products.csv           # Product catalog
│   │   └── stores.csv             # Store information
│   └── README.md                  # Data documentation
├── production_data/                # Production data ingestion
│   ├── sales_data/
│   ├── reference_data/
│   └── processed/
├── pyspark-jobs/                   # Processing logic
│   ├── sales_analytics_direct.py  # Main ETL job
│   └── database_utils.py          # Database utilities
├── jars/                          # External dependencies
│   ├── spark-bigquery-with-dependencies_2.12-0.25.2.jar
│   └── postgresql-42.7.1.jar
└── archives/                      # Long-term storage
    ├── yearly/
    ├── monthly/
    └── backup/

Staging Bucket (Temporary Processing):
├── dataproc_staging/              # Dataproc temporary files
├── intermediate_results/          # Processing intermediates
└── job_logs/                     # Processing logs
```

## Manual Execution Design

### **DAG Configuration**
```python
default_args = {
    'owner': 'data-engineering-team',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 0,  # NO RETRIES: Fail immediately on error
    'max_active_runs': 1,
}

dag = DAG(
    'sales_analytics_etl',
    default_args=default_args,
    description='Sales Analytics ETL Pipeline with PySpark and BigQuery',
    schedule_interval=None,  # Manual execution only
    catchup=False,
    tags=['etl', 'sales', 'analytics', 'pyspark', 'bigquery', 'manual']
)
```

### **Execution Control Features**
- **Manual Triggering**: No automatic scheduling
- **Zero Retry Policy**: Immediate failure detection
- **Single Active Run**: Prevents concurrent executions
- **Comprehensive Logging**: Full audit trail of executions

## Security Architecture

### **Identity and Access Management**
```terraform
# Service Account Structure
├── Composer Service Account
│   ├── Composer Worker
│   ├── Secret Manager Secret Accessor
│   └── BigQuery Data Editor
├── Dataproc Service Account
│   ├── Dataproc Worker
│   ├── BigQuery Data Editor
│   └── Secret Manager Secret Accessor
```

### **Secret Management**
- **Google Secret Manager**: Centralized credential storage
- **Runtime Retrieval**: Passwords retrieved during job execution
- **No Hardcoded Secrets**: All sensitive data in Secret Manager
- **Service Account Authentication**: No API keys or tokens

## Performance and Scalability

### **Auto-Scaling Design**
- **Dataproc Cluster**: Configurable master/worker node sizing
- **Preemptible Workers**: Cost optimization through spot instances
- **BigQuery**: Serverless auto-scaling for analytics workloads
- **Cloud Storage**: Unlimited storage with lifecycle management

### **Resource Optimization**
- **Lifecycle Policies**: Automatic data archiving (Nearline → Coldline)
- **Intelligent Tiering**: Cost-optimized storage classes
- **Preemptible Instances**: Reduced compute costs
- **Right-Sizing**: Configurable resource allocation per environment

## Monitoring and Observability

### **Built-in Monitoring**
- **Cloud Logging**: Centralized log aggregation
- **Cloud Monitoring**: Performance metrics and alerting
- **Airflow UI**: DAG execution monitoring
- **BigQuery Monitoring**: Query performance optimization

### **Operational Dashboards**
- **Infrastructure Metrics**: Resource utilization tracking
- **Pipeline Metrics**: ETL job performance monitoring
- **Cost Tracking**: Resource-level cost attribution
- **Error Tracking**: Comprehensive error logging and alerting

This design establishes a production-ready foundation for enterprise-scale sales analytics processing while maintaining flexibility for future enhancements and business requirements. 