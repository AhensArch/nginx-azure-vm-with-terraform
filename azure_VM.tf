#Used the data source for reading existing resource
data "azurerm_resource_group" "ahens_resource_group" {
  name = "1-654d4723-playground-sandbox"
}

#Create a virtual network
resource "azurerm_virtual_network" "ahens_virtual_network" {
  name                = "ahens-virtual-network"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.ahens_resource_group.location
  resource_group_name = data.azurerm_resource_group.ahens_resource_group.name
}

#Create the Subnet (Linked to VNet)
resource "azurerm_subnet" "ahens_subnet" {
  name                 = "ahens-subnet"
  resource_group_name  = data.azurerm_resource_group.ahens_resource_group.name
  virtual_network_name = azurerm_virtual_network.ahens_virtual_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create the Public IP resource
resource "azurerm_public_ip" "ahens_public_ip" {
  name                = "ahens-public-ip"
  location            = data.azurerm_resource_group.ahens_resource_group.location
  resource_group_name = data.azurerm_resource_group.ahens_resource_group.name
  allocation_method   = "Static" # Static ensures the IP populates immediately in output blocks
  sku                 = "Standard"
}

# Network Interface (NIC) bridging the Subnet and Public IP
resource "azurerm_network_interface" "ahens_nic" {
  name                = "ahens-nic"
  location            = data.azurerm_resource_group.ahens_resource_group.location
  resource_group_name = data.azurerm_resource_group.ahens_resource_group.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.ahens_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ahens_public_ip.id # Linked Public IP
  }
}

# Network Security Group (Firewall) to allow SSH & HTTP
resource "azurerm_network_security_group" "ahens_nsg" {
  name                = "ahens-nsg"
  location            = data.azurerm_resource_group.ahens_resource_group.location
  resource_group_name = data.azurerm_resource_group.ahens_resource_group.name

  # ADD THIS NEW BLOCK FOR HTTP ACCESS
  security_rule {
    name                       = "allow_http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80" # HTTP Port
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # ADD THIS NEW BLOCK FOR SSH ACCESS
  security_rule {
    name                   = "allow_ssh"
    priority               = 110 # Priority must be unique
    direction              = "Inbound"
    access                 = "Allow"
    protocol               = "Tcp"
    source_port_range      = "*"
    destination_port_range = "22" # SSH Port

    # Best Practice: Replace "*" with your actual local public IP so no one can access it 
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate the NSG with your Subnet
resource "azurerm_subnet_network_security_group_association" "ahens_nsg_assoc" {
  subnet_id                 = azurerm_subnet.ahens_subnet.id
  network_security_group_id = azurerm_network_security_group.ahens_nsg.id
}

# The Virtual Machine
resource "azurerm_virtual_machine" "ahens_virtual_machine" {
  name                  = "ahens-vm"
  location              = data.azurerm_resource_group.ahens_resource_group.location
  resource_group_name   = data.azurerm_resource_group.ahens_resource_group.name
  network_interface_ids = [azurerm_network_interface.ahens_nic.id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  #delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "ahens-osdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "ahens"
    admin_username = "stellar"
    admin_password = "Password1234!"
    # 🚀 ADD THIS LINE TO LOAD AND PASS THE NGINX SCRIPT
    custom_data = filebase64("${path.module}/install_nginx.sh")
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}

# 9. Output block to print the IP automatically when done
output "vm_public_ip" {
  value       = azurerm_public_ip.ahens_public_ip.ip_address
  description = "The public IP address assigned to your VM."
}