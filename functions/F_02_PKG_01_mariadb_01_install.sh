# =====================
# Enable databag
# =====================
# DATABAG_CFG:disable

local pkgs_list=""

# ###########################################################
# To be installed packages
# ###########################################################
pkgs_list="${pkgs_list} mariadb-server"
pkgs_list="${pkgs_list} libmariadb-dev libmariadb-dev-compat"

#-----------------------------------------------------------------------------------------
#Package Start to Install
#-----------------------------------------------------------------------------------------
apt install -y ${pkgs_list}

echo "==============================="
echo "        Disable mariadb"
echo "==============================="
echo -e "--- systemctl disable mariadb ---"
systemctl disable mariadb

echo "==============================="
echo "  Disable mariadb done"
echo "==============================="
