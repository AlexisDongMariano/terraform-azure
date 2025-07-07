resource "azurerm_key_vault" "mtc-kv" {
  name                       = "mtc-keyvault-adm"
  location                   = azurerm_resource_group.mtc-rg.location
  resource_group_name        = azurerm_resource_group.mtc-rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = true
  enable_rbac_authorization  = true

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }

  tags = {
    environment = "dev"
  }

}

data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "mtc-kv-admin" {
  scope                = azurerm_key_vault.mtc-kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = "994aad87-f45e-4e05-a392-8cee10f4eda6"
}

resource "azurerm_key_vault_key" "mtc-key" {
  name         = "mtc-key"
  key_vault_id = azurerm_key_vault.mtc-kv.id
  key_type     = "RSA"
  key_size     = 4096

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  tags = {
    environment = "dev"
  }
}
