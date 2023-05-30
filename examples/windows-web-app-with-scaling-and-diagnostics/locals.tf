locals {
  application = "scalediag"
  environment = "sbx"
  location    = "northcentralus"
  log_analytics_workspace = {
    retention_period = 30
    sku              = "PerGB2018"
  }
  service_plan = {
    os_type = "Windows"
    role    = "apps1"
    scale_settings = [
      {
        diagnostics_settings = [],
        enabled = true,
        name    = "apps1-asp-setting1",
        notification = {
          email = {
            recipients                            = [],
            send_to_subscription_administrator    = false,
            send_to_subscription_co_administrator = false
          }
        },
        profiles = [
          {
            name = "defaultProfile",
            capacity = {
              default = 1,
              minimum = 1,
              maximum = 3
            },
            rules = [
              {
                name             = "CpuPercentage",
                operator         = "GreaterThan",
                statistic        = "Average",
                threshold        = 75,
                time_aggregation = "Average",
                time_grain       = "PT1M",
                time_window      = "PT5M",
                action = {
                  cooldown  = "PT1M",
                  direction = "Increase",
                  type      = "ChangeCount",
                  value     = 1
                }
              },
              {
                name             = "CpuPercentage",
                operator         = "LessThan",
                statistic        = "Average",
                threshold        = 40,
                time_aggregation = "Average",
                time_grain       = "PT1M",
                time_window      = "PT5M",
                action = {
                  cooldown  = "PT1M",
                  direction = "Decrease",
                  type      = "ChangeCount",
                  value     = 1
                }
              },
              {
                name             = "MemoryPercentage",
                operator         = "GreaterThan",
                statistic        = "Average",
                threshold        = 75,
                time_aggregation = "Average",
                time_grain       = "PT1M",
                time_window      = "PT5M",
                action = {
                  cooldown  = "PT1M",
                  direction = "Increase",
                  type      = "ChangeCount",
                  value     = 1
                }
              },
              {
                name             = "MemoryPercentage",
                operator         = "LessThan",
                statistic        = "Average",
                threshold        = 40,
                time_aggregation = "Average",
                time_grain       = "PT1M",
                time_window      = "PT5M",
                action = {
                  cooldown  = "PT1M",
                  direction = "Decrease",
                  type      = "ChangeCount",
                  value     = 1
                }
              }
            ]
          }
        ]
      }
    ],
    sku_name = "P1v3"
  }
  tags   = {}
  tenant = var.tenant
  windows_web_app = {
    diagnostics_settings = [
      {
        name = "All logs and metrics to Log Analytics",
        destination = {
          log_analytics_workspace = {
            id = module.log_analytics_workspace.id
          }
        }
        logs = [
          {
            category = "AppServiceAntivirusScanAuditLogs",
            enabled  = true,
            retention = {
              days    = 0,
              enabled = false
            }
          },
          {
            category = "AppServiceHTTPLogs",
            enabled  = true,
            retention = {
              days    = 0,
              enabled = false
            }
          },
          {
            category = "AppServiceConsoleLogs",
            enabled  = true,
            retention = {
              days    = 0,
              enabled = false
            }
          },
          {
            category = "AppServiceAppLogs",
            enabled  = true,
            retention = {
              days    = 0,
              enabled = false
            }
          },
          {
            category = "AppServiceFileAuditLogs",
            enabled  = true,
            retention = {
              days    = 0,
              enabled = false
            }
          },
          {
            category = "AppServiceAuditLogs",
            enabled  = true,
            retention = {
              days    = 0,
              enabled = false
            }
          },
          {
            category = "AppServiceIPSecAuditLogs",
            enabled  = true,
            retention = {
              days    = 0,
              enabled = false
            }
          },
          {
            category = "AppServicePlatformLogs",
            enabled  = true,
            retention = {
              days    = 0,
              enabled = false
            }
          }
        ],
        metrics = [
          {
            category = "AllMetrics",
            enabled  = true,
            retention = {
              days    = 0,
              enabled = false
            }
          }
        ]
      }
    ],
    role = "appone"
  }
}
