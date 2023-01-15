local pkgs_list=""
echo "==============================="
echo "  Installing basic dev packages for rails..."
echo "==============================="

#-----------------------------------------------------------------------------------------
#Package Install
#-----------------------------------------------------------------------------------------
# --- For Rails (For installing rvm) ---
pkgs_list="${pkgs_list} libsqlite3-dev sqlite3"

# --- For compile latest ruby ---
# suggested by rvm
pkgs_list="${pkgs_list} libffi-dev libgdbm-dev libncurses5-dev libtool libyaml-dev zlib1g-dev libgmp-dev libreadline-dev"

# suggested by gorails
pkgs_list="${pkgs_list} libxml2-dev libxslt1-dev libcurl4-openssl-dev"

# suggested by gorails - no need.
#      can manage repo by creating files under /etc/apt/sources.list.d
#      ex: add-apt-repository 'deb [arch=amd64] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse'
# pkgs_list="${pkgs_list} software-properties-common"


# default ruby
pkgs_list="${pkgs_list} ruby"

# ----- Rails 6+ Preview use -----
# FFmpeg for video
pkgs_list="${pkgs_list} ffmpeg"

# muPDF(need to purchase license) for PDFs (Popplerer is also supported)
pkgs_list="${pkgs_list} poppler-utils libpoppler-dev"

# Generate PDF files tools - for gem: wicked_pdf (wrapper for wkhtmltopdf)
# if not installed os packages
# Instead, using gem "wkhtmltopdf_binary_gem"
#pkgs_list="${pkgs_list} wkhtmltopdf wkhtmltopdf-devel"

# ImageMagick latest version - 6.9+
# pkgs_list="${pkgs_list} imagemagick"

# ----- Rails 7+ Active Storage (gem 'ruby-vips') -----
# libvips
pkgs_list="${pkgs_list} libvips libvips-tools libjpeg-dev"

# redis
test -f /usr/share/keyrings/redis-archive-keyring.gpg && rm -f /usr/share/keyrings/redis-archive-keyring.gpg
curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg

test -f /etc/apt/sources.list.d/redis.list && rm -f /etc/apt/sources.list.d/redis.list
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list

apt update

pkgs_list="${pkgs_list} redis"


#-----------------------------------------------------------------------------------------
#Package Start to Install
#-----------------------------------------------------------------------------------------
apt install -y ${pkgs_list}


#-----------------------------------------------------------------------------------------
# Disable redis by default
#-----------------------------------------------------------------------------------------
systemctl disable redis
