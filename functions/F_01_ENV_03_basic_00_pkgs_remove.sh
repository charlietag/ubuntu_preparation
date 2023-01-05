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
done

