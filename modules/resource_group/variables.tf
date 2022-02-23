variable "application" {
  type        = string
  description = "The name of the application that this region is being provisioned for."
}

variable "contributors" {
  type = list(
    object(
      {
        name      = string,
        object_id = string
      }
    )
  )
  default     = []
  description = "The list of Active Directory object identifiers that represent users to add to the resource group as contributors."
}

variable "environment" {
  type        = string
  description = "The environment for which to provision the infrastructure (e.g. development, production)"
}

variable "location" {
  type        = string
  description = "The region in which to provision the region."
}

variable "readers" {
  type = list(
    object(
      {
        name      = string,
        object_id = string
      }
    )
  )
  default     = []
  description = "The list of Active Directory object identifiers that represent users to add to the resource group as readers."
}

variable "tags" {
  type        = map(any)
  description = "A set of name and value pairs that are applied to the resource group to help organize and categorize."
}

variable "tenant" {
  type        = string
  description = "The name of the tenant that the resource group belongs to."
}
