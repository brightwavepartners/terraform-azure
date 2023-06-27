locals {
  application = "servicebus"
  environment = "sbx"
  location    = "northcentralus"
  service_bus = {
    allowed_ips      = []
    capacity         = 1
    role_assignments = [
      {
        name = "Michael Gressman"
        object_id = "68872158-5a14-475f-8367-663addfec652"
        role_name = "Azure Service Bus Data Receiver"
      }
    ]
    sku              = "Premium"
    subnet_ids       = []
  }
  tags   = {}
  tenant = var.tenant
}
