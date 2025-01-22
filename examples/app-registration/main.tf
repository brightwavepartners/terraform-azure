# app registration - server
module "app_registration_server" {
  source = "../../modules/app_registration"

  name = local.app_registration_server.name
}