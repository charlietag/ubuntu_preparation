local pkgs_list=""
echo "==============================="
echo "  Installing basic dev packages..."
echo "==============================="

#-----------------------------------------------------------------------------------------
# NTP update date time and hwclock to prevent mariadb cause systemd warning
#-----------------------------------------------------------------------------------------
# default now: use systemd-timesyncd
# pkgs_list="${pkgs_list} chrony"


#-----------------------------------------------------------------------------------------
#Package Install
#-----------------------------------------------------------------------------------------
# For NodeJS
pkgs_list="${pkgs_list} gcc g++ make"

# Basic dev packages (meta package)
pkgs_list="${pkgs_list} build-essential"

pkgs_list="${pkgs_list} whois"

# for command: nslookup, dig
pkgs_list="${pkgs_list} bind9-dnsutils"

# Performance tools
pkgs_list="${pkgs_list} sysstat iotop atop"

pkgs_list="${pkgs_list} bash screen git tree vim mtr lsof net-tools wget"

# Basic debug tools - Enhanced tail / Enhanced grep
pkgs_list="${pkgs_list} multitail ack"

# For SSL
pkgs_list="${pkgs_list} openssl libssl-dev"

# For sql server connection (freetds)
pkgs_list="${pkgs_list} unixodbc unixodbc-dev libodbc1 odbcinst1debian2 tdsodbc"
pkgs_list="${pkgs_list} freetds-bin freetds-common freetds-dev libct4 libsybdb5"

# For GeoIP purpose
# RHEL 9 - no GeoIP, move to remi
pkgs_list="${pkgs_list} geoip-bin geoip-database geoipupdate"
pkgs_list="${pkgs_list} libgeoip-dev"

# For Nginx HTTP rewrite module (manully compile use)
pkgs_list="${pkgs_list} libpcre2-dev"



#-----------------------------------------------------------------------------------------
#Package Start to Install
#-----------------------------------------------------------------------------------------
apt install -y ${pkgs_list}
