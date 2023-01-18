# =====================
# Enable databag
# =====================
# DATABAG_CFG:enable

# ###########################################################
## Run `sudo apt-get install -y nodejs` to install Node.js 18.x and npm
## You may also need development tools to build native addons:
     # sudo apt-get install gcc g++ make
## To install the Yarn package manager, run:
     # curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null
     # echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
     # sudo apt-get update && sudo apt-get install yarn
# ###########################################################

# ###########################################################
# Using 3rd repo
# ###########################################################
# ---------- NodeJS ---------
# curl --silent --location "${node_apt_repo}" | bash -

test -f /etc/apt/sources.list.d/nodesource.list && rm -f /etc/apt/sources.list.d/nodesource.list

curl -fsSL ${node_apt_repo} | bash - && \
apt-get install -y nodejs gcc g++ make


# ---------- Yarn ---------
## To install the Yarn package manager, run:
test -f /usr/share/keyrings/yarnkey.gpg && rm -f /usr/share/keyrings/yarnkey.gpg

curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null




test -f /etc/apt/sources.list.d/yarn.list && rm -f /etc/apt/sources.list.d/yarn.list

echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
apt-get update && apt-get install yarn
