# ETL Infrastructure Objective

## Project Overview

This project is a **complete, production-ready ETL (Extract, Transform, Load) pipeline** on Google Cloud Platform using Infrastructure as Code (Terraform). The infrastructure is designed to process sales analytics data with enterprise-grade security, scalability, and reliability using a **fully modular architecture**.

## Business Objective

The primary goal is to build a robust data pipeline that:

- **Ingests** sales data, product information, and store data from various sources
- **Transforms** and processes this data using distributed computing (Apache Spark)
- **Loads** the processed analytics results into a data warehouse for business intelligence
- **Orchestrates** the entire workflow with manual execution and comprehensive monitoring

## Architecture Components

### 1. **Networking & Security Foundation**
- **Custom VPC** with public and private subnets for network isolation
- **NAT Gateway** for secure internet access from private resources
- **Firewall rules** implementing principle of least privilege
- **Private Google Access** for secure communication with Google APIs

### 2. **Data Ingestion & Storage**
- **Google Cloud Storage (GCS)** buckets serving as a data lake
  - Main data bucket for raw sales, products, and stores data
  - Staging bucket for temporary processing artifacts
- **Automated lifecycle management** for cost optimization (Nearline → Coldline storage)

### 3. **Data Processing Engine**
- **Google Dataproc cluster** running Apache Spark for distributed data processing
- **PySpark jobs** for sales analytics transformations
- **Auto-scaling** with preemptible instances for cost efficiency
- **Private networking** for enhanced security

### 4. **Data Warehouse & Analytics**
- **Google BigQuery** dataset for storing processed analytics results
- **Optimized for OLAP** queries and business intelligence tools
- **Role-based access control** for data governance

### 5. **Database Layer**
- **Google Cloud SQL (PostgreSQL)** for transactional data storage
- **Private IP** configuration for security
- **Automated backups** and high availability options

### 6. **Workflow Orchestration**
- **Google Cloud Composer** (managed Apache Airflow) for workflow management
- **Manual-only execution** for controlled ETL job triggering
- **Environment variables** for configuration management
- **Integration** with all pipeline components

### 7. **Security & Compliance**
- **Google Secret Manager** for secure credential storage
- **Service accounts** with minimal required permissions
- **IAM roles and policies** following security best practices
- **VPC peering** for private database connections

## Technical Specifications

### Infrastructure Components:
- **Compute**: Dataproc cluster with configurable master/worker nodes
- **Storage**: Multi-tier GCS buckets with lifecycle policies
- **Database**: Cloud SQL PostgreSQL with private networking
- **Orchestration**: Cloud Composer v3 environment with Airflow 2.10.5
- **Analytics**: BigQuery dataset with access controls

### Security Features:
- Private networking with NAT gateway
- Service account authentication
- Secret Manager integration
- Firewall rules and network policies
- VPC peering for database access

### Scalability & Performance:
- Auto-scaling Dataproc clusters
- Preemptible instances for cost optimization
- Multi-region deployment capability
- Lifecycle management for storage optimization

## Modular Architecture

The infrastructure is built using a **fully modular Terraform architecture** with 9 specialized modules:

### **Core Modules:**
1. **Foundation Module** - API enablement and project setup
2. **Networking Module** - VPC, subnets, NAT gateway, firewall rules
3. **IAM Module** - Service accounts and role assignments
4. **Security Module** - Secret Manager and credential management
5. **Storage Module** - GCS buckets and lifecycle policies
6. **Database Module** - Cloud SQL PostgreSQL with private networking
7. **Compute Module** - Dataproc cluster configuration
8. **Analytics Module** - BigQuery dataset and access controls
9. **Orchestration Module** - Cloud Composer environment setup

### **Benefits of Modular Design:**
- **Maintainability**: Each component is independently manageable
- **Reusability**: Modules can be reused across environments
- **Testing**: Individual modules can be tested in isolation
- **Collaboration**: Teams can work on different modules simultaneously
- **Version Control**: Fine-grained change tracking per module

## Environment Configuration

The infrastructure supports multiple environments (dev, staging, production) through:
- **Variable-driven configuration** for environment-specific settings
- **Resource naming conventions** with environment prefixes
- **Separate service accounts** and IAM roles per environment
- **Configurable resource sizing** based on workload requirements

## Data Flow Architecture

1. **Extract**: Raw data files uploaded to GCS data bucket
2. **Transform**: Dataproc Spark jobs process and enrich the data
3. **Load**: Processed data loaded into BigQuery for analytics
4. **Orchestrate**: Cloud Composer manages workflow execution (manual trigger)
5. **Monitor**: Built-in logging and monitoring across all components

## Operational Model

### **Manual Execution Approach**
- **No Automatic Scheduling**: DAGs execute only when manually triggered
- **Zero Retry Policy**: Fail-fast approach for immediate error detection
- **Single Active Run**: Prevents concurrent executions
- **Manual Monitoring**: Requires active monitoring and intervention

### **Benefits of Manual Approach**
- **Cost Control**: No unexpected resource consumption
- **Data Quality**: Ensures data validation before processing
- **Controlled Execution**: Prevents cascading failures
- **Learning Environment**: Ideal for development and testing

## Benefits

- **Scalability**: Handle growing data volumes with auto-scaling compute
- **Security**: Enterprise-grade security with private networking and IAM
- **Cost Optimization**: Lifecycle policies and preemptible instances
- **Reliability**: High availability and automated backup strategies
- **Maintainability**: Modular Infrastructure as Code for version control and reproducibility
- **Flexibility**: Support for multiple data formats and processing patterns

## Use Cases

This infrastructure is ideal for:
- Sales analytics and reporting
- Customer behavior analysis
- Product performance tracking
- Store operations optimization
- Business intelligence and data science workflows
- Batch data processing scenarios with controlled execution
- Development and testing environments requiring manual oversight

## Deployment Strategy

The infrastructure is designed for:
- **Multi-environment deployment** (dev/staging/production)
- **Modular Infrastructure as Code** best practices
- **Automated provisioning** and configuration management
- **Version-controlled infrastructure** changes
- **Disaster recovery** and backup strategies
- **Component-level updates** without full infrastructure rebuilds 