# =====================
# Enable databag
# =====================
# DATABAG_CFG:enable


if $(command -v nodejs > /dev/null); then
  if ! [[ -f /etc/apt/sources.list.d/nodesource.list ]]; then
    echo "NodeJS is already installed, through ubuntu repo !!"
    echo ""
    apt purge -y nodejs
  fi
fi

if $(command -v yarn > /dev/null); then
  if ! [[ -f /etc/apt/sources.list.d/yarn.list ]]; then
    echo "Yarn is already installed, through ubuntu repo !!"
    echo ""
    apt purge -y yarn
  fi
fi





# ###########################################################
## Run `apt-get install -y nodejs` to install Node.js 18.x and npm
## You may also need development tools to build native addons:
     # apt-get install gcc g++ make
## To install the Yarn package manager, run:
     # curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null
     # echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list
     # apt-get update && apt-get install -y yarn
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

curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null




test -f /etc/apt/sources.list.d/yarn.list && rm -f /etc/apt/sources.list.d/yarn.list

echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list
apt-get update && apt-get -y install yarn


# --------------------------------------------------------------------------------------
# origin:   F_02_PKG_04_yarn_install.sh
# --------------------------------------------------------------------------------------
# Make sure NodeJs is installed
#if ! $(command -v npm > /dev/null); then
#  echo "NodeJS is not installed correctly !!!"
#  echo ""
#  exit
#fi

#----------------------------------------
# Yarn 1.22.x, just use apt repo above
#----------------------------------------

#----------------------------------------
# Yarn 2.x
#----------------------------------------
#For Rails 5.1+ , which is supporting yarn
#npm install -g yarn

# --------------------------------------------------------------------------------------
