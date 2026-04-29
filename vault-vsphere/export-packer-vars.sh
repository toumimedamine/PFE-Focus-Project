#!/bin/bash
# =============================================
# Script pour charger les secrets depuis Vault
# =============================================
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='root'

echo "🔄 Chargement des secrets depuis Vault..."

# Charger les secrets Windows
echo "📥 Chargement des variables Windows..."
while IFS='=' read -r key value; do
    export "WIN_${key}=${value}"
done < <(vault kv get -format=json kv-v2/packer/windows-2025 | jq -r '.data.data | to_entries[] | "\(.key)=\(.value)"')

# Charger les secrets Ubuntu
echo "📥 Chargement des variables Ubuntu..."
while IFS='=' read -r key value; do
    export "UBU_${key}=${value}"
done < <(vault kv get -format=json kv-v2/packer/ubuntu-24.04 | jq -r '.data.data | to_entries[] | "\(.key)=\(.value)"')

echo "✅ Secrets chargés avec succès depuis Vault !"
echo "   - vcenter_server         = $WIN_vcenter_server"
echo "   - vcenter_user           = $WIN_vcenter_user"
echo "   - template_name (win)    = $WIN_template_name"
echo "   - iso_path (win)         = $WIN_iso_path"
echo "   - template_name (ubuntu) = $UBU_template_name"
echo "   - iso_path (ubuntu)      = $UBU_iso_path"
