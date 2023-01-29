## Predefined variables

```bash
(root)# ./start.sh -i F_00_debug
#############################################
         Preparing required lib
#############################################
Updating required lib to lastest version...
Already up to date.

#############################################
            Running start.sh
#############################################

---------------------------------------------------
NTP(systemd-timesyncd) ---> pool.ntp.org
---------------------------------------------------
---------------------------------------------------


==========================================================================================
        F_00_debug
==========================================================================================
-----------lib use only--------
CURRENT_SCRIPT : /root/ubuntu_preparation/start.sh
CURRENT_FOLDER : /root/ubuntu_preparation
FUNCTIONS      : /root/ubuntu_preparation/functions
LIB            : /root/ubuntu_preparation/../ubuntu_preparation_lib/lib
TEMPLATES      : /root/ubuntu_preparation/templates
TASKS          : /root/ubuntu_preparation/../ubuntu_preparation_lib/tasks
HELPERS        : /root/ubuntu_preparation/helpers
HELPERS_VIEWS  : /root/ubuntu_preparation/helpers_views

-----------lib use only - predefined vars--------
FIRST_ARGV     : -i
ALL_ARGVS      : F_00_debug

-----------function use only--------
PLUGINS            : /root/ubuntu_preparation/plugins
TMP                : /root/ubuntu_preparation/tmp
CONFIG_FOLDER      : /root/ubuntu_preparation/templates/F_00_debug
DATABAG            : /root/ubuntu_preparation/databag
DATABAG_FILE       : /root/ubuntu_preparation/databag/F_00_debug.cfg

-----------function extended use only--------
IF_IS_SOURCED_SCRIPT  : True: use 'return 0' to skip script
IF_IS_FUNCTION        : True: use 'return 0' to skip script
IF_IS_SOURCED_OR_FUNCTION  : True: use 'return 0' to skip script

${BASH_SOURCE[0]}    : /root/ubuntu_preparation/functions/F_00_debug.sh
${0}                 : ./start.sh
${FUNCNAME[@]}          : source F_00_debug L_RUN L_RUN_SPECIFIED_FUNC source source main
Skip script sample    : [[ -n "$(eval "${IF_IS_SOURCED_OR_FUNCTION}")" ]] && return 0 || exit 0
Skip script sample short : eval "${SKIP_SCRIPT}"

================= Testing ===============
----------Helper Debug Use-------->>>

-------------------------------------------------------------------
        helper_debug
-------------------------------------------------------------------
HELPER_VIEW_FOLDER : /root/ubuntu_preparation/helpers_views/helper_debug


----------Task Debug Use-------->>>

-----------------------------------------------
        task_debug
-----------------------------------------------
```


## Note
### Built-in vim colorscheme
* /usr/share/vim/vim72/colors

  ```bash
  colorscheme desert
  colorscheme elflord
  colorscheme koehler
  colorscheme ron
  colorscheme torte <--- Most proper
  colorscheme 256-jungle
  colorscheme lucid
  colorscheme motus
  ```

### Optional note
  * VSFTPD

    ```bash
    apt install -y vsftpd
    sed -i s/^root/'#root'/g /etc/vsftpd/ftpusers
    sed -i s/^root/'#root'/g /etc/vsftpd/user_list
    ```

