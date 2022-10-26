# Overview

This module will provision an App Service and optionally configure the following additional resources:

- **Application Insights** - An Application Insights instance will be created and connected to the App Service
if configured to do so. The Application Insights instance will also be connected to App Service diagnostics if
configured to do so.

## Variables

- **alert_settings** (optional) - defines how to configure proactive [notifications](https://docs.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-overview) when Azure Monitor data indicates that there may be a problem with the App Service. Defaults to no alerts.
- **always_on** (optional) - whether or not to keep the App Service loaded at all times. Defaults to `false`.
- **app_service_plan_id** (required) - The ID of the App Service Plan within which to create this App Service.
- **app_settings** (optional) - A key-value pair of [settings](https://docs.microsoft.com/en-us/azure/app-service/configure-common?tabs=portal) applied to the App Service. If provided, the settings will be combined with the following set of default app settings that are automatically applied to every App Service:
- **application** (required) - The name of the application. Used to automatically name the App Service using the [default naming convention](../../docs/azure_naming_conventions.md) if no name is provided.

## Dependencies

This module depends on the following modules:

- [globals](https://github.com/brightwavepartners/terraform-azure/tree/main/modules/globals)

This module also depends on environment variables. Because there are possible Powershell commands issued against Azure, user credentials are required for those commands.
To keep such credentials secure and personal to each executor of this script, they are defined in environment variables. The alternative would be to put the values
directly in the code, but that is obviously insecure. The following environment variables are expected to be defined:

1. ARM_CLIENT_ID - Azure Active Directory application (client) identifier for a service principal with appropriate permissions
2. ARM_CLIENT_SECRET - Client secret (password) from the ARM_CLIENT_ID
3. ARM_TENANT_ID - The identifier for the tenant that this script is running against

## Requirements

The following third-party tools and utilities are used by this module:

- Powershell v6+
    - Powershell module Az.Accounts