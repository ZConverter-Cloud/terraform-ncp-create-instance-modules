# terraform-ncp-create-instnace-modules

> Before You Begin
> 
> Prepare
> 
> Start Terraform



## Before You Begin
To successfully perform this tutorial, you must have the following:
   * You need to install [git](https://git-scm.com/downloads) in advance to use it. - **Reboot Required**
   * Get authentication key information for NCP. [Create and query authentication keys](https://api.ncloud-docs.com/docs/common-ncpapi#1-%EC%9D%B8%EC%A6%9D%ED%82%A4-%EC%83%9D%EC%84%B1)

## Prepare
Prepare your environment for authenticating and running your Terraform scripts. Also, gather the information your account needs to authenticate the scripts.

### Install Terraform
   Install the latest version of Terraform **v1.3.0+**:

   1. In your environment, check your Terraform version.
      ```script
      terraform -v
      ```

      If you don't have Terraform **v1.3.0+**, then install Terraform using the following steps.

   2. From a browser, go to [Download Latest Terraform Release](https://www.terraform.io/downloads.html).

   3. Find the link for your environment and then follow the instructions for your environment. Alternatively, you can perform the following steps. Here is an example for installing Terraform v1.3.3 on Linux 64-bit.

   4. In your environment, create a temp directory and change to that directory:
      ```script
      mkdir temp
      ```
      ```script
      cd temp
      ```

   5. Download the Terraform zip file. Example:
      ```script
      wget https://releases.hashicorp.com/terraform/1.3.3/terraform_1.3.3_linux_amd64.zip
      ```

   6. Unzip the file. Example:
      ```script
      unzip terraform_1.3.3_linux_amd64.zip
      ```

   7. Move the folder to /usr/local/bin or its equivalent in Mac. Example:
      ```script
      sudo mv terraform /usr/local/bin
      ```

   8. Go back to your home directory:
      ```script
      cd
      ```

   9. Check the Terraform version:
      ```script
      terraform -v
      ```

      Example: `Terraform v1.3.3 on linux_amd64`.

##  Start Terraform

* To use terraform, you must have a terraform file of command written and a terraform executable.
* You should create a folder to use terraform, create a `terraform.tf` file, and enter the contents below.
	```
	terraform {
      required_providers {
         ncloud = {
            source  = "NaverCloudPlatform/ncloud"
            version = "2.3.8"
         }
      }
   }

   provider "ncloud" {
      access_key  = var.terraform_data.provider.access_key
      secret_key  = var.terraform_data.provider.secret_key
      region      = var.terraform_data.provider.region
      site        = var.terraform_data.provider.site
      support_vpc = true
   }

   variable "terraform_data" {
      type = object({
         provider = object({
            access_key = string
            secret_key = string
            region     = string
            site       = string
         })
         vm_info = object({
            vm_name        = string
            login_key_name = string
            OS = object({
               OS_name              = string
               OS_version           = string
               server_cpus          = string
               server_memory_in_gbs = string
               storage_type         = optional(string, "SSD")
               server_generation    = optional(string, "G2")
            })
            network_interface = object({
               subnet_no                         = string
               access_control_group_name         = optional(string,null)
               create_access_control_group_name  = optional(string,null)
               create_access_control_group_rules = optional(list(object({
                  direction        = string
                  protocol         = string
                  port_range_min   = string
                  port_range_max   = string
                  remote_ip_prefix = string
               })),[])
            })
            volume = optional(list(number),[])
            user_data_file_path = optional(string,null)
         })
      })
   }

   module "create_ncp_instance" {
      source = "git::https://github.com/ZConverter-Cloud/terraform-ncp-create-instance-modules.git"

      region = var.terraform_data.provider.region

      vm_name        = var.terraform_data.vm_info.vm_name
      login_key_name = var.terraform_data.vm_info.login_key_name

      OS_name    = var.terraform_data.vm_info.OS.OS_name
      OS_version = var.terraform_data.vm_info.OS.OS_version

      server_cpus          = var.terraform_data.vm_info.OS.server_cpus
      server_memory_in_gbs = var.terraform_data.vm_info.OS.server_memory_in_gbs
      storage_type         = var.terraform_data.vm_info.OS.storage_type
      server_generation    = var.terraform_data.vm_info.OS.server_generation

      additional_volumes   = var.terraform_data.vm_info.volume

      subnet_no                         = var.terraform_data.vm_info.network_interface.subnet_no
      access_control_group_name         = var.terraform_data.vm_info.network_interface.access_control_group_name
      create_access_control_group_name  = var.terraform_data.vm_info.network_interface.create_access_control_group_name
      create_access_control_group_rules = var.terraform_data.vm_info.network_interface.create_access_control_group_rules

      user_data_file_path = var.terraform_data.vm_info.user_data_file_path
   }

   output "result" {
      value = module.create_ncp_instance.result
   }
   ```
* After creating the ncp_terraform.json file to enter the user's value, you must enter the contents below. 
* ***The ncp_terraform.json below is an example of a required value only. See below the Attributes table for a complete example.***
* ***There is an attribute table for input values under the script, so you must refer to it.***
	```
   {
      "terraform_data": {
         "provider": {
            "access_key": "HH****************",
            "secret_key": "VlB******************************",
            "region": "KR",
            "site": "public"
         },
         "vm_info": {
            "vm_name": "test-terraform",
            "login_key_name": "terraform-test",
            "OS": {
               "OS_name": "centos",
               "OS_version": "7.8",
               "server_cpus": "2",
               "server_memory_in_gbs": "4"
            },
            "network_interface": {
               "subnet_no" : "12345",
               "create_access_control_group_name": "terraform-test-acl",
               "create_access_control_group_rules" : [{
                  "direction" : "ingress",
                  "protocol" : "TCP",
                  "port_range_min" : "22",
                  "port_range_max" : "22",
                  "remote_ip_prefix" : "0.0.0.0/0"
               }]
            },
            "volume": [30,40],
            "user_data_file_path": "./user_data.sh"
         }
      }
   }
	```
### Attribute Table
| Attribute | Data Type | Required | Default Value | Description |
| --------- | --------- | -------- | ------------- | ----------- |
| terraform_data.provider.access_key | string | yes | None | See [Create Authentication Key](#before-you-begin). |
| terraform_data.provider.secret_key | string | yes | None | See [Create Authentication Key](#before-you-begin). |
| terraform_data.provider.region | string | yes | None | Enter one of the following: `KR`, `USWN`, `HK`, `SGN`, `DEN`, `JPN` |
| terraform_data.provider.site | string | yes | None | Type of NCP you want to use: www.ncloud.com - `public`, www.gov-ncloud.com - `gov`, www.fin-ncloud.com - `fin` |
| terraform_data.vm_info.vm_name | string | yes | None | Name of the server you want to use |
| terraform_data.vm_info.login_key_name | string | yes | None | Registered login key name |
| terraform_data.vm_info.OS.OS_name | string | yes | None | Enter the OS name you want to create among (windows, centos, ubuntu) |
| terraform_data.vm_info.OS.OS_version | string | yes | None | centos - (`7.3`,`7.8`), ubuntu - (`18.04`,`20.04`), windows - (`2016`,`2019`) |
| terraform_data.vm_info.OS.server_cpus | string | yes | None | Number of cpu on the server |
| terraform_data.vm_info.OS.server_memory_in_gbs | string | yes | None | Memory capacity of the server |
| terraform_data.vm_info.OS.storage_type | string | no | `SSD` | `SSD` or `HDD` |
| terraform_data.vm_info.OS.server_generation | string | no | `G2` | `G1` or `G2` |
| terraform_data.vm_info.network_interface.subnet_no | string | yes | None | Subnet id to use |
| terraform_data.vm_info.network_interface.access_control_group_name | string | no | None | Name of access_control_group to use |
| terraform_data.vm_info.network_interface.create_access_control_group_name | string | no | None | Name of access_control_group to create |
| terraform_data.vm_info.network_interface.create_access_control_group_rules | list(object) | no | None | Create rules for access_control_group to create |
| terraform_data.vm_info.network_interface.create_access_control_group_rules.*.direction | string | conditional | None | `ingress` or `egress` |
| terraform_data.vm_info.network_interface.create_access_control_group_rules.*.protocol | string | conditional | None | `tcp` or `udp` or `icmp` |
| terraform_data.vm_info.network_interface.create_access_control_group_rules.*.port_range_min | string | conditional | None | Minimum of Port Range to Apply |
| terraform_data.vm_info.network_interface.create_access_control_group_rules.*.port_range_max | string | conditional | None | Maximum range of ports to apply |
| terraform_data.vm_info.network_interface.create_access_control_group_rules.*.remote_ip_prefix | string | conditional | None | IP to allow |
| terraform_data.vm_info.volume | list(number) | no | None | Add disks of that capacity as much as you entered the disk capacity |
| terraform_data.vm_info.user_data_file_path | string | no | None | Script file location to use as cloud-init |

* ncp_terraform.json Full Example

   ```
   {
      "terraform_data": {
         "provider": {
            "access_key": null,
            "secret_key": null,
            "region": null,
            "site": null
         },
         "vm_info": {
            "vm_name": null,
            "login_key_name": null,
            "OS": {
               "OS_name": null,
               "OS_version": null,
               "server_cpus": null,
               "server_memory_in_gbs": null,
               "storage_type": null,
               "server_generation": null
            },
            "network_interface": {
               "subnet_no": null,
               "access_control_group_name": null,
               "create_access_control_group_name": null,
               "create_access_control_group_rules": [{
                  direction        = null
                  protocol         = null
                  port_range_min   = null
                  port_range_max   = null
                  remote_ip_prefix = null
               }]
            },
            "volume": [],
            "user_data_file_path": null
         }
      }
   }
   ```

* **Go to the file path of Terraform.exe and Initialize the working directory containing the terraform configuration file.**

   ```
   terraform init
   ```
   * **Note**
       -chdir : When you use a chdir the usual way to run Terraform is to first switch to the directory containing the `.tf` files for your root module (for example, using the `cd` command), so that Terraform will find those files automatically without any extra arguments. (ex : terraform -chdir=\<terraform data file path\> init)

* **Creates an execution plan. By default, creating a plan consists of:**
  * Reading the current state of any already-existing remote objects to make sure that the Terraform state is up-to-date.
  * Comparing the current configuration to the prior state and noting any differences.
  * Proposing a set of change actions that should, if applied, make the remote objects match the configuration.
   ```
   terraform plan -var-file=<Absolute path of ncp_terraform.json>
   ```
  * **Note**
	* -var-file : When you use a var-file Sets values for potentially many [input variables](https://www.terraform.io/docs/language/values/variables.html) declared in the root module of the configuration, using definitions from a ["tfvars" file](https://www.terraform.io/docs/language/values/variables.html#variable-definitions-tfvars-files). Use this option multiple times to include values from more than one file.
     * The file name of vars.tfvars can be changed.

* **Executes the actions proposed in a Terraform plan.**
   ```
   terraform apply -var-file=<Absolute path of ncp_terraform.json> -auto-approve
   ```
* **Note**
	* -auto-approve : Skips interactive approval of plan before applying. This option is ignored when you pass a previously-saved plan file, because Terraform considers you passing the plan file as the approval and so will never prompt in that case.
