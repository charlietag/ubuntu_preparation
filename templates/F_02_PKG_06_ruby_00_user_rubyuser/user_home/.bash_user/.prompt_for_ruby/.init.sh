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
  local rails_ver=""
  local rvm_prompt=""

  #if [[ -s "$HOME/.rvm/bin/rvm-prompt" ]]; then
  #  rvm_prompt="${ruby_dark_yellow}($($HOME/.rvm/bin/rvm-prompt))${ruby_color_end}"
  #fi
  local ruby_ver=""
  ruby_ver="$(ruby -v --yjit 2>/dev/null| grep -Eo 'ruby[[:space:]]+[[:digit:]\.]+|\+YJIT|\+PRISM' | xargs echo)"
  test -z "${ruby_ver}" && ruby_ver="$(ruby -v 2>/dev/null| grep -Eo 'ruby[[:space:]]+[[:digit:]\.]+')"

  rvm_prompt="${ruby_dark_yellow}(${ruby_ver})${ruby_color_end}"

  local prompt_for_ruby="${rvm_prompt}"

  # [[ -f "Gemfile.lock" ]] && rails_ver="$(cat Gemfile.lock |sed 's/ //g' |grep -E '^rails\([[:digit:]]+' | sed 's/(/ /g' | tr -d ')')"


  # --- awk to get rails version from Gemfile.lock ---
  # awk '
  # match($0, /^[[:space:]]*rails[[:space:]]*\(([0-9.]+)\)[[:space:]]*$/, m) {
  #   print "rails", m[1]
  # }
  # ' Gemfile.lock
  # --- awk to get rails version from Gemfile.lock ---
  [[ -f "Gemfile.lock" ]] && rails_ver="$(awk 'match($0, /^[[:space:]]*rails[[:space:]]*\(([0-9.]+)\)[[:space:]]*$/, m) {print "rails", m[1]}' Gemfile.lock)"


  if [[ -n "${rails_ver}" ]]; then
    rails_ver="${ruby_dark_cyan}(${rails_ver})${ruby_color_end}"
    prompt_for_ruby="${prompt_for_ruby} ${rails_ver}"
  fi
  echo -e "${prompt_for_ruby}"
}


#------------------------------------------------------
#             Bash Prompt Setting - Start
#------------------------------------------------------
append_here="\$(set_ruby)"
PS1="${ORIGIN_PS} ${append_here}\n${PROMPT_SYM} "
