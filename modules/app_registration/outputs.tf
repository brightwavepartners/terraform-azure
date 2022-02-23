output "application_id" {
  value       = azuread_application.app_registration.application_id
  description = "The Active Directory identifier for this App Registration."
}

output "oauth2_permission_scope_ids" {
  value       = azuread_application.app_registration.oauth2_permission_scope_ids
  description = "List of identifiers for delegated permissions that are exposed by the App Registration API."
}