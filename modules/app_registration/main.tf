# app registration
resource "azuread_application" "app_registration" {
  display_name                   = var.name
  fallback_public_client_enabled = var.public_client_flow_enabled
  identifier_uris                = var.api.identifier_uri != null ? [var.api.identifier_uri] : null

  api {
    dynamic "oauth2_permission_scope" {
      for_each = var.api.scopes

      content {
        admin_consent_description  = oauth2_permission_scope.value["admin_consent_description"]
        admin_consent_display_name = oauth2_permission_scope.value["admin_consent_display_name"]
        enabled                    = oauth2_permission_scope.value["enabled"]
        id                         = oauth2_permission_scope.value["id"]
        type                       = oauth2_permission_scope.value["type"]
        user_consent_description   = oauth2_permission_scope.value["user_consent_description"]
        user_consent_display_name  = oauth2_permission_scope.value["user_consent_display_name"]
        value                      = oauth2_permission_scope.value["value"]
      }
    }
  }

  dynamic "required_resource_access" {
    for_each = var.api_permissions

    content {
      resource_app_id = required_resource_access.value["app_id"]

      dynamic "resource_access" {
        for_each = required_resource_access.value.resource_access_list

        content {
          id   = resource_access.value["id"]
          type = resource_access.value["type"]
        }
      }
    }
  }

  optional_claims {
    dynamic "access_token" {
      for_each = var.token_configuration.access_token_list

      content {
        name = access_token.value["name"]
      }
    }

    dynamic "id_token" {
      for_each = var.token_configuration.id_token_list

      content {
        name = id_token.value["name"]
      }
    }
  }

  single_page_application {
    redirect_uris = var.single_page_application.redirect_uris
  }

  web {
    redirect_uris = var.web.redirect_uris

    implicit_grant {
      access_token_issuance_enabled = var.web.implicit_grant.issue_access_tokens
      id_token_issuance_enabled     = var.web.implicit_grant.issue_id_tokens
    }
  }

  lifecycle {
    ignore_changes = [
      owners
    ]
  }
}

# service principal attached to the app registration
resource "azuread_service_principal" "service_principal" {
  application_id               = azuread_application.app_registration.application_id
  app_role_assignment_required = false
}

# create client secret(s) for the app registration - if there are any defined
resource "azuread_application_password" "client_secret" {
  for_each = {
    for client_secret in var.client_secrets :
    client_secret.name => client_secret
  }

  application_object_id = azuread_application.app_registration.id
  display_name          = each.value.name
  end_date              = "2099-12-31T23:59:59Z"
}

# push client secret(s) to key vault
resource "azurerm_key_vault_secret" "keyvault_client_secret" {
  for_each = azuread_application_password.client_secret

  content_type = element(
    [
      for client_secret in var.client_secrets :
      client_secret.description if client_secret.name == each.value.display_name
    ],
    0
  )
  key_vault_id = var.key_vault_id
  name = element(
    [
      for client_secret in var.client_secrets :
      client_secret.key_vault_name if client_secret.name == each.value.display_name
    ],
    0
  )
  value = each.value.value
}

# get any existing certificates for the app registration - if there are any existing ones defined that should be attached to the app registration
data "azurerm_key_vault_certificate" "existing_keyvault_auth_certificate" {
  for_each = {
    for certificate in var.certificates.existing :
    certificate.name => certificate
  }

  name         = each.value.name
  key_vault_id = var.key_vault_id
}

# attach any existing certificate(s) to the app registration
resource "azuread_application_certificate" "existing_certificate" {
  for_each = data.azurerm_key_vault_certificate.existing_keyvault_auth_certificate

  application_object_id = azuread_application.app_registration.id
  encoding              = "hex"
  end_date              = each.value.expires
  start_date            = each.value.not_before
  type                  = "AsymmetricX509Cert"
  value                 = each.value.certificate_data
}

# create certificate(s) for the app registration - if there are any defined that need to be created new
resource "azurerm_key_vault_certificate" "keyvault_auth_certificate" {
  for_each = {
    for certificate in var.certificates.new :
    certificate.name => certificate
  }

  name         = each.value.name
  key_vault_id = var.key_vault_id

  dynamic "certificate_policy" {
    for_each = each.value.certificate_policy == null ? [] : [1]

    content {
      issuer_parameters {
        name = each.value.certificate_policy.issuer_parameters.name
      }
      key_properties {
        exportable = each.value.certificate_policy.key_properties.exportable
        key_size   = each.value.certificate_policy.key_properties.key_size
        key_type   = each.value.certificate_policy.key_properties.key_type
        reuse_key  = each.value.certificate_policy.key_properties.reuse_key
      }
      secret_properties {
        content_type = each.value.certificate_policy.secret_properties.content_type
      }
      x509_certificate_properties {
        key_usage          = each.value.certificate_policy.x509_certificate_properties.key_usage
        subject            = each.value.certificate_policy.x509_certificate_properties.subject
        validity_in_months = each.value.certificate_policy.x509_certificate_properties.validity_in_months
      }

      dynamic "lifetime_action" {
        for_each = each.value.certificate_policy.lifetime_action == null ? [] : [1]

        content {
          action {
            action_type = each.value.certificate_policy.lifetime_action.action.action_type
          }

          # the trigger block can contain either a value based on days or percentage. two dynamic
          # blocks are used to apply whichever one was defined.
          dynamic "trigger" {
            for_each = each.value.certificate_policy.lifetime_action.trigger.days_before_expiry == null ? [] : [1]

            content {
              days_before_expiry = each.value.certificate_policy.lifetime_action.trigger.days_before_expiry
            }
          }

          dynamic "trigger" {
            for_each = each.value.certificate_policy.lifetime_action.trigger.lifetime_percentage == null ? [] : [1]

            content {
              lifetime_percentage = each.value.certificate_policy.lifetime_action.trigger.lifetime_percentage
            }
          }
        }
      }
    }
  }
}

# attach any new certificate(s) to the app registration
resource "azuread_application_certificate" "certificate" {
  for_each = azurerm_key_vault_certificate.keyvault_auth_certificate

  application_object_id = azuread_application.app_registration.id
  encoding              = "hex"
  end_date              = each.value.certificate_attribute[0].expires
  start_date            = each.value.certificate_attribute[0].not_before
  type                  = "AsymmetricX509Cert"
  value                 = each.value.certificate_data
}
