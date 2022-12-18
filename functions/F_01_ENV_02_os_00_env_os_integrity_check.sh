# ------------------------------------------------------------
# rsyslog
# ------------------------------------------------------------
# If this is not installed, means image is not complete, rebuild again
echo ""
echo "------------"
echo "rsyslog check (complete image should contain package rsyslog)"
echo "------------"

rsyslog_check="$(dpkg -l rsyslog 2>/dev/null | grep -E "^ii")"

if [[ -z "${rsyslog_check}" ]]; then
  echo "Package \"rsyslog\" not found, please make sure image is fine"
  exit
fi
