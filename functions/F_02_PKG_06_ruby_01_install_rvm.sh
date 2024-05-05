# =====================
# Enable databag
# =====================
# DATABAG_CFG:enable

echo "========================================="
echo "      Install RVM"
echo "========================================="
#local rvm_install_retry=5
local rvm_install_retry=5000


############### Install RVM retry Loop #############
#let rvm_install_retry++
#for ((i=1; i<=rvm_install_retry; i++)); do
for ((i=1; ; i++)); do

  # ---------- Check RVM Installation -----------
  #local rvm_check="$(su -l $current_user -c "which rvm 2>/dev/null"  | sed 's/RVM reloaded!//g'  | grep "rvm")"
  local rvm_check="$(su -l $current_user -c "command -v rvm" | sed 's/RVM reloaded!//g' | grep "rvm")"
  if [[ -n "${rvm_check}" ]]; then
    echo "RVM is installed successfully!"
    break
  fi

  if [[ -z "${rvm_check}" ]]; then
    echo "RVM is not installed yet!"
    #[[ $i -eq $rvm_install_retry ]] && exit
    [[ $i -gt $rvm_install_retry ]] && exit
  fi

  echo -n "RVM installation (try: $i) "
  sleep 1; echo -n "."; sleep 1; echo -n "."; sleep 1; echo -n "."; echo ""

  # ---------- Remove gpg key and install gpg -----------
  rm -fr ${current_user_home}/.gnupg
  # default hkp port tcp/udp 11371, to prevent from firewall issue, force it to port 80 (make sure vendor provides port 80)
  # su -l $current_user -c "gpg --keyserver ${rvm_gpg_key_src} --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB"

  # (less secure way) comment out above to manually install through rvm.io
  # su -l $current_user -c "curl -sSL https://rvm.io/mpapis.asc | gpg --import - ; \
  #                         curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -; \
  su -l $current_user -c "curl -sSL https://raw.githubusercontent.com/charlietag/github_share_folder/master/rvm_gpg_public_keys/mpapis.asc | gpg --import - ; \
                          curl -sSL https://raw.githubusercontent.com/charlietag/github_share_folder/master/rvm_gpg_public_keys/pkuczynski.asc | gpg --import -; \
                          echo 409B6B1796C275462A1703113804BB82D39DC0E3:6: | gpg2 --import-ownertrust ; \
                          echo 7D2BAF1CF37B13E2069D6956105BD0E739499BDB:6: | gpg2 --import-ownertrust; \
                          echo --------------------------------------------- ; \
                          gpg --list-keys; \
                          echo ---------------------------------------------"

  # if [[ $? -ne 0 ]]; then
  #   echo "rvm gpg keyserver installation failed!"
  #   continue
  # fi

  local rvm_key_status=0
  test -z "$(su -l $current_user -c "gpg --list-keys | grep 409B6B1796C275462A1703113804BB82D39DC0E3")" && rvm_key_status=1
  test -z "$(su -l $current_user -c "gpg --list-keys | grep 7D2BAF1CF37B13E2069D6956105BD0E739499BDB")" && rvm_key_status=1

  if [[ ${rvm_key_status} -ne 0 ]]; then
    echo "rvm gpg keyserver installation failed!"
    continue
  fi

  # ---------- Install RVM -----------
  # su -l $current_user -c "\curl -sSL https://get.rvm.io | bash -s ${rvm_version}"
  su -l $current_user -c "\curl -sSL https://raw.githubusercontent.com/rvm/rvm/master/binscripts/rvm-installer | bash -s ${rvm_version}"

  # Ubuntu 24.04: Missing required packages: libncurses5-dev. Actually it's replaced by libncurses-dev
  # The following will add config under: (see `rvm info`)
  #     cat ${rvm_path}/user/db
  #     User settings, overrides db settings and persists across installs.
  #     autolibs=disable
  # And this will avoid `rvm requirements` to check and install missing packages all the time
  su -l $current_user -c "rvm autolibs disable"
done
echo ""
############### Install RVM retry Loop #############


# ----- rvm setup .rvmrc ------
echo "------------------------------------------"
echo "Setup .rvmrc"
echo "------------------------------------------"
task_copy_using_cat_user_home
echo ""

