# crear el grupo de recursos
resource "azurerm_resource_group" "reto1" {
    name = var.resource_group_name
    location = var.location
    
}

provider "random" {
  
}

resource "random_string" "random_suffix" {
  length  = 8
  upper   = false
  special = false
}

resource "random_password" "name" {
  length = "16"
  special = true
  upper   = true
  lower   = true
  numeric = true
}

resource "tls_private_key" "keysvm1" {
  algorithm = "RSA"
  rsa_bits = "4096"
  
}

resource "local_file" "private_key" {
  content  = tls_private_key.keysvm1.private_key_openssh
  filename = "${path.module}/ssh_${var.resource_group_name}_key"
}

data "azurerm_client_config" "info" { 
}

resource "azurerm_key_vault" "keyvault1" {
  name = "key${random_string.random_suffix.result}${var.resource_group_name}vault"
  resource_group_name = azurerm_resource_group.reto1.name
  location = azurerm_resource_group.reto1.location
  sku_name = "standard"
  tenant_id = data.azurerm_client_config.info.tenant_id
  access_policy {
    tenant_id = data.azurerm_client_config.info.tenant_id
    object_id = data.azurerm_client_config.info.object_id
    secret_permissions = ["Get", "List", "Set", "Delete", "Purge"]
  }
  }
resource "azurerm_key_vault_secret" "pass_secret" {
  name = "passvm"
  value = random_password.name.result
  key_vault_id = azurerm_key_vault.keyvault1.id
   
}
resource "azurerm_key_vault_secret" "pass_public_key" {
  name = "privatekey"
  value = tls_private_key.keysvm1.private_key_openssh 
  key_vault_id = azurerm_key_vault.keyvault1.id
   
}



resource "azurerm_virtual_network" "vnreto1" {
    name = "${var.resource_group_name}-VNET"
    location = azurerm_resource_group.reto1.location
    address_space = ["10.0.0.0/16"]
    resource_group_name = azurerm_resource_group.reto1.name
}

resource "azurerm_subnet" "sbreto1" {
    name = "${var.resource_group_name}-SUBNET-back"
    resource_group_name = azurerm_resource_group.reto1.name
    virtual_network_name = azurerm_virtual_network.vnreto1.name
    address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "sb2reto1" {
    name = "${var.resource_group_name}-SUBNET2-back"
    resource_group_name = azurerm_resource_group.reto1.name
    virtual_network_name = azurerm_virtual_network.vnreto1.name
    address_prefixes = ["10.0.2.0/24"]
}


resource "azurerm_network_security_group" "nsgreto1" {
    name = "${var.resource_group_name}-NSG"
    location = azurerm_resource_group.reto1.location
    resource_group_name = azurerm_resource_group.reto1.name
    security_rule {
        name = "allow-http"
        priority = 100
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_ranges = ["80"]
        destination_port_ranges = ["80"]
        source_address_prefix = "*"
        destination_address_prefix = azurerm_network_interface.nireto1.private_ip_address
        }
    security_rule {
        name = "allow-ssh"
        priority = 101
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "22"
        source_address_prefixes = ["167.249.0.0/16"]
        destination_address_prefixes = azurerm_subnet.sbreto1.address_prefixes
    }
}

# Creo la ip publica
resource "azurerm_public_ip" "pireto1" {
    name = "${var.resource_group_name}-Public-ip"
    resource_group_name = azurerm_resource_group.reto1.name
    location = azurerm_resource_group.reto1.location
    allocation_method = "Static"
}

resource "azurerm_network_interface" "nireto1" {
    name = "${var.resource_group_name}-NIC"
    location = azurerm_resource_group.reto1.location
    resource_group_name = azurerm_resource_group.reto1.name
    ip_configuration {
      name = "${var.resource_group_name}-IP-NIC"
      subnet_id = azurerm_subnet.sbreto1.id
      private_ip_address_allocation = "Static"
      private_ip_address = "10.0.1.5"
      public_ip_address_id = azurerm_public_ip.pireto1.id
      } 
}
resource "azurerm_network_interface" "ni2reto1" {
    name = "${var.resource_group_name}-NIC2"
    location = azurerm_resource_group.reto1.location
    resource_group_name = azurerm_resource_group.reto1.name
    ip_configuration {
      name = "${var.resource_group_name}-IP-NIC"
      subnet_id = azurerm_subnet.sb2reto1.id
      private_ip_address_allocation = "Static"
      private_ip_address = "10.0.2.5"
      } 
}


resource "azurerm_network_interface_security_group_association" "nisgreto1" {
    network_interface_id = azurerm_network_interface.nireto1.id
    network_security_group_id = azurerm_network_security_group.nsgreto1.id
 
}
  


resource "azurerm_virtual_machine" "reto1vm" {
    name = "${var.resource_group_name}-VM"
    location = azurerm_resource_group.reto1.location
    resource_group_name = azurerm_resource_group.reto1.name
    network_interface_ids = [azurerm_network_interface.nireto1.id]
    vm_size = "Standard_DS1_v2"


    storage_os_disk {
      name = "myOSdisk"
      caching = "ReadWrite"
      create_option = "FromImage"
      managed_disk_type = "Standard_LRS"
      disk_size_gb = "120"
    }

    os_profile {
      computer_name = "backend-kube"
      admin_username = "adminUser"
      admin_password = random_password.name.result
        
    }
    
    os_profile_linux_config {
        
      ssh_keys {
        path = "/home/adminUser/.ssh/authorized_keys"
        key_data = tls_private_key.keysvm1.public_key_openssh
      }
      disable_password_authentication = false
    }

    storage_image_reference {
        publisher = "canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts-gen2"
        version   = "latest"
    }

  
}

resource "azurerm_virtual_machine" "reto1vm2" {
    name = "${var.resource_group_name}-VM2"
    location = azurerm_resource_group.reto1.location
    resource_group_name = azurerm_resource_group.reto1.name
    network_interface_ids = [azurerm_network_interface.ni2reto1.id]
    vm_size = "Standard_DS1_v2"


    storage_os_disk {
      name = "myOSdisk2"
      caching = "ReadWrite"
      create_option = "FromImage"
      managed_disk_type = "Standard_LRS"
      disk_size_gb = "120"
    }

    os_profile {
      computer_name = "postgresql"
      admin_username = "adminUser"
      admin_password = random_password.name.result
        
    }
    
    os_profile_linux_config {
        
      ssh_keys {
        path = "/home/adminUser/.ssh/authorized_keys"
        key_data = tls_private_key.keysvm1.public_key_openssh
      }
      disable_password_authentication = false
    }

    storage_image_reference {
        publisher = "canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts-gen2"
        version   = "latest"
    }

  
}


# Crear un workspace de Log Analytics
resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.resource_group_name}-law"
  location            = azurerm_resource_group.reto1.location
  resource_group_name = azurerm_resource_group.reto1.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Habilitar la recopilación de métricas para las VMs
resource "azurerm_virtual_machine_extension" "vm_extension" {
  name                       = "OmsAgentForLinux"
  virtual_machine_id         = azurerm_virtual_machine.reto1vm.id
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "OmsAgentForLinux"
  type_handler_version       = "1.13"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "workspaceId": "${azurerm_log_analytics_workspace.law.workspace_id}"
    }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "workspaceKey": "${azurerm_log_analytics_workspace.law.primary_shared_key}"
    }
  PROTECTED_SETTINGS
}

# Repetir para la segunda VM
resource "azurerm_virtual_machine_extension" "vm2_extension" {
  name                       = "OmsAgentForLinux"
  virtual_machine_id         = azurerm_virtual_machine.reto1vm2.id
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "OmsAgentForLinux"
  type_handler_version       = "1.13"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "workspaceId": "${azurerm_log_analytics_workspace.law.workspace_id}"
    }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "workspaceKey": "${azurerm_log_analytics_workspace.law.primary_shared_key}"
    }
  PROTECTED_SETTINGS
}

# Crear una regla de alerta
resource "azurerm_monitor_action_group" "main" {
  name                = "${var.resource_group_name}-actiongroup"
  resource_group_name = azurerm_resource_group.reto1.name
  short_name          = "${var.resource_group_name}act"

  email_receiver {
    name          = "sendtoadmin"
    email_address = "raulmarto-testeo@hotmail.com"
  }
}

resource "azurerm_monitor_metric_alert" "alert1" {
  name                = "${var.resource_group_name}-metricalert"
  resource_group_name = azurerm_resource_group.reto1.name
  scopes              = [azurerm_virtual_machine.reto1vm.id, azurerm_virtual_machine.reto1vm2.id]

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
   }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  target_resource_type = "Microsoft.Compute/virtualMachines"
  target_resource_location = azurerm_resource_group.reto1.location
}





output "public_ip_address" {
  value = azurerm_public_ip.pireto1.ip_address
  description = "La dirección IP pública de la máquina virtual."
}
