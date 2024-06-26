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
# libncurses5-dev does not exist in Ubuntu 24.04 (use libncurses-dev instead)
pkgs_list="${pkgs_list} libffi-dev libgdbm-dev libncurses-dev libncurses5-dev libtool libyaml-dev zlib1g-dev libgmp-dev libreadline-dev"

# suggested by gorails
pkgs_list="${pkgs_list} libxml2-dev libxslt1-dev libcurl4-openssl-dev"

# suggested by gorails - no need.
#      can manage repo by creating files under /etc/apt/sources.list.d
#      ex: add-apt-repository 'deb [arch=amd64] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse'
pkgs_list="${pkgs_list} software-properties-common"


# default ruby
pkgs_list="${pkgs_list} ruby"

# for ruby 3.2YJIT enabled (rvm install 3.2.0 -C "--enable-yjit")
pkgs_list="${pkgs_list} rustc"
# rustc: libllvm14 libstd-rust-1.61 libstd-rust-dev libllvm14 libstd-rust-1.61 libstd-rust-dev rustc


# (optional) Suggested packages by rustc
pkgs_list="${pkgs_list} cargo llvm-14 lld-14 clang-14"

# ----- Rails 6+ Preview use -----
# FFmpeg for video
pkgs_list="${pkgs_list} ffmpeg"

# muPDF(need to purchase license) for PDFs (Popplerer is also supported)
pkgs_list="${pkgs_list} poppler-utils libpoppler-dev"

# Generate PDF files tools - for gem: wicked_pdf (wrapper for wkhtmltopdf)
# if not installed os packages
# Instead, using gem "wkhtmltopdf_binary_gem"
#pkgs_list="${pkgs_list} wkhtmltopdf wkhtmltopdf-devel"

# ImageMagick latest version - 6.9+ (for image uploading apps, like redmine)
pkgs_list="${pkgs_list} imagemagick libmagickwand-dev"

# For redmine - pdf preview
# Ref. https://imagemagick.org/script/security-policy.php
# sed -re '/coder[[:print:]]+pattern[[:print:]]+PDF/ s/none/READ|WRITE/g' -i /etc/ImageMagick-6/policy.xml

# ----- Rails 7+ Active Storage (gem 'ruby-vips') -----
# libvips
pkgs_list="${pkgs_list} libvips libvips-tools libjpeg-dev"

#-----------------------------------------------------------------------------------------
#Package Start to Install
#-----------------------------------------------------------------------------------------
apt install -y ${pkgs_list}

