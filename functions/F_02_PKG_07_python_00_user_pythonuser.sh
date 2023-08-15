# =====================
# Enable databag
# =====================
# DATABAG_CFG:enable

task_add_no_ssh_user

helper_env_user_base

task_copy_using_cat_user_home

if [[ -f ${current_user}/bin/poetry-new_project ]]; then
  chmod 755 ${current_user}/bin/poetry-new_project
fi
# --- already installed while installing pkgs_container ---
# Ref. https://packaging.python.org/en/latest/guides/installing-using-linux-tools/#debian-ubuntu
# python3-pip python3-venv
