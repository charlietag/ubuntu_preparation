apt install -y vim

local default_editor="$(update-alternatives --list editor |grep vim |grep -v tiny | head -n 1)"

update-alternatives --set editor ${default_editor}

task_copy_using_cat

export EDITOR="vim"
