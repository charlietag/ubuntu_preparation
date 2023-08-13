# https://github.com/pyenv/pyenv/wiki#suggested-build-environment

echo "==============================="
echo "  Installing packages pyenv suggested..."
echo "==============================="

local pkgs_list=""

pkgs_list="${pkgs_list} build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev curl libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev"

#-----------------------------------------------------------------------------------------
#Package Start to Install
#-----------------------------------------------------------------------------------------
apt install -y ${pkgs_list}

