#!/usr/bin/env python3
"""
Database Utilities for PostgreSQL with Secret Manager Integration

This module provides utilities for:
- Secure password retrieval from Google Secret Manager
- JDBC connection properties for Spark
- Database connection details
"""

import os
import time
import logging
from typing import Dict, Any, Optional

# Configure logging
logger = logging.getLogger(__name__)

class DatabaseManager:
    """
    Database manager for Spark JDBC connections
    """
    
    def __init__(self, 
                 project_id: str,
                 secret_id: str,
                 host: str,
                 database: str,
                 username: str,
                 port: int = 5432):
        """
        Initialize database manager
        
        Args:
            project_id: GCP project ID
            secret_id: Secret Manager secret ID for database password
            host: Database host
            database: Database name
            username: Database username
            port: Database port
        """
        self.project_id = project_id
        self.secret_id = secret_id
        self.host = host
        self.database = database
        self.username = username
        self.port = port
        self._password = None
    
    def get_password(self, max_retries: int = 3, retry_delay: int = 1) -> str:
        """
        Get database password from environment variable with fallback
        
        Args:
            max_retries: Maximum number of retry attempts (unused in env var mode)
            retry_delay: Delay between retries in seconds (unused in env var mode)
            
        Returns:
            str: Database password
            
        Raises:
            Exception: If password cannot be retrieved
        """
        if self._password is not None:
            return self._password
        
        # Try environment variable first
        env_password = os.getenv('DATABASE_PASSWORD')
        if env_password:
            self._password = env_password
            logger.info("Using database password from environment variable")
            return self._password
        
        # Fallback: try to get from secret manager using gcloud command
        try:
            import subprocess
            logger.info("Attempting to retrieve password using gcloud command")
            result = subprocess.run([
                'gcloud', 'secrets', 'versions', 'access', 'latest', 
                '--secret', self.secret_id, '--project', self.project_id
            ], capture_output=True, text=True, timeout=30)
            
            if result.returncode == 0:
                self._password = result.stdout.strip()
                logger.info("Successfully retrieved database password using gcloud")
                return self._password
            else:
                logger.error(f"gcloud command failed: {result.stderr}")
                
        except Exception as e:
            logger.error(f"Failed to retrieve password: {str(e)}")
        
        raise Exception(f"Could not retrieve password for secret {self.secret_id}")
    
    def get_spark_jdbc_properties(self) -> Dict[str, Any]:
        """
        Get JDBC properties for Spark connections
        
        Returns:
            dict: JDBC connection properties
        """
        password = self.get_password()
        
        return {
            "user": self.username,
            "password": password,
            "driver": "org.postgresql.Driver",
            "connectTimeout": "60",
            "socketTimeout": "60",
            "loginTimeout": "30",
            "prepareThreshold": "0",
            "preparedStatementCacheQueries": "256",
            "preparedStatementCacheSizeMiB": "5"
        }
    
    def get_jdbc_url(self) -> str:
        """
        Get JDBC URL for database connections
        
        Returns:
            str: JDBC URL
        """
        return f"jdbc:postgresql://{self.host}:{self.port}/{self.database}"
    
    def health_check(self) -> bool:
        """
        Perform basic validation of connection parameters
        
        Returns:
            bool: True if parameters are valid, False otherwise
        """
        try:
            # Validate required parameters
            if not all([self.host, self.database, self.username, self.port]):
                logger.error("Missing required connection parameters")
                return False
            
            # Try to get password to validate secret access
            password = self.get_password()
            if not password:
                logger.error("Failed to retrieve database password")
                return False
            
            logger.info("Database parameters validation: PASSED")
            return True
            
        except Exception as e:
            logger.error(f"Database parameters validation failed: {str(e)}")
            return False


def create_database_manager_from_env() -> DatabaseManager:
    """
    Create DatabaseManager instance from environment variables
    
    Returns:
        DatabaseManager: Configured database manager
        
    Raises:
        ValueError: If required environment variables are missing
    """
    required_vars = {
        'PROJECT_ID': os.getenv('PYSPARK_PROJECT_ID'),
        'SQL_PASSWORD_SECRET': os.getenv('SQL_PASSWORD_SECRET'),
        'CLOUDSQL_IP': os.getenv('CLOUDSQL_IP'),
        'DATABASE_NAME': os.getenv('DATABASE_NAME'),
        'DATABASE_USER': os.getenv('DATABASE_USER')
    }
    
    missing_vars = [var for var, value in required_vars.items() if not value]
    if missing_vars:
        raise ValueError(f"Missing required environment variables: {', '.join(missing_vars)}")
    
    return DatabaseManager(
        project_id=required_vars['PROJECT_ID'],
        secret_id=required_vars['SQL_PASSWORD_SECRET'],
        host=required_vars['CLOUDSQL_IP'],
        database=required_vars['DATABASE_NAME'],
        username=required_vars['DATABASE_USER']
    )


# Example usage functions
def test_database_connection():
    """Test database connection parameters using environment variables"""
    try:
        db_manager = create_database_manager_from_env()
        
        # Test parameter validation
        if db_manager.health_check():
            logger.info("Database connection parameters test PASSED")
            return True
        else:
            logger.error("Database connection parameters test FAILED")
            return False
            
    except Exception as e:
        logger.error(f"Database connection test failed: {str(e)}")
        return False


if __name__ == "__main__":
    # Configure logging for testing
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    
    # Test the database connection
    test_database_connection() 