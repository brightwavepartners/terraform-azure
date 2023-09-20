# global naming conventions and resources
module "globals" {
  source = "../globals"

  application = var.application
  environment = var.environment
  location    = null
  tenant      = null
}

# subscription
resource "azurerm_subscription" "subscription" {
  subscription_name = join(
    "-",
    [
      var.business_unit,
      var.application,
      module.global.environment_list[var.environment],
      var.subscription_count
    ]
  )
}
