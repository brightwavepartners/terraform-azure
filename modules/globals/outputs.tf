# some outputs here are simply just outputting values directly from the main.tf locals block
# and it would seem easier to just output the actual value from here rather than running it
# through the locals block. the reason it is in the locals block is just for consistency so
# that all values are defined in the same place, whether they are derived locals or just
# merely static locals. either way, we always know to look in locals for the definition of all
# variables.

output "application_name_max_length" {
    value = local.application_name_max_length
    description = "Defines the maximum short name length for the application identifier."
}

output "azure_cdn_service_address_range" {
  value       = local.azure_cdn_service_address_range
  description = "Specifies the address range of the Azure CDN service."
}

output "environment_name_max_length" {
    value = local.environment_name_max_length
    description = "Defines the maximum short name length for the environment identifier."
}

output "environment_list" {
  value       = local.environment_list
  description = "A mapping of string indicators to known environment names."
}

output "environment_short_name_development" {
  value       = local.environment_short_name_development
  description = "A short string that indicates the development environment."
}

output "environment_short_name_local" {
  value       = local.environment_short_name_local
  description = "A short string that indicates the local, or sandbox, environment."
}

output "environment_short_name_production" {
  value       = local.environment_short_name_production
  description = "A short string that indicates the production environment."
}

output "environment_short_name_qa" {
  value       = local.environment_short_name_qa
  description = "A short string that indicates the QA environment."
}

output "environment_short_name_uat" {
  value       = local.environment_short_name_uat
  description = "A short string that indicates the UAT environment."
}

output "location_name_max_length" {
  value = local.location_name_max_length
  description = "Defines the maximum short name length for the location identifier."
}

output "location_short_name_list" {
  value       = local.location_short_name_list
  description = "List of short names that can be used to replace the long location name."
}

output "object_type_names" {
  value       = local.object_type_names
  description = "A list of common names used to identify an Azure resource object."
}

output "resource_base_name_long" {
  value       = local.resource_base_name_long
  description = "A value used to name Azure resources that includes all hyphens and no truncation. Used for naming Azure resources that do not have short length name restrictions."
}

output "resource_base_name_short" {
  value       = local.resource_base_name_short
  description = "A value used to name Azure resources that removes all hyphens and truncates values. Used for naming Azure resources that have short length name restrictions."
}

output "resource_name_max_length" {
  value       = local.resource_name_max_length
  description = "Azure name length restrictions per resource type."
}

output "role_names" {
  value       = local.role_names
  description = "A list of common names used to identify an Azure resource role."
}

output "tenant_name_max_length" {
    value = local.tenant_name_max_length
    description = "Defines the maximum short name length for the tenant identifier."
}