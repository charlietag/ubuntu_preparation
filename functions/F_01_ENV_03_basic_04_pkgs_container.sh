echo "==============================="
echo "  Installing Container Management packages..."
echo "==============================="

local pkgs_list=""

pkgs_list="${pkgs_list} podman buildah skopeo"

#-----------------------------------------------------------------------------------------
#Package Start to Install
#-----------------------------------------------------------------------------------------
apt install -y ${pkgs_list}

apt install -y python3-pip
pip3 install podman-compose


# Disable related services
systemctl list-unit-files|grep podman | awk '{print $1}' | xargs echo  | xargs -I{} bash -c "systemctl stop {}; systemctl disable {}"
