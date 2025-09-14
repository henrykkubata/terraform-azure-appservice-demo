resource "azurerm_resource_group" "main" {
  name     = local.rg_name
  location = var.location
  tags     = var.tags
}

# ---------------- VNet & Subnets ----------------
resource "azurerm_virtual_network" "main" {
  name                = local.vnet_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "app" {
  name                 = local.subnet_app_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_app_prefix]
}

resource "azurerm_subnet" "db" {
  name                 = local.subnet_db_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_db_prefix]
}

resource "azurerm_subnet" "pe" {
  name                 = local.subnet_pe_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_private_endpoint_prefix]
}

# ---------------- App Service ----------------
resource "azurerm_service_plan" "main" {
  name                = local.app_service_plan
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = var.app_service_linux ? "Linux" : "Windows"
  sku_name            = var.app_service_sku_name
  tags                = var.tags
}

resource "azurerm_linux_web_app" "main" {
  name                = local.app_service_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.main.id

  site_config {}

  tags = var.tags
}

# ---------------- Database (Postgres) ----------------
resource "random_password" "pg_admin" {
  length  = 16
  special = true
}

resource "azurerm_postgresql_flexible_server" "main" {
  name                          = local.db_server_name
  resource_group_name           = azurerm_resource_group.main.name
  location                      = azurerm_resource_group.main.location
  administrator_login           = var.db_admin_username
  administrator_password        = var.db_admin_password != "" ? var.db_admin_password : random_password.pg_admin.result
  sku_name                      = var.db_sku_name
  storage_mb                    = var.db_storage_gb * 1024
  version                       = "13"
  public_network_access_enabled = false
}

# ---------------- Private Endpoint + DNS ----------------
resource "azurerm_private_dns_zone" "db" {
  name                = local.private_dns_zone
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "db" {
  name                  = "${local.common_name_prefix}-dnslink"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.db.name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled  = false
}

resource "azurerm_private_endpoint" "db" {
  name                = "dev-poc-pe-db"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.pe.id

  private_service_connection {
    name                           = "dbConnection"
    private_connection_resource_id = azurerm_postgresql_flexible_server.main.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "db-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.db.id]
  }
}
