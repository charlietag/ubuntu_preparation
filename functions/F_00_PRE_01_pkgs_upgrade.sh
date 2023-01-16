apt update
apt upgrade -y
apt update
apt list --upgradable | awk -F'/' '{print $1}' | xargs -I {} apt install -y {}
