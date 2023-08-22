#!/bin/bash
#------------------------------------------------------
#               Bash Prompt Setting - Function
#------------------------------------------------------
# Remain '#', will be replaced by .~/bash_base/.prompt_for_git/.init.sh
PROMPT_SYM='#'

ORIGIN_PS="${PS1%\\n# }"
unset PS1



#------------------------------------------------------
#             Bash Prompt Setting - General user
#------------------------------------------------------
function set_prompt_setting {
  local prompt_setting_red="\e[1;31m"
  local prompt_setting_magenta="\e[1;35m"
  local prompt_setting_background_green="\e[1;42m"
  local prompt_setting_background_purple="\e[1;45m"
  local prompt_setting_background_red="\e[1;41m"
  local prompt_setting_dark_green="\e[0;32m"
  local prompt_setting_dark_yellow="\e[33m"
  local prompt_setting_dark_cyan="\e[36m"
  local prompt_setting_color_end="\033[00m"

  local this_prompt="${prompt_setting_dark_yellow}($(python3 -V))${prompt_setting_color_end}"

  local prompt_for_this="${this_prompt}"

  if [[ -n "${VIRTUAL_ENV_PROMPT}" ]]; then
    # --- prompt for venv ---
    local python_venv="${prompt_setting_background_green}${VIRTUAL_ENV_PROMPT}${prompt_setting_color_end}"
    prompt_for_this="${prompt_for_this} ${python_venv}"


    # --- venv folder check ---
    local python_venv_name="$(echo $VIRTUAL_ENV_PROMPT | sed -re 's/-py[[:digit:]\.]+//g' | sed -re 's/[-]+/_/g' | sed -re 's/[_]+/_/g' | sed -re 's/[\.]+/_/g' | sed -re 's/[\(|\)]+//g')"
    local python_venv_check="$(pwd | sed -re 's/[-]+/_/g' | sed -re 's/[_]+/_/g' | sed -re 's/[\.]+/_/g' | grep -i "${python_venv_name}")"

    if [[ -z "${python_venv_check}" ]]; then
      local python_venv_check_msg="${prompt_setting_background_red}NOT IN Python Venv${prompt_setting_color_end}"
      prompt_for_this="${prompt_for_this} ${python_venv_check_msg}"
    fi

  fi





  echo -e "${prompt_for_this}"
}


#------------------------------------------------------
#             Bash Prompt Setting - Start
#------------------------------------------------------
append_here="\$(set_prompt_setting)"
PS1="${ORIGIN_PS} ${append_here}\n${PROMPT_SYM} "
