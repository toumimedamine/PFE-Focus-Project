#!/usr/bin/env bash
set -euo pipefail


prompt_with_default() {
  local prompt="$1"
  local default_value="$2"
  local value=""
  read -r -p "$prompt [$default_value]: " value
  if [[ -z "$value" ]]; then
    value="$default_value"
  fi
  printf '%s' "$value"
}


trim_spaces() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}


choose_menu_option() {
  local title="$1"
  shift
  local -a options=("$@")
  local choice=""
  local idx=0


  echo >&2
  echo "$title" >&2
  for option in "${options[@]}"; do
    idx=$((idx + 1))
    echo "  ${option}" >&2
  done


  while true; do
    read -r -p "Votre choix: " choice
    choice="${choice,,}"
    case "$choice" in
      oui) choice="a" ;;
      non) choice="b" ;;
    esac
    for option in "${options[@]}"; do
      if [[ "${option%%)*}" == "$choice" ]]; then
        printf '%s' "$choice"
        return 0
      fi
    done
    echo "Choix invalide. Merci de choisir une lettre proposee dans le menu." >&2
  done
}


to_hcl_string_list() {
  local csv="$1"
  local -a values=()
  local formatted="["
  local trimmed=""
  IFS=',' read -r -a values <<< "$csv"
  for value in "${values[@]}"; do
    trimmed="$(trim_spaces "$value")"
    if [[ -n "$trimmed" ]]; then
      if [[ "$formatted" != "[" ]]; then
        formatted+=", "
      fi
      formatted+="\"$trimmed\""
    fi
  done
  formatted+="]"
  printf '%s' "$formatted"
}


echo "=========================================="
echo "  Assistant de creation VM (Terraform)"
echo "=========================================="


storage_choice="$(choose_menu_option "1) Type de stockage" \
  "a) Thin provisioning" \
  "b) Thick provisioning")"
case "$storage_choice" in
  a) storage_type="thin" ;;
  b) storage_type="thick" ;;
esac


ip_choice="$(choose_menu_option "2) Mode d'adressage IP" \
  "a) DHCP" \
  "b) Statique (manuel)" \
  "c) Automatique (index + increment)")"
case "$ip_choice" in
  a) ip_mode="dhcp" ;;
  b) ip_mode="statique" ;;
  c) ip_mode="automatique" ;;
esac


power_on_value="true"
power_choice="$(choose_menu_option "3) Demarrage de la VM apres creation" \
  "a) Oui (demarrer)" \
  "b) Non (ne pas demarrer)")"
case "$power_choice" in
  a) power_on_value="true" ;;
  b) power_on_value="false" ;;
esac


if [[ "$power_on_value" == "false" ]]; then
  echo
  echo "Note: ce provider vSphere peut ignorer cette option selon sa version."
fi


tmp_vars_file="$(mktemp)"
trap 'rm -f "$tmp_vars_file"' EXIT


{
  echo "storage_provisioning_type = \"$storage_type\""
  echo "ip_addressing_mode = \"$ip_mode\""
  echo "power_on_after_creation = $power_on_value"
} > "$tmp_vars_file"


if [[ "$ip_mode" == "statique" ]]; then
  echo
  echo "Configuration IP statique (manuelle)"
  static_ips=""
  while [[ -z "$static_ips" ]]; do
    read -r -p "Liste IP statiques (ex: 10.1.10.21,10.1.10.22): " static_ips
  done
  static_netmask="$(prompt_with_default "Netmask IPv4 statique" "24")"
  static_gateway=""
  while [[ -z "$static_gateway" ]]; do
    read -r -p "Passerelle IPv4 statique: " static_gateway
  done
  static_dns="$(prompt_with_default "DNS statiques (ex: 8.8.8.8)" "8.8.8.8")"


  {
    echo "static_ipv4_addresses = $(to_hcl_string_list "$static_ips")"
    echo "static_ipv4_netmask = $static_netmask"
    echo "static_ipv4_gateway = \"$static_gateway\""
    echo "static_dns_servers = $(to_hcl_string_list "$static_dns")"
  } >> "$tmp_vars_file"
elif [[ "$ip_mode" == "automatique" ]]; then
  echo
  echo "Configuration IP automatique (index + increment)"
  auto_subnet="$(prompt_with_default "Subnet CIDR automatique" "10.1.10.0/24")"
  auto_start_host="$(prompt_with_default "Host de depart automatique" "10")"
  auto_gateway="$(prompt_with_default "Passerelle automatique" "10.1.10.254")"
  auto_dns="$(prompt_with_default "DNS automatique" "8.8.8.8")"


  {
    echo "auto_ipv4_subnet_cidr = \"$auto_subnet\""
    echo "auto_ipv4_start_host = $auto_start_host"
    echo "auto_ipv4_gateway = \"$auto_gateway\""
    echo "auto_dns_servers = $(to_hcl_string_list "$auto_dns")"
  } >> "$tmp_vars_file"
fi


echo
echo "Recapitulatif:"
echo "  - Stockage: $storage_type"
echo "  - Mode IP : $ip_mode"
echo "  - Demarrage apres creation: $power_on_value"
echo
echo "Lancement: terraform apply -var-file=\"$tmp_vars_file\""
terraform apply -var-file="$tmp_vars_file"





