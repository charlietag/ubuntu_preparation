# =====================
# Enable databag
# =====================
# DATABAG_CFG:enable

# -------- Remove unused packages --------
local pkg_exists
for remove_pkg_name in ${remove_pkg_names[@]}; do
  pkg_exists=""
  pkg_exists="$(dpkg -l ${remove_pkg_name} 2>/dev/null | grep -E "^ii")"

  if [[ -n "${pkg_exists}" ]]; then
    echo "Removing pkg :  ${remove_pkg_name} ..."
    # apt purge -y ${remove_pkg_name}
    # apt autoremove -y ${remove_pkg_name}
    apt remove --purge --autoremove -y ${remove_pkg_name}
    systemctl daemon-reload
  fi

  if [[ "${pkg_exists}" = "cloud-init" ]]; then
    # Delete cloud-init related file
    readlink -m /usr/lib/systemd/system/cloud-* | xargs -i basename {} | xargs -i systemctl stop {}
    systemctl list-unit-files |grep 'cloud\-' | awk '{print $1}' | xargs -i systemctl stop {}

    readlink -m /usr/lib/systemd/system/cloud-* | xargs -i basename {} | xargs -i systemctl disable {}
    systemctl list-unit-files |grep 'cloud\-' | awk '{print $1}' | xargs -i systemctl disable {}

    SAFE_DELETE "/usr/lib/systemd/system/cloud-*"
    SAFE_DELETE "/usr/src/cloud-init"
    SAFE_DELETE "/etc/cloud"

    systemctl daemon-reload

  fi
done
