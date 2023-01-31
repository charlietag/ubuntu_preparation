
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
#   apt pref config ref. https://www.debian.org/doc/manuals/apt-howto/ch-apt-get.en.html
echo "creating file /etc/apt/preferences.d/nosnap.pref"

cat <<EOF | sudo tee /etc/apt/preferences.d/nosnap.pref
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
