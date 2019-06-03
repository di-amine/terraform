data "azurerm_resource_group" "main1" {
  name = "tp3"
}

data "azurerm_virtual_network" "main1" {
  name                = "tp3-vnet"
  resource_group_name = "tp3"
}

data "azurerm_subnet" "subnet1" {
  name                 = "default"
  virtual_network_name = "tp3-vnet"
  resource_group_name  = "tp3"
}

