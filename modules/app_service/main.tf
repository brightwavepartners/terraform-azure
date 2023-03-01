terraform {
  experiments = [module_variable_optional_attrs]
}

locals {
  # if the client code supplies a name, use it. otherwise, name the resource using the default naming convention.
  app_service_name = coalesce(var.name, lower("${module.globals.resource_base_name_long}-${var.role}-${module.globals.object_type_names.app_service}"))

  # if application insights is enabled, add app settings to connect to app service
  app_settings_application_insights = var.application_insights.enabled ? {
    "ApplicationInsightsAgent_EXTENSION_VERSION" = var.app_service_plan_info.os_type == "Linux" ? "~3" : "~2"
    "APPINSIGHTS_INSTRUMENTATIONKEY"             = azurerm_application_insights.application_insights[0].instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING"      = "InstrumentationKey=${azurerm_application_insights.application_insights[0].instrumentation_key}"
  } : {}

  # if application insights is enabled and integration with app diagnostics is also enabled, add app insights api key to app settings to connect app insights with app diagnostics
  app_settings_application_insights_integrate_with_app_diagnostics = var.application_insights.enabled && var.application_insights.integrate_with_app_diagnostics ? {
    "WEBSITE_APPINSIGHTS_ENCRYPTEDAPIKEY" = "{\"ApiKey\":${module.app_insights_api_key[0].encrypted_api_key},\"AppId\":\"${azurerm_application_insights.application_insights[0].app_id}\"}"
  } : {}

  # if webjobs storage is enabled, add app settings to connect the app service to the storage account
  app_settings_webjobs_storage = var.webjobs_storage != null ? {
    "AzureWebJobsDashboard" = module.webjobs_storage[0].primary_connection_string
    "AzureWebJobsStorage"   = module.webjobs_storage[0].primary_connection_string
  } : {}

  # enforce name length restriction and show an error if name is longer than maximum allowed for app services.
  assert_app_service_name_length = length(local.app_service_name) > module.globals.resource_name_max_length.app_service ? file("ERROR: App Service name ${local.app_service_name} exceeds maximum length of ${module.globals.resource_name_max_length.app_service}") : null

  # the microsoft given namespace for app service metrics, used in diagnostics settings
  metric_namespace = "Microsoft.Web/sites"

  vnet_integrated_app_service_route_all_enabled = try(var.vnet_integration.vnet_route_all_enabled, null)
  vnet_integrated_app_service_subnet_id         = try(var.vnet_integration.subnet_id, null)
  vnet_integrated_storage_allowed_ips           = try(var.webjobs_storage.vnet_integration.allowed_ips, null)
  vnet_integrated_storage_enabled               = try(var.webjobs_storage.vnet_integration.enabled, false)
}

# get information about the current azure session
data "azurerm_client_config" "current" {}

# global naming conventions and resources
module "globals" {
  source = "../globals"

  application = var.application
  environment = var.environment
  location    = var.location
  tenant      = var.tenant
}

# create an application insights instance that will be connected to the app service
resource "azurerm_application_insights" "application_insights" {
  count = var.application_insights.enabled ? 1 : 0

  application_type    = "web"
  location            = var.location
  name                = lower("${module.globals.resource_base_name_long}-${var.role}-${module.globals.object_type_names.application_insights}")
  resource_group_name = var.resource_group_name
  tags                = var.tags
  workspace_id        = var.application_insights.workspace_id
}

# app insights api key
module "app_insights_api_key" {
  source = "../application_insights_api_key"

  count = var.application_insights.enabled ? 1 : 0

  application_insights_id = azurerm_application_insights.application_insights[0].id
  name                    = "APPSERVICEDIAGNOSTICS_READONLYKEY_${local.app_service_name}"
  read_permissions = [
    "agentconfig",
    "aggregate",
    "api",
    "draft",
    "extendqueries",
    "search"
  ]
}

# webjob storage account
# -- only needed if webjobs storage account provisioning is enabled
module "webjobs_storage" {
  source = "../storage_account"

  count = var.webjobs_storage != null ? 1 : 0

  account_replication_type = "LRS"
  account_tier             = "Standard"
  application              = var.application
  alert_settings           = try(var.webjobs_storage.alert_settings, [])
  allowed_ips              = local.vnet_integrated_storage_allowed_ips
  environment              = var.environment
  location                 = var.location
  role                     = var.role
  resource_group_name      = var.resource_group_name
  subnet_ids               = var.webjobs_storage == null ? null : var.webjobs_storage.vnet_integration.enabled ? [var.vnet_integration.subnet_id] : null
  tags                     = var.tags
  tenant                   = var.tenant
}

# app service
resource "azurerm_app_service" "app_service" {
  app_service_plan_id = var.app_service_plan_info.id
  https_only          = true
  location            = var.location
  name                = local.app_service_name
  resource_group_name = var.resource_group_name
  tags                = var.tags

  # combine all the pre-defined app settings (based on variable configurations)
  # with any that are passed in to end up with one set of app settings for the app service
  app_settings = merge(
    local.app_settings_application_insights,
    local.app_settings_application_insights_integrate_with_app_diagnostics,
    local.app_settings_webjobs_storage,
    var.app_settings
  )

  identity {
    type = "SystemAssigned"
  }

  logs {
    detailed_error_messages_enabled = true
    failed_request_tracing_enabled  = true
    http_logs {
      file_system {
        retention_in_days = 30
        retention_in_mb   = 35
      }
    }
  }

  site_config {
    always_on = var.always_on
    cors {
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
      support_credentials = try(var.cors_settings.support_credentials, false)
    }

    default_documents = [
      "Default.htm",
      "Default.html",
      "Default.asp",
      "index.htm",
      "index.html",
      "iisstart.htm",
      "default.aspx",
      "index.php",
      "hostingstart.html"
    ]

    dotnet_framework_version = var.dotnet_framework_version
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
    vnet_route_all_enabled    = local.vnet_integrated_app_service_route_all_enabled
  }

  # TODO: this shouldn't be here in an enterprise module, but don't have a way to set this from outside since the lifecycle
  # meta-argument only allows literal values (https://www.terraform.io/language/meta-arguments/lifecycle#literal-values-only).auth_settings)
  # there is a github issue to support dynamic blocks in met-arguments here https://github.com/hashicorp/terraform/issues/24188,
  # but it seems unlikely this will be addressed.  a workaround might be to place a token identifier here and have
  # a separate process, perhaps in a ci/cd pipeline, replace the token identifier with the dynamic content before the code
  # is actually executed. but that requires an external process to "transform" this section. you would no longer be running
  # the terraform commands directly (e.g. terraform plan), but instead would always run the separate process which would run the
  # terraform command internally after transformation.
  lifecycle {
    ignore_changes = [
      app_settings["AzureWebJobsDashboard"],
      app_settings["AzureWebJobsStorage"],
      app_settings["IsDisabled"],
      app_settings["ServiceBusConnection"]
    ]
  }
}

# vnet integration for app service
# -- only need this if app service is vnet integrated
resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration" {
  count = var.vnet_integration != null ? 1 : 0

  app_service_id = azurerm_app_service.app_service.id
  subnet_id      = local.vnet_integrated_app_service_subnet_id

  timeouts {
    create = "1h"
  }
}

# diagnostics settings
module "diagnostic_settings" {
  source = "../diagnostics_settings"

  settings           = var.diagnostics_settings
  target_resource_id = azurerm_app_service.app_service.id
}

# alerts
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
    name                = "${each.value.name} - ${azurerm_app_service.app_service.name}"
    resource_group_name = var.resource_group_name
    scopes = [
      azurerm_app_service.app_service.id
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
