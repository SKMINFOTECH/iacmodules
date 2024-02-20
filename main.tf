terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}
provider "azurerm" {
  subscription_id = "80ea84e8-afce-4851-928a-9e2219724c69"
  tenant_id = "84f1e4ea-8554-43e1-8709-f0b8589ea118"
  client_id = "00b2ed80-5d6e-470b-a454-87f0ebc6f43c"
  client_secret = "xs58Q~TVswCFlfmWMtRZV_hOx-0hkMfC6Kchzdh3"
  skip_provider_registration = "true"
  features {}
}
locals {
  location                 = "West US"
  resource_group_name      = "1-f1eaf201-playground-sandbox"
}
resource "azurerm_storage_account" "appstore566565637" {
  name                     = "satsappstore566565637"
  resource_group_name      = local.resource_group_name
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  account_kind = "StorageV2"
}
resource "azurerm_storage_container" "data" {
  name                  = "satsdata"
  storage_account_name  = "satsappstore566565637"
  container_access_type = "blob"
  depends_on = [
    azurerm_storage_account.appstore566565637
  ]
}

resource "azurerm_storage_blob" "maintf" {
  name                   = "main.tf"
  storage_account_name   = "satsappstore566565637"
  storage_container_name = "satsdata"
  type                   = "Block"
  source                 = "main.tf"
  depends_on = [
    azurerm_storage_container.data
  ]
}
resource "azurerm_container_group" "example" {
  name                = "${var.prefix}-cont"
  location            = local.location
  resource_group_name = local.resource_group_name
  ip_address_type     = "Public"
  dns_name_label      = "${var.prefix}-cont"
  os_type             = "Linux"
  depends_on = [
    azurerm_storage_container.data
  ]

  container {
    name   = "hw"
    image  = "docker.io/travelhelper0h/projectsconfigserver:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 8888
      protocol = "TCP"
    }
  }

  tags = {
    environment = "testing"
  }
}
