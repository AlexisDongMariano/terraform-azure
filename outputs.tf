output "vault_uri" {
  value = azurerm_key_vault.mtc-kv.vault_uri
}

output "disk_encryption_set_id" {
  value = azurerm_disk_encryption_set.mtc-des.id
}