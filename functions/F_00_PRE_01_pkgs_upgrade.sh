apt update
apt upgrade -y
apt update
apt list --upgradable 2>/dev/null | grep upgradable | awk -F'/' '{print $1}' | xargs apt install -y
