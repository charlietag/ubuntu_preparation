# =====================
# Enable databag
# =====================
# DATABAG_CFG:enable

echo "========================================="
echo "      Install ruby ${ruby_version}"
echo "========================================="
# -------------------------------------------------------------------------------------------------
# if use os ruby, then will failed while install gems, due to lack of permission of os gem path
# -------------------------------------------------------------------------------------------------
# local ruby_version_found="$(su -l $current_user -c "ruby -v 2>/dev/null" | grep -Eo "ruby[[:space:]]+${ruby_version}")"
# if defined ruby version exists in OS built-in version, then skip rvm install
# if [[ -z "${ruby_version_found}" ]]; then
#   su -l $current_user -c "rvm install ${ruby_version}"
# fi
# -------------------------------------------------------------------------------------------------

# ruby -e 'puts RbConfig::CONFIG["configure_args"]'
#   Due to default precomipled rvm ruby use argv `--enable-load-relative` and this will cause foreman script failed, everytime `rails new project` (rails 7.1.3)
#   add --disable-binary while rvm install
su -l $current_user -c "rvm autolibs disable"
if [[ "${ruby_version}" =~ "3.2" ]]; then
  su -l $current_user -c "rvm install ${ruby_version} -C \"--enable-yjit\""
elif [[ "${ruby_version}" =~ "3.3" ]]; then
  su -l $current_user -c "rvm install ${ruby_version} -C \"--enable-yjit\""
else
  su -l $current_user -c "rvm install ${ruby_version} --disable-binary"
fi

su -l $current_user -c "rvm use ${ruby_version} --default"

# ------------------------------------------------------------
# do not gem update to avoid rails compatibility
# ------------------------------------------------------------
echo "========================================="
echo "      gem update --system"
echo "========================================="
su -l $current_user -c "gem update --system"
echo ""

echo "========================================="
echo "      gem install bundler"
echo "========================================="
su -l $current_user -c "gem install bundler"
echo ""
#
# echo "========================================="
# echo "      gem update"
# echo "========================================="
# su -l $current_user -c "yes | gem update"
# echo ""
# ------------------------------------------------------------

# --- Comment these lines , in case cleanup legacy gems which are still in use, for the same ruby version ---
#echo "========================================="
#echo "      gem cleanup, delete old gems"
#echo "========================================="
#su -l $current_user -c "gem cleanup"
#echo ""

#echo "========================================="
#echo "      gem install bundler"
#echo "========================================="
#su -l $current_user -c "gem install bundler"
#echo ""
# --- Comment these lines , in case cleanup lagacy gems which are still in use, for the same ruby version ---

echo "========================================="
echo "(Rails:${rails_version}) gem install rails"
echo "========================================="
su -l $current_user -c "gem install rails -v \"~> ${rails_version}.0\""
echo ""
