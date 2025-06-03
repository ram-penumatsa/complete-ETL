#!/usr/bin/env python3
"""
Sales Analytics ETL Job - PySpark
Processes sales data, joins with reference data, and loads into BigQuery

Requirements:
- Service account with Secret Manager Secret Accessor role
"""

import os
import time
import sys
import argparse
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from pyspark.sql.types import *
import logging

# Import our database utility
from database_utils import create_database_manager_from_env

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def parse_arguments():
    """Parse command line arguments"""
    parser = argparse.ArgumentParser(description='Sales Analytics ETL Job')
    parser.add_argument('--project-id', required=True, help='GCP Project ID')
    parser.add_argument('--region', required=True, help='GCP Region')
    parser.add_argument('--data-bucket', required=True, help='Data Bucket Name')
    parser.add_argument('--cloudsql-ip', required=True, help='Cloud SQL IP')
    parser.add_argument('--database-name', required=True, help='Database Name')
    parser.add_argument('--database-user', required=True, help='Database User')
    parser.add_argument('--bigquery-dataset', required=True, help='BigQuery Dataset')
    parser.add_argument('--environment', default='dev', help='Environment')
    parser.add_argument('--sql-password-secret', required=True, help='SQL Password Secret')
    
    return parser.parse_args()

# Parse arguments
args = parse_arguments()

# Set configuration from arguments
PROJECT_ID = args.project_id
REGION = args.region
DATA_BUCKET = args.data_bucket
CLOUDSQL_IP = args.cloudsql_ip
DATABASE_NAME = args.database_name
DATABASE_USER = args.database_user
BIGQUERY_DATASET = args.bigquery_dataset
ENVIRONMENT = args.environment
SQL_PASSWORD_SECRET = args.sql_password_secret

# Set environment variables for database_utils
os.environ['PYSPARK_PROJECT_ID'] = PROJECT_ID
os.environ['REGION'] = REGION
os.environ['DATA_BUCKET'] = DATA_BUCKET
os.environ['CLOUDSQL_IP'] = CLOUDSQL_IP
os.environ['DATABASE_NAME'] = DATABASE_NAME
os.environ['DATABASE_USER'] = DATABASE_USER
os.environ['BIGQUERY_DATASET'] = BIGQUERY_DATASET
os.environ['ENVIRONMENT'] = ENVIRONMENT
os.environ['SQL_PASSWORD_SECRET'] = SQL_PASSWORD_SECRET

# Initialize database manager
db_manager = None

def get_database_manager():
    """Get or create database manager instance"""
    global db_manager
    if db_manager is None:
        db_manager = create_database_manager_from_env()
    return db_manager

def validate_database_connection(db_props, jdbc_url):
    """
    Validate database connection parameters
    
    Args:
        db_props: Database connection properties
        jdbc_url: JDBC URL
    
    Raises:
        ValueError: If required parameters are missing
    """
    required_props = ['user', 'password', 'driver']
    for prop in required_props:
        if not db_props.get(prop):
            raise ValueError(f"Missing required database property: {prop}")
    
    if not jdbc_url:
        raise ValueError("JDBC URL is required")
    
    if not CLOUDSQL_IP or not DATABASE_NAME:
        raise ValueError("Missing Cloud SQL IP or database name environment variables")

def create_spark_session():
    """Create and configure Spark session"""
    return SparkSession.builder \
        .appName(f"Sales Analytics ETL - {ENVIRONMENT}") \
        .config("spark.jars", "gs://{}/jars/spark-bigquery-with-dependencies_2.12-0.25.2.jar".format(DATA_BUCKET)) \
        .config("spark.jars", "gs://{}/jars/postgresql-42.7.1.jar".format(DATA_BUCKET)) \
        .config("spark.sql.adaptive.enabled", "true") \
        .config("spark.sql.adaptive.coalescePartitions.enabled", "true") \
        .config("spark.eventLog.enabled", "false") \
        .getOrCreate()

def read_sales_data(spark):
    """Read sales data from GCS"""
    sales_schema = StructType([
        StructField("transaction_id", StringType(), True),
        StructField("product_id", StringType(), True),
        StructField("store_id", StringType(), True),
        StructField("quantity", IntegerType(), True),
        StructField("unit_price", DoubleType(), True),
        StructField("transaction_date", StringType(), True),
        StructField("customer_id", StringType(), True)
    ])
    
    return spark.read \
        .option("header", "true") \
        .schema(sales_schema) \
        .csv(f"gs://{DATA_BUCKET}/sales_data/sales_data.csv")

def setup_reference_tables(spark, db_mgr):
    """Create PostgreSQL tables and load data from GCS CSV files"""
    
    logger.info("Setting up reference tables...")
    
    # Read CSV files from GCS
    logger.info("Reading products CSV from GCS...")
    products_csv = spark.read.option("header", "true").csv(f"gs://{DATA_BUCKET}/reference_data/products.csv")
    
    logger.info("Reading stores CSV from GCS...")
    stores_csv = spark.read.option("header", "true").csv(f"gs://{DATA_BUCKET}/reference_data/stores.csv")
    
    # Get JDBC properties
    db_props = db_mgr.get_spark_jdbc_properties()
    jdbc_url = db_mgr.get_jdbc_url()
    
    # Write to PostgreSQL (this will create tables automatically)
    logger.info("Creating and loading products table...")
    products_csv.write \
        .jdbc(url=jdbc_url, table="products", mode="overwrite", properties=db_props)
    
    logger.info("Creating and loading stores table...")
    stores_csv.write \
        .jdbc(url=jdbc_url, table="stores", mode="overwrite", properties=db_props)
    
    logger.info("Reference tables setup completed!")

def read_reference_data(spark):
    """Read products and stores data from Cloud SQL using DatabaseManager"""
    
    try:
        logger.info("Initializing database connection...")
        db_mgr = get_database_manager()
        
        # Perform health check
        if not db_mgr.health_check():
            raise Exception("Database health check failed")
        
        # Setup reference tables first (create and load from GCS)
        setup_reference_tables(spark, db_mgr)
        
        # Get JDBC properties and URL
        db_props = db_mgr.get_spark_jdbc_properties()
        jdbc_url = db_mgr.get_jdbc_url()
        
        logger.info(f"Connecting to PostgreSQL at {jdbc_url}")
        
        # Read products table
        logger.info("Reading products table...")
        products_df = spark.read \
            .jdbc(url=jdbc_url, table="products", properties=db_props)
        
        # Read stores table
        logger.info("Reading stores table...")
        stores_df = spark.read \
            .jdbc(url=jdbc_url, table="stores", properties=db_props)
        
        logger.info("Successfully retrieved reference data from Cloud SQL")
        return products_df, stores_df
        
    except Exception as e:
        logger.error(f"Failed to read reference data from Cloud SQL: {str(e)}")
        raise Exception(f"Database connection failed: {str(e)}")

def process_sales_analytics(sales_df, products_df, stores_df):
    """Transform and aggregate sales data"""
    
    # Convert transaction_date to proper date format
    sales_clean = sales_df.withColumn(
        "transaction_date", 
        to_date(col("transaction_date"), "yyyy-MM-dd")
    ).withColumn(
        "total_amount", 
        col("quantity") * col("unit_price")
    )
    
    # Drop unit_price from products to avoid ambiguity (we use sales unit_price)
    products_clean = products_df.drop("unit_price") if "unit_price" in products_df.columns else products_df
    
    # Join with reference data
    enriched_sales = sales_clean \
        .join(products_clean, "product_id", "left") \
        .join(stores_df, "store_id", "left")
    
    # Daily sales summary
    daily_sales = enriched_sales.groupBy(
        "transaction_date",
        "store_id", 
        "store_name",
        "store_location"
    ).agg(
        sum("total_amount").alias("daily_revenue"),
        sum("quantity").alias("daily_quantity"),
        countDistinct("transaction_id").alias("daily_transactions"),
        countDistinct("customer_id").alias("unique_customers")
    )
    
    # Product performance
    product_performance = enriched_sales.groupBy(
        "product_id",
        "product_name", 
        "category"
    ).agg(
        sum("total_amount").alias("total_revenue"),
        sum("quantity").alias("total_quantity_sold"),
        avg("unit_price").alias("avg_unit_price"),
        countDistinct("store_id").alias("stores_sold_in")
    )
    
    # Store performance  
    store_performance = enriched_sales.groupBy(
        "store_id",
        "store_name",
        "store_location"
    ).agg(
        sum("total_amount").alias("total_revenue"),
        sum("quantity").alias("total_items_sold"),
        countDistinct("product_id").alias("unique_products"),
        countDistinct("customer_id").alias("unique_customers")
    )
    
    return daily_sales, product_performance, store_performance

def write_to_bigquery(df, table_name):
    """Write DataFrame to BigQuery"""
    df.write \
        .format("bigquery") \
        .option("table", f"{PROJECT_ID}.{BIGQUERY_DATASET}.{table_name}") \
        .option("writeMethod", "direct") \
        .option("writeDisposition", "WRITE_TRUNCATE") \
        .mode("overwrite") \
        .save()

def main():
    """Main ETL process"""
    print(f"Starting Sales Analytics ETL for environment: {ENVIRONMENT}")
    
    # Create Spark session
    spark = create_spark_session()
    spark.sparkContext.setLogLevel("INFO")
    
    try:
        # Read data
        print("Reading sales data from GCS...")
        sales_df = read_sales_data(spark)
        print(f"Sales data count: {sales_df.count()}")
        
        print("Reading reference data from Cloud SQL...")
        products_df, stores_df = read_reference_data(spark)
        print(f"Products count: {products_df.count()}")
        print(f"Stores count: {stores_df.count()}")
        
        # Process analytics
        print("Processing sales analytics...")
        daily_sales, product_performance, store_performance = process_sales_analytics(
            sales_df, products_df, stores_df
        )
        
        # Write to BigQuery
        print("Writing results to BigQuery...")
        write_to_bigquery(daily_sales, "daily_sales_summary")
        write_to_bigquery(product_performance, "product_performance")
        write_to_bigquery(store_performance, "store_performance")
        
        # Show sample results
        print("\n=== DAILY SALES SUMMARY ===")
        daily_sales.show(5)
        
        print("\n=== TOP PRODUCTS BY REVENUE ===")
        product_performance.orderBy(desc("total_revenue")).show(5)
        
        print("\n=== STORE PERFORMANCE ===")
        store_performance.orderBy(desc("total_revenue")).show(5)
        
        print("ETL process completed successfully!")
        
    except Exception as e:
        print(f"ETL process failed: {str(e)}")
        raise e
        
    finally:
        spark.stop()

if __name__ == "__main__":
    main() 