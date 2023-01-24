# =====================
# Enable databag
# =====================
# DATABAG_CFG:enable

if [[ "${disable_cloud_init}" = "y" ]]; then
  test -d /etc/cloud && touch /etc/cloud/cloud-init.disabled
fi
