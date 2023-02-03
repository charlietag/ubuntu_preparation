# =====================
# Enable databag
# =====================
# DATABAG_CFG:enable

# --------------------------------------------------
# Package: needrestart
# --------------------------------------------------
# How it works: dpkg calls needrestart
# Prompt to check if related services need to be restarted
# Ref. https://askubuntu.com/questions/1367139/apt-get-upgrade-auto-restart-services
# Ref. https://stackoverflow.com/questions/73397110/how-to-stop-ubuntu-pop-up-daemons-using-outdated-libraries-when-using-apt-to-i

if [[ "${disable_apt_interactive_mode}" = "y" ]]; then
  task_copy_using_cat

  # /etc/profile.d/zz99-disable_apt_interactive_mode.sh rendered
  # export DEBIAN_FRONTEND again for this session
  export DEBIAN_FRONTEND="noninteractive"
fi

# --------------------------------------------------
# Package: ucf
# --------------------------------------------------
# How it works: dpkg calls ucf
# Prompt to check if config files need to be retained

# Ref. https://devops.stackexchange.com/questions/4912/how-to-keep-configuration-files-automatically-during-apt-get-upgrade-or-install
# For ansible
# Ref. https://serverfault.com/questions/1007365/how-to-force-ansible-apt-upgrade-to-install-new-configuration-files-force-confn
# For ansible

# Ref. https://askubuntu.com/questions/1421676/automatically-keep-current-sshd-config-file-when-upgrading-openssh-server
# UCF_FORCE_CONFFOLD=1 apt-get install -y openssh-server

# Ref. https://askubuntu.com/questions/104899/make-apt-get-or-aptitude-run-with-y-but-not-prompt-for-replacement-of-configu
# apt-get update
# apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install -y mypackage1 mypackage2

# Ref. https://serverfault.com/questions/259226/automatically-keep-current-version-of-config-files-when-apt-get-install
# This seems to be dangerous, when doing distro-upgrading
# /etc/apt/apt.conf.d/z99-dpkg-force-conffold.conf
# Dpkg::Options {
#    "--force-confdef";
#    "--force-confold";
# }

# The best way:
# sed -re '/conf_force_conffold=/ s/^#*[[:space:]]*//' -i /etc/ucf.conf
if [[ "${disable_apt_interactive_mode}" = "y" ]]; then
  sed -re '/conf_force_conffold=/ s/^#*[[:space:]]*//' -i /etc/ucf.conf
fi
