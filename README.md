[![GitHub tag (latest SemVer)](https://img.shields.io/github/v/release/wesbuck/vagrant-debian-php?logo=github)](https://github.com/wesbuck/vagrant-debian-php/releases)
[![GitHub License](https://img.shields.io/github/license/wesbuck/vagrant-debian-php?logo=open-source-initiative)](https://opensource.org/licenses/MIT)
[![vagrant up](https://github.com/wesbuck/vagrant-debian-php/actions/workflows/vagrant-up.yml/badge.svg)](https://github.com/wesbuck/vagrant-debian-php/actions/workflows/vagrant-up.yml)

# vagrant-debian-php
Quickly deploy a local [Vagrant](https://www.vagrantup.com/) box running **Debian 10 &amp; PHP 8** to develop or test your application(s). Comes with MariaDB (MySql) and PHPMyAdmin set up and ready to go.

# Installation

Download & Install:
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (latest version, tested with 6.1.26)
- [Vagrant](https://www.vagrantup.com/downloads.html) (latest version, tested with 2.2.18)
- this repo

## Update Configuration
If you intend on using git repos in your Vagrant box, open up the `.gitconfig` file and fill out your name & email address.

Any of the default settings can be changed in the `provisions.sh` file:
```bash
## Server settings
SERVER_TIMEZONE="America/Toronto"

## Database settings
ROOT_DB_PASSWORD="rpass"
ADMIN_DB_NAME="admin"
ADMIN_DB_PASSWORD="apass"

## PHP settings
PHP_VERSION="8.0"
PHP_MODULES=(curl json xml dev gd mbstring zip mysql imagick mcrypt soap cli memcached redis gmp mongodb odbc pgsql sqlite3 xsl)
```
You can probably delete many of the PHP modules to speed up server installation.
## Spin Up Vagrant Server.
Browse to the directory of this repo in a shell. [Git Bash](https://gitforwindows.org/) works well for Windows.

Run `vagrant up`, then wait awhile for it to complete. Connection details will be displayed once the server is ready. That's it!

Run `vagrant ssh` to control your server directly.

By default, phpMyAdmin should be available at http://192.168.33.10/phpmyadmin/ with the username `admin` and password `apass`.

## Add other Repos
Clone any repo(s) you'd like into the `webroot` directory, preferably applications built for PHP 8 & MySQL (MariaDB).

They will be avaiable at http://192.168.33.10/[directory]/

# Shut it down
When you're done for the day, run `vagrant halt` to shut down the server.

If you want to wipe the server entirely, run `vagrant destroy -f`.
