# =====================
# Enable databag
# =====================
# DATABAG_CFG:enable

echo "========================================="
echo "      Install pyenv & poetry"
echo "========================================="
# ---------- poetry check -----------
# this file should be sourced through .bashrc, but source it manually here is because .bashrc will determine if this is a interactive session, if it's not a interactive session .bashrc will not be sourced
# Move pyenv init script to .bash_profile, which is sourced before .bashrc
# So no need to source it manually
# local poetry_check="$(su -l $current_user -c "source ~/.bash_user/.31_pyenv_bashrc.sh && command -v poetry" | grep "poetry")"
local poetry_check="$(su -l $current_user -c "command -v poetry" | grep "poetry")"
if [[ -n "${poetry_check}" ]]; then
  echo "poetry is installed successfully!"
else
  # ------------------------------------------
  #     Start
  # ------------------------------------------

  # ---------- poetry -----------
  # local python_check="$(su -l $current_user -c "source ~/.bash_user/.31_pyenv_bashrc.sh && python -V" | grep "${python_version}")"
  # if [[ -n "${python_check}" ]]; then
  #   su -l $current_user -c "source ~/.bash_user/.31_pyenv_bashrc.sh && pip install --upgrade pip setuptools"
  #
  #   su -l $current_user -c "source ~/.bash_user/.31_pyenv_bashrc.sh && curl -sSL https://install.python-poetry.org | python3 -"
  # else
  #   echo "python(${python_version}) installation failed"
  #   exit
  # fi

  local if_pipx_installed="$(dpkg -l pipx 2>/dev/null | grep -E "^ii")"
  if [[ -z "${if_pipx_installed}" ]]; then
    apt install -y pipx
  fi

  # --- install poetry through pipx (easier) ---
  # check '/home/phpuser/.local/bin is already in PATH.'. no need, It's been added manually
  # su -l $current_user -c "pipx ensurepath"

  # install poetry
  su -l $current_user -c "pipx install poetry"


  # --- install poetry through installer ---
  # su -l $current_user -c "pip3 install --upgrade pip setuptools"
  # su -l $current_user -c "curl -sSL https://install.python-poetry.org | python3 -"

  # ---------- poetry check -----------
  # local poetry_check="$(su -l $current_user -c "source ~/.bash_user/.31_pyenv_bashrc.sh && command -v poetry" | grep "poetry")"
  # Install poetry using system python version, not python version from pyenv, in case, pyenv remove python version which is used by poetry and cause poetry fails to start

  local poetry_check="$(su -l $current_user -c "command -v poetry" | grep "poetry")"
  if [[ -n "${poetry_check}" ]]; then
    echo "poetry is installed successfully!"
  else
    echo "poetry installation failed"
    exit
  fi

  # ---------- pyenv -----------
  # local pyenv_check="$(su -l $current_user -c "source ~/.bash_user/.31_pyenv_bashrc.sh && command -v pyenv" | grep "pyenv")"
  local pyenv_check="$(su -l $current_user -c "command -v pyenv" | grep "pyenv")"
  if [[ -n "${pyenv_check}" ]]; then
    echo "pyenv is installed successfully!"
  else
    su -l $current_user -c "git clone https://github.com/pyenv/pyenv.git ~/.pyenv"

    # ---------- copy pyenv bash config -----------
    task_copy_using_cat_user_home
  fi

  # ---------- python -----------
  # local pyenv_check="$(su -l $current_user -c "source ~/.bash_user/.31_pyenv_bashrc.sh && command -v pyenv" | grep "pyenv")"
  local pyenv_check="$(su -l $current_user -c "command -v pyenv" | grep "pyenv")"
  if [[ -n "${pyenv_check}" ]]; then
    # su -l $current_user -c "source ~/.bash_user/.31_pyenv_bashrc.sh && pyenv install ${python_version}"
    # su -l $current_user -c "source ~/.bash_user/.31_pyenv_bashrc.sh && pyenv global ${python_version}"
    su -l $current_user -c "pyenv install ${python_version}"
    su -l $current_user -c "pyenv global ${python_version}"
  else
    echo "pyenv installation failed"
    exit
  fi

  # ------------------------------------------
  #     End
  # ------------------------------------------


fi
# ---------- poetry check -----------


echo ""
