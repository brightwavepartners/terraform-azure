# TODO: only mca subscriptions are currently supported

# global naming conventions and resources
module "globals" {
  source = "../globals"

  application = var.application
  environment = var.environment
}

# billing scope needed to provision a subscription
data "azurerm_billing_mca_account_scope" "billing_account" {
  billing_account_name = var.billing_account_id
  billing_profile_name = var.billing_profile_id
  invoice_section_name = var.invoice_section_id
}

# subscription
resource "azurerm_subscription" "subscription" {
  billing_scope_id = data.azurerm_billing_mca_account_scope.billing_account.id
  subscription_name = join(
    "-",
    compact([
      var.business_unit,
      var.application,
      module.globals.environment_list[var.environment],
      var.subscription_count
    ])
  )
}
