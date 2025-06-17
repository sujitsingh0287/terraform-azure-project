# resource "azurerm_resource_group" "RG" {
#    count = length(var.rg_name)
#   name     = var.rg_name[count.index]
#   location = var.location
# }


resource "azurerm_resource_group" "RG" {
  name     = var.rg_name
  location = var.location
}

# 2. Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "singhamvnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.RG.name
}

# 3. Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "singhamsubnet"
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# 4. Public IP
resource "azurerm_public_ip" "public_ip" {
  name                = "singham-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.RG.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

# 5. Network Interface (with Public IP)
resource "azurerm_network_interface" "nic" {
  name                = "my-windows-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.RG.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# 6. Windows Virtual Machine
resource "azurerm_windows_virtual_machine" "VM" {
  name                = "singhamvm"
  location            = var.location
  resource_group_name = azurerm_resource_group.RG.name
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  admin_password      = "azurecloud@12345"

  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    name                 = "my-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}


