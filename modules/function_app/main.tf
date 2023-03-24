terraform {
  experiments = [module_variable_optional_attrs]
}

locals {
  # default app settings are those that are always the same for every function app created
  default_app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = azurerm_application_insights.application_insights.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = "InstrumentationKey=${azurerm_application_insights.application_insights.instrumentation_key};IngestionEndpoint=https://${var.location}-0.in.applicationinsights.azure.com/"
    "FUNCTIONS_WORKER_RUNTIME"              = var.worker_runtime_type
    "WEBSITE_CONTENTOVERVNET"               = var.storage == null ? 0 : var.storage.vnet_integration.enabled ? 1 : 0
  }

  function_app_file_share_application_setting_key = "WEBSITE_CONTENTSHARE"

  metric_namespace = "Microsoft.Web/sites"

  # the runtime version is being hardcoded in this module because there are some features
  # being used by this code that are only available in versions >= ~4. if the client code
  # is allowed to set this version, it may end up being a lower version that doesn't support
  # the features needed and things won't work.
  runtime_version = "~4"

  vnet_integrated_function_route_all_enabled = try(var.vnet_integration.vnet_route_all_enabled, null)
  vnet_integrated_function_subnet_id         = try(var.vnet_integration.subnet_id, null)
  vnet_integrated_storage_allowed_ips        = try(var.storage.vnet_integration.allowed_ips, null)
  vnet_integrated_storage_enabled            = try(var.storage.vnet_integration.enabled, false)
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

# TODO: the discussion below about WEBSITE_CONTENTSHARE applies only to
# consumption and premium plans. dedicated plans (e.g. P1v2) would not
# automatically create the WEBSITE_CONTENTSHARE setting. in that case,
# the data resource below to find the existing value for WEBSITE_CONTENTSHARE
# will fail because that setting is not required for a dedicated plan.
# need to fix this to account for that since this code will fail if a
# dedicated plan is configured for the function app.

# during normal function app provisioning, a file share is automatically
# created in the storage account that is associated with the function app
# to hold the function app's code files. the name of that file share
# is automatically generated during provisioning and that automatically
# generated name will be added to the function app's application settings
# as the value of the WEBSITE_CONTENTSHARE setting. that is how the connection
# is made between the function app and its associated storage account.
#
# now, if the storage account associated with the function app is vnet
# integrated, the file share name will still get automatically generated
# and added to the function app's application settings, but the file share
# will not get provisioned automatically in the storage account (presumably
# due to access restrictions caused by vnet integration) thus causing the
# function app to fail to function properly since it cannot access its own
# code files from a file share that never got provisioned.
#
# since the file share name was already automatically generated and added
# to the function app's application settings, we can fix the missing file
# share issue by using a data source to get name of the file share that
# was added to the application settings and then creating the missing
# file share in the storage account using the name that was already
# automatically generated and added to the application settings.

# data source to get all the function app's application settings
# -- only need this if storage account is vnet integrated
data "azurerm_function_app" "function_app" {
  count = local.vnet_integrated_storage_enabled ? 1 : 0

  name                = azurerm_function_app.function_app.name
  resource_group_name = azurerm_function_app.function_app.resource_group_name
}

# storage account file share for function app application files
# using the already generated name that we retrieved with the
# data source above
# -- only need this if storage account is vnet integrated
resource "azurerm_storage_share" "application_files_storage_share" {
  count = local.vnet_integrated_storage_enabled ? 1 : 0

  name                 = data.azurerm_function_app.function_app[0].app_settings[local.function_app_file_share_application_setting_key]
  storage_account_name = module.storage_account.name
  quota                = 50
}

# vnet integration for function app
# -- only need this if function app is vnet integrated
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
