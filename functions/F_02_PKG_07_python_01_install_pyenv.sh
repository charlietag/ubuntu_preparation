# =====================
# Enable databag
# =====================
# DATABAG_CFG:enable

echo "========================================="
echo "      Install pyenv & poetry"
echo "========================================="

# ---------- pyenv -----------
local pyenv_check="$(su -l $current_user -c "command -v pyenv" | grep "pyenv")"
if [[ -n "${pyenv_check}" ]]; then
  echo "pyenv is installed successfully!"
else
  su -l $current_user -c "git clone https://github.com/pyenv/pyenv.git ~/.pyenv"
fi

# ---------- python -----------
local pyenv_check="$(su -l $current_user -c "command -v pyenv" | grep "pyenv")"
if [[ -n "${pyenv_check}" ]]; then
  su -l $current_user -c "pyenv install ${python_version}"
else
  echo "pyenv installation failed"
  exit
fi

# ---------- poetry -----------
local python_check="$(su -l $current_user -c "python -V" | grep "${python_version}")"
if [[ -n "${python_check}" ]]; then
  su -l $current_user -c "pyenv global ${python_version}"
  su -l $current_user -c "pip install --upgrade pip setuptools"

  su -l $current_user -c "curl -sSL https://install.python-poetry.org | python3 -"
else
  echo "python(${python_version}) installation failed"
  exit
fi

# ---------- poetry check -----------
local poetry_check="$(su -l $current_user -c "command -v poetry" | grep "poetry")"
if [[ -n "${poetry_check}" ]]; then
  echo "pyenv is installed successfully!"
else
  echo "poetry installation failed"
  exit
fi

echo ""
