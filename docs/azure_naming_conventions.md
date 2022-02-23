# Azure Naming Conventions

In an effort to organize cloud assets and make operational management easier, a well-defined naming convention can help to locate assets quickly and make managing resources easier. A well-defined naming convention also means resources can be named automatically in the IaC. The automatic naming ensures that the convention is followed, since the code is creating the name, and reduces the dependence on people to come up with names. In most cases, the only piece of information that is required to be provided by a person is the application name.

## Our naming convention
The naming convention applied in this repository is based on the following pattern:

````
tenant-application-environment-location-role-objecttype
````
All tokens are always in lowercase.

The tokens in the naming convention were chosen for the following reasons:

- **tenant** - Since some resources in Azure are scoped to the whole of Azure, the Tenant name should ensure uniqueness in the resource name all across Azure. Of course it is possible that two organizations in all of Azure may have the same tenant name, but the probability is highly unlikely and if it does happen, we would just modify the Tenant slightly to avoid the naming collision.
- **application** - a Tenant organization will have many different applications in Azure, so this token will keep a resource name unique for the specific application.
- **environment** - An application will likely have several different environments that it is deployed to. This token will ensure that the same resource can be deployed to different environments while keeping the resource name different from other environments.
- **location** - An application may be deployed to multiple locations to support high-availability. This token ensures that the same resource can be deployed to multiple locations while keeping the resource name different from other locations.
- **role** - This token defines what the resource is intended to be used for.
- **objecttype** - This token defines what type of object the resource is and generally tries to follow the [Microsoft recommended abbreviations for Azure resource types](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations).

## Base name, long names, and short names
When this convention is applied, it becomes obvious that every resource will always have a well defined _base name_ that is derived from the first four tokens in the naming convention. Additionally, the only token in the _base name_ that needs to be supplied by people from a product team is the application token. The other tokens are already well defined.

````
tenant-application-environment-location
````

Some resources in Azure have [length restrictions on their names](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules). In those cases, a shortened version of the convention is applied that uses just substrings from each of the tokens and the hyphen between tokens is dropped.

Combining the _base name_ and either the long version of the convention or the shortened version, due to name length restrictions, we end up with a base name that is referred to  as _resource\_base\_name\_long_ or _resource\_base\_name\_short_.

### Resource groups
Since resource groups are just a container for other Azure resources, they generally don't have a role, and the object type is not necessary since resource groups are never displayed in the same list as Azure resources. Because of that, resource groups only use the _resource\_base\_name\_long_ for their name.

## Naming convention applied
There is a Terraform module called _globals_ that applies this naming convention in the long name and short name formats. There are two local values output from the globals module named _resource\_base\_name\_long_ and _resource\_base\_name\_short_ that can be used in any other module to automatically get the derived base name as defined by our convention.

In the globals module, you will also notice that there is some abbreviation happening, even in the long name, to keep the long names from getting too long. Specifically, environment and location have mappings to reduce an environment like _development_ to just _dev_ and a location of _northcentralus_ to just _ncus_.

## Putting all together

Let's see what resource groups and resources look like when using this convention. Our example will be an Azure Function for an application that manages parts, deployed to the development environment in North Central US.

- **tenant** - mytenant
- **application** - myapplication
- **environment** - development
- **location** - northcentralus

**mytenant-myapplication-dev-ncus** (resource group)  
&nbsp;&nbsp;**mytenant-myapplication-dev-ncus-partscatalog-af** (azure function serving the role of parts catalog)  
&nbsp;&nbsp;**mytmyadevncuspartscatasa** (storage account for parts catalog azure function - notice the short name)
