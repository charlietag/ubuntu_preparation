# =====================
# Enable databag
# =====================
# DATABAG_CFG:enable

# redis
test -f /usr/share/keyrings/redis-archive-keyring.gpg && rm -f /usr/share/keyrings/redis-archive-keyring.gpg
test -f /etc/apt/sources.list.d/redis.list && rm -f /etc/apt/sources.list.d/redis.list

if [[ "${use_redis_io_repo}" = "y" ]]; then
  # test -f /usr/share/keyrings/redis-archive-keyring.gpg && rm -f /usr/share/keyrings/redis-archive-keyring.gpg
  curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg

  # test -f /etc/apt/sources.list.d/redis.list && rm -f /etc/apt/sources.list.d/redis.list
  echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/redis.list

  apt update
fi

apt install -y redis


#-----------------------------------------------------------------------------------------
# Disable redis by default
#-----------------------------------------------------------------------------------------
systemctl disable redis-server.service
