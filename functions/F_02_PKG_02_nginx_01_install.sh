# ###########################################################
# Install the prerequisites
# ###########################################################
# Should be installed already
apt install -y curl gnupg2 ca-certificates lsb-release ubuntu-keyring

# ###########################################################
# Install Nginx
# ###########################################################

# Import an official nginx signing key so apt could verify the packages authenticity. Fetch the key:
curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
    | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null

# Verify that the downloaded file contains the proper key:
local nginx_gpg_check="$(gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg | grep -o "573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62")"

if [[ -z "${nginx_gpg_check}" ]]; then
  echo "Nginx repo fingerprint - gpg check FAILED!"
  echo "Please ref. https://nginx.org/en/linux_packages.html#Ubuntu"
  exit 1
fi

# To set up the apt repository for stable nginx packages, run the following command:
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
    | tee /etc/apt/sources.list.d/nginx.list

# Set up repository pinning to prefer our packages over distribution-provided ones:
echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" \
    | tee /etc/apt/preferences.d/99nginx

# To install nginx, run the following commands:
apt update
apt install -y nginx
