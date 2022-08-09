# resource group
module "resource_group" {
    source = "../../../modules/resource_group"

    application = "insight"
    contributors = []
    environment = "dev"
    location = "northcentralus"
    readers = []
    tags = {}
    tenant = "crowe"
}

# signal r
module "signal_r" {
    source = "../"
    
    application = "insight"
    capacity = 1
    connectivity_logs_enabled = false
    cors = {
      allowed_origins = [
        "https://crowe-insight-dev-ncus-api-apim.azure-api.net",
        "https://crowe.sharepoint.com"
      ]
    }
    environment = "dev"
    location = "northcentralus"
    messaging_logs_enabled = false
    resource_group_name = module.resource_group.name
    service_mode = "Serverless"
    sku = "Standard_S1"
    tags = {}
    tenant = "crowe"
}