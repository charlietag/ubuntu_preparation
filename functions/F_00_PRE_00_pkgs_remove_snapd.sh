
# Remove packages
snap list | tail -n +2 | awk '{print $1}' | grep -vE "^bare|^core|^snapd" | xargs -I{} bash -c "echo --- removing {} \(please wait for awhile\) ---; snap remove --purge {}; echo"

# Remove base packagges
snap list | tail -n +2 | awk '{print $1}' | xargs -I{} bash -c "echo --- removing {} \(please wait for awhile\) ---; snap remove --purge {}; echo"

# Disable snapd services
systemctl list-unit-files |grep snapd | awk '{print $1}' | xargs systemctl disable --now

# Remove snapd
apt autoremove --purge -y snapd
rm -fr /root/snap

echo "--- check snapd folders ---"
echo "msg should be: (No such file or directory)"
echo ""
file /snap /var/snap /var/lib/snapd /var/cache/snapd /usr/lib/snapd ~/snap

# Avoid ubuntu install snapd back
echo "--- creating file /etc/apt/preferences.d/nosnap.pref ---"

cat <<EOF | tee /etc/apt/preferences.d/nosnap.pref
# To prevent repository packages from triggering the installation of Snap,
# this file forbids snapd from being installed by APT.
# For more information: https://linuxmint-user-guide.readthedocs.io/en/latest/snap.html

Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF

# Avoid systemd config changed
systemctl daemon-reload


echo "Snap removed"

echo "--- apt update again ---"
apt clean
apt update


# ----------------------------------
# APT notes
# ----------------------------------
# apt pref config ref. https://www.debian.org/doc/manuals/apt-howto/ch-apt-get.en.html

# $ man apt_preferences
#
# How APT Interprets Priorities
#        Priorities (P) assigned in the APT preferences file must be positive or negative integers. They are interpreted as follows (roughly speaking):
#
#        P >= 1000
#            causes a version to be installed even if this constitutes a downgrade of the package
#
#        990 <= P < 1000
#            causes a version to be installed even if it does not come from the target release, unless the installed version is more recent
#
#        500 <= P < 990
#            causes a version to be installed unless there is a version available belonging to the target release or the installed version is more recent
#
#        100 <= P < 500
#            causes a version to be installed unless there is a version available belonging to some other distribution or the installed version is more recent
#
#        0 < P < 100
#            causes a version to be installed only if there is no installed version of the package
#
#        P < 0
#            prevents the version from being installed
#
#        P = 0
#            has undefined behaviour, do not use it.
