# ----------------------------------------------
# Basic
# ----------------------------------------------
variable "environment" {
  description = "Environment: dev | staging | prod | test"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name (used in resource name prefixes)"
  type        = string
  default     = "poc"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "Poland Central"
}

variable "tags" {
  description = "Map of tags applied to resources"
  type        = map(string)
  default = {
    Owner       = "team-app"
    Environment = "dev"
    Project     = "poc-private-endpoint"
  }
}

# ----------------------------------------------
# VNet & Subnets
# ----------------------------------------------
variable "vnet_address_space" {
  description = "VNet address space (list of CIDRs)"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_app_prefix" {
  description = "CIDR for application subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_db_prefix" {
  description = "CIDR for database subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "subnet_private_endpoint_prefix" {
  description = "CIDR for Private Endpoint subnet"
  type        = string
  default     = "10.0.3.0/28"
}

# ----------------------------------------------
# App Service
# ----------------------------------------------
variable "app_service_linux" {
  description = "Whether App Service runs on Linux"
  type        = bool
  default     = true
}

variable "go_version" {
  description = "Go runtime version for App Service"
  type        = string
  default     = "1.23"
}

variable "app_service_sku_name" {
  description = "App Service SKU (e.g., B1, S1, P1v2)"
  type        = string
  default     = "B1"
}

variable "app_instance_count" {
  description = "Number of app instances (scale-out)"
  type        = number
  default     = 1
}

# ----------------------------------------------
# Database
# ----------------------------------------------
variable "db_engine" {
  description = "Database engine: mysql | postgresql"
  type        = string
  default     = "postgresql"
}

variable "db_sku_name" {
  description = "Database server SKU (e.g., GP_Standard_D2s_v3)"
  type        = string
  default     = "GP_Standard_D2s_v3"
}

variable "db_vcores" {
  description = "Number of vCores for the database"
  type        = number
  default     = 1
}

variable "db_storage_gb" {
  description = "Database storage size in GB"
  type        = number
  default     = 32
}

variable "db_admin_username" {
  description = "Database administrator username"
  type        = string
  default     = "dbadmin"
}

variable "db_admin_password" {
  description = "Database administrator password (sensitive)"
  type        = string
  sensitive   = true
  default     = ""
}

# ----------------------------------------------
# Private Endpoint
# ----------------------------------------------
variable "enable_private_endpoint" {
  description = "Whether to enable Private Endpoint"
  type        = bool
  default     = true
}

variable "private_endpoint_count" {
  description = "Number of Private Endpoints"
  type        = number
  default     = 1
}

# ----------------------------------------------
# NSG / Monitoring / Access
# ----------------------------------------------
variable "nsg_enabled" {
  description = "Whether to create Network Security Groups for subnets"
  type        = bool
  default     = false
}

variable "monitoring_enabled" {
  description = "Whether to enable monitoring (Application Insights / Log Analytics)"
  type        = bool
  default     = true
}

variable "allowed_admin_ips" {
  description = "List of public IPs allowed for administrative access"
  type        = list(string)
  default     = []
}
