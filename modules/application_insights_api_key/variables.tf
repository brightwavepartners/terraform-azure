variable "application_insights_id" {
    type = string
    description = "The Azure resource identifier for the Application Insights instance to get an API key for."
}

variable "name" {
    type = string
    description = <<EOF
        "A descriptive name given to the generated API key. This name is added to the list of API keys given access
         to the Application Insights instance, so make it descriptive enough that it explains what the key is for
         just by looking at the name."
    EOF
}

variable "read_permissions" {
    type = list(string)
    default = []
    description = "Specifices the list of read permissions granted to the API key."
}

variable "write_permissions" {
    type = list(string)
    default = []
    description = "Specifices the list of write permissions granted to the API key."
}