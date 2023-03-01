# Overview
This module builds a [Function App](https://learn.microsoft.com/en-us/azure/azure-functions/functions-overview), and its [associated storage account](https://learn.microsoft.com/en-us/azure/azure-functions/storage-considerations?tabs=azure-cli), and supports the following features:

- [Alert settings](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-overview)
- [Application Insights](https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview?tabs=net)
- [Diagnostic settings](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings?tabs=portal)
- [Virtual Network Integration](https://learn.microsoft.com/en-us/azure/azure-functions/functions-networking-options?tabs=azure-cli#virtual-network-integration)

## Variables
`alert settings` - [list(object): Optional] Specifies a list of alert settings that can be applied to the Function App. Each alert setting in the list consists of the following properties. Defaults to an empty list, which means no alerts will be configured.

- `action` - [object: Required] Specifies the action semantics when an alert is triggered
    - `action_group_id` - [string: Required]
- `description` - [string: Required] Describes the alert
- `dynamic_criteria` - [object: Optional] Specifies a [dynamic threshold alert](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-dynamic-thresholds)
    - [aggregation](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/metrics-aggregation-explained) - [string: Required]
    - [alert_sensitivity](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-create-new-alert-rule?tabs=metric) - [string: Required]
    - `evaluation_failure_count` - [number: Optional] The number of violations to trigger an alert
    - `evaluation_total_count` - [number: Optional] The number of aggregated lookback points
    - `metric_name` - [string: Required] One of the metric names to be monitored
    - `operator` - [string: Required] The criteria operator
- `enabled` - [bool: Required] Specifies whether the alert shall be enabled
- `frequency` - [string: Optional] The evaluation frequency of this alert
- `name` - [string: Required] The name of the alert
- `severity` - [number: Required]
- `static_criteria` - [object: Optional] Specifies a static threshold alert
    - [aggregation](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/metrics-aggregation-explained) - [string: Required]
    - `metric_name` - [string: Required] The name of the metric to be monitored
    - `operator` - [string: Required] The criteria operator
    - `threshold` - [number: Required] The threshold at which the alert will be activated
- `window_size` - [string: Optional] The period of time that is used to moniro alert activity

`always_on` - [bool: Optional] Specifies whether the Function App shall stay loaded at all times. Defaults to false.

`app_service_plan_id` - [string: Required] The Azure identifier for the App Service Plan that will host the Function App.

`app_settings` - [map(string): Optional] A map of key-value pairs for App Settings. Defaults to an empty map, which means no App Settings will be configured.

`application` - [string: Required] The name of the overall application that the Function App is a part of.

`environment` - [string: Required] The name of the environment (e.g. production) that the Function App is being provisioned for.

`cors_settings` - [object: Optional] Specifies settings to allow cross-origin calls to the Function App. Defaults to no CORS settings being configured.

`diagnostics_settings` - [list(object): Optional] Specifies a list of diagnostic settings that can be applied to the Function App. Each diagnostic setting in the list consists of the following properties. Defaults to an empty list, which means no diagnostics will be configured.

- `name` - [string: Required] The name of the diagnostic setting.
- `destination` - [object: Required] Specifies the destination sink where diagnostic data will be sent. **NOTE** at this time, only Log Analytics Workspace is supported and if not configured, diagnostic data will not be sent anywhere.
    - `log_analytics_workspace` - [object: Optional] The details for a Log Analytics Workspace to which diagnostic data can be sent. If this is not configured, diagnostic data will not be sent anywhere.
        - `destination_type` - [string: Optional] Possible values are **AzureDiagnostics** and **Dedicated**, default to AzureDiagnostics. When set to Dedicated, logs sent to a Log Analytics workspace will go into resource specific tables, instead of the legacy AzureDiagnostics table.
        - `id` - [string: Required] The Azure identifier for a Log Analytics Workspace to send diagnostics logs to.
- `logs` - [list(object): Optional] Specifies how to configure specific log categories (e.g. Function Application Logs).
    - category - [string: Required] The log category to be configured.
    - enabled - [bool: Required] Whether or not the log category is enabled or not
    - retention - [object: Optional] Defines a policy to enforce a specified retention setting
        - days - [number: Required] The number of days for which this Retention Policy should apply.
        - enabled - [bool: Required] Whether or not the retention policy is enabled.
- `metrics` - [list(object): Optional] Specifies how to configure specific metric categories (e.g. AllMetrics).
    - category - [string: Required] The metric category to be configured.
    - enabled - [bool: Required] Whether or not the metric category is enabled or not
    - retention - [object: Optional] Defines a policy to enforce a specified retention setting
        - days - [number: Required] The number of days for which this Retention Policy should apply.
        - enabled - [bool: Required] Whether or not the retention policy is enabled.

`dotnet_framework_version` - [string: Optional] Specifies the .NET framework CLR version the Function App is dependant upon. Possible values are v4.0 (including .NET Core 2.1 and 3.1), v5.0 and v6.0. Defaults to v4.0.

`functions_runtime_version` - [string: Required] The [function runtime version](https://docs.microsoft.com/en-us/azure/azure-functions/functions-app-settings#functions_extension_version) associated with the Function App.

`ip_restrictions` - [list(object): Optional] A list of IP restrictions for inbound access to the Function App. Defaults to an empty list which would configure no IP restrictions.
- `action` - [string: Optional] 'Allow' or 'Deny' access for this IP range. Defaults to 'Allow'.
- `description` - [string: Required] A statement describing the restriction.
- `headers` - [list(object): Optional] The headers for the given restriction.
    - `front_door_ids` - [list(string): Required] A list of allowed Azure FrontDoor IDs in UUID notation with a maximum of 8.
    - `front_door_health_probe` - [list(string): Required] A list to allow the Azure FrontDoor health probe header. Only allowed value is "1".
    - `forwarded_for` - [list(string): Required] A list of allowed 'X-Forwarded-For' IPs in CIDR notation with a maximum of 8.
    - `forwarded_host` - [list(string): Required] A list of allowed 'X-Forwarded-Host' domains with a maximum of 8.

- `ip_address` - [string: Optional] The IP Address used for this IP Restriction in CIDR notation.
- `name` - [string: Optional] The name for the IP restriction.
- `priority` - [number: Optional] The priority for this IP Restriction. Restrictions are enforced in priority order. By default, the priority is set to 65000 if not specified.
- `service_tag` - [string: Optional] The Service Tag used for this IP Restriction.
- `virtual_network_subnet_id` - [string: Optional] The Virtual Network Subnet ID used for this IP Restriction.

`log_analytics_workspace_id` - [string: Optional] The Azure resource identifier for a Log Analytics Workspace that the Application Insight instance created for the Function App will be attached to.

`location` - [string: Required] The Azure region the Function App will be provisioned in.

`minimum_instance_count` - [number: Optional] The minimum number of instances. Only affects apps on the Premium plan. Defaults to 1.

`resource_group_name` - [string: Optional] The resource group in which the Function App will be provisioned.

`role` - [string: Required] Defines a role name for the Function App so it can be referred to by this name when attaching to an App Service Plan.

`storage` - [object: Optional] Determines how to configure the storage account backing the Function App. Defaults to an automatically provisioned storage account with default storage properties.
- `alert_settings` - [list(object): Optional] Specifies a list of alert settings that can be applied to the Function App. Each alert setting in the list consists of the following properties. Defaults to an empty list, which means no alerts will be configured.

    - `action` - [object: Required] Specifies the action semantics when an alert is triggered
        - `action_group_id` - [string: Required]
    - `description` - [string: Required] Describes the alert
    - `dynamic_criteria` - [object: Optional] Specifies a [dynamic threshold alert](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-dynamic-thresholds)
        - [aggregation](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/metrics-aggregation-explained) - [string: Required]
        - [alert_sensitivity](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-create-new-alert-rule?tabs=metric) - [string: Required]
        - `evaluation_failure_count` - [number: Optional] The number of violations to trigger an alert
        - `evaluation_total_count` - [number: Optional] The number of aggregated lookback points
        - `metric_name` - [string: Required] One of the metric names to be monitored
        - `operator` - [string: Required] The criteria operator
    - `enabled` - [bool: Required] Specifies whether the alert shall be enabled
    - `frequency` - [string: Optional] The evaluation frequency of this alert
    - `name` - [string: Required] The name of the alert
    - `severity` - [number: Required]
    - `static_criteria` - [object: Optional] Specifies a static threshold alert
        - [aggregation](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/metrics-aggregation-explained) - [string: Required]
        - `metric_name` - [string: Required] The name of the metric to be monitored
        - `operator` - [string: Required] The criteria operator
        - `threshold` - [number: Required] The threshold at which the alert will be activated
    - `window_size` - [string: Optional] The period of time that is used to moniro alert activity
- `vnet_integration` - [object: Required] Specifies whether the storage account should be integrated into a virtual network and any settings associated with that virtual network integration.
    - `allowed_ips` - [list(string): Optional] A list of IP addresses that will be allowed access to the storage account if the account is integrated into a virtual network.
    - `enabled` - [bool: Required] Whether or not the storage account should be integrated into the same virtual network that the Function App is integrated into.

`tags` - [map(string): Optional] A list of key-value pairs used to add descriptive identifiers to the Function App used to help organize the resource. Defaults to no tags.

`tenant` - [string: Required] The name of the entity for which the Function App is being provisioned. This is not necessarily the Azure tenant, but rather just a unique identifier to distiguish ownership of the Function App when multiple owner's may exist under a single Azure tenant (e.g. client multi-tenant support of Azure resources under a single business Azure tenant).

`use_32_bit_worker_process` - [bool: Optional] Whether or not to use a 32-bit worker process for the Function App. Defaults to false, which will force a 64-bit worker process.

`vnet_integration` - [object: Optional] - Defines if and how to integrate the Function App into a virtual network. Defaults to no virtual network integration.
- `subnet_id` - [string: Required] The Azure identifier for a subnet provisioned within a virtual network.
- `vnet_route_all_enabled` - [bool: Required] Whether or not all outbound traffic is to have Virtual Network Security Groups and User Defined Routes applied.

`worker_runtime_type` - [string: Required] The [language worker runtime](https://docs.microsoft.com/en-us/azure/azure-functions/functions-app-settings#functions_worker_runtime) to load in the function app. This corresponds to the language being used in your application. For example, dotnet.