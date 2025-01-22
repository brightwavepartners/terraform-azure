locals {
  app_registration_server = {
    api = {
      identifier_uri = "api://server"
    }
    name = "Server"
    web = {
      "implicit_grant" : {
        "issue_access_tokens" : true,
        "issue_id_tokens" : true
      },
      redirect_uris = [
        "https://oauth.pstmn.io/v1/callback"
      ]
    }
  }
  application = "appregistration"
  environment = "dev"
  key_vault = {
    sku = "standard"
  }
  location = "northcentralus"
}
