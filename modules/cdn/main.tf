# TODO: need to figure out how to handle delivery rules, cache settings, origin groups, etc.
#       in a generic way to be a true enterprise module. for now, those items are hard-coded
#       in the azuredeploy.json

terraform {
  experiments = [module_variable_optional_attrs]
}

locals {
  arm_template_filename = "azuredeploy.json"
  metric_namespace      = "Microsoft.Cdn/profiles"
  originConfiguration = {
    originGroups = [
      {
        name = var.origin_group_name,
        origins = [
          for storage_account in var.storage_accounts :
          {
            name      = storage_account.name,
            host_name = storage_account.primary_blob_host
          }
        ]
      }
    ]
  }
}

# global naming conventions and resources
module "globals" {
  source = "../globals"

  application = var.application
  environment = var.environment
  location    = var.location
  tenant      = var.tenant
}

# cdn profile
resource "azurerm_cdn_profile" "profile" {
  name                = "${module.globals.resource_base_name_long}-${module.globals.role_names.cdn}-${module.globals.object_type_names.cdn_profile}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.profile_sku
  tags                = var.tags
}

# alerts
module "alerts" {
  source = "../metric_alert"

  for_each = { for alert_setting in var.alert_settings : alert_setting.name => alert_setting }

  alert_settings = {
    action = {
      action_group_id = each.value.action.action_group_id
    }
    description = each.value.description
    dynamic_criteria = try(
      {
        aggregation              = each.value.dynamic_criteria.aggregation
        alert_sensitivity        = each.value.dynamic_criteria.alert_sensitivity
        evaluation_failure_count = try(each.value.dynamic_criteria.evaluation_failure_count, null)
        evaluation_total_count   = try(each.value.dynamic_criteria.evaluation_total_count, null)
        metric_name              = each.value.dynamic_criteria.metric_name
        metric_namespace         = local.metric_namespace
        operator                 = each.value.dynamic_criteria.operator
      },
      null
    )
    enabled             = each.value.enabled
    frequency           = each.value.frequency
    name                = "${each.value.name} - ${azurerm_cdn_profile.profile.name}"
    resource_group_name = var.resource_group_name
    scopes = [
      azurerm_cdn_profile.profile.id
    ]
    severity = each.value.severity
    static_criteria = try(
      {
        aggregation      = each.value.static_criteria.aggregation
        metric_name      = each.value.static_criteria.metric_name
        metric_namespace = local.metric_namespace
        operator         = each.value.static_criteria.operator
        threshold        = each.value.static_criteria.threshold
      },
      null
    )
    tags        = var.tags
    window_size = try(each.value.window_size, null)
  }
}

# endpoint
#   at the time of this writing (6/24/2021), there is no terraform support for origin groups in a cdn endpoint. 
#   there is an open issue at https://github.com/terraform-providers/terraform-provider-azurerm/issues/11983 to
#   implement support in terraform, but until that happens, another method for provisioning a cdn endpoint with
#   an origin group needs to be used. it is also very difficult to create a cdn endpoint with an origin group
#   because of the way azure has the requirements setup. in order to create an orgin group in an endpoint, the
#   endpoint has to exist first. this makes complete sense, however, it would be nice to be able to create an
#   endpoint with ALL of the origins all in the same step, and then create the origin group to include all the
#   origins in the endpoint. unfortunately, the way the requirements are setup, it is not possible to create an
#   endpoint with more than one origin without creating the origin group first, and setting it as a default
#   origin group. since an endpoint cannot be created without at least one origin, but you cannot create more
#   than one origin in an endpoint without an origin group, it sets up a strange set of operations like this:
#
#       1. create the endpoint with a single origin first (because multi-origin setup is not allowed without an
#          origin group, but an origin group can't be created without an endpoint)
#       2. create the origin group that contains the single origin defined in step 1
#       3. set the new origin group as the default origin group
#       4. go back to the endpoint and add any additional origins that are required
#       5. update the origin group to include the additional origins created in step 4
#
#   because of the crazy order of operations noted above, doing this via multiple azure cli commands becomes very
#   cumbersome. therefore, an azure arm template is used, since it is much easier to read and manage these steps,
#   to create the endpoint, its origins, and its origin group.

# endpoint with origins and origin group
resource "azurerm_resource_group_template_deployment" "cdn_endpoint" {
  name                = "${module.globals.resource_base_name_long}-${module.globals.role_names.cdn}-${module.globals.object_type_names.cdn_endpoint}-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  resource_group_name = var.resource_group_name
  deployment_mode     = "Incremental"
  template_content    = file("${path.module}/${local.arm_template_filename}")
  parameters_content = jsonencode(
    {
      "compressionEnabled"     = { value = var.content_types_to_compress != [] }
      "contentTypesToCompress" = { value = var.content_types_to_compress }
      "httpAllowed"            = { value = var.http_allowed }
      "httpsAllowed"           = { value = var.https_allowed }
      "location"               = { value = var.location }
      "name"                   = { value = "${module.globals.resource_base_name_long}-${module.globals.role_names.cdn}-${module.globals.object_type_names.cdn_endpoint}" }
      "originConfiguration"    = { value = local.originConfiguration }
      "profileName"            = { value = azurerm_cdn_profile.profile.name }
    }
  )

  lifecycle {
    ignore_changes = [
      name
    ]
  }

  depends_on = [
    azurerm_cdn_profile.profile
  ]
}
