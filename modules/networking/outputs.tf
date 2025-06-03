# ===================================================================
# NETWORKING MODULE OUTPUTS
# ===================================================================

# VPC Outputs
output "vpc_name" {
  description = "Name of the custom VPC"
  value       = google_compute_network.etl_vpc.name
}

output "vpc_id" {
  description = "ID of the custom VPC"
  value       = google_compute_network.etl_vpc.id
}

output "vpc_self_link" {
  description = "Self link of the custom VPC"
  value       = google_compute_network.etl_vpc.self_link
}

# Subnet Outputs
output "public_subnet_name" {
  description = "Name of the public subnet"
  value       = google_compute_subnetwork.public_subnet.name
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = google_compute_subnetwork.public_subnet.id
}

output "public_subnet_cidr" {
  description = "CIDR range of the public subnet"
  value       = google_compute_subnetwork.public_subnet.ip_cidr_range
}

output "private_subnet_name" {
  description = "Name of the private subnet"
  value       = google_compute_subnetwork.private_subnet.name
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = google_compute_subnetwork.private_subnet.id
}

output "private_subnet_cidr" {
  description = "CIDR range of the private subnet"
  value       = google_compute_subnetwork.private_subnet.ip_cidr_range
}

# NAT Gateway Outputs
output "nat_gateway_name" {
  description = "Name of the NAT gateway"
  value       = google_compute_router_nat.nat_gateway.name
}

output "nat_router_name" {
  description = "Name of the NAT router"
  value       = google_compute_router.nat_router.name
}

# Private Service Connection
output "private_vpc_connection" {
  description = "Private VPC connection for Cloud SQL"
  value       = google_service_networking_connection.private_vpc_connection
} 