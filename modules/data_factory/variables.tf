variable "alert_settings" {
  type = list(
    object(
      {
        action = object(
          {
            action_group_id = string
          }
        )
        description = string
        dynamic_criteria = optional(
          object(
            {
              aggregation              = string
              alert_sensitivity        = string
              evaluation_failure_count = optional(number)
              evaluation_total_count   = optional(number)
              metric_name              = string
              operator                 = string
            }
          )
        )
        enabled   = bool
        frequency = optional(string)
        name      = string
        severity  = number
        static_criteria = optional(
          object(
            {
              aggregation = string
              dimensions = optional(
                list(
                  object(
                    {
                      name     = string
                      operator = string
                      values   = list(string)
                    }
                  )
                )
              )
              metric_name = string
              operator    = string
              threshold   = number
            }
          )
        )
        window_size = optional(string)
      }
    )
  )
  default     = []
  description = "Defines alert settings for the Data Factory."
}

variable "application" {
  type        = string
  description = "The name of the application that this infrastructure is being provisioned for."
}

variable "environment" {
  type        = string
  description = "The environment for which to provision the infrastructure (e.g. development, production)"
}

variable "location" {
  type        = string
  description = "The Azure region where the infrastructure will be deployed."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which the infrastructure will be created."
}

variable "tags" {
  type        = map(string)
  description = "String values used to organize resources."
}

variable "tenant" {
  type        = string
  description = "Tenant name."
}

variable "vsts_configuration" {
  type = object(
    {
      account_name    = string
      branch_name     = string
      project_name    = string
      repository_name = string
      root_folder     = string
    }
  )
  default     = null
  description = "Defines the ADO source code repository that the data factory is connected to."
}
