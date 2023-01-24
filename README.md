Table of Contents
=================
- [Ubuntu Linux Server OS Preparation](#ubuntu-linux-server-os-preparation)
- [Environment](#environment)
- [Notice](#notice)
- [Warning](#warning)
- [Configuration](#configuration)
- [Easy Installation](#easy-installation)
- [Advanced Installation](#advanced-installation)
- [Customize your own function](#customize-your-own-function)
  * [Folder](#folder)
  * [Predefined variables](#predefined-variables)
- [Note](#note)
  * [Installed Packages](#installed-packages)
  * [Folder privilege](#folder-privilege)
  * [Ruby gem config](#ruby-gem-config)
  * [Database configuration for production](#database-configuration-for-production)
  * [Extra functions](#extra-functions)
  * [(Git) Stash details](#git-stash-details)
  * [(Git) Push and Pull](#git-push-and-pull)
  * [Upgrading Redmine](#upgrading-redmine)
    + [Reference](#reference)
    + [Backup current redmine](#backup-current-redmine)
    + [Customized files](#customized-files)
    + [(Method 1) Upgrading from a git checkout](#method-1-upgrading-from-a-git-checkout)
    + [(Method 2) Upgrading from a fresh installation](#method-2-upgrading-from-a-fresh-installation)
  * [Upgrading MariaDB](#upgrading-mariadb)
    + [Reference (mariadb.com)](#reference-mariadbcom)
    + [How to Upgrade](#how-to-upgrade)
- [CHANGELOG](#changelog)

# Ubuntu Linux Server OS Preparation
You want initialize your linux server by your own script.  But you **DO NOT** want to use **PUPPET , CHEF , Ansible**.  You can just leverage this initialization project.

This is a small light bash project.  Suit small companies which have only few servers to maintain.  **GIVE IT A TRY!!**

> **Ubuntu server 22.04 environment settings**

* This is useful when
  * You have less than 5 Ubuntu servers to maintain.
  * You are deploying monolithic architecture app.
  * You are building Ruby on Rails / Laravel dev server.

* This repo contains packages below
  * **NGINX + PUMA + PHP-FPM + MariaDB + Rails + Laravel + Redmine**

# Environment
  * Ubuntu 22.04
    * ubuntu_preparation
      * release : `master` `v1.0.0`

# Notice
  * Before [ubuntu_security](https://github.com/charlietag/ubuntu_security)
    * After finish first run [ubuntu_preparation](https://github.com/charlietag/ubuntu_preparation), you'd better **DO A REBOOT** before implementing [ubuntu_security](https://github.com/charlietag/ubuntu_security)
  * **Systemd target**
    * **Default** target (*[ubuntu_preparation](https://github.com/charlietag/ubuntu_preparation) will force to use this target*)
      * **multi-user.target**
        * This command will be executed `systemctl set-default multi-user`
    * Comparision
      *  **multi-user.target: analogous to runlevel 3**
      *  graphical.target: analogous to runlevel 5
    * **WARNING** If you are under **graphical.target** **NOT** under **multi-user.target**.
      * It is highly recommended that you do the following:
        * **Reinstall whole Ubuntu** using **"Ubuntu Server"** ~~Ubuntu Server (minimized)~~
      * Reference description here
         * [F_01_ENV_00_systemd_default_target.sh](https://github.com/charlietag/ubuntu_preparation/blob/master/functions/F_01_ENV_00_systemd_default_target.sh)
    * **Check method**
      * `systemctl get-default`

# Warning
  * Please do this in fresh install OS
  * What does this not cover, DO the following manually
    * Login user
      * Change password of root
      * Add GENERAL USER and setup password of GENERAL USER
    * /etc/ssh/sshd_config
      * PermitRootLogin no
      * PasswordAuthentication yes
    * RAM
      * mkswap if RAM is insufficient to start MariaDB

        ```bash
        mkdir /swap
        dd if=/dev/zero of=/swap/swapfile bs=1M count=4096
        mkswap /swap/swapfile
        chmod 0600 /swap/swapfile
        /sbin/swapon /swap/swapfile
        ```

        ```bash
        cat << EOF >> /etc/rc.local
        #!/bin/bash
        /sbin/swapon /swap/swapfile
        EOF

        chmod 755 /etc/rc.local
        ```

        (based on `rc-local.service`)

# Configuration
  * ssh `without` `SendEnv`
    * command `ssh`
      * [ssh_to](https://github.com/charlietag/bash_script/blob/master/ssh_to.sh)
      * config `/etc/ssh/ssh_config`

        ```bash
        # SendEnv LANG LC_*
        ```

    * iTerm2 [setting](https://github.com/charlietag/tmux_settings#ssh-client)
      ![iterm2_disable_setting_LC_ALL.png](https://raw.githubusercontent.com/charlietag/github_share_folder/master/doc_images/tmux_settings/iTerm2/iterm2_disable_setting_LC_ALL.png)


  * Before installation

    ```bash
    apt clean
    apt update
    apt install git -y
    git clone https://github.com/charlietag/ubuntu_preparation.git
    ```

  * Make sure config files exists , you can copy from sample to **modify**.

    ```bash
    cd databag
    ls |xargs -I{} bash -c "cp {} \$(echo {}|sed 's/\.sample//g')"
    ```

  * Mostly used configuration :
    * **DEV** use (server in **Local** / server in **Cloud**) && **Production** use (server in **Local** / server in **Cloud**)

      ```bash
      databag/
      ├── F_01_ENV_02_os_01_env.cfg
      ├── F_01_ENV_04_ssh_config.cfg
      └── _gitconfig.cfg
      ```

  * Verify config files (with syntax color).

    ```bash
    cd databag

    echo ; \
    ls *.cfg | xargs -I{} bash -c " \
    echo -e '\e[0;33m'; \
    echo ---------------------------; \
    echo {}; \
    echo ---------------------------; \
    echo -n -e '\033[00m' ; \
    echo -n -e '\e[0;32m'; \
    cat {} | grep -vE '^\s*#' |sed '/^\s*$/d'; \
    echo -e '\033[00m' ; \
    echo "
    ```

  * Verify **ONLY modified** config files (with syntax color).

    ```bash
    cd databag

    echo ; \
    ls *.cfg | xargs -I{} bash -c " \
    echo -e '\e[0;33m'; \
    echo ---------------------------; \
    echo {}; \
    echo ---------------------------; \
    echo -n -e '\033[00m' ; \
    echo -n -e '\e[0;32m'; \
    cat {} | grep -v 'plugin_load_databag.sh' | grep -vE '^\s*#' |sed '/^\s*$/d'; \
    echo -e '\033[00m' ; \
    echo "
    ```

# Easy Installation
I'm a lazy person.  I want to install **ALL** and give me default configurations running **Nginx , MariaDB, php-fpm, puma 5 (rails)**.  And help me to create default projects about "Rails" and "Laravel"

* Command

  ```bash
  ./start -a
  reboot
  ```

* Default project path
  * DEFAULT user for rails/laravel developer is not ssh allowed
    * /etc/ssh/sshd

      ```bash
      DenyGroups no-ssh-group
      ```

  * group "no-ssh-group" add to default dev user
    * phpuser (this name can be modified)
    * rubyuser (this name can be modified)

  * rails
    * default user: rubyuser (can be changed)

  ```bash
  /home/${current_user}/rails_sites/myrails/
  --->
  /home/rubyuser/rails_sites/myrails/
  ```

  * Redmine
    * default user: rubyuser (can be changed)

  ```bash
  /home/${current_user}/rails_sites/redmine/
  --->
  /home/rubyuser/rails_sites/redmine/
  ```

  * laravel
    * default user: phpuser (can be changed)

  ```bash
  /home/${current_user}/laravel_sites/myrails/
  --->
  /home/phpuser/laravel_sites/myrails/
  ```

* Config your own hosts file (/etc/hosts)

  ```bash
  <192.168.x.x> myrails.ubuntu.localdomain
  <192.168.x.x> redmine.ubuntu.localdomain
  <192.168.x.x> mylaravel.ubuntu.localdomain
  ```

* Browse URL

  ```bash
  http://myrails.ubuntu.localdomain
  http://redmine.ubuntu.localdomain (default account: admin/admin)
  http://mylaravel.ubuntu.localdomain
  ```

# Advanced Installation
I want to choose specific part to install.
* Command

  ```bash
  ./start.sh -h
  usage: start.sh
    -a                   ,  run all functions
    -i func1 func2 func3 ,  run specified functions
  ```

# Customize your own function
## Folder
  * functions/
    * Write your own script here, **file** named start with **F_[0-9][0-9]_YourOwnFuntionName.sh**
    * Run command

      ```bash
      ./start.sh -i YourOwnFuntionName
      ```

  * templates/
    * Put your own templates here, **folder** named the same as **YourOwnFuntionName**

  * databag/
    * Put your special config variables here, **file** named the same as **YourOwnFuntionName**
    * How to use
      * In databag/YourOwnFunctionName
        * local your_vars_here
      * In templates/YourOwnFunctionName/yourowntemplate_file
        * You can use ${your_vars_here}
      * In **YourOwnFuntionName** , you can call

        ```bash
        # Method : eval "echo \"$variable\""
        # Might have escape issue, if template is complicated
        RENDER_CP ${$CONFIG_FOLDER}/yourowntemplate_file /SomeWhere/somewhere
        ```

        ```bash
        # Method : cat template | sed 's/\{\{var\}\}/$var/g'
        # BETTER method for rendering template
        RENDER_CP_SED ${$CONFIG_FOLDER}/yourowntemplate_file /SomeWhere/somewhere
        ```


        instead of

        ```bash
        cp ${$CONFIG_FOLDER}/yourowntemplate_file /SomeWhere/somewhere
        ```

      * In **YourOwnFuntionName** , you just want to **LOAD VARIABLES ONLY** from databag, try add a comment into your function script

        ```bash
        # For Load Variables Only Usage, add the following single comment line with keyword DATABAG_CFG:enable
        # DATABAG_CFG:enable
        ```

  * helpers/
    * Write your own script here, **file** named start with **helper_YourOwnHelperName.sh**
    * Works with helpers_views

  * helpers_views/
    * Put your own templates for ONLY **helper USE** here, **folder** named the same as **YourOwnHelperName**

  * tasks/
    * Write your own script here, **file** named start with **task_YourOwnTaskName.sh** , **_task_YourOwnTaskName.sh**
    * Scripts here will automatically transfer to function, just like scripts under "functions/"
    * But this is for global use for ubuntu_preparation , ubuntu_security.  So it's been moved to ubuntu_preparation_lib

  * plugins/
    * Only scripts which can be called everywhere like, ${HELPERS}/plugins_scripts.sh
    * Use this as a script, not function

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
NTP(chrony) ---> pool.ntp.org
---------------------------------------------------
RUN: chronyd -q 'pool pool.ntp.org iburst'
2020-09-08T01:47:33Z chronyd version 3.5 starting (+CMDMON +NTP +REFCLOCK +RTC +PRIVDROP +SCFILTER +SIGND +ASYNCDNS +SECHASH +IPV6 +DEBUG)
2020-09-08T01:47:38Z System clock wrong by -0.002320 seconds (step)
2020-09-08T01:47:38Z chronyd exiting
RUN: hwclock -w
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

# Note

## Installed Packages
  * PHP 8.1 (AppStream) ~~(Ref. https://rpms.remirepo.net/wizard/)~~
  * PHP-FPM (AppStream) ~~(Ref. https://rpms.remirepo.net/wizard/)~~
  * Laravel 9.x (Ref. https://laravel.com/)
  * MariaDB 10.5 (AppStream) (equals to MySQL 5.7)
  * nodejs (AppStream) (stable version - 16)
  * Nginx 1.20 (dnf module) ~~(latest version - via Nginx Official Repo)~~
  * Redis 6.2
  * Ruby 3.1.2
  * Rails 7.0
    * puma 5 (systemd integrated, puma-systemd-mgr, ~~puma-mgr~~)
  * Redmine 5.0.3
    * ruby 3.1.2
    * rails 6.1.7
  * Useful tools
    * Enhanced tail
      * ~~multitail~~ (not found in RHEL 9)
        * multitail /var/log/nginx/*.access.log
    * Enhanced grep
      * ack
        * ls | ack keyword
        * ack -i keyword *
          * default options (-r, -R, --recurse             Recurse into subdirectories (default: on))
  * Tmux 3.2a
  * VIM Plugins
    * ref https://github.com/charlietag/vim_settings
  * TMUX Plugins
    * ref. https://github.com/charlietag/tmux_settings

## Folder privilege
After this installation repo, the server will setup with "Nginx + Puma (socket)" , "Nginx + PHP-FPM (socket)" , so your Rails, Laravel, can run on the same server.  The following is something you have to keep an eye on it.

1. **folder privilege**

  * Rails Project

    ```bash
    rails new <rails_project> -d mysql --skip-spring
    cd <rails_project>
    chown -R ${current_user}.${current_user} log tmp
    ```

  * Laravel Project

    ```bash
    composer create-project --prefer-dist laravel/laravel <laravel_project>
    cd <laravel_project>
    chown -R ${current_user}.${current_user} storage
    chown -R ${current_user}.${current_user} bootstrap/cache
    ```

2. **Command**

  * Rails

    ```bash
    rails new <rails_project> -d mysql --skip-spring
    ```

  * Rails 5.1 has dropped dependency on jQuery, you might want it back via yarn

    1. Add npm of jquery using Yarn

        ```bash
        cd <rails_project>
        yarn add jquery
        ```

    2. Setup jquery npm for asset pipeline

        ```bash
        vi <rails_project>/app/assets/javascripts/application.js
        ```

        ```bash
        //= require rails-ujs
        //= require turbolinks
        //= require jquery/dist/jquery
        //= require bootstrap/dist/js/bootstrap
        //= require_tree .
        ```

    3. Yarn works with rails 5.1 asset pipeline as below
      * Usage for default path:  <rails_project>/node_modules/{pkg_name}/dist/{pkgname}.{js,css}

        ```bash
        //= require jquery
        ```

      * If package is different from this rule, ex: bootstrap.  You might specify explicitly **(better)**

        ```bash
        //= require jquery
        ```

        ```bash
        //= require jquery/dist/jquery
        //= require bootstrap/dist/js/bootstrap
        ```



  * Laravel

    ```bash
    composer create-project --prefer-dist laravel/laravel <laravel_project>
    ```

  * Useful script snippet
    * If you are always get disconnected, and you want to ***kill last failed connection of SSH***

      ```bash
      netstat -palunt |grep -i est | awk '{print $7}'| cut -d'/' -f1 |xargs -I{} bash -c "ps aux |grep sshd |grep {}|grep -v grep" | head -n -1 | awk '{print $2}' |xargs -I{} kill {}
      ```

    * If you want to restart network for new config, instead of using `systemctl restart network`, which is deprecated in **CentOS 8**
      * Reload network config (mostly, this would work)

        ```bash
        nmcli c reload
        ```

      * Stop networking and start networking in **NetworkManager (NM)**

        ```bash
        nmcli n off; nmcli n on
        ```

    * Since RHEL 9 , no more configs under `/etc/sysconfig/network-scripts/`, instead, keyfile under `/etc/NetworkManager/system-connections` only. So config network using `nmcli` will be a better method

    * Modify network static IP using `nmcli`
      * Setup static ip

        ```bash
        nmcli connection modify eth0 \
          ipv4.addresses 192.168.122.7/24 \
          ipv4.gateway 192.168.122.1 \
          ipv4.dns 192.168.122.1 \
          ipv4.method manual
        ```

      * Disable IPv6, and peerDNS

        ```bash
        nmcli connection modify eth0 \
          ipv4.ignore-auto-dns "true"

        nmcli connection modify eth0 \
          ipv6.method "disabled" \
          ipv6.addr-gen-mode "stable-privacy" \
          ipv6.ignore-auto-dns "true" \
          ipv6.ignore-auto-routes "true" \
          ipv6.never-default "true"
        ```

      * List only device name except loop 0 using `nmcli`

        ```bash
        nmcli -g name connection show
        ```


## Ruby gem config
* gem install without making document
  * Deprecated

    ~~`no-ri, no-rdoc`~~

  * Config

    ```bash
    echo "gem: --no-document" > ~/.gemrc
    ```

## Database configuration for production
* Remove test database and setup root password

  > After doing this, still need some tweak, try to manage database with https://www.adminer.org/

  ```bash
  $ mysql_secure_installation
  ```

  > Just keep **hitting** `<ENTER>`, to `USE ALL DEFAULT SETTING`

* After **mysql_secure_installation**
  * MariaDB 10.5 auth method will just like MariaDB 10.3

* Database tools - Adminer
  * Easy to manage database
    * [adminer.php](https://www.adminer.org/)
  * **Stronger than scaffold, and any other admin panel. For quick CRUD**
    * [Adminer-editor.php](https://www.adminer.org/en/editor/)

## Extra functions
* RENDER_CP
  * Render template using eval (Might have escape issue, if template is complicated)

    ```bash
    # Method : eval "echo \"$variable\""
    ```

  * Sample
    * databag

    ```bash
    local var="Hello World"
    ```

    * template (${$CONFIG_FOLDER}/yourowntemplate_file)

    ```bash
    This is $var
    ```

    * function

    ```bash
    RENDER_CP ${$CONFIG_FOLDER}/yourowntemplate_file /SomeWhere/somewhere
    ```

    * result (/SomeWhere/somewhere)

    ```bash
    This is Hello World
    ```

* RENDER_CP_SED
  * Render template using sed (BETTER method for rendering template)

    ```bash
    # Method : cat template | sed 's/\{\{var\}\}/$var/g'
    ```

  * Sample
    * databag

    ```bash
    local var="Hello World"
    ```

    * template (${$CONFIG_FOLDER}/yourowntemplate_file)

    ```bash
    This is {{var}}
    ```

    * function

    ```bash
    RENDER_CP_SED ${$CONFIG_FOLDER}/yourowntemplate_file /SomeWhere/somewhere
    ```

    * result (/SomeWhere/somewhere)

    ```bash
    This is Hello World
    ```

* SAFE_DELETE
  * Check file names and path before rm any dangerous files, preventing from destoying whole server
    * check for the following dangerous key words

      ```bash
      .
      ..
      *
      /
      .*
      *.*
      ```

      ```bash
      "$(echo "$(find / -maxdepth 1 ;  readlink -m /* )" | sort -n | uniq)"
      ```

  * Sample

    ```bash
    # --- Should be failed ---
    DELETE_FILE="/root/delete_me/.*"
    # --- safe delete command usage ---
    SAFE_DELETE "${DELETE_FILE}"
    ```

## (Git) Stash details
* Ref. https://git-scm.com/docs/git-stash
* (Git) stash list

  ```bash
  $ git stash list
  stash@{0}: WIP on redmine_4.0.7: a853fc0 Fix sort projects table by custom field (#32769).
  stash@{1}: WIP on redmine_4.0.6: 22ebc68 tagged version 4.0.6
  ```

  * redmine_4.0.6 / redmine_4.0.7, these mean branch name
  * if you want to restore data, you'd better checkout the the related branch
* Display all stash contents

  ```bash
  git stash list | cut -d':' -f1 | xargs -I{} bash -c "\
    echo; \
    echo ----------------------------------------------- {} -----------------------------------------------;\
    git stash show -p {}; echo\
  "
  ```

## (Git) Push and Pull
* Push git `commits` to remote

  `git push`

* Push git `tags` to remote

  `git push --tags`

* Fetch git `commits` to local

  `git fetch`

* Fetch git `tags` to local

  `git fetch --tags`

* `Fetch` git `commits` to local *and then* `MERGE` to Working Directory

  `git pull`

## Upgrading Redmine
### Reference
* https://www.redmine.org/projects/redmine/wiki/RedmineUpgrade

### Backup current redmine
* Database
  * `mysqldump -u {db_user} -p --lock-all-tables --skip-tz-utc redmine > redmine_$(date +"%Y%m%d")_skip-tz-utc.sql`
* Application & files
  * `cp -a redmine redmine_bak`

### Customized files
* plugins
  * `/home/rubyuser/rails_sites/redmine/plugins/redmine_*`
* themes
  * `/home/rubyuser/rails_sites/redmine/public/themes/{a1,circle,PurpleMine2}`
* session token
  * `/home/rubyuser/rails_sites/redmine/config/initializers/secret_token.rb`
* uploaded files
  * `/home/rubyuser/rails_sites/redmine/files/`



### (Method 1) Upgrading from a git checkout
* Stop puma server
  * `puma-systemd-mgr -p -i redmine`
* Go to the Redmine root directory and run the following command:

  ```bash
  cd redmine
  git stash
  ```

  ```bash
  git checkout master
  git fetch
  git fetch --tags
  git pull
  ```

  > sometimes `git pull` will not **fetch tags**, `instead`, we need to **fetch tags** by `git fetch --tags`

  > especially when `tags name` or `tags <-> commit` , has been `changed`

  ```bash
  git co 4.0.7 -b redmine_4.0.7
  git stash pop
  git status |grep 'both modified:' |awk '{print $3}' |xargs -I{} bash -c "echo --- git reset HEAD {} ---; git reset HEAD {}"
  ```

* Fix conflicts


* Perform the upgrade

  ```bash
  # gemset name using redmine version
  echo "gemset_redmine_4.1.0" > .ruby-gemset

  # switch to the new gemset
  cd
  cd -

  # Update gem / bundler for this gemset
  gem update --system
  gem install bundler

  # Install the required gems by running the following command
  bundle update

  # Update the database
  bundle exec rake db:migrate RAILS_ENV=production
  bundle exec rake redmine:plugins RAILS_ENV=production

  # Clean up
  bundle exec rake tmp:cache:clear RAILS_ENV=production
  ```

* Start puma server
  * `puma-systemd-mgr -s -i redmine`
* Go to "Admin -> Roles & permissions" to check/set permissions for the new features, if any.
* Finally, clear browser's cached data (To avoid strange CSS error)
  * Chrome -> History -> Clear History -> Choose ONLY "Cached images and files"

### (Method 2) Upgrading from a fresh installation
* Stop puma server
  * `puma-systemd-mgr -p -i redmine`
* Backup current redmine
* Remove the following lines from script `functions/F_02_PKG_06_ruby_09_redmine_create.sh` ([F_02_PKG_06_ruby_09_redmine_create_diff.png](https://raw.githubusercontent.com/charlietag/github_share_folder/master/sample_images/F_02_PKG_06_ruby_09_redmine_create_diff.png))

  ```bash
  if [[ -z "${redmine_db_pass}" ]]; then
    mysql -u root -e "CREATE DATABASE ${redmine_db_name} CHARACTER SET utf8;"
  else
    mysql -u root -p${redmine_db_pass} -e "CREATE DATABASE ${redmine_db_name} CHARACTER SET utf8;"
  fi
  ```

  ```bash
  su -l $current_user -c "cd ${redmine_web_root} && bundle _${this_redmine_bundler_version}_ exec rake generate_secret_token"
  ```

  ```bash
  if [[ -n "${redmine_default_lang}" ]]; then
    su -l $current_user -c "cd ${redmine_web_root} && bundle _${this_redmine_bundler_version}_ exec rake redmine:load_default_data RAILS_ENV=production REDMINE_LANG=${redmine_default_lang}"
  fi
  ```

* Perform the fresh installation
  * `./start -i F_02_PKG_06_ruby_09_redmine_create`

* Restore files from backup
  * `redmine/config/initializers/secret_token.rb`
  * `redmine/files/`

* Start puma server
  * `puma-systemd-mgr -s -i redmine`

* Go to "Admin -> Roles & permissions" to check/set permissions for the new features, if any.
* Finally, clear browser's cached data (To avoid strange CSS error)
  * Chrome -> History -> Clear History -> Choose ONLY "Cached images and files"

## Upgrading MariaDB

For some cases, we need to upgrade MariaDB without data lost.  Here is my note about this.

### Reference (mariadb.com)
* https://mariadb.com/kb/en/upgrading-from-mariadb-104-to-mariadb-105/#how-to-upgrade

### How to Upgrade

* Backup current database

  ```bash
  # mysqldump -u root -p --lock-all-tables --skip-tz-utc -A > all_`date +"%Y%m%d"`_skip-tz-utc.sql
  ```

* Stop MariaDB

  ```bash
  # systemctl stop mariadb
  ```

* Uninstall the old version of MariaDB

  ```bash
  dnf remove -y MariaDB-common MariaDB-client MariaDB-shared MariaDB-server MariaDB-devel
  ```

* Modify the repository configuration to newer version
* Install the new version of MariaDB

  ```bash
  dnf install -y MariaDB-common MariaDB-client MariaDB-shared MariaDB-server MariaDB-devel
  ```

* Make any desired changes to configuration options in option files, such as my.cnf. This includes removing any options that are no longer supported.

  ```bash
  # cat /etc/my.cnf.d/server.cnf | grep -B1 '127.0.0'
  [mysqld]
  bind-address = 127.0.0.1
  ```

* Start MariaDB

  ```bash
  # systemctl start mariadb
  ```

* Run `mysql_upgrade`
  * mysql_upgrade does two things:
    * Ensures that the system tables in the#[mysql](https://mariadb.com/kb/en/the-mysql-database-tables/) database are fully compatible with the new version.
    * Does a very quick check of all tables and marks them as compatible with the new version of MariaDB .
  * `mysql_upgrade -u root -p`
    * After this command, there would be a file generated for letting you know this database has already been upgraded. (owner of the file is root)

      ```bash
      $ ls /var/lib/mysql | grep upgrade
      -rw-r--r--  1 root  root    15 Sep  9 14:24 mysql_upgrade_info
      ```

      ```bash
      $ cat mysql_upgrade_info
      10.5.5-MariaDB
      ```

* Restart MariaDB - Done
  * It would be better to restart MariaDB, if it's allowed.

    ```bash
    # systemctl restart mariadb
    ```


# CHANGELOG
* 2022/11/27
  * tag: v0.0.1
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v0.0.1...master
      * Initial Ubuntu Preparation
