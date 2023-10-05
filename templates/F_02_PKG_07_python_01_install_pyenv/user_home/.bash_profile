# ----------------------------------------------------------------
# If this file exists, then ~/.profile will not be read
# ----------------------------------------------------------------
# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022
# ----------------------------------------------------------------

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
  . "$HOME/.bashrc"
    fi
fi

# ----------------------------------------------------------------
# Avoid pyenv load before the following setting
# ----------------------------------------------------------------
# which means, pyenv must start from head in $PATH


# # set PATH so it includes user's private bin if it exists
# if [ -d "$HOME/bin" ] ; then
#     PATH="$HOME/bin:$PATH"
# fi
#
# # set PATH so it includes user's private bin if it exists
# if [ -d "$HOME/.local/bin" ] ; then
#     PATH="$HOME/.local/bin:$PATH"
# fi

#------------------------------------------------------
#               pyenv
#------------------------------------------------------
# .bashrc will not be read, because of the following script in .bashrc
# ---------
# # If not running interactively, don't do anything
# case $- in
#     *i*) ;;
#       *) return;;
# esac
# ---------

# so move pyenv init command from  .bash_user/ into .bash_profile (trigger before .bashrc)

export PYENV_ROOT="$HOME/.pyenv"
if [[ -d "${PYENV_ROOT}" ]]; then
  command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
fi
