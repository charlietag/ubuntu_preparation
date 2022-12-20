# =====================
# Enable databag
# =====================
# DATABAG_CFG:enable

if [[ "${disable_cloud_init}" = "y" ]]; then
  touch /etc/cloud/cloud-init.disabled
fi
