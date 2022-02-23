# global naming conventions and resources
module "globals" {
  source = "../globals"

  application = var.application
  environment = var.environment
  location    = var.location
  tenant      = var.tenant
}

# log analytics workspace
resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = lower("${module.globals.resource_base_name_long}-${module.globals.role_names.logging}-${module.globals.object_type_names.log_analytics_workspace}")
  location            = var.location
  resource_group_name = var.resource_group_name # TODO: this can be derived from globals. should we do that instead of passing in?
  retention_in_days   = var.retention_period
  sku                 = var.sku
  tags                = var.tags
}