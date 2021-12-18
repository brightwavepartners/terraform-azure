application = "keyvaulttest"

environment = "dev"

location = "northcentralus"

# description is optional, but we recommend using it for all complex objects to help document,
# within the code, what the complex object type is for.
#
# names are optional, but we recommend using them to document, within the code, who the roles
# are being assigned for without needing to go to Azure to lookup identifiers.
#
# empty lists (e.g. contributors = []) can be provided for all role types if no role assignments are desired
resource_group_roles = {
  description = "Defines the list of contributors and readers that will be added to resource group(s)." # optional
  contributors = [
    {
      name      = "Harriet Adalet" # optional
      object_id = "68872158-5a14-475f-8367-663addfec652"
    },
    {
      name      = "Sheila Marlena" # optional
      object_id = "9b03e38a-c06e-4677-bc04-be4d0bdd0320"
    }
  ],
  "readers" : [
    {
      name      = "Denis Terell" # optional
      object_id = "faea2964-3bc9-4597-814f-9877b9b3e558"
    },
    {
      name      = "Philip Honour" # optional
      object_id = "f628fdc2-7406-41c3-b673-7dd6a624e0da"
    }
  ]
}

# an empty object (e.g. tags = {}) can be provided if no tags are needed
tags = {
  "Cost Center Code" = "1066"
  "Product"          = "ProductName"
}
