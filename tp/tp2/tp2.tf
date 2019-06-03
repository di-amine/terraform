variable "prefixg1" {
  default = "g1"
}
variable "prefixg2" {
  default = "g2"
}
variable "prefix1" {
  default = "m1"
}
variable "prefix2" {
  default = "m2"
}
variable "prefix3" {
  default = "m3"
}
variable "prefix4" {
  default = "m4"
}
variable "prefix5" {
  default = "m5"
}

// ************************************  Groups

resource "azurerm_resource_group" "main1" {
  name     = "${var.prefixg1}-resources"
  location = "West US"
}

resource "azurerm_resource_group" "main2" {
  name     = "${var.prefixg2}-resources"
  location = "West Europe"
}

// **************************************** Network

resource "azurerm_public_ip" "test1" {
  name                = "acceptanceTestPublicIp1"
  location            = "West US"
  resource_group_name = "${azurerm_resource_group.main1.name}"
  allocation_method   = "Dynamic"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_public_ip" "test2" {
  name                = "acceptanceTestPublicIp1"
  location            = "West US"
  resource_group_name = "${azurerm_resource_group.main1.name}"
  allocation_method   = "Dynamic"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_public_ip" "test3" {
  name                = "acceptanceTestPublicIp1"
  location            = "West US"
  resource_group_name = "${azurerm_resource_group.main1.name}"
  allocation_method   = "Dynamic"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_public_ip" "test4" {
  name                = "acceptanceTestPublicIp2"
  location            = "West Europe"
  resource_group_name = "${azurerm_resource_group.main2.name}"
  allocation_method   = "Dynamic"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_public_ip" "test5" {
  name                = "acceptanceTestPublicIp2"
  location            = "West Europe"
  resource_group_name = "${azurerm_resource_group.main2.name}"
  allocation_method   = "Dynamic"

  tags = {
    environment = "Production"
  }
}



resource "azurerm_virtual_network" "main1" {
  name                = "${var.prefix1}-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.main1.location}"
  resource_group_name = "${azurerm_resource_group.main1.name}"
}

resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = "${azurerm_resource_group.main1.name}"
  virtual_network_name = "${azurerm_virtual_network.main1.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_virtual_network" "main2" {
  name                = "${var.prefix2}-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.main1.location}"
  resource_group_name = "${azurerm_resource_group.main1.name}"
}
resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  resource_group_name  = "${azurerm_resource_group.main1.name}"
  virtual_network_name = "${azurerm_virtual_network.main2.name}"
  address_prefix       = "10.0.3.0/24"
}


resource "azurerm_virtual_network" "main3" {
  name                = "${var.prefix3}-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.main1.location}"
  resource_group_name = "${azurerm_resource_group.main1.name}"
}
resource "azurerm_subnet" "subnet3" {
  name                 = "subnet3"
  resource_group_name  = "${azurerm_resource_group.main1.name}"
  virtual_network_name = "${azurerm_virtual_network.main3.name}"
  address_prefix       = "10.0.4.0/24"
}


resource "azurerm_virtual_network" "main4" {
  name                = "${var.prefix4}-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.main2.location}"
  resource_group_name = "${azurerm_resource_group.main2.name}"
}
resource "azurerm_subnet" "subnet4" {
  name                 = "subnet4"
  resource_group_name  = "${azurerm_resource_group.main2.name}"
  virtual_network_name = "${azurerm_virtual_network.main4.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_virtual_network" "main5" {
  name                = "${var.prefix5}-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.main2.location}"
  resource_group_name = "${azurerm_resource_group.main2.name}"
}
resource "azurerm_subnet" "subnet5" {
  name                 = "subnet5"
  resource_group_name  = "${azurerm_resource_group.main2.name}"
  virtual_network_name = "${azurerm_virtual_network.main5.name}"
  address_prefix       = "10.0.3.0/24"
}

resource "azurerm_network_interface" "main1" {
  name                = "${var.prefix1}-nic"
  location            = "${azurerm_resource_group.main1.location}"
  resource_group_name = "${azurerm_resource_group.main1.name}"

  ip_configuration {
    name                          = "testconfiguration1"
    public_ip_address_id          = "${azurerm_public_ip.test1.id}"
    subnet_id                     = "${azurerm_subnet.subnet1.id}"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "main2" {
  name                = "${var.prefix2}-nic"
  location            = "${azurerm_resource_group.main1.location}"
  resource_group_name = "${azurerm_resource_group.main1.name}"

  ip_configuration {
    name                          = "testconfiguration1"
    public_ip_address_id          = "${azurerm_public_ip.test2.id}"
    subnet_id                     = "${azurerm_subnet.subnet2.id}"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "main3" {
  name                = "${var.prefix3}-nic"
  location            = "${azurerm_resource_group.main1.location}"
  resource_group_name = "${azurerm_resource_group.main1.name}"

  ip_configuration {
    name                          = "testconfiguration1"
    public_ip_address_id          = "${azurerm_public_ip.test3.id}"
    subnet_id                     = "${azurerm_subnet.subnet3.id}"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "main4" {
  name                = "${var.prefix4}-nic"
  location            = "${azurerm_resource_group.main2.location}"
  resource_group_name = "${azurerm_resource_group.main2.name}"

  ip_configuration {
    name                          = "testconfiguration1"
    public_ip_address_id          = "${azurerm_public_ip.test4.id}"
    subnet_id                     = "${azurerm_subnet.subnet4.id}"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "main5" {
  name                = "${var.prefix5}-nic"
  location            = "${azurerm_resource_group.main2.location}"
  resource_group_name = "${azurerm_resource_group.main2.name}"

  ip_configuration {
    name                          = "testconfiguration1"
    public_ip_address_id          = "${azurerm_public_ip.test5.id}"
    subnet_id                     = "${azurerm_subnet.subnet5.id}"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "main1" {
  name                  = "${var.prefix1}-vm"
  location              = "${azurerm_resource_group.main1.location}"
  resource_group_name   = "${azurerm_resource_group.main1.name}"
  network_interface_ids = ["${azurerm_network_interface.main1.id}"]
  vm_size               = "Standard_DS1_v2"


  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
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

resource "azurerm_virtual_machine" "main2" {
  name                  = "${var.prefix2}-vm"
  location              = "${azurerm_resource_group.main1.location}"
  resource_group_name   = "${azurerm_resource_group.main1.name}"
  network_interface_ids = ["${azurerm_network_interface.main2.id}"]
  vm_size               = "Standard_DS1_v2"


  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
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

resource "azurerm_virtual_machine" "main3" {
  name                  = "${var.prefix3}-vm"
  location              = "${azurerm_resource_group.main1.location}"
  resource_group_name   = "${azurerm_resource_group.main1.name}"
  network_interface_ids = ["${azurerm_network_interface.main3.id}"]
  vm_size               = "Standard_DS1_v2"


  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
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

resource "azurerm_virtual_machine" "main4" {
  name                  = "${var.prefix4}-vm"
  location              = "${azurerm_resource_group.main2.location}"
  resource_group_name   = "${azurerm_resource_group.main2.name}"
  network_interface_ids = ["${azurerm_network_interface.main4.id}"]
  vm_size               = "Standard_DS1_v2"


  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
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

resource "azurerm_virtual_machine" "main5" {
  name                  = "${var.prefix5}-vm"
  location              = "${azurerm_resource_group.main2.location}"
  resource_group_name   = "${azurerm_resource_group.main2.name}"
  network_interface_ids = ["${azurerm_network_interface.main5.id}"]
  vm_size               = "Standard_DS1_v2"


  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
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

