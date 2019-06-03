resource "azurerm_resource_group" "tech" {
  name     = "${var.prefixg1}-resources"
  location = "${var.locUS}"
  tags = {
    environment = "Tech"
  }
}

resource "azurerm_resource_group" "apps" {
  name     = "${var.prefixg2}-resources"
  location = "${var.locWE}"

  tags = {
    environment = "Apps"
  }
}

resource "azurerm_resource_group" "data" {
  name     = "${var.prefixg3}-resources"
  location = "${var.locWE}"
  
  tags = {
    environment = "Data"
  }
}

resource "azurerm_network_security_group" "techsg" {
  name                = "${var.securitygroupe1}"
  location            = "${azurerm_resource_group.tech.location}"
  resource_group_name = "${azurerm_resource_group.tech.name}"
}

resource "azurerm_network_security_group" "appssg" {
  name                = "${var.securitygroupe2}"
  location            = "${azurerm_resource_group.apps.location}"
  resource_group_name = "${azurerm_resource_group.apps.name}"
}

resource "azurerm_network_security_group" "datasg" {
  name                = "${var.securitygroupe3}"
  location            = "${azurerm_resource_group.data.location}"
  resource_group_name = "${azurerm_resource_group.data.name}"
}

resource "azurerm_public_ip" "techip" {
  count               = 2
  name                = "${var.IP-PG1}-${count.index}"
  location            = "${azurerm_resource_group.tech.location}"
  resource_group_name = "${azurerm_resource_group.tech.name}"
  allocation_method   = "Dynamic"

  tags = {
    environment = "Tech"
  }
}

resource "azurerm_public_ip" "appsip" {
  name                = "${var.IP-PG2}-${count.index}"
  location            = "${azurerm_resource_group.apps.location}"
  resource_group_name = "${azurerm_resource_group.apps.name}"
  allocation_method   = "Dynamic"

  tags = {
    environment = "Apps"
  }
}

resource "azurerm_public_ip" "dataip" {
  name                = "${var.IP-PG3}-${count.index}"
  location            = "${azurerm_resource_group.data.location}"
  resource_group_name = "${azurerm_resource_group.data.name}"
  allocation_method   = "Dynamic"

  tags = {
    environment = "Data"
  }
}

resource "azurerm_virtual_network" "techvn" {
  name                           = "${var.vn1}"
  address_space                  = ["10.0.0.0/16"]
  location                       = "${azurerm_resource_group.tech.location}"
  resource_group_name            = "${azurerm_resource_group.tech.name}"
}

resource "azurerm_virtual_network" "appsvn" {
  name                           = "${var.vn2}"
  address_space                  = ["10.0.0.0/16"]
  location                       = "${azurerm_resource_group.apps.location}"
  resource_group_name            = "${azurerm_resource_group.apps.name}"
}

resource "azurerm_virtual_network" "datavn" {
  name                              = "${var.vn3}"
  address_space                     = ["10.0.0.0/16"]
  location                          = "${azurerm_resource_group.data.location}"
  resource_group_name               = "${azurerm_resource_group.data.name}"

}


resource "azurerm_subnet" "techsubnet" {
  name                 = "${var.subnet1}"
  resource_group_name  = "${azurerm_resource_group.tech.name}"
  virtual_network_name = "${azurerm_virtual_network.techvn.name}"
  address_prefix       = "10.0.0.0/24"
  network_security_group_id    = "${azurerm_network_security_group.techsg.id}"
}

resource "azurerm_subnet" "appssubnet" {
  name                 = "${var.subnet2}"
  resource_group_name  = "${azurerm_resource_group.apps.name}"
  virtual_network_name = "${azurerm_virtual_network.appsvn.name}"
  address_prefix       = "10.0.3.0/24"
  network_security_group_id    = "${azurerm_network_security_group.appssg.id}"
}

resource "azurerm_subnet" "datasubnet" {
  name                 = "${var.subnet3}"
  resource_group_name  = "${azurerm_resource_group.data.name}"
  virtual_network_name = "${azurerm_virtual_network.datavn.name}"
  address_prefix       = "10.0.4.0/24"
  network_security_group_id    = "${azurerm_network_security_group.datasg.id}"
}

resource "azurerm_network_interface" "techni" {
  count               = 2
  name                = "${var.nic1}-${count.index}"
  location            = "${azurerm_resource_group.tech.location}"
  resource_group_name = "${azurerm_resource_group.tech.name}"
  network_security_group_id     = "${azurerm_network_security_group.techsg.id}"

  ip_configuration {
    name                          = "techconfiguration"
    public_ip_address_id          = "${element(azurerm_public_ip.techip.*.id, count.index)}"
    subnet_id                     = "${azurerm_subnet.techsubnet.id}"
    private_ip_address_allocation = "Dynamic"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.loadb.id}"]
  }
}

resource "azurerm_network_interface" "appsni" {
  name                = "${var.nic2}"
  location            = "${azurerm_resource_group.apps.location}"
  resource_group_name = "${azurerm_resource_group.apps.name}"
  network_security_group_id     = "${azurerm_network_security_group.appssg.id}"

  ip_configuration {
    name                          = "techconfiguration"
    public_ip_address_id          = "${azurerm_public_ip.appsip.id}"
    subnet_id                     = "${azurerm_subnet.appssubnet.id}"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "datani" {
  name                = "${var.nic3}"
  location            = "${azurerm_resource_group.data.location}"
  resource_group_name = "${azurerm_resource_group.data.name}"
  network_security_group_id     = "${azurerm_network_security_group.datasg.id}"

  ip_configuration {
    name                          = "techconfiguration"
    public_ip_address_id          = "${azurerm_public_ip.dataip.id}"
    subnet_id                     = "${azurerm_subnet.datasubnet.id}"
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_network_security_rule" "techsr1" {
  name                        = "ssh"
  priority                    = 100
  direction                   = "inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.tech.name}"
  network_security_group_name = "${azurerm_network_security_group.techsg.name}"
}
resource "azurerm_network_security_rule" "techsr2" {
  name                        = "port1"
  priority                    = 102
  direction                   = "inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "7050"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.tech.name}"
  network_security_group_name = "${azurerm_network_security_group.techsg.name}"
}
resource "azurerm_network_security_rule" "techsr3" {
  name                        = "port2"
  priority                    = 103
  direction                   = "inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.tech.name}"
  network_security_group_name = "${azurerm_network_security_group.techsg.name}"
}

resource "azurerm_network_security_rule" "techsr4" {
  name                        = "port3"
  priority                    = 104
  direction                   = "outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "7050"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.tech.name}"
  network_security_group_name = "${azurerm_network_security_group.techsg.name}"
}
resource "azurerm_network_security_rule" "appssr1" {
  name                        = "ssh"
  priority                    = 100
  direction                   = "inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.apps.name}"
  network_security_group_name = "${azurerm_network_security_group.appssg.name}"
}
resource "azurerm_network_security_rule" "appssr2" {
  name                        = "port1"
  priority                    = 101
  direction                   = "inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "1251"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.apps.name}"
  network_security_group_name = "${azurerm_network_security_group.appssg.name}"
}
resource "azurerm_network_security_rule" "appssr3" {
  name                        = "port2"
  priority                    = 102
  direction                   = "inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "7050"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.apps.name}"
  network_security_group_name = "${azurerm_network_security_group.appssg.name}"
}

resource "azurerm_network_security_rule" "appssr4" {
  name                        = "port3"
  priority                    = 103
  direction                   = "outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "7050"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.apps.name}"
  network_security_group_name = "${azurerm_network_security_group.appssg.name}"
}

resource "azurerm_network_security_rule" "appssr5" {
  name                        = "port4"
  priority                    = 104
  direction                   = "outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "1251"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.apps.name}"
  network_security_group_name = "${azurerm_network_security_group.appssg.name}"
}

resource "azurerm_network_security_rule" "datassr1" {
  name                        = "ssh"
  priority                    = 100
  direction                   = "inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.data.name}"
  network_security_group_name = "${azurerm_network_security_group.datasg.name}"
}
resource "azurerm_network_security_rule" "datassr2" {
  name                        = "port1"
  priority                    = 101
  direction                   = "inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "1251"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.data.name}"
  network_security_group_name = "${azurerm_network_security_group.datasg.name}"
}

resource "azurerm_network_security_rule" "datassr3" {
  name                        = "port2"
  priority                    = 102
  direction                   = "outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "1251"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.data.name}"
  network_security_group_name = "${azurerm_network_security_group.datasg.name}"
}
resource "azurerm_network_security_rule" "datassr4" {
  name                        = "port3"
  priority                    = 104
  direction                   = "inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "7050"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.data.name}"
  network_security_group_name = "${azurerm_network_security_group.datasg.name}"
}
resource "azurerm_network_security_rule" "datassr5" {
  name                        = "port4"
  priority                    = 105
  direction                   = "outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "445"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.data.name}"
  network_security_group_name = "${azurerm_network_security_group.datasg.name}"
}

resource "azurerm_public_ip" "loadlb" {
  name                = "ipbalancer"
  location            = "${azurerm_resource_group.tech.location}"
  resource_group_name = "${azurerm_resource_group.tech.name}"
  allocation_method   = "Dynamic"

  tags = {
    environment = "Apps"
  }
}

resource "azurerm_lb" "loadb" {
  name                = "loadBalancer"
  location            = "West US"
  resource_group_name = "${azurerm_resource_group.tech.name}"

  frontend_ip_configuration {
    name                 = "PublicIPAddress1"
    public_ip_address_id = "${azurerm_public_ip.loadlb.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "loadb" {
  name                = "backendpool"
  resource_group_name = "${azurerm_resource_group.tech.name}"
  loadbalancer_id     = "${azurerm_lb.loadb.id}"
}


resource "azurerm_lb_nat_rule" "loadb" {
  resource_group_name            = "${azurerm_resource_group.tech.name}"
  loadbalancer_id                = "${azurerm_lb.loadb.id}"
  name                           = "Balancer"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 7050
  frontend_ip_configuration_name = "PublicIPAddress1"
}
resource "azurerm_availability_set" "azure" {
  name                = "acceptanceAvailabilitySet1"
  location            = "West US"
  resource_group_name = "${azurerm_resource_group.tech.name}"
  managed             = "true"
}

resource "azurerm_virtual_machine" "techvm" {
  count                 = 2
  name                  = "${var.vmG1}-${count.index}"
  location              = "${azurerm_resource_group.tech.location}"
  resource_group_name   = "${azurerm_resource_group.tech.name}"
  network_interface_ids =  ["${element(azurerm_network_interface.techni.*.id, count.index)}"]
  vm_size               = "Standard_B1ms"


  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisktech-${count.index}"
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
    environment = "Tech"
  }
}

resource "azurerm_virtual_machine" "appsvm" {
  name                  = "${var.vmG2}"
  location              = "${azurerm_resource_group.apps.location}"
  resource_group_name   = "${azurerm_resource_group.apps.name}"
  network_interface_ids = ["${azurerm_network_interface.appsni.id}"]
  vm_size               = "Standard_B1ms"


  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdiskapps"
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
    environment = "Apps"
  }
}

resource "azurerm_virtual_machine" "datavm" {
  name                  = "${var.vmG3}"
  location              = "${azurerm_resource_group.data.location}"
  resource_group_name   = "${azurerm_resource_group.data.name}"
  network_interface_ids = ["${azurerm_network_interface.datani.id}"]
  vm_size               = "Standard_B1ms"


  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdiskdata"
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
    environment = "Data"
  }
}