# ETL Infrastructure Design Document

## Project Vision and Business Context

This document outlines the technical design for a **complete, production-ready ETL (Extract, Transform, Load) pipeline** on Google Cloud Platform. The design translates business requirements for sales analytics processing into a robust, scalable, and secure cloud-native architecture that follows Infrastructure as Code principles.

## Business Objective Alignment

The architecture is designed to support key business objectives:

- **Sales Analytics Processing**: End-to-end pipeline for sales data, product information, and store analytics
- **Scalable Data Processing**: Handle growing data volumes with distributed computing capabilities  
- **Business Intelligence Support**: Enable advanced analytics, reporting, and data science workflows
- **Multi-Environment Operations**: Support development, staging, and production deployments
- **Cost Optimization**: Implement intelligent resource management and lifecycle policies
- **Security & Compliance**: Enterprise-grade security with private networking and access controls

## System Architecture Overview

The design follows cloud-native principles with emphasis on security, scalability, and maintainability, implementing a complete data lake to data warehouse pipeline.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        ORCHESTRATION LAYER                      │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │           Cloud Composer (Apache Airflow)                   │ │
│  │  - Workflow Management  - Job Scheduling  - Monitoring      │ │
│  │  - ETL Coordination    - Error Handling   - Notifications   │ │
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
- **Infrastructure as Code**: Complete infrastructure defined in Terraform
- **Immutable Infrastructure**: Infrastructure changes through code versions
- **Container Support**: Secondary IP ranges for containerized workloads

### 4. **Scalability and Performance**
- **Horizontal Scaling**: Auto-scaling clusters based on workload
- **Data Partitioning**: Strategic data organization for performance
- **Resource Optimization**: Preemptible instances and lifecycle policies
- **Multi-Region Support**: Configurable deployment across regions
- **Intelligent Caching**: Optimized data access patterns

### 5. **Observability and Monitoring**
- **Comprehensive Logging**: Built-in logging across all components
- **Monitoring Integration**: Native GCP monitoring and alerting
- **Audit Trails**: Complete audit logging for compliance
- **Performance Metrics**: Real-time performance monitoring
- **Cost Tracking**: Resource-level cost attribution and optimization

## Component Design

### Data Pipeline Architecture

The complete ETL pipeline implements a modern data lake to data warehouse pattern:

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
- **Real-time Access**: Support for streaming and batch updates

### Networking Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Custom VPC                              │
│                    (Multi-Region Capable)                       │
│                                                                 │
│  ┌─────────────────────┐    ┌─────────────────────────────────┐  │
│  │   Public Subnet     │    │      Private Subnet             │  │
│  │  (Orchestration)    │    │    (Data Processing)            │  │
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
│  │ - Composer Services │    │ │     (Private IP Only)       │ │  │
│  └─────────────────────┘    │ │ - PostgreSQL Database       │ │  │
│                              │ │ - Automated Backups         │ │  │
│                              │ └─────────────────────────────┘ │  │
│                              │                                 │  │
│                              │ Secondary IP Ranges:            │  │
│                              │ - Dataproc Pods                │  │
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

**Design Features:**
- **Lifecycle Management**: Automatic tier transitions (Standard → Nearline → Coldline)
- **Versioning**: Enabled for data lineage and recovery
- **Uniform Bucket-Level Access**: Simplified permission management
- **Regional Storage**: Co-located with compute for performance
- **Sample Data Integration**: Production-ready sample data for testing
- **Schema Validation**: Sample data aligned with processing expectations

#### **2. Transactional Database (Cloud SQL PostgreSQL)**
**Production Configuration:**
- **Private IP Only**: No public internet access for security
- **VPC Peering**: Secure connection from processing cluster
- **Automated Backups**: Point-in-time recovery capability
- **High Availability**: Multi-zone deployment for production
- **Performance Tuning**: Optimized for reference data queries
- **Connection Pooling**: Efficient connection management

#### **3. Data Warehouse (BigQuery) - Analytics-Optimized**
**Design:**
- **Columnar Storage**: Optimized for analytical queries
- **Automatic Scaling**: Serverless query processing
- **Access Control**: Dataset-level permissions with IAM integration
- **Cost Optimization**: Partitioning and clustering strategies
- **Table Design**: 
  - `daily_sales_summary` - Time-series sales performance
  - `product_performance` - Product analytics and trends
  - `store_performance` - Store-level business metrics

### Processing Engine Design

#### **Dataproc Cluster Configuration - Production Scale**
```
Cluster Architecture:
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Master Node    │    │  Worker Nodes   │    │ Preemptible     │
│                 │    │                 │    │ Worker Nodes    │
│ - Cluster Mgmt  │    │ - Spark Workers │    │ - Cost Saving   │
│ - Job Scheduling│    │ - Data Storage  │    │ - Fault Tolerant│
│ - Resource Mgmt │    │ - Processing    │    │ - Auto Recovery │
│ - Monitoring    │    │ - Caching       │    │ - Elastic Scale │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

**Scaling Strategy:**
- **Master Nodes**: Single node with configurable machine types
- **Worker Nodes**: Configurable count based on workload requirements
- **Preemptible Workers**: Cost-optimized nodes for batch processing (up to 80% savings)
- **Auto-scaling**: Dynamic scaling based on job queue and resource utilization
- **Performance Tuning**: Optimized Spark configurations for sales analytics

### Orchestration Design

#### **Cloud Composer Architecture - Production Workflow Management**
```
Composer Environment (Production-Grade):
┌─────────────────────────────────────────────────────────────────┐
│                    Airflow Components                           │
│                                                                 │
│ ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────┐ │
│ │ Scheduler   │  │ Web Server  │  │   Workers   │  │ Database│ │
│ │             │  │             │  │             │  │         │ │
│ │ - DAG Parse │  │ - UI/API    │  │ - Task Exec │  │ - State │ │
│ │ - Task Sched│  │ - Monitoring│  │ - Parallel  │  │ - Logs  │ │
│ │ - SLA Track │  │ - Security  │  │ - Scaling   │  │ - Audit │ │
│ └─────────────┘  └─────────────┘  └─────────────┘  └─────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

**Configuration Management:**
- **Environment Variables**: Complete infrastructure configuration passed to DAGs
- **Connection Management**: Secure connections to all GCP services
- **Resource Allocation**: Configurable CPU/memory for each component
- **Auto-scaling**: Worker nodes scale based on task queue
- **High Availability**: Multi-zone deployment for production reliability

## Data Flow Design

### ETL Pipeline Architecture - Complete Business Process

```
Complete Sales Analytics Data Flow:
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Extract   │───▶│ Transform   │───▶│    Load     │───▶│   Analyze   │
│             │    │             │    │             │    │             │
│ - Sales CSV │    │ - Join Data │    │ - BigQuery  │    │ - BI Tools  │
│ - Products  │    │ - Calc Metr │    │ - Tables    │    │ - Reports   │
│ - Stores    │    │ - Clean Data│    │ - Indexes   │    │ - Dashboards│
│ - Validate  │    │ - Analytics │    │ - Partition │    │ - Insights  │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

**Detailed Business-Focused Data Flow:**

1. **Data Ingestion (Extract)**
   - **Sales Data**: Transaction records with customer, product, and store information
   - **Product Data**: Complete product catalog with pricing and attributes
   - **Store Data**: Store locations, managers, and operational details
   - **Validation**: Schema compatibility checks and data quality validation
   - **Metadata**: Automatic data lineage and catalog updates

2. **Data Processing (Transform)**
   - **Data Enrichment**: Joining sales transactions with product and store details
   - **Business Calculations**: Revenue, profit margins, and performance metrics
   - **Aggregations**: Daily sales summaries, product performance, store analytics
   - **Quality Assurance**: Data cleansing and validation operations
   - **Analytics Logic**: Business-specific calculations and KPIs

3. **Data Loading (Load)**
   - **Sales Analytics Tables**: Daily summaries, product performance, store metrics
   - **Table Optimization**: Partitioning by date, clustering by store/product
   - **Performance Tuning**: Indexes and materialized views for query acceleration
   - **Access Controls**: Role-based access for different user types

4. **Orchestration Flow (Workflow Management)**
   - **Dependency Management**: Proper task sequencing and error handling
   - **Monitoring**: Real-time job monitoring and alerting
   - **Retry Logic**: Automatic retry mechanisms for failed tasks
   - **Notifications**: Success/failure notifications and SLA monitoring

## Production Environment Configuration

### Multi-Environment Support Strategy

```
Environment Configuration Hierarchy:
┌─────────────────────────────────────────────────────────────────┐
│                  Environment Configurations                     │
│                                                                 │
│ Development:              Staging:              Production:      │
│ ├── Small instances      ├── Medium instances   ├── Large       │
│ ├── Single AZ            ├── Multi-AZ          ├── Multi-Region │
│ ├── Basic monitoring     ├── Enhanced monitor  ├── Full observ  │
│ ├── Daily backups        ├── Continuous backup ├── Multi-region │
│ └── Cost optimized       └── Performance focus └── HA + Perf    │
└─────────────────────────────────────────────────────────────────┘
```

### Resource Sizing Strategy

**Environment-Specific Scaling:**
- **Development**: Minimal resources for testing and development
- **Staging**: Production-like environment for final validation
- **Production**: Full-scale resources with high availability and performance optimization

### Security Configuration

**Production Security Features:**
- **Network Isolation**: Complete private networking with controlled access
- **Encryption**: Data encrypted at rest and in transit
- **Access Controls**: Role-based access with principle of least privilege
- **Audit Logging**: Comprehensive audit trails for compliance
- **Secrets Management**: Centralized credential management with rotation

## Technology Selection Rationale

### Google Cloud Platform Services Selection

**Cloud Composer vs. Self-managed Airflow:**
- ✅ Managed service reduces operational overhead
- ✅ Built-in security and compliance features
- ✅ Auto-scaling and high availability
- ✅ Integration with GCP services
- ✅ Enterprise-grade monitoring and logging

**Dataproc vs. Dataflow vs. GKE:**
- ✅ Spark ecosystem compatibility for complex analytics
- ✅ Custom library support and flexibility
- ✅ Cost control with preemptible instances
- ✅ Familiar Spark/Hadoop tooling
- ✅ Better suited for batch processing workloads

**BigQuery vs. Self-managed Data Warehouse:**
- ✅ Serverless architecture with automatic scaling
- ✅ Columnar storage optimized for analytics
- ✅ Built-in ML capabilities for advanced analytics
- ✅ Pay-per-query pricing model
- ✅ Integration with BI tools and data visualization

**Cloud SQL vs. Self-managed PostgreSQL:**
- ✅ Managed patches and updates
- ✅ Automated backups and high availability
- ✅ Built-in security features and compliance
- ✅ Integration with VPC and IAM
- ✅ Reduced operational complexity

## Performance and Scalability Design

### Compute Scaling Strategy

**Production Auto-scaling Configuration:**
- **Dataproc**: Primary and preemptible worker auto-scaling based on job queue
- **Composer**: Worker node scaling based on task execution requirements
- **BigQuery**: Automatic query scaling and slot allocation
- **Performance Monitoring**: Real-time metrics and automated optimization

### Cost Optimization Strategy

**Multi-Tier Cost Control:**
- **Storage Lifecycle**: Intelligent tier transitions for long-term cost optimization
- **Preemptible Instances**: Up to 80% cost savings for batch workloads
- **Auto-scaling**: Pay only for needed resources with automatic scaling
- **Regional Optimization**: Strategic resource placement for cost and performance
- **Resource Scheduling**: Off-hours scaling for non-production environments

## Disaster Recovery and Backup Strategy

### Comprehensive Backup Design

**Database Backup Strategy:**
- **Automated Daily Backups**: Cloud SQL automatic backup with point-in-time recovery
- **Cross-Region Replication**: Geographic redundancy for critical data
- **Backup Testing**: Regular backup restoration testing
- **Recovery SLAs**: Defined recovery time and point objectives

**Data Lake Backup Strategy:**
- **Object Versioning**: Multiple versions of critical data files
- **Cross-Region Replication**: Disaster recovery copies in separate regions
- **Lifecycle Policies**: Automated backup retention and archival
- **Immutable Storage**: Write-once, read-many protection for critical data

### Business Continuity Planning

**Infrastructure Recovery:**
- **Infrastructure as Code**: Complete environment recreation from Terraform
- **Configuration Management**: Version-controlled infrastructure and application configuration
- **State Management**: Terraform state backup and recovery procedures
- **Documentation**: Comprehensive runbooks and recovery procedures

## Use Cases and Business Value

### Primary Use Cases

**Sales Analytics and Reporting:**
- Daily, weekly, monthly sales performance analysis
- Product performance tracking and inventory optimization
- Store performance comparison and operational insights
- Customer behavior analysis and segmentation

**Advanced Analytics Capabilities:**
- Trend analysis and forecasting
- Real-time dashboard and KPI monitoring
- Ad-hoc analytical queries and data exploration
- Integration with machine learning and AI workflows

**Operational Benefits:**
- Automated data processing with minimal manual intervention
- Scalable architecture supporting business growth
- Cost-effective resource utilization and optimization
- Enterprise-grade security and compliance capabilities

### Future Enhancement Considerations

**Scalability Improvements:**
- **Streaming Data Support**: Real-time data ingestion and processing capabilities
- **Multi-Region Deployment**: Global data processing and disaster recovery
- **Advanced Analytics**: Machine learning and AI integration for predictive analytics
- **Data Catalog**: Automated data discovery, lineage, and governance

**Security Enhancements:**
- **Customer-Managed Encryption**: Enhanced data encryption control
- **VPC Service Controls**: Perimeter security for sensitive data
- **Advanced Threat Detection**: ML-based security monitoring and response
- **Zero-Trust Architecture**: Enhanced identity and access management

**Operational Improvements:**
- **GitOps Integration**: Automated deployment pipelines and infrastructure testing
- **Advanced Monitoring**: Predictive monitoring and automated remediation
- **Cost Optimization**: Advanced cost monitoring and recommendation systems
- **Performance Tuning**: Automated performance optimization and resource allocation

This design establishes a production-ready foundation for enterprise-scale sales analytics processing while maintaining flexibility for future enhancements and business requirements. 