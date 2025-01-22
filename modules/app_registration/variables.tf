# required variables:
#   name
variable "api" {
  type = object(
    {
      identifier_uri = string
      scopes = list(
        object(
          {
            admin_consent_description  = string
            admin_consent_display_name = string
            enabled                    = bool
            id                         = string
            type                       = string
            user_consent_description   = string
            user_consent_display_name  = string
            value                      = string
          }
        )
      )
    }
  )
  default = {
    identifier_uri = null
    scopes         = []
  }
  description = "A unique API identifier and one or more OAuth2 permission definitions to describe delegated permissions exposed by the web API represented by this application."
}

variable "api_permissions" {
  type = list(
    object(
      {
        description = string,
        app_id      = string,
        resource_access_list = list(
          object(
            {
              description = string,
              id          = string,
              type        = string
            }
          )
        )
      }
    )
  )
  default     = []
  description = "The list of required API permissions."
}

variable "certificates" {
  type = object({
    existing = optional(
      list(object(
        {
          name = string
        }
    )))
    new = optional(
      list(
        object(
          {
            name = string
            certificate_policy = optional(
              object(
                {
                  issuer_parameters = object(
                    {
                      name = string
                    }
                  )
                  key_properties = object(
                    {
                      exportable = bool
                      key_size   = number
                      key_type   = string
                      reuse_key  = bool
                    }
                  )
                  lifetime_action = optional(object(
                    {
                      action = object(
                        {
                          action_type = string
                        }
                      )
                      trigger = object(
                        {
                          days_before_expiry  = optional(number)
                          lifetime_percentage = optional(number)
                        }
                      )
                    }
                  ))
                  secret_properties = object(
                    {
                      content_type = string
                    }
                  )
                  x509_certificate_properties = object(
                    {
                      key_usage          = list(string)
                      subject            = string
                      validity_in_months = number
                    }
                  )
                }
              )
            )
          }
        )
    ))
  })
  default = {
    existing = [],
    new      = []
  }
  description = "App registration certificates that application's use to prove their identity when requesting a token."
}

variable "client_secrets" {
  type = list(
    object(
      {
        description    = string
        key_vault_name = string
        name           = string
      }
    )
  )
  default     = []
  description = "App registration client secrets that application's use to prove their identity when requesting a token."
}

variable "key_vault_id" {
  type        = string
  default     = null
  description = "The Azure resource identifier for a key vault where client secrets for App Registrations can be added."
}

variable "name" {
  type        = string
  description = "The display name for the App Registration."
}

variable "public_client_flow_enabled" {
  type        = bool
  default     = false
  description = "Enables the Resource Owner Password Credential, Device Code, Windows Integrated Auth mobile and desktop flows."
}

variable "single_page_application" {
  type = object(
    {
      redirect_uris = list(string)
    }
  )
  default = {
    redirect_uris = []
  }
  description = "Settings for a single-page application."
}

variable "token_configuration" {
  type = object(
    {
      access_token_list = list(
        object(
          {
            name = string
          }
        )
      )
      id_token_list = list(
        object(
          {
            name                  = string
            source                = string
            essential             = bool
            additional_properties = list(string)
          }
        )
      )
    }
  )
  default = {
    access_token_list = []
    id_token_list     = []
  }
  description = "Specifies optional claims that can be added to a token and sent to an application."
}

variable "web" {
  type = object(
    {
      implicit_grant = object(
        {
          issue_access_tokens = bool
          issue_id_tokens     = bool
        }
      ),
      redirect_uris = list(string)
    }
  )
  default = {
    implicit_grant = {
      issue_access_tokens = false
      issue_id_tokens     = false
    }
    redirect_uris = []
  }
  description = "Settings for a single-page application."
}
