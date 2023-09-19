variable "business_unit" {
    type = string
    description = "The business unit that the subscription is related to."  
}

variable "application" {
    type = string
    description = "The role or application the subscription is for (e.g. connectivity, email, hrcenter, etc)."
}

variable "environment" {
  type        = string
  description = "The environment for which to provision the infrastructure (e.g. development, production)"
}

variable "subscription_count" {
    type = string
    description = "This value provides a counter for the number of same subscriptions in order to keep the subscription unique name if there are more than one (e.g. 001)."  
}