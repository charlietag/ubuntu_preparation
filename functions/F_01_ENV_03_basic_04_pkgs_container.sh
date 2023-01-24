echo "==============================="
echo "  Installing Container Management packages..."
echo "==============================="

local pkgs_list=""

pkgs_list="${pkgs_list} podman buildah skopeo"

#-----------------------------------------------------------------------------------------
#Package Start to Install
#-----------------------------------------------------------------------------------------
apt install -y ${pkgs_list}

# Ref. https://packaging.python.org/en/latest/guides/installing-using-linux-tools/#debian-ubuntu
apt install -y python3-pip python3-venv

# WARNING: Running pip as the 'root' user can result in broken permissions and conflicting behaviour with the system package manager. It is recommended to use a virtual environment instead: https://pip.pypa.io/warnings/venv
# pip3 install podman-compose


#-----------------------------------------------------------------------------------------
# Podman 3.x
#-----------------------------------------------------------------------------------------
# Disable related services
systemctl list-unit-files|grep podman | awk '{print $1}' | xargs echo  | xargs -I{} bash -c "systemctl stop {}; systemctl disable {}"
if [[ -f /etc/containers/libpod.conf ]]; then
  sed -re '/cgroup_manager/ s/systemd/cgroupfs/g' -i /etc/containers/libpod.conf
fi

if [[ ! -f /etc/containers/containers.conf ]]; then
  echo "[engine]" > /etc/containers/containers.conf
  echo 'cgroup_manager = "cgroupfs"' >> /etc/containers/containers.conf
fi
