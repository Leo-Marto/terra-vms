resource "azurerm_virtual_machine" "reto1vm" {
    name = "${var.name}-VM"
    location = var.location
    resource_group_name = var.resource_group_name
    network_interface_ids = [var.id_interface]
    vm_size = "Standard_B1ls"


    storage_os_disk {
      name = "myOSdisk${var.name}"
      caching = "ReadWrite"
      create_option = "FromImage"
      managed_disk_type = "Standard_LRS"
      disk_size_gb = "120"
    }

    os_profile {
      computer_name = "backend-kube"
      admin_username = "adminUser"
      admin_password = var.passvm
        
    }
    
    os_profile_linux_config {
        
      ssh_keys {
        path = "/home/adminUser/.ssh/authorized_keys"
        key_data = var.publickey
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
