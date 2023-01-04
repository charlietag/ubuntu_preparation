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
#Setup NTP
#-----------------------------------------------------------------------------------------
local if_chrony_found="$(dpkg -l chrony 2>/dev/null | grep "ii")"
local if_timesyncd_found="$(dpkg -l systemd-timesyncd | grep "ii")"

# ------------------------------------
# Chrony
# ------------------------------------
if [[ -n "${if_chrony_found}" ]]; then
  if [[ "${ntp_use_chrony_crontab}" = "y" ]]; then
    systemctl stop chrony
    systemctl disable chrony
    sed -i /chronyd/d /etc/crontab
    echo "*/5 * * * * root chronyd -q \"pool ${ntp_url} iburst\" >/dev/null 2>/dev/null ; hwclock -w  >/dev/null 2>/dev/null" >> /etc/crontab
  else
    echo "" > /etc/chrony/conf.d/99_ntp_pool.conf
    for ntp_url in ${ntp_urls[@]}; do
      echo "pool ${ntp_url} iburst maxsources 1" >> /etc/chrony/conf.d/99_ntp_pool.conf
    done
    systemctl restart chrony
    systemctl enable chrony
  fi
# ------------------------------------
# timesyncd
# ------------------------------------
elif [[ -n "${if_timesyncd_found}" ]]; then
  sed -re '/^[[:space:]]*NTP/ s/^#*/#/' -i /etc/systemd/timesyncd.conf
  echo "NTP=${ntp_urls}" >> /etc/systemd/timesyncd.conf
  systemctl restart systemd-timesyncd
  systemctl enable systemd-timesyncd
  timedatectl set-ntp yes
  timedatectl set-local-rtc 0
fi
