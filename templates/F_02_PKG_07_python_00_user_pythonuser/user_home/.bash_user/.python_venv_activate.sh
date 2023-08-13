# this script is designed for "poetry" in TMUX
if [[ -n "${VIRTUAL_ENV}" ]]; then
  . $VIRTUAL_ENV/bin/activate
fi
