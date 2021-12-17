# global naming conventions, resources, and other enterprise standards items
module "globals" {
  source = "github.com/brightwavepartners/terraform-azure/globals"

  application = var.application
  environment = var.environment
  location    = var.location
  tenant      = var.tenant
}

# resource group
resource "azurerm_resource_group" "resource_group" {
  location = var.location
  name     = lower(module.globals.resource_base_name_long)
  tags     = var.tags
}

# add contributors to the resource group - TODO: is it possible to look up the principal id by name so we only have to specify names instead of identifiers
resource "azurerm_role_assignment" "contributor" {
  for_each = { for contributor in var.contributors : contributor.name => contributor }

  scope                = azurerm_resource_group.resource_group.id
  role_definition_name = "Contributor"
  principal_id         = each.value.object_id
}

# add readers to the resource group - TODO: is it possible to look up the principal id by name so we only have to specify names instead of identifiers
resource "azurerm_role_assignment" "reader" {
  for_each = { for reader in var.readers : reader.name => reader }

  scope                = azurerm_resource_group.resource_group.id
  role_definition_name = "Reader"
  principal_id         = each.value.object_id
}
