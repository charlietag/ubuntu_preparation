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
  local if_apt_yarn_found="$(dpkg -l yarn 2>/dev/null | grep "ii")"
  if [[ -n "${if_apt_yarn_found}" ]]; then
    echo "Yarn is already installed, through ubuntu repo !!"
    echo ""
    apt purge -y yarn
  fi
fi

if $(command -v bun > /dev/null); then
  local if_apt_bun_found="$(dpkg -l bun 2>/dev/null | grep "ii")"
  if [[ -n "${if_apt_bun_found}" ]]; then
    echo "Bun JS is already installed, through ubuntu repo !!"
    echo ""
    apt purge -y bun
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
test -f /etc/apt/keyrings/nodesource.gpg && rm -f /etc/apt/keyrings/nodesource.gpg


# ------------------------------------------------
# Ref. https://github.com/nodesource/distributions#debian-and-ubuntu-based-distributions
apt install -y ca-certificates curl gnupg
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${apt_node_major}.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
apt update
apt-get install -y nodejs

npm install -g npm@latest
# ------------------------------------------------


# ---------- Yarn ---------
## To install the Yarn package manager, run:
npm install --global yarn

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

# ---------- Bun JS ---------
npm install -g bun@${bun_version}

