variable "subscription_id" {
  description = "Azure Subscription Id"
}

variable "tenant_id" {
  description = "Azure Tenant Id"
}

variable "client_id" {
  description = "Azure Client Id"
}

variable "client_secret" {
  description = "Azure Secrete Id"
}

variable "environment" {
  type        = "string"
  description = "environment name"
  default 	  = "master"
}

variable "trs_storage_acc_name" {}
variable "trs_container_name" {}
variable "trs_key" {}
variable "trs_access_key" {}

variable "location" {
  type        = "string"
  description = "location"
  default     = "West Europe"
}

variable "azurerm_availability_set_name" {
	description = "Manages an availability set for virtual machines"
	default = "vm-availability-set"
}

variable "jenkins_private_subnet_count" {
  type        = "string"
  description = "jenkins_private_subnet_count"
  default     = "1"
}


variable "vnet_address_prefix" {
  type        = "string"
  description = "describe your variable"
  default     = "default_value"
}

variable "remote_vnet_ids" {
  type        = "list"
  default     = []
  description = "describe your variable"
}

variable "network_interface_name" {
	description = "describe your variable"
	default     = "jenkins-master-nic"
}

variable "ip_configuration_name" {
	default     = "jenkins-ip-cfg"
}

variable "virtual_machine_name" {
	type        = "string"
	default     = "jenkinsMaster"
} 

variable "vm_size" {
  type        = "string"
  description = "VM size"
  default     = "Standard_D2s_v3"
}

variable "disk_name" {
  type        = "string"
  default     = "jenkins-master-disk"
}

variable "vm_username" {
  description = "describe your variable"
}

variable "vm_password"{
  description = "describe your variable"
}

variable "computer_name" {
  type        = "string"
  description = "describe your variable"
  default = "jenkinsMasterVM"

}

variable "shell_settings" {
  type        = "map"
  description = "shell settings "

  default = {
    fileUris         = "https://storagename.blob.core.windows.net/scripts/install_jenkins_with_tool.sh"
    commandToExecute = "bash install_jenkins_with_tool.sh"
  }
}

variable "protected_settings" {
  type        = "map"
  description = "shell settings "
}

variable "deploy_timestamp" {
  type        = "string"
  description = "deploy timestamp  in milliseconds"
}


