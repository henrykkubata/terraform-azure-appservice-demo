project_name = "poc"
environment  = "dev"
location     = "Poland Central"

tags = {
  Owner       = "dev-team"
  Environment = "dev"
  Project     = "poc-private-endpoint"
}

vnet_address_space             = ["10.10.0.0/16"]
subnet_app_prefix              = "10.10.1.0/24"
subnet_db_prefix               = "10.10.2.0/24"
subnet_private_endpoint_prefix = "10.10.3.0/28"

app_service_sku_name = "B1"
app_instance_count   = 1
app_service_linux    = true

db_engine         = "postgresql"
db_sku_name       = "GP_Standard_D2s_v3"
db_vcores         = 1
db_storage_gb     = 32
db_admin_username = "devdbadmin"

enable_private_endpoint = true
private_endpoint_count  = 1

nsg_enabled           = false
monitoring_enabled    = true
backup_retention_days = 7
allowed_admin_ips     = ["0.0.0.0/0"]
