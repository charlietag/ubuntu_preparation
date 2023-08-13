# =====================
# Enable databag
# =====================
# DATABAG_CFG:enable

echo "========================================="
echo "      Install pyenv & poetry"
echo "========================================="

# ---------- pyenv -----------
local pyenv_check="$(su -l $current_user -c "source ~/.bash_user/.pyenv_bashrc.sh && command -v pyenv" | grep "pyenv")"
if [[ -n "${pyenv_check}" ]]; then
  echo "pyenv is installed successfully!"
else
  su -l $current_user -c "git clone https://github.com/pyenv/pyenv.git ~/.pyenv"

  # ---------- copy pyenv bash config -----------
  task_copy_using_cat_user_home
fi

# ---------- python -----------
local pyenv_check="$(su -l $current_user -c "source ~/.bash_user/.pyenv_bashrc.sh && command -v pyenv" | grep "pyenv")"
if [[ -n "${pyenv_check}" ]]; then
  su -l $current_user -c "source ~/.bash_user/.pyenv_bashrc.sh && pyenv install ${python_version}"
  su -l $current_user -c "source ~/.bash_user/.pyenv_bashrc.sh && pyenv global ${python_version}"
else
  echo "pyenv installation failed"
  exit
fi

# ---------- poetry -----------
local python_check="$(su -l $current_user -c "source ~/.bash_user/.pyenv_bashrc.sh && python -V" | grep "${python_version}")"
if [[ -n "${python_check}" ]]; then
  su -l $current_user -c "source ~/.bash_user/.pyenv_bashrc.sh && pip install --upgrade pip setuptools"

  su -l $current_user -c "source ~/.bash_user/.pyenv_bashrc.sh && curl -sSL https://install.python-poetry.org | python3 -"
else
  echo "python(${python_version}) installation failed"
  exit
fi

# ---------- poetry check -----------
local poetry_check="$(su -l $current_user -c "source ~/.bash_user/.pyenv_bashrc.sh && command -v poetry" | grep "poetry")"
if [[ -n "${poetry_check}" ]]; then
  echo "pyenv is installed successfully!"
else
  echo "poetry installation failed"
  exit
fi

echo ""
