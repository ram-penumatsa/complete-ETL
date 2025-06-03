# Sample Data for ETL Testing

This directory contains sample CSV files for testing the complete ETL pipeline. The data represents a retail scenario with sales transactions, product information, and store details.

## 📁 Directory Structure

```
sample_data/
├── README.md
├── sales_data/
│   └── sales_data.csv          # Transaction records (50 records)
└── reference_data/
    ├── products.csv            # Product catalog (22 products)
    └── stores.csv              # Store information (3 stores)
```

## 📊 Data Overview

### Sales Data (`sales_data/sales_data.csv`)
- **Records**: 50 transactions
- **Date Range**: December 1-5, 2023
- **Columns**: 
  - `transaction_id` - Unique transaction identifier (TXN001-TXN050)
  - `product_id` - Product reference (PROD001-PROD022)
  - `store_id` - Store reference (STORE001-STORE003)
  - `quantity` - Items purchased
  - `unit_price` - Price per item
  - `transaction_date` - Transaction date (YYYY-MM-DD format)
  - `customer_id` - Customer identifier (CUST001-CUST050)

**Note**: The PySpark job calculates `total_amount` as `quantity * unit_price` during processing.

### Products Data (`reference_data/products.csv`)
- **Records**: 22 products
- **Categories**: Electronics, Clothing, Home & Kitchen, Sports & Fitness, Home & Office, Health & Beauty, Home & Decor, Home & Bedroom
- **Price Range**: $9.99 - $299.99
- **Columns**: 
  - `product_id` - Unique product identifier
  - `product_name` - Product name
  - `category` - Main product category
  - `subcategory` - Product subcategory
  - `brand` - Brand name
  - `unit_price` - Selling price
  - `cost_price` - Cost price (for profit calculations)
  - `supplier_id` - Supplier reference
  - `weight_kg` - Product weight
  - `dimensions_cm` - Product dimensions
  - `color` - Product color
  - `material` - Primary material
  - `launch_date` - Product launch date
  - `discontinued` - Discontinuation status (Y/N)

### Stores Data (`reference_data/stores.csv`)
- **Records**: 3 stores
- **Locations**: San Francisco Bay Area (California)
- **Store Types**: Flagship, Standard, Express
- **Columns**: 
  - `store_id` - Unique store identifier
  - `store_name` - Store name
  - `store_type` - Store classification
  - `address` - Street address
  - `city` - City
  - `state` - State
  - `zip_code` - ZIP code
  - `country` - Country
  - `region` - Business region
  - `manager_name` - Store manager
  - `manager_email` - Manager email
  - `phone` - Store phone number
  - `opening_date` - Store opening date
  - `store_size_sqft` - Store size in square feet
  - `parking_spaces` - Available parking spaces
  - `24_hour_store` - 24-hour operation (Y/N)
  - `store_location` - City name (used in analytics)

## 🔗 Data Relationships

The datasets are designed to work together:

- **Sales ↔ Products**: `product_id` links sales transactions to product details
- **Sales ↔ Stores**: `store_id` links sales transactions to store information
- All product IDs in sales data have corresponding entries in products data
- All store IDs in sales data have corresponding entries in stores data

## 📈 Analytics Use Cases

This sample data supports various analytics scenarios:

1. **Revenue Analysis**: Daily, weekly sales performance
2. **Product Performance**: Best/worst selling products by category
3. **Store Performance**: Sales comparison across stores
4. **Profit Analysis**: Using cost vs. selling price
5. **Customer Behavior**: Analysis by customer segments
6. **Inventory Planning**: Sales velocity by product
7. **Regional Analysis**: Geographic sales patterns

## 🚀 Usage with ETL Pipeline

These files are designed to be uploaded to your GCS data bucket and processed through the complete ETL pipeline:

1. **Extract**: Read CSV files from GCS
2. **Transform**: Join datasets, calculate metrics, clean data
3. **Load**: Store results in BigQuery for analytics

## ✅ Schema Compatibility

The CSV schemas have been designed to match the PySpark job expectations:

- **Sales data schema** matches `sales_analytics_direct.py` StructType definition
- **Products and stores** are read dynamically with inferred schemas
- **Column names** align with analytics processing logic
- **Data types** are compatible with Spark DataFrame operations

The data volume is optimized for testing - large enough to demonstrate meaningful insights but small enough for quick processing and debugging. 