#!/bin/bash
#------------------------------------------------------
#               Bash Prompt Setting - Function
#------------------------------------------------------
# Remain '#', will be replaced by .~/bash_base/.prompt_for_git/.init.sh
PROMPT_SYM='#'

ORIGIN_PS="${PS1%\\n# }"
unset PS1



#------------------------------------------------------
#             Bash Prompt Setting - Ruby
#------------------------------------------------------
function set_ruby {
  local ruby_dark_yellow="\e[33m"
  local ruby_dark_cyan="\e[36m"
  local ruby_color_end="\033[00m"
  local python_prompt=""

  python_prompt="${ruby_dark_yellow}(podman $(podman --version | grep -Eo "[[:digit:]\.]+"))${ruby_color_end}"

  local prompt_for_python="${python_prompt}"

  echo -e "${prompt_for_python}"
}


#------------------------------------------------------
#             Bash Prompt Setting - Start
#------------------------------------------------------
append_here="\$(set_ruby)"
PS1="${ORIGIN_PS} ${append_here}\n${PROMPT_SYM} "
