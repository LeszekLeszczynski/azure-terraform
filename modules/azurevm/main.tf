resource "azurerm_public_ip" "learningpublicip" {
    name                         = "learningPublicIP"
    location                     = "westeurope"
    resource_group_name          = "${var.resource_group}"
    allocation_method            = "Dynamic"

    tags = {
        purpose = "Learning"
    }
}

resource "azurerm_network_security_group" "learningnsg" {
    name                = "learningSecurityGroup"
    location            = "westeurope"
    resource_group_name = "${var.resource_group}"

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        purpose = "Learning"
    }
}

resource "azurerm_network_interface" "learningnic" {
    name                        = "learningNIC"
    location                    = "westeurope"
    resource_group_name         = "${var.resource_group}"

    ip_configuration {
        name                          = "learningNicConfiguration"
        subnet_id                     = "${var.subnet}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.learningpublicip.id
    }

    tags = {
        purpose = "Learning"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = azurerm_network_interface.learningnic.id
    network_security_group_id = azurerm_network_security_group.learningnsg.id
}

resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${var.resource_group}"
    }

    byte_length = 8
}

resource "azurerm_storage_account" "learningstorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = "${var.resource_group}"
    location                    = "westeurope"
    account_replication_type    = "LRS"
    account_tier                = "Standard"

    tags = {
        purpose = "Learning"
    }
}

# TODO sort this out
resource "tls_private_key" "leszek_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}

#output "tls_private_key" { value = tls_private_key.leszek_ssh.private_key_pem }

resource "azurerm_linux_virtual_machine" "learningvm" {
    name                  = "learningVM"
    location              = "westeurope"
    resource_group_name   = "${var.resource_group}"
    network_interface_ids = [azurerm_network_interface.learningnic.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "learningvm"
    admin_username = "azureuser"
    disable_password_authentication = true

    admin_ssh_key {
        username       = "azureuser"
        public_key     = file("~/.ssh/id_rsa.pub")
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.learningstorageaccount.primary_blob_endpoint
    }

    tags = {
        purpose = "Learning"
    }
}