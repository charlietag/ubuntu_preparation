# Move this script AFTER customized bash prompt to enable python default venv_prompot
# this script is designed for "poetry" in TMUX

MY_PYTHON_VIRTUAL_ENV=""
POETRY_COMMAND="$(command -v poetry)"

# if [[ -f pyproject.toml ]]; then
#   POETRY_COMMAND="$(command -v poetry)"
#   if [[ -n "${POETRY_COMMAND}" ]]; then
#     # MY_PYTHON_VIRTUAL_ENV="$(poetry env info | grep poetry | grep virtualenvs | grep Path | awk '{print $2}')"
#     MY_PYTHON_VIRTUAL_ENV="$(poetry env info --path)"
#   fi
# fi

# -------------------------------------
# VENV project
# -------------------------------------
if [[ -f bin/activate ]]; then
  VIRTUAL_ENV_CHECK="$(find ./ -name virtualenv.py)"
  if [[ -n "${VIRTUAL_ENV_CHECK}" ]]; then
    MY_PYTHON_VIRTUAL_ENV="$(pwd)"
  fi

# -------------------------------------
# Poetry project
# -------------------------------------
elif [[ -n "${POETRY_COMMAND}" ]]; then
  # MY_PYTHON_VIRTUAL_ENV="$(poetry env info | grep poetry | grep virtualenvs | grep Path | awk '{print $2}')"
  MY_PYTHON_VIRTUAL_ENV_MSG="$(poetry env info --path 2>&1)"

  if [[ -n "${MY_PYTHON_VIRTUAL_ENV_MSG}" ]]; then
    # --- check if not poetry project ---
    MY_PYTHON_VIRTUAL_NOT_POETRY="$(echo -e "${MY_PYTHON_VIRTUAL_ENV_MSG}" | grep 'could not find a pyproject.toml')"

    # --- check if is poetry project ---
    if [[ -z "${MY_PYTHON_VIRTUAL_NOT_POETRY}" ]]; then
      MY_PYTHON_VIRTUAL_ENV="${MY_PYTHON_VIRTUAL_ENV_MSG}"
    fi
  else

    # --- check if is poetry project, but poetry venv is not activated ---
    MY_PYTHON_VER="$(python -V | awk '{print $2}')"
    poetry env use ${MY_PYTHON_VER}
    MY_PYTHON_VIRTUAL_ENV="$(poetry env info --path 2>/dev/null)"
  fi

fi

# -------------------------------------
# Start to activate venv, if venv found
# -------------------------------------
if [[ -n "${MY_PYTHON_VIRTUAL_ENV}" ]]; then
  . $MY_PYTHON_VIRTUAL_ENV/bin/activate
fi
