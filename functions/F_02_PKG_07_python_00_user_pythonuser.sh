# =====================
# Enable databag
# =====================
# DATABAG_CFG:enable

task_add_no_ssh_user

helper_env_user_base

task_copy_using_cat_user_home

# --- already installed while installing pkgs_container ---
# Ref. https://packaging.python.org/en/latest/guides/installing-using-linux-tools/#debian-ubuntu
# apt install -y python3-pip python3-venv
