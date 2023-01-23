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
  local prompt_setting_dark_yellow="\e[33m"
  local prompt_setting_dark_cyan="\e[36m"
  local prompt_setting_color_end="\033[00m"
  local this_prompt=""

  this_prompt="${prompt_setting_dark_yellow}(node $(node -v))${prompt_setting_color_end}"

  local prompt_for_this="${this_prompt}"

  echo -e "${prompt_for_this}"
}


#------------------------------------------------------
#             Bash Prompt Setting - Start
#------------------------------------------------------
append_here="\$(set_prompt_setting)"
PS1="${ORIGIN_PS} ${append_here}\n${PROMPT_SYM} "
