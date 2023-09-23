output "apps" {
    value = module.apps
}

output "location" {
    value = module.resource_group.location
}

output "name" {
    value = module.resource_group.name
}