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
  * [Uninstall Redmine Plugins](#uninstall-redmine-plugins)
  * [Upgrading MariaDB](#upgrading-mariadb)
    + [Reference (mariadb.com)](#reference-mariadbcom)
    + [How to Upgrade](#how-to-upgrade)
  * [Ubuntu notes](#ubuntu-notes)
    + [crontab environment](#crontab-environment)
    + [Network](#network)
    + [gnupg2 (gpg)](#gnupg2-gpg)
    + [APT - Interactive settings](#apt---interactive-settings)
    + [APT command](#apt-command)
    + [DPKG usage](#dpkg-usage)
    + [Package name convention](#package-name-convention)
    + [3rd party repo (BE CAREFUL)](#3rd-party-repo-be-careful)
    + [snapd](#snapd)
    + [ssh client known hosts hash](#ssh-client-known-hosts-hash)
    + [Editor](#editor)
    + [User manipulation](#user-manipulation)
  * [Python notes](#python-notes)
    + [pyenv](#pyenv)
    + [poetry](#poetry)
    + [pip](#pip)
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
  * **NGINX + PUMA + PHP-FPM + MariaDB + Rails + Laravel + Redmine + Redis**

# Environment
  * Ubuntu 22.04
    * ubuntu_preparation
      * release : `main` `v1.x.x`

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
      * Add GENERAL USER and setup password of GENERAL USER ([link](https://github.com/charlietag/ubuntu_preparation#user-manipulation))

        ```bash
        useradd -m -s /bin/bash {user}
        ```

      * Make GENERAL USER identifiable

        ```bash
        cat << EOF >> /home/{user}/.bashrc
        PS1='\${debian_chroot:+(\$debian_chroot)}\u@\h:\w\\$ '
        EOF
        ```

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
        cat << EOF > /etc/rc.local
        #!/bin/bash
        touch /var/lock/subsys/local
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
      ├── F_00_OS_02_env.cfg
      ├── F_01_ENV_04_ssh_config.cfg
      └── _gitconfig.cfg
      ```

    * **IP / DNS / NTP** (server in **Local** / server in **Cloud**) for who needs **customization** IP, DNS, NTP

      ```bash
      databag/
      ├── F_00_OS_01_ip.cfg
      └── F_00_OS_02_env.cfg
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
I'm a lazy person.  I want to install **ALL** and give me default configurations running **Nginx , MariaDB, php-fpm, puma 5 (rails), redis**.  And help me to create default projects about "Rails" and "Laravel"

* Command

  ```bash
  ./start.sh -a
  reboot
  ```

* disable geoipupdate timer (for some cases) - [ubuntu_preparation](https://github.com/charlietag/ubuntu_preparation) makes this default

  ```bash
  systemctl list-unit-files |grep -i ^geoipupdate | awk '{print $1}' | xargs | xargs -I{} bash -c "systemctl stop {}; systemctl disable {}"
  ```

* Default project path
  * DEFAULT user for rails/laravel developer is not ssh allowed
    * /etc/ssh/sshd_config

      ```bash
      DenyGroups no-ssh-group
      ```

  * group "no-ssh-group" add to default dev user
    * phpuser (this name can be modified)
    * rubyuser (this name can be modified)
    * jsuser (this name can be modified)
    * pythonuser (this name can be modified)
    * podmanuser (this name can be modified)

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

* Config your client hosts file (/etc/hosts) for browser

  ```bash
  <192.168.x.x> myrails.ubuntu22.localdomain
  <192.168.x.x> redmine.ubuntu22.localdomain
  <192.168.x.x> mylaravel.ubuntu22.localdomain
  ```

* Browse URL

  ```bash
  http://myrails.ubuntu22.localdomain
  http://redmine.ubuntu22.localdomain (default account: admin/admin)
  http://mylaravel.ubuntu22.localdomain
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

# Note

## Installed Packages
  * PHP 8.1
  * PHP-FPM
  * Laravel 10.x (Ref. https://laravel.com/)
  * MariaDB 10.6 (equals to MySQL 5.7)
  * nodejs 20 (Ref. https://nodejs.org/en/)
  * Nginx 1.24 (Ref. https://nginx.org/)
  * Redis 7 (Ref. https://redis.io/)
  * Ruby 3.2.2 +YJIT (rvm)
  * Rails 7.0
    * puma 5 (systemd integrated, puma-systemd-mgr, ~~puma-mgr~~)
  * Redmine 5.0.5
    * ruby 3.1.3
    * rails 6.1.7
  * Python 3.12 (pyenv)
    * pyenv (https://github.com/pyenv/pyenv)
    * poetry (https://python-poetry.org/)
  * Useful tools
    * Enhanced tail
      * multitail
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
    rails new <rails_project> -d mysql -j esbuild -c bootstrap
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
    rails new <rails_project> -d mysql -j esbuild -c bootstrap
    ```

  * **Rails 7 has intergrated with stimulusjs, stop using jquery**
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
  * MariaDB 10.5+ auth method will just like MariaDB 10.3

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
  * `mysqldump -u {db_user} -p --lock-all-tables --skip-tz-utc -B redmine > redmine_$(date +"%Y%m%d")_skip-tz-utc.sql`
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
    mysql -u root -e "CREATE DATABASE ${redmine_db_name} CHARACTER SET utf8mb4;"
  else
    mysql -u root -p${redmine_db_pass} -e "CREATE DATABASE ${redmine_db_name} CHARACTER SET utf8mb4;"
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

## Uninstall Redmine Plugins

Ref.  https://www.redmine.org/projects/redmine/wiki/plugins#Uninstalling-a-plugin

* Backup current redmine
  * Database
    * `mysqldump -u {db_user} -p --lock-all-tables --skip-tz-utc -B redmine > redmine_$(date +"%Y%m%d")_skip-tz-utc.sql`
  * Application & files
    * `cp -a redmine redmine_bak`

* **Steps of uninstalling {plugin_name}**
  * Uninstall from database

    ```bash
    bundle exec rake redmine:plugins:migrate NAME={plugin_name} VERSION=0 RAILS_ENV=production
    ```

  * Remove your plugin from the plugins folder: #{RAILS_ROOT}/plugins.
  * Restart Redmine

## Upgrading MariaDB

For some/**view** cases, we need to upgrade MariaDB without data lost.  Here is my note about this.

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
  apt purge -y mariadb-server libmariadb-dev libmariadb-dev-compat
  ```

* Modify the repository configuration to newer version
* Install the new version of MariaDB

  ```bash
  apt install -y mariadb-server libmariadb-dev libmariadb-dev-compat
  ```

* Make any desired changes to configuration options in option files, such as my.cnf. This includes removing any options that are no longer supported.

  ```bash
  # cat /etc/mysql/mariadb.conf.d/50-server.cnf | grep -B1 '127.0.0'
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

## Ubuntu notes

### crontab environment

* Default SHELL and PATH
  * `/etc/crontab`

    ```bash
    # make sure crontab use bash and PATH is correct
    sed -i /SHELL/d /etc/crontab
    sed  '1s/^/SHELL\=\/bin\/bash\n/' -i /etc/crontab

    sed -re 's/^#PATH\=/PATH\=/g' -i /etc/crontab
    ```

* Default command argv (most deference CentOS vs Ubuntu)
  * `/etc/default/*`
  * Sample

    ```bash
    # cat /etc/default/useradd | grep -vE '^#'
    SHELL=/bin/sh
    ```

### Network
* **Network** for Ubuntu 22
  * By default - no more NetworkManager, use **netplan + Systemd-networkd** instead
    * Ref. https://netplan.io/
    * Ref. [99-network-config_static.yaml](https://github.com/charlietag/ubuntu_preparation/blob/main/templates/F_00_OS_01_ip/etc/netplan/99-network-config_static.yaml)
  * [https://netplan.io/](https://netplan.io/)
    * <img src="https://assets.ubuntu.com/v1/a1a80854-netplan_design_overview.svg" data-canonical-src="https://assets.ubuntu.com/v1/a1a80854-netplan_design_overview.svg" width="30%">

      * Netplan currently works with these supported renderers
        * [NetworkManager](https://help.ubuntu.com/community/NetworkManager)
        * [Systemd-networkd](http://manpages.ubuntu.com/manpages/bionic/man5/systemd.network.5.html)

      * Senario
        * NetworkManager
          * Use for Desktop, such as wifi
        * Systemd-networkd
          * Use for server, such as netplan use

      * Commands
        * Netplan uses a set of subcommands to drive its behavior:
          * **netplan generate**: Use `/etc/netplan` to generate the required configuration for the renderers.
          * **netplan apply**: Apply all configuration for the renderers, restarting them as necessary.
          * **netplan try**: Apply configuration and wait for user confirmation; will roll back if network is broken or no confirmation is given.

  * check current DNS setting
    * `resolvectl`

### gnupg2 (gpg)
* Public key types
  * **Binary (--dearmor)**
    * **CAN BE** imported by

      ```bash
      gpg --import redis-archive-keyring.gpg
      ```

    * Command

      ```bash
      curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
      ```

  * **ASCII (--enarmor)**
    * **CAN BE** imported by

      ```bash
      gpg --import redis.asc
      ```

    * Command

      ```bash
      gpg --enarmor < redis-archive-keyring.gpg > redis.asc
      ```

* List `public` keys under `~/.gnupg`
  * `gpg -k`

* List `private` keys under ~/.gnupg
  * `gpg -K`

* Display content of `public` from key files (ascII or binary)
  * `gpg --show-keys {redis.gpg|redis.asc}`
  * Originally
    * `gpg import {plain ascii[redis.asc] | gpg bin file[redis.gpg]}`
    * Then `gpg -k`

* Sample
  * `enarmor` ascII (key.asc) transfor to bin file (key.gpg)

    ```bash
    curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
    ```

> gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

* How the command above does
  * import 2 public keys

    ```bash
    curl -sSL https://raw.githubusercontent.com/charlietag/github_share_folder/master/rvm_gpg_public_keys/mpapis.asc | gpg --import -
    curl -sSL https://raw.githubusercontent.com/charlietag/github_share_folder/master/rvm_gpg_public_keys/pkuczynski.asc | gpg --import -
    ```

  * Add 2 public keys into **ownertrust**

    ```bash
    echo 409B6B1796C275462A1703113804BB82D39DC0E3:6: | gpg2 --import-ownertrust
    echo 7D2BAF1CF37B13E2069D6956105BD0E739499BDB:6: | gpg2 --import-ownertrust
    ```

  * Ownertrust
    * Ref. [how-to-raise-a-key-to-ultimate-trust-on-another-machine](https://security.stackexchange.com/questions/129474/how-to-raise-a-key-to-ultimate-trust-on-another-machine)

      ```bash
      1 = I don't know or won't say => will be = 2
      2 = I do NOT trust => will be = 3
      3 = I trust marginally => will be = 4
      4 = I trust fully => will be = 5
      5 = I trust ultimately => will be = 6
      ```

* Generate self gpg key pairs
  * Ref. https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key

* Use for software (apt sign_by)
  * Ref. [verify-pgp-signature-software-downloads-linux](https://www.linuxbabe.com/security/verify-pgp-signature-software-downloads-linux)
  * Verify packages via public key procedure
    * wget VeraCrypt/VeraCrypt_PGP_public_key.asc
    * gpg --show-keys VeraCrypt_PGP_public_key.asc
    * compare keys listed above with website mentioned (use like md5sum)
    * gpg --import VeraCrypt_PGP_public_key.asc
    * gpg --verify veracrypt-1.24-Update7-Ubuntu-20.04-amd64.deb.sig veracrypt-1.24-Update7-Ubuntu-20.04-amd64.deb
      * **good signature**

* Use for apt-key (keyring.gpg)
  * Ref. [apt-key-deprecated](https://itsfoss.com/apt-key-deprecated/)
    * The gpg --dearmor part is important because the mechanism expects you to have the keys in binary format.
  * Old school (deprecated)
    * ~~apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10~~
  * Nowadays
    * Just put binary format gpg keyring under `/etc/apt/trusted.gpg.d`

      ```bash
      curl -sSL https://www.mongodb.org/static/pgp/server-6.0.asc | gpg --dearmor -o mongodb-server-keyring.gpg
      ```

  * Sample command

    ```bash
    root@u22:~# apt-key list
    Warning: apt-key is deprecated. Manage keyring files in trusted.gpg.d instead (see apt-key(8)).
    /etc/apt/trusted.gpg.d/ubuntu-keyring-2012-cdimage.gpg
    ------------------------------------------------------
    pub   rsa4096 2012-05-11 [SC]
          8439 38DF 228D 22F7 B374  2BC0 D94A A3F0 EFE2 1092
    uid           [ unknown] Ubuntu CD Image Automatic Signing Key (2012) <cdimage@ubuntu.com>

    /etc/apt/trusted.gpg.d/ubuntu-keyring-2018-archive.gpg
    ------------------------------------------------------
    pub   rsa4096 2018-09-17 [SC]
          F6EC B376 2474 EDA9 D21B  7022 8719 20D1 991B C93C
    uid           [ unknown] Ubuntu Archive Automatic Signing Key (2018) <ftpmaster@ubuntu.com>

    root@u22:~# cd /etc/apt/trusted.gpg.d
    root@u22:/etc/apt/trusted.gpg.d# ll
    total 16
    drwxr-xr-x 2 root root 4096 Nov 28 23:33 ./
    drwxr-xr-x 8 root root 4096 Nov 28 23:37 ../
    -rw-r--r-- 1 root root 2794 Mar 26  2021 ubuntu-keyring-2012-cdimage.gpg
    -rw-r--r-- 1 root root 1733 Mar 26  2021 ubuntu-keyring-2018-archive.gpg
    root@u22:/etc/apt/trusted.gpg.d# curl -sSL https://www.mongodb.org/static/pgp/server-6.0.asc | gpg --dearmor -o mongodb-server-keyring.gpg
    root@u22:/etc/apt/trusted.gpg.d# apt-key list
    Warning: apt-key is deprecated. Manage keyring files in trusted.gpg.d instead (see apt-key(8)).
    /etc/apt/trusted.gpg.d/mongodb-server-keyring.gpg
    -------------------------------------------------
    pub   rsa4096 2022-02-23 [SC] [expires: 2027-02-22]
          39BD 841E 4BE5 FB19 5A65  400E 6A26 B1AE 64C3 C388
    uid           [ unknown] MongoDB 6.0 Release Signing Key <packaging@mongodb.com>

    /etc/apt/trusted.gpg.d/ubuntu-keyring-2012-cdimage.gpg
    ------------------------------------------------------
    pub   rsa4096 2012-05-11 [SC]
          8439 38DF 228D 22F7 B374  2BC0 D94A A3F0 EFE2 1092
    uid           [ unknown] Ubuntu CD Image Automatic Signing Key (2012) <cdimage@ubuntu.com>

    /etc/apt/trusted.gpg.d/ubuntu-keyring-2018-archive.gpg
    ------------------------------------------------------
    pub   rsa4096 2018-09-17 [SC]
          F6EC B376 2474 EDA9 D21B  7022 8719 20D1 991B C93C
    uid           [ unknown] Ubuntu Archive Automatic Signing Key (2018) <ftpmaster@ubuntu.com>
    ```


### APT - Interactive settings
* Ref [F_00_PRE_00_disable_apt_interactive_mode.sh](https://github.com/charlietag/ubuntu_preparation/blob/main/functions/F_00_PRE_00_disable_apt_interactive_mode.sh)
* **needrestart**
  * When install packages this will check related services and prompt window to ask user decide whether to restart related services
    * Ref. [askubuntu-apt-get-upgrade-auto-restart-services](https://askubuntu.com/questions/1367139/apt-get-upgrade-auto-restart-services)
    * Ref. [stackoverflow-how-to-stop-ubuntu-pop-up-daemons-using-outdated-libraries-when-using-apt-to-i](https://stackoverflow.com/questions/73397110/how-to-stop-ubuntu-pop-up-daemons-using-outdated-libraries-when-using-apt-to-i)
* **ucf**
  * When install some packages (like openssh-server), this will check if the config files are modified and prompt window to ask user to decide whether to override the config files
    * Ref. [askubuntu-automatically-keep-current-sshd-config-file-when-upgrading-openssh-server](https://askubuntu.com/questions/1421676/automatically-keep-current-sshd-config-file-when-upgrading-openssh-server)

* **DEBIAN_FRONTEND="noninteractive"**
  * Ignore settings above , just skip all interactive config prompt
### APT command

* Remove package
  * Remove packages only

    ```bash
    apt remove -y {package}
    ```

  * Remove packages + delete config files (Mostly used - Useful for some cases)

    ```bash
    apt remove -y --purge {package}
    ```

    ```bash
    apt purge -y {package}
    ```

  * Remove packages + remove related packages without warning message

    ```bash
    apt remove --autoremove -y {package}
    ```

    ```bash
    apt autoremove -y {package}
    ```

  * Combined usage (Mostly used)

    ```bash
    apt autoremove -y --purge {package}
    ```

    ```bash
    apt remove --purge --autoremove -y {package}
    ```

  * Remove **all** unused packages (Useful)

    ```bash
    apt autoremove -y --purge
    ```

### DPKG usage

* Find specific package

  ```bash
  dpkg -l | grep {package}
  ```

* Fine specific file **belongs to what package**

  ```bash
  dpkg -S {filename}
  ```

* List all files belongs to specific package

  ```bash
  dpkg -L {package}
  ```

* Find config files of specific package

  ```bash
  dpkg -L {package} |grep "^\/etc"
  ```

* Show info of specific package

  ```bash
  apt show {package}
  ```

  (apt `info` {package} is an alias of `show`)

### Package name convention

* {pkg}
* lib{pkg}
* lib{pkg}-dev
  * Usually this contains `lib{pkg}`
* Sample
  * (CentOS) openssl openssl-libs openssl-devel
  * (Ubuntu) openssl libssl-dev

### 3rd party repo (BE CAREFUL)

**Be CAREFUL using this**

> packages here are not verified by Ubuntu

* Platform (Launchpad - PPA) hosted by Ubuntu, but **packages are not maintained by Ubuntu**
* You can contribute your own packages on PPA platform
  * Ref. https://launchpad.net/
* Install package `software-properties-common` (add-apt-repository) first
* Install PPA
  * Install php 8.2 in Ubuntu 22.04
    * `ppa:ondrej/php` is like `remi` in RedHat world
    * Ref. [install-php-8-2-ubuntu-22-04](https://techvblogs.com/blog/install-php-8-2-ubuntu-22-04)

      ```bash
      add-apt-repository ppa:ondrej/php
      apt update
      apt install php8.2 php8.2-fpm php8.2-mysql
      ```

* Remove PPA
  * Uninstall package **entirely**

    ```bash
    apt remove --purge --autoremove -y php8.2 php8.2-fpm php8.2-mysql
    ```

  * Remove PPA

    ```bash
    add-apt-repository --remove ppa:ondrej/php
    ```

### snapd

![snapd.png](https://raw.githubusercontent.com/charlietag/github_share_folder/master/doc_images/snapd/snapd.png)

* Useful sandbox application - out-of-the-box application (same as RedHat - flatpak)
  * Pros - Easy to use
  * Cons - needs more disk spaces
* Almost a lot of Desktop UI features are based on Snapd
* ~~Cannot be removed, especial rails package `libvips` is based on Snapd~~
* Remove snapd totally
  * Remove snapd steps
    * Ref. [F_00_PRE_00_pkgs_remove_snapd.sh](https://github.com/charlietag/ubuntu_preparation/blob/main/functions/F_00_PRE_00_pkgs_remove_snapd.sh)
  * LinuxMint disable snapd by default
    * Ref. [disabled-snap-store-in-linux-mint-20](https://linuxmint-user-guide.readthedocs.io/en/latest/snap.html#disabled-snap-store-in-linux-mint-20)

* Note
  * If `apt remove snapd` ~~(**NOT RECOMMEND**)~~ is triggered, the `systemd` is changed, the follow command should be executed

    ```bash
    systemctl daemon-reload
    ```

### ssh client known hosts hash

* **/etc/ssh/ssh_config**
  * By default - debian based ssh client , `HashKnownHosts=yes`, for some cases you might want to set it to `no`
  * Otherwise, you need to find public key of hosts by command as below
    * Check existence

      ```bash
      ssh-keygen -F dev.server.name
      ```

    * Remove existence

      ```bash
      ssh-keygen -R dev.server.name
      ```

### Editor

* Default - `nano`
* Switch default editor to `vim`
  * Ref. [F_00_PRE_03_default_editor_vim.sh](https://github.com/charlietag/ubuntu_preparation/blob/main/functions/F_00_PRE_03_default_editor_vim.sh)

    ```bash
    update-alternatives --set editor /usr/bin/vim.basic
    ```

  * Ref. [zz99-default_editor.sh](https://github.com/charlietag/ubuntu_preparation/blob/main/templates/F_00_PRE_03_default_editor_vim/etc/profile.d/zz99-default_editor.sh)

    ```bash
    export EDITOR="vim"
    ```

### User manipulation

* Add user
  * **(PREFERED)** Have to specify `shell` and `create home` manually

    ```bash
    useradd -m -s /bin/bash {user}
    ```

  * (Alternative , **NOT** prefered) use ~~perl script~~ - adduser
    * Interactive (Ask a lot of questions)

      ```bash
      adduser {user}
      ```

    * Don't ask, just create user like `useradd -m -s {user}` does

      ```bash
      adduser -q --disabled-login --gecos "" <user>
      ```

* Delete user
  * **(PREFERED)** Delete home directory

    ```bash
    userdel -r {user}
    ```

  * (Alternative , **NOT** prefered) use *perl script* - deluser

    ```bash
    deluser --remove-home {user}
    ```

* Delete user (**DANGER**)
  * **DANGER DO NOT USE** *perl script*
    * find / belongs to username and delete it
      * ~~deluser --remove-all-files {user}~~

* Lock user

  ```bash
  usermod -s "/bin/false"
  ```

* List users (useful)

  ```bash
  lslogin
  ```

## Python notes

### pyenv

Similar with `rvm`

* List all versions
  * `rvm list known`
  * `pyenv install -l | grep -E "[[:space:]]+[[:digit:]\.]+$"`

* Install specific version
  * `rvm install 3.2`
  * `pyenv install 3.11`

* Switch version for current **session**
  * `rvm use 3.2`
  * `pyenv shell 3.11`

* Change **DEFAULT** version
  * `rvm use 3.2 --default`
  * `pyenv global 3.11` (config locates `$(pyenv root)/version`)

* Change version for current **folder**
  * Just edit version in file `folder/.ruby-version`
  * In pyenv, edit version in file `folder/.python-version` (can just use command `pyenv local 3.11`)

### poetry

* Install poetry
  * (Python > 3.7) `curl -sSL https://install.python-poetry.org | python3 -`
  * If you install poetry through pyenv python (ie. 3.11), DO NOT uninstall the version(ie. 3.11), otherwise poetry will not be able to use (cannot find python3.11.so)...

Similar with `bundler`

* Execute command within venv
  * `bundle exec rails`
  * `poetry run django-admin startproject basic_django .`
    * Sample template(Django) [link](https://builtwithdjango.com/blog/basic-django-setup)

* Excute command within venv (easier way), after making sure poetry env is created (`poetry env list`)
  * `poetry shell`
  * Then all python command is within `venv`

* New poetry Pypi package (not for create project --- use `poetry init -n` instead for project)
  * similliar with `bundle gem ruby-gem-demo`
  * `poetry new pip-package-demo`

* New poetry project
  * `mkdir project-demo`
  * `cd project-demo`
  * `pyenv local 3.11`
  * `poetry init -n` (do not use -q, quiet, otherwise it will include current project as package while poetry install)
  * `cat pyproject.toml |grep python | grep '3.11'`
  * `poetry env use python`
  * `poetry install`
  * Reference ([poetry-new_project](https://github.com/charlietag/ubuntu_preparation/blob/main/templates/F_02_PKG_07_python_00_user_pythonuser/user_home/bin/poetry-new_project))

* Make sure project is using correct python version (ex. `^3.11``) for both `pyenv (.python-version)` and `poetry (pyproject.toml)`

  ```bash
  cd poetry-demo
  cat pyproject.toml |grep python | grep '3.11'
  pyenv local 3.11
  ```

* Create venv (ex. using Python 3.11) using `poetry`

  ```bash
  cd poetry-demo
  poetry env use python
  ```

* Make sure venv is created
  * `poetry env list`

* Install packages (`poetry.lock` generated)
  * `poetry install`

* Add packages into project (`poetry.lock` updated)
  * `bundle add rails`
  * `poetry add django`

### pip

Conclusion for below: **Just use poetry to manage python packages**

* If pip package(ie. panda) is not installed by user `root`
  * (general user) pip will store the changes under user home folder, will not effect global version
* If pip package(ie. panda) **IS** installed by user `root`
  * pip will detect if package is already installed
    * if no, install local (pip install `panda`--user)
    * if yes, try to install under `/usr/local/lib/python3.10/dist-packages`, and if no writeable priv, it will install with `--user` by default
* show detail info

  ```bash
  $ pip show panda
  Name: panda
  Version: 0.3.1
  Summary: A Python implementation of the Panda REST interface
  Home-page: http://www.pandastream.com
  Author: pandastream.com
  Author-email: support@pandastream.com
  License: MIT
  Location: /usr/local/lib/python3.10/dist-packages
  Requires: requests, setuptools
  Required-by:
  ```

### Upgrade pyenv and poetry

* pyenv
  * `cd ~/.pyenv ; git pull`
* poetry
  * `poetry self update`


# CHANGELOG
* 2022/11/27
  * tag: v0.0.0
      * Initial Ubuntu Preparation
* 2023/01/25
  * tag: v1.0.0
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v0.0.0...v1.0.0
      * First release of ubuntu_preparation
  * tag: v1.0.1
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.0.0...v1.0.1
      * Review and modify Readme document
* 2023/01/26
  * tag: v1.0.2
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.0.1...v1.0.2
      * Add notes about ppa and gpg keyring
  * tag: v1.0.3
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.0.2...v1.0.3
      * Remove comments
  * tag: v1.0.4
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.0.3...v1.0.4
      * Add more info into Readme
  * tag: v1.0.5
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.0.4...v1.0.5
      * Add `export DEBIAN_FRONTEND="noninteractive"`
* 2023/01/30
  * tag: v1.0.6
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.0.5...v1.0.6
      * Remove CentOS related notes
      * Default crontab env var
      * ToC changed
      * Move atop command to ubuntu_security
      * Default `ufw disable`
      * add desc about /etc/default/*
* 2023/01/31
  * tag: v1.0.7
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.0.6...v1.0.7
      * Disable geoipdate timer by default
* 2023/02/01
  * tag: v1.0.8
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.0.7...v1.0.8
      * RVM installer from rvm.io to raw.githubusercontent.com
      * Remove `snapd` totally
  * tag: v1.0.9
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.0.8...v1.0.9
      * Install redis through another script
      * Do not disable chrony by default, `F_00_OS_02_env` will decide whether enable , or disable chrony
  * tag: v1.0.10
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.0.9...v1.0.10
      * systemctl mask apache
* 2023/02/02
  * tag: v1.0.11
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.0.10...v1.0.11
      * Optimize redis installation
  * tag: v1.0.12
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.0.11...v1.0.12
      * typo
* 2023/02/03
  * tag: v1.0.13
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.0.12...v1.0.13
      * Optimize installation code
* 2023/02/04
  * tag: v1.0.14
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.0.13...v1.0.14
      * Modify README.md
* 2023/02/05
  * tag: v1.0.15
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.0.14...v1.0.15
      * Add `search` argv into `/etc/resolv.conf` for temp use
  * tag: v1.0.16
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.0.15...v1.0.16
      * Add `search` argv into `/etc/resolv.conf` (first line) for temp use
      * And `/etc/resolv.conf` max nameserver entries is 3
* 2023/02/06
  * tag: v1.0.17
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.0.16...v1.0.17
      * link-local: [  ]  # To avoid that netplan create Zero Configuration Network 169.254.0.0 and generate IPv6 IP
      * Ref. https://netplan.io/reference
* 2023/02/07
  * tag: v1.1.0
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.0.17...v1.1.0
      * Add redmine default plugin:
        * redmine_checklists-3_1_22-light
        * redmine_issues_tree-5.0.x
        * redmine_x_lightbox2
        * redmine_dashboard
        * redmine_issue_templates
* 2023/02/09
  * tag: v1.1.1
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.1.0...v1.1.1
      * rename function for env config
  * tag: v1.1.2
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.1.1...v1.1.2
      * do `netplan generate` first (sometimes, *netplan try*, *netplan apply*, will kill current ssh session)
      * *apt upgrade* trigger netplan upgrade, and this may cause netplan generate and `/etc/resolv.conf` will be modified
* 2023/02/11
  * tag: v1.1.3
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.1.2...v1.1.3
      * add note - how to uninstall redmine plugins
* 2023/02/12
  * tag: v1.1.4
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.1.3...v1.1.4
      * Add defaut alias setup for podman
* 2023/02/14
  * tag: v1.1.5
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.1.4...v1.1.5
      * Optimize nginx default server setting
* 2023/02/19
  * tag: v1.2.0
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.1.5...v1.2.0
      * Ruby version 3.2.0 -> 3.2.1
* 2023/02/20
  * tag: v1.2.1
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.2.0...v1.2.1
      * Laravel 9.x -> 10.x
* 2023/02/26
  * tag: v1.2.2
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.2.1...v1.2.2
      * Change login message
* 2023/03/18
  * tag: v1.2.3
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.2.2...v1.2.3
      * `alias tls='ps aux |grep -E "tmux[[:space:]]+"'`
* 2023/04/15
  * tag: v1.2.4
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.2.3...v1.2.4
      * ruby 3.2.1 -> 3.2.2
      * redmine 5.0.4 -> 5.0.5
* 2023/06/10
  * tag: v1.2.5
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.2.4...v1.2.5
      * add php-bz2
  * tag: v1.2.6
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.2.5...v1.2.6
      * create database charset default utf8(utf8mb3) -> utf8mb4
* 2023/07/18
  * tag: v1.2.7
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.2.6...v1.2.7
      * Add notes about: create database charset default utf8(utf8mb3) -> utf8mb4
* 2023/07/21
  * tag: v1.2.8
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.2.7...v1.2.8
      * Revise Readme - Nginx default version 1.22 -> 1.24
* 2023/08/05
  * tag: v1.2.9
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.2.8...v1.2.9
      * Redmine plugin: redmine_ckeditor
  * tag: v1.2.10
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.2.9...v1.2.10
      * Redmine plugin: redmine_ckeditor `disabled by default`
  * tag: v1.2.11
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.2.10...v1.2.11
      * Redmine plugin: redmineup_tags-2_0_13-light `disabled by default`
* 2023/08/13
  * tag: v1.3.0
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.2.11...v1.3.0
      * by default install pyenv , poetry
      * Setup python bash prompt for pyenv, poetry, tmux for python venv
  * tag: v1.3.1
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.3.0...v1.3.1
      * fix venv path verification
* 2023/08/15
  * tag: v1.3.2
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.3.1...v1.3.2
      * make alias command for pyenv and poetry
      * python venv in tmux automatically activate
* 2023/08/16
  * tag: v1.3.3
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.3.2...v1.3.3
      * source .bash_user/ script in order
      * optimize `poetry env info --path`
      * add script `poetry-new_project` for creating a new empty project (not **package**) in one command
* 2023/08/17
  * tag: v1.3.4
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.3.3...v1.3.4
      * poetry-new_project - add help
* 2023/08/18
  * tag: v1.3.5
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.3.4...v1.3.5
      * poetry-new_project - add empty project check
* 2023/08/22
  * tag: v1.3.6
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.3.5...v1.3.6
      * Use customized venv_prompt
* 2023/08/23
  * tag: v1.3.7
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.3.6...v1.3.7
      * change venv_prompt color
  * tag: v1.3.8
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.3.7...v1.3.8
      * Add alias for `poetry show --tree`
* 2023/09/03
  * tag: v1.3.9
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.3.8...v1.3.9
      * optimize python poetry venv prompt script
* 2023/09/04
  * tag: v1.3.10
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.3.9...v1.3.10
      * vim tab spaces: set default to `2`, for python script set to `4`
* 2023/09/08
  * tag: v1.3.11
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.3.10...v1.3.11
      * ALL USER ---> vim tab spaces: set default to `2`, for python script set to `4`
* 2023/10/02
  * tag: v1.4.0
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.3.11...v1.4.0
      * NodeJS 18 -> 20
      * tune snapd removal
* 2023/10/03
  * tag: v1.5.0
    * changelog: https://github.com/charlietag/ubuntu_preparation/compare/v1.4.0...v1.5.0
      * Python 3.11 -> 3.12
