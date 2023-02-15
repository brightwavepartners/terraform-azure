terraform {
  experiments = [module_variable_optional_attrs]
}

locals {
  # default app settings are those that are always the same for every function app created
  default_app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"           = azurerm_application_insights.application_insights.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING"    = "InstrumentationKey=${azurerm_application_insights.application_insights.instrumentation_key};IngestionEndpoint=https://${var.location}-0.in.applicationinsights.azure.com/"
    "FUNCTIONS_WORKER_RUNTIME"                 = var.worker_runtime_type
    
    #"WEBSITE_CONTENTAZUREFILECONNECTIONSTRING" = module.storage_account.primary_connection_string
    
    # this setting is required if storage account is vnet integrated
    "WEBSITE_CONTENTOVERVNET"                  = var.storage == null ? 0 : var.storage.vnet_integration.enabled ? 1 : 0
    
    #"WEBSITE_CONTENTSHARE"                     = local.function_app_website_content_folder_name
  }
  function_app_website_content_folder_name = "application-files"
  metric_namespace                         = "Microsoft.Web/sites"
  # the runtime version is being hardcoded in this module because there are some features
  # being used by this code that are only available in versions >= ~4. if the client code
  # is allowed to set this version, it may end up being a lower version that doesn't support
  # the features needed and things won't work.
  runtime_version = "~4"

  vnet_integrated_function_route_all_enabled = try(var.vnet_integration.vnet_route_all_enabled, null)
  vnet_integrated_function_subnet_id         = try(var.vnet_integration.subnet_id, null)
  vnet_integrated_storage_allowed_ips        = try(var.storage.vnet_integration.allowed_ips, null)
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
  alert_settings           = try(var.storage.alert_settings, [])
  allowed_ips              = local.vnet_integrated_storage_allowed_ips
  environment              = var.environment
  location                 = var.location
  role                     = var.role
  resource_group_name      = var.resource_group_name
  subnet_ids               = var.storage == null ? null : var.storage.vnet_integration.enabled ? [var.vnet_integration.subnet_id] : null
  tags                     = var.tags
  tenant                   = var.tenant
}

# TODO: this section should only be applied if vnet integration is enabled 
# storage account file share for application files
# # resource "azurerm_storage_share" "application_files_storage_share" {
# #     name = local.function_app_website_content_folder_name
# #     storage_account_name = module.storage_account.name
# #     quota = 50
# # }

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
    elastic_instance_minimum = var.minimum_instance_count
    ftps_state               = "FtpsOnly"

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
    vnet_route_all_enabled    = local.vnet_integrated_function_route_all_enabled
  }
}

# need to get the WEBSITE_CONTENTSHARE that was automatcially set
# when the function app was provisioned so we can create the
# file share with the same name in the storage account
data "azurerm_function_app" "function_app" {
  name = azurerm_function_app.function_app.name
  resource_group_name = azurerm_function_app.function_app.resource_group_name
}

# TODO: this section should only be applied if vnet integration is enabled 
# storage account file share for application files
resource "azurerm_storage_share" "application_files_storage_share" {
    name = data.azurerm_function_app.function_app.app_settings["WEBSITE_CONTENTSHARE"]
    storage_account_name = module.storage_account.name
    quota = 50
}

# TODO: this section should only be applied if vnet integration is enabled
# ---note---
# when the function app is provisioned, it will automatically define the
# 'WEBSITE_CONTENTSHARE' value, which is different from the manually
# created and named file share. this happens even thought he file share
# wasn't created in the storage account using the name from 'WEBSITE_CONTENTSHARE'.
# so, need to go back and update the 'WEBSITE_CONTENTSHARE' value and
# set it to the name of the file share that was setup earlier with the 
# azurerm_storage_share.application_files_storage_share resource.
# # resource "azapi_update_resource" "appsettings_websitecontentfolder" {
# #   type      = "Microsoft.Web/sites/config@2022-03-01"
# #   name      = "appsettings"
# #   parent_id = azurerm_function_app.function_app.id

# #   body = jsonencode({
# #     properties = local.default_app_settings
# #   })
# #   response_export_values = ["*"]
# # }

# vnet integration for function app - if enabled
resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration" {
  count = var.vnet_integration != null ? 1 : 0

  app_service_id = azurerm_function_app.function_app.id
  subnet_id      = local.vnet_integrated_function_subnet_id

  timeouts {
    create = "1h"
  }
}

# diagnostics settings
module "diagnostics_settings" {
  source = "../diagnostics_settings"

  settings           = var.diagnostics_settings
  target_resource_id = azurerm_function_app.function_app.id
}

# alerts on function app
module "alerts" {
  source = "../metric_alert"

  for_each = { for alert_setting in var.alert_settings : alert_setting.name => alert_setting }

  alert_settings = {
    action = {
      action_group_id = each.value.action.action_group_id
    }
    description = each.value.description
    dynamic_criteria = try(
      {
        aggregation              = each.value.dynamic_criteria.aggregation
        alert_sensitivity        = each.value.dynamic_criteria.alert_sensitivity
        evaluation_failure_count = try(each.value.dynamic_criteria.evaluation_failure_count, null)
        evaluation_total_count   = try(each.value.dynamic_criteria.evaluation_total_count, null)
        metric_name              = each.value.dynamic_criteria.metric_name
        metric_namespace         = local.metric_namespace
        operator                 = each.value.dynamic_criteria.operator
      },
      null
    )
    enabled             = each.value.enabled
    frequency           = each.value.frequency
    name                = "${each.value.name} - ${azurerm_function_app.function_app.name}"
    resource_group_name = var.resource_group_name
    scopes = [
      azurerm_function_app.function_app.id
    ]
    severity = each.value.severity
    static_criteria = try(
      {
        aggregation      = each.value.static_criteria.aggregation
        metric_name      = each.value.static_criteria.metric_name
        metric_namespace = local.metric_namespace
        operator         = each.value.static_criteria.operator
        threshold        = each.value.static_criteria.threshold
      },
      null
    )
    tags        = var.tags
    window_size = try(each.value.window_size, null)
  }
}
