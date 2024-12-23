# Please see the documentation in the docs folder for a more detailed discussion on
# naming conventions and how the variables in this file are used.
#
#     *** NOTE ***
#    if you ever get the error 'The given key does not identify an element in this collection value.' while doing a plan or apply,
#    it is likely because a value you are using in the code does not have a corresponding convention in globals. for example, if
#    i write code like this:
#
#       module.globals.environment_list["mycoolenvironment"]
#
#    that will result in the error noted above because the value "mycoolenvironment" does not exist as a key in the
#    environment_list local object defined here.

locals {
  # some resources in azure have length restrictions on their name. for those resources with
  # that length restriction, we need to derive a short-name. the variable that derives a
  # short-name is 'resource_base_name_short', and it uses this variable to determine how
  # many characters to use from the application in the short-name.
  application_name_max_length = 3

  azure_cdn_service_address_range = "147.243.0.0/16"

  # provides consistent short-names for environments. when definining new values in this list,
  # be sure the length does not exceed 'environment_name_max_length' value. otherwise, the
  # automatic derivation of names for 'resource_base_name_long' and 'resource_base_name_short'
  # will not work correctly since it depends on the 'environment_name_max_length' when deriving
  # names.
  environment_list = {
    "development"       = local.environment_short_name_development
    "dev"               = local.environment_short_name_development
    "dev_qa_shared"     = "dvqa"
    "dvqa"              = "dvqa"
    "local"             = local.environment_short_name_local
    "loc"               = local.environment_short_name_local
    "qa"                = local.environment_short_name_qa
    "prd"               = local.environment_short_name_production
    "production"        = local.environment_short_name_production
    "prod"              = local.environment_short_name_production
    "rc"                = "rc"
    "release_candidate" = "rc"
    "sandbox"           = "sbx"
    "sbx"               = "sbx"
    "shared"            = "shar"
    "temp"              = "tmp"
    "tmp"               = "tmp"
    "uat"               = local.environment_short_name_uat
  }

  # some resources in azure have length restrictions on their name. for those resources with
  # that length restriction, we need to derive a short-name. the variable that derives a
  # short-name is 'resource_base_name_short', and it uses this variable to determine how
  # many characters to use from the environment in the short-name.
  environment_name_max_length = 3

  environment_short_name_development = "dev"
  environment_short_name_local       = "loc"
  environment_short_name_production  = "prd"
  environment_short_name_qa          = "qa"
  environment_short_name_uat         = "uat"

  # provides consistent short-names for locations. when definining new values in this list,
  # be sure the length does not exceed 'location_name_max_length' value. otherwise, the
  # automatic derivation of names for 'resource_base_name_long' and 'resource_base_name_short'
  # will not work correctly since it depends on the 'location_name_max_length' when deriving
  # names.
  location_short_name_list = {
    "centralus"      = "cus"
    "cus"            = "cus"
    "eastus"         = "eus"
    "eus"            = "eus"
    "eastus2"        = "eus2"
    "eus2"           = "eus2"
    "northcentralus" = "ncus"
    "ncus"           = "ncus"
    "southcentralus" = "scus"
    "scus"           = "scus"
    "westus"         = "wus"
    "wus"            = "wus"
  }

  # some resources in azure have length restrictions on their name. for those resources with
  # that length restriction, we need to derive a short-name. the variable that derives a
  # short-name is 'resource_base_name_short', and it uses this variable to determine how
  # many characters to use from the location in the short-name.
  location_name_max_length = 4

  # provides consistent short-names for object_types. see the documentation in the docs folder for further
  # discussion on resource naming conventions and how object_type_names is used.
  object_type_names = {
    "api_management"          = "apim"
    "app_configuration"       = "appcfg"
    "app_registration"        = "ar"
    "app_service"             = "as"
    "app_service_plan"        = "asp"
    "application_insights"    = "ai"
    "cdn_endpoint"            = "cdne"
    "cdn_profile"             = "cdnp"
    "data_factory"            = "df"
    "elastic_pool"            = "ep"
    "failover_group"          = "fog"
    "function_app"            = "af"
    "key_vault"               = "kv"
    "local_network_gateway"   = "lgw"
    "log_analytics_workspace" = "law"
    "network_security_group"  = "nsg"
    "network_watcher"         = "nw"
    "public_ip"               = "pip"
    "redis_cache"             = "rc"
    "rediscache"              = "rc"
    "route_table"             = "rt"
    "service_bus"             = "sb"
    "signalr"                 = "sr"
    "sql_database"            = "sqldb"
    "sql_managed_instance"    = "sqlmi"
    "sql_server"              = "sqlsvr"
    "storage_account"         = "sa"
    "subnet"                  = "sn"
    "virtual_network"         = "vn"
    "virtual_network_gateway" = "vgw"
    "vpn_connection"          = "con"
  }

  # every resource that is created begins with a common "base name". that base name follows the pattern:
  #   tenant-application-environment-location
  #
  # this naming convention, and each token in the convention, was chosen for the following reasons:
  #   1. tenant - since some resources in azure are scoped to the whole of azure, the tenant name should
  #               ensure uniqueness in the resource name all across azure.
  #   2. application - a tenant organization will have many different applications in azure, so this token
  #                    will keep a resource name unique for the specific application.
  #   3. environment - an application will likely have several different environments that it is deployed to.
  #                    this token will ensure that the same resource can be deployed to different
  #                    environments while keeping the resource name different than other environments.
  #   4. location - an application may be deployed to multiple locations to support high-availability. this token
  #                 ensures that the same resource can be deployed to multiple locations while keeping the
  #                 resource name different than other locations.
  #
  # some resources in azure have length restrictions on their names (e.g. storage account name length cannot exceed 24 characters).
  # in cases where a resource name is not name length restricted, we use the 'resource_base_name_long' for its common base name.
  # in cases where a resource name is length restricted, we use the 'resource_base_name_short' for its common name. the short
  # name simply takes a substring of each token, defined by the various length variables in this file, and drops the hyphen
  # between each token.
  resource_base_name_long = try(
    join(
      "-",
      [
        var.tenant,
        var.application,
        local.environment_list[var.environment],
        local.location_short_name_list[var.location]
      ]
    ),
    ""
  )
  resource_base_name_short = try(
    join(
      "",
      [
        substr(var.tenant, 0, local.tenant_name_max_length),
        substr(var.application, 0, local.application_name_max_length),
        substr(local.environment_list[var.environment], 0, local.environment_name_max_length),
        substr(local.location_short_name_list[var.location], 0, local.location_name_max_length)
      ]
    ),
    ""
  )

  resource_name_max_length = {
    "app_service"      = 60
    "app_service_plan" = 40
  }

  # azure resource types that are used throughout azure in many different capacities
  # during infrastructure provisioning. an example where these resource types are used
  # is in service endpoint names. the azure resource reference documentation provides
  # these values (https://learn.microsoft.com/en-us/azure/templates/).
  resource_types = {
    "microsoft_sql" = "Microsoft.Sql"
  }

  # provides consistent short-names for roles. see the documentation in the docs folder for further
  # discussion on resource naming conventions and how role_names is used.
  role_names = {
    "api"                 = "api"
    "cache"               = "cache"
    "cdn"                 = "cdn"
    "configuration"       = "cfg"
    "data"                = "data"
    "firewall"            = "firewall"
    "front_door_profile"  = "network"
    "identity_and_access" = "iaa"
    "logging"             = "log"
    "messaging"           = "messaging"
    "network"             = "network"
    "notification"        = "notification"
    "redis"               = "cache"
    "redis_cache"         = "cache"
    "secret_management"   = "secrets"
    "sql_server"          = "sqlsvr"
    "vnetgateway"         = "vpn"
  }

  # some resources in azure have length restrictions on their name. for those resources with
  # that length restriction, we need to derive a short-name. the variable that derives a
  # short-name is 'resource_base_name_short', and it uses this variable to determine how
  # many characters to use from the tenant in the short-name.
  tenant_name_max_length = 3
}
