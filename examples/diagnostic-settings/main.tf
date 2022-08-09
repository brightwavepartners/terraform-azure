data "azurerm_client_config" "current" {}

# global naming conventions and resources
module "globals" {
  source = "../../modules/globals"

  application = local.application
  environment = local.environment
  location    = local.location
  tenant      = local.tenant
}

# resource group
module "resource_group" {
  source = "../../modules/resource_group"

  application = local.application
  environment = local.environment
  location    = local.location
  tags        = local.tags
  tenant      = local.tenant
}

# log analytics workspace
module "log_analytics_workspace" {
  source = "../../modules/log_analytics_workspace"

  application         = local.application
  environment         = local.environment
  location            = local.location
  resource_group_name = module.resource_group.name
  retention_period    = local.log_analytics_workspace.retention_period
  sku                 = local.log_analytics_workspace.sku
  tenant              = local.tenant
  tags                = local.tags
}

# app service plan
module "app_service_plan" {
  source = "../../modules/app_service_plan"

  application         = local.application
  environment         = local.environment
  kind                = local.app_service_plan.kind
  location            = local.location
  resource_group_name = module.resource_group.name
  role                = local.app_service_plan.role
  size                = local.app_service_plan.size
  tier                = local.app_service_plan.tier
  tags                = local.tags
  tenant              = local.tenant
}

# app service
module "app_service" {
  source = "../../modules/app_service"

  app_service_plan_id        = module.app_service_plan.id
  application                = local.application
  environment                = local.environment
  location                   = local.location
  log_analytics_workspace_id = module.log_analytics_workspace.id
  resource_group_name        = module.resource_group.name
  role                       = "appone"
  tags                       = local.tags
  tenant                     = local.tenant
}

# # # application insights
# # resource "azurerm_application_insights" "application_insights" {
# #   application_type    = "web"
# #   location            = azurerm_resource_group.resource_group.location
# #   name                = lower("${local.resource_base_name_long}-${local.application}-ai")
# #   resource_group_name = azurerm_resource_group.resource_group.name
# #   workspace_id        = azurerm_log_analytics_workspace.log_analytics.id
# # }

# # # application insights api key for app service diagnostics
# # resource "azurerm_application_insights_api_key" "read_telemetry" {
# #   name                    = "APPSERVICEDIAGNOSTICS_READONLYKEY_${local.resource_base_name_long}-${local.application}-as"
# #   application_insights_id = azurerm_application_insights.application_insights.id
# #   read_permissions        = ["agentconfig", "aggregate", "api", "draft", "extendqueries", "search"]
# # }

# # # get token for current user so we can use the token in the rest call to the azure encryption engine
# # resource "null_resource" "application_insights_app_service_diagnostics" {
# #   provisioner "local-exec" {
# #     command = <<EOT
# #             az account set --subscription ${data.azurerm_client_config.current.subscription_id}

# #             $token = Get-AzAccessToken
# #             $token.Token | Out-File '${path.module}/token.txt'
# #         EOT

# #     interpreter = [
# #       "PowerShell",
# #       "-Command"
# #     ]
# #   }
# # }

# # # save the token so it can be used later
# # data "local_file" "token" {
# #   filename = "${path.module}/token.txt"

# #   depends_on = [
# #     null_resource.application_insights_app_service_diagnostics
# #   ]
# # }

# # # encrypt the api key
# # data "http" "encrypted_ai_api_key" {
# #   url = "https://appservice-diagnostics.azurefd.net/api/appinsights/encryptkey"

# #   request_headers = {
# #     Authorization   = "Bearer ${data.local_file.token.content_base64}"
# #     Accept          = "application/json"
# #     appinsights-key = "${azurerm_application_insights_api_key.read_telemetry.api_key}"
# #   }
# # }

# # resource "null_resource" "debug_output" {
# #   provisioner "local-exec" {
# #     command = <<EOT
# #             ${azurerm_application_insights.application_insights.app_id} | Out-File '${path.module}/ai_appid.txt'
# #             ${azurerm_application_insights_api_key.read_telemetry.api_key} | Out-File '${path.module}/unencrypted_apikey.txt'
# #             ${data.http.encrypted_ai_api_key.body} | Out-File '${path.module}/encrypted_apikey.txt'
# #         EOT

# #     interpreter = [
# #       "PowerShell",
# #       "-Command"
# #     ]
# #   }
# # }

# # # app service plan
# # resource "azurerm_app_service_plan" "app_service_plan" {
# #   kind                = "Windows"
# #   location            = azurerm_resource_group.resource_group.location
# #   name                = "${lower(local.resource_base_name_long)}-plan0-asp"
# #   resource_group_name = azurerm_resource_group.resource_group.name

# #   sku {
# #     size = "S3"
# #     tier = "Standard"
# #   }
# # }

# # # app service
# # resource "azurerm_app_service" "app_service" {
# #   name                = lower("${local.resource_base_name_long}-${local.application}-as")
# #   location            = azurerm_resource_group.resource_group.location
# #   resource_group_name = azurerm_resource_group.resource_group.name
# #   app_service_plan_id = azurerm_app_service_plan.app_service_plan.id

# #   app_settings = {
# #     "APPINSIGHTS_INSTRUMENTATIONKEY"             = azurerm_application_insights.application_insights.instrumentation_key
# #     "APPLICATIONINSIGHTS_CONNECTION_STRING"      = "InstrumentationKey=${azurerm_application_insights.application_insights.instrumentation_key};IngestionEndpoint=https://${local.location}-0.in.applicationinsights.azure.com/"
# #     "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
# #     "XDT_MicrosoftApplicationInsights_Mode"      = "Recommended"
# #   }

# #   logs {
# #     detailed_error_messages_enabled = true
# #     failed_request_tracing_enabled  = true
# #     http_logs {
# #       file_system {
# #         retention_in_days = 30
# #         retention_in_mb   = 35
# #       }
# #     }
# #   }

# #   tags = {
# #     "hidden-related:diagnostics/applicationInsightsSettings" = "{\"ApiKey\":${data.http.encrypted_ai_api_key.body},\"AppId\":\"${azurerm_application_insights.application_insights.app_id}\"}"
# #   }
# # }

# # # diagnostics
# # resource "azurerm_monitor_diagnostic_setting" "diagnostic_setting" {
# #   log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics.id
# #   name                       = "AllLogs and AllMetrics to Log Analytics"
# #   target_resource_id         = azurerm_app_service.app_service.id

# #   log {
# #     category = "AppServiceHTTPLogs"
# #     enabled  = true

# #     retention_policy {
# #       enabled = true
# #       days    = 90
# #     }
# #   }

# #   log {
# #     category = "AppServiceConsoleLogs"
# #     enabled  = true

# #     retention_policy {
# #       enabled = true
# #       days    = 90
# #     }
# #   }

# #   log {
# #     category = "AppServiceAppLogs"
# #     enabled  = true

# #     retention_policy {
# #       enabled = true
# #       days    = 90
# #     }
# #   }

# #   log {
# #     category = "AppServiceIPSecAuditLogs"
# #     enabled  = true

# #     retention_policy {
# #       enabled = true
# #       days    = 90
# #     }
# #   }

# #   log {
# #     category = "AppServicePlatformLogs"
# #     enabled  = true

# #     retention_policy {
# #       enabled = true
# #       days    = 90
# #     }
# #   }

# #   log {
# #     category = "AppServiceAuditLogs"
# #     enabled  = true

# #     retention_policy {
# #       enabled = true
# #       days    = 90
# #     }
# #   }

# #   metric {
# #     category = "AllMetrics"
# #     enabled  = true

# #     retention_policy {
# #       enabled = true
# #       days    = 90
# #     }
# #   }
# # }
