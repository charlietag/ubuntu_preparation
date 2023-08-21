# Move this script AFTER customized bash prompt to enable python default venv_prompot
# this script is designed for "poetry" in TMUX


if [[ -f pyproject.toml ]]; then
  POETRY_COMMAND="$(command -v poetry)"
  if [[ -n "${POETRY_COMMAND}" ]]; then
    # MY_PYTHON_VIRTUAL_ENV="$(poetry env info | grep poetry | grep virtualenvs | grep Path | awk '{print $2}')"
    MY_PYTHON_VIRTUAL_ENV="$(poetry env info --path)"
  fi
elif [[ -f bin/activate ]]; then
  VIRTUAL_ENV_CHECK="$(find ./ -name virtualenv.py)"
  if [[ -n "${VIRTUAL_ENV_CHECK}" ]]; then
    MY_PYTHON_VIRTUAL_ENV="$(pwd)"
  fi
fi


if [[ -n "${MY_PYTHON_VIRTUAL_ENV}" ]]; then
  . $MY_PYTHON_VIRTUAL_ENV/bin/activate
fi
