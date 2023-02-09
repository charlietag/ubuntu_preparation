# =====================
# Enable databag
# =====================
# DATABAG_CFG:enable

#-----------------------------------------------------------------------------------------
# Backup default config under /etc/netplan
#-----------------------------------------------------------------------------------------
test -d /etc/netplan/bak || mkdir /etc/netplan/bak
local if_found_netplan_yaml="$(ls /etc/netplan | grep -E "\.yaml$")"
if [[ -n "${if_found_netplan_yaml}" ]]; then
  \cp -a --backup=t /etc/netplan/*.yaml /etc/netplan/bak/
  rm -fr rm -f /etc/netplan/*.yaml
fi


#-----------------------------------------------------------------------------------------
# Modify static IP / DHCP , Disable IPv6, Nameserver
#-----------------------------------------------------------------------------------------
local nameserver="$(echo "${nameservers}" | sed -re 's/[[:blank:]]+/, /g')"
local search="$(echo "${searches}" | sed -re 's/[[:blank:]]+/, /g')"

if [[ "${use_protocol}" = "dhcp" ]]; then
  # ----------------------------------
  # Sample infomation for sample config
  # ----------------------------------
  local this_ip="192.168.1.99/24"
  local this_gateway="192.168.1.254"
  # ----------------------------------

  RENDER_CP_SED ${CONFIG_FOLDER}/etc/netplan/99-network-config_dhcp.yaml /etc/netplan/99-network-config_dhcp.yaml
else
  if [[ "${use_protocol}" = "static" ]]; then
    RENDER_CP_SED ${CONFIG_FOLDER}/etc/netplan/99-network-config_static.yaml /etc/netplan/99-network-config_static.yaml
  fi
fi

#-----------------------------------------------------------------------------------------
# Change nameserver for temp
#-----------------------------------------------------------------------------------------
set -x
cat /dev/null > /etc/resolv.conf

if [[ -n "${searches}" ]]; then
  echo "search ${searches}" >> /etc/resolv.conf
fi

for ns in ${nameservers[@]}; do
  echo "nameserver ${ns}" >> /etc/resolv.conf
done

# sometimes netplan apply , netplay try , will kill current ssh session
#netplan apply

netplan generate
if [[ $? -ne 0 ]]; then
  echo "Network setup failed"
  exit 1
fi
set +x
