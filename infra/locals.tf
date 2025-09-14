locals {
  common_name_prefix = "${var.environment}-${var.project_name}"

  rg_name         = "${local.common_name_prefix}-rg"
  vnet_name       = "${local.common_name_prefix}-vnet"
  subnet_app_name = "${local.common_name_prefix}-snet-app"
  subnet_db_name  = "${local.common_name_prefix}-snet-db"
  subnet_pe_name  = "${local.common_name_prefix}-snet-pe"

  app_service_plan = "${local.common_name_prefix}-asp"
  app_service_name = "${local.common_name_prefix}-app"

  db_server_name = replace("${local.common_name_prefix}-db", "_", "")
  db_name        = "${var.project_name}db"

  private_dns_zone = "privatelink.postgres.database.azure.com"
}
