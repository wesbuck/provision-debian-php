#!/usr/bin/env bash

######################################################################
## 
## Intended for Debian 10 (buster) Vagrant boxes
##
## Debian already comes with many of the needed packages, including:
##  - git,wget, curl, gzip, ca-certificates, lsb-release, sed
##
######################################################################

## Server settings
SERVER_TIMEZONE="America/Toronto"

## Database settings
ROOT_DB_PASSWORD="rpass"
ADMIN_DB_NAME="admin"
ADMIN_DB_PASSWORD="apass"

## PHP settings
PHP_VERSION="8.1"
PHP_MODULES=(curl dev gd mbstring zip mysql xml imagick json mcrypt soap cli memcached redis gmp mongodb odbc pgsql sqlite3 xsl)

echo -e "\n\n============================================================\n"
echo -e " Begin provisioning PHP ${PHP_VERSION} server\n"
echo -e "   Expected:  Debian GNU/Linux 11 (bullseye)"
echo -e "   Found:     $(lsb_release -ds)"
echo -e "\n============================================================\n\n"


echo -e " ==> Preparing the server"
echo -e "      - updating"
sudo apt-get update >/dev/null 2>&1
echo -e "      - upgrading"
sudo apt-get upgrade >/dev/null 2>&1
echo -e "     Done\n"


echo -e " ==> Configuring date/time"
echo -e "      - setting timezone"
sudo timedatectl set-timezone ${SERVER_TIMEZONE}
echo -e "      - enabling clock synchronization"
sudo apt-get install -y ntp >/dev/null 2>&1
echo -e "     Done\n"

# Uncomment below & replace [other] with the name of any app you'd like to install
# echo -e " ==> Installing [other]"
# sudo apt-get install -y [other] >/dev/null 2>&1
# echo -e "     Done\n"


echo -e " ==> Setting up apache"
echo -e "      - installing apache2"
sudo apt-get install -y apache2 >/dev/null 2>&1
echo -e "      - enabling mods"
sudo a2enmod rewrite >/dev/null 2>&1
echo -e "      - configuring"
echo "ServerName localhost" >> /etc/apache2/apache2.conf
echo -e "     Done\n"


echo -e " ==> Setting up PHP ${PHP_VERSION}"
echo -e "      - installing dependencies"
sudo apt-get install -y apt-transport-https >/dev/null 2>&1
echo -e "      - importing PHP repo key"
sudo wget -qO - https://packages.sury.org/php/apt.gpg | sudo apt-key add - >/dev/null 2>&1
echo -e "      - adding PHP repo to local system"
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list >/dev/null 2>&1
echo -e "      - updating app cache"
sudo apt-get update >/dev/null 2>&1
echo -e "      - installing PHP ${PHP_VERSION}"
sudo apt-get install -y php${PHP_VERSION} >/dev/null 2>&1
echo -e "      - preparing to install modules"
sudo apt-get install -y php-pear >/dev/null 2>&1
for module in ${PHP_MODULES[@]}; do
    echo -e "        - installing php${PHP_VERSION}-${module}"
    sudo apt-get install -y php${PHP_VERSION}-${module} >/dev/null 2>&1
done
echo -e "      - installing composer"
sudo curl -s https://getcomposer.org/installer | php >/dev/null 2>&1
sudo mv composer.phar /usr/local/bin/composer
echo -e "     Done\n"


echo -e " ==> Preparing database"
echo -e "      - installing MariaDB server"
sudo apt-get install -y mariadb-server >/dev/null 2>&1
echo -e "      - configuring database"
sudo mysql -u root << EOF
SET PASSWORD FOR 'root'@localhost = PASSWORD('${ROOT_DB_PASSWORD}');
GRANT ALL ON *.* TO '${ADMIN_DB_NAME}'@'localhost' IDENTIFIED BY '${ADMIN_DB_PASSWORD}' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF
echo -e "      - restarting services"
sudo systemctl restart mysql
sudo systemctl restart apache2
echo -e "     Done\n"


echo -e " ==> Setting up PHPMyAdmin"
PHPMYADMIN_DIR="/var/www/html/phpMyAdmin"
echo -e "      - importing keyring"
sudo wget https://files.phpmyadmin.net/phpmyadmin.keyring >/dev/null 2>&1
sudo gpg --import phpmyadmin.keyring >/dev/null 2>&1
echo -e "      - fetching latest package"
sudo wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz >/dev/null 2>&1
echo -e "      - verifying package"
sudo wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz.asc >/dev/null 2>&1
sudo gpg --verify phpMyAdmin-latest-all-languages.tar.gz.asc >/dev/null 2>&1
echo -e "      - unpacking"
sudo mkdir ${PHPMYADMIN_DIR} >/dev/null 2>&1
sudo tar xvf phpMyAdmin-latest-all-languages.tar.gz --strip-components=1 -C ${PHPMYADMIN_DIR} >/dev/null 2>&1
echo -e "      - configuring"
sudo cp ${PHPMYADMIN_DIR}/config.sample.inc.php ${PHPMYADMIN_DIR}/config.inc.php >/dev/null 2>&1
echo "\$cfg['CheckConfigurationPermissions'] = false;" | sudo tee -a ${PHPMYADMIN_DIR}/config.inc.php >/dev/null 2>&1
echo -e "      - generating secret"
randomBlowfishSecret=$(openssl rand -base64 32)
sudo sed -i -e "s|cfg\['blowfish_secret'\] = ''|cfg['blowfish_secret'] = '${randomBlowfishSecret}'|g" ${PHPMYADMIN_DIR}/config.inc.php
echo -e "      - setting permissions"
sudo chown -R www-data:www-data ${PHPMYADMIN_DIR} >/dev/null 2>&1
sudo chmod -R 755 ${PHPMYADMIN_DIR} >/dev/null 2>&1
sudo chmod 640 ${PHPMYADMIN_DIR}/config.inc.php >/dev/null 2>&1
echo -e "      - cleaning up"
sudo rm phpmyadmin.keyring phpMyAdmin-latest-all-languages.tar.gz*
echo -e "      - restarting services"
sudo systemctl restart mysql
sudo systemctl restart apache2
echo -e "     Done\n"


echo -e "\n============================================================\n"
echo -e " Done provisioning PHP ${PHP_VERSION} server\n"
echo -e "  Server information"
echo -e "   IP address:             $(hostname -I | cut -d ' ' -f2)"
echo -e "   Timezone:               ${SERVER_TIMEZONE}"
echo -e "   Date:                   $(date)\n"
echo -e "  Database information"
echo -e "   root password:          ${ROOT_DB_PASSWORD}"
echo -e "   admin username:         ${ADMIN_DB_NAME}"
echo -e "   admin password:         ${ADMIN_DB_PASSWORD}"
echo -e "   phpMyAdmin directory:   ${PHPMYADMIN_DIR}\n"
echo -e "  By default, phpMyAdmin should be available at"
echo -e "   http://192.168.33.10/phpmyadmin/"
echo -e "\n============================================================\n\n"
