# Module Overview and Layout

## Why Modules?

[Terraform Modules](https://www.terraform.io/docs/language/modules/develop/index.html) are used in four different ways.

1. Lightweight abstractions - Quoting the Terraform documentation, lightweight abstractions are used in the IaC to "describe [the] infrastructure in terms of its architecture, rather than directly in terms of physical objects. For example, an Azure Function App requires not only the Function App itself, but a storage account. We can describe a Function App by combining the App itself and the associated storage account in a single module and that module now becomes a Function App architecture component everywhere a Function App is required.
2. Modularized code - There are many different components in the infrastructure, with each component likely needing many supporting resources of their own. Writing all of the code for all of the components in a single main.tf file would result in a file that would well exceed hundreds of lines of code.
3. Re-usable code - Rather than writing the same code over and over and copying and pasting between projects, modules can be used to keep code DRY so it can be re-used by other IaC projects within the enterprise.
4. Separate environments - each environment (e.g. dev, test, prod) has its own directory and root module. This follows the [HashiCorp recommended approach of using directories](https://learn.hashicorp.com/tutorials/terraform/organize-configuration#separate-states) to separate environments where the environments could be significantly different. Lower environments are similar, but those environments can be significantly different than upper environments. By using the separate directory approach, it isolates each environment when running Terraform commands so only the inteneded resources will be touched when running those commands. It also simplifies rapid code and test cycles by not having to specify command line parameters when running Terraform commands (e.g. terraform plan -var.file=foo). Simply switch to the directory for the envirinment you want to work in and issue basic Terraform commands without any additional parameters (e.g. terraform plan).

## Module Interaction
There are four "layers" to the infrastructure code.

- Environment - Every environment (e.g. dev, qa, uat, etc.) in the infrastructure is represented by a [root module](https://www.terraform.io/docs/language/modules/index.html#the-root-module). The root module for the environment is a very lightweight module that simply defines items that are specific to the environment, like the backend configuration and the target subscription. The root module also has its own corresponding .tfvars.json file that defines how to configure that environment. With this layout, you can switch between environments simply by changing to the folder for the environment and then you can run commands like _terraform plan_ and _terraform apply_ without needing to supply any additional command line parameters.
- Core - The core module is where the actual work is started to build the environments. This code is largely the same for all environments, so it is maintained in the core module so it does not have to be repeated for every environment. The core delegates much of its work to the other enterprise modules.
- Region