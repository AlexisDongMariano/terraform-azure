terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.100"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "app02-rg" {
  name     = "app02-rg"
  location = "Canada Central"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_virtual_network" "app02-vn" {
  name                = "app02-vn"
  resource_group_name = azurerm_resource_group.app02-rg.name
  location            = azurerm_resource_group.app02-rg.location
  address_space       = ["172.17.0.0/16"]

  tags = {
    environment = "dev"
  }
}

resource "azurerm_subnet" "app02-subnet" {
  name                 = "app02-subnet"
  resource_group_name  = azurerm_resource_group.app02-rg.name
  virtual_network_name = azurerm_virtual_network.app02-vn.name
  address_prefixes     = ["172.17.1.0/24"]
}

resource "azurerm_linux_virtual_machine_scale_set" "app02-vmss" {
  name                = "app02-vmss"
  resource_group_name = azurerm_resource_group.app02-rg.name
  location            = azurerm_resource_group.app02-rg.location
  sku                 = "Standard_B1s"
  instances           = 1
  admin_username      = "adminuser"

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/mtcazurekey.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = "nic"
    primary = true

    ip_configuration {
      name      = "ipconfig"
      subnet_id = azurerm_subnet.app02-subnet.id
      primary   = true
    }
  }

  tags = {
    environment = "dev"
  }
}

resource "azurerm_monitor_autoscale_setting" "app02-vmss-autoscaling" {
  name                = "app02-vmss-autoscaling"
  resource_group_name = azurerm_resource_group.app02-rg.name
  location            = azurerm_resource_group.app02-rg.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.app02-vmss.id

  profile {
    name = "defaultProfile"

    capacity {
      default = 1
      minimum = 1
      maximum = 3
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.app02-vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 70
        metric_namespace   = "microsoft.compute/virtualmachinescalesets"
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT2M"
      }

    }
  }

  tags = {
    environment = "dev"
  }
}