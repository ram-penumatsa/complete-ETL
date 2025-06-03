# ===================================================================
# NETWORKING MODULE - VPC, SUBNETS, NAT, FIREWALL
# ===================================================================

# Custom VPC for ETL infrastructure
resource "google_compute_network" "etl_vpc" {
  name                    = "${var.environment}-etl-vpc"
  description             = "Custom VPC for ETL infrastructure"
  auto_create_subnetworks = false
  mtu                     = 1460
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
} 