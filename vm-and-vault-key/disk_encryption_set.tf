resource "azurerm_disk_encryption_set" "mtc-des" {
  name                = "mtc-des"
  location            = azurerm_resource_group.mtc-rg.location
  resource_group_name = azurerm_resource_group.mtc-rg.name
  key_vault_key_id    = azurerm_key_vault_key.mtc-key.id

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "dev"
  }
}

resource "azurerm_role_assignment" "mtc-des-key-vault-access" {
  scope                = azurerm_key_vault.mtc-kv.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_disk_encryption_set.mtc-des.identity[0].principal_id
}