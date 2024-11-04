# TODO: the discussion below about WEBSITE_CONTENTSHARE applies only to
# consumption and premium plans. dedicated plans (e.g. P1v2) would not
# automatically create the WEBSITE_CONTENTSHARE setting. need to fix this
# since this code will fail if a dedicated plan is configured for the function app.

locals {
  # this is the final value for the function app settings after combining default
  # app settings, app settings passed in by the user, and then adding the app setting
  # for the storage account file share name IF the user wants to integrate the storage
  # account into the same virtual network that the function app is in to provide a private
  # connection. if there is no vnet integration of the function app and storage account,
  # the storage account file share name will be automatically set by the azurerm provider
  # when the function app is provisioned.
  app_settings = local.vnet_integrated_storage_enabled ? merge(
    local.default_app_settings_plus_variable_app_settings,
    {
      "${local.function_app_file_share_application_setting_key}"          = local.name
      "${local.function_app_storage_account_vnet_integrated_setting_key}" = 1
    }
  ) : local.default_app_settings_plus_variable_app_settings

  # default app settings are those that are always the same for every function app created
  default_app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = azurerm_application_insights.application_insights.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = "InstrumentationKey=${azurerm_application_insights.application_insights.instrumentation_key};IngestionEndpoint=https://${var.location}-0.in.applicationinsights.azure.com/"
  }

  # this is the merging of the default app settings noted above, plus any additional
  # app settings that the user has passed in to the module
  default_app_settings_plus_variable_app_settings = merge(
    local.default_app_settings,
    var.app_settings
  )

  # if the number of days to retain a soft deleted file share is not specified, this is the default value
  file_share_retention_days_default = 7

  function_app_file_share_application_setting_key          = "WEBSITE_CONTENTSHARE"
  function_app_storage_account_vnet_integrated_setting_key = "WEBSITE_CONTENTOVERVNET"

  metric_namespace = "Microsoft.Web/sites"

  name = var.name != null ? var.name : lower(
    join(
      "-",
      [
        module.globals.resource_base_name_long,
        var.role,
        module.globals.object_type_names.function_app
      ]
    )
  )

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

# storage account file share for function app application files
# -- only need this if storage account is vnet integrated
module "function_file_share" {
  source = "../storage_account_file_share"

  count = local.vnet_integrated_storage_enabled ? 1 : 0

  application          = var.application
  environment          = var.environment
  file_share_name      = local.name
  location             = var.location
  maximum_size         = 50
  resource_group_name  = var.resource_group_name
  retention_days       = try(
    var.storage.maximum_size,
    local.file_share_retention_days_default
  )
  role                 = var.role
  storage_account_name = module.storage_account.name
  tenant               = var.tenant

  depends_on = [
    module.storage_account
  ]
}

# azure function
resource "azurerm_windows_function_app" "function_app" {
  app_settings               = local.app_settings
  https_only                 = true
  location                   = var.location
  name                       = local.name
  resource_group_name        = var.resource_group_name
  service_plan_id            = var.service_plan_id
  storage_account_access_key = module.storage_account.primary_access_key
  storage_account_name       = module.storage_account.name
  tags                       = var.tags

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on = var.always_on

    application_stack {
      dotnet_version              = var.application_stack.dotnet_version
      use_dotnet_isolated_runtime = var.application_stack.use_dotnet_isolated_runtime
    }

    dynamic "cors" {
      for_each = var.cors_settings == null ? [] : [1]

      content {
        allowed_origins = try([
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
        ], [])
        support_credentials = var.cors_settings.support_credentials
      }
    }

    elastic_instance_minimum = var.minimum_instance_count
    ftps_state               = "FtpsOnly"

    dynamic "ip_restriction" {
      for_each = var.ip_restrictions

      content {
        action                    = ip_restriction.action
        headers                   = [] # TODO: according the documentation, this value should be optional but apparently is not. there is an issue here https://github.com/hashicorp/terraform-provider-azurerm/issues/12367. Need to figure out how to work around the issue without hard-coding.
        ip_address                = ip_restriction.ip_address
        name                      = ip_restriction.name
        priority                  = ip_restriction.priority
        service_tag               = ip_restriction.service_tag
        virtual_network_subnet_id = ip_restriction.virtual_network_subnet_id
      }
    }

    use_32_bit_worker      = var.use_32_bit_worker
    vnet_route_all_enabled = local.vnet_integrated_function_route_all_enabled
  }
}

# vnet integration for function app
# -- only need this if function app is vnet integrated
resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration" {
  count = var.vnet_integration != null ? 1 : 0

  app_service_id = azurerm_windows_function_app.function_app.id
  subnet_id      = local.vnet_integrated_function_subnet_id

  timeouts {
    create = "1h"
  }
}

# diagnostics settings
module "diagnostics_settings" {
  source = "../diagnostics_settings"

  settings           = var.diagnostics_settings
  target_resource_id = azurerm_windows_function_app.function_app.id
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
    name                = "${each.value.name} - ${azurerm_windows_function_app.function_app.name}"
    resource_group_name = var.resource_group_name
    scopes = [
      azurerm_windows_function_app.function_app.id
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
