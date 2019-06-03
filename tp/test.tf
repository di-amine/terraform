// resource "azurerm_resource_group" "main1" {
//   name     = "${data.azurerm_resource_group.main1.name}"
//   location = "West US"
// }
resource "azurerm_public_ip" "ipp" {
  count               = 3
  name                = "${var.IP-PG1}-${count.index}"
  location            = "${data.azurerm_resource_group.main1.location}"
  resource_group_name = "${data.azurerm_resource_group.main1.name}"
  allocation_method   = "Dynamic"

  tags {
    environment = "Production"
  }
}

resource "azurerm_network_interface" "main1" {
  count               = 3
  name                = "nic1-${count.index}"
  location            = "${data.azurerm_resource_group.main1.location}"
  resource_group_name = "${data.azurerm_resource_group.main1.name}"

  ip_configuration {
    name                          = "testconfiguration1"
    public_ip_address_id          = "${element(azurerm_public_ip.ipp.*.id, count.index)}"
    subnet_id                     = "${data.azurerm_subnet.subnet1.id}"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "main1" {
  count                 = 3
  name                  = "vm1-${count.index}"
  location              = "${data.azurerm_resource_group.main1.location}"
  resource_group_name   = "${data.azurerm_resource_group.main1.name}"
  network_interface_ids = ["${element(azurerm_network_interface.main1.*.id, count.index)}"]
  vm_size               = "Standard_B1ms"


  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdiskG1-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}


