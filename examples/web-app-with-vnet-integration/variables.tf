variable "subscription_id" {
  description = "Defines the subscription in which resources will be provisioned"
  type        = string
}

variable "tenant" {
  description = "Defines the tenant name for whom the resources are being provisioned. In a development environment, this is typically the developer's last name."
  type        = string
}