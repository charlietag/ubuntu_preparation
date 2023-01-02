# =====================
# Enable databag
# =====================
# DATABAG_CFG:enable

#-----------------------------------------------------------------------------------------
# etc/hostname for hostname setup
#-----------------------------------------------------------------------------------------
# After setting up hostname to none 'localhost.localdomain'
#   |__ will avoid /etc/resolv.conf contains search localdomain everytime reboot
hostnamectl set-hostname ${host_name}


#-----------------------------------------------------------------------------------------
# Network - netplain (systemd-networkd.service)
#-----------------------------------------------------------------------------------------
# render os config (sysctl.d-disable ipv6)
task_copy_using_render_sed

#-----------------------------------------------------------------------------------------
#Setup timezone
#-----------------------------------------------------------------------------------------
timedatectl set-timezone "${current_timezone}"

#-----------------------------------------------------------------------------------------
#Setup chrony
#-----------------------------------------------------------------------------------------
# triggered by ubuntu_preparation_lib already
# apt install -y chrony
# systemctl stop chrony
# systemctl disable chrony

if [[ "${ntp_using_cron}" = "y" ]]; then
  sed -i /chronyd/d /etc/crontab
  echo '*/5 * * * * root chronyd -q "pool pool.ntp.org iburst" >/dev/null 2>/dev/null ; hwclock -w  >/dev/null 2>/dev/null' >> /etc/crontab
else
  systemctl start chronyd
  systemctl enable chronyd
fi
