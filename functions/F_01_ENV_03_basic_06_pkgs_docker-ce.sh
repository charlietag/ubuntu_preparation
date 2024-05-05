
# Ref. https://docs.docker.com/engine/install/ubuntu/
echo "==============================="
echo "  Remove unofficial Docker packages..."
echo "==============================="
# for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do apt remove -y $pkg; done
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
  local if_pkg_found="$(dpkg -l ${pkg} 2>/dev/null | grep -E "^ii")"
  if [[ -n "${if_pkg_found}" ]]; then
    apt remove -y $pkg
  fi
done


echo "==============================="
echo "  Add Docker-CE repo ..."
echo "==============================="
# Add Docker's official GPG key:
# apt install -y ca-certificates curl
for pkg in ca-certificates curl; do
  local if_pkg_found="$(dpkg -l ${pkg} 2>/dev/null | grep -E "^ii")"
  if [[ -z "${if_pkg_found}" ]]; then
    apt install -y $pkg
  fi
done

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update


echo "==============================="
echo "  Installing Docker-CE..."
echo "==============================="
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

#-----------------------------------------------------------------------------------------
# Docker CE
#-----------------------------------------------------------------------------------------
# Disable related services
systemctl list-unit-files|grep -i "docker" | awk '{print $1}' | xargs echo  | xargs -I{} bash -c "systemctl stop {}; systemctl disable {}"
