terraform {
  experiments = [module_variable_optional_attrs]
}

locals {
  # default app settings are those that are always the same for every function app created
  default_app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = azurerm_application_insights.application_insights.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = "InstrumentationKey=${azurerm_application_insights.application_insights.instrumentation_key};IngestionEndpoint=https://${var.location}-0.in.applicationinsights.azure.com/"
    "FUNCTIONS_WORKER_RUNTIME"              = var.worker_runtime_type
  }
}

# global naming conventions and resources
module "globals" {
  source = "../globals"

  application = var.application
  environment = var.environment
  location    = var.location
  tenant      = var.tenant
}

# create an application insights instance that will be connected to the azure function
resource "azurerm_application_insights" "application_insights" {
  application_type    = "web"
  location            = var.location
  name                = lower("${module.globals.resource_base_name_long}-${var.role}-${module.globals.object_type_names.application_insights}")
  resource_group_name = var.resource_group_name
  tags                = var.tags
  workspace_id        = var.log_analytics_workspace_id
}

# storage account
module "storage_account" {
  source = "../storage_account"

  account_replication_type = "LRS"
  account_tier             = "Standard"
  application              = var.application
  environment              = var.environment
  location                 = var.location
  role                     = var.role
  resource_group_name      = var.resource_group_name
  tags                     = var.tags
  tenant                   = var.tenant
}

# azure function
resource "azurerm_function_app" "function_app" {
  app_service_plan_id        = var.app_service_plan_id
  https_only                 = true
  location                   = var.location
  name                       = lower("${module.globals.resource_base_name_long}-${var.role}-${module.globals.object_type_names.function_app}")
  resource_group_name        = var.resource_group_name
  storage_account_access_key = module.storage_account.primary_access_key
  storage_account_name       = module.storage_account.name
  tags                       = var.tags
  version                    = var.functions_runtime_version

  # combine the default app settings that never change with any that are passed in to end up with one set of app settings for the function app
  app_settings = merge(
    local.default_app_settings,
    var.app_settings
  )

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on = var.always_on
    cors {
      allowed_origins = [
        for origin in [
          for origin in var.cors_settings.allowed_origins :
          replace(
            origin,
            "$${var.environment}",
            var.environment
          )
        ] :
        replace(
          origin,
          "$${var.location}",
          module.globals.location_short_name_list[var.location]
        )
      ]
      support_credentials = var.cors_settings.support_credentials
    }

    dotnet_framework_version = var.dotnet_framework_version
    ftps_state = "FtpsOnly"

    # we are doing the ip_restriction attribute via a for loop instead of dynamic block because
    # a dynamic block will not construct an empty list to remove all rules if the passed in 
    # configuration calls for it. in other words, there is no way to use a dynamic block to 
    # remove all restrictions if there were some left from a previous configuration that we need
    # removed.
    ip_restriction = [
      for ip_restriction in var.ip_restrictions : {
        action                    = ip_restriction.action
        headers                   = [] # TODO: according the documentation, this value should be optional but apparently is not. there is an issue here https://github.com/hashicorp/terraform-provider-azurerm/issues/12367. Need to figure out how to work around the issue without hard-coding.
        ip_address                = ip_restriction.ip_address
        name                      = ip_restriction.name
        priority                  = ip_restriction.priority
        service_tag               = ip_restriction.service_tag
        virtual_network_subnet_id = ip_restriction.virtual_network_subnet_id
      }
    ]

    use_32_bit_worker_process = var.use_32_bit_worker_process
    vnet_route_all_enabled = var.vnet_route_all_enabled
  }


  # TODO: this shouldn't be here in an enterprise module, but don't have a way to set this from outside at the moment. some app_settings are being updated via null resource so will show up as changes here.
  lifecycle {
    ignore_changes = [
      app_settings
    ]
  }
}

# vnet integration for function app - if enabled
resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration" {
  count = var.vnet_integration_enabled ? 1 : 0

  app_service_id = azurerm_function_app.function_app.id
  subnet_id      = var.subnet_id

  timeouts {
    create = "1h"
  }
}
