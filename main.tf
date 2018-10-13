// Tags
locals {
  tags = {
    team        = "Devops"
    type        = "Jenkins Master"
    delete      = "False"
	environment = "master"
  }
}

# configure the Microsoft Azure Provider
provider "azurerm" {
    subscription_id = "${var.subscription_id}"
    client_id       = "${var.client_id}"
    client_secret   = "${var.client_secret}"
    tenant_id       = "${var.tenant_id}"
}

data "terraform_remote_state" "global_arch_state" {
  backend = "azurerm"

  config {
    storage_account_name = "${var.trs_storage_acc_name}"
    container_name       = "${var.trs_container_name}"
    key                  = "${var.trs_key}"
    access_key           = "${var.trs_access_key}"
  }
}

resource "azurerm_availability_set" "av" {
  name                = "${var.azurerm_availability_set_name}"
  location            = "${var.location}"
  resource_group_name = "${data.terraform_remote_state.global_arch_state.vnet_resource_group_name}"
  managed			  = "true"
  tags				  = "${local.tags}"
}

resource "azurerm_network_security_group" "private_subnet_sg" {

  name                = "jenkins-master-private-subnet-sg"
  location            = "${var.location}"
  resource_group_name = "${data.terraform_remote_state.global_arch_state.vnet_resource_group_name}"	

  // TODO : Vikas : Remove it later once master has only private IP
  security_rule {
    name                       = "Allow-HTTPS-Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  // TODO : Vikas : Remove it later once master has only private IP
  security_rule {
    name                       = "Allow-SSH-Inbound"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    // Change below line after ase testing
    destination_port_range     = "*"  
    // destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  //Added for ase
    security_rule {
    name                       = "Allow-454-Inbound"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "454"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  //added for ase
    security_rule {
    name                       = "Allow-455-Inbound"
    priority                   = 400
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "455"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  //added for ase
  security_rule {
    name                       = "Allow-ftp-Inbound"
    priority                   = 500
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "21"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTPS-Outbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}


resource "azurerm_subnet" "private_subnet" {
  name                 = "jenkins-master-private-subnet"
  virtual_network_name = "${data.terraform_remote_state.global_arch_state.vnet_name}"
  resource_group_name  = "${data.terraform_remote_state.global_arch_state.vnet_resource_group_name}"
  address_prefix       = "${var.vnet_address_prefix}"
  network_security_group_id ="${azurerm_network_security_group.private_subnet_sg.id}"  
}

// Linux VM
module "linuxvmnode" {
  source = "git::ssh://git@github.com:sagarchavan6210/linuxVM.git"

  // Parameters  
  resource_group_name = "${data.terraform_remote_state.global_arch_state.vnet_resource_group_name}"
  location            = "${var.location}"
  subnet_id           = "${azurerm_subnet.private_subnet.id}"
  computer_name       = "${var.computer_name}"
  vm_size             = "${var.vm_size}"
  disk_name           = "${var.disk_name}"
  vm_username         = "${var.vm_username}"
  vm_password         = "${var.vm_password}"
  deploy_timestamp    = "${var.deploy_timestamp}"
  shell_settings      = "${var.shell_settings}"
  protected_settings  = "${var.protected_settings}"
  availability_set_id = "${azurerm_availability_set.av.id}"
}